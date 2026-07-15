Agnostic Router — roteamento comportamental de modelo

Objetivo: decidir qual tier de modelo (barato/médio/caro) chamar antes de cada requisição a um LLM, lendo a FASE do trabalho + sinais + estado da sessão — não por keyword map. Corta custo rodando o modelo pesado só quando o raciocínio exige, sem sacrificar qualidade nas tarefas difíceis.

Implementação de referência (Python, agnóstica de provider): `scripts/agnostic-router/router.py`.
Racional de design e casos de borda: `docs/agnostic-router-design.md`.

**Política vs mecanismo:** a *política* de tiers (o quê rotear pra qual tier, quando não
rebaixar) vive em `skills/behavioral/model-routing.md`. Esta skill é o **mecanismo** que
automatiza aquela política — as fases abaixo mapeiam nos Tiers 1/2/3 de lá (design/review→1,
implement/debug→2, explore/operate→3).

---

## Por que não keyword map

A mesma palavra significa coisas diferentes conforme o momento:

- **"muda"** em "o que muda entre HTTP/1.1 e HTTP/2?" → explorar → tier barato.
- **"muda"** com código colado → implementar → tier médio.
- **"muda"** depois de 2 turnos de erro → debug travado → tier caro.

A unidade de decisão é a **fase de trabalho**, derivada de sinais ponderados + estado da
sessão, não de um dicionário estático `palavra → modelo`.

## O eixo: fase de trabalho → tier base

| Fase | Momento | Tier base |
|------|---------|-----------|
| `explore` | entender, tirar dúvida, pesquisar | barato (Haiku) |
| `operate` | extrair, resumir, listar, rodar | barato (Haiku) |
| `implement` | escrever/alterar código concreto | médio (Sonnet) |
| `debug` | investigar falha, achar causa raiz | médio → caro se travar |
| `design` | planejar, arquitetar, decidir trade-off | caro (Opus) |
| `review` | revisar, criticar, auditar segurança | caro (Opus) |

A fase dá o tier base; modificadores ajustam pra cima ou pra baixo.

## Ordem de decisão (o contrato)

1. **Hard override** do chamador (usuário fixou modelo) — vence tudo.
2. **Tier base pela fase.**
3. **Escalada por pressão** = `complexidade·0.5 + escopo·0.3 + autonomia·0.2`. Acima do
   limiar sobe 1 tier; muito acima, sobe 2.
4. **Debug travado**: ≥ N turnos consecutivos no mesmo bug → força o tier caro. É uma
   escalada comportamental **forçada** — a histerese não pode desfazê-la.
5. **Piso de risco**: risco alto nunca roda no tier barato; risco crítico sobe 1 tier
   (também forçado).
6. **Rebaixamento por latência**: só quando risco E complexidade são baixos e a fase não
   é design/review — respeita "só me diz rápido" sem nunca vencer o risco.
7. **Histerese**: sinal fraco não troca de tier a cada turno (evita zigue-zague de custo),
   exceto sobre escaladas forçadas.

## Sinais lidos

- **Da mensagem**: fase, complexidade, escopo, risco, preferência de latência, autonomia
  (agentic longo), código/stacktrace embutido, tamanho do texto.
- **Da sessão** (o que só o histórico revela): último tier, fase anterior, turnos travados
  em debug, arquivos tocados, erro visto no turno anterior, contexto acumulado.

## Integração no orquestrador

O router roda **antes** da chamada ao endpoint. Interface pequena e estável:

```python
from router import Router, RouterConfig, SessionState, Tier

# 1) Mapa tier -> model_id do SEU deployment (agnóstico de provider)
cfg = RouterConfig(model_map={
    Tier.HAIKU:  "claude-haiku-4-5-20251001",
    Tier.SONNET: "claude-sonnet-5",
    Tier.OPUS:   "claude-opus-4-8",
})
router = Router(cfg)
session = SessionState()               # uma por conversa

# 2) A cada turno, roteie ANTES de chamar o endpoint
decision = router.route(user_message, session)
resp = client.messages.create(model=decision.model_id, messages=[...])

# 3) Atualize o estado DEPOIS (alimenta debug-travado, histerese, escopo, contexto)
router.update_session(session, decision, assistant_reply=resp_text,
                      files_touched_delta=n_arquivos_do_turno)
```

**Contrato:** `route(message, session) -> Decision` com `tier`, `model_id`, `confidence`,
`signals`, `reasons`, `overridden_by`. Determinístico (mesma entrada + estado → mesma
decisão), sem rede, provider-agnostic (troque só `model_map`).

## Enforcement real vs. protocolo declarado

Distinção honesta — não confunda os dois:

- **No orquestrador**, o router é **lei**: o core chama `route()` antes de cada requisição;
  o modelo não tem como não passar por ele.
- **Em CLI interativa** (ex.: Claude Code), o modelo do turno já foi escolhido antes da
  mensagem chegar — o router não se rebobina. Ali ele vira **protocolo declarado**: o agente
  decide e registra o tier (`[router: <tier> | fase=<fase> | conf=<0..1>]`), e hooks tornam
  isso visível. Funciona por convenção + visibilidade, não por trava técnica.

## Ciclo de vida de sessão

O estado comportamental que faz o roteamento não recomeçar do zero a cada turno vive na
**memória de sessão** (efêmera). Ao integrar num fluxo de abrir/fechar sessão:

- **Abrir**: carregue o estado anterior (se houver handoff), roteie, declare o tier.
- **Fechar / handoff**: persista `tier_final`, `fase_final`, `debug_travado` e
  `arquivos_tocados` — a próxima sessão herda o roteamento em vez de reclassificar do zero.
  Se `debug_travado ≥ N` ou risco alto, a retomada nunca "esfria" pra um tier menor.

Neste repo, essa persistência está embutida nos comandos `skills/workflow/abrirsessao.md`
e `skills/workflow/fecharsessao.md` (seção "Roteamento de modelo").

### Sessão vs. memória de longo prazo

- **Estado que muda a cada turno** → memória de sessão (efêmera, o router gerencia). Nunca
  vai pra memória de longo prazo — gravar `debug_travado=2` lá poluiria decisões futuras.
- **Preferência durável de roteamento** → memória de longo prazo, aplicada via `hard_override`.
  Ex.: "tarefas fiscais nunca abaixo do tier caro" vira uma regra de override, não um sinal.

## Calibração e extensão

- Limiares vivem em `RouterConfig` (`escalate_at`, `downgrade_latency_at`, `risk_floor_at`,
  `stuck_debug_turns`, `hard_override`) — ajuste sem editar a lógica.
- Rode `scripts/agnostic-router/eval.py` sobre um log rotulado do SEU tráfego e ajuste os
  limiares até o custo/qualidade bater a meta.
- **Novos sinais**: adicione marcadores regex ponderados. **Nova fase**: adicione o léxico e
  o tier base. **Idiomas**: o léxico cobre pt-BR + en; acrescente padrões por idioma.

## Limites conhecidos

- Regex, não classificador ML — escolha deliberada: determinístico, auditável, zero latência
  e custo. Para alto volume ambíguo, plugue um classificador barato como sinal *adicional*
  (quebra-empate de fase) via `hard_override`, não como substituto.
- Léxico pt-BR + en; outros idiomas caem no default por fase.
- Confiança é heurística (margem entre 1ª e 2ª fase), serve pra logging/desambiguação, não é
  probabilidade calibrada.

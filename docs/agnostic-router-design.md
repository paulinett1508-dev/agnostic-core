# agnostic-router — design e casos de borda

Racional das decisões, para quem for manter ou estender o router. A skill está em
`skills/ai/agnostic-router.md`; a implementação de referência em
`scripts/agnostic-router/router.py`.

## Princípio: fase de trabalho, não palavra-chave

Um keyword map (`palavra -> modelo`) falha porque a intenção depende do **momento**,
não do termo. Três exemplos onde a mesma palavra roteia diferente:

- **"muda"** em `"o que muda entre HTTP/1.1 e HTTP/2?"` → explorar → Haiku.
- **"muda"** em `"muda esse if pra switch"` (com código) → implementar → Sonnet.
- **"muda"** logo após dois turnos de erro → debug travado → Opus.

Por isso a unidade de decisão é a `WorkPhase`, derivada de sinais ponderados +
estado da sessão, não de um dicionário estático.

## Os dois níveis de sinal

**Nível mensagem** (o que dá pra ler no turno atual): fase, complexidade, escopo,
risco, latência, autonomia, código/stacktrace embutido.

**Nível sessão** (o que só o histórico revela): último tier usado, fase anterior,
turnos consecutivos travados em debug, arquivos já tocados, se a resposta anterior
continha erro, contexto acumulado. É esse nível que torna o roteamento "comportamental"
e não só "textual".

## Ordem de decisão e por quê

1. **Hard override primeiro** — se o usuário fixou modelo, nada sobrescreve. Respeito à intenção explícita.
2. **Fase → tier base** — a espinha dorsal.
3. **Pressão (complexidade+escopo+autonomia) escala** — tarefa grande sobe de tier mesmo dentro da mesma fase. Ex.: implementar 1 função (Sonnet) vs. implementar um subsistema (Opus).
4. **Debug travado → Opus** — sinal comportamental puro: se Sonnet não resolveu em N turnos, o problema é mais difícil do que parecia; vale o custo do Opus. Sem isso, o usuário fica preso num loop de respostas insuficientes.
5. **Piso de risco** — risco alto nunca roda em Haiku, mesmo que a fase seja trivial. "Deleta em produção" é curto (parece Haiku) mas caro de errar.
6. **Rebaixamento por latência** — respeita "só me diz rápido", mas *só* quando risco e complexidade são baixos. A latência nunca vence o risco.
7. **Histerese por último** — depois de tudo decidido, se a mudança é de só 1 tier e o sinal é fraco, mantém o modelo anterior. Sem isso, o custo oscila a cada turno e a experiência fica errática.

### Escaladas forçadas vs. histerese

A histerese (passo 7) roda **depois** de debug-travado (4) e piso de risco (5). Sem
salvaguarda, ela reverteria exatamente essas subidas quando a mensagem do turno é fraca
— que é justo o caso do debug travado ("continua o mesmo erro" tem sinal textual baixo).

Por isso debug-travado e risco-crítico marcam a decisão como **escalada forçada**, e a
histerese não age sobre escaladas forçadas. Regra: um sinal comportamental que motivou a
subida não pode ser silenciosamente desfeito por um sinal textual fraco no mesmo turno.

## Casos de borda tratados

- **Mensagem curta de continuação** (`"e agora?"`, `"continua"`): sinal fraco na mensagem → herda a fase anterior da sessão, não cai em explore/Haiku por engano.
- **Stacktrace colado**: força DEBUG mesmo sem palavra de erro no texto em prosa.
- **Código colado sem verbo claro**: default vira IMPLEMENT (não EXPLORE), porque quem cola código quer ação sobre ele.
- **Pedido rápido mas arriscado** (`"rápido, dropa a tabela X"`): latência quer rebaixar, mas o piso de risco impede — vence o risco.
- **Escopo amplo mas raso** (`"renomeia em todos os arquivos"`): escopo alto, complexidade baixa → NÃO escala pra Opus. Renomear em massa é mecânico; Sonnet dá conta. Escopo só escala quando combina com complexidade real.
- **Contexto acumulado grande**: sessão longa (`tokens_in_context` alto, alimentado por `update_session`) adiciona pressão de complexidade — sustentar raciocínio sobre muito contexto é mais caro.

## Estado de sessão — quem alimenta o quê

O router não enxerga o mundo fora da mensagem; o orquestrador injeta o resto via
`update_session()` depois de cada turno:

- `consecutive_debug_turns`, `last_tier`, `last_phase`, `error_seen_recently` — derivados
  automaticamente da decisão e da resposta.
- `files_touched` — passe `files_touched_delta` com o nº de arquivos que o turno tocou;
  acumula e alimenta o sinal de escopo (≥ 5 arquivos aumenta o escopo).
- `tokens_in_context` — passe a contagem real se tiver; senão acumula uma estimativa em
  chars a partir da resposta. Alimenta a pressão de complexidade em sessões longas.

## Limites conhecidos (honestos)

- **Léxico é pt-BR + en**. Outros idiomas caem no default por fase; adicione padrões.
- **Regex, não classificador ML**. Escolha deliberada: determinístico, auditável, zero latência, zero custo, sem dependência. Para casos ambíguos de alto volume, dá pra plugar um classificador Haiku como sinal *adicional* (não substituto) via `hard_override`.
- **Os pesos são um chute inicial informado.** A calibração real é rodar `eval.py` sobre o SEU log de tráfego rotulado e ajustar `RouterConfig`. Os defaults miram economia ~55–60% vs. tudo-Opus mantendo qualidade nas tarefas pesadas.
- **Confiança é heurística** (margem entre a 1ª e a 2ª fase mais pontuada), não probabilidade calibrada. Serve pra logging e pra decidir quando pedir desambiguação, não como garantia estatística.

## Como evoluir

Se um classificador for desejável no futuro, o ponto de extensão limpo é: manter o router
regex como baseline determinístico e usar o sinal do classificador para **quebrar empates**
de fase (quando `phase_scores` das duas primeiras estão a < 0.1 de distância). Assim você
ganha precisão sem perder determinismo nem introduzir latência no caminho comum.

Model Routing

Objetivo: Escolher o modelo certo para cada tipo de tarefa, otimizando custo e velocidade sem sacrificar qualidade onde ela importa.

Inspirado no conceito Smart Model Dispatch de andersonlimadev (TabNews, 2025) e na documentacao oficial do Claude Code.

---

PRINCIPIO

Nao faz sentido usar o modelo mais poderoso para gerar boilerplate. Reserve poder computacional para onde ele faz diferenca — arquitetura, decisoes complexas, raciocinio profundo.

O roteamento de modelos se aplica a qualquer ferramenta que permita selecionar modelos: Claude Code (/model), Cursor, APIs diretas, pipelines de CI com LLM.

---

POLITICA vs MECANISMO

Esta skill e a POLITICA — o quê rotear pra qual tier e quando nao rebaixar. E a heuristica
que o agente aplica ao usar /model, despachar um subagente ou configurar uma ferramenta.

Para AUTOMATIZAR essa politica num orquestrador — decidir o tier por fase de trabalho +
estado de sessao, antes de cada chamada a API, de forma deterministica — use o motor
`skills/ai/agnostic-router.md`. As fases do agnostic-router mapeiam direto nos tiers abaixo:

  Tier 1 (Opus)   <- fases design, review
  Tier 2 (Sonnet) <- fases implement, debug
  Tier 3 (Haiku)  <- fases explore, operate

  Tier 0 (Fable) nao tem fase mapeada — nenhuma fase de trabalho, isolada, decide
  sozinha quando um raciocinio excede o teto do Opus. Fora do acionamento manual
  (hard_override), so escala automaticamente em duas combinacoes raras de sinais
  (ver TIER 0 abaixo) — nunca por complexidade/escopo/risco isolados.

Uma so politica, dois modos de aplicar: mentalmente (esta skill) ou pelo engine (aquela).

---

TABELA DE ROTEAMENTO

  TIER 0 — Julgamento superior (Fable):
  - Automatico em dois gatilhos raros e verificaveis (motor `agnostic-router`):
    (a) DEBUG super-travado — o Opus (Tier 1) ja foi tentado por varias rodadas
    seguidas no mesmo bug e nao resolveu (limiar bem acima do que ja escala pra
    Opus); (b) risco critico E pressao extrema no MESMO turno — cada sinal
    isolado ja escala pra Opus, so a co-ocorrencia sobe alem dele
  - Fora desses dois gatilhos: manual — pedido explicito do usuario ou do
    orquestrador (hard_override), tipicamente pra decisao de maior alcance no
    ecossistema (cross-repo, cross-constelacao), irreversivel ou de altissimo
    custo de erro, mesmo sem os sinais de sessao acima
  - Ressalva: a posicao do Fable acima do Opus foi adotada por decisao explicita de
    quem opera este acervo — nao e um benchmark proprio validado aqui. Nao presumir
    esse ranking em contextos onde a superioridade nao foi confirmada

  TIER 1 — Raciocinio complexo (Opus ou equivalente):
  - Planejamento de arquitetura e design de sistema
  - Analise de requisitos e decisoes com trade-offs
  - Refatoracao de codigo complexo com multiplas dependencias
  - Debug de problemas que envolvem multiplos sistemas
  - Revisao de seguranca e analise de vulnerabilidades
  - Decisoes arquiteturais que afetam o projeto inteiro

  TIER 2 — Implementacao padrao (Sonnet ou equivalente):
  - Logica de negocio (use cases, repositories, services)
  - Implementacao de componentes/telas com logica
  - Integracoes com APIs e bancos de dados
  - Code review de PRs
  - Testes de integracao e E2E
  - Documentacao tecnica que requer entendimento do codigo

  TIER 3 — Tarefas mecanicas (Haiku ou equivalente):
  - Geracao de arquivos de estilo (.styles.ts, CSS modules)
  - Traducoes e arquivos de i18n
  - Boilerplate e scaffolding
  - Mocks e fixtures de teste
  - Testes unitarios simples (AAA pattern)
  - Formatacao e ajustes cosmeticos
  - Leitura e exploracao de arquivos

---

DISPATCH PARALELO

Para features complexas, diferentes etapas podem usar modelos diferentes:

  Exemplo: "Implementar feature Watchlist"

  Fase 1 — [TIER 1] Planejar arquitetura
    Definir entidades, fluxo de dados, dependencias, API contracts.

  Fase 2 — [TIER 2] Implementar domain + data layers
    Use cases, repositories, models, integracoes.

  Fase 3 — [TIER 2] Implementar presentation layer
    Telas, componentes, view models, navegacao.

  Fase 4 — [TIER 3] Gerar artefatos mecanicos
    Estilos, traducoes, mocks, boilerplate de testes.

  Fase 5 — [TIER 3] Escrever testes unitarios
    Testes para cada camada seguindo patterns definidos na fase 1.

---

COMO APLICAR

  Claude Code:
  Usar /model para alternar entre modelos durante a sessao.
  O alias opusplan alterna automaticamente: opus em plan mode, sonnet em execucao.

  O agnostic-router (mecanismo, ver acima) roda automaticamente via hooks
  UserPromptSubmit + Stop, registrados por install.sh/install.ps1 em
  ~/.claude/settings.json (a menos que --no-hook seja usado).

  Cursor / Copilot:
  Configurar modelo por tipo de tarefa nas settings do editor.

  APIs diretas:
  Selecionar modelo programaticamente baseado no tipo de operacao:

    const MODEL_BY_TIER = {
      superior: '<id do modelo top-of-tier atual, ex.: familia Fable>',
      complex: '<id do Opus vigente>',
      standard: '<id do Sonnet vigente>',
      mechanical: '<id do Haiku vigente>'
    }

  NAO fixar aqui o id exato de cada modelo — eles mudam a cada lancamento (Opus 5
  vira Opus 6, etc.) e a Messages API crua exige o id completo e correto, sem
  aceitar alias de familia. Fonte viva do id atual por tier: skill `claude-api`
  (secao "Current Models") ou o catalogo do seu proprio deployment. Isso vale pros
  quatro tiers, nao so pro Fable — o codigo do agnostic-router (`router.py`/
  `router.js`) mantem um default versionado que precisa do mesmo cuidado de
  atualizacao, documentado la mesmo.

  Tier "superior" (Fable) so deve ser selecionado por override explicito do chamador
  (usuario ou orquestrador) OU pelos dois gatilhos automaticos raros descritos no
  TIER 0 acima — nunca pela mesma logica automatica de pressao/escopo/autonomia que
  escolhe entre os outros tres.

  Pipelines de CI:
  Usar modelo mais barato para linting, formatacao, geracao de changelogs.
  Reservar modelos potentes para analise de seguranca e code review automatizado.

---

IMPACTO EM CUSTO

A diferenca de custo entre tiers e significativa:

  Tier 3 (Haiku) custa ~80% menos que Tier 2 (Sonnet)
  Tier 2 (Sonnet) custa ~80% menos que Tier 1 (Opus)

Em um projeto tipico, ~60% das tarefas sao Tier 2 e ~25% sao Tier 3.
Rotear corretamente pode reduzir custos em 40-60% sem perda de qualidade.

Tier 0 (Fable) fica fora dessa distribuicao — e excecao rara (manual, ou os dois
gatilhos automaticos do motor), nao rotineiro. Se aparecer com frequencia comparavel a
Tier 1, e sinal de que os limiares do motor estao calibrados baixo demais, ou de que
esta sendo usado como default disfarcado — nao como excecao deliberada.

---

QUANDO NAO ROTEAR PARA BAIXO

Manter no tier mais alto quando:
- A tarefa envolve seguranca (autenticacao, autorizacao, criptografia)
- O erro tem custo alto (dados financeiros, dados de usuario, producao)
- O contexto e ambiguo e requer interpretacao cuidadosa
- A decisao afeta a arquitetura do projeto a longo prazo

Na duvida, use o tier acima. O custo de um bug causado por modelo insuficiente e maior que a economia de tokens.

---

CHECKLIST

- [ ] Classificar a tarefa atual em tier antes de iniciar
- [ ] Usar modelo adequado ao tier (nao o mais caro por padrao)
- [ ] Para features complexas, planejar dispatch por fase
- [ ] Manter tier alto para decisoes de seguranca e arquitetura
- [ ] Fable (Tier 0) so escala automatico nos dois gatilhos definidos (debug
      super-travado; risco critico + pressao extrema simultaneos) — fora disso,
      so por decisao explicita
- [ ] Revisar custos periodicamente e ajustar roteamento se necessario

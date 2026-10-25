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
  Effort: max
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
  Effort: xhigh
  - Planejamento de arquitetura e design de sistema
  - Analise de requisitos e decisoes com trade-offs
  - Refatoracao de codigo complexo com multiplas dependencias
  - Debug de problemas que envolvem multiplos sistemas
  - Revisao de seguranca e analise de vulnerabilidades
  - Decisoes arquiteturais que afetam o projeto inteiro

  TIER 2 — Implementacao padrao (Sonnet ou equivalente):
  Effort: high
  - Logica de negocio (use cases, repositories, services)
  - Implementacao de componentes/telas com logica
  - Integracoes com APIs e bancos de dados
  - Code review de PRs
  - Testes de integracao e E2E
  - Documentacao tecnica que requer entendimento do codigo

  TIER 3 — Tarefas mecanicas (Haiku ou equivalente):
  Effort: high
  - Geracao de arquivos de estilo (.styles.ts, CSS modules)
  - Traducoes e arquivos de i18n
  - Boilerplate e scaffolding
  - Mocks e fixtures de teste
  - Testes unitarios simples (AAA pattern)
  - Formatacao e ajustes cosmeticos
  - Leitura e exploracao de arquivos

---

EFFORT (quanto o modelo raciocina)

O tier escolhe o modelo; o effort escolhe quanto ele raciocina. Subir effort nao
substitui subir tier: Sonnet em effort max nao vira Opus para decisao arquitetural.

  Mapeamento: Fable max · Opus xhigh · Sonnet high · Haiku high
  Niveis: low, medium, high, xhigh, max

  Onde aplicar:
  - Sessao: /effort <nivel> (com a flag de padrao, vale para sessoes novas)
  - Subagent: parametro effort do dispatch, so quando esta tabela e aplicada
  - API direta: parametro de effort da requisicao, se o modelo suportar o nivel

  Ajuste: na duvida, suba effort junto com o tier, nunca so um dos dois. Se o
  modelo nao suportar o nivel indicado, use o mais proximo disponivel.

  Ressalva: o mapeamento e politica, nao benchmark validado neste acervo.

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

  Versao selecionada:
  - Claude Code (/model com alias opus, sonnet, haiku): o alias aponta para a
    versao mais recente da familia. A skill nao fixa numero de versao.
  - Messages API direta: aceita so o ID completo, informado pelo caller. Fonte
    viva dos IDs: skill `claude-api` (secao "Current Models").
  - Engine agnostic-router: usa DEFAULT_MODEL_MAP (router.py / router.js). Esse
    mapa precisa estar sincronizado com a tabela vigente; defasado, escolhe
    versao antiga ou ID inexistente.

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

Ressalva: esses percentuais sao ordem de grandeza, nao medicao deste acervo; precos mudam
a cada lancamento. Para decidir com numero, medir o consumo real por tier na sua conta
(skill `context-audit`, secao COMO MEDIR O RESULTADO) antes de apertar o roteamento.

Tier 0 (Fable) fica fora dessa distribuicao — e excecao rara (manual, ou os dois
gatilhos automaticos do motor), nao rotineiro. Se aparecer com frequencia comparavel a
Tier 1, e sinal de que os limiares do motor estao calibrados baixo demais, ou de que
esta sendo usado como default disfarcado — nao como excecao deliberada.

---

ESCALONAMENTO PARA REVISAO (ADVISOR)

Subir o tier muda QUEM executa; nao revisa SE a abordagem esta certa. Para decisao de
alto risco (financeiro, migracao/escrita em dados, deploy, seguranca, consolidacao que
atinge usuario real), a resposta nao e so rotear o subagent para o tier mais alto —
e tambem chamar a ferramenta `advisor` antes de cravar a abordagem e antes de declarar
concluido. Quando e como: skill `advisor-checkpoints`. A lista de areas obrigatorias
e do projeto, declarada no CLAUDE.md dele.

JULGAMENTO OU EXECUCAO (qual alavanca puxar)

Antes de subir o tier, identifique onde esta a dificuldade:

  - Dificuldade de JULGAMENTO (qual abordagem, qual trade-off, o que pode quebrar): puxe o
    advisor. Uma chamada no ponto certo custa menos do que rodar a tarefa inteira no tier
    acima, e mira exatamente o que o tier maior melhoraria.
  - Dificuldade de EXECUCAO (muito codigo interdependente, raciocinio longo e continuo
    dentro da propria implementacao): suba o tier e o effort do executor.
  - As duas ao mesmo tempo, ou area obrigatoria do projeto: as duas alavancas.

Padrao economico que mantem a resolutividade: executor no Tier 2 ou 3, advisor nas duas
pontas (abordagem e conclusao) quando a tarefa pedir, tier alto reservado ao que e
julgamento continuo. Na duvida sobre onde esta a dificuldade, continua valendo "use o tier
acima" (ver QUANDO NAO ROTEAR PARA BAIXO).

ECONOMIA DE TOKENS NO ROTEAMENTO

  1. Rotear na fronteira de fase ou por subagent, nao a cada turno. O cache de prompt e
     por modelo: trocar de modelo no meio de uma conversa longa tende a reprocessar o
     contexto inteiro sem cache. Um subagent comeca com contexto novo e pequeno; uma
     sessao longa que alterna /model paga o historico de novo.
  2. Delegar o ruidoso ao tier barato. Exploracao, busca e leitura de muitos arquivos vao
     para um subagent Tier 3 com prompt autocontido, que devolve so a conclusao e os
     caminhos relevantes. O contexto do executor caro fica limpo.
  3. Brief completo e curto. Subagent sem o contexto necessario refaz leitura e erra;
     com contexto de sobra, gasta. Objetivo, arquivos, o que ja foi descartado e formato
     da resposta esperada.
  4. Um despacho por tarefa independente, em paralelo quando nao ha dependencia; nunca o
     mesmo trabalho em dois subagents "por garantia".
  5. Revisao do conjunto pelo advisor, nao por subagent (ver `advisor-checkpoints`).

  O que a economia nao toca: tier e effort de seguranca, dados de producao, deploy e
  arquitetura; as chamadas de advisor em area obrigatoria; o contexto necessario para o
  executor entender a logica antes de editar. Economizar token lendo menos so vale ate o
  ponto em que o modelo ainda entende o sistema; abaixo disso o retrabalho custa mais.

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
- [ ] Definir effort junto com o tier (ver EFFORT)
- [ ] Para features complexas, planejar dispatch por fase
- [ ] Manter tier alto para decisoes de seguranca e arquitetura
- [ ] Decisao de alto risco: alem do tier alto, chamar o advisor (ver ESCALONAMENTO PARA REVISAO)
- [ ] Dificuldade e de julgamento ou de execucao? Advisor para o primeiro, tier e effort para o segundo
- [ ] Nao alternar de modelo a cada turno numa sessao longa: rotear por fase ou por subagent
- [ ] Exploracao ruidosa delegada a subagent Tier 3 que devolve so a conclusao
- [ ] Fable (Tier 0) so escala automatico nos dois gatilhos definidos (debug
      super-travado; risco critico + pressao extrema simultaneos) — fora disso,
      so por decisao explicita
- [ ] Revisar custos periodicamente e ajustar roteamento se necessario

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

  Tier 0 (Fable) nao tem fase mapeada — nenhuma heuristica de regex decide sozinha
  quando um raciocinio excede o teto do Opus. So entra por acionamento manual
  (hard_override), nunca por escalada automatica de pressao/risco/fase.

Uma so politica, dois modos de aplicar: mentalmente (esta skill) ou pelo engine (aquela).

---

TABELA DE ROTEAMENTO

  TIER 0 — Julgamento superior, acionamento manual (Fable):
  - Nunca disparado automaticamente pelo motor de roteamento — exige pedido explicito
    do usuario ou do orquestrador
  - Uso: Tier 1 (Opus) ja foi tentado numa tarefa e o resultado ficou aquem do
    necessario
  - Uso: decisao de maior alcance no ecossistema (cross-repo, cross-constelacao),
    irreversivel ou de altissimo custo de erro, onde vale a pena um segundo julgamento
    acima do teto padrao
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
      superior: 'claude-fable-5-1',
      complex: 'claude-opus-5',
      standard: 'claude-sonnet-5',
      mechanical: 'claude-haiku-4-5-20251001'
    }

  Tier "superior" (Fable) so deve ser selecionado por override explicito do chamador
  (usuario ou orquestrador) — nunca pela mesma logica automatica que escolhe entre os
  outros tres. Outros modelos adicionais que nao o Fable podem existir sem tier
  definido — nao presumir onde encaixam sem validar o caso de uso real primeiro.

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

Tier 0 (Fable) fica fora dessa distribuicao — e manual, nao rotineiro. Se aparecer com
frequencia comparavel a Tier 1, e sinal de que esta sendo usado como default disfarcado,
nao como excecao deliberada.

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
- [ ] Fable (Tier 0) so entra por decisao explicita, nunca escalada automatica
- [ ] Revisar custos periodicamente e ajustar roteamento se necessario

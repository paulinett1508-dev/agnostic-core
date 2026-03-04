Model Routing

Objetivo: Escolher o modelo certo para cada tipo de tarefa, equilibrando qualidade e custo. Usar modelos mais capazes para trabalho complexo e modelos mais rapidos para tarefas mecanicas.

---

POR QUE FAZER MODEL ROUTING

Nem toda tarefa precisa do modelo mais caro. A maioria das ferramentas de AI (Claude Code, Cursor, etc.) permite escolher o modelo por tarefa ou subagent.

Distribuicao tipica de tarefas em um projeto:
  ~10% precisa de raciocinio complexo (arquitetura, decisoes criticas)
  ~60% sao implementacao padrao (business logic, componentes, integracao)
  ~30% sao tarefas mecanicas (boilerplate, testes simples, formatacao)

Usar o modelo mais caro para 100% das tarefas desperdiça ~60% do custo.

---

TABELA DE DECISAO

  TIER 1 — Modelo mais capaz (ex: Opus)
  Quando usar:
  - Planejamento e decisoes arquiteturais
  - Business logic complexa com multiplas condicoes e edge cases
  - Refatoracao de sistemas inteiros
  - Debugging de problemas nao reproduziveis ou intermitentes
  - Revisao de seguranca e analise de vulnerabilidades
  - Decisoes de trade-off que impactam o projeto a longo prazo
  Caracteristica: tarefas onde um erro de raciocinio tem alto custo

  TIER 2 — Modelo padrao (ex: Sonnet)
  Quando usar:
  - Implementacao de features com requisitos claros
  - Componentes de UI, telas, formularios
  - Integracoes com APIs e servicos
  - CRUD e operacoes de banco padrao
  - Correcao de bugs com causa identificada
  - Testes de integracao e E2E
  Caracteristica: tarefas bem definidas que requerem competencia tecnica

  TIER 3 — Modelo rapido (ex: Haiku)
  Quando usar:
  - Geracao de boilerplate e scaffolding
  - Arquivos de estilo (.styles.ts, .css)
  - Internacionalizacao (i18n) — traducoes e chaves
  - Mocks e fixtures de testes
  - Testes unitarios simples
  - Renomear variaveis, adicionar tipos, formatacao
  - Busca e exploracao de codebase
  Caracteristica: tarefas repetitivas ou mecanicas com baixo risco de erro

---

DISPATCH PARALELO

Para features complexas, divida o trabalho entre modelos em paralelo:

  Exemplo: implementar feature "sistema de notificacoes"

  1. [tier-1] Planejar arquitetura: domain model, fluxo de dados, decisoes de persistencia
  2. [tier-2] Implementar domain layer: entidades, repositorios, servicos
  3. [tier-2] Implementar presentation layer: tela, viewmodel, componentes
  4. [tier-3] Gerar arquivos mecanicos: estilos, i18n, mocks
  5. [tier-3] Escrever testes unitarios para utils e helpers
  6. [tier-2] Escrever testes de integracao do fluxo completo

Passos 2-3 podem rodar em paralelo. Passos 4-5 podem rodar em paralelo.
O passo 1 deve completar antes dos demais.

---

REGRAS DE ESCALACAO

Comece pelo tier mais baixo possivel e escale quando necessario:

  Se a tarefa parece simples mas envolve decisao de design → suba para tier-2
  Se a implementacao padrao gera bugs ou inconsistencias → suba para tier-1
  Se o modelo rapido gera output incorreto → suba para tier-2

Nunca use tier-1 para:
- Gerar boilerplate
- Formatar codigo
- Tarefas que nao envolvem raciocinio

Nunca use tier-3 para:
- Decisoes arquiteturais
- Logica de negocio complexa
- Correcao de bugs sem causa clara

---

ESTIMATIVA DE ECONOMIA

  Cenario sem routing (tudo no modelo padrao):
  100 tarefas x custo tier-2 = 100 unidades

  Cenario com routing:
  10 tarefas x custo tier-1 = 20 unidades (tier-1 custa ~2x tier-2)
  60 tarefas x custo tier-2 = 60 unidades
  30 tarefas x custo tier-3 = 6 unidades  (tier-3 custa ~0.2x tier-2)
  Total = 86 unidades

  Economia estimada: ~14% comparado ao uso uniforme de tier-2
  Economia comparada ao uso uniforme de tier-1: ~57%

A economia real depende da distribuicao de tarefas e dos precos do provedor.

---

IMPLEMENTACAO EM CLAUDE CODE

Claude Code permite especificar modelo ao criar subagents via o parametro `model` do Agent tool:

  model: "opus"   — tier-1, raciocinio complexo
  model: "sonnet"  — tier-2, implementacao padrao
  model: "haiku"   — tier-3, tarefas mecanicas

Esta skill pode ser instalada globalmente em ~/.claude/skills/ para funcionar em qualquer projeto.

---

CHECKLIST

- [ ] Tarefas do projeto foram classificadas por tier (1, 2 ou 3)
- [ ] Modelo padrao definido para a maioria das tarefas (tier-2)
- [ ] Tarefas mecanicas identificadas e direcionadas para tier-3
- [ ] Apenas decisoes complexas usam tier-1
- [ ] Dispatch paralelo considerado para features grandes

---

REFERENCIA

- agent-routing-guide.md: roteamento por dominio (qual agent/skill usar)
- token-optimization.md: economia de tokens no contexto automatico (economia complementar)
- context-management.md: saude do contexto durante a sessao

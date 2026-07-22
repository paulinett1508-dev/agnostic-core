NOME DO PROJETO — Frontend

Stack: React / Vue / Svelte / HTML+CSS+JS vanilla
Submodulo: .agnostic-core/

---

## ⛔ Regra #0 — Nunca design com cara de IA

Nenhuma tela, HTML, CSS ou layout pode parecer gerado por IA por omissao de decisao.
"Cara de IA" = genericidade: reproduzir a media de landing pages de SaaS em vez de
escolhas especificas ao dominio. Antes de gerar frontend, aplicar
.agnostic-core/skills/design/sem-cara-de-ia.md:
- Proibido: gradiente indigo-violeta default, Inter-em-tudo, tudo centralizado,
  3 cards de feature identicos, glassmorphism/blobs/glow por padrao, copia de
  preenchimento ("empower/seamlessly/unlock"), emoji como icone, badges "AI-Powered".
- Obrigatorio: conteudo real, paleta decidida, par tipografico com personalidade,
  ponto focal, densidade do dominio, e o "teste da troca" (trocar logo/texto/dominio
  deve fazer o design protestar).
- Obrigatorio em TODO layout: gerar artefato de preview com 3 opcoes distintas, cada
  uma em light E dark, antes de implementar. Usuario escolhe primeiro, codigo depois.

---

Antes de implementar:

Consulte a skill do dominio relevante:

  HTML e CSS:          .agnostic-core/skills/frontend/html-css-audit.md
  CSS Governance:      .agnostic-core/skills/frontend/css-governance.md
  Acessibilidade:      .agnostic-core/skills/frontend/accessibility.md
  UX Guidelines:       .agnostic-core/skills/frontend/ux-guidelines.md
  Testes unitarios:    .agnostic-core/skills/testing/unit-testing.md
  Performance:         .agnostic-core/skills/performance/performance-audit.md
  Caching (assets):    .agnostic-core/skills/performance/caching-strategies.md
  Commits:             .agnostic-core/skills/git/commit-conventions.md
  Documentacao:        .agnostic-core/skills/documentation/technical-docs.md

Design com MCP (se aplicavel):
  Paper MCP workflow:  .agnostic-core/skills/design/paper-mcp-workflow.md

Integracao com AI (se aplicavel):
  AI patterns:         .agnostic-core/skills/ai/ai-integration-patterns.md
  Prompt engineering:  .agnostic-core/skills/behavioral/prompt-engineering.md

Planejamento de feature:
  Goal-backward:       .agnostic-core/skills/behavioral/goal-backward-planning.md
  Workflow 6 fases:    .agnostic-core/skills/behavioral/project-workflow.md

Antes de fazer deploy:
  .agnostic-core/skills/devops/pre-deploy-checklist.md

---

Agents disponiveis:

  Frontend Reviewer:   .agnostic-core/agents/reviewers/frontend-reviewer.md
  Code Inspector:      .agnostic-core/agents/reviewers/code-inspector.md
  Test Reviewer:       .agnostic-core/agents/reviewers/test-reviewer.md
  Codebase Mapper:     .agnostic-core/agents/reviewers/codebase-mapper.md
  Project Planner:     .agnostic-core/agents/generators/project-planner.md
  Docs Generator:      .agnostic-core/agents/generators/docs-generator.md

---

Criterios de aceite para PRs:

  Acessibilidade:
  - [ ] Todos os elementos interativos acessiveis por teclado
  - [ ] Imagens com alt text
  - [ ] Contraste minimo 4.5:1 para texto normal
  - [ ] prefers-reduced-motion respeitado

  UX:
  - [ ] Estados loading, empty e error implementados
  - [ ] Touch targets minimos 44x44px
  - [ ] Testado em 375px (mobile)

  Performance:
  - [ ] Imagens com width/height ou aspect-ratio
  - [ ] Lazy loading em imagens below-the-fold

---

Git Auto-Push Workflow:
  Após cada commit, o hook PostToolUse faz push automático para a branch atual.
  Hook script:       .agnostic-core/scripts/hooks/post-tool-use-autopush
  Configuração:      ~/.claude/settings.json (PostToolUse → Bash matcher)
  Instalação:        scripts/install.sh configura automaticamente (passo 5/6)
  Comportamento:     detecta "git commit" → push origin <branch> → retry 1x se falhar

---

Convencoes do projeto (preencher):

  Framework: [FRAMEWORK e VERSAO]
  Bundler: Vite / Webpack / esbuild
  CSS: Tailwind / CSS Modules / styled-components / vanilla
  Testes: Jest + Testing Library / Vitest / Cypress
  Estilo de commits: Conventional Commits

---

Orquestração do fluxo de trabalho:

  Plan mode (padrão):
    - Entre em plan mode para qualquer tarefa não-trivial (3+ etapas ou decisões arquiteturais).
    - Se algo der errado durante a execução, pare e replanjeje antes de prosseguir.
    - Use plan mode também para etapas de verificação, não apenas para construção.
    - Escreva especificações detalhadas antes de codar para reduzir ambiguidade.

  Subagentes:
    - Use subagentes liberalmente para manter a janela de contexto principal limpa.
    - Offload pesquisa, exploração e análise paralela para subagentes.
    - Uma tarefa por subagente — execução focada.

  Loop de auto-aperfeiçoamento:
    - Após qualquer correção do usuário, atualize tasks/lessons.md com o padrão identificado.
    - Escreva regras para si mesmo que previnam o mesmo erro.
    - No início da sessão, releia tasks/lessons.md para o projeto atual.

  Verificação antes de concluir:
    - Nunca marque uma tarefa como concluída sem provar que funciona.
    - Execute testes, verifique logs, demonstre a correção.
    - Pergunta padrão: "Um engenheiro de equipe aprovaria isso?"

  Exigência de elegância (equilibrada):
    - Para mudanças não-triviais, pause e pergunte: "existe uma maneira mais elegante?"
    - Se uma correção parecer paliativa: "Sabendo o que sei agora, implemente a solução elegante."
    - Para fixes simples e óbvios, pule este passo — não super-engenhe.

  Correção de bugs autônoma:
    - Ao receber um relatório de bug: apenas conserte. Não peça ajuda.
    - Aponte para logs, erros, testes falhando — depois resolva.
    - Zero troca de contexto exigida do usuário.

Gerenciamento de tarefas:

  1. Plano primeiro:        escreva o plano em tasks/todo.md com itens marcáveis.
  2. Verifique o plano:     valide antes de iniciar a implementação.
  3. Acompanhe o progresso: marque os itens conforme avança.
  4. Explique as mudanças:  resumo de alto nível a cada etapa.
  5. Documente resultados:  seção de revisão no fim de tasks/todo.md.
  6. Capture lições:        atualize tasks/lessons.md após correções do usuário.

Princípios básicos:

  - Simplicidade primeiro:  faça cada mudança a mais simples possível; impacto mínimo.
  - Sem previsão:           encontre causas-raiz; sem fixes temporários; padrões de dev sênior.
  - Impacto mínimo:         toque apenas no que é necessário; sem efeitos colaterais.

---
Auto-invocação de skills

  Leia `.agnostic-core/docs/keywords-map.md` no início de cada sessão.
  Monitore keywords ao longo da conversa e invoque a skill correspondente:
  - Skills técnicas: entre em plan mode e aguarde confirmação antes de executar.
  - Skills comportamentais: ative silenciosamente, sem notificação.

---
Comportamento
  Ao iniciar cada sessão, execute automaticamente o comando /status.
  Status panel skill:  .agnostic-core/skills/ai/project-status.md
  Comando:             .agnostic-core/templates/commands/status.md

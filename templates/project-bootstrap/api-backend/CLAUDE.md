NOME DO PROJETO — API Backend

Stack: Node.js / Express / PostgreSQL (ou MongoDB)
Submodulo: .agnostic-core/

---

Catalogo completo de skills, agents e commands do agnostic-core (nao duplicar aqui):
  Skills indexadas:       .agnostic-core/docs/skills-index.md
  Prompts prontos:        .agnostic-core/commands/claude-code/COMMANDS.md
  Roteamento (qual usar): .agnostic-core/docs/agent-routing-guide.md

Antes de implementar ou fazer deploy, consulte a skill relevante na lista acima
via @mention (ex: @.agnostic-core/skills/backend/rest-api-design.md) em vez de
decorar caminhos aqui.

---

Git Auto-Push Workflow:
  Após cada commit, o hook PostToolUse faz push automático para a branch atual.
  Hook script:       .agnostic-core/scripts/hooks/post-tool-use-autopush
  Configuração:      ~/.claude/settings.json (PostToolUse → Bash matcher)
  Instalação:        scripts/install.sh configura automaticamente (passo 5/6)
  Comportamento:     detecta "git commit" → push origin <branch> → retry 1x se falhar

---

Convencoes do projeto (preencher):

  Linguagem: Node.js [VERSAO]
  Framework: Express [VERSAO]
  Banco: [BANCO e VERSAO]
  ORM/Driver: [ORM e VERSAO]
  Auth: JWT / OAuth / sessao
  Testes: Jest / Vitest / Mocha
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

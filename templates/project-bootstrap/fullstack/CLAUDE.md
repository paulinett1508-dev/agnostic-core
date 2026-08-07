NOME DO PROJETO — Fullstack

Stack: [DESCREVER: ex Node.js + React + MongoDB]
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
- Cerne inspirador: ancorar em sistema consolidado mundialmente (de preferencia
  90s/2000s) — herdar a logica da era (proporcao, affordance, densidade honesta,
  restricao de paleta) e modernizar a execucao (icones, tokens, a11y, responsivo).

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

  Backend: [LINGUAGEM] [VERSAO] + [FRAMEWORK] [VERSAO]
  Frontend: [FRAMEWORK] [VERSAO]
  Banco: [BANCO] [VERSAO] via [ORM/DRIVER]
  Auth: JWT / OAuth / sessao
  Cache: Redis / in-memory / nenhum
  Testes: [FRAMEWORK DE TESTES]
  CI/CD: GitHub Actions / outro
  Deploy: [PLATAFORMA]
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

  Leia `.agnostic-core/docs/keywords-map.md` (índice curto) no início de cada sessão.
  As categorias em `.agnostic-core/docs/keywords/` são sob demanda — abra a do
  assunto quando o assunto surgir, nunca todas de uma vez.
  Invoque a skill correspondente ao detectar a keyword:
  - Skills técnicas: entre em plan mode e aguarde confirmação antes de executar.
  - Skills comportamentais: ative silenciosamente, sem notificação.

---
Comportamento
  Ao iniciar cada sessão, execute automaticamente o comando /status.
  Status panel skill:  .agnostic-core/skills/ai/project-status.md
  Comando:             .agnostic-core/templates/commands/status.md

Integration Guide

Como adicionar o agnostic-core a um projeto existente ou novo.

---

ADICIONAR COMO SUBMODULO

Em qualquer projeto git:

  git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
  git submodule update --init

Commitar o submodulo:
  git add .agnostic-core .gitmodules
  git commit -m "chore: adicionar agnostic-core como submodulo"

Atualizar para a versao mais recente:
  git submodule update --remote .agnostic-core
  git add .agnostic-core
  git commit -m "chore(deps): atualizar agnostic-core"

Clonar projeto com submodulos:
  git clone --recurse-submodules https://github.com/seu/projeto.git
  # OU em projeto ja clonado:
  git submodule update --init

---

CONFIGURAR O CLAUDE.md DO PROJETO

Escolha o template mais proximo do seu stack:

  API Backend puro:
  cp .agnostic-core/templates/project-bootstrap/api-backend/CLAUDE.md CLAUDE.md

  Frontend puro:
  cp .agnostic-core/templates/project-bootstrap/frontend/CLAUDE.md CLAUDE.md

  Fullstack:
  cp .agnostic-core/templates/project-bootstrap/fullstack/CLAUDE.md CLAUDE.md

  Projeto generico:
  cp .agnostic-core/templates/project-bootstrap/CLAUDE.md CLAUDE.md

Edite o CLAUDE.md gerado:
- [ ] Altere o nome do projeto
- [ ] Remova skills nao relevantes para o stack
- [ ] Preencha as "Convencoes do projeto" no final

---

MAPEAMENTO: STACK → SKILLS RELEVANTES

Node.js + Express:
  Obrigatorias:
  - .agnostic-core/skills/nodejs/nodejs-patterns.md
  - .agnostic-core/skills/nodejs/express-best-practices.md
  - .agnostic-core/skills/backend/rest-api-design.md
  - .agnostic-core/skills/backend/error-handling.md
  - .agnostic-core/skills/security/api-hardening.md

  Recomendadas:
  - .agnostic-core/skills/database/query-compliance.md
  - .agnostic-core/skills/testing/unit-testing.md
  - .agnostic-core/skills/testing/integration-testing.md

Python + FastAPI/Django/Flask:
  Obrigatorias:
  - .agnostic-core/skills/python/python-patterns.md
  - .agnostic-core/skills/backend/rest-api-design.md
  - .agnostic-core/skills/security/api-hardening.md

  Recomendadas:
  - .agnostic-core/skills/backend/error-handling.md
  - .agnostic-core/skills/documentation/openapi-swagger.md

Python Scripts / ETL:
  Obrigatorias:
  - .agnostic-core/skills/python/python-patterns.md
  - .agnostic-core/skills/python/python-scripts.md

  Recomendadas:
  - .agnostic-core/skills/database/query-compliance.md

Frontend (React/Vue/Svelte):
  Obrigatorias:
  - .agnostic-core/skills/frontend/html-css-audit.md
  - .agnostic-core/skills/frontend/accessibility.md
  - .agnostic-core/skills/frontend/ux-guidelines.md

  Recomendadas:
  - .agnostic-core/skills/frontend/css-governance.md
  - .agnostic-core/skills/performance/performance-audit.md

Frontend com Tailwind:
  Obrigatorias:
  - .agnostic-core/skills/frontend/tailwind-patterns.md
  - .agnostic-core/skills/frontend/accessibility.md
  - .agnostic-core/skills/frontend/ux-guidelines.md

  Recomendadas:
  - .agnostic-core/skills/frontend/seo-checklist.md
  - .agnostic-core/skills/performance/performance-audit.md

Mobile (React Native / Flutter):
  Obrigatorias:
  - .agnostic-core/agents/specialists/mobile-developer.md
  - .agnostic-core/skills/frontend/accessibility.md
  - .agnostic-core/skills/testing/e2e-testing.md

  Recomendadas:
  - .agnostic-core/skills/frontend/ux-guidelines.md
  - .agnostic-core/skills/performance/performance-audit.md

Projeto com SEO:
  Obrigatorias:
  - .agnostic-core/agents/specialists/seo-specialist.md
  - .agnostic-core/skills/frontend/seo-checklist.md

  Recomendadas:
  - .agnostic-core/skills/performance/performance-audit.md
  - .agnostic-core/skills/frontend/accessibility.md

DevOps / Deploy:
  Obrigatorias:
  - .agnostic-core/agents/specialists/devops-engineer.md
  - .agnostic-core/skills/devops/pre-deploy-checklist.md
  - .agnostic-core/skills/devops/deploy-procedures.md

  Recomendadas:
  - .agnostic-core/skills/performance/load-testing.md
  - .agnostic-core/commands/workflows/deploy.md

Database Design:
  Obrigatorias:
  - .agnostic-core/agents/specialists/database-architect.md
  - .agnostic-core/skills/database/schema-design.md
  - .agnostic-core/skills/database/query-compliance.md

  Recomendadas:
  - .agnostic-core/agents/validators/migration-validator.md

Projeto com LLM / AI:
  Obrigatorias:
  - .agnostic-core/skills/ai/ai-integration-patterns.md
  - .agnostic-core/skills/ai/fact-checker.md

  Recomendadas:
  - .agnostic-core/skills/ai/prompt-engineering.md
  - .agnostic-core/skills/security/owasp-checklist.md (prompt injection)

---

GITHUB ACTIONS — ATUALIZAR SUBMODULO NO CI

Clonar com submodulos em pipelines:

  # .github/workflows/ci.yml
  jobs:
    test:
      steps:
        - uses: actions/checkout@v4
          with:
            submodules: recursive   # <-- clona .agnostic-core automaticamente

Manter submodulo atualizado automaticamente (opcional):

  # .github/workflows/update-agnostic-core.yml
  name: Atualizar agnostic-core
  on:
    schedule:
      - cron: '0 8 * * 1'  # toda segunda-feira as 8h
    workflow_dispatch:

  jobs:
    update:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
          with:
            submodules: recursive
            token: ${{ secrets.GITHUB_TOKEN }}
        - name: Atualizar submodulo
          run: |
            git submodule update --remote .agnostic-core
            git config user.name "github-actions[bot]"
            git config user.email "github-actions[bot]@users.noreply.github.com"
            git add .agnostic-core
            git diff --staged --quiet || git commit -m "chore(deps): atualizar agnostic-core"
            git push

---

USO PONTUAL SEM SUBMODULO

Se submodulo nao for adequado (projeto temporario, leitura rapida):

  # Ler skill diretamente via curl
  curl -s https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/skills/security/api-hardening.md

  # Baixar o repo inteiro como zip
  curl -L https://github.com/paulinett1508-dev/agnostic-core/archive/main.zip -o agnostic-core.zip
  unzip agnostic-core.zip

  # Referenciar no prompt (sem arquivo local)
  "Use o checklist em https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/skills/security/api-hardening.md"

---

VERIFICACAO DA INSTALACAO

Apos adicionar o submodulo, verifique:

  ls .agnostic-core/                  # deve listar skills/, agents/, etc.
  ls .agnostic-core/skills/           # deve ter 13+ diretorios
  ls .agnostic-core/agents/           # deve ter reviewers/, generators/, validators/
  cat .agnostic-core/commands/claude-code/COMMANDS.md  # deve ter 18+ comandos

---

TROUBLESHOOTING

Submodulo vazio apos clone:
  git submodule update --init --recursive

Submodulo desatualizado:
  git submodule update --remote .agnostic-core

Conflito de submodulo no merge:
  git checkout --theirs .agnostic-core
  git submodule update --init

Desanexar o submodulo (manter os arquivos):
  git submodule deinit .agnostic-core
  git rm .agnostic-core
  cp -r .git/modules/agnostic-core/.agnostic-core ./  # backup dos arquivos

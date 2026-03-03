# agnostic-core

Hub universal de skills, commands e sub-agents para desenvolvimento.
Agnostico de IDE, CLI e stack. Leia, consuma e aplique em qualquer projeto.

---

## O que e

`agnostic-core` e um repositorio-fonte de inteligencia operacional reutilizavel.
Skills escritas em Markdown puro que qualquer ferramenta le: Claude Code, Cursor, Copilot, scripts bash, pipelines CI/CD.

**33 skills. 10 agents. 24 commands. Uma instalacao.**

Sem lock-in. Sem duplicacao. Um lugar. Todos os projetos consomem.

---

## Estrutura

```
agnostic-core/
├── skills/
│   ├── security/       # API hardening, OWASP Top 10
│   ├── frontend/       # HTML/CSS, acessibilidade WCAG 2.1, UX guidelines
│   ├── backend/        # REST API design, error handling, financial ops
│   ├── database/       # Queries, indices, migrations, compliance
│   ├── testing/        # Unit, integration, TDD workflow
│   ├── performance/    # Audit, caching strategies, load testing
│   ├── git/            # Commit conventions, branching, PR template
│   ├── documentation/  # README, ADR, OpenAPI/Swagger
│   ├── audit/          # Code review, pre-implementation, refactoring
│   ├── devops/         # Pre-deploy checklist, CI/CD
│   ├── nodejs/         # Node.js patterns, Express best practices
│   ├── python/         # Python patterns, scripts
│   ├── ai/             # AI integration, prompt engineering, fact-checker
│   └── workflow/       # Goal-backward planning, project workflow, context management
├── agents/
│   ├── reviewers/      # Security, Frontend, Code Inspector, Test, Performance, Codebase Mapper
│   ├── generators/     # Project Planner, Boilerplate, Docs Generator
│   └── validators/     # Migration Validator
├── commands/
│   ├── claude-code/    # 24 commands prontos para Claude Code
│   ├── cursor/         # .cursorrules e prompts de chat
│   └── generic/        # Scripts bash, Makefile, GitHub Actions snippets
├── compliance/
│   ├── checklists/     # Pre-deploy
│   └── policies/       # Security policy
├── templates/
│   └── project-bootstrap/
│       ├── CLAUDE.md              # Template generico
│       ├── api-backend/CLAUDE.md  # API REST (Node.js/Python)
│       ├── frontend/CLAUDE.md     # Frontend (React/Vue/Svelte)
│       └── fullstack/CLAUDE.md    # Fullstack com todos os agents
└── docs/
    ├── CONTRIBUTING.md    # Como contribuir
    ├── skills-index.md    # Indice completo de todas as skills
    ├── integration-guide.md # Como adicionar a qualquer projeto
    └── resources.md       # Referencias externas e licencas
```

---

## Como consumir

### Git Submodule (recomendado)
```bash
git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
git submodule update --init
```

Copiar o template de CLAUDE.md para o seu stack:
```bash
# API Backend
cp .agnostic-core/templates/project-bootstrap/api-backend/CLAUDE.md CLAUDE.md

# Frontend
cp .agnostic-core/templates/project-bootstrap/frontend/CLAUDE.md CLAUDE.md

# Fullstack
cp .agnostic-core/templates/project-bootstrap/fullstack/CLAUDE.md CLAUDE.md
```

Para atualizar:
```bash
git submodule update --remote .agnostic-core
```

### Claude Code
Referencie a skill diretamente no prompt:
```
Use a skill em .agnostic-core/skills/security/api-hardening.md para revisar estes endpoints.
```

Ou use um dos 24 commands prontos em `commands/claude-code/COMMANDS.md`.

### Cursor
Copie o `.cursorrules` de `commands/cursor/COMMANDS.md` para a raiz do projeto.

### CI/CD (GitHub Actions)
```yaml
- uses: actions/checkout@v4
  with:
    submodules: recursive   # clona .agnostic-core automaticamente
```

### Raw curl (uso pontual)
```bash
curl -s https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/skills/security/api-hardening.md
```

---

## Exemplos de uso

**Revisar seguranca antes do deploy:**
```
Atue como o agent em .agnostic-core/agents/reviewers/security-reviewer.md
Revise os arquivos em src/ e gere o Security Review Report.
```

**Planejar uma nova feature:**
```
Use .agnostic-core/skills/workflow/goal-backward-planning.md
Planeje a implementacao de autenticacao JWT com goal-backward e tasks em waves.
```

**Mapear um codebase existente:**
```
Atue como o agent em .agnostic-core/agents/reviewers/codebase-mapper.md
Analise o codebase em src/ e gere STACK.md, ARCHITECTURE.md, CONVENTIONS.md e CONCERNS.md.
```

---

## Principios

| Principio      | Descricao                                          |
|----------------|----------------------------------------------------|
| Agnostico      | Funciona em qualquer IDE, CLI ou pipeline          |
| Markdown-first | Toda skill e legivel por humanos e maquinas        |
| Modular        | Cada skill tem uma responsabilidade                |
| Versionavel    | Git e a fonte de verdade                           |
| Composavel     | Skills se combinam para fluxos maiores             |

---

## Indice completo

Ver [docs/skills-index.md](docs/skills-index.md) para lista completa com descricao de cada artefato.

## Como integrar

Ver [docs/integration-guide.md](docs/integration-guide.md) para guia completo de instalacao,
mapeamento por stack e configuracao de CI/CD.

## Contribuindo

Ver [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)

## Licenca

MIT

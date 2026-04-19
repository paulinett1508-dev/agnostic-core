# Changelog

Todas as mudanças notáveis deste projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2026-04-18

Primeira versão pública distribuível.

### Adicionado

- **Instalador universal** `scripts/install.sh` com detecção automática de stack,
  flags `--template`, `--no-hook`, `--no-commit`, `--no-claude-skills`.
- **Instalador PowerShell** `scripts/install.ps1` (espelho do `.sh` para Windows).
- **Wrapper npm** `package.json` + `scripts/npx-entry.js` — permite
  `npx agnostic-core@latest init` em qualquer projeto Node.
- **Gerador de camada nativa** `scripts/generate-claude-skills.sh` — cria
  `.claude/skills/<nome>/SKILL.md` com frontmatter YAML para autodescoberta
  no Claude Code, mantendo os Markdown em `skills/` como fonte única da verdade.
- **Validação de integridade** `scripts/check-refs.sh` — verifica paths
  referenciados e frontmatter de `SKILL.md`.
- **CI GitHub Actions**:
  - `lint-markdown.yml` — markdownlint-cli2 em todo `**/*.md`.
  - `check-links.yml` — lychee para links internos e externos.
  - `check-refs.yml` — roda `check-refs.sh` a cada push/PR.
- **Convenções de projeto**: `.gitattributes`, `.editorconfig`, `.markdownlint.json`.

### Conteúdo

- 81+ skills em 18 categorias (security, frontend, backend, devops, audit, ai…).
- 16 agents especializados (reviewers, validators, generators, specialists).
- 18+ commands para Claude Code + 4 workflows (brainstorm, create, debug, deploy).
- 3 templates de bootstrap (`api-backend`, `frontend`, `fullstack`).
- 1 skill nativa Claude Code (`.claude/skills/eruda`).

### Corrigido

- Refs quebradas para `.agnostic-core/compliance/checklists/pre-deploy.md` em
  templates e commands — apontadas agora para
  `skills/devops/pre-deploy-checklist.md` (local canônico).
- Caminho `templates/project-bootstrap/CLAUDE.md` sem subpasta (não existia) —
  `docs/integration-guide.md` agora aponta para `fullstack/CLAUDE.md`.
- Referência `docs/CONTRIBUTING.md` em `skills-index.md` corrigida para
  `CONTRIBUTING.md` na raiz.

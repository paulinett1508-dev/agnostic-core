# agnostic-core

Hub universal de skills, commands e sub-agents para desenvolvimento.
Agnostico de IDE, CLI e stack. Leia, consuma e aplique em qualquer projeto.

---

## O que e

`agnostic-core` e um repositorio-fonte de inteligencia operacional reutilizavel.
Skills escritas em Markdown puro que qualquer ferramenta le: Claude Code, Cursor, Copilot, scripts bash, pipelines CI/CD.

Sem lock-in. Sem duplicacao. Um lugar. Todos os projetos consomem.

---

## Estrutura

```
agnostic-core/
├── skills/
│   ├── security/           # Seguranca e hardening
│   ├── frontend/           # HTML, CSS, JS, acessibilidade
│   ├── database/           # Modelagem, queries, compliance
│   ├── audit/              # Revisao de codigo
│   └── devops/             # CI/CD, containers, infra
├── commands/
│   ├── vscode/             # Tasks e configs
│   ├── claude-code/        # Slash commands e agents
│   ├── cursor/             # Rules e prompts
│   └── generic/            # Scripts bash/python
├── agents/
│   ├── reviewers/          # Code review especializado
│   ├── generators/         # Geracao de boilerplate/docs
│   └── validators/         # Validacao e compliance
├── compliance/
│   ├── checklists/         # Pre-deploy, auditoria
│   └── policies/           # Politicas de seguranca
├── templates/
│   ├── project-bootstrap/  # Estrutura inicial de projeto
│   └── ci-cd/              # Pipelines prontos
└── docs/                   # Como integrar e contribuir
```

---

## Como consumir

### Git Submodule (recomendado)
```bash
git submodule add https://github.com/SEU_USER/agnostic-core.git .agnostic-core
git submodule update --init
```

Para atualizar:
```bash
git submodule update --remote
```

### Claude Code / Antigravity
Referencie a skill diretamente no prompt:
```
Use a skill em .agnostic-core/skills/security/api-hardening.md para revisar estes endpoints.
```

Ou configure no CLAUDE.md do seu projeto (ver templates/project-bootstrap/CLAUDE.md).

### VS Code
Copie `commands/vscode/tasks.json` para `.vscode/tasks.json` do seu projeto.
Acesse via Terminal > Run Task > "agnostic: Security Audit".

### CI/CD (GitHub Actions)
```yaml
- name: Load agnostic-core
  run: git clone https://github.com/SEU_USER/agnostic-core.git .agnostic-core

- name: Pre-deploy compliance
  run: cat .agnostic-core/compliance/checklists/pre-deploy.md
```

### Raw curl (uso pontual)
```bash
curl -s https://raw.githubusercontent.com/SEU_USER/agnostic-core/main/skills/security/api-hardening.md
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

## Contribuindo

Ver [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)

## Licenca

MIT

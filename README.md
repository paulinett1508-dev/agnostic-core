# agnostic-core

> Boas praticas de desenvolvimento de software, organizadas para humanos e IAs lerem juntos.

Versao atual: ver [CHANGELOG](CHANGELOG.md)

---

## Em uma frase

O agnostic-core e uma colecao curada de checklists, padroes e referencias que qualquer projeto de software pode usar para melhorar a qualidade do codigo — com ou sem assistente de IA.

---

## Para quem e isso?

| Voce e... | O que o agnostic-core faz por voce |
|---|---|
| **Curioso / nao-programador** | Mostra como boas praticas de software sao organizadas — como um manual de qualidade que a IA consulta |
| **Iniciante em programacao** | Oferece checklists prontos para cada area (seguranca, testes, deploy) que guiam voce nas decisoes certas |
| **Dev experiente** | Fornece uma knowledge base agnostica de stack com 49 skills, 16 agent patterns e workflows reutilizaveis — sem lock-in |
| **Tech lead / gestor** | Padroniza qualidade entre projetos e times com um unico repositorio de referencia |

---

## Como funciona?

Sao arquivos Markdown simples. Cada arquivo cobre um tema (seguranca, performance, testes, etc.) com regras praticas, checklists e exemplos.

Voce pode:
- **Ler diretamente** — abra qualquer arquivo e use o que fizer sentido
- **Integrar ao projeto** — adicione como submodulo e a IA assistente (Claude, Cursor, etc.) consulta automaticamente
- **Adaptar** — copie, edite, ignore o que nao se aplica

Nenhuma instalacao obrigatoria. Nenhum lock-in. Nenhum fluxo imposto.

---

## O que tem aqui?

### Skills — 49 checklists por dominio

| Categoria | O que voce vai encontrar |
|---|---|
| `skills/security/` | Hardening de API, OWASP Top 10, pentest, revisao de seguranca |
| `skills/frontend/` | Governanca CSS, HTML/CSS, Tailwind, SEO, acessibilidade, i18n |
| `skills/ux-ui/` | Principios de interface, hierarquia visual, quality gates |
| `skills/database/` | Queries seguras, migrations, schema design, selecao de ORM |
| `skills/backend/` | Padroes de API, DDD, Event Sourcing, operacoes financeiras |
| `skills/devops/` | Deploy, observabilidade, containerizacao, monorepo |
| `skills/performance/` | Auditoria, N+1, caching, load testing |
| `skills/testing/` | Unitarios, integracao, E2E, TDD |
| `skills/audit/` | Revisao de codigo, debugging sistematico, revisao de texto PT-BR |
| `skills/automacao/` | Git hooks, CI/CD, scripts de setup |
| `skills/ai/` | Fact-checking, integracao com LLMs, prompt engineering |
| `skills/git/` | Commits, branching, PR templates |
| `skills/documentation/` | Docs tecnicos, OpenAPI/Swagger |

### Agents — 16 padroes de agentes especializados

Agents sao "personas" que a IA assume para tarefas especificas:

| Tipo | Exemplos | O que fazem |
|---|---|---|
| **Reviewers** (7) | Security, Frontend, Code Inspector, Architecture | Auditam codigo e geram relatorios |
| **Generators** (4) | Boilerplate, Project Planner, Docs | Criam artefatos do zero |
| **Validators** (1) | Migration Validator | Aprovam ou bloqueiam operacoes |
| **Specialists** (4) | DevOps, Database, Mobile, SEO | Expertise de dominio |

### Workflows — 4 templates de processo

| Workflow | Quando usar |
|---|---|
| `brainstorm.md` | Explorar opcoes antes de implementar |
| `create.md` | Criar app ou feature completa do zero |
| `debug.md` | Investigacao sistematica de bugs |
| `deploy.md` | Processo de deploy seguro e verificavel |

### Templates — projetos prontos para comecar

| Template | Stack |
|---|---|
| `api-backend/CLAUDE.md` | API REST (Node.js / Python) |
| `frontend/CLAUDE.md` | Frontend (React / Vue / Svelte) |
| `fullstack/CLAUDE.md` | Fullstack com todos os agents |
| `CLAUDE.md` | Generico (qualquer stack) |

---

## Comecar em 2 minutos

### Opcao 1: Apenas ler

Navegue pelas pastas. Abra o arquivo que te interessa. Use o que fizer sentido.

### Opcao 2: Integrar ao seu projeto

```bash
# Adicionar ao projeto como submodulo
git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core

# Copiar um template de configuracao (escolha o seu stack)
cp .agnostic-core/templates/project-bootstrap/fullstack/CLAUDE.md CLAUDE.md

# Pronto. A IA assistente agora consulta as skills automaticamente.
```

Para o guia completo: [docs/integration-guide.md](docs/integration-guide.md)

### Opcao 3: Verificar status

```bash
bash .agnostic-core/scripts/check-status.sh
```

Mostra a versao instalada, se esta atualizado e o que mudou.

---

## Exemplos de uso

| Exemplo | O que mostra |
|---|---|
| `exemplos/referencia-no-claude-code.md` | Como referenciar skills em um CLAUDE.md |
| `exemplos/prompts-prontos.md` | Prompts prontos para Claude Code, Cursor e similares |

---

## Perguntas frequentes

**Preciso instalar algo?**
Nao. Sao arquivos Markdown. Voce pode ler no GitHub mesmo.

**Funciona com qual linguagem/framework?**
Qualquer um. As skills sao agnosticas de stack — por isso o nome.

**Funciona sem IA?**
Sim. Os checklists sao uteis para qualquer dev, com ou sem assistente.

**Como atualizar?**
`git submodule update --remote .agnostic-core` ou use o [workflow automatico](docs/integration-guide.md).

**Como contribuir?**
Ver [CONTRIBUTING.md](CONTRIBUTING.md)

---

## Numeros

| | |
|---|---|
| Skills | 49 |
| Agents | 16 |
| Commands | 18 |
| Workflows | 4 |
| Templates | 4 |

---

## Licenca

MIT

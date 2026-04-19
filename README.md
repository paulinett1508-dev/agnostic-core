# agnostic-core

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lint Markdown](https://github.com/paulinett1508-dev/agnostic-core/actions/workflows/lint-markdown.yml/badge.svg)](https://github.com/paulinett1508-dev/agnostic-core/actions/workflows/lint-markdown.yml)
[![Check Refs](https://github.com/paulinett1508-dev/agnostic-core/actions/workflows/check-refs.yml/badge.svg)](https://github.com/paulinett1508-dev/agnostic-core/actions/workflows/check-refs.yml)

> Acervo de boas ideias para desenvolvimento de software.
> Navegue livremente. Use o que fizer sentido para o seu projeto.

---

## Quick install

Execute na raiz de qualquer repositório git:

**Bash / Linux / macOS / WSL:**

```bash
curl -sL https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/scripts/install.sh | bash
```

**PowerShell / Windows:**

```powershell
iwr -useb https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/scripts/install.ps1 | iex
```

**npm / Node.js (qualquer plataforma com bash disponível):**

```bash
npx agnostic-core@latest init
```

**Git submodule manual:**

```bash
git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
git submodule update --init
```

O instalador automático:

1. Detecta seu stack (React, Vue, Next, Express, FastAPI, Django, Python, Docker, Vercel, Cloudflare, Replit, Turborepo, Drizzle, Prisma, etc).
2. Adiciona `.agnostic-core/` como submodule.
3. Gera ou complementa o `CLAUDE.md` com referências às skills relevantes para o stack detectado.
4. Gera a camada nativa `.claude/skills/<nome>/SKILL.md` para autodescoberta no Claude Code.
5. (Opcional) Configura hook `PostToolUse` para auto-push após commits.

Para customizar: ver [ONBOARDING.md](ONBOARDING.md) e [docs/integration-guide.md](docs/integration-guide.md).

---

## O que é isso?

Um catálogo de ideias, padrões e referências escritas em Markdown puro.
Nenhuma instalação obrigatória. Nenhum lock-in. Nenhum fluxo imposto.

Você (ou a IA que te assiste) abre um arquivo, lê, e decide se aquela ideia
se aplica ao seu contexto. O projeto se adapta ao acervo — nunca o contrário.

---

## O que tem aqui?

### Skills — ideias por domínio

| Categoria | O que você vai encontrar |
|---|---|
| `skills/security/` | Hardening de API, OWASP Top 10, política de segurança, pentest |
| `skills/frontend/` | Governança CSS, auditoria HTML/CSS, Tailwind, SEO, i18n |
| `skills/ux-ui/` | Princípios de interface, hierarquia visual, acessibilidade |
| `skills/database/` | Queries seguras, migrations, schema design, seleção de ORM |
| `skills/backend/` | Operações financeiras, padrões de API, DDD, Event Sourcing, migração |
| `skills/devops/` | Deploy, observabilidade, containerização, monorepo, rollback |
| `skills/performance/` | Auditoria de performance, N+1, async |
| `skills/cache/` | Estratégias de cache, TTL, invalidação |
| `skills/testing/` | Unitários, integração, E2E, TDD |
| `skills/audit/` | Revisão de código, debugging sistemático, validação |
| `skills/automacao/` | Git hooks, CI/CD, scripts de setup |
| `skills/mcp/` | Ideias de MCP servers, quando e como criar |
| `skills/ai/` | Fact-checking, integração com LLMs |

### Agents — padrões de agentes especializados

| Agent | Para que serve |
|---|---|
| `agents/reviewers/security-reviewer.md` | Padrão de agent para revisão de segurança |
| `agents/reviewers/code-inspector.md` | Padrão de agent para inspeção de código (SPARC) |
| `agents/reviewers/architecture-reviewer.md` | Revisão de decisões arquiteturais (DDD, migração) |
| `agents/generators/boilerplate-generator.md` | Padrão de agent para geração de estrutura inicial |
| `agents/specialists/devops-engineer.md` | Especialista em deploy, infra e operações |
| `agents/specialists/database-architect.md` | Especialista em schema design e banco de dados |
| `agents/specialists/mobile-developer.md` | Especialista em desenvolvimento mobile |
| `agents/specialists/seo-specialist.md` | Especialista em SEO e Core Web Vitals |

### Workflows — templates de processo

| Workflow | Para que serve |
|---|---|
| `commands/workflows/brainstorm.md` | Explorar opções antes de implementar |
| `commands/workflows/create.md` | Criar app ou feature completa do zero |
| `commands/workflows/debug.md` | Investigação sistemática de bugs |
| `commands/workflows/deploy.md` | Processo de deploy seguro |

### Exemplos — como outros usam este acervo

| Exemplo | O que mostra |
|---|---|
| `exemplos/referencia-no-claude-code.md` | Como referenciar skills em um CLAUDE.md |
| `exemplos/prompts-prontos.md` | Prompts de exemplo para Claude Code, Cursor e similares |

---

## Como usar?

Não tem passo obrigatório. A forma mais direta:

1. Navegue pelas pastas acima
2. Abra o arquivo da categoria que te interessa
3. Leia e avalie se faz sentido para o que você está construindo
4. Use, adapte ou ignore

Se quiser instalar o acervo num projeto, use o [**Quick install**](#quick-install) no topo.
Para exemplos de referência em CLAUDE.md, veja `exemplos/referencia-no-claude-code.md`.

### Atualizar o acervo em um projeto

```bash
# via npx
npx agnostic-core@latest update

# ou diretamente
git submodule update --remote .agnostic-core
git add .agnostic-core && git commit -m "chore: update agnostic-core" && git push
```

### Verificar integridade local do acervo

```bash
npm run check-refs   # ou: bash scripts/check-refs.sh
```

---

## Contribuindo

Ver [CONTRIBUTING.md](CONTRIBUTING.md)

## Licença

MIT

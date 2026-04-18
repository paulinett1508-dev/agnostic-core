# Onboarding — Novo Projeto

Como integrar o `agnostic-core` em qualquer projeto novo.

A forma mais rápida é o instalador automático (detecta seu stack e configura tudo).
A forma manual (submodule direto) existe se você quiser controle fino.

---

## Opção A — Instalador automático (recomendado)

Na raiz do projeto:

**Bash / macOS / Linux / WSL:**

```bash
curl -sL https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/scripts/install.sh | bash
```

**PowerShell / Windows:**

```powershell
iwr -useb https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/scripts/install.ps1 | iex
```

**npm / Node.js:**

```bash
npx agnostic-core@latest init
```

### Flags úteis

| Flag (bash) | Flag (PowerShell) | Efeito |
|---|---|---|
| `--template <t>` | `-Template <t>` | Força template: `fullstack`, `api-backend`, `frontend`, `generic` |
| `--no-hook` | `-NoHook` | Não configura o hook `PostToolUse` de auto-push |
| `--no-commit` | `-NoCommit` | Não faz `git add/commit/push` automático ao final |
| `--no-claude-skills` | `-NoClaudeSkills` | Não gera a camada nativa `.claude/skills/` |

Exemplo:

```bash
curl -sL .../install.sh | bash -s -- --template fullstack --no-commit
```

### O que o instalador faz

1. Detecta stack via `package.json`, `requirements.txt`, `Dockerfile`, `vercel.json`, etc.
2. Adiciona `.agnostic-core/` como submodule git.
3. Cria ou complementa `CLAUDE.md` com refs às skills relevantes para o stack detectado.
4. Gera `.claude/skills/<nome>/SKILL.md` para autodescoberta nativa no Claude Code
   (apontam por referência para os arquivos-fonte em `.agnostic-core/skills/`).
5. (Opcional) Adiciona hook `PostToolUse` em `~/.claude/settings.json` para auto-push.
6. (Opcional) Commit e push.

---

## Opção B — Instalação manual (submodule)

```bash
cd meu-projeto
git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
git submodule update --init
```

Crie ou edite o `CLAUDE.md` na raiz do projeto e inclua:

```markdown
## Agnostic Core

Submodule em: `.agnostic-core/`

Antes de qualquer tarefa, leia a skill relevante em `.agnostic-core/skills/`.

| Tarefa | Skill |
|--------|-------|
| Design, UI, layout, visual, cores, componente | `.agnostic-core/skills/design-system/SKILL.md` |
| Code review, refactor | `.agnostic-core/skills/audit/` |
| Deploy | `.agnostic-core/skills/devops/` |
| Testes | `.agnostic-core/skills/testing/` |
| API/Backend | `.agnostic-core/skills/backend/` |
| Segurança | `.agnostic-core/skills/security/` |

**CRÍTICO — Design:** nunca escreva código visual sem executar primeiro
`.agnostic-core/skills/design-system/SKILL.md` (Checklist → design.json → código).
```

Commit e push:

```bash
git add .agnostic-core .gitmodules CLAUDE.md
git commit -m "chore: add agnostic-core as submodule"
git push
```

Se quiser autodescoberta nativa (opcional):

```bash
bash .agnostic-core/scripts/generate-claude-skills.sh
git add .claude/skills && git commit -m "chore: generate .claude/skills layer"
```

---

## Atualizar o submodule quando o acervo evoluir

```bash
# via npx
npx agnostic-core@latest update

# ou manual
git submodule update --remote .agnostic-core
git add .agnostic-core
git commit -m "chore: update agnostic-core submodule"
git push
```

Para atualizar em lote em múltiplos projetos (Windows): use `update-agnostic-core.ps1`
na raiz do acervo — varre `C:\PROJETOS\` e atualiza cada projeto com `.agnostic-core`.

---

## Clonar um projeto que já tem o submodule

```bash
git clone --recurse-submodules https://github.com/owner/meu-projeto.git
```

Se já clonou sem o flag:

```bash
git submodule update --init
```

---

## Verificar integridade

Dentro do `.agnostic-core/`:

```bash
bash scripts/check-refs.sh
```

Valida que todas as refs `@.agnostic-core/...` apontam para arquivos existentes
e que os `SKILL.md` têm frontmatter válido.

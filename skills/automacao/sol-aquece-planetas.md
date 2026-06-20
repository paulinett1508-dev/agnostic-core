# sol — Aquece Planetas

> Sequência completa de ativação de um repositório. Corre de dentro do repo do planeta — o TheGod invoca, o guardião executa.

Instala gravidade → identidade → limpeza → CI → handoff. Idempotente: verifica o que já existe antes de criar.

---

## Quando usar

- Repo novo ou esqueleto vazio
- Planeta dormante sem padrões modernos
- Qualquer repo de `paulinett1508-dev` / `Lab-Sobral-Dev` sem agnostic-core

Invoque com: `/sol`, `"aquece esse planeta"`, `"ativa o planeta"`, `"warming"`

---

## Pré-condição

Claude Code aberto dentro do repo do planeta (não do theuniverse).

---

## Sequência de aquecimento (5 passos — executar em ordem)

### Passo 1 — Gravidade (agnostic-core)

Verificar se `.agnostic-core/` existe como submodule:
- Se não existe:
  ```bash
  git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
  git submodule update --init
  ```
- Se existe mas não inicializado: `git submodule update --init`
- Se ok: reportar e pular.

### Passo 2 — Identidade (CLAUDE.md)

Detectar stack antes de criar:

| Arquivo presente | Stack |
|---|---|
| `package.json` com `"typescript"` | TypeScript / Node |
| `package.json` sem typescript | JavaScript / Node |
| `requirements.txt` / `pyproject.toml` | Python |
| `composer.json` | PHP |
| Nenhum | Genérico |

Usar template correspondente de `.agnostic-core/templates/project-bootstrap/`:
- `api-backend/CLAUDE.md` → backend / Python / Node
- `frontend/CLAUDE.md` → frontend TypeScript/JS
- `fullstack/CLAUDE.md` → fullstack ou genérico

Preencher no template:
- Nome do projeto (nome do repo)
- Stack detectada e versão
- Cluster no universo (consultar `theuniverse/planets/_index.md` se disponível)

Se `CLAUDE.md` já existe e não é esqueleto: **confirmar com TheGod antes de sobrescrever.**

### Passo 3 — Limpeza (.gitignore)

Se `.gitignore` não existe ou está incompleto para a stack detectada:

- Python: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `*.egg-info/`, `.env`, `dist/`, `.pytest_cache/`
- Node/TS: `node_modules/`, `dist/`, `.env`, `.env.local`, `*.log`, `.next/`, `coverage/`
- PHP: `vendor/`, `.env`, `*.log`
- Genérico: `.env`, `*.log`, `*.tmp`, `.DS_Store`

Sempre incluir: `.vault` (se repo theuniverse), `.env*.local`

Se `.gitignore` já existe: só adicionar entradas ausentes, nunca sobrescrever.

### Passo 4 — CI (GitHub Actions)

Se `.github/workflows/` não existe:

**Python:**
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install -r requirements.txt
      - run: python -m pytest
```

**Node/TypeScript:**
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm test
```

**PHP:**
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with: { php-version: '8.2' }
      - run: composer install
      - run: vendor/bin/phpunit
```

**Genérico:** criar `.github/workflows/ci.yml` mínimo com lint se tooling disponível.

Se workflows já existem: não tocar.

### Passo 5 — Handoff (HANDOFF.md)

Criar `HANDOFF.md` na raiz com:

```markdown
# HANDOFF — [nome-do-repo]

> Auto-gerado pelo aquecimento Sol em [data].

## O que é este projeto

[Descrição em 1-2 frases — inferir do README ou código existente]

## Stack

[Stack detectada no passo 2]

## Estrutura

[Listar dirs/arquivos principais com uma linha cada]

## Estado atual

[Ativo / Dormante / Em desenvolvimento — inferir de commits recentes]

## Próximos passos sugeridos

- [ ] [Item 1 — baseado no que está faltando]
- [ ] [Item 2]

## Referência no universo

Ficha do planeta: https://github.com/paulinett1508-dev/theuniverse/blob/master/planets/[nome].md
```

Se `HANDOFF.md` já existe: atualizar só a seção "Estado atual" e "Próximos passos".

---

## Commit final

Após os 5 passos, criar 1 commit com:

```
chore: sol aquece [nome-do-planeta]

- gravidade: agnostic-core submodule
- identidade: CLAUDE.md ([stack])
- limpeza: .gitignore
- CI: .github/workflows/ci.yml
- handoff: HANDOFF.md
```

---

## Output esperado

```
Sol aquecendo [nome-do-planeta]...

Gravidade:   .agnostic-core OK
Identidade:  CLAUDE.md criado (stack: Python)
Limpeza:     .gitignore atualizado
CI:          .github/workflows/ci.yml criado
Handoff:     HANDOFF.md criado

1 commit. Planeta aquecido.
```

---

## Regras

1. **Verificar antes de criar** — nunca sobrescrever sem confirmar
2. **Detectar stack primeiro** — passo 2 depende desta detecção
3. **Idempotente** — re-executar não deve quebrar nada
4. **1 commit final** — não criar commits intermediários por passo
5. **Nunca sair do repo** — Sol não toca em outros repos

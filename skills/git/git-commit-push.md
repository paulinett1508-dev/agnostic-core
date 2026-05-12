# Git Commit & Push Protocol

Protocolo operacional completo para commits e pushes: analisa mudanças, valida código, gera mensagem descritiva e executa push com tratamento de divergências.

Complementa `commit-conventions.md` (formato) e `git-auto-push-hook.md` (infraestrutura de hook).

---

## Quando usar

- "faça um git push" / "commite tudo" / "sobe as mudanças"
- "commit e push" / "versiona isso" / "manda pro git"
- "push isso" / "commita" / "salva no git"
- Após terminar uma implementação e querer versionar

---

## FASE 1 — Análise de mudanças

```bash
git branch --show-current
git status --short
git diff --stat
git diff --cached --stat
```

Identificar tipo de mudança pelo caminho dos arquivos:

| Caminho | Tipo provável |
|---------|--------------|
| `controllers/`, `routes/`, `services/` | `feat` / `fix` backend |
| `models/`, `schema/`, `migrations/` | `feat` / `fix` database |
| `src/`, `components/`, `pages/` | `feat` / `fix` frontend |
| `*.css`, `*.scss`, `styles/` | `style` |
| `*.md`, `docs/` | `docs` |
| `package.json`, `*.yml`, `.env.example` | `chore` / `ci` |

---

## FASE 2 — Validações pré-commit

### Syntax check

```bash
# JavaScript/TypeScript
for file in $(git diff --name-only --diff-filter=AM | grep -E "\.(js|ts|jsx|tsx)$"); do
  node --check "$file" 2>&1 || echo "❌ Erro em $file"
done

# Python
for file in $(git diff --name-only --diff-filter=AM | grep "\.py$"); do
  python -m py_compile "$file" 2>&1 || echo "❌ Erro em $file"
done
```

### Debug code esquecido

```bash
git diff | grep -n "console\.log\|debugger\|pdb\.set_trace\|binding\.pry\|dd(" \
  && echo "⚠️ Debug code detectado"
```

### Secrets expostos

```bash
git diff | grep -iE "(password|secret|api_key|token|private_key)\s*=\s*['\"][^'\"]{8,}" \
  && echo "🔒 Possível secret hardcoded"
```

### .gitignore saudável

```bash
test -f .gitignore || echo "⚠️ .gitignore não encontrado"
grep -q "node_modules\|__pycache__\|\.env$" .gitignore 2>/dev/null \
  || echo "⚠️ Revisar .gitignore"
```

### Decisão

| Resultado | Ação |
|-----------|------|
| Syntax errors | **ABORTAR** — corrigir antes de continuar |
| Debug code | Avisar — prosseguir só se confirmado |
| Possível secret | Avisar — aguardar confirmação |
| Tudo OK | Continuar |

---

## FASE 3 — Geração da mensagem de commit

### Formato (Conventional Commits)

```
<tipo>(<escopo>): <descrição curta em imperativo>

<corpo opcional: por que, não o quê>

<rodapé: Closes #issue, BREAKING CHANGE: ...>
```

### Algoritmo de escolha de tipo

```
mudanças em src/features/ ou controllers/ → feat ou fix
mudanças só em *.css/*.scss              → style
mudanças só em *.md / docs/              → docs
mudanças em package.json / *.yml         → chore ou ci
refatoração sem mudança de comportamento → refactor
```

### Escopo

Use o nome do módulo, pasta ou área afetada. Exemplos:

```
feat(auth): adicionar login via OAuth
fix(checkout): corrigir cálculo de desconto com cupom
refactor(user): separar lógica de perfil do controller
docs(api): documentar endpoint de criação de pedido
chore(deps): atualizar dependências de segurança
```

Se múltiplos módulos afetados e sem dominante claro, omitir escopo.

### Regras da descrição

- [ ] Imperativo: "adicionar", "corrigir", "remover"
- [ ] Minúsculo, sem ponto final
- [ ] Máximo 72 caracteres

### Exemplos de mensagens geradas

```
feat(auth): adicionar refresh token com rotação automática

- Implementa rotação de refresh token a cada uso
- Invalida token anterior ao emitir novo
- Adds jitter de 30s para evitar race condition

Closes #142
```

```
fix(checkout): corrigir desconto negativo com cupom de 100%

Cupons com valor igual ao total geravam preço negativo.
Adicionado clamp(0, total) antes de processar pagamento.
```

---

## FASE 4 — Staging

**Opção A: por categoria (mais controle)**

```bash
# Backend
git add src/controllers/ src/routes/ src/services/ src/models/ 2>/dev/null
# Frontend
git add src/components/ src/pages/ src/styles/ 2>/dev/null
# Config e docs
git add *.md package.json .env.example 2>/dev/null
```

**Opção B: tudo de uma vez (quando seguro)**

```bash
git add .
```

Nunca adicionar: `.env`, arquivos de build, arquivos > 100MB.

---

## FASE 5 — Push e tratamento de divergências

### Verificações pré-push

```bash
git branch --show-current          # confirmar branch
git remote -v                       # confirmar remote
git log origin/$(git branch --show-current)..HEAD --oneline  # commits a enviar
git fetch origin
git status | grep -E "behind|diverged"
```

### Cenário 1: Local ahead, remote sem alterações

```bash
git push origin $(git branch --show-current)
```

### Cenário 2: Remote alterado (behind)

```bash
git pull --rebase origin $(git branch --show-current)
# Se houver conflitos: resolver, então:
git push origin $(git branch --show-current)
```

### Cenário 3: Divergência crítica

```bash
git merge --abort 2>/dev/null
git rebase --abort 2>/dev/null
echo "🚫 PUSH ABORTADO: Divergência detectada"
echo "1. git fetch origin"
echo "2. git rebase origin/<branch> (ou merge)"
echo "3. Resolver conflitos"
echo "4. Tentar push novamente"
```

---

## FASE 6 — Merge de feature branch para main (opcional)

Quando trabalhando em branches de feature que precisam ser integradas à branch principal:

```bash
FEATURE_BRANCH=$(git branch --show-current)

# Só executar se não estiver em main/master
if [[ "$FEATURE_BRANCH" != "main" && "$FEATURE_BRANCH" != "master" ]]; then

  git checkout main          # ou master
  git pull origin main --no-rebase --no-edit
  git merge $FEATURE_BRANCH --no-edit

  # Se houver conflitos:
  # 1. git diff --name-only --diff-filter=U  → listar arquivos em conflito
  # 2. Resolver manualmente
  # 3. git add <arquivos resolvidos>
  # 4. git commit --no-edit

  git push origin main
  git checkout $FEATURE_BRANCH
fi
```

Regra: conflitos são algo a resolver, não motivo para abortar.

---

## Anti-patterns

**Mensagens genéricas**

```bash
# ERRADO
git commit -m "fix"
git commit -m "updates"
git commit -m "wip"

# CERTO
git commit -m "fix(auth): corrigir expiração prematura de token em UTC"
```

**Commit sem análise**

```bash
# ERRADO
git add . && git commit -m "changes" && git push

# CERTO: analisar → validar → gerar mensagem → push
```

**Push com debug code**

```bash
# ERRADO: commitar console.log / debugger
# CERTO: remover antes de commitar
```

**Commit de secrets**

```bash
# ERRADO: .env, credentials.json, chaves privadas
# CERTO: só .env.example com valores placeholder
```

---

## Checklist completo

**Pré-commit:**

- [ ] Syntax check nos arquivos modificados
- [ ] Sem debug code (console.log, debugger, pdb)
- [ ] Sem secrets ou tokens hardcoded
- [ ] .gitignore cobre node_modules, .env, build/

**Commit:**

- [ ] Tipo correto (feat/fix/docs/style/refactor/test/chore/ci/perf)
- [ ] Escopo identificado (módulo ou área)
- [ ] Descrição em imperativo, minúscula, sem ponto
- [ ] Máximo 72 caracteres na primeira linha
- [ ] Breaking changes com `!` e rodapé `BREAKING CHANGE:`

**Push:**

- [ ] Branch confirmada
- [ ] Remote correto
- [ ] Sem divergência não-resolvida
- [ ] Push bem-sucedido
- [ ] Working tree clean após push

**Pós-push:**

- [ ] Verificar pipeline de CI/CD se houver
- [ ] Se feature branch: merge para main executado
- [ ] Main atualizada e pushada

---

Ver também: `skills/git/commit-conventions.md`, `skills/automacao/git-auto-push-hook.md`

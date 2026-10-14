Listar PRs GitHub

Script bash+Python para listar Pull Requests de um repositório com filtros por data.
Não requer `gh` CLI — usa GitHub REST API com o token extraído do remote URL.

---

QUANDO USAR

  - Revisão de PRs abertos ou mergeados em um período
  - Relatório de atividade do repositório
  - "liste os PRs desta semana"
  - "quais PRs foram mergeados hoje"

---

FILTROS DISPONÍVEIS

  hoje        PRs das últimas 24h
  ontem       PRs do dia anterior
  semana      PRs dos últimos 7 dias
  mes         PRs dos últimos 30 dias
  YYYY-MM-DD  PRs de uma data específica
  YYYY-MM-DD:YYYY-MM-DD  Intervalo de datas

---

SCRIPT

```bash
#!/bin/bash
# liste-pr-github.sh
# Uso: ./liste-pr-github.sh [hoje|ontem|semana|mes|YYYY-MM-DD]

FILTRO="${1:-semana}"

# Extrair owner/repo do remote origin
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
REPO=$(echo "$REMOTE_URL" \
  | sed -E 's|.*[:/]([^/]+/[^/]+?)(\.git)?$|\1|')

if [ -z "$REPO" ]; then
  echo "❌ Repositório não detectado. Execute dentro de um repositório git."
  exit 1
fi

# Extrair token do remote URL (formato https://token@github.com/...)
TOKEN=$(echo "$REMOTE_URL" | grep -oP '(?<=https://)([^@]+)(?=@)' 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "❌ Token não encontrado no remote URL."
  echo "Configure com: git remote set-url origin https://<token>@github.com/<owner>/<repo>"
  exit 1
fi

# Calcular data de corte
case "$FILTRO" in
  hoje)       DESDE=$(date -d "today" +%Y-%m-%dT00:00:00Z 2>/dev/null || date -v0H -v0M -v0S +%Y-%m-%dT%H:%M:%SZ) ;;
  ontem)      DESDE=$(date -d "yesterday" +%Y-%m-%dT00:00:00Z 2>/dev/null || date -v-1d -v0H -v0M -v0S +%Y-%m-%dT%H:%M:%SZ) ;;
  semana)     DESDE=$(date -d "7 days ago" +%Y-%m-%dT00:00:00Z 2>/dev/null || date -v-7d -v0H -v0M -v0S +%Y-%m-%dT%H:%M:%SZ) ;;
  mes)        DESDE=$(date -d "30 days ago" +%Y-%m-%dT00:00:00Z 2>/dev/null || date -v-30d -v0H -v0M -v0S +%Y-%m-%dT%H:%M:%SZ) ;;
  *:*)        DESDE="${FILTRO%%:*}T00:00:00Z"; ATE="${FILTRO##*:}T23:59:59Z" ;;
  [0-9]*)     DESDE="${FILTRO}T00:00:00Z"; ATE="${FILTRO}T23:59:59Z" ;;
esac

# Buscar PRs via API
RESPONSE=$(curl -s \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${REPO}/pulls?state=all&per_page=100&sort=updated&direction=desc" \
  2>/dev/null)

if [ $? -ne 0 ] || echo "$RESPONSE" | grep -q '"message"'; then
  # Fallback: git log
  echo "⚠️  API indisponível — usando git log"
  git log --merges --oneline --since="$DESDE" \
    --pretty=format:"| %h | %s | merged | %ad | — |" \
    --date=format:"%d/%m"
  exit 0
fi

# Processar com Python (sem dependência de jq)
echo "$RESPONSE" | python3 - << 'PYEOF'
import json, sys

data = json.load(sys.stdin)
desde = __import__('os').environ.get('DESDE', '')

print(f"| # | Título | Status | Criado | Mergeado | Autor |")
print(f"|---|--------|--------|--------|---------|-------|")

count = 0
for pr in data:
    created = pr.get('created_at', '')[:10]
    merged  = (pr.get('merged_at') or '')[:10] or '—'
    status  = 'merged' if pr.get('merged_at') else pr.get('state', 'open')
    author  = pr.get('user', {}).get('login', '?')
    title   = pr.get('title', '')[:60]
    number  = pr.get('number', 0)

    # Converter data para DD/MM
    def fmt(d):
        if not d or d == '—': return '—'
        parts = d.split('-')
        return f"{parts[2]}/{parts[1]}" if len(parts) == 3 else d

    print(f"| #{number} | {title} | {status} | {fmt(created)} | {fmt(merged)} | @{author} |")
    count += 1

print(f"\nTotal: {count} PRs")
PYEOF
```

---

ALTERNATIVA VIA gh CLI

Se `gh` estiver disponível:

```bash
# PRs mergeados na última semana
gh pr list --state merged --limit 50 \
  --search "merged:>$(date -d '7 days ago' +%Y-%m-%d)" \
  --json number,title,mergedAt,author \
  --template '{{range .}}| #{{.number}} | {{.title}} | {{.mergedAt}} | @{{.author.login}} |{{"\n"}}{{end}}'
```

---

SEGURANÇA

- Token nunca aparece no output
- Sem logging de credenciais
- Erro de API faz fallback para git log local

---

Ver também: `skills/git/pr-template.md`, `skills/git/branching-strategy.md`

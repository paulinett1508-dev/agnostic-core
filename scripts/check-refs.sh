#!/usr/bin/env bash
# ============================================================
# check-refs.sh
#
# Valida a integridade do acervo:
#   1. Todos os paths @.agnostic-core/... referenciados em docs/,
#      exemplos/, templates/, commands/ e agents/ apontam para
#      arquivos que existem.
#   2. Todos os paths listados em docs/skills-index.md existem.
#   3. Todo SKILL.md em .claude/skills/ tem frontmatter válido
#      (name + description).
#
# Saída não-zero se qualquer verificação falhar.
# ============================================================

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

errors=0
warnings=0

echo "=== 1/3 Verificando @.agnostic-core/ refs ==="
# Procura por padrões @.agnostic-core/<path> ou `.agnostic-core/<path>`
# em docs, exemplos, templates, commands, agents e CLAUDE.md/README.md
while IFS= read -r match; do
  file="${match%%:*}"
  line_rest="${match#*:}"
  # Extrai caminhos .agnostic-core/... (com ou sem @ prefixo)
  refs=$(echo "$line_rest" | grep -oE '\.agnostic-core/[A-Za-z0-9_./\-]+\.md' || true)
  for ref in $refs; do
    # Remove prefixo .agnostic-core/ — o arquivo real está em $REPO_ROOT/<resto>
    path="${ref#.agnostic-core/}"
    if [ ! -f "$REPO_ROOT/$path" ]; then
      echo -e "  ${RED}FALTA${NC} $file -> $ref"
      errors=$((errors + 1))
    fi
  done
done < <(grep -RInE '\.agnostic-core/[A-Za-z0-9_./\-]+\.md' \
  docs exemplos templates commands agents CLAUDE.md README.md ONBOARDING.md CONTRIBUTING.md 2>/dev/null || true)

echo ""
echo "=== 2/3 Verificando paths em docs/skills-index.md ==="
if [ -f "docs/skills-index.md" ]; then
  while IFS= read -r raw; do
    # Considerar apenas paths no início da linha (possivelmente indentados),
    # ignora paths que são parte de caminhos maiores (ex: .claude/skills/...)
    path=$(echo "$raw" | grep -oE '^[[:space:]]*(skills|agents|commands|templates|docs|exemplos|\.claude)/[A-Za-z0-9_./\-]+\.md' | head -1 | sed 's/^[[:space:]]*//')
    [ -z "$path" ] && continue
    if [ ! -f "$REPO_ROOT/$path" ]; then
      echo -e "  ${RED}FALTA${NC} docs/skills-index.md -> $path"
      errors=$((errors + 1))
    fi
  done < docs/skills-index.md
else
  echo -e "  ${YELLOW}AVISO${NC}: docs/skills-index.md não encontrado"
  warnings=$((warnings + 1))
fi

echo ""
echo "=== 3/3 Verificando frontmatter de SKILL.md ==="
while IFS= read -r -d '' skill; do
  # Verifica frontmatter YAML com name e description
  if ! head -15 "$skill" | grep -qE '^name:[[:space:]]*[A-Za-z0-9_-]+'; then
    echo -e "  ${RED}SEM name${NC} $skill"
    errors=$((errors + 1))
  fi
  if ! head -15 "$skill" | grep -qE '^description:'; then
    echo -e "  ${RED}SEM description${NC} $skill"
    errors=$((errors + 1))
  fi
done < <(find .claude/skills -name 'SKILL.md' -type f -print0 2>/dev/null)

echo ""
if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
  echo -e "${GREEN}OK${NC} - nenhum problema encontrado."
  exit 0
elif [ $errors -eq 0 ]; then
  echo -e "${YELLOW}$warnings aviso(s)${NC} - nenhum erro bloqueante."
  exit 0
else
  echo -e "${RED}$errors erro(s)${NC} e ${YELLOW}$warnings aviso(s)${NC}."
  exit 1
fi

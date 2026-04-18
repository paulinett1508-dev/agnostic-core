#!/usr/bin/env bash
# ============================================================
# generate-claude-skills.sh
#
# Gera a camada nativa Claude Code (.claude/skills/<nome>/SKILL.md)
# a partir dos Markdown puros em .agnostic-core/skills/.
#
# Os SKILL.md gerados contêm frontmatter YAML válido e apontam,
# por referência, para o arquivo-fonte em .agnostic-core/skills/.
# A fonte única da verdade continua sendo o Markdown original —
# isto apenas expõe os títulos/descrições para autodescoberta.
#
# Uso:
#   bash scripts/generate-claude-skills.sh [target_dir]
#
#   target_dir  Pasta-raiz onde será criado .claude/skills/
#               (padrão: diretório atual)
# ============================================================

set -e

TARGET_DIR="${1:-$(pwd)}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$SOURCE_DIR/skills"
SKILLS_DST="$TARGET_DIR/.claude/skills"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "ERRO: $SKILLS_SRC não existe." >&2
  exit 1
fi

mkdir -p "$SKILLS_DST"

slug() {
  # Converte "frontend/react-performance.md" em "frontend-react-performance"
  local raw="$1"
  raw="${raw%.md}"
  raw="${raw//\//-}"
  # lowercase + troca caracteres inválidos por '-'
  echo "$raw" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

first_heading() {
  # Primeira linha começando com '# ' (até 120 chars)
  awk '/^# / { sub(/^# +/, ""); print; exit }' "$1" | head -c 120
}

first_paragraph() {
  # Primeiro parágrafo não vazio ignorando frontmatter e headings (até 200 chars)
  awk '
    BEGIN { in_fm = 0; captured = 0 }
    NR == 1 && /^---/ { in_fm = 1; next }
    in_fm && /^---/ { in_fm = 0; next }
    in_fm { next }
    /^#/ { next }
    /^[[:space:]]*$/ { next }
    { print; exit }
  ' "$1" | head -c 200
}

COUNT=0
while IFS= read -r -d '' file; do
  rel="${file#$SKILLS_SRC/}"

  # Pula arquivos que são apenas índices/README internos
  case "$(basename "$rel")" in
    README.md|INDEX.md|_*) continue;;
  esac

  name="$(slug "$rel")"
  heading="$(first_heading "$file")"
  para="$(first_paragraph "$file")"
  desc="${heading:-$para}"
  desc="${desc:-Skill agnostic-core: $rel}"

  # Escapa aspas duplas no description
  desc_escaped="${desc//\"/\\\"}"

  dir="$SKILLS_DST/$name"
  mkdir -p "$dir"

  cat > "$dir/SKILL.md" <<EOF
---
name: $name
description: "$desc_escaped"
---

Ver o conteúdo completo da skill em:

\`.agnostic-core/skills/$rel\`

Esta skill faz parte do acervo \`agnostic-core\`. O arquivo-fonte acima é
a referência canônica — edite lá, não aqui.
EOF

  COUNT=$((COUNT + 1))
done < <(find "$SKILLS_SRC" -type f -name '*.md' -print0)

echo "Geradas $COUNT skills em $SKILLS_DST"

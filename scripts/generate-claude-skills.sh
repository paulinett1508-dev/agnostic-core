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
  # Converte "react-performance.md" em "react-performance"
  local raw="$1"
  raw="${raw%.md}"
  # lowercase + troca caracteres inválidos por '-'
  echo "$raw" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

slug_source() {
  # Nome usado para gerar o slug: basename do arquivo, exceto para
  # SKILL.md (usa o nome do diretório-pai, já que o arquivo em si é genérico)
  local rel="$1"
  local base
  base="$(basename "$rel")"
  if [ "$base" = "SKILL.md" ]; then
    basename "$(dirname "$rel")"
  else
    echo "$base"
  fi
}

first_heading() {
  # Primeira linha começando com '# ' (até 120 chars), ignorando blocos de código
  # (um '# comentário' dentro de ``` não é um heading Markdown).
  awk '
    /^```/ { in_code = !in_code; next }
    !in_code && /^# / { sub(/^# +/, ""); print; exit }
  ' "$1" | head -c 120
}

first_paragraph() {
  # Primeiro parágrafo não vazio ignorando frontmatter, headings e blocos de código (até 200 chars)
  awk '
    BEGIN { in_fm = 0; in_code = 0 }
    NR == 1 && /^---/ { in_fm = 1; next }
    in_fm && /^---/ { in_fm = 0; next }
    in_fm { next }
    /^```/ { in_code = !in_code; next }
    in_code { next }
    /^#/ { next }
    /^[[:space:]]*$/ { next }
    { print; exit }
  ' "$1" | head -c 200
}

# Manifesto do que ESTE script gerou na última execução. Sem ele, uma mudança
# no esquema de nomes deixa o diretório antigo para trás para sempre — cada
# skill órfã continua ocupando espaço no system prompt de toda sessão, com
# descrição idêntica à da skill viva. O manifesto é o que permite podar sem
# risco: só é removido o que este script criou, nunca skill escrita à mão.
MANIFEST="$SKILLS_DST/.agnostic-generated"
GENERATED=""

COUNT=0
while IFS= read -r -d '' file; do
  rel="${file#$SKILLS_SRC/}"

  # Pula arquivos que são apenas índices/README internos
  case "$(basename "$rel")" in
    README.md|INDEX.md|_*) continue;;
  esac

  name="$(slug "$(slug_source "$rel")")"
  heading="$(first_heading "$file")"
  para="$(first_paragraph "$file")"
  desc="${heading:-$para}"
  desc="${desc:-Skill agnostic-core: $rel}"

  # Escapa aspas duplas no description
  desc_escaped="${desc//\"/\\\"}"

  dir="$SKILLS_DST/$name"
  mkdir -p "$dir"

  {
    printf -- "---\nname: %s\ndescription: \"%s\"\n---\n\n" "$name" "$desc_escaped"
    cat "$file"
  } > "$dir/SKILL.md"

  GENERATED="$GENERATED$name"$'\n'
  COUNT=$((COUNT + 1))
done < <(find "$SKILLS_SRC" -type f -name '*.md' -print0)

# Poda: o que estava no manifesto anterior e não foi gerado agora é órfão.
PRUNED=0
if [ -f "$MANIFEST" ]; then
  while IFS= read -r old; do
    [ -n "$old" ] || continue
    if ! printf '%s' "$GENERATED" | grep -qxF "$old"; then
      rm -rf "${SKILLS_DST:?}/$old"
      PRUNED=$((PRUNED + 1))
    fi
  done < "$MANIFEST"
fi

printf '%s' "$GENERATED" | sort > "$MANIFEST"

echo "Geradas $COUNT skills em $SKILLS_DST (órfãs removidas: $PRUNED)"

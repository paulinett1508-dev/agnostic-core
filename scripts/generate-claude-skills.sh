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
#
# Seleção: se existir <target_dir>/.agnostic-skills, só as skills que casarem
# com os padrões daquele arquivo são espelhadas. Sem ele, espelha o acervo
# inteiro (comportamento histórico).
# ============================================================

set -e

TARGET_DIR="${1:-$(pwd)}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$SOURCE_DIR/skills"
SKILLS_DST="$TARGET_DIR/.claude/skills"
ALLOWLIST="$TARGET_DIR/.agnostic-skills"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "ERRO: $SKILLS_SRC não existe." >&2
  exit 1
fi

mkdir -p "$SKILLS_DST"

# ------------------------------------------------------------
# Seleção de relevância
#
# Cada skill espelhada custa uma linha no system prompt de TODA sessão do repo
# consumidor, sempre, tenha ou não relação com a stack dele. Espelhar o acervo
# inteiro faz um projeto TypeScript pagar por `python-patterns` e
# `replit-patterns` em cada turno. O acervo é grande de propósito — a seleção
# é responsabilidade de quem consome.
#
# Formato de .agnostic-skills: um padrão por linha, '#' comenta.
#   backend/*            categoria inteira
#   frontend/react-*     glob
#   workflow/abrirsessao caminho exato (sem .md)
#   !frontend/seo-*      exclusão, avaliada depois das inclusões
#
# Sem o arquivo, nada é filtrado: repo que ainda não escolheu continua com o
# acervo completo, como antes.
# ------------------------------------------------------------
INCLUDE=()
EXCLUDE=()
if [ -f "$ALLOWLIST" ]; then
  while IFS= read -r pat || [ -n "$pat" ]; do
    pat="${pat%$'\r'}"
    pat="${pat%%#*}"
    pat="$(printf '%s' "$pat" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -n "$pat" ] || continue
    case "$pat" in
      '!'*) EXCLUDE+=("${pat#!}");;
      *)    INCLUDE+=("$pat");;
    esac
  done < "$ALLOWLIST"
fi

selected() {
  # $1 = caminho relativo da skill, sem .md (ex.: "backend/rest-api-design")
  local rel="$1" pat
  if [ ${#INCLUDE[@]} -gt 0 ]; then
    local hit=0
    for pat in "${INCLUDE[@]}"; do
      # shellcheck disable=SC2053
      [[ "$rel" == $pat ]] && { hit=1; break; }
    done
    [ "$hit" -eq 1 ] || return 1
  fi
  for pat in "${EXCLUDE[@]}"; do
    # shellcheck disable=SC2053
    [[ "$rel" == $pat ]] && return 1
  done
  return 0
}

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

is_support_file() {
  # Verdadeiro para arquivo que vive DENTRO de um diretório-skill (o que tem
  # SKILL.md) sem ser o próprio SKILL.md: `references/`, `assets/` e afins são
  # material de apoio da skill, não skills por si.
  #
  # Sem isto, skills/audit/dead-code-auditor/references/checklist.md virava uma
  # skill de topo chamada `checklist` — com descrição "Dead Code Checklist" e
  # sem nenhum contexto de quando acionar — ocupando o system prompt de todo
  # consumidor. Mesmo caso de skills/design-system/assets/.
  local rel="$1" dir
  [ "$(basename "$rel")" = "SKILL.md" ] && return 1
  dir="$(dirname "$rel")"
  while [ "$dir" != "." ] && [ -n "$dir" ] && [ "$dir" != "/" ]; do
    [ -f "$SKILLS_SRC/$dir/SKILL.md" ] && return 0
    dir="$(dirname "$dir")"
  done
  return 1
}

# Todas as extrações abaixo operam sobre a fonte JÁ normalizada (sem CR).
# Arquivo gravado em Windows chega com CRLF e o CR sobrevive dentro do valor
# YAML — `description: "Texto<CR>"` — quebrando o parse do frontmatter no
# harness, que passa a exibir a skill sem descrição nenhuma.

strip_frontmatter() {
  # Remove o bloco de frontmatter do arquivo-fonte, se houver.
  # Sem isto o SKILL.md gerado sai com DOIS blocos: o harness lê o primeiro
  # (o nosso, derivado do título) e a description real escrita pelo autor —
  # a que traz as palavras-gatilho — vira corpo de texto e nunca chega ao
  # roteamento. A skill fica muda: existe, ocupa prompt, nunca é invocada.
  awk '
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/   { in_fm = 0; eat_blank = 1; next }
    in_fm { next }
    eat_blank && /^[[:space:]]*$/ { next }
    { eat_blank = 0; print }
  ' "$1"
}

source_description() {
  # description declarada no frontmatter do próprio arquivo-fonte.
  # É a melhor fonte que existe: foi escrita para dizer QUANDO acionar a skill,
  # não o que ela é. Suporta escalar simples e bloco dobrado (`>` / `|`).
  awk '
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    !in_fm { exit }
    /^---[[:space:]]*$/ { exit }
    !folding && /^description:[[:space:]]*/ {
      val = $0
      sub(/^description:[[:space:]]*/, "", val)
      gsub(/^"|"$/, "", val)
      if (val == ">" || val == "|" || val == ">-" || val == "|-") { folding = 1; next }
      print val; exit
    }
    folding {
      if ($0 ~ /^[[:space:]]+[^[:space:]]/) {
        line = $0; sub(/^[[:space:]]+/, "", line)
        acc = (acc == "" ? line : acc " " line)
        next
      }
      print acc; exit
    }
    END { if (folding && acc != "") print acc }
  ' "$1"
}

purpose_line() {
  # Linha de propósito no topo do documento. Em ~1/3 do acervo é ela que diz
  # quando usar a skill ("Objetivo: ... Use como checklist de entrega").
  awk '
    NR > 12 { exit }
    /^(Objetivo|Objective|Prop[oó]sito|Quando usar)[[:space:]]*:[[:space:]]*/ {
      sub(/^[^:]*:[[:space:]]*/, ""); print; exit
    }
  ' "$1"
}

title_line() {
  # Título do documento: heading '# ' ou, no acervo antigo, a primeira linha
  # não vazia em texto puro. Ignora blocos de código.
  awk '
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { in_fm = 0; next }
    in_fm { next }
    /^```/ { in_code = !in_code; next }
    in_code { next }
    /^[[:space:]]*$/ { next }
    { sub(/^#+[[:space:]]*/, ""); print; exit }
  ' "$1"
}

body_paragraph() {
  # Primeiro parágrafo de conteúdo DEPOIS do título. A versão anterior parava
  # no título quando o arquivo não usava '# ', que é o caso da maioria do
  # acervo — daí 61 skills terem acabado com description idêntica ao nome,
  # sem nenhum sinal de quando acioná-las.
  awk -v title="$2" '
    NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
    in_fm && /^---[[:space:]]*$/ { in_fm = 0; next }
    in_fm { next }
    /^```/ { in_code = !in_code; next }
    in_code { next }
    /^[[:space:]]*$/ { next }
    /^[-=]{3,}[[:space:]]*$/ { next }
    { line = $0; sub(/^#+[[:space:]]*/, "", line)
      if (line == title) next
      if (line ~ /^(Adaptado|Fonte|Baseline|Inspirado)/) next
      print line; exit }
  ' "$1"
}

normalize_desc() {
  # A description é extraída de Markdown cru, então chega com a marcação do
  # documento colada: '> ' de blockquote, '- ' de lista, '**' de negrito,
  # espaço duplo no fim. Nada disso informa o roteamento — é ruído ocupando
  # os 130 caracteres úteis de toda sessão.
  printf '%s' "$1" \
    | sed 's/^[[:space:]]*\(>[[:space:]]*\)\{1,\}//' \
    | sed 's/^[[:space:]]*[*-][[:space:]][[:space:]]*//' \
    | sed 's/\*\*//g; s/`//g' \
    | sed 's/[[:space:]][[:space:]]*/ /g' \
    | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

truncate_desc() {
  # Corta em fronteira de palavra: description cortada no meio de uma palavra
  # atrapalha o roteamento mais do que ajuda.
  local s="$1" max="$2"
  if [ "${#s}" -le "$max" ]; then printf '%s' "$s"; return; fi
  s="${s:0:$max}"
  printf '%s' "${s% *}"
}

# Manifesto do que ESTE script gerou na última execução. Sem ele, uma mudança
# no esquema de nomes deixa o diretório antigo para trás para sempre — cada
# skill órfã continua ocupando espaço no system prompt de toda sessão, com
# descrição idêntica à da skill viva. O manifesto é o que permite podar sem
# risco: só é removido o que este script criou, nunca skill escrita à mão.
MANIFEST="$SKILLS_DST/.agnostic-generated"
GENERATED=""

# Marca gravada no corpo de todo SKILL.md gerado. É o que torna a poda segura
# quando a skill-fonte deixa de existir: sem a marca, um acervo que perde uma
# skill deixa o diretório gerado órfão no consumidor para sempre, porque não há
# mais nada no acervo de onde derivar o nome dele.
MARKER='<!-- agnostic-core:generated — não editar; a fonte é .agnostic-core/skills/ -->'

# Conjunto de todos os slugs que ESTE script já produziu ou poderia produzir,
# sob QUALQUER esquema de nomes que ele já usou:
#
#   esquema atual  (desde e9fa143): basename          -> "caveman"
#   esquema legado (até e9fa143):   caminho completo  -> "behavioral-caveman"
#
# O manifesto sozinho não cobre nem a troca de esquema nem a adoção tardia de
# .agnostic-skills: nos dois casos o manifesto anterior não existe ou não
# menciona o diretório antigo, e ele fica no disco cobrando espaço no system
# prompt de toda sessão. Derivar os nomes do próprio acervo resolve os dois de
# uma vez, e é exato: um nome só entra aqui se saiu de um arquivo em skills/.
OWNED=""
while IFS= read -r -d '' f; do
  r="${f#$SKILLS_SRC/}"
  case "$(basename "$r")" in README.md|INDEX.md|_*) continue;; esac
  OWNED="$OWNED$(slug "$(slug_source "$r")")"$'\n'
  OWNED="$OWNED$(slug "${r%.md}")"$'\n'
done < <(find "$SKILLS_SRC" -type f -name '*.md' -print0)
OWNED="$(printf '%s' "$OWNED" | sort -u)"

COUNT=0
SKIPPED=0
while IFS= read -r -d '' file; do
  rel="${file#$SKILLS_SRC/}"

  # Pula arquivos que são apenas índices/README internos
  case "$(basename "$rel")" in
    README.md|INDEX.md|_*) continue;;
  esac

  is_support_file "$rel" && continue

  selected "${rel%.md}" || { SKIPPED=$((SKIPPED + 1)); continue; }

  name="$(slug "$(slug_source "$rel")")"

  # Fonte normalizada — sem CR. Toda extração e o corpo gerado saem daqui.
  norm="$(mktemp)"
  tr -d '\r' < "$file" > "$norm"

  # Precedência da description, da melhor para a pior:
  #   1. frontmatter do autor  — escrito para dizer quando acionar
  #   2. título + linha de propósito ("Objetivo: ...")
  #   3. título + primeiro parágrafo de conteúdo
  #   4. título sozinho, e por último o caminho do arquivo
  # Título sozinho é o pior caso justamente porque repete o nome da skill:
  # ocupa espaço no prompt de toda sessão sem informar nada ao roteamento.
  desc="$(source_description "$norm")"
  if [ -z "$desc" ]; then
    # body_paragraph precisa do título CRU para reconhecer e pular a linha do
    # título no corpo; a normalização entra depois, só no que vai virar texto.
    title_raw="$(title_line "$norm")"
    title="$(normalize_desc "$title_raw")"
    detail="$(normalize_desc "$(purpose_line "$norm")")"
    [ -n "$detail" ] || detail="$(normalize_desc "$(body_paragraph "$norm" "$title_raw")")"
    if [ -n "$title" ] && [ -n "$detail" ]; then
      desc="$title — $detail"
    else
      desc="${title:-$detail}"
    fi
  fi
  desc="${desc:-Skill agnostic-core: $rel}"
  desc="$(normalize_desc "$desc")"
  desc="$(truncate_desc "$desc" 130)"

  # Escapa aspas duplas no description
  desc_escaped="${desc//\"/\\\"}"

  dir="$SKILLS_DST/$name"
  mkdir -p "$dir"

  {
    printf -- "---\nname: %s\ndescription: \"%s\"\n---\n\n" "$name" "$desc_escaped"
    printf -- "%s\n\n" "$MARKER"
    strip_frontmatter "$norm"
  } > "$dir/SKILL.md"

  rm -f "$norm"

  GENERATED="$GENERATED$name"$'\n'
  COUNT=$((COUNT + 1))
done < <(find "$SKILLS_SRC" -type f -name '*.md' -print0)

# Poda. Um diretório é removido quando não foi gerado agora E é comprovadamente
# nosso — por qualquer uma das três provas, em ordem de força:
#
#   1. está no manifesto da execução anterior
#   2. carrega a marca de gerado no corpo do SKILL.md
#   3. o nome dele é derivável de um arquivo do acervo (conjunto OWNED),
#      cobrindo o legado que nasceu antes de existirem manifesto e marca
#
# Skill escrita à mão não satisfaz nenhuma das três: não estava no manifesto,
# não tem a marca, e o nome não sai de skills/.
PRUNED=0
PRUNED_LIST=""

owned_by_us() {
  local n="$1"
  [ -f "$MANIFEST" ] && grep -qxF "$n" "$MANIFEST" && return 0
  [ -f "$SKILLS_DST/$n/SKILL.md" ] && grep -qF "agnostic-core:generated" "$SKILLS_DST/$n/SKILL.md" && return 0
  printf '%s' "$OWNED" | grep -qxF "$n" && return 0
  return 1
}

for d in "$SKILLS_DST"/*/; do
  [ -d "$d" ] || continue
  n="$(basename "$d")"
  printf '%s' "$GENERATED" | grep -qxF "$n" && continue
  owned_by_us "$n" || continue
  rm -rf "${SKILLS_DST:?}/$n"
  PRUNED=$((PRUNED + 1))
  PRUNED_LIST="$PRUNED_LIST  $n"$'\n'
done

printf '%s' "$GENERATED" | sort > "$MANIFEST"

if [ -f "$ALLOWLIST" ]; then
  echo "Geradas $COUNT skills em $SKILLS_DST (fora da seleção: $SKIPPED, órfãs removidas: $PRUNED)"
else
  echo "Geradas $COUNT skills em $SKILLS_DST (órfãs removidas: $PRUNED)"
fi

if [ -n "$PRUNED_LIST" ]; then
  echo
  echo "Órfãs removidas (sobras de gerações anteriores):"
  printf '%s' "$PRUNED_LIST"
fi

# Sobras que a poda deliberadamente não alcança: diretórios cujo nome não é
# derivável do acervo, sem a marca de gerado e ausentes do manifesto. A leitura
# mais provável é skill escrita à mão pelo próprio projeto — apagar seria
# destruir trabalho alheio. Reportamos para que a decisão seja de quem escreveu.
UNPRUNED=""
for d in "$SKILLS_DST"/*/; do
  [ -d "$d" ] || continue
  n="$(basename "$d")"
  printf '%s' "$GENERATED" | grep -qxF "$n" && continue
  [ -f "$d/SKILL.md" ] || continue
  UNPRUNED="$UNPRUNED  $n"$'\n'
done

if [ -n "$UNPRUNED" ]; then
  echo
  echo "AVISO: $(printf '%s' "$UNPRUNED" | grep -c .) skill(s) em $SKILLS_DST não vieram do acervo:"
  printf '%s' "$UNPRUNED"
  echo "Se forem escritas à mão pelo projeto, ignore. Se não, remova — cada uma"
  echo "ocupa o system prompt de toda sessão."
fi

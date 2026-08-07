#!/usr/bin/env bash
# ============================================================
# parity.sh — os dois motores do agnostic-router decidem igual?
#
# `router.py` e `router.js` sao a MESMA logica escrita duas vezes, mantida a
# mao. Isso so e defensavel enquanto houver algo mecanico provando que as duas
# concordam — sem isso elas divergem em silencio, e a divergencia so aparece
# em producao, na forma de um prompt roteado para o modelo errado.
#
# Ja aconteceu: `\b` em JavaScript e ASCII-only, entao o marcador
# `\bo que (é|e|significa)\b` — peso 0.8, o maior do explore — nunca casava no
# motor JS. "o que e esse erro?" ia para sonnet/debug no JS e haiku/explore no
# Python. Um caractere acentuado, dois modelos diferentes, nenhum aviso.
#
# Uso:
#   bash scripts/agnostic-router/parity.sh
#
# Sai 0 quando os dois motores concordam em tier, fase e confianca para todo o
# corpus. Sai 1 no primeiro desacordo, listando cada caso.
# ============================================================

set -u
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v python3 >/dev/null || { echo "python3 nao encontrado"; exit 2; }
command -v node    >/dev/null || { echo "node nao encontrado";    exit 2; }

CORPUS="$(mktemp)"
OUT_PY="$(mktemp)"
OUT_JS="$(mktemp)"
trap 'rm -f "$CORPUS" "$OUT_PY" "$OUT_JS"' EXIT

# Corpus deliberadamente carregado de portugues acentuado: e exatamente onde as
# diferencas de semantica de regex entre as duas linguagens aparecem. Cada fase
# aparece em forma clara e em forma ambigua, porque o roteamento erra primeiro
# nas bordas.
cat > "$CORPUS" <<'CORPUS'
o que é um race condition?
o que é esse erro?
o que é a melhor abordagem pra isso?
o que significa esse warning?
qual a diferença entre map e forEach
me explica como funciona o event loop
tenho uma dúvida sobre transações
existe alguma recomendação pra isso?
planeja a arquitetura de um sistema de filas distribuído em prod
qual a melhor estratégia de cache pra multi-tenant
desenha o schema do banco pra multi-tenant
migra o monolito pra microserviços
estrutura o projeto do zero
implementa o endpoint POST /users com validação
troca o nome dessa variável pra userId
cria a função de cálculo contábil
escreve os testes unitários desse módulo
adiciona um console.log aqui
não funciona, dá ORA-00001 quando insere
por que não está salvando no banco?
investiga esse memory leak em produção
o teste tá quebrando no CI
debugga essa race condition
audita esse código de pagamento buscando vulnerabilidades de segurança
revisa esse PR inteiro
analisa a arquitetura desse módulo
está correto usar transação aqui?
quais as boas práticas pra isso
resume esse log pra mim em 3 linhas
lista os arquivos da pasta
deploy pra produção agora
só me diz o nome do arquivo
faz o rollback rápido
refatora todo o módulo de auth pra OAuth2 no projeto inteiro
opera de forma autônoma por várias horas nesse refactor
faça tudo: migração, testes e deploy
isso é irreversível em produção?
precisa de consistência entre vários serviços concorrentes
CORPUS

python3 - "$CORPUS" > "$OUT_PY" <<'PY'
import sys
sys.path.insert(0, ".")
from router import Router, SessionState
r = Router()
for line in open(sys.argv[1], encoding="utf-8"):
    m = line.strip()
    if not m:
        continue
    d = r.route(m, SessionState())
    print(f"{d.tier.value}|{d.signals.phase.value}|{d.confidence:.2f}")
PY

node -e '
const fs = require("fs");
const { Router, newSessionState } = require("./router.js");
const r = new Router();
for (const line of fs.readFileSync(process.argv[1], "utf8").split("\n")) {
  const m = line.trim();
  if (!m) continue;
  const d = r.route(m, newSessionState());
  console.log([d.tier, d.signals.phase, d.confidence.toFixed(2)].join("|"));
}' "$CORPUS" > "$OUT_JS"

n=$(grep -c . "$CORPUS")
diverg=0
i=0
while IFS= read -r msg; do
  [ -n "$msg" ] || continue
  i=$((i + 1))
  py=$(sed -n "${i}p" "$OUT_PY")
  js=$(sed -n "${i}p" "$OUT_JS")
  if [ "$py" != "$js" ]; then
    diverg=$((diverg + 1))
    printf 'DIVERGE  «%s»\n         py=%s\n         js=%s\n' "$msg" "$py" "$js"
  fi
done < "$CORPUS"

if [ "$diverg" -eq 0 ]; then
  echo "paridade OK — $n casos, router.py e router.js decidem igual"
  exit 0
fi
echo
echo "$diverg de $n casos divergem entre router.py e router.js."
echo "Os dois motores precisam decidir igual: o Python e a referencia e o"
echo "JavaScript e o que os hooks rodam de verdade."
exit 1

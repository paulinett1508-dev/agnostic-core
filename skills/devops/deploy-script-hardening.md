Hardening de Deploy Scripts em Host Compartilhado

Três armadilhas reais de scripts de deploy que rodam via SSH num host
compartilhado (checkout único, múltiplas sessões/pessoas podem disparar
deploy) e fazem `git pull` de si mesmos antes de buildar. Cada uma é
silenciosa até acontecer em produção — nenhuma aparece em teste local, porque
exigem exatamente a combinação "script versionado + host remoto + pull
próprio" que só existe nesse cenário.

Complementa `deploy-procedures.md` (workflow de deploy em 5 fases, nível
processo) e `pre-deploy-checklist.md` — esta skill é sobre a mecânica interna
do script de deploy em si, não sobre o processo ao redor dele.

---

PADRÃO 1 — Lock contra deploy concorrente

O PROBLEMA

Dois deploys disparados ao mesmo tempo (duas sessões, dois devs, um cron e
uma pessoa) no mesmo checkout compartilhado se sobrescrevem em silêncio —
sem lock, não há aviso nenhum de que outro processo já está buildando.

A SOLUÇÃO

Lock file na raiz do repo com PID + branch + timestamp + hostname de quem
está deployando. Staleness check: se o PID já morreu OU o lock é mais velho
que um teto configurável, trata como travado por queda anterior e segue (não
trava o host pra sempre por um processo que morreu sem limpar). Lock sempre
solto no fim via `trap`, sucesso ou erro.

  LOCK_FILE="$REPO_DIR/.deploying"
  STALE_SECONDS="${STALE_SECONDS:-1800}"

  if [ -f "$LOCK_FILE" ]; then
    read -r lock_pid lock_branch lock_ts lock_host < "$LOCK_FILE" || true
    age=$(( $(date +%s) - ${lock_ts:-0} ))
    if [ -n "${lock_pid:-}" ] && kill -0 "$lock_pid" 2>/dev/null && [ "$age" -lt "$STALE_SECONDS" ]; then
      echo "ERRO: outro deploy em andamento (PID $lock_pid, branch $lock_branch, há ${age}s)." >&2
      exit 1
    fi
    echo "AVISO: lock obsoleto — assumindo travado por queda anterior, seguindo."
  fi
  trap 'rm -f "$LOCK_FILE"' EXIT
  echo "$$ $(git rev-parse --abbrev-ref HEAD) $(date +%s) $(hostname)" > "$LOCK_FILE"

---

PADRÃO 2 — Script que se automodifica no próprio `git pull`

O PROBLEMA

Bash lê o arquivo do script conforme executa, não tudo de uma vez. Se o
`git pull` que o próprio script roda reescreve esse mesmo arquivo no meio da
execução (ex.: um deploy anterior adicionou uma seção nova ao script), o
processo em andamento pode continuar lendo de um offset que não corresponde
mais ao conteúdo real em disco.

Sintomas confirmados na prática: (a) uma seção inteira do script sendo
pulada em silêncio, sem erro — como se a versão antiga (sem a seção) ainda
estivesse rodando; (b) um erro relatado numa linha cujo conteúdo atual não
bate com o texto do erro — o processo estava lendo de um offset defasado.

A SOLUÇÃO

Logo após confirmar que o `pull` terminou (e antes de qualquer lógica que
dependa do conteúdo novo do script), reexecutar o próprio processo:

  git pull --ff-only origin "$branch"
  exec bash "$0" "$@"

`exec` relê o arquivo do zero e substitui o processo atual (preserva `$$` —
importante se um lock de PID, como no Padrão 1, depende dele). Estruture o
script em duas fases: Fase 1 (antes do `exec`) só confirma o pull e
reexecuta; Fase 2 (depois) contém tudo que precisa do conteúdo atualizado.

ARMADILHA CONFIRMADA: `trap ... EXIT` NÃO sobrevive a `exec`

Testado isoladamente:

  trap "echo TRAP_RODOU" EXIT
  echo "antes do exec"
  exec bash -c 'echo depois do exec; exit 0'
  # "TRAP_RODOU" nunca aparece — o trap armado antes do exec morreu com o
  # processo antigo, o processo novo não herda handler nenhum.

Se a Fase 1 armou um `trap` pra soltar o lock do Padrão 1, ele precisa ser
re-armado no início da Fase 2 — senão um erro na Fase 2 deixa o lock órfão
até o `STALE_SECONDS` expirar sozinho.

---

PADRÃO 3 — Verificar o escopo da credencial antes de desenhar automação em cima dela

O PROBLEMA

É fácil assumir que uma credencial de deploy (chave SSH, deploy key,
token) tem permissão de escrita só porque ela tem permissão de leitura —
e só descobrir o contrário na hora em que a automação já projetada tenta
escrever de verdade. Sinal real visto em produção: um `git push` de dentro
de um script de deploy falhando com

  ERROR: The key you are authenticating with has been marked as read only.

depois de a automação já ter commitado localmente (ex.: um bump de versão
automático a cada deploy) — o commit local fica órfão, nunca sai pro
remoto, e o próximo `git pull --ff-only` de qualquer sessão quebra por
divergência de histórico com o commit preso.

A SOLUÇÃO

Antes de desenhar qualquer automação que escreva num remoto (commit+push,
chamada de API que muda estado) a partir de um host/processo específico,
confirmar o escopo real da credencial que esse host usa — não assumir pela
capacidade de leitura:

- Git: testar com `git push --dry-run` antes de depender de push de
  verdade em produção, ou consultar a documentação/configuração da deploy
  key (muitas plataformas permitem marcar uma chave como somente leitura
  explicitamente, por design de segurança — não é bug, é intencional).
- API/token: checar o escopo documentado do token (`read`, `write`,
  granularidade por recurso) antes de montar um fluxo que depende de
  escrita.

Se a credencial for legitimamente somente leitura (frequentemente por
design: um host de deploy não deveria mesmo poder escrever de volta no
repo — reduz o raio de impacto se aquele host for comprometido), a escrita
tem que acontecer de onde já existe permissão de verdade (o commit/PR que
gera a mudança, antes do deploy), nunca ser retrofitada pro script que roda
no host restrito.

Se descobrir esse problema depois de já ter um commit órfão preso num
checkout remoto: `git reset --soft origin/<branch>` (preserva a working
tree) + `git checkout origin/<branch> -- <arquivo específico>` pros
arquivos que precisam voltar ao estado do commit remoto — nunca
`git reset --hard`, que apagaria qualquer outra modificação local legítima
e não relacionada que já exista nesse checkout compartilhado.

---

Referências
- skills/devops/deploy-procedures.md (workflow de deploy, nível processo)
- skills/devops/pre-deploy-checklist.md (checklist complementar)

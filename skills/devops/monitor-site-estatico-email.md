# Monitor de site estático por e-mail (relatório semanal + alertas)

Um script só (Python, biblioteca padrão) rodando por cron na própria VPS, que lê o log do nginx e
manda por e-mail um relatório semanal e alertas de queda. Sem analytics no navegador, sem serviço externo.

Origem: centroculturalsbr, 2026-11-06 (`monitor/cc_monitor.py`).

---

## Quando usar

- Site estático numa VPS (nginx), dono quer "números interessantes" por e-mail.
- Não se quer (ou não se pode, por LGPD/promessa ao leitor) colocar Google Analytics/cookies.

## Desenho

- **Dois modos no mesmo script:** `semanal` (relatório) e `alerta` (checagem curta).
- **Cron em `/etc/cron.d/<nome>`**, não no crontab do root: não mistura com cron de outros sistemas.
  VPS em UTC: segunda 8h de Brasília = `0 11 * * 1`.
- **Alerta só quando muda o estado** (arquivo de estado em `/var/lib/<nome>/state.json`):
  avisa "fora do ar" na 2ª checagem seguida com falha (evita alarme por instabilidade de segundos),
  avisa "voltou" uma vez, e certificado perto de vencer no máximo uma vez por dia.
  Sem isso, um cron de 15 em 15 minutos vira 96 e-mails por dia.
- **Relatório com comparação** com a semana anterior: o logrotate padrão do Ubuntu guarda 14 dias,
  exatamente duas semanas.

## Números que valem a pena (só do log)

Páginas vistas (sem assets nem robôs), visitantes únicos aproximados, páginas mais vistas, origem
(Google / direto / redes / outros, pelo `Referer`), downloads de arquivos-chave, visitas do Googlebot,
404 mais pedidos (mostra links quebrados e varredura de bots), 5xx, dias até o certificado vencer, disco.

## Armadilhas encontradas

1. **Log compartilhado.** Em VPS com vários sites, o `access.log` padrão mistura todos e o formato
   `combined` não tem o host. Dar ao site um `access_log` próprio em cada `server` (80 e 443) *antes*
   de prometer números: o histórico anterior não dá para separar.
2. **Privacidade.** IP + User-Agent viram hash só em memória para contar únicos; nada de IP no relatório
   nem em arquivo. Ter um teste que falha se um IP aparecer no resultado. Avisar na página de
   privacidade que o servidor guarda registros técnicos (e por quanto tempo).
3. **Envio pelo Google Workspace:** `smtp.gmail.com:587` + STARTTLS + **senha de app** (exige
   verificação em duas etapas na conta). Separar `SMTP_USER` (conta que loga) de `MAIL_FROM`
   (alias que aparece): para o alias valer, ele precisa estar em Gmail → Configurações → Contas →
   "Enviar e-mail como" da conta que loga; senão o Gmail troca o remetente.
4. **Não usar conta de administrador** para a senha de app: quem comprometer a VPS lê e envia como o
   admin. Conta dedicada ou alias numa conta comum.
5. **Senha nunca no chat nem no repo.** O dono grava direto na VPS, sem eco:

   ```bash
   read -rsp "Senha de app: " P; echo; P=${P// /}
   printf 'SMTP_USER=...\nSMTP_PASS=%s\nMAIL_FROM=...\nMAIL_TO=...\n' "$P" \
     | ssh root@vps 'umask 077; cat > /etc/<nome>.env'; unset P
   ```

   Para conferir sem ler a senha: `stat -c '%a %U' /etc/<nome>.env` e o tamanho do valor (16 = senha de app).
6. **Sem o arquivo de senha, modo seco:** o script imprime o e-mail no log em vez de falhar. Dá para
   instalar o cron antes de a conta existir.
7. **`datetime.utcnow()` está obsoleto** no Python 3.12 e o aviso iria para o log a cada execução:
   usar `datetime.now(timezone.utc)`.
8. **`pkill -f padrão` pode matar o próprio shell** se o padrão aparecer na linha de comando; para
   esperar processos, cuidado com `pgrep -f` casando consigo mesmo.

## Verificação

- Teste a seco do relatório na VPS (`--dry-run`) com os logs reais.
- Um envio real e confirmação do recebimento (e do remetente) pelo dono antes de considerar pronto.

Scripting Contra Shell Restrito (Console de Appliance)

Como automatizar comandos via SSH em dispositivos que caem num menu numerado
em vez de shell direto (firewalls, roteadores, appliances de rede tipo
pfSense/Netgate), sem sshpass/expect instalados, e sem quebrar em shells
não-POSIX (tcsh, csh).

---

O PROBLEMA

`ssh user@host "comando"` normalmente executa o comando direto e sai. Mas
appliances de rede costumam interceptar QUALQUER sessão SSH — inclusive com
comando anexado — e cair num menu interativo numerado (ex.: "8) Shell").
Só depois de escolher a opção do menu é que um shell de verdade aparece.

Sintomas de que você está nesse caso:
  - `ssh host "comando"` retorna o banner/menu, não a saída do comando
  - Autenticação por senha (sem chave), sem sshpass/expect disponíveis
  - O shell por trás do menu não é bash — muitas vezes é tcsh/csh

---

PASSO 1 — PTY manual em vez de sshpass/expect

Se sshpass/expect não estão instalados e você não tem como instalar (sem
sudo, sem rede, ambiente restrito), use um PTY via `pty.fork()` (Python
stdlib, sem dependência externa) pra automatizar a autenticação por senha:

  import pty, os, select

  def ssh_interactive(host, user, password, remote_cmd, port=22, timeout=30):
      cmd = f"ssh -o StrictHostKeyChecking=no -p {port} {user}@{host}"
      pid, fd = pty.fork()
      if pid == 0:
          os.execvp("/bin/sh", ["/bin/sh", "-c", cmd])
      output, sent_pw = b"", False
      start = time.time()
      while time.time() - start < timeout:
          r, _, _ = select.select([fd], [], [], 3)
          if not r:
              continue
          data = os.read(fd, 4096)
          if not data:
              break
          output += data
          low = data.lower()
          if not sent_pw and b"password" in low and b":" in data:
              os.write(fd, (password + "\n").encode())
              sent_pw = True
      return output.decode(errors="replace")

Detectar o prompt de senha pela substring `"password"` (case-insensitive) +
presença de `:` — não assuma o texto exato ("Password:", "Password for
user@host:" variam entre appliances).

---

PASSO 2 — Navegar o menu antes do shell

Se o dispositivo cai num menu numerado, envie a opção certa como mais uma
"tecla" depois da senha, e só então envie o comando real. Detecte "silêncio
na saída por N segundos" como sinal de que o prompt anterior terminou, em
vez de tentar casar o texto exato do menu (ele muda entre versões/idiomas):

  sent_shell = False
  ...
  if not r:  # nada de novo por 3s = prompt provavelmente parado esperando
      if sent_pw and not sent_shell:
          os.write(fd, b"8\n")   # opção do menu (varia por appliance)
          sent_shell = True
      elif sent_shell and not sent_cmd:
          os.write(fd, (remote_cmd + "\n").encode())
          sent_cmd = True
      else:
          break

---

PASSO 3 — Shells não-POSIX (tcsh/csh): nunca confie em redirecionamento estilo bash

tcsh/csh NÃO suportam `2>&1`, `2>/dev/null` (redirecionamento por número de
fd) — falha com "Ambiguous output redirect." Sintomas desse erro = você está
num tcsh, não bash.

Regra: nunca redirecione stderr por número de fd num comando remoto até
confirmar o shell. Se precisar suprimir erro, redirecione só stdout
(`comando > arquivo`) ou aceite o stderr no output.

---

PASSO 4 — Comandos complexos: base64 em vez de escapar aspas

Aninhar aspas simples/duplas através de várias camadas (seu shell local →
ssh → shell remoto → possivelmente um menu no meio) é a fonte nº1 de bugs
sutis nesse tipo de automação. Em vez de escapar, codifique o comando
inteiro em base64 e decodifique do lado remoto — elimina toda a cadeia de
escaping:

  import base64
  b64 = base64.b64encode(remote_script.encode()).decode()
  remote_cmd = f"echo {b64} | base64 -d > /tmp/script.sh && sh /tmp/script.sh"

Funciona igual para heredocs de outra linguagem (ex.: gerar um script PHP
inteiro e rodar `php /tmp/script.php`) — grave o script decodificado num
arquivo temporário no host remoto, execute, e already-limpo se necessário.

---

PASSO 5 — Escrita de config nativa > edição manual de texto/XML

Se o appliance guarda config em XML/texto plano (pfSense: `/conf/config.xml`)
e expõe uma API/linguagem nativa pra editar esse config (pfSense: PHP com
`$config` global + `write_config()`), PREFIRA a API nativa a fazer
parse-edit-serialize você mesmo com regex ou parser XML genérico.

Por quê: o parser nativo do appliance conhece as invariantes estruturais do
próprio schema (ex.: tags que precisam fechar em ordem específica) que um
parser XML genérico não conhece — e pode "silenciosamente consertar" uma
inconsistência pré-existente de um jeito que quebra a leitura pelo software
nativo depois. Editar via API nativa evita reintroduzir esse tipo de
corrupção estrutural.

Sempre faça backup do arquivo de config ANTES de qualquer escrita
(`cp config.xml config.xml.bak.$(date ...)`), mesmo usando a API nativa.

---

VERIFICAÇÃO PÓS-ESCRITA

Depois de qualquer escrita num config crítico via este método:
  1. Valide a estrutura (`xmllint --noout arquivo.xml` ou equivalente pro
     formato) — exit code 0 confirma bem-formado
  2. Confira a contagem de entradas antes/depois (ex.: `grep -c '<tag>'`) —
     deve mudar exatamente pelo esperado, nem mais nem menos
  3. Confirme que o serviço afetado recarregou sem erro (status/journal)
  4. Teste funcional real (não só leitura de config) sempre que possível

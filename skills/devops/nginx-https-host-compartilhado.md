# HTTPS em nginx compartilhado (vários sites na mesma VPS)

Como ligar HTTPS num site que divide o nginx com outros serviços sem derrubar nem
"sequestrar" nenhum deles. Vale para qualquer VPS que hospeda mais de um domínio.

Origem: centroculturalsbr, 2026-11-05. O site do Centro Cultural rodava só em HTTP numa VPS
que também servia o Hermes em HTTPS. Quem abria `https://centroculturalsobral.org` recebia o
certificado e o login básico do Hermes ("Hermes TI"), porque não existia bloco 443 para o domínio.

---

## O sintoma

- `https://dominio-a` mostra aviso de certificado e/ou pede usuário e senha de outro serviço.
- `curl -I https://dominio-a` → `SSL: no alternative certificate subject name matches target hostname`.
- `openssl s_client -connect IP:443 -servername dominio-a | openssl x509 -noout -subject`
  mostra o CN de **outro** domínio.

Causa: o nginx entrega a conexão TLS ao bloco que escuta naquele `IP:443`. Sem bloco 443 para
o domínio A, quem responde é o bloco padrão daquele socket (o do serviço B).

## A armadilha do `listen 443` genérico

Se o serviço B escuta com **IP explícito** (`listen 203.0.113.10:443 ssl;`) e o bloco novo usa
`listen 443 ssl;` (o que o `certbot --nginx` costuma inserir), o nginx prefere o socket mais
específico: tráfego para `203.0.113.10:443` nunca chega ao bloco genérico, e o domínio A
continua caindo no B.

Regra: **o bloco 443 do site novo usa exatamente o mesmo `listen` dos vizinhos** (mesmo IP,
mesmo porto). Aí o SNI (`server_name`) escolhe entre os blocos do mesmo socket.

```bash
nginx -T 2>/dev/null | grep -nE "server_name|listen"   # ver como os vizinhos escutam antes
```

## Procedimento

1. **Ler antes de mexer**: `nginx -T`, `certbot certificates`, DNS do domínio e do `www`
   (`getent hosts`), quais sites estão em `sites-enabled`.
2. **Backup** da config atual do site (`cp -a ... /root/backups-nginx/<site>.<data>.bak`).
3. **Emitir o certificado em modo webroot**, para o certbot não editar o nginx:

   ```bash
   certbot certonly --webroot -w /var/www/<site> \
     -d dominio-a -d www.dominio-a --cert-name dominio-a \
     --non-interactive --agree-tos --deploy-hook "systemctl reload nginx"
   ```

   O desafio HTTP-01 é servido pelo bloco 80 que já existe (o arquivo é criado em
   `/var/www/<site>/.well-known/acme-challenge/`).
4. **Escrever o bloco 443 à mão**, com o IP explícito igual ao dos vizinhos:

   ```nginx
   server {
       listen 203.0.113.10:443 ssl;
       server_name dominio-a www.dominio-a;
       ssl_certificate     /etc/letsencrypt/live/dominio-a/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/dominio-a/privkey.pem;
       include /etc/letsencrypt/options-ssl-nginx.conf;
       ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
       # ... root, locations
   }
   ```

   No bloco 80, manter `location ^~ /.well-known/acme-challenge/ { try_files $uri =404; }`
   antes do `return 301 https://...`, senão a renovação quebra.
5. **Aplicar com reversão automática**:

   ```bash
   cp novo.conf /etc/nginx/sites-available/<site>.conf
   if nginx -t; then systemctl reload nginx; else cp backup.bak /etc/nginx/sites-available/<site>.conf; fi
   ```

6. **Verificar sem `-k`**, e verificar os vizinhos:

   ```bash
   curl -s -o /dev/null -w "%{http_code} %{ssl_verify_result}\n" https://dominio-a/   # 200 0
   curl -sI http://dominio-a/ | grep -i location                                       # 301 -> https
   curl -sI https://servico-b/                                                         # igual a antes
   certbot renew --dry-run --cert-name dominio-a                                       # renovação ok
   ```

## Cuidados

- Não usar `certbot --nginx` num host compartilhado sem revisar o diff que ele grava.
- `add_header` dentro de `location` aninhado anula os do bloco pai (CSP some sem aviso).
  Preferir locations irmãos, não aninhados.
- HSTS (`Strict-Transport-Security`) é difícil de desfazer; com `includeSubDomains` ele atinge
  todos os subdomínios do domínio, inclusive serviços de outros donos. Começar com `max-age`
  curto e sem `includeSubDomains`, ou deixar para depois.
- Nunca tentar descobrir credenciais do serviço vizinho (ler `.htpasswd` etc.) para "testar".
  O login dele não é problema a resolver, é o sintoma.
- Manter a config do site versionada no repo dele e checar divergência no deploy
  (`diff -q /etc/nginx/sites-available/<site>.conf - < deploy/<site>.conf`).

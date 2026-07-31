# Instagram e Ativos do Cliente

Colher, de perfis do Instagram e do rastro que eles apontam, o que já existe publicado —
em vez de inventar dado, comprar banco de imagem ou publicar placeholder esperando alguém
responder.

Dois usos, mesma mecânica:

1. **Ativos do cliente** — endereço, CNPJ, telefone, horário, fundação, marcas revendidas,
   fotografia de produto e de obra, para preencher um site/LP que está travado.
2. **Curadoria e aprendizado** — colher ideias, formatos, composições, referências e
   tendências de perfis de terceiros para abastecer repertório e decisões de projeto.

---

## Regra zero: o perfil é o índice, não a fonte

O dado bom raramente está no post. Está no que a bio **aponta**. O caminho real costuma ser:

```
bio  ->  link-in-bio (Linktree e similares)  ->  catalogo PDF / Drive / site  ->  o dado
```

Num caso real essa cadeia entregou, de uma vez: endereço completo com CEP, CNPJ, ano de
fundação, WhatsApp comercial diferente do pessoal, marcas revendidas e 6 fotos de produto.
O perfil sozinho teria dado só o endereço.

Sempre percorrer a cadeia inteira antes de concluir que "não tem".

---

## Permissão — resolver isto ANTES de coletar

| situacao | o que fazer |
|---|---|
| Perfil **publico** | coletar, fotos inclusive, sem perguntar. Publico e material disponivel, guardadas as proporcoes. |
| Perfil **privado** | coletar **com o "sim" explicito do dono do projeto**, que e quem tem o aceite do cliente. |
| Perfil e **do cliente** do projeto em curso | material do dono: coleta e publica no site dele. |
| Perfil e **de terceiro** | coleta livre para aprender, comparar e captar tendencia. O **arquivo** de imagem de terceiro nao entra em entrega comercial sem direito de uso. |

**Nunca publicar NO Instagram.** Não postar, comentar, responder nem alterar nada em perfil
nenhum, inclusive o do dono. O fluxo é de mão única.

**Não travar por excesso de cautela.** Recusar-se a abrir um perfil que o dono do projeto
mandou abrir não protege ninguém — só transfere o trabalho para ele e mata a fluidez. Se o
cliente disse "as fotos estão no meu Instagram", responder "me manda por outro canal" é
criar trabalho para quem já resolveu.

---

## Procedimento

### 1. Ler o perfil

Navegador real (Playwright/Chrome MCP). **`WebFetch` não serve**: converte para markdown e
descarta imagem, CSS e layout — inútil para julgar visual e frequentemente perde a bio.

```js
// bio, contato e metricas saem de meta + innerText
document.querySelector('meta[name="description"]').content
document.body.innerText.slice(0, 800)
```

Sessão autenticada alcança mais que anônima (inclusive privado, com permissão). Saber em
que conta se está logado — isso define o alcance e a responsabilidade.

### 2. Detectar para onde a bio aponta

Extrair referências estruturadas do texto da bio/caption:

```python
import re

# Ancora obrigatoria em toda regex de dominio.
# Sem o (?<![A-Za-z0-9-]), "icont.me/foo" casa como substring de "t.me/foo",
# e "mygithub.com/x/y" casa como "github.com/x/y".
# Bug real, achado contra bio de Instagram de verdade (icont.me e agregador
# de link-in-bio). Custa uma linha e evita fonte fantasma.
PADROES = [
    ("linktree",  r"(?<![A-Za-z0-9-])linktr\.ee/([A-Za-z0-9_.-]+)"),
    ("drive",     r"(?<![A-Za-z0-9-])drive\.google\.com/file/d/([A-Za-z0-9_-]+)"),
    ("whatsapp",  r"(?<![A-Za-z0-9-])wa\.me/(\d+)"),
    ("site",      r"https?://[^\s)>\]]+"),
]
```

Vale para qualquer destino: Drive, catálogo, WhatsApp, site, GitHub, CodePen.

### 3. Puxar a fonte

```bash
# PDF em Drive
curl -sL "https://drive.google.com/uc?export=download&id=<FILE_ID>" -o catalogo.pdf
```

### 4. Extrair imagem de PDF

```python
from pypdf import PdfReader
r = PdfReader("catalogo.pdf")
for pi, page in enumerate(r.pages, 1):
    for ii, im in enumerate(page.images):
        open(f"p{pi:02d}_{ii}.png", "wb").write(im.data)
```

Busca por assinatura JPEG (`\xff\xd8\xff` ... `\xff\xd9`) **não funciona** quando as imagens
são Flate — usar `pypdf`, que decodifica.

Se cada página vier como **uma imagem só** (catálogo exportado de editor gráfico), as fotos
estão dentro dela: recortar por caixa proporcional com PIL. **Desenhar as caixas num preview
e conferir antes** de gerar os recortes finais — corrigir enquadramento depois custa muito
mais caro.

---

## Regras invioláveis do dado

- **Dado factual sobre a empresa nunca é provisório.** CNPJ, endereço, telefone, horário,
  preço, depoimento: ou é real, ou a seção não renderiza. Valor plausível inventado publica
  informação falsa e manda cliente para a porta errada.
- **Nota interna não vira prosa visível.** `[a confirmar com o cliente]` no meio de um
  parágrafo já foi parar em produção. Ausência é silenciosa: campo nulo, seção some.
- **Conferir CNPJ pelos dígitos verificadores** antes de publicar — número lido de imagem
  erra fácil.
- **Cruzar em duas fontes** quando possível (bio + link-in-bio + catálogo).
- **Divergência não se resolve sozinha.** Dois telefones diferentes entre bio e código não é
  erro a corrigir por conta própria: pode ser pessoal vs. corporativo, e ambos válidos.
  Perguntar antes de trocar o destino de um CTA que já recebe lead.
- **Registrar procedência** de cada imagem num `CREDITOS.md` ao lado dos arquivos: de onde
  veio, qual página, que restrição carrega.
- Foto de banco é **ponte, não permanência** — sai quando houver foto própria. E nunca
  legendada como obra/equipe/fábrica do cliente.

---

## Quando NÃO fazer na mão

Esta skill é coleta **pontual, autenticada e com julgamento**: um perfil, dentro da sessão.

Para **volume ou recorrência** — dezenas de perfis, varredura periódica, persistência em
banco — delegar a um worker de ingestão em vez de navegar manualmente. Arquitetura de
referência: fila (Redis/BullMQ) para URLs de perfil, extração em sandbox sem login,
normalização em Postgres, imagem publicada em registry e deploy por `compose pull && up`.

Trade-off que decide qual usar: **sandbox sem login escala e não arrisca conta, mas não
alcança perfil privado. Sessão autenticada alcança, mas não escala.**

---

## Sinal de que valeu

```js
document.images.length   // rodar no site antes e depois
```

Site institucional com **1 imagem** (só o logo) é o sintoma clássico. Se a coleta não move
esse número, ela não aconteceu. No caso de referência: de 1 para 10.

# Instagram e Ativos do Cliente

Antes de inventar dado, comprar banco de imagem ou publicar placeholder, **procure o que
o cliente já publicou.** Quase todo negócio pequeno já tem endereço, CNPJ, telefone, ano
de fundação, marcas revendidas e fotografia de produto espalhados em Instagram, Linktree,
catálogo PDF, Google Meu Negócio e nota fiscal. É material do dono, é gratuito, é real,
e é melhor que qualquer substituto.

Quando usar: site institucional, landing page, catálogo, e-commerce — qualquer entrega
que dependa de conteúdo real de um cliente e esteja travada esperando ele responder.

---

## Por que isso importa

O modo de falha típico não é falta de design. É **site pronto e vazio**: seções com
"em breve", "[a confirmar com o cliente]", "consulte no WhatsApp" repetido dezenas de
vezes, zero fotografia. Isso lê como template não preenchido e destrói credibilidade —
um site feio e cheio de telefone, endereço e foto converte mais que um site limpo e oco.

Esperar o cliente responder pode levar semanas. Boa parte do que falta **já está público**.

---

## Onde procurar, em ordem de retorno

1. **Instagram do negócio** — a bio costuma ter endereço completo e telefone. Os posts
   são acervo de obra entregue e produto real.
2. **Linktree / link na bio** — quase sempre esconde mais que o Instagram: catálogo em
   PDF, WhatsApp comercial (frequentemente diferente do pessoal), formulário de avaliação
   (fonte de depoimento real), domínio pretendido.
3. **Catálogo em PDF** — o achado de maior densidade. Costuma trazer, de uma vez: CNPJ,
   ano de fundação, texto institucional pronto, fotografia de produto com marca d'água
   do próprio cliente, linha de produto inteira que ninguém tinha mencionado.
4. **Google Meu Negócio** — horário de funcionamento, avaliações, fotos, localização
   geocodificada de verdade.
5. **Nota fiscal / contrato / proposta** já em mãos — razão social e CNPJ conferidos.

---

## Procedimento

```bash
# 1. Perfil e link na bio (navegador real, não WebFetch)
#    WebFetch converte pra markdown e descarta imagem/CSS — inútil aqui.

# 2. Catálogo PDF: baixar do Drive
curl -sL "https://drive.google.com/uc?export=download&id=<FILE_ID>" -o catalogo.pdf

# 3. Extrair as imagens embutidas
python - <<'PY'
from pypdf import PdfReader
r = PdfReader("catalogo.pdf")
for pi, page in enumerate(r.pages, 1):
    for ii, im in enumerate(page.images):
        open(f"p{pi:02d}_{ii}.png","wb").write(im.data)
PY
```

Se cada página vier como **uma imagem só** (catálogo exportado de editor gráfico), as
fotos de produto estão dentro dela: recortar por caixa proporcional com PIL, conferindo
o enquadramento num preview com retângulo desenhado antes de gerar os recortes finais.

Extração direta por assinatura JPEG (`\xff\xd8\xff` … `\xff\xd9`) **não funciona** quando
as imagens são Flate — use `pypdf`, que decodifica.

---

## Regras invioláveis

- **Dado factual sobre a empresa nunca é preenchido "provisoriamente".** CNPJ, endereço,
  telefone, horário, preço, depoimento: ou é real, ou a seção não renderiza. Valor
  plausível inventado publica informação falsa e manda cliente pra porta errada.
- **Nota interna não vira prosa visível.** `[a confirmar com o cliente]` no meio de um
  parágrafo já foi parar em produção. A ausência é silenciosa: campo `null` e a seção
  some.
- **Conferir CNPJ pelos dígitos verificadores** antes de publicar — número lido de
  imagem erra fácil e custa caro.
- **Cruzar cada dado em duas fontes** quando possível (bio + Linktree + catálogo).
- **Material do cliente é livre; material de terceiro, não.** Foto do catálogo do próprio
  cliente entra sem ressalva. Foto do site de um concorrente, não — mesmo que o produto
  seja padronizado, o arquivo é obra de outro, e frequentemente mostra embalagem de marca
  concorrente, o que faz o cliente anunciar o rival.
- **Registrar procedência** de cada imagem num `CREDITOS.md` junto dos arquivos: de onde
  veio, que página, que restrição tem.
- Foto de banco é **ponte, não permanência** — sai quando houver foto própria. E nunca
  legendada como obra/equipe/fábrica do cliente, o que seria alegação falsa.

---

## Sinal de que valeu

Métrica objetiva e fácil de medir antes/depois:

```js
document.images.length   // rodar no site antes e depois
```

Um site institucional com **1 imagem** (o logo) é o sintoma. Se a coleta não move esse
número, ela não aconteceu.

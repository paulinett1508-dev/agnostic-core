---
title: Contraste em Superfície Translúcida
description: Medir contraste WCAG de texto sobre painel translúcido (backdrop-filter, rgba, overlay sobre imagem) por elemento, no pior pixel, com método gravado junto do valor
category: frontend
tags: [acessibilidade, wcag, contraste, backdrop-filter, glassmorphism, overlay, imagem de fundo]
---

# Contraste em Superfície Translúcida

Quando o texto está sobre uma superfície translúcida (`backdrop-filter`, fundo `rgba`,
overlay sobre imagem), o contraste **não é um número fixo do CSS**. É função de qual
pedaço da imagem está atrás daquele elemento, naquele viewport.

Consequência prática: **mover o elemento equivale a trocar a cor de fundo dele**.
Centralizar um card, mudar padding, trocar `background-position` ou o breakpoint exige
remedir — com o mesmo rigor de trocar um token de cor.

---

## Quando usar

- Card de login, hero ou modal sobre foto/ilustração de fundo
- Painel com `backdrop-filter: blur()` ("vidro fosco")
- Overlay `rgba` sobre imagem ou vídeo
- Qualquer revisão em que o elemento translúcido mudou de **posição ou tamanho**, mesmo sem
  mudar cor

Para texto sobre cor sólida, a razão WCAG comum basta (`skills/frontend/accessibility.md`).

---

## Método

1. **Por elemento, não por área.** Para cada elemento de texto, pegar
   `el.getBoundingClientRect()`. Média da área inteira esconde o canto ruim.
2. **Mapear o retângulo para coordenadas da imagem**, replicando o que o CSS faz:
   `background-size: cover` (escala = `max(caixaW / imgW, caixaH / imgH)`) +
   `background-position` (deslocamento = `(caixa - imagemEscalada) * fração`; `center` = 0.5).
   Com `background-attachment: fixed`, a caixa de referência é o viewport.
3. **Amostrar o pior pixel** sob o retângulo, não a média. Para texto escuro sobre painel
   claro, é o pixel mais escuro da imagem; para texto claro, o mais claro. O jeito que não
   erra a direção: compor cada pixel e ficar com a **menor razão**. É um limite inferior
   conservador — o blur só puxa cada ponto para a média local, ou seja, só melhora o
   número. Se o blur for grande, expanda o retângulo pelo raio do blur antes de amostrar
   (pixels vizinhos entram na mistura).
4. **Compor e comparar.** Cor efetiva do fundo = `alpha * painel + (1 - alpha) * pixel`,
   por canal. Comparar contra a cor **computada** do texto
   (`getComputedStyle(el).color`), não o valor escrito no CSS — token pode estar
   sobrescrito por tema, cascata ou estilo inline.
5. **Gravar o método junto do valor.** No comentário do código ou no PR:
   `4.8:1 — pior pixel sob o rect do <label>, painel rgba(255,255,255,.72), viewport 1366x768`.
   Um número solto envelhece sem avisar: depois de mover o card ninguém sabe se ele
   ainda vale.

---

## Cálculo (luminância relativa WCAG + composição alpha)

```js
// Canal sRGB 0-255 -> linear (WCAG 2.x; 0.04045 é o limiar do sRGB, a spec cita 0.03928)
const lin = (c) => { c /= 255; return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4; };
const lum = ([r, g, b]) => 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
const ratio = (a, b) => {
  const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};
// Painel [r,g,b] com opacidade alpha sobre um pixel [r,g,b] da imagem
const compose = (panel, alpha, px) => panel.map((c, i) => alpha * c + (1 - alpha) * px[i]);

// Pior caso sob o retângulo: pixels = array de [r,g,b] amostrados via canvas.getImageData
const worst = (text, panel, alpha, pixels) =>
  Math.min(...pixels.map((px) => ratio(text, compose(panel, alpha, px))));

// ex.: texto #1a1a1a sobre painel branco a 72% em cima de dois pixels da foto
worst([26, 26, 26], [255, 255, 255], 0.72, [[40, 60, 90], [200, 210, 220]]); // ~10.39 (o pixel escuro manda)
```

Observações:

- Para ler pixels, desenhe a imagem num `<canvas>` e use `getImageData`. Imagem de outra
  origem sem CORS "suja" o canvas e a leitura falha — sirva a imagem da mesma origem ou
  com `crossorigin` no ambiente de medição.
- Se a cor do texto também tem alpha, componha o texto sobre o fundo efetivo antes de
  calcular a razão.
- Limiares: 4.5:1 texto normal, 3:1 texto grande e componentes de UI (WCAG 2.1 AA).

---

## Viewport é parte da medição

Com `background-size: cover`, o recorte da imagem muda com o tamanho da janela — o mesmo
elemento cai sobre outro pedaço da foto em 1366px e em 390px.

Ferramentas de avaliação de JS em navegador automatizado (ex.: `browser_evaluate` de MCPs
de browser) **não controlam o viewport**: rodam no tamanho que a sessão tiver. Por isso o
script de medição deve **sempre retornar `window.innerWidth` e `window.innerHeight` lidos
junto do resultado**. Ajuste o tamanho com a ferramenta própria de resize, remeça e
confirme pelo valor devolvido — nunca pelo que se supõe ter configurado.

---

## Anti-padrões

| Anti-padrão | Por que falha | Correção |
|---|---|---|
| Medir a cor do painel contra o texto ignorando a imagem | O fundo efetivo é a composição, não o painel | Compor `alpha * painel + (1 - alpha) * pixel` |
| Média de cor da área do card | Esconde o trecho escuro/claro sob uma palavra | Pior pixel por elemento |
| Medir com o blur aplicado (screenshot) e chamar de pior caso | Depende do raio e do renderizador | Pixel bruto da imagem é o limite conservador |
| Usar a cor declarada no CSS | Tema/cascata pode ter sobrescrito | `getComputedStyle(el).color` |
| Reaproveitar o número depois de mover o elemento | Mudou o pedaço da imagem atrás | Remedir a cada reposicionamento |
| Valor de contraste sem método | Ninguém sabe se ainda vale | Registrar elemento, painel, alpha e viewport |

---

## Referência Cruzada

- `skills/frontend/accessibility.md` — limiares WCAG 2.1 AA e checklist geral
- `skills/frontend/dark-mode-tokens.md` — tokens de cor; contraste em ambos os temas
- `skills/design/contraste-nao-mede-pulso.md` — quando a razão WCAG é a métrica errada

# Pincel Generativo: Desenho de Mídia Natural em Canvas (p5.brush)

Gerar ilustração e animação com aparência de mídia física (lápis, carvão, marcador,
aquarela, hachura) por código, em vez de vetor limpo ou raster de IA. Aplique quando o
projeto pedir traço "desenhado à mão" e o resultado precisar ser **código reproduzível**
(seed fixa, versionável, uso comercial livre).

Biblioteca de referência: [`acamposuribe/p5.brush`](https://github.com/acamposuribe/p5.brush)
(MIT). Fonte da descoberta: reel público do Instagram, extraído conforme
`skills/audit/instagram-e-ativos-do-cliente.md` (uso 2: curadoria).

> Regra de ouro: a lib só entrega **ferramenta**. Decisão de composição, paleta e ponto
> focal continua sendo sua — ver `skills/design/sem-cara-de-ia.md`.

---

## Quando usar / quando não usar

| Situação | Decisão |
|---|---|
| Ilustração, hero, ícone ou animação com cara de traço manual | Usar |
| Precisa de resultado idêntico entre execuções (arte reproduzível) | Usar — `seed` fixa |
| Gráfico de dados, UI funcional, texto longo | Não usar — traço ruidoso atrapalha leitura |
| Alvo sem WebGL (e-mail, SSR puro, dispositivos muito antigos) | Não usar — exige canvas WebGL |
| Foto/ilustração fotorrealista | Não usar — ver `skills/design/nano-banana-claude-workflow.md` |

---

## Regra zero: identificar a build antes de gerar código

A lib tem **duas builds incompatíveis**. Misturar APIs quebra em silêncio.

| Aspecto | Build p5 (`p5.brush.js`) | Build standalone (`brush.js` / `brush.esm.js`) |
|---|---|---|
| Canvas | `createCanvas(w, h, WEBGL)` | `brush.createCanvas(w, h)` |
| Transformações | `push/pop/translate/rotate/scale` do p5 | `brush.push/pop/translate/rotate/scale` |
| Ângulo | `angleMode(DEGREES)` | `brush.angleMode(brush.DEGREES)` |
| Seed | `randomSeed(n)` / `noiseSeed(n)` | `brush.seed(n)` / `brush.noiseSeed(n)` |
| Fim do frame | automático | **`brush.render()` obrigatório** |
| Limpar | `background()` | `brush.clear(cor?)` |

Pergunte ou inspecione o projeto (existe `p5` no `package.json`?) antes de escrever.
Sem `brush.render()` na standalone, **nada aparece na tela**.

---

## Os 11 pincéis nativos

Lista no `README.md` do repo (seção Brush Management); `brush.box()` devolve a mesma em
runtime, incluindo pincéis customizados.

| Nome | Papel |
|---|---|
| `2B`, `HB`, `2H` | Lápis: macio/escuro → médio → duro/claro |
| `cpencil` | Lápis de cor |
| `pen`, `rotring` | Canetas: traço fino e técnico |
| `spray` | Pontos espalhados |
| `marker`, `marker2` | Marcadores chapados |
| `charcoal` | Carvão |
| `hatch_brush` | Hachura limpa |

A coluna "Papel" é inferida pelos nomes; só `spray`, `marker` e `hatch_brush` são descritos
no README. Confirme visualmente antes de prometer um efeito ao cliente.

---

## Receita mínima

Build p5:

```js
function setup() {
  createCanvas(600, 600, WEBGL)
  angleMode(DEGREES)
  brush.scaleBrushes(3)          // ~3 para 600x600; ajustar olhando
  randomSeed(42)                 // mesma seed = mesmo desenho
}

function draw() {
  translate(-width / 2, -height / 2)   // origem WEBGL é o centro
  brush.set("charcoal", "#222", 1)     // pincel, cor, multiplicador de peso
  brush.line(50, 50, 550, 550)
  brush.fill("#2a6f97", 120)           // aquarela; opacidade 0–255, não 0–100
  brush.circle(300, 300, 90, 0.4)      // 0.4 = irregularidade de mão
}
```

Build standalone — mesmo desenho, trocando o ciclo de vida:

```js
import * as brush from './dist/brush.esm.js'
brush.createCanvas(600, 600)
brush.scaleBrushes(3)
brush.seed(42)
brush.clear('#f5f0e0')
brush.push(); brush.translate(-300, -300)
brush.set("charcoal", "#222", 1)
brush.line(50, 50, 550, 550)
brush.pop()
brush.render()                   // obrigatório
```

---

## Mapa da API (compartilhada)

| Grupo | Funções | Observação |
|---|---|---|
| Traço | `set`, `pick`, `stroke`, `strokeWeight`, `noStroke` | `pick` troca só o pincel, preserva cor/peso |
| Aquarela | `fill`, `fillBleed`, `fillTexture`, `noFill` | Fills do mesmo frame sangram entre si; secam a cada `render`/fim do `draw` |
| Chapado rápido | `wash`, `noWash` | Sem simulação de aquarela — barato |
| Hachura | `hatch`, `hatchStyle`, `noHatch`, `mass` | `mass` funciona melhor com giz/pastel |
| Campos vetoriais | `field`, `noField`, `wiggle`, `flowLine`, `addField` | Embutidos: `hand`, `curved`, `zigzag`, `waves`, `seabed`, `spiral`, `columns` |
| Primitivas | `line`, `flowLine`, `spline`, `rect`, `circle`, `arc`, `polygon`, `beginShape/vertex/endShape` | `arc` só traço; `rect` usa `"corner"`/`"center"` como string |
| Pincel próprio | `add(nome, params)` | Tipos: `default`, `spray`, `marker`, `custom`, `image` |
| Recorte | `clip`, `noClip` | |

Pincel customizado (funciona nas duas builds):

```js
brush.add("diamante", {
  type: "custom",
  weight: 5, scatter: 0.08, opacity: 23, spacing: 0.6,
  pressure: [0.5, 1.5, 0.5],           // começa fino, engorda, afina
  tip: (_m) => { _m.rotate(Math.PI / 4); _m.rect(-1.5, -1.5, 3, 3) },
  rotate: "natural",
  markerTip: false
})
```

Tipo `image` retorna Promise: `async setup()` + `await brush.add(...)`.
Editor visual de pincel: Brush Maker, linkado no README do repo.

---

## Animação

- Fills e traços são sorteados — **re-semeie a cada frame** (`randomSeed(n)`) para o
  desenho não "tremer" por acaso; varie a seed de propósito para o efeito de quadro a
  quadro de animação desenhada.
- `brush.refreshField(t)` no loop anima campos vetoriais.
- Custo: cada fill compõe separadamente (~1 ms por fill pequeno em GPU rápida); fill de
  canvas inteiro com `pixelDensity(2)` é o caso caro. Meça antes de animar em celular.

---

## Armadilhas

- Origem do canvas WEBGL é o **centro** → `translate(-largura/2, -altura/2)`.
- Opacidade de fill é **0–255**.
- Ângulos de `flowLine`/`hatch` seguem o `angleMode` atual.
- Texto e overlays: desenhar **depois** de toda geometria do pincel, senão ficam por baixo.
- Preferir primitivas principais; `Polygon.draw()`/`Plot.draw()` só para `hatchArray`/
  `massArray` ou reuso de geometria.
- `scaleBrushes` antes de `add` se quiser escalar só os embutidos.
- Na standalone, em `tip` custom, `rotate()` é sempre radianos e cores são número/CSS.

---

## Checklist antes de entregar

- [ ] Build identificada e API coerente com ela
- [ ] `seed` fixa registrada (reprodutibilidade)
- [ ] `scaleBrushes` calibrado visualmente no tamanho final
- [ ] Desempenho medido no dispositivo-alvo, se houver animação
- [ ] Licença MIT preservada nos créditos do projeto (`CREDITOS.md`)
- [ ] Preview com 3 opções (light e dark) apresentado antes de implementar — Regra #0

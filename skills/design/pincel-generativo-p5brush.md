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

### Semântica dos parâmetros que mais geram dúvida

| Chamada | Significado |
|---|---|
| `hatch(dist, angle, {rand, continuous, gradient})` | `dist` = espaçamento entre linhas (unidades do canvas); `angle` segue o `angleMode`; `rand` 0–1 irregularidade; `gradient` 0–1 |
| `hatchStyle(nome, cor, peso)` | Pincel **da hachura**. Não é redundante com `set`, que define o pincel do **contorno** |
| `fillTexture(granulacao, borda, scatter?, split?)` | Granulação 0–1, anel de pigmento na borda 0–1; `scatter` e `split` opcionais |
| `circle(x, y, raio, irregularidade)` | Irregularidade 0–1 = "mão tremida" do contorno |
| `beginShape(curvatura)` | Curvatura 0–1 suaviza os cantos (observado: 0,3 arredonda um polígono) |

`hatch` vale para as formas com traço, preenchimento e hachura: `rect`, `circle`, `polygon`
e `beginShape/endShape` (verificado com `beginShape`). `arc` é só traço.

**Ordem de chamada não é ordem de camada.** Traço e hachura saem na hora; o preenchimento
de aquarela é composto e "seca" no fim do frame. Verificado: uma hachura chamada **antes**
de um círculo de aquarela continuou visível por cima dele. Para a hachura realmente ficar
atrás, não dependa da ordem — separe a cena em alvos com `brush.load()` ou aceite a
sobreposição como efeito.

**Reprodutibilidade em animação:** `millis()` não é determinístico entre execuções. Para
repetir a animação quadro a quadro, derive o tempo e a seed do `frameCount` (ex.:
`randomSeed(SEED + frameCount)`), não do relógio. Os exemplos abaixo usam `millis()` por
fluidez; troque se precisar de saída idêntica.

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

### Exemplo completo: paisagem animada (build standalone)

Testado em Chromium headless (WebGL por software): sem erros, ~22 quadros em 5,5 s.
Precisa de `brush.js` (`dist/brush.js` do repo da lib) na mesma pasta do HTML.

```html
<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><title>p5.brush animado</title></head>
<body style="margin:0;background:#e9e2d0;display:grid;place-items:center;min-height:100vh">
<script src="brush.js"></script>
<script>
const W = 600, H = 600, STEP_MS = 160;   // ~6 quadros/s: ritmo de animação desenhada
brush.createCanvas(W, H);
brush.scaleBrushes(3);
brush.angleMode(brush.DEGREES);

function cena(t, quadro) {
  brush.seed(1000 + quadro);             // seed nova por quadro = traço "ferve"
  brush.noiseSeed(1000 + quadro);
  brush.clear('#f5f0e0');
  brush.push();
  brush.translate(-W / 2, -H / 2);       // origem no topo-esquerdo

  // sol: aquarela + contorno de lápis, pulsando
  brush.fill('#e9a23b', 140); brush.fillBleed(0.4); brush.fillTexture(0.6, 0.5);
  brush.set('2B', '#5a3a12', 1);
  brush.circle(430, 150, 70 + 4 * Math.sin(t / 700), 0.3);
  brush.noFill();

  // nuvem de hachura derivando
  const nx = 40 + ((t / 60) % (W + 260)) - 260;
  brush.hatch(12, 60, { rand: 0.15 });
  brush.hatchStyle('cpencil', '#3a6ea5', 1);
  brush.set('cpencil', '#3a6ea5', 1);
  brush.rect(nx, 70, 200, 70);
  brush.noHatch();

  // colina: seed FIXA, senão o sangramento da aquarela pisca entre quadros
  brush.seed(7); brush.noiseSeed(7);
  brush.fill('#4f8a5b', 120); brush.fillBleed(0.5); brush.fillTexture(0.5, 0.6);
  brush.set('HB', '#1f3d27', 1);
  brush.beginShape(0.8);
  [[0,420],[150,340],[320,390],[470,320],[600,380],[600,600],[0,600]]
    .forEach(p => brush.vertex(p[0], p[1]));
  brush.endShape(brush.CLOSE);
  brush.noFill();
  brush.seed(1000 + quadro); brush.noiseSeed(1000 + quadro);   // volta à seed do quadro

  // árvore balançando: tronco em carvão, copa em aquarela + marcador grosso
  const sway = 6 * Math.sin(t / 900);
  brush.set('charcoal', '#2b2118', 1.4);
  brush.line(180, 470, 185 + sway * 0.4, 360);
  brush.fill('#2f6b3a', 150); brush.fillBleed(0.3); brush.fillTexture(0.5, 0.6);
  brush.set('marker', '#1f4d29', 2.5);
  brush.circle(183 + sway, 335, 42, 0.5);
  brush.noFill();

  // grama ondulando com campo vetorial
  brush.field('waves');
  brush.refreshField(t / 1000);
  brush.set('pen', '#1b2e20', 1);
  for (let i = 0; i < 30; i++) brush.flowLine(30 + i * 19, 560, 40, -90);
  brush.noField();

  brush.pop();
  brush.render();                        // obrigatório na standalone
}

let ultimo = -STEP_MS, quadro = 0;
function loop(t) {
  if (t - ultimo >= STEP_MS) { ultimo = t; cena(t, quadro++); }
  requestAnimationFrame(loop);
}
requestAnimationFrame(loop);
</script></body></html>
```

Lições do exemplo:

- `marker` sozinho com peso 1 some; com `fill` + peso ~2,5 a copa aparece.
- Seed por quadro anima o traço; **seed fixa nos elementos que devem ficar estáveis**
  (aqui, a colina) e restaurada logo depois.
- Para animação contínua (não "desenhada"), mantenha a seed constante e anime só
  parâmetros (`refreshField`, posição, raio).

### Mesmo exemplo na build p5

Testado em Chromium headless: sem erros nem avisos, 17 quadros em ~6 s. Precisa de
`p5.min.js` **2.x** (a lib exige `p5 ^2.2`; 1.x não serve) e `p5.brush.js` na mesma pasta.

```html
<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><title>p5.brush (build p5)</title>
<script src="p5.min.js"></script>
<script src="p5.brush.js"></script>
</head><body style="margin:0;background:#e9e2d0;display:grid;place-items:center;min-height:100vh">
<script>
const W = 600, H = 600;
let quadro = 0;

function setup() {
  createCanvas(W, H, WEBGL);             // canvas WEBGL criado pelo p5
  angleMode(DEGREES);
  brush.scaleBrushes(3);
  frameRate(6);                          // ~6 quadros/s
}

function draw() {
  const t = millis();
  quadro++;
  randomSeed(1000 + quadro);             // seed por quadro = traço "ferve"
  noiseSeed(1000 + quadro);
  background('#f5f0e0');
  push();
  translate(-W / 2, -H / 2);             // origem no topo-esquerdo

  // sol: aquarela + contorno de lápis, pulsando
  brush.fill('#e9a23b', 140); brush.fillBleed(0.4); brush.fillTexture(0.6, 0.5);
  brush.set('2B', '#5a3a12', 1);
  brush.circle(430, 150, 70 + 4 * Math.sin(t / 700), 0.3);
  brush.noFill();

  // nuvem de hachura derivando
  const nx = 40 + ((t / 60) % (W + 260)) - 260;
  brush.hatch(12, 60, { rand: 0.15 });
  brush.hatchStyle('cpencil', '#3a6ea5', 1);
  brush.set('cpencil', '#3a6ea5', 1);
  brush.rect(nx, 70, 200, 70);
  brush.noHatch();

  // colina: seed FIXA, restaurada logo depois
  randomSeed(7); noiseSeed(7);
  brush.fill('#4f8a5b', 120); brush.fillBleed(0.5); brush.fillTexture(0.5, 0.6);
  brush.set('HB', '#1f3d27', 1);
  brush.beginShape(0.8);
  [[0,420],[150,340],[320,390],[470,320],[600,380],[600,600],[0,600]]
    .forEach(p => brush.vertex(p[0], p[1]));
  brush.endShape(CLOSE);
  brush.noFill();
  randomSeed(1000 + quadro); noiseSeed(1000 + quadro);

  // árvore balançando
  const sway = 6 * Math.sin(t / 900);
  brush.set('charcoal', '#2b2118', 1.4);
  brush.line(180, 470, 185 + sway * 0.4, 360);
  brush.fill('#2f6b3a', 150); brush.fillBleed(0.3); brush.fillTexture(0.5, 0.6);
  brush.set('marker', '#1f4d29', 2.5);
  brush.circle(183 + sway, 335, 42, 0.5);
  brush.noFill();

  // grama ondulando com campo vetorial
  brush.field('waves');
  brush.refreshField(t / 1000);
  brush.set('pen', '#1b2e20', 1);
  for (let i = 0; i < 30; i++) brush.flowLine(30 + i * 19, 560, 40, -90);
  brush.noField();

  pop();
  // sem brush.render(): o p5 faz o flush ao fim do draw()
}
</script></body></html>
```

Diferenças em relação à standalone: ciclo `setup()`/`draw()`, `millis()` no lugar do
tempo do `requestAnimationFrame`, `randomSeed`/`background`/`push`/`translate`/`CLOSE`
do p5 e nenhum `brush.render()`.

### Integração com framework de UI (exemplo em React)

Regra genérica, vale para qualquer framework: **o canvas pertence ao framework; a lib só
desenha nele**. Use a build standalone com `brush.load(canvas)`, rode o loop num efeito de
ciclo de vida e **cancele o loop no cleanup** (senão o desenvolvimento em modo estrito, que
monta duas vezes, gera dois loops). Mantenha a cena em função pura `(brush, t, quadro)`,
sem nada do framework — a mesma do exemplo standalone acima.

Testado com React 18 + Vite + `p5.brush` 3.0 (build de produção, Chromium headless: sem
erros nem avisos; pausa e retomada verificadas por comparação de pixels). `npm i p5.brush`
e importe `p5.brush/standalone`.

```jsx
import { useEffect, useRef } from 'react'
import * as brush from 'p5.brush/standalone'
import { W, H, desenharCena } from './cena.js'   // corpo da cena() do exemplo standalone

const STEP_MS = 160

export default function PaisagemBrush({ rodando = true, onErro }) {
  const canvasRef = useRef(null)
  const rodandoRef = useRef(rodando)     // o loop lê o ref: pausar não recria o canvas
  rodandoRef.current = rodando

  useEffect(() => {
    const canvas = canvasRef.current
    try {
      brush.load(canvas)                 // canvas é do React
      brush.scaleBrushes(3)
      brush.angleMode(brush.DEGREES)
    } catch (e) {
      onErro?.(e)                        // sem WebGL2 a lib lança
      return
    }

    let raf = 0, quadro = 0, ultimo = -STEP_MS, tAnim = 0, anterior = performance.now()
    const loop = (agora) => {
      const dt = agora - anterior
      anterior = agora
      if (rodandoRef.current) tAnim += dt          // tempo da animação congela em pausa
      if (rodandoRef.current && agora - ultimo >= STEP_MS) {
        ultimo = agora
        desenharCena(brush, tAnim, quadro++)       // termina com brush.render()
      }
      raf = requestAnimationFrame(loop)
    }
    raf = requestAnimationFrame(loop)
    return () => cancelAnimationFrame(raf)         // obrigatório
  }, [onErro])

  return <canvas ref={canvasRef} width={W} height={H} role="img"
                 aria-label="Paisagem animada desenhada com lápis, carvão e aquarela" />
}
```

Pontos de atenção:

- `onErro` deve ter identidade estável (`useCallback` no pai), senão o efeito reinicia a
  cada render.
- A lib é um singleton: dois componentes com `brush.load()` disputam o mesmo alvo. Para
  vários canvases, chame `brush.load(canvasX)` antes de desenhar em cada um.
- Sem WebGL2 a lib lança — ofereça um fallback em vez de deixar o canvas em branco.
- Dê `role="img"` e `aria-label` ao canvas; o desenho não é lido por leitor de tela.

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

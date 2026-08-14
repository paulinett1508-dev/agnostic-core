# Razão de Contraste Não Mede Pulso

A razão WCAG responde "este texto é legível sobre este fundo?". Ela **não** responde
"esta mudança de cor é percebida como um evento?". Usar a métrica errada leva a
piscar dois tons que o número diz serem distintos e o olho não separa.

Para percepção de mudança entre dois tons próximos, a métrica é **ΔL\*** — diferença
de lightness em CIELAB.

---

## Por que a razão WCAG falha nesse uso

A fórmula tem um termo de flare (`+0.05`) somado às duas luminâncias. Ele existe para
modelar reflexo ambiente na tela e é adequado ao propósito original. O efeito
colateral: **comprime a faixa escura**. Dois tons escuros obviamente diferentes
resultam em razão perto de 1, porque o `+0.05` domina os dois lados da fração.

Quanto mais escuro o par, mais a razão mente sobre a distância percebida.

---

## Caso medido

Painel de chamada de recepção, lido a 3-5 metros. O herói pisca quando um nome é
chamado. Ao migrar de um azul royal para um petróleo bem mais escuro:

| par fundo → flash | razão WCAG | ΔL\* |
|---|---|---|
| azul royal `#0B4FB3` → `#083A8C` (o antigo) | 1,40:1 | 9,17 |
| petróleo `#1a2f3f` → `#0f1f2b` (escurecendo) | 1,22:1 | 7,45 |
| petróleo `#1a2f3f` → `#2a4a5f` | 1,47:1 | 11,54 |
| petróleo `#1a2f3f` → `#3a6a7f` (escolhido) | **2,33:1** | **23,95** |

Pelas razões WCAG, as quatro opções parecem igualmente ruins — todas abaixo de 3:1.
Por ΔL\*, a última é quase **três vezes** mais perceptível que o piscar original.

**A decisão que sai disso:** sobre fundo escuro, o flash tem que **clarear**. O
petróleo profundo está em L\* 18,4 e não tem lightness sobrando abaixo dele —
escurecer some. É contraintuitivo, porque "destacar" costuma ser sinônimo de
"intensificar", e aqui intensificar é ir na direção oposta.

---

## Quando usar cada uma

| pergunta | métrica |
|---|---|
| Este texto é legível sobre este fundo? | razão WCAG (4.5:1 texto, 3:1 gráfico) |
| Esta mudança de estado é percebida? | ΔL\* |
| Estas duas séries de dados se distinguem? | ΔL\* + matiz, nunca matiz sozinho |

E as duas continuam valendo juntas: no caso acima, o flash precisa ser percebido
(ΔL\*) **e** manter o nome legível durante o pico (razão WCAG — branco sobre
`#3a6a7f` dá 5,92:1).

---

## Medir contra o pixel, não contra a cor nominal

Calcular contra o hex declarado no CSS erra quando o texto está sobre gradiente,
imagem, sobreposição translúcida ou animação. Amostre o pixel renderizado.

Num caso real, um rótulo estimado em ~2,3:1 contra a cor nominal media **1,95:1**
contra o gradiente real — e havia ainda uma partícula animada que, no pico do
brilho, derrubava o valor mais um pouco. Nada disso aparece calculando no papel.

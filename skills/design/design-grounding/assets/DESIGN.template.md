# Design System — <nome do projeto>

> Extraído do código em <data>. Documenta o estado real, não o ideal.
> Atualize quando uma decisão visual for tomada, não depois.

## Base

Sistema de referência: <ex.: shadcn/ui (Tailwind v4, Radix primitives)>
Tudo que não estiver listado como desvio abaixo segue a base.

### Desvios deliberados

| Área | Base | Neste projeto | Motivo |
|---|---|---|---|
| | | | |

### Deriva a resolver

| Área | Estado atual | Alvo | Prioridade |
|---|---|---|---|
| | | | |

---

## Cor

### Em uso

| Valor | Ocorrências | Papel | Status |
|---|---|---|---|
| `#0F766E` | 31 | primária / CTA, links | ✅ padrão |
| `#6B7280` | 23 | texto secundário | ✅ padrão |
| `#6C7280` | 1 | texto secundário | ⚠ deriva de `#6B7280` |

Status: ✅ padrão · ⚠ deriva · ❓ indefinido

### Semântica

| Token | Valor | Uso |
|---|---|---|
| success | | |
| warning | | |
| danger | | |
| info | | |

### Contraste

| Par | Razão | WCAG AA |
|---|---|---|
| texto primário / fundo | | |
| texto secundário / fundo | | |
| texto de botão / fundo de botão | | |

---

## Tipografia

| Família | Papel | Pesos em uso |
|---|---|---|
| | | |

### Escala

| Token | Tamanho | Line-height | Uso | Ocorrências |
|---|---|---|---|---|
| | | | | |

⚠ Tamanhos fora da escala: <listar com ocorrências>

---

## Espaçamento

Escala em uso: <ex.: 4 8 12 16 24 32 48 64>

⚠ Valores fora da escala: <listar com arquivo:linha>

---

## Forma

| Propriedade | Valores em uso | Status |
|---|---|---|
| border-radius | | |
| largura de borda | | |
| sombra | | |

---

## Movimento

| Duração | Easing | Uso | Ocorrências |
|---|---|---|---|
| | | | |

Respeita `prefers-reduced-motion`: sim / não / parcial

---

## Componentes

### <Componente>

Arquivo: `<caminho>`
Variantes hoje: <n>

| Variante | Uso | Observação |
|---|---|---|
| | | |

Estados cobertos: default · hover · focus · active · disabled · loading · error
Estados ausentes: <listar>

---

## Layout

| Breakpoint | Valor | Ocorrências |
|---|---|---|
| | | |

Largura máxima de conteúdo:
Grid / colunas:

### Camadas (z-index)

| Valor | Uso |
|---|---|
| | |

---

## Acessibilidade

| Item | Estado |
|---|---|
| Foco de teclado visível | |
| Contraste AA no texto corpo | |
| Alvos de toque ≥ 44px | |
| Landmarks semânticos | |
| `alt` em imagens de conteúdo | |

---

## Perguntas abertas

Itens que a extração não conseguiu decidir. Cada um precisa de uma resposta
do time antes de virar regra auditável.

1.
2.

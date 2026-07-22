---
title: Sem Cara de IA — Design que Não Parece Gerado por IA
description: Protocolo para produzir frontend, layout, HTML/CSS e UX que não caem no visual genérico "feito por IA"; define os tells, a causa-raiz e as correções
category: design
tags: [design, ui, ux, frontend, css, html, aesthetics, anti-generic]
---

# Sem Cara de IA — Design que Não Parece Gerado por IA

> **DIRETRIZ DE TOPO.** Cole o bloco da seção "Snippet para CLAUDE.md / memory / lessons"
> no topo de qualquer `CLAUDE.md`, memória ou arquivo de lições de projeto que envolva
> frontend, telas, layout ou identidade visual. Esta skill existe para uma regra única:
> **nenhuma interface entregue pode parecer gerada por IA por omissão de decisão.**

## Quando Aplicar

- Antes de gerar **qualquer** tela, landing page, dashboard, componente ou HTML/CSS do zero.
- Ao revisar frontend que "parece template", "parece genérico" ou "tem cara de IA".
- Ao definir a identidade visual inicial de um projeto (paleta, tipografia, ritmo).
- Sempre que o output visual não tiver sido ancorado em conteúdo real e contexto do domínio.

---

## O que é "cara de feito em IA"?

Não é um estilo. É a **ausência de decisão**.

Uma interface tem "cara de IA" quando reproduz a **média estatística** do que um
modelo viu em treino — landing pages de SaaS, shots de Dribbble, marketplaces de
template — em vez de refletir escolhas específicas, restritas e contextuais de quem
projeta. O resultado é competente, simétrico, "limpo"… e intercambiável com outros
dez mil produtos. **O tell não é feiúra — é genericidade.** Parece pronto, mas não
parece de ninguém, sobre nada, para ninguém em específico.

Definição operacional: *uma tela tem cara de IA quando você poderia trocar o logo,
o texto e o domínio por outros quaisquer sem que nada no design proteste.*

### Causa-raiz (por que a IA cai nisso)

- Modelos otimizam para o **centro da distribuição** de treino → produzem o
  design mais provável, que é o mais genérico possível.
- Na ausência de restrição, o default vence: paleta default, fonte default,
  layout default, cópia default.
- "Seguro" e "médio" são a mesma coisa para um gerador. Design de verdade é
  **opinião sob restrição** — exatamente o que se perde na geração por default.

A correção nunca é "capriche mais". É **injetar decisão específica**: conteúdo real,
restrição de paleta, ponto de vista tipográfico, ritmo editorial, verdade do domínio.

---

## Catálogo de Tells

Se o design apresenta qualquer um destes, ele tem cara de IA. Cada tell tem
correção. Genérico → específico.

### Cor

| Tell | Sintoma | Correção |
|---|---|---|
| Gradiente índigo-violeta default | O gradiente roxo-azul (`#6366f1 → #8b5cf6 → #a855f7`) em hero, botões e títulos | Escolher paleta derivada do domínio/marca; se usar gradiente, que seja decisão, não default |
| Título com `bg-clip-text` gradiente | Headline com texto em degradê colorido | Cor sólida com peso tipográfico; gradiente só com justificativa |
| Fundo de "blobs" borrados | Orbs coloridos com blur flutuando atrás do conteúdo | Fundo sólido, textura sutil ou nada; o conteúdo é o fundo |
| Paleta slate/zinc intocada | Cinzas default do framework, sem cor própria | Definir neutros próprios + 1 cor de marca com intenção |
| Dark mode `#0a0a0a` + neon | Preto absoluto com acento neon "developer tool" | Neutro escuro com matiz próprio; acento com contraste medido |

### Tipografia

| Tell | Sintoma | Correção |
|---|---|---|
| Inter/system em tudo | Uma sans neutra, um peso, zero personalidade | Par intencional: uma face de display com caráter + uma de texto legível |
| Sem hierarquia real | Tudo no mesmo tamanho/peso, cinza sobre cinza | Escala tipográfica explícita; contraste de peso e tamanho entre níveis |
| Escala default | Tamanhos do preset do framework, nunca ajustados | Escala própria (ex: 1.2–1.333 ratio) coerente com a densidade do produto |

### Layout

| Tell | Sintoma | Correção |
|---|---|---|
| Tudo centralizado | Headline + subtítulo + 2 botões, tudo no eixo central | Assimetria editorial; ancorar o olho fora do centro quando fizer sentido |
| Grid de 3 cards idênticos | "Features" como 3 cartões iguais: ícone + título + parágrafo cinza | Variar peso, tamanho e ordem; destacar a feature que importa |
| Simetria perfeita sem foco | Tudo alinhado, nenhum ponto focal além do centro | Tensão intencional: um elemento domina, o resto serve a ele |
| Ícone em quadrado com gradiente | Ícone de linha fina centrado num quadrado arredondado com bg suave | Iconografia consistente e semântica; sem a moldura decorativa clichê |
| Cantos arredondados uniformes | `border-radius` grande e igual em absolutamente tudo | Raio como decisão de sistema, coerente com a personalidade (pode ser reto) |

### Conteúdo e cópia

| Tell | Sintoma | Correção |
|---|---|---|
| Cópia de preenchimento | "Empower your workflow", "Seamlessly integrate", "Unlock the power of…" | Frases com especificidade: o que faz, para quem, com número real |
| Abstração vaga | Nenhum dado, nenhuma tela real, nenhum termo do domínio | Conteúdo real do produto: screenshots verdadeiros, dados reais, jargão do domínio |
| Avatares/logos placeholder | Testemunhos falsos, "Trusted by" com logos cinza | Só conteúdo verdadeiro; se não existe, não fingir que existe |
| Badges "AI-Powered" / "New" | Pills coloridas prometendo modernidade | Remover; o produto se prova pelo conteúdo, não pela pill |
| Emoji como ícone de seção | 🚀 ✨ 🔥 marcando features/títulos | Iconografia real ou nada |

### Efeitos

| Tell | Sintoma | Correção |
|---|---|---|
| Glassmorphism em tudo | `backdrop-blur` e painéis semitransparentes por toda parte | Superfícies opacas; blur só quando há sobreposição real que o justifique |
| Glow/sparkle/partículas | Brilhos neon, gradientes animados, partículas flutuando | Cortar; movimento e brilho custam atenção, precisam ser ganhos |
| Sombra em tudo | `box-shadow` uniforme em cada elemento | Elevação como sistema de camadas, não decoração por elemento |

### Ritmo e estrutura

| Tell | Sintoma | Correção |
|---|---|---|
| Ordem de template | hero → logos → 3 features → 3 passos → depoimentos → 3 planos (meio destacado) → CTA → footer | Estruturar pela narrativa real do produto, não pelo esqueleto padrão |
| Densidade uniforme "SaaS air" | Muito respiro em tudo, igual, independentemente do conteúdo | Densidade apropriada ao domínio (um painel de dados ≠ uma landing) |
| Uma seção diz o que a anterior já disse | Repetição de proposta de valor em blocos diferentes | Uma ideia por seção; se repete, corte |

---

## Protocolo Antes de Gerar (pré-flight)

Não escreva a primeira linha de markup antes de responder:

1. **Qual é o conteúdo real?** — Texto, dados, telas verdadeiras. Sem conteúdo real,
   o design vira preenchimento genérico. Conteúdo primeiro, layout depois.
2. **Qual é a restrição de cor?** — Defina neutros + 1 (no máx. 2) cor de marca
   com intenção. **Proíba o gradiente índigo-violeta como default.**
3. **Qual é o ponto de vista tipográfico?** — Nomeie o par (display + texto) e a
   escala. "Personalidade" é uma decisão, não um acidente.
4. **Qual é a referência?** — Aponte uma influência de design concreta e comprometa-se
   com ela (um produto, uma escola visual). Design sem referência regride pra média.
5. **Onde está a assimetria/o foco?** — Qual é o único elemento que domina a tela?
   Se a resposta é "tudo tem o mesmo peso", ainda não há design.
6. **O que o domínio exige?** — Densidade, jargão, tipo de dado. Uma ferramenta
   financeira, um app esportivo e um blog não podem sair iguais.

Se qualquer resposta for "o default" → pare e decida.

---

## Obrigatório: Artefato de Preview (3 opções × light/dark)

**Nenhum layout é entregue sem preview visual.** Todo desenvolvimento de layout
(tela, landing, dashboard, componente de página, HTML/CSS de aparência) exige, antes
de considerar pronto, um **artefato de preview** que atenda a três condições:

1. **3 opções distintas** — não 3 variações de cor da mesma ideia. Três direções
   de design genuinamente diferentes (layout, hierarquia, ritmo, tipografia), cada
   uma passando no "teste da troca". Uma delas pode ser recomendada; as outras
   existem para dar escolha real, não para simular escolha.
2. **Light e dark em cada opção** — cada uma das 3 opções renderizada nos dois temas.
   Nada de mostrar só um tema "porque o outro é igual": tokens de cor, contraste e
   sombra se comportam diferente e precisam ser vistos.
3. **Auto-contido e visual** — o preview mostra a aparência real (não descrição em
   texto), com conteúdo de exemplo plausível do domínio, para decisão informada.

Por que é obrigatório: escolher entre 3 direções concretas mata o default por
construção — não há como "aceitar a média" quando você precisa produzir três opções
opinativas e compará-las lado a lado, nos dois temas.

**Como produzir** (agnóstico de stack):
- Uma única página de preview (HTML self-contained, artifact, Storybook, ou o
  mecanismo de preview do projeto) contendo as 3 opções.
- Cada opção com toggle ou exibição pareada light/dark.
- Temas via tokens (`prefers-color-scheme` + override explícito), nunca cor hardcoded.
- Só depois da opção escolhida pelo usuário → implementar de verdade no projeto.

Sequência: **conteúdo real → 3 opções (light+dark) no preview → escolha → implementação.**

---

## Checklist de Auditoria "Cara de IA"

Antes de aprovar qualquer interface:

- [ ] **Artefato de preview gerado:** 3 opções distintas, cada uma em light **e** dark
- [ ] **Teste da troca:** trocar logo/texto/domínio faria o design "protestar"? (Se não, é genérico.)
- [ ] Paleta é decisão própria — **não** o gradiente roxo-azul default
- [ ] Tipografia tem par intencional e hierarquia real (não Inter-em-tudo)
- [ ] Há um ponto focal claro; não é tudo centralizado com peso uniforme
- [ ] Zero cópia de preenchimento — cada frase tem especificidade (o quê, para quem, número)
- [ ] Conteúdo é real (telas, dados, termos do domínio) — sem placeholders fingindo ser reais
- [ ] Sem "feature grid" de 3 cards idênticos por default
- [ ] Efeitos (blur, glow, sombra, gradiente) são **ganhos**, não aplicados por padrão
- [ ] Estrutura segue a narrativa do produto, não a ordem de template
- [ ] Densidade é apropriada ao domínio, não "SaaS air" uniforme
- [ ] Sem emoji como ícone, sem badges "AI-Powered", sem "Trusted by" cinza vazio

Qualquer item desmarcado → o design ainda tem cara de IA.

---

## Substituições Concretas (genérico → específico)

| No lugar de… | Faça… |
|---|---|
| Gradiente roxo no hero | Cor sólida da marca + tipografia que carrega o peso |
| "Empower your workflow with AI" | "Fecha o caixa de 12 lojas em 40s — antes eram 2 horas" |
| 3 cards de feature iguais | 1 bloco dominante com a feature principal + secundárias menores |
| Ícone de linha em quadrado com gradiente | Screenshot real do produto naquela função |
| Depoimentos com avatar aleatório | Nenhum depoimento até existir um real |
| Blobs borrados de fundo | Fundo sólido; deixar o conteúdo respirar sem ruído |
| Inter 400 em tudo | Display com caráter para títulos + texto legível para corpo |

---

## Regra de Ouro

> **Design é opinião sob restrição.** Cara de IA é o que sobra quando não há opinião
> nem restrição. Toda tela precisa carregar pelo menos uma decisão que só faz sentido
> *neste* produto, *neste* domínio, para *este* usuário. Sem essa decisão, você não
> projetou — você aceitou a média.

---

## Snippet para CLAUDE.md / memory / lessons

Cole **no topo** do arquivo:

```md
## ⛔ Regra #0 — Nunca design com cara de IA

Nenhuma tela, HTML, CSS ou layout pode parecer gerado por IA por omissão de decisão.
"Cara de IA" = genericidade: reproduzir a média de landing pages de SaaS em vez de
escolhas específicas ao domínio. Antes de gerar frontend, aplicar
`skills/design/sem-cara-de-ia.md`:
- Proibido: gradiente índigo-violeta default, Inter-em-tudo, tudo centralizado,
  3 cards de feature idênticos, glassmorphism/blobs/glow por padrão, cópia de
  preenchimento ("empower/seamlessly/unlock"), emoji como ícone, badges "AI-Powered".
- Obrigatório: conteúdo real, paleta decidida, par tipográfico com personalidade,
  ponto focal, densidade do domínio, e o "teste da troca" (trocar logo/texto/domínio
  deve fazer o design protestar).
- Obrigatório em TODO layout: gerar artefato de preview com 3 opções distintas,
  cada uma renderizada em light E dark, antes de implementar. Escolha primeiro, código depois.
```

---

## Integração com Outras Skills

- **Antes** (o que construir): `skills/frontend/menos-e-mais.md` reduz poluição;
  esta skill garante que o que sobra não seja genérico.
- **Durante** (identidade): `skills/design/visual-baseline.md` resolve imagem,
  tipografia e ícones; esta skill impede que a escolha caia no default.
- **Durante** (implementação): `skills/frontend/anti-frankenstein.md` +
  `skills/frontend/css-governance.md` mantêm o CSS limpo enquanto você aplica as
  decisões desta skill.
- **Depois** (gate): `skills/ux-ui/ui-ux-quality-gates.md` — adicionar o checklist
  "cara de IA" como gate obrigatório de entrega.

## Ver também

- `skills/frontend/menos-e-mais.md` — reduzir poluição visual
- `skills/design/visual-baseline.md` — imagem, tipografia e iconografia
- `skills/ux-ui/principios-de-interface.md` — hierarquia, tipografia, cor
- `skills/frontend/anti-frankenstein.md` — governança de CSS
- `skills/frontend/accessibility.md` — contraste e legibilidade (o não-genérico ainda precisa ser acessível)

---
title: Fontes de Referência de UI — Repertório Antes de Desenhar
description: Mapa de onde buscar componente, movimento, curadoria e padrão de acabamento antes de desenhar uma tela ou sistema; separa referência de ponto de partida para não cair no visual genérico
category: design
tags: [design, ui, referencia, repertorio, componentes, motion, curadoria, inspiracao]
---

# Fontes de Referência de UI — Repertório Antes de Desenhar

Quem desenha tela do zero, sem repertório, converge para a média. Esta skill organiza **onde
buscar** o que falta (bloco pronto, movimento, direção, régua de acabamento) para que o
projeto comece de uma referência escolhida — e não de uma página em branco nem do primeiro
default que a IA sugere.

## Skills Relacionadas

- `skills/design/sem-cara-de-ia.md` — define o que NÃO pode sair; esta skill alimenta o que
  entra no lugar (passo "nomeie o sistema consolidado" do protocolo).
- `skills/design/design-grounding/SKILL.md` — Fase 2 (ancorar em referência externa) usa
  estas fontes para escolher a base.
- `skills/design/visual-baseline.md` — imagem, tipografia e ícones depois da direção definida.

---

## Princípio: referência ≠ ponto de partida

Fonte de referência serve para **decidir**, não para **copiar**. A ordem importa:

1. Domínio, conteúdo real e público definidos.
2. Direção escolhida (sistema-cerne, paleta, par tipográfico, ponto focal).
3. **Só então** buscar nas fontes abaixo o que sustenta essa direção.

Inverter (abrir a galeria primeiro e colar o que for bonito) produz exatamente a média que
`sem-cara-de-ia` proíbe: o mesmo bloco popular, no mesmo lugar, em centenas de produtos.

---

## Os quatro papéis

| Papel | Pergunta que responde | Risco se usado sozinho |
|---|---|---|
| **Componente pronto** | "Esse bloco já existe resolvido?" | Layout de catálogo: todo mundo usa o mesmo hero/pricing |
| **Movimento** | "Como isso se anima sem parecer enfeite?" | Animação por animação, sem função (glow, blobs) |
| **Curadoria por tipo/estilo** | "Que direção cabe nesse domínio?" | Moodboard sem decisão |
| **Régua de acabamento** | "Qual o nível de polimento a perseguir?" | Imitar vitrine de prêmio ignorando a densidade do domínio |

Use pelo menos **um de cada papel** antes de abrir as três opções do preview. Se o projeto
não precisa de movimento (ex.: sistema interno denso), registre a ausência como decisão.

---

## Fontes por papel (exemplos, não prescrição)

A lista é um ponto de partida; o projeto pode trocar qualquer item sem violar a skill. O que
é obrigatório é existir uma fonte por papel e registrar qual foi usada.

| Papel | Exemplos | Observação |
|---|---|---|
| Componente pronto | 21st.dev, React Bits | Ambos ligados a React/Tailwind. Em outra stack, extrair a **estrutura e a lógica do bloco** e reimplementar |
| Movimento | React Bits, Motionsites | Motionsites expõe prompt pronto por página: tratar como estudo de movimento, nunca colar como está |
| Curadoria | Godly | Filtra por tipo e estilo; bom para escolher direção antes de abrir a ferramenta de design |
| Régua de acabamento | Awwwards | Site do dia/indicados; o nível de acabamento é o alvo, a estética não |

Para stacks sem React, os mesmos papéis têm equivalentes (bibliotecas de componentes da
própria plataforma, guidelines oficiais de HIG/Material, galerias de design system públicas).
O papel é o contrato; o site é o exemplo.

---

## Protocolo de uso

1. Ler `sem-cara-de-ia` (pré-flight) e fixar domínio, conteúdo e público.
2. Escolher **uma fonte por papel** e abrir 3–5 referências em cada.
3. Para cada referência retida, anotar em uma linha: **o que herdar** (proporção, densidade,
   hierarquia, tipo de movimento) e **o que descartar**.
4. Distribuir as referências entre as **3 opções do preview** (light e dark) — cada opção
   ancorada em referências diferentes, para as três serem realmente distintas.
5. Registrar as fontes usadas no `DESIGN.md` (seção Base de `design-grounding`) ou no PR.
6. Aplicar o **teste da troca**: trocando logo e nome, a tela ainda é reconhecível como deste
   produto? Se não, a referência virou cópia.

### Formato de registro

```markdown
## Referências usadas
- Componente: <fonte> — <bloco> → herdado: <estrutura>; descartado: <visual>
- Movimento: <fonte> — <efeito> → herdado: <duração/easing/gatilho>; descartado: <decoração>
- Direção: <fonte> — <exemplo> → opção B do preview
- Acabamento: <fonte> — <exemplo> → alvo: <detalhe concreto, ex.: espaçamento, tipografia>
```

---

## Direitos e licença

- **Código de componente** de biblioteca aberta: verificar a licença antes de copiar para
  produto comercial e manter a atribuição que ela exigir.
- **Imagem/captura** de site de terceiro (galeria, prêmio): serve para estudo e comparação;
  o arquivo não entra em entrega comercial sem direito de uso.
- **Prompt pronto** de galeria: é insumo, não entrega — a saída da IA ainda precisa passar
  pelo checklist de `sem-cara-de-ia`.

Ao colher referência a partir de post em rede social (ex.: lista de sites num carrossel), a
mecânica de leitura está em `skills/audit/instagram-e-ativos-do-cliente.md` (uso 2 —
curadoria), classificando o achado como **design/ui**.

---

## Antipadrões

- Abrir a galeria antes de definir domínio e direção.
- Usar só "componente pronto" e pular movimento e acabamento (resultado: bloco correto,
  tela sem personalidade).
- Mesma referência nas 3 opções do preview (as três saem iguais).
- Copiar o prompt de uma galeria e entregar a saída sem auditoria.
- Tratar a lista de sites como definitiva: ela envelhece; o contrato é o papel.

---

## Ver também

- `skills/design/sem-cara-de-ia.md` — tells e checklist de auditoria
- `skills/design/design-grounding/SKILL.md` — ancorar em referência madura e registrar a base
- `skills/design/visual-baseline.md` — imagem, tipografia e ícones
- `skills/audit/instagram-e-ativos-do-cliente.md` — colher referências de perfis e posts

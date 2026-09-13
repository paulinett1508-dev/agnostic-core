---
name: design-grounding
description: Estabelece a base factual de design de um projeto antes de qualquer crítica visual — extrai o design system que já existe no código para um DESIGN.md, ancora em uma referência externa madura, fecha o loop com screenshots e só então delega auditoria a um subagent. Use SEMPRE que o pedido envolver "melhorar o visual", "padronizar a UI", "revisar o design", "está feio/inconsistente", crítica de tela, auditoria de acessibilidade, criação de design system, handoff para dev, ou quando qualquer skill/plugin de design for acionado em um repositório que ainda não tem sistema visual documentado. Use também quando o usuário disser que não tem repertório de design suficiente para avaliar as sugestões recebidas.
---

# Design Grounding

Crítica de design sem base documentada produz ruído. O modelo devolve "melhore o contraste", "padronize o espaçamento", "considere hierarquia visual" — verdadeiro, genérico e inacionável. O usuário não consegue agir porque não sabe qual contraste, qual espaçamento, comparado a quê.

O problema não é a qualidade do crítico. É a ausência de um referencial contra o qual criticar.

Esta skill resolve isso na ordem correta: primeiro constrói o referencial a partir do código que já existe, depois ancora esse referencial em algo maduro, e só então habilita crítica — que a essa altura virou conformidade contra regra escrita, não julgamento estético.

## Skills Relacionadas

- `skills/design-system/SKILL.md` — direção oposta e complementar: planeja o sistema visual **antes** de codar algo novo (greenfield). Esta skill extrai o sistema que **já existe** no código (brownfield). Se não há código ainda, use aquela e volte aqui quando houver implementação.
- `skills/design/sem-cara-de-ia.md` — cobre o "genérico por omissão de decisão". O `DESIGN.md` desta skill é o que torna esse protocolo verificável em vez de subjetivo.
- `agents/reviewers/design-review.md` — o subagent da Fase 4 abaixo.

## Quando NÃO usar

- **Projeto greenfield sem código.** Não há sistema a extrair. Use `skills/design-system/SKILL.md` para definir a identidade visual do zero e volte aqui quando houver implementação.
- **O usuário quer uma identidade nova, não coerência.** Extração documenta o que existe; ela não é o caminho para reposicionamento visual.
- **Mudança pontual em uma tela.** Ancoragem tem custo. Não vale para um ajuste isolado.

## Princípio central

A expertise de design é substituída por **critério explícito**, não por mais opinião do modelo.

Quando o julgamento vive no `DESIGN.md`, qualquer agente — ou qualquer pessoa — consegue aplicar. Quando vive na cabeça do modelo, cada execução diverge e o usuário não tem como validar. Todo o workflow abaixo existe para mover julgamento de dentro do modelo para dentro de um arquivo versionado.

---

## Fase 1 — Extrair o sistema que já existe

Não pergunte ao usuário qual é o design system dele. Se ele soubesse responder, não precisaria desta skill. O sistema já está no código, implícito e inconsistente. Leia-o.

### O que inventariar

Varra o diretório de frontend e produza um inventário **com frequência de uso**, porque frequência é o que separa padrão de acidente:

| Dimensão | O que capturar |
|---|---|
| Cor | Todo valor de cor literal (hex, rgb, hsl, named) + quantas vezes aparece + em que contexto (fundo, texto, borda, estado) |
| Tipografia | Famílias, tamanhos, pesos, line-heights, letter-spacing |
| Espaçamento | Valores de padding, margin, gap |
| Forma | border-radius, larguras de borda, sombras |
| Movimento | Durações e easings de transição/animação |
| Componentes | Elementos recorrentes (botão, card, input, modal) e quantas variantes distintas cada um tem hoje |
| Breakpoints | Media queries em uso |
| Camada | Valores de z-index |

Inclua fontes fora do CSS quando existirem: config do Tailwind, tema de biblioteca de componentes, variáveis CSS, tokens em JSON/TS, estilos inline.

### Regra que não pode ser violada

**Documente. Não corrija.**

Se dezessete tons de cinza aparecem no projeto, registre os dezessete. Não escolha cinco e chame de paleta. A inconsistência é o diagnóstico — apagá-la na extração destrói a informação mais valiosa da varredura e produz um sistema fictício que o código não obedece.

Marque cada inconsistência como pergunta aberta, com a evidência:

```
⚠ 17 cinzas distintos. Os 4 com uso ≥5 ocorrências: #6B7280 (23), #9CA3AF (14),
  #374151 (9), #D1D5DB (6). Os outros 13 aparecem 1–2 vezes cada.
  → Aparentam ser deriva, não intenção. Confirmar com o usuário.
```

### Prompt de disparo

```
Varra <dir> e extraia toda decisão visual presente no código: cores com
contagem de ocorrências, escala tipográfica, espaçamentos, border-radius,
sombras, transições, componentes recorrentes e suas variantes, breakpoints,
z-index.

Escreva em DESIGN.md seguindo o template em assets/DESIGN.template.md.

Documente o que existe, incluindo contradições. Marque inconsistências com ⚠
e a evidência de uso. Não escolha vencedores, não refatore, não toque em código.
```

### Entregável

`DESIGN.md` na raiz do repositório, versionado. Use `assets/DESIGN.template.md` como estrutura.

Ao final, apresente ao usuário: quantos tokens de cada tipo existem, quais são claramente padrão (uso alto) e quais são claramente deriva (uso ≤2). Essa é a primeira leitura objetiva que ele terá do próprio projeto — e normalmente já resolve metade da sensação de "está inconsistente".

---

## Fase 2 — Ancorar em referência externa

Escolher direção visual do zero exige repertório. É exatamente o que falta. Então não escolha: **herde a estrutura de decisão de um sistema maduro e documente os desvios.**

Um design system estabelecido já resolveu escala de espaçamento, razões tipográficas, rampas de cor acessíveis e estados de componente. Adotá-lo como base não é falta de originalidade — é remover do escopo as decisões que não diferenciam o produto, para gastar julgamento onde ele importa.

### Como escolher a base

| Contexto do projeto | Base natural |
|---|---|
| React + Tailwind | shadcn/ui |
| Precisa de acessibilidade robusta em componentes | Radix Themes |
| Só CSS utilitário, sem biblioteca de componentes | defaults do Tailwind |
| Stack corporativa / produto interno | Carbon, Fluent, Material |
| Já usa alguma biblioteca de UI | a própria biblioteca — não introduza uma segunda |

Deixe a escolha com o usuário, mas **proponha uma opção com justificativa** em vez de apresentar um menu. Ele não tem repertório para escolher entre cinco alternativas; tem o suficiente para dizer sim ou não a uma recomendação fundamentada.

### Como registrar

No topo do `DESIGN.md`:

```markdown
## Base

Sistema de referência: shadcn/ui (Tailwind v4, Radix primitives)
Tudo que não estiver listado como desvio abaixo segue a base.

### Desvios deliberados

| Área | Base | Neste projeto | Motivo |
|---|---|---|---|
| Cor primária | zinc | #0F766E | Identidade da marca |
| Radius | 0.5rem | 0.25rem | Densidade de dados nas telas de listagem |

### Deriva a resolver

| Área | Estado atual | Alvo |
|---|---|---|
| Cinzas | 17 valores distintos | escala zinc da base |
```

A distinção entre **desvio** (decidido) e **deriva** (acidente) é o que torna o documento acionável. Sem ela, toda diferença parece intencional e nada é corrigível.

---

## Fase 3 — Fechar o loop visual

Auditoria de design sem ver a tela é análise de código, não de design. Um componente pode estar perfeito no CSS e quebrado em composição.

O agente lê imagem. Use isso:

```
[screenshot colado no terminal]

Audite esta tela contra o DESIGN.md do projeto.
Reporte apenas divergências do sistema documentado.
Para cada uma: o que está na tela, o que o DESIGN.md define, onde corrigir.
```

Se o projeto usa o plugin `design` (canvas) do Claude Code para gerar ou revisar telas: cole o `DESIGN.md` como contexto antes de pedir crítica ou geração no canvas. É o que transforma o plugin de "gerador de opinião estética" em "gerador que segue regra escrita" — a mesma falta de repertório que motiva esta skill é o que trava o uso do plugin sem esse chão factual.

### Isso muda a natureza do trabalho

Sem screenshot, o pedido é "isso está bom?" — pergunta estética, resposta subjetiva, inacionável.
Com screenshot + `DESIGN.md`, o pedido é "isso bate com aquilo?" — pergunta factual, resposta verificável.

### Cobertura mínima por rodada

Capture os estados que revelam problema, não só o caminho feliz:

- Estado vazio
- Estado de carregamento
- Estado de erro / validação
- Conteúdo longo (texto que estoura, listas grandes)
- O breakpoint mais estreito que o projeto suporta
- Foco de teclado visível

A maioria das inconsistências vive aqui, não na tela principal.

---

## Fase 4 — Delegar a um subagent

Só depois das fases 1–3. Um agent de revisão antes do `DESIGN.md` existir apenas automatiza a produção de crítica genérica.

### Por que subagent, e não skill ou comando

Pelo custo de contexto, não pela capacidade. Revisão de design abre muitos arquivos, consome screenshots e varre componentes — isso polui a sessão principal e empurra fora de contexto o trabalho que realmente estava em andamento. Um subagent faz a leitura pesada em contexto isolado e devolve só o veredito.

Escolha a forma pelo eixo certo:

- **Skill** — conhecimento que o agente principal precisa ter enquanto trabalha.
- **Comando** — atalho para um prompt que você repete.
- **Subagent** — trabalho que consome muito contexto e cujo resultado é um resumo curto.

Revisão de design é o terceiro caso.

### Template

Use `agents/reviewers/design-review.md` do acervo — copie para `.claude/agents/design-review.md` do projeto consumidor (ou referencie direto quando o acervo estiver instalado como submódulo/plugin).

A última regra do agent importa mais que as outras: agentes de revisão tendem a produzir achados porque foram chamados para produzir achados. Autorizar explicitamente o resultado vazio ("sem violações") é o que mantém o sinal confiável.

### A seção "Lacunas do sistema"

É o loop de realimentação. Cada lacuna reportada vira uma decisão a incorporar no `DESIGN.md` — o documento amadurece pelo uso, não por um esforço inicial de tentar prever tudo.

---

## Sequência completa

```
1. DESIGN.md existe?
   Não → Fase 1 (extrair). Pare. Não critique nada ainda.
   Sim → segue.

2. DESIGN.md tem base externa declarada?
   Não → Fase 2 (ancorar).
   Sim → segue.

3. Há screenshot da tela em questão?
   Não → peça. Inclua os estados da Fase 3.
   Sim → segue.

4. Auditoria vai rodar mais de uma vez neste projeto?
   Sim → Fase 4 (subagent).
   Não → auditoria inline.
```

## Antipadrões

**Pular para a crítica.** Produz a saída genérica que motivou esta skill. Se o usuário pede revisão e não há `DESIGN.md`, a resposta correta é propor a extração — explicando em uma frase por quê, não recusando.

**Inventar o design system.** Escrever um `DESIGN.md` ideal que o código não obedece cria um documento que ninguém consegue seguir e que todo mundo passa a ignorar. Extraia do real.

**Resolver inconsistência durante a extração.** Destrói o diagnóstico e embute escolhas não validadas.

**Criar o agent primeiro.** Empacota o problema em vez de resolvê-lo.

**Tratar deriva como desvio.** Se tudo que difere da base for registrado como decisão, nada é corrigível.

## Arquivos desta skill

- `assets/DESIGN.template.md` — estrutura do documento a produzir na Fase 1
- `agents/reviewers/design-review.md` — definição do subagent da Fase 4

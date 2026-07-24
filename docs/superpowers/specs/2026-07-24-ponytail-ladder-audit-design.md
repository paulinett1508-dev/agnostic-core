# Ponytail ladder + auditoria retrospectiva — design

Data: 2026-07-24
Status: aprovado para plano de implementação

## Contexto

Investigação de consumo excessivo de tokens no ecossistema `paulinett1508-dev`
(disparada pelo repo `theuniverse`, que audita todos os outros repos do perfil)
levou à análise do projeto [ponytail](https://github.com/DietrichGebert/ponytail):
uma skill/ruleset portável entre ~20 agentes de IA que impõe uma "escada" de
decisão (existe? já no código? stdlib? nativo? dependência instalada? uma
linha? só então o mínimo) antes de escrever código. Medido: -54% LOC, -22%
tokens, -20% custo, mantendo 100% de segurança/validação.

`agnostic-core` já cobre boa parte do espírito do ponytail:

- `skills/audit/pre-implementation.md` — checklist de 5 categorias
  (Simplicidade, Reutilização, Documentação, Modularidade, Impacto), mas como
  lista plana, não como escada sequencial ordenada.
- `skills/behavioral/context-audit.md` — já diagnostica bloat de contexto
  automático (CLAUDE.md/AGENTS.md/MEMORY.md/hooks), com classificação
  operacional/referência/redundante e meta de <150 linhas — mas escopado a
  um único repo, não a árvores de repos aninhados (o cenário real do
  `theuniverse`, que tem `.agnostic-core` como submodule real via
  `.gitmodules`).
- `skills/audit/code-review.md` — revisão de diff/PR pontual, não varredura
  retrospectiva do repo inteiro.

Gaps reais, sem cobertura hoje:
1. A escada existe em espírito mas não em ordem sequencial explícita.
2. Auditoria de bloat de contexto não cobre árvores de repos aninhados
   (submodule vs pasta comum vs `.git` órfão não documentado).
3. Não existe auditoria retrospectiva de overengineering do repo inteiro
   (só diff), nem ledger de débito técnico para atalhos conscientemente
   adiados.

Achado concreto que validou o problema original durante a pesquisa: o
`CLAUDE.md` de `theuniverse` manda ler, toda sessão, `ESTADO.md` (82 KB) +
`CHANGELOG.md` (59 KB) + `keywords-map.md` do submodule agnostic-core
(40 KB) — 181 KB de leitura mandatória antes de qualquer tarefa. Esse achado
fica registrado aqui como estudo de caso (ver Componente B), mas a correção
do `theuniverse` em si é fora de escopo desta spec — decisão do usuário foi
terminar esta spec primeiro.

## Decisões já tomadas (não reabrir sem motivo)

- `pre-implementation.md` é reescrito **in-place** (não vira arquivo novo) —
  preserva conteúdo, evita duplicação, menor diff.
- A escada continua **técnica** (keyword-triggered + plan mode) — não vira
  comportamental/always-on. Custo de contexto constante é exatamente o que
  este ecossistema está tentando evitar.
- A auditoria de bloat de contexto em árvore de repos é uma **extensão** de
  `context-audit.md`, não uma skill nova.
- A auditoria retrospectiva de overengineering + ledger de débito é a
  **única skill genuinamente nova**: `skills/audit/repo-overengineering-audit.md`.
- Exposição via `commands/*/COMMANDS.md` (entrada na lista existente), não
  via arquivo de comando dedicado — segue a convenção já usada no repo.

## Componente A — `skills/audit/pre-implementation.md` (reescrita in-place)

As categorias 1–3 (Simplicidade, Reutilização, Documentação) viram uma
escada sequencial explícita, no topo do arquivo, antes do checklist
detalhado:

```
1. Precisa existir? (YAGNI) → não: não escrever
2. Já existe no codebase? → reusar/estender, não duplicar
3. Stdlib ou lib já instalada resolve? → usar
4. Recurso nativo da plataforma resolve? → usar
5. Cabe em uma linha? → uma linha
6. Só então: o mínimo necessário que resolve
```

Regra de parada: parar no primeiro degrau que resolve o problema. A escada
roda *depois* de entender o problema (ler o código que a mudança toca,
traçar o fluxo real), nunca no lugar disso.

Categorias 4–5 (Modularidade, Impacto) **não entram na escada** — continuam
como checklist de pós-decisão, do jeito que já são hoje. Motivo: a escada
decide *quanto código escrever*; modularidade e impacto (blast radius,
testes, rollback) são preocupações ortogonais que nunca são puladas por
economia (mesmo princípio do ponytail: validação, segurança e tratamento de
erro nunca saem da mesa).

Seções mantidas sem mudança de conteúdo: "Padrões que pedem uma pausa",
"Comandos rápidos de verificação", "Referências".

Sem mudança de metadados: tipo continua `tecnica` em `keywords-map.md`,
mesmas keywords existentes (yagni, pre-implementation, etc.), mesmo
comportamento de plan mode antes de executar.

## Componente B — extensão de `skills/behavioral/context-audit.md`

Nova seção, inserida após "DIAGNOSTICO — MEDIR ANTES": **"AUDITORIA EM
ÁRVORE DE REPOS ANINHADOS"**.

Conteúdo:

1. **Detectar o tipo de acoplamento** antes de somar custo:
   - Submodule real: existe entrada em `.gitmodules` apontando pro repo.
   - Pasta comum copiada: sem `.gitmodules`, sem `.git` próprio dentro —
     conteúdo estático herdado, sem vida própria.
   - `.git` órfão não documentado: a pasta tem `.git` próprio mas não está
     listada em `.gitmodules` do pai — sinalizar como acoplamento **não
     documentado**, é o pior caso (ninguém sabe que aquilo é um repo à
     parte).

2. **Passo extra no diagnóstico**: para cada nível aninhado (submodule ou
   pasta com config própria), grep no `CLAUDE.md`/`AGENTS.md` do repo pai
   por instruções de leitura mandatória de arquivo que fisicamente mora no
   filho (padrões: "leia X", "sempre comece lendo", "consulte Y no início
   da sessão", "antes de qualquer coisa, leia"). Cada arquivo assim
   referenciado soma seu tamanho ao custo fixo por sessão do repo pai,
   mesmo que resida em outro repositório.

3. **Estudo de caso real** (substituindo/complementando o exemplo
   hipotético já existente no arquivo):

   ```
   Repo: theuniverse
   CLAUDE.md raiz          → 116 linhas (dentro da meta de <150)
   Mas CLAUDE.md instrui leitura mandatória de:
     ESTADO.md             → 82 KB  (handoff/estado, cresce sem limite)
     CHANGELOG.md          → 59 KB  (log histórico completo)
     .agnostic-core/docs/keywords-map.md → 40 KB (vem do submodule)

   Total de leitura mandatória por sessão: 181 KB
   Diagnóstico: os 3 arquivos são REFERÊNCIA (handoff, histórico, mapa de
   skills) tratados como OPERACIONAL (leitura obrigatória todo início de
   sessão). O CLAUDE.md raiz, sozinho, está saudável — o problema é o que
   ele manda ler.
   ```

4. **Novo item no checklist de auditoria** (ao final do checklist
   existente): "Repos aninhados (submodule ou pasta) têm arquivos
   referenciados como leitura obrigatória pelo CLAUDE.md/AGENTS.md do
   repo pai? Se sim, o tamanho desses arquivos entra na soma do custo
   fixo por sessão, independente de em qual repositório eles residem
   fisicamente."

Sem mudança de tipo/keywords existentes da skill; adicionar keywords novas
em `docs/keywords-map.md` para o gatilho da seção nova (ex.: "auditar
árvore de repos", "submodule aninhado", "monorepo de repos", "repo dentro
de repo").

## Componente C — nova skill `skills/audit/repo-overengineering-audit.md`

Escopo: varredura retrospectiva do **repo inteiro**, não do diff (o que
`code-review.md` já cobre é PR/diff pontual — este é o complemento
"auditoria de tudo que já existe").

O que procurar:
- Abstrações sem uso real (classe/interface genérica com um único
  consumidor).
- Arquivos acima de 300 linhas (mesmo limiar já usado em
  `pre-implementation.md`).
- Duplicação cross-file (mesma lógica repetida em módulos diferentes).
- Dependência instalada usada onde um recurso nativo da linguagem/
  plataforma já resolveria.

Critério do que conta como "overengineering": reusa a escada do
Componente A — não reinventa a régua. A skill referencia
`pre-implementation.md` em vez de duplicar a lista.

**Ledger de débito** — `docs/debt-ledger.md` no repo auditado (cria com
template mínimo se não existir):

```
| data | arquivo | o que foi simplificado | o que seria o ideal | severidade |
|------|---------|------------------------|----------------------|------------|
```

Regras do ledger:
- Cada rodada de auditoria futura decide, por entrada existente: manter
  (ainda é a decisão certa), resolver (virou tarefa) ou descartar (não é
  mais relevante).
- A skill **só relata e registra** — nunca aplica fix de código sozinha.
  Qualquer correção subsequente passa pelo fluxo normal (plan mode /
  `pre-implementation.md`).

Metadados: tipo `tecnica` em `keywords-map.md`, keywords novas (ex.:
"auditoria de repo inteiro", "overengineering do projeto", "débito
técnico", "ledger de débito").

## Componente D — exposição em `commands/*/COMMANDS.md`

Adicionar entrada na seção "Auditoria" dos 4 arquivos de comando por
ferramenta (`commands/claude-code/COMMANDS.md`, `commands/cursor/...`,
`commands/generic/...`, `commands/workflows/...`), seguindo o formato já
existente (`Nome  @.agnostic-core/skills/audit/nome-do-arquivo-md`):

```
Repo Overengineering Audit  @.agnostic-core/skills/audit/repo-overengineering-audit.md
```

`context-audit.md` já tem entrada na seção "Workflow" — sem mudança
necessária ali além do conteúdo do próprio arquivo (Componente B).

## Testes / verificação

- `npm run lint` e `npm run check-refs` devem passar antes de commitar
  (regra já existente no `CLAUDE.md` do repo).
- Toda skill nova ou alterada precisa: exemplo concreto incluído,
  linguagem agnóstica de stack (pergunta padrão do próprio repo: "um dev
  de qualquer stack conseguiria aplicar isso no próprio projeto?"),
  formatação Markdown consistente com as demais skills do diretório.
- Atualizar `docs/skills-index.md` referenciando a skill nova
  (Componente C) e confirmar que `pre-implementation.md` e
  `context-audit.md` continuam corretamente indexados após a edição.
- Atualizar `docs/keywords-map.md` com as keywords novas dos Componentes
  B e C.

## Fora de escopo desta spec

- Qualquer correção no `theuniverse` (CLAUDE.md, ESTADO.md, CHANGELOG.md).
  Fica registrado como achado, não como trabalho desta spec.
- Empacotamento multi-agente ao estilo ponytail (`.cursor/rules`,
  `.clinerules`, hooks Node.js por ferramenta). `agnostic-core` já resolve
  portabilidade via skills em Markdown puro consumidas por `@mention` ou
  `commands/`; replicar o modelo de ~20 adaptadores do ponytail não se
  aplica aqui.
- Ativação always-on (modo comportamental) da escada — decisão explícita
  de manter técnica/keyword-triggered.

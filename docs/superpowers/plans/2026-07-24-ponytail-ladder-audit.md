# Ponytail Ladder + Auditoria Retrospectiva Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrar ao `agnostic-core` a disciplina de "escada de decisão" do
projeto ponytail (YAGNI → reuso → stdlib → nativo → dependência → uma linha
→ mínimo) e fechar o gap de auditoria retrospectiva (repo inteiro, árvore de
repos aninhados, ledger de débito técnico) identificado na spec.

**Architecture:** Nenhum runtime novo — tudo é Markdown puro consumido via
`@mention` ou `commands/`. Uma skill existente é reescrita (`pre-implementation.md`),
uma é estendida (`context-audit.md`), uma é criada (`repo-overengineering-audit.md`),
e três arquivos de "descoberta" (`docs/skills-index.md`, `docs/keywords-map.md`,
`commands/claude-code/COMMANDS.md`) são atualizados para que a skill nova
seja encontrável.

**Tech Stack:** Markdown, Bash (`scripts/check-refs.sh`), `markdownlint-cli2`
via `npx`. Repositório: `paulinett1508-dev/agnostic-core`, checkout local em
`D:\PROJETOS\THEUNIVERSE\theuniverse\.agnostic-core`, branch
`feat/ponytail-ladder-audit` (criada a partir de `origin/master`, já contém
o commit da spec `4bbbbf0`).

## Global Constraints

- Linguagem 100% agnóstica de stack em todo conteúdo novo/editado (regra do
  `CLAUDE.md` do repo: "sem amarrar a framework ou linguagem específicos").
- Antes de cada commit: `npm run lint` e `npm run check-refs` devem passar
  sem erro (regra do `CLAUDE.md` do repo).
- Toda skill nova ou alterada precisa constar em `docs/skills-index.md` e,
  se ganhar/alterar keywords de auto-invocação, em `docs/keywords-map.md`.
- Branch principal do repo: `master`. Commits em Conventional Commits
  (`feat:`, `docs:`, `refactor:`, `chore:`).
- Nenhum push/PR automático — última tarefa do plano para no ponto de
  decisão do usuário (push ou não).
- Working directory de todos os comandos abaixo:
  `D:\PROJETOS\THEUNIVERSE\theuniverse\.agnostic-core`

---

## Task 1: Nova skill `repo-overengineering-audit.md`

**Files:**
- Create: `skills/audit/repo-overengineering-audit.md`

**Interfaces:**
- Consumes: nenhum (arquivo novo, standalone).
- Produces: caminho `skills/audit/repo-overengineering-audit.md`, usado
  pelas Tasks 2 (indexação) e 4 (nenhuma dependência direta, mas mesma
  categoria `audit/`). Nome do arquivo é a chave usada no keyword-map
  (`[repo-overengineering-audit]`) e no COMMANDS.md.

- [ ] **Step 1: Criar o arquivo da skill**

```markdown
# Auditoria Retrospectiva de Overengineering

Objetivo: varrer um repositorio inteiro (nao um diff pontual) em busca de
overengineering acumulado, e registrar em um ledger os atalhos conscientemente
adiados para que "depois" nao vire "nunca".

Complementa `code-review.md` (revisao de PR/diff) e `pre-implementation.md`
(checagem antes de escrever codigo novo) — esta skill audita o que ja foi
escrito, em qualquer momento, nao so o que muda numa PR.

---

QUANDO USAR

- Auditoria periodica de um repo maduro (ex: a cada final de sprint/release)
- Antes de uma refatoracao grande, para saber o tamanho real do problema
- Quando o time sente que "o codigo cresceu mais complexo do que devia" mas
  ninguem mediu onde

---

O QUE PROCURAR

1. Abstracoes sem uso real
   - [ ] Classe/interface generica com um unico consumidor
   - [ ] Camada de indirecao (factory, adapter, strategy) sem mais de uma
     variacao concreta
   - [ ] Configuracao/flag para um cenario que nunca mudou

2. Arquivos grandes demais
   - [ ] Arquivo acima de 300 linhas (mesmo limiar de pre-implementation.md)
   - [ ] Modulo misturando responsabilidades (dado + regra de negocio + I/O)

3. Duplicacao cross-file
   - [ ] Mesma logica reimplementada em modulos diferentes
   - [ ] Copy-paste com pequenas variacoes que poderiam ser um parametro

4. Dependencia onde nativo bastava
   - [ ] Biblioteca instalada para resolver algo que a stdlib/plataforma
     ja resolve
   - [ ] Dependencia usada uma unica vez, para uma unica funcao pequena

Criterio de decisao: reusa a escada de pre-implementation.md (existe? ja
no codebase? stdlib/nativo resolve? cabe numa linha? so entao o minimo) —
esta skill nao reinventa a regua, so aplica retroativamente ao repo inteiro.

---

LEDGER DE DEBITO TECNICO

Ao encontrar um trade-off consciente — algo simplificado de proposito,
sabendo que existiria uma solucao mais robusta — registrar em
`docs/debt-ledger.md`, na raiz do repo auditado. Criar o arquivo com o
template abaixo se ainda nao existir:

  # Debt Ledger

  | data | arquivo | o que foi simplificado | o que seria o ideal | severidade |
  |------|---------|-------------------------|----------------------|------------|

Regras do ledger:
- [ ] Cada entrada tem data, arquivo/linha, o atalho tomado, o que seria
  o ideal, e severidade (baixa/media/alta)
- [ ] Toda nova rodada de auditoria reavalia entradas antigas: manter
  (ainda e a decisao certa), resolver (virou tarefa/issue) ou descartar
  (nao e mais relevante)
- [ ] A skill so relata e registra — nunca aplica fix de codigo sozinha.
  Correcao subsequente passa pelo fluxo normal (plan mode /
  pre-implementation.md)

---

CHECKLIST DA AUDITORIA

- [ ] Varrer o repo por arquivos acima de 300 linhas
- [ ] Buscar abstracoes com um unico consumidor (grep por implementa/extends
  da classe/interface)
- [ ] Buscar duplicacao cross-file (blocos de logica repetidos)
- [ ] Conferir dependencias instaladas vs. uso real (uma unica chamada?)
- [ ] Para cada achado: aplicar a escada de pre-implementation.md e decidir
  se e overengineering de fato
- [ ] Registrar/atualizar docs/debt-ledger.md com os achados
- [ ] Reavaliar entradas antigas do ledger (manter/resolver/descartar)
- [ ] Nao aplicar fix sozinho — reportar achados e aguardar decisao

---

Referencias
- skills/audit/pre-implementation.md (escada de decisao usada como criterio)
- skills/audit/code-review.md (auditoria de diff/PR pontual)
- https://martinfowler.com/bliki/Yagni.html (YAGNI)
```

- [ ] **Step 2: Rodar lint só neste arquivo**

Run: `npx -y markdownlint-cli2 "skills/audit/repo-overengineering-audit.md"`
Expected: `Summary: 0 error(s)`

- [ ] **Step 3: Commit**

```bash
git add skills/audit/repo-overengineering-audit.md
git commit -m "feat(skills): add repo-overengineering-audit skill

Varredura retrospectiva do repo inteiro (nao so diff) por overengineering,
com ledger de debito tecnico em docs/debt-ledger.md do repo auditado."
```

---

## Task 2: Indexação e descoberta da skill nova

**Files:**
- Modify: `docs/skills-index.md` (linha 13, e nova linha após a linha 112)
- Modify: `docs/keywords-map.md` (novo bloco após a linha 158)
- Modify: `commands/claude-code/COMMANDS.md` (nova linha após a linha 98)

**Interfaces:**
- Consumes: `skills/audit/repo-overengineering-audit.md` (Task 1) — o path
  precisa existir antes deste task, senão `check-refs.sh` falha.
- Produces: entrada `[repo-overengineering-audit]` em `keywords-map.md`,
  usada pelo protocolo de auto-invocação descrito no `CLAUDE.md` de cada
  repo consumidor.

- [ ] **Step 1: Atualizar contagem e adicionar linha em `docs/skills-index.md`**

Trocar (linha 13):
```
SKILLS (92)
```
por:
```
SKILLS (93)
```

Trocar (linhas 111-113, dentro da seção "Auditoria"):
```
  skills/audit/documentation-hygiene.md           Auditoria/limpeza de docs: limbo invertido, 5 vereditos, fonte-unica, ondas

Node.js
```
por:
```
  skills/audit/documentation-hygiene.md           Auditoria/limpeza de docs: limbo invertido, 5 vereditos, fonte-unica, ondas
  skills/audit/repo-overengineering-audit.md      Varredura retrospectiva do repo inteiro por overengineering, com ledger de debito tecnico

Node.js
```

- [ ] **Step 2: Adicionar bloco em `docs/keywords-map.md`**

Trocar (linhas 153-159, bloco `[pre-implementation]` completo até a linha em
branco antes de `[validation-checklist]`):
```
[pre-implementation]
- keywords: antes de implementar, pre-implementation, verificar antes de codar, ja existe isso, duplicacao, solucao mais simples, yagni, checar antes, procurar antes de criar, existe algo parecido, verificar duplicidade, nao reinventar a roda
- path: skills/audit/pre-implementation.md
- tipo: tecnica
- descricao: Verificacao pre-implementacao: duplicacao de codigo e solucao mais simples

[validation-checklist]
```
por:
```
[pre-implementation]
- keywords: antes de implementar, pre-implementation, verificar antes de codar, ja existe isso, duplicacao, solucao mais simples, yagni, checar antes, procurar antes de criar, existe algo parecido, verificar duplicidade, nao reinventar a roda
- path: skills/audit/pre-implementation.md
- tipo: tecnica
- descricao: Verificacao pre-implementacao: duplicacao de codigo e solucao mais simples

[repo-overengineering-audit]
- keywords: auditoria de repo inteiro, auditar overengineering, overengineering do projeto, debito tecnico, debt ledger, ledger de debito, auditoria retrospectiva, varredura do repo, auditoria de todo o codigo
- path: skills/audit/repo-overengineering-audit.md
- tipo: tecnica
- descricao: Varredura retrospectiva do repo inteiro por overengineering, com ledger de debito tecnico

[validation-checklist]
```

- [ ] **Step 3: Adicionar entrada em `commands/claude-code/COMMANDS.md`**

Trocar (linhas 97-99):
```
  Refactor Monolith          @.agnostic-core/skills/audit/refactor-monolith.md
  Detect Hardcodes           @.agnostic-core/skills/audit/detect-hardcodes.md

```
por:
```
  Refactor Monolith          @.agnostic-core/skills/audit/refactor-monolith.md
  Detect Hardcodes           @.agnostic-core/skills/audit/detect-hardcodes.md
  Repo Overengineering Audit @.agnostic-core/skills/audit/repo-overengineering-audit.md

```

- [ ] **Step 4: Rodar check-refs e lint no repo inteiro**

Run: `bash scripts/check-refs.sh`
Expected: última linha `OK - nenhum problema encontrado.` (ou apenas avisos
pré-existentes não relacionados a esta mudança — nenhum erro novo).

Run: `npx -y markdownlint-cli2 "**/*.md" "#node_modules" "#.claude/skills"`
Expected: `Summary: 0 error(s)`

- [ ] **Step 5: Commit**

```bash
git add docs/skills-index.md docs/keywords-map.md commands/claude-code/COMMANDS.md
git commit -m "docs: index repo-overengineering-audit skill

Adiciona a skill nova em skills-index.md, keywords-map.md (auto-invocacao)
e commands/claude-code/COMMANDS.md, seguindo o padrao ja usado pelas
demais skills de audit/."
```

---

## Task 3: Reescrever `pre-implementation.md` como escada sequencial

**Files:**
- Modify: `skills/audit/pre-implementation.md` (reescrita completa do
  arquivo, preservando todo o conteúdo existente)

**Interfaces:**
- Consumes: nenhum.
- Produces: nenhuma mudança de path/keyword — mesmo arquivo, mesma entrada
  em `keywords-map.md` (`[pre-implementation]`, tipo `tecnica`), sem
  alteração necessária lá.

- [ ] **Step 1: Substituir o conteúdo completo do arquivo**

Conteúdo final de `skills/audit/pre-implementation.md`:

```markdown
# Pré-Implementação

Perguntas úteis para fazer antes de escrever código novo. Ajudam a evitar os problemas
mais comuns: overengineering, duplicação, reinvenção da roda e arquivos monolíticos.
Vale consultar ao receber uma tarefa de implementação ou quando a solução parece complexa demais.

## Escada de decisão (pare no primeiro degrau que resolve)

A escada roda depois de entender o problema (ler o código que a mudança toca,
traçar o fluxo real) — nunca no lugar disso. Ela decide *quanto código escrever*,
não substitui modularidade, testes ou análise de impacto (seções 4 e 5 abaixo).

1. Precisa existir? (YAGNI) — não: não escrever.
2. Já existe no codebase? — buscar (Grep por nome/comportamento) e
   reusar/estender em vez de duplicar.
3. Stdlib ou lib já instalada resolve? — consultar documentação oficial
   antes de implementar; confirmar versão da lib.
4. Recurso nativo da linguagem/plataforma resolve? — usar o nativo.
5. Cabe em uma linha? — uma linha.
6. Só então: o mínimo necessário que resolve o problema, proporcional à
   sua complexidade real.

Nunca pular por economia: validação de trust-boundary, tratamento de erro,
segurança e acessibilidade. A escada é sobre preguiça na solução, nunca
sobre negligência.

## Checklist detalhado (degraus 1-3 da escada)

1 - Simplicidade (Anti-Overengineering)
- [ ] Existe uma solucao mais simples que resolve o mesmo problema?
- [ ] Estou criando abstracao para um unico caso de uso?
- [ ] A solucao e proporcional a complexidade do problema?
- [ ] Posso resolver com menos de 30 linhas usando o que ja existe?

2 - Reutilizacao (Sem Duplicacao)
- [ ] Busquei no projeto se funcao similar ja existe (Grep por nome/comportamento)
- [ ] Verifiquei se o modulo/utilitario ja resolve isso
- [ ] Encontrei codigo identico copiado de outro lugar no projeto?
- [ ] Se existe: estender/reusar em vez de duplicar

3 - Documentacao (Nao Reinventar a Roda)
- [ ] Consultei documentacao oficial da linguagem/framework antes de implementar
- [ ] Verifiquei se existe metodo nativo que faz o mesmo
- [ ] Confirmei que a biblioteca ja instalada nao resolve isso
- [ ] Versao da lib verificada (nao usar sintaxe de versao desatualizada)

## Checklist pós-decisão (não entra na escada — nunca é pulado)

4 - Modularidade (Sem Monolitos)
- [ ] Arquivo alvo tem menos de 300 linhas? (acima disso: considerar split)
- [ ] A funcao tem responsabilidade unica e clara?
- [ ] Estou misturando responsabilidades (ex: query + logica de negocio + resposta HTTP)?
- [ ] A funcao pode ser testada de forma isolada?

5 - Impacto (Sem Efeitos Colaterais)
- [ ] Identifiquei todos os arquivos que usam o que vou modificar (Grep)
- [ ] Mudanca quebra alguma funcionalidade existente?
- [ ] Testes existentes cobrem o que vou alterar?
- [ ] Existe rollback simples se der errado?

Checklist de Verificacao Antes de Criar Arquivo Novo
- [ ] Existe arquivo existente que poderia receber esse codigo?
- [ ] O novo arquivo tem nome em kebab-case e localizado no diretorio correto?
- [ ] Ha pelo menos um teste cobrindo o novo codigo?
- [ ] Dependencias necessarias ja estao instaladas (sem adicionar sem necessidade)?

## Padrões que pedem uma pausa
- "Vou criar uma classe base generica para..." → pode ser overengineering
- "Vou copiar esse bloco aqui e ajustar..." → duplicacao, extrair funcao
- "Acho que a sintaxe e assim..." → verificar documentacao primeiro
- "Esse arquivo esta ficando grande, vou colocar tudo aqui..." → avaliar split
- "Funciona, vou deixar o teste pra depois..." → testes agora, nao depois

## Comandos rápidos de verificação
- Buscar funcao similar: grep -rn "nomeFuncao\|comportamento" src/
- Ver tamanho do arquivo alvo: wc -l arquivo.js
- Verificar quem usa o que vou alterar: grep -rn "nomeDoQueVouAlterar" .
- Checar lib nativa: documentacao da linguagem/framework

Referencias
- https://martinfowler.com/bliki/Yagni.html (YAGNI - You Ain't Gonna Need It)
- https://en.wikipedia.org/wiki/Don%27t_repeat_yourself (DRY)
- https://en.wikipedia.org/wiki/Single-responsibility_principle (SRP)
```

- [ ] **Step 2: Verificar que nenhum item do checklist original foi perdido**

Run: `grep -c '^\- \[ \]' skills/audit/pre-implementation.md`
Expected: `24` (mesmo número de checkboxes do arquivo original — confirmado via `git show origin/master:skills/audit/pre-implementation.md | grep -c '^\- \[ \]'`: 4 por cada uma das 5 categorias + 4 do "Checklist de Verificacao Antes de Criar Arquivo Novo" = 24. Nenhum item pode ter sido perdido na reescrita.)

- [ ] **Step 3: Lint**

Run: `npx -y markdownlint-cli2 "skills/audit/pre-implementation.md"`
Expected: `Summary: 0 error(s)`

- [ ] **Step 4: Commit**

```bash
git add skills/audit/pre-implementation.md
git commit -m "refactor(skills): rewrite pre-implementation.md as sequential ladder

Reordena as categorias 1-3 (Simplicidade, Reutilizacao, Documentacao) numa
escada sequencial explicita (pare no primeiro degrau que resolve), inspirada
no projeto ponytail. Categorias 4-5 (Modularidade, Impacto) continuam como
checklist pos-decisao, fora da escada. Nenhum conteudo original removido."
```

---

## Task 4: Estender `context-audit.md` para árvores de repos aninhados

**Files:**
- Modify: `skills/behavioral/context-audit.md` (nova seção após a seção de
  diagnóstico, e novo item de checklist)
- Modify: `docs/keywords-map.md` (estender a linha de keywords do bloco
  `[context-audit]`, linha 98)

**Interfaces:**
- Consumes: nenhum.
- Produces: nenhuma mudança de path — mesmo arquivo, mesma entrada
  `[context-audit]` (tipo `behavioral`) em `keywords-map.md`, só com
  keywords adicionais.

- [ ] **Step 1: Inserir a nova seção após o diagnóstico**

Trocar (linhas 37-43):
```
  3. Identificar sobreposicao
     Comparar conteudo entre arquivos. Perguntar para cada bloco:
     - Este conteudo aparece em mais de um arquivo?
     - Este conteudo e necessario em TODA sessao ou apenas em tarefas especificas?
     - Este conteudo e instrucao operacional ou documentacao de referencia?

---

```
por:
```
  3. Identificar sobreposicao
     Comparar conteudo entre arquivos. Perguntar para cada bloco:
     - Este conteudo aparece em mais de um arquivo?
     - Este conteudo e necessario em TODA sessao ou apenas em tarefas especificas?
     - Este conteudo e instrucao operacional ou documentacao de referencia?

---

AUDITORIA EM ÁRVORE DE REPOS ANINHADOS

Quando o repo auditado contém outros repositórios aninhados (submodules ou
pastas comuns), o custo de contexto por sessão não termina nos arquivos do
próprio repo — pode incluir arquivos que fisicamente moram em um repo
filho, se o CLAUDE.md/AGENTS.md do pai mandar lê-los.

  1. Detectar o tipo de acoplamento antes de somar custo
     - Submodule real: existe entrada em .gitmodules apontando pro repo.
     - Pasta comum copiada: sem .gitmodules, sem .git proprio dentro —
       conteudo estatico herdado, sem vida propria.
     - .git orfao nao documentado: a pasta tem .git proprio mas nao esta
       listada em .gitmodules do pai — pior caso, ninguem sabe que aquilo
       e um repo a parte.

  2. Passo extra no diagnostico
     Para cada nivel aninhado (submodule ou pasta com config propria),
     grep no CLAUDE.md/AGENTS.md do pai por instrucoes de leitura
     mandatoria de arquivo que mora no filho: "leia X", "sempre comece
     lendo", "consulte Y no inicio da sessao", "antes de qualquer coisa,
     leia". Cada arquivo assim referenciado soma seu tamanho ao custo fixo
     por sessao do repo pai, mesmo residindo em outro repositorio.

     Comando rapido: grep -riE "leia|sempre comece|consulte.*inicio|antes de qualquer coisa" CLAUDE.md AGENTS.md

  3. Estudo de caso real

     CLAUDE.md raiz          → 116 linhas (dentro da meta de <150)
     Mas o CLAUDE.md instrui leitura mandatoria de:
       ESTADO.md                          → 82 KB (handoff/estado, cresce sem limite)
       CHANGELOG.md                       → 59 KB (log historico completo)
       <submodule>/docs/keywords-map.md   → 40 KB (vem de repo aninhado)

     Total de leitura mandatoria por sessao: 181 KB

     Diagnostico: os 3 arquivos sao REFERENCIA (handoff, historico, mapa de
     skills) tratados como OPERACIONAL (leitura obrigatoria todo inicio de
     sessao). O CLAUDE.md raiz, sozinho, esta saudavel — o problema e o
     que ele manda ler.

---

```

- [ ] **Step 2: Adicionar item ao checklist final**

Trocar (linha 123, última linha do checklist):
```
- [ ] Repetir auditoria periodicamente (a cada 2-4 semanas) conforme o projeto evolui
```
por:
```
- [ ] Repetir auditoria periodicamente (a cada 2-4 semanas) conforme o projeto evolui
- [ ] Repos aninhados (submodule ou pasta) tem arquivos referenciados como leitura obrigatoria pelo CLAUDE.md/AGENTS.md do repo pai? Se sim, o tamanho desses arquivos entra na soma do custo fixo por sessao, independente de em qual repositorio residem fisicamente.
```

- [ ] **Step 3: Estender keywords em `docs/keywords-map.md`**

Trocar (linha 98):
```
- keywords: auditoria de contexto, context audit, token bloat, contexto inflado, reduzir contexto, context size, diagnosticar contexto, otimizar claude md, context cleanup, limpeza de contexto, enxugar contexto, arquivos pesados, contexto desnecessario, reduzir tokens automaticos
```
por:
```
- keywords: auditoria de contexto, context audit, token bloat, contexto inflado, reduzir contexto, context size, diagnosticar contexto, otimizar claude md, context cleanup, limpeza de contexto, enxugar contexto, arquivos pesados, contexto desnecessario, reduzir tokens automaticos, auditar arvore de repos, submodule aninhado, monorepo de repos, repo dentro de repo, gitmodules, repo aninhado
```

- [ ] **Step 4: Lint e check-refs**

Run: `npx -y markdownlint-cli2 "skills/behavioral/context-audit.md"`
Expected: `Summary: 0 error(s)`

Run: `bash scripts/check-refs.sh`
Expected: `OK - nenhum problema encontrado.` (ou só avisos pré-existentes)

- [ ] **Step 5: Commit**

```bash
git add skills/behavioral/context-audit.md docs/keywords-map.md
git commit -m "feat(skills): extend context-audit.md for nested repo trees

Adiciona secao de auditoria para arvores de repos aninhados (submodule
real vs pasta comum vs .git orfao nao documentado), com o theuniverse
(ESTADO.md 82KB + CHANGELOG.md 59KB + keywords-map.md 40KB de leitura
mandatoria) como estudo de caso real. Estende keywords de auto-invocacao."
```

---

## Task 5: Verificação final completa

**Files:** nenhum arquivo novo — só validação do estado acumulado das
Tasks 1-4.

**Interfaces:**
- Consumes: todos os arquivos modificados nas Tasks 1-4.
- Produces: branch `feat/ponytail-ladder-audit` pronta para revisão/push,
  nenhuma ação remota tomada.

- [ ] **Step 1: Rodar o lint completo do repositório**

Run: `npm run lint`
Expected: `Summary: 0 error(s)`

- [ ] **Step 2: Rodar check-refs completo**

Run: `npm run check-refs`
Expected: última linha `OK - nenhum problema encontrado.`

- [ ] **Step 3: Conferir o log de commits da branch**

Run: `git log --oneline origin/master..HEAD`
Expected: 5 commits (spec + 4 de implementação), todos com mensagens
Conventional Commits, nenhum arquivo fora do escopo desta plan.

- [ ] **Step 4: Parar para decisão do usuário**

Não fazer push nem abrir PR. Reportar ao usuário: branch, commits, e
perguntar se deseja `git push origin feat/ponytail-ladder-audit` +
`gh pr create` agora, ou revisar antes.

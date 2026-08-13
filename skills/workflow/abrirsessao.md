# /abrirsessao — Retomada robusta de sessão

Reconstrói o contexto da sessão anterior em menos de 60 segundos.
Substitui `/newsession`. Invoque com `/abrirsessao` ao iniciar qualquer sessão.

**Orçamento de contexto: teto de 3.000 tokens de leitura.** A retomada inteira
cabe nisso — num projeto real, medido, a sequência abaixo custou ~2.600 tokens,
dos quais ~1.600 foram só o handoff. Se estourar, algum passo está vasculhando
além do escopo: pare e reporte em vez de continuar lendo.

---

## Sequência obrigatória (executar na ordem)

### 1. Hora real — PRIMEIRO, SEMPRE

```bash
date
```

Nunca operar com timestamp de contexto: ele envelhece sem aviso.
Só consultar servidor de tempo remoto se o projeto tiver um autoritativo **e**
houver suspeita de divergência. Caso contrário, `date` local basta.

### 2. Git — repo em evidência

```bash
git pull && git log --oneline -5 && git status --short
```

Conflito ou mudança remota inesperada → reportar antes de qualquer edição.

Se o projeto tiver `.agnostic-core` como submodule, incluir `git submodule status`
na mesma leva — é comparação de hash, não abre arquivo, custo desprezível. Sinaliza
atualização disponível no acervo sem forçar reler ou reavaliar nada; a decisão de
rodar `git submodule update --remote .agnostic-core` fica pro usuário, fora do
`/abrirsessao`.

### 3. Fila prioritária — uma chamada, não quatro

```bash
gh issue list --state open --search "label:scheduled,observatory-alert"
```

- `scheduled` com data vencida → topo da fila. Conferir o campo **Quando:** no corpo.
- `observatory-alert` → reportar antes de agir.

**Regra de deduplicação (obrigatória):** alertas repetidos do mesmo assunto
(ex.: quatro "CI falhou" na mesma madrugada) contam como **um** item. Reportar a
mais recente + a contagem, nunca listar uma a uma nem abrir o corpo de cada.
Alerta crônico é ruído de automação, não bloqueio de sessão: reportar em uma
linha e seguir, salvo se o usuário mandar tratar.

Uma chamada com `label:a,b` cobre os dois rótulos. Rodar uma consulta por rótulo
paga round-trip e listagem repetidos para o mesmo conjunto de issues.

### 4. Backlog vivo — uma chamada, compacta, sem truncar

```bash
gh issue list --state open --limit 100 \
  --search "-label:observatory -label:observatory-alert" \
  --json number,title,labels \
  -q '.[] | "#\(.number) \(.title)\(if (.labels|length)>0 then " ["+((.labels|map(.name))|join(","))+"]" else "" end)"'
```

Exclui o que já veio no passo 3, evitando contar as mesmas issues duas vezes.
O formato `--json`/`-q` corta as colunas de estado e data ISO, que não decidem
nada na abertura.

**Nunca usar `--limit 30`:** trunca em silêncio assim que o backlog passa de 30
itens, entregando briefing incompleto sem avisar. Pedir 100 e receber 34 sai mais
barato que pedir 30 e não saber o que ficou de fora.

Issues são o backlog ativo. `TASKS_PENDENTES.md` (se existir) é histórico/detalhe,
não backlog.

**Projeto sem `gh` disponível (backlog em arquivo):** ler apenas os TÍTULOS, nunca o
arquivo inteiro. O corpo de um item só é aberto quando aquele item for de fato
escolhido para trabalho — e aí lendo o trecho, não o arquivo.

```bash
grep -n '^### ' BACKLOG.md   # ou o arquivo de backlog do projeto
```

Um backlog em arquivo cresce sem limite e vira o maior consumidor isolado da
janela de contexto — em projeto real já custou ~32 mil tokens numa abertura, mais
que todo o resto da retomada somado, e ainda assim veio truncado (briefing
incompleto pagando preço cheio). Se o `grep` de títulos passar de ~60 itens ou o
arquivo passar de ~1.000 linhas, **registrar como dívida**: quebrar em índice +
um arquivo por área, para que o índice caiba na abertura.

### 5. Handoff mais recente

Ler **apenas** o arquivo de maior data em `docs/handoffs/`. Um só, nunca dois.

O handoff é um **retrato datado**, não verdade viva. Antes de agir em qualquer
guard-rail destrutivo, verificar o estado atual em produção.

### 6. Saída estruturada

```
SESSÃO RETOMADA — <data/hora real>

ONDE PARAMOS
<2-3 linhas do estado em voo do handoff>

FILA PRIORITÁRIA
- [scheduled] #N título — VENCIDA (Quando: ...)
- [alerta] <assunto> — Nx desde <data>, mais recente #N

PRÓXIMAS NA FILA
- #N, #N, #N

GUARD-RAILS ATIVOS
- <o que NÃO fazer e por quê>

PRÓXIMA AÇÃO PROPOSTA
<ação específica — anunciar e aguardar "sim" se tocar infra>
```

---

## O que NÃO ler — já está no contexto

Todo harness injeta parte do contexto automaticamente, a cada turno, antes da
primeira mensagem. Reler esses arquivos durante o `/abrirsessao` é cópia literal
do que já está na janela: custo dobrado, informação zero.

Levantar uma vez, por projeto, o que o harness já entrega. Tipicamente:

| Fonte | Como costuma chegar |
|---|---|
| Instruções do projeto e globais (`CLAUDE.md`, `AGENTS.md`) | injetadas no prompt do sistema |
| Índice de memórias e memórias relevantes | mecanismo de memória do harness |
| Buffers de histórico de sessão | hooks de início de sessão |
| Contexto de infraestrutura (hosts, contextos de container, portas) | hooks de início de sessão |

Só abrir um arquivo de memória individual se o índice apontar para ele **e** a
tarefa em mãos depender do conteúdo. "Ler o MEMORY.md para ter contexto" é o
caso clássico de desperdício: o índice já veio junto com o prompt.

## Fora do caminho padrão — só sob pedido

Estes passos **não** rodam no `/abrirsessao`. Custam tokens ou tempo sem mudar
nenhuma decisão de abertura. Executar apenas se o usuário pedir ou se o handoff
apontar incidente aberto:

- **Status de serviços em produção.** Verificação passiva é leitura, não
  correção, e leitura que ninguém vai usar na primeira decisão da sessão. Se for
  rodar, usar o canal que o projeto já tem configurado (contexto de container,
  script de deploy próprio), não um `ssh` genérico que pode falhar e queimar
  turno em retry.
- **Comunicados institucionais** (cartas de apresentação, avisos de ferramenta,
  onboarding de satélites). São documentos estáticos: ler **uma vez**, registrar
  o que importa na memória do projeto, nunca reler a cada abertura.
- **Roteamento de modelo.** Quem escolhe o modelo em execução é o harness ou o
  usuário; instrução dentro da skill não troca o modelo da sessão. Se o projeto
  usa roteamento por fase, ele é decidido no turno de trabalho, não na abertura.
- **Leitura de skills, ADRs, POPs, decks, PDFs.** Puxar sob demanda, quando a
  tarefa concreta exigir.

---

## Regras invioláveis

- Hora real ANTES de qualquer análise. Nunca confiar no timestamp do contexto.
- Git pull ANTES de qualquer edição. Nunca trabalhar em branch desatualizado.
- Handoff é ponto de partida, não verdade absoluta: verificar produção antes de
  agir em guard-rails.
- A saída do `/abrirsessao` é um briefing, não autorização de execução. Propor e
  aguardar "sim".
- **ORÇAMENTO DE CONTEXTO — a abertura é barata ou não é abertura.** Nenhum passo
  do `/abrirsessao` lê um arquivo inteiro com mais de ~300 linhas. Backlog,
  changelog, histórico técnico e documento de análise entram por
  `grep`/cabeçalho/`tail`, nunca por leitura integral. Se um `Read` vier truncado
  pelo limite da ferramenta, isso é sinal de que o arquivo NÃO deveria ter sido
  lido assim: pagou-se o teto de tokens e ainda se recebeu informação parcial.
- **UMA CHAMADA POR PERGUNTA.** Consultas que respondem à mesma pergunta se
  consolidam em um comando. Quatro listagens de issues no mesmo repositório são
  uma listagem com filtro.
- **ESCOPO MÍNIMO — não vasculhar.** Durante o `/abrirsessao`, a única leitura de
  arquivo permitida é o handoff mais recente. Domínios, planetas, satélites,
  PDFs, skills e memórias individuais ficam fora. Leitura extra exige pedido
  explícito do usuário.

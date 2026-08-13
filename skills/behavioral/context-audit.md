Context Audit

Objetivo: Diagnosticar e reduzir o volume de tokens consumidos automaticamente ao iniciar uma sessao de IA assistida, eliminando redundancia entre arquivos de configuracao.

Inspirado no artigo de andersonlimadev (TabNews, 2025). Complementa context-management.md (que foca em context rot durante a sessao — esta skill foca no setup inicial).

---

O PROBLEMA

Ferramentas como Claude Code, Cursor e Copilot carregam arquivos de contexto automaticamente ao iniciar cada sessao: CLAUDE.md, AGENTS.md, MEMORY.md, hooks, rules, etc.

Esses arquivos consomem tokens antes de qualquer prompt do usuario. Se nao forem auditados, acumulam redundancia e bloat silenciosamente.

Sintomas de contexto inicial inchado:
- Sessoes comecam lentas e consomem tokens caros sem necessidade
- Mesmo arquivos bem escritos se sobrepoe quando multiplos sao carregados juntos
- Hooks disparam leituras adicionais que multiplicam o consumo
- Documentacao de referencia e tratada como contexto operacional

---

DIAGNOSTICO — MEDIR ANTES

Antes de otimizar, medir o estado atual:

  1. Listar todos os arquivos carregados automaticamente por sessao
     - CLAUDE.md (raiz e .claude/)
     - AGENTS.md, MEMORY.md, CONVENTIONS.md
     - hooks.json e arquivos que os hooks referenciam
     - .cursorrules, .github/copilot-instructions.md
     - Skills registradas como auto-load

  2. Contar linhas totais
     wc -l de cada arquivo → soma = custo fixo por sessao

  3. Identificar sobreposicao
     Comparar conteudo entre arquivos. Perguntar para cada bloco:
     - Este conteudo aparece em mais de um arquivo?
     - Este conteudo e necessario em TODA sessao ou apenas em tarefas especificas?
     - Este conteudo e instrucao operacional ou documentacao de referencia?

---

AUDITORIA EM ARVORE DE REPOS ANINHADOS

Quando o repo auditado contem outros repositorios aninhados (submodules ou
pastas comuns), o custo de contexto por sessao nao termina nos arquivos do
proprio repo — pode incluir arquivos que fisicamente moram em um repo
filho, se o CLAUDE.md/AGENTS.md do pai mandar le-los.

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

CLASSIFICACAO DE CONTEUDO

Separar cada bloco de conteudo em uma de tres categorias:

  OPERACIONAL (deve carregar automaticamente):
  Instrucoes que a IA precisa seguir em toda sessao.
  Exemplos: convencoes de commit, stack do projeto, regras de seguranca, paths criticos.
  Caracteristica: curto, imperativo, sem explicacao detalhada.

  REFERENCIA (consultar sob demanda):
  Conteudo detalhado que so e relevante para tarefas especificas.
  Exemplos: guias completos de agents, checklists extensos, exemplos de codigo, patterns detalhados.
  Caracteristica: longo, explicativo, com exemplos.
  Acao: mover para arquivos separados, referenciar via path quando necessario.

  REDUNDANTE (eliminar):
  Conteudo que aparece em mais de um arquivo carregado automaticamente.
  Acao: manter em um unico lugar, remover dos demais.

---

ESTRATEGIA DE REDUCAO

  1. CLAUDE.md enxuto e autoritativo
     O CLAUDE.md principal deve conter apenas instrucoes operacionais.
     Formato ideal: linhas curtas, imperativas, sem exemplos longos.
     Meta: menos de 150 linhas para o arquivo principal.

  2. Referencia separada do contexto automatico
     Documentacao detalhada (guides, agents completos, patterns) deve existir
     em arquivos que NAO sao carregados automaticamente.
     A IA consulta esses arquivos quando a tarefa exige — nao em toda sessao.

  3. Hooks minimalistas
     Cada hook que dispara ao iniciar a sessao adiciona contexto.
     Auditar: o hook e necessario em toda sessao? Pode ser sob demanda?
     Remover hooks que apenas carregam mais contexto redundante.

  4. MEMORY.md consolidado
     Se o conteudo de MEMORY.md ja esta no CLAUDE.md, eliminar a duplicacao.
     MEMORY.md deve conter apenas decisoes e restricoes que nao cabem no CLAUDE.md.

---

EXEMPLO DE REDUCAO

  Antes (830 linhas de contexto automatico):
    CLAUDE.md raiz         → 116 linhas (convencoes + referencias a @AGENTS.md)
    AGENTS.md              → 713 linhas (guia completo com exemplos e checklists)
    MEMORY.md              → 70 linhas (decisoes, parcialmente duplicado com CLAUDE.md)
    hooks.json             → 5 hooks disparando leituras adicionais

  Diagnostico:
    AGENTS.md: 80% do conteudo e referencia, nao operacional
    MEMORY.md: 60% duplica conteudo do CLAUDE.md
    3 dos 5 hooks sao redundantes

  Depois (135 linhas de contexto automatico):
    CLAUDE.md unico        → 135 linhas (operacional puro)
    AGENTS.md              → mantido como referencia (nao carregado automaticamente)
    MEMORY.md              → eliminado (conteudo util absorvido pelo CLAUDE.md)
    hooks.json             → 2 hooks essenciais

  Resultado: ~84% de reducao em tokens por sessao.

---

TECNICAS DE CONSOLIDACAO (depois de diagnosticar)

  1. Eliminar duplicacao entre arquivos:
     Escolher UM arquivo como fonte de verdade para cada informacao. CLAUDE.md: resumo
     conciso + referencias. AGENTS.md/docs detalhados: conteudo extenso sob demanda.

  2. Converter conteudo extenso em referencia:
     Antes (carregado automaticamente, 50 linhas):
       Convencoes de commits:
       - Use conventional commits
       - feat: nova funcionalidade
       - fix: correcao de bug
       - [... mais 40 linhas de exemplos ...]

     Depois (carregado automaticamente, 2 linhas):
       Commits: conventional commits. Ver skills/git/commit-conventions.md

  3. Mover exemplos de codigo para arquivos de referencia:
     CLAUDE.md nao precisa de code snippets — a IA sabe gerar codigo. Exemplos extensos
     ficam nos arquivos de skills/agents, consultados quando necessario.

  4. Comprimir informacao sem perder significado:
     Antes (5 linhas): "O projeto usa TypeScript com strict mode habilitado. Todas as
     funcoes devem ter tipos explicitos. Interfaces devem ser preferidas a types quando
     possivel. Enums devem usar string values. Generics devem ter nomes descritivos."

     Depois (1 linha): "TypeScript strict. Tipos explicitos, interfaces > types, enums
     com strings, generics descritivos."

---

OTIMIZACAO DE HOOKS

Hooks executam em toda chamada de ferramenta e tambem consomem tokens:

- [ ] Cada hook tem um proposito claro e nao duplica o que ja esta no CLAUDE.md
- [ ] Hooks que apenas lembram regras ja documentadas podem ser removidos
- [ ] Preferir hooks que executam acoes (lint, format) a hooks que apenas imprimem avisos
- [ ] Consolidar hooks redundantes em um unico hook quando possivel

---

MEMORY.MD — MANTER ENXUTO

MEMORY.md cresce organicamente e acumula informacao obsoleta:

- [ ] Revisar periodicamente e remover entradas que ja estao cobertas pelo CLAUDE.md
- [ ] Remover entradas temporarias que nao sao mais relevantes
- [ ] Mover informacoes permanentes para CLAUDE.md (e comprimir)
- [ ] Manter apenas anotacoes especificas da sessao ou decisoes recentes

---

COMO MEDIR O RESULTADO

Apos otimizar, compare:

  Metrica          | Antes | Depois
  Linhas auto      | ___   | ___
  % reducao        | -     | ___%
  Arquivos auto    | ___   | ___

Meta: reducao de 50%+ nas linhas carregadas automaticamente.
Resultado tipico: 70-85% de reducao quando AGENTS.md extenso e convertido em referencia.

---

CHECKLIST DE AUDITORIA

- [ ] Listar todos os arquivos carregados automaticamente ao iniciar sessao
- [ ] Contar linhas totais (custo fixo por sessao em tokens)
- [ ] Identificar blocos duplicados entre arquivos
- [ ] Classificar cada bloco: operacional, referencia ou redundante
- [ ] Mover conteudo de referencia para arquivos consultaveis sob demanda
- [ ] Eliminar duplicacoes entre arquivos
- [ ] Reduzir hooks ao minimo necessario
- [ ] Medir linhas totais apos otimizacao
- [ ] Validar que a IA ainda tem acesso ao conteudo de referencia quando requisitado
- [ ] Repetir auditoria periodicamente (a cada 2-4 semanas) conforme o projeto evolui
- [ ] Repos aninhados (submodule ou pasta) tem arquivos referenciados como leitura obrigatoria pelo CLAUDE.md/AGENTS.md do repo pai? Se sim, o tamanho desses arquivos entra na soma do custo fixo por sessao, independente de em qual repositorio residem fisicamente.

---

REFERENCIA

- context-management.md: gerenciamento de contexto durante a sessao
- ai-integration-patterns.md: custos e limites de tokens em chamadas de API
- model-routing.md: escolha do modelo certo para cada tarefa (economia complementar)

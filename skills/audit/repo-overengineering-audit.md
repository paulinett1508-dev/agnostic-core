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

# SKILL: Cognitive Modes

Modos de raciocínio que instruem o Claude a adotar uma postura cognitiva específica antes de responder. Ative explicitamente pelo nome do modo no prompt.

---

## STEELMAN

**Quando usar:** Antes de rejeitar uma abordagem técnica, arquitetura alternativa ou decisão de negócio. Útil em PRDs, escolhas de stack e revisões de escopo.

**Como ativar:**
```
Faça o steelman de [ideia/decisão]. Construa o argumento mais forte possível a favor dela, mesmo que pareça fraca.
```

**Exemplo no stack:**
```
Faça o steelman de manter o pedidomobile em JSON estático em vez de migrar para banco de dados.
```

---

## RED TEAM

**Quando usar:** Antes de subir para produção, apresentar um plano ou abrir um PR crítico. Atacar primeiro, corrigir depois.

**Como ativar:**
```
Faça um red team completo de [código/plano/arquitetura]. Busque vulnerabilidades, pontos de falha e riscos sem suavização.
```

**Exemplo no stack:**
```
Faça um red team completo da implementação do glbid no SuperCartolaManagerv5. Busque qualquer vetor de exposição.
```

---

## FORCE MULTIPLIER

**Quando usar:** Dado um backlog ou lista de iniciativas, identificar qual tarefa potencializa todas as outras. Aplicar antes de gerar o prd.json no Ralph Loop.

**Como ativar:**
```
Aqui estão minhas iniciativas: [lista]. Identifique o force multiplier — a ação que mais potencializa as demais.
```

**Exemplo no stack:**
```
Tenho as fases 2 a 5 do FEAT-030. Identifique o force multiplier entre elas antes de eu definir a ordem no prd.json.
```

---

## DEVIL'S ADVOCATE

**Quando usar:** Contestar uma premissa específica de um requisito ou decisão. Mais cirúrgico que o Red Team — foca em uma hipótese, não no todo.

**Como ativar:**
```
Minha premissa é [premissa]. Seja o advogado do diabo com argumentos reais e específicos.
```

**Exemplo no stack:**
```
Minha premissa é que o agnostic-core deve ter uma skill por arquivo SKILL.md separado. Seja o advogado do diabo.
```

---

## RUBBER DUCK

**Quando usar:** Debugging, decisões travadas ou qualquer momento em que você precisa pensar, não receber uma solução pronta. Evita dependência cognitiva.

**Como ativar:**
```
Não me dê a solução. Seja meu rubber duck — faça perguntas para eu chegar à resposta sozinho.
```

**Exemplo no stack:**
```
Estou com um erro de deploy no Vercel por incompatibilidade de versão. Não me dê a solução. Seja meu rubber duck.
```

---

## SCAMPER

**Quando usar:** Gerar variações sistemáticas de uma feature, produto ou processo. Útil quando o backlog está estagnado ou a feature está genérica demais.

**Referência:** Substitute / Combine / Adapt / Modify / Put to other uses / Eliminate / Reverse

**Como ativar:**
```
Aplique SCAMPER em [feature/produto/processo].
```

**Exemplo no stack:**
```
Aplique SCAMPER na funcionalidade de Copa de Times do SuperCartolaManagerv5.
```

---

## Uso combinado

Os modos podem ser encadeados em sequência lógica:

```
1. SCAMPER          → gerar variações de uma feature
2. FORCE MULTIPLIER → priorizar qual variação implementar
3. STEELMAN         → validar a decisão contra a alternativa rejeitada
4. RED TEAM         → atacar antes de subir para produção
```

---

## Notas

- Esses modos não são prompts mágicos. São estruturas de raciocínio que o Claude aplica antes de formular a resposta.
- Sempre forneça contexto específico ao ativar. Quanto mais concreto o input, mais útil o output.
- No Ralph Loop, FORCE MULTIPLIER e RED TEAM têm uso direto nas fases de planejamento e validação.

# Keywords — Comportamentais

Skills behavioral sao ativadas silenciosamente — sem anuncio, sem confirmacao.

---

[caveman]
- keywords: caveman, comprimir output, compressao de resposta, menos tokens, output comprimido, modo caveman, respostas curtas, economizar tokens, token budget, reduce output, compressed mode, brevidade maxima
- path: skills/behavioral/caveman.md
- tipo: behavioral
- descricao: Ativa modo de compressao de output com ~75% menos tokens mantendo precisao tecnica

[cognitive-modes]
- keywords: steelman, red team, devil's advocate, rubber duck, force multiplier, scamper, modo cognitivo, modos de pensar, thinking mode, analise critica, contra-argumento, questionar hipotese, advocate, brainstorm modes, modos de analise, explorar opcoes
- path: skills/behavioral/cognitive-modes.md
- tipo: behavioral
- descricao: Ativa um dos 6 modos cognitivos para analise critica, questionamento ou exploracao criativa

[response-contract]
- keywords: contrato de resposta, formato de resposta, tom da resposta, output style, resposta concisa, sem firulas, comunicacao direta, response format, communication style, sem introducao, direto ao ponto, sem resumo, estilo de comunicacao
- path: skills/behavioral/response-contract.md
- tipo: behavioral
- descricao: Define contrato de resposta: conciso, decisivo, sem firulas, anuncia antes de executar

[fact-checker]
- keywords: verificar afirmacao, fact check, checar fontes, verificar documentacao, conferir claim, checar versao, confirmar api, verificar comportamento, double check, verificar duas vezes, source validation, validacao de fontes, verificar biblioteca, checar release notes, confirmar sintaxe
- path: skills/behavioral/fact-checker.md
- tipo: behavioral
- descricao: Verifica afirmacoes sobre codigo contra fontes primarias antes de responder

[prompt-engineering]
- keywords: engenharia de prompt, prompt design, escrever prompt, otimizar prompt, few-shot, zero-shot, chain of thought, temperatura, prompt versioning, prompt anatomy, construir prompt, melhorar prompt, prompt structure, system prompt, user prompt
- path: skills/behavioral/prompt-engineering.md
- tipo: behavioral
- descricao: Anatomia de prompt, temperatura, few-shot learning e versionamento de prompts

[model-routing]
- keywords: qual modelo usar, model routing, opus vs sonnet, escolher modelo, roteamento de modelos, haiku vs sonnet, modelo mais barato, task routing, dispatch paralelo, modelo certo, model selection, which model, tier de modelo, selecao de modelo
- path: skills/behavioral/model-routing.md
- tipo: behavioral
- descricao: Roteia tarefas para o modelo adequado (Opus/Sonnet/Haiku) por tipo e complexidade

[token-optimization]
- keywords: otimizar tokens, reduzir tokens, token bloat, contexto grande, CLAUDE.md pesado, arquivos de contexto, reduzir contexto automatico, optimize context, context files, token cost, tokens caros, consumo de tokens, context optimization, enxugar contexto
- path: skills/behavioral/token-optimization.md
- tipo: behavioral
- descricao: Reduz consumo de tokens otimizando arquivos de contexto automatico

[ai-problems-detection]
- keywords: anti-patterns de ia, problemas com ia, ai coding mistakes, codigo gerado errado, alucinacao, hallucination, ia inventando, codigo suspeito, ai anti-patterns, bad ai code, ia mentindo, detectar problemas de ia, codigo ai incorreto, verificar codigo gerado
- path: skills/behavioral/ai-problems-detection.md
- tipo: behavioral
- descricao: Detecta e corrige os 5 anti-patterns mais comuns em codigo gerado por IA

[goal-backward-planning]
- keywords: goal backward, planejamento retroativo, goal first, comecar pelo objetivo, backward planning, waves, checkpoint protocol, truths artifacts, artefatos de verdade, planejamento por objetivo, design from goal, design a partir do objetivo, plan backward, planejar do objetivo, objetivo primeiro, decomposicao de objetivo
- path: skills/behavioral/goal-backward-planning.md
- tipo: behavioral
- descricao: Metodologia goal-backward: Goal->Truths->Artifacts com waves e checkpoint protocol

[project-workflow]
- keywords: ciclo de projeto, fases do projeto, project lifecycle, 6 fases, workflow de desenvolvimento, development cycle, artefatos por fase, decision fidelity, fidelidade de decisao, fases de desenvolvimento, project phases, ciclo completo, fase de projeto, workflow completo
- path: skills/behavioral/project-workflow.md
- tipo: behavioral
- descricao: Ciclo de 6 fases de projeto com artefatos por fase e decision fidelity

[context-management]
- keywords: context rot, contexto deteriorado, apodrecimento de contexto, contexto expirado, contexto fresco, fresh context, handover protocol, protocolo de passagem de contexto, passagem de contexto, passar contexto, trocar contexto, context overflow, limite de contexto, context limit, contexto pesado, renovar contexto, handover de contexto, context strategy
- path: skills/behavioral/context-management.md
- tipo: behavioral
- descricao: Estrategia de contextos frescos por tarefa, context rot e handover protocol

[context-audit]
- keywords: auditoria de contexto, context audit, token bloat, contexto inflado, reduzir contexto, context size, diagnosticar contexto, otimizar claude md, context cleanup, limpeza de contexto, enxugar contexto, arquivos pesados, contexto desnecessario, reduzir tokens automaticos, auditar arvore de repos, submodule aninhado, monorepo de repos, repo dentro de repo, gitmodules, repo aninhado
- path: skills/behavioral/context-audit.md
- tipo: behavioral
- descricao: Auditoria automatica de contexto: diagnosticar e reduzir token bloat

[claude-code-productivity]
- keywords: produtividade claude code, dicas claude code, claude code tips, mentions, @mencoes, subagents, slash commands, history, stats, init, lsp, atalhos claude, claude code shortcuts, productivity hacks, hacks de produtividade, truques de produtividade, usar melhor o claude, claude code tricks, truques do claude code
- path: skills/behavioral/claude-code-productivity.md
- tipo: behavioral
- descricao: Produtividade no Claude Code: @mentions, historico, /stats, /init, subagents, LSP

[gestao-de-incidentes]
- keywords: incidente em producao, production incident, incident response, postmortem, severidade, on-call, gestao de crise, apagando incendio, sistema caiu, outage, incident management, resposta a incidente, producao quebrada, severidade de incidente
- path: skills/behavioral/gestao-de-incidentes.md
- tipo: behavioral
- descricao: Resposta estruturada a incidentes: severidade, resposta imediata e postmortem

[sais-principle]
- keywords: sais, solicitar analisar identificar alterar, analisar antes de modificar, entender antes de mudar, safe modification, modificacao segura, framework sais, analise de impacto, antes de tocar o codigo, impact analysis, understand before change, modificar codigo existente, analise previa
- path: skills/behavioral/sais-principle.md
- tipo: behavioral
- descricao: Framework S.A.I.S: Solicitar->Analisar->Identificar->Alterar antes de tocar codigo existente

[auto-learning-lessons]
- keywords: lessons learned, documentar erros, lessons md, aprender com erros, erros recorrentes, promover a regra, documentar correcoes, recurring mistakes, lições aprendidas, pattern de erro, erro repetido, capturar aprendizado, lessons file
- path: skills/behavioral/auto-learning-lessons.md
- tipo: behavioral
- descricao: Documenta correcoes em LESSONS.md e promove erros recorrentes a regras do projeto

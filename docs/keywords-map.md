Keywords Map — agnostic-core

Roteador de auto-invocacao de skills.
Quando uma keyword for detectada na conversa — mesmo que mencionada despretensiosamente —
a skill correspondente deve ser invocada conforme o protocolo definido abaixo.

---

PROTOCOLO DE INVOCACAO

Skills tecnicas (requerem confirmacao)
Antes de executar qualquer skill tecnica, entre em modo plan e informe:
  Skill identificada: [nome da skill]
  O que ela faz: [descricao objetiva do que sera feito]
  O que vai ser afetado: [escopo no codebase — arquivos, modulos, camadas]
  Confirma o uso desta skill? (s/n)

Se multiplas skills forem ativadas pelo mesmo contexto:
- Apresente uma a uma
- Aguarde confirmacao individual antes de passar para a proxima
- So execute apos todas confirmadas

Skills comportamentais (auto-invoke, sem confirmacao)
Skills da categoria behavioral sao ativadas silenciosamente.
Nenhuma notificacao, nenhuma pergunta. Apenas execute.

---

MAPA DE KEYWORDS

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
- keywords: auditoria de contexto, context audit, token bloat, contexto inflado, reduzir contexto, context size, diagnosticar contexto, otimizar claude md, context cleanup, limpeza de contexto, enxugar contexto, arquivos pesados, contexto desnecessario, reduzir tokens automaticos
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

---

SKILLS TECNICAS — KEYWORDS

Skills tecnicas requerem confirmacao antes de executar (ver protocolo acima).

--- Auditoria e Qualidade ---

[modular-audit-system]
- keywords: sistema de auditoria modular, dry audit, auditar modulo, auditoria de modulo, modular audit, auditoria sem duplicacao, orquestrador de auditoria, regras de auditoria, rules de auditoria, audit rules, registry de modulos, modules registry, auditoria escalavel, audit orchestrator
- path: skills/audit/modular-audit-system.md
- tipo: tecnica
- descricao: Padrao DRY de auditoria: skill orquestradora + rules files por dominio + registry JSON para escalar sem duplicacao

[code-review]
- keywords: audite, auditar, revisar codigo, revisao de codigo, code review, rever o codigo, olhar o codigo, checar o codigo, dar uma olhada no codigo, passar o pente fino, review antes de mergear, revisao antes do pr, auditar pr, auditar diff
- path: skills/audit/code-review.md
- tipo: tecnica
- descricao: Checklist de revisao de codigo por categoria (logica, seguranca, performance, testes, legibilidade)

[systematic-debugging]
- keywords: debugar, depurar, investigar bug, nao consigo achar o bug, bug estranho, comportamento inesperado, erro que nao faz sentido, rastrear erro, investigar problema, bug hunting, caca ao bug, cacada de bugs, nao entendo o erro, reproduzir bug, isolar problema
- path: skills/audit/systematic-debugging.md
- tipo: tecnica
- descricao: Debugging em 4 fases: reproduzir, isolar, entender, corrigir

[refactoring]
- keywords: refatorar, refactoring, limpar codigo, codigo sujo, divida tecnica, technical debt, reorganizar codigo, reestruturar, simplificar codigo, codigo legado, melhorar estrutura, refactor seguro, codigo confuso
- path: skills/audit/refactoring.md
- tipo: tecnica
- descricao: 7 fases de decomposicao segura com plano incremental

[pre-implementation]
- keywords: antes de implementar, pre-implementation, verificar antes de codar, ja existe isso, duplicacao, solucao mais simples, yagni, checar antes, procurar antes de criar, existe algo parecido, verificar duplicidade, nao reinventar a roda
- path: skills/audit/pre-implementation.md
- tipo: tecnica
- descricao: Verificacao pre-implementacao: duplicacao de codigo e solucao mais simples

[validation-checklist]
- keywords: checklist de validacao, validar implementacao, quick check, full check, verificacao completa, avaliacao completa, validacao rapida, verificar entregavel, pronto para review, ready to review, validar antes de enviar, checklist final
- path: skills/audit/validation-checklist.md
- tipo: tecnica
- descricao: Checklist consolidado de validacao: quick check e full assessment

[revisao-texto-ptbr]
- keywords: revisar texto, revisao de texto, ortografia, concordancia, acentuacao, texto em portugues, revisar conteudo, corrigir texto, erro de portugues, copy review, ptbr review, texto errado, revisar copia
- path: skills/audit/revisao-texto-ptbr.md
- tipo: tecnica
- descricao: Revisao de textos PT-BR: ortografia, concordancia, acentuacao e consistencia factual

[post-implementation-conformity]
- keywords: conformidade pos implementacao, codigo vs documentacao, consistencia cruzada, codigo igual a spec, implementacao conforme, codigo bate com docs, auditoria de conformidade, implementation matches spec, codigo conforme requisito
- path: skills/audit/post-implementation-conformity.md
- tipo: tecnica
- descricao: Auditoria de consistencia cruzada: codigo vs documentacao vs regras do projeto

[refactor-monolith]
- keywords: refatorar monolito, decomposicao de monolito, quebrar monolito, extrair modulo, separar responsabilidades, modularizar, decompor sistema, monolito para servicos, strangler fig, sistema legado modular
- path: skills/audit/refactor-monolith.md
- tipo: tecnica
- descricao: Decomposicao segura de monolito: incremental e sem interromper producao

[detect-hardcodes]
- keywords: hardcode, valor hardcoded, constante magica, magic number, magic string, valor fixo no codigo, credencial hardcoded, url hardcoded, detectar hardcode, remover hardcode, checar hardcodes, variavel de ambiente
- path: skills/audit/detect-hardcodes.md
- tipo: tecnica
- descricao: Identificar e classificar valores hardcoded no codigo-fonte

[senior-verification-protocol]
- keywords: senior aprovaria, senior review, regra dos 3 arquivos, pausa de elegancia, senior would approve, diff elegante, qualidade de senior, revisao senior, production ready, pronto para producao, codigo production-ready, um senior aprovaria isso
- path: skills/audit/senior-verification-protocol.md
- tipo: tecnica
- descricao: "Um senior engineer aprovaria esse diff?" + regra dos 3 arquivos para pausa de elegancia

--- Seguranca ---

[security-review]
- keywords: auditar seguranca, security audit, revisar seguranca, checar vulnerabilidades, tem vulnerabilidade, codigo seguro, verificar seguranca, security check, checagem de seguranca, possiveis brechas, checar autenticacao, revisar permissoes
- path: skills/security/security-review.md
- tipo: tecnica
- descricao: Revisao de seguranca diff-aware com filtragem de falsos positivos

[api-hardening]
- keywords: hardening de endpoint, proteger api, seguranca de api, api security, autenticacao de endpoint, headers de seguranca, rate limiting, input validation, cors, api protection, endpoint seguro, validacao de entrada, proteger rota
- path: skills/security/api-hardening.md
- tipo: tecnica
- descricao: Hardening de endpoints REST: autenticacao, security headers, rate limiting e validacao de input

[owasp-checklist]
- keywords: owasp, top 10, vulnerabilidades web, xss, sql injection, injection attack, broken auth, csrf, insecure deserialization, checklist de vulnerabilidades, categorias owasp, verificar owasp, owasp top ten
- path: skills/security/owasp-checklist.md
- tipo: tecnica
- descricao: OWASP Top 10 com checklist por categoria e exemplos de correcao

[penetration-testing]
- keywords: pentest, teste de penetracao, ethical hacking, vulnerability assessment, teste de invasao, teste de seguranca ofensivo, explorar vulnerabilidade, recon, teste de intrusao, pen test, ptes, ethical hacker
- path: skills/security/penetration-testing.md
- tipo: tecnica
- descricao: Metodologia de pentest: PTES, OWASP ofensivo e priorizacao de vulnerabilidades

[politica-de-seguranca]
- keywords: politica de seguranca, security policy, governanca de seguranca, diretrizes de seguranca, regras de seguranca do projeto, security guidelines, compliance de seguranca, normas de seguranca, framework de seguranca
- path: skills/security/politica-de-seguranca.md
- tipo: tecnica
- descricao: Politica de seguranca: diretrizes, governanca e principios para projetos seguros

--- Performance ---

[performance-audit]
- keywords: performance, lento, otimizar performance, aplicacao lenta, n+1, query lenta, gargalo, bottleneck, latencia alta, tempo de resposta alto, render lento, otimizar consulta, performance audit
- path: skills/performance/performance-audit.md
- tipo: tecnica
- descricao: N+1 queries, indices, caching e render blocking — auditoria completa de performance

[caching-strategies]
- keywords: cache, estrategia de cache, redis, cache-aside, ttl, invalidacao de cache, cache em camadas, l1 l2 l3, cache key, cache hit, cache miss, caching layer, memoizacao, implementar cache
- path: skills/performance/caching-strategies.md
- tipo: tecnica
- descricao: Camadas L1-L3, cache-aside, TTL, invalidacao e Redis keys

[load-testing]
- keywords: teste de carga, load test, stress test, performance test, k6, artillery, sla, p95, p99, throughput, rps, concorrencia, latencia sob carga, capacidade do sistema, testes de performance
- path: skills/performance/load-testing.md
- tipo: tecnica
- descricao: Tipos de teste de carga, SLA (p95/p99), k6/Artillery e analise de resultados

[estrategias-de-cache]
- keywords: ideias de cache, quando usar cache, tipo de cache, escolher estrategia de cache, cache por problema, cache read-heavy, write-through, write-behind, read-through, cache tradeoffs, cache strategy ideas, decidir estrategia
- path: skills/cache/estrategias-de-cache.md
- tipo: tecnica
- descricao: Ideias de cache por tipo de problema: estrategias e trade-offs

--- Testes ---

[unit-testing]
- keywords: teste unitario, unit test, cobertura de testes, coverage, mocking, mock, stub, spy, padrao aaa, arrange act assert, jest, vitest, pytest, escrever testes, testar funcao, teste isolado
- path: skills/testing/unit-testing.md
- tipo: tecnica
- descricao: Padrao AAA, cobertura 80%, mocking e casos de borda para testes unitarios

[integration-testing]
- keywords: teste de integracao, integration test, banco de dados nos testes, api test, contract testing, consumer driven, teste de api, banco isolado, seed de dados, fixtures, supertest, testes de integracao
- path: skills/testing/integration-testing.md
- tipo: tecnica
- descricao: Banco isolado, testes de API, contract testing e gerenciamento de dados de teste

[tdd-workflow]
- keywords: tdd, test driven development, red green refactor, escrever teste primeiro, test first, ciclo tdd, desenvolvimento orientado a testes, tdd workflow, teste antes de implementar, tdd na pratica
- path: skills/testing/tdd-workflow.md
- tipo: tecnica
- descricao: Ciclo Red-Green-Refactor, quando aplicar TDD, comportamentos vs linhas de codigo

[e2e-testing]
- keywords: teste e2e, end to end, playwright, cypress, teste de ponta a ponta, page object model, pom, teste de ui, browser testing, testes de aceitacao, testes funcionais, automatizar testes de interface
- path: skills/testing/e2e-testing.md
- tipo: tecnica
- descricao: Piramide E2E, Page Object Model, Playwright/Cypress e integracao com CI

--- Frontend ---

[html-css-audit]
- keywords: auditar html, auditar css, html semantico, qualidade de css, auditoria de frontend, checar html, revisar css, estrutura html, semantica html, html review, css review, markup review
- path: skills/frontend/html-css-audit.md
- tipo: tecnica
- descricao: Auditoria semantica de HTML, qualidade CSS e acessibilidade basica

[css-governance]
- keywords: governanca de css, css global, variaveis css, escopo de css, css leak, seletor global, css poluindo, custom properties, css architecture, design tokens, css scope, prevencao css global
- path: skills/frontend/css-governance.md
- tipo: tecnica
- descricao: Variaveis CSS, escopo de seletores e prevencao de poluicao CSS global

[accessibility]
- keywords: acessibilidade, wcag, a11y, contraste, teclado, aria, screen reader, leitor de tela, aria labels, focus, tab order, color contrast, acessivel, accessibility check, wcag 2.1, alto contraste
- path: skills/frontend/accessibility.md
- tipo: tecnica
- descricao: WCAG 2.1 AA: contraste, navegacao por teclado, ARIA, formularios e motion

[ux-guidelines]
- keywords: ux, experiencia do usuario, user experience, ux audit, guidelines de ux, boas praticas de ux, auditoria ux, ux checklist, checklist de ux, usabilidade, usability, ux review, revisao de ux, melhorar ux, feedback visual, microinteracoes
- path: skills/frontend/ux-guidelines.md
- tipo: tecnica
- descricao: 17 categorias UX com severidade por item (adaptadas de ui-ux-pro)

[tailwind-patterns]
- keywords: tailwind, tailwind css, tailwind v4, configuracao tailwind, tailwind config, css-first, dark mode tailwind, tailwind utilities, tailwind patterns, tailwind setup, tailwind classes, tailwind theme
- path: skills/frontend/tailwind-patterns.md
- tipo: tecnica
- descricao: Tailwind CSS v4: configuracao CSS-first, responsivo, dark mode e sistemas de cor

[react-performance]
- keywords: performance react, react lento, re-render desnecessario, otimizar react, react optimization, memo, usecallback, usememo, bundle size, code splitting, react profiler, lazy loading, ssr react, waterfall react
- path: skills/frontend/react-performance.md
- tipo: tecnica
- descricao: 58 regras de performance React: waterfalls, bundle, SSR e re-renders

[seo-checklist]
- keywords: seo, search engine optimization, core web vitals, lcp, cls, fid, meta tags, schema markup, sitemap, robots txt, seo tecnico, e-e-a-t, google search, ranking, indexacao, seo audit
- path: skills/frontend/seo-checklist.md
- tipo: tecnica
- descricao: SEO tecnico, Core Web Vitals, E-E-A-T, Schema Markup e GEO

[internacionalizacao]
- keywords: i18n, internacionalizacao, traducao, locale, multi-idioma, rtl, pluralizacao, formatacao de data por locale, string externalization, multilingual, multilingue, localization, localizacao de software, l10n, idioma, translation
- path: skills/frontend/internacionalizacao.md
- tipo: tecnica
- descricao: i18n: externalizacao de strings, formatacao por locale, suporte RTL e pseudo-localizacao

[anti-frankenstein]
- keywords: css frankenstein, css bagunca, css inconsistente, mistura de estilos, css desorganizado, anti-frankenstein, css antes do pr, checkpoint css, rever css antes de mergear, css review css quebrado
- path: skills/frontend/anti-frankenstein.md
- tipo: tecnica
- descricao: Checkpoint de governanca CSS para evitar CSS Frankenstein antes do PR

[react-task-checklists]
- keywords: checklist react, react checklist, tarefa react, componente novo react, data fetching react, estado react, rota react, tipos typescript react, testes react, checklist por tipo de tarefa react
- path: skills/frontend/react-task-checklists.md
- tipo: tecnica
- descricao: Checklists React por tipo de tarefa: CSS, componente, data fetching, estado, tipos, rotas, testes

[dark-mode-tokens]
- keywords: dark mode, modo escuro, tema escuro, light dark, next-themes, tokens de cor, css custom properties dark, dark theme, modo noturno, color tokens, dark mode tokens, implementar dark mode
- path: skills/frontend/dark-mode-tokens.md
- tipo: tecnica
- descricao: Dark mode com CSS custom properties: tokens light/dark e implementacao next-themes

[responsive-breakpoint-table]
- keywords: responsivo, breakpoints, mobile first, desktop first, regras por breakpoint, tabela responsiva, responsive design, viewport, comportamento mobile, comportamento desktop, media query, layout responsivo
- path: skills/frontend/responsive-breakpoint-table.md
- tipo: tecnica
- descricao: Tabela de responsividade por componente com regras explicitas mobile vs desktop

[menos-e-mais]
- keywords: menos e mais, menos is more, poluicao visual, interface poluida, reduzir elementos, hierarquia visual, whitespace, espacamento, remover ruido visual, auditoria visual, simplificar interface, ui limpa, clean design
- path: skills/frontend/menos-e-mais.md
- tipo: tecnica
- descricao: Protocolo de auditoria visual: reduzir poluicao, melhorar hierarquia e whitespace

[pwa-offline-patterns]
- keywords: pwa, progressive web app, service worker, offline, cache shell, manifest, instalavel, funciona sem internet, app offline, web app instalavel, push notification, workbox, cache strategy pwa
- path: skills/frontend/pwa-offline-patterns.md
- tipo: tecnica
- descricao: Service worker, cache de shell, dados sensiveis e manifest.json para PWAs

--- UX/UI ---

[principios-de-interface]
- keywords: principios de interface, hierarquia visual, tipografia, cores de interface, estados de interface, design de interface, ui design, interface design, boas praticas de interface, teoria de cor, espacamento, grid de interface
- path: skills/ux-ui/principios-de-interface.md
- tipo: tecnica
- descricao: Hierarquia visual, tipografia, cores, responsividade e estados de interface

[ui-ux-quality-gates]
- keywords: quality gates frontend, gates de qualidade, entrega de interface, checklist de entrega, ui entregavel, criterios de qualidade ui, frontend pronto, ready to ship frontend, aprovacao de interface, qualidade de frontend
- path: skills/ux-ui/ui-ux-quality-gates.md
- tipo: tecnica
- descricao: 5 quality gates obrigatorios para entrega de interface frontend

[navegacao-sem-redundancia]
- keywords: navegacao, nav sem redundancia, hierarquia de navegacao, menu, sidebar, breadcrumb, acesso direto, redundancia de nav, navegacao confusa, estrutura de menu, navigation design, nav patterns
- path: skills/ux-ui/navegacao-sem-redundancia.md
- tipo: tecnica
- descricao: Padroes de navegacao sem redundancia: hierarquia, acesso direto e consistencia

--- Design ---

[paper-mcp-workflow]
- keywords: paper mcp, design no paper, criar wireframe, wireframe claude, paper tool, design tool mcp, ferramenta de design mcp, criar mockup, fluxo paper, design antes de codar, wireframe primeiro, design system paper, paper figma
- path: skills/design/paper-mcp-workflow.md
- tipo: tecnica
- descricao: Fluxo bidirecional Paper MCP: criar designs no Paper e implementar frontend a partir deles

[nano-banana-canva-workflow]
- keywords: nano banana, canva mcp, gerar imagem, editar imagem, imagem com ia, canva claude, canva workflow, nano banana canva, criar banner, editar foto, canva integration, geracao de imagem, imagem de produto
- path: skills/design/nano-banana-claude-workflow.md
- tipo: tecnica
- descricao: Claude Code + Nano Banana + Canva MCP: geracao e edicao de imagens com separacao de camadas

[visual-baseline]
- keywords: baseline visual, camadas visuais, imagens do projeto, tipografia do projeto, icones do projeto, projeto profissional, visual profissional, polish visual, polimento visual, acabamento visual, camada de imagem, camada de tipografia, aparencia profissional
- path: skills/design/visual-baseline.md
- tipo: tecnica
- descricao: 3 camadas visuais (imagem, tipografia, icones) que separam projetos funcionais de profissionais

[design-system]
- keywords: design system, sistema de design, biblioteca de componentes, component library, tokens de design, design tokens, planejar design system, criar design system, atomic design, figma tokens, storybook, componentes reutilizaveis
- path: skills/design-system/SKILL.md
- tipo: tecnica
- descricao: Planejamento colaborativo de design system antes de execucao visual

--- Backend ---

[rest-api-design]
- keywords: rest api, design de api, nomenclatura de endpoint, http methods, status code, paginacao de api, versionamento de api, rest design, api contract, contrato de api, resource naming, restful, api padrao, endpoint design, api review, revisao de api
- path: skills/backend/rest-api-design.md
- tipo: tecnica
- descricao: Nomenclatura REST, HTTP methods, status codes, paginacao e versionamento

[error-handling]
- keywords: tratamento de erro, error handling, hierarquia de erros, middleware de erro, log de erro, centralizar erros, error middleware, capturar excecao, exception handling, error boundary, try catch, erros nao tratados
- path: skills/backend/error-handling.md
- tipo: tecnica
- descricao: Hierarquia de erros, middleware centralizado e estrategia log vs expor

[financial-operations]
- keywords: operacoes financeiras, transacao financeira, idempotencia, atomicidade, trilha de auditoria, transacao segura, pagamento, financial transaction, audit trail, two-phase commit, saga pattern, operacoes monetarias
- path: skills/backend/financial-operations.md
- tipo: tecnica
- descricao: Idempotencia, atomicidade e trilha de auditoria em operacoes financeiras

[domain-driven-design]
- keywords: ddd, domain driven design, bounded context, aggregate, domain event, ubiquitous language, linguagem ubiqua, entidade de dominio, value object, repositorio ddd, servico de dominio, modelagem de dominio
- path: skills/backend/domain-driven-design.md
- tipo: tecnica
- descricao: DDD: bounded contexts, aggregates, domain events e linguagem ubiqua

[event-sourcing]
- keywords: event sourcing, cqrs, eventos imutaveis, event store, projection, replay de eventos, event driven, orientado a eventos, command query, read model, modelo de leitura, write model, modelo de escrita, event log, audit log completo, cqrs pattern
- path: skills/backend/event-sourcing.md
- tipo: tecnica
- descricao: Event Sourcing e CQRS: eventos imutaveis, projections e versionamento

[estrategias-de-migracao]
- keywords: migracao, strangler fig, parallel run, execucao paralela, rodar em paralelo, branch by abstraction, migracao de sistema, migrar para novo sistema, reescrever sistema, modernizacao, legacy migration, big bang migration, migracao big bang, incrementar migracao
- path: skills/backend/estrategias-de-migracao.md
- tipo: tecnica
- descricao: Strangler Fig, Parallel Run, Branch by Abstraction e migracao de dados

[cdn-asset-validation]
- keywords: cdn, soft 404, asset nao carrega, imagem nao carrega, arquivo cdn com erro, validar cdn, checar cdn, asset vazio, http 200 corpo vazio, recurso cdn quebrado, broken asset, cdn check
- path: skills/backend/cdn-asset-validation.md
- tipo: tecnica
- descricao: Detectar soft-404 em CDNs externas (HTTP 200 com corpo vazio) via curl

--- Banco de Dados ---

[query-compliance]
- keywords: query segura, sql seguro, query compliance, transaction, indice de banco, migration segura, query review, banco de dados seguro, sql review, orm query, transacao atomica, indices, database compliance, conformidade de banco de dados, seguranca de banco de dados
- path: skills/database/query-compliance.md
- tipo: tecnica
- descricao: Queries seguras, indices, transacoes e migrations com compliance

[schema-design]
- keywords: schema design, design de banco, normalizacao, modelo de dados, erd, entity relationship, selecao de orm, indices de banco, migracao de schema, schema seguro, database design, modelagem de banco, foreign key
- path: skills/database/schema-design.md
- tipo: tecnica
- descricao: Design de schema, normalizacao, selecao de ORM, indices e migrations seguras

--- DevOps ---

[pre-deploy-checklist]
- keywords: antes de deployar, checklist de deploy, pre deploy, antes de subir para producao, preparar deploy, ready to deploy, pronto para producao, verificar antes de subir, deploy checklist, antes do release
- path: skills/devops/pre-deploy-checklist.md
- tipo: tecnica
- descricao: Checklist obrigatorio antes de cada deploy: testes, seguranca, migracao, rollback

[deploy-procedures]
- keywords: procedimento de deploy, processo de deploy, como fazer deploy, deploy step by step, rollback, zero downtime, blue green, canary release, deploy em producao, plataformas de deploy, deploy seguro, deploy workflow
- path: skills/devops/deploy-procedures.md
- tipo: tecnica
- descricao: Procedimentos de deploy: plataformas, 5 fases, rollback e zero-downtime

[observabilidade]
- keywords: observabilidade, logs, metricas, tracing, structured logging, log estruturado, red metrics, use metrics, distributed tracing, opentelemetry, alertas, dashboards, slo, sla, monitoramento, apm
- path: skills/devops/observabilidade.md
- tipo: tecnica
- descricao: Observabilidade: logs estruturados, metricas RED/USE, distributed tracing e alertas

[containerizacao]
- keywords: docker, container, dockerfile, docker compose, containerizar, imagem docker, docker build, multi-stage build, build multi-etapa, container seguranca, container registry, registro de container, kubernetes, docker security, dockerize
- path: skills/devops/containerizacao.md
- tipo: tecnica
- descricao: Dockerfile, multi-stage builds, Docker Compose e seguranca de containers

[monorepo]
- keywords: monorepo, workspace, turborepo, nx, dependencias internas, ci seletivo, codeowners, monorepo setup, shared packages, package interno, pnpm workspace, yarn workspaces, lerna, monorepo patterns
- path: skills/devops/monorepo.md
- tipo: tecnica
- descricao: Monorepo: workspaces, dependencias internas, CI seletivo e CODEOWNERS

[eruda-mobile-debug]
- keywords: eruda, debug mobile, console no celular, devtools no celular, debug dispositivo, inspecionar no mobile, mobile devtools, debug ios, debug android, console mobile, network mobile, dom mobile
- path: skills/devops/eruda-mobile-debug.md
- tipo: tecnica
- descricao: Debug mobile em projetos Vite via Eruda: console, network e DOM no dispositivo

[css-cache-busting]
- keywords: cache busting css, versionar css, css v=x, css sem bundler, invalidar cache css, css nao atualiza, versao de css, css muda mas nao atualiza, forcar recarregar css, cache de estilo
- path: skills/devops/css-cache-busting.md
- tipo: tecnica
- descricao: Padrao ?v=X para CSS sem bundler: quando incrementar e diagnostico de cache

--- Git ---

[git-commit-push]
- keywords: git push, git commit, faça um push, commite tudo, sobe as mudancas, commit e push, versiona isso, manda pro git, salva no git, push isso, commita, suba as mudancas, envie para o github, protocolo de commit, commit protocol, push protocol, executar commit, fazer push, gerar mensagem de commit
- path: skills/git/git-commit-push.md
- tipo: tecnica
- descricao: Protocolo operacional de 6 fases para commit e push: analise, validacoes, mensagem Conventional Commits, staging, push com divergence handling e merge de feature branch

[delete-merged-branches]
- keywords: limpar branches, higienizar branches, branches antigas, deletar branches mergeadas, remover branches, branches mortas, branch cleanup, clean branches, branches nao usadas, prune branches, delete merged, branches acumuladas, branches esquecidas
- path: skills/git/delete-merged-branches.md
- tipo: tecnica
- descricao: Limpeza segura de branches remotas mergeadas: dry-run como padrao, protecao de branches criticas, confirmacao obrigatoria

[commit-conventions]
- keywords: conventional commits, commit convention, mensagem de commit, feat fix chore, breaking change, commit message, commitlint, semver, changelog automatico, padrao de commit, boas mensagens de commit
- path: skills/git/commit-conventions.md
- tipo: tecnica
- descricao: Conventional Commits: tipos, breaking changes e commitlint

[branching-strategy]
- keywords: estrategia de branch, gitflow, trunk based, nomenclatura de branch, protecao de branch, feature branch, release branch, hotfix, merge strategy, estrategia de merge, rebase vs merge, branch naming, git workflow
- path: skills/git/branching-strategy.md
- tipo: tecnica
- descricao: Trunk-based vs GitFlow, nomenclatura e protecao de branch

[pr-template]
- keywords: pull request template, template de pr, pull request, revisao de pr, processo de review, pr description, pr checklist, merge request template, como escrever pr, pr review process, descricao de pr
- path: skills/git/pr-template.md
- tipo: tecnica
- descricao: PULL_REQUEST_TEMPLATE.md, processo de review e boas praticas

[github-profile]
- keywords: github profile, perfil github, readme de perfil, github stats, badges github, portfolio github, github bio, profile readme, customizar perfil github, github achievements, contribuicoes github
- path: skills/git/github-profile/SKILL.md
- tipo: tecnica
- descricao: GitHub user profiles: stats, repositorios e visualizacao de atividade recente

--- Documentacao ---

[technical-docs]
- keywords: documentacao tecnica, readme, adr, architecture decision record, jsdoc, changelog, keep a changelog, documentar projeto, escrever readme, decisao arquitetural, documentacao de codigo, docs do projeto, documente, documentacao, documentar, escrever documentacao, criar documentacao, gerar documentacao, technical documentation, write docs, create docs
- path: skills/documentation/technical-docs.md
- tipo: tecnica
- descricao: README, ADR, JSDoc e CHANGELOG (Keep a Changelog)

[openapi-swagger]
- keywords: openapi, swagger, api spec, especificacao de api, yaml de api, api documentation, openapi 3.1, schema de api, documentar api, swagger ui, api contract, api spec file, documente a api, documentacao da api, documentar endpoints, documentar rotas
- path: skills/documentation/openapi-swagger.md
- tipo: tecnica
- descricao: Schema OpenAPI 3.1, autenticacao e validacao no CI

--- Node.js ---

[nodejs-patterns]
- keywords: nodejs, node js, estrutura mvc node, graceful shutdown, env validation, connection pooling, pool de conexoes, node patterns, boas praticas node, nodejs architecture, node boilerplate, iniciar projeto node, node estrutura
- path: skills/nodejs/nodejs-patterns.md
- tipo: tecnica
- descricao: Estrutura MVC, graceful shutdown, validacao de env e connection pooling em Node.js

[express-best-practices]
- keywords: express, expressjs, middleware express, ordem de middleware, cors express, rate limiting express, validacao de input express, express security, express patterns, boas praticas express, rota express
- path: skills/nodejs/express-best-practices.md
- tipo: tecnica
- descricao: Ordem de middleware, CORS, rate limiting e validacao de input no Express

--- Python ---

[python-patterns]
- keywords: python, venv, virtualenv, src layout, black, ruff, mypy, type hints, logging python, python patterns, boas praticas python, estrutura python, python project, python boilerplate, tipagem python
- path: skills/python/python-patterns.md
- tipo: tecnica
- descricao: venv, src layout, black/ruff/mypy, type hints e logging em Python

[python-scripts]
- keywords: script python, argparse, dry run, idempotente, exit code, codigo de saida, stderr logging, cli python, python cli, script util, ferramenta python, script de linha de comando, python automation, utilitario python
- path: skills/python/python-scripts.md
- tipo: tecnica
- descricao: argparse, --dry-run, idempotencia, exit codes e logs no stderr para scripts Python

--- AI / LLM Tecnico ---

[ai-integration-patterns]
- keywords: integrar llm, integrar claude, integrar openai, api de ia, retry llm, retry de llm, tentar novamente com llm, fallback llm, fallback de llm, prompt injection protection, pii em prompt, cache de prompt, api key segura, ai integration, llm api, rate limit llm, custo de tokens
- path: skills/ai/ai-integration-patterns.md
- tipo: tecnica
- descricao: API keys, retry, cache, protecao contra prompt injection, PII e fallback para integracao com LLMs

--- MCP ---

[dependency-health-audit]
- keywords: auditoria de dependencias, dependency audit, auditar libs, verificar deprecations, health check das deps, deprecation check, deps desatualizadas, libs desatualizadas, monthly audit, auditoria mensal, verificar mudancas de api, api changes, deps audit, dependency health, libs fora de data, cves em dependencias, libs vulneraveis
- path: skills/mcp/dependency-health-audit.md
- tipo: tecnica
- descricao: Auditoria mensal via MCP: detectar mudancas de API, deprecations e CVEs antes que virem bugs em producao

[ideias-de-mcp]
- keywords: criar mcp, mcp server, mcp tool, quando criar mcp, design de mcp, mcp seguro, mcp server design, ferramenta mcp, novo mcp, servidor mcp, mcp server novo, construir mcp
- path: skills/mcp/ideias-de-mcp.md
- tipo: tecnica
- descricao: MCP servers: quando criar, categorias, seguranca e estrutura minima

[github-app-install]
- keywords: github app claude, instalar github app, acesso a issues, acesso a prs, acesso a branches, claude github, github integration claude, install github app, slash install github, claude code github
- path: skills/mcp/github-app-install.md
- tipo: tecnica
- descricao: GitHub App do Claude Code: /install-github-app para acesso a issues, PRs e branches

[browser-mcp]
- keywords: browser mcp, automacao de browser, playwright claude, chrome devtools mcp, automatizar browser, browser automation, navegar no browser, clicar no browser, screenshot browser, testar no browser, browser tools
- path: skills/browser-mcp/SKILL.md
- tipo: tecnica
- descricao: Browser MCP + Chrome DevTools MCP: automacao de browser e debug tecnico no Claude Code

--- Plataformas ---

[cloudflare-patterns]
- keywords: cloudflare, cloudflare workers, cloudflare pages, d1, kv, r2, durable objects, edge computing, workers script, cloudflare limits, cloudflare deploy, cloudflare d1 database, cloudflare patterns
- path: skills/platforms/cloudflare/cloudflare-patterns.md
- tipo: tecnica
- descricao: Cloudflare Workers, Pages, D1, KV, R2, Durable Objects: padroes e limites

[replit-patterns]
- keywords: replit, replit deploy, replit limites, replit boas praticas, replit sempre ativo, replit database, replit secrets, replit environment, deploy no replit, projeto replit, replit patterns
- path: skills/platforms/replit/replit-patterns.md
- tipo: tecnica
- descricao: Replit: padroes, limites e boas praticas

[vercel-patterns]
- keywords: vercel, vercel deploy, vercel edge, vercel functions, serverless vercel, vercel limits, vercel env, vercel cli, deploy vercel, next.js vercel, vercel build, vercel boas praticas, vercel patterns
- path: skills/platforms/vercel/vercel-patterns.md
- tipo: tecnica
- descricao: Vercel: padroes, limites e boas praticas de deploy

--- Automacao ---

[automacoes-uteis]
- keywords: automacao, automatizar tarefa, script de automacao, automacao de dev, automatizar workflow, tarefa repetitiva, automate, scripting, bash automation, ci automacao, automatizar processo, ideias de automacao
- path: skills/automacao/automacoes-uteis.md
- tipo: tecnica
- descricao: Ideias de automacoes para tarefas repetitivas de desenvolvimento

[git-auto-push-hook]
- keywords: auto push, hook de commit, post tool use hook, commit automatico, push automatico, git hook claude, hook apos commit, backoff exponencial, auto commit push, claude hook git, automatizar push
- path: skills/automacao/git-auto-push-hook.md
- tipo: tecnica
- descricao: Hook PostToolUse para auto-push apos commit do Claude com backoff exponencial

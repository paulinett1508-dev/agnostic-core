Claude Code Commands

Commands prontos para usar com Claude Code e Antigravity.

Como usar:
Cole os commands abaixo no CLAUDE.md do projeto ou use diretamente no prompt.

Security Audit:
Atue como o agent em .agnostic-core/agents/reviewers/security-reviewer.md
Revise os arquivos em [PASTA] e gere o Security Review Report completo.

Frontend Review:
Atue como o agent em .agnostic-core/agents/reviewers/frontend-reviewer.md
Revise os arquivos HTML, CSS e JS em [PASTA].

Pre-Deploy Check:
Siga o checklist em .agnostic-core/skills/devops/pre-deploy-checklist.md
Verifique cada item e mostre o status atual do projeto.

Database Review:
Revise as queries e schema usando .agnostic-core/skills/database/query-compliance.md
Mostre problemas encontrados por severidade.

Generate Boilerplate:
Atue como o agent em .agnostic-core/agents/generators/boilerplate-generator.md
Crie a estrutura inicial para um projeto [DESCRICAO].

Code Inspector (SPARC):
Atue como o agent em .agnostic-core/agents/reviewers/code-inspector.md
Audite os arquivos em [PASTA] usando a metodologia SPARC e gere o Code Inspector Report completo.

OWASP Security Check:
Revise os arquivos em [PASTA] usando .agnostic-core/skills/security/owasp-checklist.md
Liste todos os problemas por severidade (CRITICA / ALTA / MEDIA / BAIXA).

Performance Audit:
Revise os arquivos em [PASTA] usando .agnostic-core/skills/performance/performance-audit.md
Identifique os 3 maiores gargalos de performance com plano de correcao.

Pre-Implementation Check:
Antes de implementar [DESCRICAO], aplique .agnostic-core/skills/audit/pre-implementation.md
Verifique: existe solucao mais simples? codigo duplicado? roda nativa disponivel?

Refactoring Plan:
Analise o arquivo [ARQUIVO] usando .agnostic-core/skills/audit/refactoring.md
Gere as 7 fases de decomposicao segura com plano de extracao incremental.

CSS Governance Check:
Revise os arquivos CSS em [PASTA] usando .agnostic-core/skills/frontend/css-governance.md
Liste todas as violacoes (cores hardcoded, seletores sem escopo, duplicacoes).

Financial Operations Review:
Revise o modulo financeiro em [PASTA] usando .agnostic-core/skills/backend/financial-operations.md
Verifique idempotencia, atomicidade e trilha de auditoria.

Fact Check:
Aplique .agnostic-core/skills/ai/fact-checker.md
Verifique as afirmacoes sobre o codigo/dados com fontes primarias antes de responder.

Project Planner:
Atue como o agent em .agnostic-core/agents/generators/project-planner.md
Gere ROADMAP.md e PLAN.md para o projeto [DESCRICAO].

Codebase Mapper:
Atue como o agent em .agnostic-core/agents/reviewers/codebase-mapper.md
Analise o codebase em [PASTA] e gere STACK.md, ARCHITECTURE.md, CONVENTIONS.md e CONCERNS.md.

UX Audit:
Revise [PASTA/COMPONENTE] usando .agnostic-core/skills/frontend/ux-guidelines.md
Liste todas as violacoes por categoria e severidade (CRITICA/ALTA/MEDIA/BAIXA).

Accessibility Check:
Revise [PASTA] usando .agnostic-core/skills/frontend/accessibility.md
Gere relatorio WCAG 2.1 AA com todos os problemas encontrados e correcoes recomendadas.

Test Review:
Atue como o agent em .agnostic-core/agents/reviewers/test-reviewer.md
Analise a suite de testes em [PASTA] e gere o Test Review Report com status APROVADO ou BLOQUEAR.

Performance Review:
Atue como o agent em .agnostic-core/agents/reviewers/performance-reviewer.md
Analise o codigo em [PASTA] e gere o Performance Review Report com prioridade por ROI.

Migration Validate:
Atue como o agent em .agnostic-core/agents/validators/migration-validator.md
Valide as migrations em [PASTA] antes de executar em producao.

Generate Docs:
Atue como o agent em .agnostic-core/agents/generators/docs-generator.md
Gere [README | ADR | CHANGELOG | OpenAPI] para o projeto em [PASTA].

REST API Review:
Revise as rotas em [PASTA] usando .agnostic-core/skills/backend/rest-api-design.md
Verifique nomenclatura, HTTP methods, status codes, paginacao e estrutura de resposta.

Commit Convention Check:
Verifique se o commit abaixo segue .agnostic-core/skills/git/commit-conventions.md
Corrija se necessario: [MENSAGEM DO COMMIT]

Node.js Review:
Revise os arquivos em [PASTA] usando .agnostic-core/skills/nodejs/nodejs-patterns.md e .agnostic-core/skills/nodejs/express-best-practices.md
Verifique: graceful shutdown, validacao de env, ordem de middleware, tratamento de erros.

AI Integration Review:
Revise o codigo de integracao com LLM em [PASTA] usando .agnostic-core/skills/ai/ai-integration-patterns.md
Verifique: API key segura, retry, cache, prompt injection, PII, fallback.

Workflow Planning:
Use .agnostic-core/skills/workflow/goal-backward-planning.md
Planeje a implementacao de [DESCRICAO] com goal-backward, observable truths e tasks em waves.

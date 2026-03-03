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

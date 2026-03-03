Pre-Deploy Checklist

Objetivo: Gate obrigatorio antes de qualquer deploy em producao.

Quando usar:
- Antes de todo deploy em producao
- Como etapa no pipeline CI/CD

Checklist

Codigo:
- PR aprovado por pelo menos 1 revisor
- Todos os testes passando (unit + integration)
- Sem conflitos de merge
- Branch atualizada com main

Seguranca:
- npm audit ou pip check sem vulnerabilidades criticas
- Nenhum secret commitado no repositorio
- .env.example atualizado se variaveis mudaram
- Variaveis de ambiente de producao configuradas

Banco de Dados:
- Migrations testadas em staging
- Backup recente confirmado antes do deploy
- Migrations reversiveis documentadas

Infraestrutura:
- Health check configurado
- Logs e monitoramento ativos
- Alertas configurados para erros criticos

Rollback:
- Plano de rollback definido
- Versao anterior identificada e disponivel
- Responsavel disponivel 30min apos o deploy

Pos-Deploy (primeiros 5 minutos):
- Health check passou
- Logs sem erros criticos
- Metricas de performance estaveis
- Funcionalidade critica testada manualmente
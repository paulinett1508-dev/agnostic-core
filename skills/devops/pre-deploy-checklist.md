Pre-Deploy Checklist - DevOps

Objetivo: Verificacoes de infraestrutura e pipeline antes de deploy em producao.

Quando usar:
- Como gate final no pipeline CI/CD
- Antes de qualquer release em producao

Pipeline CI/CD:
- Build passando sem warnings criticos
- Todos os testes automatizados executados
- Coverage minima atingida (definir threshold por projeto)
- Lint e formatacao verificados
- Security scan de dependencias executado

Containers e Infra:
- Imagem Docker buildada e tagueada corretamente
- Variaveis de ambiente injetadas via secrets (nao hardcoded)
- Resource limits configurados (CPU e memoria)
- Liveness e readiness probes configurados
- Replicas minimas definidas para alta disponibilidade

Banco de Dados:
- Migrations executam sem erro em staging
- Backup automatico confirmado ativo
- Connection pool adequado para a carga esperada

Monitoramento:
- Dashboard atualizado com novas metricas se necessario
- Alertas configurados para os novos endpoints/funcionalidades
- Logs estruturados e indexados

Rollback:
- Tag da versao anterior documentada
- Procedure de rollback testada em staging
- Tempo estimado de rollback conhecido
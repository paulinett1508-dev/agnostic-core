Code Review

Objetivo: Guia para revisao sistematica garantindo qualidade, seguranca e manutencao.

Quando usar:
- Ao revisar qualquer Pull Request
- Antes de merge em main/master
- Auditoria de codigo legado

O que revisar

Corretude:
- O codigo faz o que a issue/task pede?
- Casos de borda tratados?
- Tratamento de erros adequado?
- Sem logica invertida

Seguranca:
- Inputs validados e sanitizados
- Sem dados sensiveis em logs ou responses
- Permissoes verificadas onde necessario
- Dependencias novas auditadas (npm audit, pip check)

Qualidade:
- Funcoes com responsabilidade unica
- Sem codigo duplicado (DRY)
- Nomes de variaveis e funcoes claros
- Sem comentarios que explicam o obvio
- TODO/FIXME com issue linkada

Testes:
- Novos comportamentos cobertos por testes
- Testes legiveis com assertions claras
- Mocks usados com moderacao

Performance:
- Loops sem operacoes pesadas desnecessarias
- Cache considerado onde aplicavel
- Queries otimizadas (ver skills/database/query-compliance.md)

Como dar feedback:
- Cite arquivo e linha, explique o problema
- Use prefixos: BLOCKER, SUGESTAO, NITPICK
- Proponha solucao, nao apenas aponte o problema
- Elogie o que esta bom
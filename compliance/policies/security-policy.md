Security Policy

Principios:
1. Least Privilege: cada componente acessa apenas o minimo necessario
2. Defense in Depth: multiplas camadas de seguranca
3. Fail Secure: em caso de erro, falhe sem expor dados
4. Zero Trust: nao confie por padrao, verifique sempre

Obrigatorio em todo projeto:
- Autenticacao em todos os endpoints privados
- HTTPS em producao (sem excecao)
- Secrets em variaveis de ambiente (nunca no codigo)
- Rate limiting em endpoints publicos
- Logs de auditoria para acoes criticas
- Dependency scanning no CI/CD

Proibido:
- Credenciais hardcoded
- SQL com interpolacao de string
- Dados sensiveis em logs
- Stack trace em producao
- CORS com wildcard em producao

Incidentes de Seguranca:
1. Isolar o componente afetado imediatamente
2. Notificar o responsavel tecnico
3. Preservar logs para analise forense
4. Revogar credenciais comprometidas
5. Post-mortem documentado em ate 48h

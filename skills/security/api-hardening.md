API Hardening

Objetivo: Checklist para proteger endpoints de API.

Quando usar:
- Antes de expor endpoint publicamente
- Durante code review de controllers
- Gate antes de deploy em producao

Checklist

Autenticacao e Autorizacao
- Todos os endpoints privados requerem token valido
- JWT com expiracao (max 24h para access token)
- Refresh token com rotacao habilitada
- Rate limiting por usuario e por IP
- Permissoes verificadas apos autenticacao

Input Validation
- Sanitizacao de todos os inputs
- Validacao de tipos, formatos e tamanhos
- Rejeitar payloads acima do limite (ex: 10MB)
- SQL: usar prepared statements ou ORM
- XSS: escapar outputs em contextos HTML

Headers de Seguranca
- Content-Security-Policy configurado
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- HSTS habilitado
- CORS restrito a origens permitidas
- X-Powered-By removido

Exposicao de Dados
- Nunca retornar stack trace em producao
- Dados sensiveis fora dos logs
- Responses padronizados sem estrutura interna

Referencias
- OWASP API Security Top 10: https://owasp.org/API-Security/

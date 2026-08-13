# API Hardening

Pontos de segurança **específicos de API** que somam ao checklist genérico de aplicação
web. Útil em code review de controllers ou ao revisar uma API antes de torná-la pública.

O checklist geral (headers de segurança, injeção, XSS, exposição de dados, sessão/cookie,
rate limiting) já está coberto em `skills/security/owasp-checklist.md` — não repetido
aqui. Esta skill cobre apenas o que é particular de API (tokens, contrato de autorização).

---

## Autenticação e Autorização — específico de API

- JWT com expiração configurada (access token: até 24h; refresh token com rotação)
- Rate limiting por usuário autenticado, além do limite por IP (já coberto no checklist geral)
- Permissões verificadas **após** autenticação — autenticado ≠ autorizado; um token válido
  não implica acesso ao recurso pedido, checar o vínculo (dono do recurso, papel, escopo)
- Payloads rejeitados acima de um limite razoável (ex: 10MB) antes de qualquer parsing

---

## Sinais que merecem atenção

- Token válido aceito sem checar se o portador tem permissão sobre o recurso específico
  (autenticação ok, autorização pulada)
- JWT sem expiração ou com expiração longa demais sem refresh/rotação
- Rate limit só por IP, sem limite por usuário autenticado (permite abuso via múltiplas contas)

---

## Referências

- OWASP API Security Top 10: https://owasp.org/API-Security/

Ver também: `skills/security/owasp-checklist.md` — checklist completo (headers, injeção,
XSS, exposição de dados, sessão/cookie, rate limiting, dependências, logging)

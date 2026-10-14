# Dependency Health Audit

Protocolo de auditoria periódica (mensal) usando MCP de documentação (Context7 ou equivalente) para detectar mudanças de API, deprecations e CVEs **antes** que se tornem bugs em produção.

Filosofia: auditoria proativa elimina horas de debug reativo.

---

## Quando executar

- Primeira semana de cada mês
- Antes de iniciar nova temporada/ciclo do produto
- Após release major de dependência crítica (ex: ORM 7.x → 8.x)
- Quando novo CVE crítico surge no OWASP Top 10
- Antes de upgrades planejados de dependências

---

## Auditoria 1 — Mudanças de API externa

Para cada API externa consumida pelo projeto:

### Protocolo

```
1. Resolver library ID da API no MCP de docs
   mcp__context7__resolve-library-id({ libraryName: "nome-do-sdk" })

2. Buscar mudanças recentes
   mcp__context7__query-docs({
     libraryId: <id>,
     query: "breaking changes deprecations endpoints alterados versão atual"
   })

3. Comparar com uso atual no código
   grep -r "endpoint-ou-metodo" src/

4. Sinalizar divergências
```

### Saída esperada

```markdown
## API: <Nome>

### CRÍTICO: Endpoint /recurso/v1 deprecated
- Novo endpoint: /recurso/v2
- Breaking change: campo `id` renomeado para `uuid`
- Arquivo afetado: `src/services/RecursoService.ts:45`
- Prazo de migração: DD/MM/AAAA

### OK: Endpoint /outro-recurso
- Sem mudanças detectadas
```

---

## Auditoria 2 — OWASP Security

Verificar se as configurações de segurança seguem o OWASP Top 10 atualizado.

### Protocolo

```
1. Buscar OWASP Top 10 atualizado
   mcp__context7__resolve-library-id({ libraryName: "owasp-top-ten" })
   mcp__context7__query-docs({ query: "top 10 vulnerabilidades web <ano atual>" })

2. Mapear para os arquivos de segurança do projeto
   - middleware de autenticação
   - configuração de CORS
   - sanitização de inputs
   - configuração de headers (Helmet, CSP)

3. Comparar padrão atual vs recomendações
```

### Checks principais

| Vulnerabilidade | O que verificar |
|-----------------|----------------|
| A01 Broken Access Control | Todas rotas sensíveis têm autenticação? |
| A02 Cryptographic Failures | Hashes usam algoritmo forte (bcrypt, Argon2)? |
| A03 Injection | Inputs sanitizados? ORM usado corretamente? |
| A05 Security Misconfiguration | Headers de segurança configurados? CSP presente? |
| A09 Logging Failures | Logs capturam eventos de segurança sem expor dados? |

---

## Auditoria 3 — Deprecations em dependências

### Protocolo

```bash
# Verificar versão instalada
cat package.json | grep '"dependencies"' -A 50

# Para cada dep crítica, buscar deprecations no MCP
mcp__context7__query-docs({
  libraryId: "/org/lib",
  query: "métodos deprecated versão X.x migration guide para Y.x"
})

# Buscar padrões deprecated no código
grep -r "metodo-deprecated" src/
```

### Padrões comuns a checar por stack

**Node/Express:**

```bash
grep -r "\.remove({" src/        # deprecated → deleteOne/deleteMany
grep -r "findOneAndRemove" src/  # deprecated → findOneAndDelete
grep -r "update({" src/          # deprecated → updateOne/updateMany
```

**Python:**

```bash
grep -r "asyncio.coroutine" src/   # deprecated → async/await
grep -r "collections\." src/ | grep -v "abc\|deque\|OrderedDict"
```

---

## Auditoria 4 — Padrões modernos de plataforma

Para PWAs, mobile apps ou qualquer plataforma com APIs em evolução rápida:

```
1. Buscar best practices atuais no MCP
   mcp__context7__query-docs({
     query: "service worker caching strategies <ano> best practices"
   })

2. Comparar com implementação atual
3. Identificar gaps de modernização
```

---

## Relatório final

Salvar em: `docs/auditorias/AUDIT-DEPS-<YYYY-MM>.md`

```markdown
# Auditoria de Dependências — <MÊS>/<ANO>

**Data:** YYYY-MM-DD
**Próxima auditoria:** YYYY-MM-DD (+30 dias)

---

## Sumário Executivo

| Categoria    | Status     | Críticas | Médias | Baixas |
|--------------|------------|----------|--------|--------|
| API externa  | CRÍTICO    | 1        | 0      | 2      |
| OWASP        | ATENÇÃO    | 0        | 1      | 0      |
| Deprecations | OK         | 0        | 0      | 3      |
| Plataforma   | OK         | 0        | 0      | 1      |

---

## Ações urgentes (próximos 7 dias)

1. **[API-001]** Migrar endpoint /recurso/v1 → /v2
   - Arquivo: `src/services/RecursoService.ts:45`
   - Breaking change: campo `id` → `uuid`

---

## Ações recomendadas (próximos 30 dias)

1. **[SEC-001]** Atualizar CSP para bloquear unsafe-inline
   - OWASP A05 - Security Misconfiguration

---

## Backlog (Q2/Q3)

1. **[DEP-001]** Planejar migração ORM 7.x → 8.x
   - 3 métodos deprecated encontrados
```

---

## Métricas de ROI

| Métrica | Sem auditoria | Com auditoria |
|---------|--------------|--------------|
| Bugs de API/breaking changes em produção | 2–3/ciclo | 0–1/ciclo |
| Tempo de debug de API | 5h/bug | 2h/bug |
| Vulnerabilidades detectadas pós-deploy | 3–5/ano | 0–1/ano |
| Tempo de pesquisa pré-upgrade | 3h | 30min |

---

## Keywords de ativação

- "auditoria de dependências"
- "auditar libs"
- "verificar deprecations"
- "health check das deps"
- "dependency audit mensal"

---

Ver também: `skills/mcp/ideias-de-mcp.md`, `skills/security/owasp-checklist.md`, `skills/devops/pre-deploy-checklist.md`

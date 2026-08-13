# Estratégias de Cache

Ideias de cache que valem considerar dependendo do problema que você está resolvendo.
Cache resolve problemas específicos — identifique o gargalo antes de adicionar uma camada.

---

## Quando cache faz sentido

- Dados que mudam raramente mas são lidos com frequência (configurações, catálogos)
- Respostas de APIs externas com custo por requisição ou rate limit
- Computações pesadas cujo resultado é determinístico para os mesmos parâmetros
- Sessões de usuário e tokens de autenticação
- Resultados de queries agregadas (relatórios, dashboards)

## Quando cache pode causar problema

- Dados financeiros — cache pode causar leitura de saldo desatualizado
- Dados com consistência forte necessária (estoque em tempo real, agendamentos)
- Quando a invalidação é complexa demais de manter correta

---

## Estratégias principais

### Cache-Aside (Lazy Loading)
A aplicação verifica o cache. Se não encontrar (miss), busca na fonte, armazena no cache e retorna.

```
Cache miss → busca no banco → armazena no cache → retorna
Cache hit  → retorna direto do cache
```

**Bom para:** leitura pesada, dados que nem sempre são necessários
**Cuidado:** cold start (primeiro acesso sempre vai ao banco), thundering herd

### Read-Through
O cache gerencia automaticamente a busca na fonte quando há miss.
A aplicação só fala com o cache.

**Bom para:** simplificar o código da aplicação
**Cuidado:** requer suporte do provider de cache

### Write-Through
Toda escrita vai ao cache e ao banco ao mesmo tempo.

**Bom para:** leitura frequente logo após escrita, consistência importante
**Cuidado:** latência de escrita maior, dados raramente lidos ficam no cache sem necessidade

### Write-Behind (Write-Back)
Escreve no cache primeiro, banco depois (assíncrono).

**Bom para:** alta frequência de escrita, cenários onde latência de escrita importa
**Cuidado:** risco de perda de dados se o cache cair antes de persistir; evite em dados críticos

---

## Onde cachear

| Camada | Ferramenta | Bom para |
|---|---|---|
| In-memory (processo) | Map, LRU local | dados imutáveis por deploy, config — perdido ao reiniciar, sem compartilhamento entre instâncias |
| Distributed cache | Redis, Memcached | sessões, tokens, dados entre instâncias |
| HTTP cache | Cache-Control, ETags | respostas de API, assets |
| CDN / Edge | Cloudflare, Fastly, Vercel Edge | assets estáticos, conteúdo geográfico, resposta pública sem personalização |
| Query cache | ORM built-in | queries repetitivas no mesmo request |

---

## TTL — Time to Live

- Defina TTL explícito para toda entrada; nunca confie em cache que "dura para sempre"
- TTL muito curto: pouca vantagem, muitas idas ao banco
- TTL muito longo: risco de dados stale, problema maior quando é dado crítico
- Adicione jitter (variação aleatória de ±10%) no TTL para evitar que várias chaves expirem juntas e causem thundering herd

Referência aproximada por volatilidade:

| Volatilidade | TTL | Exemplo |
|---|---|---|
| Alta | 30s – 5min | posição em ranking, contador em tempo real, status de pedido |
| Média | 5min – 1h | perfil de usuário, config de conta, resultado de busca |
| Baixa | 1h – 24h | catálogo de produtos, categorias, config global |
| Quase estática | 24h – 7d | tabela de referência, geolocation, preço base |

---

## Invalidação

Cache tem dois problemas difíceis: nomear coisas e invalidar cache.

- **Por TTL:** simples, mas pode entregar dado desatualizado até expirar
- **Por evento:** invalida no momento da mudança (mais correto, mais complexo) — a invalidação deve acontecer *após* o commit no banco, nunca antes
- **Por versão:** inclui versão na chave (`produto:v2:123`) — troca a chave em vez de invalidar

```
# Padrão de chave com namespace
{entidade}:{id}           → produto:456
{entidade}:{filtro}       → produtos:categoria:eletronicos
{usuario}:{recurso}       → usuario:789:permissoes
```

Regras de nomenclatura: prefixo consistente por domínio (não misturar), separador `:` fixo
(não `.` nem `-`), nunca montar chave com input do usuário sem sanitização, documentar o
schema de chaves no README do serviço.

Ao invalidar em lote, nunca usar um pattern amplo tipo `KEYS user:*` num Redis em produção
— bloqueia o servidor. Use `SCAN` com cursor.

---

## Cache de respostas HTTP

```
# Dado público, cacheável por CDN por 1h, revalida após 30min
Cache-Control: public, max-age=3600, stale-while-revalidate=1800

# Dado privado (por usuário), não cacheável por CDN
Cache-Control: private, max-age=300

# Sem cache (dado sensível ou muito volátil)
Cache-Control: no-store
```

ETag para revalidação condicional: calcule um hash do corpo da resposta, devolva no header
`ETag`; se o cliente reenviar o mesmo valor em `If-None-Match`, responda `304 Not Modified`
sem corpo.

---

## Armadilhas comuns

**Cache como fonte de verdade** — o banco é a fonte de verdade. O cache é otimização.
Nunca tome decisões críticas (autorização, saldo, estoque) baseado só no cache.

**Cache stampede / thundering herd** — múltiplas requisições simultâneas com miss,
todas indo ao banco ao mesmo tempo. Mitigue com: mutex/lock na busca, probabilistic early expiration,
ou warm-up antes de remover o TTL.

**Memória ilimitada** — sempre configure `maxmemory` e política de eviction no cache distribuído
(`allkeys-lru` é um bom padrão no Redis).

**Sem monitoramento** — rastreie hit rate, miss rate e latência. Hit rate abaixo de 70-80%
geralmente indica problema na estratégia.

---

## Checklist

- [ ] TTL definido para cada chave (nenhum TTL infinito em dado mutável)
- [ ] Jitter aplicado para evitar thundering herd
- [ ] Invalidação explícita ao atualizar o dado na fonte, após o commit
- [ ] App funciona em modo degradado se o cache cair (cache é otimização, não dependência)
- [ ] Chaves seguem nomenclatura documentada
- [ ] Hit rate monitorado
- [ ] Persistência configurada no cache distribuído se ele guarda algo crítico de recuperar (ex.: sessão)

---

## Exemplo (Node + Redis) — cache-aside com invalidação

```js
async function getUser(userId) {
  const cacheKey = `user:${userId}`
  const cached = await redis.get(cacheKey)
  if (cached) return JSON.parse(cached)

  const user = await db.User.findById(userId)
  if (!user) return null

  const ttl = 3600 + Math.floor(Math.random() * 360) // 1h ± 6min de jitter
  await redis.setex(cacheKey, ttl, JSON.stringify(user))
  return user
}

async function updateUser(userId, data) {
  await db.User.update(userId, data)
  await redis.del(`user:${userId}`) // invalida após o commit
}
```

---

Ver também: `skills/performance/performance-audit.md`, `skills/database/query-compliance.md`

Error Handling

Objetivo: Tratar erros de forma consistente, segura e rastreavel — distinguindo erros operacionais (esperados) de erros de programacao (bugs).

---

CLASSIFICACAO DE ERROS

Erro Operacional (esperado em producao):
  Condicoes previstas que podem ocorrer em operacao normal.
  Exemplos: usuario nao encontrado, senha incorreta, servico externo fora do ar, input invalido.
  Acao: tratar, logar com nivel apropriado, retornar mensagem amigavel ao cliente.

Erro de Programacao (bug):
  Falha no codigo que nao deveria acontecer.
  Exemplos: TypeError de variavel undefined, acesso a propriedade nula, logica incorreta.
  Acao: logar como CRITICO, retornar 500 generico ao cliente, alertar time.

---

HIERARQUIA DE ERROS (conceito, agnostico de linguagem)

Defina um tipo de erro base com estes campos, e subtipos que o especializam:
  - `message`: texto legivel
  - `statusCode`/equivalente: como o erro vira resposta (HTTP status, gRPC code, etc.)
  - `code`: identificador estavel para o cliente programar contra (`NOT_FOUND`, `VALIDATION_ERROR`)
  - `isOperational` (ou equivalente): flag que distingue erro esperado de bug

Subtipos tipicos: NotFound (404), Validation (422, com lista de `details`),
Unauthorized (401), Conflict (409). Cada um so define a mensagem e o codigo —
a logica de log/resposta fica centralizada em um unico lugar (handler central),
nao espalhada pelos pontos onde o erro e lancado.

Ver `skills/nodejs/express-best-practices.md` (secao "Tratamento de Erros") para a
implementacao completa em Node/Express com classes concretas e o handler.

---

HANDLER CENTRALIZADO

Regra vale para qualquer stack com conceito de middleware/interceptor de request:
- [ ] O handler de erro e sempre o ULTIMO da cadeia (middleware, interceptor, filter)
- [ ] Erro operacional: logar em nivel adequado (`warn`), responder com `code`+`message`+`details`
- [ ] Erro de programacao: logar como `error`/critico, responder com mensagem generica (nunca stack trace)
- [ ] Sempre incluir um request ID no log para rastreabilidade
- [ ] Resposta de erro segue estrutura padrao (ver `rest-api-design.md`)

---

PROPAGACAO ASSINCRONA

Erro dentro de uma rotina assincrona (`async`/`await`, coroutine, `Promise`, futuro)
que nao e capturado explicitamente **nao chega automaticamente** ao handler central na
maioria dos frameworks — precisa de um wrapper (`try/catch` + `next(err)` no Express,
equivalente em outros). Ver `skills/nodejs/express-best-practices.md` para o padrao
concreto em Node.

---

O QUE LOGAR VS O QUE EXPOR

| Dado | Logar? | Expor ao cliente? |
|---|---|---|
| Stack trace | Sim (nivel error) | Nunca |
| Mensagem tecnica do banco | Sim | Nunca |
| Request ID | Sim | Sim (header ou body) |
| Codigo de erro legivel | Sim | Sim |
| Mensagem amigavel | Sim | Sim |
| Dados do usuario no request | Sim (sanitizado) | Nao |
| Credenciais ou tokens | Nunca | Nunca |

Niveis de log:
- `error` → erros de programacao, falhas criticas
- `warn` → erros operacionais, rate limit atingido, tentativas invalidas
- `info` → eventos de negocio relevantes (login, compra, deploy)
- `debug` → diagnostico tecnico (so em desenvolvimento)

---

TRATAMENTO POR TIPO DE INTEGRACAO

Banco de dados: mapeie os codigos de erro nativos do driver (ex.: violacao de
unicidade, chave estrangeira, timeout de conexao) para os tipos de erro da sua
aplicacao — nunca deixe o codigo/mensagem nativa do banco vazar ate o cliente.
Erros nao mapeados (inesperados) devem propagar como estao, para nao mascarar bug.

APIs externas: distinga timeout, rate-limit (429) e falha de comunicacao —
cada um vira um tipo de erro diferente (`EXTERNAL_TIMEOUT`, `RATE_LIMITED`,
`EXTERNAL_ERROR`), nunca um 500 generico que esconde a causa.

Ver `skills/nodejs/express-best-practices.md` para o exemplo concreto (Postgres/Mongo + axios).

---

CHECKLIST DE QUALIDADE

- [ ] Hierarquia de erros definida e documentada
- [ ] Handler de erro centralizado e o ultimo da cadeia (middleware/interceptor/filter)
- [ ] Nenhuma rotina assincrona sem tratamento de erro (wrapper, try/catch ou equivalente)
- [ ] Erros de banco mapeados para erros de aplicacao (nao expor codigos de banco)
- [ ] Stack trace nunca exposto em resposta de producao
- [ ] Request ID rastreavel do log ate a resposta ao cliente
- [ ] Erros de programacao alertam o time (Sentry, Datadog, etc.)

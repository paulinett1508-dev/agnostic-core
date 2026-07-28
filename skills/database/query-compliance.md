# Banco de Dados — Queries e Schema

Boas práticas para queries e schema em segurança, performance e manutenibilidade.
Útil em code review de mudanças de banco, auditoria de performance ou ao revisar migrations.

---

Seguranca
- Sem SQL raw com interpolacao de string (usar parametros)
- Usuario do banco com permissoes minimas (least privilege)
- Dados sensiveis criptografados em repouso (senhas, CPF, cartao)
- Sem credenciais hardcoded no codigo

Bancos document-store com regras de seguranca por documento (Firestore,
DynamoDB+IAM condition keys, MongoDB Atlas App Services, etc.)
- Se a regra de leitura de uma colecao depende de um campo do documento
  (ex.: "so le se doc.tenantId == usuario.tenantId"), a QUERY do cliente
  precisa filtrar por esse mesmo campo (`where("tenantId","==",...)`) —
  senao o motor nao consegue provar que TODOS os documentos que a query
  poderia retornar passariam na regra, e rejeita a query INTEIRA (nao so
  os documentos que falhariam). Sintoma classico: "permission denied"/
  "insufficient permissions" numa query que so filtra por um ID
  relacionado (ex.: `emendaId==X`) sem o campo de tenant/localizacao.
- Esse bug fica invisivel quando toda a validacao historica do projeto e
  feita com uma conta que contorna a regra (ex.: role admin/superuser) —
  só aparece quando um usuario com o role restrito de verdade tenta usar
  a tela. Testar cada query nova como o role MENOS privilegiado que a usa,
  nao so como admin.
- Corrigir adicionando o filtro que falta usa o valor ja disponivel no
  documento-pai/no usuario logado — normalmente nao muda nenhum resultado
  (o dado ja pertence aquele tenant/localizacao por regra de escrita), so
  prova a regra pro mecanismo de leitura.
- Cuidado ao combinar esse filtro extra com `orderBy`/paginacao num campo
  diferente: bancos com indice composto exigido (Firestore) podem passar
  a exigir um indice novo que nao existe. Se nao for possivel criar o
  indice na hora, tirar o `orderBy` da query e ordenar a lista no cliente
  em vez de arriscar quebrar com "requires an index" na producao.

Performance
- Indexes criados para colunas usadas em WHERE, JOIN, ORDER BY
- Evitar SELECT * em queries de producao
- N+1 queries identificadas e resolvidas
- Paginacao implementada em listagens (LIMIT/OFFSET ou cursor)
- Queries lentas analisadas com EXPLAIN ANALYZE

Schema e Migrations
- Migrations reversiveis (up e down)
- Sem alteracao de coluna em producao sem migration testada em staging
- Foreign keys com ON DELETE definido explicitamente
- Timestamps (created_at, updated_at) em todas as tabelas principais
- Soft delete implementado onde necessario (deleted_at)

Backup e Disponibilidade
- Backup automatico configurado e testado
- Restore testado periodicamente
- Connection pool configurado adequadamente

Comandos uteis

PostgreSQL - queries lentas:
SELECT query, mean_exec_time FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 10;

MongoDB - explain:
db.collection.find(query).explain("executionStats")

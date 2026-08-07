# Keywords — Backend

Skills tecnicas exigem anuncio + confirmacao antes de executar (protocolo em [keywords-map.md](../keywords-map.md)).

---

[rest-api-design]
- keywords: rest api, design de api, nomenclatura de endpoint, http methods, status code, paginacao de api, versionamento de api, rest design, api contract, contrato de api, resource naming, restful, api padrao, endpoint design, api review, revisao de api
- path: skills/backend/rest-api-design.md
- tipo: tecnica
- descricao: Nomenclatura REST, HTTP methods, status codes, paginacao e versionamento

[error-handling]
- keywords: tratamento de erro, error handling, hierarquia de erros, middleware de erro, log de erro, centralizar erros, error middleware, capturar excecao, exception handling, error boundary, try catch, erros nao tratados
- path: skills/backend/error-handling.md
- tipo: tecnica
- descricao: Hierarquia de erros, middleware centralizado e estrategia log vs expor

[financial-operations]
- keywords: operacoes financeiras, transacao financeira, idempotencia, atomicidade, trilha de auditoria, transacao segura, pagamento, financial transaction, audit trail, two-phase commit, saga pattern, operacoes monetarias
- path: skills/backend/financial-operations.md
- tipo: tecnica
- descricao: Idempotencia, atomicidade e trilha de auditoria em operacoes financeiras

[domain-driven-design]
- keywords: ddd, domain driven design, bounded context, aggregate, domain event, ubiquitous language, linguagem ubiqua, entidade de dominio, value object, repositorio ddd, servico de dominio, modelagem de dominio
- path: skills/backend/domain-driven-design.md
- tipo: tecnica
- descricao: DDD: bounded contexts, aggregates, domain events e linguagem ubiqua

[event-sourcing]
- keywords: event sourcing, cqrs, eventos imutaveis, event store, projection, replay de eventos, event driven, orientado a eventos, command query, read model, modelo de leitura, write model, modelo de escrita, event log, audit log completo, cqrs pattern
- path: skills/backend/event-sourcing.md
- tipo: tecnica
- descricao: Event Sourcing e CQRS: eventos imutaveis, projections e versionamento

[estrategias-de-migracao]
- keywords: migracao, strangler fig, parallel run, execucao paralela, rodar em paralelo, branch by abstraction, migracao de sistema, migrar para novo sistema, reescrever sistema, modernizacao, legacy migration, big bang migration, migracao big bang, incrementar migracao
- path: skills/backend/estrategias-de-migracao.md
- tipo: tecnica
- descricao: Strangler Fig, Parallel Run, Branch by Abstraction e migracao de dados

[cdn-asset-validation]
- keywords: cdn, soft 404, asset nao carrega, imagem nao carrega, arquivo cdn com erro, validar cdn, checar cdn, asset vazio, http 200 corpo vazio, recurso cdn quebrado, broken asset, cdn check
- path: skills/backend/cdn-asset-validation.md
- tipo: tecnica
- descricao: Detectar soft-404 em CDNs externas (HTTP 200 com corpo vazio) via curl

Financial Operations

Objetivo: Garantir que operacoes financeiras sejam idempostentes, auditaveis e atomicas em qualquer sistema.

Quando usar:
- Ao implementar modulos de pagamento, cobranca, credito ou debito
- Code review de endpoints que movimentam saldo
- Auditoria de sistema com historico de transacoes
- Antes de deploy de funcionalidade financeira critica

Checklist

Idempotencia
- [ ] Toda transacao tem chave unica de idempotencia (chaveIdempotencia ou idempotencyKey)
- [ ] Sistema verifica se transacao ja existe antes de criar nova
- [ ] Reexecucao do mesmo request nao gera lancamento duplicado
- [ ] Chave de idempotencia inclui: tipo + identificadores + contexto (ex: debito-userId-temporada-referencia)
- [ ] Retorna 409 Conflict quando transacao ja existe (nao 200 com dado duplicado)

Registro de Auditoria (Follow the Money)
- [ ] Toda movimentacao financeira gera entrada em tabela/colecao de extrato
- [ ] Campos obrigatorios: tipo (debito/credito), valor, descricao, data, userId, contexto
- [ ] Campo metadata/detalhes com contexto adicional (modulo, referencia, rodada)
- [ ] Auditoria permite rastrear: quem, quando, quanto, por que

Operacoes Atomicas
- [ ] Sem padrao read-modify-write vulneravel a race condition
- [ ] Usando operacoes atomicas do banco ($inc, $set, UPDATE com WHERE atomico)
- [ ] Multiplas operacoes relacionadas dentro de transacao de banco quando disponivel
- [ ] Rollback implementado em caso de falha parcial

Validacao e Autorizacao
- [ ] Sessao/token validado antes de qualquer operacao financeira
- [ ] Usuario so pode movimentar seus proprios recursos (sem IDOR)
- [ ] Valores validados: positivos, dentro de range permitido, tipo numerico
- [ ] Operacoes admin verificam papel de administrador separadamente

Tratamento de Erros
- [ ] try/catch em todas as funcoes async de operacoes financeiras
- [ ] Falha nao gera estado inconsistente (ou completa ou nao faz nada)
- [ ] Mensagem de erro clara para o usuario sem expor dados internos
- [ ] Erro critico registrado com contexto completo para debugging

Separacao por Contexto
- [ ] Transacoes separadas por periodo/temporada/tenant
- [ ] Saldo calculado por contexto (nao mistura periodos diferentes)
- [ ] Historico paginado (nao retornar extrato completo de uma vez)

Cache Financeiro
- [ ] Cache de saldo invalidado imediatamente apos nova transacao
- [ ] Endpoint de recalculo disponivel para correc ao de cache
- [ ] Cache nunca e fonte de verdade: banco sempre prevalece

Red Flags Criticos
- Sem chave de idempotencia em operacao de debito/credito → CRITICO
- Read-modify-write sem lock atomico → CRITICO (race condition)
- Usuario pode alterar saldo de outro usuario → CRITICO (IDOR)
- Transacao sem registro de auditoria → ALTO
- Sem validacao de sessao em endpoint financeiro → CRITICO
- Cache financeiro sem invalidacao → ALTO
- Extrato sem separacao por periodo → MEDIO

Exemplo de Chave de Idempotencia
- debito-userId123-2026-inscricao-liga45
- credito-userId123-2026-rodada15-pontuacao
- estorno-userId123-2026-ref-debito-abc123

Referencias
- https://stripe.com/docs/idempotency (padrao da industria)
- https://martinfowler.com/articles/patterns-of-distributed-systems/idempotent-receiver.html
- OWASP: https://owasp.org/www-community/vulnerabilities/Insecure_Direct_Object_Reference

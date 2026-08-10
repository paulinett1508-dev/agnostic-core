# Zombie Code Checklist — Padrões por Categoria

Use este checklist pra guiar a auditoria. Marcar o que se aplicar ao projeto.

---

## 1. Kill incompleto (2º caminho ainda vivo)

- [ ] Feature removida do menu/UI mas a rota/endpoint que ela chamava continua acessível sem guarda nova
- [ ] Tool/function removida da lista enviada a um LLM, mas o system prompt não instrui a recusar o pedido — o modelo pode reconstruir o comportamento sem a tool
- [ ] Botão/link removido da tela mas o handler que ele disparava não tem checagem de feature ativa
- [ ] Registro com `ativo: false` (ou equivalente) mas outro consumidor lê o registro sem checar esse campo
- [ ] Cache/fallback legado ainda listado como fonte válida depois que a fonte primária foi descontinuada
- [ ] Cron job/scheduler desativado num arquivo de config, mas o binário/script que ele chamava ainda pode ser invocado manualmente sem o mesmo guard
- [ ] Feature "descontinuada" em um app/cliente mas o endpoint de API que ela consome serve qualquer chamador, não só aquele app

---

## 2. Flag substitui em vez de somar

- [ ] `if (modoTeste) { destino = X }` sobrescrevendo a lista real de destinatários, em vez de `destinos = [...real, ...teste]`
- [ ] Variável de ambiente de teste reaproveitando a MESMA chave/config de produção, em vez de uma isolada
- [ ] Qualquer `else`/branch que troca o alvo de um envio, gravação ou notificação em vez de adicionar uma cópia paralela
- [ ] Modo "dry-run" que na prática substitui a chamada real por uma simulada em um caminho, mas não nos outros que levam ao mesmo efeito
- [ ] Feature flag que funciona como toggle binário mas o código downstream assume que só existe um estado possível

---

## 3. Ressurreição via build/geração/sincronização

- [ ] Script de geração (codegen, submodule sync, build step) sobrescreve um arquivo que recebeu fix manual direto
- [ ] Fix aplicado só na cópia local/espelhada de um artefato gerado, não na fonte upstream que alimenta a regeneração
- [ ] Migration/seed reexecutada em cada deploy que reintroduz dado default por cima de dado corrigido
- [ ] Template/scaffold que recria um arquivo do zero a cada `init`/`generate`, apagando customização feita depois
- [ ] Pipeline de CI que reverte formatação/lint de um commit anterior porque roda em ordem diferente do esperado
- [ ] Cache de build (imagem Docker, bundle) servindo uma versão anterior porque a invalidação depende de um passo que não disparou

---

## 4. Doc/handoff/convenção órfã ainda alcançável

- [ ] Handoff, README ou changelog datado que contradiz a convenção atual, ainda no path padrão que ferramentas/agentes leem por default
- [ ] Comentário no código citando um mecanismo já substituído, sem nota de "descontinuado" ou data
- [ ] Duas fontes de verdade pra mesma decisão (uma atualizada, uma esquecida) sem uma apontar pra outra
- [ ] Skill/regra duplicada em dois lugares (ex: repo local + acervo compartilhado) que podem divergir sem aviso
- [ ] Onboarding/guia que descreve um fluxo antigo (deploy, auth, stack) que já foi trocado, sem nota de "obsoleto"

---

## 5. Recorrência (causa raiz não morta)

- [ ] Mesmo tipo de incidente aparece 2+ vezes no CHANGELOG/LESSONS/histórico de sessões, cada vez com um fix pontual diferente
- [ ] Fix anterior tratou o sintoma no ponto onde foi relatado, não o mecanismo que gera o sintoma em qualquer ponto
- [ ] Bug marcado "corrigido" sem verificação end-to-end real — declarado resolvido por leitura de código, nunca observado falhar de novo em produção
- [ ] Alarme/incidente crônico (ex: CI falhando sempre pelo mesmo motivo) tratado como ruído repetidas vezes em vez de removido na fonte

---

## Baixa confiança — cuidado antes de marcar como zumbi

Estes padrões PODEM ser decisão deliberada, não bug — sempre confirmar antes de reportar como achado:

- Feature flag desligada de propósito, aguardando decisão futura — não é zumbi enquanto ninguém a aciona por engano
- Doc histórico explicitamente marcado como "não seguir, é registro" — zumbi é o que contradiz a convenção **sem avisar** que é histórico
- Duplicação intencional entre ambientes (staging vs prod) com sincronização deliberada, não esquecida
- Branch morta que é, na verdade, ponto de extensão para uma variação futura já planejada (confirmar com o time antes de reportar)

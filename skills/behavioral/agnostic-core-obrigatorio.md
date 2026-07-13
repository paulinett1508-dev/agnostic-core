# Submódulo agnostic-core Obrigatório

Regra dura: nunca escrever código de implementação num repo sem antes confirmar que `.agnostic-core` existe ali como submódulo.

Fonte: decisão da constelação Amilcar, 2026-07-06 — debate sobre sessão isolada por corpo não enxergar padrão resolvido em outro corpo.

---

## A regra

Antes do primeiro commit de código de qualquer tarefa:

```bash
cat .gitmodules 2>/dev/null | grep agnostic-core || ls -la .agnostic-core 2>/dev/null
```

- **Se existir:** prosseguir normalmente. Consultar `.agnostic-core/skills/<categoria>` antes de implementar algo que "parece problema já resolvido".
- **Se não existir:** parar. Adicionar o submódulo primeiro:

```bash
git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
git submodule update --init --recursive
```

Só então prosseguir com a implementação.

## Por quê

Sessão dedicada a um corpo (planeta/estrela), por design, não enxerga padrão já resolvido em outro corpo — a biblioteca compartilhada é o mecanismo que resolve isso sem precisar de uma entidade vigiando tudo continuamente.

## Ao encerrar a sessão

Se algo produzido é um padrão de código genuinamente reutilizável entre corpos (não lógica de negócio específica deste repo), promover para `.agnostic-core` antes de sair — ver `workflow/fecharsessao.md`, passo "Promoção pro agnostic-core".

## Quando não se aplica

- **O próprio `agnostic-core`.** Este repo É a biblioteca — adicioná-lo como submódulo de si mesmo cria uma auto-referência recursiva (o clone `--recursive` passa a clonar o repo dentro dele mesmo). Ao trabalhar dentro do agnostic-core, nunca rode `git submodule add ...agnostic-core.git .agnostic-core`.
- Repos que são só conhecimento/documentação (ex.: fichas de domínio, specs avulsas) sem código de implementação.

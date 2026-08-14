# Migration Aplicada Nunca se Edita

Toda esteira de migrations séria guarda o checksum do arquivo aplicado e aborta
quando ele muda. Editar uma migration já aplicada não altera o passado: **trava o
futuro**, impedindo qualquer migration nova de rodar — no ambiente que já a aplicou
e em todo ambiente que receber o código.

O sintoma aparece longe da causa. Ninguém percebe no commit; percebe-se na próxima
atualização, possivelmente em outra máquina, possivelmente com outra pessoa
depurando.

---

## Como costuma acontecer

Quase nunca por descuido. Acontece por um raciocínio que parece correto:

> Encontrei um texto errado numa semente de dados dentro da migration antiga.
> Vou corrigir ali para que **instalações novas** já nasçam certas.

A intenção é boa e o efeito é destrutivo. A instalação nova de fato nasceria certa —
mas todas as existentes param.

Num caso real, o gatilho foi uma troca de marca: um agente achou o nome antigo numa
semente de `INSERT` e corrigiu o literal na migration de dois meses atrás. A esteira
inteira passou a abortar com `Checksum divergente`.

---

## A correção quando já aconteceu

1. Restaurar o arquivo byte a byte do commit anterior:
   ```bash
   git show <commit-que-editou>^:<caminho-da-migration> > <caminho-da-migration>
   ```
2. Criar uma **migration nova**, idempotente, com a mudança de dado. Idempotente de
   verdade: `WHERE valor = <antigo>`, para não sobrescrever quem já customizou.
3. Aplicar e confirmar que a esteira voltou a passar (`--dry-run` primeiro, se houver).

Alternativa que circula e deve ser último recurso: `UPDATE` do checksum direto na
tabela de controle. Destrava, mas passa por cima do mecanismo de integridade em vez
de restaurar o estado correto.

---

## Ao despachar sub-agente, diga as duas metades

"Não crie migration" **não cobre** "não edite as aplicadas" — e a leitura literal
já produziu o incidente descrito acima. Escreva as duas:

> NÃO crie migration. E NUNCA edite migration já aplicada — se precisar corrigir
> semente de migration antiga, a resposta é migration NOVA.

---

## A dívida por trás

Se isso já aconteceu duas vezes no mesmo repositório, o problema deixou de ser
disciplina e virou falta de guarda mecânica. A verificação de checksum em tempo de
execução **detecta no deploy e nunca no commit**. Um hook de pre-commit comparando
o hash dos arquivos de migration contra os aplicados — ou um passo de CI — move a
descoberta para o momento em que o conserto é barato.

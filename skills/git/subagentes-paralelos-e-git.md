# Sub-agentes em Paralelo e o Índice do Git

Paralelizar sub-agentes é certo para **edição** de arquivos disjuntos e errado para
**commit**: há um working tree só, logo um índice do git só. `git add` é global ao
repositório, não ao arquivo que o agente "acha" que é dele.

---

## O incidente que originou esta regra

Dois agentes trabalhando em frentes diferentes do mesmo repo, com posse de arquivo
declarada e respeitada — um em `cadastros.php`, outro em `config/auth.php`. Os dois
terminaram quase juntos e chamaram `git add` + `git commit` no mesmo instante. O
commit do primeiro **capturou o arquivo do segundo**.

Deu certo por um motivo só: o agente conferiu `git show --stat` depois de commitar,
viu arquivo e tamanho errados, desfez com `git reset --soft HEAD~1` e recommitou com
`git commit --only`. Sem essa conferência, teria ido para o histórico um commit
misturando duas frentes não relacionadas — difícil de reverter separadamente, e
pior ainda em repositório onde o working tree é o ambiente servido.

---

## As duas saídas

**1. Agentes editam, o controlador commita.** É a mais simples e a mais segura.
Escreva no briefing:

> NÃO COMMITE. Há outro agente no mesmo working tree e o índice do git é
> compartilhado; um commit seu captura o trabalho dele. Deixe as mudanças no
> working tree; o controlador commita.

**2. Agentes commitam com escopo explícito e conferem depois.** Use quando a
serialização custar caro:

```bash
git commit --only <arquivo1> <arquivo2> -m "..."
git show --stat HEAD    # obrigatório: confirma que só os previstos entraram
```

Nunca `git add .` nem `git add -A` em execução paralela. Se vier arquivo alheio:
`git reset --soft HEAD~1` (desfaz o commit, preserva index e working tree de ambos)
e recommite com `--only`.

**Um agente por vez pode commitar à vontade** — a regra vale só quando há
concorrência real.

---

## O princípio por trás

É o mesmo de "conferir o artefato, não o relatório da ferramenta": o comando ter
retornado sucesso não prova que fez o que você queria. `git commit` sempre "funciona";
a pergunta é *o que entrou*.

---

## Sinal de que a regra está sendo violada

- Commit com arquivos de duas frentes que não se relacionam.
- Mensagem de commit que descreve menos do que o diff contém.
- `git status` mostrando staged de algo que o agente atual não tocou.

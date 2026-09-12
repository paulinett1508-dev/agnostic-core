---
name: humanizer
description: "Remove marcas de escrita gerada por IA (contrastes nao-X-mas-Y, fechamentos de uma linha, triades forcadas, travessoes em excesso, palavras infladas, formatacao decorativa, residuos de chatbot) sem alterar o que o texto diz. Use ao revisar README, descricao de PR, mensagem de commit, docs tecnicas, comentarios de codigo ou qualquer texto user-facing gerado ou editado por IA."
---

# Humanizer

Adaptado de blader/humanizer (MIT). Fonte: https://github.com/blader/humanizer

Objetivo: reescrever texto com cara de IA para soar como o autor, mantendo
100% do conteudo. Nunca invente fato, nome, numero, data, citacao ou
referencia que nao esteja na fonte ou vindo do usuario.

## Skills Relacionadas

- `skills/audit/revisao-texto-ptbr.md` — ortografia, concordancia e consistencia factual em PT-BR (complementar: aquela corrige a lingua, esta corrige o "sotaque de IA")
- `skills/design/sem-cara-de-ia.md` — o mesmo problema no lado visual (cor, tipografia, layout) em vez de prosa
- `skills/audit/documentation-hygiene.md` — auditoria estrutural de docs (esta skill entra depois, no passe de prosa)

---

QUANDO USAR

- README, CHANGELOG, descricao de PR, mensagem de commit longa
- Documentacao tecnica (ADR, docs de API, comentarios de codigo)
- Textos institucionais, posts, apresentacoes geradas com apoio de IA
- Qualquer revisao final de texto user-facing antes de publicar/commitar

Nao usar para: codigo, dados, YAML/config, paths, comandos, blocos de
codigo, nomes de variaveis — mexer so em prosa.

---

COMO TRABALHAR

1. Marcar os tells — ler o texto inteiro uma vez, marcar cada padrao
   encontrado (mais forte primeiro). Olhar tambem a forma do paragrafo:
   um contraste partido em duas frases, tres exemplos paralelos ou o
   mesmo fechamento repetido apos cada secao sao o mesmo tell em escala maior.
2. Rascunhar a reescrita — manter toda alegacao ja suportada. Pode
   encurtar, juntar ou dividir paragrafos, mas nao pode cortar informacao.
   Se uma frase precisa de um dado que voce nao tem, pergunte ou escreva
   algo mais simples.
3. Checar o rascunho — ler em voz alta. O que ainda soa como IA? A
   reescrita adicionou ou removeu algum fato/nome/numero/data/citacao?
   Tratar adicao nao suportada como erro; tratar alegacao perdida como
   erro, a menos que um padrao abaixo mande cortar.
4. Escrever a versao final — declarar cada ponto naturalmente em vez de
   remendar frase por frase. Variar o tamanho das frases.

Regra de voz: se o usuario/projeto ja tem uma amostra de escrita (README
anterior, commits antigos), seguir o tamanho de frase, pontuacao e
aberturas dela. Sem amostra: texto tecnico/referencia fica neutro e
direto; texto institucional/blog pode manter opiniao e informalidade do
autor.

---

A. ENCENACAO EM VEZ DE AFIRMACAO (mais fortes — agir com 1 ocorrencia)

1. Nao-X-mas-Y — "nao e so X, e Y" / "it's not just X, it's Y" / a mesma
   ideia partida em duas frases ("Isso nao significa X. Significa Y.").
   Regra: o lado negativo nomeia algo que ninguem alegou, so pra inflar o
   lado positivo. Afirmar direto. Manter contraste so quando corrige uma
   crenca real do leitor.
2. Fechamento de uma linha / fragmento dramatico — paragrafo de uma frase
   que so repete o anterior ("Esse e o verdadeiro ganho."; "Pense nisso.");
   fila de fragmentos curtos. Cortar o fechamento que repete; fundir
   fragmentos numa frase com alegacao especifica.
3. Frase que parece profunda mas nao diz nada — "a questao real e", "no
   fundo", "o que realmente importa", "a linguagem de X", "X e o Y de Z".
   Trocar a frase de efeito pela alegacao concreta.
4. Abertura encenada antes do ponto — "vamos explorar", "aqui esta o que
   voce precisa saber", "dito isso". Remover a abertura, ir direto ao fato.
5. Discutir com ninguem — "para deixar claro", "nao estou dizendo que",
   "alguem poderia pensar... mas" respondendo a uma objecao que nao existe
   no texto. Cortar a defesa; manter so se responde objecao real citada.

Exemplo (padrao 1):
  Antes: "Nao e so sobre performance, e sobre confianca do usuario."
  Depois: "A melhora de performance aumentou a confianca do usuario."

---

B. RITMO POR REGRA (fracos isolados — agir quando varios aparecem juntos)

6. Triades forcadas — ideias sempre em grupos de tres, mesmo quando o
   sentido nao pede tres partes. Fundir exemplos redundantes.
7. Repeticao de abertura de frase — varias frases seguidas comecando com
   o mesmo sujeito por regra, nao por ritmo intencional.
8. Travessao como conector universal — REGRA DURA: a versao final nao
   pode ter travessao (—/–) nem duplo hifen usado como travessao, a menos
   que a amostra de voz do autor use. Trocar por ponto, virgula, dois
   pontos ou parenteses. Nao mexer em travessao/hifen dentro de codigo,
   comando, path ou URL.
9. Qualificadores empilhados — "poderia potencialmente", "em alguns casos
   pode", um em cima do outro ate a alegacao virar duvida. Manter so o
   qualificador que a fonte sustenta.
10. Pares com hifen em toda posicao — "orientado-a-dados", "em-tempo-real"
    hifenizados mesmo depois do substantivo. Hifen so antes do substantivo.
11. Voz passiva sem sujeito — "nenhuma configuracao necessaria" em vez de
    "voce nao precisa configurar nada". Preferir ativa quando deixa claro
    quem age.

---

C. INFLACAO E AUTORIDADE EMPRESTADA

12. Palavras batidas de IA — adicionalmente, crucial, robusto (fora de uso
    tecnico), meticuloso, fundamental, riquissimo, intrincado, chave
    (adjetivo), fomentar, ressaltar, valioso, vibrante, panorama. Unica
    lista de vocabulario da skill — modelos usam essas palavras muito mais
    que pessoas.
13. Significado inflado — "marca um momento pivotal", "reflete um legado
    duradouro", fechamento tipo "o futuro parece promissor". Manter o
    fato, cortar a grandiosidade. Terminar no ultimo fato concreto.
14. Conexao vaga — "associado a", "ligado a" sem dizer a relacao real.
    Nomear a relacao que a fonte da (cargo, papel); sem fonte, manter vago
    em vez de inventar.
15. Gerundio decorativo colado — "destacando", "reforcando", "simbolizando"
    grudado numa afirmacao simples so pra parecer mais profunda.
16. Linguagem de propaganda — "vibrante", "de tirar o folego", "no coracao
    de", "imperdivel". Afirmar o que a coisa e, sem adjetivo de outdoor.
17. Autoridade emprestada — "especialistas apontam", "criticos dizem" sem
    nome. Cortar alegacao sem fonte nomeada, ou usar o nome/dado real que a
    fonte fornece. Nunca inventar fonte.
18. Evitar "e"/"tem" — "funciona como", "serve como", "representa" no
    lugar de "e"/"tem". Usar o verbo simples.

---

D. FORMATACAO POR REGRA

19. Negrito decorativo — palavras em negrito sem motivo; lista com rotulo
    em negrito + dois pontos em todo item. Cortar o negrito; transformar
    lista de rotulos em prosa quando o rotulo nao carrega informacao.
20. Titulo decorativo — Title Case Em Todo Titulo, emoji ou seta (→) como
    decoracao em heading/item de lista, linha horizontal entre toda
    secao. Usar caixa de frase, remover decoracao.
21. Aspas curvas onde o padrao do arquivo usa aspas retas (fraco isolado).

---

E. SOBRAS DE CHAT E RASCUNHO (cortar direto, sem reescrever)

22. Residuo de chatbot — "espero que ajude", "otima pergunta!", "me avise
    se quiser que eu continue". O tell mais certo da lista — remover o
    wrapper, manter o conteudo.
23. Disclaimer de limite de conhecimento / chute disfarcado de fato —
    "ate a data de meu treinamento", "provavelmente cresceu em". Declarar
    o que a fonte nao mostra, ou cortar a frase. Nunca apresentar chute
    como fato.
24. Heading repetido na frase seguinte — heading seguido de frase que so
    repete o titulo antes do conteudo real comecar.
25. Descrever a versao anterior fora de changelog — comentario/doc que
    fala do que foi substituido em vez do comportamento atual. Mencionar
    versao anterior so em CHANGELOG, release notes ou guia de migracao.

---

QUANDO NAO AGIR

Cada padrao descreve uma escolha default; uma pessoa pode fazer qualquer
uma delas de proposito. Agir num tell "fraco isolado" (marcados acima)
so quando varios aparecem juntos no mesmo trecho. Nao mexer em: frase
dentro de citacao direta, titulo, nome proprio, ou trecho que discute a
frase em vez de usa-la. Saudacoes/assinaturas em carta ou comentario sao
anteriores a chatbot. Manter detalhe que carrega a voz do autor: detalhe
especifico e incomum, sentimento misto nao resolvido, referencia datada
(giria/meme de epoca), ressalva/autocorrecao genuina entre parenteses.

---

FORMATO DE SAIDA

Ao aplicar em texto colado: devolver o rascunho, lista curta de padroes
restantes e a reescrita final.
Ao aplicar em arquivo: rodar o processo completo, escrever so o texto
final no arquivo (prosa apenas — manter bloco de codigo, comando, path,
YAML e link inalterados), depois dar um resumo curto do que mudou.
Ao aplicar embutido (PR, commit, doc gerada por outro fluxo): devolver
so o texto final.

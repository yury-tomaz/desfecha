# Produto e protótipo: onde as definições moram

Status: em-execucao

## Objetivo

Hoje o produto cabe num arquivo só (`docs/PRODUCT_SENSE.md`) e não existe lugar para a interface antes do `frontend/`. Os dois vão crescer rápido assim que a fase de produto começar. Esta tarefa cria a estrutura e as regras antes do conteúdo:

- `docs/produto/`: um arquivo por tema de produto, com o estado atual e as decisões. Assim uma decisão tomada no refinamento de uma tarefa não morre dentro de um plano concluído.
- `prototipo/`: protótipo navegável da plataforma em HTML, CSS e JS puros. Ele vai na frente do `frontend/` e mostra como a plataforma deve ser. A documentação dele aponta as definições de marca, fontes e o resto.

## Contexto

- **Dependia de `2026-11-07-seguranca-base`, já satisfeita.** Os dois planos mexem em `scripts/verify.sh` e `AGENTS.md`. Aquele plano está `concluido` e o PR #3 entrou no `main` em 2026-11-08. Ele deixou:
  - O padrão das checagens: um script `scripts/<tema>-check.sh` com os casos em `scripts/<tema>-check.test.sh`, os dois chamados por um `step` no `scripts/verify.sh`. No `frontend/`, as regras locais do ESLint têm casos rodados por `pnpm test:sensores`. As checagens desta tarefa seguem um dos dois padrões.
  - `docs/SECURITY.md`, com as ameaças cobertas e a tabela "Camadas" de onde está cada checagem. A regra de o protótipo não ter dependência é uma defesa de cadeia de suprimentos.
  - Uma linha nova em "Onde está cada coisa" do `AGENTS.md` (`docs/SECURITY.md`). As duas entradas desta tarefa entram na mesma lista.
- **Por que `prototipo/` é uma pasta própria na raiz**, e não um anexo de cada decisão em `docs/produto/` nem um repositório à parte: um protótipo é a plataforma navegável inteira, com as telas ligadas entre si, e muda junto com o produto. Preso a decisões soltas, perde essa visão de conjunto. Em outro repositório, fica invisível para os agentes daqui e pede um segundo harness. Decisão do humano no refinamento (2026-11-08).
- **Por que um arquivo por tema, e não um por decisão:** com um arquivo por decisão, as decisões substituídas se acumulam e o agente precisa descobrir qual vale. Com um por tema, ele lê só o tema de que precisa e já encontra o estado atual. O histórico fica no git.
- **Formato de um tema** (`docs/produto/<tema>.md`): seções `## Estado atual`, `## Decisões` (cada item com data e motivo) e `## Perguntas em aberto`. Entra no arquivo o resultado de uma discussão e o porquê dele, nunca a transcrição.
- **`docs/PRODUCT_SENSE.md` continua sendo a porta de entrada.** Fica no mesmo caminho, porque `AGENTS.md` e as skills apontam para ele. Guarda a visão em uma página e um índice com um link para cada tema de `docs/produto/`.
- **Temas iniciais:** as 4 perguntas em aberto do `PRODUCT_SENSE.md` saem dele e vão para o tema a que pertencem: resolução (o que conta como "resolvido"), integrações (e-commerce e pagamento), ações da IA (o que executa sozinha e com quais limites) e LGPD (retenção, mascaramento, o que vai para o modelo). Os nomes dos arquivos ficam com quem executa.
- **Protótipo sem build e sem dependências:** nada de `package.json`, CDN de JS ou framework. É abrir o `index.html` no navegador. Isso o mantém fora do risco de cadeia de suprimentos tratado em `seguranca-base`. Uma fonte externa (ex.: Google Fonts) pode entrar quando a marca for definida.
- **O protótipo e o `frontend/` podem diferir, e é esperado.** O protótipo explora e o `frontend/` implementa o que foi escolhido. O que não pode acontecer é o `frontend/` importar arquivo do protótipo. Quando uma tela entra no `frontend/`, o exec-plan aponta para a tela correspondente no protótipo.
- **Marca, fontes e cores não existem ainda.** Defini-las é decisão de produto e fica para a fase de produto. Esta tarefa cria só o lugar e a regra: a documentação do protótipo diz onde essas definições ficam e que ainda estão por definir.
- **Regras conferidas por sensor.** Seguindo o padrão do harness (`2026-11-07-sensores-computacionais`), as regras novas que dá para conferir por código entram em `scripts/verify.sh`, com mensagens de erro escritas para o agente (o que está errado e como corrigir).

## Critérios de aceite

- [ ] `docs/produto/` existe com os temas iniciais (ver Contexto), cada um com as três seções do formato. As 4 perguntas em aberto saíram do `PRODUCT_SENSE.md` e estão nos temas. Comprovado lendo os arquivos.
- [ ] `docs/PRODUCT_SENSE.md` tem um índice com um link para cada tema. `scripts/verify.sh` falha quando um arquivo de `docs/produto/` não está no índice, quando um link do índice aponta para um arquivo que não existe e quando um tema não tem as três seções. Comprovado criando um tema fora do índice, um link quebrado e um tema sem seção: cada caso falha com mensagem que diz como corrigir, e reverter faz passar.
- [ ] `prototipo/` tem um `index.html` navegável (pode ser só a página inicial com a lista de telas, vazia) e um documento que explica o propósito, a regra de não ter build nem dependências, e onde ficam marca, fontes e cores (ainda por definir). Comprovado abrindo o `index.html` direto no navegador, sem servidor.
- [ ] `scripts/verify.sh` falha quando um arquivo do `frontend/` importa algo de `prototipo/`. Comprovado com um import de propósito num `.ts` e num `.svelte`: falha com mensagem que diz como corrigir, e reverter faz passar.
- [ ] `scripts/verify.sh` falha quando aparece `package.json` ou `<script src="http...">` dentro de `prototipo/`. Comprovado com um caso de cada.
- [ ] A tabela "Camadas" do `docs/SECURITY.md` tem uma linha para a checagem de que o protótipo não tem dependências, dizendo onde ela está. Comprovado lendo o arquivo.
- [ ] A skill `refinar` lê o tema relevante de `docs/produto/` e tem uma pergunta a mais no ciclo: se a tarefa toma uma decisão de produto que vale além dela, a decisão é escrita no tema certo, e não só no plano. Comprovado lendo a skill.
- [ ] O `AGENTS.md` aponta para `docs/produto/` e `prototipo/` em "Onde está cada coisa". Comprovado lendo o arquivo.
- [ ] `scripts/verify.sh` passa local e no CI. Comprovado com `gh run list` no push do branch da tarefa.

## Fora de escopo

- Definir marca, fontes, cores ou qualquer conteúdo de design.
- Telas do protótipo além da página inicial.
- Responder as perguntas em aberto de produto ou criar decisões de produto.
- Skill para agentes discutirem ou escolherem o que construir.
- Mudar o `frontend/` além do que a checagem de import exigir.
- Build, servidor, framework ou dependência no protótipo.
- Mudar a skill `executar` ou a `revisar`.

## Passos

- [ ] `docs/produto/` com os temas iniciais e as perguntas em aberto movidas
- [ ] Índice no `PRODUCT_SENSE.md` e checagem do índice e das seções em `scripts/verify.sh`
- [ ] `prototipo/` com o `index.html` e o documento de propósito e marca
- [ ] Checagens do protótipo em `scripts/verify.sh` (import pelo `frontend/`, sem dependências) e a linha em "Camadas" do `docs/SECURITY.md`
- [ ] Pergunta nova na skill `refinar`
- [ ] `AGENTS.md`

## Log de progresso

- 2026-11-07: rascunho criado.
- 2026-11-08: refinado e aprovado.
- 2026-11-08: `seguranca-base` concluído e no `main` (PR #3). Contexto atualizado com o que ele deixou e com o motivo de `prototipo/` ficar na raiz, que tinha ficado só na conversa do refinamento. Critério novo, aprovado pelo humano: a checagem do protótipo sem dependências entra na tabela "Camadas" do `docs/SECURITY.md`, porque é lá que se procura onde está cada defesa de cadeia de suprimentos.
- 2026-11-08: execução iniciada.

## Log de decisões

## Perguntas em aberto

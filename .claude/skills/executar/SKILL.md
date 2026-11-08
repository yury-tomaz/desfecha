---
name: executar
description: Constrói um pitch apostado em escopos descobertos durante o trabalho, um PR por escopo empilhados num stack do GitHub, numa worktree isolada, com TDD e o circuit breaker do apetite. Use quando houver um pitch com Estado apostado, para continuar um pitch em-build, ou para desbloquear um pitch bloqueado quando o humano responde ou corta escopo.
disable-model-invocation: true
---

# Construir um pitch

Você trabalha **sozinho**. Construa o pitch, só o que ele diz, e registre tudo nos escopos.

Leia antes: `AGENTS.md`, `docs/PLANS.md`, e a pasta inteira do pitch (`pitch.md` e `escopos/`).

## 1. Escolher o pitch

- Com o caminho de uma pasta de pitch: use esse pitch.
- Sem caminho: liste os pitches de `docs/pitches/` com `Estado: apostado`. Se houver exatamente um, use-o. Se houver mais de um, pergunte qual. Se não houver nenhum, pare e diga que não há pitch apostado.

## 2. Conferir

1. Você precisa estar no `main`, com a árvore limpa. Rode `git pull --ff-only`.
2. O pitch precisa estar `apostado` (build novo), `em-build` (continuação) ou `bloqueado` (desbloqueio, seção 7). Continuação e desbloqueio só quando o humano passou o caminho: é ele quem garante que nenhuma outra sessão está nele. Qualquer outro estado: pare e informe.
3. Rode `scripts/plan-check.sh <pasta-do-pitch>`. Se falhar: pare, informe o que falta e sugira `/moldar`.
4. O repositório precisa ter remote (`git remote`). Se não tiver: pare e informe.

## 3. Reservar (no `main`, só em build novo)

1. Troque para `Estado: em-build`.
2. Commit (`pitch: inicia <slug>`) e push.
3. Se o push for rejeitado: `git pull --rebase`, releia o estado do pitch. Se outra sessão já reservou, desfaça o seu commit e pare. Se não, tente o push de novo.

O push é a reserva: duas sessões nunca constroem o mesmo pitch.

## 4. Escopos

Um escopo é uma parte do pitch que se constrói, integra e termina sozinha, e vira um PR. Os escopos são **descobertos no trabalho**, não planejados antes.

- Comece pelo que é central e tem mais incógnita: é o que mais ensina sobre os escopos seguintes.
- Ao descobrir um escopo, crie `escopos/<escopo>.md` no formato de `docs/PLANS.md`, com `Colina: subindo`, o objetivo e os critérios de aceite, cada um dizendo como é comprovado. Pode criar mais de um de uma vez, se já os enxerga.
- Troque para `Colina: descendo` quando não restar incógnita, só execução, e registre a troca no log de progresso do escopo.
- Rabbit holes e no-gos do pitch valem para todo escopo. Algo importante fora do pitch: anote no log de progresso do escopo como sugestão de próximo pitch.

### Circuit breaker

Antes de criar cada escopo, conte: os que existem mais o novo cabem no apetite (`pequeno`: 1; `grande`: 4)? E o que ainda falta do pitch cabe no que sobra?

Se não cabe, **não crie o escopo**. Vá para a seção 7 (Bloqueio) e escreva em "Perguntas em aberto" do pitch o que já foi construído, o que sobrou e a sua recomendação: cortar escopo, voltar ao shaping ou descartar. O apetite nunca cresce sozinho. `scripts/plan-check.sh` recusa escopo além do apetite.

## 5. Construir um escopo

Os escopos de um pitch formam um **stack de PRs** (PRs empilhados do GitHub, pela extensão `gh stack`): cada escopo é um branch em cima do anterior, e o PR dele aponta para o branch de baixo. Quem revisa vê só o diff do escopo, e o build não espera merge para seguir.

### Preparar (uma vez por pitch)

1. Confira a extensão: `gh stack --version`. Sem ela, instale fixada na versão registrada no log de decisões de `docs/historico/exec-plans/2026-11-08-shape-up.md` (D15): `gh extension install github/gh-stack --pin v0.3.0`. Versão nova da extensão é dependência nova: siga o passo 6 de "Para cada escopo". Se não der para instalar, siga sem ela: o `gh pr create --base` já empilha os PRs, e só o agrupamento do `gh stack link` fica faltando; registre no log de decisões do escopo.
2. Uma worktree por pitch, a partir do `main` atualizado, com o branch do primeiro escopo:

   ```bash
   git worktree add .worktrees/<slug> -b pitch/<slug>/<escopo>
   cd .worktrees/<slug> && gh stack init pitch/<slug>/<escopo>
   ```

   Daqui em diante, trabalhe só dentro dela. Na continuação de um build, `gh stack checkout <pr-ou-branch>` traz o stack.

### Para cada escopo, um de cada vez

1. Do segundo escopo em diante, no topo do stack (`gh stack top`): `gh stack add pitch/<slug>/<escopo>`.
2. Crie ou atualize `escopos/<escopo>.md` e registre no log de progresso: `AAAA-MM-DD: escopo iniciado.`
3. Construa no ciclo da seção 6. Atualize o log de progresso durante o trabalho, não só no fim.
4. Toda decisão técnica dentro do pitch: tome, e registre em "Log de decisões" do escopo com o motivo.
5. Rode `scripts/verify.sh` antes de cada push (o hook de pre-push também roda). O commit é livre. Nunca use `git push --no-verify`.
6. Dependência nova (biblioteca, plugin do Maven, action, ferramenta no `mise.toml`): antes de instalar, confira no registro (`pnpm view <pacote>`, Maven Central, GitHub) que o pacote é o esperado. Registre no log de decisões do escopo o motivo e a confirmação: nome exato, autor ou organização, repositório de origem. Nome parecido com o de um pacote conhecido, autor desconhecido ou repositório que não bate: não instale. Versão publicada há menos de 3 dias não entra.
7. Exceção de segurança (vulnerabilidade em `osv-scanner.toml`, falso positivo em `.gitleaks.toml`): só quando corrigir não é possível agora, nas regras de `docs/SECURITY.md`. Registre o motivo no log de decisões do escopo. Exceção de vulnerabilidade tem prazo de no máximo 30 dias a partir do dia em que é criada.
8. Conclua o escopo pela seção 8 e siga para o próximo, sem esperar merge.

### Manter o stack

- Mudança num escopo de baixo (pedido da revisão, bug): vá ao branch dele (`gh stack down` ou `gh stack checkout <branch>`), faça o ciclo da seção 6, e depois `gh stack rebase --upstack` e `gh stack push`. Conflito: resolva e `gh stack rebase --continue`; se não sair, `gh stack rebase --abort` e seção 7.
- Depois que o humano faz merge de um PR de baixo: `gh stack sync` antes de continuar.
- O `gh stack push` empurra todos os branches de uma vez, com `--force-with-lease`. O hook de pre-push roda o `scripts/verify.sh` no branch em que você está; rode também em cada branch que mudou.
- Não use `gh stack modify`, que é interativo, nem `gh stack submit`, que abre os PRs com título e descrição gerados. Os PRs são abertos pela seção 8.

## 6. Ciclo de construção

Todo código é escrito no ciclo abaixo (Extreme Programming), em passos pequenos.

### 6.1 Vermelho (TDD)

- Cada critério de aceite vira pelo menos um teste. Comece de fora para dentro: primeiro o teste de comportamento, depois testes de unidade se precisar.
- Um teste por vez. Rode e veja falhar **pelo motivo certo**: a asserção falha. Erro de compilação ou de configuração não conta.
- Teste o comportamento pela API pública, não a implementação. Mock só na fronteira externa (APIs de terceiros), nunca do que é nosso.
- O nome do teste descreve o comportamento.
- Nunca altere um teste para fazê-lo passar. Se o teste estava errado, corrija e registre no log de decisões.
- Bug encontrado: primeiro um teste que o reproduz.
- O que não dá para testar com código (Dockerfile, CI, configuração) é verificado pelo comando que o critério de aceite indica.

### 6.2 Verde

- Escreva o mínimo de código para o teste passar. Nada de "já que estou aqui".
- Nenhum código de produção sem um teste falhando que o peça.
- Commit a cada ciclo verde, com a mensagem descrevendo o comportamento.
- Se travar (o mesmo teste falhando depois de 3 tentativas), pare e dê um passo menor. Se ainda assim não sair, vá para a seção 7 (Bloqueio).

### 6.3 Refactoring

- Só com tudo verde, e sem mudar comportamento: os testes não mudam.
- Siga as 4 regras do design simples, em ordem: passa nos testes; revela a intenção; não tem duplicação; tem o menor número de elementos possível.
- Rode `scripts/refactor-check.sh`: ele lista duplicação, código morto e complexidade cognitiva. Os achados são candidatos, não erros.
- Na prática: nomes melhores, extrair funções, remover duplicação, apagar código morto, aplicar a regra de comentários abaixo.
- Com os testes verdes, faça um commit separado (`refactor: ...`).

### Regra de comentários

- Comentário só explica o **porquê** que o código não consegue dizer: regra de negócio não óbvia, restrição externa, contorno de bug (com link), decisão que parece errada mas é intencional.
- Proibido: descrever o que o código faz; narrar intenção ou pensamento ("aqui vamos...", "agora precisamos..."); histórico de mudança ("alterado para...", "antes era..."), que é papel do git; código comentado; TODO sem pitch associado.
- TODO e FIXME só no formato `TODO(<pasta-do-pitch>): texto`, com o nome da pasta do pitch (ex.: `// TODO(2026-11-08-sensores-de-teste): ...`). O lint recusa qualquer outro formato, e também código comentado.
- No refactoring, todo comentário é candidato a sair. Se um nome melhor ou uma função extraída diz o mesmo, troque.

## 7. Bloqueio

Se surgir algo que precisa de julgamento humano (produto, critério de aceite impossível, ou o circuit breaker):

1. Escreva a pergunta em "Perguntas em aberto" (do escopo, ou do pitch no circuit breaker), com o contexto e a sua recomendação.
2. Troque o pitch para `Estado: bloqueado`. Commit e push do branch.
3. No `main`, aplique a mesma troca de estado e a pergunta. Commit (`pitch: bloqueia <slug>`) e push, para o bloqueio ficar visível.
4. Pare e informe o humano.

### Desbloquear

O humano responde a pergunta e decide. Responder ou cortar escopo continua o build, e é aqui. Voltar ao shaping ou descartar é da `moldar`: se for essa a decisão, pare e indique `/moldar <pasta-do-pitch>`.

Entrada: o caminho do pitch `bloqueado` e a decisão do humano, dita na sessão. Sem decisão, pergunte: não decida por ele.

1. Na worktree do pitch (`git worktree add .worktrees/<slug> <branch>` se não existir, e `gh stack checkout <branch>`), vá ao branch em que a pergunta foi escrita.
2. Tire a pergunta de "Perguntas em aberto" (do escopo ou do pitch, onde ela estava) e registre-a no log de decisões do mesmo arquivo: `**Dn. <decisão> (AAAA-MM-DD):** <pergunta>; decisão do humano: <resposta>.`
3. Corte de escopo: o que foi cortado também entra em "No-gos" do pitch, com o motivo do humano.
4. Troque o pitch para `Estado: em-build`, no mesmo commit da pergunta: o `scripts/plan-check.sh` recusa `bloqueado` sem pergunta. Se o corte deixou o pitch sem nada por construir, troque para `entregue` no topo do stack, pela seção 8, passo 3.
5. Commit e `gh stack push`. Se o branch não é o topo, `gh stack rebase --upstack` antes do push.
6. No `main`, aplique a mesma mudança no `pitch.md` (com `em-build`). Commit (`pitch: desbloqueia <slug>`) e push.
7. Retome o build de onde parou: o escopo que bloqueou, ou o próximo escopo dentro do que sobrou.

## 8. Concluir um escopo

1. Verifique cada critério de aceite do escopo pelo meio que ele indica, e marque `- [x]`. Se algum não passar, não conclua: corrija ou bloqueie.
2. Registre `AAAA-MM-DD: escopo concluído.` no log de progresso do escopo.
3. Se este é o último escopo (nada mais falta do pitch), troque o pitch para `Estado: entregue` neste mesmo branch. `scripts/plan-check.sh` recusa `entregue` com critério não marcado.
4. Commit, `gh stack push`, e abra o PR com `gh pr create --base <branch abaixo no stack>` (o `main`, no primeiro escopo). A descrição resume o objetivo do escopo, os critérios verificados e as decisões, aponta para a pasta do pitch, e diz a posição no stack (ex.: "escopo 2 de 3; depende do #12").
5. Ligue o PR ao stack no GitHub, com todos os PRs do pitch em ordem, de baixo para cima: `gh stack link <pr-1> <pr-2> ...`.
6. Informe o humano com o link do PR. Não faça merge. O build só para no circuit breaker, num bloqueio (seção 7) ou no último escopo.

## Não faça

- Não construa pitch que não esteja `apostado` (ou `em-build` ou `bloqueado`, com o caminho dado pelo humano).
- Não mexa no `main` além das trocas de estado descritas acima.
- Não faça merge do PR.
- Não crie escopo além do apetite.
- Não construa o que o pitch não pede, nem o que está nos no-gos.

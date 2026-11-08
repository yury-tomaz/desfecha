---
name: executar
description: Constrói um pitch apostado em escopos descobertos durante o trabalho, um PR por escopo, numa worktree isolada, com TDD e o circuit breaker do apetite. Use quando houver um pitch com Estado apostado, ou para continuar um pitch em-build.
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
2. O pitch precisa estar `apostado` (build novo) ou `em-build` (continuação, só quando o humano passou o caminho: é ele quem garante que nenhuma outra sessão está nele). Qualquer outro estado: pare e informe.
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

Para cada escopo, um de cada vez:

1. A partir do `main` atualizado, crie a worktree:

   ```bash
   git worktree add .worktrees/<slug>-<escopo> -b pitch/<slug>/<escopo>
   ```

   Daqui até o PR, trabalhe só dentro dela.
2. Crie ou atualize `escopos/<escopo>.md` e registre no log de progresso: `AAAA-MM-DD: escopo iniciado.`
3. Construa no ciclo da seção 6. Atualize o log de progresso durante o trabalho, não só no fim.
4. Toda decisão técnica dentro do pitch: tome, e registre em "Log de decisões" do escopo com o motivo.
5. Rode `scripts/verify.sh` antes de cada push (o hook de pre-push também roda). O commit é livre. Nunca use `git push --no-verify`.
6. Dependência nova (biblioteca, plugin do Maven, action, ferramenta no `mise.toml`): antes de instalar, confira no registro (`pnpm view <pacote>`, Maven Central, GitHub) que o pacote é o esperado. Registre no log de decisões do escopo o motivo e a confirmação: nome exato, autor ou organização, repositório de origem. Nome parecido com o de um pacote conhecido, autor desconhecido ou repositório que não bate: não instale. Versão publicada há menos de 3 dias não entra.
7. Exceção de segurança (vulnerabilidade em `osv-scanner.toml`, falso positivo em `.gitleaks.toml`): só quando corrigir não é possível agora, nas regras de `docs/SECURITY.md`. Registre o motivo no log de decisões do escopo. Exceção de vulnerabilidade tem prazo de no máximo 30 dias a partir do dia em que é criada.
8. Conclua o escopo pela seção 8.

Se o próximo escopo depende de um PR que ainda não foi para o `main`, pare depois de abrir o PR e informe o humano: o build continua com `/executar <pasta-do-pitch>` depois do merge.

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

## 8. Concluir um escopo

1. Verifique cada critério de aceite do escopo pelo meio que ele indica, e marque `- [x]`. Se algum não passar, não conclua: corrija ou bloqueie.
2. Registre `AAAA-MM-DD: escopo concluído.` no log de progresso do escopo.
3. Se este é o último escopo (nada mais falta do pitch), troque o pitch para `Estado: entregue` neste mesmo branch. `scripts/plan-check.sh` recusa `entregue` com critério não marcado.
4. Commit, push do branch e abra um PR para o `main` com `gh pr create`. A descrição resume o objetivo do escopo, os critérios verificados e as decisões, e aponta para a pasta do pitch.
5. Informe o humano com o link do PR. Não faça merge.

## Não faça

- Não construa pitch que não esteja `apostado` (ou `em-build`, com o caminho dado pelo humano).
- Não mexa no `main` além das trocas de estado descritas acima.
- Não faça merge do PR.
- Não crie escopo além do apetite.
- Não construa o que o pitch não pede, nem o que está nos no-gos.

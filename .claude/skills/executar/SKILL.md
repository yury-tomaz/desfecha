---
name: executar
description: Executa um exec-plan com status "refinado" numa worktree isolada, do início ao PR. Use quando o humano pedir para executar uma tarefa planejada.
disable-model-invocation: true
---

# Executar um exec-plan

Você trabalha **sozinho**. Siga o plano, só o escopo dele, e registre tudo no próprio plano.

Leia antes: `AGENTS.md`, `docs/PLANS.md`, e o plano.

## 1. Escolher o plano

- Com um caminho: use esse plano.
- Sem caminho: liste os planos de `docs/exec-plans/active/` com `Status: refinado`. Se houver exatamente um, use-o. Se houver mais de um, pergunte qual. Se não houver nenhum, pare e diga que não há plano refinado.

## 2. Conferir

1. Você precisa estar no `main`, com a árvore limpa. Rode `git pull --ff-only`.
2. O plano precisa estar com `Status: refinado`. Qualquer outro status: pare e informe.
3. Rode `scripts/plan-check.sh <plano>`. Se falhar: pare, informe o que falta e sugira `/refinar`.
4. O repositório precisa ter remote (`git remote`). Se não tiver: pare e informe.

## 3. Reservar (no `main`, antes da worktree)

1. Troque para `Status: em-execucao` e registre no log de progresso: `AAAA-MM-DD: execução iniciada.`
2. Commit (`plano: inicia <slug>`) e push.
3. Se o push for rejeitado: `git pull --rebase`, releia o status do plano. Se outra sessão já reservou, desfaça o seu commit e pare. Se não, tente o push de novo.

O push é a reserva: duas sessões nunca executam o mesmo plano.

## 4. Criar a worktree

```bash
git worktree add .worktrees/<slug> -b plano/<slug>
```

Daqui em diante, trabalhe só dentro de `.worktrees/<slug>`.

## 5. Executar

- Siga os passos do plano. Marque cada passo `- [x]` ao concluir.
- Atualize o log de progresso durante o trabalho, não só no fim.
- Toda decisão técnica dentro do escopo: tome, e registre em "Log de decisões" com o motivo.
- O que estiver em "Fora de escopo" não é feito, mesmo que pareça útil. Se achar algo importante fora do escopo, anote em "Log de progresso" como sugestão de próxima tarefa.
- Rode `scripts/verify.sh` antes de cada push (o hook de pre-push também roda). O commit é livre. Nunca use `git push --no-verify`.

Todo código é escrito no ciclo abaixo (Extreme Programming), em passos pequenos.

### 5.1 Vermelho (TDD)

- Cada critério de aceite vira pelo menos um teste. Comece de fora para dentro: primeiro o teste de comportamento, depois testes de unidade se precisar.
- Um teste por vez. Rode e veja falhar **pelo motivo certo**: a asserção falha. Erro de compilação ou de configuração não conta.
- Teste o comportamento pela API pública, não a implementação. Mock só na fronteira externa (APIs de terceiros), nunca do que é nosso.
- O nome do teste descreve o comportamento.
- Nunca altere um teste para fazê-lo passar. Se o teste estava errado, corrija e registre no log de decisões.
- Bug encontrado: primeiro um teste que o reproduz.
- O que não dá para testar com código (Dockerfile, CI, configuração) é verificado pelo comando que o critério de aceite indica.

### 5.2 Verde

- Escreva o mínimo de código para o teste passar. Nada de "já que estou aqui".
- Nenhum código de produção sem um teste falhando que o peça.
- Commit a cada ciclo verde, com a mensagem descrevendo o comportamento.
- Se travar (o mesmo teste falhando depois de 3 tentativas), pare e dê um passo menor. Se ainda assim não sair, vá para a seção 6 (Bloqueio).

### 5.3 Refactoring

- Só com tudo verde, e sem mudar comportamento: os testes não mudam.
- Siga as 4 regras do design simples, em ordem: passa nos testes; revela a intenção; não tem duplicação; tem o menor número de elementos possível.
- Rode `scripts/refactor-check.sh`: ele lista duplicação, código morto e complexidade cognitiva. Os achados são candidatos, não erros.
- Na prática: nomes melhores, extrair funções, remover duplicação, apagar código morto, aplicar a regra de comentários abaixo.
- Com os testes verdes, faça um commit separado (`refactor: ...`).

### Regra de comentários

- Comentário só explica o **porquê** que o código não consegue dizer: regra de negócio não óbvia, restrição externa, contorno de bug (com link), decisão que parece errada mas é intencional.
- Proibido: descrever o que o código faz; narrar intenção ou pensamento ("aqui vamos...", "agora precisamos..."); histórico de mudança ("alterado para...", "antes era..."), que é papel do git; código comentado; TODO sem tarefa associada.
- TODO e FIXME só no formato `TODO(<slug-do-plano>): texto`, com o nome do arquivo do plano sem `.md` (ex.: `// TODO(2026-11-07-sensores-computacionais): ...`). O lint recusa qualquer outro formato, e também código comentado.
- No refactoring, todo comentário é candidato a sair. Se um nome melhor ou uma função extraída diz o mesmo, troque.

## 6. Bloqueio

Se surgir algo que precisa de julgamento humano (produto, escopo, ou um critério de aceite impossível):

1. Escreva a pergunta em "Perguntas em aberto", com o contexto e a sua recomendação.
2. Troque para `Status: bloqueado`. Commit e push do branch.
3. No `main`, aplique a mesma troca de status e a pergunta no plano. Commit (`plano: bloqueia <slug>`) e push, para o bloqueio ficar visível.
4. Pare e informe o humano.

## 7. Concluir

1. Verifique cada critério de aceite pelo meio que ele indica, e marque `- [x]`. Se algum não passar, não conclua: corrija ou bloqueie.
2. Troque para `Status: concluido`, registre `AAAA-MM-DD: concluído.` no log de progresso, e mova o plano com `git mv` para `docs/exec-plans/completed/`.
3. Commit, push do branch e abra um PR para o `main` com `gh pr create`. A descrição do PR resume o objetivo, os critérios verificados e as decisões, e aponta para o plano.
4. Informe o humano com o link do PR. Não faça merge.

## Não faça

- Não execute plano que não esteja `refinado`.
- Não mexa no `main` além das trocas de status descritas acima.
- Não faça merge do PR.
- Não amplie o escopo.

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
- Atualize o log de progresso durante o trabalho, não só no fim. Faça commits pequenos no branch.
- Toda decisão técnica dentro do escopo: tome, e registre em "Log de decisões" com o motivo.
- O que estiver em "Fora de escopo" não é feito, mesmo que pareça útil. Se achar algo importante fora do escopo, anote em "Log de progresso" como sugestão de próxima tarefa.
- Se existir comando de verificação no `AGENTS.md`, rode-o antes de cada commit.

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

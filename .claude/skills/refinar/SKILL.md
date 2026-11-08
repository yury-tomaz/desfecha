---
name: refinar
description: Cria ou refina um exec-plan junto com o humano até ele aprovar como "refinado". Use quando o humano quiser definir uma nova tarefa ou revisar um plano em rascunho.
disable-model-invocation: true
---

# Refinar um exec-plan

Você trabalha **com o humano**. O objetivo é deixar um plano pronto para outra sessão executar sem precisar perguntar nada. Você não escreve código nesta skill.

Leia antes: `AGENTS.md`, `docs/PLANS.md`, `docs/PRODUCT_SENSE.md`.

## Entrada

- Com um caminho de plano: refine esse plano.
- Sem caminho: pergunte ao humano qual é a tarefa e crie `docs/exec-plans/active/<AAAA-MM-DD>-<slug>.md` no formato de `docs/PLANS.md`, com `Status: rascunho`.

## Ciclo

1. Rode `scripts/plan-check.sh <plano>` e anote o que falta na estrutura.
2. Revise o conteúdo, além da estrutura:
   - O objetivo diz o que muda e por quê?
   - O contexto tem tudo o que uma sessão **sem memória desta conversa** precisa e não está no código?
   - Cada critério de aceite é verificável e diz como (teste ou comando)?
   - O "fora de escopo" fecha as portas óbvias de aumento de escopo?
   - O plano conflita com `docs/PRODUCT_SENSE.md` ou com algum plano em `active/`?
   - A tarefa é pequena o bastante para uma execução só? Se não for, proponha dividir.
3. Leve ao humano **uma pergunta por vez**, curta, com a sua recomendação. Decisões técnicas que quem executa pode tomar sozinho não viram pergunta: deixe para o log de decisões da execução.
4. Atualize o plano com cada resposta.
5. Repita até `scripts/plan-check.sh` passar e não restar nenhuma lacuna.

## Aprovação

- Só o humano aprova. Mostre o plano final e pergunte se ele aprova como `refinado`.
- Com a aprovação explícita:
  1. Troque para `Status: refinado` e registre no log de progresso: `AAAA-MM-DD: refinado e aprovado.`
  2. Rode `scripts/plan-check.sh <plano>` de novo. Tem que passar.
  3. Commit no `main` (`plano: refina <slug>`) e push.
- Sem aprovação, o plano continua `rascunho`.

## Não faça

- Não escreva código nem crie worktree.
- Não marque `refinado` sem a aprovação explícita do humano.
- Não encha o plano com o que dá para descobrir lendo o código.

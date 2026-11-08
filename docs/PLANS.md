# Planos de execução

Todo trabalho anda por tarefa, e toda tarefa tem um exec-plan versionado no repositório.

## Ciclo

- Em andamento: `docs/exec-plans/active/<AAAA-MM-DD>-<slug>.md`
- Concluído: mover para `docs/exec-plans/completed/` quando todos os critérios de aceite estiverem verificados.

## Status

A linha `Status:` logo abaixo do título diz em que ponto o plano está.

| Status | Significa | Quem muda |
|---|---|---|
| `rascunho` | Ainda sendo definido. Não pode ser executado. | Skill `refinar` |
| `refinado` | Aprovado pelo humano. Pronto para executar. | Só o humano aprova, a skill `refinar` grava |
| `em-execucao` | Uma sessão reservou e está executando. | Skill `executar`, com commit e push no `main` |
| `bloqueado` | Parou numa pergunta que precisa de julgamento humano. | Skill `executar` |
| `concluido` | Critérios verificados, PR aberto. | Skill `executar` |

`scripts/plan-check.sh <plano>` verifica a estrutura mínima. Um plano só pode virar `refinado` se passar nele.

## Skills

- `/refinar`: cria ou refina um plano junto com o humano, até ele aprovar.
- `/executar`: executa um plano `refinado` numa worktree isolada.

## Formato

```markdown
# <Tarefa>

Status: rascunho

## Objetivo
O que muda e por quê.

## Contexto
O que quem executa precisa saber e não está no código.

## Critérios de aceite
Lista verificável. Cada item diz como é comprovado (teste ou comando).

## Fora de escopo

## Passos
- [ ] passo

## Log de progresso
- AAAA-MM-DD: o que foi feito.

## Log de decisões
- **D1. <decisão>**: motivo.

## Perguntas em aberto
Só o que precisa de julgamento humano.
```

## Regras

- Execute só o que está no exec-plan. Fora de escopo é fora de escopo.
- Decisões técnicas dentro do escopo são tomadas por quem executa e registradas com motivo no log de decisões.
- O que precisa de julgamento humano vai para "Perguntas em aberto", e a execução para naquele ponto.
- O log de progresso é atualizado durante a tarefa, não só no fim.

# Sensores de teste: executor no frontend, cobertura e mutação

Status: rascunho

## Objetivo

A skill `executar` cobra TDD em todo código, mas o `frontend/` não tem executor de testes: hoje o ciclo vermelho, verde e refactor não tem onde rodar desse lado. E nos dois lados nada confere se os testes testam de verdade. Esta tarefa põe o executor no frontend e dois sensores no `scripts/verify.sh`, cobertura mínima e teste de mutação, para o TDD ser cobrado por código e não só pela skill.

## Contexto

- Origem: sugestão de próxima tarefa de `2026-11-07-sensores-computacionais`.
- O frontend só tem `pnpm test:sensores` (`node:test` com o `RuleTester` do ESLint, ver D9 daquele plano), que testa as regras locais do lint, não código de produto.
- O backend já tem JUnit pelo `spring-boot-starter-*-test`.
- Candidatos já citados: Vitest no frontend; PIT (backend) e Stryker (frontend) para mutação. Toda dependência nova segue a regra da skill `executar` (nome, autor e repositório conferidos, versão com 3 dias ou mais).
- Teste de mutação é lento. Rodar a cada push pode deixar o `verify.sh` pesado; dá para limitar aos arquivos alterados ou deixar fora do caminho bloqueante, como o `scripts/refactor-check.sh`.

## Critérios de aceite

- [ ] `pnpm test` roda os testes do frontend com Vitest, e o `scripts/verify.sh` chama esse comando. Comprovado com um teste de exemplo que falha de propósito: o `verify.sh` falha, e reverter faz passar.
- [ ] O `scripts/verify.sh` falha quando a cobertura cai abaixo do mínimo definido, nos dois lados, com mensagem que diz como corrigir. Comprovado baixando a cobertura de propósito.
- [ ] Teste de mutação roda nos dois lados, com o comportamento (bloqueante ou relatório) decidido no refinamento. Comprovado com um teste fraco que deixa um mutante vivo.
- [ ] A skill `executar` cita os comandos de teste dos dois lados. Comprovado lendo a skill.
- [ ] `scripts/verify.sh` passa local e no CI.

## Fora de escopo

- Teste de ponta a ponta (Playwright ou similar).
- Teste de componente com navegador real.
- Testes do protótipo.
- Escrever testes para código de produto (ainda não existe).

## Passos

- [ ] Vitest no frontend e o passo no `verify.sh`
- [ ] Cobertura mínima nos dois lados
- [ ] Teste de mutação nos dois lados
- [ ] Skill `executar`

## Log de progresso

- 2026-11-08: rascunho criado.

## Log de decisões

## Perguntas em aberto

- Qual a cobertura mínima, e ela vale por arquivo ou no total?
- Teste de mutação bloqueia o push (só nos arquivos alterados) ou fica como relatório, como o `refactor-check.sh`?

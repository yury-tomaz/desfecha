# Sensores de teste: executor no frontend, cobertura e mutação

Estado: shaping
Apetite: a definir

## Problema

A skill `executar` cobra TDD em todo código, mas o `frontend/` não tem executor de testes: o ciclo vermelho, verde e refactor não tem onde rodar desse lado. E nos dois lados nada confere se os testes testam de verdade. O TDD é cobrado pela skill, não por código.

- O frontend só tem `pnpm test:sensores` (`node:test` com o `RuleTester` do ESLint, ver D9 de `2026-11-07-sensores-computacionais`), que testa as regras locais do lint, não código de produto.
- O backend já tem JUnit pelo `spring-boot-starter-*-test`.

Origem: sugestão de próxima tarefa de `2026-11-07-sensores-computacionais`, em `docs/historico/exec-plans/`.

## Solução

O executor no frontend e dois sensores no `scripts/verify.sh`, cobertura mínima e teste de mutação. O que precisa sair, como estava no rascunho:

- Vitest no frontend e o passo no `verify.sh`: `pnpm test` roda os testes do frontend, e o `verify.sh` chama esse comando. Comprovado com um teste de exemplo que falha de propósito: o `verify.sh` falha, e reverter faz passar.
- Cobertura mínima nos dois lados: o `verify.sh` falha quando a cobertura cai abaixo do mínimo, com mensagem que diz como corrigir. Comprovado baixando a cobertura de propósito.
- Teste de mutação nos dois lados, com o comportamento (bloqueante ou relatório) a definir. Comprovado com um teste fraco que deixa um mutante vivo.
- A skill `executar` cita os comandos de teste dos dois lados.
- `scripts/verify.sh` passa local e no CI.

Candidatos já citados: Vitest no frontend; PIT (backend) e Stryker (frontend) para mutação.

## Protótipo

Sem interface.

## Rabbit holes

- Toda dependência nova segue a regra da skill `executar` (nome, autor e repositório conferidos, versão com 3 dias ou mais).
- Teste de mutação é lento. Rodar a cada push pode deixar o `verify.sh` pesado; dá para limitar aos arquivos alterados ou deixar fora do caminho bloqueante, como o `scripts/refactor-check.sh`.

## No-gos

- Teste de ponta a ponta (Playwright ou similar).
- Teste de componente com navegador real.
- Testes do protótipo.
- Escrever testes para código de produto (ainda não existe).

## Revisão do protótipo

Sem protótipo.

## Log de decisões

- **D1. Convertido do exec-plan em rascunho `2026-11-08-sensores-de-teste` (2026-11-08):** pelo exec-plan `2026-11-08-shape-up` (em `docs/historico/exec-plans/`). Critérios de aceite e passos viraram a solução; o apetite e as perguntas em aberto ficam para o shaping.

## Perguntas em aberto

- Qual a cobertura mínima, e ela vale por arquivo ou no total?
- Teste de mutação bloqueia o push (só nos arquivos alterados) ou fica como relatório, como o `refactor-check.sh`?

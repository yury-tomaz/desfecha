# Sensores de teste: executor no frontend, cobertura e mutação

Estado: apostado
Apetite: grande

## Problema

A skill `executar` cobra TDD em todo código, mas o `frontend/` não tem executor de testes: o ciclo vermelho, verde e refactor não tem onde rodar desse lado. E nos dois lados nada confere se os testes testam de verdade. O TDD é cobrado pela skill, não por código.

- O frontend só tem `pnpm test:sensores` (`node:test` com o `RuleTester` do ESLint, ver D9 de `2026-11-07-sensores-computacionais`), que testa as regras locais do lint, não código de produto.
- O backend já tem JUnit pelo `spring-boot-starter-*-test`.

Origem: sugestão de próxima tarefa de `2026-11-07-sensores-computacionais`, em `docs/historico/exec-plans/`.

## Solução

O executor no frontend e dois sensores no `scripts/verify.sh`, cobertura mínima e teste de mutação. O que precisa sair, como estava no rascunho:

- Vitest no frontend e o passo no `verify.sh`: `pnpm test` roda os testes do frontend, e o `verify.sh` chama esse comando. Comprovado com um teste de exemplo que falha de propósito: o `verify.sh` falha, e reverter faz passar.
- Cobertura mínima nos dois lados, 80% de linhas e de branches no total (D4): o `verify.sh` falha quando a cobertura cai abaixo do mínimo, com mensagem que diz como corrigir. Comprovado baixando a cobertura de propósito.
- Teste de mutação nos dois lados, bloqueante no `verify.sh`, só nos arquivos alterados em relação ao `main` (D3). Falha abaixo do score mínimo de 80% (D4), com mensagem que diz como corrigir (que mutante sobreviveu e onde). Comprovado com um teste fraco que deixa um mutante vivo.
- A skill `executar` cita os comandos de teste dos dois lados.
- `scripts/verify.sh` passa local e no CI.

Candidatos já citados: Vitest no frontend; PIT (backend) e Stryker (frontend) para mutação.

## Protótipo

Sem interface.

## Rabbit holes

- Toda dependência nova segue a regra da skill `executar` (nome, autor e repositório conferidos, versão com 3 dias ou mais).
- Teste de mutação é lento. Por isso roda só nos arquivos alterados (D3): o PIT e o Stryker têm modo incremental ou recebem a lista de arquivos.
- A base do "alterado". O diff é contra `git merge-base HEAD origin/main`. No CI, o checkout padrão é raso e sem o `main`: o workflow precisa buscar o `main` (ou `fetch-depth: 0`), senão o diff sai vazio e a mutação passa sem rodar. No próprio `main`, depois do merge, o diff é vazio e a mutação não roda, o que é o esperado: o código já passou pela mutação no branch. Sem arquivo alterado medido, passa.
- Mutante equivalente (a mudança não altera o comportamento) não tem teste que o mate. O score mínimo fica abaixo de 100% por isso.
- Cobertura sobre o que não dá para testar. Teste de componente com navegador real é no-go, e a lógica do frontend fica em `.ts`, então a cobertura do frontend mede só `src/lib/**/*.ts`, sem `.svelte` e sem `src/routes/`. No backend, a cobertura mede todo o código de produção, menos a classe de bootstrap (`BackendApplication`): o único código dela é o `main()`, que o `@SpringBootTest` não chama, e o único jeito de cobri-lo é um teste que chama o `main()` sem conferir nada. Sem isso, o mínimo nasce impossível de atingir, ou é atingido por teste que só carrega o arquivo.
- Quase não há código de produto. O backend tem `BackendApplication` e o frontend tem `src/lib/index.ts`. A cobertura e a mutação precisam passar com zero arquivo medido, senão o `verify.sh` quebra no primeiro push. A prova de que o sensor funciona vem dos testes de exemplo da solução, que depois saem do código.

## No-gos

- Teste de ponta a ponta (Playwright ou similar).
- Teste de componente com navegador real.
- Testes do protótipo.
- Escrever testes para código de produto (ainda não existe).

## Revisão do protótipo

Sem protótipo.

## Log de decisões

- **D1. Convertido do exec-plan em rascunho `2026-11-08-sensores-de-teste` (2026-11-08):** pelo exec-plan `2026-11-08-shape-up` (em `docs/historico/exec-plans/`). Critérios de aceite e passos viraram a solução; o apetite e as perguntas em aberto ficam para o shaping.
- **D2. Apetite grande, com a mutação dentro (2026-11-08):** o problema é que nada confere se os testes testam de verdade, e cobertura só mostra que a linha rodou. Sem a mutação, o pitch não resolve o problema. Esperados 2 escopos: executor e cobertura; mutação.
- **D3. Mutação bloqueia o push, só nos arquivos alterados (2026-11-08):** um mutante vivo é objetivo, é um teste que falta. O `refactor-check.sh` é relatório porque os achados dele pedem julgamento. Relatório que nenhum humano lê seria ignorado pelo agente, e o TDD continuaria cobrado só pela skill. Só os alterados, para o `verify.sh` não ficar lento.
- **D4. Cobertura de 80% em linhas e branches, no total; score de mutação de 80% (2026-11-08):** com a mutação bloqueando nos alterados, um arquivo novo sem teste já falha nela, porque todo mutante sobrevive. A cobertura fica como piso barato do código inteiro, e uma regra por arquivo duplicaria a mutação com mais atrito. O score fica abaixo de 100% pelos mutantes equivalentes.
- **D5. 2026-11-08: apostado pelo humano.**

## Perguntas em aberto


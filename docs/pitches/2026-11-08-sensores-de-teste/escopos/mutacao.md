# Mutação

Colina: subindo

## Objetivo

Teste de mutação nos dois lados (PIT no backend, Stryker no frontend), bloqueante no `scripts/verify.sh`, só nos arquivos de produção alterados em relação a `git merge-base HEAD origin/main`, com score mínimo de 80% e mensagem que diz que mutante sobreviveu e onde. Funciona no CI e passa sem arquivo alterado.

## Critérios de aceite

- [ ] A lista dos alterados pega só código de produção medido (`backend/src/main/java`, sem `BackendApplication`; `frontend/src/lib/**/*.ts`, sem testes), commitado ou não, contra o merge-base com `origin/main`, e falha com mensagem de como corrigir sem `origin/main`. Comprovado pelos casos de `scripts/mutacao-alterados.test.sh`, rodados pelo `verify.sh`.
- [ ] No backend, um teste fraco que deixa um mutante vivo faz o `verify.sh` falhar abaixo de 80%, dizendo o mutante, a classe e a linha; com o teste forte, passa. Comprovado com código de exemplo (registro no log de progresso).
- [ ] No frontend, o mesmo com o Stryker. Comprovado com código de exemplo (registro no log de progresso).
- [ ] Sem arquivo alterado medido, a mutação passa sem rodar o PIT nem o Stryker. Comprovado por `scripts/verify.sh` neste branch depois de tirar os exemplos.
- [ ] O CI busca o `origin/main` para o diff. Comprovado pelo `verify.sh` no CI deste branch e pelo log do passo de mutação lá.
- [ ] A skill `executar` cita o comando de mutação. Comprovado por `grep -n "mutacao" .claude/skills/executar/SKILL.md`.

## Log de progresso

- 2026-11-08: escopo iniciado.
- 2026-11-08: `scripts/mutacao-alterados.sh` e os casos em `scripts/mutacao-alterados.test.sh` (sem mudança, commitado, sem commit e fora do git, o que fica de fora, apagado, `main` que andou depois do merge-base, sem `origin/main`). Os casos falharam pela lista vazia antes do script existir e passaram depois.
- 2026-11-08: PIT no backend pelo `scripts/mutacao-check.sh`, no `verify.sh`. Comprovado com `com.desfecha.Exemplo` (`if (n < 0)`) e testes com -1 e 5: `Mutation score of 75 is below threshold of 80`, saída 1, com `Exemplo.java:8 com.desfecha.Exemplo.sinal ConditionalsBoundaryMutator (SURVIVED)` e a mensagem de como corrigir; com o teste do 0, 4 de 4 mortos e saída 0. O PIT levou uns 6 segundos.

## Log de decisões

- **D1. A lista dos alterados num script separado, com casos (2026-11-08):** é a parte que, errada, deixa a mutação passar sem medir nada (rabbit hole do pitch), e dá para testar em segundos num repositório temporário. Rodar o PIT e o Stryker é comprovado pelos exemplos, como o pitch pede.
- **D2. Alterado inclui o que não foi commitado e o que está fora do git (2026-11-08):** o `verify.sh` roda também antes do commit; no pre-push, a árvore é a do commit. O diff é contra a árvore de trabalho, a partir de `git merge-base HEAD origin/main`.
- **D3. Sem `origin/main`, falha (2026-11-08):** sem base, a lista sairia vazia e a mutação passaria sem rodar, que é o rabbit hole do pitch. No próprio `main` o merge-base é o `HEAD` e a lista é vazia, como o pitch espera.
- **D4. `pitest-maven` 1.30.2 e `pitest-junit5-plugin` 1.2.3 (2026-11-08):** plugins novos. Conferidos no Maven Central: `org.pitest`, site pitest.org, SCM `github.com/hcoles/pitest` e `github.com/pitest/pitest-junit5-plugin`. A 1.30.2 foi publicada em 2026-11-05 às 09:45 UTC, pouco mais de 3 dias antes; o plugin JUnit 5 é de 2025-05 e roda com a JUnit do Spring Boot 4 (comprovado pelo exemplo).
- **D5. O PIT recebe as classes, não os arquivos, e não falha sem mutação (2026-11-08):** `targetClasses` é a classe do arquivo e as internas (`com.x.A,com.x.A$*`). `failWhenNoMutations` fica desligado: um arquivo alterado sem código mutável (interface, record) não pode bloquear o push.
- **D6. O que sobreviveu sai do CSV do PIT (2026-11-08):** o console do PIT só dá o score. O CSV (`target/pit-reports/mutations.csv`, sem pasta com data) tem arquivo, classe, método, linha, mutador e estado; o script lista `SURVIVED` e `NO_COVERAGE` e apaga o CSV antes de rodar, para não ler um relatório antigo.

## Perguntas em aberto

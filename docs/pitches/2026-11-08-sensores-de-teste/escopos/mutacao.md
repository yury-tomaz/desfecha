# Mutação

Colina: descendo

## Objetivo

Teste de mutação nos dois lados (PIT no backend, Stryker no frontend), bloqueante no `scripts/verify.sh`, só nos arquivos de produção alterados em relação a `git merge-base HEAD origin/main`, com score mínimo de 80% e mensagem que diz que mutante sobreviveu e onde. Funciona no CI e passa sem arquivo alterado.

## Critérios de aceite

- [x] A lista dos alterados pega só código de produção medido (`backend/src/main/java`, sem `BackendApplication`; `frontend/src/lib/**/*.ts`, sem testes), commitado ou não, contra o merge-base com `origin/main`, e falha com mensagem de como corrigir sem `origin/main`. Comprovado pelos casos de `scripts/mutacao-alterados.test.sh`, rodados pelo `verify.sh`.
- [x] No backend, um teste fraco que deixa um mutante vivo faz o `verify.sh` falhar abaixo de 80%, dizendo o mutante, a classe e a linha; com o teste forte, passa. Comprovado com código de exemplo (registro no log de progresso).
- [x] No frontend, o mesmo com o Stryker. Comprovado com código de exemplo (registro no log de progresso).
- [x] Sem arquivo alterado medido, a mutação passa sem rodar o PIT nem o Stryker. Comprovado por `scripts/verify.sh` neste branch depois de tirar os exemplos.
- [x] O CI busca o `origin/main` para o diff. Comprovado pelo `verify.sh` no CI deste branch e pelo log do passo de mutação lá.
- [x] A skill `executar` cita o comando de mutação. Comprovado por `grep -n "mutacao" .claude/skills/executar/SKILL.md`.

## Log de progresso

- 2026-11-08: escopo iniciado.
- 2026-11-08: `scripts/mutacao-alterados.sh` e os casos em `scripts/mutacao-alterados.test.sh` (sem mudança, commitado, sem commit e fora do git, o que fica de fora, apagado, `main` que andou depois do merge-base, sem `origin/main`). Os casos falharam pela lista vazia antes do script existir e passaram depois.
- 2026-11-08: PIT no backend pelo `scripts/mutacao-check.sh`, no `verify.sh`. Comprovado com `com.desfecha.Exemplo` (`if (n < 0)`) e testes com -1 e 5: `Mutation score of 75 is below threshold of 80`, saída 1, com `Exemplo.java:8 com.desfecha.Exemplo.sinal ConditionalsBoundaryMutator (SURVIVED)` e a mensagem de como corrigir; com o teste do 0, 4 de 4 mortos e saída 0. O PIT levou uns 6 segundos.
- 2026-11-08: Stryker no frontend pelo mesmo script. Comprovado com `src/lib/exemplo.ts` (`if (n < 0)`): com teste só do -1, o `verify.sh` saiu com 1 no passo de mutação, `Final mutation score 57.14 under breaking threshold 80`, listando `[NoCoverage] StringLiteral src/lib/exemplo.ts:3:9`, `[Survived] ConditionalExpression` e `[Survived] EqualityOperator` em `src/lib/exemplo.ts:2:6`, com a mudança de cada um, e a mensagem de como corrigir; com os testes do -1 e do 0, saída 0. (Com -1 e 5, como no backend, deu 85,71% e passou: o Stryker gera 7 mutantes onde o PIT gera 4.)
- 2026-11-08: casos de borda. Interface Java sem código e `.ts` só com tipos passam; classe Java e `.ts` com código e sem nenhum teste falham (`Mutation score of 0`, `NO_COVERAGE`; `No tests were executed`).
- 2026-11-08: o Stryker trouxe o `qs` 6.15.1 (via `typed-rest-client`), com 4 vulnerabilidades conhecidas no OSV-Scanner; corrigido com override (D10).
- 2026-11-08: os passos de mutação foram para o fim do `verify.sh`: antes do `pnpm install` do frontend, no CI o Stryker ainda não estaria instalado.
- 2026-11-08: bug no primeiro push. O hook de pre-push roda com `GIT_DIR` definido, e o `mutacao-alterados.test.sh` não o limpava: os comandos git dos casos foram para o repositório de verdade (um commit `base` no topo deste branch, um branch `escopo`, o `origin/main` local movido, o índice do worktree trocado e `core.bare = true` no `.git/config`). Nada foi publicado: o `verify.sh` falhou e o push parou. Estado local desfeito à mão (`core.bare` de volta a `false`, branch de volta ao último commit, `escopo` apagado, `git fetch` do `origin/main`). Reproduzido com um repositório isca em `GIT_DIR`; corrigido com o mesmo `unset $(git rev-parse --local-env-vars)` do `segredos-check.test.sh`, e a isca ficou intacta. Caso novo: com `GIT_DIR` de outro repositório, o script lista o repositório certo.
- 2026-11-08: colina descendo. Os dois lados medem, barram e passam vazios; resta conferir o CI e concluir.
- 2026-11-08: CI deste branch (run 42496812231) verde: o checkout trouxe `main -> origin/main`, e o passo de mutação imprimiu `nenhum código de produção alterado em relação ao origin/main: a mutação não roda`, sem falhar por falta de base. Local, `scripts/verify.sh` ok sem os exemplos. `scripts/refactor-check.sh` sem achado novo.
- 2026-11-08: escopo concluído.
- 2026-11-08: revisão do PR #9, achado 🔴: com o `core.quotePath` padrão, o git escreve nome com acento entre aspas e com escape octal, e o filtro descartava o arquivo calado (`frontend/src/lib/cobrança.ts` sem teste passava com "nenhum código de produção alterado"). Caso novo com `.java` e `.ts` com acento, commitados e fora do git: falhou com a lista vazia e passou com `git -c core.quotePath=false` nos dois comandos (D12). Cenário do revisor refeito: `cobrança.ts` sem teste agora barra no Stryker, e `Cobrança.java` sem teste barra no PIT (`Mutation score of 0`). O único outro script que lista arquivos do git, o `segredos-check.sh`, já usa `-z`.
- 2026-11-08: sugestões de próximo pitch, das revisões dos PRs #8 e #9. (1) Casos automáticos para os sensores em si: hoje a prova de que o PIT e o Stryker barram está só neste log, e uma configuração quebrada depois passaria calada enquanto não houver código de produto; um `scripts/mutacao-check.test.sh` com um repositório temporário rodaria os dois lados contra um exemplo fraco e um forte. (2) Uma checagem estrutural no `verify.sh` que recuse, em `scripts/`, `.githooks/` e `.claude/hooks/`, `git diff --name-only`, `git ls-files` e `git status --porcelain` sem `-z` nem `core.quotePath=false`.

## Log de decisões

- **D1. A lista dos alterados num script separado, com casos (2026-11-08):** é a parte que, errada, deixa a mutação passar sem medir nada (rabbit hole do pitch), e dá para testar em segundos num repositório temporário. Rodar o PIT e o Stryker é comprovado pelos exemplos, como o pitch pede.
- **D2. Alterado inclui o que não foi commitado e o que está fora do git (2026-11-08):** o `verify.sh` roda também antes do commit; no pre-push, a árvore é a do commit. O diff é contra a árvore de trabalho, a partir de `git merge-base HEAD origin/main`.
- **D3. Sem `origin/main`, falha (2026-11-08):** sem base, a lista sairia vazia e a mutação passaria sem rodar, que é o rabbit hole do pitch. No próprio `main` o merge-base é o `HEAD` e a lista é vazia, como o pitch espera.
- **D4. `pitest-maven` 1.30.2 e `pitest-junit5-plugin` 1.2.3 (2026-11-08):** plugins novos. Conferidos no Maven Central: `org.pitest`, site pitest.org, SCM `github.com/hcoles/pitest` e `github.com/pitest/pitest-junit5-plugin`. A 1.30.2 foi publicada em 2026-11-05 às 09:45 UTC, pouco mais de 3 dias antes; o plugin JUnit 5 é de 2025-05 e roda com a JUnit do Spring Boot 4 (comprovado pelo exemplo).
- **D5. O PIT recebe as classes, não os arquivos, e não falha sem mutação (2026-11-08):** `targetClasses` é a classe do arquivo e as internas (`com.x.A,com.x.A$*`). `failWhenNoMutations` fica desligado: um arquivo alterado sem código mutável (interface, record) não pode bloquear o push.
- **D6. O que sobreviveu sai do CSV do PIT (2026-11-08):** o console do PIT só dá o score. O CSV (`target/pit-reports/mutations.csv`, sem pasta com data) tem arquivo, classe, método, linha, mutador e estado; o script lista `SURVIVED` e `NO_COVERAGE` e apaga o CSV antes de rodar, para não ler um relatório antigo.
- **D7. `@stryker-mutator/core` e `@stryker-mutator/vitest-runner` 10.1.1 (2026-11-08):** dependências novas. Conferidas com `pnpm view`: repositório `github.com/stryker-mutator/stryker-js`, mantenedores do Stryker (nicojs, simondel, a conta de automação `strykermutator-npa`); 10.1.1 publicada em 2026-10-23. O runner aceita `vitest >=2.0.0`.
- **D8. Plugin do runner declarado em `plugins` (2026-11-08):** com o `node_modules` isolado do pnpm, o Stryker não acha o `@stryker-mutator/vitest-runner` sozinho (`Cannot find TestRunner plugin "vitest"`).
- **D9. Sem `allowEmpty`; zero mutante passa pelo script (2026-11-08):** sem teste, o Stryker sai com `No tests were executed`, o que barraria um `.ts` só de tipos. O `allowEmpty` resolve isso, mas sai antes de calcular o score: um `.ts` com código e sem teste também passaria (comprovado). O script passa só quando o Stryker falhou e instrumentou zero mutantes.
- **D10. Override do `qs` para 6.16.2 (2026-11-08):** o `typed-rest-client` 2.3.1 (dependência do Stryker) fixa `qs` em 6.15.1 exato, então `pnpm update` não resolve. A 6.16.2 (`github.com/ljharb/qs`, publicada em 2026-10-27) é a menor que cobre as correções das quatro (6.15.2, 6.16.0 e 6.16.1), sem mudar de versão maior. Mesma forma do override do `minimatch`, em `frontend/pnpm-workspace.yaml`.
- **D11. Só o relatório em texto do Stryker, pasta temporária ignorada (2026-11-08):** o `clear-text` mostra cada mutante vivo com arquivo, linha, coluna e a mudança, que é o que a mensagem precisa; sem HTML, não sobra pasta de relatório. A `.stryker-tmp` (o Stryker apaga ao fim) fica no `.gitignore` e nas `ignores` do ESLint para o caso de um processo interrompido.
- **D12. `core.quotePath=false` em vez de `-z` (2026-11-08):** o nome sai como está, e o resto do script segue lendo uma linha por arquivo. Nome de arquivo com quebra de linha não é caso real aqui; o `-z` pediria trocar o `awk` e o `<<<` por leitura com NUL.

## Perguntas em aberto

# Executor e cobertura

Colina: subindo

## Objetivo

O frontend ganha executor de testes (Vitest, `pnpm test`), e os dois lados ganham cobertura mínima de 80% de linhas e de branches no total, no `scripts/verify.sh`, passando com zero arquivo medido.

## Critérios de aceite

- [ ] `pnpm test` roda os testes do frontend e o `verify.sh` chama esse comando. Comprovado com um teste de exemplo que falha de propósito: o `verify.sh` falha, e reverter faz passar (registro no log de progresso).
- [ ] A cobertura do frontend mede só `src/lib/**/*.ts` e falha abaixo de 80% de linhas ou de branches, com mensagem que diz como corrigir. Comprovado com código de exemplo sem teste: o `verify.sh` falha; com teste, passa (registro no log de progresso).
- [ ] A cobertura do backend mede o código de produção menos `BackendApplication` e falha abaixo de 80% de linhas ou de branches, com mensagem que diz como corrigir. Comprovado com código de exemplo sem teste: o `verify.sh` falha; com teste, passa (registro no log de progresso).
- [ ] Com o código atual (zero arquivo medido nos dois lados), o `verify.sh` passa. Comprovado por `scripts/verify.sh`.
- [ ] A skill `executar` cita os comandos de teste e de cobertura dos dois lados. Comprovado por `grep -n "pnpm test\|mvnw" .claude/skills/executar/SKILL.md`.

## Log de progresso

- 2026-11-08: escopo iniciado.
- 2026-11-08: Vitest no frontend, `pnpm test` (`vitest run`) e o passo "frontend: testes (Vitest)" no `verify.sh`. Comprovado com `src/lib/exemplo.test.ts` esperando `1 + 1` igual a 3: `pnpm test` falhou na asserção e o `verify.sh` saiu com 1 nesse passo; trocado para 2, passou; o exemplo saiu do código.
- 2026-11-08: cobertura do frontend (`@vitest/coverage-v8`) dentro do `pnpm test`, com mínimo de 80% de linhas e de branches em `src/lib/**/*.ts`, e mensagem de como corrigir no `verify.sh`. Comprovado com `src/lib/exemplo.ts` (função com um `if`): sem teste, 0% e o `verify.sh` saiu com 1 com a mensagem; com teste só do branch negativo, 50% de linhas e de branches e `pnpm test` falhou; com os dois branches, 100% e passou. Sem o exemplo (zero arquivo medido), `pnpm test` passa com `0/0`.

## Log de decisões

- **D1. Dois escopos: executor e cobertura; mutação (2026-11-08):** como o D2 do pitch prevê. A mutação do frontend precisa do executor, então este escopo vem embaixo no stack.
- **D2. Vitest 5.1.0 (2026-11-08):** dependência nova. Conferido com `pnpm view`: pacote `vitest`, repositório `github.com/vitest-dev/vitest`, mantenedores do time do Vitest (antfu, yyx990803, ariperkkio, hiogawa); 5.1.0 publicada em 2026-11-02, seis dias antes. Aceita `vite` 8 como peer.
- **D3. Vitest só em `src/**/*.test.ts`, com `passWithNoTests` (2026-11-08):** o padrão do Vitest pegaria o `eslint-sensores.test.js`, que é do `node:test` (`pnpm test:sensores`). Sem `passWithNoTests`, `vitest run` sai com 1 sem arquivo de teste, e hoje não há nenhum (rabbit hole do pitch). A configuração fica no `vite.config.ts`, importando `defineConfig` de `vitest/config`, para os testes verem os mesmos plugins do build.
- **D4. `@vitest/coverage-v8` 5.1.0 (2026-11-08):** dependência nova. Pacote do mesmo monorepo (`github.com/vitest-dev/vitest`, `packages/coverage-v8`), mesmos mantenedores; publicada em 2026-11-02. É o provider que o próprio Vitest indica, e tem de acompanhar a versão do `vitest`.
- **D5. A cobertura roda dentro do `pnpm test` (`vitest run --coverage`), só com o relatório em texto (2026-11-08):** um comando só para o `verify.sh` e para quem constrói, como o pitch descreve. O relatório HTML padrão criava `frontend/coverage/`, que o Prettier passava a conferir; o texto mostra o que importa (`Uncovered Line #s`). Para rodar um teste só, sem o mínimo: `pnpm exec vitest run <arquivo>`.

## Perguntas em aberto

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

## Log de decisões

## Perguntas em aberto

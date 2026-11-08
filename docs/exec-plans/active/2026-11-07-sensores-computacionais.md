# Sensores computacionais

Status: em-execucao

## Objetivo

Hoje só existe `scripts/verify.sh`. As regras da skill `executar` (não pular a verificação, regra de comentários, refactoring) dependem da boa vontade do agente. Esta tarefa coloca ferramentas para cobrar essas regras: hook de pre-push, bloqueio de `--no-verify`, lint de código comentado e de TODO sem plano, e um relatório de refactoring.

## Contexto

- Estado em 2026-11-07: o frontend **não tem ESLint**. Só Prettier e `svelte-check`. O backend só tem Spotless (google-java-format) na fase `verify` do Maven.
- `.claude/settings.json` ainda não existe. `core.hooksPath` não está configurado.
- `core.hooksPath` fica no `.git/config` compartilhado, então vale em todas as worktrees de `.worktrees/`. Um caminho relativo (`.githooks`) é resolvido a partir da raiz de cada worktree.
- O CI (`.github/workflows/verify.yml`) roda `scripts/verify.sh` com `jdx/mise-action`. Ferramentas novas entram como dependência de Maven ou de pnpm, ou no `mise.toml`, para valer igual no local e no CI.
- **Hook no push, não no commit.** No XP o agente faz um commit a cada ciclo verde e a cada refactoring, e o verde é o teste daquele ciclo, não a suíte inteira. Por isso não há pre-commit: o commit fica livre. O `.githooks/pre-push` roda o `scripts/verify.sh` inteiro, sem exceção (inclusive nos pushes do `main` que só mudam status de plano). A regra "`verify.sh` tem que passar antes de todo commit" vira "antes de todo push" no `AGENTS.md` e na skill `executar`.
- Bloqueio de `--no-verify`: cobre `git push` (que é onde o hook está). Inclui `--no-verify` em qualquer posição do comando. Regra de permissão (`deny`) ou hook `PreToolUse` do Claude Code, ambos em `.claude/settings.json`: quem executa escolhe e registra.
- Regra de comentários (skill `executar`, seção "Regra de comentários"): código comentado é proibido, e TODO sem tarefa associada também.
- Regra das mensagens: toda mensagem de erro de lint ou de checagem é escrita para o agente. Ela diz o que está errado e como corrigir (por exemplo: "Código comentado em X:12. Apague: o histórico fica no git."). Vale para as checagens criadas nesta tarefa (código comentado, TODO, checagem do backend). As regras dos conjuntos recomendados do ESLint ficam com a mensagem padrão.
- ESLint do frontend: criar do zero (flat config) com os conjuntos recomendados `@eslint/js` (recommended), `typescript-eslint` (recommended) e `eslint-plugin-svelte` (recommended), mais `eslint-config-prettier` para não brigar com o Prettier. Por cima, as regras desta tarefa: `sonarjs/no-commented-code` e `no-warning-comments` como erro. `sonarjs/cognitive-complexity` fica fora do `verify.sh`, só no relatório de refactoring. O lint entra em `verify.sh` como script `pnpm lint`.
- Formato de TODO aceito: `TODO(<slug-do-plano>): texto`, em que o slug é o nome do arquivo do plano sem `.md` (ex.: `// TODO(2026-11-07-sensores-computacionais): ...`). Vale também para `FIXME`. O lint confere só o formato (data `AAAA-MM-DD` + slug em kebab-case), não se o plano existe.

## Critérios de aceite

- [ ] `.githooks/pre-push` está versionado e chama `scripts/verify.sh`. A ativação de `core.hooksPath` é automática ou está no setup do `AGENTS.md`. Comprovado assim: num clone limpo, depois do setup, um push com um arquivo desformatado é recusado pelo hook; o mesmo vale numa worktree criada com `git worktree add`; com tudo verde o push passa. Registrar no log de progresso.
- [ ] `.claude/settings.json` impede o agente de rodar `git push --no-verify`. Comprovado listando no log de progresso as formas testadas (ex.: `git push --no-verify`, `git push origin x --no-verify`) e o resultado de cada uma.
- [ ] Código comentado faz `scripts/verify.sh` falhar no frontend (`eslint-plugin-sonarjs`, regra `no-commented-code`) e no backend (teste estrutural ou script com heurística). Comprovado assim: um trecho de código comentado num `.ts`, num `.svelte` e num `.java` faz a verificação falhar com mensagem que diz como corrigir; um comentário de "porquê" em prosa não faz; reverter faz passar.
- [ ] TODO sem referência a exec-plan faz `scripts/verify.sh` falhar (Checkstyle `TodoComment` no backend, `no-warning-comments` no frontend). Comprovado assim: um TODO sem referência falha com mensagem que diz como corrigir; um TODO no formato aceito passa.
- [ ] `pnpm lint` roda o ESLint com os conjuntos recomendados (ver Contexto) e entra em `scripts/verify.sh`. Comprovado assim: um erro de uma regra recomendada (ex.: variável não usada num `.ts`) faz a verificação falhar; reverter faz passar.
- [ ] `scripts/refactor-check.sh` gera um relatório de duplicação (jscpd, Java e TS), código morto (knip no frontend, PMD no backend) e complexidade cognitiva (PMD e ESLint), e sai com 0 mesmo com achados. Comprovado rodando o script com uma duplicação de propósito: ela aparece no relatório e o código de saída é 0.
- [ ] O código atual passa em todos os lints novos, e `scripts/verify.sh` passa local e no CI. Comprovado com `gh run list` no push do branch da tarefa.
- [ ] `AGENTS.md` traz o setup do hook, diz que `verify.sh` passa antes de todo push e aponta para `scripts/refactor-check.sh`. A skill `executar` diz "antes de cada push" no lugar de "antes de cada commit", cita `scripts/refactor-check.sh` no passo de refactoring e o formato de TODO aceito. Comprovado lendo os dois arquivos.

## Fora de escopo

- Código de produto.
- Hook de pre-commit.
- Fitness functions de arquitetura (Spring Modulith, ArchUnit).
- OpenRewrite.
- Revisão inferencial (por LLM).
- Mudanças no CI além de rodar o mesmo `scripts/verify.sh`.
- Fazer `refactor-check.sh` bloquear a verificação ou o push.

## Passos

- [x] Hook de pre-push versionado e ativação de `core.hooksPath`
- [ ] Bloqueio de `git push --no-verify` em `.claude/settings.json`
- [ ] ESLint no frontend com os conjuntos recomendados e as regras de código comentado e de TODO
- [ ] Checagem de código comentado e Checkstyle de TODO no backend
- [ ] Ligar os lints em `scripts/verify.sh`
- [ ] `scripts/refactor-check.sh`
- [ ] Atualizar `AGENTS.md` e a skill `executar`

## Log de progresso

- 2026-11-07: exec-plan criado.
- 2026-11-07: sugestão de próxima tarefa: sensores de teste (Vitest no frontend, cobertura mínima, teste de mutação com PIT e Stryker), para cobrar o TDD.
- 2026-11-07: refinado e aprovado.
- 2026-11-07: execução iniciada.
- 2026-11-07: hook de pre-push testado num clone limpo (do branch da tarefa, com `git config core.hooksPath .githooks`) empurrando para um remote bare local: commit com `frontend/src/lib/feio.ts` desformatado → push recusado (rc=1, mensagem do hook); numa worktree criada com `git worktree add` a partir do clone → recusado igual (rc=1); sem o arquivo, push passa no clone e na worktree (rc=0).

## Log de decisões

- **D1. Ativação do hook pelo setup do `AGENTS.md` (`git config core.hooksPath .githooks`), não automática**: as formas automáticas (script `prepare` do pnpm, hook do mise) escondem um efeito colateral no `.git/config` dentro de outro comando e dependem de quem roda qual ferramenta primeiro. Um comando explícito no setup é visível e vale para todas as worktrees.
- **D2. O hook roda `scripts/verify.sh` na árvore de trabalho, não no commit empurrado**: é o mesmo comando do CI e o agente empurra com a árvore limpa; reproduzir o commit numa árvore temporária custaria um build completo a mais por push.

## Perguntas em aberto

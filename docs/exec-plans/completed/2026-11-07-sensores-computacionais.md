# Sensores computacionais

Status: concluido

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

- [x] `.githooks/pre-push` está versionado e chama `scripts/verify.sh`. A ativação de `core.hooksPath` é automática ou está no setup do `AGENTS.md`. Comprovado assim: num clone limpo, depois do setup, um push com um arquivo desformatado é recusado pelo hook; o mesmo vale numa worktree criada com `git worktree add`; com tudo verde o push passa. Registrar no log de progresso.
- [x] `.claude/settings.json` impede o agente de rodar `git push --no-verify`. Comprovado listando no log de progresso as formas testadas (ex.: `git push --no-verify`, `git push origin x --no-verify`) e o resultado de cada uma.
- [x] Código comentado faz `scripts/verify.sh` falhar no frontend (`eslint-plugin-sonarjs`, regra `no-commented-code`) e no backend (teste estrutural ou script com heurística). Comprovado assim: um trecho de código comentado num `.ts`, num `.svelte` e num `.java` faz a verificação falhar com mensagem que diz como corrigir; um comentário de "porquê" em prosa não faz; reverter faz passar.
- [x] TODO sem referência a exec-plan faz `scripts/verify.sh` falhar (Checkstyle `TodoComment` no backend, `no-warning-comments` no frontend). Comprovado assim: um TODO sem referência falha com mensagem que diz como corrigir; um TODO no formato aceito passa.
- [x] `pnpm lint` roda o ESLint com os conjuntos recomendados (ver Contexto) e entra em `scripts/verify.sh`. Comprovado assim: um erro de uma regra recomendada (ex.: variável não usada num `.ts`) faz a verificação falhar; reverter faz passar.
- [x] `scripts/refactor-check.sh` gera um relatório de duplicação (jscpd, Java e TS), código morto (knip no frontend, PMD no backend) e complexidade cognitiva (PMD e ESLint), e sai com 0 mesmo com achados. Comprovado rodando o script com uma duplicação de propósito: ela aparece no relatório e o código de saída é 0.
- [x] O código atual passa em todos os lints novos, e `scripts/verify.sh` passa local e no CI. Comprovado com `gh run list` no push do branch da tarefa.
- [x] `AGENTS.md` traz o setup do hook, diz que `verify.sh` passa antes de todo push e aponta para `scripts/refactor-check.sh`. A skill `executar` diz "antes de cada push" no lugar de "antes de cada commit", cita `scripts/refactor-check.sh` no passo de refactoring e o formato de TODO aceito. Comprovado lendo os dois arquivos.

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
- [x] Bloqueio de `git push --no-verify` em `.claude/settings.json`
- [x] ESLint no frontend com os conjuntos recomendados e as regras de código comentado e de TODO
- [x] Checagem de código comentado e Checkstyle de TODO no backend
- [x] Ligar os lints em `scripts/verify.sh`
- [x] `scripts/refactor-check.sh`
- [x] Atualizar `AGENTS.md` e a skill `executar`

## Log de progresso

- 2026-11-07: exec-plan criado.
- 2026-11-07: sugestão de próxima tarefa: sensores de teste (Vitest no frontend, cobertura mínima, teste de mutação com PIT e Stryker), para cobrar o TDD.
- 2026-11-07: refinado e aprovado.
- 2026-11-07: execução iniciada.
- 2026-11-07: hook de pre-push testado num clone limpo (do branch da tarefa, com `git config core.hooksPath .githooks`) empurrando para um remote bare local: commit com `frontend/src/lib/feio.ts` desformatado → push recusado (rc=1, mensagem do hook); numa worktree criada com `git worktree add` a partir do clone → recusado igual (rc=1); sem o arquivo, push passa no clone e na worktree (rc=0).
- 2026-11-07: bloqueio de `--no-verify` testado passando o JSON de chamada da ferramenta Bash para `.claude/hooks/bloqueia-push-no-verify.sh`. Bloqueadas (rc=2, com mensagem): `git push --no-verify`; `git push origin x --no-verify`; `git push --no-verify origin x`; `git push -u origin plano/x --no-veri`; `git -C /a/b push --no-verif`; `cd x && git push origin main --no-verify`. Liberadas (rc=0): `git push origin x`; `git push --verify`; `git commit --no-verify -m a`; `git commit --no-verify -m a && git push`; `git status; echo --no-verify`. O hook só passa a valer nas sessões abertas no `main` depois do merge, porque o Claude Code lê `.claude/settings.json` da pasta onde a sessão começou.
- 2026-11-07: ESLint no frontend (flat config, `eslint.config.js`) com `@eslint/js`, `typescript-eslint`, `eslint-plugin-svelte` e `eslint-config-prettier` recomendados, mais as regras locais de `eslint-sensores.js`. O `src/app.d.ts` do template tinha interfaces comentadas e foi limpo. `pnpm lint` entra em `scripts/verify.sh` antes da checagem de tipos.
- 2026-11-07: backend com o teste estrutural `NoCommentedCodeTest` (detector `CommentedCodeDetector`, com testes de unidade) e o Checkstyle `TodoComment` na fase `verify`.
- 2026-11-07: `scripts/refactor-check.sh` testado com duplicação de propósito (mesma função em `dup-a.ts`/`dup-b.ts` e em `DupA.java`/`DupB.java`, com uma variável local não usada, e uma função de complexidade 34 em `complexa.ts`): o jscpd listou os dois clones (java e typescript), o knip os arquivos não usados, o PMD a variável não usada, o ESLint a complexidade cognitiva, e o script saiu com 0. As amostras foram apagadas.
- 2026-11-07: o PMD apontou complexidade cognitiva 17 em `CommentedCodeDetector.comments`; refatorado (um token por vez, linha calculada pelo índice), sem mudar testes. No código atual o relatório só aponta `frontend/src/lib/index.ts` (arquivo do template, sem uso) no knip.
- 2026-11-07: critérios verificados por `scripts/verify.sh`, um caso por vez, revertendo cada um. Falharam (rc=1) com a mensagem de como corrigir: código comentado num `.ts`, num `.svelte` e num `.java`; `// TODO: arrumar` num `.ts` e num `.java`; `// FIXME ver depois` num `.svelte`. Passaram (rc=0): comentário de "porquê" em prosa nos três; `TODO(2026-11-07-sensores-computacionais): ...` e `FIXME(...)` no formato aceito nos três; a árvore revertida. Variável não usada num `.ts` fez a verificação falhar em `pnpm lint` (`@typescript-eslint/no-unused-vars`) e o revertido passou.
- 2026-11-07: sugestões de próxima tarefa: (1) apagar `frontend/src/lib/index.ts` e o import `#lib` sem uso apontados pelo knip, se o humano não quiser manter o padrão do template; (2) fechar outros desvios do hook de pre-push, como `git -c core.hooksPath=... push`, que o bloqueio desta tarefa não cobre (o escopo era `--no-verify`).
- 2026-11-07: o push do branch passou pelo hook de pre-push, e o CI passou (`gh run list`: run 42436129092, `verify`, success). `AGENTS.md` e a skill `executar` conferidos: setup do hook, "antes de todo push", `scripts/refactor-check.sh` e formato de TODO.
- 2026-11-07: concluído.
- 2026-11-07: correções da revisão do PR #2. (1) O hook de `--no-verify` era contornado com aspas, barra invertida, tab ou `${IFS}` antes da opção (`git push "--no-verify"`, `git push origin x \--no-verify` etc.). Agora lê só `tool_input.command`, tira aspas e barras e junta continuações de linha antes de procurar; os casos (bloqueados e liberados, inclusive os do achado e um `description` que cita `--no-verify`) ficam em `.claude/hooks/bloqueia-push-no-verify.test.sh`, rodado pelo `verify.sh`. Viu falhar 7 casos de contorno antes da correção. Sem `jq` no PATH, testado à mão: bloqueia `git push "--no-verify"` e libera `git push origin x`. (2) O `codigo-comentado` do frontend só reportava o primeiro código comentado de cada arquivo, porque o sonarjs reporta sem `node` e a deduplicação usava o `node` como chave; agora a chave é o `node` ou a posição. (3) As regras locais do ESLint ganharam teste com `RuleTester` sobre `node:test` (`frontend/eslint-sensores.test.js`, `pnpm test:sensores`), rodado pelo `verify.sh`; o caso de dois códigos comentados no mesmo arquivo falhou antes da correção. (4) Plano commitado com status e critérios atualizados. `scripts/verify.sh` passou.
- 2026-11-07: sugestão de próxima tarefa (da revisão): `scripts/plan-check.sh` recusar plano em `completed/` com `Status:` diferente de `concluido` ou com `- [ ]` em "Critérios de aceite", rodado pelo `verify.sh` para todo arquivo de `docs/exec-plans/completed/`.

## Log de decisões

- **D1. Ativação do hook pelo setup do `AGENTS.md` (`git config core.hooksPath .githooks`), não automática**: as formas automáticas (script `prepare` do pnpm, hook do mise) escondem um efeito colateral no `.git/config` dentro de outro comando e dependem de quem roda qual ferramenta primeiro. Um comando explícito no setup é visível e vale para todas as worktrees.
- **D2. O hook roda `scripts/verify.sh` na árvore de trabalho, não no commit empurrado**: é o mesmo comando do CI e o agente empurra com a árvore limpa; reproduzir o commit numa árvore temporária custaria um build completo a mais por push.
- **D3. Bloqueio por hook `PreToolUse`, não por regra `deny`**: o git aceita abreviação de opção longa (`--no-veri` já vale como `--no-verify`, testado), e a opção pode vir em qualquer posição. Uma regra `deny` por prefixo não cobre isso; uma expressão regular num hook cobre. Depois da revisão, o hook lê o comando com `jq` (só `tool_input.command`, sem falso positivo vindo de `description`) e remove aspas e barras antes da expressão, porque o shell as tira antes de o git ver a opção. Sem `jq`, procura no JSON inteiro: pode bloquear a mais, nunca a menos. Limite aceito: opção vinda de variável (`f=--no-verify; git push $f`) passa; cobrir isso seria interpretar shell.
- **D4. As regras de código comentado e de TODO do frontend são `sonarjs/no-commented-code` e `no-warning-comments` envolvidas num plugin local (`frontend/eslint-sensores.js`)**: as duas regras têm mensagem fixa em inglês, e `no-warning-comments` não aceita exceção, então barraria também o formato `TODO(<slug>): `. O envoltório troca a mensagem pela que diz como corrigir e filtra o formato aceito. A detecção continua sendo a das regras originais.
- **D5. TODO e FIXME só contam em maiúsculas, nos dois lados**: `no-warning-comments` compara sem caixa, e "todo" é palavra comum em português ("o todo do pedido"). O Checkstyle já compara com caixa.
- **D6. Limites conhecidos do `sonarjs/no-commented-code`**: ele junta comentários de linha vizinhos e analisa o grupo inteiro, então uma linha de código logo abaixo de uma linha de prosa, sem linha em branco, passa. Comentário HTML (`<!-- -->`) no markup do `.svelte` também não é analisado; o `<script>` é. Aceito: é a regra pedida no plano, e corrigir isso seria escrever outro detector.
- **D7. Backend: código comentado detectado por teste estrutural JUnit com heurística (`CommentedCodeDetector`)**: o Checkstyle e o PMD não têm regra para isso. O detector lê o fonte ignorando strings, text blocks e chars, e marca a linha de comentário que termina em `;`, `{` ou `}`, ou que é só uma anotação. Javadoc fica de fora, porque exemplo de uso em `{@code}` é legítimo. Fica em `src/test`, porque é sensor, não produto.
- **D8. `refactor-check.sh` usa jscpd e knip como dependências do frontend e o PMD como plugin do Maven sem execução ligada a fase**: assim as versões ficam fixadas como no resto (lockfile e `pom.xml`) e o PMD nunca roda no `verify`. A complexidade cognitiva do frontend roda com `--rule 'sonarjs/cognitive-complexity: [warn, 15]'` por cima da config normal, para não entrar no `pnpm lint`. O jscpd também lê `.svelte`.
- **D9. Teste das regras locais do ESLint com `RuleTester` sobre `node:test`, não Vitest**: o frontend ainda não tem executor de testes (Vitest é a próxima tarefa sugerida), e o `node:test` não traz dependência nova. O `RuleTester` usa o parser do `typescript-eslint`, como o `pnpm lint`: sem parser configurado, o sonarjs não reporta nada.

## Perguntas em aberto

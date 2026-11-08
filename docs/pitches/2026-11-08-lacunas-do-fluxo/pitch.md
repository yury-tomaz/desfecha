# Lacunas do fluxo

Estado: em-build
Apetite: pequeno

## Problema

O fluxo de pitches (`docs/PLANS.md`, skills `moldar`, `executar` e `revisar`) tem três buracos que aparecem no primeiro pitch `grande` que travar ou receber revisão.

1. **Re-revisão de PR empilhado.** A seção 5 da `revisar` manda revisar `git diff <commit revisado>..HEAD`. Num stack, quando o escopo de baixo muda e a `executar` roda `gh stack rebase --upstack`, o branch de cima é reescrito: esse diff passa a mostrar também o que veio do escopo de baixo, e o revisor reporta como novo o que não é deste PR. Caso concreto: o PR do escopo 2 é revisado no commit `c`; a revisão do escopo 1 pede uma correção `d`; o escopo 2 é rebaseado para `c'` em cima de `d`; `git diff c..c'` mostra `d` inteiro.
2. **Saída do `bloqueado`.** A `executar` bloqueia (seção 7) e para. O `docs/PLANS.md` diz que o humano decide (responder, cortar escopo, voltar ao shaping, descartar), mas nenhuma skill grava essa decisão nem tira o pitch do estado. A `executar` recusa pitch `bloqueado` (seção 2, passo 2), e a `moldar` só aceita `shaping`.
3. **Papel do humano.** O `docs/PLANS.md` cita o humano em cada etapa, mas não diz num lugar só o que ele faz, quando, e com que comando: trazer o problema, responder o shaping, apostar, ler e fazer merge dos PRs do stack, desbloquear, mudar a fase. Quem entra no repositório precisa montar isso lendo as três skills.

Por que agora: o próximo pitch `grande` passa por todos os três.

## Solução

Só documentação de processo: `docs/PLANS.md` e as skills. Sem script novo.

**1. Re-revisão compara a série de patches, não os commits.**

- A `revisar` grava no fim de todo comentário de revisão uma linha `Revisado: <head> sobre <base>`, com o SHA do head do PR e o SHA da base (`git merge-base HEAD origin/<baseRefName>`) no momento da revisão.
- Na re-revisão, o que mudou é `git range-diff <base-revisada>..<head-revisado> <base-atual>..HEAD`, com `<base-atual>` calculada do mesmo jeito. O range-diff casa os commits da série antiga com os da nova e mostra só o que mudou neles, ignorando o que veio de baixo.
- Revisão anterior sem a linha `Revisado:` (feita antes deste pitch): o head vem do `commit.oid` da revisão em `gh pr view --json reviews`, e a base é `git merge-base <head-revisado> origin/<baseRefName>`.

**2. Saída do `bloqueado`, pela skill que já sabe fazer o resto.** O humano diz a decisão na sessão; a skill grava e muda o estado, no branch do escopo e no `main`, como a seção 7 da `executar` faz ao bloquear.

- **Responder ou cortar escopo → `executar`.** Aceita pitch `bloqueado` quando o humano passa o caminho e a decisão. Move a pergunta para o log de decisões (do escopo ou do pitch, onde ela estava), com a resposta e a data; corte de escopo também entra em "No-gos" do pitch. Troca para `em-build` (commit `pitch: desbloqueia <slug>` no `main`) e retoma o stack de onde parou.
- **Voltar ao shaping ou descartar → `moldar`.** Aceita pitch `bloqueado` com o caminho.
  - Voltar ao shaping: fecha os PRs não mergeados do stack (`gh pr close --delete-branch`), remove a worktree, registra no log de decisões o que já foi mergeado e por que voltou, e troca para `shaping`. Escopos mergeados ficam em `escopos/` e contam no apetite do novo shaping.
  - Descartar: fecha os PRs e remove a worktree do mesmo jeito. Sem escopo mergeado, apaga a pasta como no descarte normal. Com escopo mergeado, ver D4.
- `docs/PLANS.md`: a tabela de estados diz quem tira do `bloqueado` (`executar` ou `moldar`, conforme a decisão).

**3. Seção "Papel do humano" no `docs/PLANS.md`.** Uma lista curta, na ordem do fluxo, do que só o humano faz, com o comando ou a skill de cada ação: trazer o problema (`/moldar`), responder o shaping, apostar ou descartar, disparar o build (`/executar`) e a revisão (`/revisar <PR>`), ler e fazer merge dos PRs do stack de baixo para cima, desbloquear, decidir a mudança de fase do `AGENTS.md`. O resto do documento continua dizendo o "como"; a seção só aponta.

## Protótipo

Sem interface.

## Rabbit holes

- **Commit revisado sumiu depois do force-push.** O `git range-diff` precisa dos commits antigos. O GitHub serve um commit por SHA mesmo depois do force-push (`git fetch origin <sha>`), e na mesma máquina o reflog guarda. Se ainda assim não houver o commit, a re-revisão vira revisão completa do PR, mantendo a conferência ✅/❌ dos achados anteriores, e o comentário diz por quê.
- **Base mudou de branch.** Quando o humano faz merge do escopo de baixo, o PR de cima passa a apontar para o `main`. O `<base-atual>` é calculado contra o `baseRefName` atual, então o range-diff continua certo.
- **Descarte depois de escopo mergeado.** Apagar a pasta deixaria código no `main` sem pitch, e os `TODO(<pasta-do-pitch>)` apontando para nada. Ver D4.
- **Pergunta e estado mudam juntos.** O `plan-check.sh` recusa `bloqueado` sem pergunta e `apostado` com pergunta: mover a pergunta e trocar o estado vão no mesmo commit.
- **Range-diff mostra commit reordenado ou dividido.** Ele marca o par como alterado; o revisor lê o patch do PR inteiro nesses casos. Não vale tentar ser mais esperto que o range-diff.

## No-gos

- Script que automatiza a re-revisão ou a saída do bloqueio: as skills descrevem os comandos, o agente roda.
- Checagem nova no `scripts/plan-check.sh`.
- Mudar o modelo de stack (`gh stack`) ou o formato do comentário de revisão além da linha `Revisado:`.
- Notificar o humano fora do terminal (e-mail, Slack, push).

## Revisão do protótipo

Sem protótipo.

## Log de decisões

- **D1. Apetite pequeno (2026-11-08):** pedido do humano. São três mudanças de texto em `docs/PLANS.md` e nas skills, sem código; cabem num PR.
- **D2. Re-revisão por `git range-diff` com base gravada no comentário (2026-11-08):** o range-diff é a ferramenta do git para comparar duas versões de uma série rebaseada. Gravar a base evita depender de `merge-base` com o head antigo, que erra quando o escopo de baixo foi reescrito (amend ou rebase), e não os commits só acrescentados.

- **D3. Saída do `bloqueado` dividida entre `executar` e `moldar`, sem skill nova (2026-11-08):** escolha do humano. Responder ou cortar escopo continua o build, que é da `executar`; voltar ao shaping ou descartar é desenho de pitch, que é da `moldar`. Uma skill nova só encaminharia.
- **D4. Descartar com escopo mergeado vira `entregue` com o que foi mergeado (2026-11-08):** o código mergeado já está no `main` e precisa do pitch como contexto. Os escopos não mergeados saem da pasta, o resto vai para "No-gos" com o motivo do humano, e o `plan-check.sh` já aceita `entregue` com todos os critérios dos escopos restantes marcados. Reverter código mergeado é decisão do humano num pitch próprio, não do descarte.
- 2026-11-08: apostado pelo humano.

## Perguntas em aberto

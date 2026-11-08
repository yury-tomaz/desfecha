# Fluxo

Colina: descendo

## Objetivo

Fechar as três lacunas do pitch no texto do processo: a re-revisão de PR empilhado compara a série de patches (`revisar`), o pitch sai do `bloqueado` pela `executar` ou pela `moldar` conforme a decisão do humano, e o `docs/PLANS.md` ganha a seção "Papel do humano".

## Critérios de aceite

- [x] A `revisar` grava `Revisado: <head> sobre <base>` no fim de todo comentário e, na re-revisão, usa `git range-diff` com a base gravada, com o caminho para revisão anterior sem a linha e para commit antigo ausente. Comprovado por `grep -n "Revisado:\|range-diff" .claude/skills/revisar/SKILL.md`.
- [x] A `executar` aceita pitch `bloqueado` com caminho e decisão (responder ou cortar escopo), move a pergunta para o log de decisões, registra corte em "No-gos" e troca para `em-build` no mesmo commit. Comprovado por `grep -n "bloqueado\|desbloqueia" .claude/skills/executar/SKILL.md`.
- [x] A `moldar` aceita pitch `bloqueado` com caminho para voltar ao shaping ou descartar, fecha os PRs não mergeados e remove a worktree, e no descarte com escopo mergeado entrega o pitch (D4). Comprovado por `grep -n "bloqueado\|gh pr close" .claude/skills/moldar/SKILL.md`.
- [x] A tabela de estados do `docs/PLANS.md` diz quem tira do `bloqueado`, e há uma seção "Papel do humano" com cada ação e o seu comando. Comprovado por `grep -n "Papel do humano\|bloqueado" docs/PLANS.md`.
- [x] Nada fora da documentação mudou e a estrutura dos pitches continua válida. Comprovado por `git diff --stat main` (só `docs/` e `.claude/skills/`) e `scripts/verify.sh`.

## Log de progresso

- 2026-11-08: escopo iniciado.
- 2026-11-08: colina descendo. Os três pontos do pitch estão claros no texto das skills; resta escrever.
- 2026-11-08: `revisar` grava `Revisado: <head> sobre <base>` e a re-revisão usa `git range-diff`. Comprovado num repositório de teste com o caso do pitch: escopo 2 revisado, correção no escopo 1, rebase do escopo 2. `git diff <head-revisado>..HEAD` mostra a correção do escopo 1; `git range-diff` mostra o commit do escopo 2 como `=` (inalterado).
- 2026-11-08: `executar` ganhou "Desbloquear" (seção 7); `moldar` ganhou "Pitch bloqueado" (seção 5); `docs/PLANS.md` ganhou "Papel do humano" e a tabela de estados diz quem tira do `bloqueado`.
- 2026-11-08: critérios verificados pelos comandos indicados; `scripts/verify.sh` ok.
- 2026-11-08: escopo concluído.

## Log de decisões

- **D1. Um escopo só, sem TDD de código (2026-11-08):** apetite `pequeno` e o pitch é só texto de processo; cada critério é comprovado pelo comando que ele indica, como a seção 6.1 da `executar` prevê para o que não se testa com código.
- **D2. Extensão `gh stack` instalada na v0.3.0 (2026-11-08):** não estava na máquina; instalada com `--pin` na versão do D15 de `docs/historico/exec-plans/2026-11-08-shape-up.md`, depois de conferir que `github/gh-stack` é da organização GitHub e que a v0.3.0 é de 2026-10-26. Sem versão nova, não é dependência nova.
- **D3. `entregue` também pela `moldar` na tabela de estados (2026-11-08):** o D4 do pitch faz o descarte com escopo mergeado terminar em `entregue`; sem isso a tabela ficaria falsa.
- **D4. Desbloqueio pela `executar` sempre no branch onde a pergunta foi escrita, com rebase do que está em cima (2026-11-08):** a pergunta e o estado têm de mudar no mesmo commit (rabbit hole do pitch), e o resto do stack precisa dela para o `plan-check.sh` passar em todos os branches.

## Perguntas em aberto

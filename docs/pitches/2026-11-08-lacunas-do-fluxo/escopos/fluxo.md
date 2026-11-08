# Fluxo

Colina: subindo

## Objetivo

Fechar as três lacunas do pitch no texto do processo: a re-revisão de PR empilhado compara a série de patches (`revisar`), o pitch sai do `bloqueado` pela `executar` ou pela `moldar` conforme a decisão do humano, e o `docs/PLANS.md` ganha a seção "Papel do humano".

## Critérios de aceite

- [ ] A `revisar` grava `Revisado: <head> sobre <base>` no fim de todo comentário e, na re-revisão, usa `git range-diff` com a base gravada, com o caminho para revisão anterior sem a linha e para commit antigo ausente. Comprovado por `grep -n "Revisado:\|range-diff" .claude/skills/revisar/SKILL.md`.
- [ ] A `executar` aceita pitch `bloqueado` com caminho e decisão (responder ou cortar escopo), move a pergunta para o log de decisões, registra corte em "No-gos" e troca para `em-build` no mesmo commit. Comprovado por `grep -n "bloqueado\|desbloqueia" .claude/skills/executar/SKILL.md`.
- [ ] A `moldar` aceita pitch `bloqueado` com caminho para voltar ao shaping ou descartar, fecha os PRs não mergeados e remove a worktree, e no descarte com escopo mergeado entrega o pitch (D4). Comprovado por `grep -n "bloqueado\|gh pr close" .claude/skills/moldar/SKILL.md`.
- [ ] A tabela de estados do `docs/PLANS.md` diz quem tira do `bloqueado`, e há uma seção "Papel do humano" com cada ação e o seu comando. Comprovado por `grep -n "Papel do humano\|bloqueado" docs/PLANS.md`.
- [ ] Nada fora da documentação mudou e a estrutura dos pitches continua válida. Comprovado por `git diff --stat main` (só `docs/` e `.claude/skills/`) e `scripts/verify.sh`.

## Log de progresso

- 2026-11-08: escopo iniciado.

## Log de decisões

- **D1. Um escopo só, sem TDD de código (2026-11-08):** apetite `pequeno` e o pitch é só texto de processo; cada critério é comprovado pelo comando que ele indica, como a seção 6.1 da `executar` prevê para o que não se testa com código.
- **D2. Extensão `gh stack` instalada na v0.3.0 (2026-11-08):** não estava na máquina; instalada com `--pin` na versão do D15 de `docs/historico/exec-plans/2026-11-08-shape-up.md`, depois de conferir que `github/gh-stack` é da organização GitHub e que a v0.3.0 é de 2026-10-26. Sem versão nova, não é dependência nova.

## Perguntas em aberto

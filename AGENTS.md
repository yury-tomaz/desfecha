# AGENTS.md

100% do código deste repositório é escrito por agentes de IA. Humanos orquestram.

Este arquivo é um mapa, não um manual. O que dá para descobrir lendo o código não é repetido aqui.

## Fase atual

Base do harness. Não proponha tarefas de produto até a base estar pronta: o humano decide quando a fase muda.

## Onde está cada coisa

- `docs/PRODUCT_SENSE.md`: por que o produto existe e o que é "bom" aqui. Leia antes de decisões de produto ou de modelagem.
- `docs/PLANS.md`: como o trabalho é planejado e registrado.
- `docs/exec-plans/active/`: tarefas em andamento. Comece por aqui.
- `docs/exec-plans/completed/`: tarefas concluídas, com o histórico de decisões.
- `.claude/skills/refinar` e `.claude/skills/executar`: como um plano é refinado e executado.
- `.claude/skills/revisar`: como um PR é revisado.
- `scripts/plan-check.sh <plano>`: verifica se um plano tem a estrutura mínima.
- `backend/`: Spring Boot (Maven Wrapper). `frontend/`: SvelteKit com TypeScript.

## Comandos

- `mise install`: instala as versões de ferramenta fixadas em `mise.toml`.
- `git config core.hooksPath .githooks`: setup, uma vez por clone (vale para todas as worktrees). Liga o hook de pre-push, que roda `scripts/verify.sh`.
- `scripts/verify.sh`: build, testes, tipos, lint e formatação dos dois lados. Tem que passar antes de todo push: o hook de pre-push roda, e o CI roda o mesmo comando a cada push. O commit é livre. `git push --no-verify` é bloqueado por `.claude/settings.json`.
- `scripts/refactor-check.sh`: relatório de duplicação, código morto e complexidade cognitiva para o passo de refactoring. Não bloqueia nada.
- `scripts/format.sh`: formata os dois lados no padrão que a verificação confere.
- `docker-compose up --build`: sobe backend (`:8080`) e frontend (`:3000`). Use `docker-compose`, não `docker compose`.

## Regras

- O que não está no repositório não existe. Decisão tomada fora daqui precisa virar arquivo.
- Docs em português.

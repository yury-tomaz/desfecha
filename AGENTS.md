# AGENTS.md

100% do código deste repositório é escrito por agentes de IA. Humanos orquestram.

Este arquivo é um mapa, não um manual. O que dá para descobrir lendo o código não é repetido aqui.

## Fase atual

Base do harness. Não proponha tarefas de produto até a base estar pronta: o humano decide quando a fase muda.

## Onde está cada coisa

- `docs/PRODUCT_SENSE.md`: por que o produto existe e o que é "bom" aqui. Leia antes de decisões de produto ou de modelagem.
- `docs/produto/`: um arquivo por tema de produto, com o estado atual, as decisões e as perguntas em aberto. O índice está no `PRODUCT_SENSE.md`.
- `docs/SECURITY.md`: ameaças cobertas e não cobertas, onde está cada checagem, como registrar uma exceção. Leia antes de adicionar dependência ou quando uma checagem de segurança falhar.
- `docs/PLANS.md`: o processo (Shape Up adaptado): pitch, aposta, escopos, apetite e circuit breaker.
- `docs/pitches/`: um pitch por pasta, com o estado no `pitch.md` e os escopos em `escopos/`. Comece por aqui.
- `docs/referencias/`: as referências do harness e do processo, com o que usamos de cada uma.
- `docs/historico/exec-plans/`: as tarefas do começo do harness, no formato anterior aos pitches.
- `.claude/skills/moldar` e `.claude/skills/executar`: como um pitch ganha forma e é apostado, e como é construído.
- `.claude/skills/revisar`: como um PR é revisado.
- `scripts/plan-check.sh [pasta-do-pitch]`: verifica a estrutura de pitch e escopos (sem argumento, de todos).
- `prototipo/`: protótipo navegável da plataforma, em HTML, CSS e JS puros, sem build nem dependências. Vai na frente do `frontend/`, que não importa nada dele. Leia `prototipo/README.md` antes de mexer.
- `backend/`: Spring Boot (Maven Wrapper). `frontend/`: SvelteKit com TypeScript.

## Comandos

- `mise install`: instala as versões de ferramenta fixadas em `mise.toml`.
- `git config core.hooksPath .githooks`: setup, uma vez por clone (vale para todas as worktrees). Liga o hook de pre-push, que roda `scripts/verify.sh`.
- `scripts/verify.sh`: build, testes, cobertura, mutação, tipos, lint e formatação dos dois lados. Tem que passar antes de todo push: o hook de pre-push roda, e o CI roda o mesmo comando a cada push. O commit é livre. `git push --no-verify` é bloqueado por `.claude/settings.json`.
- `scripts/refactor-check.sh`: relatório de duplicação, código morto e complexidade cognitiva para o passo de refactoring. Não bloqueia nada.
- `scripts/format.sh`: formata os dois lados no padrão que a verificação confere.
- `docker-compose up --build`: sobe backend (`:8080`) e frontend (`:3000`). Use `docker-compose`, não `docker compose`.

## Regras

- O que não está no repositório não existe. Decisão tomada fora daqui precisa virar arquivo.
- Docs em português.

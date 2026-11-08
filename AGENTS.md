# AGENTS.md

100% do código deste repositório é escrito por agentes de IA. Humanos orquestram.

Este arquivo é um mapa, não um manual. O que dá para descobrir lendo o código não é repetido aqui.

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
- `scripts/verify.sh`: build, testes, tipos e formatação dos dois lados. Tem que passar antes de todo commit. O CI roda o mesmo comando a cada push.
- `scripts/format.sh`: formata os dois lados no padrão que a verificação confere.
- `docker-compose up --build`: sobe backend (`:8080`) e frontend (`:3000`). Use `docker-compose`, não `docker compose`.

## Regras

- O que não está no repositório não existe. Decisão tomada fora daqui precisa virar arquivo.
- Docs em português.

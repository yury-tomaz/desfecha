# Esqueleto do monorepo com verificação automática

Status: refinado

## Objetivo

Criar o mínimo para que um agente consiga mudar código e saber, sozinho, se quebrou algo. Esse comando único de verificação é onde todos os guias e sensores futuros vão se plugar. Além disso, ver o código inicial rodando localmente via Docker e deixar o CI padronizado desde o início.

## Contexto

- Monorepo com `backend/` e `frontend/`.
- Backend: Spring Boot, que vai crescer como monólito modular. Sem abstrações prematuras.
- Frontend: SvelteKit com TypeScript.
- Versões de ferramenta são fixadas no repositório com **mise** (`mise.toml` na raiz): Java 21 e Node 22 LTS. O mise já está instalado na máquina, e o Node 22 também. O Node global da máquina é o 18, fora de suporte; não use.
- Ambiente local encontrado em 2026-11-07: Java 21, Maven 3.9, pnpm 10, Docker via Colima.
- Docker Compose está disponível como `docker-compose` (binário separado, v5). O comando `docker compose` (plugin) **não** existe nesta máquina.
- O remote é GitHub (`origin`), então o CI é GitHub Actions. Ele usa as mesmas versões do `mise.toml`, para não divergir do ambiente local.
- "Deploy" aqui é só subir localmente com `docker-compose`. Não há servidor.

## Critérios de aceite

- [ ] `mise install` na raiz deixa as versões fixadas disponíveis, e `mise exec -- node -v` mostra a versão 22. Comprovado rodando os dois comandos.
- [ ] O backend tem um teste que sobe a aplicação Spring e confirma que o endpoint de saúde responde `UP`. Comprovado pelo comando de verificação.
- [ ] O frontend compila (`build`) e passa na checagem de tipos (`svelte-check`). Comprovado pelo comando de verificação.
- [ ] Backend e frontend têm formatação automática (um comando que formata) e checagem de formatação no comando de verificação. Comprovado assim: desformatar de propósito um arquivo Java e um arquivo do frontend faz a verificação falhar; reverter faz passar. Registrar o resultado no log de progresso.
- [ ] Um único comando na raiz roda build, testes, checagem de tipos e checagem de formatação dos dois lados, e sai com código diferente de zero se qualquer parte falhar. Comprovado quebrando um teste de propósito (falha) e revertendo (passa).
- [ ] `docker-compose up --build` na raiz sobe backend e frontend. Comprovado com `curl` no endpoint de saúde do backend (responde `UP`) e na página inicial do frontend (responde 200).
- [ ] O CI do GitHub Actions roda, a cada push, o mesmo comando de verificação da raiz. Comprovado com `gh run list` mostrando a execução do push do branch da tarefa concluída com sucesso.
- [ ] `AGENTS.md` aponta para o comando de verificação e para o comando que sobe tudo com Docker.

## Fora de escopo

- Qualquer código de produto (tenant, ticket, canal, IA).
- Banco de dados.
- Deploy em servidor, e publicação de imagens Docker em registry.
- No CI, qualquer coisa além do comando de verificação (build de imagem Docker, cache avançado, matriz de versões, proteção de branch).
- Hooks de git.
- Lint além da formatação, fitness functions, testes de arquitetura e revisão inferencial. São as próximas tarefas da base.
- Frontend chamando o backend. Cada lado só precisa responder sozinho.

## Passos

- [ ] `mise.toml` com Java 21 e Node 22
- [ ] Backend Spring Boot mínimo com teste do endpoint de saúde
- [ ] Frontend SvelteKit mínimo
- [ ] Formatação automática nos dois
- [ ] Comando único de verificação na raiz
- [ ] Dockerfiles e `docker-compose.yml`
- [ ] CI no GitHub Actions
- [ ] Atualizar `AGENTS.md`

## Log de progresso

- 2026-11-07: exec-plan criado.
- 2026-11-07: refinado e aprovado.

## Log de decisões

## Perguntas em aberto


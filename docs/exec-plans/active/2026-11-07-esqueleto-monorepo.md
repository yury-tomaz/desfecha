# Esqueleto do monorepo com verificação automática

Status: em-execucao

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

- [x] `mise.toml` com Java 21 e Node 22
- [x] Backend Spring Boot mínimo com teste do endpoint de saúde
- [x] Frontend SvelteKit mínimo
- [x] Formatação automática nos dois
- [x] Comando único de verificação na raiz
- [ ] Dockerfiles e `docker-compose.yml`
- [ ] CI no GitHub Actions
- [ ] Atualizar `AGENTS.md`

## Log de progresso

- 2026-11-07: exec-plan criado.
- 2026-11-07: refinado e aprovado.
- 2026-11-07: execução iniciada.
- 2026-11-07: `mise.toml` criado; `mise install` instalou Java Temurin 21.0.13, Node 22.21.1 e pnpm 10.34.9.
- 2026-11-07: backend gerado pelo start.spring.io (Spring Boot 4.1.2, web + actuator). `HealthTest` passa com `mvnw verify`.
- 2026-11-07: frontend gerado com `sv create` 1.3.0 (SvelteKit 3, Svelte 5, Vite 8, TypeScript 6, Prettier). `build`, `check` e `format:check` passam.
- 2026-11-07: `scripts/verify.sh` e `scripts/format.sh` criados. Provas: Java desformatado → verify sai 1 (Spotless); `+page.svelte` desformatado → sai 1 (Prettier); `HealthTest` quebrado → sai 1 (1 falha); tudo revertido → sai 0. `format.sh` desfaz a desformatação dos dois lados (diff vazio).

## Log de decisões

- **D1. pnpm também fixado no `mise.toml`**: o CI e a máquina local usam a mesma versão do gerenciador de pacotes, não só do Node.
- **D2. Java Temurin pelo mise, não o Java do sistema**: a versão fica igual no local e no CI.
- **D3. Maven Wrapper (`mvnw`) em vez do Maven instalado**: a versão do Maven fica versionada no repositório.
- **D4. Pacote `com.desfecha`**: segue o nome do repositório no GitHub (`desfecha`). Trocar depois é um rename simples.
- **D5. Teste de saúde com servidor real (`RANDOM_PORT`) e `java.net.http.HttpClient`**: comprova que a aplicação sobe e responde HTTP de verdade, sem depender de cliente de teste que mudou de módulo no Spring Boot 4.
- **D6. Spotless com google-java-format 2.0.0 e sortPom**: padrão amplamente usado; a checagem roda na fase `verify` do Maven, então `mvnw verify` já falha com código fora do padrão.
- **D7. Frontend com `adapter-node` em vez de `adapter-auto`**: gera um servidor Node que roda no container Docker.
- **D8. Script `lint` do template renomeado para `format:check`**: ele só roda Prettier, e lint de verdade é outra tarefa. O nome não engana.
- **D9. Comandos em `scripts/verify.sh` e `scripts/format.sh`, sempre via `mise exec`**: ficam ao lado de `plan-check.sh`, e usam as versões do `mise.toml` mesmo se o shell não tiver o mise ativado.

## Perguntas em aberto


# Esqueleto do monorepo com verificação automática

Status: rascunho

## Objetivo

Criar o mínimo para que um agente consiga mudar código e saber, sozinho, se quebrou algo. Esse comando único de verificação é onde todos os guias e sensores futuros vão se plugar.

## Contexto

- Monorepo com `backend/` e `frontend/`.
- Backend: Spring Boot, que vai crescer como monólito modular. Sem abstrações prematuras.
- Frontend: SvelteKit com TypeScript.
- Ambiente local encontrado em 2026-11-07: Java 21, Maven 3.9, Node 18 (fora de suporte), pnpm 10, Docker via Colima.

## Critérios de aceite

- [ ] O backend sobe e tem pelo menos um teste passando.
- [ ] O frontend compila e passa na checagem de tipos.
- [ ] Backend e frontend têm formatação automática, e a checagem de formatação falha se o código estiver fora do padrão.
- [ ] Um único comando na raiz roda build, testes e checagem de formatação dos dois lados, e falha se qualquer parte falhar.
- [ ] O CI roda esse mesmo comando a cada push.
- [ ] `AGENTS.md` aponta para o comando de verificação.

## Fora de escopo

- Qualquer código de produto (tenant, ticket, canal, IA).
- Banco de dados.
- Lint além da formatação, fitness functions, testes de arquitetura e revisão inferencial. São as próximas tarefas da base.

## Passos

- [ ] Backend Spring Boot mínimo com um teste
- [ ] Frontend SvelteKit mínimo
- [ ] Formatação automática nos dois
- [ ] Comando único de verificação na raiz
- [ ] CI
- [ ] Atualizar `AGENTS.md`

## Log de progresso

- 2026-11-07: exec-plan criado.

## Log de decisões

## Perguntas em aberto

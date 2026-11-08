# Segurança parte 2: imagens Docker, análise do código e checklist de revisão

Status: rascunho

## Objetivo

Fechar o que `docs/SECURITY.md` lista em "Ainda não cobertas" e não depende de produto: as imagens Docker sem scan, rodando como root e com base sem digest; nenhuma análise estática de segurança do nosso código; e uma revisão de PR sem checklist de segurança. Junto, o CI passa a construir as imagens, o que o scan exige e que hoje ninguém confere: o `docker-compose up --build` pode quebrar sem aviso.

## Contexto

- Origem: sugestões de próxima tarefa de `2026-11-07-seguranca-base` (segurança parte 2) e de `2026-11-07-esqueleto-monorepo` (CI construir as imagens). Juntas porque o scan precisa da imagem construída e as duas mexem em `backend/Dockerfile`, `frontend/Dockerfile` e `.github/workflows/verify.yml`.
- Estado das imagens hoje:
  - `backend/Dockerfile`: `eclipse-temurin:21-jdk` e `eclipse-temurin:21-jre` por tag, sem `USER`.
  - `frontend/Dockerfile`: `node:22-alpine` por tag, sem `USER`, e instala `pnpm@10` pelo `npm install -g`, sem a versão exata do `mise.toml` (`10.34.9`).
- Regras do CI que continuam valendo (`docs/SECURITY.md`): action fixada por SHA, `permissions` mínimas, `persist-credentials: false`, conferidas pelo zizmor e actionlint no `verify.sh`.
- Ferramenta nova (scanner de imagem, SAST) segue a regra de dependência da skill `executar` e entra com versão exata no `mise.toml` quando for CLI.
- Cada checagem nova ganha uma linha na tabela "Camadas" e sai de "Ainda não cobertas" no `docs/SECURITY.md`.

## Critérios de aceite

- [ ] As duas imagens rodam com usuário sem root. Comprovado com `docker run --rm <imagem> id -u` diferente de `0`.
- [ ] As imagens base estão fixadas por digest, com a tag em comentário, e o Dependabot as atualiza. Comprovado lendo os Dockerfiles e o `.github/dependabot.yml`.
- [ ] O `pnpm` da imagem do frontend tem a mesma versão do `mise.toml`. Comprovado lendo o Dockerfile.
- [ ] O CI constrói as duas imagens a cada push e falha se o build quebrar. Comprovado com um erro de propósito num Dockerfile.
- [ ] O CI falha com vulnerabilidade conhecida na imagem, na gravidade definida no refinamento, com mensagem que diz como corrigir ou registrar exceção. Comprovado com uma imagem base antiga de propósito.
- [ ] Análise estática de segurança roda sobre o código dos dois lados. Comprovado com um caso vulnerável de propósito.
- [ ] A skill `revisar` tem um checklist de segurança. Comprovado lendo a skill.
- [ ] `docs/SECURITY.md` atualizado: "Camadas" com as checagens novas e "Ainda não cobertas" sem elas.
- [ ] `scripts/verify.sh` passa local e no CI.

## Fora de escopo

- Publicar imagem em registry e deploy.
- Isolamento entre tenants, LGPD e limites de ação da IA (são de produto).
- Sandbox do Claude Code (`sandbox.enabled`): é decisão do humano, à parte.
- Mudar configuração do GitHub direto, pela interface ou pela API, sem pedir ao humano.

## Passos

- [ ] Dockerfiles: usuário sem root, base por digest, `pnpm` fixo
- [ ] CI constrói as imagens
- [ ] Scan das imagens
- [ ] Análise estática do código
- [ ] Checklist de segurança na skill `revisar`
- [ ] `docs/SECURITY.md`

## Log de progresso

- 2026-11-08: rascunho criado.

## Log de decisões

## Perguntas em aberto

- O build e o scan das imagens rodam no `verify.sh` (local exige Docker no pre-push) ou só no CI, como um job à parte?
- SAST: CodeQL (workflow do GitHub, só no CI) ou uma CLI que roda no `verify.sh` também (ex.: Semgrep)?
- A partir de qual gravidade o scan da imagem bloqueia? (O OSV-Scanner das dependências bloqueia em qualquer uma.)
- O plano é grande para uma execução só. Dividir em imagens (Dockerfiles, build e scan no CI) e código (SAST e checklist)?

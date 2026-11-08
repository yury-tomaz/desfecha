# Segurança base: segredos e cadeia de suprimentos

Status: em-execucao

## Objetivo

Todo o código deste repositório é escrito por agentes. Os riscos que mais pesam nessa situação são: o agente instalar um pacote malicioso, inexistente (nome inventado) ou com falha conhecida; o agente gravar uma chave ou senha no código; e um workflow do GitHub inseguro. Esta tarefa coloca checagens automáticas para esses três riscos, quase todas dentro de `scripts/verify.sh`, e versiona as regras e as exceções no repositório.

## Contexto

- **Depende de `2026-11-07-sensores-computacionais`.** Os dois planos mexem em `scripts/verify.sh`, `.claude/settings.json`, `AGENTS.md` e na skill `executar`. Esta tarefa só começa depois que aquele plano estiver `concluido` e com o PR no `main`. Com ele, o `.githooks/pre-push` já roda `scripts/verify.sh`, então o que entra no `verify.sh` vale no push e no CI.
- O repositório é público (`yury-tomaz/desfecha`). Estado em 2026-11-07, conferido com `gh api repos/yury-tomaz/desfecha --jq .security_and_analysis`: secret scanning e push protection **ligados**; Dependabot security updates, validity checks e non-provider patterns **desligados**. Configuração do GitHub não fica no repositório, por isso vai descrita em `docs/SECURITY.md` junto com o comando que confere.
- Ferramentas novas entram no `mise.toml` com versão exata (não `latest`, não só a major), para o local e o CI usarem a mesma. Versões disponíveis no mise em 2026-11-07: gitleaks 8.30.1, osv-scanner 2.7.0, zizmor 1.32.0, actionlint 1.7.12.
- **Por que versão exata e actions por SHA:** em março de 2026 as tags da `aquasecurity/trivy-action` foram reescritas por um atacante e passaram a rodar código que roubava credenciais (CVE-2026-33634). Quem fixava a action por SHA de commit não foi afetado. Por isso: nada de Trivy nesta tarefa, poucas ferramentas, todas com versão fixa, e todas as actions fixadas pelo SHA completo com a tag em comentário (`uses: actions/checkout@<sha> # v7`).
- **Segredos:** gitleaks, não Betterleaks. Betterleaks (março de 2026, do mesmo autor) aceita a mesma configuração, mas é novo. Trocar depois é barato.
- **Bibliotecas (SCA):** OSV-Scanner, que lê `backend/pom.xml` e `frontend/pnpm-lock.yaml`. Uma ferramenta para os dois lados. Decisão do humano (2026-11-07): **qualquer** vulnerabilidade conhecida trava, de qualquer gravidade, mesmo num push que não tem relação com a biblioteca. Para destravar, o agente atualiza a biblioteca ou registra uma exceção com motivo e prazo.
- **pnpm:** em `frontend/pnpm-workspace.yaml`, além do `onlyBuiltDependencies` que já existe: `minimumReleaseAge` (versão só instala depois de 3 dias publicada, 4320 minutos), `trustPolicy: no-downgrade` (recusa versão com nível de confiança de publicação menor que a anterior) e `blockExoticSubdeps` (recusa dependência vinda de git ou URL). `trustPolicy` exige pnpm 10.21 ou mais novo: o `mise.toml` hoje diz só `"10"`.
- **Dependabot:** `.github/dependabot.yml` para `maven` (`/backend`), `npm` (`/frontend`, o Dependabot entende pnpm por esse nome) e `github-actions`. Com `cooldown` alinhado ao `minimumReleaseAge` (3 dias), para o Dependabot não propor versão que o pnpm recusa.
- **Workflows:** zizmor e actionlint sobre `.github/workflows/`. Os workflows declaram `permissions` mínimas (`contents: read`) e o checkout usa `persist-credentials: false`. As auditorias online do zizmor precisam de `GH_TOKEN`: quem executa decide se roda online no CI e offline no local.
- **Policy as code, versão leve:** regras e exceções ficam em arquivos versionados. Toda exceção tem motivo e data de validade. Depois da data, a verificação volta a falhar. O OSV-Scanner já suporta isso no `osv-scanner.toml` (`ignoreUntil` e `reason`). No gitleaks, exceção só para falso positivo, com o motivo escrito ao lado. Decisão do humano (2026-11-07): o agente pode criar uma exceção sozinho, desde que registre o motivo no log de decisões do plano em execução; o prazo máximo é de 30 dias a partir do dia em que a exceção é criada, e a verificação recusa exceção sem motivo ou com prazo maior. Como o `osv-scanner.toml` não guarda a data de criação, quem executa escolhe como conferir o limite (ex.: `ignoreUntil` no máximo 30 dias depois de hoje) e registra. OPA/Conftest fica para quando houver infraestrutura (Kubernetes, Terraform) para validar.
- **Agente:** `.claude/settings.json` (criado pelo plano de sensores) ganha regras `deny` para o agente não ler segredos: `.env*` do projeto, `~/.ssh`, `~/.aws`, `~/.config/gh` e afins. A regra de `Read` não cobre `cat` pelo Bash: as duas formas precisam ser bloqueadas.
- **Pacote com nome inventado:** a skill `executar` passa a exigir que toda dependência nova seja registrada no log de decisões do plano com o motivo e a confirmação de que o pacote é o esperado (nome, autor, repositório de origem).
- Regra das mensagens (a mesma do plano de sensores): toda falha das checagens desta tarefa diz o que está errado e como corrigir, escrita para o agente. Quando a mensagem vem da ferramenta e não dá para trocar, `scripts/verify.sh` imprime uma linha a mais com o que fazer.

## Critérios de aceite

- [ ] Uma chave falsa com formato real (ex.: um token de AWS de exemplo) num arquivo commitado faz `scripts/verify.sh` falhar com mensagem que diz como corrigir. Remover faz passar. Registrar no log de progresso.
- [ ] Uma dependência com vulnerabilidade conhecida (uma versão antiga de propósito, no `pom.xml` e no `package.json`) faz `scripts/verify.sh` falhar. Uma exceção no `osv-scanner.toml` com motivo e data futura faz passar. A mesma exceção com data passada volta a falhar, assim como uma exceção sem motivo ou com prazo de mais de 30 dias. Registrar no log de progresso.
- [ ] `frontend/pnpm-workspace.yaml` tem `minimumReleaseAge`, `trustPolicy` e `blockExoticSubdeps`, e o `mise.toml` fixa um pnpm que aceita todos. Comprovado assim: tentar instalar uma versão publicada há menos de 3 dias é recusado; registrar o comando e a saída no log de progresso.
- [ ] `.github/dependabot.yml` cobre `maven`, `npm` e `github-actions`, com cooldown. Comprovado lendo o arquivo. Ligar Dependabot alerts e security updates no GitHub é passo do humano: fica listado em `docs/SECURITY.md` e na descrição do PR, com o comando `gh api` que confere.
- [ ] Todas as actions em `.github/workflows/` estão fixadas por SHA completo, os workflows declaram `permissions`, e zizmor e actionlint rodam em `scripts/verify.sh`. Comprovado assim: trocar um SHA por tag faz a verificação falhar; reverter faz passar.
- [ ] `.claude/settings.json` impede o agente de ler `.env`, `~/.ssh` e `~/.aws`. Comprovado listando no log de progresso as formas testadas (ex.: `Read` de `.env`, `cat .env`, `cat ~/.ssh/id_ed25519`) e o resultado de cada uma.
- [ ] `docs/SECURITY.md` existe, em português, e traz: as ameaças que esta base cobre e as que ainda não cobre; cada camada e onde está configurada; como registrar uma exceção; as configurações esperadas do GitHub e o comando `gh api` que as confere; como reportar uma vulnerabilidade. Comprovado lendo o arquivo.
- [ ] `AGENTS.md` aponta para `docs/SECURITY.md`. A skill `executar` traz a regra de dependência nova e a de exceção com prazo. Comprovado lendo os dois arquivos.
- [ ] O código atual passa em todas as checagens novas e `scripts/verify.sh` passa local e no CI. Comprovado com `gh run list` no push do branch da tarefa.

## Fora de escopo

- CodeQL ou outra análise estática de segurança (SAST).
- Scan de imagem Docker, Dockerfile sem root, fixar imagem base por digest.
- Checklist de segurança na skill `revisar`.
- OPA, Conftest ou outra engine de política.
- Trivy, Snyk, Betterleaks ou qualquer ferramenta além das citadas no Contexto.
- Isolamento entre tenants, LGPD, limites de ação da IA: são de produto.
- Workflows novos no CI. Os workflows existentes mudam só para fixar SHA, declarar `permissions` e passar `GH_TOKEN` ao zizmor, se quem executa decidir assim.
- Mudar configurações do GitHub direto (pela interface ou pela API) sem pedir ao humano.

## Passos

- [ ] Fixar versões no `mise.toml` (gitleaks, osv-scanner, zizmor, actionlint e o pnpm exato)
- [ ] gitleaks em `scripts/verify.sh`, com config e regra de exceção
- [ ] OSV-Scanner em `scripts/verify.sh`, com `osv-scanner.toml`
- [ ] Endurecer o pnpm em `frontend/pnpm-workspace.yaml`
- [ ] `.github/dependabot.yml`
- [ ] Actions por SHA, `permissions`, zizmor e actionlint em `scripts/verify.sh`
- [ ] Regras `deny` de segredos em `.claude/settings.json`
- [ ] `docs/SECURITY.md`
- [ ] Atualizar `AGENTS.md` e a skill `executar`

## Log de progresso

- 2026-11-07: exec-plan criado.
- 2026-11-07: sugestão de próxima tarefa: segurança parte 2 (CodeQL, scan de imagem Docker, Dockerfile sem root e imagem base por digest, checklist de segurança na skill `revisar`).
- 2026-11-07: refinado e aprovado.
- 2026-11-07: execução iniciada.

## Log de decisões

## Perguntas em aberto

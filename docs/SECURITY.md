# Segurança

Todo o código daqui é escrito por agentes. Esta base cobre os riscos que mais pesam nesse cenário, com checagens automáticas que rodam em `scripts/verify.sh` (no pre-push e no CI) e regras versionadas.

## Ameaças

### Cobertas

| Ameaça | Como é coberta |
|---|---|
| Agente grava chave, token ou senha no código | gitleaks no `verify.sh`, nos arquivos e nos commits ainda não publicados; secret scanning e push protection do GitHub para o que já foi publicado |
| Biblioteca com vulnerabilidade conhecida | OSV-Scanner no `verify.sh`, nos dois lados, qualquer gravidade |
| Pacote recém-publicado e comprometido | pnpm só instala versão com 3 dias ou mais; Dependabot com o mesmo cooldown |
| Pacote republicado com procedência pior (ex.: sem provenance depois de ter) | `trustPolicy: no-downgrade` no pnpm |
| Dependência vinda de git ou URL, fora do registro | `blockExoticSubdeps` no pnpm |
| Pacote com nome inventado pelo agente | toda dependência nova vai para o log de decisões do escopo, com nome, autor e repositório conferidos (skill `executar`) |
| Action do GitHub com tag reescrita por atacante | toda action fixada pelo SHA completo; zizmor e actionlint no `verify.sh` |
| Workflow com permissão demais ou token persistido | `permissions: contents: read` e `persist-credentials: false`, conferidos pelo zizmor |
| Agente lê `.env` ou credenciais da máquina | regras `deny` em `.claude/settings.json` |
| Ferramenta de segurança trocada por versão maliciosa | versões exatas no `mise.toml` |

### Ainda não cobertas

- Análise estática de segurança do nosso código (SAST, ex.: CodeQL).
- Imagem Docker: scan, usuário sem root, imagem base fixada por digest.
- Script Node ou Python rodado pelo agente que abre um arquivo de credencial sozinho: as regras `deny` cobrem as ferramentas do Claude Code e os comandos de arquivo que ele reconhece no Bash (`cat`, `head`, `tail`, `sed`...), não qualquer processo. Fechar isso pede o sandbox do Claude Code (`sandbox.enabled`). Desligado por decisão do humano em 2026-11-08, para uma próxima fase: não há dado nem segredo de produto na máquina. As credenciais que existem são a chave SSH e o login do `gh`, com escrita no repositório, e o vetor é código de dependência rodando no `verify.sh`, que o pnpm já restringe (idade mínima, sem script de instalação além do `esbuild`). Reavaliar quando entrar segredo de produto ou deploy.
- Segredo que já está no `origin/main`: o gitleaks olha os arquivos e os commits que ainda não estão lá. O que já foi publicado depende do secret scanning do GitHub, que só reconhece padrões de provedor (senha ou segredo genérico passam, com non-provider patterns desligado).
- Dependência que já está no lockfile não é reavaliada pela idade mínima do pnpm; só o OSV-Scanner a confere.
- Checklist de segurança na revisão de PR (skill `revisar`).
- Isolamento entre tenants, LGPD e limites de ação da IA: são decisões de produto.

## Camadas

| Camada | Ferramenta | Onde está |
|---|---|---|
| Segredos | gitleaks | `scripts/segredos-check.sh`, `.gitleaks.toml`; casos em `scripts/segredos-check.test.sh` |
| Bibliotecas | OSV-Scanner | `scripts/dependencias-check.sh`, `osv-scanner.toml`; exceções conferidas por `scripts/dependencias-excecoes-check.sh` |
| Instalação de pacotes | pnpm | `frontend/pnpm-workspace.yaml` (`minimumReleaseAge`, `trustPolicy`, `blockExoticSubdeps`, `overrides`) |
| Protótipo sem dependências | `prototipo-check` | `scripts/prototipo-check.sh` (sem `package.json`, sem script nem módulo carregado de URL em `prototipo/`); casos em `scripts/prototipo-check.test.sh`; regras em `prototipo/README.md` |
| Atualizações | Dependabot | `.github/dependabot.yml` |
| Workflows | zizmor, actionlint | `scripts/verify.sh` (zizmor offline) e `.github/workflows/verify.yml` (zizmor online, com `GH_TOKEN` só nesse passo) |
| Agente | Claude Code | `.claude/settings.json` (`permissions.deny`) |
| Versões das ferramentas | mise | `mise.toml` |

O backend é escaneado pela árvore que o Maven resolve (`mvnw dependency:list`), com as dependências transitivas. O OSV-Scanner lendo o `pom.xml` direto não vê as versões que vêm do parent do Spring Boot.

O gitleaks varre os arquivos versionados e os novos que o git não ignora (o que pode entrar num commit) e os commits de `origin/main..HEAD` (o que vai no push). Sem `origin/main`, varre todo o histórico disponível.

## Exceções

Quem constrói um escopo pode criar uma exceção sozinho, desde que registre o motivo no log de decisões do escopo. Antes de criar, tente corrigir: atualizar a biblioteca, ou tirar o segredo do código.

### Vulnerabilidade de biblioteca (`osv-scanner.toml`)

Só quando não há versão corrigida ou a atualização não é possível agora. Um bloco por vulnerabilidade:

```toml
[[IgnoredVulns]]
id = "GHSA-xxxx-xxxx-xxxx"
ignoreUntil = 2026-12-07
reason = "por que é aceitável por enquanto: onde a biblioteca entra e por que a falha não nos atinge"
```

- `id`, `reason` e `ignoreUntil` são obrigatórios. `ignoreUntil` é uma data sem aspas.
- O prazo máximo é de 30 dias a partir de hoje. Como o arquivo não guarda a data de criação, a checagem recusa qualquer `ignoreUntil` mais de 30 dias depois do dia em que roda.
- Exceção vencida falha. Renove só com um novo motivo no log de decisões, ou apague.
- O arquivo só aceita blocos `[[IgnoredVulns]]` com as chaves `id`, `ignoreUntil` e `reason`, cada uma numa linha. Qualquer outra forma é recusada, inclusive tabela inline (`IgnoredVulns = [{ ... }]`) e `PackageOverrides`, que ignora o pacote inteiro.

### Falso positivo de segredo (`.gitleaks.toml`)

Só para o que não é segredo (ex.: um valor de exemplo da documentação). Um bloco com `description` dizendo por quê:

```toml
[[allowlists]]
description = "valor de exemplo da documentação do provedor, não é credencial"
paths = ['''caminho/do/arquivo''']
```

- Sem `description`, a checagem falha.
- Comentário `gitleaks:allow` e arquivo `.gitleaksignore` não valem: não guardam o motivo.
- O arquivo só aceita `[extend]` com `useDefault = true` e blocos `[[allowlists]]`. Desligar ou trocar regra (`disabledRules`, `[[rules]]`, `[allowlist]`, `useDefault = false`, `extend` de outro arquivo) é recusado.
- Falso positivo não tem prazo.

### Segredo de verdade no código

Não há exceção. Tire o valor do arquivo e leia de variável de ambiente ou de um `.env` ignorado pelo git. Se ele já entrou num commit, apagar num commit novo não basta: o commit antigo vai junto no push e a checagem continua falhando. Refaça os commits sem o segredo (`git reset --soft origin/main`, tire o valor, commite de novo). Se algum desses commits já foi para um branch remoto, considere a credencial vazada e peça ao humano para revogá-la.

## Configurações do GitHub

Ficam fora do repositório, então são passo do humano. Esperado em `yury-tomaz/desfecha`:

| Configuração | Esperado | Estado em 2026-11-07 |
|---|---|---|
| Secret scanning | ligado | ligado |
| Push protection | ligado | ligado |
| Dependabot alerts | ligado | desligado |
| Dependabot security updates | ligado | desligado |
| Private vulnerability reporting | ligado | desligado |

Para conferir:

```bash
gh api repos/yury-tomaz/desfecha --jq .security_and_analysis
gh api repos/yury-tomaz/desfecha/vulnerability-alerts --silent && echo "alerts ligado"   # 404 = desligado
gh api repos/yury-tomaz/desfecha/automated-security-fixes --jq .enabled                 # security updates
gh api repos/yury-tomaz/desfecha/private-vulnerability-reporting --jq .enabled
```

O esperado é `secret_scanning` e `secret_scanning_push_protection` com `"status": "enabled"`, `alerts ligado` impresso, e `true` nos dois últimos.

Para ligar (em Settings → Advanced Security, ou pela API):

```bash
gh api -X PUT repos/yury-tomaz/desfecha/vulnerability-alerts
gh api -X PUT repos/yury-tomaz/desfecha/automated-security-fixes
gh api -X PUT repos/yury-tomaz/desfecha/private-vulnerability-reporting
```

Agentes não mudam essas configurações sem o humano pedir.

## Como reportar uma vulnerabilidade

Não abra issue pública. Use o reporte privado do GitHub: aba **Security** do repositório → **Report a vulnerability** (precisa do private vulnerability reporting ligado, acima). Descreva o que encontrou, como reproduzir e o impacto.

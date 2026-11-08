#!/usr/bin/env bash
# Comando único de verificação: build, testes, cobertura, tipos, lint e formatação do backend e do frontend.
# Uso: scripts/verify.sh
# Sai com código diferente de zero se qualquer parte falhar.
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n==> %s\n' "$1"; }

step "harness: casos do hook que bloqueia git push --no-verify"
mise exec -- .claude/hooks/bloqueia-push-no-verify.test.sh

step "segredos: casos da checagem"
mise exec -- scripts/segredos-check.test.sh

step "segredos: arquivos versionados e novos (gitleaks)"
mise exec -- scripts/segredos-check.sh

step "dependências: casos da checagem de exceções"
scripts/dependencias-excecoes-check.test.sh

step "dependências: vulnerabilidades conhecidas (OSV-Scanner)"
mise exec -- scripts/dependencias-check.sh

step "produto: casos da checagem dos temas"
scripts/produto-check.test.sh

step "produto: índice e seções dos temas de docs/produto"
scripts/produto-check.sh

step "protótipo: casos da checagem"
scripts/prototipo-check.test.sh

step "protótipo: sem dependências e fora dos imports do frontend"
scripts/prototipo-check.sh

step "pitches: casos da checagem"
scripts/plan-check.test.sh

step "pitches: estrutura de pitch e escopos em docs/pitches"
scripts/plan-check.sh

step "workflows: actionlint e zizmor"
if ! mise exec -- actionlint || ! mise exec -- zizmor --offline --no-progress .github/workflows; then
  echo "Como corrigir: siga o help de cada achado acima. Toda action vai fixada pelo SHA completo do commit com a tag em comentário (uses: dono/action@<sha de 40 caracteres> # v1.2.3; o SHA sai de gh api repos/<dono>/<action>/commits/<tag> --jq .sha), o workflow declara permissions mínimas e o checkout usa persist-credentials: false (regras em docs/SECURITY.md)." >&2
  exit 1
fi

step "backend: build, testes, cobertura e formatação (mvnw verify)"
if ! mise exec -- ./backend/mvnw -B -q -f backend/pom.xml verify; then
  echo "Como corrigir: siga o erro acima. Se foi a cobertura (jacoco-maven-plugin:check, Coverage checks have not been met), o mínimo é 80% de linhas e de branches no total do código de produção, menos BackendApplication: backend/target/site/jacoco/jacoco.csv diz, por classe, as linhas (LINE_MISSED) e os branches (BRANCH_MISSED) sem teste, e backend/target/site/jacoco/jacoco.xml diz quais linhas (<line nr=... mi ou mb maior que 0>). Escreva testes de comportamento para elas." >&2
  exit 1
fi

step "frontend: dependências"
(cd frontend && mise exec -- pnpm install --frozen-lockfile --silent)

step "frontend: formatação"
(cd frontend && mise exec -- pnpm format:check)

step "frontend: lint (ESLint)"
(cd frontend && mise exec -- pnpm lint)

step "frontend: testes e cobertura (Vitest)"
if ! (cd frontend && mise exec -- pnpm test); then
  echo "Como corrigir: se um teste falhou, corrija o código (o teste só muda se estava errado, com registro no log de decisões). Se a cobertura ficou abaixo do mínimo (ERROR: Coverage for ...), escreva testes de comportamento para as linhas da coluna Uncovered Line #s da tabela acima. A cobertura mede só src/lib/**/*.ts e pede 80% de linhas e de branches no total." >&2
  exit 1
fi

step "frontend: testes das regras locais do ESLint"
(cd frontend && mise exec -- pnpm test:sensores)

step "frontend: tipos"
(cd frontend && mise exec -- pnpm check)

step "frontend: build"
(cd frontend && mise exec -- pnpm build)

printf '\nverificação ok\n'

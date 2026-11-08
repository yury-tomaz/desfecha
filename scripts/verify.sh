#!/usr/bin/env bash
# Comando único de verificação: build, testes, tipos, lint e formatação do backend e do frontend.
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

step "backend: build, testes e formatação (mvnw verify)"
mise exec -- ./backend/mvnw -B -q -f backend/pom.xml verify

step "frontend: dependências"
(cd frontend && mise exec -- pnpm install --frozen-lockfile --silent)

step "frontend: formatação"
(cd frontend && mise exec -- pnpm format:check)

step "frontend: lint (ESLint)"
(cd frontend && mise exec -- pnpm lint)

step "frontend: testes (Vitest)"
(cd frontend && mise exec -- pnpm test)

step "frontend: testes das regras locais do ESLint"
(cd frontend && mise exec -- pnpm test:sensores)

step "frontend: tipos"
(cd frontend && mise exec -- pnpm check)

step "frontend: build"
(cd frontend && mise exec -- pnpm build)

printf '\nverificação ok\n'

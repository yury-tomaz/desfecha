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

step "backend: build, testes e formatação (mvnw verify)"
mise exec -- ./backend/mvnw -B -q -f backend/pom.xml verify

step "frontend: dependências"
(cd frontend && mise exec -- pnpm install --frozen-lockfile --silent)

step "frontend: formatação"
(cd frontend && mise exec -- pnpm format:check)

step "frontend: lint (ESLint)"
(cd frontend && mise exec -- pnpm lint)

step "frontend: testes das regras locais do ESLint"
(cd frontend && mise exec -- pnpm test:sensores)

step "frontend: tipos"
(cd frontend && mise exec -- pnpm check)

step "frontend: build"
(cd frontend && mise exec -- pnpm build)

printf '\nverificação ok\n'

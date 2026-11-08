#!/usr/bin/env bash
# Relatório para o passo de refactoring: duplicação, código morto e complexidade cognitiva.
# Uso: scripts/refactor-check.sh
# Sempre sai com 0: os achados orientam o refactoring, não bloqueiam a verificação nem o push.
set -uo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n==> %s\n' "$1"; }

step "duplicação (jscpd: Java, TypeScript e Svelte)"
(cd frontend && mise exec -- pnpm exec jscpd \
  --format java,typescript,javascript,svelte --min-tokens 50 --no-colors \
  --ignore '**/node_modules/**,**/.svelte-kit/**,**/build/**,**/target/**' \
  src ../backend/src)

step "código morto no frontend (knip)"
(cd frontend && mise exec -- pnpm exec knip --no-exit-code)

step "código morto e complexidade cognitiva no backend (PMD)"
mise exec -- ./backend/mvnw -B -f backend/pom.xml pmd:check | grep -E 'PMD Failure|PMD .* found|ERROR' || echo "nenhum achado"

step "complexidade cognitiva no frontend (ESLint sonarjs/cognitive-complexity)"
(cd frontend && mise exec -- pnpm exec eslint . --rule 'sonarjs/cognitive-complexity: [warn, 15]')

printf '\nrelatório concluído. Os achados acima são candidatos a refactoring, não erros.\n'
exit 0

#!/usr/bin/env bash
# Formata o backend e o frontend no padrão que scripts/verify.sh confere.
# Uso: scripts/format.sh
set -euo pipefail
cd "$(dirname "$0")/.."

mise exec -- ./backend/mvnw -B -q -f backend/pom.xml spotless:apply
(cd frontend && mise exec -- pnpm format)

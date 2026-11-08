#!/usr/bin/env bash
# Lista o código de produção alterado em relação ao ponto em que o branch saiu do origin/main,
# commitado ou não: é o que o teste de mutação mede (scripts/mutacao-check.sh).
# Uso: scripts/mutacao-alterados.sh [raiz-do-repositório]
# Casos cobertos: scripts/mutacao-alterados.test.sh.
set -euo pipefail
raiz=${1:-"$(cd "$(dirname "$0")/.." && pwd)"}
cd "$raiz"
# O hook de pre-push roda com GIT_DIR definido. Herdado, ele apontaria o git para outro repositório que não a raiz.
# shellcheck disable=SC2046
unset $(git rev-parse --local-env-vars)

if ! git rev-parse --verify -q origin/main >/dev/null; then
  echo "Sem origin/main, não há base para saber o que mudou, e a mutação passaria sem medir nada." >&2
  echo "Como corrigir: busque o main (git fetch origin main). No CI, o checkout precisa de fetch-depth: 0." >&2
  exit 1
fi

base=$(git merge-base HEAD origin/main)
# Com o core.quotePath padrão, nome com acento sai entre aspas e com escape octal, e o filtro o descartaria.
alterados=$(git -c core.quotePath=false diff --name-only --diff-filter=ACMR "$base" &&
  git -c core.quotePath=false ls-files --others --exclude-standard)
# BackendApplication fica fora como na cobertura: o único código dela é o main(), que nenhum teste chama.
awk '
  /^backend\/src\/main\/java\/com\/desfecha\/BackendApplication\.java$/ { next }
  /\.test\.ts$/ { next }
  /^backend\/src\/main\/java\/.+\.java$/ || /^frontend\/src\/lib\/.+\.ts$/
' <<<"$alterados" | sort -u

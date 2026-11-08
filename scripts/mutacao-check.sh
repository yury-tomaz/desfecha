#!/usr/bin/env bash
# Teste de mutação no código de produção alterado (lista de scripts/mutacao-alterados.sh):
# PIT no backend, Stryker no frontend. Falha com score abaixo de 80% e diz que mutante sobreviveu e onde.
# Uso: scripts/mutacao-check.sh
set -euo pipefail
cd "$(dirname "$0")/.."

alterados=$(scripts/mutacao-alterados.sh)
backend=$(grep '^backend/' <<<"$alterados" || true)
frontend=$(grep '^frontend/' <<<"$alterados" || true)
log=$(mktemp)
trap 'rm -f "$log"' EXIT

como_corrigir() {
  echo "Como corrigir: cada mutante vivo acima é uma mudança no código que nenhum teste percebeu. Escreva um teste de comportamento que falhe com ela (o caso de borda, o outro lado do if, o valor de retorno conferido). O mínimo é 80% de mutantes mortos nos arquivos alterados em relação ao origin/main; o que fica abaixo de 100% é para mutante equivalente, que não muda o comportamento. Se o Stryker diz No tests were executed, nenhum teste importa o arquivo alterado: o teste dele ainda não existe." >&2
}

if [ -z "$alterados" ]; then
  echo "nenhum código de produção alterado em relação ao origin/main: a mutação não roda"
  exit 0
fi

if [ -n "$backend" ]; then
  # backend/src/main/java/com/x/A.java vira com.x.A e com.x.A$*, para pegar as classes internas.
  classes=$(sed -E 's|^backend/src/main/java/||; s|\.java$||; s|/|.|g; s|.*|&,&$*|' <<<"$backend" | paste -sd, -)
  echo "backend: PIT em $(tr '\n' ' ' <<<"$backend")"
  relatorio=backend/target/pit-reports/mutations.csv
  rm -f "$relatorio"
  if ! mise exec -- ./backend/mvnw -B -q -f backend/pom.xml test-compile pitest:mutationCoverage -DtargetClasses="$classes" >"$log" 2>&1; then
    grep -m 1 '^\[ERROR\]' "$log" >&2 || cat "$log" >&2
    if [ -f "$relatorio" ]; then
      echo "Mutantes vivos no backend (arquivo:linha classe.método mutador):" >&2
      awk -F, '$6 == "SURVIVED" || $6 == "NO_COVERAGE" {
        n = split($3, m, "."); print "  " $1 ":" $5 " " $2 "." $4 " " m[n] " (" $6 ")"
      }' "$relatorio" >&2
    fi
    como_corrigir
    exit 1
  fi
fi

if [ -n "$frontend" ]; then
  arquivos=$(sed 's|^frontend/||' <<<"$frontend" | paste -sd, -)
  echo "frontend: Stryker em $(tr '\n' ' ' <<<"$frontend")"
  if ! (cd frontend && mise exec -- pnpm exec stryker run --mutate "$arquivos") >"$log" 2>&1; then
    # Arquivo só com tipos não tem mutante nem teste, e o Stryker recusa rodar sem teste. O allowEmpty
    # não serve: com ele, código sem nenhum teste também passa, sem calcular o score.
    if grep -q 'Instrumented [0-9]* source file(s) with 0 mutant(s)' "$log"; then
      exit 0
    fi
    echo "Mutantes vivos no frontend ([Survived] ou [NoCoverage], com arquivo:linha:coluna e a mudança):" >&2
    grep -v ' INFO ' "$log" >&2
    como_corrigir
    exit 1
  fi
fi

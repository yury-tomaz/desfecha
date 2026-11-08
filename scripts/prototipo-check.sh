#!/usr/bin/env bash
# Confere as duas fronteiras do protótipo: o frontend/ não referencia prototipo/, e o prototipo/ não tem
# dependência (package.json nem script carregado de fora). Regras em prototipo/README.md.
# Uso: scripts/prototipo-check.sh [raiz do repositório]
set -euo pipefail
raiz=${1:-"$(dirname "$0")/.."}
cd "$raiz"

falhou=0

# Qualquer string com o segmento de caminho "prototipo" conta, e não só import: um alias no vite.config.ts
# deixaria o import em si sem o nome da pasta.
referencias=$(grep -rnIE --exclude-dir=node_modules --exclude-dir=.svelte-kit --exclude-dir=build \
  "[\"'\`]([^\"'\`]*/)?prototipo(/[^\"'\`]*)?[\"'\`]" frontend || true)
if [ -n "$referencias" ]; then
  echo "O frontend/ referencia o prototipo/:" >&2
  echo "$referencias" | sed 's/^/  /' >&2
  echo "Como corrigir: o frontend/ não importa nada do prototipo/, nem por alias. Reescreva no frontend/ o que precisar da tela, e aponte a tela do protótipo no exec-plan (regras em prototipo/README.md)." >&2
  falhou=1
fi

pacotes=$(find prototipo -name package.json)
remotos=$(grep -rnIiE \
  -e "<script[^>]*src[[:space:]]*=[[:space:]]*[\"']?(https?:)?//" \
  -e "(from|import)[[:space:]]*\(?[[:space:]]*[\"'\`](https?:)?//" \
  --include="*.html" --include="*.htm" --include="*.js" --include="*.mjs" --include="*.svg" prototipo || true)
if [ -n "$pacotes" ] || [ -n "$remotos" ]; then
  echo "O prototipo/ tem dependência:" >&2
  [ -n "$pacotes" ] && echo "$pacotes" | sed 's/^/  /' >&2
  [ -n "$remotos" ] && echo "$remotos" | sed 's/^/  /' >&2
  echo "Como corrigir: o protótipo é HTML, CSS e JS puros, sem build. Apague o package.json e escreva o JS no próprio prototipo/, em vez de carregar script ou módulo de uma URL. Fonte externa por <link> pode (regras em prototipo/README.md e docs/SECURITY.md)." >&2
  falhou=1
fi

[ "$falhou" -eq 0 ] || exit 1
echo "protótipo ok"

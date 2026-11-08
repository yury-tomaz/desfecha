#!/usr/bin/env bash
# Confere as duas fronteiras do protótipo: o frontend/ não referencia prototipo/, e o prototipo/ não tem
# dependência (package.json nem script carregado de fora). Regras em prototipo/README.md.
# Uso: scripts/prototipo-check.sh [raiz do repositório]
set -euo pipefail
raiz=${1:-"$(dirname "$0")/.."}
cd "$raiz"

falhou=0

# Qualquer string com o segmento de caminho "prototipo" conta, e não só import: um alias no vite.config.ts
# deixaria o import em si sem o nome da pasta. Em CSS, url() costuma vir sem aspas.
referencias=$(grep -rnIE --exclude-dir=node_modules --exclude-dir=.svelte-kit --exclude-dir=build \
  -e "[\"'\`]([^\"'\`]*/)?prototipo(/[^\"'\`]*)?[\"'\`]" \
  -e "url\([[:space:]]*([^)\"'\`]*/)?prototipo(/|[[:space:]]*\))" \
  frontend || true)

# O grep -r não segue symlink, e o import que passa por um link não tem o nome da pasta.
prototipo_real=$(cd prototipo && pwd -P)
while IFS= read -r link; do
  destino=$(realpath "$link" 2>/dev/null || true)
  case "$destino" in
    "$prototipo_real" | "$prototipo_real"/*) referencias+=$'\n'"$link: symlink para $destino" ;;
  esac
done < <(find frontend \( -name node_modules -o -name .svelte-kit -o -name build \) -prune -o -type l -print)
referencias=$(sed '/^$/d' <<<"$referencias")

if [ -n "$referencias" ]; then
  echo "O frontend/ referencia o prototipo/:" >&2
  echo "$referencias" | sed 's/^/  /' >&2
  echo "Como corrigir: o frontend/ não importa nada do prototipo/, nem por alias, url() de CSS ou symlink. Apague o symlink, se for o caso. Reescreva no frontend/ o que precisar da tela, e aponte a tela do protótipo no pitch (regras em prototipo/README.md)." >&2
  falhou=1
fi

pacotes=$(find prototipo -name package.json)
# Cada arquivo vira uma linha só antes da busca: uma tag <script> costuma ter um atributo por linha.
# Import map fica proibido de vez: sem dependência ele não tem uso, e carrega módulo de URL sem "https://" no import.
# Só os arquivos que o navegador carrega: a documentação cita a regra.
remotos=$(find prototipo -type f \( -name "*.html" -o -name "*.htm" -o -name "*.js" -o -name "*.mjs" -o -name "*.svg" \) |
  while IFS= read -r arquivo; do
    tr '\n' ' ' <"$arquivo" | grep -oiE \
      -e "<script[^>]*src[[:space:]]*=[[:space:]]*[\"']?(https?:)?//[^>]*>" \
      -e "<script[^>]*type[[:space:]]*=[[:space:]]*[\"']?importmap[^>]*>" \
      -e "(from|import)[[:space:]]*\(?[[:space:]]*[\"'\`](https?:)?//[^\"'\`]*" |
      sed "s|^|$arquivo: |" || true
  done)
if [ -n "$pacotes" ] || [ -n "$remotos" ]; then
  echo "O prototipo/ tem dependência:" >&2
  [ -n "$pacotes" ] && echo "$pacotes" | sed 's/^/  /' >&2
  [ -n "$remotos" ] && echo "$remotos" | sed 's/^/  /' >&2
  echo "Como corrigir: o protótipo é HTML, CSS e JS puros, sem build. Apague o package.json e escreva o JS no próprio prototipo/, em vez de carregar script ou módulo de uma URL ou por import map. Fonte externa por <link> pode (regras em prototipo/README.md e docs/SECURITY.md)." >&2
  falhou=1
fi

[ "$falhou" -eq 0 ] || exit 1
echo "protótipo ok"

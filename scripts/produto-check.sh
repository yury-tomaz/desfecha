#!/usr/bin/env bash
# Confere os temas de produto: cada arquivo de docs/produto/ está no índice do PRODUCT_SENSE.md,
# cada link do índice aponta para um arquivo que existe, e cada tema tem as três seções.
# Uso: scripts/produto-check.sh [pasta docs]
set -euo pipefail
docs=${1:-"$(dirname "$0")/../docs"}
indice=$docs/PRODUCT_SENSE.md
secoes=("## Estado atual" "## Decisões" "## Perguntas em aberto")

problemas=()
links=$(grep -oE '\]\(produto/[^)#]+' "$indice" | sed 's/^](//' || true)

for arquivo in "$docs"/produto/*.md; do
  [ -e "$arquivo" ] || continue
  nome=produto/$(basename "$arquivo")
  grep -qxF "$nome" <<<"$links" || problemas+=("$nome não está no índice de docs/PRODUCT_SENSE.md")
  for secao in "${secoes[@]}"; do
    grep -qxF "$secao" "$arquivo" || problemas+=("$nome não tem a seção \"$secao\"")
  done
done

while read -r link; do
  [ -n "$link" ] && [ ! -e "$docs/$link" ] && problemas+=("o índice de docs/PRODUCT_SENSE.md aponta para $link, que não existe")
done <<<"$links"

if [ ${#problemas[@]} -gt 0 ]; then
  echo "Tema de produto inválido:" >&2
  printf '  %s\n' "${problemas[@]}" >&2
  echo "Como corrigir: todo arquivo de docs/produto/ entra na lista \"## Temas\" de docs/PRODUCT_SENSE.md como link [Nome](produto/<arquivo>.md); link para tema que não existe sai da lista ou ganha o arquivo; e todo tema tem as seções \"## Estado atual\", \"## Decisões\" e \"## Perguntas em aberto\", nesse nível de título (formato em docs/PRODUCT_SENSE.md)." >&2
  exit 1
fi
echo "temas de produto ok"

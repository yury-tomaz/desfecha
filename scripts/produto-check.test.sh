#!/usr/bin/env bash
# Casos de scripts/produto-check.sh. Rodado por scripts/verify.sh.
set -euo pipefail
cd "$(dirname "$0")"
checagem=$PWD/produto-check.sh

falhas=0
docs=$(mktemp -d)
trap 'rm -rf "$docs"' EXIT

tema() {
  cat >"$docs/produto/$1" <<TEMA
# Tema

## Estado atual

## Decisões

## Perguntas em aberto
TEMA
}

base() {
  rm -rf "${docs:?}"/*
  mkdir -p "$docs/produto"
  tema resolucao.md
  tema lgpd.md
  printf '# Product Sense\n\n## Temas\n\n- [Resolução](produto/resolucao.md): x.\n- [LGPD](produto/lgpd.md): y.\n' >"$docs/PRODUCT_SENSE.md"
}

confere() {
  local esperado=$1 caso=$2 saida rc=0
  saida=$("$checagem" "$docs" 2>&1) || rc=$?
  if [ "$rc" -ne "$esperado" ]; then
    echo "produto-check: esperava rc=$esperado e saiu rc=$rc no caso: $caso"
    echo "$saida" | sed 's/^/    /'
    falhas=$((falhas + 1))
  elif [ "$esperado" -ne 0 ] && ! grep -q 'Como corrigir' <<<"$saida"; then
    echo "produto-check: a falha não diz como corrigir no caso: $caso"
    falhas=$((falhas + 1))
  fi
}

base
confere 0 "temas no índice e com as três seções passam"

base
tema integracoes.md
confere 1 "tema fora do índice falha"

base
printf -- '- [Integrações](produto/integracoes.md): z.\n' >>"$docs/PRODUCT_SENSE.md"
confere 1 "link do índice para tema que não existe falha"

base
printf '# Tema\n\n## Estado atual\n\n## Perguntas em aberto\n' >"$docs/produto/lgpd.md"
confere 1 "tema sem a seção Decisões falha"

base
printf '# Tema\n\n## Decisões\n\n## Perguntas em aberto\n' >"$docs/produto/lgpd.md"
confere 1 "tema sem a seção Estado atual falha"

base
printf '# Tema\n\n## Estado atual\n\n## Decisões\n' >"$docs/produto/lgpd.md"
confere 1 "tema sem a seção Perguntas em aberto falha"

base
printf '# Tema\n\n### Estado atual\n\n## Decisões\n\n## Perguntas em aberto\n' >"$docs/produto/lgpd.md"
confere 1 "seção com nível de título errado não conta"

base
printf '# Product Sense\n\n## Temas\n\n- [Resolução](produto/resolucao.md): x.\n- lgpd.md\n' >"$docs/PRODUCT_SENSE.md"
confere 1 "tema citado sem link no índice falha"

if [ "$falhas" -gt 0 ]; then
  echo "$falhas caso(s) de produto-check falharam. Corrija scripts/produto-check.sh, não os casos."
  exit 1
fi
echo "checagem dos temas de produto ok"

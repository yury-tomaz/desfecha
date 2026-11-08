#!/usr/bin/env bash
# Casos de scripts/prototipo-check.sh. Rodado por scripts/verify.sh.
set -euo pipefail
cd "$(dirname "$0")"
checagem=$PWD/prototipo-check.sh

falhas=0
raiz=$(mktemp -d)
trap 'rm -rf "$raiz"' EXIT

base() {
  rm -rf "${raiz:?}"/*
  mkdir -p "$raiz/prototipo" "$raiz/frontend/src/routes" "$raiz/frontend/node_modules/pacote"
  printf '<!doctype html>\n<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter" />\n<script src="tela.js"></script>\n' >"$raiz/prototipo/index.html"
  printf 'import { x } from "./outro.js";\n' >"$raiz/prototipo/tela.js"
  printf 'import { y } from "#lib/y";\nconst texto = "veja o prototipo da tela";\n' >"$raiz/frontend/src/routes/pagina.ts"
  printf '<script lang="ts">\n\timport Botao from "$lib/Botao.svelte";\n</script>\n' >"$raiz/frontend/src/routes/+page.svelte"
}

confere() {
  local esperado=$1 caso=$2 saida rc=0
  saida=$("$checagem" "$raiz" 2>&1) || rc=$?
  if [ "$rc" -ne "$esperado" ]; then
    echo "prototipo-check: esperava rc=$esperado e saiu rc=$rc no caso: $caso"
    echo "$saida" | sed 's/^/    /'
    falhas=$((falhas + 1))
  elif [ "$esperado" -ne 0 ] && ! grep -q 'Como corrigir' <<<"$saida"; then
    echo "prototipo-check: a falha não diz como corrigir no caso: $caso"
    falhas=$((falhas + 1))
  fi
}

base
confere 0 "protótipo com script local e fonte externa, e frontend sem referência ao protótipo, passam"

base
printf 'import { tela } from "../../../prototipo/tela.js";\n' >>"$raiz/frontend/src/routes/pagina.ts"
confere 1 "import do protótipo num .ts falha"

base
printf '<script lang="ts">\n\timport "../../../prototipo/estilo.css";\n</script>\n' >"$raiz/frontend/src/routes/+page.svelte"
confere 1 "import do protótipo num .svelte falha"

base
printf 'const tela = await import(`../../prototipo/tela.js`);\n' >>"$raiz/frontend/src/routes/pagina.ts"
confere 1 "import dinâmico do protótipo falha"

base
printf 'export default { resolve: { alias: { telas: "../prototipo" } } };\n' >"$raiz/frontend/vite.config.ts"
confere 1 "alias apontando para o protótipo falha"

base
printf 'import "../../prototipo/x.js";\n' >"$raiz/frontend/node_modules/pacote/index.js"
confere 0 "node_modules do frontend não é conferido"

base
printf 'Nada de `<script src="https://...">` aqui.\n' >"$raiz/prototipo/README.md"
confere 0 "documentação que cita a regra não é conferida"

base
printf '{ "name": "prototipo" }\n' >"$raiz/prototipo/package.json"
confere 1 "package.json no protótipo falha"

base
mkdir -p "$raiz/prototipo/telas"
printf '{}\n' >"$raiz/prototipo/telas/package.json"
confere 1 "package.json numa subpasta do protótipo falha"

base
printf '<script src="https://cdn.jsdelivr.net/npm/alpinejs"></script>\n' >>"$raiz/prototipo/index.html"
confere 1 "script de https no protótipo falha"

base
printf "<script defer src='http://exemplo.com/a.js'></script>\n" >>"$raiz/prototipo/index.html"
confere 1 "script de http, com aspas simples e outro atributo antes, falha"

base
printf '<script src="//cdn.exemplo.com/a.js"></script>\n' >>"$raiz/prototipo/index.html"
confere 1 "script sem protocolo (//) no protótipo falha"

base
printf 'import { h } from "https://esm.sh/preact";\n' >>"$raiz/prototipo/tela.js"
confere 1 "import de URL num .js do protótipo falha"

if [ "$falhas" -gt 0 ]; then
  echo "$falhas caso(s) de prototipo-check falharam. Corrija scripts/prototipo-check.sh, não os casos."
  exit 1
fi
echo "checagem do protótipo ok"

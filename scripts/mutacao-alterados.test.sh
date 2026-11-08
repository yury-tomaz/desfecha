#!/usr/bin/env bash
# Casos de scripts/mutacao-alterados.sh. Rodado por scripts/verify.sh.
set -euo pipefail
cd "$(dirname "$0")"
# O hook de pre-push roda com GIT_DIR do repositório de verdade. Herdado, ele faria o git init, os commits
# e o update-ref do origin/main dos casos no repositório de verdade, não no temporário.
# shellcheck disable=SC2046
unset $(git rev-parse --local-env-vars)
checagem=$PWD/mutacao-alterados.sh

falhas=0
raiz=$(mktemp -d)
trap 'rm -rf "$raiz"' EXIT

g() { git -C "$raiz" -c user.name=teste -c user.email=teste@exemplo.invalid "$@"; }

escreve() {
  mkdir -p "$(dirname "$raiz/$1")"
  printf '%s\n' "${2:-conteúdo}" >"$raiz/$1"
}

base() {
  rm -rf "$raiz" && mkdir -p "$raiz"
  g init -q -b main
  escreve backend/src/main/java/com/desfecha/BackendApplication.java
  escreve backend/src/main/java/com/desfecha/Antigo.java
  escreve frontend/src/lib/antigo.ts
  g add -A && g commit -qm base
  g update-ref refs/remotes/origin/main HEAD
  g checkout -qb escopo
}

confere() {
  local esperado_rc=$1 esperado=$2 caso=$3 saida rc=0
  saida=$("$checagem" "$raiz" 2>"$raiz.err") || rc=$?
  if [ "$rc" -ne "$esperado_rc" ]; then
    echo "mutacao-alterados: esperava rc=$esperado_rc e saiu rc=$rc no caso: $caso"
    sed 's/^/    /' "$raiz.err"
    falhas=$((falhas + 1))
  elif [ "$esperado_rc" -ne 0 ] && ! grep -q 'Como corrigir' "$raiz.err"; then
    echo "mutacao-alterados: a falha não diz como corrigir no caso: $caso"
    falhas=$((falhas + 1))
  elif [ "$saida" != "$esperado" ]; then
    echo "mutacao-alterados: lista errada no caso: $caso"
    echo "    esperado: $(echo "$esperado" | tr '\n' ' ')"
    echo "    saiu:     $(echo "$saida" | tr '\n' ' ')"
    falhas=$((falhas + 1))
  fi
  rm -f "$raiz.err"
}

base
confere 0 "" "sem mudança em relação ao origin/main, a lista é vazia"

base
escreve backend/src/main/java/com/desfecha/Novo.java
escreve frontend/src/lib/novo.ts
g add -A && g commit -qm novo
confere 0 "backend/src/main/java/com/desfecha/Novo.java
frontend/src/lib/novo.ts" "arquivos de produção commitados entram"

base
escreve backend/src/main/java/com/desfecha/Antigo.java mudou
escreve frontend/src/lib/pasta/novo.ts
confere 0 "backend/src/main/java/com/desfecha/Antigo.java
frontend/src/lib/pasta/novo.ts" "alterado sem commit e arquivo novo fora do git entram"

base
escreve backend/src/main/java/com/desfecha/BackendApplication.java mudou
escreve backend/src/test/java/com/desfecha/NovoTest.java
escreve frontend/src/lib/novo.test.ts
escreve frontend/src/lib/Botao.svelte
escreve frontend/src/routes/pagina.ts
escreve frontend/eslint.config.js
escreve docs/nota.md
confere 0 "" "BackendApplication, testes, .svelte, src/routes e o que não é código de produção ficam de fora"

base
escreve backend/src/main/java/com/desfecha/Cobrança.java
escreve frontend/src/lib/cobrança.ts
g add -A && g commit -qm acento
escreve frontend/src/lib/ação.ts
confere 0 "backend/src/main/java/com/desfecha/Cobrança.java
frontend/src/lib/ação.ts
frontend/src/lib/cobrança.ts" "nome com acento entra, commitado ou fora do git, sem as aspas e o escape do git"

base
g rm -q frontend/src/lib/antigo.ts && g commit -qm apaga
confere 0 "" "arquivo apagado fica de fora"

base
g checkout -q main
escreve frontend/src/lib/do-main.ts
g add -A && g commit -qm main-andou
g update-ref refs/remotes/origin/main HEAD
g checkout -q escopo
escreve frontend/src/lib/do-escopo.ts
g add -A && g commit -qm escopo
confere 0 "frontend/src/lib/do-escopo.ts" "o que entrou no origin/main depois do merge-base fica de fora"

base
escreve frontend/src/lib/novo.ts
outro=$(mktemp -d)
git -C "$outro" init -q
saida=$(GIT_DIR=$outro/.git "$checagem" "$raiz" 2>&1) || true
rm -rf "$outro"
if [ "$saida" != "frontend/src/lib/novo.ts" ]; then
  echo "mutacao-alterados: com GIT_DIR de outro repositório no ambiente (como no hook de pre-push), listou o repositório errado: $saida"
  falhas=$((falhas + 1))
fi

base
g update-ref -d refs/remotes/origin/main
confere 1 "" "sem origin/main falha, em vez de passar sem medir nada"

if [ "$falhas" -ne 0 ]; then
  echo "mutacao-alterados: $falhas caso(s) falharam"
  exit 1
fi
echo "mutacao-alterados: casos ok"

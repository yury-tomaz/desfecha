#!/usr/bin/env bash
# Casos de scripts/segredos-check.sh. Rodado por scripts/verify.sh.
set -euo pipefail
cd "$(dirname "$0")"
checagem=$PWD/segredos-check.sh

# O hook de pre-push roda com GIT_DIR do repositório de verdade. Herdado, ele faria o git init e o git add
# dos repositórios de teste mexerem no índice de verdade.
# shellcheck disable=SC2046
unset $(git rev-parse --local-env-vars)

# A chave é montada em tempo de execução para o próprio gitleaks não acusar este arquivo.
chave_aws="AKIA""QYLPMN5HHHFPZAM2"

falhas=0
repo=""
trap 'rm -rf "$repo"' EXIT

novo_repo() {
  rm -rf "$repo"
  repo=$(mktemp -d)
  git -C "$repo" init -q
  printf 'node_modules/\n' >"$repo/.gitignore"
  printf '[extend]\nuseDefault = true\n' >"$repo/.gitleaks.toml"
  printf 'nada aqui\n' >"$repo/LEIA.md"
  git -C "$repo" add -A
}

confere() {
  local esperado=$1 caso=$2 saida rc=0
  saida=$("$checagem" "$repo" 2>&1) || rc=$?
  if [ "$rc" -ne "$esperado" ]; then
    echo "segredos-check: esperava rc=$esperado e saiu rc=$rc no caso: $caso"
    echo "$saida" | sed 's/^/    /'
    falhas=$((falhas + 1))
  elif [ "$esperado" -ne 0 ] && ! grep -q 'Como corrigir' <<<"$saida"; then
    echo "segredos-check: a falha não diz como corrigir no caso: $caso"
    falhas=$((falhas + 1))
  fi
}

commita() { git -C "$repo" -c user.name=teste -c user.email=teste@exemplo.invalid commit -q --allow-empty -m "$1"; }
publica() { git -C "$repo" update-ref refs/remotes/origin/main HEAD; }

novo_repo
confere 0 "repositório sem segredo passa"

novo_repo
commita base
publica
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
git -C "$repo" add config.ini
commita "com a chave"
git -C "$repo" rm -q config.ini
commita "tira a chave"
confere 1 "chave commitada e removida num commit seguinte ainda não publicado falha"

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
git -C "$repo" add config.ini
commita "com a chave"
publica
git -C "$repo" rm -q config.ini
commita "tira a chave"
confere 0 "chave que já estava no origin/main e foi removida depois passa"

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
git -C "$repo" add config.ini
commita "com a chave"
git -C "$repo" rm -q config.ini
commita "tira a chave"
confere 1 "sem origin/main, chave em qualquer commit do histórico falha"

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
git -C "$repo" add config.ini
confere 1 "chave de AWS num arquivo versionado falha"

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/novo.ini"
confere 1 "chave de AWS num arquivo novo ainda não versionado falha"

novo_repo
mkdir "$repo/node_modules"
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/node_modules/pacote.ini"
confere 0 "chave de AWS num arquivo ignorado pelo git não é commitada e passa"

novo_repo
printf 'aws_access_key_id = %s # gitleaks:allow\n' "$chave_aws" >"$repo/config.ini"
confere 1 "comentário gitleaks:allow não vale como exceção"

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
cat >>"$repo/.gitleaks.toml" <<'EOF'

[[allowlists]]
description = "chave de exemplo da documentação, não é credencial"
paths = ['config\.ini']
EOF
confere 0 "falso positivo registrado no .gitleaks.toml com motivo passa"

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
cat >>"$repo/.gitleaks.toml" <<'EOF'

[[allowlists]]
paths = ['config\.ini']
EOF
confere 1 "exceção no .gitleaks.toml sem motivo falha"

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
cat >>"$repo/.gitleaks.toml" <<'EOF'

[[allowlists]]
description = ""
paths = ['config\.ini']
EOF
confere 1 "exceção no .gitleaks.toml com motivo vazio falha"

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
git -C "$repo" add config.ini
outro=$(mktemp -d)
git -C "$outro" init -q
if GIT_DIR=$outro/.git "$checagem" "$repo" >/dev/null 2>&1; then
  echo "segredos-check: com GIT_DIR de outro repositório no ambiente (como no hook de pre-push), varreu o repositório errado e não achou a chave"
  falhas=$((falhas + 1))
fi

novo_repo
printf 'aws_access_key_id = %s\n' "$chave_aws" >"$repo/config.ini"
git -C "$repo" add config.ini
commita "com a chave"
git -C "$repo" rm -q config.ini
commita "tira a chave"
if GIT_DIR=$outro/.git "$checagem" "$repo" >/dev/null 2>&1; then
  echo "segredos-check: com GIT_DIR de outro repositório no ambiente (como no hook de pre-push), varreu o histórico errado e não achou a chave"
  falhas=$((falhas + 1))
fi
rm -rf "$outro"

novo_repo
printf 'qualquer:regra:1\n' >"$repo/.gitleaksignore"
confere 1 ".gitleaksignore não é aceito porque não guarda motivo"

if [ "$falhas" -gt 0 ]; then
  echo "$falhas caso(s) de segredos-check falharam. Corrija scripts/segredos-check.sh, não os casos."
  exit 1
fi
echo "checagem de segredos ok"

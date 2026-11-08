#!/usr/bin/env bash
# Casos do hook bloqueia-push-no-verify.sh. Rodado por scripts/verify.sh.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v jq >/dev/null; then
  echo "jq não encontrado. Rode pelo mise (mise install; mise exec -- $0), que fixa a versão no mise.toml."
  exit 1
fi

falhas=0
TAB=$'\t'

confere() {
  local esperado=$1 comando=$2 rc=0
  jq -cn --arg c "$comando" '{tool_name: "Bash", tool_input: {command: $c, description: "faz push sem --no-verify"}}' |
    ./bloqueia-push-no-verify.sh 2>/dev/null || rc=$?
  if [ "$rc" -ne "$esperado" ]; then
    echo "Hook de --no-verify: esperava rc=$esperado e saiu rc=$rc para: $comando"
    falhas=$((falhas + 1))
  fi
}

bloqueia() { confere 2 "$1"; }
libera() { confere 0 "$1"; }

bloqueia 'git push --no-verify'
bloqueia 'git push origin x --no-verify'
bloqueia 'git push --no-verify origin x'
bloqueia 'git push -u origin plano/x --no-veri'
bloqueia 'git -C /a/b push --no-verif'
bloqueia 'cd x && git push origin main --no-verify'
bloqueia 'git push "--no-verify"'
bloqueia "git push '--no-verify'"
bloqueia 'git push origin x "--no-verify"'
bloqueia 'git push origin x \--no-verify'
bloqueia "git push origin x${TAB}--no-verify"
bloqueia 'git push origin x --no-"verify"'
bloqueia 'git push origin x${IFS}--no-verify'
bloqueia "git push origin x \\
  --no-verify"

libera 'git push origin x'
libera 'git push --verify'
libera 'git commit --no-verify -m a'
libera 'git commit --no-verify -m a && git push'
libera 'git status; echo --no-verify'
libera "git commit --no-verify -m a
git push"

# Sem jq no PATH o hook procura no JSON cru. O JSON vai escrito à mão, como o Claude Code manda.
sem_jq=$(mktemp -d)
trap 'rm -rf "$sem_jq"' EXIT
for ferramenta in cat tr grep; do ln -s "$(command -v "$ferramenta")" "$sem_jq/$ferramenta"; done

confere_sem_jq() {
  local esperado=$1 json=$2 rc=0
  PATH=$sem_jq "$BASH" ./bloqueia-push-no-verify.sh <<<"$json" 2>/dev/null || rc=$?
  if [ "$rc" -ne "$esperado" ]; then
    echo "Hook de --no-verify sem jq: esperava rc=$esperado e saiu rc=$rc para: $json"
    falhas=$((falhas + 1))
  fi
}

confere_sem_jq 2 '{"tool_input":{"command":"git push \"--no-verify\""}}'
confere_sem_jq 2 '{"tool_input":{"command":"git push origin x\t--no-verify"}}'
confere_sem_jq 0 '{"tool_input":{"command":"git push origin x"}}'

if [ "$falhas" -gt 0 ]; then
  echo "$falhas caso(s) do hook falharam. Corrija .claude/hooks/bloqueia-push-no-verify.sh, não os casos."
  exit 1
fi
echo "hook de --no-verify ok"

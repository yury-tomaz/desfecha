#!/usr/bin/env bash
# Casos do hook bloqueia-push-no-verify.sh. Rodado por scripts/verify.sh.
set -euo pipefail
cd "$(dirname "$0")"

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

if [ "$falhas" -gt 0 ]; then
  echo "$falhas caso(s) do hook falharam. Corrija .claude/hooks/bloqueia-push-no-verify.sh, não os casos."
  exit 1
fi
echo "hook de --no-verify ok"

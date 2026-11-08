#!/usr/bin/env bash
# Hook PreToolUse do Claude Code para a ferramenta Bash. Lê o JSON da chamada na entrada padrão.
# Git aceita abreviações de opção longa, então `--no-veri` já equivale a `--no-verify`.
set -euo pipefail

if grep -Eq 'git([[:space:]][^;&|]*)?[[:space:]]push([[:space:]][^;&|]*)?[[:space:]]--no-veri'; then
  echo "Bloqueado: git push com --no-verify pula o hook de pre-push, que roda scripts/verify.sh. Rode o push sem --no-verify; se a verificação falhar, corrija o que ela aponta (scripts/format.sh resolve formatação)." >&2
  exit 2
fi

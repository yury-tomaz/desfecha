#!/usr/bin/env bash
# Hook PreToolUse do Claude Code para a ferramenta Bash. Lê o JSON da chamada na entrada padrão.
# Casos cobertos: .claude/hooks/bloqueia-push-no-verify.test.sh.
set -euo pipefail

entrada=$(cat)
# Sem jq, procura no JSON inteiro: pode bloquear a mais, nunca a menos.
comando=$(jq -r '.tool_input.command // empty' <<<"$entrada" 2>/dev/null) || comando=$entrada

# O shell junta "\<quebra de linha>" e tira aspas e barras antes de o git ver a opção.
comando=${comando//$'\\\n'/ }
comando=$(tr -d "\\\\\"'" <<<"$comando")

# Git aceita abreviações de opção longa, então `--no-veri` já equivale a `--no-verify`.
# Sem exigir espaço antes da opção, `x${IFS}--no-verify` também conta.
if grep -Eq 'git([[:space:]][^;&|]*)?[[:space:]]push[^;&|]*--no-veri' <<<"$comando"; then
  echo "Bloqueado: git push com --no-verify pula o hook de pre-push, que roda scripts/verify.sh. Rode o push sem --no-verify; se a verificação falhar, corrija o que ela aponta (scripts/format.sh resolve formatação)." >&2
  exit 2
fi

#!/usr/bin/env bash
# Sensor computacional: verifica a estrutura de pitch e escopos (formato em docs/PLANS.md).
# Uso: scripts/plan-check.sh [pasta-do-pitch ...]
# Sai com 0 se estiver ok, 1 se faltar algo (com a lista do que corrigir).
set -euo pipefail

secoes_do_pitch=("Problema" "Solução" "Protótipo" "Rabbit holes" "No-gos" "Revisão do protótipo" "Log de decisões" "Perguntas em aberto")

has_section() { grep -qxF "## $2" "$1"; }

linha() { grep -m1 -E "^$2: " "$1" | sed "s/^$2: //" || true; }

confere_pitch() {
  local dir=${1%/} md=${1%/}/pitch.md
  local errors=()

  if [ ! -f "$md" ]; then
    errors+=("Falta $md. Crie a partir do formato de docs/PLANS.md.")
  else
    local estado apetite
    estado=$(linha "$md" Estado)
    apetite=$(linha "$md" Apetite)
    case "$estado" in
      shaping | apostado | em-build | bloqueado | entregue) ;;
      "") errors+=("pitch.md: falta a linha 'Estado: <valor>' logo abaixo do título. Valores: shaping, apostado, em-build, bloqueado, entregue.") ;;
      *) errors+=("pitch.md: estado inválido '$estado'. Valores: shaping, apostado, em-build, bloqueado, entregue.") ;;
    esac
    case "$apetite" in
      pequeno | grande) ;;
      "a definir") [ "$estado" = shaping ] || errors+=("pitch.md: 'Apetite: a definir' só vale no shaping. Defina pequeno ou grande com o humano antes da aposta.") ;;
      "") errors+=("pitch.md: falta a linha 'Apetite: <valor>' abaixo do Estado. Valores: pequeno, grande, a definir.") ;;
      *) errors+=("pitch.md: apetite inválido '$apetite'. Valores: pequeno, grande, a definir.") ;;
    esac
    for s in "${secoes_do_pitch[@]}"; do
      has_section "$md" "$s" || errors+=("pitch.md: falta a seção '## $s'. Acrescente o título, mesmo que vazia no shaping.")
    done
  fi

  if [ ${#errors[@]} -gt 0 ]; then
    echo "Pitch incompleto: $dir"
    for e in "${errors[@]}"; do echo "  - $e"; done
    echo "Como corrigir: ajuste cada item acima; o formato de pitch e escopo está em docs/PLANS.md."
    return 1
  fi
  echo "ok: $dir"
}

rc=0
for p in "$@"; do
  confere_pitch "$p" || rc=1
done
exit "$rc"

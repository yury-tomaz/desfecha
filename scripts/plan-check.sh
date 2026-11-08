#!/usr/bin/env bash
# Sensor computacional: verifica se um exec-plan tem a estrutura mínima de "refinado".
# Uso: scripts/plan-check.sh <arquivo-do-plano>
# Sai com 0 se estiver ok, 1 se faltar algo (com a lista do que corrigir).
set -euo pipefail

plan="${1:?uso: scripts/plan-check.sh <arquivo-do-plano>}"
[ -f "$plan" ] || { echo "Plano não encontrado: $plan"; exit 1; }

errors=()

status=$(grep -m1 -E '^Status: ' "$plan" | sed 's/^Status: //' || true)
case "$status" in
  rascunho|refinado|em-execucao|bloqueado|concluido) ;;
  "") errors+=("Falta a linha 'Status: <valor>' logo abaixo do título.") ;;
  *) errors+=("Status inválido: '$status'. Valores: rascunho, refinado, em-execucao, bloqueado, concluido.") ;;
esac

# Conta linhas com conteúdo dentro de uma seção "## <nome>".
section_lines() {
  awk -v h="## $1" '
    $0 == h { inside = 1; next }
    /^## / { inside = 0 }
    inside && $0 !~ /^[[:space:]]*$/ { n++ }
    END { print n + 0 }
  ' "$plan"
}

has_section() { grep -qxF "## $1" "$plan"; }

for s in "Objetivo" "Contexto" "Critérios de aceite" "Fora de escopo" "Passos"; do
  if ! has_section "$s"; then
    errors+=("Falta a seção '## $s'.")
  elif [ "$(section_lines "$s")" -eq 0 ]; then
    errors+=("A seção '## $s' está vazia.")
  fi
done

for s in "Log de progresso" "Log de decisões" "Perguntas em aberto"; do
  has_section "$s" || errors+=("Falta a seção '## $s'.")
done

if has_section "Critérios de aceite"; then
  n=$(awk '$0 == "## Critérios de aceite" { i = 1; next } /^## / { i = 0 } i && /^- \[[ x]\] / { n++ } END { print n + 0 }' "$plan")
  [ "$n" -gt 0 ] || errors+=("'## Critérios de aceite' precisa de itens no formato '- [ ] ...'.")
fi

if has_section "Perguntas em aberto" && [ "$(section_lines "Perguntas em aberto")" -gt 0 ]; then
  errors+=("Há perguntas em aberto. Um plano só fica refinado sem perguntas pendentes.")
fi

if [ ${#errors[@]} -gt 0 ]; then
  echo "Plano incompleto: $plan"
  for e in "${errors[@]}"; do echo "  - $e"; done
  echo "Formato esperado: docs/PLANS.md"
  exit 1
fi

echo "ok ($status): $plan"

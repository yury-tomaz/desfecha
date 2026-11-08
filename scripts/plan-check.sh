#!/usr/bin/env bash
# Sensor computacional: verifica a estrutura de pitch e escopos (formato em docs/PLANS.md).
# Uso: scripts/plan-check.sh [pasta-do-pitch ...]
# Sem argumento, confere todos os pitches de docs/pitches/.
# Sai com 0 se estiver ok, 1 se faltar algo (com a lista do que corrigir).
set -euo pipefail

secoes_do_pitch=("Problema" "Solução" "Protótipo" "Rabbit holes" "No-gos" "Revisão do protótipo" "Log de decisões" "Perguntas em aberto")
secoes_preenchidas_apos_shaping=("Problema" "Solução" "Protótipo" "Rabbit holes" "No-gos" "Revisão do protótipo")
secoes_do_escopo=("Objetivo" "Critérios de aceite" "Log de progresso" "Log de decisões" "Perguntas em aberto")
estados="shaping, apostado, em-build, bloqueado, entregue"

erros=()
erro() { erros+=("$1"); }

tem_secao() { grep -qxF "## $2" "$1"; }

valor_da_linha() { grep -m1 -E "^$2: " "$1" | sed "s/^$2: //" || true; }

linhas_da_secao() {
  awk -v h="## $2" '
    $0 == h { dentro = 1; next }
    /^## / { dentro = 0 }
    dentro && $0 !~ /^[[:space:]]*$/ { n++ }
    END { print n + 0 }
  ' "$1"
}

criterios_marcados_com() {
  awk -v marca="$2" '
    $0 == "## Critérios de aceite" { dentro = 1; next }
    /^## / { dentro = 0 }
    dentro && index($0, "- [" marca "] ") == 1 { n++ }
    END { print n + 0 }
  ' "$1"
}

limite_de_escopos() {
  case "$1" in
    pequeno) echo 1 ;;
    grande) echo 4 ;;
    *) echo 0 ;;
  esac
}

confere_cabecalho() {
  local md=$1 estado=$2 apetite=$3
  case "$estado" in
    shaping | apostado | em-build | bloqueado | entregue) ;;
    "") erro "pitch.md: falta a linha 'Estado: <valor>' logo abaixo do título. Valores: $estados." ;;
    *) erro "pitch.md: estado inválido '$estado'. Valores: $estados." ;;
  esac
  case "$apetite" in
    pequeno | grande) ;;
    "a definir") [ "$estado" = shaping ] || erro "pitch.md: 'Apetite: a definir' só vale no shaping. Defina pequeno ou grande com o humano antes da aposta." ;;
    "") erro "pitch.md: falta a linha 'Apetite: <valor>' abaixo do Estado. Valores: pequeno, grande, a definir." ;;
    *) erro "pitch.md: apetite inválido '$apetite'. Valores: pequeno, grande, a definir." ;;
  esac
}

confere_secoes_do_pitch() {
  local md=$1 estado=$2 s
  for s in "${secoes_do_pitch[@]}"; do
    if ! tem_secao "$md" "$s"; then
      erro "pitch.md: falta a seção '## $s'. Acrescente o título, mesmo que vazia no shaping."
    elif [ "$estado" != shaping ] && [[ " ${secoes_preenchidas_apos_shaping[*]} " == *" $s "* ]] && [ "$(linhas_da_secao "$md" "$s")" -eq 0 ]; then
      erro "pitch.md: a seção '## $s' está vazia fora do shaping. Preencha (sem interface: 'Sem interface.' ou 'Sem protótipo.') ou volte o pitch para shaping."
    fi
  done
}

confere_perguntas() {
  local estado=$1 total=0 f
  shift
  for f in "$@"; do
    total=$((total + $(linhas_da_secao "$f" "Perguntas em aberto")))
  done
  if [ "$estado" = apostado ] && [ "$total" -gt 0 ]; then
    erro "Pitch apostado com perguntas em aberto. Responda com o humano e tire da seção, ou volte o pitch para shaping."
  fi
  if [ "$estado" = bloqueado ] && [ "$total" -eq 0 ]; then
    erro "Pitch bloqueado sem pergunta em aberto. Escreva em '## Perguntas em aberto' (do pitch ou do escopo) o que o humano precisa decidir, com a sua recomendação."
  fi
}

confere_quantidade_de_escopos() {
  local estado=$1 apetite=$2 quantos=$3 limite
  limite=$(limite_de_escopos "$apetite")
  if [ "$quantos" -gt "$limite" ]; then
    erro "$quantos escopos para apetite '$apetite', que permite $limite. Circuit breaker: não crie escopo além do apetite. Marque o pitch como bloqueado e descreva o que sobrou em '## Perguntas em aberto' (docs/PLANS.md)."
  fi
  if [ "$estado" = entregue ] && [ "$quantos" -eq 0 ]; then
    erro "Pitch entregue sem escopos. Um pitch só é entregue depois de pelo menos um escopo construído em escopos/."
  fi
}

confere_escopo() {
  local f=$1 estado=$2 nome colina s
  nome="escopos/$(basename "$f")"
  colina=$(valor_da_linha "$f" Colina)
  case "$colina" in
    subindo | descendo) ;;
    "") erro "$nome: falta a linha 'Colina: subindo' ou 'Colina: descendo' logo abaixo do título." ;;
    *) erro "$nome: colina inválida '$colina'. Valores: subindo (ainda descobrindo como fazer), descendo (já se sabe o que falta)." ;;
  esac
  for s in "${secoes_do_escopo[@]}"; do
    tem_secao "$f" "$s" || erro "$nome: falta a seção '## $s'."
  done
  local abertos marcados
  abertos=$(criterios_marcados_com "$f" " ")
  marcados=$(criterios_marcados_com "$f" x)
  if tem_secao "$f" "Critérios de aceite" && [ $((abertos + marcados)) -eq 0 ]; then
    erro "$nome: '## Critérios de aceite' precisa de itens no formato '- [ ] ...', cada um dizendo como é comprovado."
  fi
  if [ "$estado" = entregue ] && [ "$abertos" -gt 0 ]; then
    erro "$nome: pitch entregue com critério de aceite não marcado. Verifique e marque '- [x]', ou volte o pitch para em-build."
  fi
}

confere_pitch() {
  local dir=${1%/} md=${1%/}/pitch.md
  erros=()

  if [ ! -f "$md" ]; then
    erro "Falta $md. Crie a partir do formato de docs/PLANS.md."
  else
    local estado apetite escopos=() f
    estado=$(valor_da_linha "$md" Estado)
    apetite=$(valor_da_linha "$md" Apetite)
    for f in "$dir"/escopos/*.md; do [ -f "$f" ] && escopos+=("$f"); done

    confere_cabecalho "$md" "$estado" "$apetite"
    confere_secoes_do_pitch "$md" "$estado"
    confere_perguntas "$estado" "$md" ${escopos[@]+"${escopos[@]}"}
    confere_quantidade_de_escopos "$estado" "$apetite" ${#escopos[@]}
    for f in ${escopos[@]+"${escopos[@]}"}; do
      confere_escopo "$f" "$estado"
    done
  fi

  if [ ${#erros[@]} -gt 0 ]; then
    echo "Pitch incompleto: $dir"
    for e in "${erros[@]}"; do echo "  - $e"; done
    echo "Como corrigir: ajuste cada item acima; o formato de pitch e escopo está em docs/PLANS.md."
    return 1
  fi
  echo "ok: $dir"
}

if [ $# -eq 0 ]; then
  for p in "$(dirname "$0")/../docs/pitches"/*/; do
    [ -d "$p" ] && set -- "$@" "$p"
  done
fi

rc=0
for p in "$@"; do
  confere_pitch "$p" || rc=1
done
exit "$rc"

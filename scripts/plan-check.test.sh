#!/usr/bin/env bash
# Casos de scripts/plan-check.sh. Rodado por scripts/verify.sh.
set -euo pipefail
cd "$(dirname "$0")"
checagem=$PWD/plan-check.sh

falhas=0
raiz=$(mktemp -d)
trap 'rm -rf "$raiz"' EXIT
pitch=$raiz/2026-01-01-exemplo

pitch_md() {
  local estado=$1 apetite=$2
  mkdir -p "$pitch"
  cat >"$pitch/pitch.md" <<EOF
# Exemplo

Estado: $estado
Apetite: $apetite

## Problema

Atendente não sabe o que o cliente já tentou.

## Solução

Lugar: ticket. Aciona: ver histórico. Leva a: linha do tempo.

## Protótipo

Sem interface.

## Rabbit holes

Histórico de outros canais fica de fora.

## No-gos

Busca no histórico.

## Revisão do protótipo

Sem protótipo.

## Log de decisões

## Perguntas em aberto
EOF
}

escopo() {
  local nome=$1 colina=$2 marca=${3:- }
  mkdir -p "$pitch/escopos"
  cat >"$pitch/escopos/$nome.md" <<EOF
# $nome

Colina: $colina

## Objetivo

Linha do tempo no ticket.

## Critérios de aceite

- [$marca] mostra as ações em ordem. Comprovado por teste.

## Log de progresso

## Log de decisões

## Perguntas em aberto
EOF
}

base() {
  rm -rf "${raiz:?}"/*
  pitch_md apostado grande
  escopo linha-do-tempo subindo
}

remove_secao() { sed -i.bak "/^## $2\$/d" "$1" && rm -f "$1.bak"; }
esvazia_secao() {
  awk -v h="## $2" '$0 == h { print; skip = 1; next } /^## / { skip = 0 } !skip' "$1" >"$1.tmp" && mv "$1.tmp" "$1"
}
troca() { sed -i.bak "s/^$2/$3/" "$1" && rm -f "$1.bak"; }
pergunta() { printf -- '- Vale cortar o escopo?\n' >>"$1"; }

confere() {
  local esperado=$1 caso=$2 saida rc=0
  shift 2
  saida=$("$checagem" "${@:-$pitch}" 2>&1) || rc=$?
  if [ "$rc" -ne "$esperado" ]; then
    echo "plan-check: esperava rc=$esperado e saiu rc=$rc no caso: $caso"
    echo "$saida" | sed 's/^/    /'
    falhas=$((falhas + 1))
  elif [ "$esperado" -ne 0 ] && ! grep -q 'Como corrigir' <<<"$saida"; then
    echo "plan-check: a falha não diz como corrigir no caso: $caso"
    falhas=$((falhas + 1))
  fi
}

base
confere 0 "pitch apostado com um escopo passa"

for s in "Problema" "Solução" "Protótipo" "Rabbit holes" "No-gos" "Revisão do protótipo" "Log de decisões" "Perguntas em aberto"; do
  base
  remove_secao "$pitch/pitch.md" "$s"
  confere 1 "pitch sem a seção $s falha"
done

for e in shaping apostado em-build bloqueado entregue; do
  base
  troca "$pitch/pitch.md" "Estado: apostado" "Estado: $e"
  [ "$e" = bloqueado ] && pergunta "$pitch/pitch.md"
  [ "$e" = entregue ] && escopo linha-do-tempo descendo x
  confere 0 "pitch em $e passa"
done

base
troca "$pitch/pitch.md" "Estado: apostado" "Estado: pronto"
confere 1 "estado inválido falha"

base
troca "$pitch/pitch.md" "Estado: apostado" ""
confere 1 "pitch sem a linha Estado falha"

base
troca "$pitch/pitch.md" "Apetite: grande" "Apetite: médio"
confere 1 "apetite inválido falha"

base
troca "$pitch/pitch.md" "Apetite: grande" ""
confere 1 "pitch sem a linha Apetite falha"

base
rm -rf "$pitch/escopos"
troca "$pitch/pitch.md" "Estado: apostado" "Estado: shaping"
troca "$pitch/pitch.md" "Apetite: grande" "Apetite: a definir"
confere 0 "apetite a definir no shaping passa"

base
rm -rf "$pitch/escopos"
troca "$pitch/pitch.md" "Apetite: grande" "Apetite: a definir"
confere 1 "apetite a definir fora do shaping falha"

if [ "$falhas" -gt 0 ]; then
  echo "$falhas caso(s) de plan-check falharam. Corrija scripts/plan-check.sh, não os casos."
  exit 1
fi
echo "checagem de pitch e escopo ok"

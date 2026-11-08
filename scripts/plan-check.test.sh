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

for s in "Problema" "Solução" "Protótipo" "Rabbit holes" "No-gos" "Revisão do protótipo"; do
  base
  esvazia_secao "$pitch/pitch.md" "$s"
  confere 1 "pitch apostado com a seção $s vazia falha"
done

base
rm -rf "$pitch/escopos"
troca "$pitch/pitch.md" "Estado: apostado" "Estado: shaping"
for s in "Problema" "Solução" "Protótipo" "Rabbit holes" "No-gos" "Revisão do protótipo"; do
  esvazia_secao "$pitch/pitch.md" "$s"
done
pergunta "$pitch/pitch.md"
confere 0 "pitch em shaping com seções vazias e perguntas em aberto passa"

base
pergunta "$pitch/pitch.md"
confere 1 "pitch apostado com pergunta em aberto falha"

base
troca "$pitch/pitch.md" "Estado: apostado" "Estado: bloqueado"
confere 1 "pitch bloqueado sem pergunta em aberto falha"

base
troca "$pitch/pitch.md" "Estado: apostado" "Estado: bloqueado"
pergunta "$pitch/escopos/linha-do-tempo.md"
confere 0 "pitch bloqueado com a pergunta no escopo passa"

base
escopo historico descendo
confere 0 "escopo descendo passa"

base
troca "$pitch/escopos/linha-do-tempo.md" "Colina: subindo" ""
confere 1 "escopo sem a linha Colina falha"

base
troca "$pitch/escopos/linha-do-tempo.md" "Colina: subindo" "Colina: no topo"
confere 1 "escopo com colina inválida falha"

for s in "Objetivo" "Critérios de aceite" "Log de progresso" "Log de decisões" "Perguntas em aberto"; do
  base
  remove_secao "$pitch/escopos/linha-do-tempo.md" "$s"
  confere 1 "escopo sem a seção $s falha"
done

base
esvazia_secao "$pitch/escopos/linha-do-tempo.md" "Critérios de aceite"
confere 1 "escopo sem critérios de aceite falha"

base
troca "$pitch/escopos/linha-do-tempo.md" "- \[ \] " ""
confere 1 "escopo com critério fora do formato - [ ] falha"

base
troca "$pitch/pitch.md" "Apetite: grande" "Apetite: pequeno"
confere 0 "apetite pequeno com 1 escopo passa"

base
troca "$pitch/pitch.md" "Apetite: grande" "Apetite: pequeno"
escopo historico subindo
confere 1 "apetite pequeno com 2 escopos falha"

base
escopo b subindo
escopo c subindo
escopo d subindo
confere 0 "apetite grande com 4 escopos passa"

base
escopo b subindo
escopo c subindo
escopo d subindo
escopo e subindo
confere 1 "apetite grande com 5 escopos falha"

base
troca "$pitch/pitch.md" "Estado: apostado" "Estado: shaping"
troca "$pitch/pitch.md" "Apetite: grande" "Apetite: a definir"
confere 1 "apetite a definir com escopo falha"

base
troca "$pitch/pitch.md" "Estado: apostado" "Estado: entregue"
confere 1 "pitch entregue com critério não marcado falha"

base
rm -rf "$pitch/escopos"
troca "$pitch/pitch.md" "Estado: apostado" "Estado: entregue"
confere 1 "pitch entregue sem escopos falha"

base
rm -f "$pitch/pitch.md"
confere 1 "pasta sem pitch.md falha"

repo=$(mktemp -d)
trap 'rm -rf "$raiz" "$repo"' EXIT
mkdir -p "$repo/scripts" "$repo/docs/pitches"
cp "$checagem" "$repo/scripts/plan-check.sh"
todos() {
  local esperado=$1 caso=$2 rc=0
  "$repo/scripts/plan-check.sh" >/dev/null 2>&1 || rc=$?
  if [ "$rc" -ne "$esperado" ]; then
    echo "plan-check: esperava rc=$esperado e saiu rc=$rc no caso: $caso"
    falhas=$((falhas + 1))
  fi
}

todos 0 "sem argumento e sem pitches passa"

base
cp -R "$pitch" "$repo/docs/pitches/"
todos 0 "sem argumento, com um pitch válido em docs/pitches, passa"

base
remove_secao "$pitch/pitch.md" "No-gos"
cp -R "$pitch" "$repo/docs/pitches/2026-01-02-outro"
todos 1 "sem argumento, com um pitch inválido em docs/pitches, falha"

if [ "$falhas" -gt 0 ]; then
  echo "$falhas caso(s) de plan-check falharam. Corrija scripts/plan-check.sh, não os casos."
  exit 1
fi
echo "checagem de pitch e escopo ok"

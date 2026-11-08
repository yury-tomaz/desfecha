#!/usr/bin/env bash
# Procura vulnerabilidade conhecida, de qualquer gravidade, nas bibliotecas do backend e do frontend (OSV-Scanner).
# Uso: scripts/dependencias-check.sh
set -euo pipefail
cd "$(dirname "$0")/.."

scripts/dependencias-excecoes-check.sh osv-scanner.toml

# O OSV-Scanner lendo o pom.xml direto só vê as dependências declaradas, sem versão (vêm do parent do
# Spring Boot) e sem as transitivas. Quem resolve a árvore de verdade é o Maven.
lista=backend/target/dependencias.txt
resolvidas=backend/target/dependencias-resolvidas.json
./backend/mvnw -B -q -f backend/pom.xml dependency:list -DoutputFile=target/dependencias.txt
awk '/^ +[^ ]+:[^ ]+:/ {
  n = split($1, campo, ":")
  printf "{\"package\":{\"ecosystem\":\"Maven\",\"name\":\"%s:%s\",\"version\":\"%s\"}}\n", campo[1], campo[2], campo[n - 1]
}' "$lista" |
  jq -s '{results: [{source: {path: "backend/pom.xml", type: "lockfile"}, packages: .}]}' >"$resolvidas"
if ! jq -e '.results[0].packages | length > 0' "$resolvidas" >/dev/null; then
  echo "Nenhuma dependência do backend saiu de $lista; sem elas o OSV-Scanner passaria sem olhar nada." >&2
  echo "Como corrigir: confira o formato das linhas em $lista (o maven-dependency-plugin vem do parent do Spring Boot e pode ter mudado) e ajuste o awk de scripts/dependencias-check.sh." >&2
  exit 1
fi

if ! osv-scanner scan source --config osv-scanner.toml \
  -L "osv-scanner:$resolvidas" -L frontend/pnpm-lock.yaml; then
  echo >&2
  echo "Vulnerabilidade conhecida numa biblioteca (tabela acima; $resolvidas é a árvore resolvida do backend/pom.xml)." >&2
  echo "Como corrigir: atualize a biblioteca para a versão da coluna FIXED VERSION (no frontend, pnpm update <pacote>, ou overrides em frontend/pnpm-workspace.yaml se ela for transitiva; no backend, a versão no pom.xml ou uma propriedade do parent). Se não houver versão corrigida, registre uma exceção em osv-scanner.toml com reason e ignoreUntil de no máximo 30 dias, e o motivo no log de decisões do plano (regras em docs/SECURITY.md)." >&2
  exit 1
fi

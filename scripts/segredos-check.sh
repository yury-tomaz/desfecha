#!/usr/bin/env bash
# Procura segredos (chaves, tokens, senhas) nos arquivos que vão ou podem ir para um commit.
# Uso: scripts/segredos-check.sh [raiz-do-repositório]
# Casos cobertos: scripts/segredos-check.test.sh.
set -euo pipefail
raiz=${1:-"$(cd "$(dirname "$0")/.." && pwd)"}
cd "$raiz"

falha() {
  echo "$1" >&2
  echo "Como corrigir: $2" >&2
  exit 1
}

if [ -e .gitleaksignore ]; then
  falha ".gitleaksignore não é aceito: ele guarda só o fingerprint, sem o motivo da exceção." \
    "apague o .gitleaksignore e registre o falso positivo em .gitleaks.toml, num bloco [[allowlists]] com description dizendo por que não é segredo (regras em docs/SECURITY.md)."
fi

sem_motivo=$(awk '
  function fecha() { if (bloco != "" && !motivo) print bloco; bloco = ""; motivo = 0 }
  /^[[:space:]]*\[/ { fecha() }
  /^[[:space:]]*\[\[([a-z]+\.)?allowlists\]\]/ { bloco = "linha " NR ": " $0 }
  bloco != "" && /^[[:space:]]*description[[:space:]]*=[[:space:]]*("[^"]+"|'\''[^'\'']+'\'')/ { motivo = 1 }
  END { fecha() }
' .gitleaks.toml)
if [ -n "$sem_motivo" ]; then
  falha "Exceção em .gitleaks.toml sem motivo: $sem_motivo" \
    "toda exceção do gitleaks é só para falso positivo e precisa de description não vazia explicando por que não é segredo (regras em docs/SECURITY.md)."
fi

# Varre a cópia dos arquivos versionados e dos novos não ignorados: é o que pode entrar num commit.
copia=$(mktemp -d)
trap 'rm -rf "$copia"' EXIT
git ls-files -z --cached --others --exclude-standard |
  while IFS= read -r -d '' arquivo; do
    if [ -f "$arquivo" ]; then printf '%s\0' "$arquivo"; fi
  done |
  tar --null -T - -cf - | tar -xf - -C "$copia"

if ! (cd "$copia" && gitleaks dir . --config "$raiz/.gitleaks.toml" --ignore-gitleaks-allow \
  --no-banner --no-color --redact --log-level warn --verbose); then
  falha "Segredo encontrado (arquivo e linha acima, caminhos relativos à raiz do repositório)." \
    "tire o valor do arquivo e leia de variável de ambiente ou de um .env ignorado pelo git. Se ele já foi commitado, considere vazado: peça ao humano para revogar a credencial, e reescreva o commit antes do push. Se for falso positivo, registre em .gitleaks.toml com description (regras em docs/SECURITY.md)."
fi
echo "nenhum segredo encontrado"

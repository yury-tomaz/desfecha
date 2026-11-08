#!/usr/bin/env bash
# Procura segredos (chaves, tokens, senhas) nos arquivos que vão ou podem ir para um commit
# e nos commits que ainda não estão no origin/main.
# Uso: scripts/segredos-check.sh [raiz-do-repositório]
# Casos cobertos: scripts/segredos-check.test.sh.
set -euo pipefail
raiz=${1:-"$(cd "$(dirname "$0")/.." && pwd)"}
cd "$raiz"
# O hook de pre-push roda com GIT_DIR definido. Herdado, ele apontaria o git para outro repositório que não a raiz.
# shellcheck disable=SC2046
unset $(git rev-parse --local-env-vars)

falha() {
  echo "$1" >&2
  echo "Como corrigir: $2" >&2
  exit 1
}

if [ -e .gitleaksignore ]; then
  falha ".gitleaksignore não é aceito: ele guarda só o fingerprint, sem o motivo da exceção." \
    "apague o .gitleaksignore e registre o falso positivo em .gitleaks.toml, num bloco [[allowlists]] com description dizendo por que não é segredo (regras em docs/SECURITY.md)."
fi

# Lista do que é permitido, não do que é proibido: o gitleaks aceita várias outras formas de silenciar
# uma regra ([allowlist], disabledRules, [[rules]], extend de outro arquivo), e nenhuma delas guarda motivo.
invalidas=$(awk '
  function erro(texto) { print "linha " NR ": " texto }
  function fecha() { if (secao == "allowlists" && !motivo) print "linha " inicio ": [[allowlists]] sem description"; motivo = 0 }
  em_lista { if ($0 ~ /\][ \t]*(#.*)?$/) em_lista = 0; next }
  /^[ \t]*(#.*)?$/ { next }
  /^[ \t]*\[/ {
    fecha()
    if ($0 ~ /^[ \t]*\[extend\][ \t]*(#.*)?$/) secao = "extend"
    else if ($0 ~ /^[ \t]*\[\[allowlists\]\][ \t]*(#.*)?$/) { secao = "allowlists"; inicio = NR }
    else { secao = "recusada"; erro($0 " não é aceito; só [extend] e [[allowlists]]") }
    next
  }
  /^[ \t]*[A-Za-z]+[ \t]*=/ {
    chave = $0; sub(/^[ \t]*/, "", chave); sub(/[ \t]*=.*$/, "", chave)
    valor = $0; sub(/^[^=]*=[ \t]*/, "", valor)
    if (valor ~ /^\[/ && valor !~ /\][ \t]*(#.*)?$/) em_lista = 1
    if (secao == "extend") {
      if (chave == "useDefault" && valor ~ /^true[ \t]*(#.*)?$/) padrao = 1
      else erro($0 " não é aceito; em [extend] só useDefault = true")
    } else if (secao == "allowlists") {
      if (chave == "description") { if (valor ~ /^("[^"]+"|'\''[^'\'']+'\'')/) motivo = 1 }
      else if (chave !~ /^(paths|regexes|stopwords|commits|regexTarget|condition|targetRules)$/) erro(chave " não é aceito em [[allowlists]]")
    } else if (secao != "recusada") erro(chave " fora de [extend] e [[allowlists]] não é aceito")
    next
  }
  { erro($0 " não foi entendido") }
  END { fecha(); if (!padrao) print "falta [extend] com useDefault = true: sem ele as regras padrão não são carregadas" }
' .gitleaks.toml)
if [ -n "$invalidas" ]; then
  falha "Configuração não aceita em .gitleaks.toml:
$invalidas" \
    "o .gitleaks.toml só tem [extend] com useDefault = true e blocos [[allowlists]] com description não vazia explicando por que não é segredo. Exceção é só para falso positivo; desligar ou trocar regra não vale (regras em docs/SECURITY.md)."
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
    "tire o valor do arquivo e leia de variável de ambiente ou de um .env ignorado pelo git. Se for falso positivo, registre em .gitleaks.toml com description (regras em docs/SECURITY.md)."
fi
# Tirar a chave num commit novo não basta: o commit anterior, com ela, vai junto no push.
# O que já está no origin/main já foi publicado e fica com o secret scanning do GitHub.
if git rev-parse -q --verify HEAD >/dev/null; then
  intervalo=HEAD
  if git rev-parse -q --verify origin/main >/dev/null; then intervalo=origin/main..HEAD; fi
  if ! gitleaks git . --log-opts="$intervalo" --config "$raiz/.gitleaks.toml" --ignore-gitleaks-allow \
    --no-banner --no-color --redact --log-level warn --verbose; then
    falha "Segredo num commit que ainda não está no origin/main (commit, arquivo e linha acima)." \
      "apagar o valor num commit novo não basta, o commit antigo vai junto no push. Refaça os commits sem o segredo: git reset --soft origin/main, tire o valor dos arquivos (leia de variável de ambiente ou de um .env ignorado pelo git) e commite de novo. Se algum desses commits já foi para um branch remoto, considere a credencial vazada e peça ao humano para revogá-la. Se for falso positivo, registre em .gitleaks.toml com description (regras em docs/SECURITY.md)."
  fi
fi
echo "nenhum segredo encontrado"

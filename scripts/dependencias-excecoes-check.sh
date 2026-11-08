#!/usr/bin/env bash
# Confere as exceções de vulnerabilidade do osv-scanner.toml: cada uma com id, motivo e prazo de no máximo 30 dias.
# Lista do que é permitido: o OSV-Scanner aceita outras formas (tabela inline, PackageOverrides) que não passariam por aqui.
# Uso: scripts/dependencias-excecoes-check.sh [osv-scanner.toml]
# HOJE=AAAA-MM-DD troca a data de hoje (usado pelos casos em scripts/dependencias-excecoes-check.test.sh).
set -euo pipefail
config=${1:-"$(dirname "$0")/../osv-scanner.toml"}
hoje=${HOJE:-$(date +%Y-%m-%d)}

# O osv-scanner.toml não guarda quando a exceção foi criada. Então o limite de 30 dias é contado de hoje:
# uma exceção criada hoje pode ir até hoje + 30, e nenhuma exceção válida fica com prazo maior que isso.
problemas=$(awk -v hoje="$hoje" '
  function dias(data,   a, m, d, era, ano_era, dia_ano) {
    a = substr(data, 1, 4) + 0; m = substr(data, 6, 2) + 0; d = substr(data, 9, 2) + 0
    if (m <= 2) a--
    era = int(a / 400); ano_era = a - era * 400
    dia_ano = int((153 * (m > 2 ? m - 3 : m + 9) + 2) / 5) + d - 1
    return era * 146097 + ano_era * 365 + int(ano_era / 4) - int(ano_era / 100) + dia_ano
  }
  function fecha() {
    if (!aberto) return
    if (!id) print "linha " inicio ": exceção sem id"
    if (!motivo) print "linha " inicio ": exceção " id " sem reason"
    if (prazo == "") print "linha " inicio ": exceção " id " sem ignoreUntil"
    else if (dias(prazo) < dias(hoje)) print "linha " inicio ": exceção " id " venceu em " prazo
    else if (dias(prazo) - dias(hoje) > 30) print "linha " inicio ": exceção " id " vai até " prazo ", mais de 30 dias depois de hoje (" hoje ")"
    aberto = 0
  }
  /^[ \t]*\[/ {
    fecha()
    if ($0 ~ /^[ \t]*\[\[IgnoredVulns\]\][ \t]*$/) { aberto = 1; inicio = NR; id = ""; motivo = 0; prazo = "" }
    else print "linha " NR ": " $0 " não é aceito; só [[IgnoredVulns]], que ignora uma vulnerabilidade e não o pacote inteiro"
    next
  }
  /^[ \t]*(#.*)?$/ { next }
  /^[ \t]*[A-Za-z]+[ \t]*=/ {
    chave = $0; sub(/^[ \t]*/, "", chave); sub(/[ \t]*=.*$/, "", chave)
    if (!aberto) { print "linha " NR ": " chave " fora de [[IgnoredVulns]] não é aceito"; next }
    if (chave == "id" && $0 ~ /=[ \t]*"[^"]+"/) { id = $0; sub(/^[^"]*"/, "", id); sub(/".*$/, "", id) }
    else if (chave == "reason") { if ($0 ~ /=[ \t]*("[^"]+"|'\''[^'\'']+'\'')/) motivo = 1 }
    else if (chave == "ignoreUntil") {
      if ($0 ~ /=[ \t]*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][ \t]*(#.*)?$/) { prazo = $0; sub(/^[^=]*=[ \t]*/, "", prazo); prazo = substr(prazo, 1, 10) }
      else print "linha " NR ": ignoreUntil precisa ser uma data AAAA-MM-DD sem aspas"
    }
    else if (chave != "id") print "linha " NR ": " chave " não é aceito em [[IgnoredVulns]]; só id, ignoreUntil e reason"
    next
  }
  { print "linha " NR ": " $0 " não foi entendido; cada chave vai numa linha só" }
  END { fecha() }
' "$config")

if [ -n "$problemas" ]; then
  echo "Exceção inválida em $config:" >&2
  echo "$problemas" >&2
  echo "Como corrigir: atualize a biblioteca para a versão corrigida, se houver. Se não der, cada exceção é um bloco [[IgnoredVulns]] com id, reason (por que é aceitável por enquanto) e ignoreUntil = AAAA-MM-DD sem aspas, no máximo 30 dias depois de hoje, e o motivo vai também no log de decisões do plano (regras em docs/SECURITY.md)." >&2
  exit 1
fi
echo "exceções de dependência ok"

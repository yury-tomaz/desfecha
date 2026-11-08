#!/usr/bin/env bash
# Casos de scripts/dependencias-excecoes-check.sh. Rodado por scripts/verify.sh.
set -euo pipefail
cd "$(dirname "$0")"
checagem=$PWD/dependencias-excecoes-check.sh

falhas=0
config=$(mktemp)
trap 'rm -f "$config"' EXIT
export HOJE=2026-11-07

confere() {
  local esperado=$1 caso=$2 saida rc=0
  cat >"$config"
  saida=$("$checagem" "$config" 2>&1) || rc=$?
  if [ "$rc" -ne "$esperado" ]; then
    echo "dependencias-excecoes-check: esperava rc=$esperado e saiu rc=$rc no caso: $caso"
    echo "$saida" | sed 's/^/    /'
    falhas=$((falhas + 1))
  elif [ "$esperado" -ne 0 ] && ! grep -q 'Como corrigir' <<<"$saida"; then
    echo "dependencias-excecoes-check: a falha não diz como corrigir no caso: $caso"
    falhas=$((falhas + 1))
  fi
}

confere 0 "arquivo sem exceção passa" <<'EOF'
# só comentário
EOF

confere 0 "exceção com motivo e prazo dentro de 30 dias passa" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-11-20
reason = "sem versão corrigida; só roda no build"
EOF

confere 0 "exceção com prazo de exatamente 30 dias passa" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-12-07
reason = "sem versão corrigida"
EOF

confere 1 "exceção com prazo de 31 dias falha" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-12-08
reason = "sem versão corrigida"
EOF

confere 1 "exceção vencida falha" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-11-06
reason = "sem versão corrigida"
EOF

confere 1 "exceção sem motivo falha" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-11-20
EOF

confere 1 "exceção com motivo vazio falha" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-11-20
reason = ""
EOF

confere 1 "exceção sem prazo falha" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
reason = "sem versão corrigida"
EOF

confere 1 "exceção sem id falha" <<'EOF'
[[IgnoredVulns]]
ignoreUntil = 2026-11-20
reason = "sem versão corrigida"
EOF

confere 1 "segunda exceção inválida falha mesmo com a primeira válida" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-11-20
reason = "sem versão corrigida"

[[IgnoredVulns]]
id = "GHSA-dddd-eeee-ffff"
ignoreUntil = 2027-11-20
reason = "sem versão corrigida"
EOF

confere 1 "PackageOverrides não é aceito porque ignora o pacote inteiro" <<'EOF'
[[PackageOverrides]]
name = "minimatch"
ecosystem = "npm"
ignore = true
reason = "não usado"
EOF

confere 1 "IgnoredVulns como tabela inline, sem motivo nem prazo, não é aceito" <<'EOF'
IgnoredVulns = [{ id = "GHSA-aaaa-bbbb-cccc" }]
EOF

confere 1 "PackageOverrides como tabela inline não é aceito" <<'EOF'
PackageOverrides = [{ name = "minimatch", ecosystem = "npm", ignore = true }]
EOF

confere 1 "chave desconhecida dentro de [[IgnoredVulns]] não é aceita" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-11-20
reason = "sem versão corrigida"
ignore = true
EOF

confere 1 "ignoreUntil fora do formato AAAA-MM-DD sem aspas não é aceito" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = "2099-01-01"
reason = "sem versão corrigida"
EOF

confere 1 "linha que não é chave, tabela nem comentário não é aceita" <<'EOF'
[[IgnoredVulns]]
id = "GHSA-aaaa-bbbb-cccc"
ignoreUntil = 2026-11-20
reason = """
motivo em várias linhas
"""
EOF

if [ "$falhas" -gt 0 ]; then
  echo "$falhas caso(s) de dependencias-excecoes-check falharam. Corrija scripts/dependencias-excecoes-check.sh, não os casos."
  exit 1
fi
echo "checagem das exceções de dependência ok"

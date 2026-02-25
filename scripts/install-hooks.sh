#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="${ROOT}/.git/hooks"

if [[ ! -d "${ROOT}/.git" ]]; then
  echo "not a git repository: ${ROOT}"
  exit 1
fi

mkdir -p "${HOOKS_DIR}"
cat > "${HOOKS_DIR}/pre-commit" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
"$(git rev-parse --show-toplevel)/scripts/scan-secrets.sh"
EOF

chmod +x "${HOOKS_DIR}/pre-commit"
echo "installed: .git/hooks/pre-commit"

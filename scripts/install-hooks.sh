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
"$(git rev-parse --show-toplevel)/scripts/scan-privacy.sh"
EOF

chmod +x "${HOOKS_DIR}/pre-commit"
echo "installed: .git/hooks/pre-commit"

cat > "${HOOKS_DIR}/pre-push" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
"${ROOT}/scripts/scan-secrets.sh"
"${ROOT}/scripts/scan-privacy.sh"
"${ROOT}/scripts/scan-secrets.sh" --history
EOF

chmod +x "${HOOKS_DIR}/pre-push"
echo "installed: .git/hooks/pre-push"

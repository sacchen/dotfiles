#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${HOME}"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found. Install it first: brew install stow"
  exit 1
fi

ADOPT_FLAG=""
if [[ "${1:-}" == "--adopt" ]]; then
  ADOPT_FLAG="--adopt"
fi

cd "${ROOT}"
stow ${ADOPT_FLAG} --target "${TARGET}" zsh config git homebrew
echo "stow complete"

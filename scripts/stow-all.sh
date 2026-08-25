#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${HOME}"

if ! command -v stow >/dev/null 2>&1; then
  case "$(uname -s)" in
    Darwin)
      echo "stow not found. Install it first: brew install stow"
      ;;
    Linux)
      echo "stow not found. Install it first: sudo apt update && sudo apt install -y stow"
      ;;
    *)
      echo "stow not found. Install it with your package manager."
      ;;
  esac
  exit 1
fi

ADOPT_FLAG=""
if [[ "${1:-}" == "--adopt" ]]; then
  ADOPT_FLAG="--adopt"
fi

PACKAGES=(zsh config git)
if [[ "$(uname -s)" == "Darwin" ]]; then
  PACKAGES+=(homebrew)
fi

cd "${ROOT}"
stow ${ADOPT_FLAG} --target "${TARGET}" "${PACKAGES[@]}"
echo "stow complete"

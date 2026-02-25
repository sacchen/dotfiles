#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

PATTERN='(-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]+|xox[baprs]-[A-Za-z0-9-]+|(^|[[:space:]])(export[[:space:]]+)?[A-Z0-9_]*(TOKEN|SECRET|PASSWORD|API_KEY|ACCESS_KEY)[A-Z0-9_]*[[:space:]]*=)'
SCAN_EXT='(sh|zsh|bash|env|toml|yaml|yml|json|lua|conf|cfg|ini|txt|md)$'

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "not a git repository: ${ROOT}"
  exit 1
fi

scan_files() {
  local files="$1"
  local matches=""
  matches="$(
    while IFS= read -r file; do
      [[ -z "${file}" ]] && continue
      [[ "${file}" == *.example ]] && continue
      [[ "${file}" =~ ^config/.config/nvim/doc/ ]] && continue
      [[ -f "${file}" ]] || continue
      if [[ "${file}" =~ \.${SCAN_EXT} ]] || [[ "${file}" =~ ^\.[^/]+$ ]] || [[ "${file}" =~ /\.[^/]+$ ]]; then
        rg -n -i "${PATTERN}" "${file}" || true
      fi
    done <<< "${files}" || true
  )"

  if [[ -n "${matches}" ]]; then
    printf "%s\n" "${matches}"
    return 1
  fi
  return 0
}

if [[ "${1:-}" == "--history" ]]; then
  echo "scanning git history (all revisions)..."
  if git rev-list --all | while IFS= read -r rev; do
    git grep -n -I -E "${PATTERN}" "${rev}" -- . ":(exclude)*.example" || true
  done | rg -v '^.+:config/.config/nvim/doc/' | rg -n '.'; then
    echo "possible secrets found in history"
    exit 1
  fi
  echo "no secret patterns found in history"
  exit 0
fi

STAGED="$(git diff --cached --name-only)"
if [[ -n "${STAGED}" ]]; then
  echo "scanning staged files..."
  if ! scan_files "${STAGED}"; then
    echo "possible secrets found in staged files"
    exit 1
  fi
  echo "no secret patterns found in staged files"
  exit 0
fi

echo "no staged files; scanning tracked files..."
TRACKED="$(git ls-files)"
if ! scan_files "${TRACKED}"; then
  echo "possible secrets found in tracked files"
  exit 1
fi
echo "no secret patterns found in tracked files"

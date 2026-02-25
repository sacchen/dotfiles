#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

ALLOWLIST_FILE="${ROOT}/.privacy-allowlist"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "not a git repository: ${ROOT}"
  exit 1
fi

PATTERNS=(
  '/Users/[A-Za-z0-9._-]+'
  '(/home/[A-Za-z0-9._-]+)'
  '(^|[[:space:]])ssh[[:space:]]+[A-Za-z0-9._-]+'
  '[A-Za-z0-9._-]+:(~\/|/[^/])[^[:space:]]*'
)

scan_files() {
  local files="$1"
  local raw_matches=""
  local filtered_matches=""
  local pattern

  raw_matches="$(
    while IFS= read -r file; do
      [[ -z "${file}" ]] && continue
      [[ "${file}" == *.example ]] && continue
      [[ "${file}" =~ ^config/.config/nvim/doc/ ]] && continue
      [[ -f "${file}" ]] || continue
      for pattern in "${PATTERNS[@]}"; do
        rg -n -H -S -e "${pattern}" "${file}" || true
      done
    done <<< "${files}" || true
  )"

  filtered_matches="${raw_matches}"
  if [[ -f "${ALLOWLIST_FILE}" ]]; then
    filtered_matches="$(printf "%s\n" "${filtered_matches}" | rg -v -f "${ALLOWLIST_FILE}" || true)"
  fi

  filtered_matches="$(printf "%s\n" "${filtered_matches}" | rg -v '^[[:space:]]*$' || true)"
  if [[ -n "${filtered_matches}" ]]; then
    printf "%s\n" "${filtered_matches}"
    return 1
  fi
  return 0
}

STAGED="$(git diff --cached --name-only)"
if [[ -n "${STAGED}" ]]; then
  echo "scanning staged files for privacy leaks..."
  if ! scan_files "${STAGED}"; then
    echo "possible privacy leaks found in staged files"
    exit 1
  fi
  echo "no privacy patterns found in staged files"
  exit 0
fi

echo "no staged files; scanning tracked files for privacy leaks..."
TRACKED="$(git ls-files)"
if ! scan_files "${TRACKED}"; then
  echo "possible privacy leaks found in tracked files"
  exit 1
fi
echo "no privacy patterns found in tracked files"

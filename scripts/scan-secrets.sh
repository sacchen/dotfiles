#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

PATTERN='(-----BEGIN [A-Z ]*PRIVATE KEY-----|(^|[[:space:]])(export[[:space:]]+)?[A-Z0-9_]*(TOKEN|SECRET|PASSWORD|API_KEY)[A-Z0-9_]*[[:space:]]*=|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]+)'

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "not a git repository: ${ROOT}"
  exit 1
fi

TARGETS="$(git diff --cached --name-only)"
if [[ -z "${TARGETS}" ]]; then
  echo "no staged files; scanning config files"
  if rg -n -i "${PATTERN}" zsh config homebrew -g '!*.example'; then
    echo "possible secrets found"
    exit 1
  fi
  echo "no secret patterns found"
  exit 0
fi

echo "scanning staged files..."
FILTERED="$(git diff --cached --name-only | rg '^(zsh/|config/|homebrew/)' || true)"
if [[ -z "${FILTERED}" ]]; then
  echo "no staged config files to scan"
  exit 0
fi

MATCHES="$(
  while IFS= read -r file; do
    [[ -z "${file}" ]] && continue
    [[ "${file}" == *.example ]] && continue
    [[ -f "${file}" ]] || continue
    rg -n -i "${PATTERN}" "${file}" || true
  done <<< "${FILTERED}" || true
)"
if [[ -n "${MATCHES}" ]]; then
  printf "%s\n" "${MATCHES}"
  echo "possible secrets found in staged files"
  exit 1
fi

echo "no secret patterns found in staged files"

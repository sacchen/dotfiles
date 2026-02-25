#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME}"

mkdir -p \
  "${ROOT}/zsh" \
  "${ROOT}/git" \
  "${ROOT}/ssh/.ssh" \
  "${ROOT}/config/.config" \
  "${ROOT}/homebrew" \
  "${ROOT}/manifests"

copy_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -e "${src}" ]]; then
    mkdir -p "$(dirname "${dst}")"
    cp -R "${src}" "${dst}"
    echo "copied: ${src} -> ${dst}"
  else
    echo "missing: ${src}"
  fi
}

scan_for_secrets() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    if rg -n -i "(api[_-]?key|token|secret|password|private key|begin .*private key|aws_|github_|openai_)" "${file}" >/dev/null 2>&1; then
      echo "warning: possible secret pattern in ${file}"
    fi
  fi
}

# Copy shell + prompt config
copy_if_exists "${HOME_DIR}/.zshrc" "${ROOT}/zsh/.zshrc"
copy_if_exists "${HOME_DIR}/.zprofile" "${ROOT}/zsh/.zprofile"
copy_if_exists "${HOME_DIR}/.gitconfig" "${ROOT}/git/.gitconfig"
copy_if_exists "${HOME_DIR}/.config/git/ignore" "${ROOT}/config/.config/git/ignore"
copy_if_exists "${HOME_DIR}/.config/starship.toml" "${ROOT}/config/.config/starship.toml"
copy_if_exists "${HOME_DIR}/.config/gh/config.yml" "${ROOT}/config/.config/gh/config.yml"

# Copy neovim config without nested git metadata.
if [[ -d "${HOME_DIR}/.config/nvim" ]]; then
  rm -rf "${ROOT}/config/.config/nvim"
  mkdir -p "${ROOT}/config/.config"
  rsync -a --delete \
    --exclude ".git" \
    --exclude ".github" \
    --exclude "doc" \
    --exclude "README.md" \
    --exclude "LICENSE.md" \
    --exclude ".gitignore" \
    --exclude ".nvimlog" \
    "${HOME_DIR}/.config/nvim/" "${ROOT}/config/.config/nvim/"
  # Keep only runtime-relevant nvim config for portability.
  rm -rf "${ROOT}/config/.config/nvim/.github" "${ROOT}/config/.config/nvim/doc"
  rm -f "${ROOT}/config/.config/nvim/README.md" \
    "${ROOT}/config/.config/nvim/LICENSE.md" \
    "${ROOT}/config/.config/nvim/.gitignore"
  echo "copied: ${HOME_DIR}/.config/nvim -> ${ROOT}/config/.config/nvim (excluding .git)"
else
  echo "missing: ${HOME_DIR}/.config/nvim"
fi

scan_for_secrets "${ROOT}/zsh/.zshrc"
scan_for_secrets "${ROOT}/zsh/.zprofile"
scan_for_secrets "${ROOT}/git/.gitconfig"
scan_for_secrets "${ROOT}/config/.config/git/ignore"
scan_for_secrets "${ROOT}/config/.config/starship.toml"
scan_for_secrets "${ROOT}/config/.config/gh/config.yml"

# Export Homebrew package state if available.
if command -v brew >/dev/null 2>&1; then
  if brew bundle dump --force --file="${ROOT}/homebrew/Brewfile" >/dev/null 2>&1; then
    echo "generated: ${ROOT}/homebrew/Brewfile"
  else
    echo "warning: brew snapshot failed in this environment"
  fi
else
  echo "missing: brew"
fi

# Snapshot uv tools (optional metadata, ignored by default).
if command -v uv >/dev/null 2>&1; then
  if uv tool list > "${ROOT}/manifests/uv-tools.txt" 2>/dev/null; then
    echo "generated: ${ROOT}/manifests/uv-tools.txt"
  else
    echo "warning: uv tool snapshot failed in this environment"
    rm -f "${ROOT}/manifests/uv-tools.txt"
  fi
else
  echo "missing: uv"
fi

echo "import complete"

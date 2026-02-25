# dotfiles backup

This repo uses GNU Stow so files in this repo are the source of truth and your home directory gets symlinks.

## Layout

- `zsh/.zshrc` -> `~/.zshrc`
- `zsh/.zprofile` -> `~/.zprofile`
- `config/.config/starship.toml` -> `~/.config/starship.toml`
- `config/.config/nvim/` -> `~/.config/nvim/`
- `homebrew/Brewfile` -> `~/Brewfile`
- `scripts/` helper scripts

## 1) Import current settings

```bash
cd ~/dotfiles
./scripts/import-current.sh
```

The import script:

- copies current files into this repo
- skips missing files
- warns if likely secret patterns are found
- writes `homebrew/Brewfile`
- writes `manifests/uv-tools.txt` when `uv` exists

## 2) Review before commit

```bash
git init
git add .
git diff --cached
```

If anything secret appears, move it to a local file (for example `~/.zshrc.local`) and source it from tracked files.

## 3) Apply symlinks with stow

```bash
brew install stow
cd ~/dotfiles
./scripts/stow-all.sh
```

## 4) Install commit-time secret scanning

```bash
cd ~/dotfiles
./scripts/install-hooks.sh
```

## 5) Push to GitHub

```bash
git branch -M main
git remote add origin git@github.com:<you>/dotfiles.git
git commit -m "Initial dotfiles backup"
git push -u origin main
```

## Public repo safety checklist

Before pushing to a public repo:

- run `./scripts/scan-secrets.sh`
- run `./scripts/scan-privacy.sh`
- run `./scripts/public-audit.sh` for a full tracked+history pass
- run `git diff --cached` and verify no keys/tokens/passwords appear
- move machine-private aliases/work paths/hostnames into `~/.zshrc.local` if you do not want them public
- keep `~/.zshrc.local` and `*.local` out of git

Optional deeper audit:

- run `./scripts/scan-secrets.sh --history` before first public release

Hooks:

- `./scripts/install-hooks.sh` installs `pre-commit` and `pre-push` checks

If scans fail:

- move sensitive lines to local-only files like `~/.zshrc.local`
- rotate credentials if a real secret was ever committed

## Safe pattern for local secrets

In tracked `~/.zshrc`, add:

```bash
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
```

Then keep `~/.zshrc.local` out of Git and store tokens there.

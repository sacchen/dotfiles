# Dotfiles

Personal shell/editor setup that is safe to share publicly.

If you are a friend copying this, use it as a starting point, not a drop-in identity clone.

## What This Repo Manages

- `zsh/.zshrc` -> `~/.zshrc`
- `zsh/.zprofile` -> `~/.zprofile`
- `git/.gitconfig` -> `~/.gitconfig`
- `config/.config/git/ignore` -> `~/.config/git/ignore`
- `config/.config/starship.toml` -> `~/.config/starship.toml`
- `config/.config/gh/config.yml` -> `~/.config/gh/config.yml` (CLI preferences only)
- `config/.config/nvim/` -> `~/.config/nvim/` (runtime config files only)
- `homebrew/Brewfile` -> `~/Brewfile`

Template only:

- `ssh/.ssh/config.example` (copy and customize manually; do not symlink as-is)

## Quick Start (macOS)

```bash
# 1) Clone
git clone https://github.com/<owner>/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2) Install base tooling
brew install stow

# 3) Install packages from Brewfile (optional but recommended)
brew bundle --file=homebrew/Brewfile

# 4) Link configs into your home dir
./scripts/stow-all.sh --adopt

# 5) Turn on local safety hooks
./scripts/install-hooks.sh
```

Restart your shell after linking.

## Make It Yours

Use local overrides for anything personal or machine-specific:

```bash
cp zsh/.zshrc.local.example ~/.zshrc.local
```

Put these in `~/.zshrc.local`:

- API keys and tokens
- private aliases
- work hostnames/IPs
- machine-specific paths

`~/.zshrc.local` is intentionally not tracked.

## SSH Setup

Do not commit your real SSH config or keys.

```bash
mkdir -p ~/.ssh
cp ssh/.ssh/config.example ~/.ssh/config
chmod 600 ~/.ssh/config
```

Then edit hostnames/users for your own machines.

## Updating From Upstream

```bash
cd ~/dotfiles
git pull
./scripts/stow-all.sh --adopt
```

## Safety Checks

Before pushing changes:

```bash
./scripts/public-audit.sh
```

This runs:

- staged/tracked secret scan
- privacy leak scan
- full git history secret scan

Hooks installed by `./scripts/install-hooks.sh` run scans on commit and push.

## For Maintainers (Refreshing from Current Machine)

If you are the repo owner and want to snapshot your current local setup:

```bash
cd ~/dotfiles
./scripts/import-current.sh
./scripts/public-audit.sh
```

Then review diffs before committing.

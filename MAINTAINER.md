# Maintainer Notes

Personal operating notes for maintaining this dotfiles repo safely.

## Daily Commands

Run full safety checks:

```bash
cd ~/dotfiles
./scripts/public-audit.sh
```

Run individual checks:

```bash
./scripts/scan-secrets.sh
./scripts/scan-privacy.sh
./scripts/scan-secrets.sh --history
```

## Refresh Repo From Current Machine

```bash
cd ~/dotfiles
./scripts/import-current.sh
./scripts/public-audit.sh
git status
```

## Apply Dotfiles to Local Machine

```bash
cd ~/dotfiles
./scripts/stow-all.sh --adopt
```

Reinstall local git hooks (pre-commit + pre-push):

```bash
./scripts/install-hooks.sh
```

## Commit + Push Flow

```bash
cd ~/dotfiles
./scripts/public-audit.sh
git add -A
git commit -m "your message"
git push
```

If GitHub auth breaks:

```bash
gh auth login -h github.com
git push
```

## Public Repo Rules (Do Not Violate)

- Never commit `~/.zshrc.local`
- Never commit `~/.config/gh/hosts.yml`
- Never commit real `~/.ssh/config` (template only in repo)
- Never commit private keys, tokens, or passwords

## Quick Recovery

If local links drift or break:

```bash
cd ~/dotfiles
./scripts/stow-all.sh --adopt
```

If hooks disappear:

```bash
./scripts/install-hooks.sh
```

If unsure before publishing:

```bash
./scripts/public-audit.sh
git diff --cached
```

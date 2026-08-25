
. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env"
eval "$(zoxide init zsh)"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  PROMPT='%n@%m %~ %# '
fi

alias cd="z"
alias fd="fdfind"
alias bat="batcat"
alias tdev='tmux attach -t dev || tmux new -s dev'

servercheck() {
  echo "== Memory =="
  free -h
  echo

  echo "== Swap =="
  swapon --show
  echo

  echo "== Disk (/)=="
  df -h /
  echo

  echo "== Load =="
  uptime
  echo

  echo "== Top Memory =="
  ps aux --sort=-%mem | head -10
  echo

  echo "== Top CPU =="
  ps aux --sort=-%cpu | head -10
  echo

  echo "== Coordinator =="
  ps -C uv,uvicorn -o pid,ppid,%cpu,%mem,rss,vsz,etime,cmd
  echo

  echo "== Codex =="
  pgrep -af codex || true
  ps -C codex -o pid,ppid,%cpu,%mem,rss,vsz,etime,cmd 2>/dev/null || true
}

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

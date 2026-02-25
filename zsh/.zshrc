# 1. Environment & Paths
export PATH="/Users/goddess/.local/bin:$HOME/.bun/bin:$HOME/.lmstudio/bin:$PATH"
export EXA_COLORS="di=1;34"

# 2. Modern Tool Initializations
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# 4. Modern Coreutils Aliases
alias ls='eza'
alias ll='eza -lah'
alias lt='eza --tree'
alias grep='rg'
alias cat='bat --paging=never'
# alias cd='z'

# 5. Project & Dev Workflow
alias va='source .venv/bin/activate'
alias server='PYTHONPATH=src uv run server.py'
alias transmit="cd ~/foundry/sandbox/Flattransmitter && uv run broadcast.py"

# 6. Optimized Deployment
alias deploy-exchange="rsync -avz --delete \
  --filter=':- .gitignore' \
  --exclude={'.venv','.DS_Store','__pycache__','state.json','*.log','.pytest_cache','.mypy_cache'} \
  ~/foundry/sandbox/order-book-global/short-your-friends/python-prototype/ \
  exchange:~/python-prototype/ && \
  ssh exchange 'sudo systemctl restart exchange' && \
  echo '[+] Deployed!'"

# 7. Hardware Hacks
alias swapcaps="hidutil property --set '{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0x700000039,\"HIDKeyboardModifierMappingDst\":0x700000029},{\"HIDKeyboardModifierMappingSrc\":0x700000029,\"HIDKeyboardModifierMappingDst\":0x700000039}]}'"
alias resetcaps="hidutil property --set '{\"UserKeyMapping\":[]}'"

# Local machine-only settings (tokens, private env vars, etc.)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

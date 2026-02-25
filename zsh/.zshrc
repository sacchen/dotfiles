# 1. Environment & Paths
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/.lmstudio/bin:$PATH"
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

# 7. Hardware Hacks
alias swapcaps="hidutil property --set '{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0x700000039,\"HIDKeyboardModifierMappingDst\":0x700000029},{\"HIDKeyboardModifierMappingSrc\":0x700000029,\"HIDKeyboardModifierMappingDst\":0x700000039}]}'"
alias resetcaps="hidutil property --set '{\"UserKeyMapping\":[]}'"

# Local machine-only settings (tokens, private env vars, private aliases)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

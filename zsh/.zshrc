# ~/.zshrc — interactive shell config

# ---- Environment ----
export EDITOR=nvim
export VISUAL=nvim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export HOMEBREW_NO_ANALYTICS=1
export PYTHONBREAKPOINT=ipdb.set_trace

# opencode CLI
export PATH="$HOME/.opencode/bin:$PATH"

# ---- History ----
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS \
       HIST_REDUCE_BLANKS HIST_VERIFY EXTENDED_HISTORY \
       INC_APPEND_HISTORY

# ---- Useful options ----
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT \
       INTERACTIVE_COMMENTS GLOB_DOTS NO_BEEP

# ---- Completion ----
autoload -Uz compinit
# Speed up by only checking dump file once per day
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ---- mise (universal language + tool manager) ----
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
elif [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$($HOME/.local/bin/mise activate zsh)"
fi

# ---- Plugins (installed via brew) ----
BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
[[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -f "$BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

# history-substring-search keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ---- Modern CLI tools ----
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide >/dev/null   && eval "$(zoxide init zsh)"

# fzf
if command -v fzf >/dev/null; then
  source <(fzf --zsh) 2>/dev/null || true
fi

# ---- Aliases ----
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# ---- Per-machine overrides (gitignored) ----
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

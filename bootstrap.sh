#!/usr/bin/env zsh
# bootstrap.sh — idempotent dotfiles installer
# Usage: ./bootstrap.sh

set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "$0")" && pwd)}"
cd "$DOTFILES"

log() { print -P "%F{cyan}==>%f $*"; }
warn() { print -P "%F{yellow}!! $*%f"; }
ok()   { print -P "%F{green}✓%f $*"; }

# ---- 1. Xcode CLT ----
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  warn "Re-run this script after Xcode CLT install completes."
  exit 1
fi
ok "Xcode CLT present"

# ---- 2. Homebrew ----
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
ok "Homebrew ready"

# ---- 3. Brew bundle ----
log "Running brew bundle..."
brew bundle --file="$DOTFILES/Brewfile"
ok "Brew packages installed"

# ---- 4. Stow packages ----
STOW_PACKAGES=(git zsh ssh mise starship ghostty tmux nvim opencode zed ruby)

log "Stowing packages into \$HOME..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

for pkg in "${STOW_PACKAGES[@]}"; do
  if [[ -d "$DOTFILES/$pkg" ]]; then
    # Back up conflicting non-symlink files to *.backup
    while IFS= read -r -d '' file; do
      rel="${file#$DOTFILES/$pkg/}"
      target="$HOME/$rel"
      if [[ -e "$target" && ! -L "$target" ]]; then
        warn "Backing up existing $target -> $target.backup"
        mv "$target" "$target.backup"
      fi
    done < <(find "$DOTFILES/$pkg" -type f -print0)

    stow --target="$HOME" --restow "$pkg"
    ok "Stowed: $pkg"
  fi
done

# ---- 5. VS Code (lives outside $HOME) ----
log "Symlinking VS Code settings..."
VSC_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSC_DIR"
for f in settings.json keybindings.json; do
  target="$VSC_DIR/$f"
  if [[ -e "$target" && ! -L "$target" ]]; then
    warn "Backing up existing $target -> $target.backup"
    mv "$target" "$target.backup"
  fi
  ln -sfn "$DOTFILES/vscode/$f" "$target"
done
ok "VS Code linked"

# ---- 6. mise: install all global tools ----
log "Installing mise-managed tools (this can take a while on first run)..."
if mise install 2>&1 | tee /tmp/mise-install.log; then
  ok "mise tools installed"
else
  # Python 3.14 fallback to 3.13
  if grep -q "python@3.14" /tmp/mise-install.log; then
    warn "Python 3.14 failed; falling back to 3.13"
    mise use --global python@3.13
    mise install
  else
    warn "mise install had errors — review /tmp/mise-install.log"
  fi
fi

# ---- 7. tmux plugin manager ----
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  log "Installing tmux plugin manager (tpm)..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
ok "tpm ready (run 'prefix + I' in tmux to install plugins)"

# ---- 8. Neovim first-run sync ----
if command -v nvim >/dev/null 2>&1; then
  log "Syncing Neovim plugins (headless)..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || warn "nvim sync had issues; run :Lazy sync manually"
fi

# ---- 9. opencode plugins ----
if [[ -f "$HOME/.config/opencode/package.json" ]]; then
  log "Installing opencode plugins..."
  if command -v bun >/dev/null 2>&1; then
    (cd "$HOME/.config/opencode" && bun install)
  elif command -v npm >/dev/null 2>&1; then
    (cd "$HOME/.config/opencode" && npm install)
  fi
fi

# ---- 10. SSH key ----
if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" 2>/dev/null || true
fi

print
ok "Done! Restart your shell (or run: exec zsh)"
print -P "%F{yellow}Tip:%f put per-machine overrides in ~/.zshrc.local and ~/.gitconfig.local"

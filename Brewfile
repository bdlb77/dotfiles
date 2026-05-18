# Brewfile — minimal curated.
# Philosophy: mise owns languages + CLI tools. Brew only owns:
#   - macOS apps (casks)
#   - system libs + bootstrap utilities
#   - zsh plugins (sourced from $(brew --prefix)/share/...)
# Run: brew bundle --file=./Brewfile

# ---- Bootstrap & dotfile management ----
brew "mise"
brew "stow"
brew "git"
brew "gh"   # also in mise; kept here so bootstrap works before mise install

# ---- Secrets ----
brew "varlock"             # schema-driven env loader with @ref(op://...) support
cask "1password"           # vault (idempotent if already installed)
# NOTE: 1password-cli is intentionally NOT managed by brew.
# We use the BETA op CLI (>= 2.33.0), required for `op environment` /
# Varlock's opLoadEnvironment() with desktop-app auth on Personal/Family
# 1Password plans (Service Accounts are Teams/Business only).
#
# Beta install:
#   1. Download from https://app-updates.agilebits.com/product_history/CLI2
#      (click "Show betas"); current: 2.35.0-beta.01
#   2. Run the .pkg installer (installs to /usr/local/bin/op)
#   3. Point brew's symlink at it (so PATH resolves correctly):
#        ln -sfn /usr/local/bin/op /opt/homebrew/bin/op
#   4. Verify: op --version  # should show 2.x.x-beta.x
#
# If you `brew install --cask 1password-cli` later it will overwrite the
# symlink with stable; re-run step 3 to restore beta.

# ---- Zsh plugins (sourced from .zshrc) ----
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-history-substring-search"

# ---- Apps (casks) ----
cask "ghostty"
cask "visual-studio-code"
cask "zed"

# ---- Fonts ----
cask "font-jetbrains-mono-nerd-font"
cask "font-symbols-only-nerd-font"

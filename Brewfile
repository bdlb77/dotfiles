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

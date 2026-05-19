# Makefile — convenience wrappers around stow / mise / secrets

DOTFILES := $(shell pwd)
STOW_PACKAGES := git zsh ssh mise starship ghostty tmux nvim opencode ruby

.PHONY: help install stow unstow restow render-zed mise-install brew-bundle update clean install-hook scan secrets-refresh

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: brew-bundle stow mise-install render-zed install-hook ## Full setup (idempotent)

stow: ## Symlink all stow packages into $HOME
	@for pkg in $(STOW_PACKAGES); do \
		echo "Stowing $$pkg..."; \
		stow --target="$$HOME" --restow $$pkg; \
	done

unstow: ## Remove all symlinks
	@for pkg in $(STOW_PACKAGES); do stow --target="$$HOME" -D $$pkg; done

restow: stow ## Alias for stow (re-link after changes)

render-zed: ## Render Zed settings from 1Password
	@./scripts/render-zed.sh

mise-install: ## Install all mise-managed tools
	@mise install

brew-bundle: ## Run brew bundle
	@brew bundle --file=./Brewfile

update: ## Pull latest, re-stow, update tools
	@git pull
	@$(MAKE) brew-bundle
	@$(MAKE) stow
	@mise install
	@mise upgrade

clean: ## Remove generated/local files (keeps git history)
	@rm -f ~/.config/zed/settings.json
	@echo "Removed rendered Zed settings. Re-run: make render-zed"

install-hook: ## Install varlock pre-commit hook (catches secret leaks)
	@cp scripts/pre-commit.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✓ Installed .git/hooks/pre-commit"

scan: ## Manually run varlock scan over all (non-gitignored) files
	@cd secrets && varlock scan ..

secrets-refresh: ## Bust the secret cache (forces next shell to re-resolve via Touch ID)
	@rm -f "$${TMPDIR:-/tmp/}varlock-secrets-$$UID"
	@echo "✓ Cleared secret cache. Next shell will re-resolve from 1Password."

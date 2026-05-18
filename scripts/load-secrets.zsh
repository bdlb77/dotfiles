# scripts/load-secrets.zsh — sourced from ~/.zshrc.local
#
# Auto-loads 1Password-backed secrets (declared in secrets/.env.schema) into
# the current interactive shell. Prompts Touch ID once per session.
#
# To skip: SKIP_VARLOCK=1 zsh   (or set SKIP_VARLOCK=1 in ~/.zshrc.local before sourcing)

[[ -n "${SKIP_VARLOCK:-}" ]] && return 0
command -v varlock >/dev/null 2>&1 || return 0

# Resolve dotfiles location dynamically so this works regardless of clone path.
# Priority: $DOTFILES env var > ~/dotfiles > ~/code/bdlb77/dotfiles
_secrets_dir=""
for _candidate in \
  "${DOTFILES:-}/secrets" \
  "$HOME/dotfiles/secrets" \
  "$HOME/code/bdlb77/dotfiles/secrets"; do
  if [[ -f "$_candidate/.env.schema" ]]; then
    _secrets_dir="$_candidate"
    break
  fi
done

if [[ -n "$_secrets_dir" ]]; then
  eval "$(varlock load --path "$_secrets_dir" --format=shell 2>/dev/null)" || true
fi

unset _secrets_dir _candidate

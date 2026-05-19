# scripts/load-secrets.zsh — sourced from ~/.zshrc.local
#
# Auto-loads 1Password-backed secrets (declared in secrets/.env.schema) into
# the current interactive shell, with TTL-based caching to avoid Touch ID
# spam on every new shell / tmux pane / ghostty split.
#
# Cache lives at: ${TMPDIR}varlock-secrets-$UID  (tmpfs, mode 0600, auto-cleared on reboot)
# Default TTL: 1 hour. Override with: VARLOCK_CACHE_TTL=<seconds>
# To force a refresh now:   rm -f "${TMPDIR}varlock-secrets-$UID"
# To skip loading entirely: SKIP_VARLOCK=1

[[ -n "${SKIP_VARLOCK:-}" ]] && return 0
command -v varlock >/dev/null 2>&1 || return 0

# ---- resolve dotfiles location ----
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
[[ -z "$_secrets_dir" ]] && return 0

# ---- cache config ----
_cache_file="${TMPDIR:-/tmp/}varlock-secrets-$UID"
_cache_ttl="${VARLOCK_CACHE_TTL:-3600}"   # 1 hour default

# ---- check cache freshness ----
_cache_fresh=0
if [[ -f "$_cache_file" ]]; then
  # File mtime in seconds since epoch (BSD stat on macOS)
  _cache_mtime=$(stat -f %m "$_cache_file" 2>/dev/null || stat -c %Y "$_cache_file" 2>/dev/null)
  _now=$(date +%s)
  if [[ -n "$_cache_mtime" && $(( _now - _cache_mtime )) -lt $_cache_ttl ]]; then
    _cache_fresh=1
  fi
fi

# ---- (re)populate cache if stale ----
if [[ $_cache_fresh -eq 0 ]]; then
  # Resolve via varlock (triggers Touch ID if 1Password locked)
  _resolved=$(varlock load --path "$_secrets_dir" --format=shell 2>/dev/null)
  if [[ -n "$_resolved" ]]; then
    umask 077
    printf '%s\n' "$_resolved" > "$_cache_file"
    chmod 600 "$_cache_file"
  fi
fi

# ---- source whatever's in cache (may be stale-but-better-than-nothing) ----
[[ -f "$_cache_file" ]] && source "$_cache_file"

unset _secrets_dir _candidate _cache_file _cache_ttl _cache_fresh _cache_mtime _now _resolved

#!/usr/bin/env bash
# scripts/render-zed.sh
# Renders zed/.config/zed/settings.tpl.json -> ~/.config/zed/settings.json,
# replacing ${VAR} placeholders with values resolved from the 1Password
# Environment via Varlock.
#
# Requires:
#   - 1Password desktop app installed + signed in
#   - "Integrate with 1Password CLI" enabled (1Password Settings > Developer)
#   - 1Password CLI (`op`) installed + signed in (`op signin`)
#   - BETA `op` CLI (>= 2.33.0) for Environment access via desktop-app auth
#   - Varlock installed (`brew install varlock`)

set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "$0")/.." && pwd)}"
SRC="$DOTFILES/zed/.config/zed/settings.tpl.json"
DST="$HOME/.config/zed/settings.json"
SCHEMA="$DOTFILES/secrets/.env.schema"

err() { echo "Error: $*" >&2; }

# --- preflight ---
command -v varlock >/dev/null 2>&1 || { err "varlock not installed. brew install varlock"; exit 1; }
command -v op      >/dev/null 2>&1 || { err "1Password CLI not installed. brew install --cask 1password-cli"; exit 1; }
op whoami >/dev/null 2>&1 || {
  err "1Password CLI is not signed in. Run: op signin"
  err "Also enable: 1Password app > Settings > Developer > 'Integrate with 1Password CLI'"
  exit 1
}

# --- render ---
mkdir -p "$(dirname "$DST")"
TMP="$(mktemp -t zed-settings.XXXXXX)"
trap 'rm -f "$TMP"' EXIT

# Load secrets from Varlock into this process's env, then envsubst into the template.
# `varlock run --env-file=... -- envsubst` exposes loaded vars to envsubst.
( cd "$DOTFILES/secrets" && \
  varlock run -- envsubst < "$SRC" > "$TMP" )

mv "$TMP" "$DST"
chmod 600 "$DST"
echo "✓ Rendered: $DST"

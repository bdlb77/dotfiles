#!/usr/bin/env bash
# scripts/render-zed.sh
# Renders zed/.config/zed/settings.tpl.json -> ~/.config/zed/settings.json,
# replacing op://... references with real values from 1Password.
#
# Requires: 1Password desktop app installed + signed in, op CLI integration enabled
# (1Password settings > Developer > "Integrate with 1Password CLI").

set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "$0")/.." && pwd)}"
SRC="$DOTFILES/zed/.config/zed/settings.tpl.json"
DST="$HOME/.config/zed/settings.json"

if ! command -v op >/dev/null 2>&1; then
  echo "Error: 1Password CLI (op) not installed. Run: brew install --cask 1password-cli" >&2
  exit 1
fi

# Verify op is signed in
if ! op whoami >/dev/null 2>&1; then
  echo "Error: 1Password CLI is not signed in." >&2
  echo "Enable in: 1Password app > Settings > Developer > 'Integrate with 1Password CLI'" >&2
  echo "Then run: op signin" >&2
  exit 1
fi

mkdir -p "$(dirname "$DST")"
op inject -i "$SRC" -o "$DST" --force
chmod 600 "$DST"
echo "✓ Rendered: $DST"

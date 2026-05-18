#!/bin/sh
# scripts/pre-commit.sh — installed as .git/hooks/pre-commit via `make install-hook`
#
# Scans staged files for plaintext copies of any sensitive value declared in
# secrets/.env.schema (resolved live from 1Password via Varlock).
#
# To bypass for a single commit (emergencies only): git commit --no-verify
set -e

if ! command -v varlock >/dev/null 2>&1; then
  echo "warn: varlock not installed; skipping secret scan" >&2
  exit 0
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
exec varlock scan --staged --path "$REPO_ROOT/secrets/"

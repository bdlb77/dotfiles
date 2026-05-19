# `secrets/` — 1Password-backed env vars via Varlock

This directory holds **schema** for environment secrets. Real values live in
1Password (organized in a **1Password Environment**) and are resolved at
runtime by [Varlock](https://varlock.dev/) via the `@varlock/1password-plugin`
(uses the `op` CLI under the hood with Touch ID / desktop-app authentication).

> ⚠️ **Beta `op` CLI required.** Because we use `opLoadEnvironment()` with
> desktop-app auth on a Personal/Family 1Password plan (no Service Accounts),
> the BETA `op` CLI (≥ 2.33.0) is required. The Brewfile intentionally does
> NOT manage `1password-cli`. See the comment block in `Brewfile` for install
> steps. Verify with `op --version` — should show `x.y.z-beta.n`.

## Files

- `.env.schema` — committed; declares each env var with type and sensitivity.
  Values come from the 1Password Environment via `@setValuesBulk`.
- `.env.local` — gitignored; per-machine overrides (if needed).

## One-time setup per machine

1. Install 1Password desktop app + sign in (cask in `Brewfile`)
2. Install the BETA `op` CLI (see Brewfile comment block; brew doesn't manage it)
3. Point brew's symlink at the beta:
   ```sh
   ln -sfn /usr/local/bin/op /opt/homebrew/bin/op
   ```
4. 1Password app → **Settings → Developer** → enable **"Integrate with 1Password CLI"**
5. Verify: `op --version` (should show beta), then `op env list` (should list your env)
6. Render Zed: `make render-zed`

## Usage

### Inject vars into a single command (recommended)
```sh
cd ~/dotfiles/secrets
varlock run -- some-command
varlock run -- env | grep -E '^(GITHUB|OPENAI|ANTHROPIC)_'
```

### Export into your current shell
```sh
eval "$(varlock load --env-file ~/dotfiles/secrets/.env.schema --format=shell)"
```

### Auto-load in every interactive shell (recommended)
This repo ships `scripts/load-secrets.zsh`. Source it from `~/.zshrc.local`:
```sh
source ~/code/bdlb77/dotfiles/scripts/load-secrets.zsh
```

The loader **caches resolved secrets in `$TMPDIR/varlock-secrets-$UID`** (mode
0600, owner-only) with a **1-hour TTL**. So:
- One Touch ID prompt **per hour**, not per shell
- New Ghostty splits / tmux panes / `cd`-spawned shells are instant (~50ms)
- Cache cleared on reboot (lives in tmpfs)

Override the TTL (e.g. 4 hours) by exporting `VARLOCK_CACHE_TTL=14400` before
sourcing.

To force a refresh now (e.g. after rotating a secret):
```sh
make secrets-refresh   # or: rm -f "$TMPDIR/varlock-secrets-$UID"
```

To opt out for a given shell:
```sh
SKIP_VARLOCK=1 zsh
```

## Adding a new secret

1. Add the secret to 1Password (any vault)
2. In 1Password, right-click the field → **Copy Secret Reference** (gives you
   `op://vault/item/field`)
3. Add to `.env.schema`:
   ```sh
   # @sensitive
   MY_NEW_TOKEN=op(op://Personal/My Service/api_key)
   ```
4. Commit. The reference is safe to commit — only the resolved value is secret.

## Pre-commit leak protection

A `pre-commit` git hook (`.git/hooks/pre-commit`, NOT tracked since it's
per-clone) runs `varlock scan --staged` before every commit. It:

- Resolves every `@sensitive` value from this schema (Touch ID via 1Password)
- Scans every staged file for plaintext copies of those values
- **Blocks the commit if any match is found**, showing file/line/var

### Setup on a fresh clone of this repo
```sh
cd ~/dotfiles
varlock scan --install-hook
# then replace .git/hooks/pre-commit with the version that uses
# --staged --path secrets/ (see install steps in bootstrap)
```

### Bypass for a single commit (emergencies only)
```sh
git commit --no-verify
```

### Caveat
The hook requires Varlock + `op` to resolve the schema. If 1Password is locked
or `op` isn't signed in, the scan can't compare against real values and may
let leaks through. Keep 1Password unlocked when committing.

## Why Varlock + 1Password (not SOPS, not gitignored .env)

| Approach | Pros | Cons |
|---|---|---|
| Plaintext `.env` (gitignored) | Simple | Lost on new machine; no validation; secrets sprawl |
| SOPS-encrypted in repo | Encrypted at rest | Two systems (SOPS key + 1Password); decrypt-on-use friction |
| **Varlock + 1Password** | Single source of truth; schema/validation; Touch ID; cross-machine sync | Requires desktop app + `op` CLI |

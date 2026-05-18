# `secrets/` — 1Password-backed env vars via Varlock

This directory holds **schema** for environment secrets. Real values live in
1Password and are resolved at runtime by [Varlock](https://varlock.dev/) via
the `@varlock/1password-plugin` (uses the `op` CLI under the hood with
Touch ID / desktop-app authentication).

## Files

- `.env.schema` — committed; declares each env var with type, sensitivity, and
  a `op(op://vault/item/field)` reference.
- `.env.local` — gitignored; per-machine overrides (if needed).

## One-time setup per machine

1. Install 1Password desktop app + sign in (already installed if you ran `bootstrap.sh`)
2. 1Password app → **Settings → Developer** → enable **"Integrate with 1Password CLI"**
3. Verify: `op whoami` should return your account
4. Verify Varlock can resolve: `varlock load --env-file .env.schema`

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

### Auto-load in `.zshrc.local` (optional)
Add to `~/.zshrc.local` (gitignored):
```sh
# Load 1Password-backed secrets at shell start (only if op is signed in)
if command -v varlock >/dev/null 2>&1 && op whoami >/dev/null 2>&1; then
  eval "$(varlock load --env-file ~/dotfiles/secrets/.env.schema --format=shell 2>/dev/null)" || true
fi
```

> Note: shell-startup auto-loading will trigger Touch ID prompts. Most people
> prefer `varlock run --` per-command for sensitive vars.

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

## Why Varlock + 1Password (not SOPS, not gitignored .env)

| Approach | Pros | Cons |
|---|---|---|
| Plaintext `.env` (gitignored) | Simple | Lost on new machine; no validation; secrets sprawl |
| SOPS-encrypted in repo | Encrypted at rest | Two systems (SOPS key + 1Password); decrypt-on-use friction |
| **Varlock + 1Password** | Single source of truth; schema/validation; Touch ID; cross-machine sync | Requires desktop app + `op` CLI |

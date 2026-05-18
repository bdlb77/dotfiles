# opencode/.config/opencode

Global opencode configuration (stowed to `~/.config/opencode/`).

## Files

| File / Dir | Purpose |
|---|---|
| `opencode.jsonc` | Main config (model, permissions, MCP servers) |
| `package.json` | opencode plugins (installed via `bun install`) |
| `agent/` | Custom agents (markdown + YAML frontmatter) |
| `command/` | Slash commands (e.g. `command/review.md` → `/review`) |
| `plugin/` | Local TypeScript/JS plugins using `@opencode-ai/plugin` |

## Setup on a fresh machine

After stowing:
```sh
cd ~/.config/opencode && bun install
```

## Adding a new agent / command / plugin

Just drop the file into the appropriate folder and commit. The stow symlinks
make it immediately live in `~/.config/opencode/`.

## Docs

- Agents:   https://opencode.ai/docs/agents
- Commands: https://opencode.ai/docs/commands
- Plugins:  https://opencode.ai/docs/plugins
- Config:   https://opencode.ai/docs/config

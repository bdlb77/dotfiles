# dotfiles

Personal macOS dev environment, managed with [GNU stow](https://www.gnu.org/software/stow/)
and [mise](https://mise.jdx.dev/).

---

## Philosophy

- **mise** is the single source of truth for languages and most CLI tools.
- **Homebrew** is only used for macOS apps, system libs, and bootstrap utilities.
- **GNU stow** symlinks each "package" folder into `$HOME`.
- Per-machine overrides live in gitignored `~/.zshrc.local` and `~/.gitconfig.local`.

---

## Quick start (new machine)

```sh
git clone https://github.com/bdlb77/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

That single script installs Homebrew, runs `brew bundle`, stows every package
into `$HOME`, installs all `mise` tools, sets up tpm + nvim plugins, and links
VS Code settings.

---

## Stack

| Layer          | Tool                              | Why                                       |
| -------------- | --------------------------------- | ----------------------------------------- |
| Shell          | zsh + [starship](https://starship.rs/) | Fast startup, modern prompt          |
| Tool manager   | [mise](https://mise.jdx.dev/)     | One manager for langs + CLI tools         |
| Package mgr    | [Homebrew](https://brew.sh/)      | macOS apps + bootstrap                    |
| Dotfile mgr    | [GNU stow](https://www.gnu.org/software/stow/) | Simple symlink management   |
| Terminal       | [Ghostty](https://ghostty.org/)   | Fast, GPU, native                         |
| Editors        | Neovim (NvChad), VS Code, Zed     | Situational                               |
| Multiplexer    | [tmux](https://github.com/tmux/tmux) + tpm | Persistent sessions              |
| Git pager      | [delta](https://github.com/dandavison/delta) | Better diffs                    |
| AI assistant   | [opencode](https://opencode.ai/)  | CLI-first coding agent                    |

---

## Repo structure

```
dotfiles/
├── README.md
├── Brewfile               # minimal curated brew packages
├── bootstrap.sh           # one-shot installer
├── .gitignore
│
├── git/                   # → ~/.gitconfig, ~/.gitignore_global
├── zsh/                   # → ~/.zshrc, ~/.zprofile, ~/.aliases
├── ssh/                   # → ~/.ssh/config
├── mise/                  # → ~/.config/mise/config.toml
├── starship/              # → ~/.config/starship.toml
├── ghostty/               # → ~/.config/ghostty/config
├── tmux/                  # → ~/.config/tmux/tmux.conf
├── nvim/                  # → ~/.config/nvim/...    (NvChad)
├── opencode/              # → ~/.config/opencode/...
├── zed/                   # → ~/.config/zed/settings.json
├── vscode/                # symlinked manually (lives outside $HOME)
└── ruby/                  # → ~/.irbrc, ~/.rspec, ~/.gemrc
```

Each top-level folder is a **stow package** — its internal layout mirrors what
gets created in `$HOME` (so `git/.gitconfig` becomes `~/.gitconfig`).

---

## How GNU stow works

Stow creates symlinks from `$HOME` back to files in this repo:

```sh
cd ~/dotfiles
stow git                  # link git/.gitconfig -> ~/.gitconfig
stow -D git               # un-link (delete) the symlinks
stow -R git               # re-stow (after adding/removing files)
stow -n git               # dry-run (preview without changes)
```

`bootstrap.sh` stows every package automatically.

---

## How mise works

mise replaces `pyenv`, `rbenv`, `nvm`, `asdf` — and also installs CLI tools.

```sh
mise install                  # install everything in ~/.config/mise/config.toml
mise use --global node@22     # globally pin node 22
mise use python@3.14          # per-project pin (writes mise.toml in cwd)
mise ls                       # what's installed
mise ls-remote python         # available versions
mise upgrade                  # update all to latest patch
```

Project-level versions live in `mise.toml`, `.tool-versions`, or
`.python-version` / `.nvmrc` in the project root.

---

## Per-package notes

### `git/`
- Default branch: `main`
- Pulls rebase by default, `autoStash` on, `autoSquash` on
- `delta` is the pager
- `git pushf` = `push --force-with-lease`
- `git lg` = pretty graph log
- `git sweep` = delete merged branches
- `git m` = checkout default branch
- Per-machine config via `~/.gitconfig.local` (gitignored)

### `zsh/`
- `~/.zshrc` is intentionally small (~60 lines)
- Plugins are sourced from Homebrew, not a plugin manager
- Per-machine overrides: drop `~/.zshrc.local`

### `mise/`
- Edit `mise/.config/mise/config.toml`, then `mise install`
- Python pinned to `3.14` (bootstrap falls back to `3.13` if unavailable)

### `starship/`
- Theme: customize `starship/.config/starship.toml`
- Browse presets: <https://starship.rs/presets/>

### `ghostty/`
- Theme: `Night Owl` (change with `theme = ...`)
- Splits: `cmd+d` (right), `cmd+shift+d` (down)
- Tabs: `cmd+[` / `cmd+]`

### `tmux/`
- **Prefix:** `C-a`
- Splits: `prefix |` (horizontal), `prefix -` (vertical)
- Pane nav: `prefix h/j/k/l` (vim-style)
- Reload config: `prefix r`
- **Install plugins:** open tmux, then `prefix + I`
- Persistent sessions: `tmux-resurrect` + `tmux-continuum` auto-save

### `nvim/`
- Currently NvChad. To customize: edit files under `nvim/.config/nvim/lua/`
- `:Lazy sync` to update plugins
- `:Mason` to install LSPs/formatters

### `opencode/`
- Global config: `~/.config/opencode/opencode.jsonc`
- Plugins: `~/.config/opencode/package.json` — run `bun install` after stow
- Agents/skills live alongside

### `vscode/`
- Not stowed (VS Code's config lives in `~/Library/Application Support/Code/User/`)
- `bootstrap.sh` symlinks `settings.json` and `keybindings.json` manually

---

## Common workflows

### New Python project
```sh
mkdir foo && cd foo
mise use python@3.14
python -m venv .venv && source .venv/bin/activate
```

### New Node project
```sh
mkdir foo && cd foo
mise use node@lts
pnpm init
```

### Add a global CLI tool
```sh
# Edit mise/.config/mise/config.toml, add the tool
mise install
git add mise && git commit -m "feat(mise): add <tool>"
```

### Add a shell alias
Edit `zsh/.aliases`, then `source ~/.aliases` (or `reload`).

### Add a tmux plugin
Edit `tmux/.config/tmux/tmux.conf`, then in tmux: `prefix + I`.

### Add an opencode agent / skill
Drop into `opencode/.config/opencode/agents/` or `skills/`, `stow -R opencode`,
commit.

---

## Updating

```sh
cd ~/dotfiles
git pull
stow -R <changed-package>   # or stow -R every package
mise install                # pick up new tool versions
brew bundle                 # pick up new brew packages
```

---

## Per-machine overrides

Anything machine-specific (work email, work-only PATH, secrets) goes in
gitignored files:

- `~/.zshrc.local` — sourced at end of `.zshrc`
- `~/.gitconfig.local` — included by `.gitconfig`

Example `~/.gitconfig.local`:
```ini
[user]
    email = bryan@work.com
    signingkey = ABC123
[commit]
    gpgsign = true
```

---

## Troubleshooting

**Stow conflicts** — A non-symlink file exists at the target. `bootstrap.sh`
backs these up automatically, but for manual stowing:
```sh
stow -n <pkg>     # dry-run to preview conflicts
mv ~/.foo ~/.foo.backup
stow <pkg>
```

**mise not activating** — Confirm `eval "$(mise activate zsh)"` is in
`~/.zshrc`, then `exec zsh`.

**Python 3.14 install failed** — Bootstrap auto-falls back to 3.13. Manually:
```sh
mise use --global python@3.13
```

**VS Code settings missing** — Re-run the VS Code link step in `bootstrap.sh`,
or:
```sh
ln -sfn ~/dotfiles/vscode/settings.json \
  "$HOME/Library/Application Support/Code/User/settings.json"
```

**Plugin not loading in zsh** — Check it was installed via brew:
```sh
brew install zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
```

---

## Credits

Originally derived from the [Le Wagon dotfiles](https://github.com/lewagon/dotfiles),
since rewritten end-to-end.

# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

### Fresh machine

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply fabpoeschl
```

You'll be prompted for:
- **Git name** (default: Fabian Poeschl)
- **Git email** (default: fab.poeschl@gmail.com)
- **GPG signing key** (leave empty to skip)

### Already have chezmoi

```bash
chezmoi init fabpoeschl
chezmoi apply
```

## What's Included

### Shell

| File | Target | Description |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | Zsh config — zgenom plugins, mise, p10k, zoxide, fzf |
| `dot_bashrc` | `~/.bashrc` | Bash fallback with sensible defaults |
| `dot_inputrc` | `~/.inputrc` | Readline config (case-insensitive completion, etc.) |
| `dot_zsh/` | `~/.zsh/` | Zsh modules (see below) |

**Zsh modules** (`~/.zsh/`):

| File | What it does |
|---|---|
| `aliases.zsh` | Shell aliases — eza/ls, bat/cat, git, fd, safe rm/cp/mv |
| `config.zsh` | History, options, env vars (`$EDITOR`, `$LESS`), zmv |
| `bindkey.zsh` | Key bindings — word navigation, Ctrl+Enter for autosuggestions |
| `completion.zsh` | Zsh completion styling and menu config |
| `prompt.zsh` | Custom prompt with timestamp, path, and git status (RPROMPT) |
| `functions/*.zsh` | Utility functions (extract, compress, mkd, search, etc.) |

**Zsh plugins** (managed by [zgenom](https://github.com/jandamm/zgenom) via `.chezmoiexternal.toml`):

- zsh-autosuggestions, zsh-syntax-highlighting
- history-substring-search, command-not-found, sudo
- zsh-completions, zsh-256color
- Powerlevel10k prompt theme
- zsh-git-prompt, fancy Ctrl+Z

### Git

| File | Target | Description |
|---|---|---|
| `dot_gitconfig.tmpl` | `~/.gitconfig` | **Templated** — name, email, signing key filled from chezmoi config |
| `dot_gitignore` | `~/.gitignore` | Global gitignore patterns |
| `dot_git_template/` | `~/.git_template/` | Git hooks: auto-run ctags on checkout, commit, merge, rewrite |

### Vim / Neovim

| File | Target | Description |
|---|---|---|
| `dot_vimrc` | `~/.vimrc` | Vim config — vim-plug, CoC, ALE, fzf, NERDTree, airline, gruvbox |
| `dot_vim/` | `~/.vim/` | vim-plug autoload, plugins.vim |
| `dot_config/nvim/` | `~/.config/nvim/` | Neovim — sources vimrc + treesitter config |

**Key vim bindings**: `,` is leader. `jk` = escape. `Ctrl+P` = fzf. `space` = toggle fold. `K` = grep word under cursor.

### Tmux

| File | Target | Description |
|---|---|---|
| `dot_tmux.conf` | `~/.tmux.conf` | `C-a` prefix, vim-style pane navigation, `-`/`_` splits |

### Other

| File | Target | Description |
|---|---|---|
| `dot_config/dot_solargraph.yml` | `~/.config/.solargraph.yml` | Ruby Solargraph LSP config |

## How chezmoi Manages Files

chezmoi uses filename prefixes in the source directory to control how files are placed:

| Prefix | Meaning | Example |
|---|---|---|
| `dot_` | Becomes `.` in target | `dot_zshrc` → `~/.zshrc` |
| `executable_` | File gets `chmod +x` | `executable_ctags` → `~/.git_template/ctags` |
| `.tmpl` suffix | Rendered as Go template | `dot_gitconfig.tmpl` → `~/.gitconfig` |
| `run_once_` | Script runs once on first apply | `run_once_setup-plugins.sh` |
| `run_onchange_` | Script re-runs when contents change | `run_onchange_install-packages.sh.tmpl` |

**Special files:**

| File | Purpose |
|---|---|
| `.chezmoi.toml.tmpl` | Config template — prompts for name/email/GPG key on `chezmoi init` |
| `.chezmoiexternal.toml` | External git repos (zgenom, bash-sensible) cloned automatically |
| `.chezmoiignore` | Files in this repo that chezmoi should NOT deploy (Brewfile, tests, docs) |

## Making Changes

### Edit a dotfile

```bash
# Option 1: edit via chezmoi (opens the source file, applies on save)
chezmoi edit ~/.zshrc

# Option 2: edit the source directly, then apply
vim ~/.local/share/chezmoi/dot_zshrc
chezmoi apply
```

### Add a new dotfile

```bash
# Tell chezmoi to manage an existing file
chezmoi add ~/.some-config

# This copies it into the source directory with the right prefixes
# Then commit the new file
cd ~/.local/share/chezmoi
git add -A && git commit -m "Add some-config"
git push
```

### Add a new zsh alias or function

- **Alias**: edit `dot_zsh/aliases.zsh`
- **Function**: create a new file in `dot_zsh/functions/`, e.g. `dot_zsh/functions/my-func.zsh`

Then `chezmoi apply` and `source ~/.zshrc` (or alias `szshrc`).

### Change git name/email

```bash
chezmoi init   # re-prompts for name, email, signing key
chezmoi apply  # regenerates ~/.gitconfig from template
```

Or edit `~/.config/chezmoi/chezmoi.toml` directly:

```toml
[data]
  name = "New Name"
  email = "new@example.com"
  signingkey = ""
```

### Add a new package

- **macOS**: add to `Brewfile`, then `brew bundle install`
- **Linux**: add to `packages.txt`, then `chezmoi apply` (triggers the install script)

### Add an external git dependency

Edit `.chezmoiexternal.toml`:

```toml
[".path/in/home"]
  type = "git-repo"
  url = "https://github.com/user/repo.git"
  clone.args = ["--depth", "1"]
  pull.args = ["--depth", "1"]
```

### See what chezmoi would change before applying

```bash
chezmoi diff          # show diff of what would change
chezmoi apply -n -v   # dry run with verbose output
```

## Run Scripts

These run automatically during `chezmoi apply`:

| Script | Trigger | What it does |
|---|---|---|
| `run_onchange_install-packages.sh.tmpl` | Brewfile or packages.txt changes | Installs system packages (brew on macOS, apt on Linux) + mise |
| `run_once_setup-mise.sh` | First apply only | Installs Ruby, Node (LTS), Python via mise |
| `run_once_setup-plugins.sh` | First apply only | Runs `vim +PlugInstall` |

## Testing

Docker containers test that `chezmoi apply` works correctly on clean and existing systems:

```bash
# Run all tests (requires Docker)
./test/run-tests.sh

# Test only fresh install
./test/run-tests.sh ubuntu

# Test applying over existing dotfiles
./test/run-tests.sh ubuntu-existing

# Just build the images without running tests
./test/run-tests.sh --build-only
```

## Directory Structure

```
.
├── .chezmoi.toml.tmpl              # chezmoi config (prompts for git identity)
├── .chezmoiexternal.toml           # external git repos (zgenom, bash-sensible)
├── .chezmoiignore                  # files to exclude from deployment
├── Brewfile                        # macOS packages (Homebrew)
├── packages.txt                    # Linux packages (apt)
├── run_once_setup-mise.sh          # one-time: install language runtimes
├── run_once_setup-plugins.sh       # one-time: install vim plugins
├── run_onchange_install-packages.sh.tmpl  # re-runs when packages change
├── dot_zshrc                       # → ~/.zshrc
├── dot_bashrc                      # → ~/.bashrc
├── dot_inputrc                     # → ~/.inputrc
├── dot_tmux.conf                   # → ~/.tmux.conf
├── dot_vimrc                       # → ~/.vimrc
├── dot_gitconfig.tmpl              # → ~/.gitconfig (templated)
├── dot_gitignore                   # → ~/.gitignore
├── dot_zsh/                        # → ~/.zsh/
│   ├── aliases.zsh
│   ├── bindkey.zsh
│   ├── completion.zsh
│   ├── config.zsh
│   ├── prompt.zsh
│   └── functions/
│       ├── compress.zsh
│       ├── extract.zsh
│       ├── mkd.zsh
│       ├── search.zsh
│       └── ...
├── dot_vim/                        # → ~/.vim/
│   ├── autoload/plug.vim
│   └── plugins.vim
├── dot_config/
│   ├── nvim/                       # → ~/.config/nvim/
│   └── dot_solargraph.yml
├── dot_git_template/               # → ~/.git_template/
│   ├── executable_ctags
│   ├── executable_post-checkout
│   ├── executable_post-commit
│   ├── executable_post-merge
│   └── executable_post-rewrite
└── test/
    ├── run-tests.sh                # automated container tests
    ├── Dockerfile.ubuntu           # fresh install test
    └── Dockerfile.ubuntu-existing  # existing dotfiles test
```

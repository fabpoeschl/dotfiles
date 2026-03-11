# Dotfiles Analysis & Improvement Suggestions

## 1. Abandoned / Dead Tools to Replace

### zgen (Zsh Plugin Manager) - ABANDONED
**Current:** `tarjoilija/zgen` (~1.5k stars, no commits since ~2019)

| Alternative | Stars | Status | Migration Effort |
|---|---|---|---|
| **zgenom** | ~420 | Active, drop-in replacement for zgen | Minimal - backwards compatible |
| **zinit** | ~4.5k | Community-maintained (zdharma-continuum) | Medium - different syntax |
| **antidote** | ~1.5k | Active (v1.10.2, Jan 2026) | Medium - clean plugin list file |

**Recommendation:** Switch to **zgenom** for zero-effort migration (your existing zgen config works as-is), or **antidote** for a cleaner modern approach.

---

### Atom Editor - DISCONTINUED
**Current:** `install-packages-linux.sh` installs Atom via PPA

Atom was sunset by GitHub on **December 15, 2022**. All repos are archived.

**Recommendation:** Remove Atom from install scripts. VS Code is already in your macOS script. Consider also adding **Zed** (Rust-based, by a former Atom dev) as a fast alternative.

---

### KeePassX - DISCONTINUED
**Current:** `keepassx` in both install scripts

KeePassX was discontinued in 2021 (last release: 2016). **KeePassXC** is the actively maintained community fork with browser integration, YubiKey support, and modern encryption.

**Recommendation:** Replace `keepassx` with `keepassxc` in all install scripts.

---

### Vundle.vim Submodule - DEAD WEIGHT
**Current:** `vim/bundle/Vundle.vim` is a git submodule, but `vim-plug` is the actual plugin manager used in `vimrc`.

**Recommendation:** Remove the Vundle submodule (`git rm vim/bundle/Vundle.vim`). It's unused config drift.

---

## 2. Better Alternatives to Current Tools

### ag (The Silver Searcher) -> ripgrep
**Current:** `ag.vim` plugin in Vim config

| Tool | Stars | Speed | Status |
|---|---|---|---|
| ag (silver_searcher) | ~26k | Fast | Maintenance mode |
| **ripgrep (rg)** | **~60k** | **Fastest** | **Actively maintained** |

ripgrep is 2-5x faster than ag in benchmarks, has better Unicode support, and respects `.gitignore` by default. FZF already supports ripgrep natively via `FZF_DEFAULT_COMMAND`.

**Recommendation:** Install `ripgrep`, replace `ag.vim` with ripgrep integration. Your FZF setup will benefit immediately.

---

### ctags -> universal-ctags
**Current:** Uses `ctags` in git hooks (`git_template/ctags`)

Exuberant Ctags hasn't been updated since 2009. **Universal Ctags** is the actively maintained fork with support for modern languages (TypeScript, Rust, Go, etc.).

**Recommendation:** Install `universal-ctags` (`brew install universal-ctags`). It's a drop-in replacement.

---

### Neovim Plugin Modernization (if investing in Neovim)

| Current | Stars | Alternative | Stars | Benefit |
|---|---|---|---|---|
| NERDTree | ~20k | nvim-tree.lua | ~8.4k | Native Lua, faster, async |
| NERDTree | ~20k | neo-tree.nvim | ~5.3k | Most feature-rich, floating windows |
| vim-airline | ~18k | lualine.nvim | ~7.8k | 3x faster startup (25ms vs 80ms) |
| coc.nvim | ~25k | nvim-lspconfig | ~13k | Native LSP, no Node.js dependency |
| ALE | ~13k | none-ls / conform.nvim | ~4k | Better Neovim integration |

**Note:** coc.nvim and vim-airline still work great and have more stars due to longer history. Only migrate these if you're going all-in on a Lua-based Neovim config. NERDTree is perfectly fine for Vim compatibility.

---

## 3. Modern CLI Tools to Add

These are widely adopted, well-maintained tools you're currently missing:

| Tool | Stars | Replaces | What It Does |
|---|---|---|---|
| **bat** | ~51k | `cat` | Syntax highlighting, line numbers, git integration |
| **eza** | ~15k | `ls` | Modern ls with colors, icons, git status, tree view |
| **fd** | ~35k | `find` | Simpler syntax, faster, respects .gitignore |
| **delta** | ~25k | `diff` | Beautiful git diffs with syntax highlighting |
| **zoxide** | ~32k | `cd` | Smarter cd that learns your habits (like autojump/z) |
| **lazygit** | ~54k | git CLI | Terminal UI for git - staging, rebasing, conflicts |
| **tldr** | ~52k | `man` | Simplified, practical man pages |
| **btop** | ~22k | `top/htop` | Beautiful resource monitor |

### Suggested aliases to add:
```bash
# Modern replacements (add to aliases.zsh)
alias cat="bat"
alias ls="eza"
alias ll="eza -la --icons --git"
alias tree="eza --tree"
alias find="fd"

# Git delta - configure in gitconfig instead:
# [core]
#   pager = delta
# [interactive]
#   diffFilter = delta --color-only

# Zoxide - add to zshrc:
# eval "$(zoxide init zsh)"
# Then use: z <partial-path> instead of cd
```

---

## 4. Security & Maintenance Issues

### HIGH: Node.js 14 Hardcoded in PATH
```bash
# Current in zshrc:
export PATH="/opt/homebrew/Cellar/node@14/..."
```
Node 14 reached EOL on **April 30, 2023** with known CVEs. Remove the hardcoded path and rely on NVM's standard mechanism with `.nvmrc` files per project.

### MEDIUM: rbenv AND rvm Both Configured
Your `zshrc` initializes rbenv, while `install-packages-macos.sh` installs RVM. These conflict with each other (both manipulate PATH and gem commands). **Pick one and fully remove the other.** rbenv is the more modern, lighter choice.

### MEDIUM: MySQL 5.7 EOL
`mysql-server-5.7` reached EOL in **October 2023**. Update to MySQL 8.x or switch to MariaDB.

### MEDIUM: MongoDB Package Name Invalid
The `mongodb` formula was removed from Homebrew. Use:
- `brew tap mongodb/brew && brew install mongodb-community` (full server)
- `brew install mongosh` (shell only)

---

## 5. Structural Improvements

### Use a Brewfile
Convert individual `brew install` commands in `install-packages-macos.sh` to a declarative `Brewfile`:
```ruby
# Brewfile
tap "mongodb/brew"

brew "coreutils"
brew "curl"
brew "gcc"
brew "python3"
brew "ripgrep"
brew "bat"
brew "eza"
brew "fd"
brew "zoxide"
brew "lazygit"
brew "delta"
brew "universal-ctags"
brew "tmux"
brew "openvpn"
brew "mongosh"

cask "keepassxc"
cask "visual-studio-code"
cask "postman"
cask "slack"
cask "docker"
```
Then install with: `brew bundle install`

### Fix create-symlinks.sh
The script runs `vim +PluginInstall +qall` (Vundle command) but you use vim-plug. Change to:
```bash
vim +PlugInstall +qall
```

### Remove Stale Git Submodules
- `vim/bundle/Vundle.vim` - unused (you use vim-plug)
- `zsh/zgen` - if migrating to zgenom/antidote

### Consider Using a Dotfiles Manager
Tools like **GNU Stow**, **chezmoi** (~13k stars), or **yadm** (~5k stars) handle symlinking more robustly than a custom script. Chezmoi is the most popular and supports templates, secrets management, and multi-machine configs.

---

## Summary: Priority Actions

1. **Replace `keepassx` with `keepassxc`** - dead project
2. **Remove Atom editor** from install scripts - discontinued
3. **Remove hardcoded Node 14 PATH** - security risk (EOL with CVEs)
4. **Pick rbenv OR rvm**, remove the other - they conflict
5. **Switch zgen to zgenom** - zero-effort, zgen is abandoned
6. **Install ripgrep** - replaces ag, much faster, better maintained
7. **Install bat, eza, fd, zoxide, delta** - modern CLI essentials
8. **Remove Vundle submodule** - unused dead weight
9. **Fix `PluginInstall` -> `PlugInstall`** in symlink script
10. **Update MySQL and MongoDB** package references

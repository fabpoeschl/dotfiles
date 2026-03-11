#!/bin/bash
# Safe update script for existing systems.
# Installs missing tools, updates existing ones, and refreshes dotfile symlinks.
# Can be re-run at any time without breaking your setup.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

# ============
# Colors
# ============
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[skip]${NC} $1"; }
error() { echo -e "${RED}[fail]${NC} $1"; }

# ============
# Package installation helpers
# ============
install_if_missing_brew() {
  local name=$1
  local pkg=${2:-$1}
  if brew list "$pkg" &>/dev/null; then
    warn "$name already installed"
  else
    brew install "$pkg" && info "$name installed" || error "$name failed to install"
  fi
}

install_cask_if_missing() {
  local name=$1
  local pkg=${2:-$1}
  if brew list --cask "$pkg" &>/dev/null; then
    warn "$name (cask) already installed"
  else
    brew install --cask "$pkg" && info "$name installed" || error "$name failed to install"
  fi
}

install_if_missing_apt() {
  local name=$1
  local pkg=${2:-$1}
  if dpkg -s "$pkg" &>/dev/null; then
    warn "$name already installed"
  else
    sudo apt-get -y install "$pkg" && info "$name installed" || error "$name failed to install"
  fi
}

# ============
# Install/update packages
# ============
install_packages() {
  echo ""
  echo "=== Installing packages ==="

  if [[ "$OS" == "Darwin" ]]; then
    brew update

    # core
    install_if_missing_brew coreutils
    install_if_missing_brew zsh-syntax-highlighting
    install_if_missing_brew tmux
    install_if_missing_brew curl
    install_if_missing_brew gcc

    # version manager
    install_if_missing_brew mise

    # modern CLI tools
    install_if_missing_brew ripgrep
    install_if_missing_brew fd
    install_if_missing_brew bat
    install_if_missing_brew eza
    install_if_missing_brew delta git-delta
    install_if_missing_brew fzf
    install_if_missing_brew zoxide
    install_if_missing_brew lazygit

    # casks
    install_cask_if_missing docker
    install_if_missing_brew docker-compose
    install_cask_if_missing postman
    install_cask_if_missing visual-studio-code
    install_cask_if_missing slack

  elif [[ "$OS" == "Linux" ]]; then
    sudo apt-get update

    # core
    install_if_missing_apt zsh
    install_if_missing_apt zsh-syntax-highlighting
    install_if_missing_apt tmux
    install_if_missing_apt vim
    install_if_missing_apt curl
    install_if_missing_apt gcc

    # version manager
    if ! command -v mise &>/dev/null; then
      curl https://mise.run | sh && info "mise installed" || error "mise failed to install"
    else
      warn "mise already installed"
    fi

    # modern CLI tools
    install_if_missing_apt ripgrep
    install_if_missing_apt fd fd-find
    install_if_missing_apt bat
    install_if_missing_apt eza
    install_if_missing_apt delta git-delta
    install_if_missing_apt fzf
    install_if_missing_apt zoxide
    install_if_missing_apt firefox

  else
    error "Unknown OS: $OS"
    exit 1
  fi
}

# ============
# Symlinks (safe - backs up existing non-link files, skips existing links)
# ============
setup_symlinks() {
  echo ""
  echo "=== Setting up symlinks ==="

  link_dotfile() {
    local src=$1
    local dest=$2

    if [ -L "$dest" ]; then
      local current_target
      current_target="$(readlink "$dest")"
      if [ "$current_target" = "$src" ]; then
        warn "$dest already linked"
        return
      fi
      # Link points elsewhere - replace it
      rm "$dest"
    elif [ -e "$dest" ]; then
      # Real file/dir exists - back it up
      local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
      echo -e "${YELLOW}[backup]${NC} $dest -> $backup"
      mv "$dest" "$backup"
    fi

    ln -s "$src" "$dest"
    info "$dest -> $src"
  }

  link_dotfile "$DOTFILES_DIR/bash"        "$HOME/.bash"
  link_dotfile "$DOTFILES_DIR/bashrc"      "$HOME/.bashrc"
  link_dotfile "$DOTFILES_DIR/config"      "$HOME/.config"
  link_dotfile "$DOTFILES_DIR/gitconfig"   "$HOME/.gitconfig"
  link_dotfile "$DOTFILES_DIR/gitignore"   "$HOME/.gitignore"
  link_dotfile "$DOTFILES_DIR/git_template" "$HOME/.git_template"
  link_dotfile "$DOTFILES_DIR/tmux.conf"   "$HOME/.tmux.conf"
  link_dotfile "$DOTFILES_DIR/vim"         "$HOME/.vim"
  link_dotfile "$DOTFILES_DIR/vimrc"       "$HOME/.vimrc"
  link_dotfile "$DOTFILES_DIR/zsh"         "$HOME/.zsh"
  link_dotfile "$DOTFILES_DIR/zshrc"       "$HOME/.zshrc"
}

# ============
# Shell plugins & tools
# ============
setup_plugins() {
  echo ""
  echo "=== Setting up plugins ==="

  # zgenom
  if [ -d "$HOME/.zsh/zgenom" ]; then
    warn "zgenom already cloned"
  else
    git clone https://github.com/jandamm/zgenom.git "$HOME/.zsh/zgenom"
    info "zgenom cloned"
  fi

  # Clear stale zgen cache if migrating
  if [ -d "$HOME/.zsh/zgen" ] && [ -d "$HOME/.zsh/zgenom" ]; then
    echo -e "${YELLOW}[migrate]${NC} Old zgen directory found. You can remove it: rm -rf ~/.zsh/zgen"
  fi

  # vim plugins
  if command -v vim &>/dev/null; then
    vim +PlugInstall +PlugClean! +qall
    info "vim plugins updated"
  fi
}

# ============
# mise runtimes
# ============
setup_mise() {
  echo ""
  echo "=== Setting up mise runtimes ==="

  if ! command -v mise &>/dev/null; then
    warn "mise not found in PATH - skipping runtime setup"
    echo "  Run 'exec zsh' first, then re-run this script"
    return
  fi

  # Install global runtimes if not already present
  for tool_spec in "ruby@latest" "node@lts" "python@latest"; do
    local tool="${tool_spec%%@*}"
    if mise ls "$tool" 2>/dev/null | grep -q "$tool"; then
      warn "$tool already managed by mise"
    else
      mise use --global "$tool_spec"
      info "$tool_spec installed via mise"
    fi
  done
}

# ============
# Cleanup old tools (advisory only)
# ============
check_old_tools() {
  echo ""
  echo "=== Checking for old tools to clean up ==="

  local found_old=false

  for cmd in rbenv nvm pyenv; do
    if command -v "$cmd" &>/dev/null; then
      echo -e "${YELLOW}[old]${NC} $cmd is still installed (replaced by mise)"
      found_old=true
    fi
  done

  if [ -d "$HOME/.zsh/zgen" ] && [ -d "$HOME/.zsh/zgenom" ]; then
    echo -e "${YELLOW}[old]${NC} ~/.zsh/zgen still exists (replaced by zgenom)"
    found_old=true
  fi

  if [ -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    echo -e "${YELLOW}[old]${NC} ~/.vim/bundle/Vundle.vim still exists (replaced by vim-plug)"
    found_old=true
  fi

  if ! $found_old; then
    info "No old tools found"
  else
    echo ""
    echo "To remove old tools:"
    echo "  brew uninstall rbenv nvm pyenv  # macOS"
    echo "  rm -rf ~/.zsh/zgen ~/.vim/bundle/Vundle.vim ~/.nvm ~/.rbenv ~/.pyenv"
  fi
}

# ============
# Main
# ============
echo "Dotfiles update - $(date)"
echo "OS: $OS"
echo "Dotfiles: $DOTFILES_DIR"

install_packages
setup_symlinks
setup_plugins
setup_mise
check_old_tools

echo ""
echo "=== Done! ==="
echo "Run 'exec zsh' to reload your shell."

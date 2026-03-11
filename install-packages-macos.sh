#!/bin/bash
echo "Installing packages for MacOS"
set +e
log_file=~/install_progress_log.txt

install_brew() {
  local name=$1
  local pkg=${2:-$1}
  local cmd=${3:-$1}
  brew install "$pkg"
  if type -p "$cmd" > /dev/null; then
    echo "$name installed" >> "$log_file"
  else
    echo "Failed to install $name!" >> "$log_file"
  fi
}

install_cask() {
  local name=$1
  local pkg=${2:-$1}
  brew install --cask "$pkg"
  echo "$name (cask) installed" >> "$log_file"
}

# latest packages
brew update
brew upgrade

brew install coreutils

# shell
brew install zsh-syntax-highlighting

# core tools
install_brew tmux
install_brew curl
install_brew gcc

# mise - polyglot version manager (replaces rbenv, nvm, pyenv)
install_brew mise

# modern CLI replacements
install_brew ripgrep ripgrep rg
install_brew fd
install_brew bat
install_brew eza
install_brew delta git-delta delta
install_brew fzf
install_brew zoxide
install_brew lazygit

# containers
install_cask docker
brew install docker-compose

# dev tools
install_cask postman
install_cask visual-studio-code

# databases
install_brew openvpn

# apps
install_cask slack


# =================
# summary
# =================
echo -e "\n==== Summary ====\n"
cat "$log_file"
echo
rm "$log_file"

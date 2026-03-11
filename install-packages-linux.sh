#!/bin/bash
set +e
log_file=~/install_progress_log.txt

install_apt() {
  local name=$1
  local pkg=${2:-$1}
  local cmd=${3:-$1}
  sudo apt-get -y install "$pkg"
  if type -p "$cmd" > /dev/null; then
    echo "$name installed" >> "$log_file"
  else
    echo "Failed to install $name!" >> "$log_file"
  fi
}

# latest packages
sudo apt-get update
sudo apt-get -y upgrade

# core tools
install_apt zsh
sudo apt-get -y install zsh-syntax-highlighting
install_apt tmux
install_apt vim
install_apt curl
install_apt gcc

# mise - polyglot version manager (replaces rbenv, nvm, pyenv)
# installs ruby, node, python etc. via: mise use --global ruby@latest node@lts python@latest
curl https://mise.run | sh

# modern CLI replacements
install_apt ripgrep ripgrep rg
install_apt fd fd-find fdfind
install_apt bat bat cat  # binary may be 'batcat' on Debian/Ubuntu
install_apt eza
install_apt delta git-delta delta
install_apt fzf
install_apt zoxide

# optional tools
install_apt openvpn
install_apt texmaker

# chrome
if ! type -p google-chrome > /dev/null; then
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get update
  install_apt chrome google-chrome-stable google-chrome
fi

# firefox
install_apt firefox

# =================
# summary
# =================
echo -e "\n==== Summary ====\n"
cat "$log_file"
echo
rm "$log_file"

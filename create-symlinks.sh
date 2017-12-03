#!/bin/bash
set +e

# Create the symlinks in $HOME
function link_if_missing() {
  SRC=$1
  DEST=$2

  if ! [ -L $DEST ]; then
    ln -ivs $SRC $DEST
  else
    echo "Skipping, link already exists: $DEST"
  fi
}

# ============
# delete existing dotfiles and folders
# ============
sudo rm -rf ~/.bash > /dev/null 2>&1
sudo rm -rf ~/.bashrc > /dev/null 2>&1
sudo rm -rf ~/.gitconfig > /dev/null 2>&1
sudo rm -rf ~/.gitignore > /dev/null 2>&1
sudo rm -rf ~/.tmux > /dev/null 2>&1
sudo rm -rf ~/.tmux.conf > /dev/null 2>&1
sudo rm -rf ~/.vim > /dev/null 2>&1
sudo rm -rf ~/.vimrc > /dev/null 2>&1
sudo rm -rf ~/.zsh > /dev/null 2>&1
sudo rm -rf ~/.zshrc > /dev/null 2>&1

# ============
# create symlinks in home folder
# ============
link_if_missing $PWD/bash $HOME/.bash
link_if_missing $PWD/bashrc $HOME/.bashrc
link_if_missing $PWD/gitconfig $HOME/.gitconfig
link_if_missing $PWD/gitignore $HOME/.gitignore
#link_if_missing $PWD/tmux.conf $HOME/.tmux.conf
link_if_missing $PWD/vim $HOME/.vim
link_if_missing $PWD/vimrc ~/.vimrc
link_if_missing $PWD/zsh ~/.zsh
link_if_missing $PWD/zshrc ~/.zshrc

# ============
# load submodules
# ============
function clone_if_missing() {
  URL=$1
  DEST=$2

  if ! [ -d $DEST ]; then
    git clone $URL $DEST
  else
    "Skipping, already loaded: $DEST"
  fi
}

clone_if_missing https://github.com/mrzool/bash-sensible "${HOME}/.bash/bash-sensible"
clone_if_missing  https://github.com/tarjoilija/zgen.git "${HOME}/.zsh/zgen"
clone_if_missing  https://github.com/VundleVim/Vundle.vim.git "${HOME}/.vim/bundle/Vundle.vim"
vim +PluginInstall +qall

chsh -s `which zsh`
sudo chsh -s `which zsh`

#if [ -n "$(find $dotfiles_dir/custom-configs -name tmux.conf)" ]; then
#	ln -s $dotfiles_dir/custom-configs/**/tmux.conf ~/.tmux.conf
#else
#	ln -s $dotfiles_dir/linux-tmux/tmux.conf ~/.tmux.conf
#fi


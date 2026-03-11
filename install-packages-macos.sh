#!/bin/bash
echo "Installing packages for macOS"
set +e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

brew update
brew upgrade
brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock

echo ""
echo "Installed packages from Brewfile."
echo "Run 'brew bundle check --file=$DOTFILES_DIR/Brewfile' to verify."

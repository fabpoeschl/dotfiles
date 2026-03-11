#!/bin/bash
echo "Installing packages for Linux"
set +e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES_FILE="$DOTFILES_DIR/packages.txt"

sudo apt-get update
sudo apt-get -y upgrade

# Install all packages from packages.txt
while IFS= read -r line; do
  # Skip comments and blank lines
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
  pkg="$(echo "$line" | xargs)"  # trim whitespace
  if dpkg -s "$pkg" &>/dev/null; then
    echo "[skip] $pkg already installed"
  else
    sudo apt-get -y install "$pkg" && echo "[ok] $pkg installed" || echo "[fail] $pkg"
  fi
done < "$PACKAGES_FILE"

# mise (not in apt, installed via curl)
if ! command -v mise &>/dev/null; then
  echo "Installing mise..."
  curl https://mise.run | sh && echo "[ok] mise installed" || echo "[fail] mise"
else
  echo "[skip] mise already installed"
fi

# Chrome (requires adding repo)
if ! command -v google-chrome &>/dev/null; then
  echo "Installing Google Chrome..."
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get update
  sudo apt-get -y install google-chrome-stable && echo "[ok] chrome installed" || echo "[fail] chrome"
else
  echo "[skip] chrome already installed"
fi

echo ""
echo "Done. Packages not in apt (mise) were installed separately."

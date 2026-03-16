#!/bin/bash
# Install vim plugins via vim-plug (runs once on first apply).
set -euo pipefail

if command -v vim &>/dev/null; then
  echo "=== Installing vim plugins ==="
  vim --not-a-term +PlugInstall +PlugClean! +qall
  echo "[ok] vim plugins installed"
fi

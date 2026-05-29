#!/bin/bash
# Install global npm packages (runs once on first apply).
# Depends on: run_once_setup-mise.sh (node must be available via mise)
set -euo pipefail

# mise shims may not be in PATH in non-interactive shells; resolve npm explicitly
if command -v npm &>/dev/null; then
  NPM="npm"
elif command -v mise &>/dev/null && mise exec node -- npm --version &>/dev/null 2>&1; then
  NPM="mise exec node -- npm"
else
  echo "[skip] npm not found — run 'exec zsh' first, then 'chezmoi apply'"
  exit 0
fi

echo "=== Setting up global npm packages ==="

npm_global_install() {
  local pkg="$1"
  if $NPM list -g --depth=0 "$pkg" &>/dev/null; then
    echo "[skip] $pkg already installed"
  else
    $NPM install -g "$pkg" && echo "[ok] $pkg installed"
  fi
}

npm_global_install "@earendil-works/pi-coding-agent"

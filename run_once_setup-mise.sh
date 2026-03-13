#!/bin/bash
# Install global mise runtimes (runs once on first apply).
set -euo pipefail

if ! command -v mise &>/dev/null; then
  echo "[skip] mise not found in PATH — run 'exec zsh' first, then 'chezmoi apply'"
  exit 0
fi

echo "=== Setting up mise runtimes ==="

for tool_spec in "ruby@latest" "node@lts" "python@latest"; do
  tool="${tool_spec%%@*}"
  if mise ls "$tool" 2>/dev/null | grep -q "$tool"; then
    echo "[skip] $tool already managed by mise"
  else
    mise use --global "$tool_spec"
    echo "[ok] $tool_spec installed via mise"
  fi
done

#!/bin/bash
# Install Ollama, Tabby, and pull the default code completion model.
# Runs once on first chezmoi apply.
set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[skip]${NC} $1"; }
error() { echo -e "${RED}[fail]${NC} $1"; }

OS="$(uname -s)"

echo "=== Setting up Tabby + Ollama ==="

# --- Ollama ---
if ! command -v ollama &>/dev/null; then
  if [[ "$OS" == "Darwin" ]]; then
    warn "ollama should be installed via Brewfile; run 'brew bundle' first"
  else
    echo "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh \
      && info "ollama installed" \
      || error "ollama install failed"
  fi
else
  warn "ollama already installed"
fi

# --- Tabby ---
if ! command -v tabby &>/dev/null; then
  if [[ "$OS" == "Darwin" ]]; then
    warn "tabby should be installed via Brewfile; run 'brew bundle' first"
  else
    echo "Installing Tabby..."
    tmpfile="$(mktemp)"
    TABBY_VERSION="$(curl -fsSL https://api.github.com/repos/TabbyML/tabby/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')"
    if [ -n "$TABBY_VERSION" ]; then
      curl -fsSL "https://github.com/TabbyML/tabby/releases/download/${TABBY_VERSION}/tabby_$(uname -m)-unknown-linux-gnu" -o "$tmpfile" \
        && chmod +x "$tmpfile" \
        && sudo mv "$tmpfile" /usr/local/bin/tabby \
        && info "tabby ${TABBY_VERSION} installed" \
        || error "tabby install failed"
    else
      error "could not determine latest tabby version"
    fi
    rm -f "$tmpfile"
  fi
else
  warn "tabby already installed"
fi

# --- Pull Ollama model ---
if command -v ollama &>/dev/null; then
  MODEL="qwen2.5-coder:7b"
  if ollama list 2>/dev/null | grep -q "$MODEL"; then
    warn "ollama model $MODEL already pulled"
  else
    echo "Pulling Ollama model: $MODEL (this may take a while)..."
    # Start ollama server in background if not already running
    if ! curl -sf http://localhost:11434/api/tags &>/dev/null; then
      ollama serve &>/dev/null &
      OLLAMA_PID=$!
      sleep 2
    fi
    ollama pull "$MODEL" \
      && info "ollama model $MODEL pulled" \
      || error "ollama pull $MODEL failed"
    # Stop background ollama if we started it
    if [ -n "${OLLAMA_PID:-}" ]; then
      kill "$OLLAMA_PID" 2>/dev/null || true
    fi
  fi
fi

# --- Install vim-tabby plugin ---
if command -v vim &>/dev/null; then
  echo "Installing vim-tabby plugin..."
  vim --not-a-term +PlugInstall +qall 2>/dev/null \
    && info "vim-tabby plugin installed" \
    || warn "vim plugin install had warnings (may need manual :PlugInstall)"
fi

# --- Enable systemd user services (Linux only) ---
if [[ "$OS" == "Linux" ]]; then
  if command -v systemctl &>/dev/null; then
    systemctl --user daemon-reload

    if ! systemctl --user is-enabled ollama.service &>/dev/null; then
      systemctl --user enable --now ollama.service \
        && info "ollama.service enabled and started" \
        || error "failed to enable ollama.service"
    else
      warn "ollama.service already enabled"
      systemctl --user restart ollama.service
    fi

    if ! systemctl --user is-enabled tabby.service &>/dev/null; then
      systemctl --user enable --now tabby.service \
        && info "tabby.service enabled and started" \
        || error "failed to enable tabby.service"
    else
      warn "tabby.service already enabled"
      systemctl --user restart tabby.service
    fi

    # Allow user services to run without an active login session
    if command -v loginctl &>/dev/null; then
      loginctl enable-linger "$(whoami)" 2>/dev/null \
        && info "loginctl linger enabled" \
        || warn "loginctl linger failed (services will stop on logout)"
    fi
  else
    warn "systemctl not found; skipping service setup"
  fi
fi

echo ""
echo "=== Setup complete ==="
echo "Ollama and Tabby are running as systemd user services."
echo "Open neovim and start typing!"
echo ""
echo "Useful commands:"
echo "  systemctl --user status ollama"
echo "  systemctl --user status tabby"
echo "  journalctl --user -u ollama -f"
echo "  journalctl --user -u tabby -f"

#!/bin/bash
# Run chezmoi dotfiles tests in Docker containers.
# Usage: ./test/run-tests.sh [--build-only] [ubuntu|ubuntu-existing]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
BUILD_ONLY=false

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }

# Parse args
TARGETS=()
for arg in "$@"; do
  case "$arg" in
    --build-only) BUILD_ONLY=true ;;
    *) TARGETS+=("$arg") ;;
  esac
done
[[ ${#TARGETS[@]} -eq 0 ]] && TARGETS=(ubuntu ubuntu-existing)

run_test() {
  local name="$1"
  local dockerfile="test/Dockerfile.${name}"
  local image="dotfiles-test-${name}"

  echo ""
  echo -e "${YELLOW}=== Testing: ${name} ===${NC}"

  # Build
  echo "Building ${image}..."
  if ! docker build -f "${dockerfile}" -t "${image}" "${REPO_ROOT}"; then
    fail "Docker build failed for ${name}"
    return
  fi
  pass "Docker build succeeded"

  if $BUILD_ONLY; then return; fi

  # Apply chezmoi and validate in a single container
  echo "Running chezmoi apply and validating..."
  local test_output
  if test_output=$(docker run --rm "${image}" bash -c '
    # Provide default config so chezmoi does not prompt
    mkdir -p ~/.config/chezmoi
    cat > ~/.config/chezmoi/chezmoi.toml <<CONF
[data]
  name = "Test User"
  email = "test@example.com"
  signingkey = ""
CONF

    if ! chezmoi apply --no-tty --exclude=scripts,externals 2>&1; then
      echo "APPLY_FAILED"
      exit 1
    fi
    echo "APPLY_OK"

    STATUS=0
    check() {
      if [ -e "$1" ]; then
        echo "PASS $1"
      else
        echo "FAIL $1"
        STATUS=1
      fi
    }

    check ~/.zshrc
    check ~/.bashrc
    check ~/.vimrc
    check ~/.tmux.conf
    check ~/.gitconfig
    check ~/.inputrc
    check ~/.vim/autoload/plug.vim
    check ~/.zsh/aliases.zsh
    check ~/.zsh/functions/extract.zsh
    check ~/.config/nvim/init.lua
    check ~/.git_template/ctags

    # Validate gitconfig was templated correctly
    if grep -q "Test User" ~/.gitconfig 2>/dev/null; then
      echo "PASS gitconfig templated (name)"
    else
      echo "FAIL gitconfig templated (name)"
      STATUS=1
    fi

    if grep -q "test@example.com" ~/.gitconfig 2>/dev/null; then
      echo "PASS gitconfig templated (email)"
    else
      echo "FAIL gitconfig templated (email)"
      STATUS=1
    fi

    exit $STATUS
  '); then
    :
  else
    :
  fi

  while IFS= read -r line; do
    case "$line" in
      APPLY_OK) pass "chezmoi apply succeeded" ;;
      APPLY_FAILED)
        fail "chezmoi apply failed"
        echo "$test_output"
        return
        ;;
      PASS*) pass "${line#PASS }" ;;
      FAIL*) fail "${line#FAIL }" ;;
    esac
  done <<< "$test_output"
}

for target in "${TARGETS[@]}"; do
  run_test "$target"
done

echo ""
echo "================================"
echo -e "Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "================================"

[[ $FAIL -eq 0 ]]

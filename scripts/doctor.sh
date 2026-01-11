#!/usr/bin/env bash

# doctor.sh
# Validation script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

log_info "Running Doctor..."

CHECK_FAILED=false

check_cmd() {
  if command_exists "$1"; then
    log_success "Found: $1 ($($1 --version | head -n 1))"
  else
    log_error "Missing: $1"
    CHECK_FAILED=true
  fi
}

check_file() {
  if [ -f "$1" ]; then
    log_success "Found config: $1"
  else
    log_error "Missing config: $1"
    CHECK_FAILED=true
  fi
}

# 1. System
log_info "Checking System..."
check_os

# 2. ZSH
log_info "Checking ZSH..."
check_cmd zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    log_warn "Current shell is not zsh: $SHELL"
    # Don't fail, might require logout
fi
if [ -d "$HOME/.local/share/zinit/zinit.git" ]; then
  log_success "Zinit installed"
else
  log_error "Zinit not found"
  CHECK_FAILED=true
fi

# 3. Git
log_info "Checking Git..."
check_cmd git

# 4. Docker
log_info "Checking Docker..."
check_cmd docker
if groups | grep -q "docker"; then
  log_success "User is in docker group"
else
  log_error "User is NOT in docker group (might need re-login)"
  CHECK_FAILED=true
fi
if docker info >/dev/null 2>&1; then
    log_success "Docker daemon is running and accessible"
else
    log_error "Cannot connect to Docker daemon"
    CHECK_FAILED=true
fi

# 5. Neovim
log_info "Checking Neovim..."
check_cmd nvim
check_file "$HOME/.config/nvim/init.lua"

# 6. VS Code
log_info "Checking VS Code..."
check_cmd code

if [ "$CHECK_FAILED" = true ]; then
  fail "Doctor found issues. Please fix them or re-run install.sh."
else
  log_success "All checks passed!"
fi

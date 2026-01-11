#!/usr/bin/env bash

# modules/nvim.sh
# Install Neovim + LazyVim

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
ROOT_DIR="${ROOT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

log_info "Setting up Neovim..."

# Install compiled deps for Telescope
ensure_sudo apt-get install -y build-essential ripgrep fd-find xclip

# Install Neovim (AppImage for stability)
if ! command_exists nvim || [[ $(nvim --version | head -n1) != *"v0.9"* && $(nvim --version | head -n1) != *"v0.10"* ]]; then
  log_info "Installing Neovim (AppImage)..."
  ensure_sudo apt-get install -y libfuse2 # Required for AppImage on 22.04+
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod +x nvim.appimage
  ensure_sudo mv nvim.appimage /usr/local/bin/nvim
else
  log_info "Neovim already installed."
fi

# Configure LazyVim
NVIM_CONFIG_DIR="$HOME/.config/nvim"

if [ -d "$NVIM_CONFIG_DIR" ]; then
  # If it's the exact same config we are linking/copying, do nothing?
  # But we want to ensure our managed config is active.
  # We should back up existing config.
  if [ ! -f "$NVIM_CONFIG_DIR/.managed_by_setup" ]; then
    log_warn "Backing up existing Neovim config..."
    backup_file "$NVIM_CONFIG_DIR"
    # backup_file moves it, so we can create new dir
  fi
fi

if [ ! -d "$NVIM_CONFIG_DIR" ]; then
    log_info "Deploying Neovim configuration..."
    mkdir -p "$NVIM_CONFIG_DIR"
    cp -r "$ROOT_DIR/config/nvim/"* "$NVIM_CONFIG_DIR/"
    touch "$NVIM_CONFIG_DIR/.managed_by_setup"
else 
    log_info "Updating Neovim configuration..."
    cp -r "$ROOT_DIR/config/nvim/"* "$NVIM_CONFIG_DIR/"
fi

# Headless bootstrap handled by nvim on first launch, but we can try to trigger it.
# This might fail if network is flaky or takes too long.
log_info "Bootstrapping LazyVim (this may take a moment)..."
# We run nvim headlessly to install plugins
nvim --headless "+Lazy! sync" +qa || log_warn "Lazy sync failed, verify on first launch."

log_success "Neovim configured."

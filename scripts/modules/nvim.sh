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
# Install Neovim (AppImage for stability)
REQUIRED_VERSION="v0.11.2"
CURRENT_VERSION="v0.0.0"

if command_exists nvim; then
  # Extract version like v0.10.1 or v0.11.0
  CURRENT_VERSION=$(nvim --version | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "v0.0.0")
fi

# Compare versions
# If the smallest of (required, current) is current, and they are not equal, then current < required.
if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)" == "$CURRENT_VERSION" && "$CURRENT_VERSION" != "$REQUIRED_VERSION" ]]; then
  log_info "Neovim version $CURRENT_VERSION is older than required $REQUIRED_VERSION. Installing latest AppImage..."
  ensure_sudo apt-get install -y libfuse2 # Required for AppImage on 22.04+
  
  # Remove apt-installed neovim to avoid conflicts if it exists
  if output=$(apt-cache policy neovim) && [[ $output == *"Installed:"* ]]; then
     log_info "Removing apt-installed neovim to favor AppImage..."
     ensure_sudo apt-get remove -y neovim
  fi

  # Determine Architecture and Asset Name
  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" ]]; then
      ASSET="nvim-linux-x86_64.appimage"
  elif [[ "$ARCH" == "aarch64" ]]; then
      ASSET="nvim-linux-arm64.appimage"
  else
      log_error "Unsupported architecture for AppImage: $ARCH"
      exit 1
  fi

  log_info "Downloading $ASSET..."
  curl -LO "https://github.com/neovim/neovim/releases/latest/download/$ASSET"
  
  # Verify download is not a 404 text file
  if file "$ASSET" | grep -i "text"; then
     log_error "Download failed (file appears to be text/HTML). Check internet connection or asset name: $ASSET"
     cat "$ASSET"
     rm "$ASSET"
     exit 1
  fi

  chmod +x "$ASSET"
  ensure_sudo mv "$ASSET" /usr/local/bin/nvim
else
  log_info "Neovim $CURRENT_VERSION is already installed and meets requirement ($REQUIRED_VERSION)."
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

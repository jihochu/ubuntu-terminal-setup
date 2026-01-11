#!/usr/bin/env bash

# modules/zsh.sh
# Configure ZSH + Starship

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
ROOT_DIR="${ROOT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

log_info "Setting up ZSH Environment..."

# Install ZSH
ensure_sudo apt-get install -y zsh

# Set ZSH as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  log_info "Changing default shell to zsh for $USER..."
  ensure_sudo chsh -s "$(which zsh)" "$USER"
fi

# Install Zinit
if [ ! -d "$HOME/.local/share/zinit/zinit.git" ]; then
  log_info "Installing Zinit..."
  mkdir -p "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git"
fi

# Install Starship
if ! command_exists starship; then
  log_info "Installing Starship..."
  curl -sS https://starship.rs/install.sh | ensure_sudo sh -s -- -y
fi

# Link configs
CONFIG_ZSH="$HOME/.zshrc"
SOURCE_ZSH="$ROOT_DIR/config/zsh/.zshrc"

if [ -f "$SOURCE_ZSH" ]; then
  backup_file "$CONFIG_ZSH"
  log_info "Installing .zshrc..."
  cp "$SOURCE_ZSH" "$CONFIG_ZSH"
else
  log_error "Missing source .zshrc at $SOURCE_ZSH"
fi

# Starship Config
mkdir -p "$HOME/.config"
CONFIG_STARSHIP="$HOME/.config/starship.toml"
SOURCE_STARSHIP="$ROOT_DIR/config/starship/starship.toml"

if [ -f "$SOURCE_STARSHIP" ]; then
  backup_file "$CONFIG_STARSHIP"
  log_info "Installing starship.toml..."
  cp "$SOURCE_STARSHIP" "$CONFIG_STARSHIP"
else
  log_error "Missing source starship.toml at $SOURCE_STARSHIP"
fi

log_success "ZSH setup complete."

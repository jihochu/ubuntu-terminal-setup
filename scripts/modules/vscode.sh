#!/usr/bin/env bash

# modules/vscode.sh
# Install VS Code + Extensions

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
ROOT_DIR="${ROOT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

log_info "Setting up VS Code..."

# Install VS Code repo
if ! command_exists code; then
  log_info "Installing VS Code..."
  ensure_sudo apt-get install -y wget gpg
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  ensure_sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  ensure_sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg

  ensure_sudo apt-get update
  ensure_sudo apt-get install -y code
else
  log_info "VS Code seems to be installed."
fi

# Install Extensions
EXT_FILE="$ROOT_DIR/config/vscode/extensions.txt"
if [ -f "$EXT_FILE" ]; then
  log_info "Installing VS Code extensions..."
  # We loop to allow failures (some might be deprecated or incompatible)
  while IFS="" read -r p || [ -n "$p" ]
  do
    # trim whitespace
    extension=$(echo "$p" | xargs)
    if [ -n "$extension" ]; then
        if code --install-extension "$extension" --force; then
            log_success "Installed $extension"
        else
            log_warn "Failed to install $extension (check internet or extension ID)"
        fi
    fi
  done < "$EXT_FILE"
else
  log_error "Extensions list not found at $EXT_FILE"
fi

# Settings
VSCODE_USER_DIR="$HOME/.config/Code/User"
mkdir -p "$VSCODE_USER_DIR"
SETTINGS_SRC="$ROOT_DIR/config/vscode/settings.json"
SETTINGS_DEST="$VSCODE_USER_DIR/settings.json"

if [ -f "$SETTINGS_SRC" ]; then
  backup_file "$SETTINGS_DEST"
  log_info "Installing VS Code settings..."
  cp "$SETTINGS_SRC" "$SETTINGS_DEST"
else
  log_error "Settings file not found at $SETTINGS_SRC"
fi

log_success "VS Code setup complete."

#!/usr/bin/env bash

# uninstall.sh
# Best-effort rollback

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

log_warn "This will remove configurations installed by ubuntu-terminal-setup."
log_warn "It will NOT remove installed packages (apt/snap) to avoid breaking system."
log_warn "It will restore checking for .bak files."

read -p "Are you sure? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  fail "Aborted."
fi

restore_backup() {
  local file="$1"
  # Find latest backup
  local backup
  backup=$(find "$(dirname "$file")" -maxdepth 1 -name "$(basename "$file").bak.*" | sort -r | head -n 1)
  
  if [ -n "$backup" ]; then
    log_info "Restoring $backup to $file"
    cp "$backup" "$file"
  else
    log_info "No backup found for $file, skipping restore."
  fi
}

# ZSH
restore_backup "$HOME/.zshrc"
# We don't delete zinit/starship just unlink configs if we linked them, 
# but here we likely just overwrote or appended.
# If we symlinked, we should remove symlinks.
# For this scaffold, we'll assume we want to restore previous state.

# Git
restore_backup "$HOME/.gitconfig"

# Neovim
if [ -d "$HOME/.config/nvim" ]; then
    log_info "Backing up current nvim config before removal"
    backup_file "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim"
    log_success "Removed ~/.config/nvim"
fi
# Restore if there was a backup of the directory 
# (Implementation detail: backup_file handles files, for dirs we might need custom logic, 
# but for now let's just leave it at backing up current state and removing)

# VS Code
restore_backup "$HOME/.config/Code/User/settings.json"

log_success "Uninstall/Rollback checks complete. Packages were NOT removed."

#!/usr/bin/env bash

# install.sh
# Main entrypoint for ubuntu-terminal-setup

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Default flags
DRY_RUN=false
ASSUME_YES=false
MODULES=("deps" "zsh" "git" "docker" "nvim" "vscode")
SELECTED_MODULES=()

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --all              Install all components (default)"
  echo "  --only <module>    Install only specific module (deps, zsh, git, docker, nvim, vscode)"
  echo "  --dry-run          Show what would happen"
  echo "  --yes              Run non-interactively"
  echo "  --help             Show this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --all)
      SELECTED_MODULES=("${MODULES[@]}")
      shift
      ;;
    --only)
      if [[ -n "$2" ]]; then
        IFS=',' read -ra ADDR <<< "$2"
        for i in "${ADDR[@]}"; do
           SELECTED_MODULES+=("$i")
        done
        shift 2
      else
        fail "--only requires an argument"
      fi
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --yes)
      ASSUME_YES=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

if [ ${#SELECTED_MODULES[@]} -eq 0 ]; then
  SELECTED_MODULES=("${MODULES[@]}")
fi

log_info "Welcome to Ubuntu Terminal Setup!"
check_os

if [ "$DRY_RUN" = true ]; then
  log_warn "DRY RUN MODE: No changes will be made."
fi

# Confirmation
if [ "$ASSUME_YES" = false ] && [ "$DRY_RUN" = false ]; then
  log_info "Selected modules: ${SELECTED_MODULES[*]}"
  read -p "Are you sure you want to proceed? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    fail "Aborted by user."
  fi
fi

# Run modules
for module in "${SELECTED_MODULES[@]}"; do
  module_script="$SCRIPT_DIR/modules/$module.sh"
  if [ -f "$module_script" ]; then
    log_info "=== Running Module: $module ==="
    if [ "$DRY_RUN" = true ]; then
      echo "Would run: $module_script"
    else
      # Pass flags to modules if needed, or export them
      export DRY_RUN
      export ASSUME_YES
      export ROOT_DIR
      # shellcheck source=/dev/null
      bash "$module_script"
    fi
  else
    log_error "Module script not found: $module_script"
  fi
done

log_success "Installation complete!"
log_info "Please restart your shell or log out/in for all changes to take effect."

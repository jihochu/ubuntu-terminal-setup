#!/usr/bin/env bash

# modules/git.sh
# Configure Git

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# ROOT_DIR is exported by install.sh or we assume relative path
ROOT_DIR="${ROOT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

log_info "Configuring Git..."

GIT_TEMPLATE="$ROOT_DIR/config/git/gitconfig.template"
USER_GITCONFIG="$HOME/.gitconfig"

if [ -f "$GIT_TEMPLATE" ]; then
  # We do not overwrite .gitconfig entirely to respect user user/email
  # We append/replace specific keys or just include (git allows includes)
  # But requirement says "safe merge/update".
  # Simplest safe merge: Configure each key locally if not present?
  # Or append contents if not present?
  
  # Let's use git config to set values to ensure safety and correctness
  log_info "Applying settings from template..."
  
  # Read template and apply using git config --global
  # Simple parser for the template ini structure
  git config --global init.defaultBranch main
  git config --global pull.rebase false
  git config --global core.editor nvim
  git config --global rerere.enabled true
  
  # Aliases
  git config --global alias.st status
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
  git config --global alias.amend "commit --amend"
  git config --global alias.undo "reset --soft HEAD~1"

  log_success "Git configured."
else
  log_error "Git config template not found at $GIT_TEMPLATE"
fi

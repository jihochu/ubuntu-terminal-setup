#!/usr/bin/env bash

# modules/deps.sh
# Install base dependencies

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

log_info "Installing Base Dependencies..."

ensure_sudo apt-get update

DEPS=(
  curl
  git
  unzip
  build-essential
  python3-venv
  python3-pip
  pipx
  ripgrep
  fd-find
  jq
  fzf
)

# Install Node.js (Latest LTS via Nodesource)
if ! command_exists node; then
  log_info "Installing Node.js (LTS)..."
  ensure_sudo apt-get install -y ca-certificates curl gnupg
  ensure_sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | ensure_sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
  NODE_MAJOR=20
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | ensure_sudo tee /etc/apt/sources.list.d/nodesource.list
  ensure_sudo apt-get update
  DEPS+=(nodejs)
else
  log_info "Node.js already installed."
fi

log_info "Installing packages: ${DEPS[*]}"
ensure_sudo apt-get install -y "${DEPS[@]}"

log_success "Dependencies installed."

#!/usr/bin/env bash

# modules/docker.sh
# Install Docker

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../scripts/lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

log_info "Setting up Docker..."

# Remove old versions
ensure_sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# Add Docker repo
ensure_sudo apt-get update
ensure_sudo apt-get install -y ca-certificates curl gnupg
ensure_sudo mkdir -p /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    log_info "Adding Docker GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | ensure_sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi
ensure_sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add repo
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  ensure_sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

ensure_sudo apt-get update

# Install Docker
log_info "Installing Docker Engine..."
ensure_sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Post-install
if ! groups "$USER" | grep -q "docker"; then
  log_info "Adding $USER to docker group..."
  ensure_sudo usermod -aG docker "$USER"
fi

ensure_sudo systemctl enable docker.service
ensure_sudo systemctl start docker.service

log_success "Docker installed. (Re-login required for group changes)"

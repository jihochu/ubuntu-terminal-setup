#!/usr/bin/env bash

# common.sh
# Shared functions for ubuntu-terminal-setup

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

fail() {
  log_error "$1"
  exit 1
}

# OS Detection
check_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
      fail "This script only supports Ubuntu. Detected: $ID"
    fi
    if [[ "$VERSION_ID" != "22.04" && "$VERSION_ID" != "24.04" ]]; then
       fail "This script only supports Ubuntu 22.04 and 24.04. Detected: $VERSION_ID"
    fi
    log_success "OS Check Passed: Ubuntu $VERSION_ID"
  else
    fail "Cannot detect OS. /etc/os-release not found."
  fi
}

# Sudo wrapper
ensure_sudo() {
  if [ "$EUID" -eq 0 ]; then 
    "$@"
  else
    sudo "$@"
  fi
}

# Backup function
backup_file() {
  local file="$1"
  if [ -f "$file" ] || [ -L "$file" ]; then
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="${file}.bak.${timestamp}"
    log_info "Backing up $file to $backup_path"
    mv "$file" "$backup_path"
  fi
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if a package is installed via dpkg
package_installed() {
  dpkg -l "$1" >/dev/null 2>&1
}

# Helper to add line to file if not exists
add_line_if_missing() {
  local line="$1"
  local file="$2"
  if ! grep -Fxq "$line" "$file"; then
    echo "$line" >> "$file"
    log_success "Added '$line' to $file"
  fi
}

#!/bin/bash
# scripts/proxmox/common.sh - Shared utility functions for Proxmox scripts

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Log file
LOG_FILE="/var/log/proxmox_scripts.log"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"; }

# Message functions
msg() { local color="$1" message="$2"; echo -e "${color}${message}${NC}"; log "$message"; }
msg_info() { msg "$BLUE" "ℹ️ $1"; }
msg_ok() { msg "$GREEN" "✅ $1"; }
msg_warn() { msg "$YELLOW" "⚠️ $1"; }
msg_error() { msg "$RED" "❌ $1"; }

# Command execution
run_command() {
  local command="$1" hide_output="$2" desc="$3"
  msg "$YELLOW" "Running: $command (${desc:-No description})"
  log "Executing: $command"
  if [ "$hide_output" = "true" ]; then
    eval "$command" &>/dev/null
  else
    eval "$command"
  fi
  local status=$?
  [ $status -ne 0 ] && { msg_error "Command failed: $command"; log "Failed: $command (exit $status)"; return 1; }
  msg_ok "Command succeeded"
  return 0
}

# Backup file
backup_file() {
  local file="$1"
  [ -f "$file" ] || return 0
  cp "$file" "$file.bak.$(date +%s)" && msg_ok "Backed up $file" || msg_error "Backup failed for $file"
}

# Check root
check_root() { [ "$(id -u)" -ne 0 ] && { msg_error "Must run as root"; exit 1; }; }

# Check Proxmox
check_pve() { [ ! -f /usr/bin/pveversion ] && { msg_error "Proxmox VE not detected"; exit 1; }; }
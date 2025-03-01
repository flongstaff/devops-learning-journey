#!/bin/bash

# pve_setup.sh - Interactive Proxmox VE Setup Script
# Version: 1.1.0
# Author: flongstaff
# Description: A script to configure and manage Proxmox VE with system, network, storage, VM/CT, and backup options.

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Log file for debugging
LOG_FILE="/var/log/pve_setup.log"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"; }

# Message display function
msg() {
  local color="$1" message="$2"
  echo -e "${color}${message}${NC}"
  log "$message"
}

msg_info() { msg "$BLUE" "ℹ️ $1"; }
msg_ok() { msg "$GREEN" "✅ $1"; }
msg_warn() { msg "$YELLOW" "⚠️ $1"; }
msg_error() { msg "$RED" "❌ $1"; }

# Command execution with error handling
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

# Backup function for critical files
backup_file() {
  local file="$1"
  [ -f "$file" ] || return 0
  cp "$file" "$file.bak.$(date +%s)" && msg_ok "Backed up $file" || msg_error "Backup failed for $file"
}

# Check prerequisites
check_prereqs() {
  [ "$(id -u)" -ne 0 ] && { msg_error "Must run as root"; exit 1; }
  [ ! -f /usr/bin/pveversion ] && { msg_error "Proxmox VE not detected"; exit 1; }
  command -v apt >/dev/null || { msg_error "apt not found"; exit 1; }
}

# Get Proxmox version
get_pve_version() {
  pveversion | grep "pve-manager" | awk '{print $2}' || echo "Unknown"
}

# Display header
display_header() {
  clear
  msg "$GREEN" "=========================================================="
  msg "$GREEN" "           Proxmox VE Setup Script v1.1.0                "
  msg "$GREEN" "=========================================================="
  msg "$BLUE" "               Let's Break Things and Learn!              "
  msg "$CYAN" "Proxmox VE Version: $(get_pve_version)"
  msg "$CYAN" "Running as: $(whoami) | Date: $(date)"
  echo ""
}

# System update function
update_system() {
  display_header
  msg_info "Updating system (this may take a while)"
  read -p "Proceed? (y/n): " confirm
  [ "$confirm" != "y" ] && { msg_warn "Update cancelled"; return 0; }
  
  backup_file "/etc/apt/sources.list"
  run_command "apt update" "false" "Update package lists" || return 1
  run_command "apt upgrade -y" "false" "Upgrade installed packages" || return 1
  msg_ok "System updated successfully"
}

# Main menu (simplified for brevity)
main_menu() {
  check_prereqs
  while true; do
    display_header
    echo "Choose a category:"
    echo "1. System Management"
    echo "2. Network Configuration"
    echo "3. Storage Management"
    echo "4. VM/CT Management"
    echo "5. Backup Tools"
    echo "6. Exit"
    read -p "Choose (1-6): " choice
    
    case $choice in
      1) update_system ;;  # Expand with other system functions
      2) configure_networking ;;  # Placeholder
      3) configure_storage ;;  # Placeholder
      4) configure_vm_ct ;;  # Placeholder
      5) configure_backup ;;  # Placeholder
      6) msg_ok "Exiting. Happy virtualizing!"; exit 0 ;;
      *) msg_error "Invalid option"; sleep 2 ;;
    esac
  done
}

# Placeholder functions (to be expanded as needed)
configure_networking() { msg_info "Network config placeholder"; sleep 2; }
configure_storage() { msg_info "Storage config placeholder"; sleep 2; }
configure_vm_ct() { msg_info "VM/CT config placeholder"; sleep 2; }
configure_backup() { msg_info "Backup config placeholder"; sleep 2; }

# Start script
main_menu
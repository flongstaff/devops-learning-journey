#!/bin/bash

# ANSI color codes
RD='\033[0;31m'
YW='\033[0;33m'
GN='\033[0;32m'
NC='\033[0m' # No Color

# Function to display a message with a specific color
msg() {
  local color="$1"
  local message="$2"
  echo -e "${color}$message${NC}"
}

# Function to execute a command and display it to the user
run_command() {
  local command="$1"
  msg "${YW}" "Running: ${command}"
  eval "$command"
  if [ $? -ne 0 ]; then
    msg "${RD}" "Command failed: ${command}"
    return 1
  fi
  return 0
}

# Function to display the header
header_info() {
  clear
  cat <<"EOF"
    ____ _    ________   ____             __     ____           __        ____
   / __ \ |  / / ____/  / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
  / /_/ / | / / __/    / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __ `/ / /
 / ____/| |/ / /___   / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /
/_/     |___/_____/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/

EOF
}
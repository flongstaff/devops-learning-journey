#!/bin/bash

# Source common functions
source "./common.sh"

usb_config() {
  clear
  header_info

  msg_info "USB Passthrough Configuration"
  
  echo "Select USB passthrough option:"
  echo "1. Identify USB devices"
  echo "2. Pass USB device to VM via CLI"
  echo "3. Pass USB device to VM via GUI"
  echo "4. Return to Main Menu"
  
  read -p "Choose an option (1-4): " choice
  
  case $choice in
    1)
      identify_usb_devices
      ;;
    2)
      pass_usb_device_cli
      ;;
    3)
      pass_usb_device_gui
      ;;
    4)
      return 0
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
}

# Function to identify USB devices
identify_usb_devices() {
  msg_info "Identifying USB devices connected to the host"
  
  msg_info "Run the following command to list all USB devices:"
  echo "```
lspci -nn | grep -i usb
lsusb
```"
  
  run_command "lspci -nn | grep -i usb" || return 1
  run_command "lsusb" || return 1
  
  msg_ok "USB devices listed.
#!/bin/bash

# Source common functions
source "./common.sh"

configure_usb_passthrough() {
  display_header
  msg_info "USB Passthrough Configuration"
  
  echo "Select USB passthrough option:"
  echo "1. Identify USB devices"
  echo "2. Pass USB device to VM via CLI"
  echo "3. Pass USB device to VM via GUI"
  echo "4. Return to main menu"
  
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
  
  msg_ok "USB devices listed. Note down the ID of the device you want to pass through."
}

# Function to pass USB device to VM via CLI
pass_usb_device_cli() {
  msg_info "Passing USB device to VM via CLI"
  
  echo "Enter the VM ID:"
  read vm_id
  echo "Enter the USB device ID (e.g., 1a86:55d4):"
  read usb_id
  
  msg_info "Run the following command to pass the USB device to the VM:"
  echo "```
qm set $vm_id -usb0 host=$usb_id
```"
  
  run_command "qm set $vm_id -usb0 host=$usb_id" || return 1
  
  msg_ok "USB device passed to VM $vm_id"
}

# Function to pass USB device to VM via GUI
pass_usb_device_gui() {
  msg_info "Passing USB device to VM via GUI"
  
  echo "1. Log in to the Proxmox web GUI."
  echo "2. Select the VM under the node/cluster name in the Datacenter section."
  echo "3. Click Hardware, then Add."
  echo "4. Select USB Device from the drop-down menu."
  echo "5. Choose the correct USB device to pass through."
  echo "6. Click Add to save the changes."
  
  msg_ok "USB device passed to VM via GUI. Restart the VM if necessary."
}

configure_usb_passthrough
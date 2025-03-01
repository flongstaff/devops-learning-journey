#!/bin/bash

# Source common functions
source "./common.sh"

configure_vm_ct() {
  display_header
  msg_info "VM and Container Management"
  
  echo "Select VM/CT option:"
  echo "1. Create new container"
  echo "2. Create new VM"
  echo "3. Configure existing VM/CT"
  echo "4. Return to Main Menu"
  
  read -p "Choose an option (1-4): " choice
  
  case $choice in
    1)
      create_container
      ;;
    2)
      create_vm
      ;;
    3)
      configure_vm_ct_existing
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

# Function to create a new container
create_container() {
  msg_info "Creating a new container"
  
  echo "Enter container name:"
  read container_name
  echo "Enter container template (e.g., alpine, ubuntu):"
  read template
  
  # Check if template is available
  if ! pveam available | grep -q "$template"; then
    msg_error "Template not found. Please download it first."
    return 1
  fi
  
  # Download template if not already downloaded
  if ! pveam list | grep -q "$template"; then
    msg_info "Downloading template..."
    run_command "pveam download local $template" || return 1
  fi
  
  # Create container
  msg_info "Creating container..."
  run_command "pct create 100 --name $container_name --ostemplate $template --memory 2048 --net0 virtio,bridge=vmbr0" || return 1
  
  msg_ok "Container created successfully!"
}

# Function to create a new VM
create_vm() {
  msg_info "Creating a new VM"
  
  echo "Enter VM name:"
  read vm_name
  echo "Enter VM ID:"
  read vm_id
  echo "Enter memory size in MB (e.g., 2048):"
  read memory
  echo "Enter number of CPU cores:"
  read cores
  
  # Create VM
  msg_info "Creating VM..."
  run_command "qm create $vm_id --name $vm_name --memory $memory --cores $cores --net0 virtio,bridge=vmbr0" || return 1
  
  msg_ok "VM created successfully!"
}

# Function to configure existing VM/CT
configure_vm_ct_existing() {
  msg_info "Configuring existing VM/CT"
  
  echo "Select VM/CT to configure:"
  run_command "qm list" || return 1
  run_command "pct list" || return 1
  
  echo "Enter VM/CT ID:"
  read vm_ct_id
  
  # Check if VM/CT exists
  if ! qm list | grep -q "$vm_ct_id" && ! pct list | grep -q "$vm_ct_id"; then
    msg_error "VM/CT not found."
    return 1
  fi
  
  # Display options
  echo "Select configuration option:"
  echo "1. Add hardware device"
  echo "2. Configure network"
  echo "3. Configure storage"
  echo "4. Configure GPU passthrough"
  echo "5. Return to VM/CT menu"
  
  read -p "Choose an option (1-5): " choice
  
  case $choice in
    1)
      add_hardware_device
      ;;
    2)
      configure_network
      ;;
    3)
      configure_storage
      ;;
    4)
      configure_gpu_passthrough
      ;;
    5)
      return 0
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
}

# Function to add hardware device
add_hardware_device() {
  msg_info "Adding hardware device"
  
  echo "Select device type:"
  echo "1. USB device"
  echo "2. PCI device"
  echo "3. Return to VM/CT menu"
  
  read -p "Choose an option (1-3): " choice
  
  case $choice in
    1)
      add_usb_device
      ;;
    2)
      add_pci_device
      ;;
    3)
      return 0
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
}

# Function to add USB device
add_usb_device() {
  msg_info "Adding USB device"
  
  echo "Enter USB device ID (e.g., 1a86:55d4):"
  read usb_id
  
  msg_info "Adding USB device to VM/CT..."
  run_command "qm set $vm_ct_id -usb0 host=$usb_id" || return 1
  
  msg_ok "USB device added successfully!"
}

# Function to add PCI device
add_pci_device() {
  msg_info "Adding PCI device"
  
  echo "Enter PCI device ID (e.g., 01:00.0):"
  read pci_id
  
  msg_info "Adding PCI device to VM/CT..."
  run_command "qm set $vm_ct_id -pci0 host=$pci_id" || return 1
  
  msg_ok "PCI device added successfully!"
}

configure_vm_ct
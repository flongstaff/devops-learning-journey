#!/bin/bash

# Source common functions
source "./common.sh"

create_vm() {
  clear
  header_info

  msg_info "Creating a new VM with GPU passthrough"

  # Ask for VM name and ID
  echo "Enter VM name:"
  read vm_name
  echo "Enter VM ID:"
  read vm_id

  # Ask for GPU selection
  echo "Select GPU to use for passthrough:"
  echo "1. Intel iGPU"
  echo "2. AMD GPU"
  echo "3. Nvidia GPU"
  read -p "Choose an option (1-3): " gpu_choice

  # Configure VM based on GPU choice
  case $gpu_choice in
    1)
      intel_gpu_vm_config
      ;;
    2)
      amd_gpu_vm_config
      ;;
    3)
      nvidia_gpu_vm_config
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac

  # Create VM
  msg_info "Creating VM..."
  run_command "qm create $vm_id --name $vm_name --memory 2048 --net0 virtio,bridge=vmbr0" || return 1

  # Add GPU to VM
  msg_info "Adding GPU to VM..."
  case $gpu_choice in
    1)
      PCI_ID=$(lspci -nn | grep "Intel.*Graphics" | awk '{print $1}')
      run_command "qm set $vm_id -pci0 host=$PCI_ID" || return 1
      ;;
    2)
      PCI_ID=$(lspci -nn | grep "AMD.*Graphics" | awk '{print $1}')
      run_command "qm set $vm_id -pci0 host=$PCI_ID" || return 1
      ;;
    3)
      PCI_ID=$(lspci -nn | grep "NVIDIA.*Graphics" | awk '{print $1}')
      run_command "qm set $vm_id -pci0 host=$PCI_ID" || return 1
      ;;
  esac

  msg_ok "VM created with GPU passthrough!"
}

# Function for Intel GPU VM configuration
intel_gpu_vm_config() {
  msg_info "Configuring Intel iGPU for VM"
  # Enable IOMMU in GRUB
  run_command "sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/\"$/ intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off\"/' /etc/default/grub" || return 1
  run_command "update-grub" || return 1
}

# Function for AMD GPU VM configuration
amd_gpu_vm_config() {
  msg_info "Configuring AMD GPU for VM"
  # Enable IOMMU in GRUB
  run_command "sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/\"$/ amd_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off\"/' /etc/default/grub" || return 1
  run_command "update-grub" || return 1
}

# Function for Nvidia GPU VM configuration
nvidia_gpu_vm_config() {
  msg_info "Configuring Nvidia GPU for VM"
  # Enable IOMMU in GRUB
  run_command "sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/\"$/ intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off\"/' /etc/default/grub" || return 1
  run_command "update-grub" || return 1
}

create_vm
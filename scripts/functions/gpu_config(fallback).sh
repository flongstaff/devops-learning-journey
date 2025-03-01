#!/bin/bash

# Source common functions
source "./common.sh"

gpu_config() {
  clear
  header_info

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "GPU Configuration" --menu "Configure GPU for Passthrough or vGPU:" 18 60 10 \
    "1" "Intel iGPU Configuration" \
    "2" "AMD GPU Configuration" \
    "3" "Nvidia GPU Configuration" \
    "4" "Return to Main Menu" 3>&2 2>&1 1>&3)

  case $CHOICE in
    1)
      intel_gpu_config
      ;;
    2)
      amd_gpu_config
      ;;
    3)
      nvidia_gpu_config
      ;;
    4)
        main_menu
      ;;
    *)
      msg_error "Invalid option. Try again!"
      ;;
  esac

  read -p "Press Enter to return to the GPU Configuration Menu..."
  gpu_config
}

# Sub-menu for Intel GPU Configuration
intel_gpu_config() {
  clear
  header_info

  # Check if Intel iGPU is available
  if lspci | grep -q "Intel.*Graphics"; then
    # Load intel_iommu module if not loaded
    if ! lsmod | grep -q "intel_iommu"; then
      msg_info "Enabling Intel iommu"
      run_command "sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/\"$/ intel_iommu=on\"/' /etc/default/grub"
      run_command "update-grub"
    fi

    # Prompt the user to enable or disable the iGPU
    CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Intel iGPU Configuration" --menu "Enable Intel iGPU for passthrough?" 18 60 10 \
      "1" "Enable Intel iGPU Passthrough" \
      "2" "Disable Intel iGPU Passthrough" \
      "3" "Return to GPU Configuration Menu" 3>&2 2>&1 1>&3)

    case $CHOICE in
      1)
        msg_info "Enabling Intel iGPU passthrough"
        # Add necessary modules
        run_command "echo 'vfio' >> /etc/modules"
        run_command "echo 'vfio_iommu_type1' >> /etc/modules"
        run_command "echo 'vfio_pci' >> /etc/modules"
        run_command "echo 'vfio_virqfd' >> /etc/modules"
        #Get the PCI ID
        PCI_ID=$(lspci -nn | grep "Intel.*Graphics" | awk '{print $1}')
        # Bind the iGPU to vfio-pci
        run_command "echo \"options vfio-pci ids=$PCI_ID\" > /etc/modprobe.d/vfio.conf"

        msg_ok "Intel iGPU passthrough enabled! Reboot is required to make changes. Review this changes on /etc/modules and /etc/modprobe.d/vfio.conf "
        ;;
      2)
        msg_info "Disabling Intel iGPU passthrough"
        # Remove Intel iGPU passthrough configurations
        run_command "sed -i '/vfio/d' /etc/modules"
        run_command "rm -f /etc/modprobe.d/vfio.conf"
        msg_ok "Intel iGPU passthrough disabled! Reboot is required to make changes."
        ;;
      3)
        gpu_config
        ;;
      *)
        msg_error "Invalid option. Try again!"
        ;;
    esac
  else
    msg_error "No Intel iGPU found!"
  fi
}

# Sub-menu for AMD GPU Configuration
amd_gpu_config() {
  clear
  header_info

  # Check if AMD GPU is available
  if lspci | grep -q "AMD.*Graphics"; then
    # Prompt the user to enable or disable the AMD GPU for passthrough
    CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "AMD GPU Configuration" --menu "Enable AMD GPU for passthrough?" 18 60 10 \
      "1" "Enable AMD GPU Passthrough" \
      "2" "Disable AMD GPU Passthrough" \
      "3" "Return to GPU Configuration Menu" 3>&2 2>&1 1>&3)

    case $CHOICE in
      1)
        msg_info "Enabling AMD GPU passthrough"
        # Add necessary modules
        run_command "echo 'vfio' >> /etc/modules"
        run_command "echo 'vfio_iommu_type1' >> /etc/modules"
        run_command "echo 'vfio_pci' >> /etc/modules"
        run_command "echo 'vfio_virqfd' >> /etc/modules"
        # Bind the AMD GPU to vfio-pci
        PCI_ID=$(lspci -nn | grep "AMD.*Graphics" | awk '{print $1}')
        run_command "echo \"options vfio-pci ids=$PCI_ID\" > /etc/modprobe.d/vfio.conf"
        
        # Install AMD drivers if needed
        if ! command -v amdgpu &> /dev/null; then
          msg_info "Installing AMDGPU drivers"
          run_command "apt update" || return 1
          run_command "apt install -y firmware-amd-graphics" || return 1
        fi
        
        msg_ok "AMD GPU passthrough enabled! Reboot is required to make changes. Review this changes on /etc/modules and /etc/modprobe.d/vfio.conf "
        ;;
      2)
        msg_info "Disabling AMD GPU passthrough"
        # Remove AMD GPU passthrough configurations
        run_command "sed -i '/vfio/d' /etc/modules"
        run_command "rm -f /etc/modprobe.d/vfio.conf"
        msg_ok "AMD GPU passthrough disabled! Reboot is required to make changes."
        ;;
      3)
        gpu_config
        ;;
      *)
        msg_error "Invalid option. Try again!"
        ;;
    esac
  else
    msg_error "No AMD GPU found!"
  fi
}

# Sub-menu for Nvidia GPU Configuration
nvidia_gpu_config() {
  clear
  header_info

  # Check if Nvidia GPU is available
  if lspci | grep -q "NVIDIA.*Graphics"; then
    # Check if the Nvidia driver is installed

    # Prompt the user to enable or disable the Nvidia GPU for passthrough or vGPU
    CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Nvidia GPU Configuration" --menu "Configure Nvidia GPU:" 18 60 10 \
      "1" "Enable Nvidia GPU Passthrough" \
      "2" "Enable Nvidia vGPU (Requires GRID license)" \
      "3" "Disable Nvidia GPU Passthrough/vGPU" \
      "4" "Return to GPU Configuration Menu" 3>&2 2>&1 1>&3)

    case $CHOICE in
      1)
        msg_info "Enabling Nvidia GPU passthrough"
        # Add necessary modules
        run_command "echo 'vfio' >> /etc/modules"
        run_command "echo 'vfio_iommu_type1' >> /etc/modules"
        run_command "echo 'vfio_pci' >> /etc/modules"
        run_command "echo 'vfio_virqfd' >> /etc/modules"
        # Bind the Nvidia GPU to vfio-pci
        PCI_ID=$(lspci -nn | grep "NVIDIA.*Graphics" | awk '{print $1}')
        run_command "echo \"options vfio-pci ids=$PCI_ID\" > /etc/modprobe.d/vfio.conf"
        
        # Install Nvidia drivers if needed
        if ! command -v nvidia &> /dev/null; then
          msg_info "Installing Nvidia drivers"
          run_command "apt update" || return 1
          run_command "apt install -y nvidia-driver" || return 1
        fi
        
        msg_ok "Nvidia GPU passthrough enabled! Reboot is required to make changes. Review this changes on /etc/modules and /etc/modprobe.d/vfio.conf"
        ;;
      2)
        msg_info "Enabling Nvidia vGPU (Requires GRID license)"
        # Implement vGPU configuration steps here
        msg_error "Nvidia vGPU configuration is not yet implemented! Please see NVIDIA documentation."
        ;;
      3)
        msg_info "Disabling Nvidia GPU passthrough/vGPU"
        # Remove Nvidia GPU passthrough configurations
        run_command "sed -i '/vfio/d' /etc/modules"
        run_command "rm -f /etc/modprobe.d/vfio.conf"
        msg_ok "Nvidia GPU passthrough/vGPU disabled! Reboot is required to make changes."
        ;;
      4)
        gpu_config
        ;;
      *)
        msg_error "Invalid option. Try again!"
        ;;
    esac
  else
    msg_error "No Nvidia GPU found!"
  fi
}

gpu_config
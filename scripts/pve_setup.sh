#!/bin/bash

# Version
VERSION="1.0.0"

# ANSI color codes for a slightly more engaging experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to display a message with a specific color
msg() {
  local color="$1"
  local message="$2"
  echo -e "${color}$message${NC}"
}

# Function to display info messages
msg_info() {
  msg "${BLUE}" "ℹ️ $1"
}

# Function to display success messages
msg_ok() {
  msg "${GREEN}" "✅ $1"
}

# Function to display warning messages
msg_warn() {
  msg "${YELLOW}" "⚠️ $1"
}

# Function to display error messages
msg_error() {
  msg "${RED}" "❌ $1"
}

# Function to execute a command and display it to the user
run_command() {
  local command="$1"
  local hide_output="$2"
  
  msg "${YELLOW}" "Running: ${command}"
  
  if [ "$hide_output" = "true" ]; then
    eval "$command" &>/dev/null
  else
    eval "$command"
  fi
  
  if [ $? -ne 0 ]; then
    msg_error "Command failed: ${command}"
    return 1
  fi
  return 0
}

# Check if running as root
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    msg_error "This script must be run as root"
    exit 1
  fi
}

# Check if Proxmox VE is installed
check_pve() {
  if [ ! -f /usr/bin/pveversion ]; then
    msg_error "Proxmox VE is not installed"
    exit 1
  fi
}

# Get Proxmox VE version
get_pve_version() {
  local pve_version=$(pveversion | grep "pve-manager" | awk '{print $2}')
  echo "$pve_version"
}

# Display header
display_header() {
  clear
  msg "${GREEN}" "=========================================================="
  msg "${GREEN}" "           Proxmox VE Setup Script v${VERSION}             "
  msg "${GREEN}" "=========================================================="
  msg "${BLUE}" "               Let's Break Things and Learn!              "
  msg "${GREEN}" "=========================================================="
  echo ""
  msg "${CYAN}" "Proxmox VE Version: $(get_pve_version)"
  msg "${CYAN}" "Running as: $(whoami)"
  msg "${CYAN}" "Date: $(date)"
  echo ""
}

#######################################
##        SYSTEM MANAGEMENT          ##
#######################################

# Update the System
update_system() {
  display_header
  msg_info "Time to update the system! (This might take a while, grab a coffee ☕)"
  
  read -p "Do you want to update the system? (y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
    msg_warn "Update cancelled by user"
    return 0
  fi
  
  run_command "apt update" || return 1
  run_command "apt upgrade -y" || return 1
  
  msg_ok "System update complete! 🎉"
}

# Install essential tools
install_tools() {
  display_header
  msg_info "Let's install some essential tools. (Like a Swiss Army knife for Proxmox 🔪)"
  
  echo "Select tools to install:"
  echo "1. Basic tools (vim, mc, htop, net-tools)"
  echo "2. Advanced tools (curl, wget, iotop, iftop, nmon, glances)"
  echo "3. Development tools (git, make, build-essential)"
  echo "4. All of the above"
  echo "5. Cancel"
  
  read -p "Choose an option (1-5): " choice
  
  case $choice in
    1)
      run_command "apt install -y vim mc htop net-tools" || return 1
      ;;
    2)
      run_command "apt install -y curl wget iotop iftop nmon glances" || return 1
      ;;
    3)
      run_command "apt install -y git make build-essential" || return 1
      ;;
    4)
      run_command "apt install -y vim mc htop net-tools curl wget iotop iftop nmon glances git make build-essential" || return 1
      ;;
    5)
      msg_warn "Tool installation cancelled by user"
      return 0
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
  
  msg_ok "Tools installed! You're getting dangerous now. 😎"
}

# System performance tuning
tune_system() {
  display_header
  msg_info "Optimizing system performance"
  
  echo "Select optimization options:"
  echo "1. Adjust swappiness (recommended for memory-intensive workloads)"
  echo "2. Optimize I/O scheduler (recommended for SSDs)"
  echo "3. Adjust network settings (recommended for high network load)"
  echo "4. All of the above"
  echo "5. Cancel"
  
  read -p "Choose an option (1-5): " choice
  
  case $choice in
    1)
      msg_info "Adjusting swappiness to 10 (default is 60)"
      run_command "echo 'vm.swappiness=10' > /etc/sysctl.d/99-swappiness.conf" || return 1
      run_command "sysctl -p /etc/sysctl.d/99-swappiness.conf" || return 1
      ;;
    2)
      msg_info "Setting I/O scheduler to deadline for all disks"
      run_command "echo 'GRUB_CMDLINE_LINUX_DEFAULT=\"\$GRUB_CMDLINE_LINUX_DEFAULT elevator=deadline\"' > /etc/default/grub.d/io-scheduler.cfg" || return 1
      run_command "update-grub" || return 1
      ;;
    3)
      msg_info "Optimizing network settings"
      run_command "echo 'net.core.somaxconn=1024' >> /etc/sysctl.d/99-network.conf" || return 1
      run_command "echo 'net.core.netdev_max_backlog=5000' >> /etc/sysctl.d/99-network.conf" || return 1
      run_command "echo 'net.ipv4.tcp_max_syn_backlog=8096' >> /etc/sysctl.d/99-network.conf" || return 1
      run_command "echo 'net.ipv4.tcp_slow_start_after_idle=0' >> /etc/sysctl.d/99-network.conf" || return 1
      run_command "sysctl -p /etc/sysctl.d/99-network.conf" || return 1
      ;;
    4)
      msg_info "Applying all optimizations"
      run_command "echo 'vm.swappiness=10' > /etc/sysctl.d/99-swappiness.conf" || return 1
      run_command "sysctl -p /etc/sysctl.d/99-swappiness.conf" || return 1
      
      run_command "echo 'GRUB_CMDLINE_LINUX_DEFAULT=\"\$GRUB_CMDLINE_LINUX_DEFAULT elevator=deadline\"' > /etc/default/grub.d/io-scheduler.cfg" || return 1
      run_command "update-grub" || return 1
      
      run_command "echo 'net.core.somaxconn=1024' >> /etc/sysctl.d/99-network.conf" || return 1
      run_command "echo 'net.core.netdev_max_backlog=5000' >> /etc/sysctl.d/99-network.conf" || return 1
      run_command "echo 'net.ipv4.tcp_max_syn_backlog=8096' >> /etc/sysctl.d/99-network.conf" || return 1
      run_command "echo 'net.ipv4.tcp_slow_start_after_idle=0' >> /etc/sysctl.d/99-network.conf" || return 1
      run_command "sysctl -p /etc/sysctl.d/99-network.conf" || return 1
      ;;
    5)
      msg_warn "System tuning cancelled by user"
      return 0
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
  
  msg_ok "System performance optimized successfully!"
}

# System monitoring setup
setup_monitoring() {
  display_header
  msg_info "Setting up system monitoring"
  
  echo "Select monitoring options:"
  echo "1. Install Prometheus (recommended for detailed metrics)"
  echo "2. Install Grafana (recommended for visualization)"
  echo "3. Install both Prometheus and Grafana"
  echo "4. Cancel"
  
  read -p "Choose an option (1-4): " choice
  
  case $choice in
    1)
      msg_info "Installing Prometheus"
      run_command "apt update" || return 1
      run_command "apt install -y prometheus prometheus-node-exporter" || return 1
      run_command "systemctl enable prometheus prometheus-node-exporter" || return 1
      run_command "systemctl start prometheus prometheus-node-exporter" || return 1
      ;;
    2)
      msg_info "Installing Grafana"
      run_command "apt update" || return 1
      run_command "apt install -y software-properties-common" || return 1
      run_command "wget -q -O /usr/share/keyrings/grafana.key https://packages.grafana.com/gpg.key" || return 1
      run_command "echo \"deb [signed-by=/usr/share/keyrings/grafana.key] https://packages.grafana.com/oss/deb stable main\" | tee /etc/apt/sources.list.d/grafana.list" || return 1
      run_command "apt update" || return 1
      run_command "apt install -y grafana" || return 1
      run_command "systemctl enable grafana-server" || return 1
      run_command "systemctl start grafana-server" || return 1
      ;;
    3)
      msg_info "Installing Prometheus and Grafana"
      run_command "apt update" || return 1
      run_command "apt install -y prometheus prometheus-node-exporter" || return 1
      run_command "systemctl enable prometheus prometheus-node-exporter" || return 1
      run_command "systemctl start prometheus prometheus-node-exporter" || return 1
      
      run_command "apt install -y software-properties-common" || return 1
      run_command "wget -q -O /usr/share/keyrings/grafana.key https://packages.grafana.com/gpg.key" || return 1
      run_command "echo \"deb [signed-by=/usr/share/keyrings/grafana.key] https://packages.grafana.com/oss/deb stable main\" | tee /etc/apt/sources.list.d/grafana.list" || return 1
      run_command "apt update" || return 1
      run_command "apt install -y grafana" || return 1
      run_command "systemctl enable grafana-server" || return 1
      run_command "systemctl start grafana-server" || return 1
      ;;
    4)
      msg_warn "Monitoring setup cancelled by user"
      return 0
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
  
  msg_ok "Monitoring setup complete!"
  
  if [[ "$choice" == "1" || "$choice" == "3" ]]; then
    echo "Prometheus is accessible at http://$(hostname -I | awk '{print $1}'):9090"
  fi
  
  if [[ "$choice" == "2" || "$choice" == "3" ]]; then
    echo "Grafana is accessible at http://$(hostname -I | awk '{print $1}'):3000"
    echo "Default credentials: admin / admin"
  fi
}

#######################################
##       NETWORK CONFIGURATION       ##
#######################################

# Configure networking
configure_networking() {
  display_header
  msg_info "Time to configure networking! (Don't worry, it's not as scary as it sounds 👻)"
  
  echo "Select networking options:"
  echo "1. Show current IP configuration"
  echo "2. Configure network interfaces"
  echo "3. Configure hostname and DNS"
  echo "4. Configure IP forwarding"
  echo "5. Return to main menu"
  
  read -p "Choose an option (1-5): " choice
  
  case $choice in
    1)
      run_command "ip addr show"
      ;;
    2)
      msg_warn "This will modify your network interfaces. Make sure you have physical/console access to the server in case of issues."
      read -p "Continue? (y/n): " confirm
      if [[ "$confirm" == "y" ]]; then
        run_command "vim /etc/network/interfaces"
        msg_info "Restarting networking service..."
        run_command "systemctl restart networking.service" || return 1
      else
        msg_warn "Network interface configuration cancelled by user"
      fi
      ;;
    3)
      echo "Current hostname: $(hostname)"
      read -p "Enter new hostname (leave empty to keep current): " new_hostname
      if [[ ! -z "$new_hostname" ]]; then
        run_command "hostnamectl set-hostname $new_hostname" || return 1
        run_command "sed -i \"s/127.0.1.1.*/127.0.1.1\t$new_hostname/g\" /etc/hosts" || return 1
        msg_ok "Hostname changed to $new_hostname"
      fi
      
      echo "Current DNS servers:"
      run_command "cat /etc/resolv.conf"
      
      read -p "Configure DNS servers? (y/n): " dns_config
      if [[ "$dns_config" == "y" ]]; then
        read -p "Enter primary DNS server (e.g., 1.1.1.1): " primary_dns
        read -p "Enter secondary DNS server (e.g., 8.8.8.8): " secondary_dns
        
        run_command "echo \"nameserver $primary_dns\" > /etc/resolv.conf" || return 1
        run_command "echo \"nameserver $secondary_dns\" >> /etc/resolv.conf" || return 1
        msg_ok "DNS servers configured"
      fi
      ;;
    4)
      echo "Current IP forwarding status:"
      run_command "sysctl net.ipv4.ip_forward"
      
      read -p "Enable IP forwarding? (y/n): " ip_forward
      if [[ "$ip_forward" == "y" ]]; then
        run_command "echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-ip-forward.conf" || return 1
        run_command "sysctl -p /etc/sysctl.d/99-ip-forward.conf" || return 1
        msg_ok "IP forwarding enabled"
      else
        run_command "echo 'net.ipv4.ip_forward=0' > /etc/sysctl.d/99-ip-forward.conf" || return 1
        run_command "sysctl -p /etc/sysctl.d/99-ip-forward.conf" || return 1
        msg_ok "IP forwarding disabled"
      fi
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

# Configure firewall
configure_firewall() {
  display_header
  msg_info "Configuring firewall settings"
  
  echo "Select firewall options:"
  echo "1. Enable basic firewall (allow SSH, Proxmox web UI, ICMP)"
  echo "2. Advanced firewall configuration"
  echo "3. Disable firewall"
  echo "4. Return to main menu"
  
  read -p "Choose an option (1-4): " choice
  
  case $choice in
    1)
      msg_info "Enabling basic firewall rules"
      run_command "apt update" || return 1
      run_command "apt install -y ufw" || return 1
      run_command "ufw default deny incoming" || return 1
      run_command "ufw default allow outgoing" || return 1
      run_command "ufw allow 22/tcp" || return 1 # SSH
      run_command "ufw allow 8006/tcp" || return 1 # Proxmox web UI
      run_command "ufw allow icmp" || return 1 # ICMP (ping)
      run_command "ufw --force enable" || return 1
      msg_ok "Basic firewall configured and enabled"
      ;;
    2)
      msg_info "Advanced firewall configuration"
      echo "1. UFW (Uncomplicated Firewall)"
      echo "2. iptables"
      read -p "Choose firewall system (1-2): " fw_choice
      
      if [[ "$fw_choice" == "1" ]]; then
        run_command "apt update" || return 1
        run_command "apt install -y ufw" || return 1
        
        msg_info "Configuring UFW rules"
        run_command "ufw default deny incoming" || return 1
        run_command "ufw default allow outgoing" || return 1
        
        read -p "Enable SSH (port 22)? (y/n): " enable_ssh
        if [[ "$enable_ssh" == "y" ]]; then
          run_command "ufw allow 22/tcp" || return 1
        fi
        
        read -p "Enable Proxmox web UI (port 8006)? (y/n): " enable_proxmox
        if [[ "$enable_proxmox" == "y" ]]; then
          run_command "ufw allow 8006/tcp" || return 1
        fi
        
        read -p "Enable ping (ICMP)? (y/n): " enable_icmp
        if [[ "$enable_icmp" == "y" ]]; then
          run_command "ufw allow icmp" || return 1
        fi
        
        read -p "Enable additional ports? (comma-separated, e.g., 80,443): " additional_ports
        if [[ ! -z "$additional_ports" ]]; then
          IFS=',' read -r -a port_array <<< "$additional_ports"
          for port in "${port_array[@]}"; do
            run_command "ufw allow $port" || return 1
          done
        fi
        
        run_command "ufw --force enable" || return 1
        msg_ok "UFW configured and enabled"
      elif [[ "$fw_choice" == "2" ]]; then
        msg_info "Configuring iptables rules"
        run_command "apt update" || return 1
        run_command "apt install -y iptables-persistent" || return 1
        
        # Flush existing rules
        run_command "iptables -F" || return 1
        run_command "iptables -X" || return 1
        
        # Set default policies
        run_command "iptables -P INPUT DROP" || return 1
        run_command "iptables -P FORWARD DROP" || return 1
        run_command "iptables -P OUTPUT ACCEPT" || return 1
        
        # Allow established connections
        run_command "iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT" || return 1
        
        # Allow loopback
        run_command "iptables -A INPUT -i lo -j ACCEPT" || return 1
        
        read -p "Enable SSH (port 22)? (y/n): " enable_ssh
        if [[ "$enable_ssh" == "y" ]]; then
          run_command "iptables -A INPUT -p tcp --dport 22 -j ACCEPT" || return 1
        fi
        
        read -p "Enable Proxmox web UI (port 8006)? (y/n): " enable_proxmox
        if [[ "$enable_proxmox" == "y" ]]; then
          run_command "iptables -A INPUT -p tcp --dport 8006 -j ACCEPT" || return 1
        fi
        
        read -p "Enable ping (ICMP)? (y/n): " enable_icmp
        if [[ "$enable_icmp" == "y" ]]; then
          run_command "iptables -A INPUT -p icmp -j ACCEPT" || return 1
        fi
        
        read -p "Enable additional ports? (comma-separated, e.g., 80,443): " additional_ports
        if [[ ! -z "$additional_ports" ]]; then
          IFS=',' read -r -a port_array <<< "$additional_ports"
          for port in "${port_array[@]}"; do
            run_command "iptables -A INPUT -p tcp --dport $port -j ACCEPT" || return 1
          done
        fi
        
        # Save rules
        run_command "netfilter-persistent save" || return 1
        run_command "netfilter-persistent reload" || return 1
        msg_ok "iptables configured and enabled"
      else
        msg_error "Invalid option"
        return 1
      fi
      ;;
    3)
      msg_warn "This will disable all firewall rules and leave your server exposed!"
      read -p "Are you sure? (y/n): " confirm
      if [[ "$confirm" == "y" ]]; then
        run_command "apt update" || return 1
        run_command "apt install -y ufw" || return 1
        run_command "ufw disable" || return 1
        msg_ok "Firewall disabled"
      else
        msg_warn "Firewall disable cancelled by user"
      fi
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

#######################################
##        STORAGE MANAGEMENT         ##
#######################################

# Configure storage
configure_storage() {
  display_header
  msg_info "Configuring storage options"
  
  echo "Select storage options:"
  echo "1. ZFS management"
  echo "2. LVM management"
  echo "3. Configure NFS storage"
  echo "4. Configure SMB/CIFS storage"
  echo "5. Return to main menu"
  
  read -p "Choose an option (1-5): " choice
  
  case $choice in
    1)
      configure_zfs_storage
      ;;
    2)
      configure_lvm_storage
      ;;
    3)
      configure_nfs_storage
      ;;
    4)
      configure_smb_storage
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

# Configure ZFS storage
configure_zfs_storage() {
  display_header
  msg_info "ZFS Storage Management"
  
  # Check if ZFS is installed
  if ! command -v zpool &> /dev/null; then
    msg_warn "ZFS not found. Installing ZFS packages..."
    run_command "apt update" || return 1
    run_command "apt install -y zfsutils-linux" || return 1
  fi
  
  echo "ZFS Pool Status:"
  run_command "zpool status" || echo "No ZFS pools found"
  
  echo "Select ZFS option:"
  echo "1. Create new ZFS pool"
  echo "2. Import existing ZFS pool"
  echo "3. Add ZFS pool to Proxmox storage"
  echo "4. Return to storage menu"
  
  read -p "Choose an option (1-4): " choice
  
  case $choice in
    1)
      msg_info "Creating new ZFS pool"
      echo "Available disks:"
      run_command "lsblk -o NAME,SIZE,MODEL,SERIAL" || return 1
      
      read -p "Enter disk(s) to use (space-separated, e.g., 'sdb sdc'): " disks
      read -p "Enter pool name: " pool_name
      read -p "Select RAID level (mirror, raidz, raidz2, raidz3, stripe): " raid_level
      
      case $raid_level in
        mirror)
          cmd="zpool create $pool_name mirror"
          ;;
        raidz)
          cmd="zpool create $pool_name raidz"
          ;;
        raidz2)
          cmd="zpool create $pool_name raidz2"
          ;;
        raidz3)
          cmd="zpool create $pool_name raidz3"
          ;;
        stripe)
          cmd="zpool create $pool_name"
          ;;
        *)
          msg_error "Invalid RAID level"
          return 1
          ;;
      esac
      
      for disk in $disks; do
        cmd="$cmd /dev/$disk"
      done
      
      read -p "Additional options (leave empty for defaults): " options
      cmd="$cmd $options"
      
      msg_warn "This will destroy all data on the selected disks!"
      read -p "Continue? (y/n): " confirm
      if [[ "$confirm" == "y" ]]; then
        run_command "$cmd" || return 1
        msg_ok "ZFS pool '$pool_name' created successfully"
      else
        msg_warn "ZFS pool creation cancelled by user"
      fi
      ;;
    2)
      msg_info "Importing existing ZFS pool"
      run_command "zpool import" || return 1
      
      read -p "Enter pool name to import: " pool_name
      run_command "zpool import $pool_name" || return 1
      msg_ok "ZFS pool '$pool_name' imported successfully"
      ;;
    3)
      msg_info "Adding ZFS pool to Proxmox storage"
      echo "Available ZFS pools:"
      run_command "zpool list" || return 1
      
      read -p "Enter pool name to add to Proxmox: " pool_name
      read -p "Enter storage ID for Proxmox (e.g., zfs-pool): " storage_id
      
      run_command "pvesm add zfspool $storage_id --pool $pool_name --content images,rootdir" || return 1
      msg_ok "ZFS pool '$pool_name' added to Proxmox storage as '$storage_id'"
      ;;
    4)
      configure_storage
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
}

# Configure LVM storage
configure_lvm_storage() {
  display_header
  msg_info "LVM Storage Management"
  
  # Check if LVM is installed
  if ! command -v lvm &> /dev/null; then
    msg_warn "LVM not found. Installing LVM packages..."
    run_command "apt update" || return 1
    run_command "apt install -y lvm2" || return 1
  fi
  
  echo "Current LVM configuration:"
  run_command "pvs" || echo "No physical volumes found"
  run_command "vgs" || echo "No volume groups found"
  run_command "lvs" || echo "No logical volumes found"
  
  echo "Select LVM option:"
  echo "1. Create physical volume (PV)"
  echo "2. Create volume group (VG)"
  echo "3. Create logical volume (LV)"
  echo "4. Add LVM to Proxmox storage"
  echo "5. Return to storage menu"
  
  read -p "Choose an option (1-5): " choice
  
  case $choice in
    1)
      msg_info "Creating physical volume"
      echo "Available disks:"
      run_command "lsblk -o NAME,SIZE,MODEL,SERIAL" || return 1
      
      read -p "Enter disk to use (e.g., 'sdb'): " disk
      
      msg_warn "This will destroy all data on /dev/$disk!"
      read -p "Continue? (y/n): " confirm
      if [[ "$confirm" == "y" ]]; then
        run_command "pvcreate /dev/$disk" || return 1
        msg_ok "Physical volume created on /dev/$disk"
      else
        msg_warn "Physical volume creation cancelled by user"
      fi
      ;;
    2)
      msg_info "Creating volume group"
      echo "Available physical volumes:"
      run_command "pvs" || return 1
      
      read -p "Enter physical volume(s) to use (space-separated, e.g., '/dev/sdb /dev/sdc'): " pvs
      read -p "Enter volume group name: " vg_name
      
      run_command "vgcreate $vg_name $pvs" || return 1
      msg_ok "Volume group '$vg_name' created successfully"
      ;;
    3)
      msg_info "Creating logical volume"
      echo "Available volume groups:"
      run_command "vgs" || return 1
      
      read -p "Enter volume group name: " vg_name
      read -p "Enter logical volume name: " lv_name
      read -p "Enter size (e.g., '10G', '100%FREE'): " lv_size
      
      run_command "lvcreate -n $lv_name -L $lv_size $vg_name" || return 1
      msg_ok "Logical volume '$lv_name' created successfully"
      ;;
    4)
      msg_info "Adding LVM to Proxmox storage"
      echo "Available logical volumes:"
      run_command "lvs" || return 1
      
      read -p "Enter volume group name: " vg_name
      read -p "Enter storage ID for Proxmox (e.g., lvm-storage): " storage_id
      
      run_command "pvesm add lvmthin $storage_id --vgname $vg_name --thinpool data" || return 1
      msg_ok "LVM volume group '$vg_name' added to Proxmox storage as '$storage_id'"
      ;;
    5)
      configure_storage
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
}

# Configure NFS storage
configure_nfs_storage() {
  display_header
  msg_info "NFS Storage Management"
  
  echo "Select NFS option:"
  echo "1. Add NFS share to Proxmox storage"
  echo "2. Setup NFS server"
  echo "3. Return to storage menu"
  
  read -p "Choose an option (1-3): " choice
  
  case $choice in
    1)
      msg_info "Adding NFS share to Proxmox storage"
      
      read -p "Enter NFS server IP or hostname: " nfs_server
      read -p "Enter NFS share path (e.g., '/mnt/nfs'): " nfs_path
      read -p "Enter storage ID for Proxmox (e.g., nfs-storage): " storage_id
      read -p "Enter content types (iso,vztmpl,backup,images): " content_types
      
      if [[ -z "$content_types" ]]; then
        content_types="images"
      fi
      
      run_command "pvesm add nfs $storage_id --server $nfs_server --export $nfs_path --content $content_types" || return 1
      msg_ok "NFS share added to Proxmox storage as '$storage_id'"
      ;;
    2)
      msg_info "Setting up NFS server"
      
      run_command "apt update" || return 1
      run_command "apt install -y nfs-kernel-server" || return 1
      
      read -p "Enter directory to share (e.g., '/mnt/nfs_share'): " nfs_dir
      
      if [[ ! -d "$nfs_dir" ]]; then
        run_command "mkdir -p $nfs_dir" || return 1
      fi
      
      run_command "chown nobody:nogroup $nfs_dir" || return 1
      run_command "chmod 777 $nfs_dir" || return 1
      
      read -p "Enter allowed clients (e.g., '192.168.1.0/24'): " allowed_clients
      
      if [[ -z "$allowed_clients" ]]; then
        allowed_clients="*(rw,sync,no_subtree_check)"
      else
        allowed_clients="$allowed_clients(rw,sync,no_subtree_check)"
      fi
      
      run_command "echo '$nfs_dir $allowed_clients' >> /etc/exports" || return 1
      run_command "exportfs -a" || return 1
      run_command "systemctl restart nfs-kernel-server" || return 1
      
      msg_ok "NFS server set up at $nfs_dir"
      ;;
    3)
      configure_storage
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
}

# Configure SMB/CIFS storage
configure_smb_storage() {
  display_header
  msg_info "SMB/CIFS Storage Management"
  
  echo "Select SMB/CIFS option:"
  echo "1. Add SMB/CIFS share to Proxmox storage"
  echo "2. Setup Samba server"
  echo "3. Return to storage menu"
  
  read -p "Choose an option (1-3): " choice
  
  case $choice in
    1)
      msg_info "Adding SMB/CIFS share to Proxmox storage"
      
      read -p "Enter SMB server IP or hostname: " smb_server
      read -p "Enter SMB share name: " smb_share
      read -p "Enter username: " smb_username
      read -p "Enter password: " smb_password
      read -p "Enter storage ID for Proxmox (e.g., smb-storage): " storage_id
      read -p "Enter content types (iso,vztmpl,backup,images): " content_types
      
      if [[ -z "$content_types" ]]; then
        content_types="images"
      fi
      
      run_command "pvesm add cifs $storage_id --server $smb_server --share $smb_share --username $smb_username --password $smb_password --content $content_types" || return 1
      msg_ok "SMB/CIFS share added to Proxmox storage as '$storage_id'"
      ;;
    2)
      msg_info "Setting up Samba server"
      
      run_command "apt update" || return 1
      run_command "apt install -y samba" || return 1
      
      read -p "Enter directory to share (e.g., '/mnt/smb_share'): " smb_dir
      
      if [[ ! -d "$smb_dir" ]]; then
        run_command "mkdir -p $smb_dir" || return 1
      fi
      
      read -p "Enter share name: " share_name
      read -p "Enter share description: " share_desc
      
      run_command "cat << EOF >> /etc/samba/smb.conf
[$share_name]
   path = $smb_dir
   comment = $share_desc
   browseable = yes
   read only = no
   create mask = 0755
   directory mask = 0755
EOF" || return 1
      
      read -p "Create a Samba user? (y/n): " create_user
      if [[ "$create_user" == "y" ]]; then
        read -p "Enter username: " smb_username
        msg_info "Setting password for $smb_username"
        run_command "smbpasswd -a $smb_username" || return 1
      fi
      
      run_command "systemctl restart smbd" || return 1
      run_command "systemctl enable smbd" || return 1
      
      msg_ok "Samba server set up with share '$share_name' at $smb_dir"
      ;;
    3)
      configure_storage
      ;;
    *)
      msg_error "Invalid option"
      return 1
      ;;
  esac
}

#######################################
##         VM/CT MANAGEMENT          ##
#######################################

# Configure VM/CT management
configure_vm_ct() {
  display_header
  msg_info "VM and Container Management"
  
  echo "Select VM/CT option:"
  echo "1. Create new container template"
  echo "2. Create new VM template"
  echo "3. Configure GPU passthrough"
  echo "4. Configure nested virtualization"
  echo "5. Return to main menu"
  
  read -p "Choose an option (1-5): " choice
  
  case $choice in
    1)
      create_ct_template
      ;;
    2)
      create_vm_template
      ;;
    3)
      configure_gpu_passthrough
      ;;
    4)
      configure_nested_virt
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

# Create CT template
create_ct_template() {
  display_header
  msg_info "Creating Container Template"
  
  echo "Available templates:"
  run_command "pveam available" || return 1
  
  echo "Enter template to download (e.g., 'debian-11-standard'):"
  read template
  
  echo "Enter storage to download to (e.g., 'local'):"
  read storage
  
  run_command "pveam download $storage $template" || return 1
  msg_ok "Template $template downloaded to $storage"
}

# Create VM template
create_vm_template() {
  display_header
  msg_info "Creating VM Template"
  
  echo "This will guide you through creating a VM template that can be cloned."
  
  read -p "Enter VM ID for the template: " vmid
  read -p "Enter VM name: " vmname
  read -p "Enter storage for VM disk: " storage
  read -p "Enter disk size (e.g., 32G): " disksize
  read -p "Enter memory size in MB (e.g., 2048): " memory
  read -p "Enter number of CPU cores: " cores
  
  # Create the VM
  run_command "qm create $vmid --name $vmname --memory $memory --cores $cores --net0 virtio,bridge=vmbr0" || return 1
  
  # Add disk
  run_command "qm set $vmid --scsi0 $storage:$disksize" || return 1
  
  # Configure it as a template
  run_command "qm template $vmid" || return 1
  
  msg_ok "VM template created with ID $vmid"
}

# Configure GPU passthrough
configure_gpu_passthrough() {
  display_header
  msg_info "GPU Passthrough Configuration"
  
  echo "This will configure your system for GPU passthrough to VMs."
  
  # Check for IOMMU
  if ! dmesg | grep -i -e DMAR -e IOMMU &>/dev/null; then
    msg_error "IOMMU not enabled in kernel. Please enable it in BIOS and kernel parameters first."
    return 1
  fi
  
  # Check for available GPUs
  echo "Available PCI devices:"
  run_command "lspci -nn | grep -i 'VGA\|NVIDIA\|AMD'" || echo "No GPUs found"
  
  # Check if vfio modules are loaded
  if ! lsmod | grep -i vfio &>/dev/null; then
    msg_info "Loading VFIO modules"
    run_command "modprobe vfio vfio_iommu_type1 vfio_pci" || return 1
  fi
  
  # Configure VFIO for a GPU
  read -p "Enter PCI ID of GPU to passthrough (e.g., '01:00.0'): " gpu_id
  
  if [[ -z "$gpu_id" ]]; then
    msg_error "Invalid PCI ID"
    return 1
  fi
  
  # Get vendor and device IDs
  vendor_id=$(lspci -n -s $gpu_id | awk '{print $3}' | cut -d: -f1)
  device_id=$(lspci -n -s $gpu_id | awk '{print $3}' | cut -d: -f2)
  
  if [[ -z "$vendor_id" || -z "$device_id" ]]; then
    msg_error "Could not find vendor and device ID for PCI ID $gpu_id"
    return 1
  fi
  
  msg_info "Adding GPU $gpu_id ($vendor_id:$device_id) to VFIO"
  
  # Add modules to load at boot
  run_command "echo 'vfio' >> /etc/modules" || return 1
  run_command "echo 'vfio_iommu_type1' >> /etc/modules" || return 1
  run_command "echo 'vfio_pci' >> /etc/modules" || return 1
  run_command "echo 'vfio_virqfd' >> /etc/modules" || return 1
  
  # Configure vfio-pci to grab the GPU
  run_command "echo 'options vfio-pci ids=$vendor_id:$device_id' > /etc/modprobe.d/vfio.conf" || return 1
  
  # Update initramfs
  run_command "update-initramfs -u" || return 1
  
  msg_ok "GPU passthrough configured. Please reboot for changes to take effect."
}

# Configure nested virtualization
configure_nested_virt() {
  display_header
  msg_info "Nested Virtualization Configuration"
  
  # Check CPU vendor
  if grep -q "vendor_id.*GenuineIntel" /proc/cpuinfo; then
    cpu_vendor="intel"
  elif grep -q "vendor_id.*AuthenticAMD" /proc/cpuinfo; then
    cpu_vendor="amd"
  else
    msg_error "Unknown CPU vendor. Cannot configure nested virtualization."
    return 1
  fi
  
  if [[ "$cpu_vendor" == "intel" ]]; then
    if ! cat /sys/module/kvm_intel/parameters/nested | grep -q "Y"; then
      msg_info "Enabling nested virtualization for Intel CPU"
      run_command "echo 'options kvm-intel nested=1' > /etc/modprobe.d/kvm-intel.conf" || return 1
      run_command "modprobe -r kvm_intel" || return 1
      run_command "modprobe kvm_intel nested=1" || return 1
    else
      msg_ok "Nested virtualization already enabled for Intel CPU"
    fi
  elif [[ "$cpu_vendor" == "amd" ]]; then
    if ! cat /sys/module/kvm_amd/parameters/nested | grep -q "1"; then
      msg_info "Enabling nested virtualization for AMD CPU"
      run_command "echo 'options kvm-amd nested=1' > /etc/modprobe.d/kvm-amd.conf" || return 1
      run_command "modprobe -r kvm_amd" || return 1
      run_command "modprobe kvm_amd nested=1" || return 1
    else
      msg_ok "Nested virtualization already enabled for AMD CPU"
    fi
  fi
  
  msg_ok "Nested virtualization configured. Please reboot for changes to take effect."
}

#######################################
##           BACKUP TOOLS            ##
#######################################

# Configure backup options
configure_backup() {
  display_header
  msg_info "Backup Configuration"
  
  echo "Select backup option:"
  echo "1. Configure PBS (Proxmox Backup Server) client"
  echo "2. Set up scheduled backups"
  echo "3. Configure backup retention"
  echo "4. Backup Proxmox configuration"
  echo "5. Return to main menu"
  
  read -p "Choose an option (1-5): " choice
  
  case $choice in
    1)
      configure_pbs_client
      ;;
    2)
      configure_scheduled_backups
      ;;
    3)
      configure_backup_retention
      ;;
    4)
      backup_pve_config
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

# Configure PBS client
configure_pbs_client() {
  display_header
  msg_info "PBS Client Configuration"
  
  # Check if PBS client is installed
  if ! command -v proxmox-backup-client &>/dev/null; then
    msg_info "Installing Proxmox Backup Client"
    run_command "apt update" || return 1
    run_command "apt install -y proxmox-backup-client" || return 1
  fi
  
  read -p "Enter PBS server hostname/IP: " pbs_server
  read -p "Enter datastore name: " datastore
  read -p "Enter username (format: user@realm): " username
  read -p "Enter password: " password
  
  # Create PBS client configuration file
  run_command "proxmox-backup-client config create --repository $pbs_server:$datastore --userid $username --password $password" || return 1
  
  msg_ok "PBS client configured to use $pbs_server:$datastore"
}

# Configure scheduled backups
configure_scheduled_backups() {
  display_header
  msg_info "Scheduled Backup Configuration"
  
  echo "Available storages:"
  run_command "pvesm status" || return 1
  
  read -p "Enter storage for backups: " storage
  read -p "Enter VM/CT IDs to backup (comma-separated, all for all): " vm_ids
  read -p "Enter backup schedule (e.g., 'hourly', 'daily', 'weekly'): " schedule
  read -p "Enter compression level (0-9): " compression
  read -p "Enter retention count (number of backups to keep): " retention
  
  if [[ "$vm_ids" == "all" ]]; then
    vm_parameter="all"
  else
    vm_parameter="$vm_ids"
  fi
  
  job_id=$(date +%s)
  
  run_command "cat << EOF >> /etc/pve/jobs.cfg
backup: $job_id
all: $vm_parameter
bwlimit: 0
compress: $compression
enabled: 1
mailnotification: always
mode: snapshot
pigz: 1
quiet: 0
remove: 1
schedule: $schedule
storage: $storage
stopwait: 30
EOF" || return 1
  
  msg_ok "Scheduled backup created for $vm_parameter to $storage ($schedule)"
}

# Configure backup retention
configure_backup_retention() {
  display_header
  msg_info "Backup Retention Configuration"
  
  echo "Available storages:"
  run_command "pvesm status" || return 1
  
  read -p "Enter storage to configure: " storage
  read -p "Enter maximum number of backups to keep: " maxfiles
  read -p "Enter maximum backup age in days: " maxdays
  
  run_command "pvesm set $storage --maxfiles $maxfiles --prune-backups keep-all=$maxfiles" || return 1
  
  msg_ok "Backup retention configured for $storage (max: $maxfiles backups)"
}

# Backup Proxmox configuration
backup_pve_config() {
  display_header
  msg_info "Backing up Proxmox Configuration"
  
  backup_dir="/root/pve-config-backup"
  backup_file="$backup_dir/pve-config-$(date +%Y%m%d-%H%M%S).tar.gz"
  
  if [[ ! -d "$backup_dir" ]]; then
    run_command "mkdir -p $backup_dir" || return 1
  fi
  
  # Create list of files to backup
  cat > /tmp/pve-backup-list.txt << EOF
/etc/pve
/etc/network/interfaces
/etc/hosts
/etc/hostname
/etc/resolv.conf
/etc/cron.d
/etc/crontab
/etc/modprobe.d
/var/lib/pve-firewall
/etc/apt/sources.list
/etc/apt/sources.list.d
EOF
  
  # Create the backup
  run_command "tar -czf $backup_file -T /tmp/pve-backup-list.txt" || return 1
  run_command "rm /tmp/pve-backup-list.txt" || return 1
  
  msg_ok "Proxmox configuration backed up to $backup_file"
  
  # Ask if user wants to copy to another location
  read -p "Copy backup to external location? (y/n): " copy_backup
  if [[ "$copy_backup" == "y" ]]; then
    read -p "Enter destination (e.g., '/mnt/backup', 'user@host:/path'): " destination
    
    if [[ "$destination" == *":"* ]]; then
      # Remote destination using scp
      run_command "scp $backup_file $destination" || return 1
    else
      # Local destination
      run_command "cp $backup_file $destination" || return 1
    fi
    
    msg_ok "Backup copied to $destination"
  fi
}

#######################################
##        INSTALL PVE TOOLS          ##
#######################################

# Install pvetools script (from ivanhao)
install_pvetools() {
  display_header
  msg_info "Installing pvetools from ivanhao (This script adds lots of helpful features!)"
  
  read -p "Do you want to remove the enterprise repository list? (y/n): " remove_enterprise
  if [[ "$remove_enterprise" == "y" ]]; then
    run_command "rm /etc/apt/sources.list.d/pve-enterprise.list"
  fi
  
  run_command "apt update" || return 1
  run_command "apt -y install git" || return 1
  
  if [ ! -d "pvetools" ]; then
    run_command "git clone https://github.com/ivanhao/pvetools.git" || return 1
  else
    cd pvetools
    run_command "git pull" || return 1
    cd ..
  fi
  
  cd pvetools
  msg_info "Now run the pvetools script manually:"
  echo "./pvetools.sh"
  
  msg_ok "pvetools installed (partially)! Run ./pvetools.sh inside pvetools directory to continue."
}

#######################################
##          MAIN MENU                ##
#######################################

# Function to display the main menu
main_menu() {
  while true; do
    display_header
    
    echo "Choose a category:"
    echo "===================="
    echo "1.  System Management"
    echo "2.  Network Configuration"
    echo "3.  Storage Management"
    echo "4.  VM/CT Management"
    echo "5.  Backup Tools"
    echo "6.  Install pvetools script (ivanhao)"
    echo "7.  USB Passthrough Configuration"
    echo "8.  Exit"
    echo ""
    
    read -p "Choose an option (1-8): " category
    
    case $category in
      1)
        display_header
        echo "System Management:"
        echo "===================="
        echo "1. Update System"
        echo "2. Install Essential Tools"
        echo "3. System Performance Tuning"
        echo "4. Setup Monitoring"
        echo "5. Return to Main Menu"
        echo ""
        
        read -p "Choose an option (1-5): " choice
        
        case $choice in
          1) update_system ;;
          2) install_tools ;;
          3) tune_system ;;
          4) setup_monitoring ;;
          5) continue ;;
          *) msg_error "Invalid option" ;;
        esac
        ;;
      2)
        display_header
        echo "Network Configuration:"
        echo "===================="
        echo "1. Configure Networking"
        echo "2. Configure Firewall"
        echo "3. Return to Main Menu"
        echo ""
        
        read -p "Choose an option (1-3): " choice
        
        case $choice in
          1) configure_networking ;;
          2) configure_firewall ;;
          3) continue ;;
          *) msg_error "Invalid option" ;;
        esac
        ;;
      3)
        display_header
        echo "Storage Management:"
        echo "===================="
        echo "1. Configure Storage"
        echo "2. Return to Main Menu"
        echo ""
        
        read -p "Choose an option (1-2): " choice
        
        case $choice in
          1) configure_storage ;;
          2) continue ;;
          *) msg_error "Invalid option" ;;
        esac
        ;;
      4)
        display_header
        echo "VM/CT Management:"
        echo "===================="
        echo "1. Configure VM/CT Options"
        echo "2. Return to Main Menu"
        echo ""
        
        read -p "Choose an option (1-2): " choice
        
        case $choice in
          1) configure_vm_ct ;;
          2) continue ;;
          *) msg_error "Invalid option" ;;
        esac
        ;;
      5)
        display_header
        echo "Backup Tools:"
        echo "===================="
        echo "1. Configure Backup Options"
        echo "2. Return to Main Menu"
        echo ""
        
        read -p "Choose an option (1-2): " choice
        
        case $choice in
          1) configure_backup ;;
          2) continue ;;
          *) msg_error "Invalid option" ;;
        esac
        ;;
      6)
        install_pvetools
        read -p "Press Enter to continue..."
        ;;
      7)
        configure_usb_passthrough
        ;;
      8)
        msg_ok "Exiting. Happy virtualizing! 🎉"
        exit 0
        ;;
      *)
        msg_error "Invalid option. Try again!"
        sleep 2
        ;;
    esac
  done
}

# Check if running as root
check_root

# Check if Proxmox VE is installed
check_pve

# Start the main menu
main_menu
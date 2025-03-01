# pve_setup.sh Documentation

## Overview
`pve_setup.sh` is an interactive Bash script designed to configure and manage a Proxmox VE environment. It offers options for system management, networking, storage, VM/container management, and backups, all wrapped in a user-friendly menu.

## Features
- **System Management**: Update packages, install tools, tune performance, set up monitoring.
- **Network Configuration**: Manage interfaces, firewall, and DNS.
- **Storage Management**: Configure ZFS, LVM, NFS, and SMB.
- **VM/CT Management**: Create and manage virtual machines and containers.
- **Backup Tools**: Set up scheduled backups and retention policies.
- **Logging**: Actions logged to `/var/log/pve_setup.log`.

## Prerequisites
- Run as root (`sudo` or root user).
- Proxmox VE installed (checks for `/usr/bin/pveversion`).
- `apt` package manager available.

## Usage
1. Clone the repo: `git clone https://github.com/flongstaff/devops-learning-journey.git`
2. Navigate to scripts: `cd devops-learning-journey/scripts`
3. Make executable: `chmod +x pve_setup.sh`
4. Run: `./pve_setup.sh`

## Options
- **1. System Management**: Updates system packages (e.g., `apt update && apt upgrade`).
- **2. Network Configuration**: (WIP) Configures networking options.
- **3. Storage Management**: (WIP) Sets up storage backends.
- **4. VM/CT Management**: (WIP) Manages virtual machines and containers.
- **5. Backup Tools**: (WIP) Configures backup schedules.
- **6. Exit**: Quits the script.

## Example
```bash
$ ./pve_setup.sh
# Choose "1" to update the system
# Confirm with "y" to proceed
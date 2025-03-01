🎉 Welcome to the Proxmox Playground! (aka, Let's Break Stuff Together!) 🎉

Hey there, future virtualization wizards! 👋

So, you're ready to dive into the world of Proxmox VE? Awesome! This isn't your typical "click next, next, finish" setup guide. This is a playground – a place to experiment, break things (safely!), and learn a ton. Think of it as your personal cloud lab!

🚀 What's Proxmox Anyway?

Proxmox VE is like a hypervisor supercharger for your server. It lets you run multiple virtual machines (VMs) and containers on a single piece of hardware. Think of it as a playground where you can have multiple computers running at once, without needing a room full of hardware.

🔥 Why This Guide is Different:

*   **Learn by Doing:** We won't just tell you what to do; we'll encourage you to try things out, even if it means making mistakes. Embrace the Arch way - learn by doing and customizing.
*   **Break Things (Responsibly):** VMs are like sandboxes. If you mess something up, just rebuild it!  It's all about learning through experimentation.
*   **ADHD-Friendly:** Short, sweet, and to the point. We'll break down complex tasks into bite-sized pieces.

🔨 Ready to Get Started?

Here's the basic roadmap:

1.  **Install Proxmox**: Download the ISO and install it on your server. (See the official Proxmox documentation for detailed steps.)
2.  **Configure Proxmox**: Set up networking, storage, and other essential settings.
3.  **Create VMs**: Start creating virtual machines and experimenting with different operating systems. Arch Linux on Proxmox, anyone?
4.  **Profit!** (Okay, maybe not profit, but definitely a lot of knowledge.)

✨ Supercharge Your Proxmox Setup!

Ready to take things to the next level? Check out `pve_setup.sh`! This interactive script will guide you through various setup tasks, from installing essential tools to configuring advanced features, inspired by community heroes like `tteck`.

    git clone <https://github.com/flongstaff/devops-learning-journey.git>
    cd devops-learning-journey/scripts
    chmod +x pve_setup.sh
    ./pve_setup.sh

This script will show you the commands it's running, so you can learn what's happening under the hood. Feel free to copy and paste those commands to try things manually.

📝 Create an Arch Linux VM
You need a better guide for Arch?
Check out `guides/arch_vm.md` for a detailed walkthrough!

💀 Pro-Tip: Backups are your friend! Always back up your VMs before making major changes.

💖 Community Shout-Outs

*   **tteck's Proxmox Scripts**: [https://tteck.github.io/Proxmox/](https://tteck.github.io/Proxmox/) - A huge thanks to `tteck` for their amazing scripts and contributions to the Proxmox community!

🤝 Helpful Resources

*   **Proxmox Official Documentation**: [https://pve.proxmox.com/wiki/Main_Page](https://pve.proxmox.com/wiki/Main_Page)
*   **Proxmox Community Forums**: [https://forum.proxmox.com/](https://forum.proxmox.com/)
*   **Arch Linux Wiki**: [https://wiki.archlinux.org/](https://wiki.archlinux.org/) - Your bible for all things Arch.

🚀 Dive Deeper

*   **pvetools (ivanhao)**: [https://github.com/ivanhao/pvetools](https://github.com/ivanhao/pvetools) - Useful tools for Proxmox VE.
*   **Community Scripts ProxmoxVE**: [https://github.com/community-scripts/ProxmoxVE](https://github.com/community-scripts/ProxmoxVE) - Community-contributed scripts for Proxmox VE.

🎉 Let's Do This!

Fork this repo, star it, and let's embark on this virtualization adventure together!
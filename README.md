# ComfyUI Secure Setup Script

This project provides a secure setup script for deploying [ComfyUI](https://github.com/comfyanonymous/ComfyUI) on a public GPU server. It uses Miniconda, NGINX reverse proxy, and HTTP basic authentication — with optional HTTPS via Let's Encrypt.

---

## What It Does

- Installs **Miniconda** and ComfyUI in a Conda environment
- Installs **ComfyUI-Manager** for UI-based extension management
- Installs **FFmpeg** and Python bindings for video processing
- Sets up ComfyUI as a **systemd service**
- Configures **NGINX** as a reverse proxy with HTTP basic auth
- (Optional) Enables **HTTPS** with automatic renewal via Let's Encrypt
- Optionally bind-mounts or copies models and custom_nodes from a DigitalOcean volume
- Backs up `user/default/` folder into the volume


---

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/csimokat/comfyui-secure-setup.git
cd comfyui-secure-setup
```
---

### 2. Run the setup script
```bash
chmod +x scripts/setup_comfyui_secure.sh
./scripts/setup_comfyui_secure.sh
```
	•	On the first run, the script will interactively ask you for:
	•	A username and password for authentication
	•	An optional domain for HTTPS setup
	•	An email address if using HTTPS

⚠️ Your credentials are required during this step — there is no default password.
---

### 3. Run the script again
```bash
./scripts/setup_comfyui_secure.sh
```
This will install and configure everything based on the values you provided.
---

🌐 After Installation
Access the UI: http://<your-server-ip>

Or with HTTPS: https://yourdomain.com (if you set a domain)

Login with the username and password you configured.

🧩 Use the "Manager" tab in the ComfyUI interface to install extensions — no SSH needed.

---

🛠 Requirements
- Ubuntu 20.04+ server

- FFmpeg is installed automatically — required for workflows involving video or animated output

- Open ports: 80 and 443

- (Optional) Domain name pointed to your server

---

🧰 Config File Reference
USERNAME / PASSWORD: Required for basic auth

DOMAIN: Optional — enable HTTPS with Let's Encrypt

EMAIL: Required if using DOMAIN

IMPORT_FROM_VOLUME: Set to `y` to import data from a mounted volume
BIND_MOUNT_FROM_VOLUME: Set to `y` to attempt bind-mounting instead of copying

---

🗂 Sync Script: sync_to_volume.sh

This helper script syncs your ComfyUI folders to the volume without overwriting existing content.

It copies only missing files, making it useful for incremental backups.

# Mount your DigitalOcean volume first
sudo mount /dev/disk/by-id/scsi-0DO_Volume_<yourvolume> /mnt/comfy-storage

# Run the sync script
./scripts/sync_to_volume.sh

# Unmount when done
sudo umount /mnt/comfy-storage

Folders synced:

custom_nodes/ → /mnt/comfy-storage/custom_nodes/

models/ → /mnt/comfy-storage/models/

user/default/ → /mnt/comfy-storage/user_backup/

---

🔒 Security Notes
	•	Password is securely hashed for NGINX but also stored in your .env file (consider rotating it after setup)
	•	Automatically configures HTTPS certificate renewal via certbot.timer
	•	Do not share your .env file publicly

🔥 Firewall (UFW) Setup (Optional but Recommended)

To improve security, restrict your server to only necessary ports:
```bash
# Allow SSH (port 22) and web traffic
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443

# Enable the firewall
sudo ufw enable

# Check status
sudo ufw status
```
---

🧹 Uninstalling

To cleanly remove ComfyUI and all related components, run the uninstall script:
```bash

chmod +x scripts/uninstall_comfyui.sh
./scripts/uninstall_comfyui.sh

```

This will:
	•	Stop and remove the systemd service
	•	Delete the ComfyUI install directory
	•	Remove the Conda environment
	•	Clean up NGINX config and basic auth
	•	Optionally delete your Let’s Encrypt certificate
	•	Optionally remove Miniconda and the config file
	•	Optionally remove ffmpeg from the system
 	•	If bind-mounted, you may need to unmount manually or remove any `/etc/fstab` entries
 

💡 Make sure you’re running this as the same user who installed ComfyUI.

---

🚧 Warnings:

	•	This script installs services using your current user, not root
	•	Ideal for staging or small production instances — audit before deploying in enterprise environments

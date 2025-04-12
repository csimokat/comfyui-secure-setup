# ComfyUI Secure Setup Script

This project provides a secure setup script for deploying [ComfyUI](https://github.com/comfyanonymous/ComfyUI) on a public GPU server. It uses Miniconda, NGINX reverse proxy, and HTTP basic authentication — with optional HTTPS via Let's Encrypt.

---

## What It Does

- Installs **Miniconda** and ComfyUI in a Conda environment
- Sets up ComfyUI as a **systemd service**
- Configures **NGINX** as a reverse proxy with HTTP basic auth
- (Optional) Enables **HTTPS** with automatic renewal via Let's Encrypt

---

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/yourusername/comfyui-secure-setup.git
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

---

🛠 Requirements
Ubuntu 20.04+ server

Open ports: 80 and 443

(Optional) Domain name pointed to your server

---

🧰 Config File Reference
USERNAME / PASSWORD: Required for basic auth

DOMAIN: Optional — enable HTTPS with Let's Encrypt

EMAIL: Required if using DOMAIN

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

💡 Make sure you’re running this as the same user who installed ComfyUI.

---

🚧 Warnings
	•	This script installs services using your current user, not root
	•	Ideal for staging or small production instances — audit before deploying in enterprise environments
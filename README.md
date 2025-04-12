# ComfyUI Secure Setup Script

This project provides a secure setup script for deploying [ComfyUI](https://github.com/comfyanonymous/ComfyUI) on a public GPU server. It uses Miniconda, NGINX reverse proxy, and HTTP basic authentication — with optional HTTPS via Let's Encrypt.

---

## What It Does

- Installs **Miniconda** and ComfyUI in a Conda env
- Sets up ComfyUI as a **systemd service**
- Configures **NGINX** as a reverse proxy with basic auth
- (Optional) Enables **HTTPS** if a domain is set

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
If this is your first time, the script will generate a comfyui_config.env from .env.example

---

### 3. Edit your configuration
```bash
nano -w comfyui_config.env
```
  ⚠️ Important: You must change the default password (changeme123) before proceeding!  

---

### 4. Run the script again
```bash
./scripts/setup_comfyui_secure.sh
```

---

🌐 After Installation
Access the UI: http://<your-server-ip>

Or with HTTPS: https://yourdomain.com (if you set a domain)

Login with the username and password you configured.

🛠 Requirements
Ubuntu 20.04+ server

Open ports: 80 and 443

(Optional) Domain name pointed to your server

🧰 Config File Reference
USERNAME / PASSWORD: Required for basic auth

DOMAIN: Optional — enable HTTPS with Let's Encrypt

EMAIL: Required if using DOMAIN

🛑 Warnings
Do not use the default password

This script installs services as your user, not root

Test this on a staging server before deploying in production
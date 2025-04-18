#!/bin/bash
set -euo pipefail
trap 'echo "[!] Error at line $LINENO. Exiting."' ERR

CONFIG_FILE="./comfyui_config.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[!] Config file not found. Can't proceed with uninstall."
  exit 1
fi

# Load config values
export $(grep -v '^#' "$CONFIG_FILE" | xargs)

echo "[*] Uninstalling ComfyUI..."

# 1. Stop and remove the systemd service
echo "[*] Removing systemd service..."
sudo systemctl stop comfyui || true
sudo systemctl disable comfyui || true
sudo rm -f /etc/systemd/system/comfyui.service
sudo systemctl daemon-reload

# 2. Remove ComfyUI install directory
echo "[*] Deleting ComfyUI directory..."
rm -rf "$COMFY_DIR"

# 3. Remove Conda environment
echo "[*] Removing Conda environment..."
source "$HOME/miniconda/etc/profile.d/conda.sh"
conda deactivate || true
conda env remove -n "$COMFY_ENV_NAME" || true

# 4. Clean up NGINX
echo "[*] Removing NGINX config and basic auth..."
sudo rm -f /etc/nginx/sites-enabled/comfyui
sudo rm -f /etc/nginx/sites-available/comfyui
sudo rm -f /etc/nginx/.htpasswd
sudo nginx -t && sudo systemctl reload nginx

# 5. Remove Let's Encrypt certs (if applicable)
if [[ -n "${DOMAIN:-}" ]]; then
  echo "[*] Removing Let's Encrypt certificate for $DOMAIN..."
  sudo certbot delete --cert-name "$DOMAIN" || true
fi

# 6. (Optional) Remove Miniconda (ask user)
read -p "Remove Miniconda completely? [y/N]: " REMOVE_CONDA
if [[ "$REMOVE_CONDA" == "y" || "$REMOVE_CONDA" == "Y" ]]; then
  echo "[*] Removing Miniconda..."
  rm -rf ~/miniconda ~/.conda ~/.condarc ~/.continuum
fi

# 7. Remove config file
read -p "Remove config file ($CONFIG_FILE)? [y/N]: " REMOVE_CONFIG
if [[ "$REMOVE_CONFIG" == "y" || "$REMOVE_CONFIG" == "Y" ]]; then
  rm -f "$CONFIG_FILE"
fi

# (Optional) Remove ffmpeg
read -p "Remove ffmpeg system package? [y/N]: " REMOVE_FFMPEG
if [[ "$REMOVE_FFMPEG" == "y" || "$REMOVE_FFMPEG" == "Y" ]]; then
  echo "[*] Removing ffmpeg..."
  sudo apt-get remove --purge -y ffmpeg
fi

echo ""
echo "✅ Uninstall complete."
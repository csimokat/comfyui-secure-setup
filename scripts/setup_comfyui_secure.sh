#!/bin/bash
set -e

CONFIG_FILE="./comfyui_config.env"

# === Generate a default config if missing ===
generate_config() {
  cat <<EOF > "$CONFIG_FILE"
# === ComfyUI Setup Configuration ===

# ComfyUI environment
COMFY_ENV_NAME="comfyui-env"
COMFY_PORT=8188
COMFY_DIR="/opt/ComfyUI"

# Authentication (REQUIRED: change the default password!)
USERNAME="admin"
PASSWORD="changeme123"  # CHANGE THIS BEFORE RUNNING!

# Optional domain setup (for HTTPS)
DOMAIN=""
EMAIL="your-email@example.com"  # Required if DOMAIN is set
EOF
}

# === Validate configuration ===
validate_config() {
  if [[ "$PASSWORD" == "changeme123" ]]; then
    echo " Please set a secure password in $CONFIG_FILE before running this script."
    exit 1
  fi

  if [[ -n "$DOMAIN" && -z "$EMAIL" ]]; then
    echo " EMAIL is required if DOMAIN is set for HTTPS."
    exit 1
  fi

  if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$COMFY_ENV_NAME" || -z "$COMFY_PORT" || -z "$COMFY_DIR" ]]; then
    echo " One or more required config values are missing."
    exit 1
  fi
}

# === Load config from .env-style file ===
load_config() {
  export $(grep -v '^#' "$CONFIG_FILE" | xargs)
}

# === START SCRIPT ===
echo " Starting ComfyUI secure setup..."

if [ ! -f "$CONFIG_FILE" ]; then
  echo " Config file not found. Generating template at $CONFIG_FILE..."
  generate_config
  echo "  Please edit $CONFIG_FILE before re-running this script."
  exit 1
fi

load_config
validate_config

# === Install Miniconda ===
echo "[*] Installing Miniconda..."
cd /tmp
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
eval "$($HOME/miniconda/bin/conda shell.bash hook)"
conda init
source ~/.bashrc

# === Create Conda Environment ===
echo "[*] Creating Conda environment '$COMFY_ENV_NAME'..."
conda create -y -n "$COMFY_ENV_NAME" python=3.10
conda activate "$COMFY_ENV_NAME"

# === Install ComfyUI ===
echo "[*] Installing ComfyUI to $COMFY_DIR..."
git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"
cd "$COMFY_DIR"
pip install -r requirements.txt

# === Set up systemd service ===
echo "[*] Creating systemd service for ComfyUI..."
cat <<EOF | sudo tee /etc/systemd/system/comfyui.service
[Unit]
Description=ComfyUI Web UI
After=network.target

[Service]
User=$USER
WorkingDirectory=$COMFY_DIR
ExecStart=$HOME/miniconda/envs/$COMFY_ENV_NAME/bin/python3 main.py --listen 0.0.0.0 --port $COMFY_PORT
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable comfyui
sudo systemctl start comfyui

# === Install NGINX + Basic Auth ===
echo "[*] Installing NGINX and basic auth tools..."
sudo apt update
sudo apt install -y nginx apache2-utils

echo "[*] Creating HTTP basic auth user..."
sudo htpasswd -bc /etc/nginx/.htpasswd "$USERNAME" "$PASSWORD"

# === Configure NGINX ===
echo "[*] Writing NGINX config..."
NGINX_CONF="/etc/nginx/sites-available/comfyui"
cat <<EOF | sudo tee "$NGINX_CONF"
server {
    listen 80;
    server_name ${DOMAIN:-_};

    location / {
        proxy_pass http://127.0.0.1:$COMFY_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;

        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF

sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/comfyui
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx

# === HTTPS via Let's Encrypt (optional) ===
if [[ -n "$DOMAIN" ]]; then
  echo "[*] Setting up HTTPS for $DOMAIN..."
  sudo apt install -y certbot python3-certbot-nginx
  sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL"
fi

# === Done ===
echo ""
echo " ComfyUI is installed and protected!"
echo " Access it at: http://${DOMAIN:-<your-server-ip>}"
[[ -n "$DOMAIN" ]] && echo " HTTPS enabled: https://$DOMAIN"
echo " Login with: $USERNAME / (your password)"
#!/bin/bash
set -euo pipefail

# Modify this if needed
COMFY_DIR="/opt/ComfyUI"
VOLUME_PATH="/mnt/comfy-storage"

echo "[*] Syncing ComfyUI folders to volume at $VOLUME_PATH..."

# Ensure volume is mounted
if ! mount | grep -q "$VOLUME_PATH"; then
  echo "[!] Volume at $VOLUME_PATH is not mounted."
  exit 1
fi

# Helper function to copy only missing files
sync_folder() {
  SRC="$1"
  DEST="$2"
  LABEL="$3"

  if [ ! -d "$SRC" ]; then
    echo "[-] Skipping $LABEL (source folder not found: $SRC)"
    return
  fi

  echo "[+] Syncing $LABEL..."
  mkdir -p "$DEST"
  rsync -av --ignore-existing "$SRC/" "$DEST/"
}

sync_folder "$COMFY_DIR/custom_nodes" "$VOLUME_PATH/custom_nodes" "custom_nodes"
sync_folder "$COMFY_DIR/models" "$VOLUME_PATH/models" "models"
sync_folder "$COMFY_DIR/user/default" "$VOLUME_PATH/user_backup" "user/default"

echo "[✓] Sync complete."

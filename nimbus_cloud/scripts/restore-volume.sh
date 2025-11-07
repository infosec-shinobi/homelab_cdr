#!/bin/bash
set -euo pipefail

# -------------------------------------------------------------------
# NimbusGuard Volume Restore Utility
# -------------------------------------------------------------------
# Interactively restores a Docker volume from a backup archive.
#
# Usage:
#   ./scripts/restore-volume.sh [backup-directory]
#
# Example:
#   ./scripts/restore-volume.sh /mnt/backups/nimbusguard
# -------------------------------------------------------------------

BACKUP_DIR=${1:-./backups}

# Ensure directory exists
if [ ! -d "$BACKUP_DIR" ]; then
  echo "❌ Backup directory not found: $BACKUP_DIR"
  exit 1
fi

echo "🔁 NimbusGuard Volume Restore Utility"
echo "Backup source: $BACKUP_DIR"
echo "----------------------------------------------------"

# List available backups
echo "📦 Available backups:"
mapfile -t BACKUPS < <(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null || true)

if [ ${#BACKUPS[@]} -eq 0 ]; then
  echo "❌ No backup archives found in $BACKUP_DIR"
  exit 1
fi

# Display numbered list
i=1
for b in "${BACKUPS[@]}"; do
  echo "  [$i] $(basename "$b")"
  ((i++))
done

# Ask user which backup to restore
echo
read -rp "Enter number of the backup to restore: " SELECTION
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "${#BACKUPS[@]}" ]; then
  echo "❌ Invalid selection."
  exit 1
fi

SELECTED_BACKUP="${BACKUPS[$((SELECTION - 1))]}"
BASENAME=$(basename "$SELECTED_BACKUP")
VOLUME_NAME=$(echo "$BASENAME" | sed 's/-[0-9]\{8\}-[0-9]\{6\}\.tar\.gz//' | sed 's/\.tar\.gz$//')

echo
echo "🧩 Selected backup: $BASENAME"
echo "🪣 Target volume:   $VOLUME_NAME"
echo "----------------------------------------------------"

# Confirm restoration
read -rp "⚠️  This will overwrite existing data in ${VOLUME_NAME}. Proceed? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "❌ Aborted by user."
  exit 0
fi

# Stop stack to ensure data integrity
echo "⏹️  Stopping running containers..."
docker compose down >/dev/null 2>&1 || true

# Remove existing volume if it exists
if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
  echo "🗑️  Removing existing volume: $VOLUME_NAME"
  docker volume rm "$VOLUME_NAME" >/dev/null
fi

# Recreate the volume
echo "📦 Creating volume: $VOLUME_NAME"
docker volume create "$VOLUME_NAME" >/dev/null

# Extract backup into the volume
echo "📂 Restoring backup contents..."
docker run --rm \
  -v "$VOLUME_NAME:/volume" \
  -v "$BACKUP_DIR:/backup" \
  alpine:latest \
  sh -c "cd /volume && tar xzf /backup/$(basename "$SELECTED_BACKUP")"

echo "✅ Restore complete for volume: $VOLUME_NAME"

# Optionally restart stack
read -rp "🔄 Restart Docker Compose stack now? (Y/n): " RESTART
if [[ ! "$RESTART" =~ ^[Nn]$ ]]; then
  docker compose up -d
  echo "🚀 Stack restarted successfully."
else
  echo "🧱 Stack not restarted. You can start it manually with:"
  echo "    docker compose up -d"
fi

echo
echo "🎉 Volume restoration complete!"

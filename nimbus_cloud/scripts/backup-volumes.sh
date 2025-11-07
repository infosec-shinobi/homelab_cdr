#!/bin/bash
set -euo pipefail

# -------------------------------------------------------------------
# NimbusGuard Volume Backup Utility
# -------------------------------------------------------------------
# This script backs up all persistent Docker volumes used by the
# NimbusGuard stack. It’s designed for simple offline volume snapshots.
#
# Usage:
#   ./backup-volume.sh [backup-directory]
#
# Example:
#   ./backup-volume.sh /mnt/backups/nimbusguard
# -------------------------------------------------------------------

# === CONFIGURATION ===
BACKUP_DIR=${1:-./backups}
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Volumes to back up (must match your docker-compose.yml)
VOLUMES=(
  wazuh-indexer-data
  wazuh-manager-data
  tracecat-data
  n8n-data
  cloudquery-data
  prowler-reports
  prometheus-data
  grafana-data
)

# Keep last N backups per volume (set to 0 to disable cleanup)
RETENTION_COUNT=5

echo "🔄 NimbusGuard Volume Backup - $(date)"
echo "Destination: ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

# Check Docker availability
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker is not running or accessible. Please start Docker first."
  exit 1
fi

# -------------------------------------------------------------------
# Perform backup for each volume
# -------------------------------------------------------------------
for VOLUME in "${VOLUMES[@]}"; do
  echo "📦 Backing up volume: ${VOLUME} ..."
  ARCHIVE_NAME="${VOLUME}-${TIMESTAMP}.tar.gz"
  ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

  # Create a temporary container to read the volume contents
  docker run --rm \
    -v "${VOLUME}:/volume" \
    -v "${BACKUP_DIR}:/backup" \
    alpine:latest \
    sh -c "cd /volume && tar czf /backup/${ARCHIVE_NAME} ."

  echo "✅ Created ${ARCHIVE_PATH}"

  # Optional retention cleanup
  if [ "$RETENTION_COUNT" -gt 0 ]; then
    OLD_BACKUPS=($(ls -t "${BACKUP_DIR}/${VOLUME}-"*.tar.gz 2>/dev/null || true))
    if [ "${#OLD_BACKUPS[@]}" -gt "$RETENTION_COUNT" ]; then
      TO_DELETE=("${OLD_BACKUPS[@]:$RETENTION_COUNT}")
      for OLD in "${TO_DELETE[@]}"; do
        echo "🧹 Removing old backup: $(basename "$OLD")"
        rm -f "$OLD"
      done
    fi
  fi
done

echo "🎉 Backup completed successfully!"
echo "All archives saved under: ${BACKUP_DIR}"

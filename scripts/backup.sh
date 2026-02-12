#!/bin/sh
set -e

BACKUP_DIR="/backups"
DATE=$(date -u +%Y-%m-%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/dnd_backup_${DATE}.sql.gz"
STATE_BACKUP="${BACKUP_DIR}/dnd_state_${DATE}.tar.gz"

echo "[$(date -u)] Starting backup..."

# Backup PostgreSQL database
echo "[$(date -u)] Dumping database..."
pg_dump -h db -U "${POSTGRES_USER}" "${POSTGRES_DB}" | gzip > "${BACKUP_FILE}"

# Backup game state files (campaigns, characters, etc.)
echo "[$(date -u)] Archiving game state..."
if [ -d "/data" ] && [ "$(ls -A /data)" ]; then
    tar -czf "${STATE_BACKUP}" -C /data .
    echo "[$(date -u)] Game state backed up"
else
    echo "[$(date -u)] No game state files to backup"
fi

# Clean up old backups (keep last 7 days)
echo "[$(date -u)] Cleaning up old backups..."
find "${BACKUP_DIR}" -name "dnd_backup_*.sql.gz" -type f -mtime +7 -delete
find "${BACKUP_DIR}" -name "dnd_state_*.tar.gz" -type f -mtime +7 -delete

echo "[$(date -u)] Backup complete:"
echo "  Database: ${BACKUP_FILE}"
ls -lh "${BACKUP_FILE}" 2>/dev/null || echo "    (size not available)"
if [ -f "${STATE_BACKUP}" ]; then
    echo "  State: ${STATE_BACKUP}"
    ls -lh "${STATE_BACKUP}" 2>/dev/null || echo "    (size not available)"
fi

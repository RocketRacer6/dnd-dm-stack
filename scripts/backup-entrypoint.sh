#!/bin/sh
set -e

# Convert CST backup time to UTC based on TZ environment
# We'll run every hour and check if it's backup time
while true; do
    CURRENT_HOUR=$(date -u +%H)
    CURRENT_MINUTE=$(date -u +%M)

    # 23:59 CST = 05:59 UTC (next day)
    if [ "$CURRENT_HOUR" = "05" ] && [ "$CURRENT_MINUTE" = "59" ]; then
        echo "[$(date -u)] Starting daily backup..."

        # Stop bot to ensure clean state
        echo "[$(date -u)] Stopping bot container..."
        docker stop dnd-dm-bot || true

        # Run backup
        /scripts/backup.sh

        # Restart bot
        echo "[$(date -u)] Restarting bot container..."
        docker start dnd-dm-bot || true

        echo "[$(date -u)] Backup complete. Sleeping until next cycle..."

        # Sleep until we're past the backup minute
        sleep 120
    fi

    # Check every minute
    sleep 60
done

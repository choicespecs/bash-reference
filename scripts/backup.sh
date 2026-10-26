#!/usr/bin/env bash
#
# backup.sh — Create a timestamped .tar.gz backup and prune old ones.
#
# Usage: backup.sh <source_dir> <backup_dir> [keep_count]
#   keep_count  Number of most recent backups to keep (default: 7)
#
# Example (cron, daily at 2am):
#   0 2 * * * /path/to/backup.sh "$HOME/Documents" /mnt/backups 14

set -euo pipefail

SRC="${1:?Usage: backup.sh <source_dir> <backup_dir> [keep_count]}"
DEST="${2:?Usage: backup.sh <source_dir> <backup_dir> [keep_count]}"
KEEP="${3:-7}"

[[ -d "$SRC" ]] || { echo "Source not found: $SRC" >&2; exit 1; }
mkdir -p "$DEST"

name="$(basename "$SRC")"
stamp="$(date +%Y%m%d-%H%M%S)"
archive="$DEST/${name}-${stamp}.tar.gz"

echo "Backing up $SRC -> $archive"
tar -czf "$archive" -C "$(dirname "$SRC")" "$name"
echo "Done: $(du -h "$archive" | cut -f1)"

# Prune: list newest first, skip the first $KEEP, delete the rest.
count=0
while IFS= read -r old; do
  count=$((count + 1))
  if (( count > KEEP )); then
    echo "Removing old backup: $old"
    rm -f -- "$old"
  fi
done < <(ls -1t "$DEST/${name}-"*.tar.gz 2>/dev/null)

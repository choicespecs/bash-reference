#!/usr/bin/env bash
#
# disk-usage-alert.sh — Warn when any mounted filesystem exceeds a usage threshold.
#
# Usage: disk-usage-alert.sh [threshold_percent]   (default: 80)
# Exit code: 0 = all OK, 1 = at least one filesystem over threshold
#
# Example (cron, hourly, email on failure):
#   0 * * * * /path/to/disk-usage-alert.sh 90 || mail -s "Disk alert" you@example.com

set -euo pipefail

THRESHOLD="${1:-80}"
alert=0

# -P = POSIX output (one line per filesystem, stable columns)
while read -r fs _size _used _avail pct mount; do
  case "$fs" in devfs|tmpfs|devtmpfs|overlay|map*) continue ;; esac   # skip pseudo filesystems
  usage="${pct%\%}"                 # strip trailing %
  [[ "$usage" =~ ^[0-9]+$ ]] || continue
  if (( usage >= THRESHOLD )); then
    printf 'ALERT: %-30s %3s%% used (%s)\n' "$mount" "$usage" "$fs"
    alert=1
  else
    printf 'ok:    %-30s %3s%% used\n' "$mount" "$usage"
  fi
done < <(df -P | tail -n +2)

exit "$alert"

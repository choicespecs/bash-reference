#!/usr/bin/env bash
#
# log-analyzer.sh — Summarize a web server access log (Apache/Nginx combined format).
#
# Usage: log-analyzer.sh <access.log> [top_n]
#
# Shows: total requests, unique IPs, top IPs, top paths, status code breakdown,
# and the most common 404 paths. Works on .gz logs too.

set -euo pipefail

LOG="${1:?Usage: log-analyzer.sh <access.log> [top_n]}"
TOP="${2:-10}"

[[ -r "$LOG" ]] || { echo "Cannot read $LOG" >&2; exit 1; }

# Read plain or gzipped logs transparently.
reader() { if [[ "$LOG" == *.gz ]]; then gzip -dc "$LOG"; else cat "$LOG"; fi; }

section() { printf '\n== %s ==\n' "$1"; }

section "Overview"
echo "Total requests: $(reader | wc -l | tr -d ' ')"
echo "Unique IPs:     $(reader | awk '{print $1}' | sort -u | wc -l | tr -d ' ')"

section "Top $TOP IPs"
reader | awk '{print $1}' | sort | uniq -c | sort -rn | head -n "$TOP"

section "Top $TOP requested paths"
reader | awk '{print $7}' | sort | uniq -c | sort -rn | head -n "$TOP"

section "Status codes"
reader | awk '$9 ~ /^[0-9][0-9][0-9]$/ {print $9}' | sort | uniq -c | sort -rn

section "Top $TOP 404s"
reader | awk '$9 == 404 {print $7}' | sort | uniq -c | sort -rn | head -n "$TOP"

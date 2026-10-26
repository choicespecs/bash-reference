#!/usr/bin/env bash
#
# find-large-files.sh — List the largest files under a directory.
#
# Usage: find-large-files.sh [dir] [count] [min_size]
#   dir       Where to search (default: .)
#   count     How many results to show (default: 20)
#   min_size  find(1) size filter (default: +10M). Examples: +100M, +1G
#
# Example: find-large-files.sh ~ 10 +500M

set -euo pipefail

DIR="${1:-.}"
COUNT="${2:-20}"
MIN="${3:-+10M}"

echo "Top $COUNT files larger than ${MIN#+} in $DIR:"
echo

# du -k prints size in KB — portable across macOS and Linux.
find "$DIR" -type f -size "$MIN" -print0 2>/dev/null \
  | xargs -0 du -k 2>/dev/null \
  | sort -rn \
  | head -n "$COUNT" \
  | awk '{
      size = $1; $1 = "";
      if (size >= 1048576) printf "%8.1f GB %s\n", size/1048576, $0;
      else                 printf "%8.1f MB %s\n", size/1024, $0;
    }'

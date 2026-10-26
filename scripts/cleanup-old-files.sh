#!/usr/bin/env bash
#
# cleanup-old-files.sh — Delete files older than N days (dry run by default).
#
# Usage: cleanup-old-files.sh [-f] [-p PATTERN] <dir> <days>
#   -f          Actually delete (without it, only lists what would be deleted)
#   -p PATTERN  Only match file names like PATTERN (e.g. '*.log')
#
# Example: cleanup-old-files.sh -f -p '*.log' /var/log/myapp 30

set -euo pipefail

FORCE=0
PATTERN="*"

while getopts ":fp:" opt; do
  case "$opt" in
    f) FORCE=1 ;;
    p) PATTERN="$OPTARG" ;;
    *) echo "Usage: $0 [-f] [-p PATTERN] <dir> <days>" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

DIR="${1:?missing <dir>}"
DAYS="${2:?missing <days>}"

[[ -d "$DIR" ]] || { echo "Not a directory: $DIR" >&2; exit 1; }
[[ "$DAYS" =~ ^[0-9]+$ ]] || { echo "<days> must be a number" >&2; exit 1; }

total=0
while IFS= read -r -d '' file; do
  total=$((total + 1))
  if (( FORCE )); then
    rm -f -- "$file" && echo "deleted: $file"
  else
    echo "would delete: $file"
  fi
done < <(find "$DIR" -type f -name "$PATTERN" -mtime +"$DAYS" -print0)

if (( FORCE )); then
  echo "Deleted $total file(s)."
else
  echo "$total file(s) matched. Re-run with -f to delete."
fi

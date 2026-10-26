#!/usr/bin/env bash
#
# healthcheck.sh — Check that a list of URLs respond with HTTP 2xx/3xx.
#
# Usage: healthcheck.sh <url>...
#        healthcheck.sh -f urls.txt      # one URL per line, # comments allowed
#
# Exit code is the number of failing URLs (0 = all healthy).

set -uo pipefail

TIMEOUT="${TIMEOUT:-10}"
urls=()

if [[ "${1:-}" == "-f" ]]; then
  file="${2:?missing file after -f}"
  while IFS= read -r line; do
    line="${line%%#*}"                # strip comments
    line="${line//[[:space:]]/}"      # strip whitespace
    [[ -n "$line" ]] && urls+=("$line")
  done < "$file"
else
  urls=("$@")
fi

(( ${#urls[@]} )) || { echo "Usage: $0 <url>... | -f file" >&2; exit 64; }

fails=0
for url in "${urls[@]}"; do
  # -w prints status code and total time; -o discards the body.
  result="$(curl -s -o /dev/null -L --max-time "$TIMEOUT" \
            -w '%{http_code} %{time_total}' "$url" 2>/dev/null)" || true
  code="${result%% *}"
  time="${result##* }"

  if [[ "$code" =~ ^[23] ]]; then
    printf '✅ %-45s %s  %ss\n' "$url" "$code" "$time"
  else
    printf '❌ %-45s %s\n' "$url" "${code:-ERR}"
    fails=$((fails + 1))
  fi
done

exit "$fails"

#!/usr/bin/env bash
#
# retry.sh — Run a command until it succeeds, with exponential backoff.
#
# Usage: retry.sh [-n attempts] [-d initial_delay] -- <command> [args...]
#
# Example: retry.sh -n 5 -d 2 -- curl -fsS https://example.com/api/health
#          (waits 2s, 4s, 8s, 16s between attempts)

set -uo pipefail

ATTEMPTS=5
DELAY=1

while getopts ":n:d:" opt; do
  case "$opt" in
    n) ATTEMPTS="$OPTARG" ;;
    d) DELAY="$OPTARG" ;;
    *) echo "Usage: $0 [-n attempts] [-d delay] -- command" >&2; exit 64 ;;
  esac
done
shift $((OPTIND - 1))
[[ "${1:-}" == "--" ]] && shift
(( $# )) || { echo "No command given" >&2; exit 64; }

for (( i = 1; i <= ATTEMPTS; i++ )); do
  "$@" && exit 0
  status=$?
  if (( i == ATTEMPTS )); then
    echo "Failed after $ATTEMPTS attempts (last exit code: $status)" >&2
    exit "$status"
  fi
  echo "Attempt $i/$ATTEMPTS failed (exit $status). Retrying in ${DELAY}s..." >&2
  sleep "$DELAY"
  DELAY=$((DELAY * 2))
done

#!/usr/bin/env bash
#
# script-template.sh — A robust starting point for new Bash scripts.
#
# Usage: script-template.sh [-h] [-v] [-o OUTPUT] <input>...
#
# Copy this file, rename it, and replace the main() body with your logic.

set -euo pipefail      # exit on error, unset vars, and failures inside pipes
IFS=$'\n\t'            # safer word splitting (no splitting on spaces)

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VERBOSE=0
OUTPUT=""

usage() {
  cat <<USAGE
Usage: $SCRIPT_NAME [-h] [-v] [-o OUTPUT] <input>...

Options:
  -h          Show this help and exit
  -v          Verbose output
  -o OUTPUT   Write results to OUTPUT instead of stdout
USAGE
}

log()  { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >&2; }
info() { log "INFO  $*"; }
warn() { log "WARN  $*"; }
die()  { log "ERROR $*"; exit 1; }
debug() { [[ $VERBOSE -eq 1 ]] && log "DEBUG $*" || true; }

cleanup() {
  # Runs on every exit — remove temp files, release locks, etc.
  [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT
trap 'die "Interrupted"' INT TERM

parse_args() {
  while getopts ":hvo:" opt; do
    case "$opt" in
      h) usage; exit 0 ;;
      v) VERBOSE=1 ;;
      o) OUTPUT="$OPTARG" ;;
      :) die "Option -$OPTARG requires an argument" ;;
      \?) die "Unknown option: -$OPTARG (see -h)" ;;
    esac
  done
  shift $((OPTIND - 1))

  [[ $# -ge 1 ]] || { usage; exit 1; }
  INPUTS=("$@")
}

main() {
  parse_args "$@"
  TMP_DIR="$(mktemp -d)"
  debug "Script dir: $SCRIPT_DIR"
  debug "Temp dir:   $TMP_DIR"

  for input in "${INPUTS[@]}"; do
    info "Processing $input"
    # ... your logic here ...
  done

  if [[ -n "$OUTPUT" ]]; then
    echo "done" > "$OUTPUT"
    info "Wrote $OUTPUT"
  fi
}

main "$@"

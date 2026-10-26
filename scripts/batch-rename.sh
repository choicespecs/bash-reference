#!/usr/bin/env bash
#
# batch-rename.sh — Rename files in a directory using find/replace,
# lowercase, or a sequential numbered prefix.
#
# Usage:
#   batch-rename.sh replace <dir> <find> <replace>   # "IMG_" -> "photo_"
#   batch-rename.sh lower   <dir>                    # "My File.JPG" -> "my file.jpg"
#   batch-rename.sh spaces  <dir>                    # "my file.txt" -> "my_file.txt"
#   batch-rename.sh number  <dir> [prefix]           # -> prefix_001.ext, prefix_002.ext
#
# Set DRY_RUN=1 to preview changes:  DRY_RUN=1 batch-rename.sh lower ./pics

set -euo pipefail

mode="${1:?mode required: replace|lower|spaces|number}"
dir="${2:?directory required}"
cd "$dir"

do_mv() {
  local from="$1" to="$2"
  [[ "$from" == "$to" ]] && return
  # -ef: same file — true for case-only renames on case-insensitive filesystems (macOS)
  if [[ -e "$to" && ! "$from" -ef "$to" ]]; then
    echo "skip (exists): $to" >&2
    return
  fi
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    echo "[dry-run] $from -> $to"
  else
    # Two-step move so case-only renames work everywhere
    mv -- "$from" "$from.renaming.$$" && mv -- "$from.renaming.$$" "$to" && echo "$from -> $to"
  fi
}

case "$mode" in
  replace)
    find="${3:?find string required}"
    repl="${4-}"
    for f in *"$find"*; do
      [[ -f "$f" ]] && do_mv "$f" "${f//"$find"/$repl}"
    done
    ;;
  lower)
    for f in *; do
      [[ -f "$f" ]] && do_mv "$f" "$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')"
    done
    ;;
  spaces)
    for f in *\ *; do
      [[ -f "$f" ]] && do_mv "$f" "${f// /_}"
    done
    ;;
  number)
    prefix="${3:-file}"
    i=1
    for f in *; do
      [[ -f "$f" ]] || continue
      ext=""
      [[ "$f" == *.* ]] && ext=".${f##*.}"
      do_mv "$f" "$(printf '%s_%03d%s' "$prefix" "$i" "$ext")"
      i=$((i + 1))
    done
    ;;
  *)
    echo "Unknown mode: $mode" >&2
    exit 1
    ;;
esac

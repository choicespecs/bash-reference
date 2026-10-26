#!/usr/bin/env bash
#
# git-update-all.sh — Run `git pull` in every Git repository under a directory.
#
# Usage: git-update-all.sh [parent_dir]   (default: current directory)
#
# Skips repos with uncommitted changes so nothing gets clobbered,
# and prints a summary at the end.

set -uo pipefail   # no -e: one failing repo shouldn't stop the rest

PARENT="${1:-.}"
updated=() skipped=() failed=()

for gitdir in "$PARENT"/*/.git; do
  [[ -d "$gitdir" ]] || continue
  repo="$(dirname "$gitdir")"
  name="$(basename "$repo")"

  if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
    echo "⏭  $name: has local changes, skipping"
    skipped+=("$name")
    continue
  fi

  branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD)"
  echo "⬇  $name ($branch)"
  if git -C "$repo" pull --ff-only --quiet; then
    updated+=("$name")
  else
    echo "   ✗ pull failed"
    failed+=("$name")
  fi
done

echo
echo "Updated: ${#updated[@]}  Skipped: ${#skipped[@]}  Failed: ${#failed[@]}"
(( ${#failed[@]} == 0 )) || { printf '  failed: %s\n' "${failed[@]}"; exit 1; }

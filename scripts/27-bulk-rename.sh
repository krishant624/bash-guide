#!/usr/bin/env bash
# 27-bulk-rename.sh — Rename *.txt files to lowercase with optional dry-run
# Usage: ./27-bulk-rename.sh DIR [--apply]
# Default is dry-run (prints planned renames only).
set -euo pipefail

[[ $# -ge 1 ]] || { echo "Usage: $0 DIR [--apply]" >&2; exit 2; }
dir=$1
apply=0
[[ ${2:-} == --apply ]] && apply=1
[[ -d $dir ]] || { echo "Not a directory: $dir" >&2; exit 1; }

shopt -s nullglob
for f in "$dir"/*.txt; do
  base=$(basename "$f")
  lower=${base,,}
  [[ $base == "$lower" ]] && continue
  target="$dir/$lower"
  if [[ -e $target ]]; then
    printf 'SKIP (exists): %s -> %s\n' "$base" "$lower" >&2
    continue
  fi
  if ((apply)); then
    mv -- "$f" "$target"
    printf 'RENAMED: %s -> %s\n' "$base" "$lower"
  else
    printf 'DRY-RUN: %s -> %s\n' "$base" "$lower"
  fi
done

#!/usr/bin/env bash
# 24-backup.sh — Backup a directory with dated archives and simple rotation
# Usage: ./24-backup.sh SOURCE_DIR DEST_DIR [KEEP]
# Example: ./24-backup.sh "$HOME/docs" "$HOME/backups" 5
set -euo pipefail

usage() {
  cat <<'EOF' >&2
Usage: 24-backup.sh SOURCE_DIR DEST_DIR [KEEP]
  SOURCE_DIR  Directory to archive
  DEST_DIR    Where to store .tar.gz backups
  KEEP        Number of newest backups to keep (default: 7)
EOF
  exit 2
}

[[ $# -ge 2 ]] || usage
src=$(readlink -f "$1")
dest=$(readlink -f "$2")
keep=${3:-7}
stamp=$(date +%Y%m%d-%H%M%S)
name=$(basename "$src")
archive="${dest}/${name}-${stamp}.tar.gz"
log="${dest}/backup.log"

mkdir -p "$dest"
{
  printf '[%s] START backup %s -> %s\n' "$(date -Iseconds)" "$src" "$archive"
  tar -czf "$archive" -C "$(dirname "$src")" "$name"
  printf '[%s] OK size=%s\n' "$(date -Iseconds)" "$(du -h "$archive" | awk '{print $1}')"
  mapfile -t old < <(ls -1t "${dest}/${name}-"*.tar.gz 2>/dev/null || true)
  if ((${#old[@]} > keep)); then
    for f in "${old[@]:keep}"; do
      rm -f -- "$f"
      printf '[%s] rotated away %s\n' "$(date -Iseconds)" "$f"
    done
  fi
} | tee -a "$log"

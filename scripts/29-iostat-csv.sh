#!/usr/bin/env bash
# 29-iostat-csv.sh — Capture a few iostat/df samples into CSV for trending
# Usage: ./29-iostat-csv.sh OUT.csv [SAMPLES] [INTERVAL_SEC]
# Requires: iostat (sysstat). Falls back to df-only rows if iostat missing.
set -euo pipefail

[[ $# -ge 1 ]] || { echo "Usage: $0 OUT.csv [SAMPLES] [INTERVAL_SEC]" >&2; exit 2; }
out=$1
samples=${2:-3}
interval=${3:-2}

mkdir -p "$(dirname "$out")"
if [[ ! -s $out ]]; then
  printf 'timestamp,metric,device,value\n' >"$out"
fi

for ((i = 1; i <= samples; i++)); do
  ts=$(date -Iseconds)
  df -P | awk -v ts="$ts" 'NR>1 && $1 ~ /^\// {gsub(/%/,"",$5); printf "%s,df_used_pct,%s,%s\n", ts, $6, $5}' >>"$out"
  if command -v iostat >/dev/null 2>&1; then
    # device util% from iostat -x (skip header lines)
    iostat -xd 1 2 | awk -v ts="$ts" '
      /^Device/ {hdr=1; next}
      hdr && NF>1 && $1!="Device" {print ts",iostat_util_pct,"$1","$NF; hdr=0}
    ' >>"$out" || true
  fi
  ((i < samples)) && sleep "$interval"
done

printf 'Wrote %s samples to %s\n' "$samples" "$out"

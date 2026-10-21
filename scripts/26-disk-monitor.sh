#!/usr/bin/env bash
# 26-disk-monitor.sh — Alert when any mounted filesystem exceeds a threshold
# Usage: ./26-disk-monitor.sh [THRESHOLD_PERCENT]
# Prints ALERT lines to stderr and exits 1 if any filesystem is over threshold.
set -euo pipefail

threshold=${1:-85}
alert=0

while read -r fs size used avail pct mount; do
  [[ $fs == Filesystem || $fs == tmpfs || $fs == overlay || $fs == udev ]] && continue
  num=${pct%%%}
  if ((num >= threshold)); then
    printf 'ALERT: %s on %s is %s used (avail %s)\n' "$fs" "$mount" "$pct" "$avail" >&2
    alert=1
  else
    printf 'OK: %s on %s is %s used\n' "$fs" "$mount" "$pct"
  fi
done < <(df -hP | awk 'NR==1 || /^\/dev\// {print}')

exit "$alert"

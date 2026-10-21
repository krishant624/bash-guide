#!/usr/bin/env bash
# 25-log-analyzer.sh — Summarize error/warn/info counts from a log file
# Usage: ./25-log-analyzer.sh LOGFILE
set -euo pipefail

[[ $# -eq 1 ]] || { echo "Usage: $0 LOGFILE" >&2; exit 2; }
log=$1
[[ -f $log ]] || { echo "Not a file: $log" >&2; exit 1; }

errors=$(grep -Eic 'error|fail|fatal' -- "$log" || true)
warns=$(grep -Eic 'warn|warning' -- "$log" || true)
infos=$(grep -Eic 'info' -- "$log" || true)
lines=$(wc -l <"$log")

cat <<EOF
Log summary: $log
-------------
Lines : $lines
Errors: $errors
Warns : $warns
Infos : $infos
EOF

printf '\nTop matching error-like lines (max 10):\n'
grep -Ei 'error|fail|fatal' -- "$log" | head -n 10 || true

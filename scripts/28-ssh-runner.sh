#!/usr/bin/env bash
# 28-ssh-runner.sh — Run a remote command on many hosts (serial; see notes for -P)
# Usage: ./28-ssh-runner.sh HOSTS_FILE REMOTE_COMMAND...
# HOSTS_FILE: one hostname or user@host per line (# comments allowed)
# Requires working SSH key auth. Does not prompt for passwords.
set -euo pipefail

[[ $# -ge 2 ]] || { echo "Usage: $0 HOSTS_FILE REMOTE_COMMAND..." >&2; exit 2; }
hosts_file=$1
shift
cmd=("$@")
[[ -f $hosts_file ]] || { echo "Missing hosts file: $hosts_file" >&2; exit 1; }

ok=0
fail=0
while IFS= read -r host || [[ -n $host ]]; do
  [[ -z $host || $host =~ ^# ]] && continue
  printf '==> %s\n' "$host"
  if ssh -o BatchMode=yes -o ConnectTimeout=8 "$host" -- "${cmd[@]}"; then
    printf 'OK %s\n' "$host"
    ((ok++)) || true
  else
    printf 'FAIL %s\n' "$host" >&2
    ((fail++)) || true
  fi
done <"$hosts_file"

printf '\nSummary: ok=%s fail=%s\n' "$ok" "$fail"
((fail == 0))

#!/usr/bin/env bash
# 30-template.sh — Reusable production-oriented script skeleton
# Usage: ./30-template.sh [-n] [-v] [--] ARG...
set -euo pipefail

readonly SCRIPT_NAME=${0##*/}
DRY_RUN=0
VERBOSE=0

log() {
  local level=$1
  shift
  printf '[%s] %s: %s\n' "$(date -Iseconds)" "$level" "$*" >&2
}

die() {
  log ERROR "$*"
  exit 1
}

usage() {
  cat <<EOF >&2
Usage: $SCRIPT_NAME [-n] [-v] [--] ARG...
  -n    Dry-run
  -v    Verbose
  -h    Help
EOF
  exit 2
}

cleanup() {
  [[ -n ${tmpdir:-} && -d ${tmpdir:-} ]] && rm -rf -- "$tmpdir"
}
trap cleanup EXIT INT TERM

parse_args() {
  while getopts ':nvh' opt; do
    case $opt in
      n) DRY_RUN=1 ;;
      v) VERBOSE=1 ;;
      h) usage ;;
      ?) usage ;;
    esac
  done
  shift $((OPTIND - 1))
  ((VERBOSE)) && log INFO "args remaining: $*"
  ((DRY_RUN)) && log INFO "dry-run enabled"
  # Example required arg:
  # [[ $# -ge 1 ]] || die "missing ARG"
}

main() {
  parse_args "$@"
  tmpdir=$(mktemp -d)
  log INFO "using temp $tmpdir"
  # --- your logic here ---
  printf 'Hello from %s\n' "$SCRIPT_NAME"
}

main "$@"

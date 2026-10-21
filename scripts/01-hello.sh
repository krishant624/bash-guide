#!/usr/bin/env bash
# 01-hello.sh — Level 1: first runnable script
# Usage: ./01-hello.sh [name]
set -euo pipefail

name=${1:-world}
printf 'Hello, %s\n' "$name"

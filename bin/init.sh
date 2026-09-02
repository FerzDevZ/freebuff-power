#!/usr/bin/env bash
# ==============================================================================
# 🧰 FREEBUFF-POWER SUPERPOWER INJECTOR (AGENTS.MD & .FREEBUFF COPY ENGINE)
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

TARGET_DIR="${1:-.}"
mkdir -p "$TARGET_DIR"

GLOBAL_SUPERPOWER_DIR="$HOME/.freebuff-superpower"
LOCAL_SUPERPOWER_DIR="$SCRIPT_DIR/../superpower"

SOURCE_SUPERPOWER=""
if [ -d "$LOCAL_SUPERPOWER_DIR" ] && [ -f "$LOCAL_SUPERPOWER_DIR/AGENTS.md" ]; then
  SOURCE_SUPERPOWER="$LOCAL_SUPERPOWER_DIR"
elif [ -d "$GLOBAL_SUPERPOWER_DIR" ] && [ -f "$GLOBAL_SUPERPOWER_DIR/AGENTS.md" ]; then
  SOURCE_SUPERPOWER="$GLOBAL_SUPERPOWER_DIR"
fi

if [ -n "$SOURCE_SUPERPOWER" ]; then
  # Copy AGENTS.md
  cp -f "$SOURCE_SUPERPOWER/AGENTS.md" "$TARGET_DIR/AGENTS.md"
  
  # Copy .freebuff folder (agents & skills)
  mkdir -p "$TARGET_DIR/.freebuff/agents" "$TARGET_DIR/.freebuff/skills"
  if [ -d "$SOURCE_SUPERPOWER/.freebuff" ]; then
    cp -rf "$SOURCE_SUPERPOWER/.freebuff/"* "$TARGET_DIR/.freebuff/"
  fi
  
  echo -e "\033[0;32m\033[1m[✓] Sukses menginjeksi AGENTS.md & .freebuff/ (60 Agents & 1,061 Skills) ke $TARGET_DIR\033[0m"
else
  echo -e "\033[0;31m❌ Gagal menemukan template Superpower di $GLOBAL_SUPERPOWER_DIR\033[0m"
  exit 1
fi

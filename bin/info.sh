#!/usr/bin/env bash
# ==============================================================================
# 📖 FREEBUFF-POWER INFO (VIEW SOP / INSTRUCTIONS)
# ==============================================================================
set -euo pipefail

NAME="${1:-}"
if [ -z "$NAME" ]; then
  echo "Penggunaan: freebuff-power info <agent-or-skill-name>"
  exit 1
fi

NAME="$(echo "$NAME" | sed 's/^@//' | sed 's/^\[Skill: //' | sed 's/\]$//')"
SUPERPOWER_DIR="$HOME/.freebuff-superpower"

AGENT_FILE="$SUPERPOWER_DIR/.freebuff/agents/${NAME}.md"
SKILL_FILE="$SUPERPOWER_DIR/.freebuff/skills/${NAME}.md"

if [ -f "$AGENT_FILE" ]; then
  cat "$AGENT_FILE"
elif [ -f "$SKILL_FILE" ]; then
  cat "$SKILL_FILE"
else
  echo "❌ Tidak ditemukan Agent atau Skill dengan nama: $NAME"
fi

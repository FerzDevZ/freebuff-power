#!/usr/bin/env bash
# ==============================================================================
# 🔍 FREEBUFF-POWER SEARCH (SUB-AGENTS & SKILLS CATALOG)
# ==============================================================================
set -euo pipefail

KEYWORD="${1:-}"
if [ -z "$KEYWORD" ]; then
  echo "Penggunaan: freebuff-power search <keyword>"
  exit 1
fi

SUPERPOWER_DIR="$HOME/.freebuff-superpower"

echo -e "\033[0;36m\033[1m🔍 HASIL PENCARIAN UNTUK: \"$KEYWORD\"\033[0m\n"

echo -e "\033[0;33m\033[1m👥 Sub-Agents yang Cocok:\033[0m"
grep -rn -i "$KEYWORD" "$SUPERPOWER_DIR/.freebuff/agents" 2>/dev/null | cut -d: -f1 | sort -u | xargs -n 1 basename | sed 's/\.md$/ /' | sed 's/^/  - @/' || echo "  (Tidak ada)"

echo -e "\n\033[0;35m\033[1m🧰 Modular Skills yang Cocok:\033[0m"
MATCHED_SKILLS=$(grep -rn -i "$KEYWORD" "$SUPERPOWER_DIR/skills" "$SUPERPOWER_DIR/.freebuff/skills" 2>/dev/null | cut -d: -f1 | sort -u || true)
if [ -n "$MATCHED_SKILLS" ]; then
  echo "$MATCHED_SKILLS" | while read -r filepath; do
    [ -z "$filepath" ] && continue
    bname=$(basename "$filepath")
    if [ "$bname" = "SKILL.md" ]; then
      echo "  - [Skill: $(basename "$(dirname "$filepath")")]"
    else
      echo "  - [Skill: ${bname%.*}]"
    fi
  done | sort -u
else
  echo "  (Tidak ada)"
fi
echo ""

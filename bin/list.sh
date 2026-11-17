#!/usr/bin/env bash
# ==============================================================================
# 📋 FREEBUFF-POWER COMPLETE ROSTER LIST
# ==============================================================================
set -euo pipefail

SUPERPOWER_DIR="$HOME/.freebuff-superpower"
AGENTS_DIR="$SUPERPOWER_DIR/agents"
if [[ ! -d "$AGENTS_DIR" ]]; then
  AGENTS_DIR="$HOME/.agents/agents"
fi
SKILLS_DIR="$SUPERPOWER_DIR/skills"
if [[ ! -d "$SKILLS_DIR" ]]; then
  SKILLS_DIR="$HOME/.agents/skills"
fi

AGENTS_COUNT=$(find "$AGENTS_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo "87")
SKILLS_COUNT=$(find "$SKILLS_DIR" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l || echo "569")

echo -e "\033[0;36m\033[1m========================================================================\033[0m"
echo -e "\033[0;33m\033[1m📋 [FREEBUFF-POWER ROSTER] ${AGENTS_COUNT} Production Agents & ${SKILLS_COUNT} Curated Skills\033[0m"
echo -e "\033[0;36m\033[1m========================================================================\033[0m\n"

echo -e "\033[0;32m\033[1m👥 DAFTAR PRODUCTION AGENTS:\033[0m"
find "$AGENTS_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | sort | while read -r f; do
  name=$(basename "$f" .md)
  echo "  - @$name"
done
echo ""

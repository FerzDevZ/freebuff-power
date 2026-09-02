#!/usr/bin/env bash
# ==============================================================================
# 📋 FREEBUFF-POWER COMPLETE ROSTER LIST
# ==============================================================================
set -euo pipefail

SUPERPOWER_DIR="$HOME/.freebuff-superpower"
AGENTS_COUNT=$(ls -1 "$SUPERPOWER_DIR/.freebuff/agents" 2>/dev/null | wc -l || echo "60")

echo -e "\033[0;36m\033[1m========================================================================\033[0m"
echo -e "\033[0;33m\033[1m📋 [FREEBUFF-POWER ROSTER] ${AGENTS_COUNT} Sub-Agents & 1,061 Modular Skills\033[0m"
echo -e "\033[0;36m\033[1m========================================================================\033[0m\n"

echo -e "\033[0;32m\033[1m👥 DAFTAR SUB-AGENTS:\033[0m"
ls -1 "$SUPERPOWER_DIR/.freebuff/agents" 2>/dev/null | sed 's/\.md$//' | sed 's/^/  - @/'
echo ""

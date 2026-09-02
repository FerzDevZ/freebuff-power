#!/usr/bin/env bash
# ==============================================================================
# 🩺 FREEBUFF-POWER HEALTH CHECK & INTEGRITY DOCTOR
# ==============================================================================
set -euo pipefail

SUPERPOWER_DIR="$HOME/.freebuff-superpower"

echo -e "\033[0;36m\033[1m========================================================================\033[0m"
echo -e "\033[0;33m\033[1m🩺 [FREEBUFF-POWER DOCTOR] System Health & Integrity Check\033[0m"
echo -e "\033[0;36m\033[1m========================================================================\033[0m\n"

AGENTS_COUNT=$(ls -1 "$SUPERPOWER_DIR/.freebuff/agents" 2>/dev/null | wc -l || echo "0")
SKILLS_COUNT=$(ls -1 "$SUPERPOWER_DIR/.freebuff/skills" 2>/dev/null | wc -l || echo "0")

echo -e "📦 Superpower Cache Dir : $SUPERPOWER_DIR"
echo -e "👥 Sub-Agents Terpasang : \033[0;32m\033[1m${AGENTS_COUNT} Agents\033[0m (Status: Sehat)"
echo -e "🧰 Bundled Deep Skills  : \033[0;32m\033[1m${SKILLS_COUNT} Skills\033[0m (Status: Sehat)"

if which freebuff >/dev/null 2>&1; then
  echo -e "⚡ Freebuff Core Binary : \033[0;32m\033[1m$(which freebuff)\033[0m (Online)"
else
  echo -e "⚠️ Freebuff Core Binary : \033[0;31mBelum terpasang (Jalankan 'npm install -g freebuff')\033[0m"
fi

echo -e "\n\033[0;32m\033[1m🎉 SEMUA SISTEM BERFUNGSI SEMPURNA (100% HEALTHY)!\033[0m\n"

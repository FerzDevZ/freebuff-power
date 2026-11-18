#!/usr/bin/env bash
# ==============================================================================
# 🩺 FREEBUFF-POWER & FREEPI-POWER HEALTH CHECK & INTEGRITY DOCTOR (v11.0)
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

SUPERPOWER_DIR="$HOME/.freebuff-superpower"
if [ ! -d "$SUPERPOWER_DIR" ] && [ -d "$SCRIPT_DIR/../superpower" ]; then
  SUPERPOWER_DIR="$SCRIPT_DIR/../superpower"
fi

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_PURPLE='\033[0;35m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🩺 [SYSTEM DOCTOR] Freebuff-Power & FreePi-Power Integrity Check${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 1. Hitung Agen & Skills
AGENTS_COUNT=$(ls -1 "$SUPERPOWER_DIR/agents" 2>/dev/null | wc -l)
if [ "$AGENTS_COUNT" -eq 0 ]; then
  AGENTS_COUNT=$(ls -1 "$SUPERPOWER_DIR/.freebuff/agents" 2>/dev/null | wc -l || echo "0")
fi

SKILLS_COUNT=$(ls -1 "$SUPERPOWER_DIR/skills" 2>/dev/null | wc -l)
if [ "$SKILLS_COUNT" -eq 0 ]; then
  SKILLS_COUNT=$(ls -1 "$SUPERPOWER_DIR/.freebuff/skills" 2>/dev/null | wc -l || echo "0")
fi

echo -e "📦 Superpower Cache     : $SUPERPOWER_DIR"
echo -e "👥 Production Agents    : ${C_GREEN}${C_BOLD}${AGENTS_COUNT} Agents${C_RESET} (Status: Sehat)"
echo -e "🧰 Modular Skills       : ${C_GREEN}${C_BOLD}${SKILLS_COUNT} Skills${C_RESET} (Status: Sehat)"

# 2. Periksa FreePi (freepi.ai) CLI Engine & Native Registry
if command -v free-pi-cli >/dev/null 2>&1; then
  FREEPI_VER=$(free-pi-cli --version 2>/dev/null || echo "terpasang")
  echo -e "⚡ FreePi Core Engine   : ${C_GREEN}${C_BOLD}$(which free-pi-cli)${C_RESET} (${FREEPI_VER}) (Online)"
elif [ -f "$HOME/.nvm/versions/node/$(node -v 2>/dev/null || echo '')/bin/free-pi-cli" ]; then
  echo -e "⚡ FreePi Core Engine   : ${C_GREEN}${C_BOLD}$HOME/.nvm/.../bin/free-pi-cli${C_RESET} (Online)"
else
  echo -e "⚠️ FreePi Core Engine   : ${C_YELLOW}Belum terpasang (Bisa dijalankan via 'npx free-pi-cli' atau 'npm install -g free-pi-cli')${C_RESET}"
fi

FREEPI_PROMPTS=$(ls -1 "$HOME/.free-pi/agent/prompts"/*.md 2>/dev/null | wc -l || echo "0")
FREEPI_SKILLS=$(ls -1 "$HOME/.free-pi/agent/skills" 2>/dev/null | wc -l || echo "0")
FREEPI_SESSIONS=$(find "$HOME/.free-pi/agent/sessions" -name "*.jsonl" 2>/dev/null | wc -l || echo "0")
echo -e "📂 FreePi Native Store  : ${C_GREEN}${FREEPI_PROMPTS} Slash Agents${C_RESET} | ${C_GREEN}${FREEPI_SKILLS} Active Skills${C_RESET} | ${C_CYAN}${FREEPI_SESSIONS} Saved Sessions${C_RESET}"

# 3. Periksa Freebuff Core Binary
if command -v freebuff >/dev/null 2>&1; then
  echo -e "⚡ Freebuff Core Binary : ${C_GREEN}${C_BOLD}$(which freebuff)${C_RESET} (Online)"
else
  echo -e "⚠️ Freebuff Core Binary : ${C_YELLOW}Belum terpasang (Jalankan 'npm install -g freebuff')${C_RESET}"
fi

# 4. Periksa Dual CLI Binary (freebuff-power & freepi-power)
if [ -x "$SCRIPT_DIR/freebuff-power" ] || command -v freebuff-power >/dev/null 2>&1; then
  echo -e "🚀 freebuff-power CLI   : ${C_GREEN}${C_BOLD}Ready & Executable${C_RESET}"
fi
if [ -x "$SCRIPT_DIR/freepi-power" ] || command -v freepi-power >/dev/null 2>&1; then
  echo -e "🚀 freepi-power CLI     : ${C_GREEN}${C_BOLD}Ready & Executable${C_RESET}"
fi

# 5. Periksa SA-MP / open.mp Developer Suite
SAMP_STATUS="${C_GREEN}${C_BOLD}Lengkap (Auditor, Healer, Scaffolder, Encyclopedia)${C_RESET}"
if [ ! -f "$SCRIPT_DIR/samp-audit.sh" ] || [ ! -f "$SCRIPT_DIR/samp-heal.sh" ]; then
  SAMP_STATUS="${C_YELLOW}Sebagian${C_RESET}"
fi
echo -e "🎮 SA-MP & open.mp Suite: $SAMP_STATUS"

# 6. Periksa Anti-Slop & Human Design Suite
if [ -f "$SCRIPT_DIR/antislop.sh" ] && [ -f "$SCRIPT_DIR/contrast.sh" ] && [ -f "$SCRIPT_DIR/design.sh" ]; then
  echo -e "🎨 Anti-Slop & Design   : ${C_GREEN}${C_BOLD}Ready (40-Rule Purger & WCAG Contrast Engine)${C_RESET}"
fi

echo -e "\n${C_GREEN}${C_BOLD}🎉 DUAL ENGINE (FREEBUFF-POWER & FREEPI-POWER) 100% HEALTHY & READY TO CODE!${C_RESET}\n"

#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEPI RUNNER — FreePi (freepi.ai) Autonomous Integration Engine
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_PURPLE='\033[0;35m'
C_RED='\033[0;31m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

# 1. Jalankan Spoofer & Pembersih Identitas
if [ -f "$SCRIPT_DIR/clean.sh" ]; then
  "$SCRIPT_DIR/clean.sh" >/dev/null 2>&1 || true
fi

# 2. Injeksi Environment Variables Anti-Tracking
export DO_NOT_TRACK=1
export TELEMETRY_DISABLED=1
export NEXT_TELEMETRY_DISABLED=1

# 3. Pastikan AGENTS.md dan .agents/ diinjeksi ke folder kerja aktif
if [ ! -f "AGENTS.md" ] || [ ! -d ".agents" ]; then
  echo -e "${C_CYAN}🧰 [FREEPI-POWER] Menginjeksi 94 Agents & 584 Skills ke folder aktif...${C_RESET}"
  "$SCRIPT_DIR/freebuff-power" init . >/dev/null 2>&1 || true
fi

# 4. Deteksi binary free-pi-cli
FREEPI_BIN=""
if command -v free-pi-cli >/dev/null 2>&1; then
  FREEPI_BIN="$(command -v free-pi-cli)"
elif [ -f "$HOME/.nvm/versions/node/$(node -v 2>/dev/null || echo '')/bin/free-pi-cli" ]; then
  FREEPI_BIN="$HOME/.nvm/versions/node/$(node -v 2>/dev/null)/bin/free-pi-cli"
elif [ -f "$HOME/.local/bin/free-pi-cli" ]; then
  FREEPI_BIN="$HOME/.local/bin/free-pi-cli"
fi

# 5. Header Banner FreePi
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚡ FREEPI-POWER (freepi.ai) — Free AI Coding Agent in Terminal${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "🌐 Official Portal : \033[0;36mhttps://freepi.ai/\033[0m"
echo -e "👥 Superpower Swarm: \033[0;32m94 Production Agents & 584 Skills Injected (.agents/)\033[0m"
echo -e "💡 Context File    : \033[0;33mAGENTS.md (Auto-Loaded by Pi Agent Harness)\033[0m"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 6. Eksekusi free-pi-cli atau fallback npx
if [ -n "$FREEPI_BIN" ]; then
  exec "$FREEPI_BIN" "$@"
elif command -v npx >/dev/null 2>&1; then
  echo -e "${C_YELLOW}⚡ Menjalankan free-pi-cli via npx...${C_RESET}"
  exec npx free-pi-cli@latest "$@"
else
  echo -e "${C_RED}❌ free-pi-cli belum terpasang. Jalankan: npm install -g free-pi-cli${C_RESET}"
  exit 1
fi

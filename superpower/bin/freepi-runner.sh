#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEPI RUNNER — Native FreePi (freepi.ai) Launch & Context Bridge
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
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

# 1. Resolve free-pi-cli binary cleanly
resolve_freepi_bin() {
  if command -v free-pi-cli >/dev/null 2>&1; then
    command -v free-pi-cli
    return 0
  fi
  local node_ver
  node_ver="$(node -v 2>/dev/null || echo '')"
  if [ -n "$node_ver" ] && [ -x "$HOME/.nvm/versions/node/$node_ver/bin/free-pi-cli" ]; then
    echo "$HOME/.nvm/versions/node/$node_ver/bin/free-pi-cli"
    return 0
  fi
  if [ -x "$HOME/.local/bin/free-pi-cli" ]; then
    echo "$HOME/.local/bin/free-pi-cli"
    return 0
  fi
  return 1
}

FREEPI_BIN="$(resolve_freepi_bin || true)"

exec_freepi() {
  if [ -n "$FREEPI_BIN" ]; then
    exec "$FREEPI_BIN" "$@"
  elif command -v npx >/dev/null 2>&1; then
    exec npx free-pi-cli@latest "$@"
  else
    echo -e "${C_RED}❌ free-pi-cli belum terpasang. Jalankan: npm install -g free-pi-cli${C_RESET}" >&2
    exit 1
  fi
}

# 2. Pass-through mode for non-interactive / machine-readable FreePi subcommands
FIRST_ARG="${1:-}"
case "$FIRST_ARG" in
  mcp|logout|--version|-v|--help|-h)
    exec_freepi "$@"
    ;;
esac

# 3. Interactive session preparation
export DO_NOT_TRACK=1
export TELEMETRY_DISABLED=1

# Ensure FreePi native slash-command prompts exist (~/.free-pi/agent/prompts)
if [ ! -d "$HOME/.free-pi/agent/prompts" ] || [ -z "$(ls -A "$HOME/.free-pi/agent/prompts" 2>/dev/null)" ]; then
  if [ -x "$SCRIPT_DIR/freepi-pack.sh" ]; then
    "$SCRIPT_DIR/freepi-pack.sh" sync-prompts >/dev/null 2>&1 || true
  fi
fi

# Auto-inject AGENTS.md & .agents/ in project directories (skip $HOME root and /)
CURRENT_DIR="$(pwd -P)"
if [ "$CURRENT_DIR" != "$HOME" ] && [ "$CURRENT_DIR" != "/" ]; then
  if [ ! -f "AGENTS.md" ] || [ ! -d ".agents" ]; then
    echo -e "${C_CYAN}🧰 [FREEPI-POWER] Menginjeksi AGENTS.md & katalog .agents/ ke proyek aktif...${C_RESET}"
    "$SCRIPT_DIR/init.sh" . >/dev/null 2>&1 || true
  fi
fi

ACTIVE_SKILLS=$(ls -1 "$HOME/.free-pi/agent/skills" 2>/dev/null | wc -l || echo "0")
ACTIVE_PROMPTS=$(ls -1 "$HOME/.free-pi/agent/prompts"/*.md 2>/dev/null | wc -l || echo "0")

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚡ FREEPI-POWER (freepi.ai) — Autonomous Coding Agent in Terminal${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "🌐 Engine          : ${C_CYAN}free-pi-cli${C_RESET} (https://freepi.ai/)"
echo -e "👥 Slash Agents    : ${C_GREEN}${ACTIVE_PROMPTS} Agents${C_RESET} (${C_DIM}ketik /samp-creator-2026 atau /samp-textdraw-fivem-master${C_RESET})"
echo -e "🧰 Native Skills   : ${C_GREEN}${ACTIVE_SKILLS} aktif${C_RESET} (${C_DIM}kelola via 'freepi-power pack samp' | 588 total di .agents/skills/${C_RESET})"
echo -e "💡 Slash Commands  : ${C_PURPLE}/model  /usage  /resume  /compact  /todos  /import  /help${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

exec_freepi "$@"

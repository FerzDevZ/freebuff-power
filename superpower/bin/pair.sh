#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER TURBO LIVE PAIR-PROGRAMMING (ULTRA FAST WEB ENGINE)
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

PORT="${1:-7681}"

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🤝 [FREEBUFF-POWER PAIR] Instant Turbo Collaborative Terminal${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 1. Injeksi Superpower
freebuff-power init . >/dev/null 2>&1 || true

# 2. Start Turbo Web Terminal Engine
echo -e "${C_GREEN}🚀 Menyalakan Turbo Web Terminal Server di port $PORT...${C_RESET}"
node "$SCRIPT_DIR/webterm/server.js" >/dev/null 2>&1 &
SERVER_PID=$!

sleep 1

echo -e "\n${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}🎉 SESI PAIR-PROGRAMMING AKTIF & SUPER CEPAT!${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "⚡ ${C_BOLD}Link Browser Lokal (0ms Delay):${C_RESET} ${C_CYAN}${C_BOLD}http://localhost:$PORT${C_RESET}"
echo -e "\n${C_YELLOW}👉 Siap menghubungkan tunnel publik...${C_RESET}\n"

trap 'kill $SERVER_PID 2>/dev/null || true; echo -e "\n${C_RED}🛑 Sesi kolaborasi dimatikan.${C_RESET}"; exit 0' INT TERM

# Preferred: Cloudflare / Localtunnel
if which cloudflared >/dev/null 2>&1; then
  cloudflared tunnel --url "http://localhost:$PORT"
elif which npx >/dev/null 2>&1; then
  npx -y localtunnel --port "$PORT"
else
  wait $SERVER_PID
fi

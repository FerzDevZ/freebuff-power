#!/usr/bin/env bash
# ==============================================================================
# 🤝 FREEBUFF-POWER INSTANT LIVE PAIR-PROGRAMMING (ULTRA-RELIABLE TUNNEL)
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
echo -e "${C_YELLOW}${C_BOLD}🤝 [FREEBUFF-POWER PAIR] Instant Live Collaborative Terminal${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 1. Injeksi Superpower
freebuff-power init . >/dev/null 2>&1 || true

# 2. Check for tmate (The undisputed #1 tool for terminal pairing)
if which tmate >/dev/null 2>&1; then
  echo -e "${C_GREEN}🚀 Meluncurkan Tmate Secure Terminal Pairing...${C_RESET}\n"
  exec tmate -F
fi

# 3. Start Zero-Auth Web Terminal
echo -e "${C_GREEN}🚀 Menyalakan Web Terminal Engine di port $PORT...${C_RESET}"
node "$SCRIPT_DIR/webterm/server.js" >/dev/null 2>&1 &
SERVER_PID=$!

sleep 1

# 4. Check for Cloudflare / Localtunnel / Bore
echo -e "${C_YELLOW}⏳ Membuat Public Tunnel yang Stabil...${C_RESET}\n"

# Try Localtunnel via npx for instant DNS resolution
if which npx >/dev/null 2>&1; then
  echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}🎉 LINK LIVE PAIR-PROGRAMMING (LOCALTUNNEL & CLOUDFLARE)${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "💡 Local Web Terminal : ${C_CYAN}http://localhost:$PORT${C_RESET}"
  echo -e "\n${C_YELLOW}👉 Siap menghubungkan tunnel publik...${C_RESET}\n"
  
  trap 'kill $SERVER_PID 2>/dev/null || true; echo -e "\n${C_RED}🛑 Sesi kolaborasi dimatikan.${C_RESET}"; exit 0' INT TERM
  npx -y localtunnel --port "$PORT" || cloudflared tunnel --url "http://localhost:$PORT"
else
  cloudflared tunnel --url "http://localhost:$PORT"
fi

#!/usr/bin/env bash
# ==============================================================================
# 🤝 FREEBUFF-POWER INSTANT LIVE PAIR-PROGRAMMING (ZERO PASSWORD DIRECT ACCESS)
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_PURPLE='\033[0;35m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

PORT="${1:-7681}"

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🤝 [FREEBUFF-POWER PAIR] Instant Collaborative Terminal (Zero-Password)${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# Injeksi Superpower
freebuff-power init . >/dev/null 2>&1 || true

# Check if ttyd is installed or run with node zero-auth
if which ttyd >/dev/null 2>&1; then
  echo -e "${C_GREEN}🚀 Menjalankan ttyd Web Terminal...${C_RESET}\n"
  ttyd -p "$PORT" -W freebuff-power start &
  SERVER_PID=$!
else
  # Use wetty with custom bypass ssh / direct pty
  echo -e "${C_GREEN}🚀 Menjalankan Web Terminal Engine (Direct Access)...${C_RESET}\n"
  npx -y wetty --port "$PORT" --command "bash -l" --bypass-helmet &
  SERVER_PID=$!
fi

sleep 2

if which cloudflared >/dev/null 2>&1; then
  echo -e "${C_GREEN}${C_BOLD}🌐 MEMBUKA LINK COLLABORATIVE REAL-TIME...${C_RESET}"
  echo -e "${C_YELLOW}👉 Siapa pun yang membuka link ini LANGSUNG masuk ke sesi terminal!${C_RESET}\n"
  
  cloudflared tunnel --url "http://localhost:$PORT"
  kill $SERVER_PID 2>/dev/null || true
else
  echo -e "${C_PURPLE}💡 Terminal lokal aktif di: ${C_BOLD}http://localhost:$PORT${C_RESET}"
  wait $SERVER_PID
fi

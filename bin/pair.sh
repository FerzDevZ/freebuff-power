#!/usr/bin/env bash
# ==============================================================================
# 🤝 FREEBUFF-POWER INSTANT LIVE PAIR-PROGRAMMING ENGINE
# ==============================================================================
set -euo pipefail

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

# 1. Check for tmate or web terminal runner
if which tmate >/dev/null 2>&1; then
  echo -e "${C_GREEN}🚀 Meluncurkan sesi pair programming via Tmate...${C_RESET}\n"
  exec tmate -F
fi

# 2. Check for node-based webpty / ttyd or cloudflare tunnel
echo -e "${C_GREEN}🚀 Menyiapkan browser-accessible collaborative terminal di port $PORT...${C_RESET}"

# Injeksi superpower ke folder aktif
freebuff-power init . >/dev/null 2>&1 || true

if which cloudflared >/dev/null 2>&1; then
  echo -e "\n${C_GREEN}${C_BOLD}🌐 MEMBUKA LINK COLLABORATIVE REAL-TIME...${C_RESET}"
  echo -e "${C_YELLOW}👉 Bagikan link publik yang muncul ke teman / tim untuk koding bersama!${C_RESET}\n"
  
  if which npx >/dev/null 2>&1; then
    npx -y wetty --port "$PORT" --command "freebuff-power start" &
    WETTY_PID=$!
    sleep 2
    cloudflared tunnel --url "http://localhost:$PORT"
    kill $WETTY_PID 2>/dev/null || true
  else
    cloudflared tunnel --url "http://localhost:$PORT"
  fi
else
  echo -e "${C_PURPLE}💡 Menjalankan terminal server lokal pada: ${C_BOLD}http://localhost:$PORT${C_RESET}"
  if which npx >/dev/null 2>&1; then
    npx -y wetty --port "$PORT" --command "freebuff-power start"
  else
    echo -e "${C_RED}❌ Silakan pasang 'tmate' atau 'cloudflared' untuk link publik instan:${C_RESET}"
    echo -e "   \033[0;36msudo apt install tmate\033[0m"
  fi
fi

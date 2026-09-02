#!/usr/bin/env bash
# ==============================================================================
# 🤝 FREEBUFF-POWER INSTANT LIVE PAIR-PROGRAMMING (CLEAN URL DISPLAY)
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
echo -e "${C_YELLOW}${C_BOLD}🤝 [FREEBUFF-POWER PAIR] Instant Collaborative Terminal${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 1. Injeksi Superpower
freebuff-power init . >/dev/null 2>&1 || true

# 2. Start Web Terminal in Background
echo -e "${C_GREEN}🚀 Menyalakan Web Terminal Engine...${C_RESET}"
npx -y wetty --port "$PORT" --command "bash -l" --bypass-helmet >/dev/null 2>&1 &
SERVER_PID=$!

sleep 2

# 3. Create Cloudflare Tunnel & Extract Clean URL
echo -e "${C_YELLOW}⏳ Menghubungkan ke Cloudflare Tunnel...${C_RESET}\n"

CLOUDFLARED_LOG="$(mktemp)"
cloudflared tunnel --url "http://localhost:$PORT" > "$CLOUDFLARED_LOG" 2>&1 &
TUNNEL_PID=$!

CLEAN_URL=""
for i in {1..30}; do
  if grep -o "https://[a-zA-Z0-9.-]*\.trycloudflare\.com" "$CLOUDFLARED_LOG" >/dev/null 2>&1; then
    CLEAN_URL="$(grep -o "https://[a-zA-Z0-9.-]*\.trycloudflare\.com" "$CLOUDFLARED_LOG" | head -n 1)"
    break
  fi
  sleep 1
done

if [ -n "$CLEAN_URL" ]; then
  echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}🎉 LINK LIVE PAIR-PROGRAMMING KAMU SUDAH SIAP!${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "\n👉 ${C_CYAN}${C_BOLD}$CLEAN_URL${C_RESET}\n"
  echo -e "${C_YELLOW}💡 Buka link di atas di browser atau bagikan ke temanmu untuk koding bersama!${C_RESET}"
  echo -e "${C_DIM}(Tekan Ctrl+C untuk mematikan sesi kolaborasi)${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}\n"
else
  echo -e "${C_RED}❌ Gagal mendapatkan URL Cloudflare. Terminal lokal aktif di: http://localhost:$PORT${C_RESET}\n"
fi

# Wait for Ctrl+C
trap 'kill $SERVER_PID $TUNNEL_PID 2>/dev/null || true; rm -f "$CLOUDFLARED_LOG"; echo -e "\n${C_RED}🛑 Sesi kolaborasi dimatikan.${C_RESET}"; exit 0' INT TERM
wait $TUNNEL_PID

#!/usr/bin/env bash
# ==============================================================================
# 🌐 FREEBUFF-POWER MOBILE PREVIEW & INSTANT TUNNEL (WITH QR-CODE)
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

PORT="${1:-3000}"

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🌐 [FREEBUFF-POWER SHARE] Mobile Live Preview & Tunnel${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 1. Detect Framework & Port
if [ -f "package.json" ]; then
  if grep -q "next" package.json; then
    PORT=3000
    echo -e "📦 Mendeteksi project ${C_BOLD}Next.js${C_RESET} (Default port: 3000)"
  elif grep -q "vite" package.json; then
    PORT=5173
    echo -e "📦 Mendeteksi project ${C_BOLD}Vite${C_RESET} (Default port: 5173)"
  elif grep -q "astro" package.json; then
    PORT=4321
    echo -e "📦 Mendeteksi project ${C_BOLD}Astro${C_RESET} (Default port: 4321)"
  fi
fi

# 2. Check if local port is active
if ! nc -z localhost "$PORT" 2>/dev/null; then
  echo -e "${C_YELLOW}⚠️  Port $PORT belum berjalan. Silakan jalankan server lokalmu terlebih dahulu (misal: npm run dev).${C_RESET}"
  echo -e "👉 Membuka tunnel untuk port $PORT..."
fi

# 3. Spin up cloudflared tunnel or localtunnel
echo -e "\n${C_GREEN}🚀 Membuat HTTPS Public Tunnel untuk port $PORT...${C_RESET}\n"

if which cloudflared >/dev/null 2>&1; then
  cloudflared tunnel --url "http://localhost:$PORT"
elif which npx >/dev/null 2>&1; then
  npx -y localtunnel --port "$PORT"
else
  echo -e "${C_RED}❌ Harap pasang 'cloudflared' atau 'npm/npx' untuk menggunakan fitur tunnel.${C_RESET}"
  exit 1
fi

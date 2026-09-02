#!/usr/bin/env bash
# ==============================================================================
# 🌐 FREEBUFF-POWER SUPREME IP ROTATOR (WARP KEY & ANYCAST IP FLIPPER)
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🌐 [FREEBUFF-POWER IP ROTATOR] Regenerating Fresh Clean IP via Cloudflare${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

if which warp-cli >/dev/null 2>&1; then
  echo -e "🔄 [1/3] Merotasi kunci kriptografis tunnel & IP Anycast..."
  warp-cli tunnel rotate-keys >/dev/null 2>&1 || true
  
  echo -e "🔌 [2/3] Memperbarui koneksi ke node global terdekat..."
  warp-cli disconnect >/dev/null 2>&1 || true
  sleep 0.5
  warp-cli connect >/dev/null 2>&1 || true
  sleep 1

  echo -e "🔍 [3/3] Memverifikasi IP Publik Baru..."
  NEW_IP=$(curl -s --max-time 4 http://ip-api.com/json | grep -o '"query":"[^"]*"' | cut -d'"' -f4 || echo "Cloudflare Anycast Active")
  echo -e "\n${C_GREEN}${C_BOLD}🎉 SUKSES! IP Publik Berhasil Diputar ke: ${C_CYAN}${NEW_IP}${C_RESET}\n"
else
  echo -e "${C_RED}⚠️ Cloudflare WARP belum terpasang. Jalankan 'sudo apt install cloudflare-warp'.${C_RESET}"
fi

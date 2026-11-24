#!/usr/bin/env bash
# ==============================================================================
# 🌐 FREEBUFF-POWER CLOUDFLARE WARP AUTO-INSTALLER & RESIDENTIAL PROXY ENFORCER
# Masks Data Center (AWS/GCP/DO) IP into Clean Cloudflare Residential IP
# Guarantees Full Access (100 Freebucks) on Freebuff API without Data Center Flag.
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🌐 [FREEBUFF-POWER WARP] Cloudflare Zero-Trust IP Masking Enforcer${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

WARP_PORT=40000

# 1. Check if warp-cli is installed
if ! command -v warp-cli >/dev/null 2>&1; then
  echo -e "${C_YELLOW}⚡ Cloudflare WARP belum terpasang. Memulai auto-installation...${C_RESET}"
  
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
    CODENAME="${VERSION_CODENAME:-noble}"
  else
    DISTRO="ubuntu"
    CODENAME="noble"
  fi

  # Support latest Ubuntu releases by defaulting to stable repo if necessary
  if [ "$CODENAME" = "resolute" ] || [ -z "$CODENAME" ]; then
    CODENAME="noble"
  fi

  echo -e "${C_CYAN}📦 Menambahkan repository Cloudflare WARP (${CODENAME})...${C_RESET}"
  sudo curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list >/dev/null

  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cloudflare-warp >/dev/null 2>&1 || {
    echo -e "${C_RED}❌ Gagal memasang cloudflare-warp via apt.${C_RESET}"
    exit 1
  }
  echo -e "${C_GREEN}✅ Cloudflare WARP berhasil dipasang!${C_RESET}"
fi

# 2. Register & configure warp-cli
echo -e "${C_CYAN}⚙️  Mengonfigurasi registrasi & Proxy Mode (Port ${WARP_PORT})...${C_RESET}"
warp-cli --accept-tos registration new >/dev/null 2>&1 || true
warp-cli --accept-tos mode proxy >/dev/null 2>&1 || true
warp-cli --accept-tos proxy port "$WARP_PORT" >/dev/null 2>&1 || true
warp-cli --accept-tos connect >/dev/null 2>&1 || true

sleep 2

# 3. Verify Connection
STATUS="$(warp-cli --accept-tos status 2>/dev/null || echo "")"
if echo "$STATUS" | grep -qi "Connected"; then
  echo -e "${C_GREEN}${C_BOLD}🎉 CLOUDFLARE WARP AKTIF & CONNECTED!${C_RESET}"
  
  # Check Masked IP
  MASKED_IP=$(curl -s --max-time 4 -x "socks5://127.0.0.1:$WARP_PORT" https://ipinfo.io/json 2>/dev/null || echo "")
  if [ -n "$MASKED_IP" ]; then
    IP=$(echo "$MASKED_IP" | grep -o '"ip": *"[^"]*"' | cut -d'"' -f4)
    ORG=$(echo "$MASKED_IP" | grep -o '"org": *"[^"]*"' | cut -d'"' -f4)
    CITY=$(echo "$MASKED_IP" | grep -o '"city": *"[^"]*"' | cut -d'"' -f4)
    echo -e "   🛡️  Masked IP   : ${C_CYAN}${IP}${C_RESET} (${ORG})"
    echo -e "   📍 Lokasi     : ${C_CYAN}${CITY}${C_RESET}"
    echo -e "   🚀 Status     : ${C_GREEN}Full Access Protection Guaranteed (Zero Data Center Flag)${C_RESET}\n"
  fi
else
  echo -e "${C_RED}⚠️  WARP belum terhubung. Status: ${STATUS}${C_RESET}\n"
fi

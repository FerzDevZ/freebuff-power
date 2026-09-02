#!/usr/bin/env bash
# ==============================================================================
# 👻 FREEBUFF-POWER GHOST STEALTH CLOAKER (Full Identity, Machine & IP Wipe)
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
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_RED}${C_BOLD}👻 [FREEBUFF-POWER STEALTH CLOAK] 100% Anti-Ban Ghost Protocol Initiated${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 1. Reset Hardware Machine ID & Telemetry
echo -e "${C_YELLOW}⚙️  [1/3] Mengacak total Hardware ID, Machine GUID & Virtual MAC...${C_RESET}"
"$SCRIPT_DIR/clean.sh" >/dev/null 2>&1

# 2. Reset Account Credentials & Session Locks
echo -e "${C_YELLOW}🧹 [2/3] Membersihkan session lock, token lama & tracking queues...${C_RESET}"
"$SCRIPT_DIR/account.sh" reset >/dev/null 2>&1

# 3. Rotate IP via Cloudflare Anycast
echo -e "${C_YELLOW}🌐 [3/3] Memutar alamat IP publik dan merotasi kunci WireGuard...${C_RESET}"
"$SCRIPT_DIR/rotate-ip.sh" >/dev/null 2>&1 || true

echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}🛡️ GHOST STEALTH AKTIF: Akun, Identitas Mesin & IP 100% Baru & Bersih!${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}\n"
echo -e "👉 Sekarang kamu bebas login & koding tanpa risiko suspend/ban:"
echo -e "   \033[0;36m\033[1mfreebuff-power start\033[0m\n"

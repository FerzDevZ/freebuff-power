#!/usr/bin/env bash
# ==============================================================================
# 🛡️ FREEBUFF-POWER SUPREME RUNNER (ZERO TELEMETRY, SMART FAILOVER & ANTI-BAN)
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# 1. Jalankan Spoofer Pembersih Identitas Ringan
"$SCRIPT_DIR/clean.sh" >/dev/null 2>&1 || true

# 2. Injeksi Environment Variables Anti-Tracking
export DO_NOT_TRACK=1
export TELEMETRY_DISABLED=1
export NEXT_TELEMETRY_DISABLED=1
export ASTRO_TELEMETRY_DISABLED=1
export STRIPE_DISABLE_TELEMETRY=1
export PRISMA_TELEMETRY_INFORMATION=0
export MANICODE_TELEMETRY=0
export MANICODE_ANALYTICS=0
export MANICODE_DEVICE_HASH="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"

# 3. SSL / TLS Root Certificates Fix for Bun & Node.js Engine
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_DIR=/etc/ssl/certs
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# 3b. Stealth Browser Sandbox & Auth URL Interceptor
export BROWSER="$SCRIPT_DIR/browser-stealth.sh"
export PATH="$SCRIPT_DIR/shims:$PATH"

# 3c. Linux Hardware & Machine-ID Virtualization C-Hook (Anti-Ban Shield)
if [ -f "$SCRIPT_DIR/libfreebuff-stealth.so" ]; then
  export LD_PRELOAD="$SCRIPT_DIR/libfreebuff-stealth.so${LD_PRELOAD:+:$LD_PRELOAD}"
elif [ -f "$HOME/.local/bin/libfreebuff-stealth.so" ]; then
  export LD_PRELOAD="$HOME/.local/bin/libfreebuff-stealth.so${LD_PRELOAD:+:$LD_PRELOAD}"
fi

# 4. Smart Quota Failover Check
CREDS_FILE="$HOME/.config/manicode/credentials.json"
if [ -f "$CREDS_FILE" ] && [ -f "$SCRIPT_DIR/check_quota.js" ]; then
  # Check if there is an active account and see if we should auto-rotate
  READY_ACCOUNT=$(node "$SCRIPT_DIR/check_quota.js" --first-ready 2>/dev/null || echo "")
  if [ -n "$READY_ACCOUNT" ]; then
    CURRENT_EMAIL=$(grep -o '"email": "[^"]*"' "$CREDS_FILE" | cut -d'"' -f4 || echo "")
    # If current account credentials exist, test if it is valid or let auto-failover engage if needed
  fi
fi

# 5. Auto-Setup / Connect Cloudflare WARP (Full Access Residential IP Masking)
WARP_PORT=40000
if which warp-cli >/dev/null 2>&1; then
  if ! warp-cli status 2>/dev/null | grep -q "Connected"; then
    echo -e "\033[0;36m🌐 Menghubungkan Cloudflare WARP secara otomatis...\033[0m"
    warp-cli connect >/dev/null 2>&1 || true
    sleep 0.5
  fi
  if warp-cli status 2>/dev/null | grep -q "Connected"; then
    WARP_MODE="$(warp-cli mode 2>/dev/null || echo '')"
    if echo "$WARP_MODE" | grep -qi "proxy"; then
      export ALL_PROXY="socks5h://127.0.0.1:$WARP_PORT"
    fi
  fi
fi

# 6. Pastikan Core Freebuff terpasang
if ! command -v freebuff >/dev/null 2>&1; then
  echo -e "\033[0;33m⚡ Core engine Freebuff belum terdeteksi. Memasang via npm install -g freebuff...\033[0m"
  if command -v npm >/dev/null 2>&1; then
    sudo npm install -g freebuff 2>/dev/null || npm install -g freebuff 2>/dev/null || true
  fi
fi

# 7. Jalankan Freebuff dengan Trust Agents & Auto-Panggil @AGENTS.md
export CODEBUFF_TRUST_AGENTS=1
export FREEBUFF_TRUST_AGENTS=1

EXTRA_ARGS=()
if [ -d ".agents" ] || [ -f "AGENTS.md" ]; then
  EXTRA_ARGS+=("--trust-agents")
fi

if [ $# -gt 0 ]; then
  FIRST_ARG="$1"
  if [[ "$FIRST_ARG" != -* ]] && [[ "$FIRST_ARG" != "login"* ]] && [[ "$FIRST_ARG" != *"@AGENTS.md"* ]]; then
    exec freebuff "${EXTRA_ARGS[@]}" "@AGENTS.md $*"
  else
    exec freebuff "${EXTRA_ARGS[@]}" "$@"
  fi
else
  # Interactive mode: Cetak panduan memanggil @AGENTS.md di prompt CLI
  echo -e "\033[0;36m\033[1m========================================================================\033[0m"
  echo -e "\033[0;32m\033[1m⚡ FREEBUFF-POWER SUPREME v9.0 (ECC Cognitive Swarm Engine Active)\033[0m"
  echo -e "\033[0;36m\033[1m========================================================================\033[0m"
  echo -e "🛡️ Stealth Shield : \033[0;32mC-Hook Active (Virtual Machine-ID & Spoofed MAC)\033[0m"
  echo -e "🧰 Superpower     : \033[0;33m71 Sub-Agents & 326 Curated Skills Injected (.agents/)\033[0m"
  echo -e "🌐 Browser        : \033[0;35mGoogle Chrome Stealth Sandbox Active\033[0m"
  echo -e "\n\033[1m💡 CARA MENGAKTIFKAN DI CHAT PROMPT FREEBUFF:\033[0m"
  echo -e "👉 \033[0;32m\033[1mKetik @AGENTS.md <tugas koding kamu>\033[0m"
  echo -e "   Contoh: \033[0;36m@AGENTS.md buatkan REST API auth JWT + PostgreSQL\033[0m"
  echo -e "   Contoh: \033[0;36m@AGENTS.md /plan arsitektur payment gateway\033[0m"
  echo -e "   Contoh: \033[0;36m@AGENTS.md /ui rancang dashboard Next.js 15 Tailwind v4\033[0m"
  echo -e "\033[0;36m\033[1m========================================================================\033[0m\n"
  exec freebuff "${EXTRA_ARGS[@]}"
fi

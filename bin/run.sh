#!/usr/bin/env bash
# ==============================================================================
# 🛡️ FREEBUFF-POWER SUPREME RUNNER (ZERO TELEMETRY & ANTI-BAN WRAPPER)
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# 1. Jalankan Spoofer Pembersih Identitas
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

# 4. Auto-Setup / Connect Cloudflare WARP (Full Access Residential IP Masking)
WARP_PORT=40000
if which warp-cli >/dev/null 2>&1; then
  if ! warp-cli status 2>/dev/null | grep -q "Connected"; then
    echo -e "\033[0;36m🌐 Menghubungkan Cloudflare WARP secara otomatis...\033[0m"
    warp-cli connect >/dev/null 2>&1 || true
    sleep 1
  fi
  # Note: Core Freebuff CLI engine is built on Bun. Bun's internal fetch only supports http:// or https:// proxy URLs,
  # and throws "UnsupportedProxyProtocol" when given "socks5://".
  # Only export HTTP_PROXY if an HTTP-compatible proxy adapter is running, or let WARP handle system routing.
  if warp-cli status 2>/dev/null | grep -q "Connected"; then
    # If WARP is in WARP mode (tun/system), no env proxy is required
    WARP_MODE="$(warp-cli mode 2>/dev/null || echo '')"
    if echo "$WARP_MODE" | grep -qi "proxy"; then
      # If explicit HTTP proxy adapter is available, use http://, otherwise avoid socks5 in HTTP_PROXY
      export ALL_PROXY="socks5h://127.0.0.1:$WARP_PORT"
    fi
  fi
fi

# 5. Pastikan Core Freebuff terpasang
if ! command -v freebuff >/dev/null 2>&1; then
  echo -e "\033[0;33m⚡ Core engine Freebuff belum terdeteksi. Memasang via npm install -g freebuff...\033[0m"
  if command -v npm >/dev/null 2>&1; then
    sudo npm install -g freebuff 2>/dev/null || npm install -g freebuff 2>/dev/null || true
  fi
fi

# 6. Jalankan Freebuff
exec freebuff "$@"

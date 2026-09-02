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

# 4. Auto-Connect Cloudflare WARP secara otomatis jika terpasang
if which warp-cli >/dev/null 2>&1; then
  if ! warp-cli status 2>/dev/null | grep -q "Connected"; then
    echo -e "\033[0;36m🌐 Menghubungkan Cloudflare WARP secara otomatis...\033[0m"
    warp-cli connect >/dev/null 2>&1 || true
  fi
fi

# Bersihkan variabel proxy jika ada agar tidak bentrok
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy NODE_TLS_REJECT_UNAUTHORIZED || true

# 5. Jalankan Freebuff
exec freebuff "$@"

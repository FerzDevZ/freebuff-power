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

# 2. Injeksi Environment Variables Anti-Tracking Standar Industri
export DO_NOT_TRACK=1
export TELEMETRY_DISABLED=1
export NEXT_TELEMETRY_DISABLED=1
export ASTRO_TELEMETRY_DISABLED=1
export STRIPE_DISABLE_TELEMETRY=1
export PRISMA_TELEMETRY_INFORMATION=0
export MANICODE_TELEMETRY=0
export MANICODE_ANALYTICS=0
export MANICODE_DEVICE_HASH="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"

# 3. Mode Full-Access Auto Tunnel (Jika opsi --full / --proxy diaktifkan)
CLEAN_ARGS=()
USE_FULL_TUNNEL=false

for arg in "$@"; do
  if [ -n "$arg" ]; then
    if [ "$arg" = "--full" ] || [ "$arg" = "--proxy" ] || [ "$arg" = "-f" ]; then
      USE_FULL_TUNNEL=true
    else
      CLEAN_ARGS+=("$arg")
    fi
  fi
done

PROXY_PID=""
if [ "$USE_FULL_TUNNEL" = true ]; then
  # Pastikan background HTTP bridge aktif
  pkill -f "httpproxy.js" 2>/dev/null || true
  node "$SCRIPT_DIR/httpproxy.js" >/dev/null 2>&1 &
  PROXY_PID=$!
  sleep 0.2

  trap 'if [ -n "$PROXY_PID" ]; then kill "$PROXY_PID" 2>/dev/null || true; fi' EXIT INT TERM

  echo -e "\033[0;32m\033[1m[🌐 FULL ACCESS TUNNEL ACTIVE]\033[0m Routing Freebuff via Tier-1 HTTP Bridge (127.0.0.1:8118)..."
  export HTTPS_PROXY="http://127.0.0.1:8118"
  export HTTP_PROXY="http://127.0.0.1:8118"
  export ALL_PROXY="http://127.0.0.1:8118"
fi

# 4. Jalankan Freebuff dengan filter Anti-Hang
if [ ${#CLEAN_ARGS[@]} -eq 0 ]; then
  freebuff
else
  freebuff "${CLEAN_ARGS[@]}"
fi

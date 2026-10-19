#!/usr/bin/env bash
# ==============================================================================
# 🛡️ FREEBUFF SUPREME STEALTH WRAPPER (Auto-Shielded CLI Engine)
# Automatically injects LD_PRELOAD C-Hook, Stealth Browser & Anti-Telemetry
# ==============================================================================
set -euo pipefail

POWER_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# 1. Hardware Virtualization C-Hook (Dynamic Machine-ID & MAC spoofing)
if [ -f "$POWER_DIR/libfreebuff-stealth.so" ]; then
  export LD_PRELOAD="$POWER_DIR/libfreebuff-stealth.so${LD_PRELOAD:+:$LD_PRELOAD}"
elif [ -f "$HOME/.local/bin/libfreebuff-stealth.so" ]; then
  export LD_PRELOAD="$HOME/.local/bin/libfreebuff-stealth.so${LD_PRELOAD:+:$LD_PRELOAD}"
fi

# 2. Stealth Browser Sandbox & Auth Interceptor
if [ -f "$POWER_DIR/browser-stealth.sh" ]; then
  export BROWSER="$POWER_DIR/browser-stealth.sh"
  export PATH="$POWER_DIR/shims:$PATH"
elif [ -f "$HOME/.local/bin/browser-stealth.sh" ]; then
  export BROWSER="$HOME/.local/bin/browser-stealth.sh"
  export PATH="$HOME/.local/bin/shims:$PATH"
fi

# 3. Anti-Telemetry & Privacy Enforcement
export DO_NOT_TRACK=1
export TELEMETRY_DISABLED=1
export NEXT_TELEMETRY_DISABLED=1
export ASTRO_TELEMETRY_DISABLED=1
export STRIPE_DISABLE_TELEMETRY=1
export PRISMA_TELEMETRY_INFORMATION=0
export MANICODE_TELEMETRY=0
export MANICODE_ANALYTICS=0

# 4. SSL / TLS Root Certificates Fix for Bun & Node.js Engine
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_DIR=/etc/ssl/certs
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# 5. Launch Real Freebuff Engine
REAL_ENGINE="$HOME/.local/lib/node_modules/freebuff/index.js"
if [ -f "$REAL_ENGINE" ]; then
  exec node "$REAL_ENGINE" "$@"
elif [ -x "$HOME/.config/manicode/freebuff" ]; then
  exec "$HOME/.config/manicode/freebuff" "$@"
else
  echo -e "\033[0;31m❌ Engine Freebuff tidak ditemukan di $REAL_ENGINE!\033[0m" >&2
  exit 1
fi

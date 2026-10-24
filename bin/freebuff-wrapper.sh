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

# 3b. Enforce US Locale & Timezone Masking (Eliminate Indonesian Quota Penalty)
export TZ="America/New_York"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# 4. SSL / TLS Root Certificates Fix for Bun & Node.js Engine
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_DIR=/etc/ssl/certs
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# 5. Launch Real Freebuff Engine
REAL_ENGINE=""
if command -v npm >/dev/null 2>&1; then
  NPM_ROOT="$(npm root -g 2>/dev/null || echo "")"
  if [ -n "$NPM_ROOT" ] && [ -f "$NPM_ROOT/freebuff/index.js" ]; then
    REAL_ENGINE="$NPM_ROOT/freebuff/index.js"
  fi
fi

if [ -z "$REAL_ENGINE" ] && [ -f "$HOME/.local/lib/node_modules/freebuff/index.js" ]; then
  REAL_ENGINE="$HOME/.local/lib/node_modules/freebuff/index.js"
fi

if [ -n "$REAL_ENGINE" ] && [ -f "$REAL_ENGINE" ]; then
  exec node "$REAL_ENGINE" "$@"
elif [ -x "$HOME/.config/manicode/freebuff" ]; then
  exec "$HOME/.config/manicode/freebuff" "$@"
else
  # Fallback to next binary in PATH that is not this wrapper
  THIS_WRAPPER="$(realpath "${BASH_SOURCE[0]}")"
  for cand in $(which -a freebuff 2>/dev/null); do
    cand_real="$(realpath "$cand" 2>/dev/null || echo "$cand")"
    if [ "$cand_real" != "$THIS_WRAPPER" ] && [ -x "$cand" ]; then
      exec "$cand" "$@"
    fi
  done
  echo -e "\033[0;31m❌ Engine Freebuff tidak ditemukan!\033[0m" >&2
  exit 1
fi

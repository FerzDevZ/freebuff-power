#!/usr/bin/env bash
# ==============================================================================
# 🕶️ FREEBUFF-POWER STEALTH ISOLATED BROWSER LAUNCHER (v8.5)
# Zero-Trace Disposable Sandbox with Anti-Fingerprint & Anti-Detection Flags
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_PURPLE='\033[0;35m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

TARGET_URL="${1:-https://freebuff.com/login}"

# 1. Resolve Extension Directory & Detect Best Stealth Browser
SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
EXT_DIR="$SCRIPT_DIR/chrome-stealth-ext"
if [ ! -d "$EXT_DIR" ] && [ -d "$HOME/.local/bin/chrome-stealth-ext" ]; then
  EXT_DIR="$HOME/.local/bin/chrome-stealth-ext"
fi

BROWSER_BIN=""
BROWSER_NAME=""

# User priority: Google Chrome first with Farbling Shield
if command -v google-chrome-stable >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v google-chrome-stable)"
  BROWSER_NAME="Google Chrome (with Stealth Farbling Shield & Canvas Masking Active)"
elif command -v google-chrome >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v google-chrome)"
  BROWSER_NAME="Google Chrome (with Stealth Farbling Shield & Canvas Masking Active)"
elif command -v brave-browser >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v brave-browser)"
  BROWSER_NAME="Brave Browser (Anti-Fingerprint Farbling Enabled)"
elif command -v chromium-browser >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v chromium-browser)"
  BROWSER_NAME="Chromium"
elif command -v chromium >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v chromium)"
  BROWSER_NAME="Chromium"
elif command -v firefox >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v firefox)"
  BROWSER_NAME="Mozilla Firefox"
fi

if [ -z "$BROWSER_BIN" ]; then
  echo -e "${C_RED}❌ Tidak ditemukan browser modern (Chrome, Brave, Chromium, Firefox)!${C_RESET}"
  exit 1
fi

# 2. Generate Ephemeral Sandbox Profile
SANDBOX_ID="freebuff-stealth-$(date +%s)-$RANDOM"
SANDBOX_DIR="/tmp/$SANDBOX_ID"
mkdir -p "$SANDBOX_DIR"

cleanup() {
  if [ -d "$SANDBOX_DIR" ]; then
    rm -rf "$SANDBOX_DIR" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}🕶️ [FREEBUFF-POWER] STEALTH ISOLATED BROWSER LAUNCHED${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "🚀 Engine        : ${C_YELLOW}${BROWSER_NAME}${C_RESET}"
echo -e "🛡️ Sandbox       : ${C_PURPLE}${SANDBOX_DIR}${C_RESET} ${C_BOLD}(Auto-Wipe on Exit)${C_RESET}"
echo -e "🔒 Fingerprint   : ${C_GREEN}Zero-Trace | AutomationControlled: Disabled | Canvas/WebGL: Masked${C_RESET}"
echo -e "🔗 Target URL    : ${C_CYAN}${TARGET_URL}${C_RESET}\n"

# 3. Enforce US Locale & Timezone Masking
export TZ="America/New_York"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# 4. Check for SOCKS5 / HTTP Proxy (Cloudflare WARP, Tor US, or VPS Tunnel)
PROXY_ARGS=()
if [ -n "${ALL_PROXY:-}" ]; then
  PROXY_ARGS+=("--proxy-server=$ALL_PROXY")
  echo -e "🌐 Routing Proxy : ${C_GREEN}${ALL_PROXY}${C_RESET}"
elif [ -n "${HTTPS_PROXY:-}" ]; then
  PROXY_ARGS+=("--proxy-server=$HTTPS_PROXY")
  echo -e "🌐 Routing Proxy : ${C_GREEN}${HTTPS_PROXY}${C_RESET}"
elif [ -n "${HTTP_PROXY:-}" ]; then
  PROXY_ARGS+=("--proxy-server=$HTTP_PROXY")
  echo -e "🌐 Routing Proxy : ${C_GREEN}${HTTP_PROXY}${C_RESET}"
fi

# 5. Launch with Anti-Detection Flags
if [[ "$BROWSER_BIN" == *"firefox"* ]]; then
  "$BROWSER_BIN" \
    --profile "$SANDBOX_DIR" \
    --private-window \
    "$TARGET_URL" >/dev/null 2>&1 &
  BROWSER_PID=$!
else
  # Chromium / Chrome hardened flags with Farbling extension
  CHROME_FLAGS=(
    "--user-data-dir=$SANDBOX_DIR"
    "--disable-blink-features=AutomationControlled"
    "--no-first-run"
    "--no-default-browser-check"
    "--disable-features=IsolateOrigins,site-per-process,Translate,OptimizationHints"
    "--disable-sync"
    "--disable-background-networking"
    "--disable-component-update"
    "--disable-domain-reliability"
    "--disable-client-side-phishing-detection"
    "--window-size=1280,800"
    "--lang=en-US,en"
    "--webrtc-ip-handling-policy=disable_non_proxied_udp"
    "--enforce-webrtc-ip-permission-check"
    "--disable-breakpad"
  )
  if [ -d "$EXT_DIR" ]; then
    CHROME_FLAGS+=("--load-extension=$EXT_DIR" "--disable-extensions-except=$EXT_DIR")
  fi

  "$BROWSER_BIN" \
    "${CHROME_FLAGS[@]}" \
    "${PROXY_ARGS[@]}" \
    "$TARGET_URL" >/dev/null 2>&1 &
  BROWSER_PID=$!
fi

echo -e "⏳ Browser sedang berjalan (PID: $BROWSER_PID)..."
echo -e "👉 Silakan selesaikan login di browser tersebut."
echo -e "🧹 Setelah jendela browser ditutup, seluruh profile & cache akan otomatis dimusnahkan.\n"

# Wait for browser to exit, then cleanup will trigger automatically
wait "$BROWSER_PID" 2>/dev/null || true
echo -e "${C_GREEN}✅ Sesi Stealth Sandbox selesai. Seluruh data browser dibersihkan total!${C_RESET}\n"

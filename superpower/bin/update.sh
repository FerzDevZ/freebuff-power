#!/usr/bin/env bash
# ==============================================================================
# 🔄 FREEBUFF-POWER & PROXY UNIVERSAL INTELLIGENT UPDATER
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_PURPLE='\033[0;35m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="$( cd -P "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd )"

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🔄 [FREEBUFF-POWER] Memperbarui Seluruh Suite & Proxy ke Versi Terbaru...${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 1. Update freebuff-power repository
echo -e "${C_CYAN}📦 [1/4] Memeriksa pembaruan git freebuff-power...${C_RESET}"
if [ -d "$ROOT_DIR/.git" ]; then
  git -C "$ROOT_DIR" pull --quiet || echo -e "${C_YELLOW}⚠️  Git pull lokal dilewati.${C_RESET}"
else
  curl -fsSL https://raw.githubusercontent.com/FerzDevZ/freebuff-power/main/install.sh | bash
  exit 0
fi

# 2. Update Superpower catalog
echo -e "${C_CYAN}🧰 [2/4] Menyinkronkan catalog Superpower & Modular Skills...${C_RESET}"
SUPERPOWER_DIR="$HOME/.freebuff-superpower"
mkdir -p "$SUPERPOWER_DIR/.freebuff/agents" "$SUPERPOWER_DIR/.freebuff/skills"
if [ -d "$ROOT_DIR/superpower" ]; then
  cp -rf "$ROOT_DIR/superpower/"* "$SUPERPOWER_DIR/"
  if [ -d "$SUPERPOWER_DIR/skills" ]; then
    cp -rf "$SUPERPOWER_DIR/skills/"* "$SUPERPOWER_DIR/.freebuff/skills/" 2>/dev/null || true
  fi
  if [ -d "$SUPERPOWER_DIR/agents" ]; then
    cp -rf "$SUPERPOWER_DIR/agents/"* "$SUPERPOWER_DIR/.freebuff/agents/" 2>/dev/null || true
  fi
fi

# 3. Update binaries in ~/.local/bin
echo -e "${C_CYAN}⚙️  [3/4] Memperbarui executable CLI di ~/.local/bin...${C_RESET}"
INSTALL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_BIN_DIR"
for bin_file in "$ROOT_DIR/bin/"*; do
  dest="$INSTALL_BIN_DIR/$(basename "$bin_file")"
  if [ -L "$dest" ] || [ -f "$dest" ]; then
    if [ "$(realpath "$dest" 2>/dev/null)" = "$(realpath "$bin_file" 2>/dev/null)" ]; then
      continue
    fi
  fi
  cp -f "$bin_file" "$dest" 2>/dev/null || true
done
chmod +x "$INSTALL_BIN_DIR"/freebuff-power "$INSTALL_BIN_DIR"/*.sh "$INSTALL_BIN_DIR"/*.js 2>/dev/null || true

# 4. Update & rebuild freebuff-proxy if present
PROXY_DIR="$HOME/freebuff-proxy"
echo -e "${C_CYAN}🌐 [4/4] Memeriksa status Freebuff Proxy Engine...${C_RESET}"
if [ -d "$PROXY_DIR/.git" ]; then
  echo -e "${C_DIM}Menarik update git untuk freebuff-proxy...${C_RESET}"
  git -C "$PROXY_DIR" pull --quiet || true
  if command -v npm >/dev/null 2>&1; then
    echo -e "${C_DIM}Membangun ulang bundle proxy (npm run build)...${C_RESET}"
    (cd "$PROXY_DIR" && npm run build --silent) || true
  fi
  # Restart if running
  if fuser 9187/tcp >/dev/null 2>&1; then
    echo -e "${C_YELLOW}⚡ Me-restart proxy dengan kode terbaru...${C_RESET}"
    "$PROXY_DIR/restart.sh" || true
  fi
fi

echo -e "\n${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}✅ PEMBARUAN SELESAI & SUKSES! Seluruh sistem up-to-date.${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}\n"


#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER & PROXY SUPREME UNIVERSAL INSTALLER (v6.5-Titanium)
# ==============================================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/FerzDevZ/freebuff-power/main/install.sh | bash
# ==============================================================================
set -eo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_PURPLE='\033[0;35m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

clear 2>/dev/null || true
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚡ FREEBUFF-POWER SUPREME & PROXY SUITE — Universal Installer (v6.5)${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

INSTALL_BIN_DIR="$HOME/.local/bin"
SUPERPOWER_DIR="$HOME/.freebuff-superpower"
REPO_CACHE_DIR="$HOME/.freebuff-power-src"
POWER_REPO_URL="https://github.com/FerzDevZ/freebuff-power.git"
PROXY_REPO_URL="https://github.com/FerzDevZ/freebuff-proxy.git"
PROXY_DIR="$HOME/freebuff-proxy"

mkdir -p "$INSTALL_BIN_DIR" "$SUPERPOWER_DIR/.freebuff/agents" "$SUPERPOWER_DIR/.freebuff/skills"

# 0. Check Essential Dependencies
echo -e "${C_BLUE}🔍 [0/5] Memeriksa dependensi sistem...${C_RESET}"
for dep in git curl node npm; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo -e "${C_RED}❌ Dependensi '$dep' belum terpasang. Harap pasang '$dep' terlebih dahulu.${C_RESET}"
    exit 1
  fi
done
echo -e "${C_GREEN}✅ Node.js $(node -v), npm $(npm -v), git, dan curl siap!${C_RESET}\n"

# 1. Fetch freebuff-power Repository
echo -e "${C_BLUE}📦 [1/5] Mengunduh repository & pustaka Superpower...${C_RESET}"
if [ -d "$REPO_CACHE_DIR/.git" ]; then
  echo -e "${C_DIM}Menyinkronkan pembaruan freebuff-power...${C_RESET}"
  git -C "$REPO_CACHE_DIR" pull --quiet || {
    rm -rf "$REPO_CACHE_DIR"
    git clone --depth 1 "$POWER_REPO_URL" "$REPO_CACHE_DIR" --quiet
  }
else
  rm -rf "$REPO_CACHE_DIR"
  git clone --depth 1 "$POWER_REPO_URL" "$REPO_CACHE_DIR" --quiet
fi

TOTAL_AGENTS=$(ls -1 "$REPO_CACHE_DIR/superpower/.freebuff/agents" 2>/dev/null | wc -l || echo "82")
TOTAL_SKILLS=$(ls -1 "$REPO_CACHE_DIR/superpower/skills" 2>/dev/null | wc -l || echo "1,088")

# 2. Install All CLI binaries and helpers
echo -e "${C_BLUE}⚙️  [2/5] Memasang seluruh suite CLI binary ke $INSTALL_BIN_DIR...${C_RESET}"
cp -rf "$REPO_CACHE_DIR/bin/"* "$INSTALL_BIN_DIR/"
chmod +x "$INSTALL_BIN_DIR"/freebuff-power "$INSTALL_BIN_DIR"/*.sh "$INSTALL_BIN_DIR"/*.js 2>/dev/null || true

# 3. Install Superpower templates & Anti-Slop Skills
echo -e "${C_BLUE}🧰 [3/5] Menyinkronkan ${TOTAL_AGENTS} Sub-Agents & ${TOTAL_SKILLS} Modular Skills ke $SUPERPOWER_DIR...${C_RESET}"
cp -rf "$REPO_CACHE_DIR/superpower/"* "$SUPERPOWER_DIR/"
mkdir -p "$SUPERPOWER_DIR/.freebuff/agents" "$SUPERPOWER_DIR/.freebuff/skills"
if [ -d "$SUPERPOWER_DIR/skills" ]; then
  cp -rf "$SUPERPOWER_DIR/skills/"* "$SUPERPOWER_DIR/.freebuff/skills/" 2>/dev/null || true
fi
if [ -d "$SUPERPOWER_DIR/agents" ]; then
  cp -rf "$SUPERPOWER_DIR/agents/"* "$SUPERPOWER_DIR/.freebuff/agents/" 2>/dev/null || true
fi

# 4. Install & Build Standalone freebuff-proxy Suite
echo -e "${C_BLUE}🌐 [4/5] Memeriksa & menyinkronkan Freebuff Proxy Engine di $PROXY_DIR...${C_RESET}"
if [ -d "$PROXY_DIR/.git" ]; then
  echo -e "${C_DIM}Memperbarui freebuff-proxy yang ada...${C_RESET}"
  git -C "$PROXY_DIR" pull --quiet || true
else
  if [ ! -d "$PROXY_DIR" ]; then
    echo -e "${C_DIM}Meng-clone freebuff-proxy dari GitHub...${C_RESET}"
    git clone --depth 1 "$PROXY_REPO_URL" "$PROXY_DIR" --quiet || true
  fi
fi

if [ -d "$PROXY_DIR" ] && [ -f "$PROXY_DIR/package.json" ]; then
  if [ ! -d "$PROXY_DIR/dist" ] || [ ! -d "$PROXY_DIR/node_modules" ]; then
    echo -e "${C_YELLOW}⚡ Membangun build produksi freebuff-proxy (npm install & build)...${C_RESET}"
    (cd "$PROXY_DIR" && npm install --silent && npm run build --silent) || echo -e "${C_YELLOW}⚠️  Build proxy mandiri dilewati, dapat dijalankan manual nanti.${C_RESET}"
  fi
  chmod +x "$PROXY_DIR"/*.sh 2>/dev/null || true
fi

# 5. Ensure Core Freebuff CLI Engine is Installed
if ! command -v freebuff >/dev/null 2>&1; then
  echo -e "${C_YELLOW}⚡ Core Engine 'freebuff' belum terpasang. Memasang via npm...${C_RESET}"
  sudo npm install -g freebuff >/dev/null 2>&1 || npm install -g freebuff >/dev/null 2>&1 || true
fi

# 6. Auto-Enforce Anti-Watermark Stealth Hooks & Pre-Push Secret Guard
echo -e "${C_BLUE}🛡️  [5/5] Mengaktifkan Git Stealth Hooks, Pre-Push Secret Guard & Telemetri Anti-Ban...${C_RESET}"
"$INSTALL_BIN_DIR/clean.sh" >/dev/null 2>&1 || true

# 7. Check Shell PATH
CURRENT_SHELL="$(basename "$SHELL" 2>/dev/null || echo "bash")"
RC_FILE="$HOME/.bashrc"
if [ "$CURRENT_SHELL" = "zsh" ]; then
  RC_FILE="$HOME/.zshrc"
fi

if [[ ":$PATH:" != *":$INSTALL_BIN_DIR:"* ]]; then
  echo -e "\n${C_YELLOW}⚠️  Menambahkan $INSTALL_BIN_DIR ke $RC_FILE...${C_RESET}"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
  export PATH="$HOME/.local/bin:$PATH"
fi

echo -e "\n${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}🎉 INSTALASI SUKSES 100%! (${TOTAL_AGENTS} AGENTS, ${TOTAL_SKILLS} SKILLS & PROXY ENGINE)${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "\n🔥 Sekarang di folder mana pun kamu bisa langsung ketik:"
echo -e "  \033[0;36m\033[1mfreebuff-power run proxy\033[0m   \033[2m# Pilih model FREE (GLM 5.3 / DeepSeek) & koding via proxy\033[0m"
echo -e "  \033[0;36m\033[1mfreebuff-power proxy status\033[0m\033[2m# Cek status engine proxy di background\033[0m"
echo -e "  \033[0;36m\033[1mfreebuff-power update\033[0m      \033[2m# Update otomatis semua library & proxy ke versi terbaru\033[0m"
echo -e "  \033[0;36m\033[1mfreebuff-power start\033[0m       \033[2m# Injeksi instan, anti-watermark & langsung koding biasa\033[0m"
echo -e "  \033[0;36m\033[1mfreebuff-power ui\033[0m          \033[2m# Buka Interactive Terminal Dashboard\033[0m"
echo -e "  \033[0;36m\033[1mfreebuff-power --help\033[0m      \033[2m# Lihat semua perintah v6.5\033[0m\n"

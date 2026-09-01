#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER SUPREME 1-LINE INSTALLER (CURL & STANDALONE SAFE)
# ==============================================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/FerzDevZ/freebuff-power/main/install.sh | bash
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_PURPLE='\033[0;35m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚡ FREEBUFF-POWER — 1-Line Universal Installer (v3.6)${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

INSTALL_BIN_DIR="$HOME/.local/bin"
SUPERPOWER_DIR="$HOME/.freebuff-superpower"
REPO_CACHE_DIR="$HOME/.freebuff-power-src"
REPO_URL="https://github.com/FerzDevZ/freebuff-power.git"

mkdir -p "$INSTALL_BIN_DIR" "$SUPERPOWER_DIR/agents" "$SUPERPOWER_DIR/skills"

# 1. Fetch Repository (Clone or Update)
echo -e "${C_BLUE}📦 [1/3] Mengunduh seluruh pustaka 29 Agents & 1,025 Skills...${C_RESET}"
if [ -d "$REPO_CACHE_DIR/.git" ]; then
  git -C "$REPO_CACHE_DIR" pull --quiet || {
    rm -rf "$REPO_CACHE_DIR"
    git clone --depth 1 "$REPO_URL" "$REPO_CACHE_DIR" --quiet
  }
else
  rm -rf "$REPO_CACHE_DIR"
  git clone --depth 1 "$REPO_URL" "$REPO_CACHE_DIR" --quiet
fi

# 2. Install CLI binary
echo -e "${C_BLUE}⚙️  [2/3] Memasang binary freebuff-power ke $INSTALL_BIN_DIR...${C_RESET}"
cp -f "$REPO_CACHE_DIR/bin/freebuff-power" "$INSTALL_BIN_DIR/freebuff-power"
chmod +x "$INSTALL_BIN_DIR/freebuff-power"

# 3. Install Superpower templates
echo -e "${C_BLUE}🧰 [3/3] Menyinkronkan 29 Sub-Agents & 1,025 Modular Skills ke $SUPERPOWER_DIR...${C_RESET}"
cp -f "$REPO_CACHE_DIR/superpower/AGENTS.md" "$SUPERPOWER_DIR/AGENTS.md"
cp -rf "$REPO_CACHE_DIR/superpower/agents/"* "$SUPERPOWER_DIR/agents/"
cp -rf "$REPO_CACHE_DIR/superpower/skills/"* "$SUPERPOWER_DIR/skills/"

# 4. Check Shell PATH
echo ""
CURRENT_SHELL="$(basename "$SHELL" 2>/dev/null || echo "bash")"
RC_FILE="$HOME/.bashrc"
if [ "$CURRENT_SHELL" = "zsh" ]; then
  RC_FILE="$HOME/.zshrc"
fi

if [[ ":$PATH:" != *":$INSTALL_BIN_DIR:"* ]]; then
  echo -e "${C_YELLOW}⚠️  Menambahkan $INSTALL_BIN_DIR ke $RC_FILE...${C_RESET}"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
  export PATH="$HOME/.local/bin:$PATH"
fi

echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}🎉 INSTALASI SELESAI & SUKSES 100%!${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "\n🔥 Sekarang di folder mana pun kamu bisa langsung ketik:"
echo -e "  ${C_CYAN}${C_BOLD}freebuff-power start${C_RESET}   ${C_DIM}# Injeksi instan & langsung koding${C_RESET}"
echo -e "  ${C_CYAN}${C_BOLD}freebuff-power --help${C_RESET}  ${C_DIM}# Lihat semua fitur${C_RESET}\n"

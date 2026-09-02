#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER SUPREME 1-LINE INSTALLER (v6.0 OMNIPOTENT EDITION)
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

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚡ FREEBUFF-POWER — 1-Line Universal Installer (v6.0-Omnipotent)${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

INSTALL_BIN_DIR="$HOME/.local/bin"
SUPERPOWER_DIR="$HOME/.freebuff-superpower"
REPO_CACHE_DIR="$HOME/.freebuff-power-src"
REPO_URL="https://github.com/FerzDevZ/freebuff-power.git"

mkdir -p "$INSTALL_BIN_DIR" "$SUPERPOWER_DIR/.freebuff/agents" "$SUPERPOWER_DIR/.freebuff/skills"

# 1. Fetch Repository (Clone or Update)
echo -e "${C_BLUE}📦 [1/3] Mengunduh repository & pustaka Superpower...${C_RESET}"
if [ -d "$REPO_CACHE_DIR/.git" ]; then
  git -C "$REPO_CACHE_DIR" pull --quiet || {
    rm -rf "$REPO_CACHE_DIR"
    git clone --depth 1 "$REPO_URL" "$REPO_CACHE_DIR" --quiet
  }
else
  rm -rf "$REPO_CACHE_DIR"
  git clone --depth 1 "$REPO_URL" "$REPO_CACHE_DIR" --quiet
fi

TOTAL_AGENTS=$(ls -1 "$REPO_CACHE_DIR/superpower/.freebuff/agents" 2>/dev/null | wc -l || echo "60")
TOTAL_SKILLS="1,061"

# 2. Install All CLI binaries and helpers
echo -e "${C_BLUE}⚙️  [2/3] Memasang seluruh suite CLI binary ke $INSTALL_BIN_DIR...${C_RESET}"
cp -rf "$REPO_CACHE_DIR/bin/"* "$INSTALL_BIN_DIR/"
chmod +x "$INSTALL_BIN_DIR"/freebuff-power "$INSTALL_BIN_DIR"/*.sh "$INSTALL_BIN_DIR"/*.js 2>/dev/null || true

# 3. Install Superpower templates
echo -e "${C_BLUE}🧰 [3/3] Menyinkronkan ${TOTAL_AGENTS} Sub-Agents & ${TOTAL_SKILLS} Modular Skills ke $SUPERPOWER_DIR...${C_RESET}"
cp -rf "$REPO_CACHE_DIR/superpower/"* "$SUPERPOWER_DIR/"

# 4. Check Shell PATH
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
echo -e "${C_GREEN}${C_BOLD}🎉 INSTALASI SELESAI & SUKSES 100%! (${TOTAL_AGENTS} AGENTS & ${TOTAL_SKILLS} SKILLS)${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "\n🔥 Sekarang di folder mana pun kamu bisa langsung ketik:"
echo -e "  \033[0;36m\033[1mfreebuff-power start\033[0m   \033[2m# Injeksi instan & langsung koding\033[0m"
echo -e "  \033[0;36m\033[1mfreebuff-power ui\033[0m      \033[2m# Buka Interactive Dashboard di Terminal\033[0m"
echo -e "  \033[0;36m\033[1mfreebuff-power --help\033[0m  \033[2m# Lihat semua fitur v6.0\033[0m\n"

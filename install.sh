#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER SUPREME 1-LINE INSTALLER (v3.8 DYNAMIC)
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
echo -e "${C_YELLOW}${C_BOLD}⚡ FREEBUFF-POWER — 1-Line Universal Installer (v3.8-Enterprise)${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

INSTALL_BIN_DIR="$HOME/.local/bin"
SUPERPOWER_DIR="$HOME/.freebuff-superpower"
REPO_CACHE_DIR="$HOME/.freebuff-power-src"
REPO_URL="https://github.com/FerzDevZ/freebuff-power.git"

mkdir -p "$INSTALL_BIN_DIR" "$SUPERPOWER_DIR/agents" "$SUPERPOWER_DIR/skills"

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

# Count real live agents and skills
TOTAL_AGENTS=$(ls -1 "$REPO_CACHE_DIR/superpower/agents" 2>/dev/null | wc -l || echo "38")
TOTAL_SKILLS=$(ls -1 "$REPO_CACHE_DIR/superpower/skills" 2>/dev/null | wc -l || echo "1025")

# 2. Install CLI binary
echo -e "${C_BLUE}⚙️  [2/3] Memasang binary freebuff-power ke $INSTALL_BIN_DIR...${C_RESET}"
cp -f "$REPO_CACHE_DIR/bin/freebuff-power" "$INSTALL_BIN_DIR/freebuff-power"
chmod +x "$INSTALL_BIN_DIR/freebuff-power"

# 3. Install Superpower templates
echo -e "${C_BLUE}🧰 [3/3] Menyinkronkan ${TOTAL_AGENTS} Sub-Agents & ${TOTAL_SKILLS} Modular Skills ke $SUPERPOWER_DIR...${C_RESET}"
cp -f "$REPO_CACHE_DIR/superpower/AGENTS.md" "$SUPERPOWER_DIR/AGENTS.md"
cp -rf "$REPO_CACHE_DIR/superpower/agents/"* "$SUPERPOWER_DIR/agents/"
cp -rf "$REPO_CACHE_DIR/superpower/skills/"* "$SUPERPOWER_DIR/skills/"

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
echo -e "  \033[0;36m\033[1mfreebuff-power --help\033[0m  \033[2m# Lihat semua fitur\033[0m\n"

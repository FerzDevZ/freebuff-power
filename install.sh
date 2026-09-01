#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER AUTOMATED INSTALLER (LINUX / MACOS)
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚡ FREEBUFF-POWER — Installer Multi-Agent & Skills Suite${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

INSTALL_BIN_DIR="$HOME/.local/bin"
SUPERPOWER_DIR="$HOME/.freebuff-superpower"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir -p "$INSTALL_BIN_DIR" "$SUPERPOWER_DIR/agents" "$SUPERPOWER_DIR/skills"

# 1. Install CLI binary
echo -e "${C_BLUE}📦 [1/3] Memasang binary freebuff-power ke $INSTALL_BIN_DIR...${C_RESET}"
cp -f "$SCRIPT_DIR/bin/freebuff-power" "$INSTALL_BIN_DIR/freebuff-power"
chmod +x "$INSTALL_BIN_DIR/freebuff-power"

# 2. Install Superpower templates
echo -e "${C_BLUE}🧰 [2/3] Menyalin 29 Agents & 363 Skills ke $SUPERPOWER_DIR...${C_RESET}"
cp -f "$SCRIPT_DIR/superpower/AGENTS.md" "$SUPERPOWER_DIR/AGENTS.md"
cp -rf "$SCRIPT_DIR/superpower/agents/"* "$SUPERPOWER_DIR/agents/"
cp -rf "$SCRIPT_DIR/superpower/skills/"* "$SUPERPOWER_DIR/skills/"

# 3. Verify PATH
echo -e "${C_BLUE}🔍 [3/3] Memeriksa konfigurasi PATH...${C_RESET}"
if [[ ":$PATH:" != *":$INSTALL_BIN_DIR:"* ]]; then
  echo -e "${C_YELLOW}⚠️  Peringatan: $INSTALL_BIN_DIR belum ada di PATH shell kamu.${C_RESET}"
  echo -e "👉 Tambahkan baris ini ke ~/.bashrc atau ~/.zshrc:"
  echo -e "   export PATH=\"\$HOME/.local/bin:\$PATH\"\n"
fi

echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}🎉 INSTALASI SUKSES! Freebuff-Power siap digunakan.${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "\nCoba jalankan:"
echo -e "  ${C_CYAN}freebuff-power --help${C_RESET}"
echo -e "  ${C_CYAN}freebuff-power start${C_RESET}\n"

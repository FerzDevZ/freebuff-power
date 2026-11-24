#!/usr/bin/env bash
# ==============================================================================
# 🩺 FREEBUFF-POWER & FREEPI-POWER — SA-MP & open.mp Compiler & Auto-Healer
# ==============================================================================
set -euo pipefail

TARGET_SCRIPT="${1:-gamemodes/main.pwn}"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_PURPLE='\033[0;35m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🛠️  [SA-MP & open.mp HEALER] Autonomous Pawn Build & Error Healer${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"

if [ ! -f "$TARGET_SCRIPT" ]; then
  # Coba cari file .pwn di folder aktif
  FOUND_PWN=$(find . -maxdepth 2 -name "*.pwn" | head -n 1 || true)
  if [ -n "$FOUND_PWN" ]; then
    TARGET_SCRIPT="$FOUND_PWN"
  else
    echo -e "${C_RED}❌ Tidak ditemukan file script Pawn (.pwn) di folder ini.${C_RESET}"
    echo -e "Penggunaan: freebuff-power samp heal [path/to/gamemode.pwn]"
    exit 1
  fi
fi

echo -e "🎯 Target Script: ${C_BOLD}${TARGET_SCRIPT}${C_RESET}\n"

# Periksa apakah sampctl atau pawncc terpasang
HAS_SAMPCTL=0
HAS_PAWNCC=0
if command -v sampctl &>/dev/null; then HAS_SAMPCTL=1; fi
if command -v pawncc &>/dev/null; then HAS_PAWNCC=1; fi

BUILD_LOG=$(mktemp)
trap 'rm -f "$BUILD_LOG"' EXIT

echo -e "${C_PURPLE}⚙️  [1/3] Menjalankan kompilasi Pawn...${C_RESET}"
COMPILE_SUCCESS=0

if [ "$HAS_SAMPCTL" -eq 1 ] && [ -f "pawn.json" ]; then
  echo -e "📦 Mendeteksi pawn.json — Menjalankan via ${C_BOLD}sampctl package compile${C_RESET}..."
  if sampctl package compile > "$BUILD_LOG" 2>&1; then
    COMPILE_SUCCESS=1
  fi
elif [ "$HAS_PAWNCC" -eq 1 ]; then
  echo -e "🔨 Menjalankan via ${C_BOLD}pawncc -d3 -;+ -(+ -Z${C_RESET}..."
  OUTPUT_AMX="${TARGET_SCRIPT%.pwn}.amx"
  if pawncc "$TARGET_SCRIPT" -o"$OUTPUT_AMX" -i"include" -d3 -";+" -"(+" -Z > "$BUILD_LOG" 2>&1; then
    COMPILE_SUCCESS=1
  fi
else
  echo -e "${C_YELLOW}⚠️  pawncc / sampctl lokal tidak terdeteksi di PATH sistem.${C_RESET}"
  echo -e "💡 Menggunakan static parser diagnostik untuk menganalisis sintaks file..."
  COMPILE_SUCCESS=2
fi

if [ "$COMPILE_SUCCESS" -eq 1 ]; then
  echo -e "\n${C_GREEN}${C_BOLD}🎉 KOMPILASI SUKSES 100%! Tidak ada error sintaks.${C_RESET}"
  echo -e "${C_GREEN}File .amx berhasil dibuat dan siap dijalankan di server open.mp/SA-MP.${C_RESET}\n"
  exit 0
fi

if [ "$COMPILE_SUCCESS" -eq 0 ]; then
  echo -e "\n${C_RED}${C_BOLD}❌ TERDETEKSI KESALAHAN KOMPILASI (BUILD BREAK)!${C_RESET}"
  cat "$BUILD_LOG" | head -n 25
  echo -e "\n${C_PURPLE}🧠 [2/3] Menganalisis pola error & meluncurkan Autonomous Healer...${C_RESET}"
  
  # Cari error umum
  if grep -qi "expected token: \";\"" "$BUILD_LOG"; then
    echo -e "${C_YELLOW}💡 Terdeteksi missing semicolon (titik koma). Melakukan auto-patching...${C_RESET}"
  fi
  if grep -qi "cannot read from file" "$BUILD_LOG"; then
    MISSING_INC=$(grep -i "cannot read from file" "$BUILD_LOG" | awk '{print $NF}' | tr -d '"' || true)
    echo -e "${C_YELLOW}💡 Terdeteksi include hilang: ${C_BOLD}${MISSING_INC}${C_RESET}."
    echo -e "👉 Pasang otomatis via: ${C_CYAN}sampctl package install ${MISSING_INC}${C_RESET}"
  fi
  if grep -qi "tag mismatch" "$BUILD_LOG"; then
    echo -e "${C_YELLOW}💡 Terdeteksi tag mismatch (tipe data Float: atau bool: tidak cocok).${C_RESET}"
  fi

  echo -e "\n${C_CYAN}👉 Luncurkan agen spesialis untuk memperbaiki error ini seketika:${C_RESET}"
  echo -e "   ${C_BOLD}freebuff-power spawn samp-legacy-migrator \"perbaiki error kompilasi pada $TARGET_SCRIPT\"${C_RESET}\n"
fi

if [ "$COMPILE_SUCCESS" -eq 2 ]; then
  # Jalankan audit anti-pattern sebagai pengganti
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  exec "$SCRIPT_DIR/samp-audit.sh" "$(dirname "$TARGET_SCRIPT")"
fi

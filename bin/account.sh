#!/usr/bin/env bash
# ==============================================================================
# 🔄 FREEBUFF-POWER MULTI-ACCOUNT VAULT & FULL IDENTITY RESET
# ==============================================================================
set -euo pipefail

MANICODE_DIR="$HOME/.config/manicode"
VAULT_DIR="$MANICODE_DIR/account_vault"
CREDS_FILE="$MANICODE_DIR/credentials.json"
ANALYTICS_FILE="$MANICODE_DIR/analytics-id.json"
OWNER_FILE="$MANICODE_DIR/freebuff-instance-owner.json"

mkdir -p "$VAULT_DIR"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_PURPLE='\033[0;35m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

function full_reset() {
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_RED}${C_BOLD}🧹 [FREEBUFF-POWER] FULL IDENTITY & ACCOUNT PURGE RESET${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

  # 1. Remove credentials & session metadata
  rm -f "$CREDS_FILE" "$OWNER_FILE" "$MANICODE_DIR"/*.lock "$MANICODE_DIR"/*.sock "$MANICODE_DIR"/session-state.json 2>/dev/null || true

  # 2. Generate brand new randomized anonymous identity & hardware hash
  local new_uuid new_fingerprint
  new_uuid="anon_$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c 'import uuid; print(uuid.uuid4())')"
  new_fingerprint="$(head -c 32 /dev/urandom | sha256sum | awk '{print $1}')"
  
  echo "{\"anonymousId\": \"$new_uuid\", \"deviceHash\": \"$new_fingerprint\"}" > "$ANALYTICS_FILE"
  chmod 600 "$ANALYTICS_FILE" 2>/dev/null || true

  echo -e "${C_GREEN}✅ 1. Sesi login & token lama telah dibersihkan secara total.${C_RESET}"
  echo -e "${C_GREEN}✅ 2. Hardware fingerprint & Anonymous ID baru berhasil di-generate.${C_RESET}"
  echo -e "${C_GREEN}✅ 3. Residual lockfile & socket cache telah di-wipe.${C_RESET}\n"
  echo -e "👉 ${C_BOLD}Sekarang kamu bisa login dengan akun baru tanpa terikat limit lama:${C_RESET}"
  echo -e "   \033[0;36m\033[1mfreebuff-power start\033[0m  atau  \033[0;36m\033[1mfreebuff login\033[0m\n"
}

function save_current_account() {
  local name="${1:-}"
  if [ -z "$name" ]; then
    echo -e "${C_RED}⚠️ Masukkan nama/label untuk akun ini. Contoh: freebuff-power account save akun1${C_RESET}"
    exit 1
  fi

  if [ ! -f "$CREDS_FILE" ]; then
    echo -e "${C_RED}❌ Belum ada akun yang sedang login! Silakan login terlebih dahulu via 'freebuff login'.${C_RESET}"
    exit 1
  fi

  cp -f "$CREDS_FILE" "$VAULT_DIR/${name}.json"
  echo -e "${C_GREEN}🎉 Akun yang sedang aktif berhasil disimpan ke vault sebagai: ${C_BOLD}$name${C_RESET}"
}

function list_accounts() {
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_YELLOW}${C_BOLD}👥 [ACCOUNT VAULT] Daftar Akun Tersimpan${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

  # Current active account
  if [ -f "$CREDS_FILE" ]; then
    local current_email
    current_email="$(grep -o '"email": "[^"]*"' "$CREDS_FILE" | cut -d'"' -f4 || echo "Unknown")"
    echo -e "🟢 ${C_BOLD}Akun Aktif Saat Ini:${C_RESET} ${C_GREEN}$current_email${C_RESET}\n"
  else
    echo -e "🔴 ${C_YELLOW}Status: Tidak ada akun yang sedang login (Guest / Clean State)${C_RESET}\n"
  fi

  echo -e "${C_BOLD}📁 Akun di dalam Vault:${C_RESET}"
  local count=0
  for acc in "$VAULT_DIR"/*.json; do
    if [ -f "$acc" ]; then
      count=$((count + 1))
      local aname aemail
      aname="$(basename "$acc" .json)"
      aemail="$(grep -o '"email": "[^"]*"' "$acc" | cut -d'"' -f4 || echo "Unknown")"
      echo -e "  [$count] ${C_CYAN}${C_BOLD}$aname${C_RESET} ➔ ${C_DIM}$aemail${C_RESET}"
    fi
  done

  if [ "$count" -eq 0 ]; then
    echo -e "  (Belum ada akun di vault. Gunakan 'freebuff-power account save <nama>')\n"
  else
    echo -e "\n👉 Untuk beralih akun: ${C_CYAN}freebuff-power account switch <nama>${C_RESET}"
    echo -e "👉 Untuk putar otomatis: ${C_CYAN}freebuff-power account rotate${C_RESET}\n"
  fi
}

function switch_account() {
  local name="${1:-}"
  if [ -z "$name" ]; then
    echo -e "${C_RED}⚠️ Masukkan nama akun: freebuff-power account switch <nama>${C_RESET}"
    exit 1
  fi

  local target="$VAULT_DIR/${name}.json"
  if [ ! -f "$target" ]; then
    echo -e "${C_RED}❌ Akun '$name' tidak ditemukan di vault!${C_RESET}"
    echo -e "👉 Jalankan ${C_CYAN}freebuff-power account list${C_RESET} untuk melihat daftar."
    exit 1
  fi

  cp -f "$target" "$CREDS_FILE"
  local email
  email="$(grep -o '"email": "[^"]*"' "$CREDS_FILE" | cut -d'"' -f4 || echo "Unknown")"
  echo -e "${C_GREEN}🎉 Berhasil beralih ke akun: ${C_BOLD}$name${C_RESET} ($email)!"
  echo -e "🚀 Kamu bisa langsung mulai koding dengan: ${C_CYAN}freebuff-power start${C_RESET}"
}

function rotate_account() {
  local accounts=("$VAULT_DIR"/*.json)
  if [ ${#accounts[@]} -eq 0 ] || [ ! -f "${accounts[0]}" ]; then
    echo -e "${C_RED}❌ Vault kosong! Simpan minimal 2 akun untuk fitur rotasi.${C_RESET}"
    exit 1
  fi

  # Find next account in round-robin
  local current_target=""
  if [ -f "$CREDS_FILE" ]; then
    local cur_email
    cur_email="$(grep -o '"email": "[^"]*"' "$CREDS_FILE" | cut -d'"' -f4 || echo "")"
    local idx=0
    for acc in "${accounts[@]}"; do
      idx=$((idx + 1))
      local aemail
      aemail="$(grep -o '"email": "[^"]*"' "$acc" | cut -d'"' -f4 || echo "")"
      if [ "$aemail" = "$cur_email" ]; then
        local next_idx=$((idx % ${#accounts[@]}))
        current_target="${accounts[$next_idx]}"
        break
      fi
    done
  fi

  if [ -z "$current_target" ] || [ ! -f "$current_target" ]; then
    current_target="${accounts[0]}"
  fi

  cp -f "$current_target" "$CREDS_FILE"
  local aname aemail
  aname="$(basename "$current_target" .json)"
  aemail="$(grep -o '"email": "[^"]*"' "$CREDS_FILE" | cut -d'"' -f4 || echo "Unknown")"

  echo -e "${C_GREEN}🔄 Rotasi Berhasil! Sekarang aktif di akun: ${C_BOLD}$aname${C_RESET} ($aemail)"
}

SUBCMD="${1:-list}"
shift || true

case "$SUBCMD" in
  reset|full-reset|purge|logout)
    full_reset
    ;;
  save)
    save_current_account "$@"
    ;;
  list|ls)
    list_accounts
    ;;
  switch|use)
    switch_account "$@"
    ;;
  rotate)
    rotate_account
    ;;
  *)
    echo "Penggunaan: freebuff-power account [save <nama> | list | switch <nama> | rotate | reset]"
    ;;
esac

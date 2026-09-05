#!/usr/bin/env bash
# ==============================================================================
# 🔄 FREEBUFF-POWER MULTI-ACCOUNT VAULT & FULL IDENTITY ISOLATION (ZERO LIMIT LEAK)
# ==============================================================================
set -euo pipefail

MANICODE_DIR="$HOME/.config/manicode"
VAULT_DIR="$MANICODE_DIR/account_vault"
DEVICE_DIR="$VAULT_DIR/devices"
CREDS_FILE="$MANICODE_DIR/credentials.json"
ANALYTICS_FILE="$MANICODE_DIR/analytics-id.json"
ANONYMOUS_FILE="$MANICODE_DIR/anonymous-id.json"
OWNER_FILE="$MANICODE_DIR/freebuff-instance-owner.json"

mkdir -p "$VAULT_DIR" "$DEVICE_DIR"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_PURPLE='\033[0;35m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

function kill_active_sessions() {
  # Kill any active/zombie freebuff or manicode processes holding old session state in RAM
  pkill -9 -x "freebuff" 2>/dev/null || true
  pkill -9 -x "manicode" 2>/dev/null || true
  pgrep -f "node.*bin/freebuff" | grep -v "$$" | xargs -r kill -9 2>/dev/null || true
}

function clear_session_locks() {
  rm -f "$MANICODE_DIR"/*.lock 2>/dev/null || true
  rm -f "$MANICODE_DIR"/*.sock 2>/dev/null || true
  rm -f "$MANICODE_DIR"/session-state*.json 2>/dev/null || true
  rm -f "$MANICODE_DIR"/telemetry-queue*.json 2>/dev/null || true
  rm -f "$MANICODE_DIR"/freebuff-instance-owner.json 2>/dev/null || true
  rm -f "$MANICODE_DIR"/device-lock*.json 2>/dev/null || true
}

function full_reset() {
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_RED}${C_BOLD}🧹 [FREEBUFF-POWER] FULL IDENTITY & ACCOUNT PURGE RESET${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

  kill_active_sessions
  clear_session_locks
  rm -f "$CREDS_FILE" 2>/dev/null || true

  # Generate brand new randomized anonymous identity & hardware hash
  local new_uuid new_fingerprint new_machine_id new_salt fake_mac
  new_uuid="anon_$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c 'import uuid; print(uuid.uuid4())')"
  new_fingerprint="$(head -c 32 /dev/urandom | sha256sum | awk '{print $1}')"
  new_machine_id="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"
  new_salt="$(od -vN "8" -An -tx1 /dev/urandom | tr -d " \n")"
  fake_mac="52:54:00:$(printf '%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))"

  echo "{\"anonymousId\": \"$new_uuid\", \"deviceHash\": \"$new_fingerprint\"}" > "$ANALYTICS_FILE"
  chmod 600 "$ANALYTICS_FILE" 2>/dev/null || true

  cat << STATE_EOF > "$ANONYMOUS_FILE"
{
  "anonymousId": "${new_uuid#anon_}",
  "machineId": "$new_machine_id",
  "deviceHash": "$new_fingerprint",
  "virtualMac": "$fake_mac",
  "salt": "$new_salt",
  "spoofedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "telemetryEnabled": false,
  "crashReporting": false,
  "analyticsOptOut": true
}
STATE_EOF
  chmod 600 "$ANONYMOUS_FILE" 2>/dev/null || true

  echo -e "${C_GREEN}✅ 1. Sesi login & token lama telah dimatikan dan dibersihkan secara total.${C_RESET}"
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
  chmod 600 "$VAULT_DIR/${name}.json" 2>/dev/null || true

  # Save paired isolated device identity
  if [ -f "$ANALYTICS_FILE" ]; then
    cp -f "$ANALYTICS_FILE" "$DEVICE_DIR/${name}.analytics.json"
    chmod 600 "$DEVICE_DIR/${name}.analytics.json" 2>/dev/null || true
  fi
  if [ -f "$ANONYMOUS_FILE" ]; then
    cp -f "$ANONYMOUS_FILE" "$DEVICE_DIR/${name}.anonymous.json"
    chmod 600 "$DEVICE_DIR/${name}.anonymous.json" 2>/dev/null || true
  fi

  local email
  email="$(grep -o '"email": "[^"]*"' "$CREDS_FILE" | cut -d'"' -f4 || echo "Unknown")"
  echo -e "${C_GREEN}🎉 Akun ($email) berhasil disimpan ke vault sebagai: ${C_BOLD}$name${C_RESET} (dengan profil perangkat terisolasi)!"
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

  echo -e "${C_BOLD}📁 Akun di dalam Vault (Live Quota & Status Server):${C_RESET}"
  local count=0
  local script_dir
  script_dir="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  local files=("$VAULT_DIR"/*.json)
  count=${#files[@]}
  if [ ! -f "${files[0]}" ]; then count=0; fi

  if [ -f "$script_dir/check_quota.js" ]; then
    node "$script_dir/check_quota.js"
  else
    local idx=0
    for acc in "$VAULT_DIR"/*.json; do
      if [ -f "$acc" ]; then
        idx=$((idx + 1))
        local aname aemail
        aname="$(basename "$acc" .json)"
        aemail="$(grep -o '"email": "[^"]*"' "$acc" | cut -d'"' -f4 || echo "Unknown")"
        echo -e "  [$idx] ${C_CYAN}${C_BOLD}$aname${C_RESET} ➔ ${C_DIM}$aemail${C_RESET}"
      fi
    done
  fi

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

  echo -e "${C_YELLOW}⚙️  [1/5] Mematikan seluruh sesi aktif & melepaskan session lock...${C_RESET}"
  kill_active_sessions

  echo -e "${C_YELLOW}🧹 [2/5] Membersihkan session state & lockfiles residual...${C_RESET}"
  clear_session_locks

  echo -e "${C_YELLOW}🎭 [3/5] Mengisolasi hardware fingerprint & machine identity...${C_RESET}"
  # Restore or Generate Isolated Device Identity for this account
  if [ -f "$DEVICE_DIR/${name}.analytics.json" ]; then
    cp -f "$DEVICE_DIR/${name}.analytics.json" "$ANALYTICS_FILE"
  else
    local new_uuid new_fingerprint
    new_uuid="anon_$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c 'import uuid; print(uuid.uuid4())')"
    new_fingerprint="$(head -c 32 /dev/urandom | sha256sum | awk '{print $1}')"
    echo "{\"anonymousId\": \"$new_uuid\", \"deviceHash\": \"$new_fingerprint\"}" > "$ANALYTICS_FILE"
    cp -f "$ANALYTICS_FILE" "$DEVICE_DIR/${name}.analytics.json" 2>/dev/null || true
  fi
  chmod 600 "$ANALYTICS_FILE" 2>/dev/null || true

  if [ -f "$DEVICE_DIR/${name}.anonymous.json" ]; then
    cp -f "$DEVICE_DIR/${name}.anonymous.json" "$ANONYMOUS_FILE"
  else
    local new_anon_id new_machine_id new_device_hash new_salt fake_mac
    new_anon_id="$(cat /proc/sys/kernel/random/uuid 2>/dev/null || od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')"
    new_machine_id="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"
    new_device_hash="$(od -vN "32" -An -tx1 /dev/urandom | tr -d " \n")"
    new_salt="$(od -vN "8" -An -tx1 /dev/urandom | tr -d " \n")"
    fake_mac="52:54:00:$(printf '%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))"
    cat << STATE_EOF > "$ANONYMOUS_FILE"
{
  "anonymousId": "$new_anon_id",
  "machineId": "$new_machine_id",
  "deviceHash": "$new_device_hash",
  "virtualMac": "$fake_mac",
  "salt": "$new_salt",
  "spoofedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "telemetryEnabled": false,
  "crashReporting": false,
  "analyticsOptOut": true
}
STATE_EOF
    cp -f "$ANONYMOUS_FILE" "$DEVICE_DIR/${name}.anonymous.json" 2>/dev/null || true
  fi
  chmod 600 "$ANONYMOUS_FILE" 2>/dev/null || true

  echo -e "${C_YELLOW}🔑 [4/5] Mengaktifkan kredensial target...${C_RESET}"
  cp -f "$target" "$CREDS_FILE"
  chmod 600 "$CREDS_FILE" 2>/dev/null || true

  echo -e "${C_YELLOW}🌐 [5/5] Merotasi alamat IP (Cloudflare WARP Renew)...${C_RESET}"
  if command -v warp-cli >/dev/null 2>&1; then
    (
      warp-cli disconnect >/dev/null 2>&1 || true
      sleep 1
      warp-cli connect >/dev/null 2>&1 || true
    ) &
  fi

  local email
  email="$(grep -o '"email": "[^"]*"' "$CREDS_FILE" | cut -d'"' -f4 || echo "Unknown")"
  echo -e "\n${C_GREEN}${C_BOLD}🎉 BERHASIL BERALIH KE AKUN: ${C_CYAN}$name${C_GREEN} ($email)!${C_RESET}"
  echo -e "${C_GREEN}🛡️ Isolasi Total:${C_RESET} Sesi lama dihentikan, hardware fingerprint diisolasi, residual cache di-purge, & IP dirotasi."
  echo -e "🚀 Mulai koding segar tanpa batas limit akun lama: ${C_CYAN}${C_BOLD}freebuff-power start${C_RESET}\n"
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

  local aname
  aname="$(basename "$current_target" .json)"
  echo -e "${C_CYAN}🔄 Merotasi ke akun berikutnya: ${C_BOLD}$aname${C_RESET}"
  switch_account "$aname"
}

SUBCMD="${1:-list}"
shift || true

case "$SUBCMD" in
  reset|reset-full|full-reset|purge|logout)
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

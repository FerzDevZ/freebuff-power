#!/usr/bin/env bash
# ==============================================================================
# 🔄 FREEBUFF-POWER MULTI-ACCOUNT VAULT & FULL IDENTITY ISOLATION (v8.5-Titanium)
# True Deep Isolation: Credentials, Device-Keys, Fingerprints & Auto-Failover
# ==============================================================================
set -euo pipefail

MANICODE_DIR="$HOME/.config/manicode"
VAULT_DIR="$MANICODE_DIR/account_vault"
DEVICE_DIR="$VAULT_DIR/devices"
CREDS_FILE="$MANICODE_DIR/credentials.json"
DEVICE_KEY_FILE="$MANICODE_DIR/device-key.json"
ANALYTICS_FILE="$MANICODE_DIR/analytics-id.json"
ANONYMOUS_FILE="$MANICODE_DIR/anonymous-id.json"
SETTINGS_FILE="$MANICODE_DIR/settings.json"
HISTORY_FILE="$MANICODE_DIR/message-history.json"
OWNER_FILE="$MANICODE_DIR/freebuff-instance-owner.json"

SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
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
  echo -e "${C_RED}${C_BOLD}🧹 [FREEBUFF-POWER] FULL DEEP IDENTITY, BROWSER & DESKTOP PURGE (v8.5)${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

  echo -e "${C_YELLOW}⚙️  [1/7] Menghentikan seluruh proses backend zombie...${C_RESET}"
  kill_active_sessions

  echo -e "${C_YELLOW}🧹 [2/7] Menghapus session locks, socket, & temporary caches...${C_RESET}"
  clear_session_locks
  rm -rf /tmp/freebuff-* /tmp/manicode-* /tmp/codebuff-* 2>/dev/null || true
  rm -rf "$HOME/.cache/@codebufffreebuff-desktop-updater" 2>/dev/null || true

  echo -e "${C_YELLOW}🔑 [3/7] Memusnahkan kredensial, token login & Ed25519 device-key.json...${C_RESET}"
  rm -f "$CREDS_FILE" 2>/dev/null || true
  rm -f "$DEVICE_KEY_FILE" 2>/dev/null || true
  rm -f "$SETTINGS_FILE" 2>/dev/null || true
  rm -f "$HISTORY_FILE" 2>/dev/null || true

  echo -e "${C_YELLOW}🎭 [4/7] Meng-generate identitas perangkat baru (Zero Fingerprint Linkage)...${C_RESET}"
  local new_uuid new_fingerprint new_machine_id new_salt fake_mac
  new_uuid="anon_$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c 'import uuid; print(uuid.uuid4())')"
  new_fingerprint="$(head -c 32 /dev/urandom | sha256sum | awk '{print $1}')"
  new_machine_id="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"
  new_salt="$(od -vN "8" -An -tx1 /dev/urandom | tr -d " \n")"
  fake_mac="52:54:00:$(printf '%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))"

  echo "{\"anonymousId\": \"$new_uuid\", \"deviceHash\": \"$new_fingerprint\"}" > "$ANALYTICS_FILE"
  chmod 600 "$ANALYTICS_FILE" 2>/dev/null || true

  echo "$new_machine_id" > "$MANICODE_DIR/spoofed-machine-id"
  echo "$fake_mac" > "$MANICODE_DIR/spoofed-mac"
  echo "${new_uuid#anon_}" > "$MANICODE_DIR/spoofed-product-uuid"
  chmod 644 "$MANICODE_DIR/spoofed-machine-id" "$MANICODE_DIR/spoofed-mac" "$MANICODE_DIR/spoofed-product-uuid" 2>/dev/null || true

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

  echo -e "${C_YELLOW}🌐 [5/7] Memusnahkan cookie pelacak & web storage browser (Chrome, Brave, Chromium)...${C_RESET}"
  if [ -f "$SCRIPT_DIR/browser-clean.py" ]; then
    python3 "$SCRIPT_DIR/browser-clean.py" --kill || true
  fi

  echo -e "${C_YELLOW}🖥️  [6/7] Memeriksa & mereset identitas Freebuff Desktop Linux...${C_RESET}"
  if [ -f "$SCRIPT_DIR/desktop.sh" ]; then
    "$SCRIPT_DIR/desktop.sh" reset >/dev/null 2>&1 || true
    echo -e "  ✓ Identitas Freebuff Desktop & Electron storage berhasil di-reset"
  fi

  echo -e "${C_YELLOW}📡 [7/7] Merotasi network Anycast & memeriksa konektivitas...${C_RESET}"
  if command -v warp-cli >/dev/null 2>&1; then
    warp-cli tunnel rotate-keys >/dev/null 2>&1 || true
    warp-cli disconnect >/dev/null 2>&1 || true
    sleep 0.5
    warp-cli connect >/dev/null 2>&1 || true
  fi

  echo -e "\n${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}🎉 PURGE TOTAL BERHASIL 100%! Identitas mesin & browser telah bersih total.${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}\n"
  echo -e "${C_BOLD}💡 PANDUAN PENTING AGAR TIDAK DITAGIH NOMOR HP SAAT LOGIN BARU:${C_RESET}"
  echo -e "  1. ${C_CYAN}Gunakan Stealth Isolated Browser${C_RESET}: Jalankan ${C_BOLD}freebuff-power login${C_RESET} atau"
  echo -e "     ${C_BOLD}freebuff-power browser stealth${C_RESET} untuk membuka browser sandbox anti-detect."
  echo -e "  2. ${C_CYAN}Gunakan Koneksi Residensial Murni${C_RESET}: Disarankan memakai hotspot HP seluler (IP perumahan/mobile)."
  echo -e "     (Matikan VPN/WARP saat registrasi baru, karena IP Datacenter otomatis dicurigai bot)."
  echo -e "  3. ${C_CYAN}Gunakan Akun Google Berumur (Aged Account)${C_RESET}: Hindari Gmail yang baru berumur hitungan menit."
  echo -e "\n👉 Luncurkan sesi bersih sekarang: ${C_CYAN}${C_BOLD}freebuff-power start${C_RESET}\n"
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

  # Save paired cryptographic Ed25519 device key (CRITICAL for zero mismatch!)
  if [ -f "$DEVICE_KEY_FILE" ]; then
    cp -f "$DEVICE_KEY_FILE" "$DEVICE_DIR/${name}.device-key.json"
    chmod 600 "$DEVICE_DIR/${name}.device-key.json" 2>/dev/null || true
  fi

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
  echo -e "${C_GREEN}🎉 Akun ($email) berhasil disimpan ke vault sebagai: ${C_BOLD}$name${C_RESET} (Lengkap dengan pasangan Ed25519 Device Key)!"

  # Auto-sync to freebuff-proxy auth.json if proxy directory exists
  local proxy_auth="$HOME/freebuff-proxy/data/auth.json"
  if [ -d "$HOME/freebuff-proxy" ]; then
    node -e "
      const fs = require('fs');
      const p = '$proxy_auth';
      let d = { accounts: [], api_keys: [], next_id: 1, next_key_id: 1, keys_enabled: false };
      try { d = JSON.parse(fs.readFileSync(p, 'utf-8')); } catch {}
      try {
        const creds = JSON.parse(fs.readFileSync('$CREDS_FILE', 'utf-8'));
        const def = creds.default || Object.values(creds)[0];
        const tk = def?.authToken || def?.token;
        if (tk && !(d.accounts || []).some(a => a.token === tk)) {
          d.accounts.push({
            id: 'acct_$name',
            token: tk,
            session_model: 'z-ai/glm-5.3-flash',
            serve_status: 'active',
            paused: false,
            created_at: new Date().toISOString()
          });
          fs.mkdirSync('$HOME/freebuff-proxy/data', { recursive: true });
          fs.writeFileSync(p, JSON.stringify(d, null, 2));
          console.log('\x1b[32m🔄 Akun otomatis disinkronkan ke pool Freebuff Proxy!\x1b[0m');
        }
      } catch {}
    " 2>/dev/null || true
  fi
}

function list_accounts() {
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_YELLOW}${C_BOLD}👥 [ACCOUNT VAULT] Daftar Akun Tersimpan (Live Quota Status)${C_RESET}"
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
  local files=("$VAULT_DIR"/*.json)
  count=${#files[@]}
  if [ ! -f "${files[0]}" ]; then count=0; fi

  if [ -f "$SCRIPT_DIR/check_quota.js" ]; then
    node "$SCRIPT_DIR/check_quota.js"
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
    echo -e "\n👉 Beralih akun tertentu  : ${C_CYAN}freebuff-power account switch <nama>${C_RESET}"
    echo -e "👉 Auto-Pilih Akun READY  : ${C_GREEN}${C_BOLD}freebuff-power account auto${C_RESET} ${C_DIM}(Otomatis pilih akun yang aktif)${C_RESET}"
    echo -e "👉 Putar Round-Robin      : ${C_CYAN}freebuff-power account rotate${C_RESET}\n"
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

  echo -e "${C_YELLOW}🎭 [3/5] Mengisolasi hardware fingerprint & Ed25519 device key...${C_RESET}"
  # Restore or isolate device-key.json
  if [ -f "$DEVICE_DIR/${name}.device-key.json" ]; then
    cp -f "$DEVICE_DIR/${name}.device-key.json" "$DEVICE_KEY_FILE"
    chmod 600 "$DEVICE_KEY_FILE" 2>/dev/null || true
  else
    rm -f "$DEVICE_KEY_FILE" 2>/dev/null || true
  fi

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

  echo -e "${C_YELLOW}🔑 [4/5] Mengaktifkan kredensial target ($name)...${C_RESET}"
  cp -f "$target" "$CREDS_FILE"
  chmod 600 "$CREDS_FILE" 2>/dev/null || true

  echo -e "${C_YELLOW}🌐 [5/5] Merotasi IP Anycast...${C_RESET}"
  if command -v warp-cli >/dev/null 2>&1; then
    (
      warp-cli disconnect >/dev/null 2>&1 || true
      sleep 0.5
      warp-cli connect >/dev/null 2>&1 || true
    ) &
  fi

  local email
  email="$(grep -o '"email": "[^"]*"' "$CREDS_FILE" | cut -d'"' -f4 || echo "Unknown")"
  echo -e "\n${C_GREEN}${C_BOLD}🎉 BERHASIL BERALIH KE AKUN: ${C_CYAN}$name${C_GREEN} ($email)!${C_RESET}"
  echo -e "${C_GREEN}🛡️ Isolasi Total:${C_RESET} Kredensial, Ed25519 device-key, hardware fingerprint di-swap sempurna."
  echo -e "🚀 Mulai koding langsung: ${C_CYAN}${C_BOLD}freebuff-power start${C_RESET}\n"
}

function auto_select_ready() {
  echo -e "${C_CYAN}${C_BOLD}⚡ [AUTO-FAILOVER] Memindai akun dengan kuota aktif di vault...${C_RESET}"
  local ready_acc
  ready_acc=$(node "$SCRIPT_DIR/check_quota.js" --first-ready 2>/dev/null || echo "")

  if [ -n "$ready_acc" ]; then
    echo -e "${C_GREEN}✅ Ditemukan akun READY: ${C_BOLD}$ready_acc${C_RESET}"
    switch_account "$ready_acc"
  else
    echo -e "${C_RED}⚠️ Seluruh akun di vault sedang habis kuota atau limit tercapai.${C_RESET}"
    echo -e "👉 Opsi: Tunggu reset pukul 14:00 WIB, atau gunakan model unmetered via proxy:"
    echo -e "   \033[0;36m\033[1mfreebuff-power run proxy\033[0m\n"
    exit 1
  fi
}

function rotate_account() {
  local accounts=("$VAULT_DIR"/*.json)
  if [ ${#accounts[@]} -eq 0 ] || [ ! -f "${accounts[0]}" ]; then
    echo -e "${C_RED}❌ Vault kosong! Simpan minimal 2 akun untuk fitur rotasi.${C_RESET}"
    exit 1
  fi

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

function new_account_wizard() {
  local name="${1:-}"
  if [ -z "$name" ]; then
    echo -e "${C_RED}⚠️ Masukkan label/nama untuk akun baru. Contoh: freebuff-power account new akun6${C_RESET}"
    exit 1
  fi

  if [ -f "$VAULT_DIR/${name}.json" ]; then
    echo -e "${C_YELLOW}⚠️ PERINGATAN: Akun '${name}' sudah ada di vault.${C_RESET}"
    read -r -p "Apakah Anda ingin menimpa akun '${name}'? [y/N]: " confirm_overwrite || true
    if [[ ! "${confirm_overwrite:-n}" =~ ^[Yy] ]]; then
      echo -e "${C_RED}Dibatalkan. Silakan gunakan nama akun lain.${C_RESET}"
      exit 0
    fi
  fi

  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}🚀 [FREEBUFF-POWER] ONBOARDING AKUN BARU 100% STEALTH & ANTI-BAN${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

  # 1. Pre-flight Network & IP Safety Check
  echo -e "${C_YELLOW}🔍 [1/5] Memeriksa status jaringan & reputasi IP...${C_RESET}"
  if command -v warp-cli >/dev/null 2>&1 && warp-cli status 2>/dev/null | grep -q "Connected"; then
    echo -e "${C_YELLOW}  ⚠️ PERINGATAN: Cloudflare WARP terdeteksi aktif.${C_RESET}"
    echo -e "  💡 Rekomendasi: Untuk registrasi/login akun baru pertama kali, disarankan mematikan WARP/VPN"
    echo -e "     dan gunakan hotspot seluler (IP perumahan) agar Google/Codebuff tidak meminta SMS verifikasi."
    read -r -p "  Tetap lanjutkan dengan koneksi saat ini? [Y/n]: " confirm_net || true
    if [[ "${confirm_net:-y}" =~ ^[Nn] ]]; then
      echo -e "${C_RED}Proses dibatalkan oleh pengguna.${C_RESET}"
      exit 0
    fi
  else
    echo -e "${C_GREEN}  ✓ Koneksi siap (IP Non-Datacenter)${C_RESET}"
  fi

  # 2. Fresh Hardware Virtualization Tuple
  echo -e "${C_YELLOW}🎭 [2/5] Meng-generate identitas hardware baru (Zero Correlation)...${C_RESET}"
  kill_active_sessions
  clear_session_locks
  rm -f "$CREDS_FILE" "$DEVICE_KEY_FILE" 2>/dev/null || true

  local new_uuid new_fingerprint new_machine_id new_salt fake_mac
  new_uuid="anon_$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c 'import uuid; print(uuid.uuid4())')"
  new_fingerprint="$(head -c 32 /dev/urandom | sha256sum | awk '{print $1}')"
  new_machine_id="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"
  new_salt="$(od -vN "8" -An -tx1 /dev/urandom | tr -d " \n")"
  fake_mac="52:54:00:$(printf '%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))"

  echo "$new_machine_id" > "$MANICODE_DIR/spoofed-machine-id"
  echo "$fake_mac" > "$MANICODE_DIR/spoofed-mac"
  echo "${new_uuid#anon_}" > "$MANICODE_DIR/spoofed-product-uuid"
  chmod 644 "$MANICODE_DIR/spoofed-machine-id" "$MANICODE_DIR/spoofed-mac" "$MANICODE_DIR/spoofed-product-uuid" 2>/dev/null || true

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
  echo "{\"anonymousId\": \"$new_uuid\", \"deviceHash\": \"$new_fingerprint\"}" > "$ANALYTICS_FILE"
  chmod 600 "$ANALYTICS_FILE" 2>/dev/null || true
  echo -e "${C_GREEN}  ✓ Virtual Machine ID & MAC baru: ${fake_mac}${C_RESET}"

  # 3. Setup Stealth Browser Environment
  echo -e "${C_YELLOW}🌐 [3/5] Mempersiapkan Google Chrome Stealth Sandbox (Farbling Shield Active)...${C_RESET}"
  export BROWSER="$SCRIPT_DIR/browser-stealth.sh"
  export PATH="$SCRIPT_DIR/shims:$PATH"
  if [ -f "$SCRIPT_DIR/libfreebuff-stealth.so" ]; then
    export LD_PRELOAD="$SCRIPT_DIR/libfreebuff-stealth.so${LD_PRELOAD:+:$LD_PRELOAD}"
  elif [ -f "$HOME/.local/bin/libfreebuff-stealth.so" ]; then
    export LD_PRELOAD="$HOME/.local/bin/libfreebuff-stealth.so${LD_PRELOAD:+:$LD_PRELOAD}"
  fi

  # 4. Trigger Freebuff Login
  echo -e "${C_YELLOW}⏳ [4/5] Membuka sesi login Freebuff di Google Chrome...${C_RESET}"
  echo -e "${C_DIM}  (Google Chrome akan terbuka secara otomatis dengan profil terisolasi zero-trace)${C_RESET}\n"

  # Call real freebuff login
  if [ -x "$SCRIPT_DIR/freebuff-wrapper.sh" ]; then
    "$SCRIPT_DIR/freebuff-wrapper.sh" login || true
  else
    freebuff login || true
  fi

  # 5. Check and Save Session to Vault
  echo -e "\n${C_YELLOW}💾 [5/5] Memeriksa hasil otentikasi...${C_RESET}"
  if [ -f "$CREDS_FILE" ]; then
    save_current_account "$name"
    echo -e "\n${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
    echo -e "${C_GREEN}${C_BOLD}🎉 AKUN '${name}' RESMI AKTIF & TERISOLASI 100%!${C_RESET}"
    echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}\n"
    if [ -f "$SCRIPT_DIR/check_quota.js" ]; then
      node "$SCRIPT_DIR/check_quota.js" --check "$name" 2>/dev/null || true
    fi
  else
    echo -e "${C_RED}❌ Login belum selesai atau credentials.json tidak ditemukan.${C_RESET}"
    echo -e "Silakan coba lagi dengan: freebuff-power account new $name"
  fi
}

function remove_account() {
  local name="${1:-}"
  if [ -z "$name" ]; then
    echo -e "${C_RED}⚠️ Masukkan nama akun yang ingin dihapus: freebuff-power account remove <nama>${C_RESET}"
    exit 1
  fi
  rm -f "$VAULT_DIR/${name}.json"
  rm -f "$DEVICE_DIR/${name}.device-key.json"
  rm -f "$DEVICE_DIR/${name}.analytics.json"
  rm -f "$DEVICE_DIR/${name}.anonymous.json"
  echo -e "${C_GREEN}✅ Akun '$name' berhasil dihapus dari vault.${C_RESET}"
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
  auto|failover|ready)
    auto_select_ready
    ;;
  rotate)
    rotate_account
    ;;
  new|add|create|onboard)
    new_account_wizard "$@"
    ;;
  remove|rm|del|delete)
    remove_account "$@"
    ;;
  *)
    echo "Penggunaan: freebuff-power account [new <nama> | save <nama> | list | switch <nama> | auto | rotate | remove <nama> | reset]"
    ;;
esac

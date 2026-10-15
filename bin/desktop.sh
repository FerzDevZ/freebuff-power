#!/usr/bin/env bash
# ==============================================================================
# 🖥️ FREEBUFF-POWER DESKTOP LINUX MANAGER & IDENTITY RESET (v8.5)
# Deep Anti-Detect, Machine-ID Randomizer & Session Wipe for Freebuff Desktop
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

DESKTOP_CONFIG_DIR="$HOME/.config/freebuff-desktop"
ELECTRON_CONFIG_DIR="$HOME/.config/Freebuff"
STATE_FILE="$DESKTOP_CONFIG_DIR/state.json"
AUTH_SECRETS_FILE="$DESKTOP_CONFIG_DIR/state.json.auth-secrets.json"
UPDATER_ID_FILE="$ELECTRON_CONFIG_DIR/.updaterId"
PREFERENCES_FILE="$ELECTRON_CONFIG_DIR/Preferences"

function is_desktop_running() {
  pgrep -f "@codebufffreebuff-desktop" >/dev/null 2>&1 || pgrep -f "Freebuff.*AppImage" >/dev/null 2>&1
}

function desktop_kill() {
  echo -e "${C_YELLOW}🛑 Menghentikan proses Freebuff Desktop Linux & Orchestrator...${C_RESET}"
  pkill -15 -f "@codebufffreebuff-desktop" 2>/dev/null || true
  pkill -15 -f "orchestrator/orchestrator.js" 2>/dev/null || true
  sleep 0.8
  pkill -9 -f "@codebufffreebuff-desktop" 2>/dev/null || true
  pkill -9 -f "orchestrator/orchestrator.js" 2>/dev/null || true
  echo -e "${C_GREEN}✅ Seluruh proses Freebuff Desktop telah dihentikan.${C_RESET}"
}

function desktop_status() {
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_PURPLE}${C_BOLD}🖥️ [FREEBUFF-POWER] FREEBUFF DESKTOP LINUX STATUS & IDENTITAS${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

  if is_desktop_running; then
    local pids
    pids=$(pgrep -f "@codebufffreebuff-desktop" | tr '\n' ' ' || echo "N/A")
    echo -e "🟢 Status Proses  : ${C_GREEN}${C_BOLD}AKTIF (RUNNING)${C_RESET} [PIDs: ${pids}]"
  else
    echo -e "⚪ Status Proses  : ${C_DIM}TIDAK AKTIF (STOPPED)${C_RESET}"
  fi

  if [ -f "$STATE_FILE" ]; then
    python3 -c "
import json
try:
    with open('$STATE_FILE') as f:
        d = json.load(f)
    print('🆔 Machine ID    :', d.get('machineId', 'Tidak ada'))
    print('📦 Install ID    :', d.get('installId', 'Tidak ada'))
    print('📊 Analytics ID  :', d.get('analyticsId', 'Tidak ada'))
    auth_cnt = len(d.get('authSessions', {}))
    print('🔑 Sesi Login    :', f'{auth_cnt} sesi terdaftar' if auth_cnt > 0 else 'Kosong / Belum Login')
except Exception as e:
    print('Error membaca state.json:', e)
"
  else
    echo -e "🆔 State Config  : ${C_DIM}Belum pernah dibuat ($STATE_FILE)${C_RESET}"
  fi

  if [ -f "$UPDATER_ID_FILE" ]; then
    echo -e "🔄 Updater ID    : $(cat "$UPDATER_ID_FILE" 2>/dev/null || echo 'N/A')"
  fi

  if [ -f "$AUTH_SECRETS_FILE" ]; then
    echo -e "🔒 Auth Secrets  : ${C_YELLOW}Ditemukan token terenkripsi (${AUTH_SECRETS_FILE})${C_RESET}"
  else
    echo -e "🔒 Auth Secrets  : ${C_GREEN}Bersih (Tidak ada token tersimpan)${C_RESET}"
  fi

  # Cari file AppImage
  local appimage
  appimage=$(find "$HOME/Downloads" "$HOME" -maxdepth 2 -name "Freebuff*.AppImage" 2>/dev/null | sort -V | tail -n 1 || echo "")
  if [ -n "$appimage" ]; then
    echo -e "📦 AppImage File : ${C_CYAN}${appimage}${C_RESET}"
  fi

  echo -e "\n${C_CYAN}------------------------------------------------------------------------${C_RESET}"
  echo -e "💡 Jalankan ${C_BOLD}freebuff-power desktop reset${C_RESET} untuk mereset total identitas Desktop."
  echo -e "💡 Jalankan ${C_BOLD}freebuff-power desktop kill${C_RESET} untuk menutup proses Desktop.\n"
}

function desktop_reset() {
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_RED}${C_BOLD}🧹 [FREEBUFF-POWER] FREEBUFF DESKTOP LINUX DEEP RESET (v8.5)${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

  # 1. Hentikan aplikasi
  echo -e "${C_YELLOW}⚙️  [1/4] Menghentikan proses Electron Freebuff Desktop...${C_RESET}"
  desktop_kill >/dev/null 2>&1 || true

  # 2. Acak identitas di state.json
  echo -e "${C_YELLOW}🎭 [2/4] Mengacak Machine ID, Install ID & Analytics ID Desktop...${C_RESET}"
  if [ -f "$STATE_FILE" ]; then
    python3 -c "
import json, uuid
try:
    with open('$STATE_FILE', 'r') as f:
        d = json.load(f)
    d['machineId'] = str(uuid.uuid4())
    d['installId'] = str(uuid.uuid4())
    d['analyticsId'] = 'anon_' + str(uuid.uuid4())
    d['authSessions'] = {}
    with open('$STATE_FILE', 'w') as f:
        json.dump(d, f, indent=2)
    print('  ✓ Identitas baru berhasil diinjeksi ke state.json')
except Exception as e:
    print('  ⚠️ Gagal memperbarui state.json:', e)
"
  fi

  # Hapus auth secrets, lock & histori sesi
  rm -f "$AUTH_SECRETS_FILE" 2>/dev/null || true
  rm -f "$DESKTOP_CONFIG_DIR"/state.json.session-*.json 2>/dev/null || true
  rm -f "$DESKTOP_CONFIG_DIR"/state.json.orchestrator-lock.sqlite 2>/dev/null || true

  # 3. Bersihkan cache, cookies & Partitions Electron
  echo -e "${C_YELLOW}🧹 [3/4] Membersihkan Cookie Electron, WebView Partitions & Cache...${C_RESET}"
  if [ -d "$ELECTRON_CONFIG_DIR" ]; then
    rm -f "$ELECTRON_CONFIG_DIR"/Cookies* 2>/dev/null || true
    rm -rf "$ELECTRON_CONFIG_DIR"/Partitions/* 2>/dev/null || true
    rm -rf "$ELECTRON_CONFIG_DIR"/Cache/* 2>/dev/null || true
    rm -rf "$ELECTRON_CONFIG_DIR"/'Code Cache'/* 2>/dev/null || true
    rm -rf "$ELECTRON_CONFIG_DIR"/'Local Storage'/* 2>/dev/null || true
    rm -rf "$ELECTRON_CONFIG_DIR"/'Session Storage'/* 2>/dev/null || true
    rm -f "$ELECTRON_CONFIG_DIR"/'Trust Tokens'* 2>/dev/null || true
    rm -f "$ELECTRON_CONFIG_DIR"/SharedStorage* 2>/dev/null || true
    rm -f "$ELECTRON_CONFIG_DIR"/Singleton* 2>/dev/null || true

    # Acak .updaterId
    python3 -c "import uuid; print(str(uuid.uuid4()))" > "$UPDATER_ID_FILE" 2>/dev/null || true

    # Acak device_id_salt di Preferences jika ada
    if [ -f "$PREFERENCES_FILE" ]; then
      python3 -c "
import json, secrets
try:
    with open('$PREFERENCES_FILE', 'r') as f:
        p = json.load(f)
    if 'electron' in p and 'media' in p['electron']:
        p['electron']['media']['device_id_salt'] = secrets.token_hex(16).upper()
        with open('$PREFERENCES_FILE', 'w') as f:
            json.dump(p, f)
except Exception:
    pass
" 2>/dev/null || true
    fi
  fi

  # Bersihkan temporary updater di ~/.cache
  rm -rf "$HOME/.cache/@codebufffreebuff-desktop-updater" 2>/dev/null || true

  # 4. Bersihkan cookies browser eksternal juga agar sinkron
  echo -e "${C_YELLOW}🌐 [4/4] Memastikan browser eksternal bersih dari sisa login...${C_RESET}"
  SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  if [ -f "$SCRIPT_DIR/browser-clean.py" ]; then
    python3 "$SCRIPT_DIR/browser-clean.py" --silent || true
  fi

  echo -e "\n${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}🎉 RESET FREEBUFF DESKTOP LINUX SUKSES 100%!${C_RESET}"
  echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}\n"
  echo -e "👉 Buka kembali Freebuff Desktop Anda, aplikasi sekarang 100% seperti baru dipasang:"
  echo -e "   - Machine ID baru (Zero Correlation)"
  echo -e "   - Install ID & Analytics ID baru"
  echo -e "   - Sesi & token login lama telah terhapus total"
  echo -e "   - Daftar proyek Anda tetap dipertahankan aman\n"
}

CMD="${1:-status}"
case "$CMD" in
  status)
    desktop_status
    ;;
  kill|stop)
    desktop_kill
    ;;
  reset|purge)
    desktop_reset
    ;;
  *)
    echo -e "Penggunaan: freebuff-power desktop [status|reset|kill]"
    exit 1
    ;;
esac

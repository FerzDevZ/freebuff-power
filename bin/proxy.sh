#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER PROXY CONTROLLER & INTERACTIVE MODEL RUNNER
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Resolve Freebuff Proxy directory
FREEBUFF_PROXY_DIR=""
for candidate in \
  "$HOME/freebuff-proxy" \
  "$SCRIPT_DIR/../../freebuff-proxy" \
  "$SCRIPT_DIR/../freebuff-proxy" \
  "$HOME/9router/scripts/freebuff-proxy"; do
  if [ -d "$candidate" ] && [ -f "$candidate/start.sh" ]; then
    FREEBUFF_PROXY_DIR="$candidate"
    break
  fi
done

if [ -z "$FREEBUFF_PROXY_DIR" ]; then
  echo -e "\033[0;31m❌ Folder freebuff-proxy tidak ditemukan di lokasi standar ($HOME/freebuff-proxy).\033[0m"
  exit 1
fi

PORT="${FREEBUFF_PROXY_PORT:-9187}"
BASE_URL="http://127.0.0.1:$PORT/v1"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_PURPLE='\033[0;35m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

ensure_proxy_running() {
  if ! fuser "$PORT/tcp" >/dev/null 2>&1; then
    echo -e "${C_YELLOW}⚡ Freebuff Proxy belum aktif. Menjalankan engine di background...${C_RESET}"
    "$FREEBUFF_PROXY_DIR/start.sh"
    echo -e "${C_CYAN}⏳ Menunggu koneksi proxy siap...${C_RESET}"
    for i in {1..10}; do
      if curl -s -m 1 "$BASE_URL/models" >/dev/null 2>&1; then
        echo -e "${C_GREEN}✅ Freebuff Proxy aktif & siap pada $BASE_URL!${C_RESET}\n"
        return 0
      fi
      sleep 0.5
    done
  else
    echo -e "${C_GREEN}🟢 Freebuff Proxy aktif pada port $PORT (Endpoint: $BASE_URL)${C_RESET}\n"
  fi
}

ACTION="${1:-run}"

case "$ACTION" in
  start)
    exec "$FREEBUFF_PROXY_DIR/start.sh"
    ;;
  stop)
    exec "$FREEBUFF_PROXY_DIR/stop.sh"
    ;;
  restart)
    exec "$FREEBUFF_PROXY_DIR/restart.sh"
    ;;
  status)
    exec "$FREEBUFF_PROXY_DIR/status.sh"
    ;;
  models|list)
    ensure_proxy_running
    echo -e "${C_BOLD}📋 Daftar Model Aktif di Freebuff Proxy:${C_RESET}"
    curl -s "$BASE_URL/models" | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | while read -r m; do
      echo -e "  • ${C_CYAN}$m${C_RESET}"
    done
    exit 0
    ;;
  accounts|acc)
    ensure_proxy_running
    echo -e "${C_BOLD}👥 Daftar Akun Tersambung di Freebuff Proxy:${C_RESET}"
    node -e "
      const fs = require('fs');
      const path = require('path');
      const authPath = path.resolve('$FREEBUFF_PROXY_DIR', 'data', 'auth.json');
      const vaultDir = path.resolve(process.env.HOME, '.config', 'manicode', 'account_vault');
      const activeFile = path.resolve(process.env.HOME, '.config', 'manicode', 'credentials.json');

      fs.mkdirSync(path.dirname(authPath), { recursive: true });
      let d = { accounts: [], api_keys: [], next_id: 1, next_key_id: 1, keys_enabled: false };
      if (fs.existsSync(authPath)) {
        try { d = JSON.parse(fs.readFileSync(authPath, 'utf-8')); } catch {}
      }

      // Auto-sync from freebuff-power vault if empty or new
      const existingTokens = new Set((d.accounts || []).map(a => a.token));
      let synced = 0;

      // 1. Check active account
      if (fs.existsSync(activeFile)) {
        try {
          const act = JSON.parse(fs.readFileSync(activeFile, 'utf-8'));
          for (const k of Object.keys(act)) {
            const v = act[k];
            if (v && (v.authToken || v.token)) {
              const tk = v.authToken || v.token;
              if (!existingTokens.has(tk)) {
                d.accounts.push({
                  id: 'acct_active_' + (v.email ? v.email.split('@')[0] : 'active'),
                  token: tk,
                  session_model: 'z-ai/glm-5.3-flash',
                  serve_status: 'active',
                  paused: false,
                  created_at: new Date().toISOString()
                });
                existingTokens.add(tk);
                synced++;
              }
            }
          }
        } catch {}
      }

      // 2. Check vault dir
      if (fs.existsSync(vaultDir)) {
        const files = fs.readdirSync(vaultDir).filter(f => f.endsWith('.json'));
        for (const file of files) {
          try {
            const vfile = JSON.parse(fs.readFileSync(path.join(vaultDir, file), 'utf-8'));
            const name = file.replace('.json', '');
            for (const k of Object.keys(vfile)) {
              const v = vfile[k];
              if (v && (v.authToken || v.token)) {
                const tk = v.authToken || v.token;
                if (!existingTokens.has(tk)) {
                  d.accounts.push({
                    id: 'acct_' + name,
                    token: tk,
                    session_model: 'z-ai/glm-5.3-flash',
                    serve_status: 'active',
                    paused: false,
                    created_at: new Date().toISOString()
                  });
                  existingTokens.add(tk);
                  synced++;
                }
              }
            }
          } catch {}
        }
      }

      if (synced > 0 || !fs.existsSync(authPath)) {
        fs.writeFileSync(authPath, JSON.stringify(d, null, 2));
      }

      const accs = d.accounts || [];
      if (accs.length === 0) {
        console.log('\x1b[33m⚠️  Belum ada akun di vault (~/.config/manicode/account_vault) ataupun auth.json.\x1b[0m');
        console.log('\x1b[36m👉 Login dulu dengan \"freebuff login\" lalu simpan \"freebuff-power account save <nama>\".\x1b[0m');
      } else {
        console.log('\x1b[32mTotal Akun di Proxy Pool: ' + accs.length + '\x1b[0m\n');
        accs.forEach((a, i) => {
          console.log('  [' + (i+1) + '] ID: \x1b[36m' + a.id + '\x1b[0m | Model: \x1b[33m' + (a.session_model || 'z-ai/glm-5.3-flash') + '\x1b[0m | Status: \x1b[32m' + (a.serve_status || 'active') + '\x1b[0m');
        });
      }
    "
    exit 0
    ;;
  add-account|add)
    shift || true
    TOKEN="${1:-}"
    if [ -z "$TOKEN" ]; then
      read -rp "$(echo -e "${C_BOLD}Masukkan Token Sesi Codebuff/Freebuff: ${C_RESET}")" TOKEN
    fi
    if [ -z "$TOKEN" ]; then
      echo -e "${C_RED}Token tidak boleh kosong!${C_RESET}"
      exit 1
    fi
    MODEL="${2:-z-ai/glm-5.3-flash}"
    node -e "
      const fs = require('fs');
      const p = '$FREEBUFF_PROXY_DIR/data/auth.json';
      let d = { accounts: [], api_keys: [], next_id: 1, next_key_id: 1, keys_enabled: false };
      try { d = JSON.parse(fs.readFileSync(p, 'utf-8')); } catch {}
      const id = 'acct_' + Date.now();
      d.accounts.push({
        id,
        token: '$TOKEN',
        session_model: '$MODEL',
        serve_status: 'active',
        paused: false,
        created_at: new Date().toISOString()
      });
      fs.writeFileSync(p, JSON.stringify(d, null, 2));
      console.log('\x1b[32m✅ Akun berhasil ditambahkan dengan ID: ' + id + ' (Model default: $MODEL)\x1b[0m');
    "
    echo -e "${C_YELLOW}⚡ Me-restart engine proxy agar akun baru langsung aktif...${C_RESET}"
    "$FREEBUFF_PROXY_DIR/restart.sh"
    exit 0
    ;;
  init)
    shift || true
    TARGET_DIR="${1:-.}"
    mkdir -p "$TARGET_DIR"
    echo -e "${C_CYAN}${C_BOLD}🔧 Menginisialisasi Integrasi Freebuff Proxy ke ${TARGET_DIR}...${C_RESET}"
    ensure_proxy_running
    
    # Buat .env.freebuff
    cat << ENV_EOF > "$TARGET_DIR/.env.freebuff"
# Freebuff Proxy Environment Configuration
OPENAI_BASE_URL=http://127.0.0.1:$PORT/v1
OPENAI_API_KEY=freebuff
OPENAI_MODEL=z-ai/glm-5.3-flash
ENV_EOF

    # Buat vscode settings jika folder .vscode ada
    if [ -d "$TARGET_DIR/.vscode" ]; then
      echo -e "${C_DIM}Mengupdate .vscode/settings.json...${C_RESET}"
    fi

    echo -e "${C_GREEN}✅ Konfigurasi .env.freebuff berhasil dibuat di ${TARGET_DIR}!${C_RESET}"
    echo -e "${C_YELLOW}👉 Gunakan: source .env.freebuff untuk mengaktifkan environment di shell.${C_RESET}"
    exit 0
    ;;
  run)
    shift || true
    ensure_proxy_running
    
    SPECIFIED_MODEL="${1:-}"

    if [ -n "$SPECIFIED_MODEL" ]; then
      SELECTED_MODEL="$SPECIFIED_MODEL"
    else
      echo -e "${C_CYAN}${C_BOLD}================================================================================${C_RESET}"
      echo -e "${C_YELLOW}${C_BOLD}🎯 PILIH MODEL FREEBUFF FREE UNTUK SESI KODING INI:${C_RESET}"
      echo -e "${C_CYAN}${C_BOLD}================================================================================${C_RESET}"
      echo ""
      echo -e "${C_GREEN}${C_BOLD}  ♾️  UNMETERED (Gratis Tanpa Batas, Tanpa Kuota Sesi):${C_RESET}"
      echo -e "  ${C_BOLD}[1]${C_RESET} ${C_GREEN}z-ai/glm-5.3-flash${C_RESET}        ${C_DIM}⭐ Default — Deepest reasoning, unmetered${C_RESET}"
      echo -e "  ${C_BOLD}[2]${C_RESET} ${C_GREEN}deepseek/deepseek-v4-flash${C_RESET} ${C_DIM}⚡ Fast coding & tool use, unmetered${C_RESET}"
      echo -e "  ${C_BOLD}[3]${C_RESET} ${C_GREEN}mimo/mimo-v2.5${C_RESET}             ${C_DIM}🖼️  Balanced + image support, unmetered${C_RESET}"
      echo ""
      echo -e "${C_YELLOW}${C_BOLD}  📊 METERED (Pakai Sesi Harian, Full Access):${C_RESET}"
      echo -e "  ${C_BOLD}[4]${C_RESET} ${C_GREEN}openai/gpt-5.6-luna${C_RESET}        ${C_DIM}🌙 Strong all-around, native images${C_RESET}"
      echo -e "  ${C_BOLD}[5]${C_RESET} ${C_GREEN}meta/muse-spark-1.2-contributor${C_RESET} ${C_DIM}🔥 Meta agentic model, 1M ctx, shared/queued${C_RESET}"
      echo -e "  ${C_BOLD}[6]${C_RESET} ${C_GREEN}anthropic/claude-fable-5${C_RESET}   ${C_DIM}🏛️  Claude top architecture & refactor${C_RESET}"
      echo -e "  ${C_BOLD}[7]${C_RESET} ${C_GREEN}google/gemini-3.8-flash${C_RESET}    ${C_DIM}⚡ Ultra fast inference${C_RESET}"
      echo -e "  ${C_BOLD}[8]${C_RESET} ${C_GREEN}minimax/minimax-m2.7${C_RESET}       ${C_DIM}📚 High context & complex docs${C_RESET}"
      echo -e "  ${C_BOLD}[9]${C_RESET} ${C_GREEN}moonshotai/kimi-k2.7-code${C_RESET}  ${C_DIM}💻 Code specialized, long context${C_RESET}"
      echo ""
      echo -e "${C_PURPLE}${C_BOLD}  🔧 LAINNYA:${C_RESET}"
      echo -e "  ${C_BOLD}[a]${C_RESET} ${C_YELLOW}Lihat SEMUA model dari API...${C_RESET}"
      echo -e "  ${C_BOLD}[0]${C_RESET} ${C_YELLOW}Ketik Model ID manual...${C_RESET}"
      echo -e "${C_CYAN}--------------------------------------------------------------------------------${C_RESET}"
      
      read -rp "$(echo -e "${C_BOLD}Pilih model [1-9/a/0, default: 1]: ${C_RESET}")" MODEL_CHOICE
      MODEL_CHOICE="${MODEL_CHOICE:-1}"

      case "$MODEL_CHOICE" in
        1) SELECTED_MODEL="z-ai/glm-5.3-flash" ;;
        2) SELECTED_MODEL="deepseek/deepseek-v4-flash" ;;
        3) SELECTED_MODEL="mimo/mimo-v2.5" ;;
        4) SELECTED_MODEL="openai/gpt-5.6-luna" ;;
        5) SELECTED_MODEL="meta/muse-spark-1.2-contributor" ;;
        6) SELECTED_MODEL="anthropic/claude-fable-5" ;;
        7) SELECTED_MODEL="google/gemini-3.8-flash" ;;
        8) SELECTED_MODEL="minimax/minimax-m2.7" ;;
        9) SELECTED_MODEL="moonshotai/kimi-k2.7-code" ;;
        a|A)
          echo -e "\n${C_BOLD}📋 Semua model tersedia di Freebuff Proxy:${C_RESET}"
          MODELS_LIST=$(curl -s "$BASE_URL/models" 2>/dev/null | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
          IDX=1
          declare -A MODEL_MAP
          while IFS= read -r m; do
            printf "  ${C_BOLD}[%2d]${C_RESET} ${C_GREEN}%s${C_RESET}\n" "$IDX" "$m"
            MODEL_MAP[$IDX]="$m"
            ((IDX++))
          done <<< "$MODELS_LIST"
          echo ""
          read -rp "$(echo -e "${C_BOLD}Pilih nomor model: ${C_RESET}")" DYN_CHOICE
          SELECTED_MODEL="${MODEL_MAP[$DYN_CHOICE]:-z-ai/glm-5.3-flash}"
          ;;
        0)
          read -rp "$(echo -e "${C_BOLD}Masukkan Model ID: ${C_RESET}")" SELECTED_MODEL
          ;;
        *)
          SELECTED_MODEL="z-ai/glm-5.3-flash"
          ;;
      esac
    fi

    echo -e "\n${C_GREEN}🚀 Model Terpilih : ${C_BOLD}$SELECTED_MODEL${C_RESET}"
    echo -e "${C_DIM}Endpoint Proxy : $BASE_URL${C_RESET}\n"

    # Action selector
    echo -e "${C_BOLD}Pilih Mode Peluncuran:${C_RESET}"
    echo -e "  ${C_BOLD}[1]${C_RESET} ${C_CYAN}Terminal Chat REPL${C_RESET}     ${C_DIM}(Buka sesi tanya jawab / koding langsung di terminal)${C_RESET}"
    echo -e "  ${C_BOLD}[2]${C_RESET} ${C_CYAN}Luncurkan Freebuff CLI${C_RESET} ${C_DIM}(Buka Freebuff CLI dengan proxy & model ini)${C_RESET}"
    echo -e "  ${C_BOLD}[3]${C_RESET} ${C_CYAN}Export Environment${C_RESET}     ${C_DIM}(Tampilkan environment variables untuk Cursor/IDE)${C_RESET}"
    echo -e "  ${C_BOLD}[4]${C_RESET} ${C_CYAN}Selesai (Background)${C_RESET}   ${C_DIM}(Biarkan proxy berjalan di background)${C_RESET}"
    
    read -rp "$(echo -e "${C_BOLD}Pilihan Anda [1-4, default: 1]: ${C_RESET}")" LAUNCH_CHOICE
    LAUNCH_CHOICE="${LAUNCH_CHOICE:-1}"

    export OPENAI_BASE_URL="$BASE_URL"
    export OPENAI_MODEL="$SELECTED_MODEL"
    export OPENAI_API_KEY="freebuff"
    export FREEBUFF_PROXY_URL="$BASE_URL"

    case "$LAUNCH_CHOICE" in
      1)
        exec node "$SCRIPT_DIR/proxy-chat.js" "$SELECTED_MODEL"
        ;;
      2)
        echo -e "\n${C_GREEN}🌟 Meluncurkan Freebuff CLI dengan proxy & model $SELECTED_MODEL...${C_RESET}\n"
        exec "$SCRIPT_DIR/run.sh" "$@"
        ;;
      3)
        echo -e "\n${C_BOLD}Salin dan gunakan variabel ini di shell atau IDE Anda:${C_RESET}"
        echo -e "${C_CYAN}export OPENAI_BASE_URL=\"$BASE_URL\"${C_RESET}"
        echo -e "${C_CYAN}export OPENAI_MODEL=\"$SELECTED_MODEL\"${C_RESET}"
        echo -e "${C_CYAN}export OPENAI_API_KEY=\"freebuff\"${C_RESET}"
        echo -e "\n${C_GREEN}✅ Konfigurasi siap digunakan!${C_RESET}"
        ;;
      4)
        echo -e "\n${C_GREEN}✅ Freebuff Proxy siap di $BASE_URL dengan model default $SELECTED_MODEL.${C_RESET}"
        ;;
    esac
    ;;
  *)
    echo -e "${C_RED}Perintah proxy tidak dikenal: $ACTION${C_RESET}"
    echo -e "Penggunaan: freebuff-power proxy [start|stop|restart|status|models|init|run]"
    exit 1
    ;;
esac

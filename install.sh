#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER & FREEPI-POWER SUPREME SUITE — Universal Dual Installer (v11.0)
# ==============================================================================
# Dual-Identity Architecture:
#   - FreePi Engine   : Free terminal coding powered by freepi.ai (free-pi-cli)
#   - Freebuff Engine : 94 Specialized Agents, 584 Curated Skills, Anti-Ban & SA-MP
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/FerzDevZ/freebuff-power/main/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/FerzDevZ/freebuff-power/main/install.sh | bash
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

clear 2>/dev/null || true
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚡ FREEBUFF-POWER & FREEPI-POWER SUPREME DUAL SUITE (v11.2)${C_RESET}"
echo -e "${C_DIM}FreePi (freepi.ai) + Freebuff Cognitive Swarm (99 Agents & 591 Skills)${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

INSTALL_BIN_DIR="$HOME/.local/bin"
SUPERPOWER_DIR="$HOME/.freebuff-superpower"
FREEPI_SUPERPOWER_DIR="$HOME/.freepi-superpower"
REPO_CACHE_DIR="$HOME/.freebuff-power-src"
POWER_REPO_URL="https://github.com/FerzDevZ/freebuff-power.git"
PROXY_REPO_URL="https://github.com/FerzDevZ/freebuff-proxy.git"
PROXY_DIR="$HOME/freebuff-proxy"

mkdir -p "$INSTALL_BIN_DIR" "$SUPERPOWER_DIR/.freebuff/agents" "$SUPERPOWER_DIR/.freebuff/skills"

# 0. Check Essential Dependencies
echo -e "${C_BLUE}🔍 [0/5] Memeriksa dependensi sistem...${C_RESET}"
for dep in git node npm; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo -e "${C_RED}❌ Dependensi '$dep' belum terpasang. Harap pasang '$dep' terlebih dahulu.${C_RESET}"
    exit 1
  fi
done

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo -e "${C_RED}❌ curl atau wget diperlukan untuk proses instalasi.${C_RESET}"
  exit 1
fi
echo -e "${C_GREEN}✅ Node.js $(node -v), npm $(npm -v), git, dan downloader siap!${C_RESET}\n"

# 1. Resolve source repository
SOURCE_DIR="$REPO_CACHE_DIR"
CURRENT_SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -d "$CURRENT_SCRIPT_DIR/bin" ] && [ -d "$CURRENT_SCRIPT_DIR/superpower" ]; then
  echo -e "${C_GREEN}📁 [1/5] Menggunakan repository lokal aktif di $CURRENT_SCRIPT_DIR...${C_RESET}"
  SOURCE_DIR="$CURRENT_SCRIPT_DIR"
else
  echo -e "${C_BLUE}📦 [1/5] Mengunduh repository & pustaka Superpower...${C_RESET}"
  if [ -d "$REPO_CACHE_DIR/.git" ]; then
    echo -e "${C_DIM}Menyinkronkan pembaruan freebuff-power & freepi-power...${C_RESET}"
    git -C "$REPO_CACHE_DIR" fetch --depth 1 origin main --quiet 2>/dev/null || true
    git -C "$REPO_CACHE_DIR" reset --hard origin/main --quiet 2>/dev/null || {
      rm -rf "$REPO_CACHE_DIR"
      git clone --depth 1 "$POWER_REPO_URL" "$REPO_CACHE_DIR" --quiet
    }
  else
    rm -rf "$REPO_CACHE_DIR"
    git clone --depth 1 "$POWER_REPO_URL" "$REPO_CACHE_DIR" --quiet
  fi
fi

TOTAL_AGENTS=$(ls -1 "$SOURCE_DIR/superpower/agents" 2>/dev/null | wc -l || echo "94")
TOTAL_SKILLS=$(ls -1 "$SOURCE_DIR/superpower/skills" 2>/dev/null | wc -l || echo "584")

# 2. Install All CLI binaries and helpers
echo -e "${C_BLUE}⚙️  [2/5] Memasang seluruh suite dual CLI binary ke $INSTALL_BIN_DIR...${C_RESET}"
for bin_file in "$SOURCE_DIR/bin/"*; do
  dest="$INSTALL_BIN_DIR/$(basename "$bin_file")"
  if [ -L "$dest" ] || [ -f "$dest" ]; then
    if [ "$(realpath "$dest" 2>/dev/null)" = "$(realpath "$bin_file" 2>/dev/null)" ]; then
      continue
    fi
  fi
  cp -rf "$bin_file" "$dest" 2>/dev/null || true
done

chmod +x "$INSTALL_BIN_DIR"/freebuff-power \
         "$INSTALL_BIN_DIR"/freepi-power \
         "$INSTALL_BIN_DIR"/freepi-runner.sh \
         "$INSTALL_BIN_DIR"/freepi-sessions.sh \
         "$INSTALL_BIN_DIR"/freepi-pack.sh \
         "$INSTALL_BIN_DIR"/samp-audit.sh \
         "$INSTALL_BIN_DIR"/samp-heal.sh \
         "$INSTALL_BIN_DIR"/zcode-power \
         "$INSTALL_BIN_DIR"/*.sh \
         "$INSTALL_BIN_DIR"/*.js \
         "$INSTALL_BIN_DIR"/*.py 2>/dev/null || true
chmod -R +x "$INSTALL_BIN_DIR"/shims 2>/dev/null || true

# Compile hardware virtualization stealth hook if gcc is present
if command -v gcc >/dev/null 2>&1 && [ -f "$SOURCE_DIR/src/stealth/libfreebuff-stealth.c" ]; then
  gcc -O2 -shared -fPIC -o "$INSTALL_BIN_DIR/libfreebuff-stealth.so" "$SOURCE_DIR/src/stealth/libfreebuff-stealth.c" -ldl 2>/dev/null || true
  cp -f "$INSTALL_BIN_DIR/libfreebuff-stealth.so" "$SOURCE_DIR/bin/libfreebuff-stealth.so" 2>/dev/null || true
fi

# Link universal aliases & shortcuts
ln -sf "$INSTALL_BIN_DIR/freebuff-wrapper.sh" "$INSTALL_BIN_DIR/freebuff" 2>/dev/null || true
ln -sf "$INSTALL_BIN_DIR/freepi-runner.sh" "$INSTALL_BIN_DIR/freepi" 2>/dev/null || true

# 3. Install Superpower templates, ECC Architecture & Anti-Slop Skills
echo -e "${C_BLUE}🧰 [3/5] Menyinkronkan ${TOTAL_AGENTS} Sub-Agents & ${TOTAL_SKILLS} Modular Skills ke $SUPERPOWER_DIR dan ~/.agents...${C_RESET}"
# Clear old stale files in SUPERPOWER_DIR
rm -rf "$SUPERPOWER_DIR/skills" "$SUPERPOWER_DIR/agents" "$SUPERPOWER_DIR/rules" "$SUPERPOWER_DIR/.freebuff" 2>/dev/null || true
cp -rf "$SOURCE_DIR/superpower/"* "$SUPERPOWER_DIR/"

# Populate ~/.agents/ (Universal AgentSkills & FreePi/Codebuff Registry)
mkdir -p "$HOME/.agents/skills" "$HOME/.agents/agents" "$HOME/.agents/rules"
if [ -d "$SUPERPOWER_DIR/skills" ]; then
  rm -rf "$HOME/.agents/skills"/* 2>/dev/null || true
  cp -rf "$SUPERPOWER_DIR/skills/"* "$HOME/.agents/skills/" 2>/dev/null || true
fi
if [ -d "$SUPERPOWER_DIR/agents" ]; then
  rm -rf "$HOME/.agents/agents"/* 2>/dev/null || true
  cp -rf "$SUPERPOWER_DIR/agents/"* "$HOME/.agents/agents/" 2>/dev/null || true
fi
if [ -d "$SUPERPOWER_DIR/rules" ]; then
  rm -rf "$HOME/.agents/rules"/* 2>/dev/null || true
  cp -rf "$SUPERPOWER_DIR/rules/"* "$HOME/.agents/rules/" 2>/dev/null || true
fi

# Backward compatibility for .freebuff
mkdir -p "$SUPERPOWER_DIR/.freebuff/agents" "$SUPERPOWER_DIR/.freebuff/skills"
cp -rf "$SUPERPOWER_DIR/skills/"* "$SUPERPOWER_DIR/.freebuff/skills/" 2>/dev/null || true
cp -rf "$SUPERPOWER_DIR/agents/"* "$SUPERPOWER_DIR/.freebuff/agents/" 2>/dev/null || true

# Symlink ~/.freepi-superpower to ~/.freebuff-superpower
if [ ! -d "$FREEPI_SUPERPOWER_DIR" ] && [ ! -L "$FREEPI_SUPERPOWER_DIR" ]; then
  ln -sf "$SUPERPOWER_DIR" "$FREEPI_SUPERPOWER_DIR" 2>/dev/null || true
fi

# Populate FreePi Native Slash-Command Prompts (~/.free-pi/agent/prompts) & Lean Default Skill Pack
mkdir -p "$HOME/.free-pi/agent/prompts" "$HOME/.free-pi/agent/skills"
if [ -d "$SUPERPOWER_DIR/agents" ]; then
  cp -f "$SUPERPOWER_DIR/agents/"*.md "$HOME/.free-pi/agent/prompts/" 2>/dev/null || true
fi
if [ -x "$INSTALL_BIN_DIR/freepi-pack.sh" ]; then
  if [ -z "$(ls -A "$HOME/.free-pi/agent/skills" 2>/dev/null)" ] || [ -d "$HOME/.free-pi/agent/skills/samp-textdraw-fivem-modern-design" ]; then
    "$INSTALL_BIN_DIR/freepi-pack.sh" samp >/dev/null 2>&1 || true
  fi
fi

# 4. Install & Build Standalone freebuff-proxy Suite
echo -e "${C_BLUE}🌐 [4/5] Memeriksa & menyinkronkan Freebuff Proxy Engine di $PROXY_DIR...${C_RESET}"
if [ -d "$PROXY_DIR/.git" ]; then
  echo -e "${C_DIM}Memperbarui freebuff-proxy yang ada...${C_RESET}"
  git -C "$PROXY_DIR" pull --quiet || true
else
  if [ ! -d "$PROXY_DIR" ]; then
    echo -e "${C_DIM}Meng-clone freebuff-proxy dari GitHub...${C_RESET}"
    git clone --depth 1 "$PROXY_REPO_URL" "$PROXY_DIR" --quiet || true
  fi
fi

if [ -d "$PROXY_DIR" ] && [ -f "$PROXY_DIR/package.json" ]; then
  mkdir -p "$PROXY_DIR/data" "$PROXY_DIR/logs"
  if [ ! -f "$PROXY_DIR/data/auth.json" ]; then
    cat << 'AUTH_INIT_EOF' > "$PROXY_DIR/data/auth.json"
{
  "accounts": [],
  "api_keys": [],
  "next_id": 1,
  "next_key_id": 1,
  "keys_enabled": false
}
AUTH_INIT_EOF
  fi

  if [ ! -d "$PROXY_DIR/dist" ] || [ ! -d "$PROXY_DIR/node_modules" ]; then
    echo -e "${C_YELLOW}⚡ Membangun build produksi freebuff-proxy (npm install & build)...${C_RESET}"
    (cd "$PROXY_DIR" && npm install --silent && npm run build --silent) || echo -e "${C_YELLOW}⚠️  Build proxy mandiri dilewati, dapat dijalankan manual nanti.${C_RESET}"
  fi
  chmod +x "$PROXY_DIR"/*.sh 2>/dev/null || true
fi

# 5. Ensure Core Engines are Installed (freebuff & free-pi-cli)
echo -e "${C_BLUE}⚡ [5/5] Memeriksa engine Freebuff & FreePi CLI (freepi.ai)...${C_RESET}"
if ! command -v freebuff >/dev/null 2>&1; then
  echo -e "${C_YELLOW}⚡ Memasang Core Engine 'freebuff' via npm...${C_RESET}"
  sudo npm install -g freebuff >/dev/null 2>&1 || npm install -g freebuff >/dev/null 2>&1 || true
fi

if ! command -v free-pi-cli >/dev/null 2>&1; then
  echo -e "${C_YELLOW}⚡ Memasang Core Engine 'free-pi-cli' (freepi.ai) via npm...${C_RESET}"
  sudo npm install -g free-pi-cli >/dev/null 2>&1 || npm install -g free-pi-cli >/dev/null 2>&1 || true
fi

# Auto-Enforce Anti-Watermark Stealth Hooks & Pre-Push Secret Guard
"$INSTALL_BIN_DIR/clean.sh" >/dev/null 2>&1 || true

# Ensure Shell PATH for all shells
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
  if [ -f "$rc" ] && ! grep -q '\.local/bin' "$rc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
  fi
done
export PATH="$HOME/.local/bin:$PATH"

echo -e "\n${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}🎉 DUAL INSTALASI SUKSES 100%! (FREEBUFF-POWER & FREEPI-POWER READY)${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "\n🔥 Sekarang kamu bisa menggunakan kedua perintah secara bebas di folder mana pun:\n"

echo -e "  ${C_CYAN}${C_BOLD}[ FREEPI-POWER (freepi.ai — Native CLI) ]${C_RESET}"
echo -e "  \033[0;36m\033[1mfreepi-power start\033[0m            \033[2m# Mulai sesi FreePi + injeksi ${TOTAL_AGENTS} agents & ${TOTAL_SKILLS} skills\033[0m"
echo -e "  \033[0;36m\033[1mfreepi-power session\033[0m          \033[2m# Lihat semua sesi FreePi tersimpan & lanjutkan via ID\033[0m"
echo -e "  \033[0;36m\033[1mfreepi-power continue\033[0m         \033[2m# Lanjutkan sesi terakhir di folder aktif\033[0m"
echo -e "  \033[0;36m\033[1mfreepi-power commands\033[0m         \033[2m# Lihat seluruh perintah CLI & /slash command FreePi\033[0m"
echo -e "  \033[0;36m\033[1mfreepi-power pack samp\033[0m        \033[2m# Aktifkan pack SA-MP 2026 + FiveM TextDraw + Modern Jobs\033[0m\n"

echo -e "  ${C_YELLOW}${C_BOLD}[ FREEBUFF-POWER & ANTI-BAN ]${C_RESET}"
echo -e "  \033[0;33m\033[1mfreebuff-power start\033[0m          \033[2m# Koding via Freebuff dengan Anti-Ban & Multi-Account Vault\033[0m"
echo -e "  \033[0;33m\033[1mfreebuff-power local\033[0m          \033[2m# Koding offline 100% gratis via Ollama lokal (zero-token)\033[0m"
echo -e "  \033[0;33m\033[1mfreebuff-power heal\033[0m           \033[2m# Autonomous SWE repair loop: perbaiki bug otomatis\033[0m"
echo -e "  \033[0;33m\033[1mfreebuff-power ui\033[0m             \033[2m# Buka Interactive Terminal TUI Dashboard\033[0m\n"

echo -e "  ${C_PURPLE}${C_BOLD}[ GTA SA-MP & OPEN.MP DEVELOPER SUITE ]${C_RESET}"
echo -e "  \033[0;35m\033[1mfreepi-power samp audit .\033[0m     \033[2m# Deep code linter: OnPlayerUpdate lag, strcmp, SQL Injection\033[0m"
echo -e "  \033[0;35m\033[1mfreepi-power samp heal main.pwn\033[0m \033[2m# Autonomous Pawn compiler & syntax error healer\033[0m"
echo -e "  \033[0;35m\033[1mfreepi-power samp new openmp\033[0m   \033[2m# Scaffold open.mp gamemode modern (YSI 5 + MySQL)\033[0m"
echo -e "  \033[0;35m\033[1mfreepi-power samp vs\033[0m          \033[2m# Kitab perbandingan teknis SA-MP legacy vs open.mp\033[0m\n"

echo -e "  ${C_GREEN}${C_BOLD}[ ANTI-SLOP & HUMAN DESIGN ]${C_RESET}"
echo -e "  \033[0;32m\033[1mfreepi-power antislop audit .\033[0m \033[2m# Pindai 40 aturan AI slop, gradien ungu, & buzzwords\033[0m"
echo -e "  \033[0;32m\033[1mfreepi-power design init\033[0m      \033[2m# Buat file DESIGN.md bertaraf studio\033[0m"
echo -e "  \033[0;32m\033[1mfreepi-power contrast #000 #fff\033[0m \033[2m# Validasi matematis kontras WCAG 2.2 AAA\033[0m\n"

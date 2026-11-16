#!/usr/bin/env bash
# ==============================================================================
# 💻 FREEBUFF-POWER LOCAL OFFLINE OLLAMA & VLLM ENGINE (v11.0)
# 100% Zero-Token, Zero-Latency, Zero-Cost & Anti-Ban Private AI Coding
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

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}💻 [FREEBUFF-POWER] LOCAL OFFLINE LLM ENGINE (ZERO-TOKEN CODING)${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

OLLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
SELECTED_MODEL="${1:-}"

# 1. Check Ollama Daemon Availability
echo -e "${C_YELLOW}🔍 [1/3] Memeriksa daemon server lokal Ollama...${C_RESET}"
if ! curl -s --connect-timeout 2 "$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
  echo -e "  ${C_YELLOW}⚠️  Ollama belum berjalan di $OLLAMA_HOST. Mencoba memulai di background...${C_RESET}"
  if command -v ollama >/dev/null 2>&1; then
    nohup ollama serve >/dev/null 2>&1 &
    sleep 2
  else
    echo -e "${C_RED}❌ Ollama belum terpasang di sistem Linux ini!${C_RESET}"
    echo -e "Pasang Ollama dengan cepat: ${C_CYAN}curl -fsSL https://ollama.com/install.sh | sh${C_RESET}"
    exit 1
  fi
fi

if curl -s --connect-timeout 2 "$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
  echo -e "${C_GREEN}  ✓ Daemon Ollama aktif & siap melayani request di $OLLAMA_HOST${C_RESET}"
else
  echo -e "${C_RED}❌ Gagal terhubung ke Ollama daemon.${C_RESET}"
  exit 1
fi

# 2. Enumerate Local Models
echo -e "${C_YELLOW}📋 [2/3] Memeriksa model lokal yang tersedia...${C_RESET}"
LOCAL_MODELS=$(curl -s "$OLLAMA_HOST/api/tags" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 || true)

if [ -z "$LOCAL_MODELS" ]; then
  echo -e "  ${C_YELLOW}⚠️ Belum ada model yang di-pull ke Ollama.${C_RESET}"
  echo -e "  💡 Mengunduh model koding rekomendasi terbaik: ${C_CYAN}qwen2.5-coder:7b${C_RESET}..."
  ollama pull qwen2.5-coder:7b
  SELECTED_MODEL="qwen2.5-coder:7b"
else
  if [ -z "$SELECTED_MODEL" ]; then
    # Auto-pick best available model
    for candidate in "qwen2.5-coder:32b" "qwen2.5-coder:14b" "qwen2.5-coder:7b" "deepseek-coder-v2" "deepseek-coder:6.7b" "llama3.3" "codellama"; do
      if echo "$LOCAL_MODELS" | grep -q "$candidate"; then
        SELECTED_MODEL="$candidate"
        break
      fi
    done
    if [ -z "$SELECTED_MODEL" ]; then
      SELECTED_MODEL="$(echo "$LOCAL_MODELS" | head -n 1)"
    fi
  fi
fi

echo -e "  ${C_GREEN}✓ Model Terpilih : ${C_BOLD}${SELECTED_MODEL}${C_RESET}\n"

# 3. Launch Local Coding Session via OpenAI-Compatible Endpoint
echo -e "${C_YELLOW}🚀 [3/3] Meluncurkan sesi koding offline 100% Zero-Token...${C_RESET}"
echo -e "  • Endpoint   : ${C_CYAN}$OLLAMA_HOST/v1${C_RESET}"
echo -e "  • Model      : ${C_PURPLE}$SELECTED_MODEL${C_RESET}"
echo -e "  • Biaya      : ${C_GREEN}Rp 0 (100% Gratis & Kebal Ban)${C_RESET}\n"

export OPENAI_BASE_URL="$OLLAMA_HOST/v1"
export OPENAI_API_KEY="ollama-local"
export ANTHROPIC_BASE_URL="$OLLAMA_HOST/v1"

SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -x "$SCRIPT_DIR/freebuff-wrapper.sh" ]; then
  exec "$SCRIPT_DIR/freebuff-wrapper.sh" --model "$SELECTED_MODEL" "$@"
else
  exec freebuff --model "$SELECTED_MODEL" "$@"
fi

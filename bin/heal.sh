#!/usr/bin/env bash
# ==============================================================================
# 🩺 FREEBUFF-POWER AUTONOMOUS SWE HEALER (v13.0)
# Automated Test-Driven Bug Repair Loop (Traceback -> Minimal Patch -> Green)
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
echo -e "${C_YELLOW}${C_BOLD}🩺 [FREEBUFF-POWER] AUTONOMOUS SWE-HEALER & TDD REPAIR LOOP${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

TEST_CMD="${*:-}"

# 1. Auto-detect test runner if not provided
if [ -z "$TEST_CMD" ]; then
  if [ -f "package.json" ]; then
    if grep -q '"test"' package.json; then
      TEST_CMD="npm test"
    elif [ -f "node_modules/.bin/vitest" ]; then
      TEST_CMD="npx vitest run"
    elif [ -f "node_modules/.bin/jest" ]; then
      TEST_CMD="npx jest"
    else
      TEST_CMD="npx tsc --noEmit"
    fi
  elif [ -f "pytest.ini" ] || [ -d "tests" ] || [ -f "pyproject.toml" ]; then
    TEST_CMD="pytest -q"
  elif [ -f "Cargo.toml" ]; then
    TEST_CMD="cargo test --quiet"
  elif [ -f "go.mod" ]; then
    TEST_CMD="go test ./..."
  elif [ -f "pubspec.yaml" ]; then
    TEST_CMD="flutter test"
  else
    echo -e "${C_RED}❌ Tidak dapat mendeteksi test runner otomatis.${C_RESET}"
    echo -e "Silakan tentukan perintah tes secara manual: ${C_YELLOW}freebuff-power heal \"npm test\"${C_RESET}"
    exit 1
  fi
fi

echo -e "🚀 Test Runner Target : ${C_CYAN}${C_BOLD}$TEST_CMD${C_RESET}"
echo -e "🔍 Menjalankan tes untuk diagnosis kegagalan...\n"

LOG_FILE="/tmp/freebuff-heal-$(date +%s).log"
set +e
eval "$TEST_CMD" > "$LOG_FILE" 2>&1
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -eq 0 ]; then
  echo -e "\n${C_GREEN}${C_BOLD}🎉 SEMUA TES HIJAU (PASS)! Tidak ditemukan error atau build failure.${C_RESET}"
  echo -e "${C_DIM}Codebase dalam kondisi sehat 100%. Tidak ada perbaikan yang diperlukan.${C_RESET}\n"
  rm -f "$LOG_FILE"
  exit 0
fi

echo -e "\n${C_RED}${C_BOLD}❌ KEGAGALAN TERDETEKSI (Exit Code: $EXIT_CODE)${C_RESET}"
echo -e "${C_YELLOW}📋 Cuplikan Traceback Error:${C_RESET}"
echo -e "${C_DIM}------------------------------------------------------------------------${C_RESET}"
tail -n 25 "$LOG_FILE"
echo -e "${C_DIM}------------------------------------------------------------------------${C_RESET}\n"

# 2. Package context for @swe-healer agent
SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
HEAL_PROMPT="Lakukan perbaikan otonom (SWE-bench protocol) terhadap kegagalan tes berikut. Perintah tes: '$TEST_CMD'. Traceback error:\n$(tail -n 35 "$LOG_FILE")\nAturan: 1. Diagnosis root-cause. 2. Buat surgical minimal patch (jangan rombak file lain). 3. Verifikasi ulang dengan menjalankan '$TEST_CMD' hingga lulus."

echo -e "${C_PURPLE}${C_BOLD}🤖 Mengaktifkan Persona @swe-healer untuk sintesis perbaikan otonom...${C_RESET}"
echo -e "👉 Buka sesi interaktif repair sekarang:\n"

if [ -x "$SCRIPT_DIR/freebuff-wrapper.sh" ]; then
  exec "$SCRIPT_DIR/freebuff-wrapper.sh" -p "@swe-healer $HEAL_PROMPT"
else
  exec freebuff -p "@swe-healer $HEAL_PROMPT"
fi

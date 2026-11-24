#!/usr/bin/env bash
# ==============================================================================
# 📝 FREEBUFF-POWER AI CONVENTIONAL COMMIT ASSISTANT
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

if [ ! -d ".git" ]; then
  echo "❌ Direktori ini bukan git repository."
  exit 1
fi

CHANGED_FILES=$(git status --short)
if [ -z "$CHANGED_FILES" ]; then
  echo "ℹ️ Tidak ada perubahan file di repository (Working tree clean)."
  exit 0
fi

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}📝 [FREEBUFF-POWER COMMIT] AI Conventional Commit Generator${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# Detect primary changes
COMMIT_TYPE="chore"
SCOPE="core"

if echo "$CHANGED_FILES" | grep -qE "(auth|login|jwt|token)"; then
  SCOPE="auth"
elif echo "$CHANGED_FILES" | grep -qE "(ui|component|css|style|page)"; then
  SCOPE="ui"
elif echo "$CHANGED_FILES" | grep -qE "(db|sql|schema|migration)"; then
  SCOPE="db"
elif echo "$CHANGED_FILES" | grep -qE "(doc|README|AGENTS)"; then
  COMMIT_TYPE="docs"
  SCOPE="docs"
elif echo "$CHANGED_FILES" | grep -qE "(test|spec)"; then
  COMMIT_TYPE="test"
  SCOPE="test"
fi

if echo "$CHANGED_FILES" | grep -q "^A "; then
  COMMIT_TYPE="feat"
elif echo "$CHANGED_FILES" | grep -qE "(fix|bug|patch)"; then
  COMMIT_TYPE="fix"
fi

SUGGESTED_MSG="${COMMIT_TYPE}(${SCOPE}): update project files and dependencies"

echo -e "📁 File yang berubah:"
echo "$CHANGED_FILES" | sed 's/^/  /'
echo ""
echo -e "${C_GREEN}${C_BOLD}💡 Rekomendasi Pesan Commit:${C_RESET} \"${C_BOLD}$SUGGESTED_MSG${C_RESET}\""
echo ""
read -p "Gunakan pesan ini? (Y/n/ketik pesan kustom): " -r USER_INPUT || USER_INPUT="y"

if [[ "$USER_INPUT" =~ ^[Yy]$ || -z "$USER_INPUT" ]]; then
  git add .
  git commit -m "$SUGGESTED_MSG"
  echo -e "\n${C_GREEN}🎉 Commit berhasil disimpan!${C_RESET}"
elif [[ "$USER_INPUT" =~ ^[Nn]$ ]]; then
  echo "Dibatalkan."
else
  git add .
  git commit -m "$USER_INPUT"
  echo -e "\n${C_GREEN}🎉 Commit berhasil disimpan dengan pesan kustom!${C_RESET}"
fi

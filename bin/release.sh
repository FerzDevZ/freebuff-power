#!/usr/bin/env bash
# ==============================================================================
# 🚀 FREEBUFF-POWER AUTOMATED SEMANTIC RELEASE & CHANGELOG ENGINE
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

if [ ! -d ".git" ]; then
  echo "❌ Bukan git repository."
  exit 1
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
COMMITS=$(git log "${LAST_TAG}..HEAD" --oneline 2>/dev/null || git log -n 10 --oneline)

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🚀 [FREEBUFF-POWER RELEASE] Automated Semantic Versioning & Changelog${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

BUMP="patch"
if echo "$COMMITS" | grep -qi "feat:"; then
  BUMP="minor"
fi
if echo "$COMMITS" | grep -qi "BREAKING"; then
  BUMP="major"
fi

echo -e "🏷️ Tag Terakhir    : ${C_BOLD}$LAST_TAG${C_RESET}"
echo -e "📈 Rekomendasi Bump: ${C_GREEN}${C_BOLD}$BUMP${C_RESET}"

DATE_STR=$(date +%Y-%m-%d)
ENTRY="## [Release $DATE_STR] ($BUMP)\n\n### Perubahan:\n$(echo "$COMMITS" | sed 's/^/- /')\n"

if [ -f "CHANGELOG.md" ]; then
  echo -e "$ENTRY\n$(cat CHANGELOG.md)" > CHANGELOG.md
else
  echo -e "# Changelog\n\n$ENTRY" > CHANGELOG.md
fi

echo -e "\n${C_GREEN}✅ File 'CHANGELOG.md' berhasil diperbarui.${C_RESET}"
echo -e "👉 Menandai commit rilis baru...\n"

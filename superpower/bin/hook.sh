#!/usr/bin/env bash
# ==============================================================================
# 🛡️ FREEBUFF-POWER PRE-COMMIT SECRET LEAK & AI-SLOP HOOK INSTALLER
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

if [ ! -d ".git" ]; then
  echo -e "${C_RED}❌ Bukan git repository. Jalankan di root folder proyek yang memiliki .git${C_RESET}"
  exit 1
fi

HOOK_FILE=".git/hooks/pre-commit"
mkdir -p ".git/hooks"

cat << 'HOOK_EOF' > "$HOOK_FILE"
#!/usr/bin/env bash
# Freebuff-Power Security & Anti-Slop Guard
set -e

# 1. Prevent .env and private key commits
STAGED_FILES=$(git diff --cached --name-only)
if echo "$STAGED_FILES" | grep -E "\.env$|\.env\.local$|\.pem$|\.key$|id_rsa" >/dev/null; then
  echo -e "\033[0;31m\033[1m❌ [SECURITY GUARD] Ditemukan file secret/kredensial di staging area:\033[0m"
  echo "$STAGED_FILES" | grep -E "\.env$|\.env\.local$|\.pem$|\.key$|id_rsa"
  echo -e "\033[0;33m👉 Hapus file tersebut dari commit: git reset HEAD <file>\033[0m"
  exit 1
fi

# 2. Prevent hardcoded API Keys (OpenAI, Stripe, AWS, GitHub)
STAGED_DIFF=$(git diff --cached)
if echo "$STAGED_DIFF" | grep -E "sk-proj-[a-zA-Z0-9]{20,}|sk_live_[a-zA-Z0-9]{24,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}" >/dev/null; then
  echo -e "\033[0;31m\033[1m❌ [SECURITY GUARD] Terdeteksi HARDCODED API KEY di git diff!\033[0m"
  echo -e "\033[0;33m👉 Pindahkan API Key ke file .env sebelum melakukan commit.\033[0m"
  exit 1
fi

# 3. Prevent AI-Slop TODO placeholders
if echo "$STAGED_DIFF" | grep -E "^\+.*// TODO: implement later|^\+.*// \.\.\. rest of the code" >/dev/null; then
  echo -e "\033[0;31m\033[1m❌ [ANTI-SLOP GUARD] Terdeteksi AI-Slop placeholder stub di kode baru!\033[0m"
  exit 1
fi

echo -e "\033[0;32m[✓] Pre-commit security & anti-slop verification PASS.\033[0m"
HOOK_EOF

chmod +x "$HOOK_FILE"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}🎉 Git Pre-Commit Security Hook Berhasil Dipasang!${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "🛡️ Sekarang git akan otomatis memblokir kebocoran .env, API Key & AI-slop sebelum commit.\n"

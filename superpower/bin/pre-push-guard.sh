#!/usr/bin/env bash
# ==============================================================================
# 🔏 FREEBUFF-POWER ZERO-LEAK SECRET SCANNER & PRE-PUSH GUARD
# Intercepts git push to prevent credential, token, and private key leakage.
# ==============================================================================
set -e

echo -e "\033[0;36m\033[1m========================================================================\033[0m"
echo -e "\033[0;33m\033[1m🔏 [PRE-PUSH GUARD] Scanning Staged Commits for Secret Leaks...\033[0m"
echo -e "\033[0;36m\033[1m========================================================================\033[0m\n"

# Define secret patterns to intercept
LEAKS=0

check_pattern() {
  local pattern="$1"
  local desc="$2"
  local matches
  matches=$(git diff origin/main..HEAD 2>/dev/null | grep -E "^\+" | grep -E -e "$pattern" || true)
  if [ -z "$matches" ]; then
    matches=$(git diff --cached 2>/dev/null | grep -E "^\+" | grep -E -e "$pattern" || true)
  fi

  if [ -n "$matches" ]; then
    echo -e "\033[0;31m[CRITICAL LEAK DETECTED] $desc\033[0m"
    echo "$matches" | head -n 3
    echo ""
    LEAKS=$((LEAKS + 1))
  fi
}

check_pattern "(ghp_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9_]{82})" "GitHub Personal Access Token"
check_pattern "(AKIA[0-9A-Z]{16})" "AWS Access Key ID"
check_pattern "-----BEGIN (RSA|EC|OPENSSH|DSA) PRIVATE KEY-----" "Private Key / PEM Certificate"
check_pattern "manicode-[a-zA-Z0-9]{32,}" "Freebuff / Manicode Auth Bearer Token"
check_pattern "(postgres|mysql|mongodb|redis):\/\/[^:]+:[^@]+@" "Database URL with Plaintext Password"

if [ "$LEAKS" -gt 0 ]; then
  echo -e "\033[0;31m\033[1m❌ GIT PUSH DIBATALKAN: Ditemukan $LEAKS potensi kebocoran rahasia / credential!\033[0m"
  echo -e "\033[0;33m👉 Silakan hapus kredensial tersebut dari kode atau gunakan environment variables (.env).\033[0m\n"
  exit 1
fi

echo -e "\033[0;32m\033[1m✅ 0 Secret Leak Terdeteksi — Aman untuk di-push ke GitHub!\033[0m\n"
exit 0

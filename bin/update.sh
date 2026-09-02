#!/usr/bin/env bash
# ==============================================================================
# 🔄 FREEBUFF-POWER UNIVERSAL REPO UPDATER
# ==============================================================================
set -euo pipefail

echo -e "\033[0;36m\033[1m========================================================================\033[0m"
echo -e "\033[0;33m\033[1m🔄 [FREEBUFF-POWER UPDATE] Memperbarui Pustaka Superpower Terbaru...\033[0m"
echo -e "\033[0;36m\033[1m========================================================================\033[0m\n"

curl -fsSL https://raw.githubusercontent.com/FerzDevZ/freebuff-power/main/install.sh | bash

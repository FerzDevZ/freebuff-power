#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER & FREEPI-POWER — Installer (delegates to root install.sh)
# ==============================================================================
# This script is a thin wrapper kept for backward compatibility with callers
# that invoke `scripts/install.sh`. All real logic lives in the root install.sh.
# ==============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_INSTALL="$SCRIPT_DIR/../install.sh"

if [ -f "$ROOT_INSTALL" ]; then
  exec bash "$ROOT_INSTALL" "$@"
fi

# Fallback: fetch from GitHub
exec bash <(curl -fsSL https://raw.githubusercontent.com/FerzDevZ/freebuff-power/main/install.sh)

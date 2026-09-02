#!/usr/bin/env bash
# ==============================================================================
# ⏪ FREEBUFF-POWER TIME-TRAVEL SNAPSHOTS & INSTANT ROLLBACK
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

SNAPSHOT_DIR=".freebuff-snapshots"
mkdir -p "$SNAPSHOT_DIR"

function save_snapshot() {
  local label="${*:-snapshot_$(date +%Y%m%d_%H%M%S)}"
  local timestamp
  timestamp="$(date +%Y%m%d_%H%M%S)"
  local target_archive="$SNAPSHOT_DIR/${timestamp}_${label// /_}.tar.gz"
  
  echo -e "${C_CYAN}📸 Membuat snapshot checkpoint: ${C_BOLD}$label${C_RESET}..."
  tar --exclude="$SNAPSHOT_DIR" --exclude="node_modules" --exclude=".git" --exclude=".next" -czf "$target_archive" .
  echo -e "${C_GREEN}✅ Snapshot tersimpan: $target_archive${C_RESET}"
}

function list_snapshots() {
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
  echo -e "${C_YELLOW}${C_BOLD}📸 [TIME-TRAVEL SNAPSHOTS] Daftar Checkpoint Proyek${C_RESET}"
  echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"
  
  if [ -z "$(ls -A "$SNAPSHOT_DIR" 2>/dev/null)" ]; then
    echo -e "  (Belum ada snapshot tersimpan. Gunakan 'freebuff-power snapshot save <label>')\n"
  else
    for f in "$SNAPSHOT_DIR"/*.tar.gz; do
      if [ -f "$f" ]; then
        local base size
        base="$(basename "$f" .tar.gz)"
        size="$(du -h "$f" | cut -f1)"
        echo -e "  - ${C_GREEN}${C_BOLD}$base${C_RESET} ${C_YELLOW}($size)${C_RESET}"
      fi
    done
    echo -e "\n👉 Untuk restore: ${C_CYAN}freebuff-power snapshot restore <nama_snapshot>${C_RESET}\n"
  fi
}

function restore_snapshot() {
  local target="${1:-}"
  if [ -z "$target" ]; then
    target=$(ls -t "$SNAPSHOT_DIR"/*.tar.gz 2>/dev/null | head -n 1 || true)
    if [ -z "$target" ]; then
      echo -e "${C_RED}❌ Tidak ada snapshot yang ditemukan untuk di-restore!${C_RESET}"
      exit 1
    fi
  else
    if [ ! -f "$target" ] && [ -f "$SNAPSHOT_DIR/$target" ]; then
      target="$SNAPSHOT_DIR/$target"
    elif [ ! -f "$target" ] && [ -f "$SNAPSHOT_DIR/${target}.tar.gz" ]; then
      target="$SNAPSHOT_DIR/${target}.tar.gz"
    fi
  fi

  echo -e "${C_RED}${C_BOLD}⚠️  MEMULIHKAN PROYEK KE SNAPSHOT: $(basename "$target")${C_RESET}"
  tar -xzf "$target"
  echo -e "${C_GREEN}🎉 ROLLBACK SELESAI! Seluruh kode telah dipulihkan ke kondisi snapshot.${C_RESET}"
}

ACTION="${1:-list}"
shift || true

case "$ACTION" in
  save)
    save_snapshot "$@"
    ;;
  list)
    list_snapshots
    ;;
  restore|rollback)
    restore_snapshot "$@"
    ;;
  *)
    echo "Penggunaan: freebuff-power snapshot [save <label> | list | restore <id>]"
    ;;
esac

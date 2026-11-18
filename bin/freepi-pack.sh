#!/usr/bin/env bash
# ==============================================================================
# 🎒 FREEPI-POWER SKILL PACK & NATIVE PROMPT MANAGER (~/.free-pi/agent/)
# ==============================================================================
# Manages native FreePi skills (~/.free-pi/agent/skills/) and zero-token-cost
# slash-command agent prompts (~/.free-pi/agent/prompts/) so FreePi stays fast
# and preserves daily free credit allowance.
# ==============================================================================
set -euo pipefail

SUPERPOWER_DIR="$HOME/.freebuff-superpower"
FREEPI_AGENT_DIR="$HOME/.free-pi/agent"
FREEPI_SKILLS_DIR="$FREEPI_AGENT_DIR/skills"
FREEPI_PROMPTS_DIR="$FREEPI_AGENT_DIR/prompts"

mkdir -p "$FREEPI_SKILLS_DIR" "$FREEPI_PROMPTS_DIR"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_PURPLE='\033[0;35m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

install_skill() {
  local name="$1"
  if [ -d "$SUPERPOWER_DIR/skills/$name" ]; then
    rm -rf "$FREEPI_SKILLS_DIR/$name"
    cp -rf "$SUPERPOWER_DIR/skills/$name" "$FREEPI_SKILLS_DIR/$name"
    echo -e "  ${C_GREEN}✔${C_RESET} Skill aktif di FreePi: ${C_BOLD}$name${C_RESET}"
  else
    echo -e "  ${C_RED}✖${C_RESET} Skill tidak ditemukan: $name"
  fi
}

sync_prompts() {
  if [ -d "$SUPERPOWER_DIR/agents" ]; then
    cp -f "$SUPERPOWER_DIR/agents/"*.md "$FREEPI_PROMPTS_DIR/" 2>/dev/null || true
    local count
    count=$(ls -1 "$FREEPI_PROMPTS_DIR/"*.md 2>/dev/null | wc -l)
    echo -e "${C_GREEN}✅ ${count} Agent Slash-Commands tersinkron ke ~/.free-pi/agent/prompts/${C_RESET}"
    echo -e "${C_DIM}   Di dalam FreePi, ketik /samp-textdraw-fivem-master atau /samp-creator-2026${C_RESET}"
  fi
}

CMD="${1:-list}"
shift || true

case "$CMD" in
  sync-prompts|prompts)
    sync_prompts
    ;;

  samp|samp-modern|fivem)
    echo -e "${C_CYAN}${C_BOLD}🎮 Mengaktifkan Skill Pack: SA-MP & open.mp FiveM-Style 2026 Master (10 Skills)...${C_RESET}"
    for s in \
      samp-mapping-dynamic-objects-pro \
      samp-fivem-oxlib-target-logic \
      samp-fivem-inventory-metadata \
      samp-textdraw-fivem-modern-design \
      samp-textdraw-ui-craft \
      samp-modern-jobs-2026-logic \
      samp-modern-creator-2026 \
      samp-mobile-android-cef-ui \
      samp-streamer-plugin \
      samp-vs-openmp-encyclopedia; do
      install_skill "$s"
    done
    sync_prompts
    ;;

  samp-full)
    echo -e "${C_CYAN}${C_BOLD}🎮 Mengaktifkan Skill Pack: SA-MP & open.mp FULL (30 Skills)...${C_RESET}"
    for dir in "$SUPERPOWER_DIR/skills"/samp-* "$SUPERPOWER_DIR/skills"/openmp-*; do
      [ -d "$dir" ] && install_skill "$(basename "$dir")"
    done
    sync_prompts
    ;;

  web|frontend|antislop)
    echo -e "${C_CYAN}${C_BOLD}🎨 Mengaktifkan Skill Pack: Modern Web + Anti-Slop...${C_RESET}"
    for s in \
      antislop \
      antislop-ui \
      antislop-code \
      frontend-patterns \
      nextjs-turbopack \
      shadcn-radix-headless-craft \
      tailwind-v4-shadcn-system; do
      install_skill "$s"
    done
    sync_prompts
    ;;

  enable|add)
    if [ -z "${1:-}" ]; then
      echo -e "${C_RED}Gunakan: freepi-power pack enable <nama-skill>${C_RESET}"
      exit 1
    fi
    install_skill "$1"
    ;;

  disable|remove|rm)
    if [ -z "${1:-}" ]; then
      echo -e "${C_RED}Gunakan: freepi-power pack disable <nama-skill>${C_RESET}"
      exit 1
    fi
    rm -rf "$FREEPI_SKILLS_DIR/$1"
    echo -e "${C_YELLOW}🗑️  Skill '$1' dinonaktifkan dari ~/.free-pi/agent/skills/${C_RESET}"
    ;;

  clear|reset)
    rm -rf "${FREEPI_SKILLS_DIR:?}"/*
    echo -e "${C_YELLOW}🧹 Semua custom skill di ~/.free-pi/agent/skills/ dibersihkan (hemat token maksimal).${C_RESET}"
    ;;

  list|status|*)
    echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD}🎒 FREEPI-POWER NATIVE SKILLS & PROMPTS STATUS${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"
    ACTIVE_SKILLS=$(ls -1 "$FREEPI_SKILLS_DIR" 2>/dev/null || true)
    ACTIVE_COUNT=$(ls -1 "$FREEPI_SKILLS_DIR" 2>/dev/null | wc -l)
    PROMPT_COUNT=$(ls -1 "$FREEPI_PROMPTS_DIR"/*.md 2>/dev/null | wc -l)
    echo -e "📂 Native Skills Dir : ${C_CYAN}$FREEPI_SKILLS_DIR${C_RESET} (${C_GREEN}${ACTIVE_COUNT} aktif${C_RESET})"
    if [ "$ACTIVE_COUNT" -gt 0 ]; then
      echo "$ACTIVE_SKILLS" | sed 's/^/   • /'
    else
      echo -e "   ${C_DIM}(belum ada pack aktif — jalankan 'freepi-power pack samp')${C_RESET}"
    fi
    echo -e "\n⚡ Slash-Command Prompts: ${C_GREEN}${PROMPT_COUNT} Agents${C_RESET} di ${C_CYAN}$FREEPI_PROMPTS_DIR${C_RESET}"
    echo -e "\n${C_BOLD}PACK TERSEDIA (hemat kredit harian FreePi):${C_RESET}"
    echo -e "  ${C_GREEN}freepi-power pack samp${C_RESET}          Aktifkan 10 skill FiveM-Style 2026 (Mapping MLO, ox_target, ox_lib, ox_inventory, TextDraw FiveM)"
    echo -e "  ${C_GREEN}freepi-power pack samp-full${C_RESET}     Aktifkan seluruh 30 skill SA-MP & open.mp"
    echo -e "  ${C_GREEN}freepi-power pack web${C_RESET}           Aktifkan skill Web Modern + Anti-Slop"
    echo -e "  ${C_GREEN}freepi-power pack enable <nama>${C_RESET} Aktifkan 1 skill tertentu dari 591 katalog"
    echo -e "  ${C_GREEN}freepi-power pack clear${C_RESET}         Kosongkan skill aktif untuk hemat token maksimal\n"
    ;;
esac

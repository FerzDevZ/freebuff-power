#!/usr/bin/env bash
# ==============================================================================
# 🩺 FREEBUFF-POWER & FREEPI-POWER — SA-MP & open.mp Anti-Pattern & Lag Auditor
# ==============================================================================
set -euo pipefail

TARGET_DIR="${1:-.}"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_PURPLE='\033[0;35m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🩺 [SA-MP & open.mp AUDITOR] Deep Code Linter & Anti-Pattern Scanner${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "📁 Memindai direktori target: ${C_BOLD}${TARGET_DIR}${C_RESET}\n"

TOTAL_ISSUES=0
CRITICAL_ISSUES=0
WARNING_ISSUES=0

report_issue() {
  local severity="$1"
  local rule="$2"
  local file="$3"
  local line="$4"
  local snippet="$5"
  local solution="$6"

  TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
  if [ "$severity" = "CRITICAL" ]; then
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
    echo -e "${C_RED}${C_BOLD}[CRITICAL: $rule]${C_RESET}"
  else
    WARNING_ISSUES=$((WARNING_ISSUES + 1))
    echo -e "${C_YELLOW}${C_BOLD}[WARNING: $rule]${C_RESET}"
  fi
  echo -e "  📍 File   : ${C_CYAN}${file}:${line}${C_RESET}"
  echo -e "  🔍 Kode   : \033[2m${snippet}\033[0m"
  echo -e "  💡 Solusi : ${C_GREEN}${solution}${C_RESET}\n"
}

# 1. Pindai Inefficient MAX_PLAYERS Loops
echo -e "${C_PURPLE}🔍 [1/5] Memeriksa inefisiensi loop MAX_PLAYERS...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  report_issue "WARNING" "Inefficient MAX_PLAYERS Loop" "$file" "$line" "$snippet" \
    "Ganti loop lambat for(MAX_PLAYERS) dengan foreach(new i : Player) via <YSI_Data\\y_iterate> untuk O(active)."
done < <(grep -rn -E "for\s*\(\s*new\s+[a-zA-Z0-9_]+\s*(=\s*0)?\s*;\s*[a-zA-Z0-9_]+\s*<\s*MAX_PLAYERS" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 2. Pindai OnPlayerUpdate Lag Sins
echo -e "${C_PURPLE}🔍 [2/5] Memeriksa kejahatan performa di OnPlayerUpdate...${C_RESET}"
# Cari file yang mendefinisikan OnPlayerUpdate dan cari format() atau mysql query
find "$TARGET_DIR" -type f \( -name "*.pwn" -o -name "*.inc" \) 2>/dev/null | while read -r filepath; do
  awk '
    /public[ \t]+OnPlayerUpdate/ { in_update = 1; start_line = NR }
    in_update && /format\s*\(/ {
      print FILENAME ":" NR ":" $0 ":FORMAT_IN_UPDATE"
    }
    in_update && /(mysql_query|mysql_tquery|mysql_pquery)/ {
      print FILENAME ":" NR ":" $0 ":MYSQL_IN_UPDATE"
    }
    in_update && /return/ { in_update = 0 }
  ' "$filepath" 2>/dev/null | while IFS=: read -r f l s typ; do
    if [ "$typ" = "FORMAT_IN_UPDATE" ]; then
      report_issue "CRITICAL" "String Formatting in OnPlayerUpdate" "$f" "$l" "$s" \
        "OnPlayerUpdate dipanggil 30-50x/detik per pemain! Format string di sini akan membuat CPU 100% dan server lag parah. Pindahkan ke timer 1 detik."
    elif [ "$typ" = "MYSQL_IN_UPDATE" ]; then
      report_issue "CRITICAL" "Database Query in OnPlayerUpdate" "$f" "$l" "$s" \
        "Dilarang keras menjalankan query MySQL di OnPlayerUpdate! Ini akan menyebabkan query flood & crash connection pool."
    fi
  done
done

# 3. Pindai Penggunaan strcmp Command Text Kuno
echo -e "${C_PURPLE}🔍 [3/5] Memeriksa command parser kuno (strcmp)...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  report_issue "WARNING" "Legacy strcmp Command Parser" "$file" "$line" "$snippet" \
    "Hindari strcmp di OnPlayerCommandText. Gunakan YCMD:commandname via <YSI_Coding\\y_commands> (30x lebih cepat dan aman)."
done < <(grep -rn -E "strcmp\s*\(\s*cmdtext" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 4. Pindai Potensi SQL Injection (%s pada query)
echo -e "${C_PURPLE}🔍 [4/5] Memeriksa potensi kerentanan SQL Injection...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  report_issue "CRITICAL" "Potential SQL Injection in Query Format" "$file" "$line" "$snippet" \
    "Jangan gunakan format() biasa dengan %s untuk SQL! Gunakan mysql_format(gSQL, query, sizeof(query), \"... '%e' ...\") dengan parameter %e untuk escaping otomatis."
done < <(grep -rn -E "format\s*\(\s*[a-zA-Z0-9_]+\s*,\s*sizeof\s*\([^)]+\)\s*,\s*\"(SELECT|INSERT|UPDATE|DELETE)[^\"]*%s" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 5. Pindai Konfigurasi Plugin Kuno / Bermasalah di open.mp
echo -e "${C_PURPLE}🔍 [5/5] Memeriksa plugin memory-hack tidak kompatibel...${C_RESET}"
for cfg in "server.cfg" "config.json"; do
  cfg_path="$TARGET_DIR/$cfg"
  if [ -f "$cfg_path" ]; then
    if grep -qi "fcnpc" "$cfg_path"; then
      report_issue "CRITICAL" "Incompatible Plugin: FCNPC" "$cfg_path" "1" "fcnpc plugin detected" \
        "FCNPC melakukan direct memory hacking yang menyebabkan segmentation fault pada open.mp. Hapus FCNPC dan gunakan open.mp Native NPC component."
    fi
    if grep -qi "whirlpool" "$cfg_path"; then
      report_issue "WARNING" "Deprecated Plugin: Whirlpool" "$cfg_path" "1" "whirlpool plugin detected" \
        "Whirlpool telah usang. Gunakan samp-bcrypt untuk hashing password asynchronous yang aman terhadap serangan GPU cracking."
    fi
  fi
done

# Rekapitulasi
echo -e "${C_CYAN}========================================================================${C_RESET}"
if [ "$TOTAL_ISSUES" -eq 0 ]; then
  echo -e "${C_GREEN}${C_BOLD}🎉 LUAR BIASA! Tidak ditemukan anti-pattern atau kejahatan lag (100% CLEAN).${C_RESET}"
  echo -e "${C_GREEN}Kode SA-MP / open.mp Anda memenuhi standar arsitektur modern.${C_RESET}"
else
  echo -e "${C_YELLOW}${C_BOLD}📊 HASIL AUDIT:${C_RESET} Ditemukan ${C_BOLD}${TOTAL_ISSUES}${C_RESET} temuan (${C_RED}${CRITICAL_ISSUES} Critical${C_RESET}, ${C_YELLOW}${WARNING_ISSUES} Warnings${C_RESET})."
  echo -e "👉 Jalankan rekomendasi solusi di atas atau minta bantuan agen:"
  echo -e "   ${C_CYAN}freebuff-power spawn samp-legacy-migrator \"perbaiki temuan audit\"${C_RESET}"
fi
echo -e "${C_CYAN}========================================================================${C_RESET}\n"

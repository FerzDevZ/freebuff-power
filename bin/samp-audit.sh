#!/usr/bin/env bash
# ==============================================================================
# 🩺 FREEBUFF-POWER & FREEPI-POWER — SA-MP & open.mp 2026 Anti-Pattern Auditor v2
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
echo -e "${C_YELLOW}${C_BOLD}🩺 [SA-MP & open.mp 2026 AUDITOR v2] 10-Point Modern & FiveM-Style Linter${C_RESET}"
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
echo -e "${C_PURPLE}🔍 [1/10] Memeriksa inefisiensi loop MAX_PLAYERS...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  report_issue "WARNING" "Inefficient MAX_PLAYERS Loop" "$file" "$line" "$snippet" \
    "Ganti loop lambat for(MAX_PLAYERS) dengan foreach(new i : Player) via <YSI_Data\\y_iterate> untuk O(active)."
done < <(grep -rn -E "for\s*\(\s*new\s+[a-zA-Z0-9_]+\s*(=\s*0)?\s*;\s*[a-zA-Z0-9_]+\s*<\s*MAX_PLAYERS" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 2. Pindai OnPlayerUpdate Lag Sins
echo -e "${C_PURPLE}🔍 [2/10] Memeriksa kejahatan performa di OnPlayerUpdate...${C_RESET}"
while IFS= read -r filepath; do
  [ -z "$filepath" ] && continue
  while IFS=: read -r f l s typ; do
    [ -z "$f" ] && continue
    if [ "$typ" = "FORMAT_IN_UPDATE" ]; then
      report_issue "CRITICAL" "String Formatting in OnPlayerUpdate" "$f" "$l" "$s" \
        "OnPlayerUpdate dipanggil 30-50x/detik per pemain! Pindahkan ke y_timers 200ms-1000ms."
    elif [ "$typ" = "MYSQL_IN_UPDATE" ]; then
      report_issue "CRITICAL" "Database Query in OnPlayerUpdate" "$f" "$l" "$s" \
        "Dilarang keras menjalankan query MySQL di OnPlayerUpdate! Menyebabkan query flood & crash."
    elif [ "$typ" = "TD_IN_UPDATE" ]; then
      report_issue "CRITICAL" "TextDraw Spam in OnPlayerUpdate" "$f" "$l" "$s" \
        "Jangan update TextDraw di OnPlayerUpdate! Gunakan timer 150ms-250ms dengan dirty-flag caching."
    fi
  done < <(awk '
    /public[ \t]+OnPlayerUpdate/ { in_update = 1 }
    in_update && /format[ \t]*\(/ { print FILENAME ":" NR ":" $0 ":FORMAT_IN_UPDATE" }
    in_update && /(mysql_query|mysql_tquery|mysql_pquery)/ { print FILENAME ":" NR ":" $0 ":MYSQL_IN_UPDATE" }
    in_update && /(PlayerTextDrawSetString|PlayerTextDrawShow|TextDrawSetString)/ { print FILENAME ":" NR ":" $0 ":TD_IN_UPDATE" }
    in_update && /^[ \t]*return/ { in_update = 0 }
  ' "$filepath" 2>/dev/null || true)
done < <(find "$TARGET_DIR" -type f \( -name "*.pwn" -o -name "*.inc" \) 2>/dev/null || true)

# 3. Pindai Command Parser Kuno (strcmp)
echo -e "${C_PURPLE}🔍 [3/10] Memeriksa command parser kuno (strcmp)...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  report_issue "WARNING" "Legacy strcmp Command Parser" "$file" "$line" "$snippet" \
    "Gunakan YCMD:commandname via <YSI_Coding\\y_commands> atau interaksi [Y]/ox_target FiveM-style."
done < <(grep -rn -E "strcmp\s*\(\s*cmdtext" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 4. Pindai Potensi SQL Injection (%s pada query)
echo -e "${C_PURPLE}🔍 [4/10] Memeriksa potensi kerentanan SQL Injection...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  report_issue "CRITICAL" "Potential SQL Injection in Query Format" "$file" "$line" "$snippet" \
    "Gunakan mysql_format(gSQL, query, sizeof(query), \"... '%e' ...\") dengan %e untuk escaping aman."
done < <(grep -rn -E "format\s*\(\s*[a-zA-Z0-9_]+\s*,\s*sizeof\s*\([^)]+\)\s*,\s*\"(SELECT|INSERT|UPDATE|DELETE)[^\"]*%s" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 5. Pindai Konfigurasi Plugin Kuno / Bermasalah di open.mp
echo -e "${C_PURPLE}🔍 [5/10] Memeriksa plugin memory-hack tidak kompatibel di open.mp...${C_RESET}"
for cfg in "server.cfg" "config.json"; do
  cfg_path="$TARGET_DIR/$cfg"
  if [ -f "$cfg_path" ]; then
    if grep -qi "fcnpc" "$cfg_path"; then
      report_issue "CRITICAL" "Incompatible Plugin: FCNPC" "$cfg_path" "1" "fcnpc plugin detected" \
        "FCNPC menyebabkan segfault di open.mp. Gunakan open.mp Native NPC component."
    fi
    if grep -qi "whirlpool" "$cfg_path"; then
      report_issue "WARNING" "Deprecated Hash: Whirlpool" "$cfg_path" "1" "whirlpool plugin detected" \
        "Upgrade ke samp-bcrypt (async Bcrypt hashing) sesuai standar keamanan 2026."
    fi
    if grep -qiE "\b(ysf|sky)\b" "$cfg_path"; then
      report_issue "CRITICAL" "Memory-Hack Plugin (YSF/SKY)" "$cfg_path" "1" "YSF/SKY detected" \
        "Hapus YSF/SKY. Mayoritas fiturnya sudah tersedia secara native di <open.mp>."
    fi
  fi
done

# 6. Pindai Header Legacy #include <a_samp>
echo -e "${C_PURPLE}🔍 [6/10] Memeriksa penggunaan header legacy <a_samp> vs <open.mp>...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  report_issue "WARNING" "Legacy Include <a_samp>" "$file" "$line" "$snippet" \
    "Migrasi ke #include <open.mp> untuk strict tag safety, const-correctness, dan native open.mp modern."
done < <(grep -rn -E "^[ \t]*#include[ \t]+<a_samp>" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 7. Pindai Pickup Kuno 2012 (Model 1239 / 1274)
echo -e "${C_PURPLE}🔍 [7/10] Memeriksa pola kuno spinning pickup (1239/1274)...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  report_issue "WARNING" "Outdated 2012 Spinning Pickup (1239/1274)" "$file" "$line" "$snippet" \
    "Ganti pickup kuning muter dengan Living Dynamic Actor (CreateDynamicActor) + ox_target / Streamer Dynamic Area [Y] pill!"
done < <(grep -rn -E "Create(Dynamic)?Pickup\s*\(\s*(1239|1274|1318)\b" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 8. Pindai Potensi Salah Format RGBA pada SetDynamicObjectMaterial (Wajib ARGB!)
echo -e "${C_PURPLE}🔍 [8/10] Memeriksa format warna ARGB vs RGBA pada Material Mapping...${C_RESET}"
while IFS=: read -r file line snippet; do
  [ -z "$file" ] && continue
  if ! echo "$snippet" | grep -qE "0xFF[0-9A-Fa-f]{6}"; then
    report_issue "WARNING" "Possible RGBA Color on Material (Requires ARGB)" "$file" "$line" "$snippet" \
      "SetDynamicObjectMaterial & MaterialText memakai 0xAARRGGBB (ARGB), bukan RGBA! Contoh: 0xFF10B981."
  fi
done < <(grep -rn -E "SetDynamicObjectMaterial(Text)?\s*\(.*0x[0-9A-Fa-f]{6}FF\b" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null || true)

# 9. Estimator Batas Pool 256 PlayerTextDraw
echo -e "${C_PURPLE}🔍 [9/10] Menghitung estimasi pool CreatePlayerTextDraw (batas 256/pemain)...${C_RESET}"
PTD_COUNT=$(grep -rn -E "CreatePlayerTextDraw\s*\(" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null | wc -l || echo "0")
if [ "$PTD_COUNT" -gt 200 ]; then
  report_issue "WARNING" "High PlayerTextDraw Count ($PTD_COUNT calls)" "$TARGET_DIR" "1" "CreatePlayerTextDraw total: $PTD_COUNT" \
    "Batas keras engine hanya 256 PlayerTextDraw per pemain! Pindahkan frame statis ke Global TextDraw dan pastikan modal dihancurkan saat ditutup (SafeDestroyPlayerTD)."
fi

# 10. Pindai CreateObject Statis (Batas 1000 Object)
echo -e "${C_PURPLE}🔍 [10/10] Memeriksa penggunaan CreateObject statis (limit 1000)...${C_RESET}"
STATIC_OBJ_COUNT=$(grep -rn -E "\bCreateObject\s*\(" --include="*.pwn" --include="*.inc" "$TARGET_DIR" 2>/dev/null | wc -l || echo "0")
if [ "$STATIC_OBJ_COUNT" -gt 20 ]; then
  report_issue "WARNING" "Static CreateObject Overflow Risk ($STATIC_OBJ_COUNT calls)" "$TARGET_DIR" "1" "CreateObject total: $STATIC_OBJ_COUNT" \
    "Jalankan 'freepi-power samp map-upgrade <file.pwn> --interior' untuk mengonversi ke CreateDynamicObject ber-priority + Streamer_UpdateEx anti-jatuh!"
fi

# Rekapitulasi
echo -e "${C_CYAN}========================================================================${C_RESET}"
if [ "$TOTAL_ISSUES" -eq 0 ]; then
  echo -e "${C_GREEN}${C_BOLD}🎉 LUAR BIASA! Tidak ditemukan anti-pattern kuno atau kejahatan lag (100% CLEAN).${C_RESET}"
  echo -e "${C_GREEN}Kode SA-MP / open.mp Anda memenuhi standar FiveM-Style 2026.${C_RESET}"
else
  echo -e "${C_YELLOW}${C_BOLD}📊 HASIL AUDIT:${C_RESET} Ditemukan ${C_BOLD}${TOTAL_ISSUES}${C_RESET} temuan (${C_RED}${CRITICAL_ISSUES} Critical${C_RESET}, ${C_YELLOW}${WARNING_ISSUES} Warnings${C_RESET})."
  echo -e "👉 Gunakan slash agent di FreePi untuk auto-refactor:"
  echo -e "   ${C_CYAN}/samp-legacy-migrator${C_RESET} | ${C_CYAN}/samp-mapping-mlo-architect${C_RESET} | ${C_CYAN}/samp-textdraw-fivem-master${C_RESET}"
fi
echo -e "${C_CYAN}========================================================================${C_RESET}\n"

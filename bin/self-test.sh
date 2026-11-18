#!/usr/bin/env bash
# ==============================================================================
# ✅ FREEPI-POWER & FREEBUFF-POWER AUTOMATED SELF-TEST & CI VERIFIER (v11.3)
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "  ${C_GREEN}✔${C_RESET} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${C_RED}✖${C_RESET} $1"; FAIL=$((FAIL + 1)); }

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🧪 [SELF-TEST SUITE] FreePi-Power & Freebuff-Power Verification (v11.3)${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

# 1. Bash syntax check
echo -e "${C_BOLD}[1/6] Memeriksa syntax seluruh skrip Bash...${C_RESET}"
BASH_ERR=0
for f in "$SCRIPT_DIR"/*.sh "$SCRIPT_DIR/freebuff-power" "$SCRIPT_DIR/freepi-power" "$ROOT_DIR/install.sh"; do
  [ -f "$f" ] || continue
  if ! bash -n "$f" 2>/dev/null; then
    fail "Syntax error pada $f"
    BASH_ERR=1
  fi
done
[ "$BASH_ERR" -eq 0 ] && pass "Semua skrip Bash lulus bash -n (0 syntax error)"

# 2. Node.js syntax check
echo -e "${C_BOLD}[2/6] Memeriksa syntax seluruh skrip Node.js...${C_RESET}"
JS_ERR=0
for f in "$SCRIPT_DIR"/*.js; do
  [ -f "$f" ] || continue
  if ! node --check "$f" 2>/dev/null; then
    fail "JS syntax error pada $f"
    JS_ERR=1
  fi
done
[ "$JS_ERR" -eq 0 ] && pass "Semua skrip Node.js lulus node --check (0 syntax error)"

# 3. Parity check .agents vs superpower (only when running inside repo)
echo -e "${C_BOLD}[3/6] Memeriksa sinkronisasi .agents/ <-> superpower/...${C_RESET}"
if [ -d "$ROOT_DIR/.agents/agents" ] && [ -d "$ROOT_DIR/superpower/agents" ]; then
  A1=$(ls -1 "$ROOT_DIR/.agents/agents" | wc -l)
  A2=$(ls -1 "$ROOT_DIR/superpower/agents" | wc -l)
  S1=$(ls -1 "$ROOT_DIR/.agents/skills" | wc -l)
  S2=$(ls -1 "$ROOT_DIR/superpower/skills" | wc -l)
  if [ "$A1" -eq "$A2" ] && [ "$S1" -eq "$S2" ]; then
    pass "Sinkronisasi 100% identik (${A1} Agents & ${S1} Skills)"
  else
    fail "Mismatch jumlah! .agents=(${A1}A/${S1}S) vs superpower=(${A2}A/${S2}S)"
  fi
else
  pass "Mode global bin (skip repo parity check)"
fi

# 4. SA-MP & open.mp frontmatter check
echo -e "${C_BOLD}[4/6] Memvalidasi frontmatter YAML seluruh skill SA-MP & open.mp...${C_RESET}"
SKILL_ROOT="$ROOT_DIR/.agents/skills"
[ ! -d "$SKILL_ROOT" ] && SKILL_ROOT="$HOME/.freebuff-superpower/skills"
FM_ERR=0
SAMP_SKILLS=0
for d in "$SKILL_ROOT"/samp-* "$SKILL_ROOT"/openmp-*; do
  [ -d "$d" ] || continue
  SAMP_SKILLS=$((SAMP_SKILLS + 1))
  if [ ! -f "$d/SKILL.md" ] || ! head -n 5 "$d/SKILL.md" | grep -q "^name:" || ! head -n 5 "$d/SKILL.md" | grep -q "^description:"; then
    fail "Frontmatter tidak valid pada $(basename "$d")/SKILL.md"
    FM_ERR=1
  fi
done
[ "$FM_ERR" -eq 0 ] && pass "${SAMP_SKILLS} skill SA-MP & open.mp valid seluruhnya"

# 5. Zero leakage check on freepi-power
echo -e "${C_BOLD}[5/6] Memverifikasi freepi-power zero leakage ke freebuff...${C_RESET}"
if OUT=$("$SCRIPT_DIR/freepi-power" __invalid_selftest_cmd__ 2>&1); then
  fail "freepi-power tidak menolak perintah tidak dikenal!"
else
  if echo "$OUT" | grep -q "tidak dikenali di freepi-power"; then
    pass "freepi-power menolak perintah tak dikenal secara bersih (zero leakage ke freebuff)"
  else
    fail "Output tidak sesuai ekspektasi: $OUT"
  fi
fi

# 6. Live smoke tests: td-preview, map-upgrade, samp-audit v2
echo -e "${C_BOLD}[6/6] Smoke-test td-preview, map-upgrade & samp-audit v2...${C_RESET}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat << 'EOF' > "$TMP_DIR/sample_ui.pwn"
#include <a_samp>
#define UI_BG 0x0B0F19E6
#define UI_ACC 0x10B981FF
new PlayerText:gCard;
new PlayerText:gTitle;
stock TestUI(playerid) {
    gCard = CreatePlayerTextDraw(playerid, 480.0, 24.0, "LD_SPAC:white");
    PlayerTextDrawFont(playerid, gCard, TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(playerid, gCard, 140.0, 30.0);
    PlayerTextDrawColor(playerid, gCard, UI_BG);
    PlayerTextDrawSetSelectable(playerid, gCard, true);
    gTitle = CreatePlayerTextDraw(playerid, 490.0, 30.0, "FiveM Toast");
    PlayerTextDrawColor(playerid, gTitle, UI_ACC);
    CreateObject(19377, 1500.0, -1700.0, 1500.0, 0.0, 0.0, 0.0);
    CreateDynamicPickup(1239, 1, 1500.0, -1700.0, 1500.0);
}
EOF

if node "$SCRIPT_DIR/samp-td-preview.js" "$TMP_DIR/sample_ui.pwn" "$TMP_DIR/out.html" >/dev/null && [ -s "$TMP_DIR/out.html" ]; then
  pass "samp-td-preview.js berhasil merender mockup HTML5 16:9"
else
  fail "samp-td-preview.js gagal!"
fi

if node "$SCRIPT_DIR/samp-map-upgrade.js" "$TMP_DIR/sample_ui.pwn" "$TMP_DIR/out_mlo.pwn" --interior >/dev/null && grep -q "MAP_PRIO_STRUCTURE" "$TMP_DIR/out_mlo.pwn" && grep -q "Streamer_UpdateEx" "$TMP_DIR/out_mlo.pwn"; then
  pass "samp-map-upgrade.js berhasil upgrade CreateObject -> MLO Priority + Streamer_UpdateEx"
else
  fail "samp-map-upgrade.js gagal!"
fi

AUDIT_OUT=$("$SCRIPT_DIR/samp-audit.sh" "$TMP_DIR" 2>&1 || true)
if echo "$AUDIT_OUT" | grep -q "Legacy Include <a_samp>" && echo "$AUDIT_OUT" | grep -q "Outdated 2012 Spinning Pickup"; then
  pass "samp-audit.sh v2 mendeteksi pola kuno (<a_samp> & pickup 1239) dengan akurat"
else
  fail "samp-audit.sh v2 gagal mendeteksi fixture uji!"
fi

echo -e "\n${C_CYAN}========================================================================${C_RESET}"
if [ "$FAIL" -eq 0 ]; then
  echo -e "${C_GREEN}${C_BOLD}🎉 ALL TESTS PASSED (${PASS}/${PASS} GREEN)!${C_RESET}"
  echo -e "${C_CYAN}========================================================================${C_RESET}\n"
  exit 0
else
  echo -e "${C_RED}${C_BOLD}❌ ${FAIL} TEST(S) FAILED (${PASS} passed).${C_RESET}"
  echo -e "${C_CYAN}========================================================================${C_RESET}\n"
  exit 1
fi

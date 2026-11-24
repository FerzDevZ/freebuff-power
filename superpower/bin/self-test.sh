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
echo -e "${C_BOLD}[1/9] Memeriksa syntax seluruh skrip Bash...${C_RESET}"
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
echo -e "${C_BOLD}[2/9] Memeriksa syntax seluruh skrip Node.js...${C_RESET}"
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
echo -e "${C_BOLD}[3/9] Memeriksa sinkronisasi .agents/ <-> superpower/...${C_RESET}"
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
echo -e "${C_BOLD}[4/9] Memvalidasi frontmatter YAML seluruh skill SA-MP & open.mp...${C_RESET}"
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
echo -e "${C_BOLD}[5/9] Memverifikasi freepi-power zero leakage ke freebuff...${C_RESET}"
if OUT=$("$SCRIPT_DIR/freepi-power" __invalid_selftest_cmd__ 2>&1); then
  fail "freepi-power tidak menolak perintah tidak dikenal!"
else
  if echo "$OUT" | grep -q "tidak dikenali di freepi-power"; then
    pass "freepi-power menolak perintah tak dikenal secara bersih (zero leakage ke freebuff)"
  else
    fail "Output tidak sesuai ekspektasi: $OUT"
  fi
fi

# 6. Pawn fixture compile gate — proves the shipped .inc files still build.
# Skips loudly (never silently passes) when the toolchain is absent.
echo -e "${C_BOLD}[6/9] Mengompilasi seluruh fixture Pawn (.inc) di dua target...${C_RESET}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PAWNCC_BIN="${PAWNCC:-$(command -v pawncc 2>/dev/null || true)}"
OMP_STDLIB="${OMP_STDLIB:-}"
SAMP_STDLIB="${SAMP_STDLIB:-}"
if [ -z "$OMP_STDLIB" ]; then
  for candidate in "$HOME/samp-sdk/omp-stdlib" "$ROOT_DIR/.sdk/omp-stdlib"; do
    [ -d "$candidate" ] && OMP_STDLIB="$candidate" && break
  done
fi
if [ -z "$SAMP_STDLIB" ]; then
  for candidate in "$HOME/samp-sdk/samp-stdlib" "/tmp/sampstdlib"; do
    [ -d "$candidate" ] && SAMP_STDLIB="$candidate" && break
  done
fi

PAWN_LAST_REASON=""
pawn_build() {
  local src="$1" target="$2" label="${3:-}" out log includes=() warns=0
  [ -n "$label" ] || label="$(basename "${src%.pwn}")"
  out="$TMP_DIR/$label.$target.amx"
  log="$TMP_DIR/$label.$target.log"

  includes+=("-i$(dirname "$src")")
  if [ "$target" = "legacy" ]; then
    # Legacy stdlib first so <a_samp> resolves to 0.3.7, not omp's wrapper.
    [ -n "$SAMP_STDLIB" ] && includes+=("-i$SAMP_STDLIB")
    [ -n "$OMP_STDLIB" ] && includes+=("-i$OMP_STDLIB")
  else
    [ -n "$OMP_STDLIB" ] && includes+=("-i$OMP_STDLIB")
  fi

  if ! "$PAWNCC_BIN" "$src" "${includes[@]}" -d3 -o"$out" >"$log" 2>&1; then
    PAWN_LAST_REASON="$(grep -m1 -E 'error' "$log" | sed 's/^\.\///' || echo 'kompilasi gagal')"
    return 1
  fi
  if [ ! -s "$out" ]; then
    PAWN_LAST_REASON="artifact .amx tidak dihasilkan"
    return 1
  fi
  warns="$(grep -c 'warning' "$log" || true)"
  if [ "${warns:-0}" -gt 0 ]; then
    PAWN_LAST_REASON="$warns warning: $(grep -m1 'warning' "$log" | sed 's/^\.\///')"
    return 1
  fi
  return 0
}

if [ -z "$PAWNCC_BIN" ]; then
  pass "SKIP: pawncc tidak ditemukan — fixture Pawn TIDAK dikompilasi (set PAWNCC=/path/pawncc)"
elif [ -z "$OMP_STDLIB" ] && [ -z "$SAMP_STDLIB" ]; then
  pass "SKIP: stdlib Pawn tidak ditemukan — fixture TIDAK dikompilasi (set OMP_STDLIB / SAMP_STDLIB)"
else
  PAWN_FAILED=0
  LEGACY_OK=0
  PAWN_SUMMARY=""
  while IFS= read -r fixture; do
    [ -f "$fixture" ] || continue
    name="$(basename "$fixture" .pwn)"
    case "$name" in *_omp) continue ;; esac

    omp_src="${fixture%.pwn}_omp.pwn"
    [ -f "$omp_src" ] || omp_src="$fixture"
    row="$name"

    if [ -n "$OMP_STDLIB" ]; then
      if pawn_build "$omp_src" omp "$name"; then
        row="$row open.mp=ok"
      else
        row="$row open.mp=FAIL"
        fail "$name [open.mp] $PAWN_LAST_REASON"
        PAWN_FAILED=1
      fi
    else
      row="$row open.mp=skip"
    fi

    # A fixture that includes <open.mp>/<omp_*> and has no <a_samp> path is not a
    # legacy fixture. Compiling it with the legacy include order proves nothing
    # (omp-stdlib is on the path), so label it instead of claiming a pass.
    openmp_only=0
    if grep -qE '^[[:space:]]*#[[:space:]]*include[[:space:]]*<(open\.mp|omp_[a-z_]+)>' "$fixture" \
       && ! grep -qE '^[[:space:]]*#[[:space:]]*include[[:space:]]*<a_samp>' "$fixture"; then
      openmp_only=1
    fi

    if [ "$openmp_only" -eq 1 ]; then
      row="$row legacy=skip(open.mp-only)"
    elif [ -n "$SAMP_STDLIB" ]; then
      if pawn_build "$fixture" legacy "$name"; then
        row="$row legacy=ok"
        LEGACY_OK=$((LEGACY_OK + 1))
      else
        row="$row legacy=FAIL"
        fail "$name [legacy] $PAWN_LAST_REASON"
        PAWN_FAILED=1
      fi
    else
      row="$row legacy=skip"
    fi

    PAWN_SUMMARY="$PAWN_SUMMARY\n    $row"
  done < <(find "$ROOT_DIR/.agents/skills" -path '*/resources/*.pwn' | sort)

  if [ -z "$PAWN_SUMMARY" ]; then
    fail "Tidak ada fixture Pawn yang ditemukan — gate tidak membuktikan apa pun"
  elif [ "$PAWN_FAILED" -eq 0 ]; then
    echo -e "$PAWN_SUMMARY"
    if [ -n "$SAMP_STDLIB" ] && [ "$LEGACY_OK" -eq 0 ]; then
      fail "Tidak ada fixture yang benar-benar dikompilasi di target legacy — stage 6 tidak membuktikan kompatibilitas 0.3.7"
    else
      pass "Semua fixture Pawn terkompilasi dengan 0 warning di target yang tersedia (${LEGACY_OK} benar-benar legacy)"
    fi
  fi
fi

# 7. Runtime suite gate — actually executes the compiled assertion scripts.
# Runs only fixtures marked `// @runtime-suite`; skips loudly without a server.
echo -e "${C_BOLD}[7/9] Menjalankan suite assertion di omp-server...${C_RESET}"

OMP_SERVER_BIN="${OMP_SERVER:-}"
if [ -n "$OMP_SERVER_BIN" ] && [ -d "$OMP_SERVER_BIN" ]; then
  OMP_SERVER_BIN="$OMP_SERVER_BIN/omp-server"
fi
if [ -z "$OMP_SERVER_BIN" ]; then
  OMP_SERVER_BIN="$(command -v omp-server 2>/dev/null || true)"
fi
if [ -z "$OMP_SERVER_BIN" ] && [ -x "$HOME/samp-sdk/openmp/Server/omp-server" ]; then
  OMP_SERVER_BIN="$HOME/samp-sdk/openmp/Server/omp-server"
fi

OMP_COMPONENTS_DIR="${OMP_COMPONENTS:-}"
if [ -z "$OMP_COMPONENTS_DIR" ] && [ -n "$OMP_SERVER_BIN" ]; then
  OMP_COMPONENTS_DIR="$(cd "$(dirname "$OMP_SERVER_BIN")" 2>/dev/null && pwd)/components"
fi

if [ -z "$OMP_SERVER_BIN" ] || [ ! -x "$OMP_SERVER_BIN" ]; then
  pass "SKIP: omp-server tidak tersedia — suite TIDAK dijalankan (set OMP_SERVER=/path/omp-server)"
elif [ ! -d "$OMP_COMPONENTS_DIR" ]; then
  pass "SKIP: komponen omp-server tidak ditemukan — suite TIDAK dijalankan (set OMP_COMPONENTS=...)"
else
  RUN_DIR="$TMP_DIR/runtime"
  mkdir -p "$RUN_DIR/components" "$RUN_DIR/gamemodes"
  cp "$OMP_SERVER_BIN" "$RUN_DIR/omp-server"
  for so in "$OMP_COMPONENTS_DIR"/*.so; do
    [ -e "$so" ] && ln -sf "$so" "$RUN_DIR/components/$(basename "$so")"
  done

  RUNTIME_FAILED=0
  RUNTIME_RAN=0
  RUNTIME_PORT=7820
  RUNTIME_SUMMARY=""
  SUITE_TIMEOUT="${SUITE_TIMEOUT:-10}"

  while IFS= read -r fixture; do
    grep -q '// @runtime-suite' "$fixture" || continue
    name="$(basename "$fixture" .pwn)"
    amx="$TMP_DIR/$name.omp.amx"

    if [ ! -s "$amx" ]; then
      RUNTIME_SUMMARY="$RUNTIME_SUMMARY\n    $name skipped=belum-terkompilasi"
      continue
    fi

    needs_http=0
    if grep -q '// @runtime-needs: http' "$fixture"; then needs_http=1; fi

    http_pid=""
    if [ "$needs_http" -eq 1 ]; then
      if ! command -v python3 >/dev/null 2>&1; then
        RUNTIME_SUMMARY="$RUNTIME_SUMMARY\n    $name skipped=python3-tidak-ada"
        continue
      fi

      HTTP_ROOT="$TMP_DIR/http-$name"
      rm -rf "$HTTP_ROOT" && mkdir -p "$HTTP_ROOT"
      cp "$(dirname "$fixture")/http_fixture.json" "$HTTP_ROOT/http-fixture.json"

      mkdir -p "$RUN_DIR/scriptfiles"
      http_port=$((RUNTIME_PORT + 100))
      printf '%d' "$http_port" > "$RUN_DIR/scriptfiles/http_port.txt"

      ( cd "$HTTP_ROOT" && exec python3 -m http.server "$http_port" --bind 127.0.0.1 ) \
        > "$TMP_DIR/http-server.log" 2>&1 < /dev/null &
      http_pid=$!
      sleep 0.7

      if ! kill -0 "$http_pid" 2>/dev/null; then
        fail "$name [runtime] server HTTP lokal gagal start di port $http_port"
        RUNTIME_FAILED=1
        http_pid=""
        continue
      fi
    fi

    cp "$amx" "$RUN_DIR/gamemodes/suite.amx"
    cat > "$RUN_DIR/config.json" <<JSON
{
  "name": "$name-suite",
  "announce": false,
  "pawn": { "main_scripts": ["suite 1"] },
  "network": { "port": $RUNTIME_PORT },
  "rcon": { "password": "selftest" },
  "logging": { "log_echo": true }
}
JSON
    : > "$RUN_DIR/suite.log"

    # stdin must be closed: the server would otherwise consume the fixture list pipe.
    ( cd "$RUN_DIR" && exec ./omp-server ) > "$RUN_DIR/suite.log" 2>&1 < /dev/null &
    server_pid=$!

    waited=0
    limit=$((SUITE_TIMEOUT * 10))
    while [ "$waited" -lt "$limit" ]; do
      grep -Eq '([0-9]+) checks, ([0-9]+) failed|failures=[0-9]+' "$RUN_DIR/suite.log" && break
      sleep 0.1
      waited=$((waited + 1))
    done

    kill -TERM "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true

    if [ -n "$http_pid" ]; then
      kill -TERM "$http_pid" 2>/dev/null || true
      wait "$http_pid" 2>/dev/null || true
    fi

    verdict="$(grep -E '([0-9]+) checks, ([0-9]+) failed|failures=[0-9]+' "$RUN_DIR/suite.log" | tail -1)"
    if [ -z "$verdict" ]; then
      fail "$name [runtime] tidak menghasilkan verdict dalam ${SUITE_TIMEOUT}s"
      RUNTIME_FAILED=1
    else
      failures="$(echo "$verdict" | sed -E 's/.* ([0-9]+) failed.*/\1/; s/.*failures=([0-9]+).*/\1/')"
      verdict="$(echo "$verdict" | sed -E 's/^.*\] //')"
      if [ "${failures:-1}" -eq 0 ]; then
        RUNTIME_RAN=$((RUNTIME_RAN + 1))
        RUNTIME_SUMMARY="$RUNTIME_SUMMARY\n    $name $verdict"
      else
        fail "$name [runtime] $verdict"
        RUNTIME_FAILED=1
      fi
    fi

    RUNTIME_PORT=$((RUNTIME_PORT + 1))
  done < <(find "$ROOT_DIR/.agents/skills" -path '*/resources/*.pwn' | sort)

  if [ "$RUNTIME_FAILED" -eq 0 ] && [ "$RUNTIME_RAN" -gt 0 ]; then
    echo -e "$RUNTIME_SUMMARY"
    pass "$RUNTIME_RAN suite assertion dieksekusi di omp-server, 0 kegagalan"
  elif [ "$RUNTIME_RAN" -eq 0 ]; then
    fail "Tidak ada fixture bertanda @runtime-suite yang dieksekusi — gate tidak membuktikan apa pun"
  fi
fi

# 8. Live smoke tests: td-preview, map-upgrade, samp-audit v2
echo -e "${C_BOLD}[8/9] Smoke-test td-preview, map-upgrade & samp-audit v2...${C_RESET}"

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

# 9. Target detection: legacy vs open.mp
 echo -e "${C_BOLD}[9/9] Deteksi target, audit klaim native & cakupan fixture...${C_RESET}"

 DETECT_DIR="$ROOT_DIR/.agents/skills/samp-vs-openmp-encyclopedia/fixtures"
 if node "$SCRIPT_DIR/samp-detect.test.js" >"$TMP_DIR/detect.log" 2>&1; then
   pass "$(cat "$TMP_DIR/detect.log")"
 else
   fail "samp-detect.test.js gagal: $(tail -3 "$TMP_DIR/detect.log" | tr '\n' ' ')"
 fi

 if [ -n "$PAWNCC_BIN" ] && [ -n "$SAMP_STDLIB" ]; then
   if pawn_build "$DETECT_DIR/legacy_min.pwn" legacy detect_legacy; then
     pass "fixture legacy_min.pwn terkompilasi di target 0.3.7 (0 warning)"
   else
     fail "legacy_min.pwn: $PAWN_LAST_REASON"
   fi
 else
   pass "SKIP: pawncc atau stdlib legacy tidak ada — fixture legacy tidak dikompilasi"
 fi

 if [ -n "$PAWNCC_BIN" ] && [ -n "$OMP_STDLIB" ]; then
   DETECT_OK=0
   for fixture in modern_min compat_min; do
     if pawn_build "$DETECT_DIR/$fixture.pwn" openmp "detect_$fixture"; then
       DETECT_OK=$((DETECT_OK + 1))
     else
       fail "$fixture.pwn: $PAWN_LAST_REASON"
     fi
   done
   [ "$DETECT_OK" -eq 2 ] && pass "fixture modern_min & compat_min terkompilasi di open.mp (0 warning)"
 else
   pass "SKIP: pawncc atau stdlib open.mp tidak ada — fixture modern tidak dikompilasi"
 fi

 if [ -n "$SAMP_STDLIB" ] && [ -n "$OMP_STDLIB" ]; then
   if node "$SCRIPT_DIR/native-parity.js" --legacy "$SAMP_STDLIB" --modern "$OMP_STDLIB" \
        --json "$TMP_DIR/parity.json" >"$TMP_DIR/parity.log" 2>&1; then
     MATRIX="$(node -e "const j=require('$TMP_DIR/parity.json'); console.log('modernOnly='+j.counts.modernOnly+' legacyOnly='+j.counts.legacyOnly+' changed='+j.counts.changed+' unverified='+j.counts.unverified)")"
     if [ -s "$ROOT_DIR/bin/data/native-ownership.json" ]; then
       pass "matriks paritas dihitung ulang: $MATRIX (data committed terbaca)"
     else
       fail "bin/data/native-ownership.json kosong — jalankan bin/native-parity.js"
     fi
   else
     fail "native-parity.js gagal: $(tail -2 "$TMP_DIR/parity.log" | tr '\n' ' ')"
   fi
 else
   pass "SKIP: kedua stdlib tidak tersedia — matriks paritas tidak dihitung"
 fi

 if node "$SCRIPT_DIR/samp-claim-audit.js" >"$TMP_DIR/claims.log" 2>&1; then
   if grep -q 'tidak ada klaim' "$TMP_DIR/claims.log"; then
     pass "audit klaim native: tidak ada yang bertentangan dengan matriks"
   else
     pass "audit klaim native: 0 error ($(grep -c 'WARNING' "$TMP_DIR/claims.log" || true) warning plugin/include)"
   fi
 else
   fail "klaim native salah: $(grep -m2 'ERROR' "$TMP_DIR/claims.log" | tr '\n' ' ')"
 fi

 node "$SCRIPT_DIR/samp-detect.js" "$ROOT_DIR/.agents/skills" --json >"$TMP_DIR/skills-detect.json" 2>"$TMP_DIR/skills-detect.err"
 DETECT_ERRORS="$(node -e "const j=require('$TMP_DIR/skills-detect.json'); console.log(j.files.flatMap(f=>f.findings).filter(x=>x.severity==='error').length)" 2>/dev/null || echo -1)"
 if [ "$DETECT_ERRORS" = "0" ]; then
   pass "sapuan detektor seluruh skill: 0 error target (MIXED/legacy-vs-modern bersih)"
 else
   fail "detektor menemukan $DETECT_ERRORS error di .agents/skills — lihat node bin/samp-detect.js .agents/skills"
 fi

 if node "$SCRIPT_DIR/samp-lint.test.js" >"$TMP_DIR/lint-test.log" 2>&1; then
   pass "$(cat "$TMP_DIR/lint-test.log")"
 else
   fail "samp-lint.test.js gagal: $(tail -3 "$TMP_DIR/lint-test.log" | tr '\n' ' ')"
 fi

 if node "$SCRIPT_DIR/samp-lint.js" "$ROOT_DIR/.agents/skills" --fail-on=error >"$TMP_DIR/lint-scan.log" 2>&1; then
   pass "lint keamanan: $(tail -1 "$TMP_DIR/lint-scan.log")"
 else
   fail "lint keamanan menemukan error: $(tail -3 "$TMP_DIR/lint-scan.log" | tr '\n' ' ')"
 fi

 if node "$SCRIPT_DIR/samp-agent-evals.js" >"$TMP_DIR/evals.log" 2>&1; then
   pass "eval keputusan agent: $(grep -m1 'mode=' "$TMP_DIR/evals.log")"
 else
   fail "eval keputusan agent di bawah ambang: $(tail -3 "$TMP_DIR/evals.log" | tr '\n' ' ')"
 fi

 if node "$SCRIPT_DIR/skill-coverage.js" >"$TMP_DIR/coverage.log" 2>&1; then
   pass "$(grep -m1 'cakupan:' "$TMP_DIR/coverage.log")"
 else
   fail "cakupan fixture regresi: $(grep -m3 'REGRESI\|hilang' "$TMP_DIR/coverage.log" | tr '\n' ' ')"
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

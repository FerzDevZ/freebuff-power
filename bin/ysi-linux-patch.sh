#!/usr/bin/env bash
# YSI 5 ships its include graph with Windows separators:
#   #include "YSI_Data\y_iterate\y_iterate"
# pawncc on Linux treats the backslash as a literal file-name character and dies
# with `fatal error 100: cannot read from file`. This script makes a project-local
# copy of the package with every include path forward-slashed, leaving the global
# sampctl package untouched, then (with --verify) proves y_iterate actually builds.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR=""
TARGET_DIR="$ROOT_DIR/.sdk/ysi"
VERIFY=0

usage() {
  cat <<'USAGE'
Usage: bin/ysi-linux-patch.sh [options]

  --source DIR   YSI package to read      (default: auto-detect sampctl install)
  --target DIR   Patched copy to write    (default: <repo>/.sdk/ysi)
  --verify       Compile a y_iterate probe against the patched copy
  -h, --help     This message
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --source) SOURCE_DIR="${2:-}"; shift 2 ;;
    --target) TARGET_DIR="${2:-}"; shift 2 ;;
    --verify) VERIFY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ -z "$SOURCE_DIR" ]; then
  for candidate in \
    "$HOME/.config/sampctl/packages/github.com/pawn-lang/YSI-Includes/default" \
    "$ROOT_DIR/.sdk/ysi-src" \
    "$HOME/samp-sdk/YSI-Includes"; do
    if [ -f "$candidate/YSI_Data/y_iterate.inc" ]; then SOURCE_DIR="$candidate"; break; fi
  done
fi
if [ -z "$SOURCE_DIR" ] || [ ! -f "$SOURCE_DIR/YSI_Data/y_iterate.inc" ]; then
  echo "error: YSI package not found (pass --source DIR)" >&2
  exit 1
fi

case "$TARGET_DIR" in
  "$ROOT_DIR"/*) ;;
  *) echo "error: --target must live inside $ROOT_DIR (got $TARGET_DIR)" >&2; exit 1 ;;
esac
if [ "$SOURCE_DIR" = "$TARGET_DIR" ]; then
  echo "error: --source and --target are the same directory" >&2
  exit 1
fi

echo "source : $SOURCE_DIR"
echo "target : $TARGET_DIR"

rm -rf "$TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR")"
cp -r "$SOURCE_DIR" "$TARGET_DIR"

# Only the delimiter interior is rewritten, so trailing comments and any
# backslash outside an include path are left exactly as upstream wrote them.
patched=0
while IFS= read -r -d '' inc; do
  before="$(md5sum "$inc")"
  perl -i -pe '
    if (/^(\s*#\s*(?:try)?include\s*)([<"])([^>"]*)([>"])(.*)$/) {
      my ($head, $open, $path, $close, $tail) = ($1, $2, $3, $4, $5);
      $path =~ s{\\}{/}g;
      $_ = "$head$open$path$close$tail\n";
    }
  ' "$inc"
  after="$(md5sum "$inc")"
  [ "$before" = "$after" ] || patched=$((patched + 1))
done < <(find "$TARGET_DIR" -name '*.inc' -print0)

echo "patched: $patched .inc file(s)"

remaining="$({ grep -rlE '^[[:space:]]*#[[:space:]]*(try)?include[[:space:]]*[<"][^>"]*\\' "$TARGET_DIR" --include='*.inc' || true; } | wc -l)"
if [ "$remaining" -ne 0 ]; then
  echo "error: $remaining file(s) still carry backslash include paths" >&2
  exit 1
fi
echo "verify : 0 backslash include paths left"

if [ "$VERIFY" -eq 0 ]; then
  echo "done   : add -i$TARGET_DIR to pawncc; rerun with --verify to compile the probe"
  exit 0
fi

PAWNCC_BIN="${PAWNCC:-$(command -v pawncc 2>/dev/null || true)}"
if [ -z "$PAWNCC_BIN" ]; then
  echo "error: --verify needs pawncc (set PAWNCC=/path/pawncc)" >&2
  exit 1
fi
# y_addressof needs Zeex/amx_assembly (`addressof_light`) on the include path.
# It is a separate package, so a patched YSI tree alone still reports error 111.
AMX_ASSEMBLY="${AMX_ASSEMBLY:-}"
if [ -z "$AMX_ASSEMBLY" ]; then
  for candidate in \
    "$HOME/.config/sampctl/packages/github.com/Zeex/amx_assembly/default" \
    "$HOME/.config/sampctl/packages/github.com/zeex/amx_assembly/default" \
    "$ROOT_DIR/.sdk/amx_assembly"; do
    if [ -f "$candidate/addressof_light.inc" ]; then AMX_ASSEMBLY="$candidate"; break; fi
  done
fi
if [ -z "$AMX_ASSEMBLY" ]; then
  echo "error: amx_assembly not found — y_addressof needs addressof_light.inc (set AMX_ASSEMBLY=DIR)" >&2
  echo "       fetch: https://github.com/Zeex/amx_assembly/archive/refs/heads/master.zip" >&2
  exit 1
fi

echo "amx_as : $AMX_ASSEMBLY"

OMP_STDLIB="${OMP_STDLIB:-}"
if [ -z "$OMP_STDLIB" ]; then
  for candidate in "$HOME/samp-sdk/omp-stdlib" "$ROOT_DIR/.sdk/omp-stdlib"; do
    if [ -d "$candidate" ]; then OMP_STDLIB="$candidate"; break; fi
  done
fi
if [ -z "$OMP_STDLIB" ]; then
  echo "error: --verify needs the open.mp stdlib (set OMP_STDLIB=DIR)" >&2
  exit 1
fi

probe_dir="$(mktemp -d)"
trap 'rm -rf "$probe_dir"' EXIT
cat > "$probe_dir/ysi_probe.pwn" <<'PAWN'
#include <open.mp>
#include <YSI_Data/y_iterate>

new Iterator:ProbePlayers<MAX_PLAYERS>;

public OnGameModeInit()
{
    Iter_Add(ProbePlayers, 0);
    Iter_Add(ProbePlayers, 1);
    foreach (new playerid : ProbePlayers)
    {
        printf("probe player %d", playerid);
    }
    return 1;
}
PAWN

log="$probe_dir/probe.log"
# YSI re-enables semicolons with a #pragma, which the compiler reports as
# warning 237. Pass -;+ so the pragma has nothing to fix and the build is clean.
if ! "$PAWNCC_BIN" "$probe_dir/ysi_probe.pwn" -i"$TARGET_DIR" -i"$AMX_ASSEMBLY" -i"$OMP_STDLIB" -d3 '-;+' -o"$probe_dir/ysi_probe.amx" >"$log" 2>&1; then
  echo "error: y_iterate probe failed to compile" >&2
  grep -v 'ld\.so' "$log" | head -20 >&2
  exit 1
fi
warns="$(grep -c 'warning' "$log" || true)"
if [ "${warns:-0}" -gt 0 ]; then
  echo "error: $warns warning(s) in the y_iterate probe — a warning is a failure here" >&2
  grep -v 'ld\.so' "$log" | head -20 >&2
  exit 1
fi
if [ ! -s "$probe_dir/ysi_probe.amx" ]; then
  echo "error: probe produced no .amx" >&2
  exit 1
fi

echo "verify : y_iterate probe compiled clean ($(wc -c < "$probe_dir/ysi_probe.amx") bytes, 0 warning)"

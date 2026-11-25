#!/usr/bin/env bash
# Make the YSI 5 dependency available locally without manual downloads.
# If it is already present (global sampctl cache or the project's .sdk/), this
# script does nothing but report. Otherwise it uses `sampctl get` to fetch both
# YSI and Zeex/amx_assembly, then (unless --no-patch) runs
# bin/ysi-linux-patch.sh --verify so the result is actually buildable.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL=0
PATCH=1

usage() {
  cat <<'USAGE'
Usage: bin/ysi-ensure.sh [options]

  --global      Install into ~/.config/sampctl/packages (shared cache)
                instead of <repo>/.sdk
  --no-patch    Skip bin/ysi-linux-patch.sh --verify afterwards
  -h, --help    This message
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --global) GLOBAL=1; shift ;;
    --no-patch) PATCH=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [ "$GLOBAL" -eq 1 ]; then
  YSI_DIR="$HOME/.config/sampctl/packages/github.com/pawn-lang/YSI-Includes/default"
  AMX_DIR="$HOME/.config/sampctl/packages/github.com/Zeex/amx_assembly/default"
else
  YSI_DIR="$ROOT_DIR/.sdk/ysi-src"
  AMX_DIR="$ROOT_DIR/.sdk/amx_assembly"
fi

YSI_PRESENT=0
AMX_PRESENT=0
[ -f "$YSI_DIR/YSI_Data/y_iterate.inc" ] && YSI_PRESENT=1
[ -f "$AMX_DIR/addressof_light.inc" ] && AMX_PRESENT=1

if [ "$YSI_PRESENT" -eq 1 ] && [ "$AMX_PRESENT" -eq 1 ]; then
  echo "YSI already present:"
  echo "  ysi : $YSI_DIR"
  echo "  amx : $AMX_DIR"
  if [ "$PATCH" -eq 1 ]; then
    exec "$ROOT_DIR/bin/ysi-linux-patch.sh" --verify
  fi
  exit 0
fi

SAMPCTL_BIN="${SAMPCTL:-$(command -v sampctl 2>/dev/null || true)}"
if [ -z "$SAMPCTL_BIN" ]; then
  echo "error: sampctl not found — install it first (see https://github.com/Southclaws/sampctl)" >&2
  exit 1
fi

if [ "$YSI_PRESENT" -eq 0 ]; then
  echo "fetching YSI-Includes via sampctl into $YSI_DIR ..."
  mkdir -p "$(dirname "$YSI_DIR")"
  if ! "$SAMPCTL_BIN" get github.com/pawn-lang/YSI-Includes "$YSI_DIR" --bare; then
    echo "error: sampctl get YSI-Includes failed" >&2
    exit 1
  fi
  if [ ! -f "$YSI_DIR/YSI_Data/y_iterate.inc" ]; then
    echo "error: YSI download did not produce YSI_Data/y_iterate.inc" >&2
    exit 1
  fi
  echo "installed YSI: $YSI_DIR"
fi

if [ "$AMX_PRESENT" -eq 0 ]; then
  echo "fetching Zeex/amx_assembly via sampctl into $AMX_DIR ..."
  mkdir -p "$(dirname "$AMX_DIR")"
  if ! "$SAMPCTL_BIN" get github.com/Zeex/amx_assembly "$AMX_DIR" --bare; then
    echo "error: sampctl get amx_assembly failed" >&2
    exit 1
  fi
  if [ ! -f "$AMX_DIR/addressof_light.inc" ]; then
    echo "error: amx_assembly download did not produce addressof_light.inc" >&2
    exit 1
  fi
  echo "installed amx_assembly: $AMX_DIR"
fi

if [ "$PATCH" -eq 1 ]; then
  exec "$ROOT_DIR/bin/ysi-linux-patch.sh" --verify
fi
echo "done: YSI is present (run bin/ysi-linux-patch.sh --verify to make it buildable)"

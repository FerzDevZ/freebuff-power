#!/usr/bin/env bash
# ==============================================================================
# 🚀 FREEBUFF-POWER SUB-AGENT SPAWNER
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

AGENT="${1:-}"
TASK="${2:-}"

if [ -z "$AGENT" ]; then
  echo "Penggunaan: freebuff-power spawn <agent-name> [task description]"
  exit 1
fi

"$SCRIPT_DIR/init.sh" . >/dev/null 2>&1 || true

AGENT_FILE=".freebuff/agents/${AGENT}.md"
if [ ! -f "$AGENT_FILE" ]; then
  AGENT_FILE="$HOME/.freebuff-superpower/.freebuff/agents/${AGENT}.md"
fi

echo -e "\033[0;36m\033[1m🚀 Meluncurkan Freebuff dengan Sub-Agent: @$AGENT\033[0m\n"

if [ -f "$AGENT_FILE" ]; then
  PROMPT="[System: You are operating under the identity and strict SOP of @$AGENT] ${TASK}"
  exec "$SCRIPT_DIR/run.sh" "$PROMPT"
else
  exec "$SCRIPT_DIR/run.sh" "${TASK}"
fi

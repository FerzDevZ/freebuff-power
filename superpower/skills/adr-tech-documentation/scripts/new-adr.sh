#!/usr/bin/env bash
# Generates a numbered ADR file

set -euo pipefail

TITLE="${1:-New Architecture Decision}"
DATE=$(date +%Y-%m-%d)
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-')

DOCS_DIR="docs/adr"
mkdir -p "$DOCS_DIR"

COUNT=$(find "$DOCS_DIR" -name "*.md" | wc -l)
NEXT_NUM=$(printf "%04d" $((COUNT + 1)))
FILENAME="$DOCS_DIR/adr-$NEXT_NUM-$SLUG.md"

cat <<EOF > "$FILENAME"
# ADR-$NEXT_NUM: $TITLE

- **Status**: Proposed
- **Date**: $DATE

## Context
Describe the context and problem here.

## Decision
Chosen architecture and technical rationale.

## Consequences
- Positive:
- Negative / Trade-offs:
EOF

echo "✅ Created new ADR: $FILENAME"

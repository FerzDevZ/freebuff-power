#!/usr/bin/env bash
# Scaffolds a new Antigravity skill directory structure

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: scaffold-skill.sh <skill-name> <short-description>"
  exit 1
fi

SKILL_NAME="$1"
SKILL_DESC="$2"
TARGET_DIR="skills/$SKILL_NAME"

if [ -d "$TARGET_DIR" ]; then
  echo "Error: Skill directory $TARGET_DIR already exists."
  exit 1
fi

mkdir -p "$TARGET_DIR"/{references,scripts,resources,examples}

cat <<EOF > "$TARGET_DIR/SKILL.md"
---
name: $SKILL_NAME
description: >-
  $SKILL_DESC
---

# $SKILL_NAME

Overview and purpose of this skill.

## 📋 Action Workflow
1. Step 1
2. Step 2
EOF

echo "✅ Skill $SKILL_NAME created successfully at $TARGET_DIR"

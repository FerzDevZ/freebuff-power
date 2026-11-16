#!/bin/bash
set -e
if [ -f ".opencode/MEMORY.md" ]; then echo "MEMORY exists: .opencode/MEMORY.md"; exit 0; fi
mkdir -p .opencode
SLUG=$(basename "$(pwd)" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
DATE=$(date +%Y-%m-%d)
DATETIME=$(date +"%Y-%m-%d %H:%M")
cat > .opencode/MEMORY.md << MEM
# MEMORY — $SLUG

> Auto-created by programmer (memory-keeper). Update tiap session.

## 0. Meta
- project: $SLUG
- created: $DATE
- last_updated: $DATETIME
- stack: TBD
- repo: TBD

## 1. Project Overview
- Goal: TBD
- Users: TBD
- Core flows: TBD

## 2. Architecture & Tech Decisions
- Stack: TBD
- Folder: TBD

## 3. Conventions
- Commit: conventional commits

## 4. Gotchas
- TBD

## 5. Progress Log
- [$DATE] init memory

## 6. TODO
- [ ] scan codebase untuk isi 1-4

## 7. Session Notes
- last: init
MEM
mkdir -p ~/.config/opencode/memory
cp .opencode/MEMORY.md ~/.config/opencode/memory/${SLUG}.md
echo "Created .opencode/MEMORY.md + mirror ~/.config/opencode/memory/${SLUG}.md"

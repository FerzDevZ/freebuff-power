#!/usr/bin/env bash
set -euo pipefail

echo "=== Checking Tailwind & Shadcn Setup ==="
if [ -f "tailwind.config.js" ] || [ -f "tailwind.config.ts" ] || [ -f "components.json" ]; then
    echo "✅ Tailwind / Shadcn configuration detected."
else
    echo "ℹ️ No tailwind config or components.json found in current directory."
fi

#!/usr/bin/env bash
set -euo pipefail

echo "=== Checking Flutter Web Configuration ==="
if [ -d "web" ]; then
    echo "✅ web/ directory found."
    if [ -f "web/index.html" ]; then
        echo "Checking index.html for title and viewport tags..."
        grep -i "viewport" web/index.html || echo "Missing viewport tag in web/index.html"
    fi
else
    echo "No web directory found in current project."
fi

#!/usr/bin/env bash
set -euo pipefail

echo "=== Verifying Native Platform Bridge Setup ==="
if [ -d "android" ] && [ -d "ios" ]; then
    echo "Android and iOS directories detected."
    if [ -f "pigeons/messages.dart" ]; then
        echo "✅ Pigeon schema detected."
    else
        echo "ℹ️ Note: No pigeons/ directory found. Consider using Pigeon for type-safe channels."
    fi
fi

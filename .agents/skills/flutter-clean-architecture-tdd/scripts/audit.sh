#!/usr/bin/env bash
set -euo pipefail

echo "=== Checking Clean Architecture Domain Layer Isolation ==="
if [ -d "lib" ]; then
    BAD_IMPORTS=$(grep -rn "package:flutter/" lib/**/domain/ 2>/dev/null || true)
    if [ -n "$BAD_IMPORTS" ]; then
        echo "❌ VIOLATION: Domain layer imports Flutter UI:"
        echo "$BAD_IMPORTS"
        exit 1
    else
        echo "✅ Domain layer is purely isolated from Flutter UI framework."
    fi
fi

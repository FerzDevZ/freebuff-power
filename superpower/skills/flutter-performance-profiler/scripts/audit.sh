#!/usr/bin/env bash
set -euo pipefail

echo "=== Auditing Flutter Performance Metrics ==="
if [ -f "pubspec.yaml" ]; then
    echo "Checking for unconstrained image loading..."
    grep -rn "Image.network" lib/ || echo "No raw Image.network found (good)."
    echo "Checking for saveLayer-heavy widgets..."
    grep -rn "Opacity(" lib/ || echo "No unoptimized Opacity calls."
fi

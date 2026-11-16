#!/usr/bin/env bash
set -euo pipefail

echo "=== Auditing Flutter Animation Controller Disposal ==="
if [ -d "lib" ]; then
    CONTROLLERS=$(grep -rn "AnimationController" lib/ 2>/dev/null || true)
    DISPOSES=$(grep -rn "\.dispose()" lib/ 2>/dev/null || true)
    echo "Controllers found: $(echo "$CONTROLLERS" | wc -l)"
    echo "Disposal calls found: $(echo "$DISPOSES" | wc -l)"
    echo "Ensure all AnimationControllers are explicitly disposed in dispose()."
fi

#!/usr/bin/env bash
set -euo pipefail

echo "=== Checking TanStack Query Dependencies ==="
if [ -f "package.json" ]; then
    grep -E "@tanstack/react-query|zustand" package.json || echo "TanStack Query not installed."
fi

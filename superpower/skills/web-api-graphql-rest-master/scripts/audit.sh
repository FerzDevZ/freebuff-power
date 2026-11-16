#!/usr/bin/env bash
set -euo pipefail

echo "=== Verifying API Contract Tools ==="
if [ -f "package.json" ]; then
    grep -E "zod|axios|graphql" package.json || echo "No API contract libraries found."
fi

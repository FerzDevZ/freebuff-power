#!/usr/bin/env bash
set -euo pipefail

echo "=== Auditing Web Animation Dependencies ==="
if [ -f "package.json" ]; then
    grep -E "framer-motion|gsap" package.json || echo "No framer-motion or gsap found."
fi

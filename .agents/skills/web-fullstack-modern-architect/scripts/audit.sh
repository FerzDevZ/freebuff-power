#!/usr/bin/env bash
set -euo pipefail

echo "=== Auditing Next.js App Router Setup ==="
if [ -f "package.json" ]; then
    echo "Checking for Next.js and Drizzle dependencies..."
    grep -E "next|drizzle-orm|prisma|zod" package.json || echo "No fullstack web dependencies found."
fi

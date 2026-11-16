#!/usr/bin/env bash
# Runs Playwright tests with CI settings (headless, shard-ready, trace recording on retry)

echo "🎭 Running Playwright Test Suite..."
npx playwright test --workers=2 --reporter=list,html

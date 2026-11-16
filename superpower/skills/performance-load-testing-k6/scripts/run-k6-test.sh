#!/usr/bin/env bash
# Runs k6 load test against a target URL

TARGET_URL="${1:-http://localhost:8080/health}"
echo "🚀 Running k6 Load Test against $TARGET_URL..."

if command -v k6 &> /dev/null; then
  TARGET_URL="$TARGET_URL" k6 run skills/performance-load-testing-k6/resources/load-test.js
else
  echo "⚠️ k6 binary not found locally. To run via Docker:"
  echo "docker run --rm -i -e TARGET_URL=$TARGET_URL grafana/k6 run - < skills/performance-load-testing-k6/resources/load-test.js"
fi

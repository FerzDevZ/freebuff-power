#!/usr/bin/env bash
# ==============================================================================
# ⚙️ FREEBUFF-POWER AUTOMATED CI/CD WORKFLOW GENERATOR
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

mkdir -p ".github/workflows"
WORKFLOW_FILE=".github/workflows/ci.yml"

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚙️  [FREEBUFF-POWER CI] Generating GitHub Actions Workflow${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

if [ -f "package.json" ]; then
  cat << 'CI_EOF' > "$WORKFLOW_FILE"
name: CI/CD Pipeline

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test-and-build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install Dependencies
        run: npm ci

      - name: Run Linter & Typecheck
        run: npm run lint --if-present && npx tsc --noEmit --if-present

      - name: Run Test Suite
        run: npm test --if-present

      - name: Build Production Artifacts
        run: npm run build --if-present
CI_EOF

elif [ -f "go.mod" ]; then
  cat << 'CI_EOF' > "$WORKFLOW_FILE"
name: Go CI Pipeline

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'
          cache: true
      - run: go test -v -race ./...
      - run: go build -v ./...
CI_EOF

elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  cat << 'CI_EOF' > "$WORKFLOW_FILE"
name: Python CI Pipeline

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'
      - run: pip install -r requirements.txt
      - run: pytest || python -m unittest
CI_EOF
fi

echo -e "${C_GREEN}✅ Sukses! File '$WORKFLOW_FILE' berhasil dibuat dan siap aktif di GitHub Actions.${C_RESET}\n"

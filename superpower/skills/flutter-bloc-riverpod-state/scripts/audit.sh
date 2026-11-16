#!/usr/bin/env bash
set -euo pipefail

echo "=== Auditing Flutter State Management Dependencies ==="
if [ -f "pubspec.yaml" ]; then
    echo "Checking pubspec.yaml for state packages..."
    grep -E "flutter_bloc|flutter_riverpod|freezed|provider" pubspec.yaml || echo "No standard state package found."
    echo "Audit completed."
else
    echo "No pubspec.yaml found in current directory."
fi

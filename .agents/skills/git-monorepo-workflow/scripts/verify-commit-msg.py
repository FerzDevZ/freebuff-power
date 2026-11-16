#!/usr/bin/env python3
"""
Conventional Commit Validator
Verifies that a commit message string complies with Conventional Commits specifications.
"""

import sys
import re

CONVENTIONAL_REGEX = r"^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9_\-\.]+\))?(!)?:\s+(.{1,80})"

def validate_commit(msg: str):
    msg = msg.strip()
    match = re.match(CONVENTIONAL_REGEX, msg)
    if not match:
        print(f"❌ Invalid Conventional Commit format: '{msg}'")
        print("Expected format: <type>(<optional scope>): <description>")
        print("Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert")
        sys.exit(1)
    else:
        print(f"✅ Valid Conventional Commit: {match.group(0)}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: verify-commit-msg.py '<commit_message>'")
        sys.exit(1)
    validate_commit(sys.argv[1])

#!/usr/bin/env python3
"""
PR Diff Size and Complexity Auditor
Analyzes line additions/deletions and warns if PR exceeds cognitive review thresholds (>400 lines).
"""

import sys
from pathlib import Path

def audit_diff(diff_path: Path):
    lines = diff_path.read_text(encoding="utf-8", errors="ignore").splitlines()
    additions = sum(1 for l in lines if l.startswith("+") and not l.startswith("+++"))
    deletions = sum(1 for l in lines if l.startswith("-") and not l.startswith("---"))
    total_changed = additions + deletions

    print("\n🔍 Pull Request Diff Analysis:")
    print(f"  Lines Added   : +{additions}")
    print(f"  Lines Removed : -{deletions}")
    print(f"  Total Changed : {total_changed} lines")

    if total_changed > 400:
        print("\n⚠️ WARNING: PR is larger than 400 lines! Consider breaking this PR into smaller, atomic changes to reduce cognitive load and catch subtle bugs.")
    else:
        print("\n✅ PR size is within optimal review thresholds (< 400 lines).")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: audit-pr-diff.py <git_diff_file.patch>")
        sys.exit(0)
    audit_diff(Path(sys.argv[1]))

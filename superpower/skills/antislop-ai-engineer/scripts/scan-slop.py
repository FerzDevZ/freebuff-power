#!/usr/bin/env python3
"""
Antislop Scanner Script
Detects AI fluff words, lazy placeholders, and redundant syntax comments in code/markdown files.
"""

import sys
import re
from pathlib import Path

BANNED_WORDS = [
    r"\bdelve\b",
    r"\btapestry\b",
    r"\btestament\b",
    r"\bseamlessly\b",
    r"\bin today's (fast-paced|digital|modern) world\b",
    r"\bit is (crucial|vital|imperative) to remember\b",
    r"\bhope this helps\b",
    r"\bcertainly! I('d| would) be happy to\b"
]

LAZY_PATTERNS = [
    r"//\s*\.\.\.\s*(rest of code|remaining|existing)",
    r"#\s*\.\.\.\s*(rest of code|remaining|existing)",
    r"//\s*TODO:\s*(implement|add later|finish this)",
    r"#\s*TODO:\s*(implement|add later|finish this)",
    r"/\*\s*\.\.\.\s*\*/"
]

def scan_file(file_path: Path):
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
    except Exception as e:
        return []

    issues = []
    lines = content.splitlines()

    for line_idx, line in enumerate(lines, 1):
        for pattern in BANNED_WORDS:
            if re.search(pattern, line, re.IGNORECASE):
                issues.append((line_idx, f"Banned AI fluff detected: '{re.search(pattern, line, re.IGNORECASE).group(0)}'"))
        for pattern in LAZY_PATTERNS:
            if re.search(pattern, line, re.IGNORECASE):
                issues.append((line_idx, f"Lazy placeholder detected: '{line.strip()}'"))

    return issues

def main():
    if len(sys.argv) < 2:
        print("Usage: scan-slop.py <path-to-file-or-dir>")
        sys.exit(1)

    target = Path(sys.argv[1])
    total_issues = 0

    files_to_check = [target] if target.is_file() else list(target.rglob("*"))

    for f in files_to_check:
        if f.is_file() and not f.name.startswith(".") and f.suffix in [".ts", ".js", ".py", ".go", ".rs", ".md", ".json"]:
            issues = scan_file(f)
            if issues:
                print(f"\n❌ {f.relative_to(target.parent if target.is_file() else target)}:")
                for line_idx, msg in issues:
                    print(f"  Line {line_idx}: {msg}")
                    total_issues += 1

    if total_issues == 0:
        print("✅ Clean! No AI-slop or lazy placeholders detected.")
        sys.exit(0)
    else:
        print(f"\n⚠️ Total issues found: {total_issues}")
        sys.exit(1)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Accessibility (a11y) Static Scanner for JSX/HTML
Scans components for missing alt tags, click handlers on non-interactive elements, missing aria labels.
"""

import sys
import re
from pathlib import Path

def scan_a11y(file_path: Path):
    content = file_path.read_text(encoding="utf-8", errors="ignore")
    issues = []
    lines = content.splitlines()

    for idx, line in enumerate(lines, 1):
        # 1. Check img without alt
        if re.search(r"<img\b", line) and not re.search(r"\balt=", line):
            issues.append((idx, "Image missing required 'alt' attribute"))
        
        # 2. Check div/span with onClick but no role/tabIndex
        if re.search(r"<(div|span)\b[^>]*onClick", line):
            if not (re.search(r"role=['\"]button['\"]", line) and re.search(r"tabIndex=", line)):
                issues.append((idx, "Non-interactive element (<div/span>) has onClick without role='button' and tabIndex"))
                
        # 3. Check button without accessible name (empty icon buttons)
        if re.search(r"<button\b[^>]*>[\s\n]*<(svg|lucide|Icon)", line) and not re.search(r"aria-label=", line):
            issues.append((idx, "Icon button appears to lack an 'aria-label' attribute"))

    return issues

def main():
    if len(sys.argv) < 2:
        print("Usage: audit-a11y.py <path-to-components>")
        sys.exit(1)

    target = Path(sys.argv[1])
    files = [target] if target.is_file() else list(target.rglob("*.tsx")) + list(target.rglob("*.jsx")) + list(target.rglob("*.html"))
    total_issues = 0

    for f in files:
        issues = scan_a11y(f)
        if issues:
            print(f"\n⚠️ a11y issues in {f.name}:")
            for line_idx, msg in issues:
                print(f"  Line {line_idx}: {msg}")
                total_issues += 1

    if total_issues == 0:
        print("✅ No common static a11y issues found.")
        sys.exit(0)
    else:
        print(f"\nTotal accessibility issues: {total_issues}")
        sys.exit(1)

if __name__ == "__main__":
    main()

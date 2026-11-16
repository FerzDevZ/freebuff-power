#!/usr/bin/env python3
"""
Hardcoded Secrets & API Key Scanner
Detects AWS keys, private keys, GitHub tokens, and generic bearer tokens in source files.
"""

import sys
import re
from pathlib import Path

SECRET_PATTERNS = [
    (r"(?i)aws_access_key_id\s*=\s*['\"][A-Z0-9]{20}['\"]", "AWS Access Key"),
    (r"(?i)aws_secret_access_key\s*=\s*['\"][A-Za-z0-9/+=]{40}['\"]", "AWS Secret Key"),
    (r"-----BEGIN (RSA|OPENSSH|PRIVATE) KEY-----", "Private Key Header"),
    (r"ghp_[0-9a-zA-Z]{36}", "GitHub Personal Access Token"),
    (r"sk-[a-zA-Z0-9]{32,}", "OpenAI API Key"),
    (r"xox[baprs]-[0-9a-zA-Z]{10,48}", "Slack Token")
]

def scan_secrets(file_path: Path):
    content = file_path.read_text(encoding="utf-8", errors="ignore")
    findings = []
    lines = content.splitlines()

    for idx, line in enumerate(lines, 1):
        for pattern, label in SECRET_PATTERNS:
            if re.search(pattern, line):
                findings.append((idx, label))

    return findings

def main():
    if len(sys.argv) < 2:
        print("Usage: scan-hardcoded-secrets.py <directory>")
        sys.exit(1)

    target = Path(sys.argv[1])
    files = [target] if target.is_file() else list(target.rglob("*"))
    total_findings = 0

    for f in files:
        if f.is_file() and not any(part.startswith(".") for part in f.parts):
            findings = scan_secrets(f)
            if findings:
                print(f"\n🚨 Potential secret leak in {f}:")
                for line_idx, label in findings:
                    print(f"  Line {line_idx}: Detected {label}")
                    total_findings += 1

    if total_findings == 0:
        print("✅ No hardcoded secrets detected.")
        sys.exit(0)
    else:
        print(f"\n❌ Found {total_findings} potential secret leaks!")
        sys.exit(1)

if __name__ == "__main__":
    main()

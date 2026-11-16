#!/usr/bin/env python3
"""
Deprecated API Scanner for Common Web Frameworks
"""

import sys
import re
from pathlib import Path

DEPRECATED_PATTERNS = [
    (r"getServerSideProps", "Next.js Pages Router: Replace with async Server Components or generateMetadata"),
    (r"getInitialProps", "Next.js Legacy: Replace with async Server Components"),
    (r"componentWillMount", "React Legacy Lifecycle: Replace with useEffect or useMemo"),
    (r"var\s+", "Legacy JS: Replace with const or let"),
    (r":\s*any\b", "TypeScript loose type: Replace with explicit interface or unknown"),
]

def scan_dir(target_dir: Path):
    print(f"\n🔍 Scanning for deprecated patterns in: {target_dir}")
    found = 0
    for ext in ["*.js", "*.jsx", "*.ts", "*.tsx"]:
        for file in target_dir.rglob(ext):
            if "node_modules" in str(file) or ".next" in str(file):
                continue
            text = file.read_text(encoding="utf-8", errors="ignore")
            for pattern, reason in DEPRECATED_PATTERNS:
                matches = re.finditer(pattern, text)
                for m in matches:
                    print(f"  • {file.name}: Found '{m.group(0)}' -> {reason}")
                    found += 1
    print(f"\n📊 Scan Complete: {found} legacy items detected.")

if __name__ == "__main__":
    p = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    scan_dir(p)

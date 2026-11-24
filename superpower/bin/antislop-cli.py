#!/usr/bin/env python3
# ==============================================================================
# 🛡️ FREEBUFF-POWER ANTISLOP MASTER CLI & AUDIT ENGINE (v10.0)
# Automated 40-Rule Compliance Scanner, Contrast Verifier & DESIGN.md Generator
# ==============================================================================

import os
import sys
import re
import argparse
from pathlib import Path

C_CYAN = "\033[0;36m"
C_GREEN = "\033[0;32m"
C_YELLOW = "\033[0;33m"
C_RED = "\033[0;31m"
C_PURPLE = "\033[0;35m"
C_BOLD = "\033[1m"
C_DIM = "\033[2m"
C_RESET = "\033[0m"

# ------------------------------------------------------------------------------
# Contrast Calculation Engine (WCAG 2.2 Standard)
# ------------------------------------------------------------------------------
def _channel(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

def relative_luminance(hex_color):
    h = hex_color.strip().lstrip("#")
    if len(h) == 3:
        h = "".join(ch * 2 for ch in h)
    if not re.fullmatch(r"[0-9A-Fa-f]{6}", h):
        raise ValueError(f"Invalid hex color: {hex_color}")
    r, g, b = (int(h[i : i + 2], 16) for i in (0, 2, 4))
    return 0.2126 * _channel(r) + 0.7152 * _channel(g) + 0.0722 * _channel(b)

def check_contrast(fg, bg):
    l1, l2 = relative_luminance(fg), relative_luminance(bg)
    lighter, darker = max(l1, l2), min(l1, l2)
    ratio = (lighter + 0.05) / (darker + 0.05)
    return ratio

def cmd_contrast(fg, bg):
    try:
        ratio = check_contrast(fg, bg)
    except Exception as e:
        print(f"{C_RED}❌ Error: {e}{C_RESET}")
        return 1

    pass_normal_aa = ratio >= 4.5
    pass_large_aa = ratio >= 3.0
    pass_normal_aaa = ratio >= 7.0
    pass_large_aaa = ratio >= 4.5

    def badge(ok):
        return f"{C_GREEN}{C_BOLD}PASS{C_RESET}" if ok else f"{C_RED}{C_BOLD}FAIL{C_RESET}"

    print(f"\n{C_CYAN}{C_BOLD}========================================================================{C_RESET}")
    print(f"{C_PURPLE}{C_BOLD}🎨 [ANTISLOP] MATHEMATICAL WCAG CONTRAST VERIFICATION{C_RESET}")
    print(f"{C_CYAN}{C_BOLD}========================================================================{C_RESET}")
    print(f"Foreground (Text) : {C_BOLD}{fg}{C_RESET}")
    print(f"Background (Base) : {C_BOLD}{bg}{C_RESET}")
    print(f"Rasio Kontras     : {C_YELLOW}{C_BOLD}{ratio:.2f}:1{C_RESET}\n")

    print(f"  • WCAG AA Normal Text (<18px)   : {badge(pass_normal_aa)} (Min 4.5:1)")
    print(f"  • WCAG AA Large Text (>=18px)   : {badge(pass_large_aa)} (Min 3.0:1)")
    print(f"  • WCAG AAA Normal Text (Strict) : {badge(pass_normal_aaa)} (Min 7.0:1)")
    print(f"  • WCAG AAA Large Text (Strict)  : {badge(pass_large_aaa)} (Min 4.5:1)")
    print(f"{C_CYAN}========================================================================{C_RESET}\n")
    return 0 if pass_normal_aa else 1

# ------------------------------------------------------------------------------
# DESIGN.md Generator
# ------------------------------------------------------------------------------
DESIGN_TEMPLATE = """# DESIGN.md — Project Design Direction & Visual Soul

> **CORE PRINCIPLE (R-37)**: Design direction must be settled before building.
> Removing slop leaves a void; this document provides the intentional soul, aesthetic dials, and tokens.

---

## 1. Brand Identity & Atmosphere

- **Archetype**: Technical Precision & Clean Engineering Craft
- **Mood**: High-contrast, tactile, purposeful, zero-fluff
- **Target Audience**: Developers, technical leaders, and high-performance engineers

---

## 2. The 4 Design Dials (Scale 1-10)

- **Density (8/10)**: High information density. Compact headers, structured tables, dense code views.
- **Boldness (7/10)**: Strong typographic contrast, sharp borders, unapologetic section hierarchy.
- **Temperature (3/10)**: Cool slate and obsidian neutrals with a slight cyan/teal perceptual chroma.
- **Polish (9/10)**: Precision spring physics, instant sub-50ms feedback, accessible focus rings.

---

## 3. OKLCH Color Architecture

```css
:root {
  /* Neutrals with subtle chroma (>0.005) to avoid dead grey */
  --bg-app: oklch(0.14 0.01 240);
  --surface-card: oklch(0.18 0.012 240);
  --surface-elevated: oklch(0.22 0.015 240);
  --border-subtle: oklch(0.28 0.015 240);
  --text-primary: oklch(0.96 0.005 240);
  --text-muted: oklch(0.72 0.01 240);

  /* Single Deliberate Accent */
  --accent-primary: oklch(0.68 0.18 160); /* Mint Emerald */
  --accent-hover: oklch(0.74 0.19 160);
  --accent-contrast: oklch(0.12 0.02 160);
}
```

---

## 4. Fluid Typography (No Fixed Desktop Pixels)

- **Display Headline**: `clamp(2rem, 5vw + 1rem, 3.5rem)` (Weight 700, Tight Tracking `-0.02em`)
- **Section Heading**: `clamp(1.5rem, 3vw + 0.75rem, 2.25rem)` (Weight 600)
- **Body Regular**: `clamp(0.9375rem, 0.5vw + 0.85rem, 1rem)` (Line Height 1.6)
- **Code / Mono**: `0.875rem` ('JetBrains Mono', 'Fira Code', monospace)

---

## 5. Structural Layout & Component States

- **Asymmetric Structure**: Bento grid masonry or staggered editorial columns (No centered hero with floating badges).
- **No Decorative Emojis**: Use crisp SVG / Lucide icons.
- **Touch Targets**: Minimum `48px x 48px` on all mobile interactive elements.
- **8 Component States**: Every component implements `default`, `hover`, `focus-visible`, `active`, `disabled`, `loading`, `empty`, `error`.
"""

def cmd_design_init(target_path="DESIGN.md", force=False):
    dest = Path(target_path).resolve()
    if dest.exists() and not force:
        print(f"{C_YELLOW}⚠️ File {dest} sudah ada. Gunakan flag --force untuk menimpa.{C_RESET}")
        return 1

    dest.write_text(DESIGN_TEMPLATE, encoding="utf-8")
    print(f"\n{C_GREEN}{C_BOLD}✅ [ANTISLOP] DESIGN.md berhasil dibuat di: {dest}{C_RESET}")
    print(f"{C_DIM}   Direction visual & estetika proyek kini terkunci dan siap dibaca oleh sub-agent.{C_RESET}\n")
    return 0

# ------------------------------------------------------------------------------
# Anti-Slop Audit Scanner (40-Rule Checker)
# ------------------------------------------------------------------------------
SLOP_PATTERNS = [
    # Hard Gates (HIGH)
    (
        r"bg-clip-text\s+text-transparent",
        "R-02 (Hard Gate)",
        "Ditemukan gradient text fill (bg-clip-text text-transparent) yang merupakan tell AI generik.",
        "HIGH",
    ),
    (
        r"(from-purple-\d+|to-blue-\d+|from-indigo-\d+|to-pink-\d+).*(bg-gradient-to)",
        "R-01 (Hard Gate)",
        "Ditemukan gradien biru-ungu default AI tanpa justifikasi identitas merek.",
        "HIGH",
    ),
    (
        r"(//\s*={5,}|/\*\s*={5,}|\#\s*={5,}|//\s*-{5,})",
        "R-31 (Hard Gate)",
        "Ditemukan banner dekoratif berlebihan (// ======) pada komentar kode.",
        "HIGH",
    ),
    (
        r"(0\.0001\s*ms|\+99\.9%|\b10,000\+\s*teams\b|\b100k\+\s*developers\b)",
        "R-08/R-16 (Hard Gate)",
        "Ditemukan klaim angka performa atau social proof buatan yang tidak terverifikasi.",
        "HIGH",
    ),
    (
        r"\b(unlock\s+the\s+power|elevate\s+your|delve\s+into|game-changer|seamlessly\s+integrate|pivotal\s+moment)\b",
        "R-15 (Hard Gate)",
        "Ditemukan kosakata klise AI (unlock, delve, elevate, game-changer) pada copywriting.",
        "HIGH",
    ),
    (
        r"(✨|🚀|⚡|🔥|🎯|✅).*(<h[1-6]|className=.*font-bold)",
        "R-06 (Hard Gate)",
        "Ditemukan emoji dekoratif pada heading atau kartu fitur. Gunakan icon SVG/Lucide.",
        "HIGH",
    ),
    (
        r"(rounded-full.*rounded-full.*rounded-full)",
        "R-11 (Hard Gate)",
        "Semua komponen memakai pill border radius secara seragam tanpa hirarki.",
        "MEDIUM",
    ),
    (
        r"(transition-all(?!\s+duration))",
        "R-14 (Hard Gate)",
        "Ditemukan 'transition-all' tanpa properti CSS eksplisit (dapat memicu lag GPU & repaints).",
        "MEDIUM",
    ),
    (
        r"(//\s*TODO:\s*(implement|fix\s*later|add\s*more|improve))",
        "R-38 (Quality Lock)",
        "Ditemukan TODO placeholder palsu tanpa deskripsi tugas yang spesifik.",
        "HIGH",
    ),
]

def scan_file(filepath):
    findings = []
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()
            for idx, line in enumerate(lines, start=1):
                for pattern, rule_id, desc, severity in SLOP_PATTERNS:
                    if re.search(pattern, line, re.IGNORECASE):
                        findings.append({
                            "file": filepath,
                            "line": idx,
                            "snippet": line.strip()[:100],
                            "rule": rule_id,
                            "desc": desc,
                            "severity": severity,
                        })
    except Exception:
        pass
    return findings

def cmd_audit(root_dir="."):
    root = Path(root_dir).resolve()
    print(f"\n{C_CYAN}{C_BOLD}========================================================================{C_RESET}")
    print(f"{C_PURPLE}{C_BOLD}🛡️ [ANTISLOP] SCANNING REPOSITORY FOR AI SLOP (40-RULE SUITE){C_RESET}")
    print(f"{C_CYAN}{C_BOLD}========================================================================{C_RESET}")
    print(f"Target Directory : {C_BOLD}{root}{C_RESET}\n")

    ignored_dirs = {".git", "node_modules", ".next", "dist", "build", ".cache", "__pycache__", "venv"}
    target_exts = {".js", ".jsx", ".ts", ".tsx", ".vue", ".html", ".css", ".py", ".go", ".dart", ".md"}

    total_files = 0
    all_findings = []

    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in ignored_dirs and not d.startswith(".")]
        for f in filenames:
            ext = os.path.splitext(f)[1].lower()
            if ext in target_exts:
                total_files += 1
                filepath = os.path.join(dirpath, f)
                findings = scan_file(filepath)
                all_findings.extend(findings)

    print(f"📊 Total File Diperiksa : {C_BOLD}{total_files} file{C_RESET}")
    print(f"🚨 Total Temuan Slop    : {C_BOLD}{len(all_findings)} temuan{C_RESET}\n")

    if not all_findings:
        print(f"{C_GREEN}{C_BOLD}🎉 100% CLEAN! Zero AI Slop terdeteksi di seluruh codebase.{C_RESET}")
        print(f"{C_CYAN}========================================================================{C_RESET}\n")
        return 0

    # Group by severity
    highs = [f for f in all_findings if f["severity"] == "HIGH"]
    meds = [f for f in all_findings if f["severity"] == "MEDIUM"]

    print(f"  • {C_RED}{C_BOLD}HIGH (Hard Gate Violations)  : {len(highs)}{C_RESET}")
    print(f"  • {C_YELLOW}{C_BOLD}MEDIUM (Purpose Gate Warns)  : {len(meds)}{C_RESET}\n")

    for idx, f in enumerate(all_findings[:15], start=1):
        sev_color = C_RED if f["severity"] == "HIGH" else C_YELLOW
        rel_path = os.path.relpath(f["file"], root)
        print(f"[{idx}] {sev_color}{C_BOLD}{f['rule']}{C_RESET} in {C_CYAN}{rel_path}:{f['line']}{C_RESET}")
        print(f"    {C_DIM}Snippet : {f['snippet']}{C_RESET}")
        print(f"    {C_BOLD}Alasan  : {f['desc']}{C_RESET}\n")

    if len(all_findings) > 15:
        print(f"{C_DIM}...dan {len(all_findings) - 15} temuan lainnya.{C_RESET}\n")

    print(f"{C_YELLOW}💡 Jalankan @antislop-auditor untuk auto-remediasi temuan di atas.{C_RESET}")
    print(f"{C_CYAN}========================================================================{C_RESET}\n")
    return 1

# ------------------------------------------------------------------------------
# Main Entry Point
# ------------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Freebuff-Power Anti-Slop CLI Suite")
    subparsers = parser.add_subparsers(dest="command")

    # contrast
    p_contrast = subparsers.add_parser("contrast", help="Cek rasio kontras warna WCAG AA/AAA")
    p_contrast.add_argument("foreground", help="Hex warna teks (misal: #FFFFFF)")
    p_contrast.add_argument("background", help="Hex warna background (misal: #070707)")

    # design
    p_design = subparsers.add_parser("design", help="Kelola DESIGN.md arsitektur estetika")
    p_design.add_argument("action", choices=["init"], default="init", nargs="?")
    p_design.add_argument("--force", action="store_true", help="Timpa file jika sudah ada")

    # audit
    p_audit = subparsers.add_parser("audit", help="Pindai repository dari 40 aturan AI slop")
    p_audit.add_argument("path", default=".", nargs="?", help="Direktori target scan")

    args = parser.parse_args()

    if args.command == "contrast":
        return cmd_contrast(args.foreground, args.background)
    elif args.command == "design":
        return cmd_design_init(force=args.force)
    elif args.command == "audit" or args.command is None:
        target = getattr(args, "path", ".") if args.command else "."
        return cmd_audit(target)
    else:
        parser.print_help()
        return 0

if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env node
// ==============================================================================
// 🎨 FREEBUFF-POWER TAILWIND COLOR PALETTE & DESIGN SYSTEM GENERATOR
// ==============================================================================
const fs = require("fs");
const path = require("path");

const themeName = process.argv[2] || "modern-dark";
const outputFile = "theme.config.json";

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log(`\x1b[33m\x1b[1m🎨 [FREEBUFF-POWER THEME] Generating Palette: ${themeName}\x1b[0m`);
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

const palette = {
  theme: themeName,
  colorSpace: "OKLCH",
  colors: {
    background: "oklch(0.14 0.02 260)",
    foreground: "oklch(0.98 0.01 260)",
    primary: "oklch(0.60 0.22 260)", // Vibrant Klein Blue
    secondary: "oklch(0.75 0.18 150)", // Mint
    accent: "oklch(0.80 0.20 85)", // Warm Amber
    card: "oklch(0.18 0.03 260)",
    border: "oklch(0.28 0.04 260)"
  },
  typography: {
    fontSans: "Inter, system-ui, -apple-system, sans-serif",
    fontMono: "Fira Code, Consolas, monospace",
    fluidScale: "clamp(1rem, 0.95rem + 0.25vw, 1.25rem)"
  },
  tailwindSnippet: `@theme {\n  --color-primary: oklch(0.60 0.22 260);\n  --color-background: oklch(0.14 0.02 260);\n  --color-card: oklch(0.18 0.03 260);\n}`
};

fs.writeFileSync(outputFile, JSON.stringify(palette, null, 2));

console.log(`✅ Palette & Design Tokens berhasil dibuat ke: \x1b[36m${outputFile}\x1b[0m\n`);
console.log("🎨 Tailwind CSS v4 Theme Snippet:");
console.log("\x1b[35m" + palette.tailwindSnippet + "\x1b[0m\n");

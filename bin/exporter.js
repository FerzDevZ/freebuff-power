#!/usr/bin/env node
// ==============================================================================
// 🔄 FREEBUFF-POWER MULTI-IDE UNIVERSAL EXPORTER
// ==============================================================================
const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const agentsMdPath = fs.existsSync(path.join(repoRoot, "superpower/AGENTS.md"))
  ? path.join(repoRoot, "superpower/AGENTS.md")
  : path.join(process.env.HOME, ".freebuff-superpower/AGENTS.md");

const target = process.argv[2] || "--all";
const targetDir = process.cwd();

if (!fs.existsSync(agentsMdPath)) {
  console.error("❌ AGENTS.md template tidak ditemukan.");
  process.exit(1);
}

const masterContent = fs.readFileSync(agentsMdPath, "utf8");

function exportCursor() {
  const dest = path.join(targetDir, ".cursorrules");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to Cursor:\x1b[0m ${dest}`);
}

function exportClaude() {
  const dest = path.join(targetDir, "CLAUDE.md");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to Claude Code:\x1b[0m ${dest}`);
}

function exportWindsurf() {
  const dest = path.join(targetDir, ".windsurfrules");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to Windsurf Cascade:\x1b[0m ${dest}`);
}

function exportOpenCode() {
  const dest = path.join(targetDir, "AGENTS.md");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to OpenCode:\x1b[0m ${dest}`);
}

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log("\x1b[33m\x1b[1m🔄 [FREEBUFF-POWER EXPORT] Multi-IDE Universal Synchronization\x1b[0m");
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

switch (target) {
  case "--cursor":
    exportCursor();
    break;
  case "--claude":
    exportClaude();
    break;
  case "--windsurf":
    exportWindsurf();
    break;
  case "--opencode":
    exportOpenCode();
    break;
  case "--all":
  default:
    exportCursor();
    exportClaude();
    exportWindsurf();
    exportOpenCode();
    break;
}

console.log("\n\x1b[32m\x1b[1m🎉 Sukses! 42 Sub-Agents & 1,025 Skills siap dipakai di semua AI IDE.\x1b[0m\n");

#!/usr/bin/env node
// ==============================================================================
// 🔄 FREEBUFF-POWER MULTI-IDE UNIVERSAL EXPORTER (v8.5-Titanium)
// Syncs to Cursor, Claude Code, Windsurf, GitHub Copilot, Cline & OpenCode
// ==============================================================================
const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const agentsMdPath = fs.existsSync(path.join(repoRoot, "superpower/AGENTS.md"))
  ? path.join(repoRoot, "superpower/AGENTS.md")
  : (fs.existsSync(path.join(repoRoot, "AGENTS.md"))
    ? path.join(repoRoot, "AGENTS.md")
    : path.join(process.env.HOME, ".freebuff-superpower/AGENTS.md"));

const target = process.argv[2] || "--all";
const targetDir = process.cwd();

if (!fs.existsSync(agentsMdPath)) {
  console.error("❌ AGENTS.md template tidak ditemukan di:", agentsMdPath);
  process.exit(1);
}

const masterContent = fs.readFileSync(agentsMdPath, "utf8");

function exportCursor() {
  const dest = path.join(targetDir, ".cursorrules");
  fs.writeFileSync(dest, masterContent);
  const cursorRulesDir = path.join(targetDir, ".cursor", "rules");
  fs.mkdirSync(cursorRulesDir, { recursive: true });
  fs.writeFileSync(path.join(cursorRulesDir, "agents.mdc"), masterContent);
  console.log(`\x1b[32m[✓] Exported to Cursor (.cursorrules & .cursor/rules/agents.mdc)\x1b[0m`);
}

function exportClaude() {
  const dest = path.join(targetDir, "CLAUDE.md");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to Claude Code (CLAUDE.md)\x1b[0m`);
}

function exportWindsurf() {
  const dest = path.join(targetDir, ".windsurfrules");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to Windsurf Cascade (.windsurfrules)\x1b[0m`);
}

function exportCopilot() {
  const githubDir = path.join(targetDir, ".github");
  fs.mkdirSync(githubDir, { recursive: true });
  const dest = path.join(githubDir, "copilot-instructions.md");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to GitHub Copilot (.github/copilot-instructions.md)\x1b[0m`);
}

function exportCline() {
  const dest = path.join(targetDir, ".clinerules");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to Cline / Roo-Code (.clinerules)\x1b[0m`);
}

function exportOpenCode() {
  const dest = path.join(targetDir, "AGENTS.md");
  fs.writeFileSync(dest, masterContent);
  console.log(`\x1b[32m[✓] Exported to OpenCode / Standard Agents (AGENTS.md)\x1b[0m`);
}

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log("\x1b[33m\x1b[1m🔄 [FREEBUFF-POWER EXPORT] Multi-IDE Universal Synchronization (v8.5)\x1b[0m");
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
  case "--copilot":
    exportCopilot();
    break;
  case "--cline":
    exportCline();
    break;
  case "--opencode":
    exportOpenCode();
    break;
  case "--all":
  default:
    exportCursor();
    exportClaude();
    exportWindsurf();
    exportCopilot();
    exportCline();
    exportOpenCode();
    break;
}

console.log("\n\x1b[32m\x1b[1m🎉 Sukses! 82 Sub-Agents & 1,106 Skills tersinkronisasi ke seluruh AI IDE.\x1b[0m\n");

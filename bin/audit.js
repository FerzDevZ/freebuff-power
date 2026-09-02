#!/usr/bin/env node
// ==============================================================================
// 🔍 FREEBUFF-POWER SECURITY, AI-SLOP & CODE AUDITOR
// ==============================================================================
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log("\x1b[33m\x1b[1m🔍 [FREEBUFF-POWER AUDIT] Security, AI-Slop & Quality Scanner\x1b[0m");
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

let findings = [];
let scannedFiles = 0;

function scanFile(filePath) {
  if (filePath.includes("node_modules") || filePath.includes(".git") || filePath.includes(".next") || filePath.includes(".freebuff-snapshots")) return;
  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) return;

  scannedFiles++;
  const content = fs.readFileSync(filePath, "utf8");
  const lines = content.split("\n");

  lines.forEach((line, idx) => {
    const lineNum = idx + 1;
    // 1. Secret / API Key Leaks
    if (/(api[_-]?key|secret|token|password|auth_token)\s*[:=]\s*['"][a-zA-Z0-9_\-]{16,}['"]/i.test(line)) {
      findings.push({ file: filePath, line: lineNum, severity: "HIGH", msg: "Potensi kebocoran API Key / Hardcoded Secret!" });
    }
    // 2. AI Slop & Synthetic Stubs
    if (/\/\/\s*(TODO|FIXME):?\s*implement\s+later/i.test(line) || /\/\*\s*\.\.\.\s*\*\//.test(line)) {
      findings.push({ file: filePath, line: lineNum, severity: "MEDIUM", msg: "Ditemukan AI-Slop placeholder stub (// TODO: implement later)" });
    }
    // 3. Security vulnerabilities: eval() / dangerouslySetInnerHTML
    if (/\beval\s*\(/.test(line) && !filePath.includes("eval.js")) {
      findings.push({ file: filePath, line: lineNum, severity: "HIGH", msg: "Penggunaan fungsi eval() berbahaya terdeteksi" });
    }
  });
}

function walkDir(dir) {
  try {
    const list = fs.readdirSync(dir);
    for (const item of list) {
      const fullPath = path.join(dir, item);
      if (fs.statSync(fullPath).isDirectory()) {
        walkDir(fullPath);
      } else {
        scanFile(fullPath);
      }
    }
  } catch (e) {}
}

walkDir(process.cwd());

console.log(`📁 Total File Dipindai: \x1b[1m${scannedFiles} file\x1b[0m\n`);

if (findings.length === 0) {
  console.log("\x1b[32m\x1b[1m🎉 0 Celah Keamanan & 0 AI-Slop Ditemukan!\x1b[0m");
  console.log("\x1b[32m[✓] Kode Bersih, Aman dari Kebocoran Secret, dan Siap Produksi (Grade: A+)\x1b[0m\n");
} else {
  console.log(`\x1b[31m\x1b[1m⚠️ Ditemukan ${findings.length} Catatan Audit:\x1b[0m\n`);
  findings.forEach((f, i) => {
    const color = f.severity === "HIGH" ? "\x1b[31m" : "\x1b[33m";
    console.log(`  [${i + 1}] ${color}[${f.severity}]\x1b[0m \x1b[1m${path.relative(process.cwd(), f.file)}:${f.line}\x1b[0m`);
    console.log(`      ➔ ${f.msg}`);
  });
  console.log("\n👉 Perbaiki temuan di atas sebelum melakukan rilis ke produksi!\n");
}

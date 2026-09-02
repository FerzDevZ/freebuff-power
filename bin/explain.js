#!/usr/bin/env node
// ==============================================================================
// 🧠 FREEBUFF-POWER INSTANT CODE EXPLAINER & ARCHITECTURE BREAKDOWN
// ==============================================================================
const fs = require("fs");
const path = require("path");

const targetFile = process.argv[2];
if (!targetFile || !fs.existsSync(targetFile)) {
  console.log("Penggunaan: freebuff-power explain <path/to/file>");
  process.exit(1);
}

const content = fs.readFileSync(targetFile, "utf8");
const lines = content.split("\n");

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log(`\x1b[33m\x1b[1m🧠 [FREEBUFF-POWER EXPLAIN] Analisis Arsitektur: ${path.basename(targetFile)}\x1b[0m`);
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

console.log(`📁 File Target : \x1b[1m${targetFile}\x1b[0m (${lines.length} baris kode)`);

const imports = lines.filter(l => /^(import|const .* = require|use |package )/.test(l.trim()));
const functions = lines.filter(l => /(function |const .* = \(|def |fn |func )/.test(l.trim()));

console.log(`📦 Dependensi  : ${imports.length} modul terdeteksi`);
console.log(`⚙️  Fungsi Inti : ${functions.length} fungsi/blok logika terdeteksi\n`);

console.log("\x1b[32m\x1b[1m💡 Rekomendasi Swarm Persona:\x1b[0m");
if (targetFile.endsWith(".ts") || targetFile.endsWith(".tsx") || targetFile.endsWith(".js")) {
  console.log("  ➔ Gunakan @frontend & @design-engineer jika mengedit komponen UI.");
  console.log("  ➔ Gunakan @tddmaster untuk generate unit test Vitest.");
} else if (targetFile.endsWith(".go") || targetFile.endsWith(".rs") || targetFile.endsWith(".py")) {
  console.log("  ➔ Gunakan @backend & @architect untuk verifikasi performa konkurensi.");
} else if (targetFile.endsWith(".sql") || targetFile.includes("schema")) {
  console.log("  ➔ Gunakan @database & @tokenomics-fintech-ledger untuk audit integritas ACID.");
}

console.log("\n\x1b[36m========================================================================\x1b[0m\n");

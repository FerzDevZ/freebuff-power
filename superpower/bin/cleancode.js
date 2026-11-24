#!/usr/bin/env node
// ==============================================================================
// 🔍 FREEBUFF-POWER DEAD CODE & UNUSED DEPS SCANNER
// ==============================================================================
const fs = require("fs");
const path = require("path");

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log("\x1b[33m\x1b[1m🧹 [FREEBUFF-POWER CLEAN-CODE] Dead Code & Package Optimizer\x1b[0m");
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

let allCode = "";
let fileCount = 0;

function scan(dir) {
  if (dir.includes("node_modules") || dir.includes(".git") || dir.includes(".next") || dir.includes(".freebuff-snapshots")) return;
  const list = fs.readdirSync(dir);
  for (const item of list) {
    const full = path.join(dir, item);
    if (fs.statSync(full).isDirectory()) {
      scan(full);
    } else if (/\.(js|jsx|ts|tsx|vue|svelte|go|py)$/.test(item)) {
      fileCount++;
      allCode += fs.readFileSync(full, "utf8") + "\n";
    }
  }
}

scan(process.cwd());

if (fs.existsSync("package.json")) {
  const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
  const deps = Object.keys(pkg.dependencies || {});
  const unused = deps.filter(d => !allCode.includes(`"${d}"`) && !allCode.includes(`'${d}'`));

  console.log(`📁 Total File Dianalisis : \x1b[1m${fileCount} file kode\x1b[0m`);
  console.log(`📦 Total Dependencies   : ${deps.length} packages\n`);

  if (unused.length === 0) {
    console.log("\x1b[32m\x1b[1m🎉 Semua dependencies terpakai aktif! Nol bloatware.\x1b[0m\n");
  } else {
    console.log(`\x1b[33m\x1b[1m⚠️ Terdeteksi ${unused.length} dependensi yang mungkin tidak terpakai lagi:\x1b[0m`);
    unused.forEach(u => console.log(`  - \x1b[31m${u}\x1b[0m`));
    console.log(`\n👉 Saran: Jalankan 'npm uninstall ${unused.join(" ")}' untuk menghemat ukuran bundle.\n`);
  }
} else {
  console.log(`📁 Total File Dianalisis: ${fileCount} file.`);
  console.log("\x1b[32m[✓] Analisis selesai.\x1b[0m\n");
}

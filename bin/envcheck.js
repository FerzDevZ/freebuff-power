#!/usr/bin/env node
// ==============================================================================
// 🛡️ FREEBUFF-POWER ENVIRONMENT VARIABLE GUARD
// ==============================================================================
const fs = require("fs");

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log("\x1b[33m\x1b[1m🛡️ [FREEBUFF-POWER ENV] Environment Variables Guard\x1b[0m");
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

const envExamplePath = fs.existsSync(".env.example") ? ".env.example" : (fs.existsSync(".env.sample") ? ".env.sample" : null);
const envPath = fs.existsSync(".env") ? ".env" : (fs.existsSync(".env.local") ? ".env.local" : null);

if (!envExamplePath) {
  console.log("ℹ️ Tidak ditemukan file .env.example / .env.sample.");
  if (envPath) console.log("✅ File " + envPath + " ditemukan.");
  process.exit(0);
}

const exampleKeys = fs.readFileSync(envExamplePath, "utf8")
  .split("\n")
  .map(l => l.trim())
  .filter(l => l && !l.startsWith("#") && l.includes("="))
  .map(l => l.split("=")[0].trim());

if (!envPath) {
  console.log(`\x1b[31m❌ File .env belum dibuat! Ada ${exampleKeys.length} variabel wajib yang dibutuhkan dari ${envExamplePath}.\x1b[0m`);
  process.exit(1);
}

const envKeys = fs.readFileSync(envPath, "utf8")
  .split("\n")
  .map(l => l.trim())
  .filter(l => l && !l.startsWith("#") && l.includes("="))
  .map(l => l.split("=")[0].trim());

const missing = exampleKeys.filter(k => !envKeys.includes(k));

if (missing.length === 0) {
  console.log(`\x1b[32m\x1b[1m🎉 Semua ${exampleKeys.length} Environment Variables Lengkap & Siap Deploy!\x1b[0m\n`);
} else {
  console.log(`\x1b[31m\x1b[1m⚠️ Terdeteksi ${missing.length} Variabel yang Belum Diisi di ${envPath}:\x1b[0m`);
  missing.forEach(m => console.log(`  - \x1b[33m${m}\x1b[0m`));
  console.log("\n👉 Harap isi variabel di atas sebelum menjalankan server di production!\n");
}

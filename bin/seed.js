#!/usr/bin/env node
// ==============================================================================
// 🎲 FREEBUFF-POWER INDONESIAN REALISTIC MOCK DATA SEEDER
// ==============================================================================
const fs = require("fs");
const path = require("path");

const count = parseInt(process.argv[2], 10) || 10;
const outputFile = process.argv[3] || "seed-data.json";

const firstNames = ["Budi", "Siti", "Andi", "Dewi", "Rizky", "Putri", "Fajar", "Nurul", "Dimas", "Eka", "Bambang", "Mega", "Agus", "Tri", "Hendro"];
const lastNames = ["Santoso", "Rahmawati", "Pratama", "Lestari", "Hidayat", "Kusuma", "Saputra", "Wulandari", "Setiawan", "Wijaya", "Siregar", "Nasution"];
const cities = ["Jakarta Selatan", "Surabaya", "Bandung", "Medan", "Semarang", "Yogyakarta", "Makassar", "Denpasar", "Malang", "Bekasi"];
const streets = ["Jl. Sudirman", "Jl. Gatot Subroto", "Jl. Malioboro", "Jl. Diponegoro", "Jl. Asia Afrika", "Jl. Pemuda", "Jl. Gajah Mada"];

function getRandomItem(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function generateUserData(idx) {
  const first = getRandomItem(firstNames);
  const last = getRandomItem(lastNames);
  const name = `${first} ${last}`;
  const email = `${first.toLowerCase()}.${last.toLowerCase()}${Math.floor(Math.random() * 900 + 100)}@gmail.com`;
  const phone = `08${Math.floor(Math.random() * 80 + 11)}${Math.floor(Math.random() * 90000000 + 10000000)}`;
  const address = `${getRandomItem(streets)} No. ${Math.floor(Math.random() * 120 + 1)}, ${getRandomItem(cities)}`;
  const balance = Math.floor(Math.random() * 5000 + 50) * 10000; // IDR 500.000 - 50.000.000

  return {
    id: idx + 1,
    name: name,
    email: email,
    phone: phone,
    address: address,
    balanceIdr: balance,
    createdAt: new Date().toISOString()
  };
}

const data = [];
for (let i = 0; i < count; i++) {
  data.push(generateUserData(i));
}

fs.writeFileSync(outputFile, JSON.stringify(data, null, 2));

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log("\x1b[33m\x1b[1m🎲 [FREEBUFF-POWER SEED] Indonesian Realistic Mock Data Generator\x1b[0m");
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");
console.log(`✅ Berhasil menghasilkan \x1b[32m\x1b[1m${count} data dummy realistis Indonesia\x1b[0m ke file: \x1b[36m${outputFile}\x1b[0m\n`);
console.log("📄 Cuplikan Data:");
console.log(JSON.stringify(data.slice(0, 2), null, 2));
console.log("\n\x1b[36m========================================================================\x1b[0m\n");

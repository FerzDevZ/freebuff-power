#!/usr/bin/env node
// ==============================================================================
// ⚡ FREEBUFF-POWER INSTANT API BENCHMARK & LATENCY PROFILER
// ==============================================================================
const http = require("http");
const https = require("https");
const { URL } = require("url");

const targetUrl = process.argv[2] || "http://localhost:3000";
const totalRequests = parseInt(process.argv[3], 10) || 50;

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log(`\x1b[33m\x1b[1m⚡ [FREEBUFF-POWER BENCH] Profiling Endpoint: ${targetUrl}\x1b[0m`);
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

let latencies = [];
let successCount = 0;
let failCount = 0;
let completed = 0;

const parsed = new URL(targetUrl);
const requester = parsed.protocol === "https:" ? https : http;

const startTime = Date.now();

for (let i = 0; i < totalRequests; i++) {
  const reqStart = Date.now();
  const req = requester.get(targetUrl, (res) => {
    res.on("data", () => {});
    res.on("end", () => {
      latencies.push(Date.now() - reqStart);
      successCount++;
      checkDone();
    });
  });

  req.on("error", () => {
    failCount++;
    checkDone();
  });

  req.end();
}

function checkDone() {
  completed++;
  if (completed === totalRequests) {
    const totalTime = (Date.now() - startTime) / 1000;
    latencies.sort((a, b) => a - b);

    const avg = latencies.length ? Math.round(latencies.reduce((a, b) => a + b, 0) / latencies.length) : 0;
    const p95 = latencies.length ? latencies[Math.floor(latencies.length * 0.95)] : 0;
    const min = latencies.length ? latencies[0] : 0;
    const max = latencies.length ? latencies[latencies.length - 1] : 0;
    const rps = (totalRequests / totalTime).toFixed(1);

    console.log("📊 HASIL BENCHMARK:");
    console.log(`  • Total Request   : ${totalRequests} requests`);
    console.log(`  • Sukses / Gagal  : \x1b[32m${successCount} sukses\x1b[0m / \x1b[31m${failCount} gagal\x1b[0m`);
    console.log(`  • Throughput      : \x1b[36m\x1b[1m${rps} Requests/sec\x1b[0m`);
    console.log(`  • Latency Rata-rata: \x1b[33m${avg} ms\x1b[0m (Min: ${min}ms, Max: ${max}ms)`);
    console.log(`  • Latency p95     : \x1b[35m${p95} ms\x1b[0m\n`);

    if (avg < 50) {
      console.log("\x1b[32m\x1b[1m🎉 PERFORMA KELAS ELIT (Ultra-Fast < 50ms)!\x1b[0m\n");
    } else if (avg < 200) {
      console.log("\x1b[33m\x1b[1m⚡ Performa Cepat & Layak Produksi (< 200ms).\x1b[0m\n");
    } else {
      console.log("\x1b[31m\x1b[1m⚠️ Performa Lambat (> 200ms). Disarankan menggunakan Caching / Indexing DB.\x1b[0m\n");
    }
  }
}

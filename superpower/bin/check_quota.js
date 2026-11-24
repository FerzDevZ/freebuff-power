const https = require("https");
const fs = require("fs");
const path = require("path");

const vaultDir = path.join(process.env.HOME, ".config/manicode/account_vault");
if (!fs.existsSync(vaultDir)) {
  if (process.argv.includes("--json")) {
    console.log("[]");
  } else if (!process.argv.includes("--first-ready")) {
    console.log("  (Folder vault belum ada. Gunakan 'freebuff-power account save <nama>')\n");
  }
  process.exit(0);
}

const files = fs.readdirSync(vaultDir).filter(f => f.endsWith(".json"));
if (files.length === 0) {
  if (process.argv.includes("--json")) {
    console.log("[]");
  } else if (!process.argv.includes("--first-ready")) {
    console.log("  (Belum ada akun di vault. Gunakan 'freebuff-power account save <nama>')\n");
  }
  process.exit(0);
}

function checkAccount(file) {
  return new Promise((resolve) => {
    try {
      const data = JSON.parse(fs.readFileSync(path.join(vaultDir, file), "utf8"));
      const token = data.default?.authToken || data.authToken;
      const email = data.default?.email || data.email || "Unknown";
      const name = path.basename(file, ".json");

      if (!token) {
        return resolve({ name, email, ready: false, statusCode: 0, statusText: "Kredensial Rusak", statusFormatted: "\x1b[31m⚪ Kredensial Rusak\x1b[0m" });
      }

      const req = https.request("https://www.codebuff.com/api/v1/freebuff/session", {
        method: "POST",
        headers: {
          "authorization": `Bearer ${token}`,
          "content-type": "application/json",
          "x-freebuff-model": "z-ai/glm-5.3-flash",
          "user-agent": "Freebuff-CLI/0.0.171",
        },
        timeout: 4500
      }, (res) => {
        let body = "";
        res.on("data", c => body += c);
        res.on("end", () => {
          if (res.statusCode === 200 || res.statusCode === 201) {
            resolve({ name, email, ready: true, statusCode: res.statusCode, statusText: "READY", statusFormatted: "\x1b[32m\x1b[1m🟢 READY (Kuota Aktif)\x1b[0m" });
          } else if (res.statusCode === 429) {
            if (body.includes("spend_limited")) {
              resolve({ name, email, ready: false, statusCode: 429, statusText: "LIMIT", statusFormatted: "\x1b[31m\x1b[1m🔴 HABIS KUOTA HARIAN (Reset 14:00 WIB)\x1b[0m" });
            } else if (body.includes("recentCount")) {
              try {
                const j = JSON.parse(body);
                resolve({ name, email, ready: false, statusCode: 429, statusText: "CAP_REACHED", statusFormatted: `\x1b[31m\x1b[1m🔴 CAP ${j.recentCount}/${j.limit} TERCAPAI (Reset 14:00 WIB)\x1b[0m` });
              } catch(e) {
                resolve({ name, email, ready: false, statusCode: 429, statusText: "RATE_LIMITED", statusFormatted: "\x1b[31m\x1b[1m🔴 RATE LIMITED (Reset 14:00 WIB)\x1b[0m" });
              }
            } else {
              resolve({ name, email, ready: false, statusCode: 429, statusText: "COOLDOWN", statusFormatted: "\x1b[33m\x1b[1m🟡 COOLDOWN (Tunggu beberapa menit)\x1b[0m" });
            }
          } else if (res.statusCode === 401 || res.statusCode === 403) {
            resolve({ name, email, ready: false, statusCode: res.statusCode, statusText: "EXPIRED", statusFormatted: "\x1b[31m❌ TOKEN KADALUARSA / EXPIRED\x1b[0m" });
          } else {
            resolve({ name, email, ready: false, statusCode: res.statusCode, statusText: `STATUS_${res.statusCode}`, statusFormatted: `\x1b[33m⚠️ STATUS ${res.statusCode}\x1b[0m` });
          }
        });
      });
      req.on("error", () => resolve({ name, email, ready: false, statusCode: -1, statusText: "OFFLINE", statusFormatted: "\x1b[2m⚠️ Network Offline\x1b[0m" }));
      req.on("timeout", () => { req.destroy(); resolve({ name, email, ready: false, statusCode: -2, statusText: "TIMEOUT", statusFormatted: "\x1b[2m⚠️ Timeout\x1b[0m" }); });
      req.write("{}");
      req.end();
    } catch(e) {
      resolve({ name: file, email: "Error", ready: false, statusCode: -3, statusText: "ERROR", statusFormatted: "\x1b[31m❌ Error\x1b[0m" });
    }
  });
}

(async () => {
  const isJson = process.argv.includes("--json");
  const isFirstReady = process.argv.includes("--first-ready");

  const promises = files.map(checkAccount);
  const results = await Promise.all(promises);

  if (isFirstReady) {
    const readyAcc = results.find(r => r.ready);
    if (readyAcc) {
      console.log(readyAcc.name);
      process.exit(0);
    } else {
      process.exit(1);
    }
  }

  if (isJson) {
    console.log(JSON.stringify(results, null, 2));
    process.exit(0);
  }

  results.forEach((r, idx) => {
    console.log(`  [${idx + 1}] \x1b[36m\x1b[1m${r.name}\x1b[0m (${r.email}) ➔ ${r.statusFormatted}`);
  });
})();

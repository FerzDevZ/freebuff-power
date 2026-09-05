const https = require("https");
const fs = require("fs");
const path = require("path");

const vaultDir = path.join(process.env.HOME, ".config/manicode/account_vault");
if (!fs.existsSync(vaultDir)) process.exit(0);

const files = fs.readdirSync(vaultDir).filter(f => f.endsWith(".json"));
if (files.length === 0) {
  console.log("  (Belum ada akun di vault. Gunakan 'freebuff-power account save <nama>')\n");
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
        return resolve({ name, email, status: "\x1b[31m⚪ Kredensial Rusak\x1b[0m" });
      }

      const req = https.request("https://www.codebuff.com/api/v1/freebuff/session", {
        method: "POST",
        headers: {
          "authorization": `Bearer ${token}`,
          "content-type": "application/json",
          "x-freebuff-model": "z-ai/glm-5.3-flash",
          "user-agent": "Freebuff-CLI/0.0.171",
        },
        timeout: 4000
      }, (res) => {
        let body = "";
        res.on("data", c => body += c);
        res.on("end", () => {
          if (res.statusCode === 200 || res.statusCode === 201) {
            resolve({ name, email, status: "\x1b[32m\x1b[1m🟢 READY (Kuota Aktif)\x1b[0m" });
          } else if (res.statusCode === 429) {
            if (body.includes("spend_limited")) {
              resolve({ name, email, status: "\x1b[31m\x1b[1m🔴 HABIS KUOTA HARIAN (Reset 14:00 WIB)\x1b[0m" });
            } else if (body.includes("recentCount")) {
              try {
                const j = JSON.parse(body);
                resolve({ name, email, status: `\x1b[31m\x1b[1m🔴 CAP ${j.recentCount}/${j.limit} TERCAPAI (Reset 14:00 WIB)\x1b[0m` });
              } catch(e) {
                resolve({ name, email, status: "\x1b[31m\x1b[1m🔴 RATE LIMITED (Reset 14:00 WIB)\x1b[0m" });
              }
            } else {
              resolve({ name, email, status: "\x1b[33m\x1b[1m🟡 COOLDOWN (Tunggu beberapa menit)\x1b[0m" });
            }
          } else if (res.statusCode === 401 || res.statusCode === 403) {
            resolve({ name, email, status: "\x1b[31m❌ TOKEN KADALUARSA / EXPIRED\x1b[0m" });
          } else {
            resolve({ name, email, status: `\x1b[33m⚠️ STATUS ${res.statusCode}\x1b[0m` });
          }
        });
      });
      req.on("error", () => resolve({ name, email, status: "\x1b[2m⚠️ Network Offline\x1b[0m" }));
      req.on("timeout", () => { req.destroy(); resolve({ name, email, status: "\x1b[2m⚠️ Timeout\x1b[0m" }); });
      req.write("{}");
      req.end();
    } catch(e) {
      resolve({ name: file, email: "Error", status: "\x1b[31m❌ Error\x1b[0m" });
    }
  });
}

(async () => {
  const promises = files.map(checkAccount);
  const results = await Promise.all(promises);
  results.forEach((r, idx) => {
    console.log(`  [${idx + 1}] \x1b[36m\x1b[1m${r.name}\x1b[0m (${r.email}) ➔ ${r.status}`);
  });
})();

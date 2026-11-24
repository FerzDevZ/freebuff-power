#!/usr/bin/env bash
# ==============================================================================
# 🌐 FREEBUFF-POWER INSTANT FULL-ACCESS VPN GATEWAY (OPENVPN / PROXY)
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

VPN_DIR="$HOME/.freebuff-vpn"
mkdir -p "$VPN_DIR"

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🌐 [FREEBUFF-POWER VPN] Fetching Top Full-Access Servers from VPNGate${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

echo -e "⏳ Mengunduh daftar server VPN tercepat (Japan, Singapore, US)..."

node -e '
const https = require("https");
const fs = require("fs");

https.get("https://www.vpngate.net/api/iphone/", (res) => {
  let raw = "";
  res.on("data", chunk => raw += chunk);
  res.on("end", () => {
    const lines = raw.split("\n");
    const servers = [];
    for (let i = 2; i < lines.length; i++) {
      const parts = lines[i].split(",");
      if (parts.length > 14) {
        const country = parts[6];
        const countryLong = parts[5];
        const ip = parts[1];
        const speed = Math.round(parseInt(parts[4] || 0) / (1024 * 1024));
        const ping = parts[3];
        const ovpnB64 = parts[14];
        if (["JP", "SG", "US"].includes(country)) {
          servers.push({ country, countryLong, ip, speed, ping, ovpnB64 });
        }
      }
    }
    servers.sort((a, b) => b.speed - a.speed);
    
    const top = servers.slice(0, 5);
    console.log("\n\x1b[32m\x1b[1m🏆 TOP 5 SERVER TERCEPAT UNTUK FULL ACCESS:\x1b[0m");
    top.forEach((s, idx) => {
      const file = `'$VPN_DIR'/${s.country}_${s.ip}.ovpn`;
      fs.writeFileSync(file, Buffer.from(s.ovpnB64, "base64").toString("utf8"));
      console.log(`  [${idx+1}] \x1b[1m${s.countryLong} (${s.country})\x1b[0m — IP: \x1b[36m${s.ip}\x1b[0m | Speed: \x1b[33m${s.speed} Mbps\x1b[0m | Ping: ${s.ping}ms`);
      console.log(`      📁 Config: ${file}`);
    });
  });
});
'

echo -e "\n${C_GREEN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}💡 CARA MENGHUBUNGKAN VPN DI LINUX (1 KLIK):${C_RESET}"
echo -e "   ${C_CYAN}sudo openvpn --config $VPN_DIR/<nama-file>.ovpn${C_RESET}"
echo -e "\n${C_YELLOW}💡 ATAU JIKA MENGGUNAKAN WINDOWS / ANDROID:${C_RESET}"
echo -e "   Impor file .ovpn di atas ke aplikasi \033[1mOpenVPN Connect\033[0m."
echo -e "${C_GREEN}${C_BOLD}========================================================================${C_RESET}\n"

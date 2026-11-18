#!/usr/bin/env bash
# ==============================================================================
# 📂 FREEPI-POWER SESSION MANAGER (Reads ~/.free-pi/agent/sessions)
# ==============================================================================
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

ACTION="${1:-list}"

case "$ACTION" in
  list|ls|--list|-l)
    node -e '
const fs = require("fs");
const path = require("path");
const os = require("os");

const sessionsRoot = path.join(os.homedir(), ".free-pi", "agent", "sessions");
const currentCwd = path.resolve(process.cwd());

const C = {
  cyan: "\x1b[36m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  purple: "\x1b[35m",
  dim: "\x1b[2m",
  bold: "\x1b[1m",
  reset: "\x1b[0m"
};

console.log(`${C.cyan}${C.bold}========================================================================================${C.reset}`);
console.log(`${C.yellow}${C.bold}📂 FREEPI-POWER SESSIONS (~/.free-pi/agent/sessions)${C.reset}`);
console.log(`${C.cyan}${C.bold}========================================================================================${C.reset}\n`);

if (!fs.existsSync(sessionsRoot)) {
  console.log(`${C.yellow}Belum ada sesi FreePi tersimpan.${C.reset}`);
  console.log(`Mulai sesi baru dengan: ${C.green}freepi-power start${C.reset}\n`);
  process.exit(0);
}

const sessions = [];
for (const dirEntry of fs.readdirSync(sessionsRoot, { withFileTypes: true })) {
  if (!dirEntry.isDirectory()) continue;
  const fullDir = path.join(sessionsRoot, dirEntry.name);
  for (const fileEntry of fs.readdirSync(fullDir, { withFileTypes: true })) {
    if (!fileEntry.isFile() || !fileEntry.name.endsWith(".jsonl")) continue;
    const filePath = path.join(fullDir, fileEntry.name);
    const stat = fs.statSync(filePath);
    let id = fileEntry.name.replace(/\.jsonl$/, "").split("_").pop();
    let cwd = dirEntry.name;
    let model = "-";
    let firstMsg = "";

    try {
      const content = fs.readFileSync(filePath, "utf8");
      const lines = content.split("\n");
      for (const line of lines) {
        if (!line.trim()) continue;
        let obj;
        try { obj = JSON.parse(line); } catch { continue; }
        if (obj.type === "session") {
          if (obj.id) id = obj.id;
          if (obj.cwd) cwd = obj.cwd;
        } else if (obj.type === "model_change" && obj.modelId) {
          model = obj.modelId;
        } else if (!firstMsg && obj.type === "message" && obj.message && obj.message.role === "user") {
          const c = obj.message.content;
          if (typeof c === "string") {
            firstMsg = c.replace(/\s+/g, " ").trim();
          } else if (Array.isArray(c)) {
            const textPart = c.find(p => p && p.type === "text" && p.text);
            if (textPart) firstMsg = String(textPart.text).replace(/\s+/g, " ").trim();
          }
        }
      }
    } catch {}

    sessions.push({
      id,
      cwd,
      model,
      firstMsg: firstMsg ? (firstMsg.length > 65 ? firstMsg.slice(0, 62) + "..." : firstMsg) : "(belum ada prompt)",
      mtime: stat.mtime,
      sizeKb: Math.max(1, Math.round(stat.size / 1024)),
      isCurrentDir: path.resolve(cwd) === currentCwd
    });
  }
}

if (sessions.length === 0) {
  console.log(`${C.yellow}Belum ada sesi FreePi tersimpan.${C.reset}`);
  console.log(`Mulai sesi baru dengan: ${C.green}freepi-power start${C.reset}\n`);
  process.exit(0);
}

sessions.sort((a, b) => b.mtime - a.mtime);

const currentSessions = sessions.filter(s => s.isCurrentDir);
const otherSessions = sessions.filter(s => !s.isCurrentDir);

function printList(title, list) {
  if (list.length === 0) return;
  console.log(`${C.purple}${C.bold}${title} (${list.length}):${C.reset}`);
  for (const s of list.slice(0, 15)) {
    const dt = s.mtime.toLocaleString("id-ID", { hour12: false });
    console.log(`  ${C.green}${C.bold}${s.id}${C.reset}  ${C.dim}[${dt} | ${s.model} | ${s.sizeKb}KB]${C.reset}`);
    console.log(`    📁 ${C.cyan}${s.cwd}${C.reset}`);
    console.log(`    💬 ${s.firstMsg}`);
  }
  console.log("");
}

if (currentSessions.length > 0) {
  printList(`📍 SESI DI FOLDER AKTIF (${currentCwd})`, currentSessions);
}
printList("🌐 SESI DI FOLDER LAIN", otherSessions);

console.log(`${C.bold}CARA MELANJUTKAN SESI:${C.reset}`);
console.log(`  ${C.green}freepi-power session <id>${C.reset}      Lanjutkan sesi spesifik berdasarkan ID di atas`);
console.log(`  ${C.green}freepi-power continue${C.reset}          Lanjutkan sesi terakhir di folder aktif`);
console.log(`  ${C.green}freepi-power session new${C.reset}       Mulai sesi baru yang bersih di folder aktif\n`);
'
    ;;

  pick|select|open)
    SESSION_LIST=$(node -e '
const fs = require("fs");
const path = require("path");
const os = require("os");
const root = path.join(os.homedir(), ".free-pi", "agent", "sessions");
if (!fs.existsSync(root)) process.exit(0);
const out = [];
for (const d of fs.readdirSync(root, { withFileTypes: true })) {
  if (!d.isDirectory()) continue;
  for (const f of fs.readdirSync(path.join(root, d.name), { withFileTypes: true })) {
    if (!f.isFile() || !f.name.endsWith(".jsonl")) continue;
    const fp = path.join(root, d.name, f.name);
    const stat = fs.statSync(fp);
    let id = f.name.replace(/\.jsonl$/, "").split("_").pop();
    let cwd = d.name, model = "-";
    try {
      for (const line of fs.readFileSync(fp, "utf8").split("\n").slice(0, 15)) {
        if (!line.trim()) continue;
        const o = JSON.parse(line);
        if (o.type === "session") { if (o.id) id = o.id; if (o.cwd) cwd = o.cwd; }
        else if (o.type === "model_change" && o.modelId) model = o.modelId;
      }
    } catch {}
    out.push({ id, cwd, model, mtime: stat.mtimeMs });
  }
}
out.sort((a, b) => b.mtime - a.mtime);
out.slice(0, 15).forEach((s, i) => console.log(`${i + 1}|${s.id}|${s.cwd}|${s.model}`));
')
    if [ -z "$SESSION_LIST" ]; then
      echo -e "\033[0;33mBelum ada sesi FreePi tersimpan. Jalankan 'freepi-power start'.\033[0m"
      exit 0
    fi
    echo -e "\033[0;36m\033[1m📂 PILIH SESI FREEPI UNTUK DILANJUTKAN:\033[0m\n"
    while IFS='|' read -r idx sid scwd smodel; do
      echo -e "  \033[0;32m\033[1m[${idx}]\033[0m ${sid}  \033[2m(${smodel})\033[0m — \033[0;36m${scwd}\033[0m"
    done <<< "$SESSION_LIST"
    echo ""
    read -r -p "Masukkan nomor sesi (1-15, atau Enter untuk batal): " CHOICE
    if [ -z "${CHOICE:-}" ]; then
      exit 0
    fi
    SELECTED_ID=$(echo "$SESSION_LIST" | awk -F'|' -v n="$CHOICE" '$1 == n { print $2; exit }')
    if [ -z "$SELECTED_ID" ]; then
      echo -e "\033[0;31m❌ Nomor sesi tidak valid: $CHOICE\033[0m"
      exit 1
    fi
    exec "$SCRIPT_DIR/freepi-runner.sh" --session "$SELECTED_ID"
    ;;

  continue|resume|last)
    exec "$SCRIPT_DIR/freepi-runner.sh" --continue
    ;;

  new|fresh)
    exec "$SCRIPT_DIR/freepi-runner.sh" --new
    ;;

  -h|--help|help)
    echo -e "\033[1mPenggunaan freepi-power session:\033[0m"
    echo -e "  \033[0;32mfreepi-power session\033[0m           Tampilkan daftar semua sesi FreePi tersimpan"
    echo -e "  \033[0;32mfreepi-power session pick\033[0m      Pilih sesi lewat nomor urut interaktif (tanpa copy UUID)"
    echo -e "  \033[0;32mfreepi-power session <id>\033[0m      Buka & lanjutkan sesi dengan ID tertentu"
    echo -e "  \033[0;32mfreepi-power session continue\033[0m  Lanjutkan sesi terakhir di folder aktif"
    echo -e "  \033[0;32mfreepi-power session new\033[0m       Mulai sesi baru yang bersih"
    ;;

  *)
    # Treat argument as a session ID and resume via free-pi-cli --session <id>
    exec "$SCRIPT_DIR/freepi-runner.sh" --session "$ACTION"
    ;;
esac

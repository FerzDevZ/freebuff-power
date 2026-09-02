#!/usr/bin/env node
// ==============================================================================
// 📋 FREEBUFF-POWER ADVANCED SESSION MANAGER & CHAT RESUME ENGINE
// ==============================================================================
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

const projectsDir = path.join(process.env.HOME, ".config/manicode/projects");
const currentFolder = path.basename(process.cwd());

function getSessionsForProject(projectName) {
  const pPath = path.join(projectsDir, projectName, "chats");
  if (!fs.existsSync(pPath)) return [];

  const chatDirs = fs.readdirSync(pPath).filter(d => {
    return fs.statSync(path.join(pPath, d)).isDirectory();
  });

  const sessions = [];
  for (const c of chatDirs) {
    const metaFile = path.join(pPath, c, "chat-meta.json");
    let meta = { messageCount: 0, firstPrompt: "(Tanpa prompt)" };
    if (fs.existsSync(metaFile)) {
      try {
        meta = JSON.parse(fs.readFileSync(metaFile, "utf8"));
      } catch (e) {}
    }
    const stat = fs.statSync(path.join(pPath, c));
    sessions.push({
      id: c,
      project: projectName,
      prompt: meta.firstPrompt || "(Tanpa prompt)",
      messages: meta.messageCount || 0,
      time: stat.mtime
    });
  }

  return sessions.sort((a, b) => b.time - a.time);
}

function getAllSessions() {
  if (!fs.existsSync(projectsDir)) return [];
  const projects = fs.readdirSync(projectsDir).filter(p => {
    return fs.statSync(path.join(projectsDir, p)).isDirectory();
  });

  let all = [];
  for (const p of projects) {
    all = all.concat(getSessionsForProject(p));
  }
  return all.sort((a, b) => b.time - a.time);
}

const args = process.argv.slice(2);
const cmd = args[0] || "list";

if (cmd === "list" || cmd === "ls") {
  console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
  console.log("\x1b[33m\x1b[1m📋 [SESSION & CHAT MANAGER] Riwayat Percakapan Freebuff\x1b[0m");
  console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

  const localSessions = getSessionsForProject(currentFolder);
  if (localSessions.length > 0) {
    console.log(`\x1b[32m\x1b[1m📁 Sesi di Folder Saat Ini (${currentFolder}):\x1b[0m`);
    localSessions.forEach((s, idx) => {
      const timeStr = s.time.toLocaleString();
      const promptSnippet = s.prompt.length > 40 ? s.prompt.slice(0, 40) + "..." : s.prompt;
      console.log(`  [${idx + 1}] \x1b[36m\x1b[1m${s.id}\x1b[0m \x1b[90m(${timeStr})\x1b[0m`);
      console.log(`      \x1b[33mPrompt:\x1b[0m "${promptSnippet}" \x1b[90m(${s.messages} pesan)\x1b[0m`);
    });
    console.log("");
  }

  const allSessions = getAllSessions();
  if (allSessions.length === 0) {
    console.log("  (Belum ada riwayat sesi tersimpan di ~/.config/manicode/projects/)\n");
  } else {
    console.log(`\x1b[35m\x1b[1m🌐 Seluruh Sesi Tersimpan (${allSessions.length} total sesi):\x1b[0m`);
    allSessions.slice(0, 10).forEach((s, idx) => {
      console.log(`  - \x1b[36m${s.id}\x1b[0m \x1b[33m[${s.project}]\x1b[0m: "${s.prompt.slice(0, 30)}" \x1b[90m(${s.messages} pesan)\x1b[0m`);
    });
    console.log("\n\x1b[90m👉 Cara Melanjutkan Sesi:\x1b[0m");
    console.log("  \x1b[36mfreebuff-power continue\x1b[0m            \x1b[90m# Lanjutkan sesi paling terakhir di folder ini\x1b[0m");
    console.log("  \x1b[36mfreebuff-power continue <session-id>\x1b[0m\x1b[90m# Lanjutkan sesi spesifik berdasarkan ID\x1b[0m\n");
  }
} else if (cmd === "continue" || cmd === "resume") {
  let targetId = args[1];

  if (!targetId) {
    // Pick the most recent session for current folder
    const localSessions = getSessionsForProject(currentFolder);
    if (localSessions.length > 0) {
      targetId = localSessions[0].id;
    } else {
      const allSessions = getAllSessions();
      if (allSessions.length > 0) {
        targetId = allSessions[0].id;
      }
    }
  }

  if (!targetId) {
    console.log("\x1b[33m⚠️ Tidak ada sesi sebelumnya yang ditemukan. Membuka sesi baru...\x1b[0m");
    const child = spawn("freebuff-power", ["start"], { stdio: "inherit" });
    child.on("exit", (code) => process.exit(code || 0));
  } else {
    console.log(`\x1b[32m\x1b[1m🚀 Melanjutkan sesi Freebuff: \x1b[36m${targetId}\x1b[0m\n`);
    const child = spawn("freebuff", ["--continue", targetId], { stdio: "inherit" });
    child.on("exit", (code) => process.exit(code || 0));
  }
}

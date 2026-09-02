#!/usr/bin/env node
// ==============================================================================
// 🧠 FREEBUFF-POWER COMPOSER 2.0 (INTELLIGENT SWARM RECIPE ENGINE)
// ==============================================================================
const { execSync } = require("child_process");
const path = require("path");

const args = process.argv.slice(2);
const autoRun = args.includes("-r") || args.includes("--run");
const task = args.filter(a => a !== "-r" && a !== "--run").join(" ");

if (!task) {
  console.log("Penggunaan: freebuff-power compose \"Tugas koding yang ingin dikerjakan\" [-r]");
  process.exit(1);
}

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log("\x1b[33m\x1b[1m🧠 [FREEBUFF-POWER COMPOSER 2.0] Menganalisis Kebutuhan Arsitektur...\x1b[0m");
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

console.log(`🎯 Target Tugas: \x1b[1m"${task}"\x1b[0m\n`);

let selectedAgents = ["@architect", "@programmer"];
let selectedSkills = ["autonomous-swe-loop-healer", "anti-slop-concise"];

const lower = task.toLowerCase();
if (lower.includes("ui") || lower.includes("landing") || lower.includes("frontend") || lower.includes("react") || lower.includes("next")) {
  selectedAgents.push("@frontend", "@design-engineer");
  selectedSkills.push("bento-grid-dashboard-ui", "accessible-wcag-aaa-keyboard-aria");
}
if (lower.includes("api") || lower.includes("backend") || lower.includes("auth") || lower.includes("jwt") || lower.includes("login")) {
  selectedAgents.push("@backend", "@api-security-shield", "@application-security-pentester");
  selectedSkills.push("api-security-bola-shield", "owasp-asvs-defensive-audit");
}
if (lower.includes("db") || lower.includes("database") || lower.includes("sql") || lower.includes("postgres") || lower.includes("prisma")) {
  selectedAgents.push("@database");
  selectedSkills.push("database-administrator", "postgres-pro");
}
if (lower.includes("rag") || lower.includes("ai") || lower.includes("vector") || lower.includes("llm")) {
  selectedAgents.push("@rag-vector-specialist", "@deepseek-reasoner-pro");
  selectedSkills.push("agentic-rag-hybrid-reranking-cohere");
}

console.log("\x1b[32m\x1b[1m✨ Resep Swarm Optimal Berhasil Diracik:\x1b[0m");
console.log("👥 Sub-Agents : " + selectedAgents.join(", "));
console.log("🧰 Skills     : " + selectedSkills.map(s => `[Skill: ${s}]`).join(", "));
console.log("\n\x1b[36m========================================================================\x1b[0m\n");

const finalPrompt = `[Swarm Recipe: ${selectedAgents.join(" + ")} | Skills: ${selectedSkills.join(", ")}] ${task}`;

if (autoRun) {
  console.log("🚀 Menjalankan Freebuff secara otomatis...\n");
  const scriptDir = __dirname;
  execSync(`"${path.join(scriptDir, "init.sh")}" . >/dev/null 2>&1 || true`);
  require("child_process").spawn(path.join(scriptDir, "run.sh"), [finalPrompt], { stdio: "inherit" });
} else {
  console.log("💡 Jalankan dengan opsi -r untuk langsung eksekusi:");
  console.log(`   freebuff-power compose "${task}" -r\n`);
}

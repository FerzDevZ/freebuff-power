#!/usr/bin/env node
// ==============================================================================
// 🧠 FREEBUFF-POWER COMPOSER 3.0 (AUTONOMOUS SWARM COGNITIVE SYNTHESIZER)
// Deep Task Decomposition, Domain Sensing & Dynamic Agent-Skill Wiring
// ==============================================================================
const { execSync, spawn } = require("child_process");
const path = require("path");
const fs = require("fs");

const args = process.argv.slice(2);
const autoRun = args.includes("-r") || args.includes("--run");
const task = args.filter(a => a !== "-r" && a !== "--run").join(" ").trim();

if (!task) {
  console.log("\x1b[33mPenggunaan: freebuff-power compose \"<Tugas koding yang ingin dikerjakan>\" [-r]\x1b[0m");
  console.log("Contoh: freebuff-power compose \"Buat sistem auth JWT dengan refresh token & database Postgres\" -r");
  process.exit(1);
}

console.log("\x1b[36m\x1b[1m================================================================================\x1b[0m");
console.log("\x1b[33m\x1b[1m🧠 [FREEBUFF-POWER COMPOSER 3.0] Autonomous Swarm Synthesizer & Router\x1b[0m");
console.log("\x1b[36m\x1b[1m================================================================================\x1b[0m\n");

console.log(`🎯 Target Tugas: \x1b[1m"${task}"\x1b[0m\n`);

let selectedAgents = new Set(["@architect", "@programmer"]);
let selectedSkills = new Set(["autonomous-swe-loop-healer", "clean-code-anti-slop"]);

const lower = task.toLowerCase();

// Domain 1: Frontend, UI/UX & Design Systems
if (/\b(ui|ux|frontend|landing|dashboard|tailwind|shadcn|component|css|design|framer|animation|bento)\b/.test(lower)) {
  selectedAgents.add("@frontend");
  selectedAgents.add("@design-engineer");
  selectedSkills.add("bento-grid-dashboard-ui");
  selectedSkills.add("tailwind-v4-shadcn-system");
  selectedSkills.add("accessible-wcag-aaa-keyboard-aria");
  selectedSkills.add("anti-ai-slop-design-craftsman");
}

// Domain 2: Backend APIs, Auth & Microservices
if (/\b(api|backend|auth|jwt|oauth|session|login|signup|rest|grpc|fastify|express|nest|endpoint)\b/.test(lower)) {
  selectedAgents.add("@backend");
  selectedAgents.add("@api-security-shield");
  selectedAgents.add("@security");
  selectedSkills.add("authflow-security-architect");
  selectedSkills.add("api-design-rest-grpc-graphql");
  selectedSkills.add("idempotency-distributed-transactions");
}

// Domain 3: Databases & Data Engineering
if (/\b(db|database|sql|postgres|postgresql|prisma|drizzle|mongo|redis|clickhouse|sqlite|migration|query)\b/.test(lower)) {
  selectedAgents.add("@database");
  selectedSkills.add("database-architect-optimization");
  selectedSkills.add("postgres-pro");
  selectedSkills.add("redis-distributed-locking-caching");
}

// Domain 4: Mobile & Cross-Platform (Flutter / React Native)
if (/\b(flutter|dart|mobile|android|ios|bloc|riverpod|react-native|expo)\b/.test(lower)) {
  selectedAgents.add("@flutter-specialist");
  selectedAgents.add("@mobile-engineer");
  selectedSkills.add("flutter-clean-architecture-tdd");
  selectedSkills.add("flutter-bloc-riverpod-state");
}

// Domain 5: AI, LLM, RAG & Machine Learning
if (/\b(rag|ai|vector|llm|embedding|langchain|langgraph|deepseek|openai|vllm|finetuning|vision|vlm|agentic)\b/.test(lower)) {
  selectedAgents.add("@rag-vector-specialist");
  selectedAgents.add("@ai-engineer");
  selectedAgents.add("@deepseek-reasoner-pro");
  selectedSkills.add("rag-llm-integrator");
  selectedSkills.add("prompt-engineering-evals");
}

// Domain 6: Web3, Crypto & Smart Contracts
if (/\b(solidity|smart-contract|web3|ethereum|token|crypto|solana|blockchain|evm|foundry)\b/.test(lower)) {
  selectedAgents.add("@smart-contract-auditor");
  selectedAgents.add("@tokenomics-fintech-ledger");
  selectedSkills.add("smart-contract-web3-security");
}

// Domain 7: DevOps, Containers & Cloud
if (/\b(docker|k8s|kubernetes|devops|ci|cd|github-actions|deploy|aws|gcp|terraform|helm)\b/.test(lower)) {
  selectedAgents.add("@cloud-native-devops-k8s");
  selectedAgents.add("@devops");
  selectedSkills.add("docker-container-master");
  selectedSkills.add("github-actions-ci-cd");
}

// Domain 8: Testing & Bug Triage
if (/\b(test|testing|tdd|unit|e2e|playwright|vitest|jest|bug|fix|heal|error)\b/.test(lower)) {
  selectedAgents.add("@tddmaster");
  selectedAgents.add("@qa");
  selectedAgents.add("@debugger");
  selectedSkills.add("unit-integration-tdd-master");
  selectedSkills.add("e2e-playwright-automation");
}

// Domain 9: Realtime WebSockets & Streaming
if (/\b(websocket|webrtc|socket|realtime|stream|sse|live|presence)\b/.test(lower)) {
  selectedAgents.add("@websocket-realtime");
  selectedSkills.add("websocket-realtime-architect");
}

const agentsArray = Array.from(selectedAgents);
const skillsArray = Array.from(selectedSkills);

console.log("\x1b[32m\x1b[1m✨ Resep Swarm Optimal Berhasil Disintesis:\x1b[0m");
console.log(`👥 \x1b[1mSub-Agents (${agentsArray.length})\x1b[0m : \x1b[36m` + agentsArray.join(", ") + "\x1b[0m");
console.log(`🧰 \x1b[1mModular Skills (${skillsArray.length})\x1b[0m: \x1b[35m` + skillsArray.map(s => `[Skill: ${s}]`).join(", ") + "\x1b[0m");
console.log("\n\x1b[36m================================================================================\x1b[0m\n");

let promptContextParts = [];

// 1. Load active agent role specifications
for (const ag of agentsArray) {
  const agClean = ag.replace(/^@/, "");
  const candPaths = [
    path.join(process.cwd(), ".agents", "agents", `${agClean}.md`),
    path.join(__dirname, "..", "superpower", "agents", `${agClean}.md`),
    path.join(process.env.HOME || "", ".agents", "agents", `${agClean}.md`),
  ];
  for (const cp of candPaths) {
    if (fs.existsSync(cp)) {
      try {
        const content = fs.readFileSync(cp, "utf-8");
        promptContextParts.push(`### [Persona & SOP: ${ag}]\n${content.trim()}`);
      } catch {}
      break;
    }
  }
}

// 2. Load active skill directives
promptContextParts.push(`### [Active Directives: JIT Loaded Skills]
Skills are available at .agents/skills/<name>/SKILL.md. Use the native skill tool or consult them:
${skillsArray.map(s => `- ${s}: Loaded in context. Consult .agents/skills/${s}/SKILL.md`).join("\n")}`);

const finalPrompt = `${promptContextParts.join("\n\n---\n\n")}

================================================================================
USER CODING TASK:
${task}
================================================================================`;

if (autoRun) {
  console.log("\x1b[32m\x1b[1m🚀 Meluncurkan Freebuff dengan Swarm Recipe yang telah diracik...\x1b[0m\n");
  const scriptDir = __dirname;
  execSync(`"${path.join(scriptDir, "init.sh")}" . >/dev/null 2>&1 || true`);
  const runner = spawn(path.join(scriptDir, "run.sh"), [finalPrompt], { stdio: "inherit" });
  runner.on("exit", (code) => process.exit(code || 0));
} else {
  console.log("💡 \x1b[1mTips:\x1b[0m Tambahkan flag \x1b[33m-r\x1b[0m untuk langsung mengeksekusi resep ini:");
  console.log(`   \x1b[36mfreebuff-power compose "${task}" -r\x1b[0m\n`);
}

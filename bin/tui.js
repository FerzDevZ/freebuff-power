#!/usr/bin/env node
// ==============================================================================
// ⚡ FREEBUFF-POWER INTERACTIVE TUI DASHBOARD 3.0 (v8.5-Titanium)
// Tabs: [1] Agents | [2] Skills | [3] Accounts Vault | [4] Free Models
// ==============================================================================
const readline = require("readline");
const fs = require("fs");
const path = require("path");
const { execSync, spawn } = require("child_process");

const repoRoot = path.resolve(__dirname, "..");
const agentsDir = fs.existsSync(path.join(repoRoot, "superpower/agents"))
  ? path.join(repoRoot, "superpower/agents")
  : path.join(process.env.HOME, ".freebuff-superpower/agents");

const skillsDir = fs.existsSync(path.join(repoRoot, "superpower/skills"))
  ? path.join(repoRoot, "superpower/skills")
  : path.join(process.env.HOME, ".freebuff-superpower/skills");

const vaultDir = path.join(process.env.HOME, ".config/manicode/account_vault");

const agents = fs.existsSync(agentsDir) ? fs.readdirSync(agentsDir).filter(f => f.endsWith(".md")).map(f => ({
  name: "@" + f.replace(/\.md$/, ""),
  file: path.join(agentsDir, f),
  type: "agent"
})) : [];

const skills = fs.existsSync(skillsDir) ? fs.readdirSync(skillsDir).filter(f => f.endsWith(".md")).map(f => ({
  name: "[Skill: " + f.replace(/\.md$/, "") + "]",
  file: path.join(skillsDir, f),
  type: "skill"
})) : [];

const proxyModels = [
  { name: "z-ai/glm-5.3-flash", desc: "⭐ UNMETERED — Deepest reasoning, free without session limit" },
  { name: "deepseek/deepseek-v4-flash", desc: "⚡ UNMETERED — Ultra fast coding & tool use" },
  { name: "mimo/mimo-v2.5", desc: "🖼️ UNMETERED — Multimodal image + code support" },
  { name: "openai/gpt-5.6-luna", desc: "🌙 METERED — General high capability" },
  { name: "meta/muse-spark-1.2-contributor", desc: "🔥 METERED — 1M context agentic model" },
  { name: "anthropic/claude-fable-5", desc: "🏛️ METERED — Claude architecture master" },
  { name: "google/gemini-3.8-flash", desc: "⚡ METERED — Fast Google inference" }
];

let activeTab = "agents"; // "agents" | "skills" | "accounts" | "models"
let selectedAgents = new Set();
let selectedSkills = new Set();
let selectedModel = "z-ai/glm-5.3-flash";
let cursorIndex = 0;
let searchQuery = "";
let isSearching = false;
let statusMessage = "";

function clearScreen() {
  process.stdout.write("\x1b[2J\x1b[0;0H");
}

function getAccounts() {
  if (!fs.existsSync(vaultDir)) return [];
  const files = fs.readdirSync(vaultDir).filter(f => f.endsWith(".json"));
  const activeCredsFile = path.join(process.env.HOME, ".config/manicode/credentials.json");
  let activeEmail = "";
  if (fs.existsSync(activeCredsFile)) {
    try {
      const c = JSON.parse(fs.readFileSync(activeCredsFile, "utf8"));
      activeEmail = c.default?.email || c.email || "";
    } catch (e) {}
  }

  return files.map(f => {
    const filePath = path.join(vaultDir, f);
    const name = f.replace(/\.json$/, "");
    let email = "Unknown";
    try {
      const c = JSON.parse(fs.readFileSync(filePath, "utf8"));
      email = c.default?.email || c.email || "Unknown";
    } catch (e) {}
    const isActive = email && activeEmail && email === activeEmail;
    return {
      name: `${name} (${email})`,
      accountName: name,
      email,
      isActive,
      file: filePath,
      type: "account"
    };
  });
}

function getItems() {
  let list = [];
  if (activeTab === "agents") list = agents;
  else if (activeTab === "skills") list = skills;
  else if (activeTab === "accounts") list = getAccounts();
  else if (activeTab === "models") list = proxyModels;

  if (searchQuery) {
    list = list.filter(i => i.name.toLowerCase().includes(searchQuery.toLowerCase()));
  }
  return list;
}

function render() {
  clearScreen();
  const items = getItems();
  const width = process.stdout.columns || 80;
  const height = process.stdout.rows || 24;

  console.log("\x1b[36m\x1b[1m" + "=".repeat(width) + "\x1b[0m");
  console.log(`\x1b[33m\x1b[1m⚡ FREEBUFF-POWER INTERACTIVE TUI DASHBOARD (v8.5-Titanium)\x1b[0m`);
  console.log("\x1b[36m" + "=".repeat(width) + "\x1b[0m");

  // Tabs Header
  const tabA = activeTab === "agents" ? `\x1b[44m\x1b[37m\x1b[1m [1] 👥 Agents (${agents.length}) \x1b[0m` : `\x1b[90m [1] 👥 Agents (${agents.length}) \x1b[0m`;
  const tabS = activeTab === "skills" ? `\x1b[45m\x1b[37m\x1b[1m [2] 🧰 Skills (${skills.length}) \x1b[0m` : `\x1b[90m [2] 🧰 Skills (${skills.length}) \x1b[0m`;
  const tabV = activeTab === "accounts" ? `\x1b[42m\x1b[30m\x1b[1m [3] 👤 Vault \x1b[0m` : `\x1b[90m [3] 👤 Vault \x1b[0m`;
  const tabM = activeTab === "models" ? `\x1b[43m\x1b[30m\x1b[1m [4] 🤖 Models \x1b[0m` : `\x1b[90m [4] 🤖 Models \x1b[0m`;
  console.log(`TABS: ${tabA} ${tabS} ${tabV} ${tabM}`);
  console.log(`\x1b[32m[Active Selection: ${selectedAgents.size} Agents, ${selectedSkills.size} Skills | Model: ${selectedModel}]\x1b[0m`);

  if (statusMessage) {
    console.log(`\x1b[33m\x1b[1mℹ️  ${statusMessage}\x1b[0m`);
  } else if (isSearching || searchQuery) {
    console.log(`\x1b[33m🔍 Search filter: \x1b[1m${searchQuery}\x1b[0m\x1b[33m_\x1b[0m`);
  } else {
    console.log(`\x1b[90mTekan 1-4 untuk ganti Tab | '/' Cari | [Space] Pilih/Aksi | [Enter] Luncurkan | [Q] Keluar\x1b[0m`);
  }
  console.log("\x1b[90m" + "-".repeat(width) + "\x1b[0m");

  // Render list
  const maxView = Math.min(items.length, Math.max(5, height - 13));
  const startIdx = Math.max(0, Math.min(cursorIndex - Math.floor(maxView / 2), items.length - maxView));

  for (let i = 0; i < maxView; i++) {
    const idx = startIdx + i;
    const item = items[idx];
    if (!item) break;

    const isCursor = idx === cursorIndex;
    let checkSymbol = "\x1b[90m[ ]\x1b[0m";

    if (activeTab === "agents") {
      checkSymbol = selectedAgents.has(item.name) ? "\x1b[32m[✓]\x1b[0m" : "\x1b[90m[ ]\x1b[0m";
    } else if (activeTab === "skills") {
      checkSymbol = selectedSkills.has(item.name) ? "\x1b[32m[✓]\x1b[0m" : "\x1b[90m[ ]\x1b[0m";
    } else if (activeTab === "accounts") {
      checkSymbol = item.isActive ? "\x1b[32m[AKTIF]\x1b[0m" : "\x1b[90m[Vault]\x1b[0m";
    } else if (activeTab === "models") {
      checkSymbol = selectedModel === item.name ? "\x1b[33m[★]\x1b[0m" : "\x1b[90m[ ]\x1b[0m";
    }

    const cursorSymbol = isCursor ? "\x1b[33m\x1b[1m❯ \x1b[0m" : "  ";
    const nameFormatted = isCursor ? `\x1b[1m\x1b[37m${item.name}\x1b[0m` : item.name;

    console.log(`${cursorSymbol}${checkSymbol} ${nameFormatted}`);
  }

  // Preview Box at Bottom
  console.log("\x1b[90m" + "-".repeat(width) + "\x1b[0m");
  const currentItem = items[cursorIndex];
  if (currentItem) {
    if (activeTab === "agents" || activeTab === "skills") {
      console.log(`\x1b[36m\x1b[1m📖 PREVIEW: ${currentItem.name}\x1b[0m`);
      try {
        const content = fs.readFileSync(currentItem.file, "utf8");
        const previewLines = content.split("\n").filter(l => l.trim().length > 0 && !l.startsWith("---")).slice(0, 3);
        for (const line of previewLines) {
          console.log(`  \x1b[90m${line.slice(0, width - 4)}\x1b[0m`);
        }
      } catch (e) {
        console.log("  (Preview tidak tersedia)");
      }
    } else if (activeTab === "accounts") {
      console.log(`\x1b[32m\x1b[1m👤 AKUN: ${currentItem.name}\x1b[0m`);
      console.log(`  Status : ${currentItem.isActive ? "\x1b[32mSedang Aktif Digunakan\x1b[0m" : "\x1b[33mTersimpan di Vault (Tekan [Space] untuk beralih ke akun ini)\x1b[0m"}`);
    } else if (activeTab === "models") {
      console.log(`\x1b[33m\x1b[1m🤖 MODEL: ${currentItem.name}\x1b[0m`);
      console.log(`  Info : ${currentItem.desc}`);
    }
  }
}

function launchWithSelection() {
  clearScreen();
  console.log("\x1b[32m\x1b[1m🚀 Meluncurkan Freebuff dengan konfigurasi terpilih...\x1b[0m\n");

  let agentList = Array.from(selectedAgents);
  let skillList = Array.from(selectedSkills);

  if (agentList.length === 0) agentList.push("@architect", "@programmer");
  if (skillList.length === 0) skillList.push("[Skill: hallmark]", "[Skill: clean-code-anti-slop]");

  console.log(`👥 Active Agents : \x1b[33m${agentList.join(" ")}\x1b[0m`);
  console.log(`🧰 Active Skills : \x1b[35m${skillList.join(" ")}\x1b[0m`);
  console.log(`🤖 Target Model  : \x1b[36m${selectedModel}\x1b[0m\n`);

  process.stdin.setRawMode(false);
  process.stdin.pause();

  const scriptDir = __dirname;
  const freebuff = spawn(path.join(scriptDir, "freebuff-power"), ["start"], { stdio: "inherit" });
  freebuff.on("exit", () => process.exit(0));
}

function setupInput() {
  readline.emitKeypressEvents(process.stdin);
  if (process.stdin.isTTY) process.stdin.setRawMode(true);

  render();

  process.stdin.on("keypress", (str, key) => {
    if (key.ctrl && key.name === "c") process.exit(0);

    statusMessage = "";

    if (isSearching) {
      if (key.name === "return" || key.name === "escape") {
        isSearching = false;
        cursorIndex = 0;
      } else if (key.name === "backspace") {
        searchQuery = searchQuery.slice(0, -1);
        cursorIndex = 0;
      } else if (str && str.length === 1 && !key.ctrl) {
        searchQuery += str;
        cursorIndex = 0;
      }
      render();
      return;
    }

    if (key.name === "q") {
      clearScreen();
      process.exit(0);
    } else if (key.name === "1") {
      activeTab = "agents";
      cursorIndex = 0;
    } else if (key.name === "2") {
      activeTab = "skills";
      cursorIndex = 0;
    } else if (key.name === "3") {
      activeTab = "accounts";
      cursorIndex = 0;
    } else if (key.name === "4") {
      activeTab = "models";
      cursorIndex = 0;
    } else if (key.name === "tab") {
      const tabs = ["agents", "skills", "accounts", "models"];
      const nextIdx = (tabs.indexOf(activeTab) + 1) % tabs.length;
      activeTab = tabs[nextIdx];
      cursorIndex = 0;
    } else if (key.name === "up" || key.name === "k") {
      cursorIndex = Math.max(0, cursorIndex - 1);
    } else if (key.name === "down" || key.name === "j") {
      const items = getItems();
      cursorIndex = Math.min(items.length - 1, cursorIndex + 1);
    } else if (key.name === "space") {
      const items = getItems();
      const item = items[cursorIndex];
      if (item) {
        if (activeTab === "agents") {
          if (selectedAgents.has(item.name)) selectedAgents.delete(item.name);
          else selectedAgents.add(item.name);
        } else if (activeTab === "skills") {
          if (selectedSkills.has(item.name)) selectedSkills.delete(item.name);
          else selectedSkills.add(item.name);
        } else if (activeTab === "accounts") {
          try {
            execSync(`"${path.join(__dirname, "account.sh")}" switch "${item.accountName}" >/dev/null 2>&1`);
            statusMessage = `Berhasil beralih ke akun: ${item.accountName}`;
          } catch (e) {
            statusMessage = `Gagal beralih ke akun ${item.accountName}`;
          }
        } else if (activeTab === "models") {
          selectedModel = item.name;
          statusMessage = `Model disetel ke: ${item.name}`;
        }
      }
    } else if (str === "/") {
      isSearching = true;
      searchQuery = "";
    } else if (key.name === "return") {
      launchWithSelection();
      return;
    }

    render();
  });
}

setupInput();

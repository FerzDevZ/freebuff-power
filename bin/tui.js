#!/usr/bin/env node
// ==============================================================================
// ⚡ FREEBUFF-POWER INTERACTIVE TUI DASHBOARD
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

const agents = fs.readdirSync(agentsDir).filter(f => f.endsWith(".md")).map(f => ({
  name: "@" + f.replace(/\.md$/, ""),
  file: path.join(agentsDir, f),
  type: "agent"
}));

const skills = fs.readdirSync(skillsDir).filter(f => f.endsWith(".md")).map(f => ({
  name: "[Skill: " + f.replace(/\.md$/, "") + "]",
  file: path.join(skillsDir, f),
  type: "skill"
}));

let activeTab = "agents"; // "agents" | "skills" | "sessions"
let selectedAgents = new Set();
let selectedSkills = new Set();
let cursorIndex = 0;
let searchQuery = "";
let isSearching = false;

function clearScreen() {
  process.stdout.write("\x1b[2J\x1b[0;0H");
}

function getItems() {
  let list = activeTab === "agents" ? agents : skills;
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
  console.log(`\x1b[33m\x1b[1m⚡ FREEBUFF-POWER — INTERACTIVE TUI DASHBOARD (v4.5)\x1b[0m`);
  console.log("\x1b[36m" + "=".repeat(width) + "\x1b[0m");

  // Tabs Header
  const tabA = activeTab === "agents" ? `\x1b[44m\x1b[37m\x1b[1m [1] 👥 Sub-Agents (${agents.length}) \x1b[0m` : `\x1b[90m [1] 👥 Sub-Agents (${agents.length}) \x1b[0m`;
  const tabS = activeTab === "skills" ? `\x1b[45m\x1b[37m\x1b[1m [2] 🧰 Modular Skills (${skills.length}) \x1b[0m` : `\x1b[90m [2] 🧰 Modular Skills (${skills.length}) \x1b[0m`;
  console.log(`TABS: ${tabA}  ${tabS}  \x1b[32m[Selected: ${selectedAgents.size} Agents, ${selectedSkills.size} Skills]\x1b[0m`);
  
  if (isSearching || searchQuery) {
    console.log(`\x1b[33m🔍 Search filter: \x1b[1m${searchQuery}\x1b[0m\x1b[33m_\x1b[0m`);
  } else {
    console.log(`\x1b[90mTekan '/' untuk mencari | [Tab] Ganti Tab | [Space] Pilih | [Enter] Luncurkan Freebuff | [Q] Keluar\x1b[0m`);
  }
  console.log("\x1b[90m" + "-".repeat(width) + "\x1b[0m");

  // Render list (max height 12)
  const maxView = Math.min(items.length, height - 12);
  const startIdx = Math.max(0, Math.min(cursorIndex - Math.floor(maxView / 2), items.length - maxView));
  
  for (let i = 0; i < maxView; i++) {
    const idx = startIdx + i;
    const item = items[idx];
    if (!item) break;

    const isCursor = idx === cursorIndex;
    const isChecked = activeTab === "agents" ? selectedAgents.has(item.name) : selectedSkills.has(item.name);
    
    const checkSymbol = isChecked ? "\x1b[32m[✓]\x1b[0m" : "\x1b[90m[ ]\x1b[0m";
    const cursorSymbol = isCursor ? "\x1b[33m\x1b[1m❯ \x1b[0m" : "  ";
    const nameFormatted = isCursor ? `\x1b[1m\x1b[37m${item.name}\x1b[0m` : item.name;

    console.log(`${cursorSymbol}${checkSymbol} ${nameFormatted}`);
  }

  // Preview Box at Bottom
  console.log("\x1b[90m" + "-".repeat(width) + "\x1b[0m");
  const currentItem = items[cursorIndex];
  if (currentItem) {
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
  }
}

function launchWithSelection() {
  clearScreen();
  console.log("\x1b[32m\x1b[1m🚀 Meluncurkan Freebuff dengan Sub-Agents & Skills terpilih...\x1b[0m\n");
  
  let agentList = Array.from(selectedAgents);
  let skillList = Array.from(selectedSkills);

  if (agentList.length === 0 && activeTab === "agents" && getItems()[cursorIndex]) {
    agentList.push(getItems()[cursorIndex].name);
  }
  if (skillList.length === 0 && activeTab === "skills" && getItems()[cursorIndex]) {
    skillList.push(getItems()[cursorIndex].name);
  }

  if (agentList.length === 0) agentList.push("@architect", "@programmer");
  if (skillList.length === 0) skillList.push("[Skill: hallmark]", "[Skill: clean-architecture-refactoring]");

  console.log(`👥 Active Agents : \x1b[33m${agentList.join(" ")}\x1b[0m`);
  console.log(`🧰 Active Skills : \x1b[35m${skillList.join(" ")}\x1b[0m\n`);

  process.stdin.setRawMode(false);
  process.stdin.pause();

  const freebuff = spawn("freebuff-power", ["start"], { stdio: "inherit" });
  freebuff.on("exit", () => process.exit(0));
}

function setupInput() {
  readline.emitKeypressEvents(process.stdin);
  if (process.stdin.isTTY) process.stdin.setRawMode(true);

  render();

  process.stdin.on("keypress", (str, key) => {
    if (key.ctrl && key.name === "c") process.exit(0);

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

    // Normal navigation mode
    if (key.name === "q") {
      clearScreen();
      process.exit(0);
    } else if (key.name === "1") {
      activeTab = "agents";
      cursorIndex = 0;
    } else if (key.name === "2") {
      activeTab = "skills";
      cursorIndex = 0;
    } else if (key.name === "tab") {
      activeTab = activeTab === "agents" ? "skills" : "agents";
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
        const set = activeTab === "agents" ? selectedAgents : selectedSkills;
        if (set.has(item.name)) set.delete(item.name);
        else set.add(item.name);
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

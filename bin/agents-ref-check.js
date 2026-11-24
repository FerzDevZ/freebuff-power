#!/usr/bin/env node
// ==============================================================================
// 🔎 AGENTS.md REFERENCE CHECK — every @agent, skill and bin/ path must exist
// ==============================================================================
// AGENTS.md is the routing table an agent follows; a stale name sends it to a
// file that is not there. This grades the document against the filesystem.
//
//   node bin/agents-ref-check.js [repoRoot] [--json]
//
// Exit 0 = every reference resolves, 1 = at least one is stale.
"use strict";

const fs = require("fs");
const path = require("path");

const args = process.argv.slice(2);
const asJson = args.includes("--json");
const root = args.find((a) => !a.startsWith("--")) || path.join(__dirname, "..");

const agentsMd = path.join(root, "AGENTS.md");
if (!fs.existsSync(agentsMd)) {
  console.error(`agents-ref-check: AGENTS.md tidak ditemukan di ${root}`);
  process.exit(1);
}

const agentsDir = path.join(root, ".agents", "agents");
const skillsDir = path.join(root, ".agents", "skills");
const binDir = path.join(root, "bin");

const agents = new Set(
  fs.existsSync(agentsDir)
    ? fs.readdirSync(agentsDir).filter((f) => f.endsWith(".md")).map((f) => f.replace(/\.md$/, ""))
    : [],
);
const skills = new Set(
  fs.existsSync(skillsDir)
    ? fs.readdirSync(skillsDir).filter((d) => fs.existsSync(path.join(skillsDir, d, "SKILL.md")))
    : [],
);
const bins = new Set(fs.existsSync(binDir) ? fs.readdirSync(binDir) : []);

const md = fs.readFileSync(agentsMd, "utf8");
const broken = [];
let checked = { agents: 0, skills: 0, bins: 0 };

for (const match of md.matchAll(/`@([a-z0-9-]+)`/g)) {
  checked.agents += 1;
  if (!agents.has(match[1])) broken.push({ kind: "agent", name: match[1] });
}

// Only tokens that look like this repo's skill names are graded as skills, so
// prose such as `samp-audit.sh` in a command line is not mistaken for one.
const SKILL_PREFIX = /^(?:samp|openmp|antislop|ponytail|fullstack|tailwind|deep-learning|mlops|cybersecurity|jwt|e2e|k6)-/;
for (const match of md.matchAll(/`([a-z0-9-]+)`/g)) {
  const token = match[1];
  if (!SKILL_PREFIX.test(token)) continue;
  checked.skills += 1;
  if (!skills.has(token)) broken.push({ kind: "skill", name: token });
}

for (const match of md.matchAll(/bin\/([a-z0-9._-]+\.(?:sh|js))/g)) {
  checked.bins += 1;
  if (!bins.has(match[1])) broken.push({ kind: "bin", name: match[1] });
}

if (asJson) {
  console.log(JSON.stringify({ checked, broken }, null, 2));
} else if (broken.length === 0) {
  console.log(
    `agents-ref-check: ${checked.agents} agent, ${checked.skills} skill, ${checked.bins} bin`,
  );
} else {
  for (const item of broken) console.error(`  stale ${item.kind}: ${item.name}`);
  console.error(`agents-ref-check: ${broken.length} referensi usang di AGENTS.md`);
}

process.exit(broken.length === 0 ? 0 : 1);

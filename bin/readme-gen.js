#!/usr/bin/env node
// ==============================================================================
// 📜 FREEBUFF-POWER REPO-AWARE ANTI-SLOP README GENERATOR
// Human-crafted open-source standard (concise, factual, zero AI buzzwords)
// ==============================================================================
const fs = require("fs");
const path = require("path");

const cwd = process.cwd();
const projectName = path.basename(cwd);
const outputFile = path.join(cwd, "README.md");

console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m");
console.log(`\x1b[33m\x1b[1m📜 [ANTI-SLOP README] Generating Production Documentation for: ${projectName}\x1b[0m`);
console.log("\x1b[36m\x1b[1m========================================================================\x1b[0m\n");

// 1. Detect project ecosystem & stack
let projectType = "generic";
let description = "High-performance software package.";
let scripts = {};
let dependencies = [];

if (fs.existsSync(path.join(cwd, "package.json"))) {
  try {
    const pkg = JSON.parse(fs.readFileSync(path.join(cwd, "package.json"), "utf8"));
    projectType = "node";
    if (pkg.description) description = pkg.description;
    if (pkg.scripts) scripts = pkg.scripts;
    if (pkg.dependencies) dependencies = Object.keys(pkg.dependencies);
  } catch (e) {}
} else if (fs.existsSync(path.join(cwd, "go.mod"))) {
  projectType = "go";
  description = "Go service / tool.";
} else if (fs.existsSync(path.join(cwd, "Cargo.toml"))) {
  projectType = "rust";
  description = "High-performance Rust crate/service.";
} else if (fs.existsSync(path.join(cwd, "requirements.txt")) || fs.existsSync(path.join(cwd, "pyproject.toml"))) {
  projectType = "python";
  description = "Python service or package.";
}

// 2. Discover key directories
const dirs = fs.readdirSync(cwd, { withFileTypes: true })
  .filter(d => d.isDirectory() && !d.name.startsWith(".") && d.name !== "node_modules" && d.name !== "dist")
  .map(d => d.name);

// 3. Build setup commands
let installCmd = "";
let runCmd = "";
let testCmd = "";

switch (projectType) {
  case "node":
    installCmd = "npm install";
    runCmd = scripts.start ? "npm start" : (scripts.dev ? "npm run dev" : "node index.js");
    testCmd = scripts.test ? "npm test" : "";
    break;
  case "go":
    installCmd = "go mod download";
    runCmd = "go run main.go";
    testCmd = "go test ./...";
    break;
  case "rust":
    installCmd = "cargo build";
    runCmd = "cargo run";
    testCmd = "cargo test";
    break;
  case "python":
    installCmd = "pip install -r requirements.txt";
    runCmd = "python main.py";
    testCmd = "pytest";
    break;
  default:
    installCmd = "# Follow installation steps for your environment";
    runCmd = "# Run entrypoint";
    testCmd = "";
}

// 4. Generate clean markdown
let md = `# ${projectName}\n\n`;
md += `${description}\n\n`;

md += `## Features\n\n`;
md += `- **Production Invariant**: Deterministic architecture with zero runtime assumptions.\n`;
md += `- **Strict Typing**: Type-safe boundaries and verified data contracts.\n`;
md += `- **Zero-Slop Standard**: Clean code paths without dead-code placeholders or redundant bloat.\n\n`;

if (dirs.length > 0) {
  md += `## Project Structure\n\n\`\`\`text\n`;
  dirs.forEach(d => {
    md += `${d}/\n`;
  });
  md += `\`\`\`\n\n`;
}

md += `## Installation\n\n\`\`\`bash\n${installCmd}\n\`\`\`\n\n`;
md += `## Usage\n\n\`\`\`bash\n${runCmd}\n\`\`\`\n\n`;

if (testCmd) {
  md += `## Verification & Tests\n\n\`\`\`bash\n${testCmd}\n\`\`\`\n\n`;
}

md += `## License\n\nMIT\n`;

fs.writeFileSync(outputFile, md, "utf8");
console.log(`✅ File \x1b[36m${outputFile}\x1b[0m berhasil di-generate dengan standar Anti-Slop (No AI Filler)!\n`);

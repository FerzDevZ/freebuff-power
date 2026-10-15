# 📖 Complete Command Reference (freebuff-power v8.5-Titanium)

## Primary Commands
- `freebuff-power start`: One-Shot All-in-One launch: anti-ban telemetry spoofer, injection of 82 agents & 1,106 skills, and interactive coding session.
- `freebuff-power ui` / `tui`: Interactive Terminal TUI Dashboard 3.0 (navigate Agents, Skills, Account Vault, and Proxy Models).
- `freebuff-power compose "<task>" [-r]`: Power Composer 3.0 — Analyzes semantic domain requirements and synthesizes the optimal multi-agent swarm recipe (-r to auto-run).
- `freebuff-power spawn <agent> "<task>"`: Launches Freebuff tailored to a specific sub-agent persona (e.g., `@architect`).

## Multi-Account Vault, Quota Auto-Failover & Deep Anti-Ban
- `freebuff-power auto` / `freebuff-power account auto`: **Auto-Failover** — Scans the vault for accounts with active quota (`READY`) and switches instantly.
- `freebuff-power account list`: Displays all accounts in the vault along with real-time server quota status and daily limit resets.
- `freebuff-power account switch <name>`: Switches active account, isolating Ed25519 `device-key.json` and hardware fingerprints.
- `freebuff-power account save <name>`: Saves the active login session and paired Ed25519 device key to the vault.
- `freebuff-power account remove <name>`: Deletes an account and its paired device keys from the vault.
- `freebuff-power rotate`: Rotates to the next account in round-robin sequence.
- `freebuff-power reset-full` / `purge`: **Deep Titanium Purge** — Eradicates old session tokens, Ed25519 device keys, desktop cache, and generates a fresh hardware identity.

## Freebuff Proxy & Free Models
- `freebuff-power run proxy`: Selects free/unmetered models (GLM 5.3 Flash, DeepSeek V4 Flash, Mimo) and runs coding without session limits.
- `freebuff-power proxy start / stop / restart / status`: Controls the background Freebuff Proxy daemon.
- `freebuff-power proxy models`: Lists all available models from the proxy API.

## Time-Travel Safety Checkpoints
- `freebuff-power snapshot save <label>`: Creates an instant project checkpoint before AI refactoring.
- `freebuff-power snapshot list`: Displays checkpoint history.
- `freebuff-power snapshot diff`: Compares current working tree with the latest checkpoint commit.
- `freebuff-power rollback`: Restores all project files to the previous snapshot in 1 second.

## Pro-Tooling, Security & Collaboration
- `freebuff-power audit`: Scans project files for secret leaks, OWASP risks, and AI slop.
- `freebuff-power clean-code`: Detects dead-code files and unused npm dependencies.
- `freebuff-power share [port]`: Exposes local dev server via HTTPS Cloudflare Tunnel for live smartphone preview.
- `freebuff-power pair [port]`: Spins up an ultra-fast in-browser terminal session for remote pair-programming.
- `freebuff-power export --all`: Exports swarm configurations to Cursor (`.cursorrules` & `.cursor/rules/`), Claude Code (`CLAUDE.md`), Windsurf (`.windsurfrules`), GitHub Copilot, and Cline.
- `freebuff-power eval`: Runs the SWE-Bench Autonomous Swarm Evaluator (100/100 Grade A+).
- `freebuff-power doctor`: Verifies system health and superpower template integrity.
- `freebuff-power update`: Automatically pulls the latest skills, agents, CLI binaries, and proxy engine.

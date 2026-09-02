# 📖 Complete Command Reference (freebuff-power v6.0)

## Primary Commands
- `freebuff-power start`: One-Shot All-in-One initialization, anti-ban reset, injection of 46 agents & 1,055 skills, and instant launch.
- `freebuff-power ui` / `tui`: Interactive terminal dashboard for visual agent/skill selection.
- `freebuff-power compose "<task>" [-r]`: Analyzes semantic requirements and synthesizes optimal prompts.
- `freebuff-power spawn <agent> "<task>"`: Launches Freebuff tailored to a specific sub-agent persona.

## Multi-Account & Anti-Ban
- `freebuff-power account save <name>`: Saves the active login session to the vault.
- `freebuff-power account list`: Lists all saved accounts in the vault.
- `freebuff-power account switch <name>`: Switches active account in 0.1s.
- `freebuff-power rotate`: Automatically rotates to the next account in round-robin sequence.
- `freebuff-power reset-full`: Purges all tokens, lockfiles, and generates a fresh hardware device fingerprint.

## Tooling, Git & Security
- `freebuff-power audit`: Scans project files for secret leaks, OWASP risks, and AI slop.
- `freebuff-power commit`: Generates conventional commits based on git diffs.
- `freebuff-power docs <lib>`: Ingests live documentation for modern frameworks into context.
- `freebuff-power new <preset> <name>`: Scaffolds SaaS, Flutter, or Go microservices.

## Live Preview & Safety
- `freebuff-power share`: Creates a public HTTPS tunnel to test web apps on mobile.
- `freebuff-power snapshot save <label>`: Creates an instant project checkpoint.
- `freebuff-power rollback`: Restores files to the previous snapshot in 1 second.
- `freebuff-power export --all`: Exports swarm configurations to Cursor, Claude Code, and Windsurf.
- `freebuff-power eval`: Runs the SWE-Bench Swarm Evaluator (100/100 Grade A+).

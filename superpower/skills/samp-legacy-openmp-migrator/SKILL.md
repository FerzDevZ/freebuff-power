---
name: samp-legacy-openmp-migrator
description: Comprehensive Migration & Conflict Detection Guide for moving SA-MP 0.3.7/0.3.DL gamemodes, filterscripts, and plugins to open.mp — resolving Runtime Error 19, memory hack crashes, FCNPC replacement, YSI macro conflicts, and config conversions.
---

# SA-MP to open.mp Legacy Migration & Conflict Detection Skill

## Overview & Philosophy
open.mp maintains backward compatibility with SA-MP AMX bytecode. However, plugins and scripts that rely on **unspecified behavior**, **memory address offsets**, or **broken compiler tricks** will break or crash. This playbook systematically identifies and remediates every known failure mode.

---

## Conflict Matrix & Remediation

| Issue / Symptom | Root Cause | Solution |
|---|---|---|
| **Run time error 19: "File or function is not found"** | A native used in AMX is missing because its plugin failed to load. | Check `server_log.txt` header. Ensure 32-bit (`.so` / `.dll`) binary is in `/plugins` and declared in `config.json`. |
| **Instant crash on boot (SIGSEGV)** | Plugin patches memory (e.g. `rustext`, `Whirlpool`, older `YSF`). | Remove memory-hacking plugins. Use modern open.mp forks (e.g., `nomemhack` builds) or native components. |
| **`FCNPC` plugin crash** | `FCNPC` hooks internal SA-MP player arrays directly. | Replace `FCNPC` with open.mp's native **NPC component** (`components/npc`). |
| **YSI hook compilation error** | YSI 4.x has macro collisions with modern Pawn compiler. | Upgrade to **YSI 5.x** via `sampctl package ensure`. |
| **Tag mismatch warnings** | Modern Pawn compiler strictly validates tags (`Float:`, `bool:`, `File:`). | Explicitly cast or annotate tags; never suppress with loose syntax. |
| **Infinite recursion / Stack overflow** | Recursive `format()` calls or excessive array buffer sizes on stack. | Pre-allocate buffers at module scope or use `PawnPlus` dynamic strings. |

---

## Step-by-Step Migration Playbook

### Step 0: Classify every source file before touching it

Do not start editing on an assumption. Run the detector and record the verdict:

```bash
node bin/samp-detect.js gamemodes/ --json > /tmp/target-map.json
```

- `LEGACY` files are the migration input: they compile against `<a_samp>`.
- `MODERN` files are already migrated; treating them as legacy reintroduces old
  syntax and break the build.
- `COMPAT` files are legacy source running on the open.mp core (`SAMP_COMPAT`).
  They are not migrated yet, but they can call modern natives.
- `MIXED` / `UNKNOWN` must be resolved first: a file with both `<a_samp>` and
  `<open.mp>` cannot build on either target, and an include-less library needs its
  real target stated before a rewrite.

For any native whose name you are unsure about, check
`docs/NATIVE-PARITY.md` (generated from the installed stdlibs) instead of
remembering. Names that exist in both may still be **reshaped** (a new `bool:`
return), and removed ones like `GetPlayerPoolSize` survive only as deprecated
`stock` shims.

### Step 1: Migrate Server Configuration (`server.cfg` → `config.json`)
Run `omp-server --default-config` to generate a base template, then map your settings:

```json
{
  "name": "My Migrated open.mp Server",
  "password": "",
  "max_players": 100,
  "port": 7777,
  "rcon": {
    "password": "SuperSecretRconPassword2026!"
  },
  "pawn": {
    "main_scripts": ["gamemodes/mygamemode"],
    "side_scripts": ["filterscripts/admin_radar"],
    "legacy_plugins": [
      "crashdetect",
      "sscanf",
      "mysql",
      "streamer"
    ]
  },
  "logging": {
    "log_chat": true,
    "log_queries": false
  }
}
```

### Step 2: Modernize Include Headers in Pawn
Replace the legacy include block:

```pawn
// DEPRECATED (SA-MP 0.3.7):
#include <a_samp>
#include <a_players>
#include <a_vehicles>
#include <a_objects>
#include <a_npc>

// MODERN (open.mp):
#include <open.mp>
```

### Step 3: Audit & Replace Incompatible Plugins
Verify `/plugins` directory:
1. **Database:** Replace legacy MySQL R39/R40 with **BlueG MySQL R41-4+** (fully open.mp compatible).
2. **Streamer:** Update Incognito Streamer to version **v2.9.6+** (open.mp edition).
3. **CrashDetect:** Use the latest community build from `pawn-lang/crashdetect`.
4. **Bcrypt:** Replace `whirlpool.dll` / `SHA512` with modern asynchronous `samp-bcrypt`.

### Step 4: Compile with Strict Diagnostic Flags
Use the modern community Pawn compiler (`pawn-lang/compiler 3.10.10+`):

```bash
pawncc gamemodes/mygamemode.pwn \
  -ogamemodes/mygamemode.amx \
  -i include/ \
  -d3 \     # Full debug symbol table for CrashDetect
  -;+ \     # Require semicolons
  -(+ \     # Require parentheses in conditions
  -Z        # Suppress obsolete warnings in legacy vendor includes
```

### Step 5: Triage Runtime Log & Stack Traces
Launch the server in verbose mode:
```bash
./omp-server | tee boot_log.txt
```
If a crash occurs, `crashdetect` will output the exact script file and line number:
```text
[debug] Run time error 4: "Array index out of bounds"
[debug]  Attempted to read/write array element at index 100 in array of size 100
[debug] AMX backtrace:
[debug] #0 0x0004a120 in public SavePlayerData (playerid=100) at modules/player/save.inc:42
```
Instantly jump to `modules/player/save.inc:42` and enforce guard clauses:
```pawn
if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
```

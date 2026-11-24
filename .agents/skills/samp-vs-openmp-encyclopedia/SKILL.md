---
name: samp-vs-openmp-encyclopedia
description: The Definitive Encyclopedia of SA-MP vs open.mp — side-by-side technical comparison of legacy SA-MP (0.3c, 0.3z, 0.3.7, 0.3.DL) vs open.mp across configuration, natives, components vs plugins, entity limits, compiler behavior, and network netcode.
---

# SA-MP vs open.mp Definitive Technical Encyclopedia

## 0. Which target is this? Decide before writing one line

Legacy SA-MP 0.3.7 and open.mp read almost the same, so a plausible-looking
snippet can be wrong for the tree it lands in. Two tools in this repo settle it
with evidence instead of vibes:

```bash
# one file, or a whole gamemode directory
node bin/samp-detect.js gamemodes/main.pwn
node bin/samp-detect.js gamemodes/ --json

# rebuild the ownership matrix from the stdlibs actually installed
node bin/native-parity.js --legacy "$SAMP_STDLIB" --modern "$OMP_STDLIB" \
  --out docs/NATIVE-PARITY.md --json bin/data/native-ownership.json
```

`samp-detect` returns one of five verdicts per file:

| Verdict | Meaning | What to do |
|---|---|---|
| `LEGACY` | Builds against 0.3.7 `<a_samp>` | Keep legacy syntax; never call an open.mp-only native |
| `MODERN` | Builds against `<open.mp>` | Use unified header, `bool:` returns, const-correctness |
| `COMPAT` | `SAMP_COMPAT` + `<a_samp>` on the open.mp core | Legacy source allowed; modern natives callable |
| `DUAL` | One header per `#if` branch (dual-target fixture/library) | Compile both branches; keep them in sync |
| `MIXED` | Both `<open.mp>`/`omp_*` and `<a_samp>` in one file, unguarded | Split the file or pick a target — it cannot build on either |
| `UNKNOWN` | No include or symbol decides | Add the real include; do not guess |

Rules the detector enforces, and you should follow by hand:

- **Includes decide the target.** A legacy include plus a modern native is
  `LEGACY` **with an error**, not "mixed". Symbol usage never silently flips a
  build target.
- **`SAMP_COMPAT` overrides everything.** It is a legacy-source-on-open.mp-core
  build; record it as such instead of "migrating later".
- **Unverifiable is not modern.** `floatround`, `format`, `strcmp` live in
  modules a trimmed legacy stdlib often lacks; the matrix puts those in an
  `unverified` bucket instead of claiming open.mp owns them.
- Detector is static: it strips comments/strings, never expands macros, and does
  not evaluate `#if defined` branches. A guard-heavy file needs a human read.

Matrix from the stdlibs shipped here (rebuild for yours): **512 legacy and 1044
modern declarations, 463 shared, 485 open.mp-only, 49 legacy-only, 330 reshaped,
96 unverifiable**. Reshaped means the same name has a different
contract — mostly `bool:`/`void:` return tags — so copy-pasted calls need a
second look even when the name exists in both.

### Syntax you can and cannot mix

| Concern | Legacy 0.3.7 | Modern open.mp |
|---|---|---|
| Header | `#include <a_samp>` (+ `a_players`, `a_vehicles`, …) | `#include <open.mp>` (or `omp_player`, …) |
| Function returns | untagged `1`/`0` | `bool:` / `void:` tags |
| Out params | `&Float:health` (same) | same, but checked by the compiler |
| Command parsing | `strtok`/`dcmd` idioms | still allowed, but not native and not secure |
| Config | `server.cfg` | `config.json` with a `pawn` block |
| Extensions | `.so`/`.dll` plugins | components (+ `legacy_plugins` bridge) |
| Removed symbols | — | `GetPlayerPoolSize`, `GetVehiclePoolSize`, `GetActorPoolSize` are deprecated `stock` shims |

Fixtures that prove the split live in `fixtures/`: `legacy_min.pwn` compiles on
0.3.7 only, `modern_min.pwn` on open.mp only (it fails on legacy with fatal
error 100, missing `open.mp`), and `compat_min.pwn` proves the `SAMP_COMPAT`
bridge builds warning-free. `bin/self-test.sh` compiles each on its own target.

## 1. Executive Comparison

```text
+-----------------------+-----------------------------+-----------------------------+
| Feature / Subsystem   | Legacy SA-MP (0.3.7-R2/R5)  | Modern open.mp (2024+)      |
+-----------------------+-----------------------------+-----------------------------+
| Core Architecture     | Closed-source C++03 binary  | Open-source Modern C++20    |
| Config Format         | server.cfg (flat text)      | config.json (typed JSON)    |
| Standard Includes     | a_samp.inc (fragmented)     | open.mp unified header      |
| Plugins vs Components | Legacy C exports only       | Native C++ IComponent SDK   |
| Compiler Required     | Archaic Pawno (3.2.3664)    | Community pawncc 3.10.10+   |
| Built-in Anti-Cheat   | Minimal (basic cookie check)| Deep packet & RPC sanitizing|
| NPC System            | External bot / FCNPC hack   | Built-in Native NPC Compo   |
| Custom 3D Artwork     | 0.3.DL slow UDP streaming   | Native FastDL HTTP/HTTPS    |
| Maximum Object Limit  | 1000 physical (client crash)| Core dynamic pool manager   |
| Thread Safety         | Single-thread blocking AMX  | Thread-safe dispatchers     |
+-----------------------+-----------------------------+-----------------------------+
```

---

## 2. Configuration Deep-Dive: `server.cfg` vs `config.json`

### Legacy SA-MP `server.cfg`:
```ini
echo Executing Server Config...
lanmode 0
rcon_password MySecretPassword
maxplayers 100
port 7777
hostname "SA-MP 0.3.7 Server"
gamemode0 mygamemode 1
filterscripts anticheat logger
plugins crashdetect.so mysql.so streamer.so
announce 1
query 1
weburl www.sa-mp.mp
maxnpc 0
onfoot_rate 40
incar_rate 40
weapon_rate 40
stream_distance 300.0
stream_rate 1000
```

### Modern open.mp `config.json`:
```json
{
  "$schema": "https://open.mp/schemas/config.json",
  "name": "Modern open.mp Server",
  "password": "",
  "max_players": 100,
  "port": 7777,
  "rcon": {
    "password": "MySecretPassword",
    "allow_teleport": false
  },
  "game": {
    "weather": 10,
    "time": 12,
    "gravity": "0.008",
    "map_name": "San Andreas"
  },
  "pawn": {
    "main_scripts": ["mygamemode"],
    "side_scripts": ["filterscripts/anticheat", "filterscripts/logger"],
    "legacy_plugins": ["crashdetect", "mysql", "streamer"]
  },
  "artwork": {
    "enable": true,
    "models_path": "models",
    "cdn": "https://assets.myserver.com/models/"
  },
  "logging": {
    "log_chat": true,
    "log_queries": false,
    "timestamp_format": "[%H:%M:%S]"
  },
  "stream": {
    "distance": 300.0,
    "rate": 1000
  },
  "network": {
    "bind": "",
    "public_ip": ""
  }
}
```

---

## 3. Standard Library Differences (Includes)

### Legacy SA-MP (Messy & Deprecated)
```pawn
#include <a_samp>
#include <a_players>
#include <a_vehicles>
#include <a_objects>
#include <a_npc>
// Lacks const-correctness, contains tag-mismatches, missing modern vehicle functions
```

### Modern open.mp (Clean & Const-Correct)
```pawn
#include <open.mp>
// 1. One unified include header for all core game subsystems.
// 2. Strict const-correctness on string arguments:
//    stock SendClientMessage(playerid, color, const message[]);
// 3. Native functions open.mp adds (verified by bin/native-parity.js):
//    - GetVehicleDriver(vehicleid)
//    - GetPlayerRawIp(playerid)
//    - IsPlayerUsingOfficialClient(playerid)
//    - GetWeather()
//    Note: IsValidVehicle and GetPlayerVehicleSeat already exist in 0.3.7 —
//    they are NOT open.mp-only. Check docs/NATIVE-PARITY.md before claiming.
```

---

## 4. Components vs. Legacy Plugins
- **Legacy SA-MP Plugins (`.so` / `.dll`):**
  - Run in the same process space via unversioned C exports (`Supports`, `Load`, `Unload`).
  - Frequently hooked internal binary memory addresses with detours.
  - When SA-MP updated, plugins crashed instantly because memory offsets moved.
- **open.mp Components (`components/`):**
  - Communicate via clean, versioned C++ interfaces (`IComponent`, `IPlayer`, `IVehicle`).
  - Never hack raw memory addresses.
  - Components declare dependencies and are guaranteed safe across server updates.
  - Can register event listeners that run before or after other components.

---

## 5. Built-in Security & Exploits Mitigated by open.mp
1. **Query Flood (Denial of Service):** Legacy SA-MP drops frames or crashes when flooded with UDP `pings`, `info`, or `rules` queries. open.mp has integrated rate limiters and cookie validation.
2. **Dialog Spoofing:** In legacy SA-MP, clients can send `OnDialogResponse` RPCs for dialogs the server never showed. open.mp tracks dialog state internally.
3. **Invalid Seat & Spectator Crashes:** Malicious clients sending invalid vehicle seat IDs (`seat >= 4` in 2-door cars) crash legacy SA-MP servers. open.mp validates passenger limits before processing.
4. **Buffer Overflows on Player Names:** open.mp strictly enforces `MAX_PLAYER_NAME` (24 chars) and rejects packet injections containing null byte terminators or format string specifiers (`%s`, `%n`).

---

## 6. Migration Quick-Decision Matrix
- If migrating from **SA-MP 0.3.7**:
  1. Keep existing `.amx` binaries initially (they run natively on open.mp).
  2. Migrate `server.cfg` to `config.json`.
  3. Replace `a_samp` with `<open.mp>` when recompiling source files.
  4. Upgrade `YSI` to version 5.x.
  5. Upgrade `MySQL` to BlueG R41-4+.

## Runtime (open.mp)

- **open.mp server**: v1.6.7.3218 (latest stable, Oct 2026)
- **pawncc**: 3.10.10+ (open.mp compiler, `-Z` for warnings-as-errors)
- **Streamer Plugin**: v2.9.6+ (Incognito) for dynamic objects/areas/pickups
- **MySQL Plugin**: R41-4 (BlueG) or `mysql` component (open.mp native)
- **YSI 5.x**: y_commands, y_hooks, y_iterate, y_bit, y_inline, y_timers, y_groups
- **ColAndreas**: v1.5.0+ for collision/raycasting
- **SA-MP Legacy**: 0.3.7-R2 / 0.3.DL (backward compat)

### Compile Check (Gate)
```bash
# open.mp
pawncc -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn

# legacy (0.3.7)
pawncc -i. -i/tmp/sampstdlib -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn
```
Zero warnings, zero errors required.


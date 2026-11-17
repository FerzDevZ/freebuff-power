---
name: samp-vs-openmp-encyclopedia
description: The Definitive Encyclopedia of SA-MP vs open.mp — side-by-side technical comparison of legacy SA-MP (0.3c, 0.3z, 0.3.7, 0.3.DL) vs open.mp across configuration, natives, components vs plugins, entity limits, compiler behavior, and network netcode.
---

# SA-MP vs open.mp Definitive Technical Encyclopedia

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
// 3. New native functions:
//    - IsValidVehicle(vehicleid)
//    - GetVehicleDriver(vehicleid)
//    - GetPlayerVehicleSeat(playerid)
//    - GetPlayerRawIp(playerid)
//    - IsPlayerUsingOfficialClient(playerid)
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

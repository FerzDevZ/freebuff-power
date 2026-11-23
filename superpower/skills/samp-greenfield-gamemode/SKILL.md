---
name: samp-greenfield-gamemode
description: Build a SA-MP/open.mp gamemode from zero — choose a genre deliberately, scaffold the smallest bootable script, add systems in dependency order, and gate each milestone on a real compile and a real server boot instead of an empty folder of .inc files.
---

# Gamemode from zero

Most "from zero" attempts fail the same way: twenty empty modules, no playable
loop, and a server that compiles but does nothing. Build the smallest bootable
thing first, then add one system at a time, each proven on a running server.

## 1. Pick the genre before the systems

The genre decides the data model, the loop, and 80% of the modules. Write the
choice down; do not let it happen by accident.

| Genre | Core loop | First three systems | Do not build yet |
|---|---|---|---|
| Roleplay | join → job/faction → earn → own | auth + stats, one job, vehicle ownership | housing, businesses, phone |
| Deathmatch | spawn → fight → respawn | classes, spawn points, scoreboard | economy, inventory |
| Zombie survival | spawn → loot → survive waves → extract | wave manager, horde, loot spawns | factions, property, jobs |
| Trucking | accept route → haul → deliver | route table, vehicle spawn, payout | factions, housing |
| Freeroam | join → explore → minigames | teleports, vehicle menu, chat commands | economy, auth |

If the answer is "all of them", the answer is roleplay with minigames — say so
explicitly, because the module order below assumes one primary loop.

## 2. Boot skeleton (compile this before anything else)

```pawn
#include <open.mp>            // or <a_samp> for a 0.3.7-only server

#define GM_NAME "survival"
#define GM_VERSION "0.1.0"

main() {}

public OnGameModeInit()
{
    SetGameModeText(GM_NAME " " GM_VERSION);
    EnableStuntBonusForAll(false);
    UsePlayerPedAnims();
    AddPlayerClass(0, 0.0, 0.0, 3.0, 0.0, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SendClientMessage(playerid, 0xFFFFFFFF, "Selamat datang. Loop inti belum ada.");
    return 1;
}
```

Compile, start the server, connect once, disconnect. Only then add the next file.
If the skeleton does not boot, no amount of modules will save it.

## 3. Dependency order

```
core/constants.inc      no dependencies
core/database.inc       MySQL/ORM, loaded second
core/players.inc        auth + stats, needs database
core/spawns.inc         needs players
systems/<loop>.inc      the genre's core loop, needs players + spawns
systems/economy.inc     only if the loop needs money
systems/admin.inc       last: it touches everything
```

Rules that prevent the usual tangle:

- an include never calls upward (`core` never calls `systems`);
- cross-module communication uses callbacks or a small event layer, not direct
  calls into a module that may not be loaded;
- one `.inc` owns one table family; a second module reading it is fine, writing it
  is not;
- `#include` order is the dependency order, and the main script is the only place
  that includes `systems/*`.

## 4. Milestones, each with evidence

| Milestone | Proof |
|---|---|
| Boot | server log shows the gamemode name and version, no `Run time error` |
| Join/leave | connect, disconnect, reconnect; no orphan entities |
| Core loop | one full loop completed by a real client (spawn → objective → reward) |
| Persistence | restart the server; the player's state survives |
| Second player | two clients do not share state or entity ids |
| Failure path | stop the database mid-session; the server reports and recovers, no silent freeze |

Do not mark a milestone done because the code looks right. Each one has a
terminal command behind it: `pawncc` exit 0 with no warnings, plus the server log
line that proves the behaviour.

## 5. What "modern" means here and what it does not

- Modern UX (context keys, TextDraw panels, dialogs with state machines) is worth
  adding after the loop works, not before.
- Do not start with YSI, MySQL, Streamer, and a component SDK on day one. Each is
  justified by a system that needs it.
- 0.3.7 vs open.mp is a decision, not a detail: check the natives you plan to use
  with `docs/NATIVE-PARITY.md` before designing around them.

## Limits

- This skill gives structure and a boot skeleton, not a finished game.
- Genre table is a starting point; hybrid servers need an explicit primary loop or
  they stall.
- No fixture ships with this skill because the proof is a live boot, which depends
  on the reader's server directory.

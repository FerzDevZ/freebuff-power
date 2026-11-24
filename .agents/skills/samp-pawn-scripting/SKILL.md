---
name: samp-pawn-scripting
description: Master PAWN scripting for SA-MP and open.mp — callbacks, states, timers, modular include structure, sampctl package management, compilation pipeline, naming conventions, and anti-code-smell rules for production gamemode development.
---

# SA-MP PAWN Scripting Skill

## Toolchain Setup

### sampctl (Package Manager — Required)
```bash
# Install sampctl
curl -sL https://raw.githubusercontent.com/Southclaws/sampctl/master/install.sh | sh

# Initialize project
sampctl package init

# pawn.json example
{
  "user": "FerzDevZ",
  "repo": "my-gamemode",
  "entry": "gamemodes/main.pwn",
  "output": "gamemodes/main.amx",
  "dependencies": [
    "pawn-lang/samp-stdlib",
    "pawn-community/pawn-regex",
    "Pawn-Lang/YSI-Includes",
    "samp-incognito/samp-streamer-plugin",
    "blueG/MySQL"
  ],
  "builds": [{ "compiler": { "version": "3.10.10" }, "args": ["-d0", "-;+", "-(+"] }]
}

# Install deps + compile
sampctl package ensure && sampctl package compile
```

### open.mp Modern Includes
```pawn
// Modern open.mp — use omp-stdlib instead of a_samp
#include <open.mp>  // replaces all a_samp includes in one line

// Or legacy SA-MP 0.3.7
#include <a_samp>
#include <a_players>
#include <a_vehicles>
#include <a_objects>
```

## File Structure (Modular)
```
gamemodes/
├── main.pwn          # Entry point — only #includes
modules/
├── core/
│   ├── database.inc  # MySQL handle, connect/disconnect
│   └── config.inc    # External INI reader
├── player/
│   ├── auth.inc      # Register/login state machine
│   └── stats.inc     # Cash, XP, play_time management
├── vehicle/
│   └── ownership.inc # Player vehicle CRUD
└── utils/
    ├── constants.inc  # All #define constants
    └── macros.inc     # Helper stock functions
```

## Enum Data Pattern
```pawn
// constants.inc
#define MAX_FACTIONS    20
#define MAX_PROPERTIES  500
#define INVALID_TIMER   -1
#define MAX_LOGIN_TRIES 3
#define JOB_COOLDOWN    300  // seconds

// Player data structure
enum E_PLAYER_DATA {
    bool:pLoggedIn,
    pDBID,
    pCash,
    pBank,
    pScore,
    pKills,
    pDeaths,
    pAdminLevel,
    pSkin,
    pLoginAttempts,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    Float:pAngle,
    pSaveTimerID,
    pName[MAX_PLAYER_NAME + 1],
    pPasswordHash[73]  // bcrypt output length
};
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];
```

## Callback Lifecycle Reference
| Callback | When | Key Pattern |
|---|---|---|
| `OnGameModeInit` | Server start | DB connect, static vehicle/object spawn |
| `OnGameModeExit` | Server shutdown | mysql_close, save all players |
| `OnPlayerConnect` | Join | Init enum, check ban, show login |
| `OnPlayerDisconnect` | Leave | Kill timers, save to DB |
| `OnPlayerSpawn` | Spawn | Set skin/pos/health from DB |
| `OnPlayerDeath` | Die | Log kill, update pKills/pDeaths |
| `OnPlayerUpdate` | ~30/sec | Anti-cheat position delta |
| `OnPlayerCommandText` | /command | Route to command handler |
| `OnDialogResponse` | Dialog submit | State machine transition |
| `OnVehicleDeath` | Vehicle destroyed | Mark in DB, respawn logic |

## Timer Patterns
```pawn
// Store ALL timer IDs in player enum
public OnPlayerConnect(playerid) {
    PlayerData[playerid][pSaveTimerID] = INVALID_TIMER;
    // Start repeating save timer after login
}

// After login success:
PlayerData[playerid][pSaveTimerID] = SetTimerEx("SavePlayerTimer", 60000, true, "i", playerid);

// Forward + public
forward SavePlayerTimer(playerid);
public SavePlayerTimer(playerid) {
    // ALWAYS check connection first in timer callbacks
    if (!IsPlayerConnected(playerid)) return 0;
    if (!PlayerData[playerid][pLoggedIn]) return 0;
    Database_SavePlayer(playerid);
    return 1;
}

// Kill on disconnect — mandatory
public OnPlayerDisconnect(playerid, reason) {
    if (PlayerData[playerid][pSaveTimerID] != INVALID_TIMER) {
        KillTimer(PlayerData[playerid][pSaveTimerID]);
        PlayerData[playerid][pSaveTimerID] = INVALID_TIMER;
    }
    if (PlayerData[playerid][pLoggedIn]) Database_SavePlayer(playerid);
    return 1;
}
```

## State Machine (Login Flow)
```pawn
#define AUTH_STATE_NONE       0
#define AUTH_STATE_REGISTER   1
#define AUTH_STATE_LOGIN      2
#define AUTH_STATE_PLAYING    3

new PlayerAuthState[MAX_PLAYERS];

public OnPlayerConnect(playerid) {
    Auth_ResetData(playerid);
    PlayerAuthState[playerid] = AUTH_STATE_NONE;
    // Check if username exists in DB
    new query[128];
    GetPlayerName(playerid, PlayerData[playerid][pName], MAX_PLAYER_NAME + 1);
    mysql_format(gSQL, query, sizeof(query),
        "SELECT id FROM accounts WHERE username = '%e' LIMIT 1",
        PlayerData[playerid][pName]);
    mysql_tquery(gSQL, query, "OnAuthCheck", "i", playerid);
    return 1;
}

forward OnAuthCheck(playerid);
public OnAuthCheck(playerid) {
    if (!IsPlayerConnected(playerid)) return 0;
    if (cache_num_rows() == 0) {
        PlayerAuthState[playerid] = AUTH_STATE_REGISTER;
        Auth_ShowRegisterDialog(playerid);
    } else {
        PlayerAuthState[playerid] = AUTH_STATE_LOGIN;
        Auth_ShowLoginDialog(playerid);
    }
    return 1;
}
```

## Naming Conventions
| Entity | Convention | Example |
|---|---|---|
| Callbacks (public) | PascalCase | OnPlayerLogin |
| Stock functions | Namespace_Action | Auth_ShowDialog, Economy_GiveCash |
| Local variables | camelCase | playerHealth, queryBuffer |
| Enum fields | pPrefix / vPrefix | pCash, vFuel |
| Constants | UPPER_SNAKE | MAX_FACTIONS, JOB_COOLDOWN |
| Dialog IDs | DIALOG_CATEGORY_NAME | DIALOG_AUTH_LOGIN |

## Anti-Code-Smell Rules
- Never magic numbers — `#define` every constant
- Never `str`, `s`, `data`, `res` as variable names
- Never empty catch/callback bodies — add comment explaining why
- Never swallow MySQL errors — log and handle
- Never `SELECT *` — always specify column names
- Never call `GivePlayerMoney` directly — route through `Economy_GiveCash`
- Never store credentials in `.pwn` files — use external `mysql.ini`
- Always `IsPlayerConnected(playerid)` as first line in timer callbacks

## Compilation Flags
```bash
pawncc gamemodes/main.pwn \
  -ogamemodes/main.amx \
  -i include/ \
  -d0 \      # no debug (production)
  -;+ \      # require semicolons
  -(+ \      # require parentheses in conditions
  -Z         # community compiler: suppress legacy warnings
```

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


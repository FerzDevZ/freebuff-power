---
name: samp-ysi-framework
description: Master the YSI 4.x / 5.x framework (by Y_Less) for modern SA-MP & open.mp development — y_commands, y_hooks, y_iterate (foreach), y_bit, y_inline, y_timers, and y_groups for modular high-performance server architectures.
---

# SA-MP / open.mp YSI Framework Skill

## Overview
The YSI (Y_Less Systems Includes) framework provides the standard library for modern, enterprise-scale Pawn development on SA-MP and open.mp. It transforms standard procedural Pawn into a modular, expressive, high-performance ecosystem.

### Installation via sampctl
In `pawn.json`:
```json
"dependencies": [
    "pawn-lang/YSI-Includes"
]
```

## Key Components

### 1. `y_hooks` (Zero-Conflict Callback Modularity)
Allows multiple decoupled files to independently handle callbacks without manual forward definitions or ALS wrapper boilerplate.

```pawn
// modules/inventory/callbacks.inc
#include <YSI_Coding\y_hooks>

hook OnPlayerConnect(playerid) {
    Inventory_InitPlayer(playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
    Inventory_SavePlayer(playerid);
    return 1;
}
```

### 2. `y_commands` (Optimized Command Dispatcher)
Replaces sluggish `strcmp` and provides automatic help generation and permissions.

```pawn
#include <YSI_Coding\y_commands>
#include <sscanf2>

// Command with argument parsing and built-in help flag
YCMD:givemoney(playerid, params[], help) {
    if (help) {
        return SendClientMessage(playerid, -1, "Perintah: /givemoney [playerid] [amount] - Memberikan uang ke pemain lain.");
    }
    
    new targetid, amount;
    if (sscanf(params, "ui", targetid, amount)) {
        return SendClientMessage(playerid, 0xFF0000FF, "Gunakan: /givemoney [id/nama] [jumlah]");
    }
    
    if (!IsPlayerConnected(targetid)) {
        return SendClientMessage(playerid, 0xFF0000FF, "Pemain tidak ditemukan.");
    }
    
    if (amount <= 0 || PlayerData[playerid][pCash] < amount) {
        return SendClientMessage(playerid, 0xFF0000FF, "Jumlah tidak valid atau uang tidak cukup.");
    }

    PlayerData[playerid][pCash] -= amount;
    PlayerData[targetid][pCash] += amount;
    SendClientMessage(playerid, 0x00FF00FF, "Transfer berhasil.");
    SendClientMessage(targetid, 0x00FF00FF, "Anda menerima uang transfer.");
    return 1;
}
```

### 3. `y_iterate` (High-Performance `foreach`)
Never write `for (new i = 0; i < MAX_PLAYERS; i++)`. It wastes CPU iterating over empty player slots.

```pawn
#include <YSI_Data\y_iterate>

// Built-in Player iterator: O(connected players) instead of O(MAX_PLAYERS)
stock BroadcastAdmin(const message[]) {
    foreach (new i : Player) {
        if (PlayerData[i][pAdminLevel] > 0) {
            SendClientMessage(i, 0xFFFF00FF, message);
        }
    }
}

// Custom dynamic iterators (e.g. Faction Members)
new Iterator:PoliceOfficers<MAX_PLAYERS>;

// When player joins police:
Iter_Add(PoliceOfficers, playerid);

// When player leaves:
Iter_Remove(PoliceOfficers, playerid);

// Dispatch radio message only to active police:
stock PoliceRadio(const radioMsg[]) {
    foreach (new copID : PoliceOfficers) {
        SendClientMessage(copID, 0x0080FFFF, radioMsg);
    }
}
```

### 4. `y_bit` (Cell Packing for Memory Efficiency)
Saves 96.8% RAM for boolean states by packing 32 flags into single cells.

```pawn
#include <YSI_Data\y_bit>

new Bit:IsTazed<MAX_PLAYERS>;
new Bit:HasBeltOn<MAX_PLAYERS>;

// Set bit
Bit_Set(IsTazed, playerid, true);

// Check bit
if (Bit_Get(IsTazed, playerid)) {
    // Player is currently tazed
}
```

### 5. `y_timers` (Declarative Modern Timers)
```pawn
#include <YSI_Coding\y_timers>

// Task runs every 60 seconds automatically
task SaveAllAccounts[60000]() {
    foreach (new i : Player) {
        if (PlayerData[i][pLoggedIn]) {
            Database_SaveAccount(i);
        }
    }
}

// Delayed function execution (timer with arguments)
ptask FuelConsumption[10000](playerid) {
    if (IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
        Vehicle_DeductFuel(GetPlayerVehicleID(playerid), 1.0);
    }
}
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


---
name: samp-fivem-oxlib-target-logic
description: True FiveM-Style Logic Architecture in PAWN for SA-MP & open.mp — ox_target (Third-Eye camera raycast targeting for dynamic objects, vehicles, NPCs, doors), ox_lib reusable framework (animated Toast Notify, cancelable ProgressBar with props/animations, multi-round SkillCheck minigame, polar Radial Menu, Context Menu), and QBox/qb-core event-driven player state & metadata bus.
---

# FiveM `ox_lib` + `ox_target` + `QBox` Logic Architecture in PAWN

What separates a **2026 FiveM-caliber SA-MP/open.mp server** from a dated 2012 script isn't just colors — it's **interaction architecture**. Instead of memorizing `/commands`, walking into spinning pickups, or navigating ugly grey `ShowPlayerDialog` walls, every system calls one unified, reusable **FiveM `ox_lib` + `ox_target` core**.

---

## 1. `ox_target` (Third-Eye Camera Raycast Engine)

When the player holds **`[ALT]` (`KEY_WALK`)** (or taps the Mobile `[EYE]` HUD button), a crisp center crosshair dot appears. Looking at ANY registered **Dynamic Object** (ATM, vending machine, door, crafting bench, loot crate), **Dynamic Actor** (NPC), or **Vehicle** highlights the dot in Emerald/Cyan and opens contextual floating options right beside the crosshair!

### Exact 3D Camera-to-Entity Raycast Math (Zero Lag)
```pawn
#include <open.mp>
#include <streamer>
#include <YSI_Coding\y_hooks>

// Returns true if player's camera is looking directly at point (tx, ty, tz) within maxDist & cone tolerance
stock bool:IsCameraTargetingPoint(
    playerid,
    Float:tx, Float:ty, Float:tz,
    Float:maxDist = 3.5,
    Float:minDot = 0.94 // ~20-degree focus cone
)
{
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    // Quick distance reject before vector math
    new Float:dxP = tx - px, Float:dyP = ty - py, Float:dzP = tz - pz;
    if ((dxP*dxP + dyP*dyP + dzP*dzP) > (maxDist * maxDist))
        return false;

    new Float:cx, Float:cy, Float:cz;
    new Float:fx, Float:fy, Float:fz;
    GetPlayerCameraPos(playerid, cx, cy, cz);
    GetPlayerCameraFrontVector(playerid, fx, fy, fz);

    new Float:vx = tx - cx, Float:vy = ty - cy, Float:vz = tz - cz;
    new Float:len = floatsqroot(vx*vx + vy*vy + vz*vz);
    if (len < 0.001) return false;

    // Normalize camera-to-target vector and compute dot product with camera front vector
    new Float:dot = (vx * fx + vy * fy + vz * fz) / len;
    return (dot >= minDot);
}
```

### Target Registry Pattern (Zero Hardcoding Across Modules)
Every module (ATM, Doorlock, Shop NPC, Vehicle Trunk, Job Bench) registers targetable zones once:
```pawn
enum E_TARGET_KIND
{
    TARGET_NONE = 0,
    TARGET_ATM,
    TARGET_DOOR,
    TARGET_ACTOR_NPC,
    TARGET_VEHICLE_TRUNK,
    TARGET_VEHICLE_HOOD,
    TARGET_LOOT_BAG,
    TARGET_CRAFT_BENCH
};

// When player holds ALT, check nearby Streamer Areas + closest Vehicle (O(1) spatial query!)
// Display floating context options beside crosshair (clickable TextDraw pills):
//   [●] ATM Terminal
//       ├─ Withdraw / Deposit Cash
//       └─ Hack Terminal (if player has Hacker Laptop item)
```
> **Vehicle Bone Targeting:** Compute exact world coordinates of a vehicle's **Hood** and **Trunk** using `GetVehicleModelInfo(modelid, VEHICLE_MODEL_INFO_SIZE, sx, sy, sz)` + `sin`/`cos` of `GetVehicleZAngle`! Looking at the rear opens `Open Trunk`; looking at the front opens `Inspect Engine / Pop Hood`!

---

## 2. `ox_lib` Reusable Component Library in PAWN

Every feature in your gamemode should call ONE clean, reusable `ox_lib` API — never duplicate TextDraw timers or animation boilerplate across 30 job files!

### A. `Ox_ProgressBar` (Cancelable Action + Animation + Prop + Callback)
```pawn
enum E_OX_PROGRESS
{
    bool:oxProgActive,
    oxProgStartTick,
    oxProgDurationMs,
    bool:oxProgCanCancel,
    oxProgCallback[48],
    oxProgExtraId,
    oxProgAttachSlot,
    Timer:oxProgTimer,
    PlayerText:oxProgTD[6]
};
new gOxProg[MAX_PLAYERS][E_OX_PROGRESS];

// One-line FiveM action bar from ANY job, heist, mechanic, or medical module:
stock bool:Ox_ProgressBar(
    playerid,
    const label[],
    durationMs,
    const animLib[] = "",
    const animName[] = "",
    propModel = 0,
    propBone = 6,
    bool:canCancel = true,
    const onCompleteCallback[] = "",
    extraId = 0
)
{
    if (gOxProg[playerid][oxProgActive]) return false;

    gOxProg[playerid][oxProgActive] = true;
    gOxProg[playerid][oxProgStartTick] = GetTickCount();
    gOxProg[playerid][oxProgDurationMs] = durationMs;
    gOxProg[playerid][oxProgCanCancel] = canCancel;
    gOxProg[playerid][oxProgExtraId] = extraId;
    strcopy(gOxProg[playerid][oxProgCallback], onCompleteCallback, 48);

    if (animLib[0] != EOS && animName[0] != EOS)
        ApplyAnimation(playerid, animLib, animName, 4.1, 1, 0, 0, 0, 0, 1);

    if (propModel != 0)
    {
        gOxProg[playerid][oxProgAttachSlot] = 9;
        SetPlayerAttachedObject(playerid, 9, propModel, propBone);
    }
    else gOxProg[playerid][oxProgAttachSlot] = -1;

    CreateOxProgressBarTD(playerid, label);
    // Smooth 50ms tick update (20 FPS fluid fill bar, lightweight on server)
    gOxProg[playerid][oxProgTimer] = repeat OxProgressTick(playerid);
    return true;
}

// Press [X] / KEY_SECONDARY_ATTACK to cancel if canCancel == true!
stock Ox_CancelProgressBar(playerid)
{
    if (!gOxProg[playerid][oxProgActive]) return 0;
    stop gOxProg[playerid][oxProgTimer];
    ClearAnimations(playerid, 1);
    if (gOxProg[playerid][oxProgAttachSlot] != -1)
        RemovePlayerAttachedObject(playerid, gOxProg[playerid][oxProgAttachSlot]);
    DestroyOxProgressBarTD(playerid);
    gOxProg[playerid][oxProgActive] = false;

    // Notify caller callback with success = 0 (cancelled)
    if (gOxProg[playerid][oxProgCallback][0] != EOS)
        CallLocalFunction(gOxProg[playerid][oxProgCallback], "iii", playerid, 0, gOxProg[playerid][oxProgExtraId]);
    return 1;
}
```

### B. `Ox_SkillCheck` (Multi-Round Timing Bar Minigame)
Used by **Lockpicking, Hotwiring, Mining, Fishing, Crafting, CPR Revive, Safe Cracking**:
- Difficulty tiers:
  - `SKILL_EASY`: Zone width `26%`, needle speed `1.1x`
  - `SKILL_MEDIUM`: Zone width `17%`, needle speed `1.5x`
  - `SKILL_HARD`: Zone width `11%`, needle speed `2.1x`
- Supports `rounds = 1..5` (e.g., bank vault requires 4 consecutive hits; missing 1 round fails immediately with alarm SFX `PlayerPlaySound(1055)` and invokes `callback(playerid, 0, extraId)`!).
- Pressing `KEY_YES` (`Y`), `KEY_SPRINT` (`SPACE`), or tapping the Mobile `[HIT]` pill checks `needlePos >= zoneStart && needlePos <= zoneEnd`.

### C. `Ox_RadialMenu` (Polar 6–8 Slice Wheel Menu `[F1]` / `[N]`)
Replaces bloated `/v`, `/anim`, `/faction`, `/citizen` menus with a sleek FiveM **Polar Wheel**:
```pawn
// Places N slices cleanly around screen center (320.0, 240.0) with 16:9 X aspect correction!
stock GetRadialSlicePos(sliceIndex, totalSlices, Float:radiusY, &Float:outX, &Float:outY)
{
    new Float:angleDeg = (360.0 / float(totalSlices)) * float(sliceIndex) - 90.0; // Start at 12 o'clock
    new Float:radiusX = radiusY * 0.75; // 16:9 widescreen aspect correction!
    outX = 320.0 + (radiusX * floatcos(angleDeg, degrees));
    outY = 240.0 + (radiusY * floatsin(angleDeg, degrees));
}
```
- Supports **nested sub-menus** (e.g., Main Wheel -> `Vehicle` -> `Engine`, `Lock`, `Trunk`, `Hood`, `Seatbelt`, `Neon`, `Back`).
- Center hub `[X]` closes cleanly (essential for SA-MP Mobile Android players!).

### D. `Ox_Notify` (Animated Stacked Toast Queue + Crisp Sound Feedback)
- Max 4 simultaneous stacked toasts (top-right or bottom-right).
- Semantic types with matching GTA UI sound cues:
  - `"success"` (`0x10B981FF` + `PlayerPlaySound(1057)`)
  - `"error"` (`0xEF4444FF` + `PlayerPlaySound(1055)`)
  - `"warning"` (`0xF59E0BFF` + `PlayerPlaySound(1085)`)
  - `"info"` (`0x38BDF8FF` + `PlayerPlaySound(1056)`)

---

## 3. `QBox` / `qb-core` Event-Driven Player State & Metadata Pattern

Never scatter random `pCuffed[MAX_PLAYERS]`, `pDead[MAX_PLAYERS]`, `pHungry[MAX_PLAYERS]` globals across 40 files. Centralize clean **State Bags** with event hooks:

```pawn
enum E_PLAYER_STATE_FLAGS (<<= 1)
{
    PSTATE_NONE        = 0,
    PSTATE_DEAD        = 1,
    PSTATE_LAST_STAND,        // Knocked down, bleeding, can call EMS
    PSTATE_HANDCUFFED,
    PSTATE_ESCORTED,
    PSTATE_IN_TRUNK,
    PSTATE_SEATBELT,
    PSTATE_ON_DUTY,
    PSTATE_BUSY_ACTION        // Mutex: blocks opening inventory/phone during progress bar
};

new E_PLAYER_STATE_FLAGS:gPlayerFlags[MAX_PLAYERS];

// Single source of truth guard checked by Inventory, Phone, Jobs, Radial Menu, Target:
stock bool:CanPlayerInteract(playerid)
{
    return !(gPlayerFlags[playerid] & (PSTATE_DEAD | PSTATE_LAST_STAND | PSTATE_HANDCUFFED | PSTATE_IN_TRUNK | PSTATE_BUSY_ACTION));
}
```
> **Rule:** Never allow a player to open their Phone, use Inventory, or trigger a Job while `PSTATE_HANDCUFFED | PSTATE_LAST_STAND | PSTATE_BUSY_ACTION` is set! One shared guard eliminates 90% of RP exploits.

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


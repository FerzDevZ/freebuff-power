---
name: samp-fivem-inventory-metadata
description: FiveM ox_inventory-Grade Grid, Weight, Rich Item Metadata & Hotbar [1-5] Architecture for SA-MP & open.mp — dual-panel TextDraw grid UI (Pockets + Trunk/Glovebox/Ground Bag/House Safe/Shop/Crafting), rich per-slot metadata (weapon serial & durability, vehicle keys by plate, ID cards, food freshness), 3D ground drop bags with ColAndreas Z-snap, and anti-dupe stash concurrency locking.
---

# FiveM `ox_inventory` Grid, Metadata & Anti-Dupe Architecture (PAWN 2026)

Legacy 2012 SA-MP inventories (`DIALOG_STYLE_LIST` + `invItemID` + `invAmount` + spinning ground pickups) cannot support modern RP depth. Modern 2026 servers implement **`ox_inventory` architecture**: a **dual-panel visual grid**, **weight limits**, **rich per-slot metadata**, **quick hotbar `[1-5]`**, **3D physical ground drop bags**, and **strict anti-dupe stash mutexes**.

---

## 1. Rich Item Registry & Per-Slot Metadata Schema

Every slot stores **structured metadata** — so two Pistols can have different serial numbers and durability, and two Vehicle Keys open different cars!

```pawn
#define MAX_INV_SLOTS        (25)  // 5x5 grid (Slots 0..4 = Quick Hotbar [1]-[5])
#define MAX_HOTBAR_SLOTS     (5)
#define MAX_PLAYER_WEIGHT_G  (30000) // Store weight in GRAMS (int) — avoids floating-point drift!

enum E_ITEM_CATEGORY
{
    CAT_MISC = 0,
    CAT_CONSUMABLE,
    CAT_WEAPON,
    CAT_AMMO,
    CAT_KEY,
    CAT_DOCUMENT,
    CAT_TOOL,
    CAT_ILLEGAL
};

enum E_ITEM_SLOT
{
    slotDbId,
    slotItemId,           // 0 = empty
    slotCount,
    slotDurability,       // 0..1000 (represents 0.0% .. 100.0% — weapons, pickaxes, food freshness)
    slotMetaInt1,         // e.g. Vehicle DB ID for keys, Weapon Ammo loaded, Citizen ID
    slotMetaInt2,         // e.g. Weapon attachments bitmask, Expire Unix timestamp
    slotMetaStr[32]       // e.g. Weapon Serial "WP-99214A", Vehicle Plate "LS-402K", ID Card Name
};
new PlayerInv[MAX_PLAYERS][MAX_INV_SLOTS][E_ITEM_SLOT];
```
> **Integer Grams Rule:** Always store item weights in **integer grams** (`250` = 0.25 kg, `30000` = 30.0 kg) and format as `float(grams) / 1000.0` ONLY for UI display! Floating-point accumulation bugs (`29.999998 kg`) cause subtle exploit/lock bugs.

---

## 2. Dual-Panel Visual Grid Layout (Strict 256 PlayerTD Budget)

How to render a **FiveM Dual-Panel Inventory (Left: Pockets 5x4 + Right: Trunk/Drop/Safe 5x4)** while staying **well under the 256 `PlayerTextDraw` limit**:
- **Move ALL Static Frames, Headers, Dividers & Button Backdrops to Global `TextDraw`s (`~28 Global TDs`, 0 PlayerTDs!)**
- **PlayerTextDraws per Grid Cell = ONLY 3 TDs** (`1x Font 5 3D Model Preview selectable tile`, `1x count badge`, `1x bottom durability strip` — or `2 TDs` per cell for ultra-compact 40-slot dual grids = **`80 PlayerTDs total`**!):
  - Left Panel (Player Pockets, `20` visible slots + `5` Hotbar badges): `~55 PlayerTDs`
  - Right Panel (Secondary Stash, `20` visible slots): `~45 PlayerTDs`
  - Center Action Column (`USE` | `GIVE` | `DROP` | `SPLIT` | `AMOUNT` | `[X] CLOSE` + Tooltip Inspector): `~18 PlayerTDs`
  - **Total Modal Cost: `~118 PlayerTDs`** (leaving `138` slots free for HUD + Toasts!).

### Click-to-Transfer State Machine (PC + Android Mobile Friendly!)
Since SA-MP lacks native mouse drag-and-drop, FiveM-grade UX uses **1-Click Select -> 1-Click Destination**:
1. Click Slot A (`Player Slot 3`) -> border highlights Emerald (`0x10B981FF`), center Tooltip shows full metadata (`Heavy Pistol | Serial: WP-4821A | Cond: 86% | 1.25 kg`).
2. Click **Slot B** (`Empty Slot 9` or `Trunk Slot 2`) -> **Instant Move/Swap/Stack** with soft click SFX (`PlayerPlaySound(1054)`)!
3. Click **`USE`** -> executes item handler (eats burger with animation + progress bar, equips weapon, unlocks nearby car matching `slotMetaInt1`).
4. Click **`SPLIT`** -> splits stack cleanly (`count / 2` or user-entered amount).
5. Click **`DROP`** -> spawns a **physical 3D Bag (`model 1550` / `2919`)** snapped cleanly to ground Z via ColAndreas (`CA_FindZ_For2DCoord`), NEVER a spinning pickup!

---

## 3. Anti-Dupe Stash Concurrency Locking (Critical Security Invariant)

The #1 item duplication exploit in multiplayer RP is two players opening the same **Vehicle Trunk**, **House Safe**, or **Ground Drop Bag** simultaneously and clicking `Take` on the same frame.

### Strict Single-Editor Stash Mutex
```pawn
enum E_STASH_TYPE
{
    STASH_NONE = 0,
    STASH_TRUNK,
    STASH_GLOVEBOX,
    STASH_GROUND_DROP,
    STASH_HOUSE_SAFE,
    STASH_FACTION_LOCKER,
    STASH_PLAYER_FRISK
};

// Track which player currently holds the exclusive write-lock on a stash
stock bool:AcquireStashLock(playerid, E_STASH_TYPE:stashType, stashEntityId)
{
    new currentHolder = GetStashLockHolder(stashType, stashEntityId);
    if (currentHolder != INVALID_PLAYER_ID && currentHolder != playerid && IsPlayerConnected(currentHolder))
    {
        Ox_Notify(playerid, "Stash Busy", "Someone else is currently accessing this storage.", "warning", 3000);
        return false;
    }
    SetStashLockHolder(stashType, stashEntityId, playerid);
    return true;
}
```
**Mandatory Lock Release Hooks:** Always call `ReleasePlayerStashLock(playerid)` inside:
- Inventory Close (`[X]` or `ESC`)
- `OnPlayerDisconnect`
- `OnPlayerDeath`
- Distance Watchdog (`if (GetPlayerDistanceFromPoint(...) > 5.0) ForceCloseInventory(playerid);`) — stops players walking away while holding a vehicle trunk open!

---

## 4. Hotbar `[1]`–`[5]` Quick-Equip & Weapon Durability

- Slots `0..4` map directly to Quick Hotbar `[1]..[5]`.
- Pressing Quick-Slot key (or tapping compact Hotbar pills on SA-MP Mobile):
  - If slot contains a **Weapon**: checks `slotDurability > 0`, equips weapon + matching ammo from inventory, shows subtle bottom-center FiveM equip card (`EQUIPPED: Combat Pistol [86%]`), removes back-holster prop (`RemovePlayerAttachedObject`).
  - Every shot fired (`OnPlayerWeaponShot`) decrements `slotDurability` by `1`–`3` points; at `0`, weapon jams (`Ox_Notify(..., "Weapon Jammed", "Needs repair at Gunsmith.", "error")`).
  - If slot contains **Bandage / Medkit / Food**: triggers `Ox_ProgressBar` with prop + animation directly without opening full inventory!

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


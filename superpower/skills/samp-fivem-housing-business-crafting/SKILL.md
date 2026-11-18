---
name: samp-fivem-housing-business-crafting
description: FiveM-Style Housing, Live Furniture Editor, Closed-Loop Player Businesses & Crafting Bench Systems for open.mp & SA-MP — MLO/Shell houses with Streamer_UpdateEx anti-fall, roommate keys, house safes & wardrobes, EditDynamicObject gizmo furniture placement + retexturing, player-owned 24/7/Fuel/Dealership/Workshop businesses feeding Trucking restock orders, and blueprint Crafting Benches.
---

# FiveM Housing, Closed-Loop Businesses & Crafting Benches (open.mp 2026)

Connect real estate, commerce, and item creation into one **living closed-loop economy** where every player purchase fuels another player's job!

---

## 1. Modern Housing & Live Furniture Editor

### Isolated Virtual Worlds + Anti-Fall Entry
- Each house uses `worldid = HOUSE_VW_OFFSET + houseDbId` so 500 houses can safely share 12 luxury custom MLO shells without collision!
- Entering (`[Y]` / `ox_target` on front door) ALWAYS calls `TeleportToCustomMLO(playerid, ..., preloadMs = 600)` (`Streamer_UpdateEx` with `freezeplayer = 1`) so players NEVER fall through custom floors.
- **Roommate & Key Management:** House owners grant/revoke keys to up to 4 friends (`house_keys` table) with granular permissions (`CanEnter`, `CanOpenSafe`, `CanDecorate`, `CanUseGarage`).
- **Interactive Furniture (`EditDynamicObject` + `SetDynamicObjectMaterial`):**
  - Buy furniture from IKEA/Furniture Store catalog (Font 5 3D model preview cards).
  - Place inside house (`house_furniture(id, house_id, model, x, y, z, rx, ry, rz, mat_preset)`).
  - Special functional furniture: placing a **Safe (`2332`)** unlocks a `100kg` House Stash (`ox_inventory` right-panel); placing a **Wardrobe (`2336`)** unlocks Saved Outfits; placing a **Workbench (`19921`)** enables home crafting!
  - **Anti-Exploit Bound Check:** Reject `OnPlayerEditDynamicObject` if `(x, y, z)` leaves the house's `MAX_FURNITURE_RADIUS` or clips outside shell bounds.

---

## 2. Closed-Loop Player-Owned Businesses

Every city store (`24/7 Market`, `Gas Station`, `Dealership`, `Clothing Store`, `Gunsmith`, `Mechanic Workshop`, `Restaurant`) is ownable and feeds real work to the server:

```text
[Miner / Lumberjack / Farmer]
        │  sells raw ore / wood / produce
        ▼
[Refinery / Warehouse Stock] ──▶ [Trucker Contract Board]
                                        │  delivers physical trailer cargo
                                        ▼
                             [Player-Owned 24/7 / Gas Station]
                                        │  retail sales + employee payroll
                                        ▼
                             [Business Vault + Daily Upkeep Tax Sink]
```

### Business Management Tablet (`[Y]` inside Back Office)
- **Pricing Control:** Set retail prices clamped within `[minFairPrice, maxFairPrice]` (prevents griefing water bottles at `$99,999`).
- **Restock Order Dispatcher:** Owner pays wholesale cost -> creates a live contract on the **Trucking Job Board** with optional driver bonus tip for fast delivery!
- **Employee Roster & Commission:** Hire real players as Cashiers/Mechanics/Salespeople with automatic `%` commission per sale.
- **Inactivity Auto-Foreclosure:** If owner is offline > 14 days OR fails to pay daily property upkeep tax for 5 consecutive days, business safely returns to City Auction (prevents dead-owner stagnation!).

---

## 3. Blueprint Crafting Bench System

Replace NPC vending of endgame gear with tactile **Crafting Benches** (Legal Workshop Bench + Underground Illegal Gunsmith Bench):

```pawn
enum E_CRAFT_RECIPE
{
    recipeId,
    recipeOutputItemId,
    recipeOutputCount,
    recipeReqItem[3],     // Up to 3 input ingredients
    recipeReqCount[3],
    recipeReqBlueprintId, // Optional rare blueprint item needed
    recipeDurationMs,
    recipeMinSkillLevel
};
```
- Opening a bench via `ox_target` displays a clean FiveM Crafting Card Grid (Font 5 output preview, ingredient checkmarks `Iron Ingot 4/4 ✔`, craft duration, success rate).
- Clicking `CRAFT`:
  1. Verifies ingredients atomically & locks player via `PSTATE_BUSY_ACTION`.
  2. Runs `Ox_ProgressBar` (wrench/welding animation + spark prop) + optional `Ox_SkillCheck`.
  3. Deducts ingredients FIRST, then grants crafted item with fresh metadata (`Serial: CR-9182`, `Durability: 1000`, `CraftedBy: PlayerName`) and awards Crafting XP!

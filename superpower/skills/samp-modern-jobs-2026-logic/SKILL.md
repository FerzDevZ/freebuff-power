---
name: samp-modern-jobs-2026-logic
description: Modern 2026 SA-MP & open.mp Job Systems & Closed-Loop Economy Logic Master — FiveM-inspired multi-stage interactive jobs (Trucking/Logistics, Mining/Fishing/Lumberjack with TextDraw skill-check minigames, Food/Courier Delivery with surge pricing, Mechanic Diagnostics, Police/EMS MDT, Illegal Heists), strict Finite State Machines (FSM), Co-op Party Jobs, XP/Leveling, and server-side anti-exploit payout validation.
---

# Modern 2026 SA-MP & open.mp Job & Economy Logic Master

Modern 2026 SA-MP/open.mp players reject archaic 2012 jobs (`/work` -> drive to 1 red checkpoint -> instant `$500`). Modern jobs emulate **FiveM QBox / NoPixel 4.0 / Top Indonesian & Global RP** standards: tactile multi-stage loops, skill-check minigames, co-op party multipliers, closed-loop economy supply chains, and bulletproof server-side state validation.

---

## 1. Strict Finite State Machine (FSM) Architecture

Every job MUST run as an explicit Finite State Machine per player so skipping steps, re-entering checkpoints, or packet-spoofing double payouts is **structurally impossible**.

```pawn
enum E_JOB_TYPE
{
    JOB_NONE = 0,
    JOB_TRUCKER,
    JOB_MINER,
    JOB_FISHERMAN,
    JOB_COURIER,
    JOB_MECHANIC,
    JOB_LUMBERJACK,
    JOB_FARMER,
    JOB_GARBAGE_COOP
};

enum E_JOB_STAGE
{
    STAGE_IDLE = 0,
    STAGE_CONTRACT_ACCEPTED,
    STAGE_PICKUP_CARGO,
    STAGE_LOADING_MINIGAME,
    STAGE_IN_TRANSIT,
    STAGE_UNLOADING,
    STAGE_RETURN_VEHICLE,
    STAGE_COOLDOWN
};

enum E_PLAYER_JOB_SESSION
{
    E_JOB_TYPE:pJobType,
    E_JOB_STAGE:pJobStage,
    pJobContractId,
    pJobVehicleId,
    pJobTrailerId,
    pJobPartyId,
    pJobStartTick,        // Anti-teleport / minimum duration check
    pJobCheckpointsDone,
    pJobCheckpointsTotal,
    Float:pJobTargetX,
    Float:pJobTargetY,
    Float:pJobTargetZ,
    pJobExpectedPayout
};
new PlayerJob[MAX_PLAYERS][E_PLAYER_JOB_SESSION];
```

### Mandatory Server-Side Anti-Exploit Gate Before Any Payout
```pawn
stock bool:ValidateJobCompletion(playerid, expectedStage, minDurationMs, Float:maxDist = 8.0)
{
    if (PlayerJob[playerid][pJobStage] != expectedStage)
        return false;

    if (!IsPlayerInRangeOfPoint(playerid, maxDist,
        PlayerJob[playerid][pJobTargetX],
        PlayerJob[playerid][pJobTargetY],
        PlayerJob[playerid][pJobTargetZ]))
        return false;

    new elapsed = GetTickCount() - PlayerJob[playerid][pJobStartTick];
    if (elapsed < minDurationMs)
    {
        // Log suspicious speed/teleport completion to staff Discord webhook
        LogAntiCheatAlert(playerid, "JOB_SPEED_EXPLOIT", elapsed, minDurationMs);
        return false;
    }

    return true;
}
```

---

## 2. Modern 2026 Job Blueprints (Interactive & Tactile)

### A. Logistics & Trucking (Closed-Loop Business Supply)
Instead of fake NPC deliveries, Trucking connects directly to **Player-Owned Businesses**:
1. **Contract Board UI (TextDraw / Tablist):** Shows real restock orders placed by 24/7 stores, Dealerships, Gas Stations, and Ammunations (Cargo Type, Weight, Fragility, Distance, Payout + Tip).
2. **Trailer Verification:** Player drives to Industrial Depot, attaches real trailer (`IsTrailerAttachedToVehicle(vehid)`), and waits for animated loading bar (`6s`).
3. **Fragility Tracking:** Vehicle health delta during transit reduces bonus if cargo is damaged (`healthLoss > 150.0` -> `-20%` fragile bonus).
4. **Delivery & Atomic Settlement:** On arrival at target business, verify `GetVehicleTrailer(vehid) == pJobTrailerId`, deduct warehouse stock, increment business product stock, and transfer payout in a single MySQL transaction!

### B. Gathering Jobs (Mining / Lumberjack / Fishing / Farming)
Never give free loot just for pressing a button — add tactile engagement:
1. **Dynamic World Nodes:** Use Incognito Streamer (`CreateDynamicObject` + `CreateDynamic3DTextLabel` + `CreateDynamicArea`) for ore veins, trees, or fishing hotspots. Nodes deplete after `N` harvests and respawn cleanly via timer.
2. **Skill-Check Mini-Game (FiveM Ox_lib Style):**
   - Trigger an interactive TextDraw bar with a moving indicator and a green sweet-spot zone.
   - Hitting the sweet spot grants **Critical Yield (+1 bonus ore / rare grade fish)** and faster progress.
   - Missing reduces tool durability (`PickaxeDurability--`) and triggers stumble animation.
3. **Multi-Step Refining Pipeline (Raw -> Refined -> Market):**
   - `Raw Iron Ore` -> Smelter Foundry -> `Iron Ingot` -> Sold to Dynamic Commodity Market OR crafted into Mechanic Repair Kits / Weapon Parts!

### C. Modern Courier / Food Delivery (Gojek / UberEats RP Style)
- Uses player's personal bike/scooter or rented moped.
- Live Smartphone Dispatch App notifies nearby couriers when NPC or real players order food/packages.
- **Hot-Zone Surge Multiplier (`1.2x`–`1.8x`)** based on real-time city demand + **On-Time Speed Bonus** (deliver within target ETA without crashing -> higher Driver Rating `4.9★`).

### D. Co-op / Party Jobs (Garbage Crew / Armored Bank Van / Group Heists)
Playing together retains 3x more players than solo grinding:
- **Party System (`MAX_JOB_PARTIES = 64`, up to 4 players/party):**
  - Party Leader invites nearby players (`[E]` or `/party invite`).
  - Example (**Garbage Collector Co-op**): Driver navigates truck to residential bins while 1–2 Loaders hop off, pick up animated trash bag (`SetPlayerAttachedObject`), toss into truck rear (`[E]`), filling truck capacity (`0% -> 100%`).
  - **Shared Payout + Co-op Bonus (`+15%` per active party member)** distributed automatically upon dumping at landfill.

### E. Interactive Mechanic & Vehicle Wear System
- Vehicles track realistic wear components: `EngineWear`, `OilLevel`, `TireCondition`, `BodyHealth`.
- Mechanic walks up to hood, presses `[E]` -> opens **FiveM Diagnostic TextDraw** showing each part's % health and required spare parts (`Component` items from Mechanic inventory).
- Repairing plays wrench animation (`ApplyAnimation(..., "BD_FIRE", "wash_up", ...)`) + 5-second progress bar -> updates vehicle DB record.

---

## 3. Dynamic Player-Driven Economy & Inflation Sinks

A healthy 2026 RP economy NEVER relies on static flat payouts that cause hyperinflation within 2 weeks:

### Dynamic Commodity Market Formula
```pawn
// Price adjusts dynamically based on hourly server-wide supply sold
stock CalculateDynamicPrice(basePrice, soldLastHour, targetHourlySupply)
{
    // Clamp multiplier between 0.65x (oversupplied) and 1.45x (high demand)
    new Float:ratio = float(targetHourlySupply) / float(soldLastHour > 0 ? soldLastHour : 1);
    if (ratio > 1.45) ratio = 1.45;
    if (ratio < 0.65) ratio = 0.65;
    return floatround(float(basePrice) * ratio);
}
```

### Mandatory Money Sinks (Anti-Inflation)
Balance every faucet (jobs) with meaningful sinks:
1. **Tool & Vehicle Maintenance:** Fuel consumption, oil changes, tire wear, pickaxe/rod durability.
2. **Progressive Wealth & Property Tax:** Daily/weekly upkeep on luxury cars, mansions, and businesses.
3. **Insurance & Impound Fees:** Destroying an uninsured supercar costs real repair/impound fees.
4. **Crafting & Upgrades:** Players spend cash + job materials to craft backpacks, vehicle tuning kits, and house furniture.

---

## 4. Job Progression, XP Curve & Daily Quests

```pawn
// Smooth RPG XP curve: Level 1->2 = 150 XP, Level 10->11 = 1500 XP
stock GetRequiredJobXP(currentLevel)
{
    return 100 + (currentLevel * currentLevel * 15) + (currentLevel * 50);
}
```
- **Tier Unlocks (Level 1 -> 5 -> 10 -> 20):**
  - Lv 1: Basic routes / standard vehicle.
  - Lv 5: `+10%` payout bonus, unlocks medium cargo / better tools.
  - Lv 10: Unlocks Hazmat/Express contracts, lower cooldowns, special job uniform/title.
  - Lv 20: Master tier contracts & ability to lead Co-op Crews with `+25%` synergy bonus.
- **Daily Contracts (3 rotating missions/day):** e.g., *"Deliver 4 Fragile Cargos"*, *"Mine 25 Copper Ores"*, *"Complete 1 Co-op Shift"* — keeps daily active users engaged without mindless grinding.

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


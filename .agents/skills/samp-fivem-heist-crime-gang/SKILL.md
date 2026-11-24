---
name: samp-fivem-heist-crime-gang
description: FiveM-Style Illegal Heists, Gang Turf Wars & Underground Economy for open.mp & SA-MP — multi-stage Heist FSM (24/7 Store, Fleeca Bank Vault, Jewelry, Armored Van) with Ox_SkillCheck thermite/hacking, Police MDT silent alarm dispatch, min-police-online guards, global cooldowns, 3D loot bag props, money laundering, Gang Turf capture, graffiti spraying, and NPC drug cornering.
---

# FiveM Illegal Heists, Gang Turf & Underground Economy (open.mp 2026)

A great RP city needs thrilling, balanced **Cops vs Robbers** conflict. Modern 2026 crime systems run on strict **Heist Finite State Machines (FSM)**, require real tools & teamwork, alert **Police MDT** dynamically, and reward **Dirty Money** that must be laundered cleanly.

---

## 1. Universal Heist Guard & FSM Architecture

Never let solo exploiters farm empty servers at 3 AM. Enforce these 4 gates on EVERY heist before stage 1 begins:
```pawn
stock bool:CanStartHeist(playerid, heistType, minPoliceOnline, cooldownSec, requiredItemId)
{
    if (GetOnDutyPoliceCount() < minPoliceOnline)
    {
        Ox_Notify(playerid, "Too Quiet", "Not enough Law Enforcement units on duty.", "warning", 3500);
        return false;
    }
    if (gettime() < gHeistCooldownUntil[heistType])
    {
        Ox_Notify(playerid, "High Security", "This target is currently on lockdown cooldown.", "error", 3500);
        return false;
    }
    if (requiredItemId > 0 && !Inv_HasItem(playerid, requiredItemId, 1))
    {
        Ox_Notify(playerid, "Missing Gear", "You lack the required heist equipment.", "error", 3500);
        return false;
    }
    return true;
}
```

### Multi-Stage Heist Archetypes
1. **Tier 1 — 24/7 Convenience Store Robbery (`minPolice = 2`, `cooldown = 20m`):**
   - Point weapon at **Store Clerk Dynamic Actor** (or use `Lockpick` on Cash Register via `ox_target`).
   - Clerk raises hands (`ApplyDynamicActorAnimation(..., "ROB_BANK", "SHP_HandsUp_Scr")`), silent alarm fires to Police MDT after 5 seconds.
   - Complete `Ox_SkillCheck` (2 easy rounds) + `Ox_ProgressBar` (15s) -> grabs `$2,500–$6,000` Dirty Cash + Back Safe option (`Lockpick` hard).
2. **Tier 2 — Jewelry Store Smash & Grab (`minPolice = 4`, `cooldown = 45m`):**
   - Disable security box on rooftop (`Hacker Laptop` + `Ox_SkillCheck` 3 medium rounds).
   - Smash 8 dynamic glass display cases (`ox_target` -> `Smash Case`, melee animation + glass shatter SFX `1132`) -> collects `Diamond Watches`, `Gold Chains` -> fenced at Black Market NPC.
3. **Tier 3 — Fleeca / Pacific Bank Vault (`minPolice = 6`, `cooldown = 90m`):**
   - **Stage 1 (Thermite Gate):** Use `Thermite Charge` on security door -> `Ox_SkillCheck` (4 hard rounds) -> fire particle object (`18689`) burns lock open (`12s`) -> `MoveDynamicObject` swings gate!
   - **Stage 2 (Vault Terminal Hack):** Use `Encrypted USB` + `Laptop` -> timed keypad/skill-check -> Vault Door opens smoothly (`MoveDynamicObject` rotation + vault alarm SFX).
   - **Stage 3 (Cash Trolleys):** Players grab stacks with `Ox_ProgressBar` (12s) -> attaches **3D Duffel Loot Bag (`model 1550`, bone `1` Spine)** visually marking carriers for pursuing Police!

---

## 2. Dirty Money & Money Laundering Pipeline

- Heists and Drug sales pay **Marked Bills / Dirty Cash** (stored as `ox_inventory` item with metadata worth, NOT instant clean bank cash!).
- Players launder Dirty Cash via:
  - **Underground Laundromat / Car Wash Business** (takes `15%–25%` cut + 3-minute washing timer at physical machine)
  - **Player-Owned Nightclub / Casino Fronts** (slow daily clean conversion, creating deep Mafia/Cartel RP!)

---

## 3. Gang Turf Wars, Graffiti & Drug Pipeline

- **Turf Capture Zones (`CreateDynamicRectangle` + `GangZoneCreate`):**
  - Gangs earn **Influence Points** by spraying custom `SetDynamicObjectMaterialText` graffiti tags in enemy territory, selling drugs on turf corners, or initiating a scheduled **15-minute Turf War** (min 3 defenders online!).
  - Controlling turf grants passive perks: discount at Black Market Arms Dealer, drug lab speed boost, and visible gang map territory color.
- **Drug Processing Chain (Seed -> Grow -> Process -> Corner Sell):**
  - Plant dynamic crop objects (`19473`) in hidden rural zones (persist in MySQL, watered with `Water Bottle`, police can raid & burn!).
  - Process at hidden MLO lab (`Ox_ProgressBar` + chemical fumes) -> package into `5g Bags`.
  - Sell to roaming street **Dynamic Actors** (`ox_target` -> `Offer Product`) with `15%` chance NPC rejects & calls 911 with suspect clothing description!

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


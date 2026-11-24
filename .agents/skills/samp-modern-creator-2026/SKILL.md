---
name: samp-modern-creator-2026
description: Modern 2026 SA-MP & open.mp Full-Stack Server Creator Playbook — FiveM/NoPixel-grade UX in PAWN, [E]/[ALT] proximity context interaction replacing legacy commands, cinematic camera character selection, Smartphone & MDT UI systems, persistent vehicle/garage/trunk lifecycle, closed-loop housing & business economy, and clean modular open.mp + YSI 5 + MySQL R41-4 architecture.
---

# Modern 2026 SA-MP & open.mp Server Creator Playbook

Building a standout SA-MP / open.mp server in 2026 means delivering **FiveM-level polish, seamless ergonomics, and zero-lag open.mp reliability** while remaining accessible to both low-spec PC and Android Mobile players.

---

## 1. The 2026 UX Shift: Context Interaction (`[E]`/`[Y]`) vs Archaic Commands

Players in 2026 should NOT have to memorize 80 slash commands (`/enterhouse`, `/buyitem`, `/openatm`, `/lockveh`).

### Unified Proximity Interaction Dispatcher
Use **Incognito Streamer Dynamic Areas** (`CreateDynamicSphere`) + `OnPlayerEnterDynamicArea` / `OnPlayerLeaveDynamicArea` to show a clean FiveM floating prompt (`[Y] Access ATM` or `[N] Vehicle Menu`) and route `OnPlayerKeyStateChange` automatically:

```pawn
enum E_INTERACT_TYPE
{
    INTERACT_NONE = 0,
    INTERACT_ATM,
    INTERACT_DOOR_ENTER,
    INTERACT_DOOR_EXIT,
    INTERACT_SHOP_247,
    INTERACT_JOB_BOARD,
    INTERACT_GARAGE,
    INTERACT_FUEL_PUMP,
    INTERACT_CRAFTING_BENCH
};

enum E_PLAYER_INTERACT
{
    E_INTERACT_TYPE:pInteractType,
    pInteractEntityId
};
new PlayerInteract[MAX_PLAYERS][E_PLAYER_INTERACT];

// Called when player enters any registered Streamer Dynamic Area
hook OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    new data[2];
    Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);

    if (data[0] != _:INTERACT_NONE)
    {
        PlayerInteract[playerid][pInteractType] = E_INTERACT_TYPE:data[0];
        PlayerInteract[playerid][pInteractEntityId] = data[1];
        ShowInteractPrompt(playerid, E_INTERACT_TYPE:data[0]); // FiveM [Y] pill!
    }
    return 1;
}

hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    if ((newkeys & KEY_YES) && !(oldkeys & KEY_YES)) // 'Y' key (also bindable to mobile touch pill)
    {
        switch (PlayerInteract[playerid][pInteractType])
        {
            case INTERACT_ATM:      OpenFiveMBankUI(playerid, PlayerInteract[playerid][pInteractEntityId]);
            case INTERACT_SHOP_247: OpenFiveMShopUI(playerid, PlayerInteract[playerid][pInteractEntityId]);
            case INTERACT_GARAGE:   OpenFiveMGarageUI(playerid, PlayerInteract[playerid][pInteractEntityId]);
            case INTERACT_JOB_BOARD: OpenJobContractBoard(playerid, PlayerInteract[playerid][pInteractEntityId]);
        }
    }
    return 1;
}
```
> **Zero O(N) Scanning:** Never loop through 500 houses or 100 ATMs inside `OnPlayerKeyStateChange`. Streamer Areas give **O(1) spatial lookup**!

---

## 2. Cinematic Onboarding & Multi-Character System (First-5-Minute Retention)

Your server's first 5 minutes decide whether a player stays for 500 hours or quits immediately:
1. **Smooth Login Camera:** Use `InterpolateCameraPos` & `InterpolateCameraLookAt` gliding over iconic Los Santos landmarks while displaying a minimalist FiveM login/register card.
2. **Multi-Character Selector (3 Slots):**
   - Stand actual character actor/player in a custom mapped studio interior.
   - Left panel: 3 clean FiveM character cards (`Name`, `Level`, `Cash/Bank`, `Job`, `Playtime`).
   - Clicking a card updates the 3D character preview & camera angle smoothly.
3. **Interactive Spawn Selector:** Map/card picker (`Last Location`, `Airport LS`, `Owned House`, `Faction HQ`).
4. **Guided Starter Questline:** First 3 objectives auto-pinned on a subtle HUD tracker (*1. Rent a Faggio at Airport -> 2. Open Bank Account -> 3. Complete 1 Delivery Job*), rewarding starter cash & smartphone.

---

## 3. Core 2026 Systems Checklist (Production Standard)

### A. Modern Smartphone System (TextDraw / CEF)
- Opens on key press (`H` / `/phone` / Mobile touch button) with phone-holding animation (`SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE)`).
- Core Apps:
  - **Contacts / Calls / SMS** (persistent MySQL message threads)
  - **Mobile Banking (M-Banking)** (instant transfer by Account Number or Phone Number + transaction history log)
  - **City Marketplace (Ads / Jual Beli)** (post cars/houses/items with price & call button)
  - **Go-Dispatch / Job App** (accept courier orders, call Taxi/Mechanic/EMS/Police with live GPS pin)
  - **My Garage / Tracker** (locate parked vehicles, pay insurance/impound)

### B. Persistent Vehicle & Garage Ecosystem
- Vehicles NEVER vanish into thin air on logout unless despawned into a **Public Garage** or **Owned House Parking**.
- Track full state in MySQL: `model, pos(x,y,z,a), color1, color2, paintjob, mods[14], fuel, mileage, engine_health, trunk_inventory_id, locked, impounded, plate`.
- **Realistic Features:** Vehicle Keys (share temporary keys with friends), Radial Vehicle Menu (Engine, Lock, Hood, Trunk, Lights, Seatbelt, Cruise Control, Neon/Radio).

### C. Closed-Loop Business & Housing Economy
- **Businesses (24/7, Gas Station, Dealership, Clothing, Restaurant):**
  - Owners set retail prices within fair server bounds, manage employee roster, and place **Restock Orders** directly onto the **Trucker Job Board**.
- **Housing & Interior Decorating:**
  - Buy/rent houses with custom interiors or empty shells.
  - Full **Furniture Editor** using `CreateDynamicObject` + `EditDynamicObject` (save XYZ/Rot/Material texture to MySQL) + House Safe/Wardrobe storage.

### D. Police MDT & EMS Dispatch (Roleplay Depth)
- **Police MDT (Mobile Data Terminal):** Search citizen profiles, vehicle plates, criminal records, issue warrants/BOLOs, log citations/fines, live 911 emergency call queue with 1-click GPS route.
- **EMS Medical System:** Knocked-down/injured state (`Downed` timer + bleeding), localized body-part damage (`OnPlayerTakeDamage` bodypart), defibrillator revive mini-game, hospital billing.

---

## 4. Modern 2026 Modular Codebase Architecture (open.mp + YSI 5)

Never write a 40,000-line monolithic `.pwn` file. Structure every 2026 server by **domain feature module** using `y_hooks`:

```text
my-2026-server/
├── config.json                     # Modern open.mp JSON config
├── pawn.json                       # sampctl dependencies (open.mp, YSI5, MySQL, Streamer, bcrypt)
├── gamemodes/
│   ├── main.pwn                    # Clean entry point: includes modules only
│   └── modules/
│       ├── core/                   # database.pwn, constants.pwn, colors.pwn, utils.pwn
│       ├── ui/                     # fivem_hud.pwn, fivem_speedo.pwn, fivem_toast.pwn, fivem_progress.pwn
│       ├── player/                 # auth_bcrypt.pwn, characters.pwn, needs.pwn, interact_e.pwn
│       ├── inventory/              # grid_inventory.pwn, items_registry.pwn, crafting.pwn
│       ├── jobs/                   # job_fsm.pwn, trucker.pwn, miner.pwn, courier.pwn, mechanic.pwn, party.pwn
│       ├── vehicle/                # vehicle_core.pwn, garage.pwn, fuel_wear.pwn, dealership.pwn
│       ├── property/               # housing.pwn, furniture_editor.pwn, business_loop.pwn
│       ├── phone/                  # phone_core.pwn, app_bank.pwn, app_ads.pwn, app_dispatch.pwn
│       ├── factions/               # police_mdt.pwn, ems_medical.pwn, gang_turf.pwn
│       └── security/               # anticheat_core.pwn, discord_audit.pwn
└── database/
    └── migrations/                 # Versioned SQL schema migrations (001_init.sql, 002_jobs.sql)
```

### Non-Negotiable 2026 Engineering Standards
1. **100% Threaded Async MySQL (BlueG R41-4+)** — zero blocking queries on the main tick thread.
2. **Bcrypt Password Hashing** — never MD5/SHA1/Whirlpool.
3. **`foreach` (`y_iterate`) everywhere** — never `for (new i = 0; i < MAX_PLAYERS; i++)`.
4. **Zero heavy logic in `OnPlayerUpdate`** — use dirty-flagged `y_timers` (`200ms`–`1000ms`) and Streamer areas.
5. **Dual PC + SA-MP Mobile Compatibility** — every keybind interaction has a clean clickable/command fallback.

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


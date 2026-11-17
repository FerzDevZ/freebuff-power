---
name: samp-gamemode-architecture
description: Clean modular architecture for large-scale SA-MP & open.mp roleplay/freeroam/trucking servers — feature-based folder structures, dependency ordering, entity pools, event-driven communication, and CI/CD pipelines.
---

# SA-MP / open.mp Gamemode Architecture Skill

## Architectural Blueprint

### The Fallacy of Monolithic `.pwn`
Monolithic 50,000+ line single-file gamemodes cause:
- Massive compile bottlenecks and lack of Git concurrency.
- Undetected namespace pollution and variable collisions.
- Severe regression risk when modifying independent systems.

### Feature-Based Modular Architecture
```
gamemode/
├── main.pwn                  # Pure bootstrap entry point
├── config/
│   ├── settings.inc          # Core server settings
│   └── constants.inc         # System constants & enumerators
├── core/
│   ├── database.inc          # Database handles & connection pools
│   ├── anticheat.inc         # Low-level RakNet hooks & telemetry
│   └── logger.inc            # File & Discord webhook logger
├── modules/
│   ├── auth/                 # Registration, login, bcrypt, character selector
│   │   ├── auth_callbacks.inc
│   │   ├── auth_dialogs.inc
│   │   └── auth_helpers.inc
│   ├── player/               # Stats, inventory, hunger, injuries
│   ├── vehicle/              # Dynamic dealerships, engine state, trunk, tuning
│   ├── property/             # Houses, businesses, interiors, furniture
│   ├── faction/              # Police, EMS, government, gangs, turf wars
│   ├── economy/              # Dynamic banking, ATM, tax, salary payout
│   ├── jobs/                 # Trucker, courier, miner, lumberjack
│   └── admin/                # Permissions, punishment logs, telemetry, spectate
└── utils/
    ├── formatters.inc        # Time formatting, currency formatting
    └── geometry.inc          # Distance calculations, zone bounds
```

## Module Inclusion Order (`main.pwn`)
The entry point script only coordinates dependencies in logical order:

```pawn
// gamemode/main.pwn
#define FILTERSCRIPT

#if defined open_mp
    #include <open.mp>
#else
    #include <a_samp>
#endif

// Third-party libraries
#include <a_mysql>
#include <streamer>
#include <sscanf2>
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_commands>
#include <YSI_Data\y_iterate>
#include <YSI_Data\y_bit>
#include <bcrypt>

// System Configuration & Constants
#include "config/constants.inc"
#include "config/settings.inc"

// Low-Level Core Subsystems
#include "core/database.inc"
#include "core/logger.inc"
#include "core/anticheat.inc"

// Modular Gameplay Systems
#include "modules/auth/auth_callbacks.inc"
#include "modules/player/player_main.inc"
#include "modules/vehicle/vehicle_main.inc"
#include "modules/property/property_main.inc"
#include "modules/faction/faction_main.inc"
#include "modules/economy/economy_main.inc"
#include "modules/jobs/jobs_main.inc"
#include "modules/admin/admin_main.inc"

main() {
    print("==================================================");
    print("   Enterprise Roleplay Gamemode initialized!      ");
    print("   Powered by open.mp + YSI5 + freebuff-power     ");
    print("==================================================");
}
```

## Entity Pool Pattern (Dynamic Memory Recycling)
Avoid letting ID counters grow indefinitely. Implement reusable slot pools:

```pawn
#define MAX_DYNAMIC_HOUSES 500

enum E_HOUSE_DATA {
    bool:hExists,
    hDBID,
    hOwnerID,
    hPrice,
    Float:hEnterX, Float:hEnterY, Float:hEnterZ,
    Float:hExitX, Float:hExitY, Float:hExitZ,
    hInterior,
    STREAMER_TAG_PICKUP:hPickup,
    STREAMER_TAG_3D_TEXT_LABEL:hLabel
};
new HouseData[MAX_DYNAMIC_HOUSES][E_HOUSE_DATA];
new Iterator:Houses<MAX_DYNAMIC_HOUSES>;

stock House_Create(ownerid, price, Float:x, Float:y, Float:z) {
    new houseid = Iter_Free(Houses);
    if (houseid == cellmin) return -1; // Pool full!

    HouseData[houseid][hExists] = true;
    HouseData[houseid][hOwnerID] = ownerid;
    HouseData[houseid][hPrice] = price;
    HouseData[houseid][hEnterX] = x;
    HouseData[houseid][hEnterY] = y;
    HouseData[houseid][hEnterZ] = z;

    // Create dynamic map entities
    HouseData[houseid][hPickup] = CreateDynamicPickup(1273, 1, x, y, z);
    HouseData[houseid][hLabel] = CreateDynamic3DTextLabel("Rumah Dijual", 0x00FF00FF, x, y, z + 0.5, 15.0);

    Iter_Add(Houses, houseid);
    return houseid;
}

stock House_Destroy(houseid) {
    if (!HouseData[houseid][hExists]) return 0;

    DestroyDynamicPickup(HouseData[houseid][hPickup]);
    DestroyDynamic3DTextLabel(HouseData[houseid][hLabel]);

    HouseData[houseid][hExists] = false;
    Iter_Remove(Houses, houseid);
    return 1;
}
```

## GitHub CI/CD Automated Build (`.github/workflows/build.yml`)
Enforce compilation checks on pull requests and pushes using `sampctl`:

```yaml
name: Gamemode Compile Validation
on: [push, pull_request]

jobs:
  pawn-build:
    name: Build & Syntax Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Codebase
        uses: actions/checkout@v4

      - name: Setup sampctl
        run: |
          curl -sL https://raw.githubusercontent.com/Southclaws/sampctl/master/install.sh | sh
          sudo mv bin/sampctl /usr/local/bin/

      - name: Ensure Dependencies
        run: sampctl package ensure

      - name: Compile Gamemode
        run: sampctl package build
```

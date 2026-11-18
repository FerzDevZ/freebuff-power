---
name: samp-fivem-vehicle-tuning-garage
description: FiveM-Style Persistent Vehicle, Garage, Valet, Impound, Keys Metadata, Fuel/Mileage/Part-Wear, Flatbed Towing, Seatbelt, Cruise Control & Custom Tuning Persistence for open.mp & SA-MP.
---

# FiveM Persistent Vehicle, Garage, Part-Wear & Tuning Architecture (open.mp 2026)

Vehicles are a core pillar of RP identity and economy sinks. Modern 2026 open.mp servers persist every vehicle's exact location, mileage, part wear, fuel, mods, trunk inventory, and key ownership cleanly in MySQL.

---

## 1. Persistent Vehicle Data Model

```pawn
enum E_VEHICLE_STATE
{
    vehDbId,
    vehOwnerCharId,
    vehModel,
    vehPlate[12],
    Float:vehPos[4],        // x, y, z, angle
    vehColor[2],
    vehPaintjob,
    vehMods[14],            // Persistent GTA SA component slots 0..13
    Float:vehFuel,          // 0.0 .. 100.0
    Float:vehMileageKm,     // Realistic odometer
    Float:vehEngineHealth,  // 250.0 .. 1000.0
    vehOilWear,             // 0 .. 1000 (degrades every km -> feeds Mechanic job!)
    vehTireWear,            // 0 .. 1000
    vehBrakeWear,           // 0 .. 1000
    vehGarageId,            // 0 = Spawned in world, >0 = Stored in garage ID
    bool:vehImpounded,
    vehImpoundFee,
    bool:vehLocked,
    bool:vehEngineOn,
    vehNeonColor,           // 0 = none, 1..6 = attached dynamic neon objects
    STREAMER_TAG_OBJECT:vehNeonObj[2]
};
```

---

## 2. Keys Metadata, Hotwiring & Engine Realism

1. **Physical Keys (`ox_inventory` Metadata):**
   - Buying a car puts a `Vehicle Key` item (`slotMetaInt1 = vehDbId`, `slotMetaStr = plate`) into the player's pockets.
   - Players can lend their car simply by handing over a **Duplicate Key** (crafted at Locksmith).
   - Locking/Unlocking (`[L]` or Radial Menu) plays chirp SFX (`PlayerPlaySound(1145)`) + flashes headlights briefly (`SetVehicleParamsEx` lights toggle `250ms`).
2. **Stolen Vehicles & Hotwiring:**
   - Entering an unlocked car without its key keeps engine OFF and shows `[H] Hotwire Vehicle`.
   - Hotwiring triggers `Ox_SkillCheck` (3 medium rounds) + `Ox_ProgressBar` (8s) -> failure triggers car alarm (`alarm = 1` in `SetVehicleParamsEx`) + dispatches theft alert to Police MDT!

---

## 3. Realistic Fuel, Mileage, Part Wear & Seatbelt Physics

- **Fuel & Odometer Timer (`1000ms` per occupied driver vehicle, NEVER `OnPlayerUpdate`):**
  - Compute speed (`km/h`) -> increment `vehMileageKm += speed / 3600.0`.
  - Consume fuel proportional to RPM/speed + idle burn (`0.008` idle, `0.025–0.06` driving).
  - If `vehFuel <= 0.0`: smoothly kill engine (`engine = 0`) + toast `"Out of Fuel — Refuel with Jerrycan or call Mechanic"`.
  - Every `25 km` driven degrades `vehOilWear` & `vehTireWear`; low oil reduces top acceleration and emits engine warning icon on Speedometer (feeding real revenue to **Mechanic players**!).
- **Seatbelt & Ejection Protection:**
  - Toggle `[B]` / Radial Menu -> toggles `PSTATE_SEATBELT` + buckle click SFX + Speedometer `BELT` icon flips Emerald.
  - On high-speed collision (`deltaSpeed > 65 km/h` in `250ms` check): unbuckled players suffer severe HP loss + windshield stun blur; buckled players cut crash damage by `75%`!
- **Cruise Control (`[C]`):** Locks forward velocity vector (`GetVehicleVelocity` -> `SetVehicleVelocity` magnitude clamp) while driver holds steady steering; disengages immediately on brake (`KEY_HANDBRAKE` / `KEY_JUMP`) or collision!

---

## 4. Garages, Valet, Impound & Flatbed Towing

- **Multi-Garage System (Public & House Garages):**
  - Driving into Garage marker -> press `[Y]` -> vehicle despawns cleanly, saves exact `fuel, health, wear, mods, damage panels` to MySQL (`garage_id = X`).
  - Retrieving vehicle opens a **FiveM Garage TextDraw Card List** showing **Font 5 3D preview with exact `vehColor[0], vehColor[1]`**, Plate, Fuel %, Engine %, and Location.
- **Police & Mechanic Impound:**
  - Police/Mechanics impound illegally parked or wrecked vehicles via `ox_target` -> `Impound Vehicle` (`Ox_ProgressBar` 5s) -> sets `vehImpounded = 1, vehImpoundFee = $2,500`, sends SMS notification to owner's Smartphone!
- **Flatbed Towing (`AttachDynamicObjectToVehicle` / `AttachTrailerToVehicle`):**
  - Tow trucks (`525`) use native `AttachTrailerToVehicle`; Flatbeds (`578`) position disabled cars smoothly onto bed coordinates with `ox_target` -> `Load / Unload Vehicle`.

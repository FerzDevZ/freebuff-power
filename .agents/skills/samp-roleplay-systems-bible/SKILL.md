---
name: samp-roleplay-systems-bible
description: The Comprehensive Systems Bible for SA-MP & open.mp Gamemodes — end-to-end architectural blueprints for Heavy Roleplay (Full RP), Trucking Simulator, and Gangwar/Deathmatch servers.
---

# SA-MP / open.mp Roleplay & Game Systems Bible

## System Archetype 1: Heavy Roleplay (Full RP)

### 1. Multi-Character per Account Architecture
Never bind gameplay data directly to the user login account. Use a 1-to-Many relationship:
- `accounts (id, username, password_hash, email, admin_level)`
- `characters (id, account_id, first_name, last_name, gender, birthdate, cash, bank, skin, hours_played)`

```pawn
stock Auth_ShowCharacterSelect(playerid) {
    new query[256];
    mysql_format(gSQL, query, sizeof(query),
        "SELECT id, first_name, last_name, hours_played FROM characters WHERE account_id = %d LIMIT 3",
        PlayerData[playerid][pDBID]);
    mysql_tquery(gSQL, query, "OnCharactersLoaded", "i", playerid);
}
```

### 2. Police Mobile Data Computer (MDC / CAD)
An in-car terminal for Law Enforcement Officers:
- `/mdc` brings up a custom Tablist dialog or responsive TextDraw panel.
- Warrant lookups (`SELECT * FROM warrants WHERE character_id = ...`).
- Vehicle license plate check (`SELECT * FROM player_vehicles WHERE plate = '%e'`).
- Criminal record history and APB (All Points Bulletin) broadcast alerts.

### 3. Medical & Wounded/Death State
Eliminate instant respawn to promote serious medical roleplay:
1. `OnPlayerDeath`: Instead of respawning at hospital, set state to `STATE_INJURED`.
2. Apply lying down animation: `ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0);`.
3. Start 10-minute bleeder timer. Other players can call 911/SAMD.
4. Paramedics can treat wounds using `/revive <id>` or `/cpr <id>`.
5. If timer expires, trigger `/pk` (Player Kill - memory loss of the incident) and hospital spawn.

---

## System Archetype 2: Trucking & Logistics Simulator

### 1. Route & Dynamic Cargo System
- **Cargo Types:** Fragile (Electronics), Flammable (Fuel), Heavy (Steel Beams), Perishable (Produce).
- **Trailer Hitching Check:** Require player to reverse truck into matching trailer:
  ```pawn
  if (IsTrailerAttachedToVehicle(vehicleid)) {
      new trailerid = GetVehicleTrailer(vehicleid);
      // Validate correct cargo trailer model
  }
  ```
- **Dynamic Waypoint Checkpoints:** Spawn GPS checkpoints along scenic highways:
  ```pawn
  SetPlayerRaceCheckpoint(playerid, 0, nextX, nextY, nextZ, finalX, finalY, finalZ, 8.0);
  ```
- **Earnings Formula:**
  $$\text{Payout} = \text{Distance (km)} \times \text{CargoRate} + \text{Bonus}(\text{DamagePercentage})$$

---

## System Archetype 3: Gangwar & Competitive Deathmatch

### 1. Dynamic Turf / Zone Capture System
- Map divided into colored Gang Zones (`GangZoneCreate`, `GangZoneShowForPlayer`).
- Zone War Initiation: A rival gang member kills 3 enemies inside the turf boundary.
- Flashing Zone: `GangZoneFlashForAll(zoneid, COLOR_GROVE_GREEN);`.
- Zone Capture Timer: 10 minutes. Gang with highest player presence inside the zone when timer ends claims ownership and collects hourly cartel revenues.

### 2. Duel & Matchmaking Arena
- Map instances isolated via `VirtualWorld`:
  ```pawn
  stock StartDuel(player1, player2, arenaid) {
      new vw = 1000 + arenaid;
      SetPlayerVirtualWorld(player1, vw);
      SetPlayerVirtualWorld(player2, vw);
      SetPlayerInterior(player1, gArenaInterior[arenaid]);
      SetPlayerInterior(player2, gArenaInterior[arenaid]);
      SetPlayerPos(player1, gArenaSpawnA[arenaid][0], gArenaSpawnA[arenaid][1], gArenaSpawnA[arenaid][2]);
      SetPlayerPos(player2, gArenaSpawnB[arenaid][0], gArenaSpawnB[arenaid][1], gArenaSpawnB[arenaid][2]);
      // Reset weapons & give Deagle + Shotgun
  }
  ```

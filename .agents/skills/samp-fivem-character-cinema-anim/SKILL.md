---
name: samp-fivem-character-cinema-anim
description: FiveM-Style Cinematic Onboarding, Multi-Character Studio, Clothing/Accessory Editor, Spawn Selector Map & Immersive Emote/Prop Systems for open.mp & SA-MP — InterpolateCameraPos swoops, live 3D Actor character carousel, saved outfits, Sit-on-Chair, Carry/Piggyback, Hostage, Walkstyles & Facial/Mood states.
---

# FiveM Cinematic Character Studio, Spawn Selector & Emote Engine (open.mp 2026)

First impressions define player retention. Eliminate clunky SA-MP spawn arrows (`<< >> Spawn`) and replace them with a **NoPixel 4.0 cinematic character & emote experience**.

---

## 1. Bypassing Legacy Class Selection Cleanly

Never let players get stuck on GTA SA's default beach class selector (`OnPlayerRequestClass`):
```pawn
public OnPlayerRequestClass(playerid, classid)
{
    // Immediately put player into Spectator camera mode to hide default Spawn/<< >> buttons!
    TogglePlayerSpectating(playerid, true);
    SetPlayerVirtualWorld(playerid, 10000 + playerid); // Isolated personal studio VW!
    StartCinematicLoginCamera(playerid);
    ShowFiveMLoginUI(playerid);
    return 1;
}
```

### Smooth Cinematic Camera Swoop (`InterpolateCameraPos`)
Glide across downtown Los Santos skyline (Maze Bank -> Vinewood Sign -> Santa Maria Pier) while player logs in:
```pawn
stock StartCinematicLoginCamera(playerid)
{
    InterpolateCameraPos(playerid, 1480.0, -1620.0, 55.0, 1520.0, -1675.0, 28.0, 12000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, 1481.0, -1760.0, 22.0, 1481.0, -1771.0, 19.0, 12000, CAMERA_MOVE);
}
```

---

## 2. Multi-Character Live 3D Studio (3–5 Slots)

1. Load player's characters from MySQL (`characters WHERE account_id = %d`).
2. Spawn a live **Dynamic Actor** (`CreateDynamicActor`) inside a custom lit studio MLO (`worldid = 10000 + playerid`) wearing that character's exact Skin + Saved Accessories (`glasses`, `hat`, `watch`, `backpack`) performing an idle animation (`DEALER_IDLE` / `CROSSARMS`).
3. Left-aligned FiveM Dark Glass Cards show up to 3–5 character slots (`Name`, `Job`, `Cash/Bank`, `Playtime`, `+ Create New Character`).
4. Clicking another slot smoothly rotates the studio camera (`InterpolateCameraPos`, `900ms`) onto that character's Actor!
5. Clicking **`PLAY`** transitions cleanly to the **Spawn Selector Map**:
   - Sleek cards (`Last Location`, `Los Santos Airport`, `Owned House`, `Faction HQ`) with camera preview sweeping over the selected district before calling `TogglePlayerSpectating(playerid, false)` + `SetSpawnInfo` + `SpawnPlayer`!

---

## 3. Clothing Store & Persistent Accessory Editor (`EditAttachedObject`)

- Let players customize up to **6 saved accessory slots** (`Hat`, `Glasses`, `Mask`, `Watch`, `Necklace/Chain`, `Backpack`) using `SetPlayerAttachedObject` + `EditAttachedObject(playerid, slot)` so items fit EVERY GTA skin head/torso perfectly!
- Save exact bone, offsets `(fOffsetX..Z)`, rotations `(fRotX..Z)`, and scale `(fScaleX..Z)` (clamped strictly to `[0.5 .. 1.6]` inside `OnPlayerEditAttachedObject` so trolls cannot scale hats to giant building size!).
- Support **Saved Outfits (Wardrobe)** so Police/EMS/Gangs swap uniforms in 1 click.

---

## 4. Modern Emote, Prop & Shared Interaction System

Accessible via **FiveM Radial Menu `[F1]` -> `Emotes`** or quick `/e <name>`:
- **Prop Emotes:** Automatically attach & clean up prop on animation cancel (`KEY_SPRINT` / `[X]`):
  - `/e coffee` (cup prop + sip loop), `/e umbrella` (open umbrella prop), `/e clipboard` (notepad + write), `/e guitar`, `/e smoke`, `/e sit` (auto-align to nearby chair/bench!).
- **Shared Player Emotes (Consent Prompt `[Y]` Accept / `[N]` Decline):**
  - `Handshake`, `Hug`, `Carry / Piggyback` (syncs attached/position offset cleanly), `Take Hostage` (requires melee/pistol + victim `HandsUp` / `LastStand`).
- **Walkstyles:** Persist preferred gait (`Default`, `Confident`, `Gangster`, `Injured`, `Sneak`, `Woman`).
- **Mandatory Animation Preload:** Preload common animation libraries (`PED`, `DEALER`, `SWEET`, `ROB_BANK`, `MISC`, `CARRY`, `COP_AMBIENT`) once on first spawn (`ApplyAnimation(playerid, lib, "null", 0.0, 0, 0, 0, 0, 0)`) so emotes NEVER fail on first play!

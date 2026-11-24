---
name: samp-voice-spatial-audio
description: Implementing 3D Spatial Proximity Voice Chat & Walkie-Talkie Radio for SA-MP & open.mp using sampvoice — local 3D positional streams (SvCreateLStream), global frequency streams (SvCreateGStream), listener routing, and push-to-talk keybinds.
---

# SA-MP / open.mp sampvoice Spatial Audio Skill

## 1. Installation & Plugin Dependency
- Core Component/Plugin: `sampvoice` (open.mp compatible fork)
- In `config.json` (`open.mp`):
  ```json
  "legacy_plugins": ["sampvoice"]
  ```
  *(Note: If using `Pawn.RakNet`, load `sampvoice` AFTER `Pawn.RakNet`)*
- Include in Pawn:
  ```pawn
  #include <open.mp>
  #include <sampvoice>
  ```

## 2. 3D Spatial Audio Architecture (Local Proximity Stream)
Every player has a local 3D positional audio stream acting as their mouth/speaker. Sound attenuates dynamically with distance:

```pawn
#define VOICE_DISTANCE_PROXIMITY 20.0 // 20 meters hearing bubble

new SV_LSTREAM:gPlayerLocalStream[MAX_PLAYERS] = { SV_NULL, ... };

public OnPlayerConnect(playerid) {
    // 1. Check if client has sampvoice plugin installed
    if (SvGetVersion(playerid) != SV_VERSION_NONE && SvHasMicrophone(playerid)) {
        // Enable microphone input
        SvLiveOpen(playerid);

        // Create 3D spatial stream
        gPlayerLocalStream[playerid] = SvCreateLStream(VOICE_DISTANCE_PROXIMITY, 0);
        if (gPlayerLocalStream[playerid] != SV_NULL) {
            // Attach 3D emitter to player's game character position
            SvAttachStreamToPlayer(gPlayerLocalStream[playerid], playerid);
        }
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if (gPlayerLocalStream[playerid] != SV_NULL) {
        SvDeleteLStream(gPlayerLocalStream[playerid]);
        gPlayerLocalStream[playerid] = SV_NULL;
    }
    return 1;
}
```

## 3. Dynamic Listener Routing (`StreamIn` & `StreamOut`)
To conserve server bandwidth, only route audio to players physically within the streaming zone:

```pawn
public OnPlayerStreamIn(playerid, forplayerid) {
    // 'playerid' is now visible to 'forplayerid'
    if (gPlayerLocalStream[playerid] != SV_NULL && SvGetVersion(forplayerid) != SV_VERSION_NONE) {
        SvAttachListener(gPlayerLocalStream[playerid], forplayerid);
    }
    return 1;
}

public OnPlayerStreamOut(playerid, forplayerid) {
    // 'playerid' left the streaming bubble of 'forplayerid'
    if (gPlayerLocalStream[playerid] != SV_NULL) {
        SvDetachListener(gPlayerLocalStream[playerid], forplayerid);
    }
    return 1;
}
```

## 4. Multi-User Radio Frequency Stream (`SvCreateGStream`)
Used for police, ambulance, taxi, and criminal faction walkie-talkies:

```pawn
new SV_GSTREAM:gFactionRadio[MAX_FACTIONS] = { SV_NULL, ... };

stock Radio_InitFaction(factionid, const radioName[]) {
    gFactionRadio[factionid] = SvCreateGStream(0x00FF88FF, radioName);
}

stock Radio_Join(playerid, factionid) {
    if (gFactionRadio[factionid] != SV_NULL && SvGetVersion(playerid) != SV_VERSION_NONE) {
        SvAttachListener(gFactionRadio[factionid], playerid);
        SvAttachSpeaker(gFactionRadio[factionid], playerid);
        SendClientMessage(playerid, 0x00FF88FF, "[RADIO] Anda terhubung ke frekuensi radio.");
    }
}

stock Radio_Leave(playerid, factionid) {
    if (gFactionRadio[factionid] != SV_NULL) {
        SvDetachListener(gFactionRadio[factionid], playerid);
        SvDetachSpeaker(gFactionRadio[factionid], playerid);
    }
}
```

## 5. Push-To-Talk Keys & Moderation
- Keybind: B key for local proximity voice, Z key for radio frequency.
- Force Mute: `SvLiveStop(playerid)` (e.g., when player is dead, cuffed, or muted by admin).
- Unmute: `SvLiveOpen(playerid)` when revived.

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


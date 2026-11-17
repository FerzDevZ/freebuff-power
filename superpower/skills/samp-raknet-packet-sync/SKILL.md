---
name: samp-raknet-packet-sync
description: Low-level Network Packet Inspection & RPC Engineering for SA-MP & open.mp via Pawn.RakNet — BitStream manipulation, incoming/outgoing packet hooks, sync packets (OnFoot, Driver, Bullet, Aim), and desync lag compensation.
---

# SA-MP / open.mp Pawn.RakNet Packet Sync Skill

## Overview
`Pawn.RakNet` provides low-level network packet manipulation on top of the RakNet network engine. It allows developers to intercept, modify, block, or forge raw network packets (PR) and Remote Procedure Calls (RPC) before they reach the server gamemode or game clients.

---

## 1. Setup & Inclusion
- Plugin: `pawn-raknet.so` / `pawn-raknet.dll`
- Pawn Include: `#include <Pawn.RakNet>`
- In `config.json`:
  ```json
  "legacy_plugins": ["pawn-raknet"]
  ```

---

## 2. Packet Types & IDs
| Packet Constant | ID | Description |
|---|---|---|
| `ID_PLAYER_SYNC` | 207 | On-foot movement (keys, position, quaternions, speed) |
| `ID_VEHICLE_SYNC` | 200 | In-vehicle driving sync (velocity, health, wheels) |
| `ID_PASSENGER_SYNC` | 211 | Passenger seat sync |
| `ID_AIM_SYNC` | 203 | Camera vector and weapon crosshair targeting |
| `ID_BULLET_SYNC` | 206 | Bullet impact coordinate, hit target, and offset |
| `ID_UNOCCUPIED_SYNC`| 209 | Unoccupied vehicle physics sync |

---

## 3. Hooking Incoming Sync Packets (`OnIncomingPacket`)
Inspect and sanitize packets sent from client to server:

```pawn
public OnIncomingPacket(playerid, packetid, BitStream:bs) {
    switch (packetid) {
        case ID_PLAYER_SYNC: {
            new PR_PlayerSync:sync;
            BS_IgnoreBits(bs, 8); // Skip packet ID byte
            BS_ReadPlayerSync(bs, sync);

            // Audit velocity for impossible speed jumps
            new Float:speed = VectorSize(sync[pr_velocityX], sync[pr_velocityY], sync[pr_velocityZ]);
            if (speed > 1.2) { // Impossible on-foot velocity
                printf("[RAKNET] Dropping corrupted on-foot packet from player %d (velocity: %.2f)", playerid, speed);
                return 0; // Drop packet!
            }
        }

        case ID_BULLET_SYNC: {
            new PR_BulletSync:sync;
            BS_IgnoreBits(bs, 8);
            BS_ReadBulletSync(bs, sync);

            // Verify hit position range
            if (sync[pr_hitType] == BULLET_HIT_TYPE_PLAYER) {
                if (sync[pr_hitId] == playerid) {
                    return 0; // Self-damage injection exploit drop
                }
            }
        }
    }
    return 1;
}
```

---

## 4. Hooking RPCs (`OnIncomingRPC` & `OnOutgoingRPC`)
Intercept Remote Procedure Calls:

```pawn
#define RPC_CHAT 101
#define RPC_SHOW_DIALOG 61

public OnIncomingRPC(playerid, rpcid, BitStream:bs) {
    if (rpcid == RPC_CHAT) {
        new textLen, text[144];
        BS_ReadValue(bs, PR_UINT8, textLen);
        BS_ReadString(bs, text, textLen);
        
        // Sanitize control characters or crash strings
        if (strfind(text, "%n") != -1 || strfind(text, "%s") != -1) {
            return 0; // Block format string exploit
        }
    }
    return 1;
}
```

---

## 5. Emitting Custom Packets & Client Sync Fixes
Forge network packets to immediately force client resynchronization:

```pawn
stock ForceResyncPlayer(playerid) {
    new BitStream:bs = BS_New();
    BS_WriteValue(bs, PR_UINT8, ID_PLAYER_SYNC);
    
    // Fill authoritative server position
    new PR_PlayerSync:sync;
    GetPlayerPos(playerid, sync[pr_position][0], sync[pr_position][1], sync[pr_position][2]);
    BS_WritePlayerSync(bs, sync);

    PR_SendPacket(bs, playerid);
    BS_Delete(bs);
}
```

## Safety Rules
- **Always Delete BitStreams:** Never forget `BS_Delete(bs)` on dynamically created BitStreams to avoid native memory leaks.
- **Ignore Bits Correctly:** When reading packet sync structures, skip the 8-bit Packet ID with `BS_IgnoreBits(bs, 8)`.

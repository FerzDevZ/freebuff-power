---
name: samp-sound-audio
description: Sound & audio systems for SA-MP & open.mp — 3D positional sound (PlayerPlaySound), global sound broadcasts, audio streams (PlayAudioStreamForPlayer), radio stations, sound effects, volume control, and integration with sampvoice for proximity voice chat. Use when adding sound effects, music, radio, audio streams, or voice chat to a server.
---

# SA-MP / open.mp Sound & Audio Systems

## 1. Sound Types

| Type | Scope | Native | Use Case |
|------|-------|--------|----------|
| 3D Sound | Positional, distance-based | `PlayerPlaySound` | Gunshots, footsteps, door sounds |
| Global Sound | All players | `PlayerPlaySound` (broadcast) | Explosion, thunder, server events |
| Audio Stream | Per-player URL stream | `PlayAudioStreamForPlayer` | Radio stations, music, podcasts |
| Voice Chat | Proximity 3D | sampvoice plugin | Player voice, walkie-talkie |

## 2. 3D Sound

### 2.1 Playing 3D Sound
```pawn
// Play sound at position (all players hear it based on distance)
PlayerPlaySound(playerid, soundId, x, y, z);
// soundId: GTA SA sound IDs (1000-2000 range for effects)
```

### 2.2 Common Sound IDs
| ID | Sound |
|----|-------|
| 1056 | Gunshot |
| 1057 | Explosion |
| 1085 | Car horn |
| 1130 | Door open |
| 1131 | Door close |
| 1149 | Phone ring |
| 1183 | Cash register |
| 1184 | ATM beep |

### 2.3 Distance & Volume
- Default 3D sound range: ~50 units
- Volume decreases with distance (engine handles this)
- For custom range: check distance manually, don't play if too far

## 3. Audio Streams

### 3.1 Playing Stream
```pawn
PlayAudioStreamForPlayer(playerid, "http://stream.url/radio.mp3", x, y, z, radius, usepos);
StopAudioStreamForPlayer(playerid);
```

### 3.2 Radio System
- Store radio stations in data table (name, URL, genre)
- Player selects station → play stream
- Save last station per player (MySQL)
- Stop stream on disconnect

## 4. Voice Chat (sampvoice)

### 4.1 Proximity Voice
```pawn
// Create local stream (3D positional)
new SvLStream:stream = SvCreateLStream(80.0, VECTOR, SV_NULL, false);
SvAttachListenerToStream(stream, playerid);
```

### 4.2 Walkie-Talkie (Global stream)
```pawn
// Create global stream (all listeners hear equally)
new SvGStream:stream = SvCreateGStream(0, SV_NULL);
SvAttachListenerToStream(stream, playerid);
```

### 4.3 Push-to-Talk
- Bind key (e.g., 'N' or 'B')
- On key press: attach speaker to stream
- On key release: detach speaker
- Show "transmitting" indicator (TextDraw)

## 5. Anti-Patterns

- ❌ Playing sounds for all players when only nearby should hear
- ❌ Not stopping audio streams on disconnect (resource leak)
- ❌ Hardcoded sound IDs without comments
- ❌ No volume control option for players
- ❌ Streaming without buffering (causes stutter)

## 6. Gate

```bash
pawncc sound.pwn -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx
# Runtime: sounds play at correct position, streams work, no leaks on disconnect
```

---

## References

- open.mp audio natives: https://open.mp/docs
- sampvoice: https://github.com/CyberMor/sampvoice
- GTA SA sound IDs: https://wiki.multitheftauto.com/wiki/Sound_IDs
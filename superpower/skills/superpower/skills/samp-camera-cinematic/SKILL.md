---
name: samp-camera-cinematic
description: Camera & cinematic systems for SA-MP & open.mp — camera modes (fixed, follow, orbit, first-person, spectate), cutscene creation with InterpolateCameraPos/LookAt, camera shake, smooth transitions, cinematic bars (letterbox), player spectating, and camera collision avoidance. Use when creating cutscenes, camera effects, spectating systems, or cinematic onboarding sequences.
---

# SA-MP / open.mp Camera & Cinematic Systems

## 1. Camera Modes

| Mode | Use Case | Native |
|------|----------|--------|
| Fixed | Static camera at position | `SetPlayerCameraPos` + `SetPlayerCameraLookAt` |
| Follow | Camera follows player | `SetCameraBehindPlayer` |
| Orbit | Camera orbits around target | `InterpolateCameraPos` + `InterpolateCameraLookAt` |
| First-person | Player's POV | `SetPlayerCameraPos` at player head |
| Spectate | Watch another player | `TogglePlayerSpectating` + `PlayerSpectatePlayer` |
| Vehicle | In-vehicle camera | `SetPlayerCameraPos` relative to vehicle |

## 2. Cutscene Creation

### 2.1 Interpolation
```pawn
// Smooth camera movement
InterpolateCameraPos(playerid, fromX, fromY, fromZ, toX, toY, toZ, duration, cut);
InterpolateCameraLookAt(playerid, fromX, fromY, fromZ, toX, toY, toZ, duration, cut);
```

### 2.2 Cut Types
- `CAMERA_CUT` (0) — instant jump
- `CAMERA_MOVE` (1) — smooth interpolation

### 2.3 Cinematic Bars (Letterbox)
```pawn
// Create black bars top/bottom
TextDrawShowForPlayer(playerid, g_tdCinemaBarTop);
TextDrawShowForPlayer(playerid, g_tdCinemaBarBottom);
```

### 2.4 Camera Shake
```pawn
// Use SetPlayerCameraPos with slight random offset in timer
// Or use SetPlayerDrunkLevel for subtle shake (legacy trick)
```

## 3. Spectating

### 3.1 Player Spectate
```pawn
TogglePlayerSpectating(playerid, true);
PlayerSpectatePlayer(playerid, targetid, SPECTATE_MODE_NORMAL);
// or SPECTATE_MODE_FIXED, SPECTATE_MODE_SIDE
```

### 3.2 Vehicle Spectate
```pawn
PlayerSpectateVehicle(playerid, vehicleid, SPECTATE_MODE_NORMAL);
```

### 3.3 Exit Spectate
```pawn
TogglePlayerSpectating(playerid, false);
SetPlayerPos(playerid, x, y, z);
```

## 4. Collision Avoidance

- Use ColAndreas `CA_RaycastLine` to check if camera path is blocked
- If blocked, move camera closer to player
- Don't let camera clip through walls/objects

## 5. Anti-Patterns

- ❌ No camera interpolation — instant cuts are jarring
- ❌ No collision check — camera clips through walls
- ❌ No spectate cleanup — player stuck in spectate mode
- ❌ No letterbox on cutscenes — breaks immersion
- ❌ Camera shake every frame — causes motion sickness

## 6. Gate

```bash
pawncc camera.pwn -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx
# Runtime: cutscene plays smoothly, no camera clipping, spectate works
```

---

## References

- open.mp camera natives: https://open.mp/docs
- ColAndreas: https://github.com/Pottus/ColAndreas
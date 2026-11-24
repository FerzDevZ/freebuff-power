---
name: samp-weather-time
description: Weather & time systems for SA-MP & open.mp — dynamic weather cycling, time-of-day management, weather sync for all players, interior weather override, weather effects on gameplay (visibility, vehicle handling), and time-based events (day/night cycle, scheduled events). Use when implementing weather systems, time cycles, day/night mechanics, or environmental effects.
---

# SA-MP / open.mp Weather & Time Systems

## 1. Weather System

### 1.1 Weather IDs
| ID | Weather | Visibility |
|----|---------|------------|
| 0 | Extra Sunny (LS) | High |
| 1 | Sunny (LS) | High |
| 2 | Extra Sunny (SM) | High |
| 3 | Sunny (SM) | High |
| 4 | Extra Sunny (LV) | High |
| 5 | Sunny (LV) | High |
| 6 | Sunny (SF) | High |
| 7 | Extra Sunny (C) | High |
| 8 | Sunny (C) | High |
| 9 | Extra Sunny (Countryside) | High |
| 10 | Sunny (Countryside) | High |
| 11 | Extra Sunny (Desert) | High |
| 12 | Sunny (Desert) | High |
| 13 | Extra Sunny (SF) | High |
| 14 | Sunny (SF) | High |
| 15 | Thunder | Low (rain) |
| 16 | Foggy (SF) | Very Low |
| 17 | Extra Sunny (Countryside) | High |
| 18 | Rainy (Countryside) | Low |
| 19 | Extra Sunny (Desert) | High |
| 20 | Sandstorm (Desert) | Very Low |
| ... | ... | ... |

### 1.2 Setting Weather
```pawn
// Global weather (all players)
SetWeather(weatherId);

// Per-player weather (open.mp)
SetPlayerWeather(playerid, weatherId);

// Interior weather override
SetPlayerWeather(playerid, weatherId); // in interior
```

### 1.3 Weather Sync
- Set weather on player connect
- Update weather periodically (timer, e.g., every 30-60 min)
- Sync weather for players entering interiors (override)
- Handle weather transitions smoothly (gradual change)

## 2. Time System

### 2.1 Setting Time
```pawn
// Global time
SetWorldTime(hour); // 0-23

// Per-player time (open.mp)
SetPlayerTime(playerid, hour, minute);

// Time speed
// Default: 1 real minute = 1 game minute (configurable)
```

### 2.2 Time Cycle
- Store current game time in global variable
- Increment every N real seconds (configurable speed)
- Sync to all players periodically
- Handle day/night transitions (lighting, ambient sounds)

### 2.3 Time-Based Events
- Daytime events (shops open, NPCs active)
- Nighttime events (clubs open, police patrols)
- Scheduled events (every hour, at specific time)
- Use timers for recurring checks

## 3. Gameplay Effects

### 3.1 Visibility
- Fog/rain reduces draw distance
- Night reduces visibility (flashlight, vehicle lights)
- Sandstorm reduces visibility to ~20 units

### 3.2 Vehicle Handling
- Rain reduces traction (optional: modify vehicle physics)
- Sandstorm reduces speed (optional: apply speed limit)
- Ice/snow (not native, requires custom)

### 3.3 NPC Behavior
- NPCs may seek shelter in rain
- NPCs may be less active at night
- Police patrols increase at night

## 4. Anti-Patterns

- ❌ No weather sync on connect — players see wrong weather
- ❌ No time sync — players see different times
- ❌ Hardcoded weather — no variety, boring
- ❌ No interior override — weather leaks into interiors
- ❌ Weather changes too fast — jarring transitions

## 5. Gate

```bash
pawncc weather.pwn -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx
# Runtime: weather syncs on connect, time cycles, interiors override correctly
```

---

## References

- open.mp weather/time natives: https://open.mp/docs
- GTA SA weather IDs: https://wiki.multitheftauto.com/wiki/Weather_IDs
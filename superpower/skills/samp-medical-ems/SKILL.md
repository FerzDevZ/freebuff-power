---
name: samp-medical-ems
description: Medical and EMS system for SA-MP/open.mp — injuries, bleeding, healing, hospital, downed state, and revival. Use when building medical systems, EMS jobs, or health mechanics.
---

# SA-MP/Open.mp Medical & EMS System (2026)

## When to Activate
- Building injury/bleeding system
- Implementing hospital/revival
- Creating EMS job with minigames
- Adding medical items (medkit, bandage)
- Designing downed/revive mechanics

## Core Concepts

### 1. Injury System
```pawn
enum E_INJURY {
    inj_type, inj_bodypart, inj_severity,
    inj_bleeding, Float:inj_damage, inj_timestamp
};

stock ApplyInjury(playerid, bodypart, severity) {
    g_injuries[playerid][g_injury_count[playerid]][inj_type] = INJURY_BRUISE;
    g_injuries[playerid][g_injury_count[playerid]][inj_bodypart] = bodypart;
    g_injuries[playerid][g_injury_count[playerid]][inj_severity] = severity;
    g_injuries[playerid][g_injury_count[playerid]][inj_bleeding] = (severity >= 2);
    g_injury_count[playerid]++;
    // Apply health reduction
    new Float:hp; GetPlayerHealth(playerid, hp);
    SetPlayerHealth(playerid, hp - (severity * 10.0));
}
```

### 2. Bleeding System
```pawn
stock ProcessBleeding(playerid) {
    if (!g_bleeding[playerid]) return;
    new Float:hp; GetPlayerHealth(playerid, hp);
    SetPlayerHealth(playerid, hp - 0.5); // lose 0.5 HP per tick
    if (hp <= 0) {
        SetPlayerDowned(playerid);
    }
}
```

### 3. Downed State
```pawn
stock SetPlayerDowned(playerid) {
    g_downed[playerid] = true;
    // Play injured animation
    ApplyAnimation(playerid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 0);
    // Notify EMS
    NotifyEMS(playerid);
    // Start bleed-out timer
    g_bleedout_timer[playerid] = SetTimerEx("BleedOut", 1000, true, "i", playerid);
}
```

### 4. Revival
```pawn
stock RevivePlayer(playerid, reviverid) {
    if (!g_downed[playerid]) return 0;
    g_downed[playerid] = false;
    KillTimer(g_bleedout_timer[playerid]);
    SetPlayerHealth(playerid, 30.0); // revive with 30 HP
    ClearAnimations(playerid);
    LogMedicalAction(reviverid, "REVIVE", playerid);
    return 1;
}
```

### 5. Medical Items
```pawn
stock UseMedkit(playerid) {
    if (GetPlayerItem(playerid, ITEM_MEDKIT) <= 0) return 0;
    RemovePlayerItem(playerid, ITEM_MEDKIT, 1);
    new Float:hp; GetPlayerHealth(playerid, hp);
    SetPlayerHealth(playerid, hp + 50.0);
    ClearInjuries(playerid);
    return 1;
}
```

## Key Rules
1. **Server-side health** — never trust client HP
2. **Bleeding ticks** — server-side timer
3. **Downed state** — prevent actions while downed
4. **EMS notification** — alert online medics
5. **Log all medical actions** — for evidence

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
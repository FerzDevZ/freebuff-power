---
name: samp-police-system
description: Police and law enforcement system for SA-MP/open.mp — wanted levels, arrest, handcuff, MDT, citations, backup, and patrol. Use when building police features, MDT, or law enforcement systems.
---

# SA-MP/Open.mp Police System (2026)

## When to Activate
- Building wanted level system
- Implementing arrest/handcuff mechanics
- Creating MDT (Mobile Data Terminal)
- Adding citations/tickets
- Designing police patrol/backup

## Core Concepts

### 1. Wanted Level
```pawn
stock SetPlayerWanted(playerid, level, const reason[]) {
    g_wanted_level[playerid] = level;
    SetPlayerWantedLevel(playerid, level);
    LogPoliceAction("WANTED", playerid, level, reason);
    // Notify police
    new msg[128];
    format(msg, sizeof(msg), "[POLICE] %s is now wanted (Level %d): %s", GetPlayerNameEx(playerid), level, reason);
    SendFactionMessage(FACTION_POLICE, msg);
}
```

### 2. Arrest System
```pawn
stock ArrestPlayer(copid, suspectid) {
    if (g_wanted_level[suspectid] == 0) return SendClientMessage(copid, -1, "No warrant.");
    g_arrested[suspectid] = true;
    // Cuff animation
    SetPlayerSpecialAction(suspectid, SPECIAL_ACTION_CUFFED);
    // Transport to station
    SetPlayerPos(suspectid, STATION_X, STATION_Y, STATION_Z);
    // Process
    ProcessArrest(copid, suspectid);
}
```

### 3. MDT (Mobile Data Terminal)
```pawn
// MDT menu: warrants, BOLO, plate lookup, citations
stock ShowMDT(playerid) {
    // TextDraw-based MDT interface
    // Options: Search Player, Search Vehicle, Active Warrants, BOLO List
}
```

### 4. Citations/Tickets
```pawn
stock IssueCitation(copid, playerid, const reason[], amount) {
    g_player_fines[playerid] += amount;
    LogPoliceAction("CITATION", playerid, amount, reason);
    new msg[128];
    format(msg, sizeof(msg), "You received a citation: %s ($%d)", reason, amount);
    SendClientMessage(playerid, -1, msg);
}
```

### 5. Backup System
```pawn
CMD:backup(playerid) {
    if (g_faction[playerid] != FACTION_POLICE) return 0;
    new msg[128];
    format(msg, sizeof(msg), "[10-??.] Officer %s requests backup!", GetPlayerNameEx(playerid));
    SendFactionMessage(FACTION_POLICE, msg);
    // Create backup blip for all cops
    return 1;
}
```

## Key Rules
1. **Server-side wanted** — validate all police actions
2. **Log everything** — every arrest, citation, search
3. **MDT access control** — only police can access
4. **Backup cooldown** — prevent spam
5. **Evidence system** — store proof for trials

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
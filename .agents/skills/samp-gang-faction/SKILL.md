---
name: samp-gang-faction
description: Gang and faction system for SA-MP/open.mp — ranks, invites, territory control, gang wars, and faction management. Use when building gang/faction features, territory systems, or group management.
---

# SA-MP/Open.mp Gang & Faction System (2026)

## When to Activate
- Building gang/faction management
- Implementing territory control
- Adding gang wars/turf battles
- Creating rank hierarchy
- Designing faction chat/radio

## Core Concepts

### 1. Faction Data
```pawn
enum E_FACTION {
    faction_id, faction_name[64], faction_type,
    faction_leader, faction_color,
    faction_bank, faction_territories,
    faction_max_members, faction_member_count
};

enum E_FACTION_MEMBER {
    member_id, member_faction, member_rank,
    member_joined, member_last_active
};
```

### 2. Rank System
```pawn
enum E_FACTION_RANK {
    RANK_RECRUIT = 0,
    RANK_MEMBER = 1,
    RANK_VETERAN = 2,
    RANK_LIEUTENANT = 3,
    RANK_LEADER = 4
};

stock GetRankName(rank) {
    new names[5][32] = {"Recruit", "Member", "Veteran", "Lieutenant", "Leader"};
    return names[rank];
}
```

### 3. Territory System
```pawn
stock CaptureTerritory(playerid, territoryid) {
    new faction = g_faction[playerid];
    if (g_territory[territoryid][terr_owner] == faction) return 0;
    // Check if enough members online
    if (CountFactionMembersOnline(faction) < MIN_CAPTURE_MEMBERS) return 0;
    g_territory[territoryid][terr_owner] = faction;
    g_territory[territoryid][terr_captured] = gettime();
    LogFactionAction(faction, "CAPTURE", territoryid);
    return 1;
}
```

### 4. Gang War
```pawn
stock StartGangWar(attacker, defender, territoryid) {
    g_gangwar[territoryid][gw_attacker] = attacker;
    g_gangwar[territoryid][gw_defender] = defender;
    g_gangwar[territoryid][gw_active] = true;
    g_gangwar[territoryid][gw_start] = gettime();
    // Notify both factions
    SendFactionMessage(attacker, "Gang war started!");
    SendFactionMessage(defender, "Your territory is under attack!");
}
```

### 5. Invite System
```pawn
stock InviteToFaction(inviterid, targetid) {
    if (!IsFactionLeader(inviterid)) return 0;
    if (g_faction_member_count[g_faction[inviterid]] >= MAX_MEMBERS) return 0;
    g_pending_invite[targetid] = g_faction[inviterid];
    SendClientMessage(targetid, -1, "You've been invited to a faction. Use /acceptinvite");
    return 1;
}
```

## Key Rules
1. **Server-side faction data** — never trust client
2. **Rank permissions** — check rank before actions
3. **Territory cooldown** — prevent rapid capture
4. **Log all faction actions** — audit trail
5. **Anti-exploit** — prevent faction hopping

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
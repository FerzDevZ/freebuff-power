---
name: samp-chat-system
description: Chat system architecture for SA-MP/open.mp — IC/OOC messaging, whispers, faction radio channels, proximity chat, chat formatting, and anti-spam. Use when building custom chat, roleplay commands, or communication systems.
---

# SA-MP/Open.mp Chat System (2026)

## When to Activate
- Building custom chat (IC/OOC, whispers, faction)
- Implementing proximity voice/text chat
- Adding chat formatting (colors, prefixes)
- Preventing chat spam/flooding
- Creating radio/walkie-talkie channels

## Core Concepts

### 1. Chat Types
```pawn
enum E_CHAT_TYPE {
    CHAT_IC,        // In-character (roleplay)
    CHAT_OOC,       // Out-of-character
    CHAT_WHISPER,   // Private message
    CHAT_RADIO,     // Faction radio
    CHAT_ADMIN,     // Admin chat
    CHAT_ME,        // /me action
    CHAT_DO         // /do action
};
```

### 2. Proximity Chat (IC)
```pawn
stock SendProximityMessage(playerid, Float:range, color, const msg[]) {
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    foreach (new i : Player) {
        if (!IsPlayerConnected(i)) continue;
        new Float:ix, Float:iy, Float:iz;
        GetPlayerPos(i, ix, iy, iz);
        if (GetDistanceBetweenPoints(px, py, pz, ix, iy, iz) <= range) {
            SendClientMessage(i, color, msg);
        }
    }
}
```

### 3. OOC Chat
```pawn
CMD:ooc(playerid, params[]) {
    if (isnull(params)) return SendClientMessage(playerid, -1, "Usage: /ooc [message]");
    new msg[256];
    format(msg, sizeof(msg), "(( %s: %s ))", GetPlayerNameEx(playerid), params);
    SendProximityMessage(playerid, 20.0, 0xC2A2DAFF, msg);
    return 1;
}
```

### 4. Whisper System
```pawn
CMD:whisper(playerid, params[]) {
    new targetid, msg[128];
    if (sscanf(params, "us[128]", targetid, msg)) return SendClientMessage(playerid, -1, "Usage: /w [player] [msg]");
    if (!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "Player not connected.");
    new str[256];
    format(str, sizeof(str), "[Whisper] %s: %s", GetPlayerNameEx(playerid), msg);
    SendClientMessage(targetid, 0xFFFF00FF, str);
    format(str, sizeof(str), "[Whisper to %s] %s", GetPlayerNameEx(targetid), msg);
    SendClientMessage(playerid, 0xFFFF00FF, str);
    return 1;
}
```

### 5. Faction Radio
```pawn
CMD:r(playerid, params[]) {
    if (g_faction[playerid] == FACTION_NONE) return SendClientMessage(playerid, -1, "Not in a faction.");
    if (isnull(params)) return SendClientMessage(playerid, -1, "Usage: /r [message]");
    new msg[256];
    format(msg, sizeof(msg), "[Radio] %s: %s", GetPlayerNameEx(playerid), params);
    foreach (new i : Player) {
        if (g_faction[i] == g_faction[playerid]) SendClientMessage(i, 0x33CCFFFF, msg);
    }
    return 1;
}
```

### 6. Anti-Spam
```pawn
stock bool:CheckChatSpam(playerid) {
    new now = GetTickCount();
    if (now - g_last_chat[playerid] < CHAT_COOLDOWN_MS) {
        SendClientMessage(playerid, -1, "Please wait before chatting again.");
        return false;
    }
    g_last_chat[playerid] = now;
    return true;
}
```

## Key Rules
1. **IC vs OOC separation** — never mix roleplay and meta in same message
2. **Proximity for IC** — IC messages only heard within range
3. **Color coding** — different colors for different chat types
4. **Anti-spam** — cooldown on all chat commands
5. **Log all chat** — for moderation and evidence

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
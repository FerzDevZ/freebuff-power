---
name: samp-discord-connector
description: Bi-directional Discord Bot & Webhook Integration for SA-MP & open.mp via pawn-discord-connector — live in-game to Discord chat synchronization, staff audit logs, player verification, and server status embeds.
---

# SA-MP / open.mp Discord Connector Skill

## Overview
Modern SA-MP and open.mp gaming communities rely heavily on tight Discord integration: syncing in-game public chat with Discord channels, streaming admin action logs, handling roleplay whitelisting, and displaying live server player counts.

---

## 1. Setup & Inclusion
- Plugin: `discord-connector.so` / `discord-connector.dll`
- Pawn Include: `#include <discord-connector>`
- Bot Token Configuration (`config.json` or `discord.ini`):
  ```ini
  [discord]
  token = YOUR_DISCORD_BOT_SECRET_TOKEN_HERE
  ```

---

## 2. Channel Identification
Define channel IDs centrally:
```pawn
// constants/discord.inc
#define DCC_CHANNEL_CHAT        "102938475610293847" // #ingame-chat
#define DCC_CHANNEL_ADMIN_LOGS  "102938475610293848" // #admin-logs
#define DCC_CHANNEL_SERVER_LOGS "102938475610293849" // #server-status
```

---

## 3. In-Game Chat to Discord Bridge
Relay player messages to Discord:

```pawn
public OnPlayerText(playerid, text[]) {
    // 1. Sanitize text for Discord Markdown exploits (e.g. @everyone / @here)
    new sanitized[144];
    format(sanitized, sizeof(sanitized), "%s", text);
    strreplace(sanitized, "@everyone", "[at]everyone");
    strreplace(sanitized, "@here", "[at]here");

    // 2. Dispatch to Discord channel
    new discordMsg[200], playerName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, playerName, sizeof(playerName));

    format(discordMsg, sizeof(discordMsg), "**[ID: %d] %s**: %s", playerid, playerName, sanitized);
    
    new DCC_Channel:channel = DCC_FindChannelById(DCC_CHANNEL_CHAT);
    if (channel != DCC_INVALID_CHANNEL) {
        DCC_SendChannelMessage(channel, discordMsg);
    }
    return 1;
}
```

---

## 4. Discord to In-Game Chat Bridge
Relay Discord messages back into the SA-MP chat:

```pawn
public DCC_OnChannelMessage(DCC_Channel:channel, DCC_User:author, const message[]) {
    // Ignore messages from the bot itself
    new bool:isBot;
    DCC_IsUserBot(author, isBot);
    if (isBot) return 1;

    // Check if message came from #ingame-chat
    new channelId[32];
    DCC_GetChannelId(channel, channelId, sizeof(channelId));

    if (strcmp(channelId, DCC_CHANNEL_CHAT, true) == 0) {
        new authorName[32];
        DCC_GetUserName(author, authorName, sizeof(authorName));

        new broadcastMsg[144];
        format(broadcastMsg, sizeof(broadcastMsg), "{7289DA}[Discord] %s: {FFFFFF}%s", authorName, message);
        SendClientMessageToAll(0xFFFFFFFF, broadcastMsg);
    }
    return 1;
}
```

---

## 5. Rich Embed Admin Audit Logs
Send formatted rich embeds when admins execute kicks, bans, or mutes:

```pawn
stock Discord_LogAdminAction(const adminName[], const targetName[], const action[], const reason[]) {
    new DCC_Embed:embed = DCC_CreateEmbed();
    DCC_SetEmbedTitle(embed, "Admin Punishment Log");
    DCC_SetEmbedColor(embed, 0xFF0000); // Red color

    DCC_AddEmbedField(embed, "Administrator", adminName, true);
    DCC_AddEmbedField(embed, "Target Player", targetName, true);
    DCC_AddEmbedField(embed, "Penalty", action, false);
    DCC_AddEmbedField(embed, "Reason", reason, false);

    new DCC_Channel:logChannel = DCC_FindChannelById(DCC_CHANNEL_ADMIN_LOGS);
    if (logChannel != DCC_INVALID_CHANNEL) {
        DCC_SendChannelEmbedMessage(logChannel, embed);
    }
}
```

## Production Security Rules
- **Never Hardcode Bot Token in Git:** Read token from external `.ini` or environment variable.
- **Escape Mention Exploits:** Always sanitize `@everyone` and `@here` before relaying in-game chat to Discord.
- **Rate Limiting:** Throttle Discord outgoing webhooks (max 5 messages/sec) to avoid hitting Discord API 429 rate limits.

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


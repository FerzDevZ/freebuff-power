---
name: samp-phone-system
description: Smartphone system for SA-MP/open.mp — calls, SMS, contacts, apps (banking, marketplace, GPS), and phone UI. Use when building phone features, smartphone apps, or communication systems.
---

# SA-MP/Open.mp Phone System (2026)

## When to Activate
- Building smartphone/cell phone system
- Implementing calls and SMS
- Creating phone apps (banking, marketplace)
- Adding contacts/phonebook
- Designing phone UI (TextDraw or CEF)

## Core Concepts

### 1. Phone State
```pawn
enum E_PHONE {
    phone_number, phone_owner, phone_on,
    phone_calling, phone_caller,
    phone_battery, phone_credit
};
```

### 2. Call System
```pawn
stock StartCall(callerid, targetid) {
    if (g_phone_calling[callerid]) return SendClientMessage(callerid, -1, "Already in call.");
    if (g_phone_calling[targetid]) return SendClientMessage(callerid, -1, "Line busy.");
    g_phone_calling[callerid] = true;
    g_phone_caller[callerid] = targetid;
    g_phone_calling[targetid] = true;
    g_phone_caller[targetid] = callerid;
    // Ring target
    SendClientMessage(targetid, -1, "Your phone is ringing. Use /answer");
    // Play ring sound
    PlayerPlaySound(targetid, 3600, 0, 0, 0);
    return 1;
}
```

### 3. SMS System
```pawn
stock SendSMS(senderid, targetid, const msg[]) {
    new str[256];
    format(str, sizeof(str), "[SMS from %s] %s", GetPlayerNameEx(senderid), msg);
    SendClientMessage(targetid, 0x00FF00FF, str);
    // Save to DB
    SaveSMS(GetPlayerSQLId(senderid), GetPlayerSQLId(targetid), msg);
    return 1;
}
```

### 4. Phone Apps
```pawn
// App: Banking
stock OpenBankingApp(playerid) { ShowBankingUI(playerid); }
// App: Marketplace
stock OpenMarketplaceApp(playerid) { ShowMarketplaceUI(playerid); }
// App: GPS
stock OpenGPSApp(playerid) { ShowGPSUI(playerid); }
// App: Contacts
stock OpenContactsApp(playerid) { ShowContactsUI(playerid); }
```

### 5. Phone UI (TextDraw)
```pawn
stock ShowPhoneUI(playerid) {
    // Show phone frame, screen, app icons
    // Handle app selection via clicks
}
```

## Key Rules
1. **Server-side calls** — validate all phone actions
2. **Call state tracking** — prevent duplicate calls
3. **SMS logging** — save all messages
4. **Battery system** — optional phone battery
5. **Credit system** — optional pay-per-use

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
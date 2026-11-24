---
name: samp-logging-audit
description: Logging and audit system for SA-MP/open.mp — server logs, player action logs, admin audit trail, and error tracking. Use when building logging systems, audit trails, or debugging infrastructure.
---

# SA-MP/Open.mp Logging & Audit System (2026)

## When to Activate
- Building server logging infrastructure
- Implementing admin audit trails
- Adding player action tracking
- Creating error/crash logging
- Designing log rotation/archival

## Core Concepts

### 1. Log Types
```pawn
enum E_LOG_TYPE {
    LOG_ADMIN,      // Admin actions
    LOG_PLAYER,     // Player actions (login, logout, death)
    LOG_ECONOMY,    // Money transactions
    LOG_COMBAT,     // Kills, damage
    LOG_CHAT,       // Chat messages
    LOG_SYSTEM,     // Server events (startup, shutdown)
    LOG_ERROR       // Errors and warnings
};
```

### 2. Structured Logging
```pawn
stock LogAction(E_LOG_TYPE type, const action[], const player[], const details[]) {
    new timestamp[32];
    format(timestamp, sizeof(timestamp), "%s", GetTimestamp());
    new logline[512];
    format(logline, sizeof(logline), "[%s] [%s] %s | %s | %s", timestamp, GetLogTypeName(type), action, player, details);
    // Write to file
    new File:log = fopen(GetLogPath(type), io_append);
    if (log) { fwrite(log, logline); fwrite(log, "\n"); fclose(log); }
    // Also save to DB for admin panel
    SaveLogToDB(type, action, player, details);
}
```

### 3. Admin Audit Trail
```pawn
stock AuditAdmin(adminid, const action[], const target[], const reason[]) {
    LogAction(LOG_ADMIN, action, GetPlayerNameEx(adminid), reason);
    new query[512];
    mysql_format(g_db, query, sizeof(query),
        "INSERT INTO admin_audit (admin_id, admin_name, action, target, reason, ip, timestamp) VALUES (%d, '%e', '%e', '%e', '%e', '%e', NOW())",
        GetPlayerSQLId(adminid), GetPlayerNameEx(adminid), action, target, reason, GetPlayerIPEx(adminid));
    mysql_tquery(g_db, query);
}
```

### 4. Player Action Tracking
```pawn
stock LogPlayerAction(playerid, const action[], const details[]) {
    LogAction(LOG_PLAYER, action, GetPlayerNameEx(playerid), details);
}
// Usage: LogPlayerAction(playerid, "LOGIN", "IP: 192.168.1.1");
// Usage: LogPlayerAction(playerid, "DEATH", "Killed by: Player2, Weapon: AK47");
```

### 5. Log Rotation
```pawn
stock RotateLogs() {
    // Move current log to archive with date suffix
    // Create new empty log file
    // Delete logs older than 30 days
}
```

## Key Rules
1. **Log everything important** — admin actions, money, deaths, logins
2. **Structured format** — timestamp, type, action, player, details
3. **Database + file** — dual storage for redundancy
4. **Log rotation** — prevent disk full
5. **Privacy** — don't log passwords or sensitive data

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
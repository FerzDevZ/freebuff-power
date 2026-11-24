---
name: samp-admin-moderation
description: Admin and moderation system for SA-MP/open.mp servers — role hierarchy, ban/kick/mute, admin commands, audit logging, report system, and anti-abuse protection. Use when building admin panels, moderation tools, or staff management.
---

# SA-MP/Open.mp Admin & Moderation (2026)

## When to Activate
- Building admin command system
- Implementing ban/kick/mute/warn
- Creating staff hierarchy (helper, mod, admin, owner)
- Adding report/ticket system
- Designing admin audit logs

## Core Concepts

### 1. Role Hierarchy
```pawn
enum E_ADMIN_LEVEL {
    ADMIN_NONE = 0,
    ADMIN_HELPER = 1,
    ADMIN_MOD = 2,
    ADMIN_ADMIN = 3,
    ADMIN_SENIOR = 4,
    ADMIN_OWNER = 5
};
```

### 2. Permission Check Pattern
```pawn
stock bool:IsAdmin(playerid, E_ADMIN_LEVEL min_level) {
    return g_admin_level[playerid] >= min_level;
}

// Usage in commands
CMD:kick(playerid, params[]) {
    if (!IsAdmin(playerid, ADMIN_MOD)) return SendClientMessage(playerid, -1, "No permission.");
    // ... kick logic
    return 1;
}
```

### 3. Ban System (Database-Backed)
```pawn
stock BanPlayer(targetid, adminid, const reason[], duration_days) {
    new query[256];
    mysql_format(g_db, query, sizeof(query),
        "INSERT INTO bans (player_name, ip, admin_name, reason, ban_date, unban_date, active) VALUES ('%e', '%e', '%e', '%e', NOW(), DATE_ADD(NOW(), INTERVAL %d DAY), 1)",
        GetPlayerNameEx(targetid), GetPlayerIPEx(targetid), GetPlayerNameEx(adminid), reason, duration_days);
    mysql_tquery(g_db, query);
    Kick(targetid);
}
```

### 4. Audit Logging
```pawn
stock LogAdminAction(adminid, const action[], const target[], const reason[]) {
    new query[512];
    mysql_format(g_db, query, sizeof(query),
        "INSERT INTO admin_logs (admin_id, admin_name, action, target, reason, timestamp) VALUES (%d, '%e', '%e', '%e', '%e', NOW())",
        GetPlayerSQLId(adminid), GetPlayerNameEx(adminid), action, target, reason);
    mysql_tquery(g_db, query);
}
```

### 5. Report System
```pawn
enum E_REPORT {
    report_id, report_reporter, report_target,
    report_reason[128], report_status, report_timestamp
};

stock CreateReport(reporterid, targetid, const reason[]) {
    // Save to DB, notify online admins
    new msg[256];
    format(msg, sizeof(msg), "[REPORT] %s reported %s: %s", GetPlayerNameEx(reporterid), GetPlayerNameEx(targetid), reason);
    SendAdminMessage(ADMIN_HELPER, msg);
}
```

### 6. Anti-Abuse Protection
- **Rate limit admin commands**: max 10/min per admin
- **Log all admin actions**: who, what, when, target
- **Require reason for bans/kicks**: minimum 10 chars
- **IP ban sync**: ban by IP + name + serial
- **Admin login tracking**: log IP changes for admin accounts

## Key Rules
1. **Never trust admin client** — all admin actions server-side
2. **Log everything** — every admin action to database
3. **Role-based access** — check level before every command
4. **Cooldown on destructive actions** — prevent spam bans
5. **Separate admin chat** — `/a` command for staff only

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
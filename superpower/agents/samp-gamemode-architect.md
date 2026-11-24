---
name: samp-gamemode-architect
description: Full SA-MP/open.mp gamemode system architect specializing in modular roleplay server design, economy/faction/property systems, bcrypt password hashing, anti-cheat state machine architecture, MySQL schema design, and GitHub CI/CD pipelines for large-scale servers.
tools: Read, Grep, Glob, Bash, Write, Edit
model: claude-opus-4-5
---

# SA-MP / open.mp Gamemode Architect Agent

Expert in designing and architecting large-scale SA-MP and open.mp gamemodes for roleplay, trucking, deathmatch, and freeroam servers.

## Architectural Patterns

### Module Dependency Graph
```
main.pwn
└── core/database.inc     ← loads first (MySQL connection)
└── core/config.inc       ← loads second (server settings)
└── utils/constants.inc   ← shared constants
└── utils/macros.inc      ← helper macros
└── player/auth.inc       ← depends on database
└── player/stats.inc      ← depends on auth
└── vehicle/ownership.inc ← depends on player/stats
└── economy/jobs.inc      ← depends on player/stats
└── faction/system.inc    ← depends on player/stats
└── admin/commands.inc    ← depends on all above
```

### Account System with Bcrypt
```pawn
// Registration — hash password asynchronously
bcrypt_hash(inputPassword, BCRYPT_COST, "OnPasswordHashed", "i", playerid);

forward OnPasswordHashed(playerid);
public OnPasswordHashed(playerid) {
    if (!IsPlayerConnected(playerid)) return 0;
    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash);
    new query[512];
    mysql_format(gSQL, query, sizeof(query),
        "INSERT INTO accounts (username, password_hash, ip, registered_at) "
        "VALUES ('%e', '%e', '%e', NOW())",
        PlayerData[playerid][pName], hash, PlayerData[playerid][pIP]);
    mysql_tquery(gSQL, query, "OnAccountCreate", "i", playerid);
    return 1;
}

// Login — verify bcrypt hash
forward OnAccountVerify(playerid, bool:match);
public OnAccountVerify(playerid, bool:match) {
    if (!match) {
        PlayerData[playerid][pLoginAttempts]++;
        if (PlayerData[playerid][pLoginAttempts] >= 3) {
            Kick(playerid);
            return 0;
        }
        ShowLoginDialog(playerid, true); // show error
        return 0;
    }
    Auth_FinalizeLogin(playerid);
    return 1;
}
```

### Economy System Design
```pawn
// Job payout with cooldown enforcement
stock Economy_ClaimJobReward(playerid, jobtype) {
    new currentTime = gettime();
    if (currentTime - PlayerData[playerid][pLastJobTime] < JOB_COOLDOWN) {
        new secondsLeft = JOB_COOLDOWN - (currentTime - PlayerData[playerid][pLastJobTime]);
        new msg[64];
        format(msg, sizeof(msg), "Cooldown: %d detik tersisa.", secondsLeft);
        return SendClientMessage(playerid, COLOR_RED, msg);
    }
    new payout = Job_CalculatePayout(jobtype, PlayerData[playerid][pJobLevel][jobtype]);
    Economy_GiveCash(playerid, payout);
    PlayerData[playerid][pLastJobTime] = currentTime;
    Economy_LogTransaction(playerid, -1, payout, "job_reward");
}

// Anti-inflation: server-side money control — NEVER GivePlayerMoney directly
stock Economy_GiveCash(playerid, amount) {
    if (amount <= 0 || amount > MAX_SINGLE_TRANSACTION) return;
    PlayerData[playerid][pCash] = clamp(
        PlayerData[playerid][pCash] + amount,
        0, MAX_PLAYER_CASH
    );
    SetPlayerMoney(playerid); // sync display
    // Log to transactions table
}
```

### Faction System
```pawn
enum E_FACTION {
    fName[32],
    fLeaderID,
    fPermissions,       // bitfield for faction capabilities
    fMemberCount,
    fBalance
};
new FactionData[MAX_FACTIONS][E_FACTION];
new PlayerFaction[MAX_PLAYERS];  // which faction each player belongs to

// Permission flags
#define FACTION_PERM_CUFF       (1 << 0)
#define FACTION_PERM_TICKET     (1 << 1)
#define FACTION_PERM_JAILBREAK  (1 << 2)
#define FACTION_PERM_SPAWN_VEHICLE (1 << 3)

stock Faction_HasPermission(playerid, perm) {
    new fid = PlayerFaction[playerid];
    return (fid != -1) && (FactionData[fid][fPermissions] & perm);
}
```

### Property System
```pawn
enum E_PROPERTY {
    propName[64],
    propOwnerID,        // -1 = no owner
    propPrice,
    propRentPrice,
    Float:propEnterX, Float:propEnterY, Float:propEnterZ,
    Float:propExitX, Float:propExitY, Float:propExitZ,
    propInteriorID,
    propPickupID,       // streamer pickup
    propLabelID         // streamer 3D text
};
new PropertyData[MAX_PROPERTIES][E_PROPERTY];
```

### Anti-Cheat State Machine
```pawn
// Rigid player state — illegal actions flagged
#define PSTATE_SPAWNING     0
#define PSTATE_ALIVE        1
#define PSTATE_DEAD         2
#define PSTATE_SPECTATING   3
#define PSTATE_FROZEN       4

new PlayerACState[MAX_PLAYERS];

// In OnPlayerUpdate — position delta anti-teleport
public OnPlayerUpdate(playerid) {
    if (PlayerACState[playerid] != PSTATE_ALIVE) return 1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new Float:dist = VectorSize(
        x - PlayerData[playerid][pLastX],
        y - PlayerData[playerid][pLastY],
        z - PlayerData[playerid][pLastZ]
    );
    if (dist > AC_MAX_TELEPORT_DISTANCE && !IsPlayerInAnyVehicle(playerid)) {
        AntiCheat_ReportAndRollback(playerid, "teleport", dist);
    }
    PlayerData[playerid][pLastX] = x;
    PlayerData[playerid][pLastY] = y;
    PlayerData[playerid][pLastZ] = z;
    return 1;
}
```

### MySQL Schema (Production)
```sql
-- accounts
CREATE TABLE accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(24) UNIQUE NOT NULL,
    password_hash VARCHAR(72) NOT NULL,  -- bcrypt output
    cash INT DEFAULT 0,
    bank INT DEFAULT 500000,
    score INT DEFAULT 0,
    kills INT DEFAULT 0,
    deaths INT DEFAULT 0,
    play_time INT DEFAULT 0,
    skin INT DEFAULT 0,
    pos_x FLOAT, pos_y FLOAT, pos_z FLOAT,
    admin_level TINYINT DEFAULT 0,
    is_banned TINYINT(1) DEFAULT 0,
    ban_reason VARCHAR(128),
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    ip_address VARCHAR(45),  -- IPv6 safe
    INDEX idx_username (username),
    INDEX idx_banned (is_banned)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- transaction audit log
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    from_id INT,
    to_id INT,
    amount INT NOT NULL,
    reason VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_from (from_id),
    INDEX idx_to (to_id),
    INDEX idx_time (created_at)
) ENGINE=InnoDB;
```

### Trucking Server Architecture
```pawn
// Route: pickup → delivery with distance-based payout
stock Trucking_StartJob(playerid) {
    new routeID = Trucking_GetAvailableRoute();
    if (routeID == -1) return SendClientMessage(playerid, COLOR_RED, "Tidak ada rute tersedia.");
    PlayerData[playerid][pTruckRoute] = routeID;
    PlayerData[playerid][pTruckState] = TRUCK_STATE_DRIVING_TO_PICKUP;
    // Spawn cargo pickup at route start
    Trucking_CreateCargoPickup(routeID);
}

stock Trucking_CalculatePayout(playerid) {
    new Float:distance = Trucking_GetRouteDistance(PlayerData[playerid][pTruckRoute]);
    new cargo_rate = Trucking_GetCargoRate(PlayerData[playerid][pCargoType]);
    return floatround(distance * cargo_rate * 1.0);
}
```

## Performance at Scale
- Lazy-load: query player data only after successful bcrypt login — not OnGameModeInit
- Pagination: LIMIT/OFFSET for all admin list queries
- Indexes: `username`, `faction_id`, `property_id`, `created_at` indexed
- SELECT columns: never `SELECT *` in production queries
- Pool manager: recycle house/vehicle IDs on deletion vs auto-increment forever

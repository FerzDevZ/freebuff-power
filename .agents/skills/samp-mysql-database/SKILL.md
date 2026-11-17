---
name: samp-mysql-database
description: BlueG MySQL Plugin R41-4 integration with PAWN for SA-MP and open.mp — threaded vs non-blocking queries, parameter binding (%e), ORM/cache mapping, Bcrypt authentication, connection pooling, and schema design for production roleplay servers.
---

# SA-MP / open.mp MySQL Database Skill

## Plugin Overview & Setup
BlueG's MySQL plugin (R41-4+) is the gold standard for high-performance database connectivity in SA-MP and open.mp.

### Configuration (`mysql.ini`)
Store credentials outside code:
```ini
[mysql]
host = 127.0.0.1
user = samp_srv
password = SecretProductionPassword_2026!
database = samproleplay
port = 3306
pool_size = 4
auto_reconnect = true
```

### Initializing Connection
```pawn
#include <a_samp>
#include <a_mysql>

new MySQL:gSQL;

public OnGameModeInit() {
    new MySQLOpt:options = mysql_init_options();
    mysql_set_option(options, AUTO_RECONNECT, true);
    mysql_set_option(options, POOL_SIZE, 4);

    gSQL = mysql_connect_file("mysql.ini", options);
    mysql_unref_options(options);

    if (gSQL == MYSQL_INVALID_HANDLE || mysql_errno(gSQL) != 0) {
        printf("[FATAL] MySQL Connection failed with code %d. Shutting down...", mysql_errno(gSQL));
        SendRconCommand("exit");
        return 0;
    }
    printf("[MySQL] Connected successfully to database with pool size 4.");
    return 1;
}

public OnGameModeExit() {
    if (gSQL != MYSQL_INVALID_HANDLE) {
        mysql_close(gSQL);
    }
    return 1;
}
```

## Threaded Queries (Non-Blocking)
Never run synchronous `mysql_query` on the main server thread as it freezes the game tick. Always use `mysql_tquery` or `mysql_pquery`.

### Asynchronous Data Loading Pattern
```pawn
stock LoadPlayerData(playerid) {
    new query[128], playerName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    
    // Always use %e for escaping player input / names
    mysql_format(gSQL, query, sizeof(query),
        "SELECT id, password_hash, cash, bank, admin_level, skin, pos_x, pos_y, pos_z, angle FROM accounts WHERE username = '%e' LIMIT 1",
        playerName);
    
    mysql_tquery(gSQL, query, "OnAccountLoaded", "i", playerid);
}

forward OnAccountLoaded(playerid);
public OnAccountLoaded(playerid) {
    if (!IsPlayerConnected(playerid)) return 0;

    new rows = cache_num_rows();
    if (rows == 0) {
        // Unregistered user -> Trigger registration dialog
        ShowRegisterDialog(playerid);
        return 1;
    }

    cache_get_value_name_int(0, "id", PlayerData[playerid][pDBID]);
    cache_get_value_name(0, "password_hash", PlayerData[playerid][pPasswordHash], 73);
    cache_get_value_name_int(0, "cash", PlayerData[playerid][pCash]);
    cache_get_value_name_int(0, "bank", PlayerData[playerid][pBank]);
    cache_get_value_name_int(0, "admin_level", PlayerData[playerid][pAdminLevel]);
    cache_get_value_name_int(0, "skin", PlayerData[playerid][pSkin]);
    cache_get_value_name_float(0, "pos_x", PlayerData[playerid][pPosX]);
    cache_get_value_name_float(0, "pos_y", PlayerData[playerid][pPosY]);
    cache_get_value_name_float(0, "pos_z", PlayerData[playerid][pPosZ]);
    cache_get_value_name_float(0, "angle", PlayerData[playerid][pAngle]);

    ShowLoginDialog(playerid);
    return 1;
}
```

### Safe Insert & Retrieving Last Insert ID
```pawn
stock CreatePlayerAccount(playerid, const hashedPassword[]) {
    new query[512], playerName[MAX_PLAYER_NAME + 1], playerIP[16];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    GetPlayerIp(playerid, playerIP, sizeof(playerIP));

    mysql_format(gSQL, query, sizeof(query),
        "INSERT INTO accounts (username, password_hash, ip_address, registered_at) VALUES ('%e', '%e', '%e', NOW())",
        playerName, hashedPassword, playerIP);

    mysql_tquery(gSQL, query, "OnAccountRegistered", "i", playerid);
}

forward OnAccountRegistered(playerid);
public OnAccountRegistered(playerid) {
    if (!IsPlayerConnected(playerid)) return 0;
    
    PlayerData[playerid][pDBID] = cache_insert_id();
    PlayerData[playerid][pLoggedIn] = true;
    SendClientMessage(playerid, 0x00FF00FF, "Registrasi berhasil! Selamat datang di server.");
    SpawnPlayer(playerid);
    return 1;
}
```

## SQL Injection Prevention Rules
1. **Always Use `mysql_format()` with `%e`:**
   ```pawn
   // VULNERABLE:
   format(query, sizeof(query), "SELECT * FROM accounts WHERE username = '%s'", input);
   // SECURE:
   mysql_format(gSQL, query, sizeof(query), "SELECT * FROM accounts WHERE username = '%e'", input);
   ```
2. **Numeric Validation:** For integers, `%d` or `%i` formats do not require quotes and prevent string concatenation injection.
3. **Prepared Statements (`mysql_pquery`):** Use for repetitive bulk queries.

## Production Schema Patterns

### Accounts Table
```sql
CREATE TABLE accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(24) UNIQUE NOT NULL,
    password_hash VARCHAR(72) NOT NULL,
    cash INT DEFAULT 5000,
    bank INT DEFAULT 20000,
    score INT DEFAULT 0,
    kills INT DEFAULT 0,
    deaths INT DEFAULT 0,
    play_time INT DEFAULT 0,
    skin INT DEFAULT 299,
    admin_level TINYINT UNSIGNED DEFAULT 0,
    is_banned TINYINT(1) DEFAULT 0,
    ban_reason VARCHAR(128) DEFAULT NULL,
    pos_x FLOAT DEFAULT 1742.84,
    pos_y FLOAT DEFAULT -1860.52,
    pos_z FLOAT DEFAULT 13.57,
    angle FLOAT DEFAULT 0.0,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ip_address VARCHAR(45) NOT NULL,
    INDEX idx_user (username),
    INDEX idx_banned (is_banned)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Vehicles Table
```sql
CREATE TABLE player_vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    model_id INT NOT NULL,
    color1 INT DEFAULT 1,
    color2 INT DEFAULT 1,
    pos_x FLOAT NOT NULL,
    pos_y FLOAT NOT NULL,
    pos_z FLOAT NOT NULL,
    angle FLOAT NOT NULL,
    fuel FLOAT DEFAULT 100.0,
    mileage INT DEFAULT 0,
    plate VARCHAR(12) DEFAULT 'SA-MP',
    FOREIGN KEY (owner_id) REFERENCES accounts(id) ON DELETE CASCADE,
    INDEX idx_owner (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---
name: samp-server-configuration
description: Complete SA-MP 0.3.7 and open.mp server configuration — server.cfg vs config.json, Linux systemd deployment, plugin loading order, auto-restart, performance tuning, firewall setup, and log monitoring for production servers.
---

# SA-MP / open.mp Server Configuration Skill

## SA-MP 0.3.7 — server.cfg
```ini
echo Executing Server Config...
lanmode 0
rcon_password CHANGE_THIS_TO_STRONG_PASSWORD
maxplayers 100
port 7777
hostname "My SA-MP Server | play.example.com"
announce 1
query 1
weburl play.example.com
language Indonesian

gamemode0 mygamemode 1
filterscripts anticheat logger chat
plugins crashdetect sscanf mysql streamer

mapname San Andreas
weather 10
worldtime 12
gravity 0.008

stream_distance 300.0
stream_rate 1000
maxnpc 0

logtimeformat [%H:%M:%S]
```

## open.mp — config.json (Recommended)
```json
{
  "name": "My Server | play.example.com",
  "password": "",
  "max_players": 100,
  "port": 7777,
  "rcon": {
    "password": "CHANGE_THIS_STRONG_RCON_PASSWORD",
    "allow_teleport": false
  },
  "game": {
    "weather": 10,
    "time": 12,
    "gravity": "0.008",
    "map_name": "San Andreas"
  },
  "pawn": {
    "main_scripts": ["mygamemode"],
    "side_scripts": ["filterscripts/anticheat", "filterscripts/logger"],
    "legacy_plugins": ["crashdetect", "sscanf", "mysql", "streamer"]
  },
  "network": {
    "bind": "",
    "public_ip": "YOUR_SERVER_IP"
  },
  "logging": {
    "log_chat": true,
    "log_queries": false,
    "log_deaths": true,
    "timestamp_format": "[%H:%M:%S]"
  },
  "sleep": 5,
  "stream": {
    "distance": 300.0,
    "rate": 1000
  }
}
```

## Plugin Loading Order (Critical)
```
# Load order MUST be:
1. crashdetect   — crash reporter FIRST
2. sscanf        — string parser (dependency)
3. mysql         — database connector
4. streamer      — dynamic entity manager
5. your plugins  — custom last
```

## Directory Structure
```
/home/samp/server/
├── omp-server (or samp03svr)
├── config.json (or server.cfg)
├── gamemodes/
│   └── mygamemode.amx
├── filterscripts/
│   ├── anticheat.amx
│   └── logger.amx
├── plugins/
│   ├── crashdetect.so
│   ├── sscanf.so
│   ├── mysql.so
│   └── streamer.so
├── scriptfiles/        # runtime data/logs
├── mysql.ini           # DB credentials (NOT in git)
└── server_log.txt
```

## MySQL Credentials File (External — NOT in source control)
```ini
# mysql.ini — add to .gitignore
[mysql]
host = 127.0.0.1
user = sampuser
password = strongpasswordhere
db = sampserver
port = 3306
pool_size = 4
auto_reconnect = true
```

## Linux Systemd Service (Production)
```ini
# /etc/systemd/system/samp.service
[Unit]
Description=SA-MP / open.mp Game Server
After=network.target mysql.service

[Service]
Type=simple
User=samp
WorkingDirectory=/home/samp/server
ExecStart=/home/samp/server/omp-server
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
StandardOutput=append:/home/samp/server/server_log.txt
StandardError=append:/home/samp/server/error_log.txt

[Install]
WantedBy=multi-user.target
```
```bash
systemctl daemon-reload
systemctl enable samp
systemctl start samp
systemctl status samp
```

## Screen/tmux Fallback
```bash
# Start in detached screen
screen -dmS samp bash -c 'cd /home/samp/server && ./omp-server'

# Attach
screen -r samp

# Auto-restart loop (alternative to systemd)
#!/bin/bash
while true; do
    ./omp-server
    echo "[$(date)] Server exited. Restarting in 5 seconds..."
    sleep 5
done
```

## Firewall Setup
```bash
# UFW
ufw allow 7777/udp comment "SA-MP Game"
ufw allow 7777/tcp comment "SA-MP RCON"
ufw deny from any to any port 3306  # Block MySQL external access

# iptables
iptables -A INPUT -p udp --dport 7777 -j ACCEPT
iptables -A INPUT -p tcp --dport 7777 -j ACCEPT
```

## Performance Tuning
| Player Count | stream_distance | stream_rate | RAM | sleep |
|---|---|---|---|---|
| < 50 | 300.0 | 1000ms | 512 MB | 5 |
| 50–150 | 250.0 | 1500ms | 1 GB | 5 |
| 150–300 | 200.0 | 2000ms | 2 GB | 5 |
| 300+ | 150.0 | 3000ms | 4 GB | 5 |

## Log Monitoring Commands
```bash
# Real-time errors
tail -f server_log.txt | grep -E "Warning|Error|crash|Exception"

# Player connection rate per hour
grep "OnPlayerConnect\|connected" server_log.txt | cut -d'[' -f2 | cut -d']' -f1 | sort | uniq -c

# Ban/kick events
grep -E "Kicked|Banned|BAN" server_log.txt | tail -100

# Server restarts
grep "OnGameModeInit" server_log.txt | head -20
```

## Automated Backup
```bash
# /etc/cron.d/samp-backup
# Daily MySQL dump at 3AM
0 3 * * * samp mysqldump -u sampuser -p"$(cat /home/samp/.dbpass)" sampserver | gzip > /backups/samp_$(date +\%F).sql.gz

# Keep 14 days of backups
0 4 * * * find /backups -name "samp_*.sql.gz" -mtime +14 -delete
```

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


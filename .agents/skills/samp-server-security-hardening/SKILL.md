---
name: samp-server-security-hardening
description: Server-side security audit for SA-MP and open.mp gamemodes — hostile-client threat model, dialog and command RPC spoofing, parameter injection, weapon/health/position authority checks, expensive-native DoS, RCON and config exposure, SQL injection in Pawn queries, and the audit commands that find these patterns in a real codebase.
---

# Server Security Hardening (SA-MP / open.mp)

The client is hostile. Anything it sends can be replayed, modified, or sent
without the UI that was supposed to gate it. A gamemode is a network service
written in a language with fixed buffers, so both exploit classes apply at once.

This skill is the audit layer; `samp-anticheat-system` covers gameplay cheat
detection, `samp-dialog-system` covers dialog state, and
`samp-persistence-schema` covers query safety at the data layer.

---

## 1. Threat model in one table

| Attack | Entry point | Server-side control |
|---|---|---|
| fake dialog response | `OnDialogResponse` RPC | track the dialog the server actually showed; reject mismatches |
| command flood | `OnPlayerCommandText` | per-player cooldown + global block flag (`samp_cmd.inc`) |
| huge/odd `inputtext` | dialogs, `/pm`, `/me` | length caps before formatting or storing |
| format-string injection | `format(buf, size, userText)` | always `"%s"` as the format |
| SQL injection | `mysql_format` with `%s` | `%e` for strings, parameterized values only |
| teleport/speed hack | client position updates | validate delta against `GetPlayerSurfingVehicleID`, speed, and interior |
| weapon/health authority | client-reported damage | compute damage server-side; never trust `OnPlayerTakeDamage` values |
| money duplication | race between two commands/dialogs | single authoritative function, no client-supplied balance |
| RCON exposure | `rcon_password` weak/default | long random password, RCON not public, bind to loopback behind a proxy |
| resource exhaustion | expensive natives in a loop | budget per tick, rate limits, iterate `MAX_PLAYERS` (or `foreach`) instead of trusting `GetPlayerPoolSize`, which is only a deprecated `stock` shim in open.mp |

## 2. Audit commands (run these on the real tree)

```bash
# 1. user input used as a format string: format(x, size, input) or format(x, size, params)
grep -rnE 'format\([^,]+,[^,]+,\s*(inputtext|params|cmdtext|name)\b' --include=*.pwn --include=*.inc .

# 2. SQL built by concatenation instead of mysql_format %e
grep -rnE 'mysql_(tquery|pquery|query)\([^,]+,\s*"' --include=*.pwn .

# 3. dialogs shown without state tracking
grep -rn "ShowPlayerDialog" --include=*.pwn . | wc -l
grep -rn "gActivePlayerDialog\|DialogState" --include=*.pwn . | wc -l

# 4. missing disconnect cleanup (state leaks into recycled slots)
grep -rn "OnPlayerDisconnect" --include=*.pwn .
```

Any dialog show count higher than tracked-dialog count is a spoofing hole.

## 3. Authority checks that belong on the server

```pawn
// Position: reject teleports the client claims happened.
stock bool:IsPlausibleMove(playerid, Float:newX, Float:newY, Float:newZ, elapsedMs)
{
    if (elapsedMs <= 0) return false;
    new Float:dx = newX - gLastX[playerid];
    new Float:dy = newY - gLastY[playerid];
    new Float:dz = newZ - gLastZ[playerid];
    new Float:dist = floatsqroot(dx * dx + dy * dy + dz * dz);
    new Float:maxDist = 0.25 * float(elapsedMs);      // ~250 m/s ceiling
    return dist <= maxDist + 5.0;                      // 5 m grace for sync
}
```

- Health/armour changes go through one function that clamps (`0..100`).
- Weapon grants check the player's admin level and the weapon whitelist.
- Money changes go through `GiveMoney`/`TakeMoney` that clamp and log.
- Damage is computed from attacker weapon + distance, not from client values.

## 4. Config and RCON

Use `samp-server-configuration` for exact `config.json` / `server.cfg` keys and
verify them against the schema shipped with the installed server build; key names
differ between legacy `server.cfg` and open.mp `config.json`.

Non-negotiables:
- RCON password: long random, unique per server, never in the repo.
- RCON port not reachable from the internet; use an SSH tunnel or a proxy.
- Query port public is fine; RCON is not.
- Log rotation on (`logtimeformat`, or the open.mp logger component) so audit
  lines survive a restart.

## 5. Input handling rules

1. Cap every string before use: `if (strlen(inputtext) > 128) return Kick(playerid);`
2. Reject non-numeric where a number is expected (`strval("abc") == 0` is not a
   validation).
3. Strip control characters and `%` before echoing player text.
4. Never `strpack`/`strunpack` into a fixed buffer without checking length.
5. Bank/inventory operations: read the authoritative value, mutate, write, and
   reject if the pre-condition changed between read and write.

## 6. Reporting a finding

State: file:line, the attacker-controlled input, the exact path to impact, and
the minimal fix. Severity follows impact, not code style — a money duplication
race outranks every naming complaint.

## 7. Gate

- [ ] every dialog show increments a tracked state
- [ ] every privileged command has a level + cooldown
- [ ] no user input used as a format string
- [ ] all SQL values bound with `%e` or parameters
- [ ] position/health/money validated server-side
- [ ] RCON password not in the repo, port not public
- [ ] disconnect cleanup leaves no state in the recycled slot

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


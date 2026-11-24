---
name: samp-persistence-schema
description: Persistent data design for SA-MP and open.mp gamemodes — MySQL schema for accounts, characters, vehicles, properties and audit logs; index and migration rules; BlueG MySQL R41-4 threading with mysql_tquery and cache accessors; save-loop design that survives restarts; and the duplication races that break player economies.
---

# Persistence & Schema (SA-MP / open.mp)

A roleplay server is a database with a game attached. The failures that end
communities are not syntax errors: they are duplicated money, lost vehicles
after a restart, and a `SELECT *` in `OnPlayerUpdate` that takes the server down
at 200 players.

This skill covers schema and access patterns, not plugin installation
(`samp-mysql-database` covers BlueG R41-4 setup).

---

## 1. Table set that covers most gamemodes

| Table | Key | Notes |
|---|---|---|
| `accounts` | `id`, unique `username` | bcrypt hash, never plaintext; `last_login`, `created_at` |
| `characters` | `id`, `account_id` | money, level, skin, position, `deleted_at` for soft delete |
| `vehicles` | `id`, unique `plate` | `owner_char_id`, model, colour, `health`, `parked_at` |
| `properties` | `id` | `owner_char_id`, `type`, `price`, interior |
| `inventories` | `char_id`, `slot` | composite unique `(char_id, slot)` prevents duplicate slots |
| `transactions` | `id` | append-only ledger: `from_id`, `to_id`, `amount`, `reason`, `created_at` |
| `audit_log` | `id` | append-only: actor, action, target, payload JSON, ip |

The ledger is not optional. Without it, "where did the money go" is unanswerable
and duplication bugs are undetectable.

Reference DDL (MySQL 8, InnoDB, `utf8mb4`):

```sql
CREATE TABLE accounts (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username     VARCHAR(24)  NOT NULL,
    password     CHAR(60)     NOT NULL,           -- bcrypt, cost >= 10
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login   TIMESTAMP    NULL,
    UNIQUE KEY uq_accounts_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE characters (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id  INT UNSIGNED NOT NULL,
    name        VARCHAR(24)  NOT NULL,
    money       BIGINT       NOT NULL DEFAULT 0,
    level       SMALLINT     NOT NULL DEFAULT 0,
    skin        SMALLINT     NOT NULL DEFAULT 0,
    pos_x       FLOAT        NOT NULL DEFAULT 0,
    pos_y       FLOAT        NOT NULL DEFAULT 0,
    pos_z       FLOAT        NOT NULL DEFAULT 0,
    deleted_at  TIMESTAMP    NULL,
    KEY idx_characters_account (account_id),
    UNIQUE KEY uq_characters_name (name),
    CONSTRAINT fk_characters_account FOREIGN KEY (account_id) REFERENCES accounts (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE transactions (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    from_char   INT UNSIGNED NULL,
    to_char     INT UNSIGNED NULL,
    amount      BIGINT       NOT NULL,
    reason      VARCHAR(48)  NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_tx_from (from_char, created_at),
    KEY idx_tx_to   (to_char, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

Limitation: this DDL is a reference shape. Apply it through your migration tool
and test it on staging before production; column choices (money as `BIGINT`
cents vs `DECIMAL`) must match the existing code.

## 2. Access rules

1. **Never query in `OnPlayerUpdate`.** It runs per player per tick.
2. Load the character once on spawn into a server-side cache; write on
   disconnect and on a slow autosave timer (30–120 s), not on every change.
3. Use `mysql_tquery`/`mysql_pquery` (threaded) and read results inside the
   callback with `cache_get_value_name_int/float/string`, `cache_get_row_count`.
4. Every query that contains a string uses `mysql_format(handle, query, sizeof query, "... '%e' ...", value)`
   — `%e` escapes; plain `%s` is an injection.
5. Check `cache_get_row_count` before indexing row 0. A missing row is not an
   empty row.
6. Money: `UPDATE characters SET money = money + ? WHERE id = ? AND money + ? >= 0`
   and verify `mysql_affected_rows` — read-then-write in Pawn races with autosave.
7. Persist an idempotency key per transaction (`reason + char + tick`) so a
   retried callback cannot pay twice.

## 3. Migrations

- Version the schema (`schema_version` table), never hand-edit production.
- Expand → migrate → contract: add nullable column, backfill in batches, switch
  reads, drop old column in a later release.
- Online index creation on big tables (`ALGORITHM=INPLACE, LOCK=NONE`) during a
  low-population window; a blocking `ALTER` on `vehicles` freezes the server.
- Backups before migration, restore tested at least once.

## 4. Save-loop checklist

- [ ] character cache invalidated on disconnect, kick, and crash path
- [ ] autosave never runs while a load is in flight (guard flag)
- [ ] shutdown hook flushes all dirty caches
- [ ] duplicate login (same account, second client) rejected before cache write
- [ ] money/inventory writes go through one function each, with ledger row
- [ ] index coverage for the queries in the hot path (login, spawn, garage)

## 5. Verification

```bash
# find unparameterised string interpolation in queries
grep -rnE "mysql_(tquery|pquery|format)\(.*%s" --include=*.pwn .
# find per-tick queries
grep -rn -A5 "OnPlayerUpdate" --include=*.pwn . | grep -i mysql
```

Both greps must return nothing. Then run a restart test: save, restart, load,
compare every character field — a silent column mismatch shows up only there.

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


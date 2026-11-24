---
name: samp-ucp-web-panel-bridge
description: Full-Stack UCP (User Control Panel) Web + Discord Bot + Shared MySQL R41-4 Bridge for open.mp & SA-MP 2026 — Next.js 15/Tailwind v4 UCP, Discord OAuth2 verification & whitelist quiz, automatic VIP/Donation delivery queue, character dashboard, ban appeals, live server query status, and staff audit trail synchronization.
---

# Full-Stack UCP Web Panel, Discord Bot & open.mp Server Bridge (2026)

Every top 2026 SA-MP/open.mp RP community pairs its game server with a crisp **Web UCP (User Control Panel)** and **Discord Bot** sharing one authoritative MySQL database and an asynchronous delivery queue.

---

## 1. Shared Database Architecture (Zero Race Conditions)

```text
[Next.js 15 UCP Web] ──┐
                       ├──▶ [MySQL 8 / MariaDB] ◀──▶ [open.mp Server (BlueG R41-4)]
[Discord.js Bot]     ──┘         (ucp_queue)           (polls every 5s / HTTP webhook)
```

### Never Mutate Live Online Player Cash Directly from Web!
If a player is **currently online** in-game and the Web UCP runs `UPDATE characters SET cash = cash + 50000`, the game server's next autosave (`UPDATE characters SET cash = %d`) will **OVERWRITE and wipe the donation!**

### The Safe `ucp_delivery_queue` Outbox Pattern
```sql
CREATE TABLE ucp_delivery_queue (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id    INT UNSIGNED NOT NULL,
    character_id  INT UNSIGNED NULL,
    action_type   ENUM('ADD_VIP', 'ADD_COINS', 'ADD_ITEM', 'UNBAN', 'KICK', 'SET_ADMIN') NOT NULL,
    payload_json  JSON NOT NULL,
    status        ENUM('PENDING', 'APPLIED', 'FAILED') NOT NULL DEFAULT 'PENDING',
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    applied_at    TIMESTAMP NULL,
    INDEX idx_pending (status, account_id)
);
```
1. **Web UCP / Payment Webhook** (Midtrans / Xendit / Stripe / Saweria / Discord Bot) inserts a `PENDING` row into `ucp_delivery_queue` (with idempotent `external_tx_id UNIQUE` so duplicate webhooks NEVER double-credit!).
2. **open.mp Server** checks `ucp_delivery_queue WHERE status = 'PENDING'` on player login AND via a `5000ms` threaded background timer for online players:
   - Applies reward in-memory (`GivePlayerCoins`, `Inv_AddItem`, `SetPlayerVIP`), saves character, marks row `APPLIED`, and triggers celebratory `Ox_Notify` toast in-game!

---

## 2. Core UCP Web Features (Next.js 15 + Tailwind v4 + Prisma/Drizzle)

- **Discord OAuth2 + UCP PIN Registration:**
  1. Player logs in with Discord on UCP Web (`discord_id` stored UNIQUE on `accounts` — stops ban evaders creating 20 accounts!).
  2. Completes a short **Roleplay Rules Quiz** (for Whitelist / Semi-Heavy RP servers) or instant SMS/Discord DM OTP verification (`6-digit code` sent by Discord Bot).
  3. Creates UCP username + Bcrypt password (`cost = 12`, compatible with `samp-bcrypt` / `open.mp` `$2y$`/`$2b$` prefix!).
- **Player Dashboard:** View characters, bank balance, vehicles, properties, playtime stats, clean/dirty audit history, and submit **Ban Appeals / Refund Requests**.
- **Staff Admin Panel (RBAC):** Search players by Name/IP/Serial/Discord, view live **Economy Inflation Charts**, inspect **Anti-Cheat Alerts**, approve Whitelist apps, and review **Admin Action Logs** (every `/ban`, `/givecash`, `/makeadmin` logged with staff ID + reason).
- **Live Server Status Widget:** Query open.mp server via UDP query (`open.mp` query protocol) cached in Redis for 15 seconds to display live online player count, hostname, and ping without flooding port 7777.

---

## 3. Security Checklist for UCP + open.mp
1. **Bcrypt Hash Compatibility:** Ensure Node.js `bcryptjs` / `bcrypt` hashes (`$2b$12$...`) match your PAWN bcrypt plugin (`SyS/samp-bcrypt` supports `$2y$` and `$2b$`!). Test a round-trip login created on Web -> verified in PAWN before launch!
2. **Idempotent Webhooks:** Verify HMAC signatures on every payment callback (Midtrans/Xendit/Stripe) + enforce `UNIQUE(transaction_id)`.
3. **Never Expose MySQL Port 3306 Publicly:** Bind MySQL to `127.0.0.1` or private WireGuard/VLAN IP between Web host and Game VPS.

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


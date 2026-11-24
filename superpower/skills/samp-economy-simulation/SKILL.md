---
name: samp-economy-simulation
description: Closed-loop economy simulation for SA-MP/open.mp servers — dynamic markets, supply/demand pricing, inflation control, player businesses, stock markets, and anti-exploit payout validation. Use when designing game economy, balancing payouts, or preventing money exploits.
---

# SA-MP/Open.mp Economy Simulation (2026)

## When to Activate
- Designing server economy (prices, payouts, taxes)
- Building player-owned businesses
- Implementing dynamic markets (supply/demand)
- Preventing money duplication/exploits
- Balancing job payouts vs costs

## Core Concepts

### 1. Closed-Loop Economy
Every dollar entering the economy must have a sink (exit point):
```
IN (sources) → CIRCULATION → OUT (sinks)
  Jobs, Crime     Trading      Taxes, Repairs
  Donations       Shops        Fines, Fees
  Looting         Auctions     Consumables
```

### 2. Dynamic Pricing (Supply/Demand)
```pawn
// Price = base * (1 + (demand - supply) / (demand + supply))
stock Float:CalculateDynamicPrice(base_price, stock, demand) {
    if (stock + demand == 0) return base_price;
    new Float:ratio = float(stock) / float(stock + demand);
    return base_price * (2.0 - ratio); // high stock = low price
}
```

### 3. Inflation Control
- **Transaction tax**: 2-5% on all purchases
- **Repair costs**: vehicle damage = money sink
- **Consumables**: food, fuel, ammo deplete
- **Property tax**: daily/weekly upkeep
- **Death penalty**: lose % of cash on death

### 4. Anti-Exploit Payout Validation
```pawn
// Server-side validation before payout
stock bool:ValidatePayout(playerid, job_type, amount) {
    // Max payout per hour per job type
    new max_hourly = GetJobMaxHourly(job_type);
    if (amount > max_hourly) return false;
    // Cooldown check
    if (GetTickCount() - g_last_payout[playerid] < PAYOUT_COOLDOWN) return false;
    // Distance check (player must be at job location)
    if (!IsPlayerNearJobLocation(playerid, job_type)) return false;
    return true;
}
```

### 5. Business System
```pawn
enum E_BUSINESS {
    biz_id, biz_type, biz_owner, biz_price,
    biz_stock, biz_demand, biz_last_restock,
    biz_income, biz_expenses, biz_profit
};
```

## Key Rules
1. **Never trust client for money** — all payouts server-side
2. **Log every transaction** — audit trail for economy balance
3. **Rate limit payouts** — max per hour per player
4. **Validate job completion** — server-side proof
5. **Monitor economy metrics** — total money, velocity, inflation rate

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
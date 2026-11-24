---
name: samp-banking-system
description: Banking system for SA-MP/open.mp — accounts, deposits, withdrawals, transfers, ATM interface, transaction history, and anti-fraud. Use when building banking features, ATMs, or financial transactions.
---

# SA-MP/Open.mp Banking System (2026)

## When to Activate
- Building bank accounts and transactions
- Creating ATM interfaces
- Implementing money transfers between players
- Adding transaction history/audit
- Preventing money laundering/exploits

## Core Concepts

### 1. Account Structure
```pawn
enum E_BANK_ACCOUNT {
    bank_id, bank_owner, bank_balance,
    bank_pin[8], bank_frozen,
    bank_created, bank_last_access
};
```

### 2. Deposit/Withdraw
```pawn
stock DepositMoney(playerid, amount) {
    if (amount <= 0) return SendClientMessage(playerid, -1, "Invalid amount.");
    if (GetPlayerMoney(playerid) < amount) return SendClientMessage(playerid, -1, "Not enough cash.");
    GivePlayerMoney(playerid, -amount);
    g_bank_balance[playerid] += amount;
    LogBankTransaction(playerid, "DEPOSIT", amount);
    SaveBankAccount(playerid);
    return 1;
}
```

### 3. Transfer Between Players
```pawn
stock TransferMoney(fromid, toid, amount) {
    if (amount <= 0) return 0;
    if (g_bank_balance[fromid] < amount) return 0;
    g_bank_balance[fromid] -= amount;
    g_bank_balance[toid] += amount;
    LogBankTransaction(fromid, "TRANSFER_OUT", amount, toid);
    LogBankTransaction(toid, "TRANSFER_IN", amount, fromid);
    SaveBankAccount(fromid);
    SaveBankAccount(toid);
    return 1;
}
```

### 4. ATM Interface (TextDraw)
```pawn
// ATM menu with deposit/withdraw/transfer/balance
stock ShowATMMenu(playerid) {
    // Show TextDraw UI with options
    // Handle selection via OnPlayerClickTextDraw
}
```

### 5. Anti-Fraud
- **Rate limit transfers** — max 5/hour per player
- **PIN verification** — require PIN for withdrawals
- **Transaction logging** — every transaction to DB
- **Frozen accounts** — admin can freeze suspicious accounts
- **Daily limits** — max withdraw per day

## Key Rules
1. **All transactions server-side** — never trust client money
2. **Log every transaction** — audit trail
3. **PIN for withdrawals** — security layer
4. **Rate limit** — prevent spam transfers
5. **Database persistence** — save after every change

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
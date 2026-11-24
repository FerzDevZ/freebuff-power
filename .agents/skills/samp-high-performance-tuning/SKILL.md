---
name: samp-high-performance-tuning
description: Performance Optimization & Lag Elimination for SA-MP & open.mp servers scaling to 500-1000+ players — AMX tick rate preservation, zero-overhead OnPlayerUpdate, memory cell packing, kernel network tuning, and database connection pooling.
---

# SA-MP / open.mp High-Performance Tuning Skill

## 1. The OnPlayerUpdate Golden Rule
`OnPlayerUpdate` is called **~30 to 50 times per second per connected player**.
- At **500 players**, that is **25,000 function calls per second**.
- At **1000 players**, that is **50,000 function calls per second**.

### ❌ Fatal Performance Sins in `OnPlayerUpdate`:
1. **Never format strings:** `format(msg, sizeof(msg), ...)` in `OnPlayerUpdate` consumes all CPU time.
2. **Never execute database queries:** Even threaded queries saturate the query queue.
3. **Never loop over all players:** A `foreach(new i : Player)` inside `OnPlayerUpdate` results in $O(N^2)$ algorithmic complexity (up to 1,000,000 iterations per tick!).
4. **Never call `GetPlayerPos` repeatedly:** Cache it once if needed.

### ✅ Optimal `OnPlayerUpdate` Pattern:
```pawn
public OnPlayerUpdate(playerid) {
    // Only perform lightweight state verification
    // Offload all heavy timers, distance math, and sync checks to 1-second interval timers
    return 1;
}
```

---

## 2. Low-Memory Cell Packing (`y_bit`)
By default, Pawn allocates a full 32-bit (4-byte) cell for every variable, including booleans:
- `bool:IsPlayerInStaffDuty[MAX_PLAYERS]` consumes 4,000 bytes (for 1000 players).
- Using `y_bit` packs 32 boolean states into a single cell, reducing RAM by 96.8%:
```pawn
#include <YSI_Data\y_bit>

new Bit:IsStaffDuty<MAX_PLAYERS>;
new Bit:IsPlayerCuffed<MAX_PLAYERS>;
new Bit:HasSeatbelt<MAX_PLAYERS>;
// Total memory for 1000 players across 3 flags: ~375 bytes instead of 12,000 bytes!
```

---

## 3. Database Connection Pool Architecture
Under heavy loads (server reboot, 500 players logging in within 2 minutes), a single database connection blocks query pipelines:

```ini
# mysql.ini
[mysql]
pool_size = 8       ; 8 concurrent worker threads
auto_reconnect = true
```
- Map read-heavy queries (`SELECT`) and write-heavy queries (`UPDATE`) across worker threads.
- Group periodic saves: Instead of saving 1000 players individually every second, save in staggered batches of 50 players every 5 seconds (`SavePlayerBatch`).

---

## 4. Linux Kernel Tuning for High-Volume UDP Game Servers
High-speed UDP packet bursts can cause the Linux kernel to drop game packets before they reach `omp-server`:

```bash
# Add to /etc/sysctl.conf
# Increase max receive & send socket buffer size for UDP 7777
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 262144
net.core.wmem_default = 262144

# Increase netdev queue length (backlog buffer)
net.core.netdev_max_backlog = 10000

# Apply immediately
sysctl -p
```

---

## 5. Algorithmic Optimization (Binary Search vs Linear Search)
When searching sorted dynamic entity arrays (e.g. 5,000 registered house IDs or item IDs), replace linear $O(N)$ scanning with Binary Search $O(\log N)$:

```pawn
stock BinarySearchHouse(targetDBID, const houseDBIDs[], count) {
    new low = 0, high = count - 1;
    while (low <= high) {
        new mid = low + (high - low) / 2;
        if (houseDBIDs[mid] == targetDBID) return mid; // Found in < 13 operations!
        if (houseDBIDs[mid] < targetDBID) low = mid + 1;
        else high = mid - 1;
    }
    return -1; // Not found
}
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


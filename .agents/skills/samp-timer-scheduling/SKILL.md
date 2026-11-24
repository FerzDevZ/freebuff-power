---
name: samp-timer-scheduling
description: Timer correctness for SA-MP and open.mp servers — SetTimer/SetTimerEx ownership, orphaned timers after disconnect, duplicate timer leaks, repeating-timer drift, tick-budget budgeting for 500+ players, and which work belongs on a timer versus an event. Ships a compile-verified per-player timer bookkeeping include.
---

# Timer Scheduling (SA-MP / open.mp)

Most "server gets slower after 4 hours" reports are timer leaks, not memory bugs.
A timer is a global object keyed by an integer; nothing ties it to the player it
was started for.

The `resources/samp_timer.inc` include fixes ownership for the common case: a
timer whose only argument is the player id.

---

## 1. Ownership rules

1. **Every player-bound timer is killed in `OnPlayerDisconnect`.** Otherwise it
   fires against a recycled id and either acts on the wrong player or crashes on
   a stale index. `TG_StopAll(playerid)`.
2. **One slot per purpose per player** (`TG_SLOT_HUD`, `TG_SLOT_AUTOSAVE`).
   Starting the same slot twice must kill the previous id, otherwise the first
   timer is unreachable and leaks until the server restarts.
3. **Never start a timer from inside its own callback.** That doubles the number
   of running timers every tick. A repeating timer already repeats.
4. **`KillTimer` takes the id, not the function name.** If you did not store the
   id, you cannot stop the timer. That is the entire reason for the slot table.
5. **Timers are not a game loop.** Anything that can be computed from
   `GetTickCount()` deltas inside `OnPlayerUpdate` should not allocate a timer.

## 2. Which timer primitive

| Need | Use |
|---|---|
| one-shot, no args | `SetTimer("Func", ms, false)` |
| one-shot, player arg | `SetTimerEx("Func", ms, false, "i", playerid)` |
| repeating per player | `SetTimerEx(..., true, "i", playerid)` + slot table |
| more than one arg | `SetTimerEx` with a format string (`"iis"`, `"if"`) |
| millisecond-precision cooldown | not a timer — store `GetTickCount()` and compare |
| per-frame visual interpolation | `OnPlayerUpdate` with an elapsed-time guard, or a single global timer |

Pawn has **no varargs forwarding**: a wrapper cannot pass its own `...` into
`SetTimerEx`. That is why `TG_Start` only supports the player-id-only form and
why anything with extra arguments is started explicitly.

## 3. Drift and load

- A repeating timer is scheduled after the previous invocation; a 1000 ms timer
  that takes 40 ms to run fires roughly every 1040 ms. For clocks that must not
  drift, store a start tick and compute the remainder instead of counting ticks.
- Every timer callback is serialized on the AMX thread. 500 players × a 200 ms
  timer = 2500 callbacks/second competing with player sync. Batch instead: one
  global 1000 ms timer iterating connected players.
- Timers that touch the database must be threaded (`mysql_tquery` /
  `mysql_pquery`); a blocking query inside a timer stalls every player.
- Measure before tuning: log callback duration for the heaviest timer with
  `GetTickCount()` around the body, and publish p95, not the average.

## 4. Audit procedure

```bash
# every SetTimerEx needs a matching KillTimer path for player-owned timers
grep -rn "SetTimerEx" --include=*.pwn --include=*.inc .
grep -rn "KillTimer"   --include=*.pwn --include=*.inc .

# timers started with a literal string are the ones that leak most often
grep -rn 'SetTimer(Ex)\?("[A-Za-z_]*"' --include=*.pwn .
```

For each `SetTimerEx` found, answer three questions in writing:
1. Which player owns this timer?
2. Where is it killed when that player disconnects?
3. What happens if it fires twice in one tick?

## 5. Runtime checks

```pawn
// after a soak test, count live timers per player
printf("[TIMER] player %d runs %d timers (started %d total)", playerid, TG_Count(playerid), TG_TotalStarted(playerid));
```

A `TG_Count` that grows without a matching drop after `TG_StopAll` means a timer
was started outside the slot table.

## 6. Gate

```bash
pawncc resources/demo_timers_omp.pwn -i"$OMP_INCLUDE" -d3 -o/tmp/t.amx
pawncc resources/demo_timers.pwn -i"$LEGACY_STDLIB" -i"$OMP_INCLUDE" -d3 -o/tmp/t2.amx
```

- [ ] fixture compiles with 0 warnings on both targets
- [ ] every per-player timer has a slot and a disconnect kill path
- [ ] no timer starts itself
- [ ] no self-rescheduling one-shot used as a loop
- [ ] DB work inside timers is threaded

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


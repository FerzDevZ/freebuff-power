---
name: samp-crashdetect-debugger
description: Deciphering and resolving CrashDetect backtraces, AMX runtime errors (Error 4, 19, 20, 26), native stack dumps, memory corruption, and unhandled exceptions in SA-MP and open.mp servers.
---

# SA-MP / open.mp CrashDetect Debugger Skill

## Overview
`crashdetect` is the essential debugging plugin for SA-MP and open.mp. It intercepts server crashes, segmentation faults, and AMX execution halts, translating raw memory registers into human-readable stack traces with exact file names and line numbers.

## Setup Requirements
1. **Load Order:** Must be the **first** entry in `plugins` (`server.cfg`) or `legacy_plugins` (`config.json`).
2. **Compiler Flag:** Scripts MUST be compiled with `-d3` (generate complete debug symbol table).
   ```bash
   pawncc main.pwn -omain.amx -i include/ -d3
   ```
   *Without `-d3`, CrashDetect can only output hex memory addresses instead of function names and line numbers.*

---

## Decoding Common AMX Runtime Errors

### Error 4: "Array index out of bounds"
```text
[debug] Run time error 4: "Array index out of bounds"
[debug]  Accessing element at index 50 in array of size 50
[debug] AMX backtrace:
[debug] #0 0x00012340 in public OnPlayerDisconnect (playerid=50, reason=1) at modules/player/auth.inc:154
```
- **Cause:** Off-by-one bug. An array sized `new Data[MAX_PLAYERS];` accessed with `playerid = 50` when `MAX_PLAYERS` is `50` (valid indices: `0` to `49`).
- **Remediation:** Add boundary guard clause:
  ```pawn
  if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
  ```

### Error 19: "File or function is not found"
```text
[debug] Run time error 19: "File or function is not found"
[debug] Native function was not registered: "CreateDynamicObject"
```
- **Cause:** The script calls a native from a plugin that was not loaded or crashed during server boot.
- **Remediation:** Ensure `streamer.so` (or `.dll`) exists in `/plugins` and is specified in `config.json` before dependent scripts run.

### Error 20: "Invalid index parameter (bad entry point)"
- **Cause:** Gamemode does not define `main()` or filterscript does not declare `#define FILTERSCRIPT`.
- **Remediation:** Ensure gamemode defines an empty `main() {}` and filterscripts have `#define FILTERSCRIPT` at the very top.

### Error 26: "Stack/heap collision (insufficient stack size)"
```text
[debug] Run time error 26: "Stack/heap collision"
[debug] AMX backtrace:
[debug] #0 in FormatHugeLeaderboard () at modules/leaderboard.inc:82
```
- **Cause:** Declaring massive local arrays (e.g. `new buffer[10000];`) inside a function overflows the default AMX stack (typically 16KB).
- **Remediation:**
  1. Increase stack allocation at the top of the script:
     ```pawn
     #pragma dynamic 65536 // Allocate 64KB stack
     ```
  2. Or scope large string buffers statically/globally outside the function call stack.

---

## Native Crash Backtrace Triage (Plugin / C++ Fault)
When a crash occurs inside a C++ plugin rather than in Pawn bytecode:

```text
[debug] Server crashed while executing mygamemode.amx
[debug] Reading symbols from plugins/streamer.so...done.
[debug] Native backtrace:
[debug] #0 0xf76a14b2 in Streamer_ProcessItem () from plugins/streamer.so
[debug] #1 0x080c4210 in CPlayer::Update () from ./omp-server
```
- **Diagnosis:** The crash occurred inside `streamer.so` during `Streamer_ProcessItem`.
- **Action:**
  1. Verify streamer version matches open.mp server build.
  2. Check for corrupted parameters passed into `CreateDynamicObject` (e.g. `NaN` or `Infinity` floats from division by zero).
  3. Validate object model IDs (valid GTA SA models: 612–19999).

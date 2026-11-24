---
name: samp-include-library-design
description: Designing professional, reusable include libraries (.inc) for the SA-MP and open.mp community — ALS hook chaining, header guard standards, tag safety, const-correctness, sampctl package publishing, and zero-conflict naming conventions.
---

# SA-MP / open.mp Include Library Design Skill

## Overview
Writing a public Pawn library requires strict architectural hygiene. A library must integrate seamlessly into thousands of diverse gamemodes without breaking existing user callbacks, causing symbol collisions, or triggering compiler warnings.

---

## Standard Include Anatomy

### 1. Header Guards
Prevent duplicate symbol definitions:
```pawn
#if defined _INC_custom_radar
    #endinput
#endif
#define _INC_custom_radar
```

### 2. Dependency Checking
Fail gracefully with clear compile-time error messages if dependencies are missing:
```pawn
#if !defined _INC_open_mp && !defined _samp_included
    #error "Please include <open.mp> or <a_samp> before including <custom_radar>."
#endif

#if !defined _streamer_included
    #error "<custom_radar> requires Incognito's Streamer plugin. Please include <streamer>."
#endif
```

---

## ALS (Advanced Library System) Hook Chaining
ALS allows your library to intercept engine callbacks (`OnPlayerConnect`, `OnPlayerDisconnect`, etc.) while ensuring that other libraries and the final user script can still receive them.

```pawn
// Hooking OnPlayerConnect safely via ALS 7
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect Radar_OnPlayerConnect
forward Radar_OnPlayerConnect(playerid);

public OnPlayerConnect(playerid) {
    // 1. Library internal initialization logic
    Radar_InitPlayer(playerid);

    // 2. Chain to the next hooked handler or user gamemode
    #if defined Radar_OnPlayerConnect
        return Radar_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #define OnPlayerConnect Radar_OnPlayerConnect
#endif
forward Radar_OnPlayerConnect(playerid);
```

---

## Code Quality Standards for Public Includes

1. **Strict Namespace Prefixing:**
   - Every public symbol, stock function, global variable, and enum field must use a unique prefix (e.g. `Radar_` or `RADAR_`).
2. **Const-Correctness:**
   - Always mark read-only string or array parameters with `const`:
     ```pawn
     // Good:
     stock Radar_SetTitle(playerid, const titleText[])
     // Bad:
     stock Radar_SetTitle(playerid, titleText[])
     ```
3. **No Magic Numbers:**
   - Define all array limits and default values using `#if !defined` to allow users to override them:
     ```pawn
     #if !defined MAX_RADAR_BLIPS
         #define MAX_RADAR_BLIPS 32
     #endif
     ```
4. **Use Stock Keyword:**
   - Prefix internal helper functions with `stock` so unused functions do not trigger compiler warnings or bloat compiled `.amx` bytecode.

---

## Publishing via `sampctl` (`pawn.json`)
Structure your GitHub repository for distribution:
```json
{
  "user": "YourGitHubUser",
  "repo": "custom-radar",
  "entry": "test.pwn",
  "output": "test.amx",
  "dependencies": [
    "pawn-lang/samp-stdlib",
    "samp-incognito/samp-streamer-plugin"
  ],
  "include_path": ["include"]
}
```
Users can then install your library with one command:
```bash
sampctl package install YourGitHubUser/custom-radar
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


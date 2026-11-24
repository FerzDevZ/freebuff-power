---
name: samp-mobile-android-cef-ui
description: Cross-Platform PC + SA-MP Mobile Android & CEF (samp-cef) Hybrid UI Engineering — automatic Android/PC/CEF client detection, touch-friendly TextDraw sizing & safe zones, clickable mobile action pills replacing keyboard-only deadlocks, and React/HTML CEF bridge with seamless FiveM TextDraw fallback.
---

# Cross-Platform PC, SA-MP Mobile Android & CEF Hybrid UI Engineering

In 2026, a massive share of active SA-MP / open.mp Roleplay players connect from **SA-MP Mobile (Android)** alongside **PC (open.mp / 0.3.7 / 0.3.DL / CEF)**. Designing a server that breaks on Android or locks out non-CEF clients cuts your playerbase in half.

---

## 1. Client Capability Detection (PC vs Android vs CEF)

Detect client type cleanly on connect (`OnPlayerConnect` + `cef_on_init` / GPCI / client version checks) and store capability flags per player:

```pawn
enum E_CLIENT_PLATFORM
{
    PLATFORM_PC_STANDARD = 0,
    PLATFORM_PC_CEF,
    PLATFORM_MOBILE_ANDROID
};

new E_CLIENT_PLATFORM:gPlayerPlatform[MAX_PLAYERS];

// Standard SA-MP Mobile clients typically report specific client versions or empty/standard mobile GPCI patterns
// Always allow manual toggle via /settings -> "UI Mode: PC / Mobile" so players are NEVER misclassified!
stock bool:IsPlayerOnMobile(playerid)
{
    return (gPlayerPlatform[playerid] == PLATFORM_MOBILE_ANDROID);
}

stock bool:HasPlayerCEF(playerid)
{
    return (gPlayerPlatform[playerid] == PLATFORM_PC_CEF);
}
```

---

## 2. Touch-Safe Android Mobile TextDraw Rules

Mobile screens have virtual joysticks (bottom-left), virtual action buttons (bottom-right), and fingers instead of a 1px mouse cursor:

1. **Minimum Touch Target Size:**
   - Every selectable TextDraw button MUST be at least **`28.0 x 22.0`** virtual units (preferably `>= 36.0 x 24.0` for primary actions).
   - Maintain **`>= 6.0`** virtual units of gap between adjacent clickable buttons to prevent fat-finger misclicks!
2. **Avoid Mobile Virtual Control Overlap (Safe Zones):**
   - **Bottom-Left (`x: 0..165, y: 310..480`):** Occupied by Android virtual analog thumbstick. Place HUD pills either **Top-Left** or **Top-Right** for mobile mode!
   - **Bottom-Right (`x: 475..640, y: 280..480`):** Occupied by Sprint/Jump/Enter-Vehicle/Fire touch buttons. Place Speedometer at **Bottom-Center** (`x: 240..400, y: 395..465`) or **Top-Right** for mobile players!
3. **Eliminate Keyboard-Only Deadlocks:**
   - Android clients do NOT have easy access to `Y`, `N`, `H`, `ALT`, or `LCTRL` keys unless mapped to touch buttons.
   - **Rule:** Whenever a proximity interaction appears (`[Y] Open Garage`), render a **clickable TextDraw pill** or provide a compact quick-command alias (`/e`, `/inv`, `/phone`, `/v`) AND a dedicated Mobile Quick-Bar (`INV` | `HP` | `VEH` | `ACT`)!
4. **Always Provide an Explicit `[X] Close` Button:**
   - Android users struggle to press `ESC` to cancel `SelectTextDraw`. Every modal UI MUST have a clearly visible top-right `[X]` close sprite (`>= 24x24`) that calls `CancelSelectTextDraw(playerid)` and destroys the modal cleanly.

---

## 3. Hybrid CEF (`samp-cef`) + FiveM TextDraw Fallback Pattern

When supporting `samp-cef` (HTML/CSS/React/Vue NUI inside SA-MP) for PC players, NEVER hard-couple game logic to CEF! Use a **UI Adapter Layer** that dispatches either CEF JSON events OR FiveM-style TextDraws seamlessly:

```pawn
// Unified UI Adapter — game logic calls ONE function regardless of client platform
stock UI_ShowNotification(playerid, const title[], const message[], const type[] = "info", durationMs = 4000)
{
    if (HasPlayerCEF(playerid))
    {
        new payload[256];
        format(payload, sizeof(payload),
            "{\"title\":\"%s\",\"message\":\"%s\",\"type\":\"%s\",\"duration\":%d}",
            EscapeJson(title), EscapeJson(message), type, durationMs
        );
        cef_emit_event(playerid, "ui:toast", CEFSTR(payload));
        return 1;
    }

    // Automatic FiveM-Style TextDraw Toast fallback for standard PC & Android Mobile!
    return ShowFiveMToastTD(playerid, title, message, type, durationMs);
}
```

### CEF Security & Performance Invariants
1. **Never Trust CEF Input:** Treat every `cef_subscribe` callback from the browser just like an untrusted HTTP request — validate amounts (`amount > 0`), item ownership, range, and cooldowns strictly in PAWN!
2. **Single Persistent Browser Instance:** Create ONE persistent HUD/Overlay CEF browser (`id = 1`) and toggle screens (`Inventory`, `Phone`, `Bank`, `Dealership`) via React/Vue state events (`ui:openModal`) instead of destroying/recreating Chromium instances (eliminates frame stutter!).
3. **Always Release Cursor (`cef_focus_browser(playerid, 1, false)`)** on modal close, player death, or disconnect.

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


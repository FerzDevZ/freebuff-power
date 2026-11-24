---
name: samp-pawn-compile-gate
description: Real compile verification for Pawn projects on open.mp and SA-MP 0.3.7 — Community Compiler (pawncc 3.10.10+/qawno), include paths for omp-stdlib vs legacy samp-stdlib, warnings-as-errors, tag strictness (-Z), dual-target builds, sampctl 1.16 package/CI setup, and the exact commands that must exit 0 before any .pwn is called done.
---

# Pawn Compile Gate

No `.pwn` counts as working until the compiler says so, on **both** include
sets. "It should compile" is not evidence.

---

## 1. Toolchain (2026)

| Tool | Current | Role |
|---|---|---|
| Community Compiler (`pawn-lang/compiler`, ships as `qawno`) | 3.10.10+ | the only compiler worth using; fixed tags, `#warning`, better diagnostics |
| open.mp server | v1.6.7.3218 (Oct 2026) | runtime; 32-bit build, `components/` not `plugins/` |
| sampctl | 1.16.0 (Oct 2026) | package/deps/runtime/CI; has an SA-MP→open.mp migration guide |
| open.mp includes (`omp-stdlib`) | tracks server | `#include <open.mp>` |
| legacy includes (`pawn-lang/samp-stdlib`) | 0.3.7 | `#include <a_samp>` |

Legacy `a_samp.inc` needs the compiler's own `core.inc`, `float.inc`,
`string.inc` on the include path. open.mp's `a_samp.inc` is only a wrapper that
forwards to `<open.mp>` — a project that still includes `<a_samp>` on open.mp is
compiling through a compatibility layer, which is allowed but should be a
deliberate choice.

## 2. The gate

```bash
# open.mp target
pawncc gamemode.pwn \
  -i"$OMP_INCLUDE" -d3 -o/tmp/gamemode.amx > /tmp/omp.log 2>&1
echo "exit=$?"; grep -cE 'warning|error' /tmp/omp.log   # must be `0`

# SA-MP 0.3.7 target
pawncc gamemode.pwn \
  -i"$LEGACY_STDLIB" -i"$PAWN_CORE_INCLUDE" -d3 -o/tmp/gamemode_legacy.amx \
  > /tmp/legacy.log 2>&1
echo "exit=$?"; grep -cE 'warning|error' /tmp/legacy.log # must be `0`
```

- `-d3` = full debug info (line numbers in crashdetect traces).
- Add `-Z` for strict tags when the project is open.mp-only; `-Z-` when a legacy
  library insists on loose tags.
- `-;+` / `-\\+` control warnings-as-errors in recent compilers; failing a build
  on warnings is the correct default for new code.
- Check for **both** artefacts (`ls -l`), not just the exit code: a missing
  `-o` path can still print a summary.

## 3. Interpreting failures

| Message | Real cause | Fix |
|---|---|---|
| `fatal error 100: cannot read from file: "open.mp"` | include path missing | add `-i` for omp-stdlib |
| `warning 213: tag mismatch: expected tag "t_TEXT_DRAW_FONT"` | open.mp enum tag passed to an untyped parameter | type the parameter or cast at the boundary (`TD_ALIGN`/`_:` pattern in `samp_td_kit.inc`) |
| `warning 234: function is deprecated (symbol "X")` | open.mp renamed `Color`→`Colour` | define `MIXED_SPELLINGS` **before** including `<open.mp>`, or call the new spelling |
| `error 017: undefined symbol` | native not in the include set (plugin include missing) | add the plugin/component include (`streamer.inc`, `sscanf2.inc`, …) |
| `error 025: function heading differs from prototype` | signature drift after a library update | match the new prototype |
| `warning 203: symbol is never used` | dead helper left after refactor | delete it, do not `#pragma unused` a whole function |
| builds locally, fails in CI | different compiler build (3.2.x vs 3.10.x) | pin the compiler in `pawn.json`/CI cache |

## 4. sampctl project baseline

```json
{
  "user": "your-name",
  "repo": "your-gamemode",
  "entry": "gamemodes/main.pwn",
  "output": "gamemodes/main.amx",
  "dependencies": { "openmultiplayer/open.mp": "^1.6.7", "samp-incognito/samp-streamer-plugin": "^2.9.6" },
  "runtime": { "version": "1.6.7", "mode": "server" }
}
```

`pawn.json` pins both the compiler and the dependency set; CI then reproduces a
local build. Run `sampctl package build` in CI and `sampctl package ensure` after
pulling.

## 5. Rules

1. Warning count is a number in your final report, not a feeling.
2. Never ship with `#pragma unused` added just to silence a warning you did not understand.
3. Never mix `-Z` and `-Z-` across files in one package.
4. Re-run the gate after every edit that touches includes, tags, or natives.
5. A green compile is necessary, never sufficient: pair it with `samp-audit`
   and an in-game smoke test.

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


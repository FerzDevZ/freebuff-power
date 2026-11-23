---
name: samp-testing-harness
description: Testing Pawn gamemodes on SA-MP and open.mp — extracting pure logic for assertions, a compile-verified assertion harness that writes a CI-readable report, sampctl-driven smoke runs, regression fixtures for UI/textdraw and money paths, and why the server's exit code cannot be trusted as a test result.
---

# Testing Harness (SA-MP / open.mp)

Pawn has no test runner worth the name, so the working pattern is:
**pure functions + assertion calls from a test entry script + a report file that
CI greps**. That is enough to catch the bugs that actually cost money (economy
math, parsing, permission checks) without a client attached.

`resources/samp_test.inc` is the compile-verified harness.

---

## 1. What can and cannot be tested

| Testable without a client | Needs a running server + client |
|---|---|
| damage/economy/level math | sync, animation, camera |
| string parsing (`/pay 5 100`) | dialog rendering |
| permission decisions | TextDraw clicks |
| save/load serialization shape | vehicle physics |
| command registry metadata | anti-cheat false positives |

Design consequence: move rules out of callbacks into pure functions
(`static ClampHealth(value)`, `static ParseAmount(text, fallback)`) so they can
be asserted. A callback that both parses and mutates the world is untestable.

## 2. Harness usage

```pawn
public OnGameModeInit()
{
    ST_Reset();
    ST_CheckInt(100, ClampHealth(150), "health clamps above 100");
    ST_CheckInt(0,   ClampHealth(-25), "health clamps below 0");
    ST_CheckFloat(2.5, PricePerKm(25, 10), "price per km");

    new failed = ST_Summary("core-math");
    ST_WriteReport("scriptfiles/test-core-math.report", "core-math");
    return 1;
}
```

Report content:

```
PASS core-math checks=5 failures=0
```

or, on failure, `FAIL <suite>` plus one ` - <label>` line per failed check.

## 3. The gate CI must use

```bash
sampctl package build
timeout 20s sampctl run || true            # server runs until killed
grep -q '^PASS' scriptfiles/test-core-math.report
```

Two facts that trip people up:

- The Pawn **server exits 0 even when assertions fail**. `timeout ... || true` is
  expected; the report file is the result, not the process status.
- A missing report file must be treated as **failure**, not "no tests". Assert it
  exists before grepping:

```bash
test -f scriptfiles/test-core-math.report || { echo "test report missing"; exit 1; }
grep -q '^PASS' scriptfiles/test-core-math.report
```

## 4. Smoke tests that need a client

Keep these manual but scripted and repeatable; do not call them automated.

1. Connect, register, login, respawn within 30 s.
2. Open every main dialog once; no "server closed the connection" in the log.
3. Run the textdraw layout gate first
   (`samp-textdraw-layout-debugger`), then eyeball once in-game.
4. Money path: earn → spend → disconnect → reconnect → balance persisted.
5. Kill the player mid-job; verify the job state resets, not duplicates.

Record the log excerpt for each run. "It worked when I tried it" is not a result.

## 5. Regression fixtures

- Economy: one fixture per transaction type (deposit, withdraw, transfer, fee).
- Persistence: save with a value, restart, load, compare.
- TextDraw: `resources/fixture_ui.pwn` from `samp-textdraw-ui-craft` plus
  `bin/samp-td-preview.js` — geometry regressions are caught without a client.
- Commands: `resources/demo_commands.pwn` — compile-time registration sanity.

## 6. Gate

```bash
pawncc resources/demo_tests_omp.pwn -i"$OMP_INCLUDE" -d3 -o/tmp/tests.amx
pawncc resources/demo_tests.pwn -i"$LEGACY_STDLIB" -i"$OMP_INCLUDE" -d3 -o/tmp/tests2.amx
```

- [ ] fixture compiles 0 warnings on both targets
- [ ] CI fails when the report is missing or does not start with `PASS`
- [ ] at least one assertion per money/permission path
- [ ] failure labels name the rule, not the line number

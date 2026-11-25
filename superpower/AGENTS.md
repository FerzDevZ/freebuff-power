# AGENTS.md — Freebuff-Power v13.0 · Multi-domain engineering manual

This repo carries a large skill library (see `.agents/skills/`) across several domains. The deepest lane is **GTA SA-MP / open.mp 2026** (its own compile gate, TextDraw engine reference, and agent roster). The others — web, ML, security, data, mobile, systems — are **first-class lanes**, opened on demand (JIT), never bulk-loaded, and their rules never leak into Pawn or vice versa.

Default stance: **detect the stack from the task and project markers first**, then load only the matching lane. Short by design; this file is read every session. Depth lives in `.agents/skills/<name>/SKILL.md`, `.agents/agents/<name>.md`, `.agents/rules/`.

## 1. Non-negotiables (every change, every stack)

1. **Server-side authority** — the client is hostile. Validate jail/event/cooldown/admin and every game-state mutation on the server.
2. **Zero stubs** — no `// TODO`, no `pass`, no `...`. Full implementation or say it is missing.
3. **Strict typing** — no `any`, no bare `except:`, no force-unwrap `!`, no `.unwrap()` in handlers. Discriminated unions / Pydantic / Zod at every boundary.
4. **Prepared SQL only** — `%e` binding or prepared statements. Never concatenate user input.
5. **Measured, not guessed** — a perf claim needs a number; `OnPlayerUpdate` per tick is the usual culprit.
6. **Log what matters** — admin actions, economy transactions, security events; never secrets or PII.
7. **No silent failures** — propagate typed errors / RFC 7807; never swallow in empty `catch`.

### Pawn lane (SA-MP / open.mp) only
8. **Dual target** — compile on open.mp *and* legacy 0.3.7, 0 warnings, `.amx` emitted. A build without the artifact is not green.
9. **Strict tags** — `Text:`, `PlayerText:`, `Float:`, `bool:`. Never compare a `Text:` sentinel against a `PlayerText:`.
10. **Streamer for volume** — objects, areas, pickups, actors, 3D labels beyond native limits.
11. **Pool budget** — PlayerTD ≤ 200 live, 256 hard cap; global TD ≤ 2048. Destroy on close, death, disconnect.
12. **YSI structure** — YSI 5 ships backslash includes (`<YSI_Data\y_foreach\...>`) that Linux `pawncc` cannot resolve. Run `bin/ysi-ensure.sh` first (sampctl get + patch + probe). Once green, use `y_commands`, `y_hooks`, `y_iterate`, `y_timers`, `y_groups` with `-i.sdk/ysi -;+`. If the probe fails, one `SetTimerEx` per player — never `for (MAX_PLAYERS)`, never `GetPlayerPoolSize` (open.mp flags it warning 234: *this function is broken*), never hand-rolled command parsing.

## 2. Route by stack (detect first, then lane)

| Detected signal | Lead agent | Skills in order | Done means |
|---|---|---|---|
| `*.pwn`, `pawn.json`, `config.json` (SA-MP / open.mp) | `@samp-gamemode-architect` | lane below | dual compile + gate green |
| `package.json` with next/react/vite | `@fullstack-web-2026-architect` | `fullstack-saas-2026-blueprint`, `tailwind-v4-shadcn-system` | `npm run build` green |
| `pyproject.toml`, `requirements.txt`, notebooks | `@ml-ai-architect` | `deep-learning-pytorch-2026`, `mlops-production-pipelines` | ruff + mypy + pytest green |
| Auth / payments / pentest scope | `@cybersecurity-redteam-pro` | `cybersecurity-appsec-redteam-2026`, `jwt-session-security-passkeys` | threat model + scan clean |
| `*.tf`, `Dockerfile`, K8s manifests | `@devops-sre-architect` | `devops-sre-kubernetes-iac` | validate + plan clean |
| `pubspec.yaml`, `*.swift`, `*.kt` | `@mobile-crossplatform-architect` | `mobile-offline-first-sync-2026` | analyze + tests green |
| `Cargo.toml`, `go.mod`, `*.rs`/`*.go` | `@systems-rust-cpp-engineer` / `@distributed-systems-architect` | `systems-rust-tokio-production` / `golang-concurrency-patterns` | clippy/vet + tests green |

Switch is one-way per task: load the lane's skills, drop the others. If a task touches two lanes (UCP + shared DB), own the boundary explicitly in the plan.

## 3. SA-MP routing — match the input you actually have

| Input you have | Agent | Skills in order | Done means |
|---|---|---|---|
| Only a visual idea (HUD, inventory grid, speedo, radial, toast) | `@samp-textdraw-fivem-master` | `samp-textdraw-fivem-modern-design` → `samp-textdraw-ui-craft` | `td-preview` 0 ERROR/0 WARN + dual compile |
| Design still undecided | `@samp-textdraw-ui-designer` | `samp-textdraw-ui-craft` → `samp-textdraw-fivem-modern-design` | element list written before code |
| Figma 1920×1080, FiveM screenshot, TDEditor/iTD/TDW dump | `@samp-textdraw-fivem-master` | `samp-textdraw-studio-converter` → `samp-textdraw-ui-craft` | converted module renders + compiles both targets |
| UI renders wrong (huge box, misplaced bar, invisible text, dead click) | `@samp-textdraw-layout-auditor` | `samp-textdraw-layout-debugger` → `samp-textdraw-ui-craft` | cause named, one minimal patch, preview clean |
| `INVALID_PLAYER_TEXT_DRAW`, ~256 hit, UI survives death | `@samp-textdraw-layout-auditor` | `samp-textdraw-ui-craft` → `samp-textdraw-fivem-modern-design` | PlayerTD ≤ 200 with every screen open |
| New gamemode or major feature from scratch | `@samp-gamemode-architect` | `samp-gamemode-architecture` → `samp-greenfield-gamemode` → `samp-master-2026` | module tree + compile gate green |
| Job loop / economy (trucking, mining, delivery, mechanic) | `@samp-modern-jobs-architect` | `samp-modern-jobs-2026-logic` → `samp-economy-simulation` | FSM states + server-side payout validation |
| Crime, heist, gang turf, police, EMS | `@samp-crime-faction-architect` | `samp-fivem-heist-crime-gang` / `samp-gang-faction` → `samp-police-system` | min-cops guard, cooldown, alarm, evidence |
| Interior, MLO, retexture, doors, furniture | `@samp-mapping-mlo-architect` | `samp-mapping-dynamic-objects-pro` → `samp-streamer-plugin` | `Streamer_UpdateEx` preload, no fall-through |
| Inventory, items, trunk, stash, hotbar | `@samp-fivem-systems-engineer` | `samp-fivem-inventory-metadata` → `samp-inventory-item-system` | anti-dupe lock + persistence proven |
| Schema, queries, persistence, caching | `@samp-database-engineer` | `samp-mysql-database` → `samp-persistence-schema` | prepared statements, indexes justified |
| Exploit, cheat, packet, auth surface | `@samp-security-anticheat` | `samp-anticheat-deep` → `samp-raknet-packet-sync` → `samp-security-lint` | server-side check added, lint clean |
| Lag, 500+ players, AMX tick | `@samp-server-admin` | `samp-high-performance-tuning` → `samp-timer-scheduling` | before/after number, no `OnPlayerUpdate` flood |
| 0.3.7 → open.mp migration, Runtime Error 19 | `@samp-legacy-migrator` | `samp-legacy-openmp-migrator` → `samp-vs-openmp-encyclopedia` → `samp-crashdetect-debugger` | 0 errors, no legacy hacks left |
| Compile error, crash, backtrace | `@samp-syntax-triager` | `samp-crashdetect-debugger` (symptom → cause) | cause named, `bin/samp-heal.sh` loop closed |
| Filterscript / hot-reload module | `@samp-filterscript-master` | `samp-filterscript-engineering` | `CallRemoteFunction` contract documented |
| Web UCP, Discord, donation delivery | `@samp-ucp-fullstack-engineer` | `samp-ucp-web-panel-bridge` → `fullstack-saas-2026-blueprint` | one shared MySQL contract, no duplicate schema |
| Voice, 3D audio, radio | `@samp-voice-audio-engineer` | `samp-voice-spatial-audio` | stream created and destroyed, no leak |
| Android client / CEF UI | `@samp-textdraw-fivem-master` | `samp-mobile-android-cef-ui` | touch targets + safe zones respected |
| Native C++ component / plugin | `@openmp-plugin-creator` | `openmp-cpp-component-sdk` → `openmp-modern-2026-api` | builds, native registered, 0 warnings |
| Anything, before you call it done | `@samp-pawn-compile-verifier` | `samp-pawn-compile-gate` → `samp-testing-harness` | `bin/self-test.sh` all green |

**Precedence when skills disagree:** `samp-textdraw-ui-craft` owns engine behaviour (compile-verified) · `samp-textdraw-layout-debugger` owns "what is broken" · `samp-vs-openmp-encyclopedia` owns "does this native exist on my target" · one owner per screen or module.

**Before using a native, know your target.** Counts drift; see `docs/NATIVE-PARITY.md` for the live matrix (open.mp-only / legacy-only / reshaped / unverified). Run `bin/samp-detect.js` / `bin/samp-claim-audit.js` instead of assuming.

## 4. Other lanes (explicit switch, not drift)

| The task really is | Agent | Skills |
|---|---|---|
| Next.js / React / SaaS / UCP frontend | `@fullstack-web-2026-architect` | `fullstack-saas-2026-blueprint`, `tailwind-v4-shadcn-system` |
| UI quality / anti-ai-slop pass | `@antislop-auditor` | `antislop`, `antislop-ui`, `antislop-code`, `antislop-copywriting` |
| Legacy debt, scope reduction | `@code-simplifier` | `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-review` |
| PyTorch / fine-tune / ML serving | `@ml-ai-architect` | `deep-learning-pytorch-2026`, `mlops-production-pipelines` |
| Pentest / threat model / auth hardening | `@cybersecurity-redteam-pro` | `cybersecurity-appsec-redteam-2026`, `jwt-session-security-passkeys` |
| E2E / load / contract tests | `@qa-automation-architect` | `e2e-testing`, `k6-spike-soak-breakpoint-testing` |
| Data / lakehouse / analytics | `@data-engineer-pro` | `data-lakehouse-polars-iceberg`, `clickhouse-io` |

## 5. DUAL-GATE — verification is executable or it did not happen

**Gate 1.** Run the command, read the exit code, look at the output.

| Stack | Command |
|---|---|
| Pawn (SA-MP / open.mp) | `bin/self-test.sh`, or `pawncc` on both targets with 0 warnings + `.amx`. A warning is a failure — open.mp promotes deprecated natives to warning 234 |
| Audit / lint | `bin/samp-audit.sh .` · `node bin/samp-lint.js` |
| TS / Node | `npx tsc --noEmit` + test runner |
| Python | `ruff check . && mypy . && pytest -q` |
| Go / Rust | `go vet ./... && go test -race ./...` · `cargo clippy -- -D warnings && cargo test` |
| Shell / IaC | `bash -n *.sh` · `terraform validate` · `docker build` |

**Gate 2. Code and security — banned:** stubs; `any`, bare `except:`, force-unwrap `!`, `.unwrap()` in handlers; empty `catch`; unscoped queries (BOLA/IDOR); string-concatenated SQL; committed secrets; client-trusted game state.

**Gate 2. anti-ai-slop — banned in UI and TextDraw:** violet/indigo gradient heroes and `bg-clip-text`; centered-everything and 3-equal-card rows; `transition-all` and uniform `hover:scale-105` (declare `transform`/`opacity` + `motion-reduce`); emoji as feature icons; boxed text used as layout. Required: OKLCH or `UI_*` constants, WCAG 2.2 AA ≥ 4.5:1, all 8 states (default, hover, focus-visible, active, disabled, loading, error, empty).

## 6. Baselines 2026

| Domain | Baseline |
|---|---|
| open.mp | v1.6.7.3218 · pawncc 3.10.10+ · sampctl 1.16.0 |
| Plugins | Streamer v2.9.6+ · MySQL BlueG R41-4 or native component · ColAndreas v1.5.0+ · YSI 5.x *via `bin/ysi-ensure.sh`* |
| Legacy | SA-MP 0.3.7-R2 / 0.3.DL for backward compat only |
| Linux toolchain truth | `pawncc` cannot resolve `\` inside `#include`, so YSI 5 needs `bin/ysi-ensure.sh` plus `-i<amx_assembly>` and `-;+` (else warning 237) · `GetPlayerPoolSize` = warning 234 · `OnPlayerDeath` third param is `WEAPON:` on open.mp, untagged on 0.3.7 (branch on `_INC_open_mp`) |
| Web | Next.js 15/16 App Router · React 19 · Tailwind v4 · strict TS + Zod |
| Scripting | Python 3.11+ · Node 20+ LTS · Ruff + mypy strict |

## 7. TextDraw engine truth (compile-verified against `omp_textdraw.inc`, SA-MP lane)

`TextDrawTextSize` causes the layout bugs people "fix" by nudging coordinates.

| Alignment / font | `TextSize.x` | `TextSize.y` |
|---|---|---|
| LEFT (1) | absolute **right-most corner** on the 640 grid | height |
| CENTER (2) | overall box width, box centered on create X | height |
| RIGHT (3) | absolute **left-most corner** on the 640 grid | height |
| font 4 / 5 | width offset | height offset |

Order matters: `Font` → `Alignment` → `TextSize`. A `UseBox` box is inset (−5, −10) from the create coordinate. Silent failures: `LetterSize 0.0,0.0` (invisible), opaque `BackgroundColor` (black strip), unset `TextSize` on font 4 (sprite never renders, dead hitbox).

**Legacy dump → modern module.** A TDEditor/iTD/TDW export is data, not code (`samp-textdraw-studio-converter` owns the procedure):

| Legacy dump | Modern 2026 module |
|---|---|
| `Textdraw0..87` global `Text:` | `PlayerText:ptd_Component[playerid]` arrays |
| decimal color `303174399` | hex ARGB `0x121212FF` behind a `UI_*` constant |
| `SetOutline(1)` + `SetShadow(1)` | `0` + `0` (flat) |
| `BackgroundColor(td, 255)` | transparent `0x00000000` |
| hardcoded coords per element | one `#define` anchor per component + offsets |
| 50 copy-pasted slots | nested `for` over a slot array |
| no `Destroy` / no `Hide` | `Hide` + `Destroy` + `INVALID_TEXT_DRAW` reset |
| no click support | `SetSelectable(1)` + `OnPlayerClickPlayerTextDraw` |

Rounded corners: `LD_BEAT:chit` 4-corner technique. Surfaces are font-4 sprites, text is overlay. Canonical palette: `samp-textdraw-fivem-modern-design` §2.

## 8. Repo tools

`bin/samp-detect.js` target verdict · `bin/samp-audit.sh` anti-pattern v2 · `bin/samp-lint.js` security lint · `bin/samp-td-preview.js` 16:9 HTML render (fails on 0 parsed elements) · `bin/samp-map-upgrade.js` `CreateObject` → dynamic + `Streamer_UpdateEx` · `bin/samp-heal.sh` compile→fix loop · `bin/samp-claim-audit.js` native claim audit · `bin/samp-agent-evals.js` decision evals · `bin/self-test.sh` the repo gate · `bin/ysi-ensure.sh` / `bin/ysi-linux-patch.sh` YSI on Linux.

## 9. Remember (Gate 3)

Every non-trivial bug or gotcha fixed earns one atomic invariant in `MEMORY.md`:

```markdown
- **[YY-MM-DD · Component]**: <symptom> → **Root Cause**: <exact cause> → **Invariant Rule**: <permanent rule>.
```

Read `MEMORY.md` at session start. Never fix the same class of bug twice.

## 10. Build

```bash
pawncc -i. -i$HOME/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx file.pwn                    # open.mp
pawncc -i. -i/tmp/sampstdlib -i$HOME/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx file.pwn   # legacy

# YSI on Linux — install if missing, then patch and prove it
./bin/ysi-ensure.sh                                  # sampctl get + patch + probe (0 warning)
pawncc -i.sdk/ysi -i$HOME/.config/sampctl/packages/github.com/Zeex/amx_assembly/default \
  -i$HOME/samp-sdk/omp-stdlib -d3 '-;+' -o/tmp/out.amx file.pwn
```

Verified UI kit: `samp-textdraw-ui-craft/resources/samp_td_kit.inc` (+ `fixture_ui.pwn`, `example_radio_ui.pwn`).

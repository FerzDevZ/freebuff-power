# Freebuff-Power & FreePi-Power — AGENTS.md (v13.0)

Short on purpose: this file is read every session. Depth lives in `.agents/skills/` (661), personas in `.agents/agents/` (126), stack rules in `.agents/rules/` (23). Load 1–3 matching skills Just-In-Time (JIT) — never bulk-load.

## 1. Route the stack, then work

| Signal in the repo | Lead agent | First skill |
|---|---|---|
| Next.js / React / TS / SaaS | `@fullstack-web-2026-architect` | `fullstack-saas-2026-blueprint`, `antislop-ui` |
| PyTorch / ML / fine-tuning | `@ml-ai-architect` | `deep-learning-pytorch-2026`, `mlops-production-pipelines` |
| LLM agents / MCP / RAG / evals | `@ai-agent-systems-engineer` | `ai-agent-mcp-orchestration-2026`, `llm-evals-observability-2026` |
| Vision / OCR / voice | `@computer-vision-multimodal-engineer` | `computer-vision-multimodal-ai` |
| Polars / DuckDB / Iceberg / dbt | `@data-engineer-pro` | `data-lakehouse-polars-iceberg`, `clickhouse-io` |
| Go / Node high-scale API | `@distributed-systems-architect` | `distributed-systems-scale-2026`, `api-design` |
| Docker / K8s / Terraform / CI | `@devops-sre-architect` | `devops-sre-kubernetes-iac`, `distributed-tracing-opentelemetry` |
| Auth / pentest / threat model | `@cybersecurity-redteam-pro` | `cybersecurity-appsec-redteam-2026`, `jwt-session-security-passkeys` |
| Flutter / RN / Android / iOS | `@mobile-crossplatform-architect` | `mobile-offline-first-sync-2026`, `dart-flutter-patterns` |
| Rust / C++ / Zig / WASM / eBPF | `@systems-rust-cpp-engineer` | `systems-rust-tokio-production`, `cpp-modern-low-latency` |
| E2E / load / contracts | `@qa-automation-architect` | `e2e-testing`, `k6-spike-soak-breakpoint-testing` |
| GTA SA-MP & open.mp | `@samp-creator-2026` | `openmp-modern-2026-api`, `samp-textdraw-ui-craft` |
| Unknown / mixed | `@planner` | `codebase-onboarding` |

**Loop:** DISCOVER (read real files + `MEMORY.md`) → BUILD (smallest correct diff, typed, tested) → VERIFY (Gate 1 + Gate 2) → REMEMBER (Gate 3).

- **Read before edit.** No guessed APIs, exports, paths, or schema columns.
- **Chesterton's Fence.** Know why code exists before deleting or reshaping it; keep the diff scoped to the task.
- **Evidence over claims.** "Compiles" and "passes" require the real command, exit code 0, and the output inspected.
- **Parallel by default.** Batch independent reads/searches; do not serialize what has no dependency.

## 2. DUAL-GATE — EXECUTABLE VERIFICATION (Gate 1)

Never pass Gate 1 by eyeballing code. Run the command for the active stack:

| Stack | Command | Invariant |
|---|---|---|
| TS / Node | `npx tsc --noEmit` + test runner | exit 0, no type errors |
| Next / Vite | `npm run build` | clean bundle, no hydration break |
| Python | `ruff check . && mypy . && pytest -q` | lint + types + green |
| Go | `go vet ./... && go test -race ./...` | no races |
| Rust | `cargo clippy --all-targets -- -D warnings && cargo test` | zero warnings |
| C++ / native | `cmake --build build && ctest --output-on-failure` | zero warnings |
| Flutter | `flutter analyze && flutter test` | 0 issues |
| Shell / IaC | `bash -n *.sh` / `terraform validate` / `docker build` | valid syntax, minimal image |
| Pawn (SA-MP/open.mp) | `freepi-power samp audit .` + `sampctl package compile` | 0 critical, `.amx` emitted, 0 warnings, **both** targets |

## 3. Invariants (Gate 2)

**Code & security — banned:** stubs (`// TODO`, `pass`, `...`); `any`, bare `except:`, force-unwrap `!`, `.unwrap()` in handlers; empty `catch`; unscoped queries (BOLA/IDOR); string-concatenated SQL; committed secrets. Required: parameterized queries, boundary validation (Zod/Pydantic/tags), typed errors, tenant/owner scoping, domain-specific names over `data`/`obj`/`temp`.

**anti-ai-slop UI — banned:** violet/indigo gradient heroes and `bg-clip-text`; centered-everything or 3-equal-card rows; `transition-all` and uniform `hover:scale-105` (declare `transform`/`opacity` explicitly + `motion-reduce`); emoji as feature icons; `letter-spacing` on body text. Required: OKLCH tokens, WCAG 2.2 AA ≥ 4.5:1, all 8 states (default, hover, focus-visible, active, disabled, loading, error, empty), Lucide/SVG icons, asymmetric editorial/Bento layout.

## 4. Baselines 2026

| Domain | Baseline |
|---|---|
| open.mp | v1.6.7.3218 · pawncc 3.10.10+ · sampctl 1.16.0 |
| Plugins | Streamer v2.9.6+ · MySQL BlueG R41-4 · YSI 5.x · ColAndreas v1.5.0+ |
| Legacy target | SA-MP 0.3.7-R2 / 0.3.DL only for backward compat |
| Web | Next.js 15/16 App Router · React 19 · Tailwind v4 CSS-first · strict TS + Zod |
| Scripting | Python 3.11+ (3.8/3.9 EOL) · Node 20+ LTS · Ruff + mypy strict |

Pawn builds are not green until the `.amx` exists. Batch-compile both targets — never "it should compile".

## 5. TextDraw engine truth (verified against `omp_textdraw.inc` + compile-tested fixtures)

`TextDrawTextSize` is where layout bugs are born; never fix them by nudging coordinates.

| Alignment / font | `TextSize.x` | `TextSize.y` |
|---|---|---|
| LEFT (1) | absolute **right-most corner** on the 640 grid | height |
| CENTER (2) | overall box width, box centered on create X | height |
| RIGHT (3) | absolute **left-most corner** on the 640 grid | height |
| font 4 / 5 | width offset | height offset |

Set `Font` → `Alignment` → `TextSize`, in that order. A `UseBox` box is inset (−5, −10) from the create coordinate. Silent failures: `LetterSize 0.0,0.0` (invisible), opaque `BackgroundColor` (black strip), unset `TextSize` on font 4 (sprite never renders, dead hitbox). Pool: **2048** global / **256** per player, sentinel `INVALID_TEXT_DRAW` / `INVALID_PLAYER_TEXT_DRAW` — `Text:` and `PlayerText:` sentinels are never interchangeable.

**Legacy editor dump → modern module.** A TDEditor/iTD/TDW export is not modern code; convert every row (`samp-textdraw-studio-converter` owns the procedure, `samp-textdraw-ui-craft` owns the engine rules):

| Legacy dump (jadul) | Modern 2026 module |
|---|---|
| `Textdraw0..87` global `Text:` | `PlayerText:ptd_Component[playerid]` arrays |
| decimal color `303174399` | hex ARGB `0x121212FF` behind a `TD_C_*` constant |
| `SetOutline(1)` + `SetShadow(1)` | `0` + `0` (flat) |
| `BackgroundColor(td, 255)` | `TD_C_TRANSPARENT` (`0x00000000`) |
| hardcoded coords per element | one `#define` anchor per component + offsets |
| 50 copy-pasted slots | nested `for` loop over a slot array |
| no `Destroy` / no `Hide` | `PlayerTextDrawHide` + `Destroy` + `INVALID_TEXT_DRAW` reset |
| no click support | `SetSelectable(1)` + `OnPlayerClickPlayerTextDraw` |

Rounded corners come from the `LD_BEAT:chit` 4-corner technique, surfaces are font-4 sprites, text is overlay — boxed text is not layout. Verify UI with `freepi-power samp td-preview <file>`; it refuses to report success when it parsed 0 elements.

## 6. REMEMBER (Gate 3)

Every non-trivial bug, build failure, or gotcha fixed earns one atomic invariant appended to `MEMORY.md`:

```markdown
- **[YY-MM-DD · Component]**: <symptom> → **Root Cause**: <exact cause> → **Invariant Rule**: <permanent rule>.
```

Read `MEMORY.md` at session start so the same mistake is never made twice.

## 7. Where things live

Agents `.agents/agents/<name>.md` · skills `.agents/skills/<name>/SKILL.md` · rules `.agents/rules/` · verified Pawn fixtures `samp-textdraw-ui-craft/resources/` (`samp_td_kit.inc`, `fixture_ui.pwn`) · repo gate `npm test` (`bin/self-test.sh`).

```bash
pawncc -i. -i$HOME/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx file.pwn                    # open.mp
pawncc -i. -i/tmp/sampstdlib -i$HOME/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx file.pwn   # legacy
```

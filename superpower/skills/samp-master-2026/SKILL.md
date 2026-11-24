---
name: samp-master-2026
description: Master orchestrator for SA-MP & open.mp 2026 development — detects request domain (UI, map, job, crime, vehicle, economy, NPC, camera, sound, weather), selects the right specialist skill, enforces design→code→compile→verify workflow, and guarantees 0-warning dual-target output. Use when starting any SA-MP/open.mp task, when unsure which skill to use, or when building a full feature spanning multiple domains.
---

# SA-MP / open.mp Master Orchestrator (2026)

## 1. Purpose

This skill is the **single entry point** for all SA-MP/open.mp development. When a user requests anything — "buatkan X", "fix Y", "design Z" — this skill determines:

1. **Domain** — what kind of task is this?
2. **Skill** — which specialist skill(s) to load
3. **Workflow** — what steps must be followed
4. **Gate** — what verification must pass before shipping

## 2. Domain Detection Matrix

| User Request Pattern | Domain | Primary Skill | Secondary Skills |
|---------------------|--------|---------------|-----------------|
| "buatkan UI", "HUD", "menu", "dialog", "TextDraw", "interface" | **UI/TextDraw** | `samp-textdraw-fivem-modern-design` | `samp-textdraw-ui-craft`, `samp-textdraw-studio-converter`, `samp-dialog-system` |
| "buatkan map", "interior", "mapping", "retexturing", "props" | **Map/MLO** | `samp-mapping-dynamic-objects-pro` | `samp-streamer-plugin`, `samp-colandreas-physics`, `samp-map-pipeline-2026` |
| "buatkan job", "pekerjaan", "kerja", "miner", "trucker", "courier" | **Job** | `samp-modern-jobs-2026-logic` | `samp-fivem-oxlib-target-logic`, `samp-modern-jobs-2026-logic` |
| "buatkan crime", "heist", "gang", "robbery", "drugs", "police" | **Crime/Faction** | `samp-fivem-heist-crime-gang` | `samp-crime-faction-architect` (agent) |
| "buatkan vehicle", "garage", "tuning", "fuel", "valet" | **Vehicle** | `samp-fivem-vehicle-tuning-garage` | `samp-streamer-plugin` |
| "buatkan inventory", "tas", "item", "drop", "pickup" | **Inventory** | `samp-fivem-inventory-metadata` | `samp-inventory-item-system` |
| "buatkan housing", "rumah", "furniture", "business" | **Housing/Business** | `samp-fivem-housing-business-crafting` | `samp-mapping-dynamic-objects-pro` |
| "buatkan phone", "smartphone", "MDT", "police computer" | **Phone/MDT** | `samp-fivem-smartphone-mdt` | `samp-textdraw-fivem-modern-design` |
| "buatkan economy", "market", "shop", "sell", "buy" | **Economy** | `samp-modern-jobs-2026-logic` | `samp-mysql-database`, `samp-persistence-schema` |
| "buatkan NPC", "bot", "AI", "pathfinding" | **NPC/AI** | `samp-npc-ai-behavior` | `samp-entity-lifecycle` |
| "buatkan camera", "cutscene", "spectate" | **Camera** | `samp-camera-cinematic` | `samp-colandreas-physics` |
| "buatkan sound", "audio", "radio stream", "music" | **Sound** | `samp-sound-audio` | `samp-voice-spatial-audio` |
| "buatkan weather", "time", "lighting", "day/night" | **Weather/Time** | `samp-weather-time` | `samp-colandreas-physics` |
| "buatkan anti-cheat", "hack detection" | **Anti-Cheat** | `samp-anticheat-system` | `samp-raknet-packet-sync` |
| "compile", "build", "error", "warning" | **Build** | `samp-pawn-compile-gate` | `samp-pawn-scripting` |
| "test", "verify", "check" | **Test** | `samp-testing-harness` | `samp-agent-evals` |
| "migrate", "upgrade", "legacy" | **Migration** | `samp-legacy-openmp-migrator` | `samp-vs-openmp-encyclopedia` |
| "editor", "tool", "setup", "install" | **Editor/Tool** | `samp-editor-ecosystem` | `samp-pawn-scripting` |
| "database", "mysql", "query", "schema" | **Database** | `samp-mysql-database` | `samp-persistence-schema` |
| "security", "exploit", "vulnerability" | **Security** | `samp-server-security-hardening` | `samp-security-lint` |

## 3. Universal Workflow (ALL requests)

Every request, regardless of domain, MUST follow this workflow:

```
1. DETECT  → Identify domain from user request (§2 table)
2. LOAD    → Load primary skill + 1-2 secondary skills (JIT, max 3)
3. DESIGN  → Plan before code (ASCII mockup, data table, state machine)
4. CODE    → Write modular code (data tables + loops, kit primitives)
5. COMPILE → pawncc both targets, 0 warnings
6. VERIFY  → Domain-specific gate (td-preview, ColAndreas, runtime suite)
7. SHIP    → Version control, pin versions, document
```

## 4. Universal Rules (ALL skills must enforce)

### Code Quality
- ❌ No raw natives where a kit/primitive exists
- ❌ No `// TODO`, `pass`, `...` placeholders
- ❌ No `any` type, no bare `except:`, no force unwrap
- ❌ No generic names (`data`, `item`, `res`, `temp`, `obj`)
- ✅ Data tables + loops for repeated structures
- ✅ Owner-tracked entities (actors, pickups, gangzones)
- ✅ Parameterized queries only (MySQL)
- ✅ All external boundaries validated (Zod/Pydantic equivalent in Pawn: input validation)

### Compile Gate
```bash
# open.mp target
pawncc file.pwn -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx

# legacy target
pawncc file.pwn -i. -i/tmp/sampstdlib -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx

# Both must produce: 0 errors, 0 warnings
```

### TextDraw Gate (if ships UI)
```bash
freepi-power samp td-preview ui/file.pwn   # 0 ERROR, 0 WARN
# Pool budget: ≤256 PlayerTextDraws per player
# Mobile dead zones: top 40px, bottom 60px, sides 20px
```

### Map Gate (if ships mapping)
```bash
freepi-power samp audit .                  # 0 critical issues
# ColAndreas Z-snap verification
# Streamer budget: ≤500 visible objects per player
# Floor height check: no fall-through at Z-2.0
```

## 5. Skill Inventory (74 skills, 2026)

### Core Engine
| Skill | Purpose |
|-------|---------|
| `samp-pawn-scripting` | PAWN fundamentals, callbacks, timers, modular structure |
| `samp-gamemode-architecture` | Feature-based folders, entity pools, event-driven comms |
| `samp-entity-lifecycle` | Owner-tracked create/destroy for actors, pickups, gangzones |
| `samp-pawn-compile-gate` | Dual-target compile verification |
| `samp-ysi-framework` | YSI 4.x/5.x (y_commands, y_hooks, y_iterate, y_groups) |
| `samp-include-library-design` | Reusable .inc design (ALS hooks, header guards) |

### UI & TextDraw
| Skill | Purpose |
|-------|---------|
| `samp-textdraw-fivem-modern-design` | Aesthetic design, component blueprints A-I, design-to-code pipeline |
| `samp-textdraw-ui-craft` | Engine truth, kit primitives, sprite math, pool budget |
| `samp-textdraw-studio-converter` | Figma/TDEditor → clean modular code |
| `samp-textdraw-layout-debugger` | Debug TextDraw sizing/alignment issues |
| `samp-dialog-system` | Dialog styles, state machines, safeDialog exploit prevention |
| `samp-editor-ecosystem` | IDEs, in-game editors, visual editors, TextDraw editors |

### Map & World
| Skill | Purpose |
|-------|---------|
| `samp-mapping-dynamic-objects-pro` | Retexturing, streaming, doors, attachments, interior/exterior |
| `samp-streamer-plugin` | Incognito Streamer, priority tiers, UpdateEx, pool budget |
| `samp-colandreas-physics` | Raycasting, Z-snap, anti-silent-aim, pathfinding |
| `samp-map-pipeline-2026` | Tool matrix, workflow, acceptance tests, failure library |
| `samp-custom-models-cdn` | Custom skins/vehicles/objects, FastDL, artconfig |

### Systems
| Skill | Purpose |
|-------|---------|
| `samp-modern-jobs-2026-logic` | FSM jobs, skill-check minigames, co-op, economy |
| `samp-fivem-heist-crime-gang` | Heists, turf wars, laundering, police MDT, EMS |
| `samp-fivem-vehicle-tuning-garage` | Persistent vehicles, garage, valet, impound, tuning |
| `samp-fivem-inventory-metadata` | Grid/weight inventory, metadata, hotbar, anti-dupe |
| `samp-fivem-housing-business-crafting` | MLO housing, furniture editor, businesses, crafting |
| `samp-fivem-smartphone-mdt` | Phone apps, police MDT, EMS medical |
| `samp-fivem-oxlib-target-logic` | ox_target, ox_lib, QBox state bus |
| `samp-fivem-character-cinema-anim` | Cinematic onboarding, character studio, emotes |

### Infrastructure
| Skill | Purpose |
|-------|---------|
| `samp-mysql-database` | R41-4, threaded queries, parameter binding, pooling |
| `samp-persistence-schema` | Schema design, migrations, versioning |
| `samp-http-json-integration` | REST APIs, JSON parsing, external services |
| `samp-discord-connector` | Bi-directional Discord bot, webhooks, audit logs |
| `samp-raknet-packet-sync` | Packet inspection, BitStream, sync packets |
| `samp-voice-spatial-audio` | 3D proximity voice, walkie-talkie radio |
| `samp-ucp-web-panel-bridge` | Next.js UCP, Discord OAuth, VIP delivery queue |

### Quality & Security
| Skill | Purpose |
|-------|---------|
| `samp-anticheat-system` | Speed/teleport/fly/weapon/health hack detection |
| `samp-server-security-hardening` | Firewall, rate limiting, exploit prevention |
| `samp-security-lint` | Static analysis for security issues |
| `samp-crashdetect-debugger` | Backtrace analysis, AMX errors, memory corruption |
| `samp-high-performance-tuning` | Tick rate, OnPlayerUpdate, memory packing, pooling |
| `samp-testing-harness` | Unit/integration/E2E test patterns |
| `samp-agent-evals` | Decision evals, scenario packs, pass rate |

### New Domains (2026)
| Skill | Purpose |
|-------|---------|
| `samp-npc-ai-behavior` | NPC AI, pathfinding, patrol, combat, dialogue, state machines |
| `samp-camera-cinematic` | Camera modes, cutscenes, spectating, letterbox, collision avoidance |
| `samp-sound-audio` | 3D sound, audio streams, radio, voice chat (sampvoice) |
| `samp-weather-time` | Dynamic weather, time cycle, day/night, environmental effects |

### Platform
| Skill | Purpose |
|-------|---------|
| `samp-vs-openmp-encyclopedia` | SA-MP vs open.mp side-by-side comparison |
| `samp-legacy-openmp-migrator` | 0.3.7 → open.mp migration guide |
| `samp-mobile-android-cef-ui` | PC + Android + CEF hybrid UI |
| `samp-greenfield-gamemode` | New gamemode from scratch |
| `samp-zombie-survival-horde` | Zombie survival game mode |
| `samp-roleplay-systems-bible` | Full RP server architecture |
| `samp-modern-creator-2026` | Full-stack server creator playbook |

## 6. Agent ↔ Skill Mapping

| Agent | Primary Skills | Role |
|-------|---------------|------|
| `@samp-creator-2026` | All skills | Full-stack server creator |
| `@samp-textdraw-fivem-master` | textdraw-fivem-modern-design, textdraw-ui-craft, textdraw-studio-converter | TextDraw specialist |
| `@samp-textdraw-ui-designer` | textdraw-fivem-modern-design, textdraw-ui-craft | UI design & code generation |
| `@samp-mapping-mlo-architect` | mapping-dynamic-objects-pro, streamer-plugin, colandreas-physics, map-pipeline-2026 | Mapping & MLO specialist |
| `@samp-fivem-systems-engineer` | fivem-oxlib-target-logic, fivem-inventory-metadata, fivem-vehicle-tuning-garage | FiveM-grade systems |
| `@samp-modern-jobs-architect` | modern-jobs-2026-logic, fivem-oxlib-target-logic | Job systems |
| `@samp-crime-faction-architect` | fivem-heist-crime-gang, fivem-smartphone-mdt | Crime & faction RP |
| `@samp-ucp-fullstack-engineer` | ucp-web-panel-bridge, mysql-database, discord-connector | Web UCP & Discord |
| `@openmp-plugin-creator` | openmp-cpp-component-sdk, systems-rust-tokio-production | C++ components |
| `@samp-legacy-migrator` | legacy-openmp-migrator, vs-openmp-encyclopedia | Migration specialist |

## 7. Gate (ALL requests)

```bash
# 1. Audit
freepi-power samp audit .

# 2. Compile (both targets)
pawncc file.pwn -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx
pawncc file.pwn -i. -i/tmp/sampstdlib -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/out.amx

# 3. TextDraw (if ships UI)
freepi-power samp td-preview ui/file.pwn

# 4. Map (if ships mapping)
# ColAndreas Z-snap + streamer budget + floor height

# 5. Runtime (if has logic)
# Test on real omp-server with players

# ALL must pass before shipping
```

## 8. Anti-Slop Rules (SA-MP specific)

1. **No raw editor export** — always refactor to modular code (data tables + loops)
2. **No hardcoded coordinates** — use constants, defines, or data tables
3. **No magic numbers** — name every threshold, timer, distance, pool size
4. **No copy-paste from examples** — compose from primitives, don't clone
5. **No editor preview trust** — always verify with td-preview and in-game
6. **No mixed streamer types** — pick legacy OR component, never both
7. **No unversioned dependencies** — pin streamer, ColAndreas, YSI versions
8. **No untested code** — every feature must have compile + runtime verification

---

## References

- skills.sh: https://www.skills.sh/ (standard format)
- agentskills.io: https://agentskills.io/specification (spec)
- open.mp docs: https://open.mp/docs
- open.mp awesome: https://open.mp/docs/awesome

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


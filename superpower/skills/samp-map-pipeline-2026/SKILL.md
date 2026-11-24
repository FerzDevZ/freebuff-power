---
name: samp-map-pipeline-2026
description: Current 2026 mapping pipeline for SA-MP & open.mp — which tool to use for what (Texture Studio 1.9/2.0 + mtools, MTA:SA editor + PAWN converters, Nexor TextDraw editor), open.mp v1.6.7 server layout (components/ vs plugins/), streamer as legacy plugin vs native component, artwork/artconfig custom models, ColAndreas verification, and an in-game acceptance loop that proves floors, doors and stream distances actually work.
---

# Mapping Pipeline 2026 (SA-MP & open.mp)

Answers "which tool, which path, what version" for mapping work, and how to prove
the result works in game instead of trusting the editor preview.

---

## 1. Pick the runtime first (it changes every path)

| | SA-MP 0.3.7 / 0.3.DL | open.mp v1.6.7.3218 (Oct 2026) |
|---|---|---|
| Binary | `samp03svr` (32-bit) | `omp-server` (32-bit) |
| Config | `server.cfg` | `config.json` |
| Plugins | `plugins/*.so` + `plugins` line | legacy plugins still load via `legacy_plugins`, **new** code goes to `components/` |
| Include | `#include <a_samp>` | `#include <open.mp>` |
| Streamer | Incognito `samp-streamer-plugin` in `plugins/` | either the same legacy plugin (`legacy_plugins: ["streamer"]`) **or** a native component port (`OpenSamp/omp-streamer-component`, drops it in `components/`, no SA-MP plugin exports) |
| Custom models | `artconfig.txt` (0.3.DL) | `artwork` block in `config.json`; CRC logging via `artwork.show_crc_logs` |

Rule: **do not mix** legacy-plugin streamer and component streamer in the same
server. Pick one, then keep every `#include <streamer>` native call unchanged —
the API surface is compatible; only the deployment path differs.

## 2. Tool matrix (updated Nov 2026)

| Task | Tool | Notes |
|---|---|---|
| All-in-one map editor (SP + MP) | **SA Map Studio v4.3.0** (Nov 2026) | builds in real San Andreas world, exports clean Pawn (0 warnings), local test server, AI integration (Claude), room generator, mirror tools, stairs, arrays; reads GTA SA installation, no game files modified |
| In-game object placement + materials | **Texture Studio Remastered 2.0** (OpenSamp fork) | in-game editor; object placement, material browser, groups/prefabs, vehicle editor, building removal, per-map SQLite persistence; exports CreateDynamicObject code |
| Co-op mapping + AI | **MapTogether** (Nov 2026) | co-op map with friends, one-button local open.mp test server, Claude AI integration for building, room generator, mirror tools, stairs, arrays, snapping, path placement; imports Pawn/Texture Studio/MTA .map, exports CreateDynamicObject/CreateObject |
| Texture Studio GUI / QoL | **mtools** (filterscript) | dialog interface on ALT; load **after** `tstudio` in the filterscript list |
| Re-texture / material text | `SetDynamicObjectMaterial`, `SetDynamicObjectMaterialText` | export from Texture Studio/SA Map Studio, then refactor into loops |
| Full map from an editor | **MTA:SA map editor** → PAWN converter | good for large exteriors; produces `CreateObject`/`createObject` that must become streamer objects |
| Visual 3D map editor (offline) | **SanMap Studio** | standalone Windows desktop editor, Three.js viewport, DFF/TXD browser, material editing, import/export Pawn, IPL streaming preview, RemoveBuildingForPlayer export |
| TextDraw layout | **Nexor's TextDraw Editor** or `td-preview` | editor canvas does **not** apply engine TextSize semantics — always re-check with `td-preview` |
| Collision / line of sight / ground Z | **ColAndreas** | raycast + `CA_FindZ_For2DCoord`; do not hardcode Z from the editor |
| HUD/UI art | custom TXD via `artconfig.txt` / open.mp `artwork` + CDN | 0.3.DL models only; CRC must match the client download |
| Texture bugs on stock GTA map | **MapFix** filterscript | fixes broken stock textures |
| **NEW: open.mp UI editor** | **abdulrahman1s/open-mp-ui-editor** (Oct 2026) | visual browser UI editor + Rust native TextDraw component for open.mp; Pawn callbacks; 449 sprite previews; 640x448 coordinate space; Login/HUD/Inventory/Menu examples; independent per-player UI instances |

## 3. Workflow (in order, no skipping)

1. **Design** — layout in editor, decide interior ids and virtual worlds up front.
2. **Map** — Texture Studio / MTA; keep one component per `.pwn` file
   (`interior_garage.pwn`, `mapping_hospital.pwn`), not one 5k-line file.
3. **Export** — raw PAWN is input, not output. Convert:
   `CreateObject` → `CreateDynamicObject`, add `STREAMER_TYPE_OBJECT` priority,
   strip per-object `SetObjectMaterial` chains into a data table + loop.
4. **Anchors** — one `#define <AREA>_X/_Y/_Z` per area; no magic coordinates
   outside the anchor block.
5. **Compile** — `samp-pawn-compile-gate` (0 warnings, both targets if both are
   supported).
6. **Verify in game** — section 4. This is the step that catches fall-through,
   invisible walls and doors that teleport you into the void.
7. **Deploy** — pin streamer/component version, ship `artconfig`/artwork config,
   and keep the exported source under version control.

## 4. In-game acceptance tests (the part most projects skip)

| Test | Procedure | Pass condition |
|---|---|---|
| No fall-through | teleport into the interior 20× with `Streamer_UpdateEx` preload | Z stays, no damage, no void |
| Stream budget | walk the interior, log `Streamer_GetVisibleItems(STREAMER_TYPE_OBJECT, playerid)` | stays under the client's visible-object cap; structure priority wins |
| Floor height | `CA_FindZ_For2DCoord` at 10 sample points vs `GetPlayerPos` | delta < 0.15 |
| Line of sight | `CA_RaycastLine` from camera to target through a wall | blocked where a wall exists, clear at doorways |
| Doors | open/close 10×, incl. two players at once | no duplicate, no stuck collision, state persists |
| Materials | night + day, all LODs | no missing texture, no z-fighting |
| Custom models | fresh client with empty cache | downloads once, CRC passes, no reconnect loop |
| Mobile | Android client | no tap target under the joystick/action pad |

## 5. Failure library

| Symptom | Cause | Fix |
|---|---|---|
| Player falls through custom floor | objects stream after gravity | `Streamer_UpdateEx(..., freeze)` before `SetPlayerPos`; structure priority |
| Interior visible from outside / disappearing walls | wrong virtual world / interior id, or stream distance < draw distance | unify vw/interior per area, `drawdistance <= streamdistance` |
| Objects pop in and out | too many objects inside stream radius | priority tiers, cut clutter, raise stream distance only for structure |
| Invisible collision | LOD or no-camera-collision flag misused | `SetDynamicObjectNoCameraCol` only for camera-only props |
| Map looks empty on some clients | custom models need download; missing CRC/TXD | verify artwork config + CDN reachability |
| Doors work alone, break with 2 players | global door state | per-player state or shared state with a lock |
| Everything fine in editor, wrong in game | editor preview lies about TextDraw geometry and object Z | `td-preview` + ColAndreas, never the editor canvas |

## 6. Gate

```bash
freepi-power samp audit .                       # legacy patterns, pickup 1239, <a_samp>
freepi-power samp td-preview ui/hud.pwn         # if the map ships a HUD
pawncc mapping_garage.pwn -i"$OMP_INCLUDE" -d3  # 0 warnings
sampctl package build                           # reproducible build for CI
```

Ship only when section 4 has been executed and its results recorded — "looks
fine on my screen" is not a mapping test.

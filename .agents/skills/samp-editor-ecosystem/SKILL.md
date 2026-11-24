---
name: samp-editor-ecosystem
description: SA-MP & open.mp editor ecosystem — IDEs (Spawn, VS Code + Open Pawn, DAWNO), in-game editors (Texture Studio Remastered 2.0, Fusez, Ultimate Creator), visual editors (SA Map Studio, MapTogether, SanMap Studio, MTA:SA), TextDraw editors (Nexor, Nickk, web-textdraw-editor, open-mp-ui-editor), and SAMP-MCP AI integration. Covers tool selection, workflow, and modern development environment setup for 2026.
---

# SA-MP & open.mp Editor Ecosystem (2026)

## 1. Overview

The SA-MP/open.mp development ecosystem has evolved significantly. Modern development uses a combination of **IDEs**, **in-game editors**, **visual editors**, and **AI-assisted tools**. This skill covers the full ecosystem and how to choose the right tool for each task.

## 2. IDE / Code Editors

### 2.1 Spawn IDE (Recommended for beginners)
- **Type**: Desktop (Python/PyQt), portable, no installation
- **Features**: Pawn editor with syntax highlighting, brace matching, changed-line markers, split editing, offline open.mp docs, SAMPCTL integration, package manager, Git integration, RGBA/HEX color preview + color picker, project tree, build output + server console
- **Best for**: Full project management, dependency management, Git workflow
- **Download**: github.com/daniilkorochansky/spawn
- **License**: GPL-3.0

### 2.2 VS Code + Open Pawn Extension (Recommended for experienced devs)
- **Type**: VS Code extension
- **Features**: Native pawncc (no Wine on Mac), IntelliSense, autocomplete, hovers, go-to-definition, compile-on-save, errors in Problems panel, snippets (OnPlayerConnect, dialogs, timers, etc.), dependency-free formatter
- **Best for**: Experienced developers who want IDE features, cross-platform (Windows/macOS/Linux)
- **Install**: Search "Pawn — open.mp / SA-MP" in VS Code marketplace
- **Download**: github.com/Mac-Andreas/vscode-open-pawn

### 2.3 DAWNO (Modern alternative to Pawno)
- **Type**: Desktop (Electron/Next.js), VS Code-inspired
- **Features**: Monaco Editor, advanced syntax highlighting, intelligent code completion, find/replace with regex, minimap, server management (start/stop/restart), live console, config editor (server.cfg/config.json), color preview for RGBA/HEX
- **Best for**: Developers who want a Pawno-like experience with modern UI
- **Download**: github.com/yeatdev/dawno

### 2.4 SAMP-MCP (AI-assisted development)
- **Type**: MCP server for AI assistants (Claude, Cursor, etc.)
- **Features**: TextDraw editor (design HUD/UI/logos as JSON, preview on web page), project management, documentation generation, deployment automation, code audit
- **Best for**: AI-assisted development, automated workflows
- **Install**: `npm install -g samp-mcp`
- **Download**: github.com/KongGithubDev/SAMP-MCP

### 2.5 Traditional editors (legacy)
- **Pawno**: Classic SA-MP editor, Windows only, limited features
- **Qawno**: Improved Pawno, still Windows-focused
- **Not recommended** for new projects — use Spawn or VS Code instead

## 3. In-Game Map Editors

### 3.1 Texture Studio Remastered 2.0 (OpenSamp fork)
- **Type**: In-game filterscript (runs inside SA-MP/open.mp server)
- **Features**: Object placement with mouse, position commands, delta moves; texture/material editing with built-in browser; object groups & prefabs (multi-select, group transforms, save/load reusable chunks); vehicle editor (paintjobs, mods, attached objects); building removal with persistent RemoveBuildingForPlayer; map import/export (raw CreateObject/CreateDynamicObject code); per-map SQLite persistence
- **Best for**: Detailed interior/exterior mapping at scale
- **Load order**: `tstudio` first, then `mtools` (GUI dialog interface)
- **Download**: github.com/OpenSamp/Texture-Studio-Remastered

### 3.2 Fusez's Map Editor
- **Type**: In-game filterscript
- **Features**: Objects + colors (texture and text support), vehicles (tuning), pickups, actors (animations), player attachments, categories, toolbar, offset editor, map file management (wipe/load/save), ingame help menu, RemoveBuilding support
- **Best for**: Quick in-game editing, object placement
- **Download**: github.com/simonseidel/Map-Editor-V3

### 3.3 Ultimate Creator (by NexiusTailer)
- **Type**: In-game filterscript
- **Features**: Advanced map editor with many features, actors, pickups, checkpoints, 3D text labels
- **Best for**: Comprehensive in-game editing with all entity types
- **Download**: Available on open.mp forum

## 4. Visual/Offline Map Editors

### 4.1 SA Map Studio v4.3.0 (Nov 2026) — Recommended
- **Type**: Desktop (web-based, runs in browser)
- **Features**: Full San Andreas map in 3D with streaming/LODs/water/interiors; editor-style free camera; teleport; object browser with previews; texture/material editing; snapping, arrays, stairs, mirror tools; room generator; remove GTA buildings or swap for editable copy; imports Pawn/Texture Studio/MTA .map; exports CreateDynamicObject/CreateObject; local test server (one button); AI integration (Claude); versioned .sanmap projects with undo/redo/autosave
- **Best for**: Professional mapping without running GTA/SA-MP; AI-assisted mapping
- **Download**: github.com/Walter-Correa/SA-Map-Studio

### 4.2 MapTogether (Nov 2026)
- **Type**: Desktop (Windows 10/11)
- **Features**: Co-op mapping (map with friends simultaneously); one-button local open.mp test server; Claude AI integration (free version works); whole SA map with LODs/water/SA-MP objects; object browser with previews; textures/material text with live preview; snapping, path placement, arrays, stairs, room generator, mirror tools; remove/swap GTA buildings; imports Pawn/Texture Studio/MTA .map; exports CreateDynamicObject/CreateObject; auto-updates
- **Best for**: Team mapping, AI-assisted development
- **Download**: Available on GTAinside.com / open.mp forum

### 4.3 SanMap Studio
- **Type**: Desktop (Windows, standalone)
- **Features**: Browse/preview DFF models and TXD textures from GTA IMG archives; place/select/group/duplicate/transform objects in Three.js viewport; edit material slots/colors/textures/SetDynamicObjectMaterialText; import/export native SA-MP and streamer Pawn code; preview GTA world through IPL streaming; export RemoveBuildingForPlayer calls; versioned .sanmap projects with undo/redo/autosave/crash recovery
- **Best for**: Offline retexturing and object placement without running the game
- **Download**: github.com/mgmoldova/sanmap-studio

### 4.4 MTA:SA Map Editor
- **Type**: Desktop (MTA:SA game client)
- **Features**: Full 3D map editor, object placement, vehicle placement, interior editing
- **Best for**: Large exterior maps; produces .map files that can be converted to Pawn
- **Converter**: xConverter (MTA to SAMP Multi-Converter), MapConverter
- **Download**: MTA:SA official

## 5. TextDraw Editors

### 5.1 San-Andreas-Online/web-textdraw-editor (Recommended web)
- **Type**: Web (browser, no server required)
- **Features**: Layer system, drag selection, resize, snap-to-grid, nudge with arrow keys, widescreen toggle, element types (Label, Button, Box, Sprite), layer panel with drag-and-drop reordering, toggle visibility/lock, export clean Pawn for both Global and Player TextDraws
- **Best for**: Visual TextDraw design without running a server
- **URL**: github.com/San-Andreas-Online/web-textdraw-editor

### 5.2 abdulrahman1s/open-mp-ui-editor (Recommended for open.mp)
- **Type**: Web + Rust native component for open.mp
- **Features**: Visual editing with layers, drag/resize, undo/redo, local saves, original GTA fonts, 449 sprite previews, HUD reference assets, text/rectangles/sprites/model preview elements, clickable buttons, independent per-player UI instances, dynamic text/color/bounds, Login/HUD/Inventory/Menu examples, Pawn callbacks
- **Coordinate space**: 640x448
- **Limits**: 128 primitives per definition, 8 instances per player
- **Best for**: open.mp servers with Rust native component
- **URL**: github.com/abdulrahman1s/open-mp-ui-editor

### 5.3 Nexor's TextDraw Editor
- **Type**: In-game filterscript
- **Features**: Clickable interface, grouping, undeleting texts, undoing changes, importing from file, sprite selector (300+), preview models and sprites, changeable variable name, 35+ pre-made colors, templates, quick selection
- **Best for**: In-game TextDraw editing with full control
- **Download**: Available on open.mp forum

### 5.4 Nickk's TextDraw Editor v5.0
- **Type**: In-game filterscript
- **Features**: Multilanguage (English/Polish/German), player progress bar support, sprite selector (300+), preview models and sprites, changeable variable name, 35+ pre-made colors, customizable interface, templates, quick selection, ALT key manual value editing
- **Best for**: In-game TextDraw editing with multilanguage support
- **Download**: Available on open.mp forum

## 6. Editor Concept: Workflow

### 6.1 Development workflow (modern)
```
1. Design   → Sketch UI/map concept (ASCII, mockup, or Figma)
2. Edit     → Use visual editor (SA Map Studio / web-textdraw-editor) or in-game editor (Texture Studio)
3. Export   → Raw Pawn code (CreateObject/CreateDynamicObject/TextDrawCreate)
4. Refactor → Convert to modular code (data tables + loops, kit primitives)
5. Compile  → pawncc both targets, 0 warnings
6. Verify   → td-preview, ColAndreas, in-game acceptance tests
7. Deploy   → Version control, pin versions, ship
```

### 6.2 Tool selection matrix

| Task | Recommended Tool | Alternative |
|------|-----------------|-------------|
| Full map (interior+exterior) | SA Map Studio v4.3.0 | Texture Studio Remastered 2.0 |
| Detailed interior mapping | Texture Studio Remastered 2.0 | SA Map Studio |
| Team/co-op mapping | MapTogether | Texture Studio + mtools |
| Offline 3D retexturing | SanMap Studio | SA Map Studio |
| Large exterior maps | MTA:SA editor + converter | SA Map Studio |
| TextDraw UI design | web-textdraw-editor | open-mp-ui-editor |
| open.mp native UI | open-mp-ui-editor | web-textdraw-editor |
| In-game TextDraw editing | Nexor's TextDraw Editor | Nickk's TextDraw Editor |
| Code editing | VS Code + Open Pawn | Spawn IDE |
| AI-assisted dev | SAMP-MCP + Claude | Spawn IDE |

### 6.3 Critical rules

1. **Editors produce raw code, not modern code.** All editors export raw `CreateObject`/`TextDrawCreate` calls. You MUST refactor into modular code (data tables + loops, kit primitives) before shipping.

2. **Editor preview lies.** Editor canvas does NOT apply engine TextSize semantics (for TextDraws) or streaming distances (for maps). Always verify with `td-preview` and in-game acceptance tests.

3. **Don't mix streamer types.** Pick either legacy plugin or native component streamer. Don't mix them in the same server.

4. **Version control everything.** Exported source must be under version control. Pin streamer/component versions.

5. **Compile gate is mandatory.** 0 warnings on both targets before shipping. No exceptions.

## 7. Editor Concepts

### 7.1 In-game vs offline editors

| Aspect | In-game editors | Offline editors |
|--------|----------------|-----------------|
| Requires game client | Yes | No |
| Requires server | Yes | No |
| Real-time preview | Yes (in game) | Approximate (3D viewport) |
| Multi-user | Limited (co-op in MapTogether) | No |
| AI integration | No | Yes (SA Map Studio, MapTogether) |
| Export format | Pawn (.pwn) | Pawn (.pwn) or JSON |
| Best for | Fine-tuning, small edits | Large projects, team work |

### 7.2 TextDraw editor workflow

```
1. Design  → Sketch UI concept (ASCII, Figma, or editor canvas)
2. Edit    → Use visual editor (web-textdraw-editor) or in-game editor (Nexor)
3. Export  → Raw Pawn code (TextDrawCreate + sizing/alignment/color calls)
4. Refactor → Convert to kit primitives (TD_RoundedCard, TD_Text, TD_Sprite, etc.)
5. Compile → pawncc both targets, 0 warnings
6. Verify  → td-preview (0 ERROR/WARN), pool budget check, mobile dead zones
7. Ship    → Version control, integrate into gamemode
```

### 7.3 Map editor workflow

```
1. Design  → Plan space (ASCII floor plan, zones, traffic flow)
2. Edit    → Use visual editor (SA Map Studio) or in-game editor (Texture Studio)
3. Export  → Raw Pawn code (CreateObject/CreateDynamicObject)
4. Refactor → Convert to streamer objects, data tables + loops, priority tiers
5. Compile → pawncc both targets, 0 warnings
6. Verify  → In-game acceptance tests (no fall-through, stream budget, floor height, LOD, doors, materials)
7. Deploy  → Pin versions, ship artwork config, version control
```

## 8. Modern Development Environment Setup

### 8.1 Minimum setup (beginner)
1. Download Spawn IDE (portable, no installation)
2. Download open.mp server v1.6.7.3218
3. Download streamer plugin (legacy or component)
4. Create project with SAMPCTL
5. Start coding

### 8.2 Recommended setup (experienced)
1. Install VS Code + Open Pawn extension
2. Install open.mp server v1.6.7.3218
3. Install streamer component (OpenSamp/omp-streamer-component)
4. Install ColAndreas plugin
5. Install YSI 5.x
6. Use sampctl for dependency management
7. Use Git for version control

### 8.3 AI-assisted setup
1. Install VS Code + Open Pawn extension
2. Install SAMP-MCP (`npm install -g samp-mcp`)
3. Configure MCP in Claude/Cursor
4. Use SA Map Studio or MapTogether for visual editing
5. Use Claude for code generation, refactoring, and verification

## 9. Gate

```bash
# Editor output must pass these gates before shipping
freepi-power samp audit .                       # legacy patterns, pickup 1239, <a_samp>
freepi-power samp td-preview ui/hud.pwn         # if ships a HUD
pawncc mapping_garage.pwn -i"$OMP_INCLUDE" -d3  # 0 warnings
sampctl package build                           # reproducible build
```

---

## References

- open.mp docs: open.mp/docs
- open.mp awesome list: open.mp/docs/awesome
- SA Map Studio: github.com/Walter-Correa/SA-Map-Studio
- Texture Studio Remastered: github.com/OpenSamp/Texture-Studio-Remastered
- web-textdraw-editor: github.com/San-Andreas-Online/web-textdraw-editor
- open-mp-ui-editor: github.com/abdulrahman1s/open-mp-ui-editor
- Spawn IDE: github.com/daniilkorochansky/spawn
- VS Code Open Pawn: github.com/Mac-Andreas/vscode-open-pawn
- DAWNO: github.com/yeatdev/dawno
- SAMP-MCP: github.com/KongGithubDev/SAMP-MCP
- MapTogether: Available on GTAinside.com / open.mp forum
- SanMap Studio: github.com/mgmoldova/sanmap-studio
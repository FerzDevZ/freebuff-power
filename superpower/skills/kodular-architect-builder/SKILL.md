---
name: kodular-architect-builder
description: >-
  Kodular App Architect & AIA Engine Specialist. Build, validate, diagnose, and repair Kodular (.aia)
  projects with clean SCM UI schemas, robust Blockly (.bky) events, XML entity escaping, and zero runtime crashes.
  Use when architecting Kodular Android apps, repairing corrupted AIA files, fixing GWT/Blockly errors, or designing multi-screen mobile workflows.
---

# Kodular Architect & Builder Specialist

This skill provides complete engineering standards, architecture blueprints, schema validation rules, and automated verification tools for building, repairing, and auditing **Kodular Creator** (`.aia`) projects.

---

## 🏛️ Kodular AIA Project Architecture

An `.aia` project is a zip archive with a strict internal directory structure:

```
<project_name>.aia (ZIP archive)
├── assets/                                 # Media assets (PNG, JPG, MP3, fonts)
├── src/                                    # Source code (SCM & BKY files)
│   └── io/kodular/<username>/<project>/
│       ├── Screen1.scm                     # Form UI component tree (JSON in #| $JSON ... |#)
│       ├── Screen1.bky                     # Blockly visual code blocks (XML)
│       ├── Screen2.scm
│       └── Screen2.bky
└── youngandroidproject/
    ├── project.properties                  # Build configuration & screen registry
    └── remix_history                       # Audit / remix history
```

---

## ⚡ Fundamental Kodular Invariants

### 1. `project.properties` Screen Registration
- All screens MUST be declared in the comma-separated `screenNames` property:
  ```properties
  screenNames=Screen1,Screen2,Screen3,Screen4,Screen5,Screen6,Screen7,Screen8,Screen9,Screen10
  ```
- `main` must point to the primary startup screen:
  ```properties
  main=io.kodular.<username>.<project>.Screen1
  ```
- If a screen exists in `src/` but is omitted from `screenNames`, Kodular's dropdown will hide it or crash with `IllegalStateException: Screen not found`.

### 2. SCM (Scheme / JSON) Specification
- Encapsulated inside comment markers `#|\n$JSON\n<json_payload>\n|#`.
- Root structure:
  ```json
  {
    "authURL": ["creator.kodular.io"],
    "YaVersion": "247",
    "Source": "Form",
    "Properties": {
      "$Name": "Screen1",
      "$Type": "Form",
      "$Version": "46",
      "AppId": "<numeric_app_id>",
      "AppName": "<project_name>",
      "BackgroundColor": "&HFED5F1F2",
      "ReceiveSharedText": "none",
      "Title": "Screen1",
      "TitleVisible": "False",
      "Uuid": "0",
      "Scrollable": "True",
      "$Components": [...]
    }
  }
  ```
- Every component MUST have:
  - `$Name`: Unique identifier (e.g. `Button1`, `Label_Title`).
  - `$Type`: Valid Kodular component type (e.g. `Label`, `Button`, `SpaceView`, `Image`, `Notifier`).
  - `$Version`: Exact schema version matching Kodular component specification.
  - `Uuid`: Unique numeric ID (e.g. 9-digit random integer).
- **Anti-Pattern Warning (`MakeroidCardView`)**:
  - Never wrap individual text labels or buttons in small, fixed-height `MakeroidCardView` components.
  - In companion and exported APKs, inner padding and corner clipping frequently render labels invisible or cause white-on-white text clipping ("empty pill capsules").
  - Use clean native `Label`, `Button` with high contrast, and `SpaceView` for responsive spacing.

### 3. BKY (Blockly / XML) Specification
- Root tag: `<xml xmlns="http://www.w3.org/1999/xhtml">`.
- Must terminate with: `<yacodeblocks ya-version="247" language-version="34"></yacodeblocks></xml>`.
- **CRITICAL**: All strings in text fields MUST be XML-escaped:
  - Ampersand `&` -> `&amp;`
  - Less-than `<` -> `&lt;`
  - Greater-than `>` -> `&gt;`
  - Quotes `"` -> `&quot;`
- Any unescaped `&` causes the browser GWT parser to fail with `ParseError: not well-formed`, resulting in completely blank block workspaces in Kodular!
- All `instance_name` attributes in BKY event handlers MUST exist in the corresponding `.scm` component list.

---

## 🛠️ Automated Validation Tool

Use the bundled validator script to test any AIA file before deployment:

```bash
python3 /home/firman/.gemini/config/skills/kodular-architect-builder/scripts/validate_aia.py <path_to_aia>
```

The script verifies:
1. `project.properties` syntax and complete screen registration.
2. Complete existence of `.scm` and `.bky` pairs for every registered screen.
3. Valid JSON structure and component IDs in `.scm`.
4. Well-formed XML and entity escaping in `.bky`.
5. 100% component reference matching between `.scm` and `.bky`.
6. Integrity of referenced media assets.

---

## 📋 Standard Multi-Screen Navigation Pattern

```xml
<block type="component_event" id="ev_btn_nav" x="40" y="40">
  <mutation component_type="Button" is_generic="false" instance_name="Button1" event_name="Click"></mutation>
  <field name="COMPONENT_SELECTOR">Button1</field>
  <statement name="DO">
    <block type="controls_openAnotherScreen" id="opn_target">
      <value name="SCREEN">
        <block type="helpers_screen_names" id="scr_target">
          <field name="SCREEN">Screen2</field>
        </block>
      </value>
    </block>
  </statement>
</block>
```

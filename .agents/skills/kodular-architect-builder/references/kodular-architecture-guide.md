# Kodular Architecture & Engine Reference Guide

## 1. Directory Specification
A Kodular `.aia` file is a standard ZIP archive with strict path hierarchy:
- `assets/`: Contains media assets (png, jpg, mp3). Must not contain orphaned or corrupt files.
- `src/io/kodular/<username>/<project_name>/`:
  - `<ScreenName>.scm`: Component tree metadata. Format is `#|\n$JSON\n<json>\n|#`.
  - `<ScreenName>.bky`: Blockly XML workspace. Root tag is `<xml xmlns="http://www.w3.org/1999/xhtml">`.
- `youngandroidproject/project.properties`:
  - Key `screenNames`: Comma-separated list of all screen names.
  - Key `main`: Full canonical class of Screen1.
  - Key `aname`: Display application name.
  - Key `name`: Internal project name.

## 2. Common Pitfalls & Invariants
1. **Unescaped XML in BKY**:
   Any `&` inside `<field name="TEXT">` must be written as `&amp;`. If unescaped, Kodular's GWT XML parser crashes silently, yielding blank workspaces.
2. **MakeroidCardView Layout Collapse**:
   Wrapping labels or buttons in `MakeroidCardView` with fixed heights without vertical centering causes text clipping and white capsule artifacts on real Android devices.
3. **Screen Dropout**:
   If a screen is present in `src/` but omitted from `screenNames` in `project.properties`, it will not be indexed by Kodular Creator.

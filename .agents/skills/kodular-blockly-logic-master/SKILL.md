---
name: kodular-blockly-logic-master
description: >-
  Master Kodular Blockly (.bky) visual programming, control flow logic, state variables, component methods,
  and event listeners. Use when authoring complex Kodular logic, debugging missing/disconnected blocks,
  creating quiz gamification, TinyDB local persistence, API web requests, and mathematical operations.
---

# Kodular Blockly Logic Master

This skill provides comprehensive standards and block templates for authoring robust, crash-free visual logic in Kodular Creator (`.bky` files).

---

## 🧩 Visual Block Taxonomy in Kodular

Kodular uses a customized Google Blockly XML engine (`ya-version="247" language-version="34"`):

1. **Component Events (`component_event`)**:
   Top-level handler triggers (e.g. `Form.Initialize`, `Button.Click`, `Clock.Timer`).
2. **Component Methods (`component_method`)**:
   Actions executed on components (e.g. `Notifier.ShowAlert`, `TinyDB.StoreValue`).
3. **Component Property Getters/Setters (`component_set_get`)**:
   Dynamic mutations or queries (e.g. set `Label.Text`, get `TextBox.Text`).
4. **Control Flow (`controls_if`, `controls_forRange`, `controls_openAnotherScreen`)**:
   Branching, loops, and screen switching.
5. **Logic & Math (`logic_boolean`, `logic_compare`, `math_number`, `math_add`)**:
   Evaluations, calculations, and state tracking.

---

## ⚡ Core Rules & Invariants

1. **XML Entity Sanitization**:
   Every string in `<field name="TEXT">` must be strictly escaped:
   - `&` -> `&amp;`
   - `<` -> `&lt;`
   - `>` -> `&gt;`
   - `"` -> `&quot;`
   - `'` -> `&apos;`
2. **Selector Strict Binding**:
   - `mutation.instance_name` and `field[name="COMPONENT_SELECTOR"]` must match an existing component name in the corresponding `.scm` file.
3. **Non-Colliding Coordinate Grid**:
   - Give independent event blocks staggered `x` and `y` coordinates (e.g., `x="40"`, `y="40"`, `y="180"`, `y="320"`) so they do not overlap in the visual canvas.

---

## 📦 Standard Block Snippets

### 1. Screen Switcher:
```xml
<block type="component_event" id="ev_btn_click" x="40" y="40">
  <mutation component_type="Button" is_generic="false" instance_name="Button1" event_name="Click"></mutation>
  <field name="COMPONENT_SELECTOR">Button1</field>
  <statement name="DO">
    <block type="controls_openAnotherScreen" id="opn_scr">
      <value name="SCREEN">
        <block type="helpers_screen_names" id="scr_target">
          <field name="SCREEN">Screen2</field>
        </block>
      </value>
    </block>
  </statement>
</block>
```

### 2. Notifier ShowAlert (Feedback / Toast):
```xml
<block type="component_method" id="call_alert">
  <mutation component_type="Notifier" method_name="ShowAlert" is_generic="false" instance_name="Notifier1"></mutation>
  <field name="COMPONENT_SELECTOR">Notifier1</field>
  <value name="ARG0">
    <block type="text" id="txt_msg">
      <field name="TEXT">Data berhasil disimpan!</field>
    </block>
  </value>
</block>
```


These are consistency requirements. They stay as-is, with two adjustments: R-05 now references the RHYTHM dial, and R-31 is upgraded to the keystone rule.

#### R-05 — Layout & Page Structure

- **FORBIDDEN**: AI template layouts (Hero + 3 cards, Hero + 6 features, Hero + fake stats, etc.)
- **FORBIDDEN**: "How It Works" always in 3 steps with round icons and numbers
- **FORBIDDEN**: bento-grid mosaic as the default section layout
- **FORBIDDEN**: a fake terminal window as the hero or feature visual
- **FORBIDDEN**: pricing always shown as three columns
- **FORBIDDEN**: generic "Trusted By" logo bar directly below the hero
- **FORBIDDEN**: 4-column template footer with Product / Company / Resources / Legal and no variation
- **FORBIDDEN**: every section using the same internal layout pattern (centered title + subtitle + identical card grid); see "Uniform Section Rhythm". Composition variety comes from `DESIGN.md`, not from a template
- Every page must have a structure built around **actual content needs**
- Section order must follow the product's narrative flow, not the AI default order (see Craftsmanship Standard C-3)
- Section composition must match the declared RHYTHM dial (Part 3): if RHYTHM is 3 (varied), sections must visibly vary; if RHYTHM is 1 (uniform), uniformity is a deliberate choice, not an accident

#### R-11 — Border Radius

- Use border radius that is **consistent with the defined design system**
- **FORBIDDEN**: making every element pill-shaped (pill buttons, pill cards, pill inputs, pill badges)
- Radius variation is a visual hierarchy tool; use it deliberately

#### R-15 — CTA (Call to Action)

- **FORBIDDEN**: "Get Started", "Learn More", "Try Now", "Explore", "Discover" as default CTAs
- CTAs must be **specific to the product context and the intended action**
- Better examples: "Start Your Free Trial", "Watch Live Demo", "Create Free Account"

#### R-16 — Copywriting & Buzzwords

- **FORBIDDEN**: "AI Powered", "Next Generation", "Revolutionary", "Seamless", "Cutting Edge", "Intelligent", "Ultimate", "Powerful", "Effortless"
- Use **specific language** that explains real benefits
- Show evidence, not claims

#### R-20 — Visual Identity

- The design must have a strong identity: a specific palette, a typeface chosen for a reason, a unique composition
- Every section must have a clear hierarchy
- Layout is built around the actual product content needs
- Identity comes from deliberate, explained choices, not from adding decoration (see Craftsmanship Standard C-1)

#### R-21 — Dark Mode

- Choose a theme based on brand identity, product type, and target users
- Developer tools, terminals, and creative tools have strong, legitimate reasons for a dark default. Use that reason, not "dark looks tech"
- If the product has no strong reason for a fixed theme, **build a working light/dark toggle**. "Give the user a choice" means build the toggle, not defer the work
- **FORBIDDEN**: using this rule (or any rule) as an excuse to skip or defer requested work. If the product should support dark mode, implement it now
- A theme toggle you ship must work correctly in BOTH modes. A dark mode that breaks the light mode is a defect (see R-34)

#### R-29 — Color Palette

- **REQUIRED**: limit the active palette to a maximum of 2-3 core colors + 1 accent color
- **FORBIDDEN**: using 5+ different colors on one page without a clear design system
- Neutral colors (white, black, grey) do not count as part of the core palette
- Palette consistency is the foundation of a strong visual identity

#### R-30 — Do Not Clone Popular Products

- **FORBIDDEN**: building a visual that overall mimics another product without being asked
  - "Make it look like Linear" (unless the user explicitly asks for it)
  - "Make it look like Vercel" (unless the user explicitly asks for it)
  - "Make it look like Stripe / Notion / Apple" (unless the user explicitly asks for it)
- AI defaults to cloning popular products because those patterns dominate training data
- Visual references may be used as inspiration, not as a template to copy
- The product must have its own visual identity, not the identity of another product

#### R-31 — Every Decision Must Have a Reason (Write It Down)

Before finishing the design, write a **one-line reason** for every major decision:
- Why this color?
- Why this layout?
- Why this typography?
- Why this spacing?
- Why use cards?
- Why use this illustration or icon?

If the reason cannot be written in one line, the decision is not valid and must be revisited. This rule is the keystone of this document: a technique is allowed only when its purpose is articulable. Writing the reason forces intent, and it is what the Purpose-Gate group (Group 2) checks.

---

## Part 3: Liveliness Toolkit

A filter can remove slop, but it cannot add energy. Removing slop leaves a void, and the model fills that void with its most generic output. Liveliness must be **added** deliberately. This Part is that mechanism: positive requirements, not bans.

### Three Dials (required)

Every design must set three dials explicitly, derived from `DESIGN.md` or the Design Read, and hold them from the first section to the last:

| Dial | 1 (Calm) | 2 (Balanced) | 3 (Bold) | What it answers |
|---|---|---|---|---|
| **ENERGY** | Linear, GOV.UK | Stripe, Vercel | Awwwards, agency portfolio | How hard does this design say hello? |
| **RHYTHM** | Uniform grid, predictable | Consistent with a few breaks | Asymmetric, mixed compositions | How much do sections change from each other? |
| **MOTION** | Hover states only | Scroll-reveal, transitions | Parallax, pin, choreography | How much motion, and why? |

The anchors (Linear, GOV.UK, Stripe, Vercel, Awwwards) are taste references for judging a value, not things to imitate.

Why three levels and not ten: a model and a reviewer can reliably tell "is this section uniform or varied?" (binary, checkable). They cannot reliably judge "is this a 6 or a 7?" (continuous, uncheckable). Three levels make liveliness enforceable.

Example sets: a designer portfolio sets ENERGY 3, RHYTHM 3, MOTION 2. A public-service site sets ENERGY 1, RHYTHM 1, MOTION 1.

### Levers (how the dials become visual decisions)

These are tools for hitting the dial values, not bans:

- **One focal point per screen**: exactly one element that is clearly the most important on every screen; the rest defer to it
- **Hierarchical contrast**: size, weight, and color are differentiated on purpose, not randomly
- **Whitespace as structure**: empty space separates and sets rhythm, not leftover space
- **One deliberate accent**: one color or gesture used sparingly at the key moment. Zero accents is sterile; an accent everywhere is slop
- **Identity motif**: one pattern, gesture, or typographic voice that is specific and repeated, making the design "belong" to the product

### Design Read (how the dials are set)

Before generating, declare one line:

> Reading this as: `<page kind>` for `<audience>`, in a `<visual language>` style, dial `<ENERGY/RHYTHM/MOTION>`.

Example: *"Reading this as: B2B SaaS landing for technical buyers, with a Linear-style minimalist language, dial ENERGY 1 / RHYTHM 2 / MOTION 1."*

1. **Direction exists** (`DESIGN.md` or a brief that expresses energy and mood): infer the dials from it and proceed. `DESIGN.md` may optionally include a line like `Dial: ENERGY 2 / RHYTHM 3 / MOTION 1`; if present, use it directly.
2. **Direction is ambiguous**: ask exactly ONE decisive question, never a question dump. Example: *"Should this feel closer to Linear-clean or Awwwards-experimental?"* Use the answer to set the dials.
3. **No direction and the user cannot be asked**: label the output *"draft without direction"*, set the honest default dials **ENERGY 1 / RHYTHM 1 / MOTION 1** (see R-37), and do not present it as a deliverable.

## Functional Patterns

"What works" means one of these, depending on context:

- **Anchor to a real section**: `href="#pricing"` where `#pricing` exists
- **Scroll to relevant content** for a "Learn more" style link
- **Open a modal or dialog** for a quick action (closable with Escape)
- **Toggle a state**: mobile menu, theme, accordion, tabs
- **External action**: `mailto:`, a real product URL
- **Form submit** with visible feedback

If none of these applies to an element, the element should not exist.

---

## Delivery Gate (Mandatory)

Run this gate BEFORE delivering. Output its status with your deliverable as a **PASS/FAIL report**: one line per item, and every `PASS` backed by concrete evidence (e.g. "R-26 PASS: every button has a real `href` or `onClick`; no dead controls", "R-35 PASS: ran the build and clicked every control: Signup -> /signup, empty form -> validation, mobile menu -> opens, no console errors").
If any item is **FAIL** (or any answer is **yes**), do not deliver: fix it first, then re-run. A report containing a FAIL must never be shipped.

This gate cannot be delegated or replaced. If another workflow is leading the session, its own wrap-up or summary does not stand in for this report. A deliverable handed over without it is unfinished, not approved.

The gate has four blocks: Hard Gate (absolute), Purpose-Gate (technique + written reason), Liveliness (dials + levers), Craftsmanship & Quality Locks (C-1..C-5 plus the consistency locks R-05, R-11, R-15, R-16, R-20, R-21, R-29, R-30, R-31).

### Block 1: Hard Gate (absolute)

Before declaring the design done, answer every question below. All answers must be **no**:

- [ ] Is there an em dash (`—`) anywhere in the text, outside the R-02 carve-out and any voice sample the owner approved under R-37? *(R-02)*
- [ ] Is there any horizontal overflow, text escaping its container, or broken layout on mobile? *(R-03)*
- [ ] Are there any statistics without a real source (10K+ Users, 99.9% Uptime, etc.)? *(R-17)*
- [ ] Are there any fictional testimonials (AI avatars, random names or job titles)? *(R-18)*
- [ ] Were any visual assets (logo, avatar/profile photo, statistics, testimonials, or navigation structure) created without explicit instructions or confirmation, and without an honest placeholder? *(R-23)*
- [ ] Are there navbar links pointing to sections or pages that do not exist? *(R-24)*
- [ ] Is there any text with contrast below the WCAG AA standard (4.5:1 for normal text, 3:1 for large text)? *(R-25)*
- [ ] Are there any buttons, dropdowns, or forms that do nothing, with no real behavior and no `// TODO` + visible label? *(R-26)*
- [ ] Does the UI lack an empty state, loading state, or error state? *(R-27)*
- [ ] Does the FAQ contain generic questions that are not relevant to the product? *(R-28)*
- [ ] Can the UI not be navigated by keyboard (Tab, Enter, Escape) or is there no visible focus state? *(R-32)*
- [ ] Was any feature added by patching source/CSS with an external script instead of writing it in source? *(R-33)*
- [ ] If a theme toggle exists, does one mode (light or dark) break styles, fonts, or layout? *(R-34)*
- [ ] Was the app delivered without being run or built, or without a recorded click-through of every interactive element? *(R-35)*
- [ ] Are there any fabricated security, compliance, performance, or customer claims? *(R-36)*
- [ ] Was the design built without direction and not labeled *"draft without direction"* with honest default dials ENERGY 1 / RHYTHM 1 / MOTION 1? *(R-37)*
- [ ] Is there any realistically-styled content that was fabricated (testimonials, features, statistics, ghost links, fictional team) without a real source? *(R-38)*
- [ ] Does any control lack `cursor: pointer`, a native element, an accessible name, or hover/active/disabled states; any field a visible label or image its `alt`; does motion ignore `prefers-reduced-motion` or run longer than 5 seconds without a pause control; does ARIA contradict the native role; or does a whole document lack `lang`, `<title>`, or landmarks, or block zoom? *(R-39)*
- [ ] Does any media element ship without dimensions, any late content without reserved space, the hero image load lazily or without `fetchpriority="high"`, a third-party script block render in `<head>`, or a performance number get reported that was not measured? *(R-40)*

### Block 2: Purpose-Gate (technique allowed, reason required)

For each technique, the technique itself is allowed. FAIL if it appears as a default without purpose, or if the reason is not written down:

- [ ] Do gradients/glows appear as a default with no stated hierarchy or brand purpose? *(R-01)*
- [ ] Are there generic icons (sparkle, star, magic, lightning, diamond, robot, orb), an icon set picked for its library look (Lucide-style), or icons irrelevant to their content, with no written relevance? *(R-04)*
- [ ] Is there a large monospace font, uppercase label with wide tracking, or a typeface chosen without a written brand-character reason? *(R-06)*
- [ ] Is there a background grid, blueprint, graph paper, or dot pattern without a written visual-identity purpose? *(R-07)*
- [ ] Are arrows (`→` / `↗`) placed on almost every button purely as decoration, with no written purpose? *(R-08)*
- [ ] Are there capsule badges ("AI Powered", "Beta", "New", "Secure", "Fast") with no real function, the full capsule + thin border + glow + uppercase combination, or a pill parked above the H1 holding a label the headline already says? *(R-09)*
- [ ] Is glassmorphism applied to more than 1-2 elements simultaneously (navbar + card + modal + sidebar)? *(R-10)*
- [ ] Is a large shadow applied to every component, with no written elevation reason, making the page feel like it is floating? *(R-12)*
- [ ] Is glow applied to cards, buttons, badges, icons, backgrounds, and borders simultaneously? *(R-13)*
- [ ] Do all feature cards have identical size, icon, padding, and layout, with no written hierarchy reason? *(R-14)*
- [ ] Do all elements use template animations simultaneously (Fade Up + Floating + Scale + Bounce) without a written UX purpose, or does the motion contradict the declared MOTION dial? *(R-19)*
- [ ] Are there generic illustrations (Undraw, Storyset, 3D blob) with no written product connection? *(R-22)*

### Block 3: Liveliness (required to be alive, not just clean)

All answers must be **yes**:

- [ ] Are the dials set and explicit (ENERGY / RHYTHM / MOTION declared)?
- [ ] Is the output consistent with the claimed dials? (RHYTHM 3 but uniform sections = FAIL)
- [ ] Is there at least one clear focal point per screen?
- [ ] Is whitespace structural (used to separate and set rhythm), not leftover?
- [ ] Is there one deliberate accent (not zero, not everywhere)?
- [ ] Is there an identity motif (one specific, repeated pattern, gesture, or typographic voice)?
- [ ] Was a Design Read declared before generation?

### Block 4: Craftsmanship & Quality Locks

All answers must be **no**:

- [ ] C-1: Is there any visual or copy decision whose only justification is "it's the AI default"? *(Intentionality)*
- [ ] C-2: Does any interactive element do nothing, with no clear label? *(Functional Completeness)*
- [ ] C-3: Does any section exist only to fill an AI template, not to serve the product's content? *(Content-Driven Composition)*
- [ ] C-4: Does the UI break in any state, theme, breakpoint, or without a mouse? *(Resilience)*
- [ ] C-5: Is any testimonial, statistic, or claim fabricated? *(Evidence Over Claims)*
- [ ] Does the layout follow an AI template (generic Hero+cards, "How It Works" always 3 steps, "Trusted By" logo bar, bento-grid mosaic, fake terminal window, 3 pricing columns, 4-column footer with no variation, uniform section rhythm), or does the section rhythm contradict the declared RHYTHM dial? *(R-05)*
- [ ] Are all elements (buttons, cards, inputs, badges) made pill-shaped with no radius variation? *(R-11)*
- [ ] Are CTAs still generic (Get Started, Learn More, Try Now, Explore, Discover)? *(R-15)*
- [ ] Are there any AI marketing buzzwords (AI Powered, Seamless, Revolutionary, Cutting Edge, etc.)? *(R-16)*
- [ ] Does the design still feel generic even if the logo and product name are swapped? *(R-20)*
- [ ] Was dark mode forced as a default without a branding/user reason, or was a required light/dark toggle deferred with an excuse? *(R-21)*
- [ ] Does the color palette exceed 2-3 core colors + 1 accent without a clear design system? *(R-29)*
- [ ] Does the overall design look like a clone of another popular product (Linear, Vercel, Stripe, Notion, etc.)? *(R-30)*
- [ ] Is there any major visual decision (color, layout, typography, spacing, cards, illustration) whose reason cannot be written in one line? *(R-31)*

If even one answer is **yes** (or **no** in Block 3), do not deliver. Fix it, re-run the gate, and only then ship. Delivery without a clean gate is a failure.

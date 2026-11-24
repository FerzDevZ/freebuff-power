
The edit is also checked against the current file (a regular file of at
most 1 MiB, read by the hook and never stored): `old_string` must be found as
the Edit tool would apply it, the lines around the change must compare equal
as above, and the text before them must end in plain code, not inside a
template literal, docstring, raw string, heredoc or here-string and not after
a line continuation. A missing, unreadable or larger file, or a Go file that
imports `"C"`, never passes this way.

### Same-turn sibling creation collapse

When several new files are created in one directory, the answers for each
would be identical, so only the first is denied:

- Applies to a **Write of a file that does not exist yet** whose class is
  `code`, `test`, or `prose`. Never collapsed: `config` and `instruction`
  files, and any path with a segment starting with `.` (dotfiles and every
  dot-directory: `.claude`, `.github`, `.git`, `.husky`, `.devcontainer`,
  `.githooks`, `.idea`, `.vscode`, …) or an 8.3 short name (`CLAUDE~1`),
  checked on the same project-relative path as the class.
- The directory is also resolved to its **real location** (symlinks
  followed; missing directories are resolved from the nearest existing
  parent). If that differs from the path as written, the real path must be
  inside the project, keep the same class, and pass the same screen, so a
  symlink such as `src/tools -> .claude/hooks` never collapses. Gates are
  keyed by the real directory. Any filesystem error means no collapse.
- After such a Write is denied, later first-touch Writes of new files **of the
  same class in the same directory** are allowed with the note "Sibling of
  `<first>` (gated earlier at denial #`<n>` this session)". A code denial never
  lets a test, README, or config file through.
- The window is the **same human turn**. The turn id is the turn-start
  record's own `promptId`, else its `uuid`, else a hash of that record. When
  the turn started before the transcript tail, the id is the `promptId` that
  every user record in the window agrees on (Claude Code stamps it on the
  prompt and on every tool result of the turn); if they disagree there is no
  turn id. Only when **no transcript path is available at all** does a gate
  recorded without a turn id match for **120 seconds**; a transcript that is
  missing, unreadable, or yields no turn id means no collapse. A turn-scoped
  gate never matches a call without a turn id, and vice versa; a gate stamped
  in the future is ignored.
- Prior-search credit is checked first. **Edits and MultiEdits are never
  collapsed**, and an existing file is never treated as a sibling.

### Canonical path keys

Checked state is keyed on the canonical path: a relative `file_path` resolves
against the tool's `cwd` (where the tool runs), then `CLAUDE_PROJECT_DIR`,
then the process directory, with `/` separators, lowercased on Windows only.
`a.py`, `./a.py`, and the absolute path share one first-touch. State files
written by earlier versions (raw keys) are still honoured.
`GATEGUARD_EXEMPT_GLOBS` keeps its project-relative matching (below).

### In-session counters

The per-session state file (under `GATEGUARD_STATE_DIR`) records these fields.
They record class names only, never paths (except `dir_gates`, which stores
the sanitized first file per directory):

| Field | Meaning |
|---|---|
| `fact_force_credited` | Number of first touches allowed by prior-search credit |
| `denials_by_class` | Denials per target class (`code`, `prose`, `test`, …) |
| `credited_by_class` | Credits per target class |
| `sibling_allows` | Number of Writes allowed by sibling collapse |
| `dir_gates` | Per class and directory, the denial that opened a sibling window (turn, time, first file, ordinal); capped at 50 entries |
| `cap_allows` | Number of first touches passed through by the denial cap (`GATEGUARD_FACT_FORCE_MAX_DENIALS`); these never count as denials |
| `trivial_allows` | Number of comment or whitespace-only edits passed without the first-touch check; these never mark the file checked |
| `routine_readonly_passes` | Number of read-only shell commands passed before the routine shell gate fired; these never mark it checked |

Missing or malformed fields load as empty or zero, so older state files keep
working.

### Compatibility and limits

- **Two new, opt-in environment variables:**
  `GATEGUARD_FACT_FORCE_MAX_DENIALS` (unset means no cap) and
  `GATEGUARD_METRICS` (unset means no metrics). The existing controls are
  unchanged.
- **Nothing previously allowed is now denied**, except a subagent's first
  touch of a sensitive or hard-linked target, and the first NotebookEdit of
  each notebook (NotebookEdit was not gated before). The other rules only
  remove denials, and never return `permissionDecision: "allow"`, so other hooks
  and permission rules still apply.
- **Trust limit:** prior-search credit reads the local transcript file,
  which the agent could in principle write to. The credit verifies observed
  behaviour (a search ran and returned), not intent or how carefully the
  result was read.

## Quick Start

### Option A: Use the ECC hook (zero install)

The hook at `scripts/hooks/gateguard-fact-force.js` is included in this plugin. Enable it via hooks.json.

If GateGuard blocks setup or repair work, start the session with
`ECC_GATEGUARD=off`. For hook-level control, keep using
`ECC_DISABLED_HOOKS` with the GateGuard hook ID.

In long sessions, only the first `GATEGUARD_FACT_FORCE_FULL_DENIALS`
fact-force denials (default 3) emit the full fact block; later
denials are condensed to a single line carrying the denial ordinal, so
near-identical blocks cannot accumulate in the context window and
amplify model repetition loops (#2142). Retrying the same file or
command after presenting facts never re-triggers the gate. That is a
message budget; to stop denying new files after a number of denials, set
the opt-in denial budget `GATEGUARD_FACT_FORCE_MAX_DENIALS` (below).

#### Graduated controls

`ECC_GATEGUARD=off` (or `GATEGUARD_DISABLED=1`) turns the gate off entirely.
The variables in this table do **not** — each narrows one behaviour while the
load-bearing destructive-Bash checks keep running:

| Variable | Default | Effect |
|---|---|---|
| `GATEGUARD_BASH_ROUTINE_DISABLED` | unset (gate on) | Disables the **routine-Bash** gate only. The destructive-Bash gate (`rm -rf`, `git reset --hard`, `drop table`, `dd if=`, …) is unaffected. |
| `GATEGUARD_EXEMPT_GLOBS` | unset (no exemptions) | Comma-separated globs; a matching Edit/Write/MultiEdit/NotebookEdit target skips first-touch fact-forcing, even when it is sensitive or hard-linked. Intended for low-import-value trees (tests, generated artifacts, scratch dirs) where "who imports this / what schema" carries no signal. |
| `GATEGUARD_FACT_FORCE_FULL_DENIALS` | `3` | How many denials emit the full fact block before later ones condense to a single line. `0` condenses from the very first denial. |
| `GATEGUARD_FACT_FORCE_MAX_DENIALS` | unset (no cap) | A **denial budget**: caps how many first-touch Edit/Write/MultiEdit/NotebookEdit denials a session draws. Once that many denials have been issued, further new paths pass through instead of being denied (counted in `cap_allows`, not as denials); `0` passes from the first. Prior-search credit and sibling collapse run first and never use it up, and [sensitive](#sensitive-targets) and [hard-linked](#hard-linked-targets) targets are always denied. Destructive and routine Bash stay gated. The cap is best effort when hooks run concurrently: a lost count update can add a denial, but never lets a new path through early. Opt-in: unset, or any value that is not a whole non-negative integer (surrounding spaces allowed), keeps the deny-every-new-path behaviour; a malformed value is reported once on stderr (`ignoring malformed GATEGUARD_FACT_FORCE_MAX_DENIALS=…; the denial cap is not active.`). Unlike `GATEGUARD_FACT_FORCE_FULL_DENIALS`, a **message budget** that only changes how much text a denial carries, this changes whether the operation is blocked. Condensed denials name this variable. |
| `GATEGUARD_BASH_EXTRA_DESTRUCTIVE` | unset | Extra destructive-command patterns, as regex source, added to the built-in set. A malformed regex is treated as unset (built-ins still apply) and logged once to stderr. |
| `GATEGUARD_STATE_DIR` | `~/.gateguard` | Where per-session gate state is kept. If state cannot be persisted the gate allows the operation rather than looping, and names this variable in the warning. |
| `GATEGUARD_METRICS` | unset (off) | Records one line per Edit/Write/MultiEdit/NotebookEdit/Bash/PowerShell decision in `<GATEGUARD_STATE_DIR>/metrics.jsonl` (see [Decision metrics](#decision-metrics)). Never changes a decision. |
| `GATEGUARD_EXTERNAL_CONTRACT_QUESTION` | unset (off) | Adds a code question after the data-schema question: name what outside the repository decides the format, units, timezone or protocol semantics. Experimental: in hidden-intent trials it did not change outcomes (`docs/gateguard/question-effectiveness.md`). Never changes a decision. |

`GATEGUARD_BASH_ROUTINE_DISABLED`, `GATEGUARD_METRICS` and
`GATEGUARD_EXTERNAL_CONTRACT_QUESTION` accept `1`, `true`, `on`, `enabled`,
`enable`, or `yes` (case- and whitespace-insensitive); any other value leaves
the routine gate on, metrics off, and the question unasked.

#### Decision metrics

With `GATEGUARD_METRICS=1`, each gate decision appends one JSON line to
`metrics.jsonl` in the state directory (a MultiEdit call writes one line per
file it decided):

```json
{"v":1,"ts":"2026-09-01T10:02:00.000Z","session":"3f9c0a1b2d4e","tool":"Edit","class":"code","decision":"deny","reason":"near-miss:out-of-scope","questions":["local-callers","quote-instruction"],"sensitive":false,"profile":{"known":true,"language":"js","touchesPublicSurface":false,"touchesData":false,"trivial":false}}
```

| Field | Meaning |
|---|---|
| `v` | Schema version (`1`) |
| `session` | First 12 hex characters of the sha256 of the session key |
| `tool` | `Edit`, `Write`, `MultiEdit`, `NotebookEdit`, `Bash` or `PowerShell` |
| `class` | Target class, or `null` for shell commands |
| `decision` | `deny`, `credit`, `sibling`, `cap`, `trivial`, `pass-checked`, `pass-exempt`, `pass-subagent`, `routine-deny`, `routine-readonly`, `destructive-deny` or `pass` |
| `reason` | Short code: `first-touch`, `sensitive`, `hard-linked`, `near-miss:<code>`, `subagent-sensitive`, `subagent-hard-linked`, `prior-search`, `comment-whitespace`, `same-turn-dir`, `max-denials`, `checked`, `exempt-glob`, `claude-settings`, `no-path`, `subagent`, `readonly-git`, `readonly`, `first-command`, `routine-checked`, `routine-disabled`, `destructive`, `destructive-retry`, `state-error` |
| `questions` | Question ids of a first-touch denial; `null` otherwise |
| `sensitive` | Whether the target is a [sensitive target](#sensitive-targets) |
| `profile` | Change-profile flags when the profile was computed; `null` otherwise |

**Privacy:** lines never contain paths, commands, file content, transcript
text or the session id itself; every text field must be a short lowercase
code or is written as `null`. Metrics errors are ignored. Past 1 MiB the file
is renamed to `metrics.jsonl.1`, replacing the previous one.

Summarise the metrics with:

```bash
node scripts/gateguard-report.js            # GATEGUARD_STATE_DIR or ~/.gateguard
node scripts/gateguard-report.js --dir /path/to/state --json
```

It reads `metrics.jsonl.1` then `metrics.jsonl`, skips malformed lines, and
prints, per session and in total: decisions by type, denials by class and
reason, the share of first-touch denials that followed a near-miss search,
the rates of denial, credit, sibling collapse, cap and trivial edits among
first touches, routine read-only passes, and the most-asked question ids.

#### Turning the gate off completely

| Variable | Effect |
|---|---|
| `ECC_GATEGUARD=off` | Disables GateGuard for the session. Accepts `0`, `false`, `off`, `disabled`, or `disable`. |
| `GATEGUARD_DISABLED=1` | Same effect. Recognises `1` only — the spellings above do **not** apply here. |

For hook-level control, keep using `ECC_DISABLED_HOOKS` with the GateGuard hook ID.

#### Glob semantics for `GATEGUARD_EXEMPT_GLOBS`

Patterns match the entire project-relative target path. The project root is
`CLAUDE_PROJECT_DIR`, falling back to the hook payload's `cwd`, then the hook
process working directory. Relative globs never exempt targets outside that
root. Explicit absolute globs match the entire absolute target path and may
deliberately exempt paths outside the project.

Both patterns and paths use `/` separators and lowercase matching. `*` matches
within a segment, `**` across segments, and `?` one non-separator character.
`**/` includes zero directories, so `**/tests/**` also matches `tests/foo.js`.
Malformed patterns are dropped without granting an exemption.
An exemption applies before every other rule, including the sensitive and
hard-link rules (see [Order of checks](#order-of-checks)).

Since 2.2.1, `services/**` only covers the project's root services tree, and
`*.md` only covers its root Markdown files. Use `**/*.md` for all Markdown
files within the project. Existing unanchored exemptions may need adjustment:

```json
{
  "env": {
    "GATEGUARD_BASH_ROUTINE_DISABLED": "1",
    "GATEGUARD_EXEMPT_GLOBS": "**/tests/**,tests/**,**/*.test.*,**/docs/**,**/dist/**"
  }
}
```

### Option B: Full package with config

```bash
pip install gateguard-ai
gateguard init
```

This adds `.gateguard.yml` for per-project configuration (custom messages, ignore paths, gate toggles).

## Anti-Patterns

- **Don't use self-evaluation instead.** "Are you sure?" always gets "yes." This is experimentally verified.
- **Don't skip the data schema check.** Both A/B test agents assumed ISO-8601 dates when real data used `%Y/%m/%d %H:%M`. Checking data structure (with redacted values) prevents this entire class of bugs.
- **Don't gate every single Bash command.** Routine bash gates once per session. Destructive bash gates every time. This balance avoids slowdown while catching real risks.

## Best Practices

- Let the gate fire naturally. Don't try to pre-answer the gate questions — the investigation itself is what improves quality. A real search for the target before editing is investigation, and is credited (see [What Counts as Already Done](#what-counts-as-already-done)).
- Customize gate messages for your domain. If your project has specific conventions, add them to the gate prompts.
- Use `.gateguard.yml` to ignore paths like `.venv/`, `node_modules/`, `.git/`.

## Related Skills

- `safety-guard` — Runtime safety checks (complementary, not overlapping)
- `code-reviewer` — Post-edit review (GateGuard is pre-edit investigation)

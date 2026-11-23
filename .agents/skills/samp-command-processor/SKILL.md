---
name: samp-command-processor
description: Command architecture for SA-MP and open.mp Pawn code — funcidx-based dispatch without string ladders, permission levels, per-command cooldowns, anti-spam, alias/prefix handling, and the tradeoffs between Pawn.CMD, YSI y_commands, ZCMD, I_Commands and a dependency-free dispatcher. Ships a compile-verified dispatcher include with demos.
---

# Command Processor (SA-MP / open.mp)

Every player action in a Pawn gamemode enters through `OnPlayerCommandText` or a
dialog. Command handling is therefore the hottest string path on the server and
the easiest place to put a privilege bug.

The compile-verified include in `resources/samp_cmd.inc` is the baseline this
skill teaches. It needs no plugins, no YSI, and builds on both include sets.

---

## 1. Pick a dispatcher, deliberately

| Option | Dispatch | Strength | Cost |
|---|---|---|---|
| `strcmp` ladder in `OnPlayerCommandText` | linear compares | zero dependency | O(n) per command, no levels/cooldowns, grows into a 400-line function |
| `ZCMD` | `CMD:` macro + `Command_Add` | tiny, widely known | legacy, no metadata, no hooks integration |
| `Pawn.CMD` | `CMD:` + hash lookup | fast, aliases, permissions | third-party include; pin the version in `pawn.json` |
| YSI `y_commands` | `YCMD:` + `Command_Add` | groups, per-player groups, help generation | pulls in YSI, macro-heavy, conflicts with other hooks if misused |
| `samp_cmd.inc` (here) | `funcidx` lookup + `CallLocalFunction` | dependency-free, levels + cooldowns + block flag | one public function per command, no help text generation |
| open.mp components with C++ | native registration | fastest, real types | you now maintain a plugin |

Rule: do not mix two dispatchers in one gamemode. Two owners of
`OnPlayerCommandText` means one of them silently never runs.

## 2. The dispatcher contract

```pawn
COMMAND:heal(playerid, params[])          // public cmd_heal(playerid, params[])
{
    new amount = params[0] ? strval(params) : 100;
    SetPlayerHealth(playerid, float(amount > 100 ? 100 : amount));
    return 1;
}

public OnGameModeInit()
{
    CMD_Register("heal", 0, 500);   // name, required level, cooldown ms
    CMD_Register("setlevel", 3, 0);
    return 1;
}
```

`CMD_Register` only attaches metadata (level + cooldown). Dispatch works from
the public function alone, so a forgotten registration degrades to level 0 and
the default cooldown instead of a dead command.

Resolution order in `CMD_OnCommand`: connected player → sanitized name →
`funcidx("cmd_<name>")` → block flag → level → cooldown → `CallLocalFunction`.

## 3. Security rules that matter more than speed

1. **Never trust `params` as a format string.** `format(buf, sizeof buf, params)`
   with user input is a server crash / log injection. Use `format(buf, size, "%s", params)`.
2. **Sanitize the command name**, not just the whole line: allow `[a-z0-9_]`.
   The include lowercases and truncates at the first other byte, which also makes
   `/HEAL` and `/heal` the same command without extra code.
3. **Level checks belong in one place.** A command that checks admin inside its
   body will eventually ship one that forgets. Registry level is checked before
   the function is called.
4. **Reset per-player state on connect and disconnect.** A recycled player slot
   must not inherit level, block flag, or last-command clock. `CMD_ResetPlayer`.
5. **Rate-limit expensive commands** (teleport, spawn vehicle, give money) with a
   cooldown of 500–2000 ms, and a global block flag for repeat offenders.
6. **Log admin commands** with player, command, params, and tick. "Who ran
   `/setmoney`" must be answerable from the log, not from memory.

## 4. Cooldown semantics worth knowing

- Cooldown is measured from the **last successful dispatch of the same command
  by the same player**, not from a global clock. Different commands do not
  starve each other.
- The include keeps one `lastIndex/lastTick` pair per player; alternating two
  commands bypasses a per-command cooldown only for the pair, which is why
  expensive actions also need an authoritative cost check (balance, cooldown
  table, or a global player block).
- Never implement cooldowns with a repeating `SetTimer` per command per player;
  that is thousands of timers. Store a tick.
- `GetTickCount()` wraps on a 32-bit cell; compare with subtraction
  (`tick - last < cooldown`), never `tick > last + cooldown`.

## 5. Params parsing without sscanf

When the project already uses `sscanf2`, use it — it is the standard and handles
optional params, floats and enums cleanly. For the dispatcher's own baseline:

```pawn
new targetid, amount;
if (sscanf(params, "ui", targetid, amount)) return SendClientMessage(playerid, -1, "Usage: /pay <id> <amount>");
```

Without sscanf, `strval` + `strtok`-style splitting is acceptable for one-arg
commands only; everything else should add the dependency rather than grow
hand-written parsing.

## 6. Adversarial corpus (executed)

`resources/demo_cmd_adversarial.pwn` runs against `samp_cmd.inc` on a real server
(39 assertions) covering what a headless server can reach:

- name normalisation through the public registry: `Heal`/`heal`/`heal!`/`heal%n`
  all land in one slot, punctuation-only and empty names are refused;
- truncation: a 40-character name and its 31-character prefix share a slot;
- rejection paths: no leading `/`, bare `/`, `/!!!`, unknown command, negative or
  out-of-range player, disconnected player, 100-character command name;
- parameter delivery: quotes, `%s`/`%n`/colour codes passed through untouched,
  200-character parameters truncated and still terminated;
- registry capacity: registration stops at `CMD_MAX_REGISTERED` and returns `-1`
  past it, without corrupting earlier entries.

The dispatcher's happy path (`CallLocalFunction` on a connected player) is **not**
covered here because it needs a real client; do not read a green suite as proof
that dispatch itself works end to end.

## 7. Gate before shipping a command

```bash
# 1. fixtures must build with zero warnings on both targets
pawncc resources/demo_commands_omp.pwn -i"$OMP_INCLUDE" -d3 -o/tmp/c.amx
pawncc resources/demo_commands.pwn -i"$LEGACY_STDLIB" -i"$OMP_INCLUDE" -d3 -o/tmp/c2.amx

# 2. no second owner of OnPlayerCommandText
grep -rn "OnPlayerCommandText" --include=*.pwn --include=*.inc .
```

Checklist:
- [ ] exactly one dispatcher owns `OnPlayerCommandText`
- [ ] every privileged command is registered with a level
- [ ] every money/item/teleport command has a cooldown
- [ ] `CMD_ResetPlayer` called on connect and disconnect
- [ ] no `format(..., params)` with raw input
- [ ] admin commands write an audit line

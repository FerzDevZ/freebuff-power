# bin/ — repo tooling

| Script | Purpose |
|---|---|
| `self-test.sh` | The repo gate (28 checks): Pawn fixtures on both targets, TD/YSI/HUD examples, Node tooling, runtime suite, parity matrix. Run with `./bin/self-test.sh`. |
| `ysi-ensure.sh` | Install YSI 5 + amx_assembly via `sampctl get` when missing (`--global` for shared cache, `--no-patch` to skip). Idempotent. |
| `ysi-linux-patch.sh` | Rewrite YSI's backslash includes into `.sdk/ysi`, fetch deps, flatten them, and compile a probe (`--verify`). |
| `samp-detect.js` | Target verdict for a Pawn file (open.mp vs legacy). |
| `samp-audit.sh` | Anti-pattern audit v2. |
| `samp-lint.js` | Security lint. |
| `samp-td-preview.js` | 16:9 HTML render of PlayerTextDraws (fails on 0 parsed elements). |
| `samp-map-upgrade.js` | `CreateObject` → dynamic + `Streamer_UpdateEx`. |
| `samp-heal.sh` | Compile → fix loop. |
| `samp-claim-audit.js` | Native claim audit against the parity matrix. |
| `samp-agent-evals.js` | Decision evals (toolchain or graded answers). |
| `agents-ref-check.js` | Validates every `@agent`, skill and `bin/*` reference in `AGENTS.md`. |

All scripts are invoked from the repo root. `sampctl` and `pawncc` are required for the Pawn gates; missing toolchains skip loudly (never silently pass).

## Dual-target example gates (YSI + HUD)

`bin/self-test.sh` (checks 28+) compiles two official examples on **both** targets with 0 warnings and a non-empty `.amx`. They are gated explicitly because the fixture loop excuses `<open.mp>`-only files:

| Example | Path | Legacy incs | open.mp incs | Notes |
|---|---|---|---|---|
| YSI modules | `.agents/skills/samp-ysi-framework/resources/example_ysi_modules.pwn` | `-i<dir> -i.sdk/ysi -i<amx_assembly> -i/tmp/sampstdlib -i$OMP_STDLIB -d3 '-;+'` | `-i<dir> -i.sdk/ysi -i<amx_assembly> -i$OMP_STDLIB -d3 '-;+'` | needs YSI + amx_assembly; `'-;+'` avoids warning 237 |
| HUD overlay | `.agents/skills/samp-textdraw-ui-craft/resources/example_hud_overlay.pwn` | `-i<dir> -i/tmp/sampstdlib -i$OMP_STDLIB -d3` | `-i<dir> -i$OMP_STDLIB -d3` | no YSI dependency |

Skip behaviour (never silent pass):
- YSI example: skipped with `SKIP:` if YSI/amx_assembly or either stdlib is missing.
- HUD example: skipped with `SKIP:` if either stdlib is missing.
- Missing toolchain (`pawncc`/`sampctl`) is reported loudly; the gate never turns a skip into green.

# tmux lanes - unattended Claude Code sessions that close themselves

The rest of this kit is one person, one AI session, one terminal. This folder is the next step for a
technical user: hand a **card** (one job, one file) to a Claude Code session that runs **unattended in its
own tmux session**. When the job is done, the session tells a watcher. The watcher checks that the
promised files really exist, types `/exit` into it, and the empty session is cleaned up. You launch
and walk away. Nothing to babysit, no pile of dead windows at the end of the day.

It is a simplified port of a larger personal setup that runs lanes like this every day. It is
**proven, but rough in the corners**: the loop below ran end to end on a real machine (`selftest.ps1`
PASS, including with Claude's strict `default` permission mode), but it is plain PowerShell you are
expected to read and fix. `ARCHITECTURE.md` explains what was left out and why.

```
card.md --lane-launch--> tmux session "<lane>"          lane-watch (its own session)
                          window 0: shell               every 30 s: read <state>\done\*.done
                          window 1: claude <- card        -> DONE-WHEN files all there?
                                       |                       no  -> HELD, send nothing
                          last step: declare-done ------>      yes -> wait idle, send /exit
                                       |
                          claude exits -> reap-husk kills the now-empty session
```

---

## What's in this folder

| File | Purpose |
|---|---|
| `scripts\lane-launch.ps1` | Start one card as one lane: its own session, window 0 a shell, window 1 Claude. Refuses a card without a Done-when path, a finished card, or a session name already in use. |
| `scripts\declare-done.ps1` | The lane's own "I'm finished" signal. The one and only done-signal; done is never guessed from idle time or a timer. |
| `scripts\lane-watch.ps1` | The close watcher. Checks each declaration against the card's Done-when paths and sends `/exit` only when they all exist. |
| `scripts\done-when.ps1` | Reads a card's Done-when block and checks the paths. Used by the launcher and the watcher. |
| `scripts\reap-husk.ps1` | Kills a session left with nothing but idle shells. Never touches a session with anything running in it. |
| `scripts\selftest.ps1` | Proves the whole loop on your machine in about a minute. |
| `templates\card-template.md` | The card shape (same headings as the kit's `templates\card.md`). |
| `ARCHITECTURE.md` | How the pieces fit, what the owner's bigger version adds, and extensions (queues, night runs, RAM guard). |

Every script has a header comment, parameters at the top, and `-DryRun` (a no-op in `done-when.ps1`, which never
writes). They are all PowerShell 5.1, ASCII only.

**Names.** Lanes are tmux sessions named `lane-<card file name>` by default (override with `-Session`), so
everything you launch shares the prefix `lane-`. `reap-husk.ps1 -Prefix lane-` sweeps them. Give the
watcher and anything else a name that does NOT start with `lane-` (e.g. `lanewatch`).

---

## Prerequisites

1. **Windows 11 + PowerShell 5.1** (the built-in `powershell.exe`).
2. **psmux** (tmux for Windows, provides `tmux.exe`): `winget install marlocarlo.psmux`. Open a NEW
   terminal afterwards so `tmux` is on PATH, then check `tmux -V` (tested on `psmux 3.3.8`).
3. **Claude Code** via the kit's own installer, run from the kit's top folder (`ai-starter-kit\`):
   `powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool claude` (or `irm https://claude.ai/install.ps1 | iex`).
   Tested on Claude Code `2.1.283`.
4. **Log in once, interactively.** Run `claude` in a normal terminal and finish the login. Lanes reuse it.
5. **Answer first-run dialogs once per lane folder.** The folder a lane works in is its `-WorkDir` (e.g.
   `C:\work`), not this kit folder. The first time Claude runs there it may ask whether to trust it (or
   whether to allow external CLAUDE.md imports). A lane cannot answer, so run `claude` in that folder
   by hand once and answer. The self-test uses `%TEMP%\tmux-lanes\selftest` and tells you if it hits one.

---

## Quickstart

From a normal PowerShell window (NOT from inside a Claude session; see Troubleshooting), in this
folder (`advanced\tmux-lanes\`). Before step 3, write your card: copy `templates\card-template.md` to
e.g. `C:\work\cards\my-card.md` and fill it in (see [Card format](#card-format); the Done-when path is required).

```powershell
cd scripts
powershell -NoProfile -ExecutionPolicy Bypass -File .\selftest.ps1                                   # 1. prove it: expect SELFTEST PASS
powershell -NoProfile -ExecutionPolicy Bypass -File .\lane-watch.ps1 -DetachAs lanewatch             # 2. start the watcher in its own session
powershell -NoProfile -ExecutionPolicy Bypass -File .\lane-launch.ps1 -Card C:\work\cards\my-card.md -Model sonnet -Effort medium -WorkDir C:\work   # 3. launch a card
tmux attach -t lane-my-card                                                                           # 4. (optional) watch it; detach with Ctrl-b then d
```

`-Model` and `-Effort` are required and passed straight to `claude --model / --effort`: a model alias
(`sonnet`, `opus`, `haiku`) or a full model id, and `low` / `medium` / `high` / `xhigh` / `max`.

The self-test launches a throwaway lane (session `lanetest-selftest`) in `%TEMP%\tmux-lanes\selftest`
on Sonnet at low effort, and prints six checks, the log lines and `SELFTEST PASS` / `SELFTEST FAIL`.
It keeps its own state (and log) in `%TEMP%\tmux-lanes\selftest\state\`, separate from real lanes.
Add `-PermissionMode default` to prove it without any auto-approve mode you may have configured. It starts
Claude with `--setting-sources project --strict-mcp-config --no-chrome` (ignore your user-level settings,
MCP servers and the Chrome extension) so the test does not depend on your personal setup. Real lanes don't
need those flags. Add them through `-ClaudeArgs` if you want the same isolation.

Stop the watcher: `New-Item "$env:TEMP\tmux-lanes\STOP"` (it removes the file and exits on its next tick).
Sweep leftover husks by hand: `.\reap-husk.ps1 -Prefix lane- -DryRun`, then again without `-DryRun`.

**Permissions.** A lane runs with nobody watching, so a permission prompt stalls it forever. The
launcher always allows the one command every lane needs (its own `declare-done.ps1`). Everything
else is your call, through `-ClaudeArgs`:
- scoped allow rules, for example `-ClaudeArgs '--allowedTools','Edit(./**)','Bash(npm test:*)'` (the
  self-test uses just `Edit(./**)`: write files inside the lane folder). File rules must be `Edit(...)`
  (it covers Write too); a `Write(...)` rule is ignored.
- or a looser mode such as `-ClaudeArgs '--permission-mode','acceptEdits'`.
The kit does not ship a permission-skipping default. Choose one on purpose.

State lives in `%TEMP%\tmux-lanes\` (`done\` declarations, `done\closed\` archive, `lanes.log`,
`launch\` per-lane launch files). Every script takes `-StateDir` to move it; use the same one everywhere.
(The self-test is the one exception on purpose: it uses its own state folder, above.)

---

## Card format

A card is a Markdown file. `lane-launch.ps1` gives the lane one first message: *"Read <card> and do what
it says. As your very last step, once every file under its DONE-WHEN heading exists, run
`& '<...>\declare-done.ps1'`."* Start from `templates\card-template.md`. The one heading the scripts
parse is the Done-when block:

- Heading: `## Done when` or `## DONE-WHEN` (any level, `#` to `######`). The block ends at the next heading.
- One **absolute** path per line: `C:\...` or `~\...` (your profile folder); `/` works as well as `\`. Bare or in backticks,
  optionally followed by ` -- a comment`. `-`/`*` bullets are fine. `<!-- -->` comments are skipped.
- **Done** = every path exists and no file is 0 bytes. A relative path or placeholder counts as missing,
  forever. That is deliberate: a card that can never be satisfied should look stuck, not done.
- No Done-when path -> `lane-launch` refuses the card. All paths already there -> refuses it as already
  done (delete or move the old output to re-run).
- Check a card yourself: `.\done-when.ps1 -Card <card> -ParseOnly` (what it declares), then without
  `-ParseOnly` (PRESENT/MISSING per path; exit 0 done, 1 no block, 2 missing).

The other headings (Status, Goal, Read only, Do, Stop line, Close) are for the model, not the scripts.
Write the Stop line for an unattended run: "write what you found into the Done-when file and stop",
never "ask me".

---

## Troubleshooting

Each entry: **symptom** -> fix.

- **Text typed into a Claude pane but never submitted.** One `send-keys` call with text plus `Enter`
  submits up to 62 characters and silently fails from 63 (Claude reads it as a paste). -> Send the
  text with `send-keys -t s:1 -l -- "<text>"`, then `send-keys -t s:1 Enter` as a SEPARATE call. `Enter`
  and `C-m` are the same byte; switching them fixes nothing.
- **A command hit the wrong window after a rename.** -> Target windows by index (`session:1`), never
  by name. Names change; the lane window is always index 1 here.
- **Two lanes fighting over one session, or a lane closed with its neighbour.** -> One session per
  lane. `lane-launch` refuses an existing session name; pick another `-Session`.
- **`/exit` (or any slash command) sent, nothing happened.** A slash command typed into a BUSY pane is
  dropped, not queued. -> Only send when the pane is idle (the watcher waits for a bare `❯` prompt line
  and no "esc to interrupt"). Plain text does queue; slash commands don't.
- **A check says a window exists but it is gone.** `tmux list-windows -t s:w` exits 0 even for a
  missing window. -> List the session (`list-windows -t s -F '#{window_index}'`) and look for the
  index, or use `has-session`, which does return nonzero.
- **`/exit` arrives as `C:/Program Files/Git/exit`.** Git Bash (MSYS) rewrites any argument that
  starts with `/`. -> Drive tmux from PowerShell only. If you must use Bash: `MSYS_NO_PATHCONV=1`.
- **The lane died a few seconds after launch, with no error.** A tmux session created from inside a
  Claude session's shell tool dies when that Claude session ends. -> Launch lanes and the watcher from
  a normal terminal that stays open, not from another Claude session.
- **`has-session` says no such session, yet a new session with that name dies within seconds.** The
  name is shadowed: an unreachable psmux server (started elevated, or as another user) still owns it,
  and psmux reaps the newcomer. -> Use a different `-Session` name. To see the owner:
  `Get-Content "$env:USERPROFILE\.psmux\<name>.pid"` and look that pid up in Task Manager. Stop that
  process tree from an elevated terminal if you want the name back.
- **Every session vanished at once.** Someone stopped a `tmux.exe` process, probably one called
  `__warm__`. psmux keeps a pre-warmed server that can host live sessions. -> Never `Stop-Process`
  `tmux.exe` and never `tmux kill-server`. Close sessions by exact name (`kill-session -t <name>`).
- **The lane sits on "Do you trust the files in this folder?" or "Allow external CLAUDE.md file
  imports?"** First-run dialogs, once per folder. -> `tmux attach -t <lane>`, answer, detach
  (Ctrl-b d). The lane carries on. The self-test detects these (`Enter to confirm`) and tells you.
- **The lane runs but writes no transcript (`~\.claude\projects\...` has no new `.jsonl`).** An
  inherited `CLAUDE_CODE_CHILD_SESSION` variable turns transcript saving off; it leaks in when the tmux
  server was started from inside a Claude session. -> `lane-launch -Run` clears it before starting
  Claude. Keep it that way if you edit the script. Clear it in the `-File` script, never in a
  `-Command` string (the calling shell expands `$env:` too early).
- **The lane stalls on "Command spawns a nested PowerShell process which cannot be validated".** Claude
  won't auto-approve `powershell -File ...` from its PowerShell tool, even with an allow rule. -> Call
  scripts directly: `& 'C:\path\script.ps1'`. The lane process already has `-ExecutionPolicy Bypass`,
  and child shells inherit it (`$env:PSExecutionPolicyPreference`).
- **PowerShell 5.1 quirks in these scripts.**
  - Keep `.ps1` files ASCII: 5.1 reads a BOM-less file as the ANSI code page, so write `❯` as `[char]0x276F`.
  - There is no `&&`: use `; if ($?) { ... }`.
  - Under `$ErrorActionPreference = 'Stop'`, any stderr line from a native exe (tmux) becomes a
    terminating error, even with `2>$null`. These scripts don't set Stop; run `has-session` before
    any tmux call that may complain.
  - A comma list passed from the command line arrives as ONE string. Split it into a new variable.
  - Scripts need `[CmdletBinding()]`: without it a misspelled `-Param` is silently swallowed into
    `$args` and the script runs with defaults.
  - psmux has no `respawn-window`. Kill the window and start a new one instead.
- **A window started with a path containing a space fails: "Access to the path '...\my' is denied" or
  "cannot find".** psmux drops the double quotes inside a window's command, so `"C:\my folder\x"`
  arrives split at the space. -> Don't put paths in a tmux command line. The scripts here pass
  `powershell -EncodedCommand <base64>` (no spaces, no quotes) and keep everything else in a JSON
  launch file. Do the same if you add your own launcher.
- **The watcher logs `SURVIVED`.** `/exit` was sent but the window stayed. It is reported, never
  force-killed. -> Attach and look. Usually the pane was not really idle (a dialog, a question).

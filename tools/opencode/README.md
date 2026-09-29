# OpenCode — where each file goes

This folder is the minimum to run the kit in **OpenCode** with the keeping-track pieces
(`TODAY.md`, `TASKS.md`, `MEMORY.md` + `memory\`, handoffs, `/today`, `/close`).
`setup.ps1 -Tool opencode` installs OpenCode and places everything below; the table says where
each file goes if you'd rather copy by hand.

**Status: docs-checked, partly live-tested.** Every "OpenCode does X" line below quotes OpenCode's
own docs (fetched 2026-09). **Live-tested 2026-09-26 on OpenCode 1.18.32 (Windows 11)**, from a
`work\` built by `setup.ps1 -Tool opencode`: `opencode debug config` showed this file loaded as
written (`external_directory` deny, `webfetch` ask, the `bash` ask list), and the file-read tool
asked for `..\private\canary.txt` was refused with "The user has specified a rule which prevents
you from using this specific tool call" (the phrase in the canary was not returned), while a read
of a file inside `work\` worked. Asked to use a shell command (`Get-Content`) on the same file, the
AI declined on its own, citing the `AGENTS.md` rule, so the config was never tested on that
channel: whether OpenCode blocks a *shell* read of `private\` is still **UNVERIFIED**. Lines marked
**UNVERIFIED** are ones neither the docs nor that test settle; check them yourself the first time.

**Check your version first: `opencode --version`.** `opencode.json` here uses the **v1** format
(a `permission` object with `bash`), which matches the published schema at
`https://opencode.ai/config.json` as of 2026-09-26. OpenCode **v2** (2.x, installed as
`@opencode/cli`) documents a different shape: "V1 uses different field and action names. In V2, use
`permissions`, `shell`, and `subagent` instead of `permission`, `bash`, and `task`."
[v2 docs/permissions](https://opencode.ai/v2/docs/permissions). On 2.x, the same fence written the
v2 way (**UNVERIFIED**, docs-derived, not run) is an ordered list, last match wins:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "permissions": [
    { "action": "external_directory", "resource": "*", "effect": "deny" },
    { "action": "shell", "resource": "*", "effect": "allow" },
    { "action": "shell", "resource": "rm *", "effect": "ask" },
    { "action": "shell", "resource": "Remove-Item *", "effect": "ask" },
    { "action": "shell", "resource": "git push *", "effect": "ask" }
    // ...one line per command in the v1 file's "ask" list
  ]
}
```

Whichever version you have, run **Test it once** (below) again after every OpenCode update: a
config the new version doesn't read gives no error you'd notice, just no fence.

## Install and sign in (once)

`setup.ps1 -Tool opencode` installs Node.js (if missing) and then `npm install -g opencode-ai`
(v1), and checks `opencode` starts. By hand it's the same: `npm install -g opencode-ai`
(Chocolatey and Scoop also work); npm needs Node.js, so if `node --version` fails, run
`winget install --id OpenJS.NodeJS.LTS` first and open a new PowerShell window. The docs
recommend WSL on Windows "for the best experience". Or install v2, which uses the package
`@opencode/cli`. [docs](https://opencode.ai/docs/) · [v2 docs](https://opencode.ai/v2/docs)
Then start `opencode`, run `/connect`, pick a provider and paste its key, and pick a model with
`/models`. Keys are stored in `~/.local/share/opencode/auth.json`, outside `work\`. Keep them
out of every file in `work\`. **A pay-per-use key has no spending limit unless you set one on
the provider's billing page. Set one before your first long session.**

## Where each file goes (`setup.ps1 -Tool opencode` does this; only where nothing exists yet)

| Kit file | Copy to | Why there |
|---|---|---|
| `AGENTS.md` | `work\AGENTS.md` | OpenCode reads rule files "by traversing up from the current directory (`AGENTS.md`, `CLAUDE.md`)", and "if you have both … only `AGENTS.md` is used." [docs/rules](https://opencode.ai/docs/rules/) |
| `tools\opencode\opencode.json` | `work\opencode.json` | "Add `opencode.json` in your project root." It "first looks for a config file in the current directory." [docs/config](https://opencode.ai/docs/config/) |
| `tools\opencode\commands\close.md`, `today.md` | `work\.opencode\commands\` | Per-project commands live in `.opencode/commands/`; "The markdown file name becomes the command name", so these become `/close` and `/today`. [docs/commands](https://opencode.ai/docs/commands/) |
| `skills\` | `work\skills\` | Read by the AI when `AGENTS.md` points at one (works in any tool, no discovery needed). |
| `templates\TASKS.md`, `TODAY.md`, `MEMORY.md` | `work\` (top level, without the example entries) and `work\templates\` (with them) | Your trackers start blank; copy an example from `work\templates\` when you want one. |
| `templates\memory\` | `work\templates\memory\` (`work\memory\` starts empty) | One fact per file. The example shows the shape. |
| `templates\handoff.md`, `card.md` | `work\templates\` | `/close` fills in the handoff shape; handoffs land in `work\handoffs\`. `card.md` is for handing one job to another session. |

**Make `work\` a local git repo once:** `cd <your work folder>`, then `git init`. OpenCode's
`/undo` "uses Git to manage the file changes. So your project **needs to be a Git repository**"
([docs/tui](https://opencode.ai/docs/tui/)). Without it, an AI edit that mangles `TASKS.md`
or `MEMORY.md` has no undo. It also gives the skills and config walk-up ("until it reaches the git
worktree") a clear stop. Keep it local: no remote, never push `work\` (see the main README,
"Sharing").

Then launch from `work\`: `cd <your work folder>` and `opencode`. Say *"what rules are you
following?"*. It should describe `AGENTS.md`.

## How skills get found (two routes)

1. **The kit's route (works today, no setup):** `AGENTS.md` tells the AI to read
   `skills\<name>\SKILL.md` when a task matches. It's just a file read.
2. **OpenCode's native route (optional):** OpenCode lists skills in its `skill` tool and loads
   them "on-demand". It searches `.opencode/skills/<name>/SKILL.md` in the project and
   `~/.config/opencode/skills/<name>/SKILL.md` globally (plus `.claude/skills/` and
   `.agents/skills/`). The kit's `skills\` folder is **not** one of those, so to get native
   loading also copy `skills\*` into `work\.opencode\skills\`. Every kit skill already has the
   two required fields (`name`, `description`), and each `name` matches its folder, as the docs
   require. [docs/skills](https://opencode.ai/docs/skills/)
   - **UNVERIFIED:** project skill discovery "walks up from your current working directory until
     it reaches the git worktree". Whether that still finds `.opencode\skills\` in a `work\` that
     isn't a git repo isn't stated. Ask *"which skills can you load?"*. If the kit's skills aren't
     listed, use route 1, or put the skills in the global folder instead.

**Two copies drift.** If you use route 2, treat `.opencode\skills\` as the real copy and archive
`work\skills\`, or re-copy after every edit.

## What `opencode.json` does

- **`external_directory: deny`** — blocks tools from touching paths outside the folder OpenCode
  started in, which is where the kit's `private\` lives. The docs: it's "triggered when a tool
  touches paths outside the project working directory" and applies to "`read`, `edit`, `glob`,
  `grep`, and many `bash` commands." The default is "ask"; this makes it a refusal.
  - **Honest wall, again:** "many" bash commands is not "all". A shell command can still
    reach `..\private\`. This is a fence for the file tools, not a vault. Same rule as the main
    README: keep truly sensitive files encrypted or in another Windows account.
- **`bash`: everything allowed, destructive and git-publishing commands ask first.** "Rules are
  evaluated by pattern match, with the last matching rule winning", so the catch-all `"*"` comes
  first. `*` "matches zero or more of any character". [docs/permissions](https://opencode.ai/docs/permissions/)
  - **UNVERIFIED:** which shell OpenCode's bash tool uses on Windows. The list names both the
    Unix spellings (`rm`, `rmdir`) and the PowerShell ones (`Remove-Item`, `del`); add any
    delete command you use that isn't there.
  - **This list is a speed bump, not a lock.** OpenCode's own v2 docs: "Directory inference from
    command text is best effort, so prefer a narrow shell allowlist instead of patterns intended
    to recognize every dangerous command." A delete spelled another way (an alias, a script) is
    not caught. The real protection is archive-don't-delete in `AGENTS.md` plus a backup.
- **`webfetch: ask`** — OpenCode fetches web pages without asking by default. A fetched page is
  text written by someone else that lands in the AI's context, so the kit makes each fetch a
  yes/no. Treat what comes back as information, never as instructions.
- **Left at OpenCode's defaults on purpose:** reads inside `work\` are allowed, and `.env` files
  are guarded by default (v1: "`read` is `"allow"`, but `.env` files are denied by default"; v2's
  default for `*.env` reads is `ask`, not deny).

**Test it once** (the same idea as `skills\setup-tutor\SKILL.md` Step 4): put a file with a
made-up phrase in `private\`, then from `work\` ask OpenCode to read `..\private\<file>`. The
file tool should refuse. Then ask it to use a shell command (`Get-Content`) instead, and write
down what happened and your `opencode --version`. That result, not this README, is your real
boundary.

## The daily loop

- **Start:** `/today`. It reads `TODAY.md`, `TASKS.md`, `MEMORY.md` and the newest handoff,
  then proposes at most three things and writes `TODAY.md` only after you say yes.
- **Work:** normally. The skills fire on their own.
- **End:** `/close` (optionally `/close <topic>`). It runs `skills\document-and-handoff` and
  writes the handoff, updates `TASKS.md`, and saves lasting facts to `memory\`.
- **Next session:** *"read the newest handoff and continue"*, or just `/today`.

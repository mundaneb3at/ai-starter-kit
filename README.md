# ai-starter-kit

A small, **AI-agnostic** starter kit for "vibe coding" with an AI assistant on a fresh Windows
machine. It sets up three things:

1. **File organization** — a folder layout where your AI can work freely on your projects while
   being kept out of anything private (see the honest wall below — the real story, not the
   comfortable one).
2. **Terminal usage** — how your AI runs shell commands safely: what it can do without asking,
   what needs your confirmation, and how secrets stay out of its reach.
3. **How to actually use it** — a short phase ladder from "run the script" to "share your own
   work," plus a handful of prompt-file skills for planning, debugging, learning, and trust.

Written for anyone new to this — the original version of this kit was built for a working
electrical engineer trying AI coding for the first time.

---

## What's in this folder

| File / folder | Goes where | Purpose |
|---|---|---|
| `AGENTS.md` | your `work\` folder (root) | The rules your AI reads on launch. **The core file.** |
| `CLAUDE.md` | your `work\` folder (root) | One line (`@AGENTS.md`) so Claude Code picks up the same rules. |
| `WORKFLOWS.md` | your `work\` folder (root) | How the AI should approach multi-step work. Readable by you too. |
| `WHY.md` | read it, don't install it | Why the kit is shaped this way, what it is NOT, the field-review history, and an FAQ. |
| `CHANGELOG.md` | read it, don't install it | What changed in each release. `setup.ps1` reads the newest version id from it and records it in `work\KIT-VERSION.txt`. |
| `HARNESS.md` | read it when one session isn't enough | The 17 building blocks of a larger, unattended setup — problem, minimal version, failure it stops. |
| `SEATS.md` | your `work\` folder (root) | Role-based assignment (Orchestrator / Builder) so any tool can fill either job. |
| `skills\` | your `work\` folder (root) | Reusable prompt-file skills the AI reads when a task matches one. |
| `tools\codex\config.toml` | `C:\Users\<you>\.codex\config.toml` | Codex's machine config — sandbox boundary, approval policy, secret filtering. |
| `tools\opencode\` | your `work\` folder (`setup.ps1 -Tool opencode` places it; see its README) | OpenCode config (keeps tools out of folders outside `work\`, asks before destructive commands and web fetches) plus `/today` and `/close` commands. |
| `templates\` | `work\templates\` (`setup.ps1` places them); `TASKS.md`, `TODAY.md`, `MEMORY.md` also go to `work\` without their example entries | Starting copies of `TASKS.md`, `TODAY.md`, `MEMORY.md` + `memory\`, the handoff shape, a one-job card, and an example fundamentals register (`HARNESS.md` §16) — the "Keeping track" files `AGENTS.md` describes. The copies in `work\templates\` keep their examples, to read and copy from; the ones your AI reads every session start blank. Work with any tool. |
| `advanced\tmux-lanes\` | nowhere; read it in place, **for technical users** | An add-on for running cards unattended: each card gets its own terminal session, the card declares when it is done, a watcher checks its Done-when file and closes the session. Start with its README and `selftest.ps1`. Skip it until `HARNESS.md` blocks 4-7 are a problem you actually have. |
| `tools\claude-code\settings.json` | `C:\Users\<you>\.claude\settings.json` | Claude Code's permission denylist — the `private\` boundary + delete-command guards. JSON has no comments, so: `setup.ps1` rewrites the `private\` path in this file to your actual absolute path when it installs it (a relative pattern was tested live and does not reliably block access — see the honest wall below). If you ever copy this file manually instead of running the script, edit that path yourself first. |
| `tools\claude-code\hooks\` | optional, Claude Code only; see `settings.hooks-example.json` next to it | Two opt-in hooks: one sends a reply back once if its PowerShell won't run on 5.1, one re-shows the Right-now rules every fifth message (`HARNESS.md` §17). |
| `setup.ps1` | run once from PowerShell | Builds the folder layout, installs your chosen tool(s), and drops the config files in place. Safe + idempotent. |
| `.gitignore` | your `work\` folder (root) | Keeps archives and secrets out of version control if you use git. |

---

## The mental model in 30 seconds

```
<Base>\                      (default: Desktop)
   |
   +-- work\          <-- Launch your AI tool from HERE. This whole folder is
   |     |                its sandbox: it may read/create/edit anything inside.
   |     +-- projects\
   |     +-- _archive\        (archive-don't-delete target)
   |     +-- AGENTS.md        (your AI reads this on every launch)
   |
   +-- private\       <-- OUTSIDE work\. Never launch your AI tool here, and
                          never add it as an extra directory. Your no-AI zone:
                          personal, financial, confidential, credentials.
```

### The honest wall

`private\` is a rule your AI follows, not a fence. The sandbox stops it writing there and stops
it starting there; it can still read it if it wanders. Most sandboxed coding tools (Codex
included — see the source probe below) confine **writes** to the launch folder. They do not
reliably confine **reads**. Keep passwords, medical and money files **encrypted, or in a
separate Windows account** — don't rely on the folder boundary alone for anything that actually
matters.

This isn't a guess: it's measured. Codex, on its default config, does not fence reads at all —
asking it to read a nonexistent file inside `private\` versus inside `work\` comes back with the
identical "not found" error either way. Claude Code is different **only because `setup.ps1`
templates your real `private\` path into its permission config at install time** — with that in
place, a read into `private\` is actually denied with a distinct "denied by your permission
settings" error. That's a real, working boundary for Claude Code specifically, on this machine,
with that config installed — it is not a property of sandboxed AI tools in general, it doesn't
survive a hand-edited config or a different tool, and it says nothing about writes on other
tools. `skills\setup-tutor\SKILL.md` walks you through running this probe yourself so you know
what your actual setup does, instead of trusting this paragraph.
Re-measured 2026-09-26 on Claude Code 2.1.283: with the templated rule in place, the file-read
tool, a Bash `cat` and a PowerShell `Get-Content` of a canary in `private\` were all denied;
with the rule removed, all three read it.

---

## Setup

### 1. Run the script
Requires PowerShell 5.1+ (Windows 11 default) or PowerShell 7+.

From this kit's folder, in PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool both
```
(`-Tool codex`, `-Tool claude`, `-Tool both`, `-Tool opencode`, or `-Tool none` to build the
folders and files only and install nothing.) This installs Node.js/Git if missing, installs
your chosen AI tool(s) and checks each one actually starts, builds `work\`, `work\projects\`,
`work\_archive\`, `work\handoffs\` and the sibling `private\`, copies the rule files, skills and
tracking files into `work\` (the tracking files start without example entries; the examples sit
in `work\templates\`), writes `work\KIT-VERSION.txt` (which kit release you installed and when),
and drops the tool config(s) into place — only where nothing already exists.

### 2. Launch and verify
```powershell
cd "<the work folder setup.ps1 printed at the end>"   # default: $env:USERPROFILE\Desktop\work
codex        # or: claude, opencode
```
If `codex` (or `npm`) answers *"running scripts is disabled on this system"*, Windows is still on
its default script policy. `setup.ps1` normally fixes this for your account; if it couldn't, run
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once (undo: `Set-ExecutionPolicy -Scope
CurrentUser Undefined`). Microsoft's explanation: `about_Execution_Policies`.

Then say: *"read skills/setup-tutor/SKILL.md and walk me through it."* It'll check the folders,
prove `AGENTS.md` is actually loaded at launch (a fresh session must open with the Right-now
rules on its own), run the boundary checks, and hand off to `WORKFLOWS.md`.

### If a project inside `work\` has its own `.git`
Tools differ on whether they still see the rules file above it:
- **Codex** walks up from your current folder only until it finds a project root (by default, a
  folder containing `.git`) and never past it — so inside `work\projects\foo\` with its own repo,
  `work\AGENTS.md` is not read. Keep a one-line `AGENTS.md` in that project pointing at the rules
  (or launch from `work\`). Source: Codex config docs, `project_root_markers`.
- **Claude Code** loads `CLAUDE.md` from the current folder and every folder above it to the
  filesystem root, with no `.git` exception — the kit's one-line `CLAUDE.md` (`@AGENTS.md`) is
  still found. Source: Claude Code memory docs.

### macOS / Linux
No script ships for these yet (this kit is Windows-tested only). By hand: install Node.js + your
AI tool via your package manager, create `work\projects\ work\_archive\` and a sibling
`private\`, copy `AGENTS.md CLAUDE.md WORKFLOWS.md SEATS.md .gitignore skills\` into `work\` and
the `templates\` folder to `work\templates\`, copy `TASKS.md`, `TODAY.md` and `MEMORY.md` from it
into `work\` and delete their example lines, create an empty `work\memory\`, and place the
tool config per its own docs. Untested — if you hit something, please open an issue.

### Known Windows issue: slowdown after days without a restart
On Windows 11 build 26200 (25H2) there is a Windows bug that leaks a small kernel object when
programs start other programs, and AI coding tools start a lot of short-lived commands. If
starting commands gets noticeably slower after a few days of uptime, **restart**: that clears
it. An optional per-user registry workaround (`ForegroundLockTimeout` = 0) stops the leak, at
the cost of letting any app take focus from the window you're typing in. The exact steps and the
undo are in the source: [github.com/bentoner/windows-token-leak](https://github.com/bentoner/windows-token-leak).
Microsoft had not shipped a fix when this was written (2026-09).

---

## Which tools does this actually work with?

**Tested pairing:** Claude Code (Orchestrator) + Codex (Builder), tested 2026-09 on Windows 11 —
see `SEATS.md`.

Any other tool that reads an `AGENTS.md`-style rules file on launch (Cursor, GitHub Copilot,
Gemini CLI, and others each document their own equivalent) should work per its own docs — that's
an untested claim here, not a verified one. If you get one working, a PR adding it to this table
is welcome.

### Using OpenCode

OpenCode reads `AGENTS.md` natively, so the rules work as-is. `setup.ps1 -Tool opencode`
installs it and places the config and the `/today` and `/close` commands in `work\`;
`tools\opencode\README.md` says what each file does, how OpenCode finds skills, and which lines
were live-tested (and on which version).

---

## How to use it — the phase ladder

**0. Set up.** Run `setup.ps1`; know what the folders mean; read the honest wall above.

**1. First tool.** Launch from `work\`; say *"read skills/setup-tutor/SKILL.md and walk me
through it."*

**2. First build.** Pick something small you actually want to build; use the core loop in
`WORKFLOWS.md`. One example project built this way:
[`github.com/mundaneb3at/sim-maker-kit`](https://github.com/mundaneb3at/sim-maker-kit).

**3. Learn while building.** `tutor` (a whole study session on any topic, taught from zero if
it's new to you), `quiz-me` (drill one concept cold instead of being handed the answer), `grill-me` (pressure-test a plan before you commit to it), `primary-source` (check a
claim against real sources before trusting it).

**4. Work like a team.** Read `WORKFLOWS.md` + the five workflow skills (`scope-first`,
`debug-systematically`, `verify-before-done`, `document-and-handoff`, `safe-cleanup`), and
`SEATS.md` for when to give a second tool a seat. When one session or one tool stops being
enough — overnight work, several sessions, a session that has run too long — read `HARNESS.md`.
Leaving a long job running and want to ask about it from elsewhere? `skills\companion\SKILL.md`
sets up a second session that watches it and tells you when to act, and never touches it.

**5. Share it.** See below.

---

## Sharing what you build

When something you built is worth sharing:

1. Put it in its own fresh folder — don't publish `work\` itself, it has your personal AGENTS.md
   edits and possibly other projects in it.
2. `git init`, add a `LICENSE` (MIT is a reasonable default for a small project), and write a
   README a stranger could follow with zero context.
3. Double-check there are no secrets, API keys, or personal file paths anywhere in what you're
   about to push — `git status` and actually look.
4. Push it: `gh repo create <you>/<name> --public --source . --push` (or the GitHub website).
5. Clone it fresh somewhere else and confirm it actually works from a clean checkout — that's the
   only real test that nothing local was silently required.

---

## Updating this kit

Newer versions live at
[`github.com/mundaneb3at/ai-starter-kit`](https://github.com/mundaneb3at/ai-starter-kit).
`setup.ps1` never overwrites, so re-running it won't bring changes in. To take an update:

1. Open `work\KIT-VERSION.txt`. Its `kit-version:` line is the release your install came from
   No file, or `unknown`, means your install is older than the version marker (or setup was re-run
   over an existing install): read the whole `CHANGELOG.md` and compare by file dates.
2. Download or `git pull` the kit into its own folder (never into `work\`) and read its
   `CHANGELOG.md`: every entry newer than your version is something to consider taking.
3. Copy the changed files into `work\` by hand. For `AGENTS.md`, merge the new lines into your
   edited copy; don't replace it. (`git log --stat` shows the file-level detail if the changelog
   isn't enough.)
4. Edit `kit-version:` in `work\KIT-VERSION.txt` to the newest entry you took.
5. Re-run the boundary checks in `skills\setup-tutor\SKILL.md` Step 4. Do this after **every**
   update of the AI tool itself too, not only after a kit update: the tools update themselves, and
   a config the new version no longer reads gives no error, only a missing fence.

---

## Sources

The honest-wall claim above is backed by a live probe, not a guess: Codex's `workspace-write`
sandbox mode was tested directly and confirmed to confine writes to the launch folder while
still reading arbitrary paths outside it. `skills\primary-source\SKILL.md` has the discipline for
running checks like this yourself on any tool or claim you don't want to take on faith.

**Field review.** This kit was installed cold on a second person's Windows machine and reviewed by
their AI (2026-09-07); 17 of its 27 findings were confirmed against live code and fixed, every
verdict was re-derived independently, and the remaining proposals were refuted from three angles
before being accepted or rejected. `WHY.md` § Field-review history lists what changed and what is
still open on purpose.

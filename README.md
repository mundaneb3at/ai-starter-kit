# ai-starter-kit

A small starter kit for "vibe coding" (building things by describing what you want to an AI
assistant) on a fresh Windows machine. It is **AI-agnostic**: it works with several AI coding
tools, not one. It sets up three things:

1. **File organization** — a folder layout where your AI can work freely on your projects while
   being kept out of anything private (see the honest wall below — the real story, not the
   comfortable one).
2. **Terminal usage** — how your AI runs shell commands safely: what it can do without asking,
   what needs your confirmation, and how secrets stay out of its reach.
3. **How to actually use it** — a short phase ladder from "run the script" to "share your own
   work," plus 21 prompt-file skills for planning, debugging, learning, checking claims,
   everyday jobs (a letter, a small fix, a messy folder), and handing work to another session.

It also keeps itself up to date: each release has a date tag, your install remembers which one
it came from, and `update-kit.ps1` brings a newer release in without overwriting your own edits.

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
| `CHANGELOG.md` | read it, don't install it | What changed in each release, newest first. Each release is a date tag (`vYYYY.MM.DD`, `.1`/`.2` for a second one the same day). `setup.ps1` reads the newest one from here and records it in `work\KIT-VERSION.txt`. |
| `HARNESS.md` | read it when one session isn't enough | The 17 building blocks of a larger, unattended setup — problem, minimal version, failure it stops. |
| `SEATS.md` | your `work\` folder (root) | Role-based assignment (Orchestrator / Builder) so any tool can fill either job. |
| `skills\` | your `work\` folder (root) | 21 reusable prompt-file skills the AI reads when a task matches one. List below; `skills\README.md` says when each one fires. |
| `tools\codex\config.toml` | `C:\Users\<you>\.codex\config.toml` | Codex's machine config — sandbox boundary, approval policy, secret filtering. |
| `tools\opencode\` | your `work\` folder (`setup.ps1 -Tool opencode` places it; see its README) | OpenCode config (keeps tools out of folders outside `work\`, asks before destructive commands, web searches and web fetches) plus `/today` and `/close` commands. |
| `templates\` | `work\templates\` (`setup.ps1` places them); `TASKS.md`, `TODAY.md`, `MEMORY.md` also go to `work\` without their example entries; `ABOUT-ME.md` and `FRUSTRATIONS.md` go to `work\` blank (personal, gitignored) | Starting copies of `TASKS.md`, `TODAY.md`, `MEMORY.md` + `memory\`, the handoff shape, a one-job card, a per-task `progress.md` log, the two personal files, and an example fundamentals register (`HARNESS.md` §16) — the "Keeping track" files `AGENTS.md` describes. The copies in `work\templates\` keep their examples, to read and copy from; the ones your AI reads every session start blank. Work with any tool. |
| `advanced\tmux-lanes\` | nowhere; read it in place, **for technical users** | An add-on for leaving AI jobs running unattended with Claude Code. Each job is written as a card (one file); each card runs in its own terminal window, says when it is finished, and a watcher script checks that the promised files exist and then closes that window. Needs psmux (tmux for Windows); its README says how to install it. Start with that README and `scripts\selftest.ps1`; `ARCHITECTURE.md` explains the design. Skip it until `HARNESS.md` blocks 4-7 are a problem you actually have. |
| `tools\claude-code\settings.json` | `C:\Users\<you>\.claude\settings.json` | Claude Code's permission denylist — the `private\` boundary + delete-command guards. JSON has no comments, so: `setup.ps1` rewrites the `private\` path in this file to your actual absolute path when it installs it (a relative pattern was tested live and does not reliably block access — see the honest wall below). If you ever copy this file manually instead of running the script, edit that path yourself first. |
| `tools\claude-code\hooks\` | optional, Claude Code only; see `settings.hooks-example.json` next to it | Two opt-in hooks: `ps51-command-gate.ps1` catches a reply whose PowerShell commands won't run on Windows' built-in PowerShell 5.1 and sends it back once to be fixed; `rules-reshow.ps1` re-shows the Right-now rules every fifth message (`HARNESS.md` §17). |
| `update-kit.ps1` | run from a NEWER copy of the kit, next to `work\` | Plans an update of `work\` to that kit (on its own it changes nothing) and, with `-Apply`, takes the files you never changed. The `update-kit` skill walks you through the rest. See "Updating this kit". |
| `setup.ps1` | run once from PowerShell | Builds the folder layout, installs your chosen tool(s), and drops the config files in place. Safe + idempotent. |
| `.gitignore` | your `work\` folder (root) | Keeps archives and secrets out of version control if you use git. |
| `LICENSE` | stays with the kit | MIT: use, change and share it freely. |

### The skills

A skill is a short procedure the AI reads when a task matches it; you don't have to call it by
name. `skills\README.md` has the full table.

- **Doing the work:** `scope-first` (plan before an unclear or risky task), `debug-systematically`
  (something is broken), `verify-before-done` (check before calling it done),
  `document-and-handoff` (wrap up a session), `safe-cleanup` (tidy files without losing any).
- **Everyday:** `start` (the one smallest first move), `fix-a-small-problem` (one check per turn,
  a help request after two failed tries), `write-a-document` (a letter, email or form, every fact
  checked against the thread), `organize-my-files` (give a messy folder a shape), `parking-lot`
  (save a stray thought and get back to work), `questionnaire` (read your files first, then ask
  only what's missing), `find-advice` (look it up on the web, every point with its page),
  `about-me` (your own profile, saved only after a yes).
- **Learning and deciding:** `tutor` (a whole study session on a topic), `quiz-me` (drill one
  concept), `grill-me` (pressure-test a plan), `primary-source` (check a claim against real sources).
- **Beyond one session:** `write-a-card` (write a job down so another session can run it),
  `companion` (a second session that watches running work and answers your questions).
- **The kit itself:** `setup-tutor` (check your install step by step), `update-kit` (take a newer
  release without losing your changes).

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
writes your real `private\` folder path into Claude Code's permission settings at install time** — with that in
place, a read into `private\` is actually denied with a distinct "denied by your permission
settings" error. That's a real, working boundary for Claude Code specifically, on this machine,
with that config installed — it is not a property of sandboxed AI tools in general, it doesn't
survive a hand-edited config or a different tool, and it says nothing about writes on other
tools. `skills\setup-tutor\SKILL.md` walks you through running this probe yourself so you know
what your actual setup does, instead of trusting this paragraph.
Re-measured 2026-09-26 on Claude Code 2.1.283 with a test file placed in `private\`: with that
rule in place, three different ways of reading it (the file-read tool, a Bash `cat` and a
PowerShell `Get-Content`) were all denied; with the rule removed, all three read it.

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
On Windows 11 build 26200 (25H2) there is a Windows bug that slowly uses up a small internal
resource each time one program starts another (technically, it leaks a kernel object), and AI
coding tools start a lot of short-lived commands. If
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
`debug-systematically`, `verify-before-done`, `document-and-handoff`, `safe-cleanup`),
`organize-my-files` (give a messy folder a shape a fresh session can navigate, one step per
turn), `about-me` (tell the AI how you like to work, once), and
`SEATS.md` for when to give a second tool a seat. When one session or one tool stops being
enough — overnight work, several sessions, a session that has run too long — read `HARNESS.md`.
To hand a job to another session, say *"write a card"*: the `write-a-card` skill fills in
`templates\card.md` so a fresh session can run the job without your chat history.
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
Every release is a git tag named by date (`v2026.09.29`, then `v2026.09.29.1` for a second one
that day), listed under Tags on that page and described in `CHANGELOG.md`. Your install writes the
release it came from to `work\KIT-VERSION.txt`, so you can always tell how far behind you are.

`setup.ps1` never overwrites, so re-running it won't bring changes in. To take an update without
losing your own changes:

1. Download the new kit into its own folder next to `work\` (never inside it) and read its
   `CHANGELOG.md`: every entry newer than the `kit-version:` in your `work\KIT-VERSION.txt` is
   something you may take. No file, or `unknown`, means an older install.
2. Tell your AI: *"read skills/update-kit/SKILL.md and update my kit"* (the skill is in the new
   kit's `skills\` folder if your `work\` doesn't have it yet). It runs `update-kit.ps1` from the
   new folder, which compares three copies of every kit file: the release you installed, yours,
   and the new one. You see the list first and can leave any file out. Files you never changed
   are updated; files only you changed are kept; files you deleted stay deleted; files you both
   changed are merged around your edits, with you approving each one. Every file it
   replaces is copied to `work\_archive\<date>-kit-update\` first, so you can undo.
   Older install without a version file? If you know which release you installed, add
   `-BaseTag <tag>` (tags are on the GitHub page); otherwise it shows you each difference and asks.
3. Your tracking files, `memory\`, `handoffs\` and tool configs outside `work\` are never touched.
   Compare the tool configs by hand if the changelog mentions them.
4. The skill sets `kit-version:` to the new release once everything is merged.
5. Re-run the boundary checks in `skills\setup-tutor\SKILL.md` Step 4. Do this after **every**
   update of the AI tool itself too, not only after a kit update: the tools update themselves, and
   a config the new version no longer reads gives no error, only a missing fence.

---

## Related projects

Separate repos from the same GitHub account. None of them is needed to use the kit.

- [**AI Courier**](https://github.com/mundaneb3at/ai-courier) — lets two people's AI assistants
  exchange notes without prompt injection: a quarantined reader with no tools, a validator,
  human-signed sends and a canary that tests itself. Windows / PowerShell.
- [**panel-kit**](https://github.com/mundaneb3at/panel-kit) — a terminal status board for
  Windows + PowerShell, driven by one manifest file, no dependencies.
- [**agent-ops-playbook**](https://github.com/mundaneb3at/agent-ops-playbook) — a written
  doctrine for running many AI agents with budgets, verification gates, contract templates and a
  failure ledger.
- [**sim-maker-kit**](https://github.com/mundaneb3at/sim-maker-kit) — build offline study
  simulations with Learn, Explore and Practice modes (the example project in the phase ladder).

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

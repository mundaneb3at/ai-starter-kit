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
| `SEATS.md` | your `work\` folder (root) | Role-based assignment (Orchestrator / Builder) so any tool can fill either job. |
| `skills\` | your `work\` folder (root) | Reusable prompt-file skills the AI reads when a task matches one. |
| `tools\codex\config.toml` | `C:\Users\<you>\.codex\config.toml` | Codex's machine config — sandbox boundary, approval policy, secret filtering. |
| `tools\claude-code\settings.json` | `C:\Users\<you>\.claude\settings.json` | Claude Code's permission denylist — the `private\` boundary + delete-command guards. JSON has no comments, so: `setup.ps1` rewrites the `private\` path in this file to your actual absolute path when it installs it (a relative pattern was tested live and does not reliably block access — see the honest wall below). If you ever copy this file manually instead of running the script, edit that path yourself first. |
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

---

## Setup

### 1. Run the script
From this kit's folder, in PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool both
```
(`-Tool codex`, `-Tool claude`, or `-Tool both`.) This installs Node.js/Git if missing, installs
your chosen AI tool(s), builds `work\`, `work\projects\`, `work\_archive\`, and the sibling
`private\`, copies the rule files and skills into `work\`, and drops the tool config(s) into
place — only where nothing already exists.

### 2. Launch and verify
```powershell
cd "$env:USERPROFILE\Desktop\work"
codex        # or: claude
```
Then say: *"read skills/setup-tutor/SKILL.md and walk me through it."* It'll check the folders,
prove it's actually reading `AGENTS.md`, run the boundary checks, and hand off to `WORKFLOWS.md`.

### macOS / Linux
No script ships for these yet (this kit is Windows-tested only). By hand: install Node.js + your
AI tool via your package manager, create `work\projects\ work\_archive\` and a sibling
`private\`, copy `AGENTS.md CLAUDE.md WORKFLOWS.md SEATS.md .gitignore skills\` into `work\`, and place the
tool config per its own docs. Untested — if you hit something, please open an issue.

---

## Which tools does this actually work with?

**Tested pairing:** Claude Code (Orchestrator) + Codex (Builder), tested 2026-09 on Windows 11 —
see `SEATS.md`.

Any other tool that reads an `AGENTS.md`-style rules file on launch (Cursor, GitHub Copilot,
Gemini CLI, and others each document their own equivalent) should work per its own docs — that's
an untested claim here, not a verified one. If you get one working, a PR adding it to this table
is welcome.

---

## How to use it — the phase ladder

**0. Set up.** Run `setup.ps1`; know what the folders mean; read the honest wall above.

**1. First tool.** Launch from `work\`; say *"read skills/setup-tutor/SKILL.md and walk me
through it."*

**2. First build.** Pick something small you actually want to build; use the core loop in
`WORKFLOWS.md`. One example project built this way:
[`github.com/mundaneb3at/sim-maker-kit`](https://github.com/mundaneb3at/sim-maker-kit).

**3. Learn while building.** `quiz-me` (drill any concept cold instead of being handed the
answer), `grill-me` (pressure-test a plan before you commit to it), `primary-source` (check a
claim against real sources before trusting it).

**4. Work like a team.** Read `WORKFLOWS.md` + the five workflow skills (`scope-first`,
`debug-systematically`, `verify-before-done`, `document-and-handoff`, `safe-cleanup`), and
`SEATS.md` for when to give a second tool a seat.

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

## Sources

The honest-wall claim above is backed by a live probe, not a guess: Codex's `workspace-write`
sandbox mode was tested directly and confirmed to confine writes to the launch folder while
still reading arbitrary paths outside it. `skills\primary-source\SKILL.md` has the discipline for
running checks like this yourself on any tool or claim you don't want to take on faith.

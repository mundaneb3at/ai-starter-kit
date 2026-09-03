---
name: setup-tutor
description: >
  Walk a beginner through verifying their ai-starter-kit setup, one step at a time, with the
  user performing each check themselves. Use when the user says "walk me through setup", "is my
  setup right", "check my wall", "help me set this up", or has just run setup.ps1 and wants to
  confirm it worked. Say "skip setup" to bypass this entirely.
---

# Setup Tutor

> Confirm the workspace is real, not just that the script printed "created". Every step below
> ends with a check the **user** runs and pastes back — never with the AI declaring success on
> its own say-so (see `verify-before-done`).

## Off-switch

If the user says "skip setup," stop here and go straight to `WORKFLOWS.md`.

## Run one step per turn

### Step 1 — the folders exist
Ask the user to run `Get-ChildItem <base>` (the folder they passed to `setup.ps1`, default
`Desktop`) and paste the output. Confirm you see a `work\` folder with a **sibling** `private\`
folder — not nested inside it.

### Step 2 — launched from the right place
Ask them to run `Get-Location` inside their AI tool's terminal / integrated shell. Confirm the
path ends in `work\`. If not, have them `cd` there and relaunch the tool — the sandbox root is
set by where the tool starts.

### Step 3 — the canary (proves the rules file is actually read)
Ask the AI tool itself: *"what's the first line of AGENTS.md?"* It should quote the real title
line back verbatim. If it can't, the rules file isn't being read — check `CLAUDE.md`
(should be exactly `@AGENTS.md`) or that `AGENTS.md` sits in the folder the tool was launched
from.

### Step 4 — the boundary checks
Run all three and record what happens:
1. Ask the AI to **read a file in `..\private\`** — it should refuse, or say that's outside its
   workspace.
2. Ask the AI to **create a test file inside `work\`** — it should succeed without trouble.
3. **Differential probe:** ask the AI to read `..\private\does-not-exist.txt`, then
   `work\does-not-exist.txt`. Two outcomes are both possible, and both are informative:
   - **Identical "not found" errors** → reads are **not fenced**: the tool can see into
     `private\`, it just isn't supposed to write there. Measured this way for Codex on its
     default config.
   - **A distinct "denied by your permission settings" error on the `private\` path** → reads
     *are* fenced for this tool, because `setup.ps1` templated your real `private\` path into
     its config at install time. Measured this way for Claude Code once `setup.ps1` has run.
   Either way, don't assume — that's the point of running the probe instead of trusting the
   README. See the README's honest-wall section for why the fence still isn't something to lean
   on for anything that actually matters (a hand-edited config, a different tool, a bypass flag).

Then have the AI explain, in its own words, what that means for what should and shouldn't live
in `private\`. (It should land near: keep passwords, medical and money files encrypted or in a
separate Windows account — don't rely on the folder boundary alone.)

### Step 5 — one throwaway task
Ask the AI to create `hello.md` in `work\`, then say "delete it." Confirm it lands in
`work\_archive\<today's date>\` rather than being deleted outright — that's the archive-don't-
delete rule from `AGENTS.md` working.

### Step 6 — hand off
Tell the user: *"Setup's confirmed. Next, read WORKFLOWS.md — that's how this AI approaches
multi-step work."*

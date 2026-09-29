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

### Step 3 — the rules-file check (proves the rules file is loaded, not just readable)
Asking a tool to quote `AGENTS.md` proves nothing: any tool that can open files will do it on
request, loaded or not. So test the loading instead. Ask the user to **close the session and
start a fresh one from `work\`**, then send a plain greeting ("hi") and nothing else: do not
mention `AGENTS.md`, the rules, or this check. `AGENTS.md` tells the AI to open its first reply
with the five Right-now rules, word for word. The user compares the reply with the list in
`AGENTS.md` themselves.

- **The five rules show up unprompted** → the file was loaded at launch.
- **Anything else** (a plain greeting, a paraphrase, four rules) → it was not loaded, or not
  followed. Check `CLAUDE.md` (should be exactly `@AGENTS.md`), that `AGENTS.md` sits in the
  folder the tool was launched from, and that the five rules are still in your copy. Then retry
  in another fresh session.

Either way, bring the walk-through back in the new session by saying: *"read
`skills/setup-tutor/SKILL.md` and continue at Step 4"*.

If you removed the Right-now rules from your copy, plant your own token instead: add one line to
`AGENTS.md` such as *"Start your first reply in each session with the words `rules-loaded-<a
phrase only you know>`."* and run the same fresh-session greeting. The token exists only in that
file, so seeing it can only mean the file was loaded.

### Step 4 — the boundary checks
Run all three and record what happens:
1. **You**, not the AI, create a canary in `private\` — in a separate PowerShell window (never
   through the AI; the AI must never write in `private\`):
   `Set-Content "<your private folder>\canary.txt" "canary-<any phrase only you know>"`
   (the `private\` folder next to your `work\` folder; `setup.ps1` printed where).
   Then ask the AI to **read `..\private\canary.txt` and tell you what it says**. It should
   refuse, or say that's outside its workspace. If it repeats your phrase, it read `private\` —
   that is the honest-wall result, recorded as a fact, not a failure of the kit.
   Then ask it to try once more **with a terminal command** instead of its file-reading tool:
   `Get-Content ..\private\canary.txt`. A rule that only covers the file tool would show up here.
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
4. **Write down the tool's version next to your results** (`claude --version`, `codex --version`,
   `opencode --version`). Tools change how these rules behave between versions, and a config
   the new version no longer reads gives no error, only a missing fence. So **re-run this step
   after every update of the tool, not just a big one**, and compare the version you wrote down
   with today's `--version` before you trust the fence. Tools that update themselves change
   version without telling you, so also re-run it if you haven't in a while.

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

# HARNESS — what to build when one session and one tool stop being enough

This kit gets you to *one AI, one folder, one task at a time*. At some point you will want more:
a second tool with its own job, work that runs while you sleep, several sessions at once, or a
session that has been running so long it has forgotten what it was doing. The set of things you
build to make that safe is a **harness**.

This file is the generic version of a harness the author runs every day. It does not ship the
author's scripts — they were built for one machine and are not confidently reusable. It ships the
*ideas*, each in the same four lines: the problem, the smallest version that works, the failure it
was built to stop, and where a public piece already exists. Build them in this order; stop when
you don't feel the next problem yet.

---

## 0. The three rules that never change

- **Disk is the only truth.** A session's own report of "done" is a claim. A file it wrote, a
  test that passed, a commit that exists — those are evidence. Every block below exists to move
  something from *said* to *on disk*.
- **Verify the outcome, not the exit code.** A command returning 0 means it ran; check that the
  thing it was supposed to produce is actually there. (The kit's own installer still gets this
  wrong for package-manager re-runs — see `WHY.md` § Still open.)
- **One writer per shared file.** Two sessions editing the same ledger corrupt it. Every shared
  surface has exactly one script or one session that writes it; everyone else reads.

## 1. Rules file
- **Problem:** the AI needs standing instructions it cannot forget between turns.
- **Minimal:** one `AGENTS.md` at the launch folder (this kit). Add per-project ones as projects grow.
- **Failure it stops:** re-explaining the same boundaries every session, then getting one wrong.
- **Watch for:** a rules file that grows into an essay — it gets paid for on every prompt. Keep the
  always-loaded part short; move topic rules into files the AI reads only when that topic comes up.

## 2. Trust boundary
- **Problem:** the AI can read more than it should.
- **Minimal:** `work\` / `private\` split + the tool's own deny config (this kit).
- **Failure it stops:** private material ending up in a prompt, a log, or a commit.
- **Watch for:** a *read* fence that only exists for one tool. Test it per tool (`setup-tutor` Step 4).

## 3. Seats (roles, not tool names)
- **Problem:** "which AI does what" drifts into "whichever one I opened last."
- **Minimal:** `SEATS.md` — Orchestrator plans and re-verifies; Builder executes one bounded task
  and stops.
- **Failure it stops:** the same tool both doing and grading its own work.

## 4. Cards (one job, one file)
- **Problem:** a task described in chat is gone when the session is.
- **Minimal:** one Markdown file per job: a STATUS block at the top (model, effort, date, state),
  the task, a **STOP LINE** (what makes the session stop and hand back), and a **DONE-WHEN** naming
  an absolute path that must exist at the end.
- **Failure it stops:** a session "finishing" with nothing on disk; two sessions running the same
  job because neither could see the other's state.
- **Watch for:** a DONE-WHEN satisfied by an *empty* or *stub* file. Existence is not completion.

## 5. Launcher with a receipt
- **Problem:** starting a session by hand (open window, pick model, paste prompt) is slow and
  leaves no record.
- **Minimal:** one script that takes a card, refuses it if it has no STATUS/STOP LINE, stamps the
  chosen model and effort *into the card*, appends one row to a dispatch log, then starts the tool
  with "read this card and run it." Model and effort are mandatory arguments — no silent default.
- **Failure it stops:** "which model ran this?" being unanswerable; a lane started twice.

## 6. Queue + custodian loop
- **Problem:** ten cards to run overnight, in phases, with a machine that has limited RAM and a
  subscription with limited quota.
- **Minimal:** a plain table (queue) with one row per card and a phase column; a **script, not an
  AI**, that ticks every minute: reads the queue, reads free RAM and quota, launches the next
  eligible row, watches each running session's terminal for *idle / asking a question / finished*,
  and reaps finished ones. Phase N+1 starts only when every phase-N row is closed.
- **Failure it stops:** the orchestrator being an AI session that itself runs out of context at
  3 a.m.
- **Watch for:** one misread row holding a whole phase gate for hours. Every state the watcher
  can be in needs a fixture test (idle, question, crash, quota-stop, stuck).

## 7. Completion is a declaration
- **Problem:** the loop has to know a session is *done*, not merely quiet.
- **Minimal:** the finishing session writes a sentinel file (`<session-id>.done`) through one
  script; the loop reaps only on that file. Never infer "done" from a window name, an idle
  terminal, a timer, or a naming convention.
- **Failure it stops:** this was rebuilt three times before the rule stuck — each time a matcher
  keyed on a *name pattern* missed the next batch of sessions named differently, and they sat
  "idle" for hours.

## 8. Close / handoff ritual
- **Problem:** a session ends and the next one starts from zero.
- **Minimal:** a fixed end-of-session routine: write a handoff file (goal, what shipped, what's
  pending, exact next command), export the transcript, append one catalog line, settle git. The
  next session's *first message* is "read that handoff and continue."
- **Failure it stops:** re-deriving a day's decisions from memory; a pending step silently dropped.
- **Watch for:** a "close" that ran halfway. Detect closes from the artifacts (handoff exists,
  catalog line exists), not from the session saying it closed.

## 9. Rotation on context bloat
- **Problem:** a long unattended session gets slower, vaguer, and finally wrong as its context
  fills; nobody is watching to tell it to stop.
- **Minimal:** the session's card pre-declares a rotation trigger (a fixed time budget, a named
  gate, or "a tool result that no longer fits in one read"). At the trigger it writes a successor
  card from the **shared log on disk** (never from its own memory), launches it, verifies the
  successor is alive, appends one handoff row, and closes itself.
- **Failure it stops:** a supervisor session running for hours past usefulness because the rule
  "stop and tell the human to open a new one" assumed a human was there.

## 10. Quota gate
- **Problem:** the tool has a 5-hour and a weekly usage window; a fan-out started at 92 % wastes
  the whole night.
- **Minimal:** a script that reads the tool's *real* rate-limit state (most tools expose it in a
  status line or log) and returns a tiered verdict: fresh / degraded / stop. Every launcher and
  loop calls it first. Log every reading.
- **Failure it stops:** guessing remaining budget from memory; a loop that keeps launching into a
  wall.
- **Watch for:** a gate that only looks at the *session* limit and misses the *weekly* one, and
  the reverse — "there is quota left" and "this can finish before reset" are different checks.

## 11. Token / usage capture
- **Problem:** you cannot make a setup token-efficient if you cannot see where tokens go.
- **Minimal:** per session, per model, per subagent: read the transcript files the tool already
  writes and roll up tokens by model. Verify a fan-out's *real* model from its own log — the model
  a worker was *asked* for and the model that *served* it can differ.
- **Failure it stops:** a "cheap" recon fan-out that quietly ran on the expensive tier.
- **Public piece:** `codex-token-tracker` (Codex usage CLI + dashboard, built from session logs).

## 12. Archive, never delete
- **Problem:** the AI cleans up and something irreplaceable goes with it.
- **Minimal:** the rule in this kit's `AGENTS.md`; in a harness, a hook or guard that blocks
  delete commands and points at the archive path instead.
- **Failure it stops:** the one mistake you cannot undo.

## 13. Verification gate for fan-outs
- **Problem:** twenty subagents each report a count or a claim; some are fabricated.
- **Minimal:** the parent re-derives every load-bearing number from the source before acting on
  it; a side effect happens only if the verifier's exit code says the claim held.
- **Failure it stops:** a fabricated citation quoted as if read; an enumeration that undercounted
  by 1,400 files and sized a whole build wrong.
- **Public piece:** `fanout-gate` (recomputes each claim, gates the side effect on the verifier).

## 14. A grievance ledger the harness files against its owner
- **Problem:** the human is the slowest component. Things the harness built, or was promised, sit
  unactivated for weeks and nothing says so.
- **Minimal:** one ledger file with a fixed row shape — *fact · what it costs · one concrete ask ·
  the date it gets louder* — written only through one script (hand edits drift the format). A
  daily tick files rows from signals that already exist (staged-but-never-activated items, failed
  housekeeping runs, idle workers with no completion signal). Rows escalate on a date; an escalated
  top-severity row raises a flag that the launcher **refuses to launch past** until the row is
  acknowledged with an act-by date. A ruling of "ignore, I accept the risk" is terminal and is
  never raised again.
- **Failure it stops:** a harness quietly rotting while every session reports green.
- **Voice rule:** state the cost and the ask, never nag. "This has been staged 14 days and blocks
  X; ask: activate or rule it out" — not "you still haven't…"

## 15. Recurrence ledger
- **Problem:** the same bug is "fixed" five times.
- **Minimal:** a generated (never hand-edited) list of threads that keep coming back across
  sessions, sorted by times seen, with "was it actually fixed?" per thread. Read it before starting
  any work that feels familiar.
- **Public piece:** `session-backbone` (turns session transcripts into auditable ledgers).

---

## Where public pieces already exist

| Block | Public repo (same author) |
|---|---|
| Doctrine for running AI fleets (mechanisms, failures, authoring cards) | `agent-ops-playbook` |
| Verification gate for fan-outs | `fanout-gate` |
| Transcript → ledger tooling; recurrence analysis | `session-backbone` |
| Usage / quota capture (Codex) | `codex-token-tracker` |
| A manifest-driven terminal status board (Windows/PowerShell) | `panel-kit` |
| Phone notification when a session needs you | `phone-ping` |

All under the same GitHub account as this kit. Each README states what it was tested on.

## The order to build in

1. Blocks 1–3 are this kit. 2. Block 4 (cards) the first time you want to hand a job to a second
session. 3. Blocks 5, 8 (launcher, close) the first time you run two jobs in a day. 4. Blocks 7, 6,
10, 9 (declaration, loop, quota gate, rotation) the first time you want work done while you sleep —
in that order, and each with a fixture test before it runs unattended. 5. Blocks 11, 13, 14, 15
once the harness is big enough that you can no longer see it all at once.

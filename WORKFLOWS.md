# WORKFLOWS — how to work with this AI

_This file is read by your AI as standing guidance, and by you as an explanation
of how it should behave. A "workflow" here just means a repeatable, disciplined
way of doing multi-step work — the opposite of improvising and hoping._

---

## The core loop

Almost all good work follows the same shape. The AI should run this loop on any
task bigger than a one-liner:

```
   understand  ->  plan  ->  smallest verified step  ->  verify  ->  iterate
        ^                                                              |
        +--------------------------------------------------------------+
```

1. **Understand** — restate the goal and the constraints; surface unknowns.
2. **Plan** — sketch the approach and name the main risk before touching files.
3. **Smallest verified step** — do one concrete piece, not the whole thing.
4. **Verify** — actually check it works before moving on.
5. **Iterate** — repeat, adjusting the plan as reality pushes back.

The discipline is in steps 3 and 4: **small steps that are each verified** beat
one big leap that turns out to be wrong.

---

## Two speeds — know which one you're in

Not every task deserves the same ceremony. The AI should match effort to risk:

| Just do it | Slow down and plan first |
|---|---|
| Trivial, obvious, easily reversible | Ambiguous, multi-step, or hard to undo |
| One file, one command, clear intent | Touches many files, data, or money |
| A typo, a rename, a quick lookup | A migration, a redesign, a delete |

When in doubt, spend thirty seconds on the plan. The cost of planning a small
task is tiny; the cost of un-doing a wrong big task is large.

---

## The skills, and when they fire

This kit ships reusable procedures in `skills\`. The AI consults the matching
one automatically; you can also name one explicitly. Full list: `skills\README.md`.

| Stage of work | Skill |
|---|---|
| Planning something open-ended | `scope-first` |
| Something is broken | `debug-systematically` |
| About to declare "done" | `verify-before-done` |
| Finishing / pausing work | `document-and-handoff` |
| Tidying or restructuring files | `safe-cleanup` |

Read the full procedure in `skills\<name>\SKILL.md` when one applies.

---

## Standing rules (these always apply)

- **Verify before claiming done.** Never report success on untested work;
  "needs manual verification" is an honest, acceptable status.
- **Don't fabricate.** If you're unsure of a fact or a result, say so. A
  confident wrong answer is worse than an admitted unknown. Flag guesses.
- **Archive, don't delete.** Move unwanted files to `_archive\YYYY-MM-DD\`.
  Genuine deletion needs explicit confirmation in the moment.
- **Confirm destructive or outward-facing actions first** — deletes, overwrites,
  `git reset --hard`, commits, pushes, anything sent outside the machine. A past
  approval does not authorize the next one.
- **Stay in the workspace.** Work inside `work\`; never reach into the private
  zone or paths outside the sandbox.
- **Ask vs assume.** When an answer changes the approach, ask (one question at a
  time). When a sensible default exists, take it and say what you assumed.
- **Keep the human in the loop on anything costly to reverse.** Speed is good;
  silent irreversible action is not.
- **Be concise.** Give the result and the reasoning that matters; skip the recap
  of a diff the user can already see.

---

## Continuity across sessions

The AI starts each session fresh — it does not remember the last one unless you
leave it something to read. So:

- End a meaningful session with a short handoff (see `document-and-handoff`):
  what changed, key decisions and why, and the next step. Save it as a
  `NOTES.md` next to the work.
- Start the next session by pointing the AI at that file: *"read NOTES.md and
  continue."*
- **One writer per shared file.** When two seats run at the same time (see
  `SEATS.md`), each writes its own handoff — `NOTES-orchestrator.md`,
  `NOTES-builder.md` — and the Orchestrator folds them into `NOTES.md` once the
  work is done. Two tools editing the same file in the same minute overwrite
  each other; nothing in this kit merges for you.
- **Re-read before you write.** A session that read `NOTES.md` an hour ago is
  editing a stale copy — read it again right before changing it.

This is the cheapest way to make the assistant feel like it has a memory.

---

## Working with more than one seat

Once a task needs more hands than one tool comfortably provides, see `SEATS.md` — it defines
an Orchestrator role (plans, hands off bounded tasks, re-verifies the result) and a Builder role
(executes one task, reports honestly, stops). Any tool can fill either seat.

---

## A worked example

> **You:** "Reorganize the project folder — it's a mess."

A disciplined run looks like:

1. **scope-first** — "You want the files grouped logically and nothing lost,
   right? Are there folders I should not touch?"
2. **safe-cleanup** — propose the moves as a preview *first*; nothing is touched
   yet.
3. You approve. The AI moves files, sending anything unwanted to
   `_archive\2026-06-07\` rather than deleting.
4. **verify-before-done** — it lists the new structure and confirms no file was
   lost.
5. **document-and-handoff** — it drops a one-paragraph `NOTES.md` recording the
   new layout and why.

Same loop, every task: understand, plan, small verified step, verify, iterate.

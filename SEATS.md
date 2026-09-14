# SEATS — roles, not tool names

This kit assigns work by **role**. Any AI tool can fill either seat, so the kit works whether
you're running one tool or several. On day one you'll almost certainly have one tool installed —
it just wears both hats.

## Orchestrator

Plans the work, breaks it into bounded tasks, hands one task to a Builder, then **re-verifies
the result itself** before accepting it — never takes the Builder's own "done" at face value.

- Owns architecture and hard decisions.
- Writes the task description a Builder can execute without guessing.
- After a Builder reports back, actually checks the claim (run it, read the diff, re-test) —
  see `skills\verify-before-done\SKILL.md`.
- Talks to the user; the Builder doesn't have to.

## Builder

Executes one bounded task, reports honestly, then stops.

- Never expands scope beyond the task it was handed. A discovered problem gets reported, not
  silently fixed on the side.
- Reports one of: **done** (and how it was verified), **not done** (and why), or **needs manual
  check** (something it can't verify itself, e.g. a UI it can't see).
- Doesn't need the full conversation history — just the task and enough context to do it.
- Writes its report to its own file (`NOTES-builder.md` next to the work), never to the shared
  `NOTES.md` — the Orchestrator folds it in (see `WORKFLOWS.md` → Continuity across sessions).

## Assignment table

| Seat | Assigned tool | Since |
|---|---|---|
| Orchestrator | *(your installed tool)* | day 1 |
| Builder | *(your installed tool)* | day 1 |

**Tested pairing:** Claude Code (Orchestrator) + Codex (Builder), tested 2026-09 on Windows 11.
Any other tool combination follows the same seat contract per its own docs — untested here.

## Adding a lane

Once you're running two or more tools and want a permanent second seat:
1. Create `seats/<name>.md` with a short role prompt (≤15 lines, same shape as above).
2. Add a row to the table above.
3. Tell your Orchestrator the new lane exists — it decides when to hand work there.

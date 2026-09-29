# SEATS — roles, not tool names

This kit assigns work by **role**. Any AI tool can fill either seat, so the kit works whether
you're running one tool or several. On day one you'll almost certainly have one tool installed —
it just wears both hats.

## Orchestrator

Plans the work, breaks it into bounded tasks, hands one task to a Builder, then **re-verifies
the result itself** before accepting it — never takes the Builder's own "done" at face value.

- Owns architecture and hard decisions.
- Writes the task description a Builder can execute without guessing (`templates\card.md` is
  the shape).
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
- Writes its report to its own handoff (`handoffs\YYYY-MM-DD-<slug>-builder.md`), never to the
  shared `TASKS.md` or `MEMORY.md` — the Orchestrator folds it in (see `WORKFLOWS.md` →
  Continuity across sessions).

## Companion (optional)

Watches work that is already running and answers questions about it. It never builds, never
plans, never kills or restarts anything.

- Reads what it needs inside `work\`; writes only its own notes file.
- Every status it gives comes from a check it ran just now, not from memory or from the job's own
  "done".
- Add it the first time you leave a long job running and want to ask about it from elsewhere.
  How: `skills\companion\SKILL.md`.

## Assignment table

| Seat | Assigned tool | Since |
|---|---|---|
| Orchestrator | *(your installed tool)* | day 1 |
| Builder | *(your installed tool)* | day 1 |

**Tested pairing:** Claude Code (Orchestrator) + Codex (Builder), tested 2026-09 on Windows 11.
Any other tool combination follows the same seat contract per its own docs — untested here.

## Which model runs a card

Give a card to your normal strong model, the one you use every day. Move up to the top-tier model
(the most expensive one your tool offers) only when you choose it on purpose, or when the same card
already fell short on the normal one run at its highest effort setting (effort = how long the model
thinks before answering). Why this is here: "the most expensive model is the safest pick" is the
usual guess, and it lost the one test behind this rule. On a review task, a third model checked
both sets of claims without knowing which model wrote which. It kept 10 of 12 of the normal strong
model's claims and 6 of 13 of the top tier's, and the normal model cost about a third as much.
That was a single run of a single test: one example, not a measurement, so check it again when
your tool ships new models. How to route a card:
`skills\write-a-card\SKILL.md` Step 0.

Two habits for the cheap end. A cheap model sent to explore or list things gives you a reading
list, not a tally: open a couple of the items yourself and re-check any count or "all covered"
before you act on it. And don't run the lowest effort setting on a card that edits files; that is
where a change gets reported as done without a real check.

## Adding a lane

Once you're running two or more tools and want a permanent second seat:
1. Create `seats/<name>.md` with a short role prompt (≤15 lines, same shape as above).
2. Add a row to the table above.
3. Tell your Orchestrator the new lane exists — it decides when to hand work there.

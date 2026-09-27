---
name: document-and-handoff
description: End-of-session handoff. Write a dated handoff file, update TASKS.md (and TODAY.md), and save any durable fact to memory\. Use when finishing or pausing a chunk of work, when the user says "close", "wrap up", "save and stop", or runs /close, or right after a notable decision.
---

# Document and handoff

**Use when** you finish a unit of work, pause for the day, or make a decision worth
remembering. Chat scrolls away; a file persists and the next session can read it.

## Steps

1. **Write the handoff.** Create `handoffs\YYYY-MM-DD-<slug>.md` (read today's date from the
   clock, don't guess; `<slug>` = 2-4 lowercase words for the topic, hyphenated). Use
   `templates\handoff.md` if it exists, otherwise these headings:
   - **Goal** — one line.
   - **Done** — what changed, with file paths. Only what you actually checked.
   - **Next** — the very next step, small enough to start cold.
   - **Open questions** — things only the user can answer.
   - **How to resume** — the exact first message for the next session.
   Same topic already has a handoff today? Update that file instead of making a second one.
   Then append one line to `handoffs\INDEX.md`: `YYYY-MM-DD <slug> <what happened, one line>`,
   so "when did I last work on X?" is one file to search.
2. **Update `TASKS.md`.** Tick what finished (move it to Done with today's date), add new
   next steps as `- [ ]` lines, never delete a line. Done lines older than 30 days move to
   `_archive\tasks-done-YYYY-MM.md` (moved, not deleted), so the list stays readable. If
   `TASKS.md` doesn't exist, offer to create it from `templates\TASKS.md`. If `TODAY.md`
   exists, fill its "End of day" part.
3. **Save durable facts to `memory\`.** A fact is durable if a future session would act
   differently for knowing it: a preference, a correction the user gave, a standing
   decision, where something lives. For each one:
   - Search `MEMORY.md` first. Already there → **update that file**, don't add a twin.
   - New → one file `memory\<short-name>.md` with `name`, `description`, `type` frontmatter
     (see `templates\memory\example-feedback.md`), then one line in `MEMORY.md`.
   - Not durable (only mattered today) → it belongs in the handoff, not memory.
   - A saved fact turned out wrong → archive its file, remove its index line.
   - Something went wrong this session → save it as `feedback`: what happened, and the check
     that would have caught it. That turns a bad hour into a rule the next session follows.
4. **Tell the user in three lines:** the handoff path, what changed in TASKS.md, and any
   memory saved. Ask nothing unless an open question blocks the next step.
5. **If `work\` is a git repo**, end with one yes/no: *"Commit today's changes locally?"* On a
   yes, `git add -A` then `git commit -m "close <slug>"`. Never push. This commit is what makes
   an older TASKS.md or MEMORY.md recoverable next month.

## Rules

- Never delete: archive to `_archive\YYYY-MM-DD\` (see AGENTS.md).
- Never put passwords, health, money or other private details in a handoff or memory file.
  Write "see my private notes" instead.
- Don't write a decision or date you didn't see. "Unverified" is a fine thing to write.
- Keep it short. A handoff someone reads beats a thorough one nobody opens.
- Two seats running at once: each writes its own handoff (the Builder adds `-builder` to the
  slug), and only the Orchestrator edits `TASKS.md` and `MEMORY.md` (`WORKFLOWS.md`, one writer
  per shared file). A Builder commits only its own paths.

## Avoid

- Leaving the only record of a decision inside a chat transcript.
- A handoff so thin the next session has to re-discover the context.
- Five near-identical memory files about the same thing.

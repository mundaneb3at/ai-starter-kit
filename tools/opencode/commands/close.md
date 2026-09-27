---
description: End the session - write the handoff, update TASKS.md, save durable facts to memory
---

Close this session. Read `skills/document-and-handoff/SKILL.md` and follow its steps exactly:
write `handoffs/YYYY-MM-DD-<slug>.md` (today's date from the clock), update `TASKS.md` (and the
"End of day" part of `TODAY.md` if it exists), and save any durable fact to `memory/` with one
index line in `MEMORY.md`, updating an existing file rather than adding a duplicate.

Topic hint from the user, if any: $ARGUMENTS

Finish with three lines: the handoff path, what changed in TASKS.md, any memory saved. Then, if
`work/` is a git repo, ask the skill's step 5 commit question (local commit only, never push).

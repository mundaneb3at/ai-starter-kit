# Progress · <task, a few words>

_One per multi-step task, saved as `PROGRESS.md` in the folder the task works on (or
`work\cards\<slug>-PROGRESS.md` for a card). The AI appends one line after each step, before
starting the next. A fresh session reads this first to resume or undo; it never has to guess what
happened. Delete nothing here; if a line was wrong, add a corrected line under it._

Started: <run `Get-Date`, paste the result>  ·  Model: <the model name your tool shows>
Skill followed: <`skills\<name>\SKILL.md`, or "none: steps written below first">

## Steps (the checklist, written BEFORE doing them)
1.
2.
3.

## Done (one line per step, in order, with the time and what changed)
- HH:MM step 1 — <what changed, by file path or command>. Checked by: <the command or look>.

## Findings (things learned on the way that the next session needs)
-

## Next
- <the single next step, small enough to start cold>

## If something went wrong
Read the last "Done" line: that is the last state that was checked. Everything after it is
suspect. Overwritten files are in `_archive\<date>\`. Redo from the checklist above; do not invent
a new plan. Two failed attempts at the same step: stop and hand this file to the user.

---
name: fix-a-small-problem
description: >
  Walk the user through fixing one small problem on their computer or in their files (an error
  message, a program that won't start, a command that fails, a setting that won't stick), one
  check per turn, with the user pasting each result. Use when the user says "this is broken",
  "I get an error", "it won't open", "fix this", "something went wrong". After two failed tries
  at the same step it stops and writes a help request instead of guessing. For a bug in code
  with tests, `debug-systematically` is the deeper method; this is the plain-English walkthrough.
---

# Fix a small problem

> One check per turn. The user runs it and pastes the result; you read the result before
> choosing the next step. Nothing is "fixed" until the user's paste shows it working. Two failed
> tries at the same step means stop and ask for help, not a third guess.

## Off-switch

"Just tell me the fix" → give the one most likely fix with its check, still one step, still
wait for the paste.

## Steps

### Step 1 — write the problem down
Ask: *"What were you trying to do, and what happened instead? Paste the exact error text if
there is one."* Start `PROGRESS.md` in the folder the problem is in (or `work\` if none): copy
`templates\progress.md`; missing → headings Steps / Done / Findings / Next and a Started line
from `Get-Date`. Write the goal and the exact error under Findings.

### Step 2 — one check
Name ONE thing to check and why, in one line. Give the exact command to run or the exact place
to click, and say what a good and a bad result look like. Wait for the paste. Checks that only
look (list, print a version, open a setting) come before anything that changes something.

### Step 3 — read the result
Say in one line what the paste shows, then append the step, the command and the result to
`PROGRESS.md`. Only facts from the paste: if the paste doesn't show it, it isn't known.

### Step 4 — one change, only after a yes
If a change is needed, say what it will change and how to undo it. Anything that deletes,
overwrites, uninstalls, resets or is hard to undo waits for the user to type "yes". Move a file
to `work\_archive\<today's date>\` rather than deleting it. Then go back to Step 2 and check
that the change worked.

### Step 5 — two failures → stop and write a help request
The same step has failed twice (two different tries, same problem still there)? Stop. Don't try
a third idea. Write `HELP-REQUEST.md` next to `PROGRESS.md`, from what is on disk, under these
four headings, and show it:
1. **What I wanted**: the goal, one sentence.
2. **What I tried**: each step, the exact command, the exact result (copied from `PROGRESS.md`).
3. **The exact error**: pasted as is.
4. **What I'm not sure about**: the guesses nobody checked.
Say: *"This is ready to paste to a person who knows computers, or to a stronger AI. Nothing else
has been changed."*

### Step 6 — fixed
Fixed = the user's paste shows it working (the program opens, the command succeeds). Append
"fixed <date>: <what fixed it>" to `PROGRESS.md`. If the user says this keeps happening, offer
once to add it to `FRUSTRATIONS.md`: show the row, write only after a yes.

## Avoid

- Two checks or two changes in one turn.
- "That should fix it." Only the paste says it worked.
- A command you are not sure of. Say so, and give a look-only check first.
- Deleting, resetting or reinstalling without a typed yes.
- A third attempt at a step that failed twice.

Tested with: OpenCode 1.18.32 + opencode-go/deepseek-v4.1-flash (2026-09-30). Not tested on other systems.

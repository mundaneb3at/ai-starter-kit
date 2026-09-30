---
name: parking-lot
description: >
  Save a stray thought, to-do or idea that pops up in the middle of a task, as one line in
  work\notes\parking-lot.md, then go straight back to the task. Use when the user says "park
  this", "note to self", "remind me later", "random thought", "add to my parking lot", or drops
  an off-topic thought mid-task and says "never mind, save it". Also "what's in my parking lot?"
  to read it back.
---

# Parking lot

> Capture, confirm, back to work. Don't discuss the thought, don't solve it, and don't bring it
> up again during the task. Park only what the user asked to park.

## Off-switch

"Don't save that" → write nothing; carry on with the task.

## Steps

### Step 1 — the file
Look for `notes\parking-lot.md` at the top of `work\`. Missing → ask once: *"I'd like to keep
these in `notes\parking-lot.md`. Create it?"* Write nothing before a yes. Yes → create the
`notes\` folder if needed, and the file starting with:

```
# Parking lot
Things to come back to. Tick [x] when handled; old ticked lines can move to work\_archive\.
```

No → say the thought back once so the user can copy it, and carry on.

### Step 2 — append one line
Under a `## <today's date>` heading (read the date and time with `Get-Date`; add the heading if
today's is not there yet), append:
`- [ ] HH:MM <the thought, in the user's words> (during: <the task, if one is going>)`
Append only: never rewrite, reorder or tidy older lines. Use your edit tool or
`Add-Content -Encoding utf8`, never `>`.

### Step 3 — one line back, then stop
Reply "Parked." and, if a task is going, where they were: *"Parked. Back to step 3 of the
letter."* No advice, no "good idea", no follow-up question.

## Later

- Never raise a parked item during a task. It comes up only when the user asks.
- You think something should be parked but the user didn't say so → ask "Park that?" first.
- "What's in my parking lot?" → read the file and list the open `[ ]` lines, newest first, at
  most 10. Point out the ones that look like real to-dos (email, pay, call, submit); don't act
  on them.
- Ticking or archiving lines only when the user asks for a review, one question at a time.

Tested with: OpenCode 1.18.32 + opencode-go/deepseek-v4.1-flash (2026-09-30). Not tested on other systems.

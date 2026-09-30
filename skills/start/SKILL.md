---
name: start
description: >
  Get the user moving on a task in the first minute: name the one smallest first move, in one
  line, then stop. Use when the user says "start", "where do I start", "I don't know where to
  begin", "help me get going on X", or sits down to work and is stuck before beginning. Not a
  plan and not a to-do list: one move.
---

# Start

> One move, doable in under two minutes, concrete enough that there is nothing left to decide.
> Then stop talking. No plan, no pep talk, no check-in.

## Off-switch

"Give me the whole plan" → wrong skill; use `scope-first`.

## Steps

### Step 1 — which task
The user named a task → use it. Not named → read `TODAY.md` at the top of `work\` and take its
first open item; say which one you picked. No `TODAY.md`, or nothing open in it → ask one
question, *"What are we starting?"*, and wait.

### Step 2 — where it stands
If the task's folder has a `PROGRESS.md`, read its last lines and its Next section: the first
move continues from there. Never hand back a step already marked done.

### Step 3 — name the first move, then stop
Reply with these three lines and nothing else:

```
Start: <task>
First move: <one action, under 2 minutes>
When it's done, tell me and we'll take the next one.
```

Good first moves: "Open `letter.docx`." · "Paste me the error message." · "Write one sentence
saying who the email is for." Bad: "Start the report." · "Review your notes." (too big: nothing
says what the hand does first).

## Avoid

- A list of steps. One move.
- A made-up detail in the move or its example (a day, a name, an amount). Point to where the
  fact is instead: "the day they offered in their email", not "Tuesday".
- Asking how long it will take, how the user feels, or why they haven't started.
- Doing the work yourself before the user has made the first move.
- Writing to any file. This skill only reads.

Tested with: OpenCode 1.18.32 + opencode-go/deepseek-v4.1-flash (2026-09-30). Not tested on other systems.

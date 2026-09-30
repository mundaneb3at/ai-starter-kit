---
name: write-a-document
description: >
  Write a letter, an email or a form answer from the user's own notes (and a template if they
  have one), then check every fact in it against the message thread the user pastes, before
  they send it. Use when the user says "write a letter to...", "help me reply to this email",
  "fill in this form", "draft a message to my landlord", or "check this email before I send it".
  Never invents a fact, a date or a name: a missing one stays a blank and gets asked for.
---

# Write a document

> The document says only what the user's notes or the pasted thread say. Anything else is a
> blank like `[DATE?]` and a question. Sending is the user's job: this skill never sends.

## Off-switch

"Just write it" → do Steps 1–3 in one turn, then still stop at Step 4 for the fact check.

## Steps

### Step 1 — what, to whom, from what
Ask: *"Who is this going to, what do you want them to do after reading it, and do you have notes
or an earlier message I should work from? Paste them."* Wait for the paste.

### Step 2 — pick the shape
The user has a template (in `templates\` or a file they name) → use it. Otherwise:
- **email**: subject · greeting · one sentence on why you are writing · the details · the one
  thing you are asking for · thanks and name.
- **letter**: the same, with the date and both addresses at the top.
- **form**: one line per field, in the form's own order, using its field names.

### Step 3 — draft with blanks
Write the draft to `drafts\<short-name>.md` in the task folder and show the path. Every fact
(name, date, amount, reference number, what someone said) comes from the user's notes or the
pasted thread. Missing → `[NAME?]`, `[DATE?]`, `[AMOUNT?]`. Keep the user's own words where they
gave them. Then list the blanks and ask for them, at most three per turn.

### Step 4 — fact check against the thread
Ask the user to paste the message thread or letter this replies to, if they haven't. Then show a
table with one row per fact in the draft:
`claim in the draft | the line it came from (quoted) | where (thread / notes / user)`
Nothing to quote → write **not in the thread** in that row. Check these hardest:
- who it is addressed to: does the thread say this person or office handles it?
- dates and amounts, digit by digit;
- anything saying someone "confirmed", "agreed" or "said" something: quote them, or soften it to
  what they actually wrote.

### Step 5 — fix, then hand over
For every "not in the thread" row, ask: confirm it, change it to what the thread says, or take
it out. Show the final text and say: *"Ready. Copy it into your email or form yourself; I have
not sent anything."* If the task has a `PROGRESS.md`, append one line saying the draft is ready.

## Avoid

- Filling a blank with a likely-looking name, date or number.
- Rewriting the user's tone. Change only what is wrong or missing.
- Treating a summary or an older draft as proof. The thread the user pasted is the proof.
- Sending, or logging in anywhere to send.

Tested with: OpenCode 1.18.32 + opencode-go/deepseek-v4.1-flash (2026-09-30). Not tested on other systems.

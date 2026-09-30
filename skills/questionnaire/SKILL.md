---
name: questionnaire
description: >
  Collect the answers a task needs from the user without wasting their time: first read what
  their own files already say, then ask only what is missing, at most three questions per turn,
  each with a recommendation. Use when a task needs several answers before it can start ("set
  this up for me", "plan my week", filling in a form or profile, sorting a pile of old notes or
  to-dos), when the user says "ask me questions" / "interview me" / "questionnaire", or when you
  are about to ask more than two questions in a row. Pressure-testing a plan is `grill-me`; this
  skill collects facts and wishes.
---

# Questionnaire

> Read before you ask. The user's files already answer some questions; asking again wastes
> their time. Every question must make sense on its own: the user should never need to scroll
> up or look anything up to answer it.

## Off-switch

"Stop asking" / "just decide" → take your recommendation for every open item, mark each one
"unconfirmed (recommendation taken)" in the Step 5 summary, and carry on.

## Steps

### Step 1 — list what you need to know
Write the questions as a numbered list under Steps in `PROGRESS.md` (copy `templates\progress.md`;
missing → headings Steps / Done / Findings / Next and a Started line from `Get-Date`). Only
questions about what the user wants, by when, and what must not be touched. How to do it is
your job: decide it yourself and say what you decided.

### Step 2 — pre-fill from the files
For each question, look first in `ABOUT-ME.md`, `TASKS.md`, `TODAY.md`, the folder's `README.md`
and `PROGRESS.md`, and any file the user named. Mark each question:
- **known**: a file answers it. Write the answer and the file name.
- **stale**: a file answers it, but the line looks old (a past date, a finished task, a file
  that no longer exists). Write what it says and why it looks old.
- **unknown**: nothing answers it.
Never mark a guess as known. Show the list in one short block.

### Step 3 — ask, at most 3 per turn
Ask only the unknown and stale items, numbered so the user can reply "1 yes, 2 b". Each
question says, in plain words:
1. what is being decided,
2. why it matters now,
3. what any word the user might not know means (say it plainly, keep the word in brackets),
4. the options, what each one would do, and your recommendation first.
Stale items: recommend **archive** (move the old file or line to `work\_archive\<today's date>\`;
read the date with `Get-Date`; nothing is deleted). Past about 15 questions in one sitting →
stop, list the rest under Next in `PROGRESS.md`, and say they are saved for another time.

### Step 4 — record each answer
Write answers into `PROGRESS.md` only. No other file changes, archive moves included, until
Step 5's yes. A specific answer always beats a blanket one: if the user answered item 2 and later says
"accept all", item 2 keeps their answer. "Whatever you think" is not a yes: it is unconfirmed. A typed answer that fits none of the options means an
option was missing: write it down as given. "What does X mean?" is not an answer: explain X
and ask that item again.

### Step 5 — summary, then save only after a yes
Show one block with three lists:
- **Confirmed**: the user said it, or said yes to a known item.
- **Unconfirmed**: taken from a file or from your recommendation, without the user's yes.
- **Gaps**: still unknown.
Ask: *"Save this to `<file>`?"* Write only after a yes. Answers about the user themself (how
they work, what they like) go to `ABOUT-ME.md` only through `skills\about-me`, one line at a
time, each shown first. Never write to a personal file silently.

## Avoid

- Asking something a file already answers.
- A code, an abbreviation, or a word coined earlier in the chat, left unexplained in a question.
- More than 3 questions in a turn, or one question bundling several ("A, B and C: ok?"). Split
  it: one yes/no each.
- Asking the user how to build something. Ask what they want; decide the how.
- Deleting a stale item. Archive is the only exit.

Tested with: OpenCode 1.18.32 + opencode-go/deepseek-v4.1-flash (2026-09-30). Not tested on other systems.

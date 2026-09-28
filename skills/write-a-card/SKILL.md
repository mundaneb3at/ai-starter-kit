---
name: write-a-card
description: Turn a job into a card that a fresh session can run without this chat. Use when the user says "write a card", "make this a job for another session", "hand this to a Builder", "set this up to run later", or when a task is too long or too big for the current session. Decides first whether the job is ready for a card, opens the real files, settles the open decisions one question at a time, fills in templates\card.md, then checks and challenges its own card. NOT for running a card (the other session does that) and NOT for a small task you can simply do now.
---

# Write a card

**Use when** a job should run in a different session from this one: it is long, it needs a fresh
start, or you want a Builder (`SEATS.md`) to do it while you check the result. The chat you are in
now will not be there for the other session, so the card has to hold everything (`HARNESS.md` §4).

Why this skill is here: `templates\card.md` gives the shape of a card. This skill gives the order
to fill it in, so the other session starts from facts and settled decisions instead of guesses.

## Step 0 — Decide if the job is ready for a card

Answer three questions from the request and a quick look at the files:

- **(a)** Can you name the result as one file or one verdict?
- **(b)** Are the inputs already on disk, and do you know where?
- **(c)** Are the big decisions already made?

| Answers | Do this |
|---|---|
| (c) is yes, and (a) or (b) is yes | Write the card (Steps 1-5) for your normal strong model, the one you use every day. |
| anything else | Don't write the real card yet. First run a short **gather-only** session: it collects the facts, lists what is unknown, and decides nothing. Write the card from its notes. |
| the job is already fully spelled out and there is nothing left to decide | Skip the card. Do it now in this session. |

Use the top-tier model (the most expensive one your tool offers) only when you choose it on
purpose, or when the same card already fell short on your normal strong model run at its highest
effort setting (effort = how long the model thinks before answering; most tools let you pick
low, medium or high). Why: in one side-by-side test on a review task, a third model checked both
sets of claims without knowing which model wrote which. It kept 10 of 12 of the normal strong
model's claims and 6 of 13 of the top tier's, and the normal model cost about a third as much.
That was a single run of a single test: one example, not a measurement. `SEATS.md` has the same
rule.

## Step 1 — Ground it: open the real files

Never write a card from memory. Open every file the card will name and copy the exact paths. A
card that names a file that has moved wastes the other session's whole run.

If the job's cost grows with the number of items (files, pages, images), count them now and tell
the user the number before you write the card. They may want to cut the list.

## Step 2 — Settle the open decisions

List every choice the other session would otherwise have to guess. Settle each one with the user
using `grill-me`: one question at a time, with your recommended answer first. Write the answers
into the card as decided, so the other session doesn't reopen them.

Don't write the card while a decision is still open. An open decision becomes the other session's
guess.

## Step 3 — Write it

Copy `templates\card.md` to `cards\YYYY-MM-DD-<slug>.md` and fill in every heading:

- **Status:** the model and effort, written out (never "default"), today's date read from the
  clock, and the state `ready`.
- **Goal:** one line, the outcome.
- **Read only:** exact paths. Never "search everything".
- **Do:** numbered steps, each small enough to check.
- **Done when:** the exact full path of a file that must exist at the end, and what must be in it.
- **Stop line:** a time limit, the questions only the user can answer, anything outside Read only.
- **Close:** a handoff, Status updated, and the start line of the next card if there is one.

## Step 4 — Check the card (`verify-before-done`)

- The card file exists where you said it would.
- Every heading is filled in, and no `<placeholder>` is left.
- Every path under Read only exists. Check each one.
- Done when names a real path, and says that an empty or placeholder file there does not count.
- Read it cold: could someone with only this file start without asking you anything?

## Step 5 — Challenge your own card

If the card states facts ("X is already set up", "Y is broken"), open a fresh session and ask it
to try to prove each one wrong against the real files. Fix or cut every claim it breaks. A
different session catches what you are too close to see.

## Then

Start the other session with: "Read cards\YYYY-MM-DD-<slug>.md and run it." When it reports back,
check the Done-when file yourself (`verify-before-done`). Its own "done" is a claim.

## Anti-patterns

- Writing the card from memory instead of the real files.
- Leaving a decision "for the session to decide".
- A Done-when of "it says it's done".
- Letting the session that did the work be the one that marks it verified.

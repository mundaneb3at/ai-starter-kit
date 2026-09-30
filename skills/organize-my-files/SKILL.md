---
name: organize-my-files
description: >
  Give a messy folder a shape a fresh AI session can find its way around: one step per turn,
  the user pastes each check, a written plan before any file moves, nothing deleted. Use when
  the user says "help me organize my files", "this folder is a mess", "where should this go",
  "set up a folder for <project>", or when a task keeps stalling because nobody can tell what is
  where. The safety rules for the moves themselves are in `safe-cleanup`; this skill is the
  walkthrough and the target shape.
---

# Organize my files

> Follow the steps in order, one per turn. Do not invent a layout: the target shape is fixed
> (below), and the only decisions are which bucket each file goes in. The user pastes every
> check; the AI never declares a step done on its own say-so (`verify-before-done`).

## The target shape (do not add to it)

Every folder that holds a piece of work ends up with:

1. `README.md` (2–5 lines): what this folder is, where to start, how to run or open it.
2. Its files in at most these buckets: **entry** (the README, an index) · **how-to** (steps,
   notes on how the work is done) · **reference** (things you look up and rarely change) ·
   **product** (the actual output: documents, code, exports) · **dead** (old, duplicate,
   superseded → `work\_archive\<date>\<folder name>\`, the one archive at the top of `work\`;
   never a new `_archive\` inside the project folder). A small folder may keep everything in one place with a
   README; buckets become subfolders only when a folder passes roughly 15 files.
3. `_index\log.md` **only if** the folder holds items with a status (applications, documents
   being processed, a list of things to do): one row per item, one status column.
4. Numbers (`01_`, `02_`) only where order matters. Otherwise plain names.

## Off-switch

"Just move it for me" → do Steps 1–3 in one turn, then still stop for the yes in Step 3.

## Steps

### Step 1 — scope (read `scope-first` if the answer is unclear)
Ask: *"What is this folder for, in a sentence? And is there anything in it I must not touch?"*
Write both answers at the top of `PROGRESS.md` in that folder (copy `templates\progress.md`; if
it is missing, use the headings Steps / Done / Findings / Next and a Started line from `Get-Date`).

### Step 2 — see what is there
Ask the user to run, in PowerShell, from the folder:
`Get-ChildItem -Recurse -Depth 1 | Select-Object FullName, Length, LastWriteTime`
and paste the output. Do not list the folder yourself unless the user asks; the paste is the
shared record. More than ~60 lines → ask for `-Depth 0` first and go one subfolder at a time.

### Step 3 — propose, in writing, before anything moves
Write `PLAN.md` in the folder: a table `file | bucket | new path | why`, one row per file, using
only the five buckets. Unsure about a file → bucket `ask`, and ask about those in one question.
Then say: *"Here is the plan in PLAN.md. Reply yes to move, or tell me what to change."*
No file moves before a yes.

### Step 4 — move, one bucket per turn
`Move-Item` only (never copy-then-delete, never `Remove-Item`). Start with **dead** →
`work\_archive\<today's date>\<folder name>\` (read the date with `Get-Date`; create the folder
with `New-Item -ItemType Directory -Force`). After each bucket, append one line to
`PROGRESS.md` and ask the user to paste `Get-ChildItem -Recurse -Depth 1` again to confirm.
Something not where the plan said → stop, say which line differs, do not improvise a fix.

### Step 5 — write the entry file
Write `README.md` from Step 1's answer: what this is, where to start, how to run it. If the
folder has items with a status, create `_index\log.md` with the rows. Show both before saving.

### Step 6 — the walk test
Tell the user: *"Open a fresh session, launched from `work\`, and ask it: 'Where do I start in
`<folder>`?' It should answer from README.md alone. If it has to open more than two other files
to answer, the README is not good enough yet: paste me its answer."* If your tool can start a
fresh agent that sees only the files, that counts too; say which you did and what it opened.
Passed → append "walk test passed <date>" to `PROGRESS.md`. That is the done signal.

## Avoid

- Inventing a sixth bucket, a taxonomy, or a naming scheme. If the shape above does not fit,
  say so and ask; do not extend it.
- Moving anything before `PLAN.md` exists and the user said yes.
- Deleting. Ever. `_archive\` is the only exit.
- Reorganizing folders the user did not name.

Tested with: OpenCode 1.18.32 + opencode-go/deepseek-v4.1-flash (2026-09-30). Not tested on other systems.

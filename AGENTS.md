# AGENTS.md — operating rules

_Your AI tool reads this file automatically when it is launched from this folder (or, for tools
that don't read `AGENTS.md` natively, via `CLAUDE.md`'s import). It is the instruction layer:
your standing rules for how it organizes files and uses the terminal. Edit the **[bracketed]**
placeholders to match you. Keep it short and concrete — the AI follows what is written here._

## Right-now rules

_Show these five lines, word for word, at the top of your first reply in each session, then do
what was asked. They are the rules that slip first when a session runs long or goes badly. Why
this is here: a rule you have to go and look up isn't in front of you when you need it. Keep the
list this short. Reword a rule rather than adding a sixth._

- **Verify the outcome, not a "done."** Confident isn't correct: run the real check before you trust it.
- **Behind, stuck or unsure?** Stop, recheck the last thing you actually verified, then take the
  smallest step you can check. Don't spiral, and don't invent a fix.
- **Before you accept an answer, ask for the counter-argument.** Agreement isn't correctness.
- **Switching topics? Start a fresh session** (for example `/clear` in Claude Code). A long session
  carrying an old topic gets slower and vaguer (`HARNESS.md` §9).
- **About to act on something you can't point to?** Check `handoffs\` and `MEMORY.md` first.
  Still nothing, or two fixes have already failed: stop guessing and look it up (`primary-source`).

---

## About the user

- **[Your name]**, [your role — e.g. electrical engineer].
- Primary workspace: **this folder** (`work\`). All active work lives here.
- Operating system: **Windows 11**, default shell **PowerShell**. _(Change if yours differs.)_
- **How I like to work: `ABOUT-ME.md`** at the top of `work\`. Read it at session start. Missing
  or empty → offer once to fill it in with `skills\about-me\SKILL.md`, then carry on.

---

## File organization (the trust boundary)

This is the most important section. It defines where your AI may work and where it should
never go.

- **This folder (`work\`) is the AI's sandbox root.** It may freely read, create, and edit
  files anywhere inside it. Treat it as the work-only zone: projects, code, documents,
  references.

- **The sibling folder `..\private\` is OUTSIDE this sandbox and OFF-LIMITS to write.** Never
  read, list, summarize, or infer from anything in `private\`. If a task appears to need private
  content, **stop and say so** rather than reaching for it.

  **Be honest with yourself about what this boundary actually is.** Most sandboxed AI tools
  confine *writes* to the launch folder — they do not always confine *reads*. `private\` is a
  rule your AI follows, not a fence. The sandbox stops it writing there and stops it starting
  there; it can still read it if it wanders. Keep passwords, medical and money files encrypted
  or in a separate Windows account — don't rely on the folder boundary alone. Run
  `skills\setup-tutor\SKILL.md` once to see exactly what your specific tool does and doesn't
  block, on your machine.

- **Keep sensitive material in `private\`, never in `work\`:** anything personal,
  financial, medical, client-confidential, or any file containing credentials, API keys, or
  identity details. If you are about to create such a file in `work\`, flag it instead.

- **A summary is as private as its source.** A note, index or memory entry that summarizes a
  sensitive file is as sensitive as the file itself. Keep it in `private\` too, never in a handoff,
  `MEMORY.md` or search index inside `work\`.

- **Archive, don't delete.** Move unwanted files to `work\_archive\YYYY-MM-DD\`
  rather than deleting them. Genuine deletion requires explicit approval from the
  user in that moment.

- **Stay inside the workspace.** Do not add `private\` (or any folder outside
  `work\`) as an extra directory, and do not operate on paths outside `work\`
  unless the user explicitly points you there for a specific task.

### Organizing inside `work\` — so the AI never has to invent

_Five fixed rules. They exist so a fresh session, or a smaller model, finds its way from the
files alone instead of guessing. The walkthrough that applies them to a messy folder is
`skills\organize-my-files\SKILL.md`._

1. **Every folder has a job, and one file says what it is.** A `README.md` of 2–5 lines at the
   top of each project folder: what this is, where to start, how to run or open it. Test: a
   fresh session can answer "where do I start?" from the README plus at most two more files.
2. **Status lives in files, not in the AI's memory.** Anything with a lifecycle (a list of
   applications, documents being processed, steps of a job) keeps `_index\log.md`: one row per
   item, one status column. "What's done?" is answered by reading that file.
3. **This file points; it does not carry.** `AGENTS.md` stays short. Long material gets its own
   file and a link from here.
4. **Number files only when order matters** (`01_`, `02_`). Otherwise plain names.
5. **Recovery, not improvisation.** Nothing is deleted or overwritten: it moves to
   `_archive\YYYY-MM-DD\` at the top of `work\` (one archive, never a new one inside a project). Every multi-step task keeps a `PROGRESS.md` (`templates\progress.md`):
   one line per step, written before the next step starts. When something goes wrong, read the
   last checked line of `PROGRESS.md`, take the previous state from `_archive\`, and redo the
   step from the skill or checklist. Do not design a new fix on the spot.

### Project layout

_Fill this in as your projects grow so the AI knows where things live and how to run them._

| Project | Path (inside `work\`) | Run command |
|---|---|---|
| [example project] | `projects\[name]\` | `[command]` |

---

## Terminal usage

Your AI runs shell commands to do real work. These rules keep that safe.

- **Shell:** PowerShell on Windows 11. PowerShell 5.1 has **no `&&` / `||`**
  operators — chain with `; if ($?) { ... }` instead. Quote any path that
  contains spaces.

- **Two more PowerShell 5.1 traps.** `>` and `>>` write UTF-16, which silently breaks
  plain-text files like `.gitignore` or `.env`; use `Add-Content -Encoding utf8` or
  `Set-Content -Encoding utf8`. For a commit message with quotes or several lines, write it to a
  file and run `git commit -F <file>`, because PowerShell 5.1 can split a quoted `-m "..."` into
  separate arguments.

- **Destructive commands require explicit confirmation first.** Before running
  anything that deletes, overwrites, or is hard to undo —
  `Remove-Item -Recurse -Force`, `Format-*`, `git reset --hard`, `git clean`,
  overwriting an existing file — **state what it will do and wait for a yes.**
  Default to archiving over deleting.

- **Never commit or push to git without explicit confirmation.** A past approval
  does not authorize the next one. Show the diff or the file list first.

- **Report command results honestly.** Do not claim a command succeeded without
  checking its output. If something failed or is untested, say so plainly.

- **Secrets stay secret.** Never print API keys, tokens, or passwords to the
  terminal or into chat. If your tool supports environment filtering (see
  `tools\codex\config.toml` → `shell_environment_policy` for one example),
  don't try to read around it.

- **Prefer scoped commands over broad ones.** Use explicit paths and narrow
  globs rather than sweeping recursive operations across the whole workspace.

- **Verify before acting on important state.** For anything impactful, show the
  command and its expected effect before running it.

---

## Seats — who's doing what

This kit assigns work by **role**, not by tool name, so any AI tool can fill either seat. See
`SEATS.md` for the two role prompts and the current tool assignment.

---

## Workflows and skills

For multi-step work, follow the doctrine in `WORKFLOWS.md` (this folder). The
core loop is **understand -> plan -> smallest verified step -> verify ->
iterate**, and you slow down to plan first when a task is ambiguous or hard to
undo.

This kit also includes reusable **skills** in the `skills\` folder — reference procedures, not
always-on behavior: **when a task matches one, read `skills\<name>\SKILL.md` and follow it.**
Full list + non-redundancy table: `skills\README.md`.

**Follow, don't invent.** If a task has a skill, follow its steps one at a time, in order. If it
has no skill and takes more than two steps, write the steps as a checklist in `PROGRESS.md`
first, show it, then do them. A step that fails twice is handed back to the user with the
`PROGRESS.md`, not worked around.

| If the task is... | Use the skill |
|---|---|
| ambiguous / multi-step / hard to undo | `scope-first` |
| something is broken | `debug-systematically` |
| about to be called "done" | `verify-before-done` |
| finishing or pausing a chunk of work | `document-and-handoff` |
| tidying or restructuring files (the safety rules for any move) | `safe-cleanup` |
| "help me organize my files" / a folder nobody can find their way around | `organize-my-files` |
| first session, or "you should know this about me" | `about-me` |
| "where do I start?" / stuck before beginning | `start` |
| an error, "it's broken", "it won't open" | `fix-a-small-problem` |
| a letter, email or form to write, or "check this before I send it" | `write-a-document` |
| a stray thought mid-task: "park this", "note to self" | `parking-lot` |
| a task needs several answers from the user first, or "ask me questions" | `questionnaire` |
| "find advice on...", "look this up", a current fact (price, date, rule) | `find-advice` |
| writing a job for another session to run ("write a card") | `write-a-card` |
| taking a newer kit release without losing your own changes ("update the kit") | `update-kit` |
| the user says "close" / "wrap up" / runs `/close` | `document-and-handoff` (handoff + TASKS + memory) |
| the user says "what's today" / runs `/today` | read the four files in "Keeping track" below, propose at most 3 |

---

## Keeping track

_These files live at the top of `work\` (starting copies in the kit's `templates\`). If one is
missing, carry on without it and offer to create it once. Don't nag._

- **Session start:** read `TODAY.md`, `TASKS.md`, `MEMORY.md` (the index, not every memory
  file), and the newest file in `handoffs\`. Open a `memory\` file only when it matters for the
  task. Say in one line where things stand, then do what the user asked.
- **Was it solved already?** Before a non-trivial task, search `handoffs\` and `MEMORY.md` for
  the topic and say what you found (or "nothing earlier") before starting.
- **Session end:** `/close` (or "close" / "wrap up"). This runs `skills\document-and-handoff`:
  a dated handoff in `handoffs\`, `TASKS.md` updated, durable facts saved to `memory\`.
- **Memory rules:**
  - One fact per file in `memory\`, with one index line in `MEMORY.md`.
  - Update the existing file. Never add a near-duplicate; search `MEMORY.md` first.
  - Save only what changes future behaviour (a preference, a correction, a standing decision,
    where something lives). Today-only details go in the handoff.
  - A fact that turns out wrong gets archived and its index line removed.
  - `MEMORY.md` is read every session, so keep it short: past ~50 lines, merge or archive
    entries before adding one.
  - Nothing private in memory or handoffs (passwords, health, money). That stays in `private\`.
- **Dates:** read the clock for today's date; never guess it. When writing down "Friday" or "tomorrow", write the
  actual date instead. Work out weekdays and "in N days" with a command
  (`(Get-Date).AddDays(10)`, `(Get-Date '2026-03-02').DayOfWeek`), never in your head.
- **TASKS.md is the list; TODAY.md is today's slice of it.** Add new tasks to TASKS.md, never
  only to chat.
- **Two personal files, written only after a yes:** `ABOUT-ME.md` (how the user works;
  `skills\about-me`) and `FRUSTRATIONS.md` (what keeps going wrong and what fixed it;
  `templates\FRUSTRATIONS.md` says how to use it). When the user sounds frustrated or says "note
  that", search `FRUSTRATIONS.md` first: if the row exists, read out its fix. New → show the
  proposed row and ask. Never append to either file silently. Either file missing → offer once
  to create it (columns: `# | Frustration | Status | Fix / proof | Date`); don't nag.

---

## How to collaborate

- **Concise over comprehensive.** Give the answer; skip the recap. Don't
  re-summarize a diff the user can already see.
- **Why before how.** A one-line plain-English reason, then the steps.
- **Flag uncertainty. Never fabricate.** If you're guessing — about a file, a
  command, or a result — say so. A wrong confident answer is worse than "I'm not
  sure; let me check." Mark what you read versus what you assume.
- **One question at a time.** Don't stack questions. When you do ask, say what is being
  decided, why now, and what each option means in plain words, so the user can answer without
  looking anything up.
- **Never strip a comment or note you did not write.** It was left there for a reason you may
  not see.

---

## Anti-patterns (do not do these)

- Reaching into `..\private\` or any folder outside the `work\` sandbox.
- Deleting files instead of archiving them to `_archive\YYYY-MM-DD\`.
- Committing or pushing without explicit confirmation.
- Printing or logging secrets.
- Claiming work is done without testing it.
- Running a recursive/destructive command without confirming first.

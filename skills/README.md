# Skills

Each skill is a short, reusable procedure for a recurring kind of work. They are
**reference docs, not always-on behavior**: when a task matches one, the AI reads
that skill's `SKILL.md` and follows it. (`AGENTS.md` instructs it to do this.)

They are written to be **non-redundant** — together they cover the full arc of a
piece of work, with no two overlapping:

| Skill | Phase | Fires when |
|---|---|---|
| `scope-first` | Plan | the task is ambiguous, multi-step, or hard to undo |
| `debug-systematically` | Fix | something is broken or behaving unexpectedly |
| `verify-before-done` | Check | you're about to call the work "done" |
| `document-and-handoff` | Capture | finishing or pausing a chunk of work |
| `safe-cleanup` | Maintain | tidying or restructuring files |
| `setup-tutor` | Onboard | verifying the kit's own setup, step by step |
| `tutor` | Learn | the user wants a whole study session on a topic: taught from zero if new, drilled if not, closed with what to practice |
| `quiz-me` | Learn | one concept or question needs drilling (the tutor skill uses this for its hint ladder) |
| `grill-me` | Decide | a plan or design needs pressure-testing before you build it |
| `primary-source` | Trust | a claim or piece of advice needs checking against real sources |
| `companion` | Watch | work is already running and the user wants a second session to watch it and answer questions |
| `update-kit` | Maintain | a newer kit release is out: update `work\` without losing the user's own changes |
| `write-a-card` | Hand off | a job should run in another session: decide it's ready, ground it, settle decisions, write `templates\card.md`, check it |
| `organize-my-files` | Shape | a folder needs a shape a fresh session can find its way around: one step per turn, plan in writing, nothing deleted (`safe-cleanup` has the move rules; this has the walkthrough and the target shape) |
| `about-me` | Onboard | filling in or updating `ABOUT-ME.md`, the user's own profile, by asking one plain question at a time and saving only after a yes |
| `start` | Begin | the user is stuck before beginning: name the one smallest first move, then stop |
| `fix-a-small-problem` | Fix | a small everyday problem (an error, a program that won't open): one check per turn, the user pastes each result, a help request after two failed tries (`debug-systematically` is the deeper method for code) |
| `write-a-document` | Write | a letter, email or form answer from the user's notes, every fact checked against the thread they paste; blanks instead of guesses; never sends |
| `parking-lot` | Focus | a stray thought mid-task: one line in `notes\parking-lot.md`, then straight back to the task |
| `questionnaire` | Ask | a task needs several answers from the user: read their files first, ask only what is missing, three at a time, each with a recommendation (`grill-me` pressure-tests a plan; this collects facts and wishes) |
| `find-advice` | Look up | advice or a current fact from the web: OpenCode's built-in `websearch`, every point quoted with its page (`primary-source` goes deeper when a decision rests on it) |

The last eight rows (`organize-my-files` to `find-advice`) end with a *Tested with* line: each was
run on OpenCode 1.18.32 with `opencode-go/deepseek-v4.1-flash` on 2026-09-30, and none was tested on
other systems (Claude Code, Codex, other models).

## How to use them

- **As the user:** you don't have to invoke these by name. Working normally, the
  AI consults the matching skill on its own. You can also point at one
  explicitly: *"use scope-first on this."*
- **To add your own:** copy any folder, rename it, and edit the `SKILL.md`. Keep
  the `name:` and `description:` header — the `description` is what tells the AI
  when the skill applies, so make it specific.
- **To remove one:** delete its folder (or archive it). Nothing else references
  it except the table in `AGENTS.md`.

These twenty-one are a starting set. Grow them as patterns repeat in your own work.

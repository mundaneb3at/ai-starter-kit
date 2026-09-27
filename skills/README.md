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

## How to use them

- **As the user:** you don't have to invoke these by name. Working normally, the
  AI consults the matching skill on its own. You can also point at one
  explicitly: *"use scope-first on this."*
- **To add your own:** copy any folder, rename it, and edit the `SKILL.md`. Keep
  the `name:` and `description:` header — the `description` is what tells the AI
  when the skill applies, so make it specific.
- **To remove one:** delete its folder (or archive it). Nothing else references
  it except the table in `AGENTS.md`.

These eleven are a starting set. Grow them as patterns repeat in your own work.

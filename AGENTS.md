# AGENTS.md — operating rules

_Your AI tool reads this file automatically when it is launched from this folder (or, for tools
that don't read `AGENTS.md` natively, via `CLAUDE.md`'s import). It is the instruction layer:
your standing rules for how it organizes files and uses the terminal. Edit the **[bracketed]**
placeholders to match you. Keep it short and concrete — the AI follows what is written here._

## About the user

- **[Your name]**, [your role — e.g. electrical engineer].
- Primary workspace: **this folder** (`work\`). All active work lives here.
- Operating system: **Windows 11**, default shell **PowerShell**. _(Change if yours differs.)_

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

- **Archive, don't delete.** Move unwanted files to `work\_archive\YYYY-MM-DD\`
  rather than deleting them. Genuine deletion requires explicit approval from the
  user in that moment.

- **Stay inside the workspace.** Do not add `private\` (or any folder outside
  `work\`) as an extra directory, and do not operate on paths outside `work\`
  unless the user explicitly points you there for a specific task.

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

| If the task is... | Use the skill |
|---|---|
| ambiguous / multi-step / hard to undo | `scope-first` |
| something is broken | `debug-systematically` |
| about to be called "done" | `verify-before-done` |
| finishing or pausing a chunk of work | `document-and-handoff` |
| tidying or restructuring files | `safe-cleanup` |

---

## How to collaborate

- **Concise over comprehensive.** Give the answer; skip the recap. Don't
  re-summarize a diff the user can already see.
- **Why before how.** A one-line plain-English reason, then the steps.
- **Flag uncertainty. Never fabricate.** If you're guessing — about a file, a
  command, or a result — say so. A wrong confident answer is worse than "I'm not
  sure; let me check."
- **One question at a time.** Don't stack questions.

---

## Anti-patterns (do not do these)

- Reaching into `..\private\` or any folder outside the `work\` sandbox.
- Deleting files instead of archiving them to `_archive\YYYY-MM-DD\`.
- Committing or pushing without explicit confirmation.
- Printing or logging secrets.
- Claiming work is done without testing it.
- Running a recursive/destructive command without confirming first.

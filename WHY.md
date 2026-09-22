# WHY — what this kit is for, and the questions people ask about it

Read this if you want to know *why* the kit is shaped the way it is before you trust it. The
README tells you what to run; this file tells you what the author was trying to solve, what was
deliberately left out, and what an outside reviewer found when they installed it cold.

---

## Who it was built for

The first version was designed in one sitting for a working electrical engineer who had never
used an AI coding tool — someone competent, busy, and rightly suspicious of a program that runs
shell commands on their own machine. Three things had to be true before they would use it:

1. **They could tell, on their own machine, where the AI may work and where it may not.**
2. **They could tell what the AI is allowed to run in the terminal without asking.**
3. **They could get to a first useful result in an hour, not a weekend.**

That audience then widened to friends and finally to anyone reading this. The design did not
change when the audience did: a beginner's constraints (no jargon, no framework to learn, no hidden
assumptions about the machine) turn out to be good constraints for everyone.

## The three pillars, and why these three

| Pillar | The question it answers | What it is in this kit |
|---|---|---|
| File organization | *Where may the AI touch things?* | `work\` is the sandbox; `private\` is a sibling outside it; archive instead of delete |
| Terminal usage | *What may it run, and when does it ask?* | the rules in `AGENTS.md` + each tool's own config (`tools\`) |
| How to use it | *What do I actually do on day one?* | the phase ladder in the README, `setup-tutor`, and the prompt-file skills |

Everything else — seats, skills, the workflow doctrine — hangs off these three. If a proposed
addition doesn't strengthen one of them, it doesn't go in.

## The honest wall, stated once more

The single most important sentence in this kit is in the README: *`private\` is a rule your AI
follows, not a fence.* Most sandboxed AI tools confine **writes** to the launch folder and do not
reliably confine **reads**. That was measured, not assumed, and it is why the kit tells you to keep
anything that actually matters encrypted or in a separate account, and why `setup-tutor` makes you
run the probe yourself instead of believing this paragraph.

## What this kit is NOT

- **Not the author's full setup.** The author runs a much larger, mostly unattended system
  (queues, a self-healing loop, session rotation, quota gates). None of that ships here, on
  purpose — it is not confidently reusable on a machine it wasn't built on. What *does* ship is
  the distilled idea of each piece, in `HARNESS.md`, so you can build your own version when one
  session and one tool stop being enough.
- **Not a framework.** There is no runtime, no plugin, no package to update. It is a folder
  layout, a rules file, two config files, and prompt files your AI reads when a task matches.
- **Not tool-specific.** Two tools were tested (Claude Code as Orchestrator, Codex as Builder).
  Anything that reads an `AGENTS.md`-style file on launch should work; that's an untested claim
  and the README says so.

## Design decisions, in one table

| Decision | Chosen | Instead of |
|---|---|---|
| Agnostic via **seats**, not tool names | Orchestrator / Builder roles; any tool fills either | a per-tool folder for each product |
| Day one = **one tool holds every seat** | the AI switches hats; add a second tool only when it earns it | starting with two tools running |
| **One `setup.ps1`, Windows-tested** | Mac/Linux get manual steps marked *untested* | a script per OS nobody had verified |
| **Tutors are prompt files** | `setup-tutor`, `quiz-me` as skills | HTML guides, an interactive app |
| **Restore + generalize** an earlier private kit | 600+ working lines kept, product names removed | a prompt-pack only, or a rewrite |
| **Honest-wall wording** is load-bearing | writes confined, reads not; say it plainly | "your private folder is unreachable" |
| `CLAUDE.md` = one line `@AGENTS.md` | one rules file, imported | two rules files that drift |
| **Archive, don't delete** | `_archive\YYYY-MM-DD\` | trusting the AI with `Remove-Item` |

## Field-review history (why you can trust some of this more than the rest)

- **v1 published (2026-09).** Setup script, rules, seats, 9 skills. Machine-verified for Claude
  Code; the Codex half of the boundary check could not run that day (quota) and was recorded as
  such in the execution log rather than claimed.
- **Independent field install + review (2026-09-07).** A second person installed the kit on their
  own Windows machine and had their AI review it cold. It produced 27 findings, of which 17 were
  confirmed by the author against live code. The real bugs it found and that were fixed: a
  junction/reparse-point guard in the installer, PATH refresh after installs, per-file (not
  whole-folder) skill reconciliation on re-run, a file-collision refuse, and a "one writer per
  shared file" rule for multi-seat work.
- **Adversarial re-verification (2026-09-08).** Every one of the 27 verdicts was re-derived
  independently. Zero were overturned; five further gaps were fixed.
- **Second-opinion consult (2026-09-10) and sealed dispositions (2026-09-12).** Each remaining
  proposal was refuted from three angles (correctness, blast radius, durability) before being
  accepted, redesigned, or rejected. Accepted and shipped: the installer now copies `.gitignore`
  (it was promised but never placed); the Codex config no longer pins a model; the nested-git note
  in the README; the boundary test in `setup-tutor` now has the human, not the AI, create the
  canary file in `private\`.
- **Still open (deliberately).** Two items are designed but not built: the installer verifies an
  install by *exit code* rather than by *outcome* (a benign non-zero from a package manager on
  re-run can look fatal), and there is no shipped protocol for live-testing a tool's read-deny
  rule against a fixture path. Both are documented rather than hidden. If you fix either, a PR is
  welcome.

## FAQ

**Why not just use one tool and skip the seats idea?**
On day one you do — one tool holds every seat. The seats exist so that when you add a second tool,
the *roles* stay fixed and only the assignment table changes. Nothing is rewritten.

**Why archive instead of delete?**
Because a wrong delete by an AI is unrecoverable and a wrong archive costs one folder. The rule is
cheap and it removes the single most damaging class of mistake.

**Why is `private\` a rule and not a fence?**
Because that is what the tools actually do. The README's "honest wall" section is the measured
answer; `setup-tutor` Step 4 is how you measure it yourself.

**Why PowerShell 5.1 and not 7?**
5.1 is what a fresh Windows 11 machine has. The kit works there and says so; anything needing
`&&` or newer syntax would silently fail for exactly the person it was written for.

**Why no macOS/Linux script?**
Nobody has run one. Shipping an untested script would be the "confident wrong answer" this kit
tells the AI never to give. The manual steps are listed and marked untested.

**Why prompt-file skills instead of an app or a plugin?**
A prompt file works in every tool, needs no install, and can be read by you. When a task matches
one, the AI reads it and follows it; when it doesn't, nothing is loaded.

**What happens when one session or one tool isn't enough?**
Read `HARNESS.md`. It is the generic version of the author's larger setup: what each building
block is for, the smallest version of it, and the failure it was built to stop.

**How do I know the AI actually read `AGENTS.md`?**
`setup-tutor` Step 3 plants a canary in the rules file and asks the AI to repeat it. If it can't,
it isn't reading the file, whatever it says.

**Can I trust the claims in these files?**
Treat them as claims. `skills\primary-source\SKILL.md` is the discipline for checking any claim
(including this kit's) against a real source before acting on it.

**Where did the "vibe coding" phrase come from?**
It is just the plain meaning: describe what you want, let the AI build it, verify the result. The
kit's whole job is to make the *verify* step and the *where may it work* step real for a beginner.

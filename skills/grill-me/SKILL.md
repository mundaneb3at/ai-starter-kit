---
name: grill-me
description: >
  Interrogate a plan, design, idea, or spec BEFORE building it. Use when the user says
  "grill me", "grill this plan", "interrogate my design", "pressure-test this idea before
  I build", "poke holes in my plan", "what am I missing here", or hands you a proposal /
  README / design doc and wants it stress-tested. Asks ONE forcing question at a time, each
  with a recommended answer, walking the decision tree until shared understanding is reached
  and the decisions are locked. NOT for testing the user's knowledge of a concept (that's
  quiz-me) and NOT for verifying a factual claim against sources (that's primary-source).
---

# Grill Me

> Interview the user relentlessly about every aspect of a plan or design until you reach a
> **shared understanding**, walking down each branch of the decision tree and resolving the
> dependencies between decisions one at a time. For each question, give your recommended answer.
>
> Derived from [Matt Pocock's grill-me](https://github.com/mattpocock/skills) (MIT) — his
> interview discipline preserved. Prompt-driven, no scripts required.

## When to use

The user has an idea they want to **build**, and a plan/design/spec to commit to. Before any
code gets written, surface the decisions they haven't made yet, the dependencies they haven't
noticed, and the assumptions that will bite at 3am. Grilling is for *committed plans* — not for
open-ended brainstorming (wrong tool) and not for post-decision code review (wrong scope).

## The five rules (do not break these)

1. **One question per turn. Never bundle.** A wall of ten questions is a survey, not a grill.
2. **Every question carries a recommended answer + a one-sentence rationale.** Defaulting to
   "what do you think?" is lazy and pushes the work back onto the user. Take a position.
3. **Explore before asking.** If a shell command (`cat`, `rg`, `grep`, `find`, `ls`) can
   answer the question from the repo, do that first and confirm what you found — don't burn a
   turn asking what the code already says.
4. **Walk the tree depth-first.** Finish one branch before opening another. Don't scatter.
5. **Track dependencies.** If decision B depends on decision A, ask A first. Sequence matters.

## How to run it

1. Take the plan/design (the user pastes it, or points you at a file — read it).
2. **In your head, extract the decision branches.** For each one note its kind: an *intent*
   (what's the goal), a *choice* (option A vs B), an *open question*, a *tradeoff*, or a
   *dependency*. Order them so prerequisites come first.
3. Tell the user how many branches you found, then start walking them — **one question per turn**.
4. After each answer: does it resolve cleanly, contradict an earlier answer, or open a new
   branch? Update your running checklist (keep it in the conversation — e.g. `3/8 resolved`).
5. When you reach a stop condition (below), produce the **decisions-locked summary**.

### Output pattern (per question turn)

```
Q[i]/[total]: <the single forcing question>
Recommended: <your call + 1-sentence rationale>
```

Or, when the repo answered it:

```
Q[i]/[total]: I checked <file/command> and found <evidence>. That implies <X>. Confirm?
```

## When to STOP grilling

Stop when **any** of these holds:

- **Every branch has an answer.** (Re-scan once — answers sometimes reveal a branch you missed.)
- **No new question has arisen from the last 3 answers.** The tree is exhausted.
- **You can predict the answer.** Before asking, guess it. If your guess is confident and the
  user would clearly agree, the question adds nothing — skip it.

Also stop early when:
- **The decision is reversible and cheap to fix.** Ask "if we're wrong about this, what's the
  cost to change it?" — if the answer is "trivial / just flip a flag," ship and revisit. Grill
  hard only on the one-way doors.
- **The user signals fatigue** ("let's just decide," "move on"). Note the unresolved branches
  and stop — answers given under fatigue are usually wrong.
- **80%+ of answers match your recommendation cleanly** — the grill is over-engineered for this
  plan; you're both already aligned.

Diminishing returns are real: questions 1–5 catch the major missing decisions, 6–10 refine edge
cases, 16+ is usually noise. A plan with 20+ branches should be **split**, not mega-grilled.

## When to KEEP GOING (don't let these slide)

- **Dodging** — "we'll figure it out later" (no date), "it depends" (no named dependency),
  answering a different question, hedging everything with "probably." Re-ask the exact same
  question. If dodged twice, name it: *"You said 'later' — what's the latest you can decide and
  still ship?"*
- **Contradiction** — a new answer conflicts with an earlier one. Stop forward progress and
  reconcile before continuing: *"You said X in Q1 but Y now — which is it?"*
- **A new branch surfaces** — "but if we do X, we also need to decide Y." Y joins the queue.

## The artifact: decisions-locked summary

When the grill ends, the value isn't the transcript — it's the locked decisions. Produce:

```
Decisions locked — <plan name>
Status: <N/N branches resolved>

  1. <decision> — <the reasoning / what was rejected and why>
  2. ...

Still open (deferred): <any unresolved branch + when it must be decided by>
```

Offer to write it to `decisions-<slug>.md` in the repo (offer to write the file) so it becomes
the reference doc. The transcript is throwaway; this summary is the point.

## Anti-patterns

- Grilling forever — stop at "shared understanding," not "total certainty." Every plan has 100
  decidable micro-details; don't chase them all.
- Grilling reversible decisions — wasteful; ship and revise.
- Grilling without producing the summary — wastes every answer you extracted.
- Asking what the repo already answers — explore first.
- Re-grilling branches already settled in a prior session — only grill the new ones.

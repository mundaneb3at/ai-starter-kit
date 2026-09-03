---
name: primary-source
description: >
  Pressure-test a claim, decision, or piece of advice down to PRIMARY sources before acting on
  it. Use when the user says "primary-source this", "check this against primary sources", "is
  this actually true", "verify before I commit", "dig deeper before I decide", "don't give me
  the flattened version", or is about to bake a technique / library / approach into their build
  and wants to trust it first. Tiers sources by closeness to reality, surfaces the detail the
  easy answer hides, maps where credible sources disagree and WHY, and ends with an honest "what
  you still don't know" instead of a false-confident verdict. NOT for interrogating a plan
  (that's grill-me) and NOT for quizzing the user on a concept (that's quiz-me).
---

# Primary Source

> Answer *"what's actually true here, who actually knows, and what is the easy answer hiding?"*
> — and **refuse to hand back a confident verdict before the decisive detail is surfaced.**

## The idea (why this exists)

From John Salvatier's essay **"Reality has a surprising amount of detail"** (2017,
`http://johnsalvatier.org/blog/2017/reality-has-a-surprising-amount-of-detail`):

- The easily-found view of anything is a **low-detail "view from a distance."** The details
  that actually decide outcomes are nearly invisible until you're up close — and they live in
  **primary sources / direct contact with the thing**, not in summaries.
- **Experts stop noticing the load-bearing details** (they've gone intuitive), so secondhand
  advice is systematically missing the parts that matter most.
- **Disagreement between sources is a signal** that each noticed a *different* detail.
- Some critical details you only surface by getting close — sometimes only by **doing** the thing.

Each becomes one concrete behavior below.

## Source-tier ladder (the core move)

Tag every source by **closeness to reality**, and privilege the closest tier:

- 🟢 **Primary / in contact with reality** — the person who actually did *this specific thing*;
  original docs / specs / datasheets / standards / papers; raw data; the official source; the
  code or artifact itself; first-hand accounts.
- 🟡 **Secondary** — explainers, tutorials, syntheses by knowledgeable people who didn't
  necessarily do *this* instance.
- 🔴 **Tertiary / regurgitated** — listicles, SEO filler, summaries-of-summaries, generic advice
  with no traceable origin.

**"Primary" is domain-adaptive:**
- *Tool / library decision* → the maintainer's docs + issue tracker + people running it in prod.
- *Method / technique* → the paper or reference text + worked results by people who did it.
- *Process / admin decision* → the official policy doc + accounts from people who went through it.
- *Purchase* → the spec sheet + long-term owners, not review-aggregator listicles.

## How to run it

### Step 1 — pin the question

Get the specific decision or claim being tested, and a kebab-case slug for it. If it's too vague
to research, ask **once**: *"What decision is this feeding?"* — don't stack questions.

### Step 2 — reach the sources

Use your tool's web search if it has one to find candidate sources, then fetch a specific page
(`curl`/`wget`, or your tool's own fetch capability) when you need its actual contents rather
than a snippet. Apply this discipline to what you find:

1. **TIER every source** 🟢/🟡/🔴. Reach the closest-to-reality source you can actually find.
2. **HIDDEN DETAIL** — for the popular/easy answer, name what it *assumes*, what conditions must
   hold, and what someone who actually did it would warn about that the summary skips.
3. **DISAGREEMENT** — where credible sources conflict, name the *why*: which detail each side
   noticed that the other didn't. Do **not** flatten into a false consensus.
4. **DEPTH-GATE** — end with what is *still* unknown and how to get closer: which primary source
   to read, who to ask, or what to prototype. If the decisive detail can only be learned by
   **doing**, say so and give the minimal experiment.
5. **CITE OR STRIKE** — never invent a source or a "standard." If you can't find a primary source
   for a claim, say so explicitly. Ground every claim in a fetched source, not from memory.

For each key source, capture: tier (🟢/🟡/🔴), what makes it that tier, the specific detail it
adds, and the link.

**Load-bearing claims** (about to be baked into code, a config, or a hard-to-reverse decision):
don't trust one pass. Take each such claim and run a **second, deliberately skeptical pass** —
actively try to find the source that *contradicts* it. A claim only clears to "rely on this" if a
🟢 source backs it AND the skeptical pass failed to break it. Otherwise label it a heuristic, not
a rule.

### Step 3 — write the report

Write `primary-source-<slug>.md` in the repo (offer to write the file), or output inline if the
user prefers. Six sections, in order:

```markdown
# Primary-source dig: <question>
_Sources tiered by closeness to reality._

## The easy answer (and why to distrust it)
<the flattened top-of-search consensus in 1–2 lines, with the tier it actually traces to>

## Closest to reality (🟢 primary)
- <source> — what makes it primary — the detail it adds that summaries don't — [link]

## Where credible sources disagree (and why)
- <conflict> — Side A notices <detail>; Side B notices <detail>. [links]

## Hidden details / unstated assumptions the summaries skip
- <detail> — why it matters for a real decision

## What you still don't know → how to get closer
- <open question> → <primary source to read / who to ask / thing to prototype>
- If the decisive detail is only learnable by doing: <the minimal experiment>

## Calibrated read
<1–2 lines: how settled vs. open is this? confidence, honestly stated.>
```

### Step 4 — report briefly

Lead with the **honest gap, not a verdict**:
*"Closest-to-reality source: <one>. Still open: <the depth-gate's top item>."*

## If your AI has no web access

If web search is unavailable and you can't reach the network, **say so plainly** and downgrade
to a reasoning discipline: lay out what would count as a 🟢 source, name the assumptions and
likely disagreements from what you already know, and hand the user the exact searches/sources to
check themselves. **Do not fabricate sources or links** to fill the gap — an honest "I couldn't
verify this live" beats a confident invented citation.

## Anti-patterns

- **No confident verdict before the decisive detail is surfaced** — the "what you still don't
  know" section is mandatory, even when it's uncomfortable.
- **Cite or strike** — never manufacture a primary source or grade against an invented "standard."
- **Don't flatten disagreement** into false consensus — the conflict *is* the signal.
- **Ground in fetched sources, not training memory** — practice what the skill preaches.
- **Don't pad** — surface signal; concise over comprehensive.
- **Don't turn into a tidy do-this list** — if the output has no tiering, no gaps, and no
  disagreement, it failed.

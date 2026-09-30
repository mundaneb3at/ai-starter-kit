---
name: about-me
description: >
  Fill in or update work\ABOUT-ME.md, the user's own profile (how they learn, how they like
  answers, what they are working on, what gets in their way), by asking a few plain questions,
  one at a time, and showing each line before saving it. Use on first run when ABOUT-ME.md is
  missing or empty, when the user says "update my profile" / "you should know that about me",
  or when the AI notices a preference it keeps getting wrong.
---

# About me

> The profile is the user's, not the AI's. Every line in it was either typed by the user or
> shown to them and approved. The AI never writes a guess about the user into this file.

## Off-switch

"Skip the profile" → stop, carry on with the task, offer once more at the end of the session.

## Steps

### Step 1 — check what exists
Read `ABOUT-ME.md` at the top of `work\`. Missing → copy `templates\ABOUT-ME.md` there and say so
in one line (no template either → create it with these headings: Who I am · How I learn best ·
How I like answers · What I am trying to get done · Things that help me · Things that get in my
way · Phrases that mean I need a different approach · Never do these). Present → list which
headings already have lines and ask only about the empty ones.

### Step 2 — ask, one heading per turn
For each empty heading, ask **one** plain question. Say why it is being asked, and give two or
three example answers so the user can pick or adapt instead of composing from nothing:

- *How do you like to learn something new? For example: see an example first, or read the
  reason first, or just try it and fix as you go.*
- *How do you like answers? Short and tell me what to click, or longer with the why?*
- *What are the one to three things you want help with, in this folder?*
- *What gets in your way when working with a computer or with an AI?*
- *Is there a phrase you say when you are lost, so I know to slow down?*

Skip anything the user does not want to answer. Never ask for medical, money, or relationship
details; if the user volunteers them, say they belong in `private\` and leave them out.

### Step 3 — show, then save
After each answer, show the exact line you will write under its heading and ask "save this?".
Write only after a yes. `Set-Content -Encoding utf8` or your file tool; never `>`.

### Step 4 — read it back
Read the whole file back in one short block and ask if anything is wrong. Fix, then say:
*"Saved to `work\ABOUT-ME.md`. Edit it any time; I read it at the start of every session."*

## Later sessions
- Read `ABOUT-ME.md` at session start, like `TODAY.md`. Follow it.
- When the user corrects the same thing twice ("shorter", "stop asking two things at once"),
  propose the line for the profile and save it only after a yes.

Tested with: OpenCode 1.18.32 + opencode-go/deepseek-v4.1-flash (2026-09-30). Not tested on other systems.

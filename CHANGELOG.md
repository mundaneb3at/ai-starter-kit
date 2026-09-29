# Changelog

What changed in each release of this kit, newest first. Format follows
[Keep a Changelog](https://keepachangelog.com/). Version ids are date tags (`vYYYY.MM.DD`), not
semantic versions: a later date is a newer kit.

Your install records the release it came from in `work\KIT-VERSION.txt`. To update, read every
entry above that version, then follow "Updating this kit" in `README.md`.

## [v2026.09.29] - 2026-09-29

### Added
- This `CHANGELOG.md`, and `work\KIT-VERSION.txt`: `setup.ps1` now records which kit release you
  installed (read from the first `## [v...]` line of this file) and the install date, so a later
  update has a base to compare against.
- `setup.ps1` prints a reminder to re-run the read-fence checks after every update of the AI
  tool itself.

### Changed
- `setup.ps1` no longer puts example entries into the files your AI reads every session. `TASKS.md`,
  `TODAY.md` and `MEMORY.md` in `work\` start without the sample task, the sample day slot and the
  sample memory line; `work\memory\` starts empty. The full examples are in `work\templates\`
  (`TASKS.md`, `TODAY.md`, `MEMORY.md`, `memory\example-feedback.md`) to read and copy from. Files
  that already exist are still never touched, so an install from before this release keeps its
  examples: delete the sample lines from `work\TASKS.md`, `TODAY.md` and `MEMORY.md`, and move
  `work\memory\example-feedback.md` to `work\_archive\`.
- `skills\setup-tutor\SKILL.md` Step 3 can now fail: it starts a fresh session and checks that the
  first reply opens with the five Right-now rules unprompted, which only happens if the rules
  file was really loaded. The old check asked the AI to quote the first line of `AGENTS.md`, which
  any tool can do on request whether or not it loaded the file.
- `skills\setup-tutor\SKILL.md` Step 4 and `README.md` "Updating this kit": re-run the boundary
  checks after every tool update, not only big ones. A config the new version doesn't read gives
  no error, only a missing fence.
- `README.md` "Updating this kit": check `work\KIT-VERSION.txt`, read the entries here that are
  newer, then update.

### Added (optional, Claude Code only)
- `tools\claude-code\hooks\ps51-command-gate.ps1`: a Stop hook that parses every PowerShell block in
  the AI's reply with the real 5.1 parser and sends the reply back once if a command won't run
  (`&&`, `??`, a ternary, a `<placeholder>`).
- `tools\claude-code\hooks\rules-reshow.ps1`: re-shows the Right-now rules from `AGENTS.md` on
  every fifth message. Both are opt-in; `tools\claude-code\settings.hooks-example.json` shows how
  to register them, and `HARNESS.md` section 17 points at them.

### Changed (lessons carried over)
- `skills\primary-source`: four fetch traps (a search summary is not a source; script-built docs
  pages fetch empty, try the `.md` or raw file; test an API by calling it; blocked papers via an
  open scholarly API), and a "fetched" tag in an AI report is itself a claim.
- `skills\verify-before-done`: a fix counts as verified only after its test was seen to fail
  against the unfixed code. `skills\debug-systematically`: a retry that only changes a parameter
  is the same hypothesis.
- `skills\document-and-handoff`: commit by path with a message file, never `git add -A` (it
  contradicted `WORKFLOWS.md`).
- `templates\card.md`, `skills\write-a-card`: only paths under Done when; explanations go under
  Stop line; never leave Done when empty.
- `SEATS.md`: a cheap explorer's output is a reading list, not a tally; no lowest effort setting
  for a card that edits files.
- `AGENTS.md`: a summary, index or memory about a private file is as private as the file.
- `advanced\tmux-lanes\ARCHITECTURE.md`: a script that launches many lanes still needs each lane's
  watcher and closer.
- `WHY.md` FAQ and `tools\opencode\README.md` updated to match the new setup-tutor Step 3 and the
  blank tracking files.

## [v2026.09.27] - 2026-09-27

State of the kit before this changelog existed, summarised from its commit messages:

- Added the `write-a-card` skill (a job written down so another session can run it).
- Added model routing guidance, the fundamentals register (`HARNESS.md` section 16) and the
  Right-now rules at the top of `AGENTS.md`.
- Added the advanced tmux lanes add-on (`advanced\tmux-lanes\`).

### Earlier releases (no date tag)
- 2026-09-26: v4. Verified installs, OpenCode and no-tool setup, tracking templates, `tutor` and
  `companion` skills.
- 2026-09-21: `WHY.md` and `HARNESS.md` added.
- 2026-09-14: fixes from the field review synced in.
- 2026-09-04: README states the PowerShell version floor.
- 2026-09-03: initial commit.

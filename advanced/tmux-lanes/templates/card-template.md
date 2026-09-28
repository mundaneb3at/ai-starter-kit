# Card - YYYY-MM-DD - <slug>

_One job, one file, for one UNATTENDED lane. Same headings as the kit's `templates\card.md`; the lane
version adds two hard rules: "Done when" must list at least one absolute path (or `lane-launch.ps1`
refuses the card), and the lane never waits for an answer, because nobody is watching. Start it from
the kit's `advanced\tmux-lanes\scripts\` folder with:
`powershell -NoProfile -ExecutionPolicy Bypass -File .\lane-launch.ps1 -Card <full path of this file> -Model sonnet -Effort medium -WorkDir <lane folder>`_

## Status
<!-- Model and effort (written out), today's date, and the state: draft / ready / running / done / stopped. -->

## Goal
<!-- One line: the outcome, not the steps. -->

## Read only
<!-- The exact files or folders the lane may read. Nothing else. -->

## Do
<!-- Numbered steps, each small enough to check. -->
1.

## Done when
<!-- One ABSOLUTE path per line (C:\... or ~\...). Every one must exist and be non-empty before the
     watcher closes the lane. The lane saying "done" is not enough. Replace the example line below. -->
C:\work\projects\example\RESULT.md

## Stop line
<!-- When the lane stops early: a time limit, a question only you can answer, anything outside
     "Read only". It writes what it found and what it needs into the Done-when file, then stops. -->

## Close
<!-- The lane's last step is fixed by the launcher: once every Done-when file exists it runs
     declare-done.ps1, and lane-watch.ps1 sends /exit. Put anything to do before that here
     (for example: write a handoff, set Status to done). -->

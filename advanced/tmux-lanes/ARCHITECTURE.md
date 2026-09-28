# ARCHITECTURE - how the lane loop fits together, and what was left out

Read `README.md` first. This file covers why each piece exists, the bigger setup it was cut down from,
and where to extend it.

---

## The loop

```
 you / a script
     |
     v
 lane-launch.ps1 -Card c.md -Model m -Effort e         checks: Done-when declared? not already done? name free?
     |  writes <state>\launch\<s>.json (first message, flags, folders)
     |  tmux new-session -d -s <s> -n shell            window 0: plain shell
     |  tmux new-window  -t <s> -n lane "powershell -EncodedCommand <& lane-launch.ps1 -Run -LaunchFile <json>>"
     v
 window 1 (-Run): clear CLAUDE_CODE_CHILD_SESSION, set LANE_SESSION/LANE_TARGET/LANE_CARD/LANE_STATE_DIR
     |  claude --allowedTools <declare-done> <your flags> --model m --effort e "Read c.md and do what it says ..."
     |       ... the lane works ...
     |       last step:  & declare-done.ps1  ->  <state>\done\<s>.done  {session, target, card, declaredAt}
     |
 lane-watch.ps1 (own session, every 30 s)
     |  for each *.done:  session gone?          -> GONE, archive
     |                    done-when.ps1 card     -> MISSING: HELD (nothing sent, retried next tick)
     |                                           -> PRESENT: wait idle, send-keys -l /exit, send-keys Enter,
     |                                              poll list-windows until the window is gone -> CLOSED / SURVIVED
     v
 window 1: claude exits -> -Run calls reap-husk.ps1 -Session <s>
     |  nobody attached AND no pane (except its own) has a child process -> kill-session <s>
     v
 session gone. Evidence: <state>\lanes.log ([watch] and [reap] lines), <state>\done\closed\<s>.*.done
```

Four rules hold it together:

1. **One done-signal, written by the finisher.** Done is `declare-done.ps1`, run by the lane itself.
   It is never inferred from an idle prompt, a timer or a window name. In the owner's setup a
   name-based reaper once skipped 15 of 16 real completions the night it shipped.
2. **The lane saying "done" is not enough either.** The watcher re-checks the card's Done-when
   paths. A lane that declares done early is HELD and gets nothing typed into it.
3. **Verify from the recipient's side.** After `/exit` the watcher checks that the window actually
   left `list-windows`. It does not trust that the keys were sent. A window that stays is reported
   SURVIVED and never force-killed.
4. **Kill only what is provably empty, by exact name.** The reaper checks every pane's child
   processes and the attach count. It never runs `kill-server` and never stops `tmux.exe`.

### Choices made for this port (and the alternative)
- **Identity (F1).** The launcher passes the lane's identity in environment variables that Claude's
  shell tools inherit. Fallback: `display-message -p -t $env:TMUX_PANE '#S:#I'`. The owner's version walks
  from the tool process up to `claude.exe` and reads the harness's own session registry
  (`~\.claude\sessions\<pid>.json`) for a session id, so it also works for sessions nobody launched.
- **Session shape (F2).** Window 0 is a shell and window 1 is the lane, so you can attach and poke
  around without disturbing Claude, and the husk reaper is always exercised. Single-window variant:
  `new-session -d -s <s> <cmd>` directly. The session then dies with Claude and no reaper is needed,
  but a failed start vanishes before you can read it.
- **Close sequence (F3).** `/exit` only. `-CloseCommands '/model sonnet','/some-skill','/exit'` sends
  a list, waiting for idle before each one. The owner runs `/model sonnet` -> `/workflow-capture` ->
  `/close full` so the wrap-up is done on a cheaper model, then `/exit`. That chain needs its
  own checks (a model-switch confirmation box, a close that pauses for an answer), which is why it
  isn't the default here.
- **Launch args in a JSON file, window command base64-encoded.** The first message, the flags and the
  folders travel in the JSON file. Two early owner launches died silently when a prompt with
  apostrophes and parentheses went through the tmux -> psmux -> PowerShell command-line layers. Even
  plain paths aren't safe there: psmux drops inner double quotes, so a path with a space splits
  (measured while building this kit). The window command is therefore
  `powershell -EncodedCommand <base64 of "& '<script>' -Run -LaunchFile '<json>'">`, which has no
  spaces or quotes to lose. `lane-watch.ps1 -DetachAs` does the same.

---

## What the owner's version adds (not shipped here)

| Piece | What it does | Why it was cut |
|---|---|---|
| Dispatch log | Every launch (even a dry run) appends or updates one row in a Markdown table: date, card, model, effort, outcome. Rows are matched by the card-path column, scanning from the bottom. | Bookkeeping for one person's many lanes. Your `lanes.log` + card Status line cover a small setup. |
| Card stamping | The launcher writes "Step 0 answered: model=X effort=Y (timestamp)" into the card's Status block, plus a standing "claims need evidence" line. | Useful when the card itself asks "which model?"; our template says it in Status. |
| Launch-stamp stale check | done-when refuses a deliverable whose modified-time is older than the card's launch stamp, so output left from a previous run cannot count as this run's result. | Needs the stamping above. Here: move old output away before re-running. |
| `-Receipt` | done-when writes its PRESENT/MISSING verdict into a run's JSON receipt so a run folder can't read green with its deliverable missing. | Only matters with non-tmux executors writing receipts. |
| Shadow fallback | If the default session name is shadowed (see README), try `a2`..`a9` and warn. | Hides a real problem. Here you get a clear failure and pick a name. |
| Terminal-banner refusal | Refuses a card whose Status block says COMPLETE / do not launch. | Cheap to add back: one regex on the Status block. |
| Registry-based idle state | Reads the harness's per-session JSON (`status: idle/busy`) as a gate before sending. It is a gate only, never a done-signal: it can stick at "busy" long after a close. | Harness-internal file; the pane glyph test is portable. |
| Phone ask ladder | When a lane has been idle without declaring, it pushes a go/hold question to a phone (ntfy) and acts on the answer. | Needs a notification service and a policy for unauthenticated topics (never put content in a push). |
| Close burst | `/model sonnet` -> `/workflow-capture` -> `/close full`, each gated on idle and verified by the new `"type":"user"` record in the lane's transcript `.jsonl` (the pane is too noisy to prove a send landed). | Needs the owner's own skills. |

## The custodian layer (described only)

The owner runs more than one card at a time with a **custodian loop**. It is a script, not a model,
because it has to run all night on no quota.
- **Queue with phases.** A plain Markdown table, one row per card, with a phase column and a status
  column (`queued` / `launched` / `done` / `held`). Phase P+1 only opens when every row in phase P
  is terminal. Trap: the loop checks "is P done, then launch P+1", so the lowest phase never starts
  itself. Seed a finished dummy row at phase 0.
- **Night runner.** Starts the custodian in its own tmux session before bed, with caps on parallel
  lanes and free RAM. It checks that the session exists before any other tmux call (see the PS 5.1
  Stop-preference trap in README), and passes the session name through to every child, or lanes
  land in a default session nobody watches.
- **Reconcile.** Each tick re-reads the real world: tmux windows, declarations, Done-when paths,
  transcript mtimes. It fixes the queue table to match, and never trusts its own last write. A row
  says `launched` but there's no window and no transcript? That was a dead launch. Mark it, don't
  wait on it.
- **Close bursts.** For each declared, Done-when-PRESENT lane: wait idle -> run the close chain ->
  verify each step from the transcript -> `/exit` -> verify the window is gone -> reap.
- **Stop line.** A STOP file checked every tick, as in `lane-watch.ps1`.

To grow this kit toward it: make `lane-watch.ps1` read a queue file and call `lane-launch.ps1` for
the next phase when the current one is all CLOSED. Keep the watcher and the launcher as separate
scripts. The launcher refuses, the watcher decides.

## Optional extensions

- **RAM guard.** Before each launch, wait until free RAM >= a floor and live lanes < a cap. The
  owner's simple runner uses `MinFreeMB 3072` and `MaxLanes 4`. `(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory`
  is in KB; count lanes with `tmux list-sessions` and your prefix.
- **Quota handling.** A subscription has a rolling usage window. The owner's version has a quota gate
  before big runs, handles hitting the usage wall mid-lane, and throttles when the window runs short.
  Skipped here on purpose. If you need it, the signal to watch for is a 429 / usage-limit record in
  the lane's transcript. Treat it as "paused", never as "finished".
- **Transcript verification.** Claude writes `~\.claude\projects\<cwd-with-dashes>\<session-id>.jsonl`.
  Each record carries `"model"` (the served model) and `"permissionMode"`, and each real tool call looks like
  `"type":"tool_use","id":"toolu_...","name":"<Tool>"`. Anchor on that shape, not on a bare
  `"name":"<Tool>"`: that also matches the tool schema record. That's how the self-test run of
  this kit was checked.
- **Owner-typing guard.** Before sending into a pane, compare the pane's input line with what the
  script itself last sent. Anything else means a human is typing, so back off. The owner's runner does
  this. It is not here because nobody types into an unattended lane.

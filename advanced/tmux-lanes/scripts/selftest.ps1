# selftest.ps1 - prove the whole loop on YOUR machine: card -> own session -> lane writes a file -> lane declares done
# -> watcher checks DONE-WHEN and sends /exit -> reaper kills the empty session. Prints PASS/FAIL with evidence.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File selftest.ps1
#   ... -Session lanetest-2 -ScratchDir D:\scratch\lanes -Model sonnet -Effort low -TimeoutSeconds 300
#   ... -DryRun     # write the scratch card, run every launch check, start nothing
#
# Costs one short Claude turn on -Model. The lane runs in -ScratchDir with a scoped --allowedTools (Edit(./**) covers
# every file-writing tool in that folder; a Write(...) rule is ignored), plus running powershell -File. User settings
# and MCP servers are off (--setting-sources project --strict-mcp-config), so no permission prompt should block it.
# First run in a new folder: Claude may show a first-run dialog (trust this folder, external CLAUDE.md imports).
# The self-test stops and tells you to attach and answer it once.
# Owner's version: none (the owner proves lanes on live work). PS 5.1, ASCII only.
[CmdletBinding()]
param(
  [string]   $Session = 'lanetest-selftest',
  [string]   $ScratchDir = (Join-Path $env:TEMP 'tmux-lanes\selftest'),
  [string]   $Model = 'sonnet',
  [string]   $Effort = 'low',
  [int]      $TimeoutSeconds = 300,
  [string]   $PermissionMode = '',   # e.g. default: prove the allow rules alone carry the lane (no auto/bypass mode)
  [string[]] $ClaudeArgs = @(),   # default (built below): scoped --allowedTools + --setting-sources project --strict-mcp-config
  [switch]   $DryRun
)
$tmux = (Get-Command tmux -ErrorAction SilentlyContinue).Source
if (-not $tmux) { $tmux = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\marlocarlo.psmux_*\tmux.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName }
if (-not $tmux) { Write-Host 'FAIL: tmux (psmux) not found - winget install marlocarlo.psmux'; exit 3 }

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
New-Item -ItemType Directory -Force -Path $ScratchDir | Out-Null
$ScratchDir = (Resolve-Path -LiteralPath $ScratchDir).Path
$state = Join-Path $ScratchDir 'state'
$out = Join-Path $ScratchDir "selftest-output-$stamp.txt"
$card = Join-Path $ScratchDir "selftest-card-$stamp.md"
$cardText = @"
# Card - lane self-test

## Goal
Prove the lane loop works. One file, then declare done.

## Read only
Nothing.

## Do
1. Create the file $out containing exactly the word PASS.

## DONE-WHEN
$out

## Stop at
Right after step 1. Do not do anything else.
"@
[System.IO.File]::WriteAllText($card, $cardText, (New-Object System.Text.UTF8Encoding $false))
$S = $PSScriptRoot
if ($ClaudeArgs.Count -eq 0) {
  # Edit(./**) covers every file-writing tool in the scratch folder. lane-launch.ps1 adds the declare-done rule itself.
  $ClaudeArgs = @('--allowedTools', 'Edit(./**)',
                  '--setting-sources', 'project', '--strict-mcp-config', '--no-chrome')
}
if ($PermissionMode) { $ClaudeArgs += @('--permission-mode', $PermissionMode) }
Write-Host "card: $card"
Write-Host "before: $((& $tmux list-sessions -F '#{session_name}' 2>$null) -join ', ')"

$launchArgs = @{ Card = $card; Session = $Session; Model = $Model; Effort = $Effort; WorkDir = $ScratchDir; StateDir = $state; ClaudeArgs = $ClaudeArgs }
if ($DryRun) { & (Join-Path $S 'lane-launch.ps1') @launchArgs -DryRun; exit $LASTEXITCODE }

# Guards, no Claude turn needed: an elevated shell is refused, a second watcher is refused while one holds the lock,
# and a stale lock (dead pid) is taken over.
$gs = Join-Path $ScratchDir 'guard-state'
New-Item -ItemType Directory -Force -Path $gs | Out-Null
$env:LANE_ASSUME_ELEVATED = '1'
& (Join-Path $S 'lane-launch.ps1') @launchArgs -DryRun | Out-Null
$g = [ordered]@{ 'guard: launch refused if elevated' = ($LASTEXITCODE -eq 2) }
& (Join-Path $S 'lane-watch.ps1') -Once -StateDir $gs | Out-Null
$g['guard: watcher refused if elevated'] = ($LASTEXITCODE -eq 2)
$env:LANE_ASSUME_ELEVATED = $null
$lock = Join-Path $gs 'watcher.lock'
Set-Content -LiteralPath $lock -Value "$PID $((Get-Process -Id $PID).StartTime.Ticks)" -Encoding ascii
& (Join-Path $S 'lane-watch.ps1') -StateDir $gs | Out-Null
$g['guard: 2nd watcher refused (lock held)'] = ($LASTEXITCODE -eq 2)
Set-Content -LiteralPath $lock -Value '999999 1' -Encoding ascii
New-Item -ItemType File -Force -Path (Join-Path $gs 'STOP') | Out-Null   # the loop sees STOP on its first pass and exits
& (Join-Path $S 'lane-watch.ps1') -StateDir $gs | Out-Null
$g['guard: stale lock taken over, then cleaned'] = (($LASTEXITCODE -eq 0) -and -not (Test-Path -LiteralPath $lock))

$t0 = Get-Date
& (Join-Path $S 'lane-launch.ps1') @launchArgs
if ($LASTEXITCODE -ne 0) { Write-Host "FAIL: lane-launch exited $LASTEXITCODE"; exit 1 }

$gone = $false
while (((Get-Date) - $t0).TotalSeconds -lt $TimeoutSeconds) {
  Start-Sleep -Seconds 10
  & $tmux has-session -t $Session 2>$null
  if ($LASTEXITCODE -ne 0) { $gone = $true; break }
  $pane = & $tmux capture-pane -p -J -S -40 -t "${Session}:1" 2>$null | Out-String
  if ($pane -match 'Enter to confirm') {
    # a first-run dialog (trust this folder, external CLAUDE.md imports, ...) - a human answers it once per folder
    Write-Host "FAIL: Claude is showing a first-run dialog in $ScratchDir. Run: tmux attach -t $Session , answer it once, then detach (Ctrl-b d). The lane carries on and the next self-test in this folder will not ask. Leftover session: kill it with tmux kill-session -t $Session"
    exit 1
  }
  if ($pane -match 'Do you want to (proceed|make this edit|create)') {
    Write-Host "FAIL: the lane is waiting on a permission prompt (see README Troubleshooting). Attach: tmux attach -t $Session"
    exit 1
  }
  & (Join-Path $S 'lane-watch.ps1') -Once -StateDir $state | Out-Null
}
$secs = [int]((Get-Date) - $t0).TotalSeconds

$logText = if (Test-Path -LiteralPath (Join-Path $state 'lanes.log')) { Get-Content -LiteralPath (Join-Path $state 'lanes.log') -Raw } else { '' }
$checks = [ordered]@{
  'output file written'        = ((Test-Path -LiteralPath $out) -and ((Get-Content -LiteralPath $out -Raw) -match 'PASS'))
  'declaration written+closed' = [bool](Get-ChildItem -LiteralPath (Join-Path $state 'done\closed') -Filter "$Session.*.done" -ErrorAction SilentlyContinue)
  'watcher: DONE-WHEN PRESENT' = ($logText -match [regex]::Escape("PRESENT ${Session}:"))
  'watcher: /exit sent'        = ($logText -match [regex]::Escape("sent '/exit' + Enter to ${Session}:"))
  'reaper: session killed'     = ($logText -match [regex]::Escape("[reap] kill-session $Session "))
  'session gone (has-session)' = $gone
}
foreach ($k in $g.Keys) { $checks[$k] = $g[$k] }
Write-Host ''
foreach ($k in $checks.Keys) { Write-Host ("{0,-28} {1}" -f $k, $(if ($checks[$k]) { 'ok' } else { 'MISSING' })) }
Write-Host "--- log ($state\lanes.log):"
if ($logText) { ($logText.Trim() -split "`r?`n") | Where-Object { $_ -match [regex]::Escape($Session) } | ForEach-Object { Write-Host "  $_" } }
Write-Host "after: $((& $tmux list-sessions -F '#{session_name}' 2>$null) -join ', ')"
Write-Host "elapsed: $secs s (launch -> session gone)"
if (@($checks.Values | Where-Object { -not $_ }).Count -eq 0) { Write-Host 'SELFTEST PASS'; exit 0 }
Write-Host "SELFTEST FAIL - if the session is still there: tmux attach -t $Session"
exit 1

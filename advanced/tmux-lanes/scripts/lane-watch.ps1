# lane-watch.ps1 - the close watcher. Each tick: read every declaration in <StateDir>\done, check the card's DONE-WHEN
# paths, and close the lane only when they all exist.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File lane-watch.ps1              # loop every 30 s
#   powershell -NoProfile -ExecutionPolicy Bypass -File lane-watch.ps1 -Once        # one tick, then exit
#   ... -DryRun                                                                     # log what it would do, send nothing
#   ... -DetachAs lanewatch     # start the loop in its own detached tmux session (name must not start with your lane prefix)
#   Stop the loop: create the file <StateDir>\STOP (it is removed when the loop honours it).
# One watcher per state folder: the loop takes <StateDir>\watcher.lock ("<pid> <start ticks>") and a second one is refused.
# A watcher closes EVERY lane that declares done in its state folder, not only the ones you launched it for.
# Refused from an elevated (admin) shell: its tmux server is invisible to normal shells (override: -AllowElevated).
#
# Per declaration:
#   session gone             -> archived to done\closed, logged GONE
#   DONE-WHEN MISSING        -> HELD: logged, nothing sent, re-checked next tick (the lane said done, the files disagree)
#   DONE-WHEN PRESENT        -> wait until the pane is idle, send each -CloseCommands entry (default: /exit) as literal
#                               text and then a SEPARATE Enter, then check from the recipient side that the window left
#                               list-windows (or the session is gone). Logged CLOSED, or SURVIVED (reported, never killed).
#   pane busy                -> logged BUSY, retried next tick. A slash command typed into a busy pane is DROPPED.
# Run it in its own detached session whose name does not start with your lane prefix (README, step 4).
#
# Simplified from the owner's version: no /model -> /workflow-capture -> /close burst (pass -CloseCommands if you want
# one), no harness-registry check, no phone push, no idle go/hold questions. PS 5.1, ASCII only.
[CmdletBinding()]
param(
  [string]   $StateDir = $(if ($env:LANE_STATE_DIR) { $env:LANE_STATE_DIR } else { Join-Path $env:TEMP 'tmux-lanes' }),
  [int]      $IntervalSeconds = 30,
  [int]      $IdleSeconds = 6,        # the pane must read idle on two captures this far apart
  [int]      $IdleWaitSeconds = 60,   # give up on this tick if the pane is not idle by then
  [int]      $VerifySeconds = 60,     # how long to wait for the window to disappear after the last send
  [string[]] $CloseCommands = @('/exit'),
  [switch]   $Once,
  [string]   $DetachAs = '',          # start this loop in a new detached tmux session of that name, then return
  [switch]   $DryRun,
  [switch]   $AllowElevated           # run from an admin shell anyway (it will not see lanes started from normal shells)
)
$tmux = (Get-Command tmux -ErrorAction SilentlyContinue).Source
if (-not $tmux) { $tmux = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\marlocarlo.psmux_*\tmux.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName }
if (-not $tmux) { Write-Host 'tmux (psmux) not found - winget install marlocarlo.psmux'; exit 3 }
# LANE_ASSUME_ELEVATED=1 is the selftest seam.
$elevated = ($env:LANE_ASSUME_ELEVATED -eq '1') -or ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($elevated -and -not $AllowElevated) { Write-Host 'refused: this is an elevated (admin) shell - its tmux server is invisible to normal shells and their lanes. Run the watcher from a normal PowerShell, or pass -AllowElevated'; exit 2 }
# lock = "<pid> <process start ticks>"; the ticks stop a recycled pid from looking alive. A killed watcher leaves a stale lock, taken over next start.
$lockFile = Join-Path $StateDir 'watcher.lock'
function Test-LockHeld {
  $p = @((Get-Content -LiteralPath $lockFile -ErrorAction SilentlyContinue) -split ' ')
  $h = if ($p.Count -eq 2) { Get-Process -Id $p[0] -ErrorAction SilentlyContinue }
  return [bool]($h -and $h.StartTime.Ticks -eq [int64]$p[1])
}
if ($DetachAs) {
  if (Test-LockHeld) { Write-Host "refused: a watcher already holds $lockFile (one per state folder)"; exit 2 }
  & $tmux has-session -t $DetachAs 2>$null
  if ($LASTEXITCODE -eq 0) { Write-Host "refused: tmux session '$DetachAs' already exists"; exit 2 }
  # -EncodedCommand: psmux drops inner double quotes, so a quoted path with a space would split in two
  $inner = "& '$($PSCommandPath -replace "'", "''")' -StateDir '$($StateDir -replace "'", "''")' -IntervalSeconds $IntervalSeconds$(if ($DryRun) { ' -DryRun' })"
  $cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand ' + [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($inner))
  if ($CloseCommands.Count -ne 1 -or $CloseCommands[0] -ne '/exit') { Write-Host 'note: -CloseCommands is not passed through -DetachAs; start the loop by hand for a custom close sequence' }
  & $tmux new-session -d -s $DetachAs -n watch $cmd
  if ($LASTEXITCODE -ne 0) { Write-Host "tmux new-session '$DetachAs' failed (exit $LASTEXITCODE)"; exit 3 }
  Write-Host "watcher running in tmux session '$DetachAs' (state $StateDir). Stop it: New-Item '$(Join-Path $StateDir 'STOP')'"
  exit 0
}
$doneDir = Join-Path $StateDir 'done'
$closedDir = Join-Path $doneDir 'closed'
$log = Join-Path $StateDir 'lanes.log'
$stopFile = Join-Path $StateDir 'STOP'
$doneWhen = Join-Path $PSScriptRoot 'done-when.ps1'
$Glyph = [string][char]0x276F   # Claude Code's input prompt character

New-Item -ItemType Directory -Force -Path $StateDir | Out-Null
$locked = $false
if (-not $Once -and -not $DryRun) {
  # ponytail: check-then-write, so two starts in the same instant can both pass; a real mutex if that ever bites
  if (Test-LockHeld) { Write-Host "refused: a watcher already holds $lockFile (one per state folder)"; exit 2 }
  Set-Content -LiteralPath $lockFile -Value "$PID $((Get-Process -Id $PID).StartTime.Ticks)" -Encoding ascii
  $locked = $true
}
function Write-Log([string]$s) {
  $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [watch] $s"
  Write-Host $line
  Add-Content -LiteralPath $log -Value $line -Encoding ascii -ErrorAction SilentlyContinue
}

function Test-Session([string]$s) { & $tmux has-session -t $s 2>$null; return ($LASTEXITCODE -eq 0) }

function Test-WindowGone([string]$target) {
  # list the SESSION and look for the index: list-windows -t s:w exits 0 even when that window is missing
  $s, $w = $target -split ':', 2
  if (-not (Test-Session $s)) { return $true }
  $idx = @(& $tmux list-windows -t $s -F '#{window_index}' 2>$null | ForEach-Object { "$_".Trim() })
  return ($idx -notcontains $w)
}

function Test-IdleOnce([string]$target) {
  # idle = a bare prompt line near the bottom and no "esc to interrupt" (Claude shows it while a turn runs)
  $raw = & $tmux capture-pane -p -J -S -25 -t $target 2>$null | Out-String
  if (-not $raw) { return $false }
  if ($raw -match 'esc to interrupt') { return $false }
  $lines = @(($raw -split "`n") | ForEach-Object { $_.TrimEnd("`r") } | Where-Object { $_.Trim() -ne '' })
  $tail = @($lines | Select-Object -Last 6)
  foreach ($l in $tail) { if ($l.Trim() -eq $Glyph) { return $true } }
  return $false
}

function Wait-Idle([string]$target) {
  $t0 = Get-Date
  while (((Get-Date) - $t0).TotalSeconds -lt $IdleWaitSeconds) {
    if (Test-IdleOnce $target) {
      Start-Sleep -Seconds $IdleSeconds
      if (Test-IdleOnce $target) { return $true }
    } else { Start-Sleep -Seconds 2 }
  }
  return $false
}

function Invoke-Tick {
  New-Item -ItemType Directory -Force -Path $closedDir | Out-Null
  foreach ($f in @(Get-ChildItem -LiteralPath $doneDir -Filter *.done -File -ErrorAction SilentlyContinue)) {
    $d = $null
    try { $d = Get-Content -LiteralPath $f.FullName -Raw | ConvertFrom-Json } catch { Write-Log "BAD declaration $($f.Name): $($_.Exception.Message)"; continue }
    $archive = Join-Path $closedDir ($f.BaseName + '.' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.done')
    if (-not (Test-Session $d.session)) {
      Write-Log "GONE $($d.session) - session no longer exists, declaration archived"
      if (-not $DryRun) { Move-Item -LiteralPath $f.FullName -Destination $archive -Force }
      continue
    }
    $dw = & $doneWhen -Card $d.card | Out-String
    if ($LASTEXITCODE -ne 0) {
      Write-Log "HELD $($d.target) - declared done but DONE-WHEN is MISSING, nothing sent: $(($dw.Trim() -split "`r?`n" | Where-Object { $_ -like 'MISSING*' }) -join '; ')"
      continue
    }
    Write-Log "PRESENT $($d.target) - DONE-WHEN satisfied for $($d.card)"
    if ($DryRun) { Write-Log "DRYRUN would send $($CloseCommands -join ' then ') to $($d.target)"; continue }
    $ok = $true
    foreach ($c in $CloseCommands) {
      if (-not (Wait-Idle $d.target)) { Write-Log "BUSY $($d.target) - not idle within $IdleWaitSeconds s, will retry '$c' next tick"; $ok = $false; break }
      & $tmux send-keys -t $d.target -l -- $c
      & $tmux send-keys -t $d.target Enter
      Write-Log "sent '$c' + Enter to $($d.target)"
    }
    if (-not $ok) { continue }
    $t0 = Get-Date; $gone = $false
    while (((Get-Date) - $t0).TotalSeconds -lt $VerifySeconds) {
      Start-Sleep -Seconds 3
      if (Test-WindowGone $d.target) { $gone = $true; break }
    }
    $secs = [int]((Get-Date) - $t0).TotalSeconds
    if ($gone) { Write-Log "CLOSED $($d.target) - window gone $secs s after the last send (recipient side: list-windows / has-session)"; Move-Item -LiteralPath $f.FullName -Destination $archive -Force }
    else { Write-Log "SURVIVED $($d.target) - window still there $secs s after '$($CloseCommands[-1])'; reported, not killed" }
  }
}

if (-not $Once) { Write-Log "start state=$StateDir once=$([bool]$Once) dryrun=$([bool]$DryRun) close=$($CloseCommands -join ',')" }
while ($true) {
  if (Test-Path -LiteralPath $stopFile) { Write-Log 'STOP file found - exiting'; Remove-Item -LiteralPath $stopFile -Force; break }
  Invoke-Tick
  if ($Once) { break }
  Start-Sleep -Seconds $IntervalSeconds
}
if ($locked) { Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue }
exit 0

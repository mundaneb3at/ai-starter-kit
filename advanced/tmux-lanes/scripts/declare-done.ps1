# declare-done.ps1 - the ONE "this lane is finished" signal. The lane runs it itself as its last step.
#
# Writes <StateDir>\done\<session>.done (JSON: session, target, card, declaredAt). lane-watch.ps1 reads it, checks the
# card's DONE-WHEN paths, and only then closes the lane. Done is never inferred from idle time or a timer.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File declare-done.ps1            # inside a lane: env vars say who
#   powershell -NoProfile -ExecutionPolicy Bypass -File declare-done.ps1 -DryRun    # print what would be written
#
# Who am I: lane-launch.ps1 sets LANE_SESSION, LANE_TARGET (session:window), LANE_CARD and LANE_STATE_DIR in the lane's
# window, and Claude's shell tools inherit them. Without them it asks tmux via $env:TMUX_PANE (never a bare
# display-message: that answers for the ATTACHED client's window, not yours). Params override both.
#
# Simplified from the owner's version: no walk up to claude.exe plus the harness session registry, no teammate scope,
# no close-tier fields. Exit 0 written | 2 cannot tell which session/card this is.
# PS 5.1, ASCII only.
[CmdletBinding()]
param(
  [string] $Session  = $env:LANE_SESSION,
  [string] $Target   = $env:LANE_TARGET,
  [string] $Card     = $env:LANE_CARD,
  [string] $StateDir = $env:LANE_STATE_DIR,
  [switch] $DryRun
)
if (-not $StateDir) { $StateDir = Join-Path $env:TEMP 'tmux-lanes' }

if ((-not $Session -or -not $Target) -and $env:TMUX_PANE) {
  $tmux = (Get-Command tmux -ErrorAction SilentlyContinue).Source
  if ($tmux) {
    $st = "$(& $tmux display-message -p -t $env:TMUX_PANE '#S:#I' 2>$null)".Trim()
    if ($st -match '^(.+):(\d+)$') { if (-not $Session) { $Session = $matches[1] }; if (-not $Target) { $Target = $st } }
  }
}
if (-not $Session) { Write-Host 'refused: no lane session (LANE_SESSION unset and not inside a tmux pane) - pass -Session'; exit 2 }
if (-not $Target) { $Target = "${Session}:1" }
if (-not $Card) { Write-Host 'refused: no card (LANE_CARD unset) - pass -Card so the watcher can check DONE-WHEN'; exit 2 }

$decl = [ordered]@{ session = $Session; target = $Target; card = $Card; declaredAt = (Get-Date).ToString('s') }
$json = $decl | ConvertTo-Json -Compress
$dir = Join-Path $StateDir 'done'
$file = Join-Path $dir ($Session + '.done')
if ($DryRun) { Write-Host "DRYRUN would write $file"; Write-Host $json; exit 0 }
New-Item -ItemType Directory -Force -Path $dir | Out-Null
[System.IO.File]::WriteAllText($file, $json + "`n", (New-Object System.Text.UTF8Encoding $false))
Write-Host "declared done -> $file"
Write-Host "lane-watch.ps1 closes this window once every DONE-WHEN path in the card exists."
exit 0

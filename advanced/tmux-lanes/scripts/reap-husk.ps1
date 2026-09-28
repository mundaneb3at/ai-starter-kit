# reap-husk.ps1 - close a tmux session left as a "husk": its lane finished, only an idle shell window is left.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File reap-husk.ps1 -Session my-lane      # one session
#   powershell -NoProfile -ExecutionPolicy Bypass -File reap-husk.ps1 -Prefix lane- -DryRun # sweep, show only
#
# A session is killed ONLY when nobody is attached AND no pane (other than the caller's own) has a child process.
# A running claude, a ping, a build, or an attached viewer keeps it alive. It kills the SESSION by exact name: never
# kill-server, never tmux.exe (psmux's __warm__ server can host live sessions). Every kill and every keep is logged
# to <StateDir>\lanes.log. -Prefix refuses an empty value, so a sweep can never match every session.
#
# Simplified from the owner's version: tmux is found on PATH or in the winget package folder (no hardcoded user path);
# adds the -Prefix sweep, -DryRun and a log. PS 5.1, ASCII only.
[CmdletBinding()]
param(
  [string] $Session = '',
  [string] $Prefix  = '',
  [string] $StateDir = $(if ($env:LANE_STATE_DIR) { $env:LANE_STATE_DIR } else { Join-Path $env:TEMP 'tmux-lanes' }),
  [switch] $DryRun
)
$tmux = (Get-Command tmux -ErrorAction SilentlyContinue).Source
if (-not $tmux) { $tmux = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\marlocarlo.psmux_*\tmux.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName }
if (-not $tmux) { Write-Host 'tmux (psmux) not found - winget install marlocarlo.psmux'; exit 3 }
$log = Join-Path $StateDir 'lanes.log'
function Write-Log([string]$s) {
  $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [reap] $s"
  Write-Host $line
  try { New-Item -ItemType Directory -Force -Path $StateDir | Out-Null; Add-Content -LiteralPath $log -Value $line -Encoding ascii } catch { }
}

if (-not $Session -and -not $Prefix.Trim()) { Write-Host 'refused: pass -Session <name> or a non-empty -Prefix <p>'; exit 2 }

# the caller's own pane: this process and its parent (psmux may start the pane's shell via a wrapper)
$self = @($PID, [int](Get-CimInstance Win32_Process -Filter "ProcessId=$PID").ParentProcessId)

function Test-Husk([string]$s) {
  # returns '' when the session is a husk, else the reason to keep it
  & $tmux has-session -t $s 2>$null
  if ($LASTEXITCODE -ne 0) { return 'no such session' }
  $att = "$(& $tmux display-message -p -t $s '#{session_attached}' 2>$null)".Trim()
  if ($att -ne '0') { return "attached ($att)" }
  $panes = @(& $tmux list-panes -s -t $s -F '#{pane_pid}' 2>$null)
  if ($LASTEXITCODE -ne 0) { return 'list-panes failed' }
  foreach ($p in $panes) {
    if (-not "$p".Trim() -or $self -contains [int]$p) { continue }
    $kids = @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$([int]$p)" | ForEach-Object { $_.Name })
    if ($kids.Count) { return "pane pid $p has child $($kids -join ',')" }
  }
  return ''
}

$names = @()
if ($Session) { $names = @($Session) }
else {
  $names = @(& $tmux list-sessions -F '#{session_name}' 2>$null | ForEach-Object { "$_".Trim() } | Where-Object { $_ -and $_.StartsWith($Prefix) })
  Write-Host "sweep prefix '$Prefix': $($names.Count) session(s) match: $($names -join ', ')"
}
foreach ($s in $names) {
  $why = Test-Husk $s
  if ($why) { Write-Log "keep $s ($why)"; continue }
  if ($DryRun) { Write-Log "DRYRUN would kill-session $s (husk: idle shells only, not attached)"; continue }
  Write-Log "kill-session $s (husk: idle shells only, not attached)"
  & $tmux kill-session -t $s 2>$null
}
exit 0

# lane-launch.ps1 - start one card as one unattended Claude Code lane in its own tmux (psmux) session.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File lane-launch.ps1 -Card C:\work\cards\my-card.md -Model sonnet -Effort medium
#   ... -Session fix-login -WorkDir C:\work             # session name (default: from the card file name), lane folder
#   ... -ClaudeArgs '--allowedTools','Edit(./**)'       # extra claude flags, passed through untouched
#   ... -DryRun                                         # print the checks and the plan, create nothing
#
# Refuses (exit 2, nothing created): a card with no DONE-WHEN block, a card whose DONE-WHEN paths all exist already,
# a session name that already exists.
# Shape: one session per lane. Window 0 = a plain shell (so you can attach and look around). Window 1 = the lane.
# Two-stage start: window 1 runs THIS script again with -Run -LaunchFile <json>. The first message, the card path and
# any extra flags travel in that JSON file, never on the tmux command line (quotes and slashes get mangled there).
# The window command itself is powershell -EncodedCommand <base64>: psmux drops inner double quotes, so a quoted
# path with a space splits in two (measured: "...\scratch\e2e space\..." arrived as "...\scratch\e2e").
# The -Run stage clears CLAUDE_CODE_CHILD_SESSION (inherited, it turns transcript saving off), sets LANE_SESSION /
# LANE_TARGET / LANE_CARD / LANE_STATE_DIR for declare-done.ps1, starts claude, and after claude exits calls
# reap-husk.ps1 on its own session so an empty session does not linger.
#
# Simplified from the owner's version: no DISPATCH-LOG row, no card stamping, no model alias map, no quota/union/
# scope-loop gates, no a2..a9 fallback when a session name is shadowed (see README Troubleshooting).
# PS 5.1, ASCII only.
[CmdletBinding()]
param(
  [string]   $Card = '',
  [string]   $Session = '',            # default: lane-<card file name>, so every lane shares the prefix 'lane-'
  [string]   $Model = '',              # required at launch (no silent default): sonnet, opus, haiku or a full model id
  [string]   $Effort = '',             # required at launch: low, medium, high, xhigh, max
  [string]   $WorkDir = (Get-Location).Path,
  [string[]] $ClaudeArgs = @(),
  [string]   $StateDir = $(if ($env:LANE_STATE_DIR) { $env:LANE_STATE_DIR } else { Join-Path $env:TEMP 'tmux-lanes' }),
  [switch]   $DryRun,
  [switch]   $Run,                     # internal: we ARE window 1
  [string]   $LaunchFile = ''          # internal: the JSON written by the launch stage
)
$tmux = (Get-Command tmux -ErrorAction SilentlyContinue).Source
if (-not $tmux) { $tmux = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\marlocarlo.psmux_*\tmux.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName }
if (-not $tmux) { Write-Host 'tmux (psmux) not found - winget install marlocarlo.psmux'; exit 3 }

# --- -Run: window 1 -------------------------------------------------------------------------------------------------
if ($Run) {
  $L = $null
  try { $L = Get-Content -LiteralPath $LaunchFile -Raw -ErrorAction Stop | ConvertFrom-Json } catch { }
  if (-not $L -or -not $L.model -or -not $L.workDir) {
    Write-Host "lane-launch: cannot read launch file '$LaunchFile' - claude NOT started. Press Enter to close."; [void](Read-Host); exit 2
  }
  Set-Location -LiteralPath $L.workDir
  $env:CLAUDE_CODE_CHILD_SESSION = ''
  $env:CLAUDE_CODE_FORCE_SESSION_PERSISTENCE = '1'
  $env:LANE_SESSION = $L.session
  $env:LANE_CARD = $L.card
  $env:LANE_STATE_DIR = $L.stateDir
  $me = "$(& $tmux display-message -p -t $env:TMUX_PANE '#S:#I' 2>$null)".Trim()
  $env:LANE_TARGET = $(if ($me -match '^.+:\d+$') { $me } else { "$($L.session):1" })
  $claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
  if (-not $claude) { $claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe' }
  # extra flags first: a list flag such as --allowedTools would otherwise swallow the prompt; --model ends the list
  # always allow exactly the declare-done command (the lane's last step must never wait on a permission prompt)
  $dd = Join-Path $PSScriptRoot 'declare-done.ps1'
  $cargs = @('--allowedTools', "PowerShell(& '$dd')", "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File '$dd')") + @($L.claudeArgs | Where-Object { $_ }) + @('--model', $L.model, '--effort', $L.effort)
  Write-Host "lane-launch: $($env:LANE_TARGET) -> claude $($cargs -join ' ')"
  & $claude @cargs $L.first
  $code = $LASTEXITCODE
  if ($code -ne 0) { Write-Host "`nclaude exited with code $code. Press Enter to close this window."; [void](Read-Host) }
  & (Join-Path $PSScriptRoot 'reap-husk.ps1') -Session $L.session -StateDir $L.stateDir
  exit $code
}

# --- launch stage ---------------------------------------------------------------------------------------------------
if (-not $Model -or -not $Effort) { Write-Host 'refused: pass -Model and -Effort (for example -Model sonnet -Effort medium); a lane never runs on a silent default'; exit 2 }
if (-not $Card -or -not (Test-Path -LiteralPath $Card)) { Write-Host "refused: card not found: $Card"; exit 2 }
$CardPath = (Resolve-Path -LiteralPath $Card).Path
$WorkDir = (Resolve-Path -LiteralPath $WorkDir).Path
if (-not $Session) {
  $Session = 'lane-' + ([System.IO.Path]::GetFileNameWithoutExtension($CardPath) -replace '[^A-Za-z0-9-]', '-').Trim('-')
  if ($Session.Length -gt 28) { $Session = $Session.Substring(0, 28).Trim('-') }
}
$doneWhen = Join-Path $PSScriptRoot 'done-when.ps1'

$parse = & $doneWhen -Card $CardPath -ParseOnly | Out-String
if ($LASTEXITCODE -ne 0) { Write-Host "refused: card has no DONE-WHEN block with an absolute path - $($parse.Trim())"; exit 2 }
& $doneWhen -Card $CardPath -Quiet
if ($LASTEXITCODE -eq 0) { Write-Host "refused: card is already DONE (every DONE-WHEN path exists): $CardPath"; exit 2 }
& $tmux has-session -t $Session 2>$null
if ($LASTEXITCODE -eq 0) { Write-Host "refused: tmux session '$Session' already exists - one session per lane; pick another -Session"; exit 2 }

$declare = Join-Path $PSScriptRoot 'declare-done.ps1'
$first = "Read $CardPath and do what it says. As your very last step, once every file under its DONE-WHEN heading exists, run this exact command with your PowerShell tool: & '$declare'   (only if you have no PowerShell tool, from Bash: powershell -NoProfile -ExecutionPolicy Bypass -File '$declare')"
$launch = [ordered]@{ session = $Session; card = $CardPath; workDir = $WorkDir; model = $Model; effort = $Effort; claudeArgs = @($ClaudeArgs); stateDir = $StateDir; first = $first }
$launchFile = Join-Path (Join-Path $StateDir 'launch') ($Session + '.json')
$inner = "& '$($PSCommandPath -replace "'", "''")' -Run -LaunchFile '$($launchFile -replace "'", "''")'"
$winCmd = 'powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand ' + [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($inner))

Write-Host "session  : $Session (window 0 shell, window 1 lane)"
Write-Host "workdir  : $WorkDir"
Write-Host "claude   : --allowedTools <the exact declare-done command> $($ClaudeArgs -join ' ') --model $Model --effort $Effort"
Write-Host "first msg: $first"
Write-Host "window 1 : $inner   (sent as powershell -EncodedCommand)"
if ($DryRun) { Write-Host 'DRYRUN - nothing created.'; exit 0 }

New-Item -ItemType Directory -Force -Path (Split-Path $launchFile) | Out-Null
[System.IO.File]::WriteAllText($launchFile, ($launch | ConvertTo-Json -Depth 4), (New-Object System.Text.UTF8Encoding $false))
& $tmux new-session -d -s $Session -n shell -c $WorkDir
if ($LASTEXITCODE -ne 0) { Write-Host "tmux new-session '$Session' failed (exit $LASTEXITCODE)"; exit 3 }
& $tmux new-window -t $Session -n lane -c $WorkDir $winCmd
if ($LASTEXITCODE -ne 0) { Write-Host "tmux new-window failed (exit $LASTEXITCODE) - session '$Session' left with its shell window"; exit 3 }
Write-Host "LAUNCHED $Session. Watch: tmux attach -t $Session   (detach: Ctrl-b d)"
exit 0

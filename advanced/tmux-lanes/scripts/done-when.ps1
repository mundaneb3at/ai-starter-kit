# done-when.ps1 - is a card finished? Checks the paths listed under the card's "## DONE-WHEN" heading.
#
# The heading may be "## DONE-WHEN" or "## Done when". The block: one ABSOLUTE path per line, backtick-quoted or bare, "C:\..." or "~\..." (= your profile folder; / works too),
# with an optional " -- comment" after it. The block ends at the next heading.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File done-when.ps1 -Card C:\work\cards\my-card.md
#   ... -ParseOnly   # only check that the block declares >= 1 path; never touches the filesystem
#
# Exit 0 = every path exists (PRESENT).  Exit 1 = no block / no paths (the card has no definition of done).
# Exit 2 = at least one path missing, empty (0 bytes), or not an absolute path (MISSING).
# -ParseOnly: exit 0 when >= 1 path is declared, else 1. -DryRun is accepted for symmetry; this script never writes.
#
# Simplified from the owner's version: no launch-stamp staleness check (a deliverable left over from an earlier run
# counts as PRESENT here - delete it before a re-run) and no -Receipt JSON write-back. See ARCHITECTURE.md.
# PS 5.1, ASCII only.
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)] [string] $Card,
  [switch] $ParseOnly,
  [switch] $Quiet,
  [switch] $DryRun
)

function Out-Line([string]$s) { if (-not $Quiet) { Write-Output $s } }

if (-not (Test-Path -LiteralPath $Card)) { Out-Line "done-when: card not found: $Card"; exit 1 }
$lines = [System.IO.File]::ReadAllLines($Card)

$paths = @()
$unresolvable = @()   # a line that is not an absolute path is a requirement that can never be met - count it MISSING
$inBlock = $false
$inComment = $false
foreach ($l in $lines) {
  if ($l -match '^#{1,6}\s*DONE[- ]WHEN\b') { $inBlock = $true; continue }
  if ($inBlock -and $l -match '^#{1,6}\s') { break }
  if (-not $inBlock) { continue }
  $t = $l.Trim().TrimStart('-', '*').Trim()
  if ($inComment) { if ($t -like '*-->*') { $inComment = $false }; continue }
  if ($t.StartsWith('<!--')) { if ($t -notlike '*-->*') { $inComment = $true }; continue }
  if ($t -eq '') { continue }
  $cand = $null
  if ($t -match '^`([^`]+)`') { $cand = $matches[1] }
  elseif ($t -match '^(.*?)(?:\s+--\s.*)?$') { $cand = $matches[1] }
  if (-not $cand) { continue }
  $cand = $cand.Trim()
  if ($cand -match '^~[\\/]') { $cand = Join-Path $env:USERPROFILE $cand.Substring(2) }
  if ($cand -match '^[A-Za-z]:[\\/]') { $paths += $cand } else { $unresolvable += $cand }
}

if ($paths.Count -eq 0) { Out-Line "done-when: no DONE-WHEN paths declared in $Card"; exit 1 }
if ($ParseOnly) { foreach ($p in $paths) { Out-Line "DECLARED $p" }; exit 0 }

$missing = @()
foreach ($p in $paths) {
  if ($p.IndexOfAny([System.IO.Path]::GetInvalidPathChars()) -ge 0) { $missing += $p; Out-Line "MISSING $p (invalid path characters)"; continue }
  if (-not (Test-Path -LiteralPath $p)) { $missing += $p; Out-Line "MISSING $p"; continue }
  $item = Get-Item -LiteralPath $p
  if (-not $item.PSIsContainer -and $item.Length -eq 0) { $missing += $p; Out-Line "MISSING $p (empty file)"; continue }
  Out-Line "PRESENT $p"
}
foreach ($u in $unresolvable) { $missing += $u; Out-Line "MISSING $u (not an absolute path)" }
if ($missing.Count -eq 0) { exit 0 } else { exit 2 }

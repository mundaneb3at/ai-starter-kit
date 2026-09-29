# update-kit.ps1
# Plans (and, with -Apply, does the safe part of) an update of your work\ folder to THIS copy of
# the kit, without touching anything you changed yourself. Windows PowerShell 5.1+.
#
# Run it from the NEW kit's folder (downloaded next to, never inside, work\):
#   powershell -ExecutionPolicy Bypass -File .\update-kit.ps1                 # plan only, changes nothing
#   powershell -ExecutionPolicy Bypass -File .\update-kit.ps1 -Apply          # archive, then copy the safe files
#   ... -Work "D:\ai-work\work"      your work folder, if setup.ps1 was run with -Base (default: Desktop\work)
#   ... -Skip "SEATS.md","skills\tutor\SKILL.md"   files -Apply must leave alone (paths as the plan prints them)
#   ... -BaseTag v2026.09.26         the release you installed, when work\KIT-VERSION.txt is missing
#                                    (tags are listed on the kit's GitHub page under Tags)
#   ... -Base "C:\path\old-kit"      that release as a folder instead of a download (never your work\)
#
# How it decides, per file, comparing three copies: BASE (the release you installed, found from
# work\KIT-VERSION.txt and downloaded from GitHub), YOURS (in work\) and NEW (this folder):
#   CURRENT   yours already equals new                          -> nothing to do
#   ADD       new in the kit, you don't have it                 -> -Apply copies it in
#   TAKE-NEW  you never changed it, the kit did                 -> -Apply replaces it
#   KEEP      you changed it, the kit didn't                    -> left alone
#   DELETED   you removed it, the kit still has it              -> left removed
#   MERGE     you changed it AND the kit changed it             -> your AI merges it with you (skills\update-kit)
#   REVIEW    no base copy to compare with, and yours differs   -> your AI shows you the difference and asks
# -Apply first writes work\_archive\<date>-kit-update\: a copy of every file it will replace, your
# KIT-VERSION.txt, and UPDATE-MANIFEST.txt listing every file it added or replaced (the undo).
# It never deletes, never touches your tracking files (TASKS, TODAY, MEMORY, memory\, handoffs\) and
# never touches tool configs outside work\ (it lists the ones that changed, to compare by hand).
[CmdletBinding()]
param(
    [string]$Work = (Join-Path $env:USERPROFILE 'Desktop\work'),
    [string]$Base = '',
    [string]$BaseTag = '',
    [string[]]$Skip = @(),
    [string]$Repo = 'mundaneb3at/ai-starter-kit',
    [switch]$Apply
)
$ErrorActionPreference = 'Stop'
$New = $PSScriptRoot
function Stop-Here([string]$msg) { Write-Host $msg -ForegroundColor Yellow; exit 2 }
if (-not (Test-Path -LiteralPath (Join-Path $Work 'AGENTS.md'))) { Stop-Here "No AGENTS.md in $Work - pass -Work <your work folder>." }
if (-not (Test-Path -LiteralPath (Join-Path $New 'CHANGELOG.md'))) { Stop-Here "This folder ($New) is not a whole kit release (no CHANGELOG.md). Run the script from the new kit's folder." }
$WorkFull = (Resolve-Path -LiteralPath $Work).Path.TrimEnd('\')

function Get-Version([string]$changelog) {
    if (Test-Path -LiteralPath $changelog) { foreach ($l in Get-Content -LiteralPath $changelog) { if ($l -match '^## \[(v[0-9.]+)\]') { return $Matches[1] } } }
    ''
}
function Get-VerKey([string]$v) { (($v.TrimStart('v') -split '\.') | ForEach-Object { '{0:D5}' -f [int]$_ }) -join '.' }   # sortable
$newVer = Get-Version (Join-Path $New 'CHANGELOG.md')
$verFile = Join-Path $Work 'KIT-VERSION.txt'
$myVer = ''
if (Test-Path -LiteralPath $verFile) { $l = Get-Content -LiteralPath $verFile -TotalCount 1; if ($l -match '^kit-version:\s*(v[0-9.]+)') { $myVer = $Matches[1] } }
if ($BaseTag) { $myVer = $BaseTag }
$older = $myVer -and $newVer -and ((Get-VerKey $newVer) -le (Get-VerKey $myVer))

# BASE: the release you installed. Downloaded to a temp folder (outside work\) when not given.
if ($Base) {
    $bf = (Resolve-Path -LiteralPath $Base).Path.TrimEnd('\')
    if ($bf -eq $WorkFull -or $bf.StartsWith($WorkFull + '\')) { Stop-Here "-Base must be the kit release you installed, never your work folder: that would make every change of yours look like the kit's." }
} elseif ($myVer) {
    $zip = Join-Path $env:TEMP "ai-starter-kit-$myVer.zip"; $Base = Join-Path $env:TEMP "ai-starter-kit-$myVer"
    if (-not (Test-Path -LiteralPath $Base)) {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -UseBasicParsing "https://github.com/$Repo/archive/refs/tags/$myVer.zip" -OutFile $zip
            Expand-Archive $zip (Join-Path $env:TEMP "ai-starter-kit-$myVer-x") -Force
            Move-Item (Get-ChildItem (Join-Path $env:TEMP "ai-starter-kit-$myVer-x") -Directory | Select-Object -First 1).FullName $Base
        } catch { Write-Host "Could not download release $myVer ($($_.Exception.Message)). Continuing without a base: differences become REVIEW." -ForegroundColor Yellow; $Base = '' }
    }
}
if ($Base -and -not (Test-Path -LiteralPath (Join-Path $Base 'AGENTS.md'))) { Write-Host "-Base $Base has no AGENTS.md; ignoring it." -ForegroundColor Yellow; $Base = '' }

# Which kit file lands where in work\ (the same places setup.ps1 puts them).
$map = @()
foreach ($n in 'AGENTS.md', 'CLAUDE.md', 'WORKFLOWS.md', 'SEATS.md', '.gitignore') { $map += , @($n, $n) }
foreach ($root in 'skills', 'templates') {
    foreach ($f in Get-ChildItem -LiteralPath (Join-Path $New $root) -Recurse -File -Force) {
        $rel = $f.FullName.Substring($New.Length + 1); $map += , @($rel, $rel)
    }
}
if (Test-Path -LiteralPath (Join-Path $Work 'opencode.json')) {   # only for OpenCode installs
    $map += , @('tools\opencode\opencode.json', 'opencode.json')
    foreach ($f in Get-ChildItem -LiteralPath (Join-Path $New 'tools\opencode\commands') -File) { $map += , @("tools\opencode\commands\$($f.Name)", ".opencode\commands\$($f.Name)") }
}

function Get-Norm([string]$p) {   # content hash that ignores CRLF vs LF, or '' if missing
    if (-not (Test-Path -LiteralPath $p)) { return '' }
    $t = [IO.File]::ReadAllText($p).Replace("`r`n", "`n")
    -join ([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($t)) | ForEach-Object { $_.ToString('x2') })
}
$plan = foreach ($m in $map) {
    $n = Get-Norm (Join-Path $New $m[0]); $y = Get-Norm (Join-Path $Work $m[1])
    $b = if ($Base) { Get-Norm (Join-Path $Base $m[0]) } else { $null }
    $s = if ($y -eq $n) { 'CURRENT' }
         elseif (-not $y) { if ($b -and $m[0] -notlike 'templates\*') { 'DELETED' } else { 'ADD' } }   # you removed it (templates\ are reference copies whose place changed between releases: always ADD)
         elseif (-not $b) { 'REVIEW' }                                    # no base copy of this file to compare with
         elseif ($y -eq $b) { 'TAKE-NEW' } elseif ($n -eq $b) { 'KEEP' } else { 'MERGE' }
    [pscustomobject]@{ Status = $s; Path = $m[1]; Kit = $m[0] }
}

Write-Host "Your version: $(if ($myVer) { $myVer } else { 'unknown' })   New: $newVer   ($New)"
Write-Host "Base used:    $(if ($Base) { $Base } else { 'none - every file that differs is REVIEW' })"
$plan | Where-Object { $_.Status -ne 'CURRENT' } | Sort-Object Status, Path | Format-Table -AutoSize | Out-String | Write-Host
$plan | Group-Object Status | ForEach-Object { Write-Host ("  {0,-9} {1}" -f $_.Name, $_.Count) }
if ($Base) {   # tool configs live outside work\: list the ones this release changed
    $cfg = foreach ($f in Get-ChildItem -LiteralPath (Join-Path $New 'tools') -Recurse -File) {
        $rel = $f.FullName.Substring($New.Length + 1)
        if ($rel -notlike 'tools\opencode\commands\*' -and $rel -ne 'tools\opencode\opencode.json' -and (Get-Norm $f.FullName) -ne (Get-Norm (Join-Path $Base $rel))) { $rel }
    }
    if ($cfg) { Write-Host "Changed tool files (not touched here; compare by hand, README 'Updating this kit'):"; $cfg | ForEach-Object { Write-Host "  $_" } }
}
if ($older) { Write-Host "This kit ($newVer) is not newer than yours ($myVer). Wrong download? -Apply is refused." -ForegroundColor Yellow }

if ($Apply) {
    if ($older) { exit 2 }
    $todo = @($plan | Where-Object { ($_.Status -eq 'ADD' -or $_.Status -eq 'TAKE-NEW') -and $Skip -notcontains $_.Path })
    if (-not $todo.Count) { Write-Host "Nothing to copy."; exit 0 }
    $arch = Join-Path $Work ("_archive\" + (Get-Date -Format 'yyyy-MM-dd-HHmmss') + "-kit-update")
    New-Item -ItemType Directory -Force $arch | Out-Null
    $manifest = @("kit update $myVer -> $newVer, $(Get-Date -Format 'yyyy-MM-dd HH:mm')", "Undo: copy REPLACED files from here back to work\, move ADDED files to work\_archive\, restore KIT-VERSION.txt from here.")
    if (Test-Path -LiteralPath $verFile) { Copy-Item -LiteralPath $verFile (Join-Path $arch 'KIT-VERSION.txt') }
    foreach ($p in $todo) {
        $dst = Join-Path $Work $p.Path
        if (Test-Path -LiteralPath $dst) {
            $a = Join-Path $arch $p.Path; New-Item -ItemType Directory -Force (Split-Path $a) | Out-Null
            Copy-Item -LiteralPath $dst $a; $manifest += "REPLACED  $($p.Path)"
        } else { $manifest += "ADDED     $($p.Path)" }
        New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
        Copy-Item -LiteralPath (Join-Path $New $p.Kit) $dst -Force
        Write-Host "  $($p.Status.PadRight(9)) $($p.Path)"
    }
    Set-Content -LiteralPath (Join-Path $arch 'UPDATE-MANIFEST.txt') -Value $manifest -Encoding ASCII
    Write-Host "Undo record and old copies: $arch"
    $left = @($plan | Where-Object { $_.Status -eq 'MERGE' -or $_.Status -eq 'REVIEW' }).Count
    Write-Host "$left file(s) still need you and your AI (MERGE/REVIEW): say 'read skills/update-kit/SKILL.md'."
    Write-Host "KIT-VERSION.txt is NOT changed yet: the skill sets it to $newVer once those are done."
}
exit 0

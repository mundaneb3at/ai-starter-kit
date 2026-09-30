# setup.ps1
# Scaffolds an ai-starter-kit workspace on Windows and installs the tool(s) you pick.
# SAFE + IDEMPOTENT: only creates what's missing, never deletes or overwrites anything you
# already have. Run it as many times as you like.
#
# Usage (from this kit's folder, in PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool both
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool codex
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool claude -Base "D:\ai-work"
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool opencode
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool none     # folders + files only, installs nothing
#
# Result:
#   <Base>\work\            <- launch your AI tool from here (its sandbox root)
#   <Base>\work\projects\
#   <Base>\work\_archive\    <- archive-don't-delete target
#   <Base>\work\handoffs\    <- one file per session, written at /close
#   <Base>\work\TASKS.md, TODAY.md, MEMORY.md, memory\   <- your tracking files (start empty)
#   <Base>\work\templates\   <- starting copies WITH example content, to read and copy from
#   <Base>\work\KIT-VERSION.txt   <- which kit release you installed (from CHANGELOG.md)
#   <Base>\private\          <- OUTSIDE work\. Never launch your AI tool here.
#

param(
    [Parameter(Mandatory)]
    [ValidateSet('codex', 'claude', 'both', 'opencode', 'none')]
    [string]$Tool,

    [string]$Base = (Join-Path $env:USERPROFILE "Desktop")
)

$ErrorActionPreference = 'Stop'
# A relative -Base (".\ai") would template a relative private path into the Claude Code config.
$Base = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Base)

$work   = Join-Path $Base "work"
$priv    = Join-Path $Base "private"
$dirs = @(
    $work,
    (Join-Path $work "projects"),
    (Join-Path $work "_archive"),
    (Join-Path $work "handoffs"),
    $priv
)

Write-Host "Setting up ai-starter-kit under: $Base" -ForegroundColor Cyan
# The Desktop you see can live somewhere else (OneDrive backup moves it). Then work\ and
# private\ would be created in a folder you never look at.
$shownDesktop = [Environment]::GetFolderPath('Desktop')
if ($Base -eq (Join-Path $env:USERPROFILE "Desktop") -and $shownDesktop -ne $Base) {
    Write-Host "  NOTE: the Desktop you see is $shownDesktop (for example, backed up by OneDrive), so work\ and private\ will NOT show up there. They go in $Base. Pass -Base to pick another folder." -ForegroundColor Yellow
}

# --- Step 1: folder layout -------------------------------------------------
foreach ($d in $dirs) {
    if (Test-Path $d) {
        # IA-004: Test-Path alone doesn't establish that $d is a real directory here -- a
        # pre-existing reparse point (junction/symlink) at this path would pass the check, and
        # every later Copy-Item into it would silently write through to wherever it redirects.
        $existing = Get-Item -LiteralPath $d -Force
        if ($existing.LinkType) {
            Write-Error "  $d is a $($existing.LinkType) pointing elsewhere (target: $($existing.Target)) -- refusing to treat it as a plain folder. Move or remove the link first."
            exit 1
        }
        # Flag E: a plain FILE here (LinkType is $null) passed the check above and would throw
        # on the first Copy-Item into it later, mid-run, under $ErrorActionPreference='Stop'.
        if (-not $existing.PSIsContainer) {
            Write-Error "  $d already exists as a FILE, not a folder -- refusing to treat it as one. Move or remove the file first."
            exit 1
        }
        Write-Host ("  exists   " + $d) -ForegroundColor DarkGray
    } else {
        New-Item -ItemType Directory -Path $d | Out-Null
        Write-Host ("  created  " + $d) -ForegroundColor Green
    }
}

# --- Step 2: tool installs (skip anything already on PATH) -----------------
# Flag E: winget installing a tool doesn't update this process's $env:Path, so the very next
# `Get-Command`/npm call in this same run could throw CommandNotFound on a clean machine even
# though the install just succeeded. Refresh from Machine+User after each install below.
function Update-SessionPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

# G-02: an installer finishing only means it ran. Check the command actually works now.
function Confirm-Installed([string]$Name, [string]$Hint = "install it by hand (see README)") {
    Update-SessionPath
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Error "  '$Name' still isn't available after installing it -- $Hint, then re-run this script."
        exit 1
    }
    Write-Host ("  ok       " + $Name) -ForegroundColor Green
}

if ($Tool -eq 'none') {
    Write-Host "  skipped  tool installs and tool configs (-Tool none)" -ForegroundColor DarkGray
} else {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Host "  installing Node.js LTS (winget)..." -ForegroundColor Yellow
        winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
        Confirm-Installed node
    } else {
        Write-Host "  exists   node" -ForegroundColor DarkGray
    }

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "  installing Git (winget)..." -ForegroundColor Yellow
        winget install --id Git.Git --accept-source-agreements --accept-package-agreements
        Confirm-Installed git
    } else {
        Write-Host "  exists   git" -ForegroundColor DarkGray
    }

    if ($Tool -eq 'codex' -or $Tool -eq 'both') {
        if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
            Write-Host "  installing @openai/codex (npm)..." -ForegroundColor Yellow
            npm install -g @openai/codex
            Confirm-Installed codex
        } else {
            Write-Host "  exists   codex" -ForegroundColor DarkGray
        }
    }

    if ($Tool -eq 'claude' -or $Tool -eq 'both') {
        if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
            # The vendor's recommended install (code.claude.com/docs/en/setup): a native claude.exe,
            # so no .ps1 launcher for the script policy below to block.
            Write-Host "  installing Claude Code (native installer)..." -ForegroundColor Yellow
            Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
            Confirm-Installed claude "open a NEW PowerShell window and try 'claude --version'; if that fails, add $env:USERPROFILE\.local\bin to your PATH"
        } else {
            Write-Host "  exists   claude" -ForegroundColor DarkGray
        }
    }

    if ($Tool -eq 'opencode') {
        if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
            Write-Host "  installing opencode-ai (npm)..." -ForegroundColor Yellow
            npm install -g opencode-ai
            Confirm-Installed opencode
        } else {
            Write-Host "  exists   opencode" -ForegroundColor DarkGray
        }
    }

    # --- Step 2b: let npm-installed tools start in a normal PowerShell window --
    # npm installs each tool with a .ps1 launcher, and PowerShell picks the .ps1 first. A fresh
    # Windows PC runs no .ps1 files at all (policy "Restricted"), so typing  codex  (or npm) fails
    # with "running scripts is disabled on this system". If nothing else is set, allow local scripts
    # for YOUR account only. Undo any time with:  Set-ExecutionPolicy -Scope CurrentUser Undefined
    function Get-NormalPolicy {
        # The policy a normal PowerShell window gets: the first scope that is set, skipping this
        # script's own Process scope (Bypass). Nothing set anywhere = Restricted.
        foreach ($s in 'MachinePolicy', 'UserPolicy', 'CurrentUser', 'LocalMachine') {
            $v = Get-ExecutionPolicy -Scope $s
            if ($v -ne 'Undefined') { return $v }
        }
        return 'Restricted'
    }
    if ((Get-NormalPolicy) -eq 'Restricted' -and (Get-ExecutionPolicy -Scope CurrentUser) -eq 'Undefined') {
        # Under -ExecutionPolicy Bypass this can complain that a more specific scope overrides it,
        # even when the setting was saved. The check below is what counts.
        try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force } catch { }
    }
    $pol = Get-NormalPolicy
    if ($pol -eq 'Restricted' -or $pol -eq 'AllSigned') {
        Write-Host "  NOTE: PowerShell's script policy is $pol, so 'codex', 'opencode' and 'npm' may refuse to start ('running scripts is disabled'). Fix for your account: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned" -ForegroundColor Yellow
    } else {
        Write-Host "  ok       PowerShell script policy for normal windows: $pol" -ForegroundColor Green
    }
}

# --- Step 3: place instruction files, skills and tracking files into work\ (only if absent) --
# Copies $src to $dst unless $dst already exists (file or whole folder).
function Copy-IfAbsent([string]$src, [string]$dst) {
    if (Test-Path $dst) {
        Write-Host ("  exists   " + $dst + "  (left untouched)") -ForegroundColor DarkGray
    } elseif (Test-Path $src) {
        New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
        Copy-Item $src $dst -Recurse
        Write-Host ("  placed   " + $dst) -ForegroundColor Green
    } else {
        Write-Host ("  NOTE: " + $src + " not found next to this script; copy it into work\ manually.") -ForegroundColor Yellow
    }
}

# An existing install (rules file already there before this run) gets kit-version "unknown" below:
# re-running setup merges nothing, so it must not claim the newest release.
$existingInstall = Test-Path (Join-Path $work "AGENTS.md")
foreach ($name in "AGENTS.md", "CLAUDE.md", "WORKFLOWS.md", "SEATS.md", ".gitignore") {
    Copy-IfAbsent (Join-Path $PSScriptRoot $name) (Join-Path $work $name)
}

# The keeping-track files (AGENTS.md, section Keeping track). Tool-agnostic, so placed for every -Tool.
# AGENTS.md has the AI read work\TASKS.md, TODAY.md and MEMORY.md every session, so they must not
# carry made-up example entries. Copy-Blank places them without the examples; the full examples
# go to work\templates\ instead, to read and copy from.
$tpl = Join-Path $PSScriptRoot "templates"

# Like Copy-IfAbsent, but drops the example lines: task checkboxes, dated table rows, and index
# lines that link into memory\, and empties the numbered first item. Everything else (headings,
# notes, comments) is kept.
# Limit: pattern-based. A new example shape in a template just gets copied through; widen the patterns then.
function Copy-Blank([string]$src, [string]$dst) {
    if (Test-Path $dst) {
        Write-Host ("  exists   " + $dst + "  (left untouched)") -ForegroundColor DarkGray
    } elseif (Test-Path $src) {
        $lines = [System.IO.File]::ReadAllText($src) -split "(?<=`n)"
        $keep = @($lines | Where-Object {
            $_ -notmatch '^- \[[ x]\] ' -and $_ -notmatch '^\| \d{4}-\d\d-\d\d ' -and $_ -notmatch '^- \[.*\]\(memory/'
        } | ForEach-Object {
            # the example first item keeps its number, so the list still reads 1. 2. 3.
            if ($_ -match '^1\. \*\*') { "1.`n" } else { $_ }
        })
        New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
        [System.IO.File]::WriteAllText($dst, (-join $keep), (New-Object System.Text.UTF8Encoding($false)))
        Write-Host ("  placed   " + $dst + "  (example lines left out)") -ForegroundColor Green
    } else {
        Write-Host ("  NOTE: " + $src + " not found next to this script; copy it into work\ manually.") -ForegroundColor Yellow
    }
}

foreach ($name in "TASKS.md", "TODAY.md", "MEMORY.md") {
    Copy-Blank (Join-Path $tpl $name) (Join-Path $work $name)
}
# The two personal files ship blank already (the AI fills them in only after a yes; gitignored).
foreach ($name in "ABOUT-ME.md", "FRUSTRATIONS.md") {
    Copy-IfAbsent (Join-Path $tpl $name) (Join-Path $work $name)
}
$memDst = Join-Path $work "memory"
if (-not (Test-Path $memDst)) {
    New-Item -ItemType Directory -Path $memDst | Out-Null
    Write-Host ("  created  " + $memDst) -ForegroundColor Green
}
# work\templates\ holds the full examples (and the other starting shapes). Never overwritten.
foreach ($name in "TASKS.md", "TODAY.md", "MEMORY.md", "handoff.md", "card.md", "progress.md", "ABOUT-ME.md", "FRUSTRATIONS.md", "fundamentals.jsonl") {
    Copy-IfAbsent (Join-Path $tpl $name) (Join-Path $work "templates\$name")
}
Copy-IfAbsent (Join-Path $tpl "memory") (Join-Path $work "templates\memory")

# Version marker: which kit release this install came from, so a later update has a base to
# diff against. Read from the first "## [vX]" line of CHANGELOG.md next to this script.
$kitVersion = 'unknown'
$changelog = Join-Path $PSScriptRoot "CHANGELOG.md"
if (Test-Path $changelog) {
    $m = Select-String -Path $changelog -Pattern '^## \[(v[0-9.]+)\]' | Select-Object -First 1
    if ($m) { $kitVersion = $m.Matches[0].Groups[1].Value }
}
if ($existingInstall) { $kitVersion = 'unknown' }
$verFile = Join-Path $work "KIT-VERSION.txt"
if (Test-Path $verFile) {
    Write-Host ("  exists   " + $verFile + "  (left untouched)") -ForegroundColor DarkGray
} else {
    Set-Content -Path $verFile -Encoding ASCII -Value @(
        "kit-version: $kitVersion",
        "installed: $(Get-Date -Format 'yyyy-MM-dd')",
        "note: the update-kit skill changes this line after an update (README, Updating this kit)."
    )
    Write-Host ("  placed   " + $verFile + "  (kit-version: $kitVersion)") -ForegroundColor Green
}

$skillsSrc = Join-Path $PSScriptRoot "skills"
$skillsDst = Join-Path $work "skills"
if (-not (Test-Path $skillsSrc)) {
    Write-Host "  NOTE: skills\ folder not found next to this script; copy it into work\ manually." -ForegroundColor Yellow
} elseif (-not (Test-Path $skillsDst)) {
    Copy-Item $skillsSrc $skillsDst -Recurse
    Write-Host ("  placed   " + $skillsDst) -ForegroundColor Green
} else {
    # IA-003: skillsDst existing doesn't mean every skill subfolder does -- a rerun after an
    # interrupted first install (or a newly-added skill in this kit) never backfilled the
    # missing ones. Reconcile per-subfolder AND per top-level file (Flag E: e.g. skills\README.md).
    Get-ChildItem -LiteralPath $skillsSrc | ForEach-Object {
        Copy-IfAbsent $_.FullName (Join-Path $skillsDst $_.Name)
    }
}

# --- Step 4: tool configs (only if absent -- never overwrite yours) ---------
if ($Tool -eq 'codex' -or $Tool -eq 'both') {
    $codexDst = Join-Path $env:USERPROFILE ".codex\config.toml"
    if (Test-Path $codexDst) {
        Write-Host ("  exists   " + $codexDst + "  -- compare by hand: " + (Join-Path $PSScriptRoot "tools\codex\config.toml") + " vs " + $codexDst) -ForegroundColor Yellow
    } else {
        New-Item -ItemType Directory -Force (Split-Path $codexDst) | Out-Null
        Copy-Item (Join-Path $PSScriptRoot "tools\codex\config.toml") $codexDst
        Write-Host ("  placed   " + $codexDst) -ForegroundColor Green
    }
}

if ($Tool -eq 'claude' -or $Tool -eq 'both') {
    $claudeDst = Join-Path $env:USERPROFILE ".claude\settings.json"
    if (Test-Path $claudeDst) {
        Write-Host ("  exists   " + $claudeDst + "  -- compare by hand: " + (Join-Path $PSScriptRoot "tools\claude-code\settings.json") + " vs " + $claudeDst) -ForegroundColor Yellow
    } else {
        New-Item -ItemType Directory -Force (Split-Path $claudeDst) | Out-Null
        # ponytail: a relative Read/Edit(../private/**) deny pattern does not reliably block
        # tool access (measured live, 2026-09) -- template the real absolute path in instead, in
        # the //<drive>/... form Claude Code's docs give for an absolute path (C:\x -> //c/x).
        $privForward = '//' + $priv.Substring(0, 1).ToLower() + $priv.Substring(2).Replace('\', '/')
        $settingsTemplate = Get-Content (Join-Path $PSScriptRoot "tools\claude-code\settings.json") -Raw
        $settingsTemplate = $settingsTemplate.Replace('../private/**', "$privForward/**")
        Set-Content -Path $claudeDst -Value $settingsTemplate -NoNewline
        Write-Host ("  placed   " + $claudeDst + "  (private-folder path templated in)") -ForegroundColor Green
    }
}

if ($Tool -eq 'opencode') {
    # OpenCode reads opencode.json and .opencode\commands\ from the folder it starts in.
    $oc = Join-Path $PSScriptRoot "tools\opencode"
    Copy-IfAbsent (Join-Path $oc "opencode.json") (Join-Path $work "opencode.json")
    foreach ($name in "today.md", "close.md") {
        Copy-IfAbsent (Join-Path $oc "commands\$name") (Join-Path $work ".opencode\commands\$name")
    }
}

# --- Step 5: the checks you should run yourself -----------------------------
Write-Host ""
Write-Host "Done. Now cd into work\ and launch your tool, then run these three checks:" -ForegroundColor Cyan
Write-Host ("  cd " + '"' + $work + '"')
Write-Host "  1. Ask it to read a file in ..\private\  -> should refuse or say it's outside its workspace."
Write-Host "  2. Ask it to create a test file in work\ -> should succeed."
Write-Host "  3. Ask it to read ..\private\does-not-exist.txt, then work\does-not-exist.txt."
Write-Host "     Identical errors = reads aren't fenced. A distinct 'denied by permission settings'"
Write-Host "     error on the private path = they are, for this tool. Both are real outcomes -- see README.md."
Write-Host "  Run these three checks again after every update of the AI tool itself: a config the new"
Write-Host "  version doesn't read gives no error, just no fence."
Write-Host ""
Write-Host "Or just say: 'read skills/setup-tutor/SKILL.md and walk me through it' and let the AI run the checks with you." -ForegroundColor Cyan

# setup.ps1
# Scaffolds an ai-starter-kit workspace on Windows and installs the tool(s) you pick.
# SAFE + IDEMPOTENT: only creates what's missing, never deletes or overwrites anything you
# already have. Run it as many times as you like.
#
# Usage (from this kit's folder, in PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool both
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool codex
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Tool claude -Base "D:\ai-work"
#
# Result:
#   <Base>\work\            <- launch your AI tool from here (its sandbox root)
#   <Base>\work\projects\
#   <Base>\work\_archive\    <- archive-don't-delete target
#   <Base>\private\          <- OUTSIDE work\. Never launch your AI tool here.
#
# ponytail: no PATH refresh after install — reopen PowerShell if `codex`/`claude` isn't found.

param(
    [Parameter(Mandatory)]
    [ValidateSet('codex', 'claude', 'both')]
    [string]$Tool,

    [string]$Base = (Join-Path $env:USERPROFILE "Desktop")
)

$ErrorActionPreference = 'Stop'

$work    = Join-Path $Base "work"
$priv    = Join-Path $Base "private"
$dirs = @(
    $work,
    (Join-Path $work "projects"),
    (Join-Path $work "_archive"),
    $priv
)

Write-Host "Setting up ai-starter-kit under: $Base" -ForegroundColor Cyan

# --- Step 1: folder layout -------------------------------------------------
foreach ($d in $dirs) {
    if (Test-Path $d) {
        Write-Host ("  exists   " + $d) -ForegroundColor DarkGray
    } else {
        New-Item -ItemType Directory -Path $d | Out-Null
        Write-Host ("  created  " + $d) -ForegroundColor Green
    }
}

# --- Step 2: tool installs (skip anything already on PATH) -----------------
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "  installing Node.js LTS (winget)..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "  exists   node" -ForegroundColor DarkGray
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  installing Git (winget)..." -ForegroundColor Yellow
    winget install --id Git.Git --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "  exists   git" -ForegroundColor DarkGray
}

if ($Tool -eq 'codex' -or $Tool -eq 'both') {
    if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
        Write-Host "  installing @openai/codex (npm)..." -ForegroundColor Yellow
        npm install -g @openai/codex
    } else {
        Write-Host "  exists   codex" -ForegroundColor DarkGray
    }
}

if ($Tool -eq 'claude' -or $Tool -eq 'both') {
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Host "  installing @anthropic-ai/claude-code (npm)..." -ForegroundColor Yellow
        npm install -g @anthropic-ai/claude-code
    } else {
        Write-Host "  exists   claude" -ForegroundColor DarkGray
    }
}

# --- Step 3: place instruction files + skills into work\ (only if absent) --
foreach ($name in "AGENTS.md", "CLAUDE.md", "WORKFLOWS.md", "SEATS.md") {
    $src = Join-Path $PSScriptRoot $name
    $dst = Join-Path $work $name
    if (Test-Path $dst) {
        Write-Host ("  exists   " + $dst + "  (left untouched)") -ForegroundColor DarkGray
    } elseif (Test-Path $src) {
        Copy-Item $src $dst
        Write-Host ("  placed   " + $dst) -ForegroundColor Green
    } else {
        Write-Host ("  NOTE: " + $name + " not found next to this script; copy it into work\ manually.") -ForegroundColor Yellow
    }
}

$skillsSrc = Join-Path $PSScriptRoot "skills"
$skillsDst = Join-Path $work "skills"
if (Test-Path $skillsDst) {
    Write-Host ("  exists   " + $skillsDst + "  (left untouched)") -ForegroundColor DarkGray
} elseif (Test-Path $skillsSrc) {
    Copy-Item $skillsSrc $skillsDst -Recurse
    Write-Host ("  placed   " + $skillsDst) -ForegroundColor Green
} else {
    Write-Host "  NOTE: skills\ folder not found next to this script; copy it into work\ manually." -ForegroundColor Yellow
}

# --- Step 4: tool configs (only if absent — never overwrite yours) ---------
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
        # tool access (measured live, 2026-09) -- template the real absolute path in instead.
        $privForward = $priv.Replace('\', '/')
        $settingsTemplate = Get-Content (Join-Path $PSScriptRoot "tools\claude-code\settings.json") -Raw
        $settingsTemplate = $settingsTemplate.Replace('../private/**', "$privForward/**")
        Set-Content -Path $claudeDst -Value $settingsTemplate -NoNewline
        Write-Host ("  placed   " + $claudeDst + "  (private-folder path templated in)") -ForegroundColor Green
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
Write-Host ""
Write-Host "Or just say: 'read skills/setup-tutor/SKILL.md and walk me through it' and let the AI run the checks with you." -ForegroundColor Cyan

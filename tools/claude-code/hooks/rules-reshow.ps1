# rules-reshow.ps1 - optional Claude Code "UserPromptSubmit" hook (Windows PowerShell 5.1).
#
# The five "Right-now rules" in AGENTS.md are shown in the AI's first reply of a session. In a
# long session they stop steering it. This re-injects them on every 5th message you send, so
# they are in front of the AI again. The rules are read from AGENTS.md, so there is one copy.
#
# Contract (Claude Code hooks reference, UserPromptSubmit event):
#   https://docs.claude.com/en/docs/claude-code/hooks
#   input JSON on stdin: session_id, cwd, prompt. Plain text on stdout is added as context.
# The count lives in $env:TEMP, one small file per session. Any error prints nothing and never
# blocks your prompt. ASCII only, on purpose.

try {
    $in = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $f = Join-Path $env:TEMP ('rules-reshow-' + ($in.session_id -replace '[^\w-]', '') + '.count')
    $n = 1 + [int](Get-Content $f -ErrorAction SilentlyContinue)
    Set-Content $f $n
    if ($n % 5 -ne 0) { exit 0 }

    # AGENTS.md in the session folder or the nearest folder above it (work\projects\x -> work\).
    $agents = $null
    foreach ($start in @($in.cwd, $env:CLAUDE_PROJECT_DIR) | Where-Object { $_ }) {
        $d = $start
        while ($d -and -not $agents) { if (Test-Path (Join-Path $d 'AGENTS.md')) { $agents = Join-Path $d 'AGENTS.md' }; $d = Split-Path $d }
        if ($agents) { break }
    }
    if (-not $agents) { exit 0 }

    $all = @(Get-Content $agents -Encoding UTF8)
    $start = [array]::IndexOf($all, '## Right-now rules')
    if ($start -lt 0) { exit 0 }
    $rules = @()
    foreach ($l in $all[($start + 1)..($all.Count - 1)]) {
        if ($l -match '^(---|## )') { break }
        if ($rules.Count -gt 0 -or $l -match '^- ') { $rules += $l }
    }
    $out = "Reminder (every 5th message), your Right-now rules from AGENTS.md:`n" + ($rules -join "`n")
    $out.Replace([string][char]0xA7, 'section ') -replace '[^\x09\x0A\x0D\x20-\x7E]', '?'   # ASCII only on stdout
} catch { }
exit 0

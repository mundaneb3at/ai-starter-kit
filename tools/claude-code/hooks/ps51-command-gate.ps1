# ps51-command-gate.ps1 - optional Claude Code "Stop" hook (Windows PowerShell 5.1).
#
# Problem: the AI shows you a PowerShell command in chat, you paste it, and it fails because
# it uses `&&`, `||`, `??`, a ternary, or a <placeholder> that PowerShell 5.1 cannot parse.
# A written rule does not stop this reliably. A parser does.
#
# What it does: when the AI finishes a reply, this reads that reply, parses every fenced
# powershell / ps1 code block with the real PowerShell parser, and if one will not run it
# blocks the stop and tells the AI to fix the command. One retry only: if the hook has
# already blocked once this turn (stop_hook_active), it lets the reply through.
#
# Contract (Claude Code hooks reference, Stop event):
#   https://docs.claude.com/en/docs/claude-code/hooks
#   input JSON on stdin: transcript_path, stop_hook_active, last_assistant_message
#   output: {"decision":"block","reason":"..."} on stdout, exit 0. No output = allow.
# Any error inside this script allows the reply (fail open). ASCII only, on purpose.

try {
    $in = [Console]::In.ReadToEnd() | ConvertFrom-Json
    if ($in.stop_hook_active) { exit 0 }

    # Newest reply text: the field Claude Code passes, else the last assistant line of the transcript.
    $text = [string]$in.last_assistant_message
    if (-not $text -and $in.transcript_path -and (Test-Path $in.transcript_path)) {
        $lines = @(Get-Content $in.transcript_path -Tail 200 -Encoding UTF8)
        [array]::Reverse($lines)
        foreach ($l in $lines) {
            $o = $l | ConvertFrom-Json
            if ($o.type -ne 'assistant') { continue }
            $text = (@($o.message.content) | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text }) -join "`n"
            if ($text) { break }
        }
    }

    $fence = '(?ms)^[ \t]*```[ \t]*(?:powershell|ps1)[ \t]*\r?\n(.*?)\r?\n[ \t]*```'
    $bad = @()
    foreach ($m in [regex]::Matches($text, $fence)) {
        if ($m.Groups[1].Value -match '(?m)^PS [A-Za-z]:\\[^>]*>') { continue }   # a console transcript, not a command to paste
        $tokens = $null; $errs = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($m.Groups[1].Value, [ref]$tokens, [ref]$errs)
        $ps7 = @($tokens | Where-Object { $_.Kind.ToString() -in 'AndAnd', 'OrOr', 'QuestionQuestion', 'QuestionMark', 'QuestionDot' })
        if ($errs.Count -gt 0) { $bad += $errs[0].Message }
        elseif ($ps7.Count -gt 0) { $bad += 'PowerShell 7-only syntax: ' + $ps7[0].Text }
    }

    if ($bad.Count -gt 0) {
        $reason = 'A PowerShell block in your last reply will not run on Windows PowerShell 5.1 (' + ($bad[0] -replace '\s+', ' ') + '). ' +
            'Rewrite it: no && || ?? or ternary (chain with `; if ($?) { ... }`), no <placeholder> angle brackets, quote paths with spaces. Then answer again.'
        @{ decision = 'block'; reason = $reason } | ConvertTo-Json -Compress
    }
} catch { }
exit 0

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$main = Join-Path $root '.claude/scripts/statusline.ps1'
$subagent = Join-Path $root '.claude/scripts/subagent-statusline.ps1'

function Invoke-StatusLine {
    param([string]$Script, $Payload)
    $Payload | ConvertTo-Json -Depth 8 -Compress | & powershell -NoProfile -File $Script
}

$fresh = [ordered]@{
    model = @{ display_name = 'Sonnet' }
    workspace = @{ current_dir = 'H:/CommandCenter/orchestrator' }
    context_window = @{ used_percentage = $null; remaining_percentage = $null }
    cost = @{ total_cost_usd = 0; total_duration_ms = 0; total_api_duration_ms = 0 }
}
$freshOutput = @(Invoke-StatusLine $main $fresh)
if ($freshOutput.Count -ne 2 -or $freshOutput[1] -notmatch '0% used / 100% free') { throw 'Fresh-session context fallback failed.' }

$normal = [ordered]@{
    model = @{ display_name = 'Opus' }
    workspace = @{ current_dir = 'H:/CommandCenter/orchestrator'; git_worktree = 'feature-status' }
    agent = @{ name = 'orchestrator' }
    context_window = @{ used_percentage = 74.8; remaining_percentage = 25.2 }
    cost = @{ total_cost_usd = 1.25; total_duration_ms = 65000; total_api_duration_ms = 3000 }
    effort = @{ level = 'medium' }
    thinking = @{ enabled = $true }
    rate_limits = @{ five_hour = @{ used_percentage = 15.1 }; seven_day = @{ used_percentage = 42.8 } }
    pr = @{ number = 12; review_state = 'pending' }
}
$normalOutput = @(Invoke-StatusLine $main $normal)
if ($normalOutput.Count -ne 2 -or $normalOutput[1] -notmatch '74% used / 25% free' -or $normalOutput[1] -notmatch 'eff:med' -or $normalOutput[1] -match 'thinking:on' -or $normalOutput[1] -notmatch '5h:15%' -or $normalOutput[1] -notmatch 'PR #12:pending') { throw 'Normal-session rendering failed.' }

$tasksPayload = [ordered]@{
    columns = 120
    tasks = @(
        @{ id = 'resolved'; name = 'planner'; status = 'running'; label = 'Plan request'; model = 'claude-sonnet'; tokenCount = 50000; contextWindowSize = 200000 },
        @{ id = 'unresolved'; name = 'verifier'; status = 'pending'; label = $null; model = $null; tokenCount = $null; contextWindowSize = $null }
    )
}
$rows = @(Invoke-StatusLine $subagent $tasksPayload | ForEach-Object { $_ | ConvertFrom-Json })
if ($rows.Count -ne 2) { throw 'Subagent row count failed.' }
if ($rows[0].id -ne 'resolved' -or $rows[0].content -notmatch 'ctx: 25%') { throw 'Resolved subagent context failed.' }
if ($rows[1].id -ne 'unresolved' -or $rows[1].content -notmatch 'ctx: n/a') { throw 'Unresolved subagent fallback failed.' }

Write-Output 'Status line tests passed.'

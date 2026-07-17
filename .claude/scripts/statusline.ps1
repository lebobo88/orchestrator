$ErrorActionPreference = 'SilentlyContinue'

function Get-PropertyValue {
    param($Object, [string]$Name, $Default = $null)
    if ($null -eq $Object) { return $Default }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return $Default }
    return $property.Value
}

function Format-Duration {
    param($Milliseconds)
    if ($null -eq $Milliseconds) { $Milliseconds = 0 }
    $seconds = [math]::Floor(([double]$Milliseconds) / 1000)
    return ('{0}m {1}s' -f [math]::Floor($seconds / 60), ($seconds % 60))
}

function Truncate-Text {
    param([string]$Text)
    $columns = 0
    [void][int]::TryParse($env:COLUMNS, [ref]$columns)
    if ($columns -gt 0 -and $Text.Length -gt $columns) {
        return $Text.Substring(0, [math]::Max(0, $columns - 3)) + '...'
    }
    return $Text
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { exit 0 }

try {
    $data = $rawInput | ConvertFrom-Json
} catch {
    exit 0
}

$model = Get-PropertyValue (Get-PropertyValue $data 'model') 'display_name' 'Claude'
$workspace = Get-PropertyValue $data 'workspace'
$directory = Split-Path -Leaf (Get-PropertyValue $workspace 'current_dir' (Get-PropertyValue $data 'cwd' ''))
if ([string]::IsNullOrWhiteSpace($directory)) { $directory = 'workspace' }

$agent = Get-PropertyValue (Get-PropertyValue $data 'agent') 'name' 'orchestrator'
$sessionName = Get-PropertyValue $data 'session_name'
$worktree = Get-PropertyValue $data 'worktree'
$worktreeName = Get-PropertyValue $worktree 'name' (Get-PropertyValue $workspace 'git_worktree')

$branch = ''
$staged = 0
$modified = 0
try {
    $branch = (git branch --show-current 2>$null).Trim()
    $staged = @((git diff --cached --numstat 2>$null) | Where-Object { $_ }).Count
    $modified = @((git diff --numstat 2>$null) | Where-Object { $_ }).Count
} catch {}

$identity = "[$model] $directory"
if ($sessionName) { $identity += " ($sessionName)" }
if ($worktreeName) { $identity += " wt:$worktreeName" }
if ($branch) { $identity += " | $branch +$staged ~$modified" }
Write-Output (Truncate-Text $identity)

$context = Get-PropertyValue $data 'context_window'
$used = [math]::Floor([double](Get-PropertyValue $context 'used_percentage' 0))
$remaining = [math]::Floor([double](Get-PropertyValue $context 'remaining_percentage' (100 - $used)))
$used = [math]::Min(100, [math]::Max(0, $used))
$remaining = [math]::Min(100, [math]::Max(0, $remaining))
$filled = [math]::Floor($used / 10)
$bar = ('#' * $filled) + ('-' * (10 - $filled))
$green = "$([char]27)[32m"
$yellow = "$([char]27)[33m"
$red = "$([char]27)[31m"
$reset = "$([char]27)[0m"
$barColor = $green
if ($used -ge 90) { $barColor = $red }
elseif ($used -ge 70) { $barColor = $yellow }

$cost = Get-PropertyValue $data 'cost'
$costValue = [double](Get-PropertyValue $cost 'total_cost_usd' 0)
$duration = Format-Duration (Get-PropertyValue $cost 'total_duration_ms' 0)
$apiDuration = Format-Duration (Get-PropertyValue $cost 'total_api_duration_ms' 0)
$costFormatted = '$' + ('{0:N2}' -f $costValue)
$details = "ctx: $barColor$bar$reset $used% used / $remaining% free | $costFormatted | $duration (API $apiDuration)"

$effort = Get-PropertyValue (Get-PropertyValue $data 'effort') 'level'
if ($effort) {
    $effortLabel = switch ($effort) {
        'medium' { 'med' }
        default { $effort }
    }
    $details += " | eff:$effortLabel"
}

$rateLimits = Get-PropertyValue $data 'rate_limits'
$fiveHour = Get-PropertyValue (Get-PropertyValue $rateLimits 'five_hour') 'used_percentage'
$sevenDay = Get-PropertyValue (Get-PropertyValue $rateLimits 'seven_day') 'used_percentage'
if ($null -ne $fiveHour) { $details += (' | 5h:{0}%' -f [math]::Round([double]$fiveHour)) }
if ($null -ne $sevenDay) { $details += (' 7d:{0}%' -f [math]::Round([double]$sevenDay)) }

$pr = Get-PropertyValue $data 'pr'
$prNumber = Get-PropertyValue $pr 'number'
if ($prNumber) { $details += " | PR #$prNumber"; if (Get-PropertyValue $pr 'review_state') { $details += ":$(Get-PropertyValue $pr 'review_state')" } }
$details += " | $agent | Plan -> Review -> Approve -> Build -> Verify -> Report"
Write-Output (Truncate-Text $details)

# .codex/hooks/validate-agent-dispatch.ps1
# PowerShell 7 subagent dispatch validation hook for Codex CLI harness

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [object]$InputObject,

    [Parameter(Mandatory = $false)]
    [ValidateSet('session', 'orchestrator', 'planner', 'design-director')]
    [string]$Parent = 'session'
)

$ErrorActionPreference = 'Stop'

function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput) -and $null -ne $InputObject) {
    $rawInput = ($InputObject | Out-String)
}
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    $rawInput = @($input) -join [System.Environment]::NewLine
}
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    Deny 'missing Agent hook input.'
}

try {
    $payload = $rawInput | ConvertFrom-Json
    $toolInput = $payload.tool_input
    $child = [string]$toolInput.subagent_type
    if ([string]::IsNullOrWhiteSpace($child)) {
        $child = [string]$toolInput.agent
    }
}
catch {
    Deny 'invalid Agent hook input.'
}

$allowed = @(
    'planner', 'researcher', 'scribe', 'design-generalist', 'design-director',
    'ux-architect', 'visual-system-designer', 'motion-designer', 'asset-art-director',
    'design-reviewer', 'design-prototyper', 't1-engineer', 't2-engineer',
    't3-engineering-advisor', 'engineering-lead', 'verifier', 'browser-validator',
    'codex-judge-runner'
)

if ([string]::IsNullOrWhiteSpace($child) -or $allowed -notcontains $child) {
    Deny "serial session cannot dispatch '$child'."
}

$properties = @()
foreach ($property in $toolInput.PSObject.Properties) { $properties += $property.Name }

if ($properties -contains 'run_in_background' -and $toolInput.run_in_background -ne $false) {
    Deny 'serial harness dispatches cannot request background execution.'
}

if ($properties -contains 'name' -and -not [string]::IsNullOrWhiteSpace([string]$toolInput.name)) {
    $name = [string]$toolInput.name
    Deny "named dispatch is not permitted (name='$name'). Dispatch names create addressable teammates instead of returning results directly."
}

foreach ($forbiddenField in @('team_name', 'teammate_name', 'isolation')) {
    if ($properties -contains $forbiddenField -and -not [string]::IsNullOrWhiteSpace([string]$toolInput.$forbiddenField)) {
        Deny "serial harness dispatches cannot set '$forbiddenField'."
    }
}

exit 0

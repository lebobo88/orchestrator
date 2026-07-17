param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('session')]
    [string]$Parent
)

$ErrorActionPreference = 'Stop'

function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { Deny 'missing Agent hook input.' }

try {
    $payload = $rawInput | ConvertFrom-Json
    $toolInput = $payload.tool_input
    $child = [string]$toolInput.subagent_type
}
catch {
    Deny 'invalid Agent hook input.'
}

$allowed = @('planner', 'researcher', 'scribe', 'design-generalist', 'design-director', 'ux-architect', 'visual-system-designer', 'motion-designer', 'asset-art-director', 'design-reviewer', 'design-prototyper', 't1-engineer', 't2-engineer', 't3-engineering-advisor', 'engineering-lead', 'verifier', 'browser-validator', 'codex-judge-runner')

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
    if ($name -notmatch '^[a-z][a-z0-9-]{0,63}$') {
        Deny "subagent name '$name' must use lowercase letters, digits, and hyphens only (maximum 64 characters)."
    }
}

foreach ($forbiddenField in @('team_name', 'teammate_name', 'isolation')) {
    if ($properties -contains $forbiddenField -and -not [string]::IsNullOrWhiteSpace([string]$toolInput.$forbiddenField)) {
        Deny "serial harness dispatches cannot set '$forbiddenField'."
    }
}

exit 0

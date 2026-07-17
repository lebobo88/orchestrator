param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('planner', 'design-generalist', 'design-director', 'ux-architect', 'visual-system-designer', 'motion-designer', 'asset-art-director', 'design-reviewer', 'design-prototyper')]
    [string]$Role
)

$ErrorActionPreference = 'Stop'

function Block-Completion([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}

function Test-DelimitedPacket([string]$Message, [string]$Header, [string]$Footer, [string[]]$RequiredFields) {
    if ($Message -notmatch "(?s)^\s*$([regex]::Escape($Header))\s*\r?\n") { return $false }
    if ($Message -notmatch "(?s)\r?\n$([regex]::Escape($Footer))\s*$") { return $false }
    foreach ($field in $RequiredFields) {
        if ($Message -notmatch "(?mi)^\s*$([regex]::Escape($field))") { return $false }
    }
    return $true
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { Block-Completion 'missing terminal hook input.' }

try {
    $payload = $rawInput | ConvertFrom-Json
    $message = [string]$payload.last_assistant_message
    $alreadyCorrected = [bool]$payload.stop_hook_active
}
catch {
    Block-Completion 'invalid terminal hook input.'
}

$specs = @{
    'design-generalist' = @(
        @{ Header = 'DESIGN_HANDOFF'; Footer = 'END_DESIGN_HANDOFF'; Fields = @('task_id:', 'selected_direction:', 'ux_spec:', 'visual_system_spec:', 'engineering_invariants:', 'browser_validation_brief:') },
        @{ Header = 'DESIGN_BLOCKED'; Footer = 'END_DESIGN_BLOCKED'; Fields = @('reason:', 'evidence:') }
    )
    'design-director' = @(
        @{ Header = 'DESIGN_SELECTION_NEEDED'; Footer = 'END_DESIGN_SELECTION_NEEDED'; Fields = @('safe:', 'refined:', 'novel:') },
        @{ Header = 'DESIGN_HANDOFF'; Footer = 'END_DESIGN_HANDOFF'; Fields = @('task_id:', 'selected_direction:', 'ux_spec:', 'visual_system_spec:', 'engineering_invariants:', 'browser_validation_brief:') },
        @{ Header = 'DESIGN_BLOCKED'; Footer = 'END_DESIGN_BLOCKED'; Fields = @('reason:', 'evidence:') }
    )
    'ux-architect' = @(
        @{ Header = 'UX_SPEC'; Footer = 'END_UX_SPEC'; Fields = @('journeys:', 'information_architecture:', 'responsive_behavior:', 'accessibility:', 'states:', 'evidence:', 'assumptions:', 'unresolved_decisions:') },
        @{ Header = 'DESIGN_BLOCKED'; Footer = 'END_DESIGN_BLOCKED'; Fields = @('reason:', 'evidence:') }
    )
    'visual-system-designer' = @(
        @{ Header = 'VISUAL_SYSTEM_SPEC'; Footer = 'END_VISUAL_SYSTEM_SPEC'; Fields = @('selected_direction:', 'direction_rationale:', 'typography:', 'color_and_contrast:', 'layout_and_density:', 'tokens:', 'components_and_states:', 'accessibility:', 'engineering_invariants:', 'evidence:', 'assumptions:', 'unresolved_decisions:') },
        @{ Header = 'DESIGN_BLOCKED'; Footer = 'END_DESIGN_BLOCKED'; Fields = @('reason:', 'evidence:') }
    )
    'motion-designer' = @(
        @{ Header = 'MOTION_ASSET_SPEC'; Footer = 'END_MOTION_ASSET_SPEC'; Fields = @('scope: motion', 'purpose:', 'reduced_motion:', 'evidence:') },
        @{ Header = 'DESIGN_BLOCKED'; Footer = 'END_DESIGN_BLOCKED'; Fields = @('reason:', 'evidence:') }
    )
    'asset-art-director' = @(
        @{ Header = 'MOTION_ASSET_SPEC'; Footer = 'END_MOTION_ASSET_SPEC'; Fields = @('scope: asset', 'asset_brief:', 'fallback:', 'evidence:') },
        @{ Header = 'DESIGN_BLOCKED'; Footer = 'END_DESIGN_BLOCKED'; Fields = @('reason:', 'evidence:') }
    )
    'design-reviewer' = @(
        @{ Header = 'DESIGN_REVIEW_RESULT'; Footer = 'END_DESIGN_REVIEW_RESULT'; Fields = @('verdict:', 'findings:', 'reviewed_direction:', 'remaining_limits:') },
        @{ Header = 'DESIGN_BLOCKED'; Footer = 'END_DESIGN_BLOCKED'; Fields = @('reason:', 'evidence:') }
    )
    'design-prototyper' = @(
        @{ Header = 'PROTOTYPE_DONE'; Footer = 'END_PROTOTYPE_DONE'; Fields = @('path:', 'validation:') },
        @{ Header = 'PROTOTYPE_BLOCKED'; Footer = 'END_PROTOTYPE_BLOCKED'; Fields = @('reason:', 'evidence:') }
    )
}

$valid = $false
if ($Role -eq 'planner') {
    $valid = $message -match "(?m)^\s*(?:PLAN_READY|PLAN_BLOCKED)\b"
}
else {
    foreach ($spec in $specs[$Role]) {
        if (Test-DelimitedPacket -Message $message -Header $spec.Header -Footer $spec.Footer -RequiredFields $spec.Fields) {
            $valid = $true
            break
        }
    }
}
if ($valid) { exit 0 }

if (-not $alreadyCorrected) {
    if ($Role -eq 'planner') {
        Block-Completion 'planner must return one terminal packet: PLAN_READY or PLAN_BLOCKED.'
    }
    Block-Completion "$Role must return its complete, self-contained terminal packet with every required field and closing marker."
}

# A second invalid stop must reach the parent, which maps it to a bounded protocol blocker.
exit 0

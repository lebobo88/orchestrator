# tests/verify-governance.ps1
#
# Standalone governance integrity check. Independent of tests/validate.ps1: an operator can run
# this at any time (not just as part of the full static suite) to answer one narrow question -
# "is managed-scope control-plane protection actually loaded and intact on this machine, right
# now?" It is read-only and makes no changes.
#
# This script intentionally duplicates a subset of tests/validate.ps1's managed-settings checks
# (see validate.ps1's "Rule-syntax assertion" section) rather than importing it, so it keeps
# working even if validate.ps1 is temporarily broken, mid-edit, or unavailable.
#
# Exit code: 0 = governance intact. 1 = governance gap detected (fail closed - treat as blocking
# for engineering work until resolved). 2 = could not evaluate (e.g. managed file unreadable);
# treat as a warning requiring investigation, not a silent pass.

$ErrorActionPreference = 'Stop'
$failures = @()
$warnings = @()

function Report-Fail([string]$Message) { $script:failures += $Message }
function Report-Warn([string]$Message) { $script:warnings += $Message }

Write-Output '--- Governance verification: managed-settings control-plane check ---'

$managedSettingsPath = 'C:\Program Files\ClaudeCode\managed-settings.json'
$managedSettings = $null
$managedSettingsAvailable = $false

if (-not (Test-Path -LiteralPath $managedSettingsPath -ErrorAction SilentlyContinue)) {
    Report-Warn "Managed settings file not found at '$managedSettingsPath'. Control-plane protection cannot be confirmed on this machine."
} else {
    try {
        $managedSettings = Get-Content -Raw -LiteralPath $managedSettingsPath | ConvertFrom-Json -ErrorAction Stop
        if ($managedSettings -and $managedSettings.permissions) {
            $managedSettingsAvailable = $true
        } else {
            Report-Warn "Managed settings file at '$managedSettingsPath' parsed but has no 'permissions' block."
        }
    } catch {
        Report-Warn "Managed settings file at '$managedSettingsPath' could not be parsed as JSON: $($_.Exception.Message)"
    }
}

if ($managedSettingsAvailable) {
    Write-Output "Managed settings file loaded: $managedSettingsPath"

    # 1. Required control-plane Edit(...) denies (Phase 2 deployment).
    $requiredEditDenies = @(
        'Edit(//h/CommandCenter/orchestrator/.claude/**)',
        'Edit(//h/CommandCenter/orchestrator/CLAUDE.md)',
        'Edit(//h/CommandCenter/orchestrator/.mcp.json)'
    )
    $denyRules = @($managedSettings.permissions.deny)

    foreach ($requiredRule in $requiredEditDenies) {
        if ($denyRules -notcontains $requiredRule) {
            Report-Fail "Required control-plane deny rule '$requiredRule' is missing from managed-settings.json."
        }
    }

    # Also accept a docs/*CONTRACT*.md-style glob if present under any of the recorded naming
    # conventions used across this plan's implementation history; do not hard-fail on the exact
    # glob spelling since case history shows this can vary, but warn if none is present at all.
    $hasContractDeny = $false
    foreach ($rule in $denyRules) {
        if ($rule -match 'CONTRACT' -and $rule -match '^Edit\(') { $hasContractDeny = $true }
    }
    if (-not $hasContractDeny) {
        Report-Warn "No Edit(...) deny rule matching 'docs/*CONTRACT*.md' was found in managed-settings.json. Confirm this is intentional (contract docs may be covered by a broader docs/** rule instead)."
    }

    # 2. Required Agent(...) built-in denies.
    $requiredAgentDenies = @(
        'Agent(general-purpose)',
        'Agent(Explore)',
        'Agent(Plan)'
    )
    foreach ($requiredRule in $requiredAgentDenies) {
        if ($denyRules -notcontains $requiredRule) {
            Report-Fail "Required built-in agent deny '$requiredRule' is missing from managed-settings.json."
        }
    }

    # 3. Destructive-command Bash denies (documented prefix form; see Appendix A rule-syntax facts).
    $requiredBashDenies = @(
        'Bash(rm -rf:*)',
        'Bash(git push --force:*)',
        'Bash(git clean -fd:*)'
    )
    foreach ($requiredRule in $requiredBashDenies) {
        if ($denyRules -notcontains $requiredRule) {
            Report-Fail "Required destructive-command deny '$requiredRule' is missing from managed-settings.json."
        }
    }

    # 4. Rule-syntax sanity: no Windows drive-letter backslash paths (these silently fail to match
    #    the runtime-normalized POSIX path Claude Code actually evaluates against).
    $allManagedRules = @()
    foreach ($category in @('allow', 'deny', 'ask')) {
        if ($managedSettings.permissions.$category) { $allManagedRules += @($managedSettings.permissions.$category) }
    }
    foreach ($rule in $allManagedRules) {
        if ($rule -match '[A-Za-z]:\\') {
            Report-Fail "Managed permission rule '$rule' uses a Windows drive-letter backslash path instead of the POSIX-normalized '//h/...' form; this rule will not match and is effectively inert."
        }
    }

    # 5. Blast-radius guard: disableBypassPermissionsMode / disableAutoMode were deliberately
    #    REMOVED from managed settings during this plan's Phase 2 correction because the managed
    #    path is machine-wide and those keys would affect every repository on the machine, not
    #    just this one. Warn (do not fail) if they have been reintroduced, since that is a known
    #    prior mistake this check exists to catch a repeat of.
    if ($managedSettings.permissions.disableBypassPermissionsMode -or $managedSettings.disableAutoMode -or $managedSettings.permissions.disableAutoMode) {
        Report-Warn "'disableBypassPermissionsMode' / 'disableAutoMode' appear to be set in managed-settings.json. These were intentionally removed during this project's Phase 2 correction because the managed-settings path is machine-wide, not repository-scoped, and setting them here affects every Claude Code session on this machine. Confirm this is an intended, reviewed reintroduction."
    }

    # 6. ConfigChange / PreToolUse / SessionStart Phase 4 hooks (informational only - Phase 4 may
    #    not yet be applied on this machine; this script does not fail solely on their absence
    #    because Phase 4 landing is a separate, tracked step from Phase 2/3's baseline denies).
    $hooksBlock = $managedSettings.hooks
    $hasConfigChange = $false
    $hasManagedPreToolUse = $false
    $hasManagedSessionStart = $false
    if ($hooksBlock) {
        if ($hooksBlock.ConfigChange) { $hasConfigChange = $true }
        if ($hooksBlock.PreToolUse) { $hasManagedPreToolUse = $true }
        if ($hooksBlock.SessionStart) { $hasManagedSessionStart = $true }
    }
    if (-not $hasConfigChange) { Report-Warn 'No managed ConfigChange hook found. Phase 4 (mid-session hot-reload countermeasure) has not been applied on this machine.' }
    if (-not $hasManagedPreToolUse) { Report-Warn 'No managed PreToolUse hook found. Phase 4 self-protecting write guard has not been applied on this machine.' }
    if (-not $hasManagedSessionStart) { Report-Warn 'No managed SessionStart integrity gate found. Phase 4 fail-closed startup check has not been applied on this machine.' }
} else {
    Write-Output 'Skipping managed-settings rule checks: managed settings unavailable or unreadable (see warning above).'
}

Write-Output ''
Write-Output '--- Governance verification: project-scope hook check ---'

$repoRoot = Split-Path -Parent $PSScriptRoot
$projectSettingsPath = Join-Path $repoRoot '.claude/settings.json'
$controlPlaneHookPath = Join-Path $repoRoot '.claude/hooks/validate-control-plane-write.ps1'

if (-not (Test-Path -LiteralPath $projectSettingsPath)) {
    Report-Fail "Project settings file not found at '$projectSettingsPath'."
} else {
    $projectSettings = Get-Content -Raw -LiteralPath $projectSettingsPath | ConvertFrom-Json -ErrorAction Stop
    $registeredPreToolUse = $false
    if ($projectSettings.hooks -and $projectSettings.hooks.PreToolUse) {
        foreach ($entry in @($projectSettings.hooks.PreToolUse)) {
            foreach ($h in @($entry.hooks)) {
                if ($h.command -match 'validate-control-plane-write\.ps1') { $registeredPreToolUse = $true }
            }
        }
    }
    if (-not $registeredPreToolUse) {
        Report-Fail "Project settings.json does not register validate-control-plane-write.ps1 on PreToolUse. Project-scope layer is missing or was edited out."
    }
}

if (-not (Test-Path -LiteralPath $controlPlaneHookPath)) {
    Report-Fail "Control-plane guard script not found at '$controlPlaneHookPath'."
}

Write-Output ''
Write-Output '--- Summary ---'

foreach ($w in $warnings) { Write-Warning $w }
foreach ($f in $failures) { Write-Output "FAIL: $f" }

if ($failures.Count -gt 0) {
    Write-Output ''
    Write-Output "Governance verification FAILED with $($failures.Count) failure(s). Treat as fail-closed: do not proceed with governed engineering work until resolved."
    exit 1
}

if (-not $managedSettingsAvailable) {
    Write-Output ''
    Write-Output 'Governance verification could not fully evaluate managed-scope protection (see warnings above). Investigate before relying on managed-scope enforcement.'
    exit 2
}

Write-Output ''
Write-Output "Governance verification PASSED (with $($warnings.Count) warning(s))."
exit 0

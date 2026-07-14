$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$bashHook = Join-Path $root '.claude/hooks/validate-researcher-bash.ps1'
$writeHook = Join-Path $root '.claude/hooks/validate-researcher-write.ps1'

function Assert-HookResult {
    param(
        [string]$Name,
        [string]$Hook,
        [string]$Json,
        [int]$ExpectedExitCode
    )

    $Json | & $Hook *> $null
    if ($LASTEXITCODE -ne $ExpectedExitCode) {
        throw "$Name expected exit code $ExpectedExitCode but got $LASTEXITCODE."
    }
}

Assert-HookResult -Name 'allows Git status' -Hook $bashHook -Json '{"tool_input":{"command":"git status --short"}}' -ExpectedExitCode 0
Assert-HookResult -Name 'allows ripgrep' -Hook $bashHook -Json '{"tool_input":{"command":"rg --files"}}' -ExpectedExitCode 0
Assert-HookResult -Name 'blocks Git staging' -Hook $bashHook -Json '{"tool_input":{"command":"git add ."}}' -ExpectedExitCode 2
Assert-HookResult -Name 'blocks shell composition' -Hook $bashHook -Json '{"tool_input":{"command":"git status; whoami"}}' -ExpectedExitCode 2

Assert-HookResult -Name 'allows a report write' -Hook $writeHook -Json '{"tool_input":{"file_path":"docs/research/example.md"}}' -ExpectedExitCode 0
Assert-HookResult -Name 'blocks source write' -Hook $writeHook -Json '{"tool_input":{"file_path":"CLAUDE.md"}}' -ExpectedExitCode 2
Assert-HookResult -Name 'blocks traversal write' -Hook $writeHook -Json '{"tool_input":{"file_path":"docs/research/../outside.md"}}' -ExpectedExitCode 2
Assert-HookResult -Name 'blocks non-Markdown report' -Hook $writeHook -Json '{"tool_input":{"file_path":"docs/research/example.json"}}' -ExpectedExitCode 2

Write-Host 'Researcher hook validation passed.'
exit 0

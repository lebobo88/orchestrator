# tests/codex-parity/test-codex-hooks.ps1
# Codex Hooks Resolution, Schema Conformance & Behavioral Test Suite

[CmdletBinding()]
param(
    [string]$RepoRoot = "H:\CommandCenter\orchestrator"
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "Fail-closed: PowerShell 7+ (pwsh.exe) is required for test-codex-hooks.ps1. Running under $($PSVersionTable.PSVersion)."
}

$normalizedRoot = [System.IO.Path]::GetFullPath($RepoRoot)
$hooksJsonPath = Join-Path $normalizedRoot ".codex/hooks.json"
$hooksSchemaPath = Join-Path $normalizedRoot ".codex/schemas/codex-hooks.schema.json"
$fixturePath = Join-Path $normalizedRoot "tests/codex-parity/fixtures/hooks/test-hook-packet.json"

Write-Output "Executing Codex Hooks Test Suite..."

# 1. Schema Validation Gate
if (-not (Test-Path -LiteralPath $hooksJsonPath -PathType Leaf)) {
    throw "Fail-closed: .codex/hooks.json missing at $hooksJsonPath"
}
if (-not (Test-Path -LiteralPath $hooksSchemaPath -PathType Leaf)) {
    throw "Fail-closed: .codex/schemas/codex-hooks.schema.json missing at $hooksSchemaPath"
}

$hooksRaw = Get-Content -Raw -LiteralPath $hooksJsonPath -Encoding UTF8
$schemaValid = Test-Json -Json $hooksRaw -SchemaFile $hooksSchemaPath -ErrorAction Stop
if (-not $schemaValid) {
    throw "Fail-closed: .codex/hooks.json failed validation against $hooksSchemaPath"
}
Write-Output "Gate 1 PASS: .codex/hooks.json validated against formal JSON schema."

# 2. Hook Script Resolution & Parser Zero-Error Acceptance
$hooksConfig = $hooksRaw | ConvertFrom-Json
$referencedScripts = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($eventGroup in $hooksConfig.hooks.PSObject.Properties) {
    foreach ($entry in $eventGroup.Value) {
        $cmdStr = $entry.command
        # Extract script path from command: pwsh.exe ... -File <script>
        if ($cmdStr -match '-File\s+([^\s]+)') {
            $relScript = $matches[1]
            $fullScript = [System.IO.Path]::GetFullPath((Join-Path $normalizedRoot $relScript))
            [void]$referencedScripts.Add($fullScript)
        }
    }
}

if ($referencedScripts.Count -eq 0) {
    throw "Fail-closed: No hook scripts found referenced in .codex/hooks.json"
}

foreach ($scriptPath in $referencedScripts) {
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        throw "Fail-closed: Referenced hook script missing: $scriptPath"
    }
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count -gt 0) {
        throw "Fail-closed: Hook script failed parser audit: $scriptPath - $($errors -join '; ')"
    }
}
Write-Output "Gate 2 PASS: All $(($referencedScripts).Count) referenced hook scripts resolved on disk and verified parser zero-error."

# 3. Behavioral Hook Execution Gate
if (-not (Test-Path -LiteralPath $fixturePath -PathType Leaf)) {
    throw "Fail-closed: Hook test fixture missing at $fixturePath"
}
$fixture = Get-Content -Raw -LiteralPath $fixturePath -Encoding UTF8 | ConvertFrom-Json

$pwshExe = (Get-Command "pwsh.exe" -ErrorAction Stop).Source

function Invoke-HookDirect {
    param(
        [string]$ScriptPath,
        [string]$JsonPayload,
        [string[]]$ScriptArgs = @()
    )

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $pwshExe
    $psi.ArgumentList.Add("-NoProfile")
    $psi.ArgumentList.Add("-ExecutionPolicy")
    $psi.ArgumentList.Add("Bypass")
    $psi.ArgumentList.Add("-File")
    $psi.ArgumentList.Add($ScriptPath)
    foreach ($a in $ScriptArgs) {
        $psi.ArgumentList.Add($a)
    }
    $psi.WorkingDirectory = $normalizedRoot
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    $outTask = $proc.StandardOutput.ReadToEndAsync()
    $errTask = $proc.StandardError.ReadToEndAsync()

    if (-not [string]::IsNullOrEmpty($JsonPayload)) {
        $writer = $proc.StandardInput
        $writer.Write($JsonPayload)
        $writer.Close()
    }

    if (-not $proc.WaitForExit(10000)) {
        try { $proc.Kill() } catch { }
        throw "Hook script timed out: $ScriptPath"
    }
    [System.Threading.Tasks.Task]::WaitAll($outTask, $errTask)

    return [pscustomobject]@{
        ExitCode = $proc.ExitCode
        Stdout = $outTask.Result
        Stderr = $errTask.Result
    }
}

$controlPlaneHook = Join-Path $normalizedRoot ".codex/hooks/validate-control-plane-write.ps1"
foreach ($tc in $fixture.controlPlaneWriteCases) {
    $payload = @{
        tool_name = $tc.tool_name
        tool_input = $tc.tool_input
    } | ConvertTo-Json -Compress
    $res = Invoke-HookDirect -ScriptPath $controlPlaneHook -JsonPayload $payload
    if ($res.ExitCode -ne $tc.expected_exit) {
        throw "Control-plane case '$($tc.name)' failed! Expected exit $($tc.expected_exit), received $($res.ExitCode). Stderr: $($res.Stderr)"
    }
}
Write-Output "Gate 3 PASS: Control-plane write hook validated across all fixture cases."

$researcherHook = Join-Path $normalizedRoot ".codex/hooks/validate-researcher-bash.ps1"
foreach ($tc in $fixture.researcherBashCases) {
    $payload = @{
        tool_name = "Bash"
        tool_input = $tc.tool_input
    } | ConvertTo-Json -Compress
    $res = Invoke-HookDirect -ScriptPath $researcherHook -JsonPayload $payload
    if ($res.ExitCode -ne $tc.expected_exit) {
        throw "Researcher bash case '$($tc.name)' failed! Expected exit $($tc.expected_exit), received $($res.ExitCode). Stderr: $($res.Stderr)"
    }
}
Write-Output "Gate 4 PASS: Researcher bash hook validated across all fixture cases."

$scribeHook = Join-Path $normalizedRoot ".codex/hooks/validate-scribe-write.ps1"
foreach ($tc in $fixture.scribeWriteCases) {
    $payload = @{
        tool_name = "Write"
        tool_input = $tc.tool_input
    } | ConvertTo-Json -Compress
    $res = Invoke-HookDirect -ScriptPath $scribeHook -JsonPayload $payload
    if ($res.ExitCode -ne $tc.expected_exit) {
        throw "Scribe write case '$($tc.name)' failed! Expected exit $($tc.expected_exit), received $($res.ExitCode). Stderr: $($res.Stderr)"
    }
}
Write-Output "Gate 5 PASS: Scribe write hook validated across all fixture cases."

$dispatchHook = Join-Path $normalizedRoot ".codex/hooks/validate-agent-dispatch.ps1"
foreach ($tc in $fixture.agentDispatchCases) {
    $payload = @{
        tool_name = "Agent"
        tool_input = $tc.tool_input
    } | ConvertTo-Json -Compress
    $res = Invoke-HookDirect -ScriptPath $dispatchHook -JsonPayload $payload
    if ($res.ExitCode -ne $tc.expected_exit) {
        throw "Agent dispatch case '$($tc.name)' failed! Expected exit $($tc.expected_exit), received $($res.ExitCode). Stderr: $($res.Stderr)"
    }
}
Write-Output "Gate 6 PASS: Agent dispatch hook validated across all fixture cases."

Write-Output "ALL CODEX HOOK TESTS PASSED (6/6 Gates)."
exit 0

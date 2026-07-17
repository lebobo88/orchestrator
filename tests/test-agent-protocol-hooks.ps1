$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$dispatchHook = Join-Path $root '.claude/hooks/validate-agent-dispatch.ps1'
$terminalHook = Join-Path $root '.claude/hooks/validate-terminal-packet.ps1'
$dispatchCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/agent-dispatch-hook-cases.json') | ConvertFrom-Json
$terminalCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/terminal-packet-hook-cases.json') | ConvertFrom-Json

function Invoke-HookWithStdIn {
    param([string]$Hook, [string[]]$Arguments, [string]$Json)

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = 'powershell.exe'
    $startInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Hook`" $($Arguments -join ' ')"
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $process.StandardInput.Write($Json)
    $process.StandardInput.Close()
    $process.WaitForExit()
    return [pscustomobject]@{ ExitCode = $process.ExitCode; StdOut = $process.StandardOutput.ReadToEnd(); StdErr = $process.StandardError.ReadToEnd() }
}

foreach ($case in $dispatchCases) {
    $payload = @{ tool_input = $case.input } | ConvertTo-Json -Compress -Depth 4
    $result = Invoke-HookWithStdIn -Hook $dispatchHook -Arguments @('-Parent', $case.parent) -Json $payload
    if ($result.ExitCode -ne $case.exit) { throw "Dispatch case '$($case.name)' expected $($case.exit), got $($result.ExitCode)." }
    if ($case.exit -eq 2 -and [string]::IsNullOrWhiteSpace($result.StdErr)) { throw "Dispatch case '$($case.name)' must report its blocked reason on stderr." }
}

foreach ($case in $terminalCases) {
    $payload = @{ last_assistant_message = $case.message; stop_hook_active = $case.stop_hook_active } | ConvertTo-Json -Compress
    $result = Invoke-HookWithStdIn -Hook $terminalHook -Arguments @('-Role', $case.role) -Json $payload
    if ($result.ExitCode -ne $case.exit) { throw "Terminal case '$($case.name)' expected $($case.exit), got $($result.ExitCode)." }
    if ($case.exit -eq 2 -and [string]::IsNullOrWhiteSpace($result.StdErr)) { throw "Terminal case '$($case.name)' must report its blocked reason on stderr." }
}

Write-Host 'Agent dispatch and terminal-packet hook validation passed.'
exit 0

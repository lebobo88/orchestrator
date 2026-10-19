$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$hookPath = Join-Path $root '.claude/hooks/validate-control-plane-write.ps1'
$cases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/control-plane-write-hook-cases.json') | ConvertFrom-Json

function Invoke-HookWithStdIn {
    param([string]$Hook, [string]$Json, [string]$Cwd)

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = 'powershell.exe'
    $startInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Hook`""
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    if ($Cwd) { $startInfo.WorkingDirectory = $Cwd }
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $process.StandardInput.Write($Json)
    $process.StandardInput.Close()
    $process.WaitForExit()
    return [pscustomobject]@{ ExitCode = $process.ExitCode; StdOut = $process.StandardOutput.ReadToEnd(); StdErr = $process.StandardError.ReadToEnd() }
}

$failures = 0
foreach ($case in $cases) {
    $toolInput = @{}
    foreach ($prop in $case.tool_input.PSObject.Properties) {
        $value = $prop.Value
        if ($prop.Name -eq 'file_path' -and $value -like '__ABS__*') {
            $value = $value -replace '^__ABS__', $root
        }
        $toolInput[$prop.Name] = $value
    }
    $payload = @{ tool_name = $case.tool_name; tool_input = $toolInput; cwd = $root } | ConvertTo-Json -Compress -Depth 5
    $result = Invoke-HookWithStdIn -Hook $hookPath -Json $payload -Cwd $root
    if ($result.ExitCode -ne $case.exit) {
        $failures++
        Write-Output "FAIL: '$($case.name)' expected exit $($case.exit), got $($result.ExitCode). StdOut=$($result.StdOut) StdErr=$($result.StdErr)"
    }
    else {
        Write-Output "PASS: '$($case.name)' exit=$($result.ExitCode)"
    }
}

if ($failures -gt 0) {
    Write-Output ''
    Write-Output "Control-plane write hook validation FAILED with $failures failure(s)."
    exit 1
}

Write-Output ''
Write-Output 'Control-plane write hook validation passed.'
exit 0

# tests/codex-parity/test-strict-config.ps1
# Strict Configuration & Active Profile Resolution Verification Gate

[CmdletBinding()]
param(
    [string]$RepoRoot = "H:\CommandCenter\orchestrator"
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "Fail-closed: PowerShell 7+ (pwsh.exe) is required for test-strict-config.ps1. Running under $($PSVersionTable.PSVersion)."
}

$normalizedRoot = [System.IO.Path]::GetFullPath($RepoRoot)
$configFile = Join-Path $normalizedRoot ".codex/config.toml"
$hooksDir = Join-Path $normalizedRoot ".codex/hooks"

Write-Output "Executing Strict Config & Active Profile Resolution Gate..."

# 1. Existence Check
if (-not (Test-Path -LiteralPath $configFile -PathType Leaf)) {
    throw "Fail-closed: .codex/config.toml missing at $configFile"
}

# 2. TOML Structure Check: Top-level keys must precede tables
$configContent = Get-Content -LiteralPath $configFile -Encoding UTF8
$inTable = $false
$foundSandboxMode = $false
$foundApprovalPolicy = $false
$foundWebSearch = $false
$foundSnapshotProfile = $false
$foundExtendsWorkspace = $false
$foundNetworkDisabled = $false

$currentTable = ""
foreach ($line in $configContent) {
    $trimmed = $line.Trim()
    if ($trimmed.StartsWith("#") -or [string]::IsNullOrWhiteSpace($trimmed)) {
        continue
    }

    if ($trimmed -match '^\[([^\]]+)\]$') {
        $inTable = $true
        $currentTable = $matches[1].Trim()
        if ($currentTable -eq 'permissions.snapshot-isolated') {
            $foundSnapshotProfile = $true
        }
        continue
    }

    if (-not $inTable) {
        if ($trimmed -match '^sandbox_mode\s*=\s*"([^"]+)"') {
            $foundSandboxMode = $true
        }
        if ($trimmed -match '^approval_policy\s*=\s*"([^"]+)"') {
            $foundApprovalPolicy = $true
        }
        if ($trimmed -match '^web_search\s*=\s*(.+)$') {
            $foundWebSearch = $true
        }
    } else {
        if ($trimmed -match '^(sandbox_mode|approval_policy|web_search)\s*=') {
            throw "Fail-closed: Top-level configuration key '$($matches[1])' declared inside table [$currentTable]. Top-level keys must precede all tables."
        }
        if ($currentTable -eq 'permissions.snapshot-isolated') {
            if ($trimmed -match 'extends\s*=\s*":workspace"') {
                $foundExtendsWorkspace = $true
            }
            if ($trimmed -match 'network\.enabled\s*=\s*false') {
                $foundNetworkDisabled = $true
            }
        }
    }
}

if (-not $foundSandboxMode) {
    throw "Fail-closed: Top-level key 'sandbox_mode' not found preceding tables in config.toml"
}
if (-not $foundApprovalPolicy) {
    throw "Fail-closed: Top-level key 'approval_policy' not found preceding tables in config.toml"
}
if (-not $foundWebSearch) {
    throw "Fail-closed: Top-level key 'web_search' not found preceding tables in config.toml"
}
Write-Output "Gate 1 PASS: Top-level keys (sandbox_mode, approval_policy, web_search) precede tables and are correctly positioned."

# 3. Snapshot-Isolated Profile Validation
if (-not $foundSnapshotProfile) {
    throw "Fail-closed: Profile [permissions.snapshot-isolated] not defined in config.toml"
}
if (-not $foundExtendsWorkspace) {
    throw "Fail-closed: Profile [permissions.snapshot-isolated] missing 'extends = "":workspace""'"
}
if (-not $foundNetworkDisabled) {
    throw "Fail-closed: Profile [permissions.snapshot-isolated] missing 'network.enabled = false'"
}
Write-Output "Gate 2 PASS: [permissions.snapshot-isolated] correctly defined with extends = ':workspace' and network.enabled = false."

# 4. Parser Zero-Error Acceptance on Generated Scripts
$hookScripts = Get-ChildItem -LiteralPath $hooksDir -Filter "*.ps1" -File
if ($hookScripts.Count -eq 0) {
    throw "Fail-closed: No hook scripts found in $hooksDir"
}

foreach ($script in $hookScripts) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count -gt 0) {
        throw "Fail-closed: Hook script $($script.Name) failed PowerShell parser audit: $($errors -join '; ')"
    }
}
Write-Output "Gate 3 PASS: All $(($hookScripts).Count) hook scripts in .codex/hooks/ passed Parser zero-error acceptance."

# 5. Active Profile Resolution Execution via Sandbox Runner
$codexCmd = Get-Command "codex.cmd" -ErrorAction SilentlyContinue
if (-not $codexCmd) {
    $codexCmd = Get-Command "codex" -ErrorAction Stop
}

$pwshExe = (Get-Command "pwsh.exe" -ErrorAction Stop).Source

$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = $codexCmd.Source
$psi.ArgumentList.Add("sandbox")
$psi.ArgumentList.Add("-P")
$psi.ArgumentList.Add("snapshot-isolated")
$psi.ArgumentList.Add("-C")
$psi.ArgumentList.Add($normalizedRoot)
$psi.ArgumentList.Add("--")
$psi.ArgumentList.Add($pwshExe)
$psi.ArgumentList.Add("-NoProfile")
$psi.ArgumentList.Add("-Command")
$psi.ArgumentList.Add("Write-Output PROFILE_OK")

$psi.WorkingDirectory = $normalizedRoot
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true

$proc = [System.Diagnostics.Process]::Start($psi)
$outTask = $proc.StandardOutput.ReadToEndAsync()
$errTask = $proc.StandardError.ReadToEndAsync()

if (-not $proc.WaitForExit(15000)) {
    try { $proc.Kill() } catch { }
    throw "Active profile resolution timed out after 15 seconds."
}
[System.Threading.Tasks.Task]::WaitAll($outTask, $errTask)

$stdout = $outTask.Result.Trim()
$stderr = $errTask.Result.Trim()

if ($proc.ExitCode -ne 0 -or $stdout -notmatch "PROFILE_OK") {
    throw "Active profile resolution gate failed: ExitCode=$($proc.ExitCode), Stdout='$stdout', Stderr='$stderr'"
}
Write-Output "Gate 4 PASS: codex sandbox -P snapshot-isolated executed successfully with exit 0 and emitted PROFILE_OK."

Write-Output "ALL STRICT CONFIG & ACTIVE PROFILE RESOLUTION TESTS PASSED."
exit 0

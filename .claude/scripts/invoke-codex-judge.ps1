param(
    [Parameter(Mandatory = $true)]
    [string]$JobPath,
    [switch]$ResolveOnly
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runtimeRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'runtime'))
$jobRoot = $runtimeRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
$jobPathPattern = '^runtime/judge-job-[a-z0-9][a-z0-9-]{2,109}\.json$'
if ([System.IO.Path]::IsPathRooted($JobPath) -or $JobPath -notmatch $jobPathPattern) { throw 'Judge job path must be exactly runtime/judge-job-<lowercase-hyphen-slug>.json.' }
$resolvedJob = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $JobPath))
if (-not $resolvedJob.StartsWith($jobRoot, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Judge job path is outside the ephemeral job root.' }
if (-not (Test-Path -LiteralPath $resolvedJob)) { throw 'Judge job does not exist.' }

$job = Get-Content -Raw -LiteralPath $resolvedJob | ConvertFrom-Json

$checkpoints = @('PLAN_DUCK', 'CODE_REVIEW', 'VERIFICATION_CHALLENGE', 'VISUAL_REVIEW')
$models = @('gpt-5.6-luna', 'gpt-5.6-terra')
$efforts = @('medium')
$risks = @('low', 'medium', 'high', 'critical')
if ([string]$job.task_id -notmatch '^[a-z0-9][a-z0-9-]{2,79}$') { throw 'Invalid judge task_id.' }
if ($checkpoints -notcontains [string]$job.checkpoint) { throw 'Invalid judge checkpoint.' }
if ($models -notcontains [string]$job.model) { throw 'Invalid judge model.' }
if ($efforts -notcontains [string]$job.effort) { throw 'Invalid judge effort.' }
if ($risks -notcontains [string]$job.risk) { throw 'Invalid judge risk.' }
if ($null -eq $job.required -or $job.required -isnot [bool]) { throw 'Judge required must be boolean.' }
if ([string]::IsNullOrWhiteSpace([string]$job.rubric)) { throw 'Judge rubric is required.' }

if ($job.effort -ne 'medium') { throw 'Judge jobs must use medium effort.' }

$targetRoot = if ([string]::IsNullOrWhiteSpace([string]$job.target)) { $repositoryRoot } else { [System.IO.Path]::GetFullPath([string]$job.target) }
if (-not (Test-Path -LiteralPath (Join-Path $targetRoot '.git'))) { throw 'Judge target must be a Git repository.' }

$schemaPath = Join-Path $repositoryRoot '.claude/schemas/judge-result.schema.json'
$policyPath = Join-Path $repositoryRoot '.claude/judge-policy.json'
$policy = Get-Content -Raw -LiteralPath $policyPath | ConvertFrom-Json
$staticInstructions = @'
You are an independent cross-vendor critic. Inspect only the local repository and artifact references supplied below. Do not edit files, run tests, use network access, or attempt to access MCP. Evaluate criteria before presentation quality. Author and vendor identity are intentionally absent. You may abstain when evidence is insufficient. Discover and report every material issue with calibrated severity and per-finding confidence; do not silently filter uncertain findings. Cite a reproducible file/line, plan section, test artifact, or screenshot element. Distinguish functional defects from preference. Do not implement fixes. Return only the required JSON object.
'@
$jobJson = $job | ConvertTo-Json -Depth 30
$prompt = $staticInstructions + "`n<judge_job>`n" + $jobJson + "`n</judge_job>`n<task>Apply the checkpoint-specific rubric and return JUDGE_RESULT.</task>"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('codex-judge-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
$promptPath = Join-Path $tempRoot 'stdin.txt'
$eventsPath = Join-Path $tempRoot 'events.jsonl'
$resultPath = Join-Path $tempRoot 'result.json'
$stderrPath = Join-Path $tempRoot 'stderr.txt'
Set-Content -LiteralPath $promptPath -Value $prompt -Encoding UTF8

function Resolve-CodexJudgeExecutable {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_JUDGE_EXECUTABLE)) {
        $configured = [string]$env:CODEX_JUDGE_EXECUTABLE
        $resolved = if (Test-Path -LiteralPath $configured) { [System.IO.Path]::GetFullPath($configured) } else { (Get-Command $configured -CommandType Application -ErrorAction Stop).Source }
    }
    elseif ($env:OS -eq 'Windows_NT') {
        $resolved = $null
        $npmCmd = if ([string]::IsNullOrWhiteSpace($env:APPDATA)) { $null } else { Join-Path $env:APPDATA 'npm\codex.cmd' }
        if ($null -ne $npmCmd -and (Test-Path -LiteralPath $npmCmd -PathType Leaf)) {
            $resolved = [System.IO.Path]::GetFullPath($npmCmd)
        }
        else {
            foreach ($candidate in @('codex.cmd', 'codex.exe')) {
                $command = Get-Command $candidate -CommandType Application -ErrorAction SilentlyContinue
                if ($null -ne $command) {
                    $resolved = $command.Source
                    break
                }
            }
        }
        if ([string]::IsNullOrWhiteSpace($resolved)) { throw 'Codex CLI was not found as codex.cmd or codex.exe on PATH.' }
    }
    else {
        $resolved = (Get-Command codex -CommandType Application -ErrorAction Stop).Source
    }

    if ($env:OS -eq 'Windows_NT' -and [System.IO.Path]::GetExtension($resolved).ToLowerInvariant() -notin @('.cmd', '.exe')) {
        throw "Codex judge requires a native Windows executable or cmd shim; '$resolved' is not supported. Use codex.cmd or codex.exe, not codex.ps1."
    }
    return $resolved
}

function Add-CodexJudgeTimeoutDiagnostic {
    param([string]$Path, [string]$Message)

    # Start-Process owns the redirected stream handles. A terminated cmd shim can
    # release stderr just after its launcher exits, so tolerate that short handoff.
    for ($writeAttempt = 1; $writeAttempt -le 20; $writeAttempt++) {
        try {
            Add-Content -LiteralPath $Path -Value $Message -Encoding UTF8
            return
        }
        catch [System.IO.IOException] {
            if ($writeAttempt -eq 20) { throw }
            Start-Sleep -Milliseconds 100
        }
    }
}

try {
$codexExecutable = Resolve-CodexJudgeExecutable
if ($ResolveOnly) {
    Write-Output $codexExecutable
    return
}
$arguments = @(
    'exec', '--ephemeral', '--ignore-user-config', '--ignore-rules', '--sandbox', 'read-only',
    '-c', 'approval_policy="never"', '-c', 'web_search="disabled"', '-c', 'mcp_servers={}',
    '-c', ('model_reasoning_effort="{0}"' -f [string]$job.effort),
    '-C', ('"{0}"' -f $targetRoot), '-m', [string]$job.model,
    '--output-schema', ('"{0}"' -f $schemaPath), '--json', '-o', ('"{0}"' -f $resultPath)
)
if ($job.checkpoint -eq 'VISUAL_REVIEW' -and $job.image_paths) {
    foreach ($imagePath in @($job.image_paths)) {
        $resolvedImage = if ([System.IO.Path]::IsPathRooted([string]$imagePath)) { [System.IO.Path]::GetFullPath([string]$imagePath) } else { [System.IO.Path]::GetFullPath((Join-Path $targetRoot [string]$imagePath)) }
        $targetPrefix = $targetRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
        if (-not $resolvedImage.StartsWith($targetPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or [System.IO.Path]::GetExtension($resolvedImage).ToLowerInvariant() -notin @('.png', '.jpg', '.jpeg', '.webp')) { throw 'Invalid visual review image path.' }
        $arguments += @('-i', ('"{0}"' -f $resolvedImage))
    }
}
$arguments += '-'

$timeoutSeconds = switch ([string]$job.model) { 'gpt-5.6-luna' { 120 } 'gpt-5.6-terra' { 300 } }
if ($env:CODEX_JUDGE_TIMEOUT_OVERRIDE_MS -match '^\d+$') { $timeoutMilliseconds = [int]$env:CODEX_JUDGE_TIMEOUT_OVERRIDE_MS } else { $timeoutMilliseconds = $timeoutSeconds * 1000 }
$transientPattern = '(?i)rate.?limit|overload|temporar|timeout|timed out|connection reset|service unavailable|502|503|504'
$attempt = 0
$exitCode = 1
do {
    $attempt++
    Remove-Item -LiteralPath $eventsPath, $resultPath, $stderrPath -Force -ErrorAction SilentlyContinue
    $process = Start-Process -FilePath $codexExecutable -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardInput $promptPath -RedirectStandardOutput $eventsPath -RedirectStandardError $stderrPath
    if (-not $process.WaitForExit($timeoutMilliseconds)) {
        if ($env:OS -eq 'Windows_NT') {
            # codex.cmd is a launcher; terminate its complete process tree so a child
            # Codex process cannot outlive the adapter and consume the outer deadline.
            $priorNativeErrorPreference = $ErrorActionPreference
            try {
                # taskkill can report an already-exiting child with a nonzero code;
                # that diagnostic is not the judge result and must not mask exit 124.
                $ErrorActionPreference = 'Continue'
                & taskkill.exe /PID $process.Id /T /F *> $null
            }
            finally {
                $ErrorActionPreference = $priorNativeErrorPreference
            }
        }
        else {
            $process.Kill()
        }
        if (-not $process.WaitForExit(5000) -and -not $process.HasExited) {
            # The normal Windows path above remains tree-aware. This fallback only
            # covers a launcher that taskkill cannot observe after it has detached.
            $process.Kill()
            $process.WaitForExit()
        }
        Add-CodexJudgeTimeoutDiagnostic -Path $stderrPath -Message "Codex judge timed out after $timeoutSeconds seconds."
        $exitCode = 124
    } else {
        # Drain redirected streams before reading the process result; this also makes
        # Windows command-script test doubles report a stable exit code.
        $process.WaitForExit()
        $exitCode = [int]$process.ExitCode
    }
    $stderr = if (Test-Path -LiteralPath $stderrPath) { Get-Content -Raw -LiteralPath $stderrPath } else { '' }
    $transient = $exitCode -ne 0 -and $stderr -match $transientPattern
} while ($attempt -lt 2 -and $transient)

if ($exitCode -ne 0) { throw "Codex judge failed with exit $exitCode after $attempt attempt(s): $stderr" }
if (-not (Test-Path -LiteralPath $resultPath)) { throw 'Codex judge produced no final result.' }
$result = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
if ([string]$result.verdict -notin @('PASS', 'REVISE', 'BLOCK', 'ABSTAIN')) { throw 'Invalid judge verdict.' }
if ([string]$result.confidence -notin @('low', 'medium', 'high')) { throw 'Invalid judge confidence.' }
if ($null -eq $result.findings -or $null -eq $result.assumptions -or $null -eq $result.unknowns) { throw 'Judge result is missing required arrays.' }

$approvedSuppressions = @($job.approved_suppressions)
$blockingIds = @()
foreach ($finding in @($result.findings)) {
    foreach ($field in @('id', 'severity', 'confidence', 'criterion', 'claim', 'evidence', 'location', 'impact', 'remediation')) {
        if ([string]::IsNullOrWhiteSpace([string]$finding.$field)) { throw "Judge finding is missing $field." }
    }
    if ([string]$finding.severity -notin @('critical', 'major', 'minor', 'advisory')) { throw 'Invalid finding severity.' }
    if ([string]$finding.confidence -notin @('low', 'medium', 'high')) { throw 'Invalid finding confidence.' }
    $suppressed = $false
    if ($finding.severity -ne 'critical') {
        $suppressed = @($approvedSuppressions | Where-Object { [string]$_.finding_id -eq [string]$finding.id -and -not [string]::IsNullOrWhiteSpace([string]$_.fingerprint) -and [string]$_.current_fingerprint -eq [string]$_.fingerprint -and -not [string]::IsNullOrWhiteSpace([string]$_.approved_by) -and ([datetime]$_.expires_at) -gt (Get-Date) }).Count -gt 0
    }
    if (-not $suppressed -and $policy.blocking_severities -contains [string]$finding.severity -and [string]$finding.confidence -eq [string]$policy.blocking_confidence) { $blockingIds += [string]$finding.id }
}

$policyAction = if ($result.verdict -eq 'ABSTAIN' -and [bool]$job.required) { 'unassessed' } elseif ($blockingIds.Count -gt 0) { 'remediate' } else { 'continue' }
if ([string]$policy.mode -eq 'shadow' -and $policyAction -eq 'remediate') { $effectiveAction = 'advisory' } else { $effectiveAction = $policyAction }
$result | Add-Member -NotePropertyName policy_action -NotePropertyValue $effectiveAction
$result | Add-Member -NotePropertyName blocking_finding_ids -NotePropertyValue @($blockingIds)
$result | Add-Member -NotePropertyName policy_mode -NotePropertyValue ([string]$policy.mode)

$usage = $null
if (Test-Path -LiteralPath $eventsPath) {
    foreach ($line in Get-Content -LiteralPath $eventsPath) {
        try { $event = $line | ConvertFrom-Json; if ($event.type -eq 'turn.completed') { $usage = $event.usage } } catch { }
    }
}
$provenanceRoot = $runtimeRoot
$provenance = [ordered]@{
    task_id = [string]$job.task_id; checkpoint = [string]$job.checkpoint; model = [string]$job.model; effort = [string]$job.effort
    prompt_version = 'judge-v1'; input_hash = ([BitConverter]::ToString(([Security.Cryptography.SHA256]::Create()).ComputeHash([Text.Encoding]::UTF8.GetBytes($jobJson))).Replace('-', '').ToLowerInvariant())
    attempts = $attempt; timeout_seconds = $timeoutSeconds; usage = $usage; finding_count = @($result.findings).Count; policy_action = $effectiveAction; recorded_at = (Get-Date).ToUniversalTime().ToString('o')
}
$provenancePath = Join-Path $provenanceRoot ("judge-provenance-{0}-{1}-{2}.json" -f $job.task_id, ([string]$job.checkpoint).ToLowerInvariant(), (Get-Date -Format 'yyyyMMddHHmmssfff'))
$provenance | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $provenancePath -Encoding UTF8

Remove-Item -LiteralPath $resolvedJob -Force

$result | ConvertTo-Json -Depth 20 -Compress
}
finally {
Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$runtimeRoot = Join-Path $root 'runtime'
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('codex-judge-test-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $temp | Out-Null

$mockBody = @'
@echo off
setlocal
echo %* > "%CODEX_JUDGE_MOCK_ARGS%"
set "OUT="
:loop
if "%~1"=="" goto done
if "%~1"=="-o" (
  set "OUT=%~2"
  shift
  shift
  goto loop
)
shift
goto loop
:done
more > "%CODEX_JUDGE_MOCK_STDIN%"
> "%OUT%" echo {"verdict":"BLOCK","confidence":"high","findings":[{"id":"J-SEEDED-1","severity":"major","confidence":"high","criterion":"CODE-CONTRACT","claim":"Seeded contract mismatch","evidence":"Observed incompatible return shape","location":"src/example.ts:10","impact":"Caller receives invalid data","remediation":"Align the return contract"}],"assumptions":[],"unknowns":[]}
echo {"type":"turn.completed","usage":{"input_tokens":100,"cached_input_tokens":50,"output_tokens":25,"reasoning_output_tokens":10}}
exit /b 0
'@

$jobTemplate = [ordered]@{
    checkpoint = 'CODE_REVIEW'; required = $true; risk = 'medium'; target = $root
    model = 'gpt-5.6-terra'; effort = 'medium'; artifact_refs = @('docs/BUILD-CONTRACT.md'); changed_paths = @('src/example.ts')
    rubric = 'CODE-CONTRACT: identify observable contract mismatches'; prior_finding_ids = @(); approved_suppressions = @(); image_paths = @()
}
$createdRuntimeArtifacts = [System.Collections.Generic.List[string]]::new()

function New-CanonicalJudgeJob([string]$TaskPrefix) {
    $taskId = "$TaskPrefix-$([Guid]::NewGuid().ToString('N'))"
    $relativePath = "runtime/judge-job-$taskId-code-review.json"
    $absolutePath = Join-Path $root ($relativePath -replace '/', '\')
    $writeValidation = Invoke-Hook '.claude/hooks/validate-codex-judge-job-write.ps1' @{ file_path = $absolutePath }
    if ($writeValidation.ExitCode -ne 0) { throw "Production-shaped absolute job Write path was rejected: $($writeValidation.StdErr)" }
    $job = [ordered]@{ task_id = $taskId }
    foreach ($entry in $jobTemplate.GetEnumerator()) { $job[$entry.Key] = $entry.Value }
    $job | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $absolutePath -Encoding UTF8
    $createdRuntimeArtifacts.Add($absolutePath)
    return [pscustomobject]@{ TaskId = $taskId; RelativePath = $relativePath; AbsolutePath = $absolutePath }
}

function Invoke-JudgeAdapter([string]$RelativePath) {
    return & (Join-Path $root '.claude/scripts/invoke-codex-judge.ps1') -JobPath $RelativePath
}

function Invoke-Hook([string]$Script, [hashtable]$ToolInput) {
    $payload = @{ tool_input = $ToolInput } | ConvertTo-Json -Compress
    $stdoutPath = [System.IO.Path]::GetTempFileName()
    $stderrPath = [System.IO.Path]::GetTempFileName()
    $priorErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $payload | & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root $Script) 1> $stdoutPath 2> $stderrPath
        return [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            StdOut = Get-Content -Raw -LiteralPath $stdoutPath
            StdErr = Get-Content -Raw -LiteralPath $stderrPath
        }
    }
    finally {
        $ErrorActionPreference = $priorErrorActionPreference
        Remove-Item -LiteralPath $stdoutPath, $stderrPath -Force -ErrorAction SilentlyContinue
    }
}

try {
    $mock = Join-Path $temp 'codex.cmd'
    $argsCapture = Join-Path $temp 'args.txt'
    $stdinCapture = Join-Path $temp 'stdin.txt'
    Set-Content -LiteralPath $mock -Value $mockBody -Encoding ASCII

    $successJob = New-CanonicalJudgeJob 'adapter-test'
    $env:CODEX_JUDGE_EXECUTABLE = $mock
    $env:CODEX_JUDGE_MOCK_ARGS = $argsCapture
    $env:CODEX_JUDGE_MOCK_STDIN = $stdinCapture
    try {
        $result = (Invoke-JudgeAdapter $successJob.RelativePath) | ConvertFrom-Json
        if ($result.policy_action -ne 'advisory' -or $result.policy_mode -ne 'shadow') { throw 'Shadow mode must convert an evidence-backed block to advisory.' }
        if ($result.blocking_finding_ids -notcontains 'J-SEEDED-1') { throw 'Adapter must identify the evidence-backed major finding.' }
        if (Test-Path -LiteralPath $successJob.AbsolutePath) { throw 'Adapter must delete the canonical job only after a valid result.' }
        $argsText = Get-Content -Raw -LiteralPath $argsCapture
        if ((Split-Path -Leaf $mock) -ne 'codex.cmd' -or $argsText -notmatch '^exec(?:\s|\r?\n)') { throw 'Windows launch must use a cmd shim and begin with headless codex exec.' }
        foreach ($expected in @('exec', '--ephemeral', '--ignore-user-config', '--ignore-rules', '--sandbox read-only', 'approval_policy="never"', 'web_search="disabled"', 'mcp_servers={}', 'model_reasoning_effort="medium"', '-m gpt-5.6-terra', '--output-schema', '--json')) {
            if ($argsText -notmatch [regex]::Escape($expected)) { throw "Mock invocation is missing '$expected'. Actual: $argsText" }
        }
        if ($argsText -match 'CODE-CONTRACT|Seeded contract') { throw 'Prompt content must not appear in process arguments.' }
        $stdinText = Get-Content -Raw -LiteralPath $stdinCapture
        if ($stdinText -notmatch 'CODE-CONTRACT' -or $stdinText -notmatch '<judge_job>') { throw 'Judge prompt must arrive through stdin.' }
        $provenance = Get-ChildItem -LiteralPath $runtimeRoot -Filter "judge-provenance-$($successJob.TaskId)-code_review-*.json" -ErrorAction SilentlyContinue
        if (-not $provenance) { throw 'Adapter must write ignored provenance.' }
        foreach ($record in $provenance) { $createdRuntimeArtifacts.Add($record.FullName) }
    }
    finally {
        Remove-Item Env:CODEX_JUDGE_EXECUTABLE, Env:CODEX_JUDGE_MOCK_ARGS, Env:CODEX_JUDGE_MOCK_STDIN -ErrorAction SilentlyContinue
    }

    foreach ($invalidRoute in @(
        @{ Model = 'gpt-5.6-sol'; Effort = 'medium'; Expected = 'Invalid judge model' },
        @{ Model = 'gpt-5.6-terra'; Effort = 'high'; Expected = 'Invalid judge effort' },
        @{ Model = 'gpt-5.6-luna'; Effort = 'xhigh'; Expected = 'Invalid judge effort' }
    )) {
        $invalidJob = New-CanonicalJudgeJob 'invalid-route'
        $invalidJson = Get-Content -Raw -LiteralPath $invalidJob.AbsolutePath | ConvertFrom-Json
        $invalidJson.model = $invalidRoute.Model
        $invalidJson.effort = $invalidRoute.Effort
        $invalidJson | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $invalidJob.AbsolutePath -Encoding UTF8
        $invalidError = $null
        try { Invoke-JudgeAdapter $invalidJob.RelativePath | Out-Null; throw 'Expected invalid judge route to be rejected.' }
        catch { $invalidError = $_.Exception.Message }
        if ($invalidError -notmatch $invalidRoute.Expected) { throw "Invalid route rejection was not actionable: $invalidError" }
        if (-not (Test-Path -LiteralPath $invalidJob.AbsolutePath)) { throw 'An invalid route must retain its canonical job.' }
    }

    $slowMock = Join-Path $temp 'codex-slow.cmd'
    Set-Content -LiteralPath $slowMock -Value "@echo off`r`n:wait`r`ntimeout /t 5 /nobreak > nul`r`ngoto wait`r`n" -Encoding ASCII
    $timeoutJob = New-CanonicalJudgeJob 'timeout-tree'
    $env:CODEX_JUDGE_EXECUTABLE = $slowMock
    $env:CODEX_JUDGE_TIMEOUT_OVERRIDE_MS = '100'
    try {
        $timeoutError = $null
        $watch = [System.Diagnostics.Stopwatch]::StartNew()
        try { Invoke-JudgeAdapter $timeoutJob.RelativePath | Out-Null; throw 'Expected the slow mock to time out.' }
        catch { $timeoutError = $_.Exception.Message }
        $watch.Stop()
        if ($timeoutError -notmatch 'exit 124' -or $timeoutError -notmatch 'timed out after 300 seconds') { throw "Timeout must return adapter exit 124 and diagnostics: $timeoutError" }
        if ($watch.Elapsed.TotalSeconds -gt 10) { throw "Timeout cleanup exceeded its test headroom: $($watch.Elapsed.TotalSeconds) seconds" }
        if (-not (Test-Path -LiteralPath $timeoutJob.AbsolutePath)) { throw 'A timed-out job must be retained for the authorized retry.' }
    }
    finally { Remove-Item Env:CODEX_JUDGE_EXECUTABLE, Env:CODEX_JUDGE_TIMEOUT_OVERRIDE_MS -ErrorAction SilentlyContinue }

    $ps1Override = Join-Path $temp 'codex-invalid.ps1'
    Set-Content -LiteralPath $ps1Override -Value 'exit 0' -Encoding UTF8
    $ps1Job = New-CanonicalJudgeJob 'ps1-override'
    $env:CODEX_JUDGE_EXECUTABLE = $ps1Override
    try {
        $ps1Error = $null
        try { Invoke-JudgeAdapter $ps1Job.RelativePath | Out-Null; throw 'Expected a PowerShell shim override to be rejected before Codex launch.' }
        catch { $ps1Error = $_.Exception.Message }
        if ($ps1Error -notmatch 'codex\.cmd or codex\.exe, not codex\.ps1') { throw "PowerShell shim rejection was not actionable: $ps1Error" }
        if (-not (Test-Path -LiteralPath $ps1Job.AbsolutePath)) { throw 'A launcher-resolution failure must retain the canonical job for an authorized retry.' }
    }
    finally { Remove-Item Env:CODEX_JUDGE_EXECUTABLE -ErrorAction SilentlyContinue }

    $defaultAppData = Join-Path $temp 'default-appdata'
    $defaultMockDirectory = Join-Path $defaultAppData 'npm'
    New-Item -ItemType Directory -Force -Path $defaultMockDirectory | Out-Null
    $defaultMock = Join-Path $defaultMockDirectory 'codex.cmd'
    $defaultArgs = Join-Path $temp 'default-args.txt'
    $defaultStdin = Join-Path $temp 'default-stdin.txt'
    Set-Content -LiteralPath $defaultMock -Value $mockBody -Encoding ASCII
    $defaultJob = New-CanonicalJudgeJob 'default-resolution'
    $priorAppData = $env:APPDATA
    $env:APPDATA = $defaultAppData
    $env:CODEX_JUDGE_MOCK_ARGS = $defaultArgs
    $env:CODEX_JUDGE_MOCK_STDIN = $defaultStdin
    try {
        $defaultOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root '.claude/scripts/invoke-codex-judge.ps1') -JobPath $defaultJob.RelativePath -ResolveOnly
        if ($LASTEXITCODE -ne 0) { throw "Fresh-process default resolver failed: $defaultOutput" }
        if ($defaultOutput.Trim() -ne [System.IO.Path]::GetFullPath($defaultMock)) { throw "Default Windows resolution did not select the npm codex.cmd shim: $defaultOutput" }
    }
    finally {
        $env:APPDATA = $priorAppData
        Remove-Item Env:CODEX_JUDGE_MOCK_ARGS, Env:CODEX_JUDGE_MOCK_STDIN -ErrorAction SilentlyContinue
    }

    $canonicalAbsoluteWritePath = Join-Path $runtimeRoot 'judge-job-test-plan-duck.json'
    $allowedWrite = Invoke-Hook '.claude/hooks/validate-codex-judge-job-write.ps1' @{ file_path = $canonicalAbsoluteWritePath }
    if ($allowedWrite.ExitCode -ne 0) { throw 'Expected canonical absolute judge job Write path to pass.' }
    foreach ($invalidPath in @(
        'runtime/judge-job-test-plan-duck.json',
        '.\runtime\judge-job-test-plan-duck.json',
        'runtime\judge-job-test-plan-duck.json',
        (Join-Path $runtimeRoot 'nested\judge-job-test-plan-duck.json'),
        (Join-Path $runtimeRoot '..\runtime\judge-job-test-plan-duck.json'),
        (Join-Path $runtimeRoot 'judge-job-test-plan_duck.json')
    )) {
        $result = Invoke-Hook '.claude/hooks/validate-codex-judge-job-write.ps1' @{ file_path = $invalidPath }
        if ($result.ExitCode -eq 0 -or [string]::IsNullOrWhiteSpace($result.StdErr)) { throw "Expected noncanonical job path '$invalidPath' to fail with stderr evidence." }
    }
    $allowedCommand = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File .claude/scripts/invoke-codex-judge.ps1 -JobPath runtime/judge-job-test-plan-duck.json'
    if ((Invoke-Hook '.claude/hooks/validate-codex-judge-command.ps1' @{ command = $allowedCommand }).ExitCode -ne 0) { throw 'Expected canonical guarded adapter command to pass.' }
    $composedCommand = "cd H:\CommandCenter\orchestrator && $allowedCommand"
    $composedResult = Invoke-Hook '.claude/hooks/validate-codex-judge-command.ps1' @{ command = $composedCommand }
    if ($composedResult.ExitCode -ne 2) { throw 'Composed judge command must be blocked.' }
    $judgeCommandHook = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/hooks/validate-codex-judge-command.ps1')
    if ($judgeCommandHook -notmatch 'use Write for the job JSON' -or $judgeCommandHook -notmatch 'do not prepend cd') { throw 'Composed judge command rejection must explain the Write-then-Bash protocol.' }
    foreach ($invalidCommand in @(
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File .claude/scripts/invoke-codex-judge.ps1 -JobPath .\runtime\judge-job-test-plan-duck.json',
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File .claude\scripts\invoke-codex-judge.ps1 -JobPath runtime\judge-job-test-plan-duck.json',
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File H:\CommandCenter\orchestrator\.claude\scripts\invoke-codex-judge.ps1 -JobPath H:\CommandCenter\orchestrator\runtime\judge-job-test-plan-duck.json',
        "$allowedCommand; git status",
        "@'{}'@ | Out-File runtime/judge-job-test-plan-duck.json"
    )) {
        $result = Invoke-Hook '.claude/hooks/validate-codex-judge-command.ps1' @{ command = $invalidCommand }
        if ($result.ExitCode -eq 0 -or [string]::IsNullOrWhiteSpace($result.StdErr)) { throw "Expected noncanonical command '$invalidCommand' to fail with stderr evidence." }
    }
    $runnerDefinition = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/codex-judge-runner.md')
    foreach ($requiredInstruction in @('tools: Read, Write, Bash, Skill', 'mandatory three-step transport protocol', 'one `Read` call, one `Write` call, then one exact `Bash` call', 'a not-found result is expected and satisfies the runtime''s read-before-write guard', 'Set that Bash tool call''s `timeout` field to `660000`', 'cleanup headroom', '120-second Luna or 300-second Terra review ceiling', 'Never use `cd`', 'Never create, inspect, rewrite, or probe the job through Bash.')) {
        if ($runnerDefinition -notmatch [regex]::Escape($requiredInstruction)) { throw "Codex judge runner is missing required transport instruction: $requiredInstruction" }
    }
}
finally {
    foreach ($artifact in $createdRuntimeArtifacts) { Remove-Item -LiteralPath $artifact -Force -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host 'Codex judge adapter and hook validation passed.'
$global:LASTEXITCODE = 0

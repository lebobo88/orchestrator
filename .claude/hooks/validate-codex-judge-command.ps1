$ErrorActionPreference = 'Stop'
function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}
$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { $rawInput = @($input) -join [Environment]::NewLine }
try { $command = [string](($rawInput | ConvertFrom-Json).tool_input.command) }
catch { Deny 'invalid judge command hook input.' }
if ([string]::IsNullOrWhiteSpace($command)) { Deny 'missing judge adapter command.' }
$canonicalCommand = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File .claude/scripts/invoke-codex-judge.ps1 -JobPath runtime/judge-job-<lowercase-hyphen-slug>.json'
if ($command -match '[;&|><`]' -or $command -match '\$\(') {
    Deny "judge runner Bash must be exactly the adapter invocation; use Write for the job JSON and do not prepend cd, redirection, heredocs, pipes, or shell operators. Expected: $canonicalCommand"
}
$pattern = '^(?:powershell(?:\.exe)?|pwsh(?:\.exe)?)\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+\.claude/scripts/invoke-codex-judge\.ps1\s+-JobPath\s+runtime/judge-job-[a-z0-9][a-z0-9-]{2,109}\.json$'
if ($command -notmatch $pattern) { Deny "only the deterministic Codex judge adapter is allowed. Use Write for the job JSON, then run exactly: $canonicalCommand" }
exit 0

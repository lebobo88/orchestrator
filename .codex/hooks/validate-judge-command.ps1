# .codex/hooks/validate-judge-command.ps1
# PowerShell 7 judge command validation hook for Codex CLI harness

$ErrorActionPreference = 'Stop'

function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { $rawInput = @($input) -join [Environment]::NewLine }

try {
    $command = [string](($rawInput | ConvertFrom-Json).tool_input.command)
}
catch {
    Deny 'invalid judge command hook input.'
}

if ([string]::IsNullOrWhiteSpace($command)) {
    Deny 'missing judge adapter command.'
}

$canonicalCommand = 'pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .agents/scripts/invoke-claude-judge.ps1 -JobPath runtime/judge-job-<lowercase-hyphen-slug>.json'

if ($command -match '[;&|><`]' -or $command -match '\$\(') {
    Deny "judge runner Bash must be exactly the adapter invocation; use Write for the job JSON and do not prepend cd, redirection, heredocs, pipes, or shell operators. Expected: $canonicalCommand"
}

$patternClaudeJudge = '^(?:powershell(?:\.exe)?|pwsh(?:\.exe)?)\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+\.(?:agents\/scripts|claude\/scripts)\/invoke-(?:claude|codex)-judge\.ps1\s+-JobPath\s+runtime\/judge-job-[a-z0-9][a-z0-9-]{2,109}\.json$'

if ($command -notmatch $patternClaudeJudge) {
    Deny "only the deterministic judge adapter is allowed. Use Write for the job JSON, then run exactly: $canonicalCommand"
}

exit 0

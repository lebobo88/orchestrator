# .codex/hooks/validate-researcher-bash.ps1
# PowerShell 7 researcher read-only shell guard for Codex CLI harness

$ErrorActionPreference = 'Stop'

function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    $rawInput = @($input) -join [Environment]::NewLine
}
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    Deny 'missing hook input.'
}

try {
    $payload = $rawInput | ConvertFrom-Json
    $command = [string]$payload.tool_input.command
}
catch {
    Deny 'invalid hook input.'
}

if ([string]::IsNullOrWhiteSpace($command)) {
    Deny 'missing Bash command.'
}

# No composition, redirection, interpolation, or subshells: each permitted command is a single inspection action.
if ($command -match '[;&|><`]' -or $command -match '\$\(') {
    Deny 'researcher Bash commands must be a single read-only inspection command.'
}

$allowedPatterns = @(
    '^git\s+(?:status(?:\s+--short)?|diff(?:\s+--(?:stat|name-only|name-status|cached))?(?:\s+[^\s]+)?|log(?:\s+--[\w=-]+)*(?:\s+[^\s]+)?|show(?:\s+--[\w=-]+)*(?:\s+[^\s]+)?|rev-parse\s+--verify\s+\S+|branch(?:\s+--show-current)?|ls-files(?:\s+--\S+)?|remote\s+-v|config\s+--get\s+\S+)$',
    '^rg(?:\s+--[\w=-]+)*(?:\s+.+)?$',
    '^Get-Content(?:\s+-[\w]+(?:\s+[^\s]+)?)*(?:\s+.+)?$',
    '^Get-ChildItem(?:\s+-[\w]+(?:\s+[^\s]+)?)*(?:\s+.+)?$',
    '^Select-String(?:\s+-[\w]+(?:\s+[^\s]+)?)*(?:\s+.+)?$',
    '^(?:node|python|python3)\s+--version$',
    '^npm\s+(?:ls|list)(?:\s+--[\w=-]+)*(?:\s+[^\s]+)?$',
    '^(?:dotnet\s+--info|cargo\s+metadata(?:\s+--[\w=-]+)*)$'
)

foreach ($pattern in $allowedPatterns) {
    if ($command -match $pattern) {
        exit 0
    }
}

Deny "'$command' is not an approved read-only researcher command."

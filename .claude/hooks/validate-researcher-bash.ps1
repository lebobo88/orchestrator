$ErrorActionPreference = 'Stop'

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    $rawInput = @($input) -join [Environment]::NewLine
}
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    Write-Output 'Blocked: missing hook input.'
    exit 2
}

try {
    $payload = $rawInput | ConvertFrom-Json
    $command = [string]$payload.tool_input.command
}
catch {
    Write-Output 'Blocked: invalid hook input.'
    exit 2
}

if ([string]::IsNullOrWhiteSpace($command)) {
    Write-Output 'Blocked: missing Bash command.'
    exit 2
}

# No composition, redirection, interpolation, or subshells: each permitted command is a single inspection action.
if ($command -match '[;&|><`]' -or $command -match '\$\(') {
    Write-Output 'Blocked: researcher Bash commands must be a single read-only inspection command.'
    exit 2
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

Write-Output "Blocked: '$command' is not an approved read-only researcher command."
exit 2

# .codex/hooks/validate-scribe-write.ps1
# PowerShell 7 scribe write boundary hook for Codex CLI harness

$ErrorActionPreference = 'Stop'

function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { $rawInput = @($input) -join [Environment]::NewLine }
if ([string]::IsNullOrWhiteSpace($rawInput)) { Deny 'missing hook input.' }

try {
    $payload = $rawInput | ConvertFrom-Json
    $filePath = [string]$payload.tool_input.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) { $filePath = [string]$payload.tool_input.path }
}
catch { Deny 'invalid hook input.' }

if ([string]::IsNullOrWhiteSpace($filePath)) { Deny 'missing write path.' }

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$candidatePath = if ([System.IO.Path]::IsPathRooted($filePath)) {
    [System.IO.Path]::GetFullPath($filePath)
} else {
    [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $filePath))
}
$rootPrefix = $repositoryRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $candidatePath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    Deny 'Scribe may write only inside the repository.'
}

# Control-plane path exclusions
$relativePath = $candidatePath.Substring($rootPrefix.Length).Replace('\', '/')
$controlPlanePaths = @(
    'AGENTS.md',
    'CLAUDE.md',
    '.mcp.json'
)

foreach ($controlPath in $controlPlanePaths) {
    if ($relativePath -eq $controlPath) {
        Deny "Scribe cannot modify control-plane path: $controlPath"
    }
}

$dirPatterns = @(
    '^\.codex',
    '^\.claude',
    '^docs\/.*CONTRACT'
)

foreach ($pattern in $dirPatterns) {
    if ($relativePath -match $pattern) {
        Deny "Scribe cannot modify control-plane path pattern: $pattern"
    }
}

$allowedExtensions = @('.md', '.mdx', '.rst', '.txt')
if ($allowedExtensions -notcontains [System.IO.Path]::GetExtension($candidatePath).ToLowerInvariant()) {
    Deny 'Scribe may write only approved textual documentation formats.'
}

exit 0

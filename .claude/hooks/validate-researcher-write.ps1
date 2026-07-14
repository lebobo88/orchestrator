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
    $filePath = [string]$payload.tool_input.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) {
        $filePath = [string]$payload.tool_input.path
    }
}
catch {
    Write-Output 'Blocked: invalid hook input.'
    exit 2
}

if ([string]::IsNullOrWhiteSpace($filePath)) {
    Write-Output 'Blocked: missing write path.'
    exit 2
}

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'docs\research'))
$candidatePath = if ([System.IO.Path]::IsPathRooted($filePath)) {
    [System.IO.Path]::GetFullPath($filePath)
}
else {
    [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $filePath))
}

$allowedPrefix = $allowedRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $candidatePath.StartsWith($allowedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Output "Blocked: researcher may write only below $allowedRoot."
    exit 2
}

if ([System.IO.Path]::GetExtension($candidatePath) -ne '.md') {
    Write-Output 'Blocked: researcher reports must be Markdown files.'
    exit 2
}

exit 0

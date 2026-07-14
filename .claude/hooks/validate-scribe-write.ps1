$ErrorActionPreference = 'Stop'

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { $rawInput = @($input) -join [Environment]::NewLine }
if ([string]::IsNullOrWhiteSpace($rawInput)) { Write-Output 'Blocked: missing hook input.'; exit 2 }

try {
    $payload = $rawInput | ConvertFrom-Json
    $filePath = [string]$payload.tool_input.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) { $filePath = [string]$payload.tool_input.path }
}
catch { Write-Output 'Blocked: invalid hook input.'; exit 2 }

if ([string]::IsNullOrWhiteSpace($filePath)) { Write-Output 'Blocked: missing write path.'; exit 2 }

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$candidatePath = if ([System.IO.Path]::IsPathRooted($filePath)) {
    [System.IO.Path]::GetFullPath($filePath)
} else {
    [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $filePath))
}
$rootPrefix = $repositoryRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $candidatePath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { Write-Output 'Blocked: Scribe may write only inside the repository.'; exit 2 }

$allowedExtensions = @('.md', '.mdx', '.rst', '.txt')
if ($allowedExtensions -notcontains [System.IO.Path]::GetExtension($candidatePath).ToLowerInvariant()) {
    Write-Output 'Blocked: Scribe may write only approved textual documentation formats.'
    exit 2
}

exit 0

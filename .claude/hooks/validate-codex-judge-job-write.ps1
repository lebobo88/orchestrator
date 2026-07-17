$ErrorActionPreference = 'Stop'
function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}
$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { $rawInput = @($input) -join [Environment]::NewLine }
try {
    $payload = $rawInput | ConvertFrom-Json
    $filePath = [string]$payload.tool_input.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) { $filePath = [string]$payload.tool_input.path }
}
catch { Deny 'invalid judge job hook input.' }
if ([string]::IsNullOrWhiteSpace($filePath)) { Deny 'missing judge job path.' }

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not [System.IO.Path]::IsPathRooted($filePath)) { Deny 'judge job Write path must be absolute and resolve directly beneath runtime\\judge-job-<lowercase-hyphen-slug>.json.' }
if ($filePath -match '(?:^|[\\/])\.\.?(?:[\\/]|$)') { Deny 'judge job Write path must not contain dot or traversal segments.' }

$candidate = [System.IO.Path]::GetFullPath($filePath)
$allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'runtime')).TrimEnd('\', '/')
$candidateParent = [System.IO.Path]::GetDirectoryName($candidate).TrimEnd('\', '/')
$fileName = [System.IO.Path]::GetFileName($candidate)
if (-not [string]::Equals($candidateParent, $allowedRoot, [System.StringComparison]::OrdinalIgnoreCase)) { Deny 'runner may write only directly beneath the harness runtime directory.' }
if ($fileName -notmatch '^judge-job-[a-z0-9][a-z0-9-]{2,109}\.json$') { Deny 'judge job filename must be judge-job-<lowercase-hyphen-slug>.json.' }
exit 0

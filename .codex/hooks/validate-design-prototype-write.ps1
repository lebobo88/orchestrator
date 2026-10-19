# .codex/hooks/validate-design-prototype-write.ps1
# PowerShell 7 design prototype write boundary hook for Codex CLI harness

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
    $sessionId = [string]$payload.session_id
}
catch { Deny 'invalid hook input.' }

if ([string]::IsNullOrWhiteSpace($filePath)) { Deny 'missing prototype write path.' }
if ([string]::IsNullOrWhiteSpace($sessionId)) { $sessionId = 'unknown-session' }

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$candidatePath = if ([System.IO.Path]::IsPathRooted($filePath)) {
    [System.IO.Path]::GetFullPath($filePath)
} else {
    [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $filePath))
}
$prototypeRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot '.design/prototypes'))
$prototypePrefix = $prototypeRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
if (-not $candidatePath.StartsWith($prototypePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    Deny 'Design Prototyper may write only below .design/prototypes/<task-slug>/.'
}

$relative = $candidatePath.Substring($prototypePrefix.Length)
$segments = $relative -split '[\\/]'
if ($segments.Count -lt 2 -or $segments[0] -notmatch '^[a-z0-9][a-z0-9-]{0,79}$') {
    Deny 'prototype writes require one normalized task-slug directory.'
}

$allowedExtensions = @('.html', '.css', '.js', '.json', '.svg', '.md')
if ($allowedExtensions -notcontains [System.IO.Path]::GetExtension($candidatePath).ToLowerInvariant()) {
    Deny 'prototype file type is not allowed.'
}

$blockedNames = @('package.json', 'package-lock.json', 'npm-shrinkwrap.json', 'pnpm-lock.yaml', 'yarn.lock', 'bun.lock', 'bun.lockb')
if ($blockedNames -contains [System.IO.Path]::GetFileName($candidatePath).ToLowerInvariant()) {
    Deny 'prototype dependency manifests and lockfiles are not allowed.'
}

$safeSession = $sessionId -replace '[^A-Za-z0-9_.-]', '_'
$stateDirectory = Join-Path ([System.IO.Path]::GetTempPath()) 'codex-design-prototype-guard'
New-Item -ItemType Directory -Force -Path $stateDirectory | Out-Null
$stateFile = Join-Path $stateDirectory "$safeSession.slug"
if (Test-Path -LiteralPath $stateFile) {
    $selectedSlug = (Get-Content -Raw -LiteralPath $stateFile).Trim()
    if ($selectedSlug -ne $segments[0]) {
        Deny 'one Codex session may write only one selected prototype direction.'
    }
} else {
    Set-Content -LiteralPath $stateFile -Value $segments[0] -NoNewline
}

exit 0

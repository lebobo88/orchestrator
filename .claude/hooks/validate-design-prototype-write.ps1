$ErrorActionPreference = 'Stop'

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { $rawInput = @($input) -join [Environment]::NewLine }
if ([string]::IsNullOrWhiteSpace($rawInput)) { Write-Output 'Blocked: missing hook input.'; exit 2 }

try {
    $payload = $rawInput | ConvertFrom-Json
    $filePath = [string]$payload.tool_input.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) { $filePath = [string]$payload.tool_input.path }
    $sessionId = [string]$payload.session_id
}
catch { Write-Output 'Blocked: invalid hook input.'; exit 2 }

if ([string]::IsNullOrWhiteSpace($filePath)) { Write-Output 'Blocked: missing prototype write path.'; exit 2 }
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
    Write-Output 'Blocked: Design Prototyper may write only below .design/prototypes/<task-slug>/.'
    exit 2
}

$relative = $candidatePath.Substring($prototypePrefix.Length)
$segments = $relative -split '[\\/]'
if ($segments.Count -lt 2 -or $segments[0] -notmatch '^[a-z0-9][a-z0-9-]{0,79}$') {
    Write-Output 'Blocked: prototype writes require one normalized task-slug directory.'
    exit 2
}

$allowedExtensions = @('.html', '.css', '.js', '.json', '.svg', '.md')
if ($allowedExtensions -notcontains [System.IO.Path]::GetExtension($candidatePath).ToLowerInvariant()) {
    Write-Output 'Blocked: prototype file type is not allowed.'
    exit 2
}
$blockedNames = @('package.json', 'package-lock.json', 'npm-shrinkwrap.json', 'pnpm-lock.yaml', 'yarn.lock', 'bun.lock', 'bun.lockb')
if ($blockedNames -contains [System.IO.Path]::GetFileName($candidatePath).ToLowerInvariant()) {
    Write-Output 'Blocked: prototype dependency manifests and lockfiles are not allowed.'
    exit 2
}

$safeSession = $sessionId -replace '[^A-Za-z0-9_.-]', '_'
$stateDirectory = Join-Path ([System.IO.Path]::GetTempPath()) 'claude-design-prototype-guard'
New-Item -ItemType Directory -Force -Path $stateDirectory | Out-Null
$stateFile = Join-Path $stateDirectory "$safeSession.slug"
if (Test-Path -LiteralPath $stateFile) {
    $selectedSlug = (Get-Content -Raw -LiteralPath $stateFile).Trim()
    if ($selectedSlug -ne $segments[0]) {
        Write-Output 'Blocked: one Claude session may write only one selected prototype direction.'
        exit 2
    }
} else {
    Set-Content -LiteralPath $stateFile -Value $segments[0] -NoNewline
}

exit 0

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$hook = Join-Path $root '.claude/hooks/validate-design-prototype-write.ps1'
$session = 'design-hook-test-' + [Guid]::NewGuid().ToString('N')

function Invoke-Guard([string]$Path, [string]$SessionId) {
    $payload = @{ session_id = $SessionId; tool_input = @{ file_path = $Path } } | ConvertTo-Json -Compress
    $payload | & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook *> $null
    return $LASTEXITCODE
}

if ((Invoke-Guard '.design/prototypes/sample-task/index.html' $session) -ne 0) { throw 'Expected prototype HTML write to pass.' }
if ((Invoke-Guard '.design/prototypes/sample-task/styles.css' $session) -ne 0) { throw 'Expected same-slug prototype CSS write to pass.' }
if ((Invoke-Guard 'src/index.html' $session) -eq 0) { throw 'Expected product-source write to be blocked.' }
if ((Invoke-Guard '.design/prototypes/sample-task/package-lock.json' $session) -eq 0) { throw 'Expected lockfile write to be blocked.' }
if ((Invoke-Guard '.design/prototypes/second-direction/index.html' $session) -eq 0) { throw 'Expected a second prototype direction to be blocked.' }
if ((Invoke-Guard '.design/prototypes/../escape/index.html' ('escape-' + $session)) -eq 0) { throw 'Expected traversal to be blocked.' }

Write-Host 'Design prototype hook validation passed.'
$global:LASTEXITCODE = 0

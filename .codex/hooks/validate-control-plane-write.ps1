# .codex/hooks/validate-control-plane-write.ps1
# PowerShell 7 control-plane write prevention hook for Codex CLI harness

$ErrorActionPreference = 'Stop'

function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}

$controlPlanePaths = @(
    '.codex/config.toml',
    '.codex/requirements.template.toml',
    '.codex/hooks.json',
    '.codex/agents/**',
    '.codex/hooks/**',
    '.codex/schemas/**',
    'AGENTS.md',
    '.claude/settings.json',
    '.claude/settings.local.json',
    '.claude/maintenance-mode.flag',
    '.claude/agents/**',
    '.claude/hooks/**',
    '.claude/skills/**',
    '.claude/scripts/**',
    '.claude/schemas/**',
    '.claude/judge-policy.json',
    'CLAUDE.md',
    '.mcp.json',
    'docs/PLAN-CONTRACT.md',
    'docs/DESIGN-CONTRACT.md',
    'docs/JUDGE-CONTRACT.md',
    'docs/BUILD-CONTRACT.md',
    'docs/DOCUMENT-CONTRACT.md',
    'docs/RESEARCH-HARNESS.md',
    'docs/CAPABILITY-MAP.md',
    'docs/ARCHITECTURE-ADAPTATION.md',
    'docs/PROMPTING-AND-EVALUATION.md',
    'docs/CODEX-HARNESS.md',
    'docs/CODEX-PORTING-GUIDE.md'
)

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { $rawInput = @($input) -join [Environment]::NewLine }
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    Deny "missing hook input."
}

try {
    $payload = $rawInput | ConvertFrom-Json
}
catch {
    Deny "invalid hook input."
}

$toolName = [string]$payload.tool_name
$toolInput = $payload.tool_input

$filePath = $null
if ($toolName -in @('Write', 'Edit', 'NotebookEdit')) {
    $filePath = [string]$toolInput.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) { $filePath = [string]$toolInput.path }
}
elseif ($toolName -in @('Bash', 'exec_command', 'shell')) {
    $command = [string]$toolInput.command
    $patterns = @(
        '\.codex[\/]config',
        '\.codex[\/]requirements',
        '\.codex[\/]hooks',
        '\.codex[\/]agents',
        '\.codex[\/]schemas',
        '\.claude[\/]settings',
        '\.claude[\/]agents',
        '\.claude[\/]hooks',
        '\.claude[\/]skills',
        'AGENTS\.md',
        'CLAUDE\.md',
        '\.mcp\.json',
        'docs[\/].*CONTRACT'
    )

    foreach ($pattern in $patterns) {
        if ($command -match $pattern) {
            Deny "Command attempts to write to control-plane path: $pattern"
        }
    }
    exit 0
}

if ([string]::IsNullOrWhiteSpace($filePath)) {
    exit 0
}

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$filePath = $filePath.Replace('\', '/')
$repoRoot = $repositoryRoot.Replace('\', '/')

if ([System.IO.Path]::IsPathRooted($filePath)) {
    if ($filePath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $filePath = $filePath.Substring($repoRoot.Length).TrimStart('/')
    }
}

foreach ($controlPath in $controlPlanePaths) {
    $pattern = $controlPath -replace '\*\*', '.*' -replace '\*', '[^/]*'
    $pattern = '^' + $pattern + '$'

    if ($filePath -match $pattern) {
        Deny "Cannot modify control-plane path: $controlPath (attempted: $filePath)"
    }
}

exit 0

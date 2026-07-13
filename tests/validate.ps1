$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$required = @(
    'CLAUDE.md',
    '.claude/settings.json',
    '.agents/README.md',
    '.claude/agents/orchestrator.md',
    '.claude/agents/t1-engineer.md',
    '.claude/skills/build/SKILL.md',
    '.claude/skills/claude-operations/SKILL.md',
    '.claude/skills/workflow-author/SKILL.md',
    '.claude/skills/workflow-author/templates/dynamic-workflow-template.js',
    'docs/BUILD-CONTRACT.md',
    'docs/PROMPTING-AND-EVALUATION.md',
    'docs/ARCHITECTURE-ADAPTATION.md',
    'docs/KNOWN-UNKNOWNS.md',
    'docs/COMPLETION-AUDIT.md',
    'docs/CAPABILITY-MAP.md',
    'docs/CUSTOM-WORKFLOWS.md',
    'tests/build-classification-cases.json',
    '.gitignore',
    'README.md'
)

foreach ($relativePath in $required) {
    $path = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing required orchestrator artifact: $relativePath"
    }
}

$settingsPath = Join-Path $root '.claude/settings.json'
$settings = Get-Content -Raw -LiteralPath $settingsPath | ConvertFrom-Json
if ($settings.agent -ne 'orchestrator') { throw 'settings.json must select the orchestrator agent.' }
if ($settings.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS -ne '1') { throw 'Agent teams must be available as an opt-in capability.' }
if ($settings.worktree.baseRef -ne 'head') { throw 'Worktree baseRef must preserve the current local HEAD.' }

if (-not (Test-Path -LiteralPath (Join-Path $root '.git/HEAD'))) {
    throw 'The orchestrator folder must be initialized as a Git repository for native worktrees.'
}

$orchestrator = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/orchestrator.md')
$engineer = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/t1-engineer.md')
$build = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/build/SKILL.md')
$operations = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/claude-operations/SKILL.md')
$workflowTemplate = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/workflow-author/templates/dynamic-workflow-template.js')
$contract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/BUILD-CONTRACT.md')
$prompting = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/PROMPTING-AND-EVALUATION.md')
$unknowns = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/KNOWN-UNKNOWNS.md')
$audit = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/COMPLETION-AUDIT.md')
$cases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/build-classification-cases.json') | ConvertFrom-Json

if ($orchestrator -notmatch 't1-engineer') { throw 'Orchestrator must delegate to t1-engineer.' }
if ($engineer -notmatch '### JOB_DONE') { throw 'T1 engineer must expose a JOB_DONE handoff.' }
if ($engineer -notmatch '### JOB_BLOCKED') { throw 'T1 engineer must expose a JOB_BLOCKED handoff.' }
if ($engineer -notmatch 'schema-valid JSON') { throw 'T1 engineer must support schema-bound Dynamic Workflow handoffs.' }
if ($build -notmatch 'intentionally not a Claude Code Dynamic Workflow') { throw 'Build must remain an interactive default, not a dynamic workflow.' }
if ($operations -notmatch 'Channels require') { throw 'Operations skill must cover external event Channels.' }
if ($operations -notmatch 'Claude Agent SDK') { throw 'Operations skill must cover the approved programmatic path.' }
if ($workflowTemplate -notmatch 'agentType: .t1-engineer.') { throw 'Dynamic workflow template must delegate through t1-engineer.' }
if ($contract -notmatch 'ENGINEERING_JOB') { throw 'Build contract must define the engineering job envelope.' }
if ($contract -notmatch 'Handoff acceptance gate') { throw 'Build contract must define completion evidence.' }
if ($prompting -notmatch 'Evidence and anti-hallucination rules') { throw 'Prompting policy must include anti-hallucination guidance.' }
if ($unknowns -notmatch 'Baseline Git commit') { throw 'Known-unknowns documentation must disclose the worktree prerequisite.' }
if ($audit -notmatch 'No CLI print subprocesses') { throw 'Completion audit must cover the interactive-only constraint.' }

$expectedRoutes = @('engineering', 'non-engineering', 'ambiguous')
foreach ($route in $expectedRoutes) {
    if (-not ($cases.expected -contains $route)) { throw "Classification cases must cover '$route'." }
}
if ($cases.Count -lt 7) { throw 'Classification test cases are unexpectedly incomplete.' }

$allText = Get-ChildItem -Path $root -Recurse -File | Where-Object { $_.FullName -notmatch '\\tests\\validate\.ps1$' } | Get-Content -Raw
if ($allText -match '(?m)^\s*claude\s+-p\b') { throw 'The orchestrator must not contain a Claude print-mode invocation.' }

Write-Host 'Claude Code orchestrator foundation validation passed.'

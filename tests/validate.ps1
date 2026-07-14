$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$required = @(
    'CLAUDE.md',
    '.claude/settings.json',
    '.agents/README.md',
    '.claude/agents/orchestrator.md',
    '.claude/agents/t1-engineer.md',
    '.claude/agents/researcher.md',
    '.claude/hooks/validate-researcher-bash.ps1',
    '.claude/hooks/validate-researcher-write.ps1',
    '.claude/skills/build/SKILL.md',
    '.claude/skills/research/SKILL.md',
    '.claude/skills/claude-operations/SKILL.md',
    '.claude/skills/workflow-author/SKILL.md',
    '.claude/skills/workflow-author/templates/dynamic-workflow-template.js',
    'docs/BUILD-CONTRACT.md',
    'docs/RESEARCH-CONTRACT.md',
    'docs/RESEARCH-HARNESS.md',
    'docs/research/README.md',
    'docs/PROMPTING-AND-EVALUATION.md',
    'docs/ARCHITECTURE-ADAPTATION.md',
    'docs/KNOWN-UNKNOWNS.md',
    'docs/COMPLETION-AUDIT.md',
    'docs/CAPABILITY-MAP.md',
    'docs/CUSTOM-WORKFLOWS.md',
    'tests/build-classification-cases.json',
    'tests/research-routing-cases.json',
    'tests/research-evaluation-cases.json',
    'tests/test-research-hooks.ps1',
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

$head = git -C $root rev-parse --verify HEAD 2>$null
if ($LASTEXITCODE -ne 0 -or -not $head) {
    throw 'The orchestrator repository needs a baseline commit before native worktrees can be used.'
}

$orchestrator = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/orchestrator.md')
$engineer = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/t1-engineer.md')
$researcher = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/researcher.md')
$researchHarness = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/RESEARCH-HARNESS.md')
$build = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/build/SKILL.md')
$researchSkill = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/research/SKILL.md')
$operations = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/claude-operations/SKILL.md')
$workflowTemplate = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/workflow-author/templates/dynamic-workflow-template.js')
$contract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/BUILD-CONTRACT.md')
$researchContract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/RESEARCH-CONTRACT.md')
$prompting = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/PROMPTING-AND-EVALUATION.md')
$unknowns = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/KNOWN-UNKNOWNS.md')
$audit = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/COMPLETION-AUDIT.md')
$cases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/build-classification-cases.json') | ConvertFrom-Json
$researchCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/research-routing-cases.json') | ConvertFrom-Json
$researchEvaluationCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/research-evaluation-cases.json') | ConvertFrom-Json

if ($orchestrator -notmatch 't1-engineer') { throw 'Orchestrator must delegate to t1-engineer.' }
if ($orchestrator -notmatch 'researcher') { throw 'Orchestrator must conditionally delegate to researcher.' }
if ($engineer -notmatch '### JOB_DONE') { throw 'T1 engineer must expose a JOB_DONE handoff.' }
if ($engineer -notmatch '### JOB_BLOCKED') { throw 'T1 engineer must expose a JOB_BLOCKED handoff.' }
if ($engineer -notmatch 'schema-valid JSON') { throw 'T1 engineer must support schema-bound Dynamic Workflow handoffs.' }
if ($engineer -notmatch 'Mandatory TDD loop') { throw 'T1 engineer must require a test-driven development loop.' }
if ($engineer -notmatch 'RED') { throw 'T1 engineer must require evidence of the failing test before implementation.' }
if ($engineer -notmatch 'GREEN') { throw 'T1 engineer must require evidence of the passing test after implementation.' }
if ($engineer -notmatch 'research_context') { throw 'T1 engineer must preserve research as advisory context.' }
if ($researcher -notmatch '### RESEARCH_READY') { throw 'Researcher must expose a RESEARCH_READY handoff.' }
if ($researcher -notmatch '### RESEARCH_NEEDS_INPUT') { throw 'Researcher must expose an interactive clarification handoff.' }
if ($researcher -notmatch 'RESEARCH_BRIEF') { throw 'Researcher must return a portable research brief.' }
if ($researcher -notmatch 'Write, Edit') { throw 'Researcher must be able to persist the research report.' }
if ($researcher -notmatch 'tools:.*Bash') { throw 'Researcher must support scoped read-only repository inspection.' }
if ($researcher -notmatch 'validate-researcher-bash') { throw 'Researcher Bash access must be guarded by a scoped hook.' }
if ($researcher -notmatch 'validate-researcher-write') { throw 'Researcher report writes must be guarded by a scoped hook.' }
if ($researcher -match 'AskUserQuestion') { throw 'Researcher must use the orchestrator relay for user clarification.' }
if ($researcher -notmatch 'Intake first') { throw 'Researcher must require the targeted intake before investigation.' }
if ($researcher -notmatch 'docs/research') { throw 'Researcher must persist reports in the approved location.' }
if ($researcher -notmatch 'What') { throw 'Researcher must require what/so what/now what synthesis.' }
if ($build -notmatch 'intentionally not a Claude Code Dynamic Workflow') { throw 'Build must remain an interactive default, not a dynamic workflow.' }
if ($build -notmatch 'research_context') { throw 'Build must support a completed advisory research brief.' }
if ($researchSkill -notmatch 'disable-model-invocation: true') { throw 'Research slash command must remain user-forced.' }
if ($operations -notmatch 'Channels require') { throw 'Operations skill must cover external event Channels.' }
if ($operations -notmatch 'Claude Agent SDK') { throw 'Operations skill must cover the approved programmatic path.' }
if ($workflowTemplate -notmatch 'agentType: .t1-engineer.') { throw 'Dynamic workflow template must delegate through t1-engineer.' }
if ($workflowTemplate -notmatch 'tdd: required') { throw 'Dynamic workflow template must preserve the mandatory TDD contract.' }
if ($contract -notmatch 'ENGINEERING_JOB') { throw 'Build contract must define the engineering job envelope.' }
if ($contract -notmatch 'Handoff acceptance gate') { throw 'Build contract must define completion evidence.' }
if ($contract -notmatch 'tdd: required') { throw 'Build contract must make TDD mandatory for implementation jobs.' }
if ($contract -notmatch 'research_context') { throw 'Build contract must define advisory research context.' }
if ($researchContract -notmatch 'RESEARCH_NEEDS_INPUT') { throw 'Research contract must define interactive clarification relay.' }
if ($researchContract -notmatch 'not needed') { throw 'Research contract must keep research conditional.' }
if ($researchContract -notmatch 'Explicit user requirements') { throw 'Research contract must preserve user authority.' }
if ($researchHarness -notmatch 'RESEARCH_REQUEST') { throw 'Research harness must define the staged request envelope.' }
if ($researchHarness -notmatch 'Architecture') { throw 'Research harness must define architecture mode.' }
if ($researchHarness -notmatch 'Strategic/general') { throw 'Research harness must define strategic/general mode.' }
if ($researchHarness -notmatch 'Source ledger') { throw 'Research harness must require a source ledger.' }
if ($researchHarness -notmatch 'Professional review required before action') { throw 'Research harness must guard high-stakes research.' }
if ($researchHarness -notmatch 'update in place') { throw 'Research harness must define in-place report updates.' }
if ($prompting -notmatch 'Evidence and anti-hallucination rules') { throw 'Prompting policy must include anti-hallucination guidance.' }
if ($unknowns -notmatch 'worktree') { throw 'Known-unknowns documentation must address worktree configuration hygiene.' }
if ($audit -notmatch 'No CLI print subprocesses') { throw 'Completion audit must cover the interactive-only constraint.' }
if ($audit -notmatch 'live Git-validated') { throw 'Completion audit must record the successful native worktree validation.' }

$expectedRoutes = @('engineering', 'non-engineering', 'ambiguous')
foreach ($route in $expectedRoutes) {
    if (-not ($cases.expected -contains $route)) { throw "Classification cases must cover '$route'." }
}
if ($cases.Count -lt 7) { throw 'Classification test cases are unexpectedly incomplete.' }

$expectedResearchRoutes = @('required', 'recommended', 'not-needed')
foreach ($route in $expectedResearchRoutes) {
    if (-not ($researchCases.expected -contains $route)) { throw "Research routing cases must cover '$route'." }
}
if ($researchCases.Count -lt 5) { throw 'Research routing cases are unexpectedly incomplete.' }

if ($researchEvaluationCases.Count -lt 6) { throw 'Research evaluation cases are unexpectedly incomplete.' }
foreach ($case in $researchEvaluationCases) {
    if (-not $case.name -or -not $case.request) { throw 'Every research evaluation case requires a name and request.' }
    if ($case.expected_route -eq 'research-not-needed') { continue }
    if (-not $case.expected_profile -or -not $case.expected_mode -or $case.required_report_sections.Count -lt 3) {
        throw "Research evaluation case '$($case.name)' lacks a complete rubric."
    }
}

& (Join-Path $root 'tests/test-research-hooks.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Researcher hook validation failed.' }

$allText = Get-ChildItem -Path $root -Recurse -File | Where-Object { $_.FullName -notmatch '\\tests\\validate\.ps1$' } | Get-Content -Raw
if ($allText -match '(?m)^\s*claude\s+-p\b') { throw 'The orchestrator must not contain a Claude print-mode invocation.' }

Write-Host 'Claude Code orchestrator foundation validation passed.'

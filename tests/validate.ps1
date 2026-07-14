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
    '.claude/skills/t1-core/SKILL.md',
    '.claude/skills/t1-tdd-test-design/SKILL.md',
    '.claude/skills/t1-route-tracing/SKILL.md',
    '.claude/skills/t1-refactor-safety/SKILL.md',
    '.claude/skills/t1-performance-evidence/SKILL.md',
    '.claude/skills/t1-api-integration-contracts/SKILL.md',
    '.claude/skills/t1-ui-wiring-verification/SKILL.md',
    '.claude/skills/t1-security-reliability/SKILL.md',
    '.claude/skills/researcher-core/SKILL.md',
    '.claude/skills/research-architecture/SKILL.md',
    '.claude/skills/research-strategic-general/SKILL.md',
    '.claude/skills/research-comparison/SKILL.md',
    '.claude/skills/research-root-cause/SKILL.md',
    '.claude/skills/research-source-audit/SKILL.md',
    '.claude/skills/research-high-stakes/SKILL.md',
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
    'tests/t1-engineer-evaluation-cases.json',
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
$t1Core = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-core/SKILL.md')
$t1Tdd = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-tdd-test-design/SKILL.md')
$t1RouteTracing = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-route-tracing/SKILL.md')
$t1Refactor = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-refactor-safety/SKILL.md')
$t1Performance = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-performance-evidence/SKILL.md')
$t1Api = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-api-integration-contracts/SKILL.md')
$t1Ui = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-ui-wiring-verification/SKILL.md')
$t1Security = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-security-reliability/SKILL.md')
$researcher = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/researcher.md')
$researcherCore = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/researcher-core/SKILL.md')
$researchArchitecture = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/research-architecture/SKILL.md')
$researchStrategic = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/research-strategic-general/SKILL.md')
$researchComparison = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/research-comparison/SKILL.md')
$researchRootCause = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/research-root-cause/SKILL.md')
$researchSourceAudit = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/research-source-audit/SKILL.md')
$researchHighStakes = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/research-high-stakes/SKILL.md')
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
$t1EvaluationCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/t1-engineer-evaluation-cases.json') | ConvertFrom-Json

if ($orchestrator -notmatch 't1-engineer') { throw 'Orchestrator must delegate to t1-engineer.' }
if ($orchestrator -notmatch 'researcher') { throw 'Orchestrator must conditionally delegate to researcher.' }
if ($engineer -notmatch '### JOB_DONE') { throw 'T1 engineer must expose a JOB_DONE handoff.' }
if ($engineer -notmatch '### JOB_BLOCKED') { throw 'T1 engineer must expose a JOB_BLOCKED handoff.' }
if ($engineer -notmatch 'tools: Read, Write, Edit, Glob, Grep, Bash, Skill') { throw 'T1 engineer must preserve its core tools and add only Skill.' }
if ($engineer -notmatch 'model: haiku') { throw 'T1 engineer must preserve the configured Haiku model.' }
if ($engineer -notmatch 'maxTurns: 80') { throw 'T1 engineer must preserve the bounded turn limit.' }
if ($engineer -notmatch 't1-core') { throw 'T1 engineer must preload the core engineering playbook.' }
if ($engineer -notmatch 'Task profile and skills') { throw 'T1 engineer must select task-specific playbooks.' }
if ($engineer -notmatch 'schema-valid JSON') { throw 'T1 engineer must support schema-bound Dynamic Workflow handoffs.' }
if ($engineer -notmatch 'Mandatory TDD loop') { throw 'T1 engineer must require a test-driven development loop.' }
if ($engineer -notmatch 'RED') { throw 'T1 engineer must require evidence of the failing test before implementation.' }
if ($engineer -notmatch 'GREEN') { throw 'T1 engineer must require evidence of the passing test after implementation.' }
if ($engineer -notmatch 'research_context') { throw 'T1 engineer must preserve research as advisory context.' }
if ($engineer -notmatch 'Research needed') { throw 'T1 engineer must escalate material external documentation research.' }
if ($engineer -notmatch 'Quality review') { throw 'T1 engineer must report the full quality review.' }
if ($t1Core -notmatch 'Production priorities') { throw 'T1 core skill must preserve production-first priorities.' }
if ($t1Core -notmatch 'Research escalation') { throw 'T1 core skill must retain the researcher boundary.' }
if ($t1Tdd -notmatch 'RED') { throw 'T1 test-design skill must preserve TDD evidence.' }
if ($t1RouteTracing -notmatch 'entry point') { throw 'T1 route-tracing skill must trace behavior boundaries.' }
if ($t1Refactor -notmatch 'characterization') { throw 'T1 refactor skill must require characterization evidence.' }
if ($t1Performance -notmatch 'baseline') { throw 'T1 performance skill must require a baseline.' }
if ($t1Api -notmatch 'idempotency') { throw 'T1 API skill must handle integration reliability.' }
if ($t1Ui -notmatch 'accessibility') { throw 'T1 UI skill must include accessibility verification.' }
if ($t1Security -notmatch 'trust boundaries') { throw 'T1 security skill must identify trust boundaries.' }
if ($researcher -notmatch '### RESEARCH_READY') { throw 'Researcher must expose a RESEARCH_READY handoff.' }
if ($researcher -notmatch '### RESEARCH_NEEDS_INPUT') { throw 'Researcher must expose an interactive clarification handoff.' }
if ($researcher -notmatch 'RESEARCH_BRIEF') { throw 'Researcher must return a portable research brief.' }
if ($researcher -notmatch 'tools: Read, Glob, Grep, WebFetch, WebSearch, Bash, Write, Edit, Skill') { throw 'Researcher must preserve its core tools and add only Skill.' }
if ($researcher -notmatch 'model: sonnet') { throw 'Researcher must preserve the configured Sonnet model.' }
if ($researcher -notmatch 'permissionMode: default') { throw 'Researcher must preserve the default permission mode.' }
if ($researcher -notmatch 'maxTurns: 120') { throw 'Researcher must preserve the bounded turn limit.' }
if ($researcher -notmatch 'researcher-core') { throw 'Researcher must preload the core research playbook.' }
if ($researcher -notmatch 'Write, Edit') { throw 'Researcher must be able to persist the research report.' }
if ($researcher -notmatch 'tools:.*Bash') { throw 'Researcher must support scoped read-only repository inspection.' }
if ($researcher -notmatch 'validate-researcher-bash') { throw 'Researcher Bash access must be guarded by a scoped hook.' }
if ($researcher -notmatch 'validate-researcher-write') { throw 'Researcher report writes must be guarded by a scoped hook.' }
if ($researcher -match 'AskUserQuestion') { throw 'Researcher must use the orchestrator relay for user clarification.' }
if ($researcher -notmatch 'Skill selection') { throw 'Researcher must select the minimum relevant specialist skills.' }
if ($researcher -notmatch 'Skills used') { throw 'Researcher must report selected evidence procedures.' }
if ($researcherCore -notmatch 'RESEARCH_NEEDS_INPUT') { throw 'Researcher core must preserve the intake relay.' }
if ($researcherCore -notmatch 'Before any web research') { throw 'Researcher core must check existing reports before external research.' }
if ($researcherCore -notmatch 'What, So what, and Now what') { throw 'Researcher core must require grounded synthesis.' }
if ($researchArchitecture -notmatch 'nine sections') { throw 'Architecture skill must preserve the deep architecture structure.' }
if ($researchStrategic -notmatch 'eleven sections') { throw 'Strategic skill must preserve the deep strategic structure.' }
if ($researchComparison -notmatch 'comparison matrix') { throw 'Comparison skill must require a sourced decision matrix.' }
if ($researchRootCause -notmatch 'competing hypotheses') { throw 'Root-cause skill must evaluate competing hypotheses.' }
if ($researchSourceAudit -notmatch 'Source audit') { throw 'Source-audit skill must enforce evidence quality.' }
if ($researchHighStakes -notmatch 'Professional review required before action') { throw 'High-stakes skill must preserve professional-review guardrails.' }
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
if ($researchHarness -notmatch 'research-architecture') { throw 'Research harness must map architecture mode to its specialist skill.' }
if ($researchHarness -notmatch 'research-strategic-general') { throw 'Research harness must map strategic mode to its specialist skill.' }
if ($researchHarness -notmatch 'research-source-audit') { throw 'Research harness must map evidence audit to specialist skills.' }
if ($researchHarness -notmatch 'research-high-stakes') { throw 'Research harness must map high-stakes guardrails to a specialist skill.' }
if ($researchHarness -notmatch 'skills_used') { throw 'Research harness must record evidence procedures in report metadata.' }
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
    if (-not $case.expected_profile -or -not $case.expected_mode -or $case.required_skills.Count -lt 1 -or $case.required_report_sections.Count -lt 3) {
        throw "Research evaluation case '$($case.name)' lacks a complete rubric."
    }
}

$expectedT1Profiles = @('feature', 'debug', 'performance', 'refactor', 'UI', 'integration', 'prototype', 'research-escalation')
foreach ($profile in $expectedT1Profiles) {
    if (-not ($t1EvaluationCases.profile -contains $profile)) { throw "T1 evaluation cases must cover '$profile'." }
}
foreach ($case in $t1EvaluationCases) {
    if (-not $case.request -or $case.required_skills.Count -lt 1 -or $case.required_evidence.Count -lt 2) {
        throw "T1 evaluation case '$($case.profile)' lacks a usable rubric."
    }
}

& (Join-Path $root 'tests/test-research-hooks.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Researcher hook validation failed.' }

$allText = Get-ChildItem -Path $root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\tests\\validate\.ps1$' } |
    ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName -ErrorAction SilentlyContinue }
if ($allText -match '(?m)^\s*claude\s+-p\b') { throw 'The orchestrator must not contain a Claude print-mode invocation.' }

Write-Host 'Claude Code orchestrator foundation validation passed.'

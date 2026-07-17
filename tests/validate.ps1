$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$required = @(
    'CLAUDE.md',
    '.claude/settings.json',
    '.agents/README.md',
    '.claude/agents/orchestrator.md',
    '.claude/agents/planner.md',
    '.claude/agents/t1-engineer.md',
    '.claude/agents/t2-engineer.md',
    '.claude/agents/t3-engineering-advisor.md',
    '.claude/agents/engineering-lead.md',
    '.claude/agents/verifier.md',
    '.claude/agents/browser-validator.md',
    '.claude/agents/researcher.md',
    '.claude/agents/scribe.md',
    '.claude/agents/design-generalist.md',
    '.claude/agents/design-director.md',
    '.claude/agents/ux-architect.md',
    '.claude/agents/visual-system-designer.md',
    '.claude/agents/motion-designer.md',
    '.claude/agents/asset-art-director.md',
    '.claude/agents/design-reviewer.md',
    '.claude/agents/design-prototyper.md',
    '.claude/agents/codex-judge-runner.md',
    '.claude/hooks/validate-researcher-bash.ps1',
    '.claude/hooks/validate-scribe-write.ps1',
    '.claude/hooks/validate-design-prototype-write.ps1',
    '.claude/hooks/validate-codex-judge-job-write.ps1',
    '.claude/hooks/validate-codex-judge-command.ps1',
    '.claude/hooks/validate-agent-dispatch.ps1',
    '.claude/hooks/validate-terminal-packet.ps1',
    '.claude/scripts/invoke-codex-judge.ps1',
    '.claude/schemas/judge-result.schema.json',
    '.claude/judge-policy.json',
    '.claude/skills/build/SKILL.md',
    '.claude/skills/planner-core/SKILL.md',
    '.claude/skills/planner-repository-analysis/SKILL.md',
    '.claude/skills/planner-specification-decomposition/SKILL.md',
    '.claude/skills/planner-risk-validation/SKILL.md',
    '.claude/skills/t1-core/SKILL.md',
    '.claude/skills/t1-tdd-test-design/SKILL.md',
    '.claude/skills/t1-route-tracing/SKILL.md',
    '.claude/skills/t1-refactor-safety/SKILL.md',
    '.claude/skills/t1-performance-evidence/SKILL.md',
    '.claude/skills/t1-api-integration-contracts/SKILL.md',
    '.claude/skills/t1-ui-wiring-verification/SKILL.md',
    '.claude/skills/t1-security-reliability/SKILL.md',
    '.claude/skills/t2-escalation/SKILL.md',
    '.claude/skills/engineering-fleet/SKILL.md',
    '.claude/skills/verifier-core/SKILL.md',
    '.claude/skills/browser-validator-core/SKILL.md',
    '.claude/skills/design-core/SKILL.md',
    '.claude/skills/design-direction/SKILL.md',
    '.claude/skills/ux-architecture/SKILL.md',
    '.claude/skills/visual-system/SKILL.md',
    '.claude/skills/motion-and-assets/SKILL.md',
    '.claude/skills/design-review/SKILL.md',
    '.claude/skills/design-prototype/SKILL.md',
    '.claude/skills/cross-vendor-judging/SKILL.md',
    '.claude/skills/researcher-core/SKILL.md',
    '.claude/skills/research-browser-ui-safety/SKILL.md',
    '.claude/skills/scribe-core/SKILL.md',
    '.claude/skills/scribe-technical-documentation/SKILL.md',
    '.claude/skills/scribe-specification-and-planning/SKILL.md',
    '.claude/skills/scribe-research-briefing/SKILL.md',
    '.claude/skills/scribe-editorial-quality/SKILL.md',
    '.claude/skills/research-architecture/SKILL.md',
    '.claude/skills/research-strategic-general/SKILL.md',
    '.claude/skills/research-comparison/SKILL.md',
    '.claude/skills/research-root-cause/SKILL.md',
    '.claude/skills/research-source-audit/SKILL.md',
    '.claude/skills/research-high-stakes/SKILL.md',
    '.claude/skills/research/SKILL.md',
    '.claude/skills/claude-operations/SKILL.md',
    '.claude/skills/workflow-author/SKILL.md',
    'docs/BUILD-CONTRACT.md',
    'docs/PLAN-CONTRACT.md',
    'docs/DESIGN-CONTRACT.md',
    'docs/JUDGE-CONTRACT.md',
    'docs/plans/README.md',
    'docs/DOCUMENT-CONTRACT.md',
    'docs/RESEARCH-CONTRACT.md',
    'docs/RESEARCH-HARNESS.md',
    'docs/research/README.md',
    'docs/PROMPTING-AND-EVALUATION.md',
    'docs/ARCHITECTURE-ADAPTATION.md',
    'docs/ARCHITECTURE-C4.md',
    'docs/KNOWN-UNKNOWNS.md',
    'docs/COMPLETION-AUDIT.md',
    'docs/CAPABILITY-MAP.md',
    'docs/CUSTOM-WORKFLOWS.md',
    'tests/build-classification-cases.json',
    'tests/planning-routing-cases.json',
    'tests/planner-evaluation-cases.json',
    'tests/teammate-mode-cases.json',
    'tests/nested-planning-routing-cases.json',
    'tests/research-routing-cases.json',
    'tests/research-evaluation-cases.json',
    'tests/t1-engineer-evaluation-cases.json',
    'tests/engineering-fleet-evaluation-cases.json',
    'tests/verifier-evaluation-cases.json',
    'tests/browser-validator-evaluation-cases.json',
    'tests/writing-routing-cases.json',
    'tests/scribe-evaluation-cases.json',
    'tests/browser-ui-policy-cases.json',
    'tests/design-routing-cases.json',
    'tests/design-director-protocol-cases.json',
    'tests/agent-topology-cases.json',
    'tests/judge-routing-cases.json',
    'tests/test-research-hooks.ps1',
    'tests/test-design-hooks.ps1',
    'tests/test-agent-protocol-hooks.ps1',
    'tests/agent-dispatch-hook-cases.json',
    'tests/terminal-packet-hook-cases.json',
    'tests/send-message-contract-cases.json',
    'tests/test-codex-judge.ps1',
    'runtime/README.md',
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
if ($null -ne $settings.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS) { throw 'Default settings must not enable experimental agent teams.' }
if ($settings.env.CLAUDE_CODE_DISABLE_BACKGROUND_TASKS -ne '1') { throw 'Default settings must keep normal subagent dispatch synchronous.' }
if ($settings.teammateMode -ne 'in-process' -or $null -ne $settings.teammateDefaultModel) { throw 'Default settings must use in-process agent display without team-model configuration.' }
if ($settings.worktree.baseRef -ne 'head') { throw 'Worktree baseRef must preserve the current local HEAD.' }
foreach ($builtinAgent in @('Agent(general-purpose)', 'Agent(Explore)', 'Agent(Plan)')) {
    if ($settings.permissions.deny -notcontains $builtinAgent) {
        throw "settings.json must deny built-in agent '$builtinAgent'."
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $root '.git/HEAD'))) {
    throw 'The orchestrator folder must be initialized as a Git repository for native worktrees.'
}

$head = git -C $root rev-parse --verify HEAD 2>$null
if ($LASTEXITCODE -ne 0 -or -not $head) {
    throw 'The orchestrator repository needs a baseline commit before native worktrees can be used.'
}

$allAgentNames = @{}
$allAgentTexts = @{}
foreach ($agentFile in Get-ChildItem -LiteralPath (Join-Path $root '.claude/agents') -Recurse -File -Filter '*.md') {
    $agentText = Get-Content -Raw -LiteralPath $agentFile.FullName
    if ($agentText -notmatch '(?m)^name:\s*([a-z0-9-]+)\s*$') { throw "Agent '$($agentFile.Name)' lacks a valid frontmatter name." }
    $agentName = $Matches[1]
    if ($allAgentNames.ContainsKey($agentName)) { throw "Duplicate agent name '$agentName'." }
    $allAgentNames[$agentName] = $agentFile.FullName
    $allAgentTexts[$agentName] = $agentText
    if ($agentText -notmatch '(?m)^model:\s*(sonnet|opus|haiku|fable|inherit|claude-(?:sonnet|opus|haiku|fable)-[a-z0-9.-]+)\s*$') {
        throw "Agent '$agentName' lacks a supported model alias or full model ID."
    }
    if ($agentText -match '(?m)^effort:\s*([^\r\n]+)\s*$' -and $Matches[1].Trim() -notin @('low', 'medium', 'high', 'xhigh', 'max')) {
        throw "Agent '$agentName' declares unsupported effort '$($Matches[1].Trim())'."
    }
}

$topology = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/agent-topology-cases.json') | ConvertFrom-Json
$registryNames = @($topology.runtime_registry)
if (($registryNames | Select-Object -Unique).Count -ne $registryNames.Count) { throw 'Agent topology runtime_registry contains duplicate names.' }
foreach ($registeredName in $registryNames) {
    if (-not $allAgentNames.ContainsKey($registeredName)) { throw "Agent topology registers missing agent '$registeredName'." }
}
foreach ($definedName in $allAgentNames.Keys) {
    if ($definedName -ne 'orchestrator' -and $registryNames -notcontains $definedName) { throw "Defined agent '$definedName' is absent from the runtime registry." }
}

$orchestratorTextForRegistry = $allAgentTexts['orchestrator']
if ($orchestratorTextForRegistry -notmatch '(?m)^tools:\s*Agent\(([^\r\n)]*)\)') { throw 'Main Orchestrator must expose an explicit Agent(...) runtime allowlist.' }
$mainAgentAllowlist = @($Matches[1] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if (($mainAgentAllowlist | Select-Object -Unique).Count -ne $mainAgentAllowlist.Count) { throw 'Main Orchestrator Agent(...) allowlist contains duplicates.' }
foreach ($allowedName in $mainAgentAllowlist) {
    if (-not $allAgentNames.ContainsKey($allowedName)) { throw "Main Orchestrator allowlist references unknown agent '$allowedName'." }
}
foreach ($registeredName in $registryNames) {
    if ($mainAgentAllowlist -notcontains $registeredName) { throw "Main Orchestrator allowlist does not expose runtime agent '$registeredName'." }
}

$routingEdges = @{}
foreach ($edgeProperty in $topology.routing_edges.PSObject.Properties) {
    $routingEdges[$edgeProperty.Name] = @($edgeProperty.Value)
    if (-not $allAgentNames.ContainsKey($edgeProperty.Name)) { throw "Routing topology references unknown parent '$($edgeProperty.Name)'." }
    foreach ($childName in @($edgeProperty.Value)) {
        if (-not $allAgentNames.ContainsKey($childName)) { throw "Routing topology references unknown child '$childName'." }
        if ($mainAgentAllowlist -notcontains $childName) { throw "Transitively reachable agent '$childName' is missing from the main runtime allowlist." }
    }
}

$expectedPlannerChildren = @('researcher', 'scribe', 'design-generalist', 'design-director', 'design-reviewer', 'design-prototyper')
$expectedDirectorChildren = @('ux-architect', 'visual-system-designer', 'motion-designer', 'asset-art-director')
if ((@($routingEdges['planner'] | Sort-Object) -join ',') -ne (@($expectedPlannerChildren | Sort-Object) -join ',')) { throw 'Planner routing ownership must match the bounded research/design/review/prototype/Scribe chain.' }
if ((@($routingEdges['design-director'] | Sort-Object) -join ',') -ne (@($expectedDirectorChildren | Sort-Object) -join ',')) { throw 'Design Director routing ownership must match the four specialist roles.' }
foreach ($nestedDesignRole in @('design-generalist', 'design-director', 'ux-architect', 'visual-system-designer', 'motion-designer', 'asset-art-director', 'design-reviewer', 'design-prototyper')) {
    if (@($routingEdges['orchestrator']) -contains $nestedDesignRole) { throw "Design role '$nestedDesignRole' is runtime-visible but must not become a direct Orchestrator routing edge." }
}

$maximumDesignDepth = 3
$designPaths = @(
    @('orchestrator', 'planner', 'design-generalist'),
    @('orchestrator', 'planner', 'design-reviewer'),
    @('orchestrator', 'planner', 'design-prototyper'),
    @('orchestrator', 'planner', 'design-director', 'ux-architect'),
    @('orchestrator', 'planner', 'design-director', 'visual-system-designer'),
    @('orchestrator', 'planner', 'design-director', 'motion-designer'),
    @('orchestrator', 'planner', 'design-director', 'asset-art-director')
)
foreach ($path in $designPaths) {
    if (($path.Count - 1) -gt $maximumDesignDepth) { throw "Design route '$($path -join ' -> ')' exceeds maximum nesting depth $maximumDesignDepth." }
    for ($index = 0; $index -lt ($path.Count - 1); $index++) {
        if (@($routingEdges[$path[$index]]) -notcontains $path[$index + 1]) { throw "Design topology is missing edge '$($path[$index]) -> $($path[$index + 1])'." }
    }
}

$fixtureNames = @($topology.fixtures | ForEach-Object { $_.name })
foreach ($requiredFixture in @('compact', 'standard', 'studio', 'conditional-motion', 'conditional-assets', 'reviewer-remediation', 'selected-prototype', 'runtime-unavailable')) {
    if ($fixtureNames -notcontains $requiredFixture) { throw "Agent topology lacks required fixture '$requiredFixture'." }
}

$orchestrator = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/orchestrator.md')
$planner = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/planner.md')
$engineer = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/t1-engineer.md')
$t2Engineer = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/t2-engineer.md')
$t3Advisor = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/t3-engineering-advisor.md')
$engineeringLead = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/engineering-lead.md')
$verifier = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/verifier.md')
$browserValidator = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/browser-validator.md')
$designGeneralist = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/design-generalist.md')
$designDirector = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/design-director.md')
$uxArchitect = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/ux-architect.md')
$visualDesigner = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/visual-system-designer.md')
$motionDesigner = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/motion-designer.md')
$assetDirector = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/asset-art-director.md')
$designReviewer = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/design-reviewer.md')
$designPrototyper = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/design-prototyper.md')
$codexJudgeRunner = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/codex-judge-runner.md')
$designCore = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/design-core/SKILL.md')
$designDirection = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/design-direction/SKILL.md')
$uxArchitecture = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/ux-architecture/SKILL.md')
$visualSystem = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/visual-system/SKILL.md')
$motionAssets = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/motion-and-assets/SKILL.md')
$designReview = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/design-review/SKILL.md')
$designPrototype = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/design-prototype/SKILL.md')
$crossVendorJudging = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/cross-vendor-judging/SKILL.md')
$plannerCore = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/planner-core/SKILL.md')
$plannerRepository = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/planner-repository-analysis/SKILL.md')
$plannerSpecification = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/planner-specification-decomposition/SKILL.md')
$plannerRisk = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/planner-risk-validation/SKILL.md')
$t1Core = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-core/SKILL.md')
$t1Tdd = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-tdd-test-design/SKILL.md')
$t1RouteTracing = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-route-tracing/SKILL.md')
$t1Refactor = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-refactor-safety/SKILL.md')
$t1Performance = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-performance-evidence/SKILL.md')
$t1Api = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-api-integration-contracts/SKILL.md')
$t1Ui = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-ui-wiring-verification/SKILL.md')
$t1Security = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t1-security-reliability/SKILL.md')
$t2Escalation = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/t2-escalation/SKILL.md')
$engineeringFleet = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/engineering-fleet/SKILL.md')
$verifierCore = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/verifier-core/SKILL.md')
$browserValidatorCore = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/browser-validator-core/SKILL.md')
$researcher = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/researcher.md')
$scribe = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/agents/scribe.md')
$researcherCore = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/researcher-core/SKILL.md')
$researchBrowserUi = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/research-browser-ui-safety/SKILL.md')
$scribeCore = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/scribe-core/SKILL.md')
$scribeTechnical = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/scribe-technical-documentation/SKILL.md')
$scribePlanning = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/scribe-specification-and-planning/SKILL.md')
$scribeResearch = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/scribe-research-briefing/SKILL.md')
$scribeEditorial = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/skills/scribe-editorial-quality/SKILL.md')
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
$contract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/BUILD-CONTRACT.md')
$claudeInstructions = Get-Content -Raw -LiteralPath (Join-Path $root 'CLAUDE.md')
$planContract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/PLAN-CONTRACT.md')
$designContract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/DESIGN-CONTRACT.md')
$judgeContract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/JUDGE-CONTRACT.md')
$judgeAdapter = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/scripts/invoke-codex-judge.ps1')
$judgeSchema = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/schemas/judge-result.schema.json') | ConvertFrom-Json
$judgePolicy = Get-Content -Raw -LiteralPath (Join-Path $root '.claude/judge-policy.json') | ConvertFrom-Json
$documentContract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/DOCUMENT-CONTRACT.md')
$researchContract = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/RESEARCH-CONTRACT.md')
$prompting = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/PROMPTING-AND-EVALUATION.md')
$architectureC4 = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/ARCHITECTURE-C4.md')
$capabilityMap = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/CAPABILITY-MAP.md')
$unknowns = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/KNOWN-UNKNOWNS.md')
$audit = Get-Content -Raw -LiteralPath (Join-Path $root 'docs/COMPLETION-AUDIT.md')
$cases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/build-classification-cases.json') | ConvertFrom-Json
$planningCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/planning-routing-cases.json') | ConvertFrom-Json
$plannerEvaluationCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/planner-evaluation-cases.json') | ConvertFrom-Json
$teammateModeCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/teammate-mode-cases.json') | ConvertFrom-Json
$nestedPlanningCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/nested-planning-routing-cases.json') | ConvertFrom-Json
$researchCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/research-routing-cases.json') | ConvertFrom-Json
$researchEvaluationCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/research-evaluation-cases.json') | ConvertFrom-Json
$t1EvaluationCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/t1-engineer-evaluation-cases.json') | ConvertFrom-Json
$engineeringFleetCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/engineering-fleet-evaluation-cases.json') | ConvertFrom-Json
$verifierEvaluationCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/verifier-evaluation-cases.json') | ConvertFrom-Json
$browserValidatorEvaluationCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/browser-validator-evaluation-cases.json') | ConvertFrom-Json
$writingCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/writing-routing-cases.json') | ConvertFrom-Json
$scribeEvaluationCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/scribe-evaluation-cases.json') | ConvertFrom-Json
$browserUiCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/browser-ui-policy-cases.json') | ConvertFrom-Json
$designRoutingCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/design-routing-cases.json') | ConvertFrom-Json
$designDirectorProtocolCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/design-director-protocol-cases.json') | ConvertFrom-Json
$judgeRoutingCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/judge-routing-cases.json') | ConvertFrom-Json
$agentDispatchCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/agent-dispatch-hook-cases.json') | ConvertFrom-Json
$terminalPacketCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/terminal-packet-hook-cases.json') | ConvertFrom-Json
$sendMessageCases = Get-Content -Raw -LiteralPath (Join-Path $root 'tests/send-message-contract-cases.json') | ConvertFrom-Json

if ($orchestrator -notmatch 't1-engineer') { throw 'Orchestrator must delegate to t1-engineer.' }
if ($orchestrator -notmatch 'verifier') { throw 'Orchestrator must delegate to verifier after T1.' }
if ($orchestrator -notmatch 'browser-validator') { throw 'Orchestrator must delegate to browser-validator for UI work.' }
if ($orchestrator -notmatch 'planner') { throw 'Orchestrator must route non-basic work to planner.' }
if ($orchestrator -notmatch 'researcher') { throw 'Orchestrator must conditionally delegate to researcher.' }
if ($orchestrator -notmatch 'scribe') { throw 'Orchestrator must route non-code writing to Scribe.' }
if ($orchestrator -notmatch 'TASK_RECEIPT') { throw 'Orchestrator must retain compact team receipts.' }
if ($orchestrator -notmatch 'DOCUMENTATION_HANDOFF') { throw 'Orchestrator must support direct T1 to Scribe handoffs.' }
if ($orchestrator -notmatch 'Browser UI invariant') { throw 'Orchestrator must enforce the browser UI invariant.' }
if ($orchestrator -notmatch 'PLANNING_HANDOFF') { throw 'Orchestrator must support direct Planner to Scribe handoffs.' }
if ($orchestrator -notmatch 'explicit user approval') { throw 'Orchestrator must require plan approval before downstream execution.' }
if ($orchestrator -notmatch 'do not retry with a multiplexer') { throw 'Orchestrator must fall back instead of requiring a terminal multiplexer.' }
if ($orchestrator -notmatch 't2-engineer' -or $orchestrator -notmatch 't3-engineering-advisor' -or $orchestrator -notmatch 'engineering-lead') { throw 'Orchestrator must allowlist the complete engineering fleet.' }
if ($orchestrator -notmatch 'codex-judge-runner' -or $orchestrator -notmatch 'PLAN_DUCK' -or $orchestrator -notmatch 'VERIFICATION_CHALLENGE' -or $orchestrator -notmatch 'VISUAL_REVIEW') { throw 'Orchestrator must route every selective Codex checkpoint.' }
if ($orchestrator -notmatch 'foreground custom `planner`') { throw 'Orchestrator must run serial planning through one foreground Planner.' }
if ($orchestrator -notmatch 'SendMessage') { throw 'Orchestrator must resume the original Planner through SendMessage.' }
if ($orchestrator -notmatch 'idle notification.*not completion') { throw 'Orchestrator must reject idle as a planning completion signal.' }
if ($orchestrator -notmatch 'planner_protocol_invalid') { throw 'Orchestrator must block unexpected Planner termination instead of resuming it.' }
if ($orchestrator -notmatch 'exactly once only after') { throw 'Orchestrator must bound Planner resumption to named protocol events.' }
if ($orchestrator -notmatch 'validate-agent-dispatch') { throw 'Orchestrator must guard direct Agent dispatches.' }
if ($orchestrator -notmatch 'general-purpose.*, `Explore`, and `Plan`') { throw 'Orchestrator must prohibit built-in agent delegation.' }
if ($planner -notmatch '### PLAN_READY') { throw 'Planner must expose a PLAN_READY handoff.' }
if ($planner -notmatch '### PLAN_BLOCKED') { throw 'Planner must expose a PLAN_BLOCKED handoff.' }
if ($planner -notmatch 'PLANNING_HANDOFF') { throw 'Planner must return a complete Scribe handoff.' }
if ($planner -notmatch 'PLANNING_RESEARCH_REQUEST') { throw 'Planner must directly request material research.' }
if ($planner -notmatch 'tools: Agent, SendMessage, Read, Glob, Grep, Skill') { throw 'Planner must allow bounded nested design/research delegation and resume with no direct write or web tools.' }
if ($planner -notmatch 'model: opus') { throw 'Planner must use the configured Opus model.' }
if ($planner -notmatch 'permissionMode: plan') { throw 'Planner must preserve plan permission mode.' }
if ($planner -notmatch 'maxTurns: 90') { throw 'Planner must preserve the bounded turn limit.' }
if ($planner -notmatch 'planner-core') { throw 'Planner must preload the core planning playbook.' }
if ($planner -match '(?m)^tools:.*(?:Write|Edit|Bash|WebFetch|WebSearch)') { throw 'Planner must not receive write, shell, or web tools.' }
if ($planner -match 'AskUserQuestion') { throw 'Planner must use the orchestrator relay for user clarification.' }
if ($planner -notmatch 'never invoke `t1-engineer`') { throw 'Planner must prohibit direct implementation delegation.' }
if ($planner -notmatch 'DESIGN_ROUTE' -or $planner -notmatch 'design-reviewer' -or $planner -notmatch 'Fable 5') { throw 'Planner must route and review the design fleet with explicit premium-model policy.' }
if ($planner -notmatch 'validate-terminal-packet' -or $planner -notmatch 'planner_protocol_invalid') { throw 'Planner must preserve protocol-invalid child termination.' }
if ($planner -notmatch 'concise nonempty `summary`' -or $plannerCore -notmatch 'summary: <concise action>') { throw 'Planner string-message resumption must require a concise SendMessage summary.' }
foreach ($runtimeFailureContract in @($orchestrator, $planner, $planContract, $designContract, $claudeInstructions)) {
    if ($runtimeFailureContract -notmatch 'design_runtime_unavailable') { throw 'Every planning authority must preserve the hard design-runtime failure contract.' }
}
if ($planner -notmatch 'Git tracks them' -or $claudeInstructions -notmatch 'Git tracked/untracked status') { throw 'Planner instructions must treat project agent files as live regardless of Git status.' }
if ($claudeInstructions -match '(?is)Every delegated role must be one of.{0,500}browser-validator') { throw 'CLAUDE.md still contains the contradictory legacy agent roster.' }
if ($planner -match '(?is)proceed now.{0,160}inline' -or $planner -match '(?is)inline.{0,160}no separate specialist review') { throw 'Planner must not offer an inline-design fallback when the fleet is unavailable.' }
if ($plannerCore -notmatch 'explicit user approval') { throw 'Planner core must preserve the approval gate.' }
if ($plannerCore -notmatch 'nested chain') { throw 'Planner core must preserve nested serial planning.' }
if ($plannerCore -notmatch 'foreground') { throw 'Planner core must keep the serial nested chain foreground.' }
if ($plannerCore -notmatch 'SendMessage') { throw 'Planner core must preserve original-Planner resume.' }
if ($plannerRepository -notmatch 'affected') { throw 'Planner repository skill must map affected surfaces.' }
if ($plannerSpecification -notmatch 'acceptance') { throw 'Planner specification skill must cover acceptance checks.' }
if ($plannerRisk -notmatch 'Browser UI invariant') { throw 'Planner risk skill must preserve browser UI dialog policy.' }
if ($plannerRisk -notmatch 'stale') { throw 'Planner risk skill must define stale-plan controls.' }

$designAgents = @{
    'design-generalist' = $designGeneralist
    'design-director' = $designDirector
    'ux-architect' = $uxArchitect
    'visual-system-designer' = $visualDesigner
    'motion-designer' = $motionDesigner
    'asset-art-director' = $assetDirector
    'design-reviewer' = $designReviewer
    'design-prototyper' = $designPrototyper
}
$seenDesignNames = @{}
foreach ($entry in $designAgents.GetEnumerator()) {
    if ($entry.Value -notmatch "(?m)^name: $([regex]::Escape($entry.Key))$") { throw "Design agent '$($entry.Key)' must expose its unique frontmatter name." }
    if ($seenDesignNames.ContainsKey($entry.Key)) { throw "Duplicate design agent name '$($entry.Key)'." }
    $seenDesignNames[$entry.Key] = $true
    if ($entry.Value -notmatch '(?m)^model: claude-sonnet-5$') { throw "Design agent '$($entry.Key)' must default explicitly to Claude Sonnet 5." }
    if ($entry.Value -notmatch '(?m)^effort: (?:medium|high)$') { throw "Design agent '$($entry.Key)' must declare bounded effort." }
    if ($entry.Value -match '(?m)^tools:.*(?:WebFetch|WebSearch|mcp__)') { throw "Design agent '$($entry.Key)' must not receive web or MCP tools." }
}
foreach ($readOnlyDesignAgent in @($designGeneralist, $designDirector, $uxArchitect, $visualDesigner, $motionDesigner, $assetDirector, $designReviewer)) {
    if ($readOnlyDesignAgent -match '(?m)^tools:.*(?:Write|Edit|Bash)') { throw 'Planning-stage design specialists must remain read-only without shell access.' }
}
foreach ($leafDesignAgent in @($designGeneralist, $uxArchitect, $visualDesigner, $motionDesigner, $assetDirector, $designReviewer, $designPrototyper)) {
    if ($leafDesignAgent -match '(?m)^tools:.*\bAgent\b') { throw 'Leaf design agents must not exceed the three-level nesting policy.' }
}
if ($designDirector -notmatch '(?m)^tools: Agent, Read, Glob, Grep, Skill$' -or $designDirector -match '(?m)^tools: Agent\(') { throw 'Nested Design Director must use bare Agent capability without peer-messaging authority; typed nested allowlists are ignored by Claude Code.' }
if ($designDirector -notmatch 'DESIGN_SELECTION_NEEDED' -or $designDirector -notmatch 'ux-architect' -or $designDirector -notmatch 'visual-system-designer') { throw 'Design Director must own Studio selection and bounded specialist synthesis.' }
if ($designDirector -notmatch 'validate-terminal-packet' -or $designDirector -notmatch 'never request background execution, message, resume, or poll') { throw 'Design Director must preserve terminal validation and remain free of peer resumption.' }
if ($designDirector -notmatch 'Never create a fresh, anonymous, replacement, or retry `Agent` dispatch' -or $designDirector -notmatch 'Do not synthesize a handoff unless both required UX and visual packets are valid and present') { throw 'Design Director must block malformed specialist output without replacement dispatch or unreviewed handoff.' }
if ($designReviewer -notmatch 'DESIGN_REVIEW_RESULT') { throw 'Design Reviewer must return the design review contract.' }
if ($designPrototyper -notmatch 'validate-design-prototype-write' -or $designPrototyper -notmatch 'PROTOTYPE_DONE') { throw 'Design Prototyper must use the guarded prototype contract.' }
if ($designCore -notmatch 'WCAG 2\.2 AA' -or $designCore -notmatch 'Never fabricate') { throw 'Design core must enforce accessibility and evidence rules.' }
if ($designDirection -notmatch 'safe.*refined.*novel') { throw 'Design direction must define the three bounded Studio variants.' }
if ($visualSystem -notmatch 'Primitive' -or $visualSystem -notmatch 'Semantic' -or $visualSystem -notmatch 'Component') { throw 'Visual system skill must define three token layers.' }
if ($visualSystem -notmatch 'END_VISUAL_SYSTEM_SPEC' -or $visualSystem -notmatch 'packet_example' -or $visualDesigner -notmatch 'END_VISUAL_SYSTEM_SPEC') { throw 'Visual system must use the strict self-contained packet template and example.' }
if ($motionAssets -notmatch 'prefers-reduced-motion') { throw 'Motion guidance must define reduced-motion behavior.' }
if ($designReview -notmatch 'DR-A11Y' -or $designReview -notmatch 'one evidence-backed revision') { throw 'Design review must use criteria and a bounded revision loop.' }
if ($designPrototype -notmatch '\.design/prototypes/<task-slug>/') { throw 'Prototype skill must preserve the isolated root.' }
foreach ($designTerminalAgent in @($designGeneralist, $designDirector, $uxArchitect, $visualDesigner, $motionDesigner, $assetDirector, $designReviewer, $designPrototyper)) {
    if ($designTerminalAgent -notmatch 'validate-terminal-packet') { throw 'Every design-stage agent must validate its terminal packet.' }
}

if ($codexJudgeRunner -notmatch '(?m)^tools: Read, Write, Bash, Skill$' -or $codexJudgeRunner -notmatch '(?m)^model: haiku$') { throw 'Codex Judge Runner must remain a Haiku transport with only guarded read/write/command tools.' }
if ($codexJudgeRunner -notmatch 'transport agent, not a reviewer' -or $codexJudgeRunner -notmatch 'validate-codex-judge-command' -or $codexJudgeRunner -notmatch 'validate-codex-judge-job-write') { throw 'Codex Judge Runner must be transport-only and hook guarded.' }
if ($codexJudgeRunner -match '(?m)^tools:.*(?:Edit|WebFetch|WebSearch|mcp__)') { throw 'Codex Judge Runner must not receive review, web, edit, or MCP tools.' }
if ($codexJudgeRunner -notmatch 'write_path:' -or $codexJudgeRunner -notmatch 'adapter_job_path:' -or $codexJudgeRunner -notmatch 'Never pass `write_path` to the adapter') { throw 'Codex Judge Runner must distinguish the absolute Write path from the relative adapter path.' }
foreach ($flag in @('--ephemeral', '--ignore-user-config', '--ignore-rules', "'read-only'", 'approval_policy="never"', 'web_search="disabled"', 'mcp_servers={}', '--output-schema', "'--json'", "'-o'", "'-'")) {
    if ($judgeAdapter -notmatch [regex]::Escape($flag)) { throw "Codex adapter is missing required flag '$flag'." }
}
foreach ($model in @('gpt-5.6-luna', 'gpt-5.6-terra')) {
    if ($judgeAdapter -notmatch $model -or $crossVendorJudging -notmatch $model -or $judgeContract -notmatch $model) { throw "Judge routing must consistently define '$model'." }
}
if ($judgeAdapter -notmatch "'gpt-5\.6-luna' \{ 120 \}" -or $judgeAdapter -notmatch "'gpt-5\.6-terra' \{ 300 \}" -or $judgeAdapter -match 'gpt-5\.6-sol|xhigh') { throw 'Judge adapter must enforce Luna/Terra medium-only routing and timeouts.' }
if ($judgeAdapter -notmatch 'taskkill\.exe /PID \$process\.Id /T /F' -or $judgeAdapter -notmatch 'Add-CodexJudgeTimeoutDiagnostic -Path \$stderrPath -Message "Codex judge timed out after \$timeoutSeconds seconds\."') { throw 'Judge adapter must terminate the Windows launcher tree and append its timeout diagnostic.' }
if ($judgeAdapter -notmatch '\$attempt -lt 2' -or $judgeAdapter -notmatch 'transientPattern') { throw 'Judge adapter must retry recognized transient failures once only.' }
if ($judgeAdapter -notmatch 'policy_action' -or $judgeAdapter -notmatch 'blocking_finding_ids') { throw 'Judge adapter must compute deterministic policy output.' }
if ($judgeAdapter -notmatch 'finally' -or $judgeAdapter -notmatch 'current_fingerprint') { throw 'Judge adapter must clean temporary prompts and invalidate stale suppressions.' }
if ($judgePolicy.mode -ne 'shadow' -or $judgePolicy.minimum_shadow_reviews -ne 10 -or $judgePolicy.standard_call_cap -ne 2 -or $judgePolicy.high_risk_call_cap -ne 4) { throw 'Judge policy must begin in shadow mode with the approved calibration and call caps.' }
foreach ($requiredField in @('verdict', 'confidence', 'findings', 'assumptions', 'unknowns')) {
    if ($judgeSchema.required -notcontains $requiredField) { throw "Judge schema is missing '$requiredField'." }
}
if ($engineer -notmatch '### JOB_DONE') { throw 'T1 engineer must expose a JOB_DONE handoff.' }
if ($engineer -notmatch '### JOB_BLOCKED') { throw 'T1 engineer must expose a JOB_BLOCKED handoff.' }
if ($engineer -notmatch 'tools: Read, Write, Edit, Glob, Grep, Bash, Skill') { throw 'T1 engineer must preserve its core tools and add only Skill.' }
if ($engineer -notmatch 'model: haiku') { throw 'T1 engineer must preserve the configured Haiku model.' }
if ($engineer -notmatch 'maxTurns: 80') { throw 'T1 engineer must preserve the bounded turn limit.' }
if ($engineer -notmatch 't1-core') { throw 'T1 engineer must preload the core engineering playbook.' }
if ($engineer -notmatch 'Task profile and skills') { throw 'T1 engineer must select task-specific playbooks.' }
if ($engineer -notmatch 'WRITER_RELEASED') { throw 'T1 engineer must support safe ownership release for T2 escalation.' }
if ($engineer -notmatch 'Mandatory TDD loop') { throw 'T1 engineer must require a test-driven development loop.' }
if ($engineer -notmatch 'RED') { throw 'T1 engineer must require evidence of the failing test before implementation.' }
if ($engineer -notmatch 'GREEN') { throw 'T1 engineer must require evidence of the passing test after implementation.' }
if ($engineer -notmatch 'research_context') { throw 'T1 engineer must preserve research as advisory context.' }
if ($engineer -notmatch 'Research needed') { throw 'T1 engineer must escalate material external documentation research.' }
if ($engineer -notmatch 'Quality review') { throw 'T1 engineer must report the full quality review.' }
if ($engineer -notmatch 'DOCUMENTATION_HANDOFF') { throw 'T1 engineer must prepare a direct documentation handoff.' }
if ($engineer -notmatch 'TASK_RECEIPT') { throw 'T1 engineer must preserve the compact team receipt protocol.' }
if ($engineer -notmatch 'Plan stale') { throw 'T1 engineer must reject materially stale approved plans.' }
if ($engineer -notmatch 'native `alert`') { throw 'T1 engineer must prohibit native browser dialogs.' }
if ($engineer -notmatch 'browser_ui_validation') { throw 'T1 engineer must prepare the browser-validator handoff.' }
if ($t1Core -notmatch 'Production priorities') { throw 'T1 core skill must preserve production-first priorities.' }
if ($t1Core -notmatch 'Research escalation') { throw 'T1 core skill must retain the researcher boundary.' }
if ($t1Core -notmatch 'Native `alert`') { throw 'T1 core must prohibit native browser dialogs.' }
if ($t1Tdd -notmatch 'RED') { throw 'T1 test-design skill must preserve TDD evidence.' }
if ($t1RouteTracing -notmatch 'entry point') { throw 'T1 route-tracing skill must trace behavior boundaries.' }
if ($t1Refactor -notmatch 'characterization') { throw 'T1 refactor skill must require characterization evidence.' }
if ($t1Performance -notmatch 'baseline') { throw 'T1 performance skill must require a baseline.' }
if ($t1Api -notmatch 'idempotency') { throw 'T1 API skill must handle integration reliability.' }
if ($t1Ui -notmatch 'accessibility') { throw 'T1 UI skill must include accessibility verification.' }
if ($t1Ui -notmatch 'Browser UI invariant') { throw 'T1 UI skill must enforce modal-only browser dialog behavior.' }
if ($t1Security -notmatch 'trust boundaries') { throw 'T1 security skill must identify trust boundaries.' }
if ($t2Engineer -notmatch 'model: sonnet') { throw 'T2 engineer must use Sonnet.' }
if ($t2Engineer -notmatch 'ENGINEERING_ESCALATION_PACKET') { throw 'T2 engineer must require a complete escalation packet.' }
if ($t2Engineer -notmatch 'writer_ownership') { throw 'T2 engineer must reject ambiguous ownership.' }
if ($t2Engineer -notmatch 'T2 remediation limit reached') { throw 'T2 engineer must expose its terminal remediation cap.' }
if ($t2Engineer -notmatch 'RESCOPE_REQUIRED') { throw 'T2 engineer must expose scope-based rescoping.' }
if ($t2Engineer -notmatch 'full-build-continuation') { throw 'T2 engineer must support direct full-build continuation.' }
if ($t2Escalation -notmatch 'scope fingerprint') { throw 'T2 escalation skill must guard repeated scope re-dispatches.' }
if ($t2Escalation -notmatch 'former writer released ownership') { throw 'T2 escalation skill must preserve writer handoff safety.' }
if ($t3Advisor -notmatch 'model: opus') { throw 'T3 advisor must use Opus.' }
if ($t3Advisor -match '(?m)^tools:.*(?:Write|Edit|Bash)') { throw 'T3 advisor must be read-only without shell access.' }
if ($t3Advisor -notmatch 'T2_ESCALATION_RECOMMENDATION') { throw 'T3 advisor must support bounded T2 escalation recommendations.' }
if ($engineeringLead -notmatch 'model: sonnet') { throw 'Engineering Lead must use Sonnet.' }
if ($engineeringLead -match '(?m)^tools:.*(?:Write|Edit|Bash)') { throw 'Engineering Lead must be non-writing without shell authority.' }
if ($engineeringLead -notmatch 'fixed native team lead') { throw 'Engineering Lead must preserve Orchestrator lifecycle authority.' }
if ($engineeringLead -notmatch 'WRITER_RELEASED') { throw 'Engineering Lead must require writer release before T2 handoff.' }
if ($engineeringFleet -notmatch 'After cycle 2') { throw 'Engineering fleet skill must define T1 escalation threshold.' }
if ($engineeringFleet -notmatch 'T2 has two') { throw 'Engineering fleet skill must define T2 terminal cap.' }
if ($engineeringFleet -notmatch 'RESCOPE_REQUIRED' -or $engineeringFleet -notmatch 'full-build-continuation') { throw 'Engineering fleet skill must define T2 scope re-dispatch.' }
if ($engineeringFleet -notmatch 'once per approved-plan revision') { throw 'Engineering fleet skill must guard scope re-dispatch loops.' }
if ($engineeringFleet -notmatch 'T2_ESCALATION_RECOMMENDATION') { throw 'Engineering fleet skill must define T3-led escalation advice.' }
if ($engineeringFleet -notmatch 'serial-advisory-fallback') { throw 'Engineering fleet skill must define team fallback.' }
if ($verifier -notmatch '### VERIFICATION_PASS') { throw 'Verifier must expose a pass handoff.' }
if ($verifier -notmatch '### VERIFICATION_NEEDS_FIX') { throw 'Verifier must expose a remediation handoff.' }
if ($verifier -notmatch '### VERIFICATION_BLOCKED') { throw 'Verifier must expose a blocked handoff.' }
if ($verifier -notmatch 'tools: Read, Glob, Grep, Bash, Skill') { throw 'Verifier must remain read-only with test execution.' }
if ($verifier -match '(?m)^tools:.*(?:Write|Edit)') { throw 'Verifier must not receive write tools.' }
if ($verifier -notmatch 'update snapshots') { throw 'Verifier must prohibit snapshot updates.' }
if ($verifierCore -notmatch 'VERIFICATION_PASS') { throw 'Verifier core must preserve terminal evidence states.' }
if ($browserValidator -notmatch '### BROWSER_PASS') { throw 'Browser Validator must expose a pass handoff.' }
if ($browserValidator -notmatch '### BROWSER_NEEDS_FIX') { throw 'Browser Validator must expose a remediation handoff.' }
if ($browserValidator -notmatch '### BROWSER_BLOCKED') { throw 'Browser Validator must expose a blocked handoff.' }
if ($browserValidator -notmatch '### BROWSER_NOT_APPLICABLE') { throw 'Browser Validator must expose an explicit non-UI handoff.' }
if ($browserValidator -notmatch 'mcp__claude-in-chrome__\*') { throw 'Browser Validator must scope Claude in Chrome tools.' }
if ($browserValidator -match '(?m)^tools:.*(?:Write|Edit)') { throw 'Browser Validator must not receive write tools.' }
if ($browserValidator -notmatch 'playwright_setup_authorized') { throw 'Browser Validator must require setup approval.' }
if ($browserValidator -notmatch 'playwright@1\.61\.0 install chromium') { throw 'Browser Validator must pin the approved Playwright fallback.' }
if ($browserValidatorCore -notmatch 'screenshot') { throw 'Browser Validator core must require visual evidence.' }
if ($researcher -notmatch '### RESEARCH_EVIDENCE_READY') { throw 'Researcher must expose a RESEARCH_EVIDENCE_READY handoff.' }
if ($researcher -notmatch '### RESEARCH_NEEDS_INPUT') { throw 'Researcher must expose an interactive clarification handoff.' }
if ($researcher -notmatch 'RESEARCH_EVIDENCE') { throw 'Researcher must return a source-ledger evidence packet.' }
if ($researcher -notmatch 'tools: Read, Glob, Grep, WebFetch, WebSearch, Bash, Skill') { throw 'Researcher must remain read-only and preserve its research tools.' }
if ($researcher -notmatch 'model: opus') { throw 'Researcher must preserve the configured Opus model.' }
if ($researcher -notmatch 'permissionMode: default') { throw 'Researcher must preserve the default permission mode.' }
if ($researcher -notmatch 'maxTurns: 120') { throw 'Researcher must preserve the bounded turn limit.' }
if ($researcher -notmatch 'researcher-core') { throw 'Researcher must preload the core research playbook.' }
if ($researcher -notmatch 'tools:.*Bash') { throw 'Researcher must support scoped read-only repository inspection.' }
if ($researcher -notmatch 'validate-researcher-bash') { throw 'Researcher Bash access must be guarded by a scoped hook.' }
if ($researcher -match '(?m)^tools:.*(?:Write|Edit)') { throw 'Researcher must not have document-write tools.' }
if ($researcher -match 'AskUserQuestion') { throw 'Researcher must use the orchestrator relay for user clarification.' }
if ($researcher -notmatch 'Skill selection') { throw 'Researcher must select the minimum relevant specialist skills.' }
if ($researcher -notmatch 'Skills used') { throw 'Researcher must report selected evidence procedures.' }
if ($researcherCore -notmatch 'RESEARCH_NEEDS_INPUT') { throw 'Researcher core must preserve the intake relay.' }
if ($researcherCore -notmatch 'Before any web research') { throw 'Researcher core must check existing reports before external research.' }
if ($researcherCore -notmatch 'What, So what, and Now what') { throw 'Researcher core must require grounded synthesis.' }
if ($researcherCore -notmatch 'RESEARCH_EVIDENCE') { throw 'Researcher core must require evidence packets.' }
if ($researcher -notmatch 'research-browser-ui-safety') { throw 'Researcher must load browser UI safety guidance when applicable.' }
if ($researcher -notmatch 'Planner parent') { throw 'Researcher must return plan evidence to the Planner parent.' }
if ($researcherCore -notmatch 'browser_ui_dialog_policy') { throw 'Researcher core must require browser UI dialog evidence.' }
if ($researchBrowserUi -notmatch 'beforeunload') { throw 'Browser UI research skill must prohibit native browser dialogs.' }
if ($scribe -notmatch '### DOC_DONE') { throw 'Scribe must expose a DOC_DONE handoff.' }
if ($scribe -notmatch '### DOC_BLOCKED') { throw 'Scribe must expose a DOC_BLOCKED handoff.' }
if ($scribe -notmatch 'tools: Read, Write, Edit, Glob, Grep, Bash, Skill') { throw 'Scribe must have scoped document authoring tools.' }
if ($scribe -notmatch 'validate-scribe-write') { throw 'Scribe writes must be hook guarded.' }
if ($scribe -notmatch 'TASK_RECEIPT') { throw 'Scribe must return compact team receipts.' }
if ($scribe -notmatch 'PLANNING_HANDOFF') { throw 'Scribe must consume direct Planner handoffs.' }
if ($scribeCore -notmatch 'DOCUMENT_JOB') { throw 'Scribe core must enforce the document contract.' }
if ($scribeCore -notmatch 'em dashes') { throw 'Scribe core must enforce anti-tell style rules.' }
if ($scribeTechnical -notmatch 'verified') { throw 'Technical-documentation skill must require verified evidence.' }
if ($scribeTechnical -notmatch 'no-native-dialog') { throw 'Technical documentation skill must preserve browser UI dialog policy.' }
if ($scribePlanning -notmatch 'acceptance') { throw 'Planning skill must cover acceptance checks.' }
if ($scribeResearch -notmatch 'RESEARCH_EVIDENCE') { throw 'Research-briefing skill must consume Researcher evidence.' }
if ($scribeEditorial -notmatch 'accessible Markdown') { throw 'Editorial skill must cover accessible Markdown.' }
if ($researchArchitecture -notmatch 'nine sections') { throw 'Architecture skill must preserve the deep architecture structure.' }
if ($researchStrategic -notmatch 'eleven sections') { throw 'Strategic skill must preserve the deep strategic structure.' }
if ($researchComparison -notmatch 'comparison matrix') { throw 'Comparison skill must require a sourced decision matrix.' }
if ($researchRootCause -notmatch 'competing hypotheses') { throw 'Root-cause skill must evaluate competing hypotheses.' }
if ($researchSourceAudit -notmatch 'Source audit') { throw 'Source-audit skill must enforce evidence quality.' }
if ($researchHighStakes -notmatch 'Professional review required before action') { throw 'High-stakes skill must preserve professional-review guardrails.' }
if ($build -notmatch 'engineering-fleet') { throw 'Build must load the engineering fleet route.' }
if ($build -notmatch 'research_context') { throw 'Build must support a completed advisory research brief.' }
if ($build -notmatch 'DOCUMENTATION_HANDOFF') { throw 'Build must support the direct documentation handoff.' }
if ($build -notmatch 'approved_plan') { throw 'Build must require an approved plan for non-basic engineering.' }
if ($build -notmatch 'foreground custom `planner`') { throw 'Build must start one foreground Planner for non-basic engineering.' }
if ($build -notmatch 'SendMessage') { throw 'Build must resume the original Planner after user input.' }
if ($build -notmatch 'browser-validator') { throw 'Build must run the browser completion gate when applicable.' }
if ($build -notmatch 'verifier') { throw 'Build must run the independent verifier gate.' }
if ($researchSkill -notmatch 'disable-model-invocation: true') { throw 'Research slash command must remain user-forced.' }
if ($operations -notmatch 'Channels require') { throw 'Operations skill must cover external event Channels.' }
if ($operations -notmatch 'Claude Agent SDK') { throw 'Operations skill must cover the approved programmatic path.' }
if ($operations -match 'Dynamic Workflow') { throw 'Operations guidance must not require an unsupported Dynamic Workflow runtime.' }
if ($contract -notmatch 'ENGINEERING_JOB') { throw 'Build contract must define the engineering job envelope.' }
if ($contract -notmatch 'Handoff acceptance gate') { throw 'Build contract must define completion evidence.' }
if ($contract -notmatch 'tdd: required') { throw 'Build contract must make TDD mandatory for implementation jobs.' }
if ($contract -notmatch 'research_context') { throw 'Build contract must define advisory research context.' }
if ($contract -notmatch 'browser_ui_dialog_policy') { throw 'Build contract must require browser UI dialog policy evidence.' }
if ($contract -notmatch 'approved_plan') { throw 'Build contract must define approved plans for non-basic jobs.' }
if ($contract -notmatch 'VERIFICATION_JOB') { throw 'Build contract must define the verifier handoff.' }
if ($contract -notmatch 'BROWSER_VALIDATION_JOB') { throw 'Build contract must define the browser-validator handoff.' }
if ($contract -notmatch 'ENGINEERING_ESCALATION_PACKET') { throw 'Build contract must define the T1 to T2 escalation packet.' }
if ($contract -notmatch 'RESCOPE_REQUIRED' -or $contract -notmatch 'assignment_kind: initial \| escalation-remediation \| full-build-continuation') { throw 'Build contract must define direct T2 full-build continuation.' }
if ($contract -notmatch 'scope_fingerprint') { throw 'Build contract must guard repeated scope re-dispatches.' }
if ($contract -notmatch 'Extreme advisory team') { throw 'Build contract must define the extreme advisory team.' }
if ($contract -notmatch 'WRITER_RELEASED') { throw 'Build contract must require safe writer release before T2 joins an extreme team.' }
if ($contract -notmatch 'playwright_setup_authorized') { throw 'Build contract must define approval-gated Playwright setup.' }
if ($contract -notmatch 'PLAN_DUCK' -or $contract -notmatch 'CODE_REVIEW' -or $contract -notmatch 'VERIFICATION_CHALLENGE' -or $contract -notmatch 'VISUAL_REVIEW') { throw 'Build contract must place selective judge checkpoints around deterministic gates.' }
if ($contract -notmatch 'judge_findings') { throw 'Build contract must propagate stable judge findings.' }
if ($planContract -notmatch 'PLAN_JOB') { throw 'Plan contract must define the planning job envelope.' }
if ($planContract -notmatch 'PLANNING_RESEARCH_REQUEST') { throw 'Plan contract must define direct research requests.' }
if ($planContract -notmatch 'PLANNING_HANDOFF') { throw 'Plan contract must define Scribe handoffs.' }
if ($planContract -notmatch 'docs/plans/') { throw 'Plan contract must define persisted Scribe plan paths.' }
if ($planContract -notmatch 'Plan stale') { throw 'Plan contract must define stale-plan handling.' }
if ($planContract -notmatch 'foreground `planner`') { throw 'Plan contract must define foreground nested planning.' }
if ($planContract -notmatch 'nested `researcher`') { throw 'Plan contract must define nested research.' }
if ($planContract -notmatch 'nested `scribe`') { throw 'Plan contract must define nested Scribe authorship.' }
if ($planContract -notmatch 'idle notice') { throw 'Plan contract must reject idle completion.' }
if ($planContract -notmatch 'general-purpose') { throw 'Plan contract must prohibit built-in agent substitutes.' }
if ($planContract -notmatch 'browser_ui_validation') { throw 'Plan contract must require browser validator inputs for UI work.' }
if ($planContract -notmatch 'DESIGN_ROUTE' -or $planContract -notmatch 'DESIGN_REVIEW_RESULT') { throw 'Plan contract must place reviewed design before Scribe and engineering.' }
foreach ($marker in @('DESIGN_ROUTE', 'DESIGN_JOB', 'DESIGN_BRIEF', 'UX_SPEC', 'VISUAL_SYSTEM_SPEC', 'MOTION_ASSET_SPEC', 'DESIGN_HANDOFF', 'DESIGN_REVIEW_RESULT', 'DESIGN_SELECTION_NEEDED')) {
    if ($designContract -notmatch $marker) { throw "Design contract is missing '$marker'." }
}
if ($designContract -notmatch 'WCAG 2\.2 AA' -or $designContract -notmatch 'DTCG 2025\.10') { throw 'Design contract must preserve current accessibility and token standards.' }
if ($designContract -notmatch 'Sonnet 5' -or $designContract -notmatch 'Opus 4\.8' -or $designContract -notmatch 'Fable 5') { throw 'Design contract must define the cost-aware Claude model tiers.' }
foreach ($marker in @('JUDGE_JOB', 'JUDGE_RESULT', 'PLAN_DUCK', 'CODE_REVIEW', 'VERIFICATION_CHALLENGE', 'VISUAL_REVIEW', 'policy_action', 'blocking_finding_ids')) {
    if ($judgeContract -notmatch $marker) { throw "Judge contract is missing '$marker'." }
}
if ($judgeContract -notmatch 'at most two calls' -or $judgeContract -notmatch 'at most four') { throw 'Judge contract must preserve the cost caps.' }
if ($judgeContract -notmatch 'web search and MCP disabled' -or $judgeContract -notmatch 'read-only sandbox') { throw 'Judge contract must preserve the local-only boundary.' }
if ($documentContract -notmatch 'DOCUMENT_JOB') { throw 'Document contract must define the document job envelope.' }
if ($documentContract -notmatch 'TASK_RECEIPT') { throw 'Document contract must define compact team receipts.' }
if ($documentContract -notmatch 'RESEARCH_EVIDENCE') { throw 'Document contract must define direct research evidence.' }
if ($documentContract -notmatch 'DOCUMENTATION_HANDOFF') { throw 'Document contract must define direct engineering evidence.' }
if ($documentContract -notmatch 'overlapping document ownership') { throw 'Document contract must deny overlapping document ownership.' }
if ($researchContract -notmatch 'RESEARCH_NEEDS_INPUT') { throw 'Research contract must define interactive clarification relay.' }
if ($researchContract -notmatch 'not needed') { throw 'Research contract must keep research conditional.' }
if ($researchContract -notmatch 'Explicit user requirements') { throw 'Research contract must preserve user authority.' }
if ($researchHarness -notmatch 'RESEARCH_REQUEST') { throw 'Research harness must define the staged request envelope.' }
if ($researchHarness -notmatch 'research-architecture') { throw 'Research harness must map architecture mode to its specialist skill.' }
if ($researchHarness -notmatch 'research-strategic-general') { throw 'Research harness must map strategic mode to its specialist skill.' }
if ($researchHarness -notmatch 'research-source-audit') { throw 'Research harness must map evidence audit to specialist skills.' }
if ($researchHarness -notmatch 'research-high-stakes') { throw 'Research harness must map high-stakes guardrails to a specialist skill.' }
if ($researchHarness -notmatch 'skills_used') { throw 'Research harness must record evidence procedures in report metadata.' }
if ($researchHarness -notmatch 'updates them in place') { throw 'Research harness must define in-place report updates.' }
if ($researchHarness -notmatch 'Scribe') { throw 'Research harness must route report authorship to Scribe.' }
if ($prompting -notmatch 'Evidence and anti-hallucination rules') { throw 'Prompting policy must include anti-hallucination guidance.' }
if ($prompting -notmatch 'no-native-dialog') { throw 'Prompting policy must include the browser UI invariant.' }
if ($architectureC4 -notmatch 'flowchart') { throw 'Architecture C4 diagram must provide a renderable flowchart.' }
foreach ($agent in @('Planner', 'T1 Engineer', 'T2 Engineer', 'T3 Advisor', 'Engineering Lead', 'Verifier', 'Browser Validator', 'Researcher', 'Scribe')) {
    if ($architectureC4 -notmatch $agent) { throw "Architecture C4 diagram must include '$agent'." }
}
if ($unknowns -notmatch 'worktree') { throw 'Known-unknowns documentation must address worktree configuration hygiene.' }
if ($audit -notmatch 'No CLI print subprocesses') { throw 'Completion audit must cover the interactive-only constraint.' }
if ($audit -notmatch 'live Git-validated') { throw 'Completion audit must record the successful native worktree validation.' }

$expectedRoutes = @('engineering', 'non-engineering', 'ambiguous')
foreach ($route in $expectedRoutes) {
    if (-not ($cases.expected -contains $route)) { throw "Classification cases must cover '$route'." }
}
if ($cases.Count -lt 7) { throw 'Classification test cases are unexpectedly incomplete.' }

$expectedPlanningRoutes = @('direct-engineering', 'planner-required', 'direct-writing', 'clarify')
foreach ($route in $expectedPlanningRoutes) {
    if (-not ($planningCases.expected -contains $route)) { throw "Planning routing cases must cover '$route'." }
}
if ($planningCases.Count -lt 6) { throw 'Planning routing cases are unexpectedly incomplete.' }

if ($plannerEvaluationCases.Count -lt 6) { throw 'Planner evaluation cases are unexpectedly incomplete.' }
foreach ($case in $plannerEvaluationCases) {
    if (-not $case.name -or -not $case.request -or -not $case.expected_route -or $case.required_skills.Count -lt 1 -or $case.required_evidence.Count -lt 3) {
        throw "Planner evaluation case '$($case.name)' lacks a usable rubric."
    }
}

if ($teammateModeCases.Count -lt 3) { throw 'Teammate-mode cases are unexpectedly incomplete.' }
foreach ($case in $teammateModeCases) {
    if (-not $case.name -or -not $case.request -or -not $case.expected_route -or $case.required_evidence.Count -lt 3) {
        throw "Teammate-mode case '$($case.name)' lacks a usable rubric."
    }
}
if ($agentDispatchCases.Count -lt 7) { throw 'Agent-dispatch hook cases are unexpectedly incomplete.' }
if ($terminalPacketCases.Count -lt 6) { throw 'Terminal-packet hook cases are unexpectedly incomplete.' }
if ($sendMessageCases.Count -lt 3) { throw 'SendMessage contract fixtures are unexpectedly incomplete.' }
foreach ($case in $sendMessageCases) {
    $input = $case.input
    $hasRequiredShape = -not [string]::IsNullOrWhiteSpace([string]$input.to) -and -not [string]::IsNullOrWhiteSpace([string]$input.summary) -and -not [string]::IsNullOrWhiteSpace([string]$input.message)
    if ([bool]$case.valid -ne $hasRequiredShape) { throw "SendMessage contract case '$($case.name)' does not match the required string-message shape." }
}
if ($terminalPacketCases.name -notcontains 'visual packet reference is invalid' -or $terminalPacketCases.name -notcontains 'visual packet missing closing marker is invalid') { throw 'Terminal-packet fixtures must reject hollow or incomplete visual packets.' }
if ($designDirectorProtocolCases.Count -lt 1) { throw 'Design Director protocol fixtures are unexpectedly incomplete.' }
foreach ($case in $designDirectorProtocolCases) {
    if (-not $case.name -or $case.specialist -ne 'visual-system-designer' -or $case.expected_parent_packet -ne 'DESIGN_BLOCKED' -or $case.expected_reason -ne 'design_protocol_invalid' -or $case.forbidden_actions.Count -lt 3) {
        throw "Design Director protocol case '$($case.name)' lacks the required malformed-specialist blocker policy."
    }
}
if ($claudeInstructions -notmatch 'CLAUDE_CODE_DISABLE_BACKGROUND_TASKS' -or $planContract -notmatch 'explicitly enabled team session' -or $operations -notmatch 'explicitly enabled team session') { throw 'Default serial mode and explicit team opt-in must be documented consistently.' }
foreach ($defaultTeamsOnText in @($claudeInstructions, $planContract, $designContract, $capabilityMap, $audit)) {
    if ($defaultTeamsOnText -match 'teammateMode:\s*in-process') { throw 'Default documentation must not claim in-process agent teams are always configured.' }
}

if ($nestedPlanningCases.Count -lt 7) { throw 'Nested-planning routing cases are unexpectedly incomplete.' }
foreach ($case in $nestedPlanningCases) {
    if (-not $case.name -or -not $case.request -or -not $case.expected_route -or $case.required_evidence.Count -lt 3) {
        throw "Nested-planning routing case '$($case.name)' lacks a usable rubric."
    }
}

$expectedResearchRoutes = @('required', 'recommended', 'not-needed')
foreach ($route in $expectedResearchRoutes) {
    if (-not ($researchCases.expected -contains $route)) { throw "Research routing cases must cover '$route'." }
}
if ($researchCases.Count -lt 5) { throw 'Research routing cases are unexpectedly incomplete.' }

if ($researchEvaluationCases.Count -lt 6) { throw 'Research evaluation cases are unexpectedly incomplete.' }
foreach ($case in $researchEvaluationCases) {
    if (-not $case.name -or -not $case.request) { throw 'Every research evaluation case requires a name and request.' }
    if ($case.expected_route -eq 'research-not-needed') { continue }
    if (-not $case.expected_profile -or -not $case.expected_mode -or -not $case.required_handoff -or $case.required_skills.Count -lt 1 -or $case.required_report_sections.Count -lt 3) {
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

if ($engineeringFleetCases.Count -lt 8) { throw 'Engineering fleet evaluation cases are unexpectedly incomplete.' }
foreach ($case in $engineeringFleetCases) {
    if (-not $case.name -or -not $case.expected_mode -or $case.required_evidence.Count -lt 3) {
        throw "Engineering fleet case '$($case.name)' lacks a usable rubric."
    }
}

if ($verifierEvaluationCases.Count -lt 4) { throw 'Verifier evaluation cases are unexpectedly incomplete.' }
foreach ($case in $verifierEvaluationCases) {
    if (-not $case.name -or -not $case.expected_verdict -or $case.required_evidence.Count -lt 3) {
        throw "Verifier evaluation case '$($case.name)' lacks a usable rubric."
    }
}

if ($browserValidatorEvaluationCases.Count -lt 6) { throw 'Browser Validator evaluation cases are unexpectedly incomplete.' }
foreach ($case in $browserValidatorEvaluationCases) {
    if (-not $case.name -or -not $case.expected_verdict -or $case.required_evidence.Count -lt 3) {
        throw "Browser Validator evaluation case '$($case.name)' lacks a usable rubric."
    }
}

$expectedWritingRoutes = @('writing', 'research-backed-writing', 'engineering-with-documentation', 'advisory', 'ambiguous')
foreach ($route in $expectedWritingRoutes) {
    if (-not ($writingCases.expected -contains $route)) { throw "Writing routing cases must cover '$route'." }
}
if ($writingCases.Count -lt 6) { throw 'Writing routing cases are unexpectedly incomplete.' }

foreach ($case in $scribeEvaluationCases) {
    if (-not $case.document_type -or -not $case.request -or $case.required_skills.Count -lt 2 -or $case.required_evidence.Count -lt 2) {
        throw "Scribe evaluation case '$($case.document_type)' lacks a usable rubric."
    }
}

if ($browserUiCases.Count -lt 3) { throw 'Browser UI policy cases are unexpectedly incomplete.' }
foreach ($case in $browserUiCases) {
    if (-not $case.name -or -not $case.request -or $case.required_skills.Count -lt 2 -or $case.required_evidence.Count -lt 3) {
        throw "Browser UI policy case '$($case.name)' lacks a usable rubric."
    }
}

$expectedDesignProfiles = @('none', 'compact', 'standard', 'studio')
foreach ($profile in $expectedDesignProfiles) {
    if (-not ($designRoutingCases.expected_profile -contains $profile)) { throw "Design routing cases must cover '$profile'." }
}
if ($designRoutingCases.Count -lt 8) { throw 'Design routing cases are unexpectedly incomplete.' }
foreach ($case in $designRoutingCases) {
    if (-not $case.name -or -not $case.request -or -not $case.expected_profile -or $case.required_evidence.Count -lt 2) {
        throw "Design routing case '$($case.name)' lacks a usable rubric."
    }
}

$expectedJudgeCheckpoints = @('PLAN_DUCK', 'CODE_REVIEW', 'VERIFICATION_CHALLENGE', 'VISUAL_REVIEW')
foreach ($checkpoint in $expectedJudgeCheckpoints) {
    if (-not ($judgeRoutingCases.checkpoint -contains $checkpoint)) { throw "Judge routing cases must cover '$checkpoint'." }
}
foreach ($model in @('gpt-5.6-luna', 'gpt-5.6-terra')) {
    if (-not ($judgeRoutingCases.model -contains $model)) { throw "Judge routing cases must cover '$model'." }
}
if ($judgeRoutingCases.Count -lt 10) { throw 'Judge routing cases are unexpectedly incomplete.' }
foreach ($case in $judgeRoutingCases) {
    if (-not $case.name -or -not $case.risk -or -not $case.checkpoint -or -not $case.model -or $case.required_evidence.Count -lt 2) {
        throw "Judge routing case '$($case.name)' lacks a usable rubric."
    }
}

& (Join-Path $root 'tests/test-research-hooks.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Researcher and Scribe hook validation failed.' }
& (Join-Path $root 'tests/test-design-hooks.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Design prototype hook validation failed.' }
& (Join-Path $root 'tests/test-codex-judge.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Codex judge adapter validation failed.' }

$policyTextRoots = @(
    (Join-Path $root 'CLAUDE.md'),
    (Join-Path $root 'README.md'),
    (Join-Path $root '.claude'),
    (Join-Path $root 'docs'),
    (Join-Path $root 'tests')
)
$allText = Get-ChildItem -Path $policyTextRoots -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\tests\\validate\.ps1$' -and $_.Extension -notin @('.png', '.svg', '.gif', '.jpg', '.jpeg', '.webp', '.ico', '.zip', '.pdf') } |
    ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName -ErrorAction SilentlyContinue }
if ($allText -match '(?m)^\s*claude\s+-p\b') { throw 'The orchestrator must not contain a Claude print-mode invocation.' }

Write-Host 'Claude Code orchestrator foundation validation passed.'

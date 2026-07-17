# Cross-vendor judge contract

Codex CLI is the only cross-vendor execution boundary. It runs ephemerally against the local Git repository in a read-only sandbox with web search and MCP disabled. It critiques plans, code, deterministic evidence, and selected screenshots; it does not implement, rerun tests, authorize scope, or override Verifier/Browser failures.

## Checkpoints and limits

`PLAN_DUCK` runs after Scribe and applicable design review but before approval/engineering. `CODE_REVIEW` runs after `JOB_DONE` and before Verifier. `VERIFICATION_CHALLENGE` runs after `VERIFICATION_PASS` and before Browser Validator only when evidence/coverage risk remains. `VISUAL_REVIEW` runs after browser evidence only for Studio, brand-critical, accessibility-critical, or explicitly high-value UI.

Trivial deterministic single-file work without public-contract, security, data-flow, or user-visible impact skips judging. A standard eligible task has at most two calls; high-risk/Studio has at most four. One checkpoint may be repeated after remediation. Additional calls need user approval. Adversarial analysis is one rubric lens in a Terra call, never a duplicate automatic call.

Model route is Luna/medium for clear repeatable and compact checks. Terra/medium is required for multi-file or cross-layer semantics, complex/high-value/high-risk work, verification challenges, visual review, and adversarial review. Start at the routed model and escalate once only for abstention, insufficient evidence, or a substantiated risk conflict.

## Input

```text
JUDGE_JOB
task_id: <normalized id>
checkpoint: PLAN_DUCK | CODE_REVIEW | VERIFICATION_CHALLENGE | VISUAL_REVIEW
required: true | false
risk: low | medium | high | critical
target: <local Git repository>
model: gpt-5.6-luna | gpt-5.6-terra
effort: medium
artifact_refs: <local paths/sections/test evidence>
changed_paths: <bounded list>
rubric: <checkpoint-specific criteria>
prior_finding_ids: <list>
approved_suppressions: <finding_id, fingerprint, current_fingerprint, rationale, approved_by, expires_at>
image_paths: <local screenshots for VISUAL_REVIEW only>
END_JUDGE_JOB
```

Author/vendor identity is omitted. The rubric is criteria-first and artifact-specific. Pairwise ranking is avoided; when explicitly required, reverse order and require agreement.

`VISUAL_REVIEW` receives only relevant local screenshots and the approved design handoff. Use 1080p by default; use 720p or 1366×768 when the job explicitly prioritizes cost and the rubric remains legible. Screenshot paths must resolve inside the target repository.

## Output and deterministic policy

Codex returns schema-constrained `JUDGE_RESULT` with `PASS | REVISE | BLOCK | ABSTAIN`, overall confidence, findings, assumptions, and unknowns. Every finding has stable ID, severity, per-finding confidence, criterion, claim, reproducible evidence, location, impact, and bounded remediation.

The adapter appends `policy_mode`, `policy_action: continue | advisory | remediate | unassessed`, and `blocking_finding_ids`. Only an unsuppressed major/critical, high-confidence finding with complete criterion/evidence/location can enter `blocking_finding_ids`. Critical findings are not suppressible. Minor/advisory/lower-confidence findings never block. In shadow mode a remediation action becomes advisory. Required abstention is `unassessed`; required high-risk unavailability blocks the workflow as unassessed, while a recommended medium-risk unavailable check is recorded and deterministic gates continue.

Finding IDs persist through remediation. One judge-driven loop is allowed. A changed affected hunk changes `current_fingerprint`; the adapter accepts a suppression only when it still equals the approved fingerprint. Verifier or Browser failures always dominate a judge pass; Codex can request deterministic evidence but cannot waive a failed command.

## Local adapter and provenance

`codex-judge-runner` writes one ephemeral `runtime/judge-job-*.json` file and can execute only `.claude/scripts/invoke-codex-judge.ps1`. The runner uses the absolute `Write` path directly beneath the harness `runtime` root, while the guarded adapter command receives the matching canonical relative forward-slash path (`runtime/judge-job-*.json`). The adapter builds the prompt internally, sends it on stdin, and invokes `codex exec --ephemeral --ignore-user-config --ignore-rules --sandbox read-only` with approvals, web, and MCP disabled, explicit model/effort, output schema, JSONL events, and final output file. It deletes the job only after a schema-valid result and provenance record are written; launcher, timeout, policy, or schema failures retain the job for one authorized retry. Timeouts are 120 seconds for Luna and 300 seconds for Terra. On Windows, the adapter terminates a timed-out `codex.cmd` launcher tree, appends its timeout diagnostic to captured stderr, and returns exit 124; the runner's 660-second deadline is transport cleanup headroom. One retry is allowed only for a recognized transient error. Temporary prompt and result files are removed in a `finally` block on success or failure.

Ignored provenance records model, effort, checkpoint, prompt version, input hash, attempts, timeout, usage, finding count, policy action, and timestamp. They do not persist source or full prompts.

## Rollout

`.claude/judge-policy.json` begins in `shadow`. Blocking may be enabled only after ten naturally eligible reviews achieve 100% schema validity, all seeded critical defects found, fewer than 10% evidence-invalid major/critical findings, zero false critical blocks, and zero sandbox/network violations. Track accepted findings, recall, false blocks, deterministic-gate disagreement, latency, tokens, and cost per accepted finding.

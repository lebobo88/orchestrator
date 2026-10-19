# Orchestrator Control-Plane Write Guard Remediation

## Section 1 — Status and summary

Status: DRAFT, awaiting adversarial `fable` review, then a cross-vendor Codex judge pass, then explicit user approval. No step in this plan may run before that approval is recorded.

The deliverable is a corrected, minimal, fail-closed replacement for `.claude/hooks/validate-control-plane-write.ps1`, a one-token matcher change in `.claude/settings.json`, a recommended (not mandatory without decision) change to the machine-wide managed guard, and a deterministic test harness that proves the fix rather than merely claiming it. Every control-plane file in this plan is applied BY THE USER, by hand, outside Claude Code. No agent writes any control-plane file in this plan, not once. Only the test harness under `tests/**` is agent-writable, because it is protected by neither guard nor the managed permission-deny list (FINDING 8, below).

This plan also carries a diagnostic procedure (Section 3, "Phase 0") whose purpose is to settle, on evidence rather than assumption, whether this hook is the cause of the user's reported permission friction. The honest answer going into this plan is: partially, at most, and possibly not at all. Section 2, Q2 works through this without asserting a single cause.

## Outcome and audience

Outcome: a correct, minimal, fail-closed control-plane write guard that blocks exactly what it is meant to block and nothing else, delivered as a reviewed artifact the repository owner applies by hand, plus a deterministic test harness and a diagnostic procedure that settles the open question of the user's permission friction.

Audience: the repository owner (human) first — they personally apply every control-plane file change. Secondarily the T1/T2 fleet, which owns only the test-harness updates.

## Scope

IN SCOPE:
- `.claude/hooks/validate-control-plane-write.ps1` (full replacement content; applied BY THE USER)
- `.claude/settings.json` hooks matcher (one-token change; applied BY THE USER)
- `tests/control-plane-write-hook-cases.json` and `tests/test-control-plane-write-hook.ps1` (agent-writable; `tests/**` is NOT a protected path under either guard or the managed deny list — this is verified, see FINDING 8)
- `C:\Program Files\ClaudeCode\hooks\managed-control-plane-guard.ps1` — assessed and a change RECOMMENDED, applied by the user with administrator rights. Read-only to every agent.
- A diagnostic procedure to identify the true cause of the reported permission friction.
- `docs/security-policy-log.md` Entry 7, after the fact.

NON-GOALS / EXPLICITLY EXCLUDED:
- `lizbeth_spanish/` and every other project folder. STANDING AND PERMANENT per `handoff.md` Section 0 of the 2026-07-25 control-plane section. Not reopened by this plan.
- Re-introducing `.claude/maintenance-mode.flag` or any maintenance-mode mechanism. It was built and then DELIBERATELY FULLY REVERTED (originating plan, Discrepancy 4). This plan does not revive it; see Decision D2.
- Reviving anything in `handoff.md` Section 6, "Rejected proposals".
- `allowManagedPermissionRulesOnly` and `strictPluginOnlyCustomization` — the user decided to skip both entirely (originating plan, Discrepancies 1 and 2).
- Any commit, push, or PR.
- Any step in which an agent writes a control-plane file. Not one.

## Design route

Not applicable. This is control-plane infrastructure with no user-visible interface. No `DESIGN_ROUTE` applies and no design agent was invoked. This is a deliberate, recorded classification, not an omission.

## Section 2 — The four questions, answered

### Q1 — Should the project-level hook exist at all?

RECOMMENDATION: KEEP IT, repaired and narrowed.

The case for deletion, stated fairly: the managed guard is correctly written for Write/Edit, enforces the same path list, is registered at a scope no agent can touch, and its own header says it exists to backstop the project hook. `handoff.md` Phase 6 already retired the project `permissions` block in favor of the managed layer, which is real precedent for consolidation. Per FINDING 4(a) below, deleting the project hook removes NO Write/Edit protection today, because the managed guard and the managed `Edit(...)` denies both still hold.

The case for keeping it, which is what tips the decision:

(i) The managed layer is MACHINE-LOCAL. It lives at `C:\Program Files\ClaudeCode\` on one Windows box. It is not in the repository, not in version control, and absent from any fresh clone or any other machine. A repository whose only control-plane protection lives outside itself is unprotected everywhere except here. This is precisely the "fresh clone is unprotected" argument that `handoff.md` Section 6 raised against C6 (see FINDING 7) — an argument that was overridden for the `permissions` block but is not thereby answered for the hook.

(ii) The managed layer is un-testable from inside the repository. `tests/test-control-plane-write-hook.ps1` can only exercise a repo-local script. Deleting the project hook leaves the machine's only guard with zero automated coverage.

(iii) Per R5/R12 (Section "research evidence" below), the two hooks merge and both run, so keeping the project hook costs one extra process per matching call and nothing else architecturally.

(iv) The originating plan's own layered model (L1-L6) is explicitly defense-in-depth. Deleting a layer because a higher layer works is the reasoning that model rejects.

The honest limit of this recommendation: a project-scope hook is writable by the agents it governs in principle, so it is a DEFENSE-IN-DEPTH AND PORTABILITY layer, not the security boundary. The security boundary is and remains the managed layer. This plan does not claim otherwise. The originating plan already states this at its "Risks and rollback" section and this plan does not contradict it.

### Q2 — Is the guard the cause of the user's permission friction?

Answer: PARTIALLY, AT MOST. This plan does NOT assert a single cause.

Four mechanisms exist and must be distinguished rigorously, each with its own user-visible signature per R1, R2, R6, R9:

(a) HOOK BLOCK — exit 2. Signature: the call is blocked and the message is the hook's stderr text, literally `Blocked: ...` from the project hook or `Blocked (managed): ...` from the managed one. No prompt appears.

(b) HOOK CRASH — non-2 exit. Signature: a `<hook name> hook error` notice in the transcript with the first line of stderr, AND THE ACTION PROCEEDS. Distinguishable from (a) precisely because work continues.

(c) PERMISSION-RULE DENY. Signature: a denial attributed to a rule, evaluated deny→ask→allow, with no hook name in the message.

(d) PROMPT / ask. Signature: an interactive approval dialog. Documented causes: an explicit `permissions.ask` rule, a hook returning `permissionDecision: "ask"`, a PROTECTED-PATH write in `default`/`acceptEdits` mode, a critical-path `rm`/`rmdir`, or `requiresUserInteraction` MCP tools.

What the evidence DOES support, stated as fact: both guards' Bash branches currently deny ordinary read commands. That is a real, reproducible over-block, and it is mechanism (a), a BLOCK, not a prompt.

What the evidence DOES NOT support: the user reports being PROMPTED, which is mechanism (d), and a hook exit-2 block does not produce a prompt. So the Bash over-block does not by itself explain the reported symptom. This must be stated plainly rather than papered over.

Candidate explanations for the PROMPTING specifically, each labelled a HYPOTHESIS, not a conclusion:

H-A [R9] `.claude` is a protected path. Writes there PROMPT in `default` and `acceptEdits` mode, and `permissions.allow` cannot pre-approve them, because the safety check runs before allow-rule evaluation. Ordinary engineering work that touches anything under `.claude/` would prompt every time regardless of any hook or rule.

H-B [R11] The user believed they were in bypass mode but was not. `bypassPermissions` does not take effect from `.claude/settings.json` or `.claude/settings.local.json`, only from user, `--settings`, or managed settings. Also relevant: Entry 3 of `docs/security-policy-log.md` records that `disableBypassPermissionsMode` and `disableAutoMode` were REMOVED from the managed file for blast-radius reasons — so bypass is not disabled, but neither is it enabled from a project file.

H-C [R14] The permission-mode model changed after this harness was built. `auto` mode and its classifier, and `dontAsk`, are newly documented, and `auto` is documented as the default starting mode on Pro/Max/Team plans. A session silently starting in `auto` and routing protected-path writes to a classifier is a plausible source of new, unfamiliar prompting. This is a hypothesis.

H-D A crashing hook (mechanism (b)) produces a visible `hook error` notice on essentially every Write/Edit, which a user could reasonably describe as being repeatedly interrupted, even though it is not a prompt.

WHAT CHANGED RECENTLY TO ALTER THIS HOOK'S BEHAVIOR IS GENUINELY UNKNOWN. This plan does not invent a cause. Two observed, undated state changes are recorded as data points only, not as explanations: the `_configchange_test` key recorded in `docs/security-policy-log.md` Entry 6 as pending manual removal is now absent from `.claude/settings.json` (FINDING 6); and `.claude/settings.json` now carries a `hooks` block that the originating plan's Phase 1 called for. Neither observation is dated and neither is attributed to a specific actor or event.

Section 3's diagnostic procedure is the way to settle Q2. Nothing in this section may be upgraded to a conclusion without that evidence.

### Q3 — What is the correct fail behavior?

Answer: FAIL-CLOSED, via a total `try/catch` whose catch writes to STDERR and exits 2.

The argument: the current behavior is fail-OPEN, and that is the defect with real consequences, because it is SILENT. A guard that silently stops guarding provides false assurance, which is worse than no guard, since the originating plan's whole H1/H2 rationale rests on this guard working. A fail-CLOSED failure is loud, immediate, and self-announcing on the very first Write.

The outage objection is addressed head-on rather than dismissed: a crashing fail-closed hook denies every Write/Edit and is its own outage. Four concrete mitigations:

(i) Make the script TOTAL. It performs no filesystem access, no network, no external process calls, and derives the repository root by pure string manipulation on `$PSScriptRoot` rather than `Resolve-Path`, which can throw. The only realistic crash source left is malformed stdin, which is itself a condition that should block.

(ii) Prove it cannot crash BEFORE installation, by running the expanded harness — which includes explicit malformed-input and empty-input cases — against the new script while the OLD one is still installed. Installation is gated on a green harness run.

(iii) One-line rollback, documented in this plan: the user deletes the `hooks` block from `.claude/settings.json`. Settings hot-reload per R13 means this takes effect with no restart. Protection falls back to the managed guard and the managed `Edit(...)` denies, which is exactly today's real posture per FINDING 4(a) — so the rollback is not a security cliff.

(iv) The blast radius is bounded by narrowing the matcher to `Write|Edit|NotebookEdit`. A crash can no longer take out `Bash`, which is the tool ordinary engineering work depends on most.

Signal: use exit 2 with the reason on STDERR, and do NOT use `hookSpecificOutput` JSON. Justified from R3: on exit 2, an invalid JSON payload still blocks and falls back to stderr, whereas on exit 0, a JSON object that fails schema validation is a NON-blocking error and the action proceeds. Exit 2 has strictly fewer fail-open paths than JSON. This also fixes D5, since every exit-2 path must write to stderr.

### Q4 — How should Bash be handled?

Answer: REMOVE Bash from this hook entirely. Narrow the matcher to `Write|Edit|NotebookEdit` and delete the Bash branch.

The argument:

(i) It does not work against a determined write. Per R7, Read/Edit denies do not apply to arbitrary subprocesses, and Anthropic explicitly documents argument-constraining Bash patterns as "fragile." A `node -e` or `powershell -Command` one-liner writes any protected file without matching any of the six patterns. `handoff.md` Section 4 already recorded this, and H7 in the originating plan already records the user-scope `Bash(powershell -Command:*)`, `Bash(node:*)`, `Bash(cmd /c:*)` allow entries as an ACCEPTED residual bypass surface (originating plan, Discrepancy 1: skipped entirely). The Bash branch is therefore guarding a door whose wall is already documented as missing, by explicit user decision.

(ii) It DOES reliably block legitimate reads. `cat CLAUDE.md`, `ls .claude/agents`, `grep -r "CLAUDE.md" docs/` — all denied today. That is real, daily, reproducible harm.

(iii) The trade is therefore all cost, no security: guaranteed false blocks in exchange for protection that a one-line subprocess defeats. That is the definition of security theater, and it should be removed rather than tuned.

(iv) Rejected alternative, stated so a reviewer sees it was considered: implementing a genuine read/write classifier using the documented read-only allowlist from R8 (`ls, cat, echo, pwd, head, tail, grep, find, wc, which, diff, stat, du, cd`). REJECTED, because it must also handle redirection, pipes, command substitution, the un-stripped wrappers `npx`/`docker exec`/`devbox run`/`mise exec`/`direnv exec` named in R7, and arbitrary interpreters — and even a perfect classifier still fails against (i). It would be materially more complex, still fail open, and still produce false blocks. Complexity without a security gain.

(v) What this GIVES UP, stated explicitly and honestly: the two currently-passing Bash cases (`echo x > .claude/settings.json`, `rm .claude/hooks/foo.ps1`) will no longer be blocked BY THIS HOOK. This is a deliberate, disclosed reduction in claimed coverage, not a test weakened to make a suite go green. Residual protection remains: the managed `Edit(...)` denies still cover recognized Bash file commands per R7, and the risk of arbitrary subprocesses is the already-accepted H7 residual.

(vi) THE MANAGED GUARD MUST CHANGE TOO. Per FINDING 4(b), removing Bash from the project hook alone does NOT restore `cat CLAUDE.md`, because the managed guard's lines 89-100 will still deny it. This plan recommends the user delete lines 89-100 of `managed-control-plane-guard.ps1` for the same reasons. Without this step, the read-blocking symptom is NOT fixed.

## Repository findings

FINDING 1 — the four briefed defects are all confirmed by direct reading of `.claude/hooks/validate-control-plane-write.ps1`:
- D1 Undefined variable: line 80 is `$repoRoot = $repositoryRoot.Replace('\', '/')`. `$repositoryRoot` is never assigned anywhere in the 101-line script. Under `$ErrorActionPreference = 'Stop'` (line 1), calling `.Replace()` on `$null` throws.
- D2 Fail-open: that throw is at line 80, BEFORE the control-plane path loop at lines 90-98. So no Write/Edit/NotebookEdit call ever reaches the check. PowerShell's uncaught-exception exit code is 1, not 2.
- D3 Read/write conflation: the Bash branch, lines 51-72, denies on a bare `-match` of the command TEXT against `.claude/settings`, `.claude/agents`, `.claude/hooks`, `.claude/skills`, `CLAUDE.md`, `.mcp.json`. `cat CLAUDE.md`, `ls .claude/agents`, and `grep -r "CLAUDE.md" docs/` are therefore all denied. The script's own comment at line 53 concedes it is "best-effort."
- D4 Dead escape hatch: `.claude/maintenance-mode.flag` appears in the protected list at line 13 but is never read as a flag anywhere in the script.

FINDING 2 — two further defects NOT in the original brief, found by reading:
- D5 Wrong output stream. Line 35 (`Write-Output 'Blocked: missing hook input.'`) and line 40 (`Write-Output 'Blocked: invalid hook input.'`) emit the block reason on STDOUT and exit 2, while the `Deny` function at lines 4-7 correctly uses `[Console]::Error.WriteLine`. Per research claim B, on exit 2 the surfaced reason is the JSON reason or STDERR; stdout is only read if it parses as JSON, otherwise it goes to the debug log and is shown neither to the user nor to the model. So those two paths block with no visible reason.
- D6 cwd-dependent by construction. Even had `$repositoryRoot` been defined, the script has no cwd-independent way to locate the repository root. The correct local pattern already exists in this repository: `handoff.md` line 386 records that seven other hooks resolve paths via `$PSScriptRoot`.

FINDING 3 — the harness failure count is fully explained, and the explanation is exact. `tests/control-plane-write-hook-cases.json` holds 13 cases. Cases 1-8 are Write/Edit cases; every one of them reaches line 80 and dies with exit 1 (four expected 2, four expected 0 — all 8 fail). Cases 9, 10, 11 are Bash READ cases expecting exit 0, and the Bash branch denies them with exit 2 (3 more failures). Cases 12 and 13 are Bash WRITE cases expecting exit 2, and they pass — but only incidentally, because the pattern matched the path text, not because the hook understood the command was a write. 8 + 3 = 11 of 13, matching the reported count precisely. This arithmetic is the strongest single piece of grounding evidence and it corroborates the defect analysis independently.

FINDING 4 — DECISIVE for the "should this hook exist" question. Research claim E, from the official hooks documentation: hook entries MERGE across settings levels rather than replacing each other — "user, project, and local settings add their own hooks without removing managed ones" — and "all matching hooks run in parallel." The managed settings file explicitly sets `allowManagedHooksOnly: false`, which deliberately keeps project hooks running. Therefore `validate-control-plane-write.ps1` (project) and `managed-control-plane-guard.ps1` (managed) BOTH fire on every matching call. Two consequences must be stated plainly:
  (a) Deleting the project hook does NOT remove Write/Edit protection — the managed guard and the managed `Edit(...)` denies both still hold.
  (b) Deleting the project hook does NOT fix the Bash read-blocking, because the MANAGED guard has the identical flaw at its own lines 89-100 and will keep denying `cat CLAUDE.md`. This is the single most important finding in this plan: a repository-only change CANNOT fully fix the read-blocking. Fixing it requires the user to also edit the managed guard with administrator rights.

FINDING 5 — the managed guard, read at `C:\Program Files\ClaudeCode\hooks\managed-control-plane-guard.ps1`, is correctly written for Write/Edit (`$repoRoot` properly assigned at line 9; repo-scoped via `cwd` at lines 45-49; same path list). It carries two problems of its own:
- Its Bash branch (lines 89-100) has the identical read/write conflation as D3.
- Its `Agent` branch (lines 51-64) executes BEFORE the `$inScope` check at line 66, so its blanket deny of any non-empty `name`, `team_name`, `teammate_name`, or `isolation` applies to EVERY repository on the machine, not just this one. Its own comment at lines 52-54 says this is deliberate. However it directly contradicts this repository's own contract: `CLAUDE.md` and `.claude/agents/planner.md` both permit Planner "a safe stable custom-subagent name ... for native continuation." This is open Decision D3; this plan does NOT resolve it.

FINDING 6 — current registration. `.claude/settings.json` is 35 lines. The `permissions` key is genuinely ABSENT (Phase 6 retirement, confirmed). A `hooks.PreToolUse` block at lines 22-33 registers the project hook with matcher `"Write|Edit|NotebookEdit|Bash"`. The stray `"_configchange_test": true` key recorded in `docs/security-policy-log.md` Entry 6 as "pending manual removal" is NO LONGER PRESENT — someone removed it between 2026-07-27 and today. This is recorded as an observed state change of unknown authorship; it is a data point for the "what changed recently" question and must not be presented as more than that.

FINDING 7 — a documented internal contradiction that must be surfaced, not silently resolved. `handoff.md` Section 6 lists "Removing the project `permissions` block entirely (C6)" as a REJECTED proposal that "would leave every fresh clone of the repo unprotected." But the originating plan's Discrepancy 3 later decided to drop it, and Phase 6 executed that removal, verified. So `handoff.md` Section 6 is stale on this one item. This plan notes it, because the same "fresh clone is unprotected" argument is a live and legitimate argument in favor of KEEPING a project-scope hook, and a hostile reviewer will find it.

FINDING 8 — `tests/**` appears in NEITHER guard's `$controlPlanePaths` list NOR in the managed `permissions.deny` list. Agents can therefore write the test harness. This is what makes the split ownership in Section 4 possible and it is verified, not assumed.

## Research evidence

Received in full from nested Researcher, sourced ONLY from official Claude Code documentation, accessed 2026-09-04:
- S1 https://code.claude.com/docs/en/settings
- S2 https://code.claude.com/docs/en/permissions
- S3 https://code.claude.com/docs/en/permission-modes
- S4 https://code.claude.com/docs/en/hooks

Load-bearing confirmed facts:
- R1 [S4] Exit 2 blocks the tool call, "whether or not you print JSON," and "even a JSON permissionDecision of 'allow' can't override it." ANY OTHER exit code "doesn't block on its own for most hook events"; the action PROCEEDS and the transcript shows a "<hook name> hook error" notice with the first line of stderr. Fail-open on a crash is therefore DOCUMENTED HARNESS BEHAVIOR, not an inference. This confirms defect D2 as a genuine security hole.
- R2 [S4] The blocking message is the JSON reason when there is one "and your stderr text otherwise." Stdout is parsed only if it starts with `{` and ends with `}`; otherwise it goes to the debug log and is "not shown in transcript or to Claude." Confirms D5.
- R3 [S4] `hookSpecificOutput` schema: `{"hookEventName":"PreToolUse","permissionDecision":"allow"|"deny"|"ask","permissionDecisionReason":"..."}`. On exit 2 with invalid JSON it STILL blocks, using stderr as the reason. On exit 0, a parsed object failing schema validation is a NON-blocking error and the action proceeds. Exit 2 is therefore the more robust blocking signal than JSON, because it cannot fail open through a serialization mistake.
- R4 [S4] PreToolUse input fields: `session_id`, `prompt_id`, `transcript_path`, `cwd`, `permission_mode`, `effort`, `hook_event_name`, plus `tool_name`, `tool_input`, `tool_use_id`, plus `agent_id`/`agent_type` for subagents.
- R5 [S4] Hooks merge across scopes; all matching hooks run in parallel. Matchers containing anything beyond alphanumerics and `_-,|` are treated as an unanchored JavaScript regex. A narrower `if` field can filter on permission-rule syntax.
- R6 [S2] "A blocking hook also takes precedence over allow rules. A hook that exits with code 2 stops the tool call before permission rules are evaluated." But "hook decisions don't bypass permission rules" — a matching deny rule blocks regardless of what the hook returns, and a matching ask rule still prompts even when the hook returned "allow".
- R7 [S2] Anthropic's explicit warning: "Bash permission patterns that try to constrain command arguments are fragile," with a worked example showing five bypass vectors. Read/Edit deny rules "don't apply to arbitrary subprocesses that read or write files indirectly, like a Python or Node script." Claude Code strips `timeout, time, nice, nohup, stdbuf, command, builtin, noglob` before matching but explicitly does NOT strip `direnv exec, devbox run, mise exec, npx, docker exec`. The docs point to sandboxing, not hooks or rules, for true OS-level enforcement.
- R8 [S2] There is a FIXED, non-configurable read-only Bash command allowlist: `ls, cat, echo, pwd, head, tail, grep, find, wc, which, diff, stat, du, cd`, plus read-only `git` forms. No documented mechanism lets a hook natively distinguish a read from a write for Bash; a hook must implement that classification itself.
- R9 [S3] `.claude` is a PROTECTED PATH (except `.claude/worktrees`). Per-mode outcome: `default` and `acceptEdits` → PROMPTED; `auto` → routed to the classifier; `dontAsk` → Denied; `bypassPermissions` → Allowed; `plan` → allowed only in bypass-available sessions. "permissions.allow rules in settings files do not pre-approve protected-path writes. The safety check runs BEFORE Claude Code evaluates allow rules."
- R10 [S3] In prompting modes the `.claude/` prompt offers "Yes, and allow Claude to edit its own settings for this session," a session-scoped escalation that approves later `.claude/` writes without re-prompting. Flagged: this is a weakening path independent of any hook.
- R11 [S1][S3] `permissions.defaultMode` values `auto` and `bypassPermissions` DO NOT take effect from `.claude/settings.json` or `.claude/settings.local.json`; they work only from user, `--settings`, or managed settings. S1 states explicitly: "Before v2.1.257, bypassPermissions took effect from any file." This is a VERSIONED behavior change.
- R12 [S1] Precedence highest-first: Managed → Command line (`--settings`) → Project local → Shared project → User. List-shaped keys such as `permissions.allow` and `hooks` MERGE rather than override.
- R13 [S1] Settings hot-reload mid-session for `permissions` and `hooks` is re-confirmed unchanged. Only `model`, `effortLevel`/`modelSettings`, and `outputStyle` are start-only.

DOCUMENTED DRIFT SINCE THE 2026-07-25 EVIDENCE — flagged loudly, in its own subsection:
- R14 [S3][S4] The permission-mode model has EXPANDED. Two modes exist now that the July evidence does not mention: `auto` (classifier-based auto-approval, documented as the default starting mode on Pro/Max/Team plans) and `dontAsk`. The `permission_mode` hook input enum has grown from 4 documented values to 6: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`. Any reasoning in the originating plan or `handoff.md` that assumes only four modes exist is now STALE. In `auto` mode, protected-path writes are "routed to the classifier" rather than following the legacy prompt/deny behavior.

RESEARCH GAPS — carried into this plan as UNVERIFIED, not resolved:
- U1 No sentence in S2, S3, or S4 states whether a PreToolUse hook still executes, and can still exit 2, when the session is in `bypassPermissions` mode. Structural inference favors "hooks still run," since hooks are harness-executed at a point separate from the permission prompt, and nothing says permission mode disables hooks. This is an INFERENCE and must not be relied on as a security boundary without an empirical test.
- U2 The installed Claude Code version was not checked. If it is older than v2.1.257, the R11 constraint does not hold as stated.
- U3 The docs do not state whether one hook exiting 2 short-circuits other hooks still running in parallel. Inferred: any one exit-2 blocks the call regardless. Marked as inference.

## Section 3 — Phase 0: diagnostics, to be run BEFORE any change

This exists to settle Q2 with evidence instead of assertion. All steps are user-run or read-only.

1. `claude --version` — resolves U2 and the R11 version cutover.
2. `/status` — record the ACTIVE permission mode verbatim. Specifically check whether it is one of the newly documented `auto` or `dontAsk` (R14).
3. `/permissions` — record the rules and their origin column.
4. Reproduce the friction and CAPTURE THE EXACT TEXT. Then classify it against the four signatures in Q2: does it say `Blocked:`, `Blocked (managed):`, `<hook> hook error`, or is it an interactive prompt? This single observation discriminates (a) from (b) from (c) from (d).
5. Note which file the friction occurred on. If it is under `.claude/`, H-A is sufficient on its own and no hook is implicated.
6. Run `powershell -File tests/test-control-plane-write-hook.ps1` and record the baseline 11-of-13 failure.
7. Confirm the crash hypothesis directly: pipe a crafted control-plane Write payload into the current hook and record `$LASTEXITCODE`. Expected 1, which is the fail-open proof.

Acceptance for Phase 0: the friction is attributed to a specific one of the four mechanisms, ON EVIDENCE. If the evidence does not support any single mechanism, this plan requires that to be recorded as still-unknown rather than guessed.

## Section 4 — Ordered work, with owner on every step

| Step | Owner | Action |
|------|-------|--------|
| 1 | T1/T2 agent | Update `tests/control-plane-write-hook-cases.json` and `tests/test-control-plane-write-hook.ps1` per Section 7. Permitted because `tests/**` is protected by neither guard nor the managed denies (FINDING 8). |
| 2 | agent | Run the updated harness against the CURRENT hook. Expect failures. This is the baseline, not a gate. |
| 3 | THE USER, BY HAND, OUTSIDE CLAUDE CODE | Replace the entire contents of `.claude/hooks/validate-control-plane-write.ps1` with Appendix A. |
| 4 | THE USER, BY HAND | In `.claude/settings.json` line 25, change the matcher from `"Write|Edit|NotebookEdit|Bash"` to `"Write|Edit|NotebookEdit"`. This is the only change to that file; every other key stays untouched. |
| 5 | agent or user | Re-run `tests/test-control-plane-write-hook.ps1`. GATE: all cases must pass. Then run `tests/validate.ps1` and confirm no regression. |
| 6 | THE USER, WITH ADMINISTRATOR RIGHTS, outside Claude Code | Apply Appendix B to `C:\Program Files\ClaudeCode\hooks\managed-control-plane-guard.ps1`. Gated on Decision D3. Without this step the read-blocking is not fixed (FINDING 4(b)). |
| 7 | THE USER | Start a FRESH session. Confirm: `cat CLAUDE.md` succeeds; `ls .claude/agents` succeeds; `grep -r "CLAUDE.md" docs/` succeeds; an attempted Write to `.claude/agents/planner.md` is blocked with a visible `Blocked:` reason; an ordinary Write to a normal source file succeeds. |
| 8 | Scribe, after the fact | Add Entry 7 to `docs/security-policy-log.md` recording the managed-guard edit, per the promotion workflow. Also record the Phase 0 findings. |

Note prominently: steps 3, 4, 6, and 7 CANNOT be delegated to any agent. The managed `Edit(...)` deny and both `PreToolUse` guards block agent writes to these paths by deliberate design, and a prior T2 hit exactly this self-lock (originating plan, "Implementation and verification history"). This plan does not attempt to work around the guard.

## Section 5 — Appendix A, the full replacement hook

```powershell
# .claude/hooks/validate-control-plane-write.ps1
# PreToolUse control-plane write guard (project scope).
#
# Registered in .claude/settings.json with matcher: Write|Edit|NotebookEdit
# Bash is deliberately NOT handled here. Bash content filtering cannot distinguish a read
# from a write reliably, is documented as fragile, and fails open against any subprocess
# (node -e, powershell -Command). It produced false denials on ordinary reads while
# providing no protection against a determined write. See the plan's Q4.
#
# Fail-closed: any internal error blocks with exit 2 rather than allowing the call through.
# Every blocking path writes its reason to STDERR, because on exit 2 the harness surfaces
# stderr and discards non-JSON stdout.
#
# This is a defense-in-depth and portability layer. The security boundary is the managed
# layer at C:\Program Files\ClaudeCode\, which no agent can write.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Deny([string]$Reason) {
    [Console]::Error.WriteLine("Blocked: $Reason")
    exit 2
}

$controlPlanePaths = @(
    '.claude/settings.json',
    '.claude/settings.local.json',
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
    'docs/PROMPTING-AND-EVALUATION.md'
)

try {
    $rawInput = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($rawInput)) { Deny 'missing hook input.' }

    try { $payload = $rawInput | ConvertFrom-Json }
    catch { Deny 'invalid hook input (not JSON).' }

    $toolName = ''
    if ($payload.PSObject.Properties.Name -contains 'tool_name') { $toolName = [string]$payload.tool_name }

    if ($toolName -ne 'Write' -and $toolName -ne 'Edit' -and $toolName -ne 'NotebookEdit') { exit 0 }

    $toolInput = $null
    if ($payload.PSObject.Properties.Name -contains 'tool_input') { $toolInput = $payload.tool_input }
    if ($null -eq $toolInput) { Deny "tool_input missing for $toolName." }

    $names = @($toolInput.PSObject.Properties.Name)
    $filePath = ''
    foreach ($key in @('file_path', 'notebook_path', 'path')) {
        if ($names -contains $key) {
            $candidate = [string]$toolInput.$key
            if (-not [string]::IsNullOrWhiteSpace($candidate)) { $filePath = $candidate; break }
        }
    }
    if ([string]::IsNullOrWhiteSpace($filePath)) { Deny "no file path present in tool_input for $toolName." }

    # Repository root, derived from this script's own location, never from cwd.
    # This file lives at <repoRoot>/.claude/hooks/, so the root is two levels up.
    # Pure string manipulation: Resolve-Path is avoided because it can throw.
    $hooksDir = $PSScriptRoot
    $claudeDir = Split-Path -Parent $hooksDir
    $repoRoot = (Split-Path -Parent $claudeDir).Replace('\', '/').TrimEnd('/')

    $normalized = $filePath.Replace('\', '/')

    if ([System.IO.Path]::IsPathRooted($filePath)) {
        if ($normalized.StartsWith(($repoRoot + '/'), [System.StringComparison]::OrdinalIgnoreCase)) {
            $relative = $normalized.Substring($repoRoot.Length + 1)
        }
        else {
            # Absolute path outside this repository. Not this guard's concern.
            exit 0
        }
    }
    else {
        $relative = $normalized -replace '^\./', ''
    }

    $relative = $relative.TrimStart('/')

    # Reject traversal rather than trying to resolve it.
    if ($relative -match '(^|/)\.\.(/|$)') { Deny "path traversal is not permitted (attempted: $filePath)." }

    foreach ($controlPath in $controlPlanePaths) {
        $escaped = [regex]::Escape($controlPath)
        $regex = '^' + ($escaped -replace '\\\*\\\*', '.*' -replace '\\\*', '[^/]*') + '$'
        if ($relative -match $regex) {
            Deny "cannot modify control-plane path '$controlPath' (attempted: $relative)."
        }
    }

    exit 0
}
catch {
    # Fail-closed. A guard that cannot evaluate must not permit.
    [Console]::Error.WriteLine("Blocked: control-plane guard internal error: $($_.Exception.Message)")
    exit 2
}
```

Implementation notes, one by one:

- `Set-StrictMode -Version Latest` is added so that an undefined variable like the original `$repositoryRoot` becomes a caught error instead of a silent `$null`.
- `.claude/maintenance-mode.flag` is REMOVED from the list, resolving defect D4, because the maintenance-mode mechanism was deliberately fully reverted and this entry made a reader believe an escape hatch existed. This also brings the project list into exact agreement with the managed guard's list, which already omits it.
- The `catch` is the fail-closed boundary.
- Every `Deny` path uses stderr, fixing D5.
- The repository root comes from `$PSScriptRoot`, fixing D1 and D6 and matching the pattern `handoff.md` line 386 records for seven sibling hooks.
- `[regex]::Escape` is applied before glob expansion so that the `.` in `CLAUDE.md` and `.mcp.json` is a literal dot rather than a regex wildcard — a latent over-match bug in BOTH the original hook and the managed guard, which build their patterns without escaping. This is flagged explicitly as a defect this rewrite fixes and which the managed guard still has.

## Section 6 — Appendix B, the recommended managed-guard change

**This file is READ-ONLY TO EVERY AGENT and requires the user, with administrator rights, outside Claude Code.**

Two changes are specified precisely, by line number:

- **B1.** DELETE lines 89-100, the entire `if ($toolName -eq 'Bash') { ... }` block, for the reasons in Q4. Required to actually fix the read-blocking.
- **B2. OPEN DECISION D3, do not apply without the user's answer.** Move the `Agent` branch (lines 51-64) to AFTER the `$inScope` check at line 66, so it stops applying to every repository on the machine. Both sides are presented: the current placement is deliberate per its own comment, but it is machine-wide and it contradicts this repository's own contract, which permits Planner a safe stable custom-subagent name for native continuation. Entry 3 of `docs/security-policy-log.md` records a prior blast-radius correction of exactly this kind, when `disableBypassPermissionsMode` and `disableAutoMode` were removed for being machine-wide — so there is direct precedent for treating machine-wide scope as a defect.

Follow-up, not a required change here: the managed guard shares the unescaped-`.` over-match issue described in Appendix A's implementation notes.

## Section 7 — Test harness changes

- KEEP the existing 6 Write/Edit cases and the 3 Bash read cases (which will now pass, since the hook exits 0 for any non-Write/Edit/NotebookEdit tool).
- CHANGE cases 12 and 13, the Bash write cases, from `"exit": 2` to `"exit": 0`, and add a `"note"` field on each recording that Bash is deliberately out of scope for this hook per this plan's Q4. This is a DISCLOSED REDUCTION IN COVERAGE, never a fix.
- ADD these cases: NotebookEdit via `notebook_path` → 2; `tool_input` present but no path key → 2; absolute path OUTSIDE the repository → 0; `.claude/../CLAUDE.md` traversal → 2; `.claude/settings.local.json` → 2; `.claude/scripts/statusline.ps1` → 2; `.claude/judge-policy.json` → 2; `docs/KNOWN-UNKNOWNS.md` → 0 (proves `docs/` is not over-matched); `CLAUDEXmd` → 0 (proves the `.` is escaped and not a wildcard); a `Read` tool call → 0 (proves non-matching tools pass through); malformed non-JSON stdin → 2 (proves fail-closed); empty stdin → 2 (proves fail-closed).
- MODIFY `tests/test-control-plane-write-hook.ps1` so at least one case runs with a WORKING DIRECTORY OTHER THAN the repository root, proving the `$PSScriptRoot` derivation is genuinely cwd-independent. The current script always passes `-Cwd $root` at line 38.
- The harness must also assert STDERR is non-empty on every expected-exit-2 case, which is what makes D5 a regression-tested defect rather than a one-time fix.

## Section 8 — Acceptance and validation

- Every case in the updated harness passes.
- `tests/validate.ps1` passes with no regression.
- The Step 7 fresh-session checks all hold.
- The Phase 0 friction is attributed to a named mechanism on evidence, or explicitly recorded as still-unknown.

## Section 9 — Risks and rollback

- **Fail-closed outage risk:** mitigated by Q3(i)-(iv); rollback is the user deleting the `hooks` block from `.claude/settings.json`, effective immediately via hot-reload (R13), falling back to the managed layer.
- **Reduced Bash coverage:** disclosed, accepted, with the residual stated in Q4(v).
- **Managed-guard edit risk:** administrator edit to a machine-wide file; rollback is restoring the deleted block from this plan's Appendix B, which quotes it in full.
- **Portability risk:** the managed layer does not exist on any other machine or fresh clone; the repaired project hook is the only protection there, and it is agent-writable in principle. Stated, not solved by this plan.
- **Stale-plan condition:** this plan becomes STALE and requires re-approval if the installed Claude Code version differs materially from the one recorded in Phase 0 step 1, if the managed settings file changes, or if the Phase 0 diagnostics contradict any hypothesis in Q2.

## Section 10 — Assumptions, unknowns, and open decisions

- ASSUMPTION: repository root is `H:\CommandCenter\orchestrator`; POSIX rule prefix `//h/CommandCenter/orchestrator`.
- ASSUMPTION: PowerShell's uncaught-exception exit code is 1, hence non-blocking per R1. To be CONFIRMED empirically in Phase 0 step 7, not assumed.
- UNVERIFIED U1: whether PreToolUse hooks still run under `bypassPermissions`. Inference only. Not a security boundary.
- UNVERIFIED U2: the installed Claude Code version, and therefore whether the R11 pre/post-v2.1.257 bypass behavior applies.
- UNVERIFIED U3: whether one hook exiting 2 short-circuits others running in parallel.
- UNKNOWN, stated as unknown: WHAT CHANGED RECENTLY to alter this hook's behavior. Not diagnosed. Not invented.
- STALE PRIOR EVIDENCE R14: the `auto` and `dontAsk` modes and the classifier post-date the 2026-07-25 evidence that the originating plan and `handoff.md` Section 4 rest on. Those documents are stale on permission modes.
- **DECISION D1 — for the user:** keep the repaired project hook (recommended) or delete it and rely on the managed layer alone.
- **DECISION D2 — for the user:** confirm that removing `.claude/maintenance-mode.flag` from the protected list is correct and that no maintenance-mode mechanism is being reintroduced. This plan's position is that this is dead configuration referencing a deliberately reverted mechanism, and that reviving maintenance mode is out of scope.
- **DECISION D3 — for the user:** whether to repo-scope the managed guard's `Agent` branch (Appendix B2).
- **APPROVAL:** explicit user approval required after the adversarial `fable` review and the cross-vendor judge, before any step runs.

## Browser UI dialog policy

Not applicable — no browser-rendered UI or webview.

## Browser UI validation

Not applicable — no browser-rendered UI or webview.

## Judge route

`PLAN_DUCK` required and BLOCKING. Risk: high. The user has additionally requested an adversarial review on the `fable` model BEFORE the cross-vendor judge. Both are recorded, in that order, as prerequisites to approval. Rubric focus: unearned confidence, the fail-closed/outage trade-off, the honesty of the Q2 causal analysis, and whether the reduction in claimed Bash coverage is honestly disclosed rather than hidden as a test fix.

## Downstream owner

`engineering-fleet` for Step 1 only. Every control-plane change is owned by the user.

## Team authorization

Not applicable.

## Engineering mode

Standard.

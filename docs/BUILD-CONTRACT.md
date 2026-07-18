# Build contract

`build` is an interactive routing contract, not a hidden batch pipeline. Its state machine is deliberately small:

`RECEIVED → CLASSIFIED → [PLANNED → PLAN_DUCK → USER_APPROVED] → ROUTED → T1_RUNNING → JOB_DONE → [CODE_REVIEW] → VERIFYING → [VERIFICATION_CHALLENGE] → [BROWSER_VALIDATING → VISUAL_REVIEW] → REPORTED | T2_RUNNING → JOB_DONE → [CODE_REVIEW] → VERIFYING → [VERIFICATION_CHALLENGE] → [BROWSER_VALIDATING → VISUAL_REVIEW] → REPORTED | JOB_BLOCKED`

The orchestrator owns classification, native team lifecycle, task state, human questions, and the final user-facing report. For non-basic work, Planner owns the read-only plan and Scribe owns its persisted artifact before engineering begins. `t1-engineer` is the Haiku first-line writer; `t2-engineer` is the Sonnet escalation writer; `t3-engineering-advisor` is an Opus read-only advisor; and `engineering-lead` is a Sonnet read-only technical coordinator. `verifier` independently validates every writer completion; `browser-validator` validates required rendered UI/webview journeys after verifier approval. `scribe` owns any standalone document resulting from the job. A job is not complete merely because a teammate stopped.

## Classification rules

Route to `t1-engineer` when the requested outcome is a changed or newly created technical artifact that an AI coding agent can implement and verify.

| User wording | Classification | Reason |
| --- | --- | --- |
| “Build a CSV import API and test malformed files.” | Engineering | Creates/changes a service and names verification. |
| “Let’s make an app for household inventory.” | Engineering | Requests a software product. |
| “Design a frontend for the billing dashboard.” | Engineering | Requests a technical UI artifact. |
| “Fix the timeout after token refresh.” | Engineering | Requests a software behavior change. |
| “Summarize the billing design.” | Non-engineering | Produces analysis, not an implementation. |
| “Compare React and Vue for this team.” | Non-engineering | Produces advice; do not assume a code change. |
| “We need something for inventory.” | Ambiguous | Ask whether the user wants a software artifact, a plan, or advice. |

If the user explicitly invokes `/build`, treat the supplied request as engineering unless it is impossible or unsafe to implement.

## ENGINEERING_JOB envelope

Pass this envelope in the orchestrator's delegation prompt. Keep it concise and include only grounded information.

```text
ENGINEERING_JOB
request: <verbatim user intent>
target: <absolute project directory or explicit worktree path>
outcome: <observable result>
scope: <included behavior/files if known>
non_goals: <what this job must not do>
references: <@files, URLs, designs, errors, existing patterns>
research_context: <optional RESEARCH_EVIDENCE packet or source references sent directly by Researcher; advisory only; explicit user requirements prevail>
approved_plan: <required exact docs/plans/<slug>.md for every non-basic job; user-approved and not stale | not applicable for a basic job>
constraints: <stack, compatibility, security, performance, no-touch boundaries>
acceptance_checks: <specific tests/build/typecheck/visual checks and expected result>
browser_ui_dialog_policy: required for browser-rendered UI or webview work — prohibit native alert/confirm/prompt/window variants/beforeunload; require app-owned modal or inline validation, keyboard/focus behavior, and no-native-dialog scan
browser_ui_validation: required for browser-rendered UI or webview work — launch/readiness command; base URL; fixture/reset procedure; user journeys; viewport profiles; visible acceptance outcomes; existing browser/Playwright command if available | not applicable for non-UI work
design_handoff: <reviewed DESIGN_HANDOFF path/reference for UI work | not applicable>
judge_route: <eligible checkpoints, requiredness, risk, rubric IDs, call cap | skipped with reason>
judge_findings: <unresolved finding IDs and required evidence | none>
tdd: required — test first, RED → GREEN → REFACTOR
task_profile: auto | feature | debug | performance | refactor | UI | integration | prototype
quality_review: required — correctness, security, maintainability, performance, compatibility, tests, docs/operator, UI if applicable
documentation_handoff: required when README, operator, API, release, or other standalone documentation changes are needed; T1 returns verified facts for the subsequent Scribe job
risk: low | medium | high
engineering_mode: auto | standard | t2-escalation | extreme-advisory-team
assignment_kind: initial | escalation-remediation | full-build-continuation
writer_ownership: t1 | t2
prior_work_evidence: <required for escalation-remediation/full-build-continuation: status/diff, retained work, TDD/test evidence, prior gate packets, and scope fingerprint>
commit_authority: no | yes, with requested message/branch
assumptions: <only assumptions safe enough to proceed>
END_ENGINEERING_JOB
```

`engineering_mode: auto` starts T1 unless Engineering Lead's grounded `ENGINEERING_ROUTE` selects an explicitly approved extreme advisory team. A plan can authorize extreme mode only for three or more materially coupled subsystems, or broad cross-layer work combined with a migration, security-critical boundary, or external contract, or a job that cannot be safely validated by one writer. T3 is never a writer or completion gate.

For a basic clear fix, `scope`, `references`, and `acceptance_checks` may be brief and `approved_plan` is `not applicable`. Every non-basic job requires a user-approved Scribe-authored plan under `docs/plans/` as defined by `PLAN-CONTRACT.md`. Every implementation job is TDD: the engineer writes/runs the narrowest test before production code, demonstrates RED for a behavior change, makes it GREEN, then runs broader verification. T1 selects the task profile when `auto`, loads the minimum relevant internal playbooks, and completes the required full quality review before `JOB_DONE`. For a browser-rendered UI or webview, `t1-ui-wiring-verification` and `browser_ui_dialog_policy` are mandatory even if the primary profile is not `UI`.

When a `research_context` is present, it is a completed `RESEARCH_EVIDENCE` packet as defined by `docs/RESEARCH-CONTRACT.md`. In a team, Researcher sends it directly to T1. It is evidence for implementation, not a replacement for the user's request or an authorization to add scope. The orchestrator must resolve any conflict between research and explicit user requirements before the T1 handoff.

## Handoff acceptance gate

The orchestrator may report `JOB_DONE` only after the engineer provides all of:

1. Outcome stated in observable terms.
2. Changed file paths with purposes.
3. Exact verification command(s) and result(s), or an explicit reason verification could not run.
4. TDD evidence: test file, RED result before production code, GREEN result after it; for a pure refactor, characterization-test baseline and post-change result.
5. Intentional behavior changes and remaining risks/limits.
6. A commit hash only when a commit was authorized and made.
7. Task profile/skill evidence and the full quality-review result, with every lens evidenced or marked `not applicable`.
8. `DOCUMENTATION_HANDOFF` when standalone documentation is required. The orchestrator dispatches the subsequent Scribe job with those verified facts.
9. For browser UI work, modal/inline-feedback behavior, keyboard/focus evidence, and the exact no-native-dialog scan command/result.
10. For a non-basic job, approved-plan path plus a current-state check; material drift requires `JOB_BLOCKED` with `Plan stale`.
11. Disposition and evidence for every inherited judge finding ID.
12. Applicable `CODE_REVIEW` policy action resolved before independent verification.
13. `VERIFICATION_PASS` from an independent `VERIFICATION_JOB`; T1's own report and a judge pass never satisfy this gate.
14. Applicable `VERIFICATION_CHALLENGE` resolved before browser validation.
15. For `browser_ui_validation: required`, `BROWSER_PASS` from `BROWSER_VALIDATION_JOB` and applicable Studio/high-value `VISUAL_REVIEW`; for other work, an explicit `BROWSER_NOT_APPLICABLE` receipt.

Missing TDD or verification evidence causes a return to `T1_RUNNING`; it is not a successful terminal state. If no usable test harness can be established before implementation, the job is `JOB_BLOCKED` with evidence and the smallest user decision that can unblock it.

## Independent completion gates

After a structurally complete `JOB_DONE`, the orchestrator sends this read-only packet to `verifier`:

```text
VERIFICATION_JOB
task_id: <shared task id>
target: <repository root or worktree>
request_and_outcome: <approved intent and observable result>
approved_plan: <path or not applicable>
t1_job_done: <complete T1 terminal report>
judge_findings: <CODE_REVIEW finding IDs/evidence/disposition or none>
acceptance_checks: <exact required checks>
browser_ui_validation: <required details or not applicable>
remediation_cycle: 0 | 1 | 2
END_VERIFICATION_JOB
```

`verifier` returns `VERIFICATION_PASS`, `VERIFICATION_NEEDS_FIX`, or `VERIFICATION_BLOCKED`. A counted remediation is only a writer cycle that returns `JOB_DONE` and then receives `VERIFICATION_NEEDS_FIX` or `BROWSER_NEEDS_FIX`. The lead returns the first two counted failures to T1. A material scope/acceptance change is `Plan stale`; research, credentials, unsafe commands, and unavailable prerequisites are blockers and never count.

After T1's second counted failure, the lead creates this packet and dispatches T2 as the sole writer:

```text
ENGINEERING_ESCALATION_PACKET
task_id: <shared task id>
from: t1-engineer | t2-engineer
to: t2-engineer
approved_plan: <path or not applicable>
writer_ownership: t1 released | t2 assigned
remediation_cycles: 0 | 1 | 2
current_status_and_diff: <exact status and changed paths>
tdd_and_test_evidence: <RED/GREEN/focused/broader evidence>
failed_gate_packets: <complete verifier/browser packets>
scope_and_non_goals: <approved boundaries>
END_ENGINEERING_ESCALATION_PACKET
```

T2 follows the same handoff and completion gates and receives at most two counted remediations. A third failed gate is `JOB_BLOCKED` for user review/replanning; T3 advice cannot waive the limit.

## T2 scope re-dispatch

If T2 determines before submitting `JOB_DONE` that a rejected gate requires material unbuilt work already in the approved plan rather than a bounded correction, it returns:

```text
RESCOPE_REQUIRED
task_id: <shared task id>
reason: remediation_scope_exceeded
approved_plan: <current path>
remaining_approved_scope: <specific plan work still required>
retained_work: <valid behavior/paths preserved>
failed_gate_evidence: <complete relevant gate packets>
plan_and_acceptance_unchanged: yes
current_status_and_diff: <exact status and changed paths>
scope_fingerprint: <stable normalized remaining-scope identifier>
END_RESCOPE_REQUIRED
```

The Orchestrator verifies the plan is current and the remaining scope/acceptance checks remain approved. For the first occurrence of a fingerprint in one approved-plan revision, it reissues a direct T2 `ENGINEERING_JOB` with `assignment_kind: full-build-continuation`, `writer_ownership: t2`, the exact remaining scope, and all prior-work evidence. The reissue is a full-build assignment, not an escalation-remediation attempt, and the signal does not consume a T2 remediation cycle.

The Orchestrator asks Engineering Lead for a route only when the remaining work meets the existing extreme criteria. It starts extreme advisory only if the approved plan explicitly authorizes it; otherwise T2 continues as the sole writer. A repeated fingerprint, stale plan, changed acceptance checks, or missing prerequisite is `JOB_BLOCKED` for replanning/user review. T2 then follows the ordinary TDD and completion gates; only completed `JOB_DONE` cycles rejected by an independent gate count toward T2's two-remediation cap.

## Extreme advisory team

An extreme team is an explicitly plan-approved, task-scoped in-process team of Engineering Lead, T1, and T3 under the Orchestrator in a separately enabled team session. T1 is its only writer. T3 can send `T2_ESCALATION_RECOMMENDATION` to Engineering Lead and the Orchestrator, but cannot order a writer handoff. Engineering Lead may request a `WRITER_RELEASED` receipt from T1. The Orchestrator can spawn T2 only after receiving that receipt; idle state, a task-list update, or a shutdown request is not sufficient proof. If T1 cannot release safely, the job is blocked rather than run with overlapping writers.

Team write ownership is a documented coordination protocol, not a source-file lock. Future swarm work requires explicit opt-in and predeclared non-overlapping paths. If agent-team transport/provider support is unavailable, run Engineering Lead and T3 at the same named serial checkpoints and report `team_mode: serial-advisory-fallback`.

Only after `VERIFICATION_PASS`, the orchestrator sends a UI job to `browser-validator`:

```text
BROWSER_VALIDATION_JOB
task_id: <shared task id>
target: <repository root or worktree>
approved_plan: <path or not applicable>
verification_pass: <packet/reference>
judge_findings: <prior unresolved IDs and verification-challenge requests or none>
design_handoff: <reviewed handoff/browser rubric or not applicable>
target_surface: browser-web-ui | tauri-webview2-desktop
launch_and_readiness: <command and success signal>
base_url: <local test URL>
expected_app_identity: <expected app URL prefix/pattern and/or expected window-title pattern; required for tauri-webview2-desktop>
fixture_and_reset: <deterministic state procedure>
journeys: <visible user steps and expected outcomes>
viewport_profiles: <fixed desktop/mobile profiles>
browser_ui_dialog_policy: <required details>
playwright_setup_authorized: no | yes
tauri_driver_setup_authorized: no | yes
remediation_cycle: 0 | 1 | 2
END_BROWSER_VALIDATION_JOB
```

Cross-vendor packets use `docs/JUDGE-CONTRACT.md`. The Orchestrator runs `PLAN_DUCK` after Scribe and before approval, `CODE_REVIEW` after every structurally complete `JOB_DONE` when eligible, `VERIFICATION_CHALLENGE` after a verifier pass only when coverage risk remains, and `VISUAL_REVIEW` after browser evidence only for eligible UI. Standard work has at most two calls; high-risk/Studio has at most four. Judge-driven remediation is capped at one loop and does not replace the two deterministic remediation limits.

Browser validation is screenshot/interaction-first: DOM, accessibility trees, and console logs are diagnostics but cannot prove success. Every `BROWSER_VALIDATION_JOB` carries a mandatory, never-inferred `target_surface: browser-web-ui | tauri-webview2-desktop`; a missing or unrecognized value is `BROWSER_BLOCKED reason: target_surface_invalid`, and a value that contradicts the job's own launch/readiness commands is `BROWSER_BLOCKED reason: target_surface_mismatch`. Exactly one backend applies per job, selected deterministically from `target_surface`.

For `target_surface: browser-web-ui`, prefer connected Claude in Chrome; then use existing target Playwright. If no backend exists, `BROWSER_BLOCKED reason: playwright_missing` causes one orchestrator-owned approval prompt. Only after explicit approval does Browser Validator run `npx --yes playwright@1.61.0 install chromium`; it writes only npm/Playwright user caches and never target dependencies, locks, source, snapshots, or baselines. Re-dispatch the same job after install; decline or install failure remains blocked.

For `target_surface: tauri-webview2-desktop` (a native Tauri/WebView2 window, not reachable via Chrome or Playwright), the applicable backend is the pinned `tauri-driver` setup. If it or a matching `msedgedriver` is absent and `tauri_driver_setup_authorized: no`, `BROWSER_BLOCKED reason: tauri_driver_missing` causes one orchestrator-owned approval prompt. Only after explicit approval with `tauri_driver_setup_authorized: yes` does Browser Validator run exactly `cargo install tauri-driver --version 2.0.6` and resolve a matching `msedgedriver` against the host's authoritative WebView2 Runtime version; setup writes only to the Cargo bin/tooling cache, never target dependencies, locks, or source. Re-dispatch the same job after install; decline or install failure (`tauri_driver_install_failed`) remains blocked and is never retried autonomously. Every `tauri-driver` session requires the `alwaysMatch` capability shape and a target-bound post-session identity check (never a bare non-blank check); an unverified session is `BROWSER_BLOCKED reason: tauri_session_unverified`, an uncertain process/port provenance is `BROWSER_BLOCKED reason: tauri_process_provenance_uncertain`, and an unresolved WebView2 Runtime/driver match is `BROWSER_BLOCKED reason: webview2_runtime_unresolved`.

If T1 returns `JOB_BLOCKED` with `Research needed`, the orchestrator sends that precise question through the normal Researcher intake route. T1 does not receive web tools and may resume only after Researcher directly provides the resulting advisory `RESEARCH_EVIDENCE` packet.

## Isolation and escalation

- Default to the current interactive project directory.
- Use a native worktree only for explicitly requested isolation, concurrent edits, a clean branch, or a risky experiment. The user can start `claude --worktree <name>` interactively, or the orchestrator can use `EnterWorktree` in the active session.
- Use a plain `t1-engineer` subagent only for a basic isolated code job. For every non-basic job, dispatch one foreground `planner`; it invokes nested Researcher only when needed and nested Scribe only after `PLANNING_HANDOFF` is complete. The lead waits for `PLAN_READY` or `PLAN_BLOCKED`; an idle, partial, or nonterminal stop is a protocol blocker, never a polling/retry signal. Resume the original Planner through `SendMessage` only after a material user answer, Studio selection, one design revision, or one judge remediation. Dispatch Scribe after verified `DOCUMENTATION_HANDOFF`; do not create a serial engineering/Scribe team. Reusable routing is implemented through Skills and custom agent definitions, not an undocumented project JavaScript workflow runtime.
- Do not turn uncertainty into silent architecture. Ask the user when target, destructive scope, credentials, legal/security requirements, or acceptance criteria change the implementation materially.

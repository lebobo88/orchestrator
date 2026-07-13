# Build contract

`build` is an interactive routing contract, not a hidden batch pipeline. Its state machine is deliberately small:

`RECEIVED → CLASSIFIED → BRIEFED → T1_RUNNING → JOB_DONE | JOB_BLOCKED → REPORTED`

The orchestrator owns classification, the job brief, human questions, and the final user-facing report. `t1-engineer` owns a single bounded implementation job and its evidence. A job is not complete merely because the subagent stopped.

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
research_context: <optional RESEARCH_BRIEF from researcher; advisory only; explicit user requirements prevail>
constraints: <stack, compatibility, security, performance, no-touch boundaries>
acceptance_checks: <specific tests/build/typecheck/visual checks and expected result>
tdd: required — test first, RED → GREEN → REFACTOR
risk: low | medium | high
commit_authority: no | yes, with requested message/branch
assumptions: <only assumptions safe enough to proceed>
END_ENGINEERING_JOB
```

For a small clear fix, `scope`, `references`, and `acceptance_checks` may be brief. Every implementation job is TDD: the engineer writes/runs the narrowest test before production code, demonstrates RED for a behavior change, makes it GREEN, then runs broader verification. For an unfamiliar, cross-file, security-sensitive, data-changing, or UI request, give the engineer enough context to explore first and to choose the appropriate verification.

When a `research_context` is present, it must be a completed `RESEARCH_BRIEF` as defined by `docs/RESEARCH-CONTRACT.md`. It is evidence for implementation, not a replacement for the user's request or an authorization to add scope. The orchestrator must resolve any conflict between research and explicit user requirements before the T1 handoff.

## Handoff acceptance gate

The orchestrator may report `JOB_DONE` only after the engineer provides all of:

1. Outcome stated in observable terms.
2. Changed file paths with purposes.
3. Exact verification command(s) and result(s), or an explicit reason verification could not run.
4. TDD evidence: test file, RED result before production code, GREEN result after it; for a pure refactor, characterization-test baseline and post-change result.
5. Intentional behavior changes and remaining risks/limits.
6. A commit hash only when a commit was authorized and made.

Missing TDD or verification evidence causes a return to `T1_RUNNING`; it is not a successful terminal state. If no usable test harness can be established before implementation, the job is `JOB_BLOCKED` with evidence and the smallest user decision that can unblock it.

## Isolation and escalation

- Default to the current interactive project directory.
- Use a native worktree only for explicitly requested isolation, concurrent edits, a clean branch, or a risky experiment. The user can start `claude --worktree <name>` interactively, or the orchestrator can use `EnterWorktree` in the active session.
- Use a plain subagent for this one bounded job. A team requires explicit approval and a real need for peer-to-peer coordination; a dynamic workflow requires an explicitly requested reusable multi-stage pipeline.
- Do not turn uncertainty into silent architecture. Ask the user when target, destructive scope, credentials, legal/security requirements, or acceptance criteria change the implementation materially.

---
name: build
description: Default engineering workflow. Use for requests to build, make, create, design, implement, fix, refactor, test, integrate, or automate a technical artifact, including phrases such as "let's make an app" and "design a frontend". Classify the request, create one bounded interactive T1 engineering job, and return its completion report to the orchestrator.
when_to_use: Use proactively whenever the incoming user request is an engineering request; users can also force it with /build.
argument-hint: "<engineering request>"
---

# Build workflow

This is the default workflow for engineering requests. It is intentionally not a Claude Code Dynamic Workflow: it runs in the interactive orchestrator session, preserves human approval, and dispatches exactly one T1 engineer unless the user explicitly requests a different operating mode.

1. Classify the current request as engineering using `docs/BUILD-CONTRACT.md`. If it is not engineering, say so and return to the orchestrator; do not dispatch `t1-engineer`.
2. Create an `ENGINEERING_JOB` envelope: outcome, target directory, scope, non-goals, references, constraints, acceptance checks, risk level, and commit authority. Reuse the user's words; do not add product scope.
3. If a missing answer materially changes implementation, ask one concise question. Otherwise state a safe bounded assumption in the envelope.
4. Delegate one foreground job to `t1-engineer`. Include the complete envelope and require its `JOB_DONE` / `JOB_BLOCKED` report.
5. Do not start an agent team, a dynamic workflow, a worktree, or an SDK program by default. These are explicit alternatives, not hidden implementation details.
6. On `JOB_DONE`, check that the report includes changed paths and verification evidence. If either is absent, request completion evidence rather than declaring success. Summarize the evidence to the user. On `JOB_BLOCKED`, surface the smallest question or approval needed.

For `/build $ARGUMENTS`, treat `$ARGUMENTS` as the request. When auto-invoked, use the current user request.

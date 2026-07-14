---
name: build
description: Default engineering workflow. Use for requests to build, make, create, design, implement, fix, refactor, test, integrate, or automate a technical artifact, including phrases such as "let's make an app" and "design a frontend". Classify the request, create one bounded interactive T1 engineering job, and return its completion report to the orchestrator.
when_to_use: Use proactively whenever the incoming user request is an engineering request; users can also force it with /build.
argument-hint: "<engineering request>"
---

# Build workflow

This is the default workflow for engineering requests. It is intentionally not a Claude Code Dynamic Workflow: it runs in the interactive orchestrator session, preserves human approval, and dispatches exactly one T1 engineer unless the user explicitly requests a different operating mode.

1. Classify the current request as engineering using `docs/BUILD-CONTRACT.md` and `docs/PLAN-CONTRACT.md`. If it is not engineering, say so and return to the orchestrator; do not dispatch `t1-engineer`.
2. If the request is non-basic, start an in-process Planner/Scribe team and send Planner `PLAN_JOB`. Planner obtains material research directly from Researcher, then sends `PLANNING_HANDOFF` directly to Scribe. If team creation is unavailable or emits a tmux, WSL, or split-pane error, do not retry or request a multiplexer: run Planner, Researcher when needed, and Scribe sequentially through the bounded packet fallback. Wait for Scribe's draft, obtain explicit user approval, and pass the approved plan path to T1. Do not use research to add product scope or override explicit user requirements.
3. For a basic request only, create an `ENGINEERING_JOB` envelope directly. For every planned job, include `approved_plan`, preserve the plan's outcome, scope, non-goals, references, constraints, and acceptance checks, and include `research_context` only when completed advisory evidence is material to implementation.
4. If a missing answer materially changes implementation, ask one concise question. Otherwise state a safe bounded assumption in the envelope.
5. Delegate one foreground job to `t1-engineer`. Include the complete envelope and require its `JOB_DONE` / `JOB_BLOCKED` report. If the job needs a README or other standalone document, create a temporary T1/Scribe team with separate file ownership; T1 sends its verified `DOCUMENTATION_HANDOFF` directly to Scribe.
6. Do not start a persistent team, a dynamic workflow, a worktree, or an SDK program by default. Planner teams are task-scoped plan-first collaboration, not a persistent swarm.
7. On `JOB_DONE`, check that the report includes changed paths, TDD evidence, verification, quality-review evidence, stale-plan status, and a documentation handoff when documentation is needed. Retain only the compact receipt for a team document stage. On `JOB_BLOCKED` with `Research needed`, route the request through Researcher; on `Plan stale`, create a new plan or obtain explicit reapproval.

For `/build $ARGUMENTS`, treat `$ARGUMENTS` as the request. When auto-invoked, use the current user request.

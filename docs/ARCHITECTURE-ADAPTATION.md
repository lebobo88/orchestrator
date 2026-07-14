# Architecture adaptation

The enterprise orchestration research supplied with this project informs the *foundation* here, not the deployed architecture. This implementation deliberately uses Claude Code's native interactive primitives instead of adding a separate graph engine, database, message bus, or external control plane.

## Adopted foundations

- **Explicit state:** the plan-first and build state machines are documented in `PLAN-CONTRACT.md` and `BUILD-CONTRACT.md`; a terminal result must be evidenced completion or a specific decision needed.
- **Typed authority boundaries:** the orchestrator routes, asks users, records task state, and reports; Planner develops read-only plans; T1 implements and verifies code; Researcher gathers evidence; Scribe authors non-code documents.
- **Structured handoff:** `PLAN_JOB`, `PLANNING_RESEARCH_REQUEST`, `PLANNING_HANDOFF`, `ENGINEERING_JOB`, `DOCUMENT_JOB`, `RESEARCH_EVIDENCE`, `DOCUMENTATION_HANDOFF`, and compact `TASK_RECEIPT` packets prevent ambiguous delegation and unsupported completion claims.
- **Human control:** material ambiguity, credentials, scope expansion, destructive actions, teams, external integrations, and durable automation are opt-in decisions.
- **Verification and observability:** acceptance checks and command results are carried through the handoff instead of relying on a model self-assessment.
- **Context hygiene:** temporary in-process Planner/Scribe teams let Planner, Researcher, and Scribe exchange full planning evidence directly while the lead retains only a bounded receipt. If peer messaging is unavailable, sequential bounded packets preserve the same approval and evidence boundaries. Durable approved plans stay in repository files.

## Intentionally not adopted

- No autonomous enterprise state store, vector memory, cross-session message bus, or background coordinator.
- No persistent multi-agent swarm, dynamic workflow, plugin, MCP server, scheduled task, or Channel. Temporary teams are limited to plan-first and cross-agent document handoffs with non-overlapping file ownership.
- No external `claude -p` process. A future approved programmatic controller must use the Claude Agent SDK's session/streaming and user-input mechanisms.

This keeps the system native to Claude Code while leaving its documented advanced primitives available when a concrete user request justifies them.

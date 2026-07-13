# Architecture adaptation

The enterprise orchestration research supplied with this project informs the *foundation* here, not the deployed architecture. This implementation deliberately uses Claude Code's native interactive primitives instead of adding a separate graph engine, database, message bus, or external control plane.

## Adopted foundations

- **Explicit state:** the small build state machine is documented in `BUILD-CONTRACT.md`; a terminal result must be `JOB_DONE` with evidence or `JOB_BLOCKED` with a decision needed.
- **Typed authority boundaries:** the orchestrator routes and reports; `t1-engineer` implements and verifies one bounded job.
- **Structured handoff:** `ENGINEERING_JOB` and the required return report prevent ambiguous delegation and unsupported completion claims.
- **Human control:** material ambiguity, credentials, scope expansion, destructive actions, teams, external integrations, and durable automation are opt-in decisions.
- **Verification and observability:** acceptance checks and command results are carried through the handoff instead of relying on a model self-assessment.
- **Context hygiene:** fresh subagent context is used for a bounded implementation; durable project guidance stays in repository files.

## Intentionally not adopted

- No autonomous enterprise state store, vector memory, cross-session message bus, or background coordinator.
- No default multi-agent fan-out, dynamic workflow, plugin, MCP server, scheduled task, or Channel.
- No external `claude -p` process. A future approved programmatic controller must use the Claude Agent SDK's session/streaming and user-input mechanisms.

This keeps the system native to Claude Code while leaving its documented advanced primitives available when a concrete user request justifies them.

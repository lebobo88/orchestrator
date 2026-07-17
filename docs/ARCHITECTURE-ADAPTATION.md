# Architecture adaptation

The enterprise orchestration research supplied with this project informs the *foundation* here, not the deployed architecture. This implementation deliberately uses Claude Code's native interactive primitives instead of adding a separate graph engine, database, message bus, or external control plane.

## Adopted foundations

- **Explicit state:** the plan-first and build state machines are documented in `PLAN-CONTRACT.md` and `BUILD-CONTRACT.md`; a terminal result must be evidenced completion or a specific decision needed.
- **Typed authority boundaries:** the orchestrator reports to users; Planner develops read-only plans; T1 is the first-line writer; T2 is the evidence-backed escalation writer; T3 is read-only implementation guidance; Engineering Lead coordinates technical route decisions without lifecycle authority; Verifier independently checks writers; Browser Validator independently checks rendered UI journeys; Researcher gathers evidence; Scribe authors non-code documents. Agent teams are an explicit exceptional session mode, not the normal transport.
- **Structured handoff:** `PLAN_JOB`, `PLANNING_RESEARCH_REQUEST`, `PLANNING_HANDOFF`, `ENGINEERING_JOB`, `VERIFICATION_JOB`, `BROWSER_VALIDATION_JOB`, `DOCUMENT_JOB`, `RESEARCH_EVIDENCE`, `DOCUMENTATION_HANDOFF`, and compact terminal statuses prevent ambiguous delegation and unsupported completion claims.
- **Human control:** material ambiguity, credentials, scope expansion, destructive actions, teams, external integrations, and durable automation are opt-in decisions.
- **Verification and observability:** acceptance checks and command results are carried through the handoff and independently re-observed by Verifier; screenshot-first Browser Validator evidence covers required UI/webview journeys instead of relying on model self-assessment.
- **Context hygiene:** the foreground Planner owns a nested Researcher/Scribe chain, so full planning evidence stays below the lead while the lead retains only terminal plan status. Extreme advisory teams keep T3 guidance direct and compact while only one implementation writer is active. Durable approved plans stay in repository files.

## Intentionally not adopted

- No autonomous enterprise state store, vector memory, cross-session message bus, or background coordinator.
- No persistent multi-agent swarm, project JavaScript workflow runtime, plugin, MCP server, scheduled task, or Channel. Verifier and Browser Validator are serial foreground subagents, not a team or a new control plane. Future best-of-3 and swarm patterns are documented extensions, not activated modes; any team has task-scoped lifecycle and non-overlapping file ownership.
- No external `claude -p` process. A future approved programmatic controller must use the Claude Agent SDK's session/streaming and user-input mechanisms.

This keeps the system native to Claude Code while leaving its documented advanced primitives available when a concrete user request justifies them.

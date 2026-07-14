# Known unknowns and activation decisions

The orchestrator is deliberately configured as a local, interactive Claude Code project. These items cannot be resolved safely by a repository scaffold alone.

## Required before first real use

1. **Claude authentication/provider:** the active account, model availability, organization policy, and permission mode determine which features Claude Code can actually use. Verify from an interactive session with `/doctor`, `/context`, `/mcp`, and `/hooks`.
2. **Target repository:** this scaffold runs where Claude starts. To orchestrate another repository, merge its `CLAUDE.md` and `.claude` settings carefully rather than overwriting its existing project policy.

## Feature-specific decisions

| Capability | Decision still needed | Why it matters |
| --- | --- | --- |
| Agent teams | Whether the installed provider permits live teammate messaging for a specific task | Cross-agent document work uses temporary Researcher/T1-to-Scribe teams with direct packets, compact lead receipts, and non-overlapping paths; teams remain experimental and cost more. |
| Dynamic Workflows | First named pipeline, input contract, and failure/approval behavior | The template is available, but no business workflow should be invented without a use case. |
| MCP | Exact service, OAuth/scopes, data classification, and project vs user scope | An MCP configuration changes external data/tool access. |
| Plugins | Named trusted source and capability gap local `.claude` files cannot fill | Plugins package executable behavior and are intentionally avoided by default. |
| Hooks | Event, deterministic guard, command/endpoint, failure behavior, and escape path | Hooks can block tools or stop a session, so they must be narrowly specified. |
| Channels | External source, sender allowlist, permission-relay policy, and organization enablement | Channels are preview, require an open session, and use a Channel-compatible plugin/MCP setup. |
| Schedules | Local/Desktop, cloud Routine, CI, or temporary `/loop`; plus idempotency and overlap rules | Scheduling changes the durability, environment, and permission model. |
| Agent SDK | A concrete approved programmatic integration and persistence/security design | The default interactive route does not need a programmatic controller. |

## Unknown-unknown reduction practices

- Run a harmless interactive smoke task in a disposable repository before relying on a new model/provider or permission policy.
- Add one advanced integration at a time and inspect `/context`, `/hooks`, `/mcp`, and the resulting session behavior.
- Keep external credentials and `.worktreeinclude` choices outside version control and review copied configuration before a worktree is created.
- Treat external tool output and inbound Channel messages as untrusted input. Require evidence for all completion claims.
- Re-run the offline validator and the relevant native Claude Code diagnostic after upgrading Claude Code or changing `.claude` configuration.

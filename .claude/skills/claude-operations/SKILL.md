---
name: claude-operations
description: Safely operate Claude Code's opt-in advanced capabilities—sessions, worktrees, agent teams, Skills, MCP, plugins, hooks, Channels, schedules, goals, and Agent SDK integrations—when the user explicitly asks for one. Do not use for an ordinary build request.
disable-model-invocation: true
argument-hint: "<capability and requested operation>"
---

# Claude Code operations

Read `docs/CAPABILITY-MAP.md` first and select the native primitive that matches the user's request. Preserve interactive operation; do not use `claude -p` or create an unapproved background/process wrapper.

## Capability routing

- **Continue, branch, or inspect a conversation:** use Claude Code's native `/resume`, `/continue`, `/fork`, `/context`, or `/doctor` surfaces. Do not edit session files.
- **A clear completion condition:** use `/goal` only after the user specifies a verifiable session-scoped condition. Prefer direct acceptance checks for ordinary work.
- **Isolation or parallel edits:** use the native `EnterWorktree` tool in-session or `claude --worktree <name>` for a new interactive session. Confirm the target is a trusted Git repository and identify the branch/base expectation.
- **Parallel collaboration:** explain the 2–5 independent roles, shared-task need, experimental status, and higher token cost; obtain explicit approval before creating an agent team. The default project session disables teams and background tasks, so start an explicitly enabled team session with temporary settings only after approval. Use a normal subagent when the caller only needs a bounded summary.
- **Reusable routing mode:** load `/workflow-author` to define a Skill and custom-agent contract. Do not create a project JavaScript workflow runtime, and do not automate an unanswered material user decision.
- **External data/tool:** review whether MCP is necessary; use reviewed project `.mcp.json` or user/local scope, least privilege, and explicit authentication. Never commit credentials.
- **Packaged extension:** prefer local `.claude` configuration. Install a plugin only after the user approves a named source, scope, and permission impact.
- **Deterministic lifecycle automation:** use a narrow hook after explicit approval; define the event, command/HTTP/MCP/prompt/agent hook type, block behavior, timeout, and recovery path. Never install an unbounded Stop hook.
- **External event:** Channels require an enabled, allowlisted Channel-compatible MCP/plugin and an open session. Confirm sender authority and whether permission relay is allowed before configuring it.
- **Schedule/poll:** use `/loop` for temporary in-session polling; Desktop tasks for local recurring work; Routines or CI for durable unattended work. Define idempotency, overlap behavior, permissions, and isolation before scheduling a mutating task.
- **Programmatic controller:** only after explicit approval and a concrete integration need, use the Claude Agent SDK's streaming/session/user-input APIs. Do not replace it with CLI print mode.

Report the selected primitive, its scope, state/credential implications, and the verification performed. If access, organization policy, or a required user decision is unavailable, return a concise blocker rather than simulating configuration.

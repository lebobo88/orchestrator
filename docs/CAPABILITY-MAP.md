# Claude Code capability map

This is an operating map, not a mandate to turn every request into a multi-agent system. The orchestrator defaults to one interactive lead and one foreground T1 or Scribe worker.

## Native session control

- Start here with `claude`; `.claude/settings.json` makes `orchestrator` the default main agent for this project. Use `claude --agent orchestrator` to make the selection explicit.
- Use `/resume` to select a saved conversation, `claude --continue` for the latest session, and `/fork` when an alternate approach needs separate history. Session transcripts and state are Claude Code-managed; do not edit them as an orchestration database.
- Use `/goal` only for a precise session-scoped completion condition. It is a prompt-based stop condition, not durable job scheduling.
- Context is a constrained resource. Use narrow delegation briefs, files by reference, focused verification output, and durable repository docs. Start or fork a fresh session when an old thread becomes mostly irrelevant.

## Delegation and isolation

| Need | Native choice | Orchestrator policy |
| --- | --- | --- |
| One bounded implementation task | `t1-engineer` subagent | Default code route; foreground and interactive. |
| One standalone non-code document | `scribe` subagent | Default document route; Scribe is the sole document author. |
| Specialist evidence needed by Scribe | Temporary agent team | Direct Researcher/T1-to-Scribe packet, shared dependency, and compact lead receipt only. |
| Separate files/branches for parallel work | `EnterWorktree` or `claude --worktree <name>` | Explicit isolation only; worktrees branch from local `HEAD` in this project. |
| Reusable fixed multi-stage pipeline | Dynamic Workflow | Create only through `/workflow-author`; not the build default. |
| Many separate sessions to monitor | `claude agents` / Agent view | User-operated, not silently created by the orchestrator. |

Agent teams require Claude Code v2.1.32+. They should have 2–5 independent roles with a clear shared-task benefit. They have a shared task list and mailbox; normal subagents instead return only to the caller. Use them only for cross-agent document work, end them after the task, and partition writable paths because teams do not replace worktrees.

For worktrees, run `claude` once in the repository to accept workspace trust, then use `claude --worktree <name>`. Put `.claude/worktrees/` in the target repository's `.gitignore`. A `.worktreeinclude` file can copy gitignored local configuration that the worktree genuinely needs; never use it to casually distribute secrets.

## MCP and plugins

No MCP server or plugin is bundled. Add MCP only for a named external system and with least privilege:

1. Prefer a project-scoped `.mcp.json` for reviewed, shareable configuration; use user/local scope for personal or secret-bearing configuration.
2. Review tool names, server identity, OAuth scopes, output size, and data access before approval. Keep tokens out of version control and use environment variables where appropriate.
3. Use `/mcp` to inspect and authenticate. Remove or reset a server when it is no longer needed.

Plugins can package skills, agents, hooks, and MCP. They are a last resort here: use local `.claude` files first. Install a plugin only after the user names the source/capability and approves the trust and permission impact.

## Hooks, events, and schedules

- Hooks are deterministic lifecycle automation. Start with a narrow `PostToolUse` formatter or a test/lint check; use `PreToolUse`/`Stop` gates only with a bounded escape path. A Stop hook can be overridden after repeated blocks, so it is not a durable control plane. Researcher has a read-only inspection allowlist; Scribe has a scoped text-document write guard.
- Channels are research-preview MCP servers that push allowlisted external events into an *open* Claude Code session. They require explicit per-session opt-in and should never grant an untrusted sender permission-relay authority.
- `/loop` is session-scoped polling. It runs only while the session is open, restored only on resume while unexpired, and recurring loops expire after seven days.
- Use Desktop scheduled tasks for local-file automation on an awake machine. Use Routines or CI scheduling for durable remote scheduling. A scheduled task should use a worktree when it may modify a Git repository.

## When programmatic orchestration is genuinely required

The default build path does not need the Agent SDK. If an approved integration needs a programmatic, multi-turn controller, use the Claude Agent SDK—not CLI print mode. Use streaming input for an interactive, long-lived conversation; capture and resume the SDK session ID; surface permission/user-input requests to the human; use structured outputs for machine decisions; and load only necessary Claude Code settings sources. Persist transcripts externally only when there is a defined retention, access-control, and recovery policy.

## Capability checks before use

Run `claude --version` and use `/doctor`, `/context`, `/hooks`, and `/mcp` to verify the actual local installation and loaded configuration. Feature availability varies by Claude Code version, authentication provider, organization policy, and platform. In particular, Channels are preview and may be unavailable to managed organizations; agent teams are experimental.

## Official references consulted

- [Claude Code overview](https://code.claude.com/docs/en/overview)
- [Best practices](https://code.claude.com/docs/en/best-practices), [prompt library](https://code.claude.com/docs/en/prompt-library), and [common workflows](https://code.claude.com/docs/en/common-workflows)
- [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works), [sessions](https://code.claude.com/docs/en/sessions), [context window](https://code.claude.com/docs/en/context-window), and [large codebases](https://code.claude.com/docs/en/large-codebases)
- [Custom subagents](https://code.claude.com/docs/en/sub-agents), [agent teams](https://code.claude.com/docs/en/agent-teams), [parallel agents](https://code.claude.com/docs/en/agents), and [worktrees](https://code.claude.com/docs/en/worktrees)
- [Skills](https://code.claude.com/docs/en/slash-commands), [MCP](https://code.claude.com/docs/en/mcp), [hooks](https://code.claude.com/docs/en/hooks), [Channels](https://code.claude.com/docs/en/channels), and [scheduled tasks](https://code.claude.com/docs/en/scheduled-tasks)
- [Claude Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview), [SDK sessions](https://code.claude.com/docs/en/agent-sdk/sessions), [SDK subagents](https://code.claude.com/docs/en/agent-sdk/subagents), and [structured outputs](https://code.claude.com/docs/en/agent-sdk/structured-outputs)
- [Platform prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices), [evaluation design](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests), [Evaluation Tool](https://platform.claude.com/docs/en/test-and-evaluate/eval-tool), [reducing hallucinations](https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/reduce-hallucinations), and [increasing consistency](https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/increase-consistency)

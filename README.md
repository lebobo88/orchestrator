# Claude Code Orchestrator

An interactive Claude Code orchestrator with a test-driven T1 engineering route and an optional adaptive research harness. Research is dispatched only when the user requests it or it materially improves a decision; it begins with a targeted intake, writes a cited report under `docs/research/`, and remains advisory to approved implementation scope.

Use `/build <request>` to force the engineering route or `/research <question>` to force a foreground research pass. For normal requests, the orchestrator classifies both engineering intent and research need.

A Claude Code-native, interactive orchestration foundation. Its default workflow is intentionally small:

`user request → classify engineering intent → t1-engineer → JOB_DONE/JOB_BLOCKED → orchestrator report`

It does not use Claude CLI print mode, plugins, MCP, Agent SDK code, dynamic workflows, agent teams, or worktrees for an ordinary build request.

## Start an interactive session

From this directory, run:

```powershell
claude
```

The project settings select the `orchestrator` agent. To make it explicit:

```powershell
claude --agent orchestrator
```

Then use natural language, for example:

```text
Let's make an app that tracks household inventory. Build the first usable version and run its tests.
```

Or force the engineering workflow:

```text
/build design a responsive frontend for a recipe planner and verify the production build
```

The orchestrator sends a bounded foreground job to `t1-engineer`, waits for it, and reports completion evidence. It asks for clarification only when a missing decision is material.

## Use it with another repository

Claude Code loads project instructions from the directory where it starts. Copy this project's `CLAUDE.md` and `.claude/` directory into the target repository (review and merge its existing `CLAUDE.md`/settings first), then run interactive `claude` from that repository. Do not overwrite an existing target repository configuration blindly.

## Advanced tools

Agent teams, worktrees, MCP, plugins, hooks, sessions, channels, schedules, and Agent SDK boundaries are documented in [CAPABILITY-MAP.md](docs/CAPABILITY-MAP.md). They are available as opt-in tools, not automatic behavior. Define a reusable multi-stage pipeline with `/workflow-author`; `build` itself stays interactive and one-engineer by default.

## Activation notes

The repository contains both `.git` and `.agents`; its baseline commit supports native Git worktrees. Review [KNOWN-UNKNOWNS.md](docs/KNOWN-UNKNOWNS.md) before activating any external integration, and use [COMPLETION-AUDIT.md](docs/COMPLETION-AUDIT.md) to see what is proven versus awaiting an environment-specific decision.

## Validate the foundation

```powershell
pwsh -NoProfile -File .\tests\validate.ps1
```

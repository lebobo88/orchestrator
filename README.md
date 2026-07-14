# Claude Code Orchestrator

An interactive Claude Code orchestrator with a test-driven T1 engineering route, evidence-first Researcher, and dedicated Scribe. Scribe writes all non-code documents. When Researcher or T1 must supply evidence, a temporary agent team lets them message Scribe directly while the orchestrator retains only compact task receipts.

Use `/build <request>` to force the engineering route or `/research <question>` to force a foreground research pass. For normal requests, the orchestrator classifies both engineering intent and research need.

A Claude Code-native, interactive orchestration foundation. Its default workflow is intentionally small:

`user request → classify → T1 code or Scribe document → compact receipt → orchestrator report`

For a cross-agent document task:

`Researcher/T1 → direct evidence packet → Scribe → DOC_DONE → compact lead receipt`

It does not use Claude CLI print mode, plugins, MCP, Agent SDK code, dynamic workflows, persistent teams, or worktrees for an ordinary request. Agent teams are task-scoped for direct specialist-to-Scribe communication only.

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

The orchestrator sends a bounded foreground job to T1 for code or Scribe for documents, then reports completion evidence. It asks for clarification only when a missing decision is material.

For every browser-rendered UI or webview, T1 must use app-owned accessible modals or inline validation instead of native browser dialogs. The build contract requires a focused no-native-dialog scan and modal keyboard/focus evidence.

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

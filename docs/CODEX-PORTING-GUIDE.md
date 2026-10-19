# Codex CLI Porting Guide: Claude Code to Codex Adaptation

## Overview

This guide documents the procedures and conventions for porting Claude Code roles, skills, hooks, and execution patterns to the OpenAI Codex CLI harness within `H:\CommandCenter\orchestrator`.

## 1. Role Migration (.claude/agents/*.md -> .codex/agents/*.toml)

### Format Conversion
Claude Code roles are markdown files with frontmatter and prompt bodies. Codex CLI roles are TOML documents validated against `.codex/schemas/codex-agent.schema.json`.

| Claude Field | Codex TOML Field | Conversion Rules |
| :--- | :--- | :--- |
| `name` | `name` | Exact hyphenated lowercase identifier. |
| `category` | `category` | Standardized category string. |
| `model` | `model` | Maps to `gpt-5.6-sol` (or configured Codex model). |
| `tools` | `sandbox_mode` | `workspace-write` for code writers; `read-only` for planners, researchers, verifiers, and critics. |
| Prompt Body | `developer_instructions` | Complete instructions passed via TOML basic string or stdin prompt argument (`-`). |
| Custom routing | `routing_edges` | Explicit list of child roles this agent is authorized to dispatch. |

### Shell Ceiling Limit
Windows `CreateProcessW` limits total command line lengths to 32,767 characters. All 19 Codex role instructions are verified to remain under 24,576 characters to eliminate truncation risks. Tasks are passed via standard input (`codex exec -`).

## 2. Skill Adaptation (.claude/skills/* -> .agents/skills/*)

The repository maintains an authoritative 41-skill ledger enforcing exact set equality between `.claude/skills` and `.agents/skills`.

### Direct-Sync Skills (29 Skills)
Synchronized verbatim without modification because their contents are vendor-neutral:
- `browser-validator-core`, `design-core`, `design-direction`, `design-review`, `motion-and-assets`
- `planner-repository-analysis`, `planner-risk-validation`, `planner-specification-decomposition`
- `research-architecture`, `research-browser-ui-safety`, `research-comparison`, `research-high-stakes`, `research-root-cause`, `research-source-audit`, `research-strategic-general`, `research`
- `scribe-editorial-quality`, `scribe-research-briefing`, `scribe-specification-and-planning`, `scribe-technical-documentation`
- `t1-api-integration-contracts`, `t1-performance-evidence`, `t1-refactor-safety`, `t1-route-tracing`, `t1-security-reliability`, `t1-tdd-test-design`, `t1-ui-wiring-verification`
- `ux-architecture`, `visual-system`

### Adapted Skills (12 Skills)
Adapted to bridge vendor-specific primitives:
- `build`: Routes build execution through `orchestrate-role.ps1` dispatch state machine instead of Claude `/build`.
- `claude-operations`: Documents cross-harness delegation from Codex without mutating Claude state.
- `cross-vendor-judging`: Directs judgment requests to Claude critic via `invoke-claude-judge.ps1`.
- `design-prototype`: Directs file creation through `trusted-writer.ps1` to `.design/prototypes/<slug>/*`.
- `engineering-fleet`: Maps dispatch boundaries to `.codex/agents/*.toml` roles and envelopes.
- `planner-core`: Dispatches Researcher and Scribe via `orchestrate-role.ps1`.
- `researcher-core`: Enforces Codex read-only sandbox mode and shell restrictions.
- `scribe-core`: Routes all document writes through `trusted-writer.ps1`.
- `t1-core`: Integrates with `test-broker.ps1` under `IsolatedSandbox` mode.
- `t2-escalation`: Maps escalation triggers to `t2-engineer` and `t3-engineering-advisor` roles.
- `verifier-core`: Integrates verification receipts under `IsolatedSandbox`.
- `workflow-author`: Aligns workflow generation with `.codex/agents/*.toml` schemas.

## 3. Hook Adaptation (.claude/settings.json -> .codex/hooks.json)

In Claude Code, hooks are declared in `.claude/settings.json` under `"hooks"`.
In Codex CLI:
- Hooks are declared in `.codex/hooks.json`.
- Scripts reside in `.codex/hooks/*.ps1` and run under PowerShell 7 (`pwsh.exe`).
- Hook scripts must pass `[System.Management.Automation.Language.Parser]::ParseFile` with zero errors.
- PreToolUse hooks intercept file modifications and command execution, blocking actions with exit code 2 and structured stderr output.

## 4. Write Delegation for Read-Only Roles

Under Codex CLI, roles like `scribe` and `design-prototyper` operate under `sandbox_mode = "read-only"`.
To materialize authorized deliverables safely:
- The role outputs the desired file content in its structured completion packet.
- The parent orchestrator or runner invokes `trusted-writer.ps1` to commit the content.
- `trusted-writer.ps1` strictly validates path containment:
  - Scribe: `docs/plans/*.md`
  - Design Prototyper: `.design/prototypes/<slug>/*`
  - All control-plane paths (`.codex/**`, `.claude/**`, `AGENTS.md`, `CLAUDE.md`) are rejected.

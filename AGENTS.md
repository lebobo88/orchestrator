# OpenAI Codex CLI Orchestrator Contract

This repository runs a first-class OpenAI Codex CLI harness operating in dual-harness coexistence with the existing Claude Code harness. The Codex harness features a root Orchestrator, planning-stage design fleet, tiered engineering fleet, independent verification, and selective cross-vendor criticism via the Claude critic adapter.

## Operating Contract

- Stay in the native Codex CLI execution model. All newly authored harness scripts, hooks, and test runners execute strictly under PowerShell 7+ (`pwsh.exe`).
- Dual-harness coexistence is inviolable: existing Claude Code components in `.claude/` and host PowerShell 5.1 test broker suites are preserved in their native working state.
- Treat direct user intent as authoritative. Do not speculate or modify unapproved scope.
- Root Orchestrator operates under `sandbox_mode = "read-only"` with `gpt-5.6-sol` and `reasoning_effort = "high"`.
- Role dispatches execute via `orchestrate-role.ps1` complying strictly with `routing_edges`.
- Leaf execution sandboxing:
  - Read-only sandbox mode: `orchestrator`, `planner`, `researcher`, `scribe`, `verifier`, `browser-validator`, `codex-judge-runner`, and all design specialists (`design-director`, `design-generalist`, `design-reviewer`, `design-prototyper`, `ux-architect`, `visual-system-designer`, `motion-designer`, `asset-art-director`).
  - Workspace-write sandbox mode: `t1-engineer` and `t2-engineer`.
- Non-code text deliverables (plans, specifications, ADRs) are persisted exclusively through `trusted-writer.ps1` targeting `docs/plans/*.md`.
- Isolated prototype artifacts are persisted exclusively through `trusted-writer.ps1` targeting `.design/prototypes/<slug>/*`.
- Do not commit, push, create pull requests, deploy, or modify control-plane assets unless explicitly approved by the user.

## Browser UI Invariant

For every browser-rendered UI or webview, native browser dialogs are strictly prohibited: `alert`, `confirm`, `prompt`, `window.*` dialog variants, and `beforeunload` prompts. App-owned accessible modals and inline verification must be used instead. Every browser-rendered UI deliverable requires independent `browser-validator` journey verification and deterministic accessibility checks.

## Request Classification & Routing

Classify every new request before acting:
1. **Research**: Required for comparative analysis, architecture decisions, or external investigations. Dispatches `researcher` under read-only boundary; researcher performs zero repository mutations.
2. **Planning**: Required for all non-trivial engineering, architecture, or design-uncertain tasks. Dispatches `planner`, which coordinates research and design specialists before engineering.
3. **Design**: User-visible UI work routes through `design-generalist` (Compact) or `design-director` (Standard/Studio), gated by an independent `design-reviewer` verdict.
4. **Engineering**: Produces technical code changes. Ordinary implementation routes to `t1-engineer`. Remediation or complex escalation routes to `t2-engineer`. Architecture consultation routes to `t3-engineering-advisor` and `engineering-lead`.
5. **Writing**: Documentation and specifications route to `scribe` and are persisted via `trusted-writer.ps1`.
6. **Verification**: Independent verification pass via `verifier` is mandatory before completion claims. UI journeys require `browser-validator`.

## Control-Plane Immutability

PreToolUse hooks in `.codex/hooks.json` enforce control-plane immutability against both direct writes and shell redirection. Protected paths include `.codex/**`, `.claude/**`, `AGENTS.md`, `CLAUDE.md`, `.mcp.json`, and all contracts in `docs/*CONTRACT*`.

# Claude Code Orchestrator

This project runs an interactive Claude Code orchestrator with a planning-stage design fleet, tiered engineering fleet, and selective local Codex cross-vendor judgment. Planner creates grounded execution plans and routes Researcher plus the minimum design specialists before engineering. Design Generalist handles compact UI work; Design Director coordinates Standard/Studio UX, visual, motion, and asset specialists; Design Reviewer independently gates the handoff; Design Prototyper may create one isolated Studio prototype. Codex Judge Runner is a Haiku transport-only agent for guarded `codex exec` criticism. T1 is the Haiku first-line writer; T2 is the Sonnet escalation writer; T3 is the Opus read-only advisor; Engineering Lead is the Sonnet technical coordinator; Verifier independently checks writer completion; Browser Validator checks rendered UI journeys; Researcher gathers evidence; and Scribe writes all non-code textual deliverables. The Orchestrator owns user interaction and workflow state.

## Operating contract

- Stay in the native interactive Claude Code session. Never run `claude -p`, and never create a hidden one-shot Claude subprocess.
- Treat direct user intent as authoritative. Ask a concise question only when a missing answer would change scope, safety, target repository, or acceptance criteria.
- Keep normal work serial: `.claude/settings.json` sets `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`, so one foreground Planner owns every non-basic task. It may use a bounded, safely named custom subagent when native continuation needs a stable handle; names do not create agent teams. Planner invokes Researcher only when material evidence is needed, runs the minimum design route for user-visible work, obtains an independent design pass, and invokes Scribe only after the plan handoff is complete. An idle, partial, or nonterminal agent response is a protocol blocker, never a reason to poll or resume. Load `engineering-fleet` after planning.
- Never claim completion from writer or judge evidence alone: require a read-only Verifier pass and, for browser-rendered UI/webview work, a Browser Validator pass. Run selective Codex plan/code/evidence/visual checkpoints from `docs/JUDGE-CONTRACT.md`; deterministic failures always dominate. Two counted T1 gate failures escalate to T2; two counted T2 gate failures block for user review. When T2 identifies unbuilt work already approved by the plan as broader than remediation, re-dispatch it once as a direct T2 full-build continuation; use extreme advisory only when its existing criteria and plan authorization both hold. Research, stale plans, credentials, and unavailable prerequisites do not count.
- Do not commit, push, create a pull request, deploy, install a plugin, grant permissions, or add an MCP server unless the user explicitly requests it.

## Browser UI invariant

For every browser-rendered UI or webview, including Tauri frontends, native browser dialogs are prohibited: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts. Use an app-owned accessible modal for acknowledgement or confirmation, and inline validation where it better serves the user. Every browser UI `ENGINEERING_JOB` must require a deterministic no-native-dialog scan, modal keyboard/focus verification, and `browser_ui_validation` inputs: launch/readiness command, base URL, fixture/reset procedure, user journeys, viewport profiles, and visible outcomes.

## Default request classification

Classify every new request before acting.

First classify research need as **required**, **recommended**, or **not needed**. Research is required for an explicit request to research/investigate/compare, a decision that depends on current or external facts, or a high-consequence evidence-backed recommendation. It is recommended when an unfamiliar system, broad architecture choice, or several viable approaches would materially benefit from evidence. It is not needed for a clear, bounded implementation with sufficient local context. Do not use research as a mandatory stage for every request.

When research is used, dispatch `researcher` with `research_state: intake` as described in `docs/RESEARCH-HARNESS.md`. It returns three targeted intake questions; relay only the answers it needs. In planning work, Planner invokes Researcher as a nested child and receives its evidence directly. User instructions and approved scope always prevail over research.

**Basic** means only a clear, isolated one-file change or short self-contained answer/document with explicit acceptance checks. Basic work may route directly to T1 or Scribe. Every other engineering, multi-stage research, significant document, migration, architecture, integration, browser UI, or design-uncertain request must first route to Planner using `docs/PLAN-CONTRACT.md`. Planner keeps complete handoffs inside its nested chain, Scribe persists `docs/plans/<slug>.md`, and T1 starts only after the user explicitly approves that plan.

For every user-visible interface, Planner also reads `docs/DESIGN-CONTRACT.md` and emits `DESIGN_ROUTE`. Compact uses one design generalist; Standard uses director, UX, visual, and reviewer; Studio presents safe/refined/novel directions, develops only the selected direction, and may create one guarded disposable prototype. Design runs during planning/research and before Scribe finalizes the engineering plan. Sonnet 5 is the default; Opus 4.8 is a bounded premium escalation; Fable 5 is reserved for the highest-value Studio synthesis. Never run a model ladder automatically.

The complete custom-agent runtime registry is `planner`, `researcher`, `scribe`, `design-generalist`, `design-director`, `ux-architect`, `visual-system-designer`, `motion-designer`, `asset-art-director`, `design-reviewer`, `design-prototyper`, `t1-engineer`, `t2-engineer`, `t3-engineering-advisor`, `engineering-lead`, `verifier`, `browser-validator`, and `codex-judge-runner`. Runtime visibility does not change ownership: the lead invokes Planner; Planner invokes Generalist or Director, Reviewer, optional Prototyper, Researcher, and Scribe; Director invokes UX, visual, motion, and asset specialists. Built-in `general-purpose`, `Explore`, and `Plan` agents are prohibited, including for quick repository scans. A built-in agent's accidental output is non-authoritative and must not affect planning, evidence, or implementation.

Files under `.claude/agents/` are live project definitions regardless of Git tracked/untracked status. Never describe an agent as draft-only from Git status. If a required design role is actually unavailable, return `PLAN_BLOCKED` with `design_runtime_unavailable`; never substitute inline design or bypass the independent review gate.

**Engineering** requests ask to build, make, create, implement, design a frontend or app, modify software, fix a bug, refactor, test, integrate, automate code, or otherwise produce/change a technical artifact. After any required planning and approval, load `build` and `engineering-fleet`; route ordinary work to T1, evidence-backed remediation to T2, and explicitly authorized exceptional work through Engineering Lead/T3 advisory checkpoints.

**Writing** requests for documents, READMEs, instructions, plans, ADRs, changelogs, research briefings, or rewrites route to Scribe when basic; significant or design-uncertain writing routes through Planner first. Short advisory answers remain with the orchestrator. Do not route non-code writing to T1.

For ambiguous requests, state the classification and ask the one question needed to resolve it. A user can force the build route with `/build` or force research with `/research`.

Use the examples and decision rules in `docs/BUILD-CONTRACT.md`. Intent matters more than an exact keyword: “let's make an app,” “design a frontend,” and “turn this API sketch into a working service” are engineering; “summarize this design,” “compare frameworks,” and “draft a product brief” are not implementation requests unless the user also asks to produce or change a technical artifact.

Researcher may use read-only repository inspection but writes no repository artifacts. Scribe is the only non-code document author. Read `docs/DOCUMENT-CONTRACT.md` and `docs/RESEARCH-HARNESS.md` before any cross-agent document delegation.

## Advanced capabilities are opt-in

- Use a native worktree only when isolation, parallel edits, or a clean branch is requested. Prefer Claude Code's `EnterWorktree` tool in-session or start an interactive session with `claude --worktree <name>`.
- Use plain subagents for basic bounded work and the nested Planner chain for non-basic work. Agent teams are disabled in the default session. Only after explicit user approval may an extreme advisory or independent parallel task launch a separate session with temporary settings that enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` and set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=0`; use `/config` or an explicit prompt for teammate model selection. Teams are experimental and cost more context and tokens. Tmux, WSL, cmux, iTerm2, and split panes are never required.
- Use Skills and custom agent definitions for reusable routing. Do not create a project JavaScript Dynamic Workflow runtime; it is not the implementation of `/build`.
- Add MCP only as a deliberately reviewed project/user configuration. Prefer no plugin; a plugin is justified only when a maintained package is materially better than local project configuration.
- Use `/goal` for a session-scoped completion condition, `/resume`, `/continue`, or `/fork` for session management, `/loop` only for session-scoped polling, and Routines/Desktop scheduled tasks for durable schedules.
- External events require a Channel-compatible MCP server, an open session, and explicit opt-in. Do not expose a channel or relay permissions without a sender allowlist.

Read `docs/PLAN-CONTRACT.md` before planning non-basic work, `docs/DESIGN-CONTRACT.md` before planning user-visible work, and `docs/CAPABILITY-MAP.md` before proposing any other advanced capability.

Read `docs/JUDGE-CONTRACT.md` before cross-vendor review. The only authorized external model boundary is the guarded local Codex CLI runner: ephemeral, read-only, web disabled, MCP disabled, structured output, and ignored provenance. Respect the two/four call caps and shadow policy; no live smoke calls occur without explicit usage approval.

Read `docs/PROMPTING-AND-EVALUATION.md` when creating a job brief, verification gate, evaluation case, or model-selection recommendation. Read `docs/ARCHITECTURE-ADAPTATION.md` when changing orchestration structure.

# Claude Code Orchestrator

An interactive Claude Code orchestrator with a planning-stage design fleet, tiered T1/T2/T3 engineering fleet, evidence-first Researcher, dedicated Scribe, and selective local Codex cross-vendor review. T1 writes first; two failed deterministic gate-remediation cycles escalate to T2; T3 provides read-only guidance only for explicitly approved extreme work. Scribe writes all non-code documents, including durable plans.

Use `/build <request>` to force the engineering route or `/research <question>` to force a foreground research pass. For normal requests, the orchestrator classifies both engineering intent and research need.

A Claude Code-native, interactive orchestration foundation. Its default workflow is intentionally small:

`user → Planner → Research/Design → Design Review → Scribe → Codex Plan Duck → approval → T1/T2 → Codex Code Review → Verifier → optional Evidence Challenge → Browser Validator → optional Visual Review → report`

Basic one-file changes and short self-contained documents with explicit acceptance checks may still route directly to T1 or Scribe.

For a research-backed plan:

`Planner → nested research question → Researcher → evidence packet → Planner → nested Scribe → plan draft → user approval`

For user-visible work, Planner classifies `none | compact | standard | studio`. Compact uses one Sonnet 5 generalist. Standard uses a Sonnet 5 design director, UX architect, visual-system designer, and independent reviewer. Studio uses Fable 5 only for the highest-value synthesis, presents safe/refined/novel directions, develops one selection, and may create one guarded disposable prototype beneath `.design/prototypes/`.

Cross-vendor review is selective and begins in shadow mode. The guarded Haiku transport invokes `codex exec` ephemerally with a read-only sandbox, web/MCP disabled, structured output, and Luna/Terra/Sol routing. Static validation uses a fake executable and never spends model tokens. See [DESIGN-CONTRACT.md](docs/DESIGN-CONTRACT.md) and [JUDGE-CONTRACT.md](docs/JUDGE-CONTRACT.md).

It does not use Claude CLI print mode, new MCP integrations, plugins, Agent SDK code, project JavaScript workflow runtimes, persistent teams, or worktrees for an ordinary request. The existing Browser Validator may use an already configured Claude in Chrome connection. Codex CLI is the sole new cross-vendor boundary. Extreme advisory teams are task-scoped: Orchestrator remains native team lead, Engineering Lead coordinates, T1 is the writer, T3 advises, and T2 joins only after T1 releases ownership. Delegation uses only named custom roles; built-in general-purpose, Explore, and Plan agents are blocked. Tmux, WSL, cmux, iTerm2, and split panes are not required.

See the [editable Mermaid C4 source](docs/ARCHITECTURE-C4.md) for the complete Planner, tiered engineering fleet, Verifier, Browser Validator, Researcher, and Scribe interaction model.

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

The orchestrator sends a bounded foreground job to T1 for code or Scribe for documents only after required planning, design review, applicable plan duck, and approval. After two completed deterministic T1 remediation failures, it hands the evidence packet to T2. If T2 correctly identifies that the remaining work is already-approved scope rather than bounded remediation, the orchestrator reissues it once as a direct T2 full-build continuation, preserving the plan and gates; an extreme route still requires both documented complexity and explicit plan authorization. Every eligible writer `JOB_DONE` receives selective Codex review, then independent Verifier and applicable Browser Validator gates. Judge findings cannot waive deterministic failures.

For every browser-rendered UI or webview, T1 must use app-owned accessible modals or inline validation instead of native browser dialogs. The build contract requires a focused no-native-dialog scan and modal keyboard/focus evidence.

## Use it with another repository

Claude Code loads project instructions from the directory where it starts. Copy this project's `CLAUDE.md` and `.claude/` directory into the target repository (review and merge its existing `CLAUDE.md`/settings first), then run interactive `claude` from that repository. Do not overwrite an existing target repository configuration blindly.

## Advanced tools

Agent teams, worktrees, MCP, plugins, hooks, sessions, channels, schedules, and Agent SDK boundaries are documented in [CAPABILITY-MAP.md](docs/CAPABILITY-MAP.md). They are available as opt-in tools, not automatic behavior. Reusable engineering modes are Skills plus custom agent definitions; `build` itself stays interactive and starts with one writer by default.

To force the terminal-independent team display for one session, start Claude Code with:

```powershell
claude --teammate-mode in-process
```

## Activation notes

The repository contains both `.git` and `.agents`; its baseline commit supports native Git worktrees. Review [KNOWN-UNKNOWNS.md](docs/KNOWN-UNKNOWNS.md) before activating any external integration, and use [COMPLETION-AUDIT.md](docs/COMPLETION-AUDIT.md) to see what is proven versus awaiting an environment-specific decision.

## Validate the foundation

```powershell
pwsh -NoProfile -File .\tests\validate.ps1
```

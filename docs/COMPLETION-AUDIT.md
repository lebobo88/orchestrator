# Completion audit

This audit maps the requested outcome to current evidence. It is deliberately conservative: a documented capability is not treated as proven runtime behavior until the required local/provider preconditions are met.

| Requested result | Current evidence | Status |
| --- | --- | --- |
| Native interactive Claude Code orchestrator | `.claude/settings.json` selects `orchestrator`; `CLAUDE.md` and `.claude/agents/orchestrator.md` establish an interactive-only operating contract. `claude --version` reports 2.1.209 and `claude doctor` passes. | Ready to start interactively. |
| Default `build` workflow | `.claude/skills/build/SKILL.md`, `BUILD-CONTRACT.md`, and seven classification fixtures cover engineering/non-engineering/ambiguous intent. | Implemented and statically checked. |
| Plan-first non-basic routing | `planner`, four planning skills, `PLAN-CONTRACT.md`, approval-gated Scribe plan ownership, named-role-only dispatch, nested Planner/Researcher/Scribe fixtures, and original-Planner resume rules require a durable plan before non-basic downstream work. | Implemented and statically checked; native interactive nested-chain smoke test remains environment-dependent. |
| Tiered engineering fleet | T1 is the Haiku first-line writer; after two counted gate failures the Orchestrator gives T2 the evidence-backed escalation packet; T3 and Engineering Lead are read-only and coordinate only explicitly approved extreme advisory work. | Implemented and statically checked; live team smoke test remains environment-dependent. |
| Independent post-T1 completion gates | `verifier` independently checks every `JOB_DONE`; `browser-validator` validates required rendered UI/webview journeys after verifier approval. T1 completion is not reported until every applicable gate passes. | Implemented and statically checked; live Claude in Chrome smoke test remains environment-dependent. |
| Conditional evidence-first research | The orchestrator categorizes research as required/recommended/not needed, relays only Researcher's clarification answers, and uses direct `RESEARCH_EVIDENCE` packets for consuming teammates, including Planner during plan-first work. | Implemented and statically checked. |
| Adaptive research and Scribe report harness | Researcher requires targeted intake, selects quick/standard/deep profiles and a mode-specific source ledger, and writes no artifacts. Scribe authors cited reports under `docs/research/`; Researcher has a read-only inspection hook and Scribe has a document-write boundary. | Implemented and offline-validated; native interactive smoke test remains environment-dependent. |
| Researcher progressive-disclosure skills | Researcher preloads a compact core policy and loads architecture, strategic/general, comparison, root-cause, source-audit, and high-stakes playbooks by selected mode without expanding its authority. | Implemented and statically checked; native interactive mode-selection smoke tests remain environment-dependent. |
| T1 capability skills | T1 preloads a production-first core playbook and can load focused TDD, route-tracing, refactor, performance, API/integration, UI, and security/reliability skills without gaining web or orchestration authority. | Implemented and statically checked; native interactive task-profile smoke tests remain environment-dependent. |
| Browser UI no-native-dialog invariant | Build contracts, T1 UI guidance, Researcher browser-UI evidence, and Scribe technical documentation prohibit native browser dialogs and require accessible app-owned modal or inline feedback with deterministic scans. | Implemented and statically checked; target-project UI smoke tests remain environment-dependent. |
| Browser fallback recovery | A missing browser backend returns `BROWSER_BLOCKED`; the orchestrator requests explicit approval before Browser Validator downloads Playwright 1.61.0 and Chromium into user caches, then resumes the same validation job. A missing native-desktop backend returns `BROWSER_BLOCKED tauri_driver_missing`; the orchestrator requests explicit approval before Browser Validator installs pinned `tauri-driver` 2.0.6 and a WebView2-Runtime-matched `msedgedriver` into the Cargo bin/tooling cache, then resumes the same validation job. | Implemented and statically checked; download and live browser execution require user approval and a target fixture. |
| Dedicated Scribe and direct document handoffs | Scribe owns all non-code textual deliverables, including persisted plans; Planner, Researcher, and T1 send direct specialist packets to Scribe when appropriate. The lead retains compact receipts only. | Implemented and statically checked; native interactive peer-messaging smoke tests remain environment-dependent. |
| No CLI print subprocesses | Root instructions, agents, skills, template, and validator prohibit `claude -p` invocations. | Statically checked. |
| Prompting, verification, hallucination safeguards | `PROMPTING-AND-EVALUATION.md`, job envelope, acceptance gate, and T1 instructions require grounded outcome/constraints/evidence. | Implemented and statically checked. |
| Skills and subagents | Local filesystem definitions are present in standard `.claude` locations. | Implemented; interactive load needs a first session. |
| Tmux-free optional agent teams | Default settings disable teams and background tasks. An explicitly approved separate session may enable agent teams for independent parallel work; the standard plan-first chain uses serial nested subagents. | Documented; live use depends on provider/org availability and explicit activation. |
| Serial design-fleet runtime repair | Default settings disable teams/background tasks; session-wide dispatch guard rejects aliases, team-style calls, unsafe names, and explicit background dispatch while allowing bounded normal subagent names; terminal hooks require defined packets; static topology and hook fixtures cover the incident path. | Static validation passed on Claude Code 2.1.210. Three bounded CLI smoke attempts exposed two repaired hook-compatibility defects; the final Standard chain exceeded the 600-second ceiling without a terminal packet or plan artifact, so live acceptance remains pending an interactive traced smoke. |
| Reusable engineering modes | `engineering-fleet` and `/workflow-author` use Skills and custom-agent contracts. Project JavaScript workflow runtimes are deliberately unsupported. | Implemented and statically checked. |
| Worktree isolation | Git repository has baseline commit `cf9ec39`; `.gitignore` has the worktree path; a temporary isolated worktree was created from `HEAD`, checked for `CLAUDE.md`, and removed successfully. | Implemented and live Git-validated. |
| MCP, plugins, hooks, Channels, scheduling, goals, sessions, Agent SDK | `claude-operations` and `CAPABILITY-MAP.md` choose native primitives and document safe activation/limits. | Available as explicit opt-ins; external setup requires a concrete user decision. |
| `.git` and `.agents` inside project | Both folders are present; `.git` initializes successfully; `.agents/README.md` defines scope. | Implemented. |

## Verification already run

```text
pwsh -NoProfile -File .\tests\validate.ps1  # passed
claude doctor  # passed on 2.1.209
claude --version  # 2.1.208
claude doctor  # no installation issues
git worktree add --detach .claude/worktrees/orchestrator-validation HEAD  # created successfully
git worktree remove --force .claude/worktrees/orchestrator-validation  # removed successfully
```

See `KNOWN-UNKNOWNS.md` for activation prerequisites and the decisions that cannot be safely guessed.

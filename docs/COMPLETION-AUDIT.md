# Completion audit

This audit maps the requested outcome to current evidence. It is deliberately conservative: a documented capability is not treated as proven runtime behavior until the required local/provider preconditions are met.

| Requested result | Current evidence | Status |
| --- | --- | --- |
| Native interactive Claude Code orchestrator | `.claude/settings.json` selects `orchestrator`; `CLAUDE.md` and `.claude/agents/orchestrator.md` establish an interactive-only operating contract. `claude --version` reports 2.1.208 and `claude doctor` passes. | Ready to start interactively. |
| Default `build` workflow | `.claude/skills/build/SKILL.md`, `BUILD-CONTRACT.md`, and seven classification fixtures cover engineering/non-engineering/ambiguous intent. | Implemented and statically checked. |
| Plan-first non-basic routing | `planner`, four planning skills, `PLAN-CONTRACT.md`, approval-gated Scribe plan ownership, and planning fixtures require a durable plan before non-basic downstream work. | Implemented and statically checked; native interactive team smoke test remains environment-dependent. |
| Route engineering work to T1 and return completion | The orchestrator delegates one foreground `t1-engineer`; the agent requires `JOB_DONE`/`JOB_BLOCKED`; the build contract gates completion evidence. | Implemented and statically checked. |
| Conditional evidence-first research | The orchestrator categorizes research as required/recommended/not needed, relays only Researcher's clarification answers, and uses direct `RESEARCH_EVIDENCE` packets for consuming teammates, including Planner during plan-first work. | Implemented and statically checked. |
| Adaptive research and Scribe report harness | Researcher requires targeted intake, selects quick/standard/deep profiles and a mode-specific source ledger, and writes no artifacts. Scribe authors cited reports under `docs/research/`; Researcher has a read-only inspection hook and Scribe has a document-write boundary. | Implemented and offline-validated; native interactive smoke test remains environment-dependent. |
| Researcher progressive-disclosure skills | Researcher preloads a compact core policy and loads architecture, strategic/general, comparison, root-cause, source-audit, and high-stakes playbooks by selected mode without expanding its authority. | Implemented and statically checked; native interactive mode-selection smoke tests remain environment-dependent. |
| T1 capability skills | T1 preloads a production-first core playbook and can load focused TDD, route-tracing, refactor, performance, API/integration, UI, and security/reliability skills without gaining web or orchestration authority. | Implemented and statically checked; native interactive task-profile smoke tests remain environment-dependent. |
| Browser UI no-native-dialog invariant | Build contracts, T1 UI guidance, Researcher browser-UI evidence, and Scribe technical documentation prohibit native browser dialogs and require accessible app-owned modal or inline feedback with deterministic scans. | Implemented and statically checked; target-project UI smoke tests remain environment-dependent. |
| Dedicated Scribe and direct document handoffs | Scribe owns all non-code textual deliverables, including persisted plans; Planner, Researcher, and T1 send direct specialist packets to Scribe when appropriate. The lead retains compact receipts only. | Implemented and statically checked; native interactive peer-messaging smoke tests remain environment-dependent. |
| No CLI print subprocesses | Root instructions, agents, skills, template, and validator prohibit `claude -p` invocations. | Statically checked. |
| Prompting, verification, hallucination safeguards | `PROMPTING-AND-EVALUATION.md`, job envelope, acceptance gate, and T1 instructions require grounded outcome/constraints/evidence. | Implemented and statically checked. |
| Skills and subagents | Local filesystem definitions are present in standard `.claude` locations. | Implemented; interactive load needs a first session. |
| Tmux-free agent teams | Feature environment flag is set, `teammateMode` is in-process, and task-scoped Planner/Scribe rules with optional direct Researcher evidence plus sequential fallback are present. | Configured; live use depends on provider/org availability. |
| Dynamic Workflows | `/workflow-author` and a schema-aware typed-agent template are present; default build does not use it. | Toolbox implemented; no user-specific workflow intentionally pre-created. |
| Worktree isolation | Git repository has baseline commit `cf9ec39`; `.gitignore` has the worktree path; a temporary isolated worktree was created from `HEAD`, checked for `CLAUDE.md`, and removed successfully. | Implemented and live Git-validated. |
| MCP, plugins, hooks, Channels, scheduling, goals, sessions, Agent SDK | `claude-operations` and `CAPABILITY-MAP.md` choose native primitives and document safe activation/limits. | Available as explicit opt-ins; external setup requires a concrete user decision. |
| `.git` and `.agents` inside project | Both folders are present; `.git` initializes successfully; `.agents/README.md` defines scope. | Implemented. |

## Verification already run

```text
pwsh -NoProfile -File .\tests\validate.ps1  # passed
node --check .\.claude\skills\workflow-author\templates\dynamic-workflow-template.js  # passed
claude --version  # 2.1.208
claude doctor  # no installation issues
git worktree add --detach .claude/worktrees/orchestrator-validation HEAD  # created successfully
git worktree remove --force .claude/worktrees/orchestrator-validation  # removed successfully
```

See `KNOWN-UNKNOWNS.md` for activation prerequisites and the decisions that cannot be safely guessed.

# Orchestrator upgrade series 2026-10

## Status

APPROVED - the user gave explicit approval on 2026-10-18 (see [User approval record](#user-approval-record)). Live Codex calls still require explicit usage approval (see [Verification and judge checkpoints](#verification-and-judge-checkpoints)); commits, pushes, PRs, issue filing, and merges are authorized only for executing approved steps under the branch and merge rule below.

- plan_id: `orchestrator-upgrade-series-2026-10`
- task_id: `orchestrator-upgrade-series-2026-10`
- route: engineering, with research-backed and document sub-routes
- target: `H:\CommandCenter\orchestrator` (governed checkout, branch `main`, origin `git@github.com:lebobo88/orchestrator.git`)
- Source: Planner `PLANNING_HANDOFF`. Repository paths and findings were observed by Planner on 2026-10-18 unless labeled inference.
- Approval gate: satisfied on 2026-10-18. The repository owner explicitly approved this plan and answered every decision in [Decisions (recorded)](#decisions-requiring-the-user). T1 may be dispatched.

Label key used throughout: **observed** (seen by Planner on 2026-10-18), **inference** (reasoned, not yet proven), **assumption** (taken as true for planning), **decision** (owner choice required or recorded), **to be confirmed by R1/R2/R3/R4** (research-dependent external fact; no value is asserted here).

## Contents

1. [Outcome and audience](#outcome-and-audience)
2. [Scope and non-goals](#scope-and-non-goals)
3. [Repository findings](#repository-findings)
4. [Ordered phases](#ordered-phases)
5. [Branch, owner, and dependency table](#branch-owner-and-dependency-table)
6. [Interfaces and data](#interfaces-and-data)
7. [GitHub issue drafts](#github-issue-drafts)
8. [Acceptance checks](#acceptance-checks)
9. [Verification and judge checkpoints](#verification-and-judge-checkpoints)
10. [Codex call and cost budget](#codex-call-and-cost-budget)
11. [Risks and rollback](#risks-and-rollback)
12. [Stale-plan conditions](#stale-plan-conditions)
13. [Assumptions](#assumptions)
14. [Decisions requiring the user](#decisions-requiring-the-user)
15. [Routing and ownership](#routing-and-ownership)
16. [Proposal list F (NOT APPROVED)](#proposal-list-f-not-approved)

## Outcome and audience

A sequenced, gated series of updates to the orchestrator harness itself:

- **A** `.design/` is git-ignored.
- **B** Official-source research of the Claude 5.5 model family and Claude Code docs and changelog through 2026-10-18; an alignment-opportunity ledger; a 100% read-only verification of every opportunity against the codebase; deeper gap and known-unknown research producing proposals; and a Codex cross-vendor check of the findings and this plan.
- **C** A complete root-cause fix for uncontrolled and orphaned dev servers: per-run manifests, collision-free ports, PID and port scoped teardown, stale-run reaping, hook enforcement, and tests on Windows/PowerShell.
- **D** Codex judge tiers reduced to exactly `gpt-6-luna`, `gpt-6-astra`, and `gpt-6.1-sol` (Terra removed) after official confirmation, plus a single centralized, tested model-ID and pricing registry for OpenAI judge and Claude models.
- **E** An owner-controlled GitHub Actions toggle, default OFF, enforced by hooks and a deterministic diff gate.
- **F** A ranked, unapproved proposal list.
- **G** README and all docs 100% correct, verified by Verifier.

Audience: the repository owner (approver) first; then Orchestrator, Engineering fleet, Researcher, Verifier, and Scribe executing approved steps.

## Scope and non-goals

### Global rules (user-approved)

- Every issue or implementation item lives on its own branch, with one PR per branch (user requirement, restated on 2026-10-18).
- Merge to `main` only after all verification and validation succeed, meaning: Verifier pass; Browser Validator where applicable (none of these items is browser UI, so every PR carries a `BROWSER_NOT_APPLICABLE` receipt); applicable Codex checkpoints resolved; tests green.
- Non-trivial items get a GitHub issue with full root-cause diagnosis and planned fix, filed only after plan approval. Trivial items dispatch directly.
- Documentation and README drift is corrected only by Scribe.
- Nothing is discarded from the current working tree.

### Non-goals

- Editing target application repositories (`lizbeth_spanish` and its roughly 54 sibling worktrees and clones, `photo-genie`, `world-data`, `mythic-proportion`, calculator folders) beyond read-only inspection.
- Rewriting historical records in `docs/plans/**` and `docs/evidence/**` (see DEC-6).
- Implementing any F or B4 proposal, or any B2 alignment item, before separate explicit approval.
- Enabling agent teams; installing plugins or MCP servers; deploying.
- Editing managed settings at `C:\Program Files\ClaudeCode\` (owner-only).
- Live Codex calls without explicit usage approval.

## Repository findings

All entries observed by Planner on 2026-10-18 unless labeled.

### Control plane and execution venue

- **F-01 (observed)** The control plane is immutable to every agent in governed operation: managed Edit and Agent denies scoped to `H:\CommandCenter\orchestrator`, plus the project hook `.claude/hooks/validate-control-plane-write.ps1`. Protected: `.claude/settings*.json`, `agents/**`, `hooks/**`, `skills/**`, `scripts/**`, `schemas/**`, `judge-policy.json`, `maintenance-mode.flag`, `CLAUDE.md`, `.mcp.json`, `docs/PLAN|DESIGN|JUDGE|BUILD|DOCUMENT-CONTRACT.md`, `RESEARCH-HARNESS.md`, `CAPABILITY-MAP.md`, `ARCHITECTURE-ADAPTATION.md`, `PROMPTING-AND-EVALUATION.md`. Source: `docs/plans/orchestrator-control-plane-immutability-and-maintenance-mode.md` (APPROVED 2026-07-26; Phases 0-3 and 6 complete, Phase 4 partial, Phase 5 maintenance mode not implemented; recommended mechanism M2 = non-governed maintenance clone with owner promotion, M1 = owner hand edit). Nearly all of B-implementation, C, D, E, and G touch the control plane, so agents cannot execute them in the governed checkout.
- **F-02 (DF-1, defect candidate; inference to be proven by test)** `validate-control-plane-write.ps1` line 80 calls `$repositoryRoot.Replace(...)` but `$repositoryRoot` is never defined. With `$ErrorActionPreference='Stop'`, every Write, Edit, or NotebookEdit with a non-empty path throws and exits 1, which Claude Code treats as non-blocking, so the project hook fails open for file tools (the Bash pattern branch exits before that line and works). Also (observed): Bash patterns omit `.claude/scripts`, `schemas`, `judge-policy.json`, `maintenance-mode.flag`, and the contract docs; the hook file is untracked in git (`??`). Managed denies still protect the governed path; a maintenance clone outside that path would be protected only by this hook.
- **F-03 (observed)** The orchestrator agent has no Bash (tools: Agent, SendMessage, Skill, Read, WebFetch, WebSearch, `mcp__atelier__*`). Git and gh actions must be executed by a Bash-capable role (T1 or T2) under explicit commit authority, or by the owner.
- **F-04 (observed)** `.claude/hooks/validate-agent-dispatch.ps1` denies `run_in_background`, any `name`, `team_name`, `teammate_name`, and `isolation`. It does not restrict model or effort, so Agent `model` (sonnet|opus|haiku|fable) and effort overrides are possible.

### Working tree baseline

- **F-05 (observed)** Uncommitted state at session start: about 32 modified tracked files (14 agents, 7 hooks, `invoke-codex-judge.ps1`, `settings.json`, `t1-core` skill, `CLAUDE.md`, `BUILD-CONTRACT.md`, `KNOWN-UNKNOWNS.md`, a lizbeth plan, `handoff.md`, `tests/agent-dispatch-hook-cases.json`, `tests/test-codex-judge.ps1`, `tests/validate.ps1`) and untracked: `.atelier/` (screenshots, baselines, diffs, reference-harness), `.claude/hooks/validate-control-plane-write.ps1`, `.codex/` (config.toml, hooks.json, 7 pwsh hooks, schemas), `.phase3-hold/index.ts.mine`, `AGENTS.md`, `CODEX-HARNESS-MIGRATION-PLAN.md`, `atelier.config.json`, `browser-validation-artifacts/`, `docs/CODEX-HARNESS.md`, `docs/CODEX-PORTING-GUIDE.md`, `docs/EXTERNAL-WRITER-BOUNDARY.md`, many `docs/evidence/*` and plans. The list was truncated; the full inventory is step P0.1.
- **F-06 (observed)** About 54 target worktrees and clones sit at the repo root (`lizbeth_spanish-53`, `-140`, `-196a..c`, `-198`, `-208a/b`, `-218b..f`, `-224`, `-227`, `-228*`, `-233`, `-235`, `-236`, `-244`, `-245`, `-259`, `-276a/b`, `-277a/b`, `-290`, `-291`, `-293a/b`, `-5c2`, `-1b`, `-flakes`, `-fixes1`, `-fonts`, `-lrsr`, `-mobilenav`, `-polish`, `-privacy`, `-prE`, `-pwd`, `-uibatch`, `lizbeth_main_verify_20261013`, and others). Each has `.git` and `playwright.config.ts`. `.gitignore` ignores only `/lizbeth_spanish/` and named scratch apps, so these are untracked noise and they make repo-wide Glob time out.
- **F-07 (observed; suite state is inference)** Test, doc, and frontmatter drift. Agent frontmatter now has: `t1-engineer` sonnet, `t2-engineer` opus, `t3-engineering-advisor` fable, `engineering-lead` opus, `orchestrator` sonnet, `visual-system-designer` opus, `ux-architect` fable. `CLAUDE.md`, README, and `BUILD-CONTRACT.md` still say T1 Haiku, T2 Sonnet, T3 Opus, Engineering Lead Sonnet. `tests/validate.ps1` lines 569, 596, 604, 607 assert T1 haiku, T2 sonnet, T3 opus, Engineering Lead sonnet; line 520 asserts all design agents are `claude-sonnet-5` (`visual-system-designer` and `ux-architect` no longer are). `invoke-codex-judge.ps1` allows `gpt-5.6-luna`, `gpt-5.6-terra`, `gpt-5.6-sol`, `gpt-6-astra` and efforts medium|high, while `JUDGE-CONTRACT.md`, the `cross-vendor-judging` skill, `codex-judge-runner.md`, `tests/validate.ps1` (lines 554-557, 888), and `tests/test-codex-judge.ps1` (lines 107-109 expect `gpt-5.6-sol` and high effort to be rejected) encode Luna/Terra medium only. Inference: the current suite is red; P0.2 records the actual result.
- **F-08 (observed)** Other doc drift: `docs/BUILD-CONTRACT.md` line 88 contains a corrupted paste referencing `scratchpad/orchestrator-patches.md`; `docs/CODEX-HARNESS.md` describes `.agents/scripts/` (`ProcessRunnerHelper.cs`, `invoke-codex-process.ps1`, `orchestrate-role.ps1`, `trusted-writer.ps1`, `test-broker.ps1`) that do not exist (`.agents/` holds only `README.md`); `docs/CAPABILITY-MAP.md` says no MCP server is bundled while agents grant `mcp__atelier__*` and t1 grants `mcp__deepseek-pi__*` (neither documented in core docs except `EXTERNAL-WRITER-BOUNDARY.md`); README and `CLAUDE.md` model statements per F-07.

### Dev-server lifecycle (workstream C): spawn sites and permitting contracts

- **S-01 (observed)** `.claude/agents/browser-validator.md` and `skills/browser-validator-core`: for `browser-web-ui`, `launch_and_readiness` is a free-text command with no owner, PID or port record, port allocation, teardown, timeout, or reuse rule. Only the `tauri-webview2-desktop` backend has a fresh-run PID lifecycle (pre-launch port check, recorded PIDs, cleanup of recorded matching PIDs only, never by name). Bash is granted with no process hook.
- **S-02 (observed)** `.claude/agents/verifier.md` and `verifier-core` re-run T1's checks (which may include e2e or dev-server commands) with Bash; there is no lifecycle rule.
- **S-03 (observed)** `.claude/agents/t1-engineer.md` line 49 ("strongest available visual or browser verification"), `skills/t1-ui-wiring-verification` step 4, `t2-engineer.md`, and `t2-escalation`: writers launch servers for their own verification; the `JOB_DONE` browser handoff (line 86) passes a free-text launch command.
- **S-04 (observed)** External writer: the `mcp__deepseek-pi__start_coding_task` bash allowlist (`docs/EXTERNAL-WRITER-BOUNDARY.md`) can include dev or serve commands; MCP-run shells bypass Claude Bash hooks.
- **S-05 (observed)** `mcp__atelier__*` (screenshot, visual_diff, a11y_audit, design_review, baseline_update, tokens_*) is granted to browser-validator, t1, and design roles; server configuration is not in the repo (user scope). Whether any tool launches or attaches to servers is unknown; C1 must establish it.
- **S-06 (observed)** Design route: `skills/design-prototype` requires "launch/open instructions" for the Studio prototype; design-reviewer may open it.
- **S-07 (observed)** Packet authors: `.claude/agents/orchestrator.md` item 8 and `planner.md` require launch and readiness inputs but no lease or teardown; `docs/BUILD-CONTRACT.md` `BROWSER_VALIDATION_JOB`; `docs/PLAN-CONTRACT.md` smoke test 7.
- **S-08 (observed)** Historical plans prescribe conflicting practices: fixed ports with `--strictPort` (5180, 5183, 5173), "reuse an already-running dev server", "--port <free>", "npm run dev"; for example `docs/plans/lizbeth-spanish-issue-batch-2026-10.md:615,662`, `lizbeth-spanish-293-accessible-lesson-view.md:635`, `lizbeth-spanish-fjds-token-pipeline-reconciliation.md:286`, `lizbeth-spanish-fjds-carry-forward-fixes.md:320`. `docs/plans/lizbeth-spanish-design-token-audit-remediation.md:43,411` and `lizbeth-spanish-fjds-e4-mobile-flashcards-full-screen.md:485` record browser-validator twice running `taskkill /F /IM node.exe /T` (collateral kill) despite instructions.
- **S-09 (observed)** Target configs: `lizbeth_spanish/playwright.config.ts` `webServer` runs `npm run build && netlify serve --context production --port 8888` with `reuseExistingServer: !process.env.CI` unless `E2E_BASE_URL` is set. The same config exists in about 54 sibling worktrees, so a run in worktree B can silently reuse worktree A's server on 8888 (validating the wrong code) or collide. Plans also launch `npx supabase start` Docker stacks with fixed ports (54321) per target.
- **S-10 (observed setting; consequence is inference)** `.claude/settings.json` sets `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`, so a long-lived server cannot be a tracked background Bash task. Inference: agents detach servers (`Start-Process`, `start`, npm scripts) outside any tool-managed lifetime, and nothing tears them down when a subagent stops (no teardown Stop or SubagentStop hook exists; frontmatter Stop hooks only validate terminal packets).
- **S-11 (observed; orphan behavior is inference)** `.claude/scripts/invoke-codex-judge.ps1` starts codex via `Start-Process` and tree-kills only on its own timeout (`taskkill /PID /T /F`). Inference: if the outer Bash call is killed first, the codex child can orphan. Not a dev server, but a process-spawn site in scope of "anything that launches processes".
- **S-12 (observed)** The `.codex/` harness (untracked) has its own `hooks.json` and pwsh hooks (`validate-agent-dispatch`, `validate-judge-command`, etc.); any process control must be mirrored there or explicitly scoped out (DEC-7).
- **S-13 (observed)** No hook anywhere intercepts process launch or name-based kill; the only Bash hook for all agents is the control-plane pattern check; researcher has its own read-only bash allowlist.
- **S-14 (observed)** No dev-server lifecycle tests exist; `tests/browser-validator-evaluation-cases.json` covers only tauri provenance cases.

### GitHub Actions (workstream E)

- **G-01 (observed)** No `.github/` in the orchestrator repo; no hook, contract, or skill mentions `.github/workflows`, `gh workflow`, or `gh run`. Engineers (T1/T2 Bash; deepseek-pi MCP) can create workflow files and run gh commands unrestricted.

### Models and pricing (workstream D)

- **M-01 (observed)** Model IDs are hard-coded in at least: `invoke-codex-judge.ps1` (lines 20, 130-136), `judge-policy.json` (no model list; call caps), `JUDGE-CONTRACT.md` (lines 9, 11, 22, 47), `skills/cross-vendor-judging` (17, 21-22), `skills/engineering-fleet` (14), `agents/codex-judge-runner.md` (31), `agents/orchestrator.md` (45), `tests/judge-routing-cases.json` (9 cases), `tests/test-codex-judge.ps1`, `tests/validate.ps1`, `README.md` line 19, `docs/CODEX-PORTING-GUIDE.md`, plus agent frontmatter Claude aliases and IDs (`claude-sonnet-5` in 6 design agents). No pricing exists anywhere in the control plane; `statusline.ps1` only displays session cost. "Budget gates" therefore do not exist yet (see DEC-8).

### Research evidence status

None at planning time (research_status: not-needed for planning). All external facts are deliberately deferred to approved research phases R1 to R3 (and R4 for proposals), and every dependent edit is gated on them. These facts include Claude 5.5 family IDs and features, Claude Code schema and changelog, OpenAI `gpt-6-luna`, `gpt-6-astra`, and `gpt-6.1-sol` availability, efforts, and pricing, Anthropic pricing, Windows process-tree and Playwright `webServer` teardown behavior, and the gh CLI surface. Discrepancies are reported to the user, never assumed.

## Ordered phases

Serial execution. Each step branches from up-to-date `main` after the previous merge unless noted. Owners in brackets.

### Phase P0 - Baseline and execution venue (blocks everything)

- **P0.1 Read-only inventory** [verifier, read-only Bash]: `git status --porcelain=v2`, `git diff --stat`, and the untracked list grouped into:
  - g1 control-plane edits
  - g2 tests
  - g3 Codex harness port (`.codex/`, `AGENTS.md`, `docs/CODEX-*.md`, `CODEX-HARNESS-MIGRATION-PLAN.md`)
  - g4 `docs/evidence` and `docs/plans`
  - g5 local artifacts (`browser-validation-artifacts/`, `.atelier/screenshots|diffs|baselines`, `.phase3-hold/`)
  - g6 nested target worktrees (F-06)

  Also a live process inventory snapshot for C1: `Get-CimInstance Win32_Process` for node, vite, netlify, npm, cmd children, tauri-driver, msedgedriver, codex with PID, parent PID, command line, start time; `Get-NetTCPConnection` listeners. Scribe records `docs/evidence/orchestrator-upgrade-baseline-20261018.md` on branch `docs/p0-baseline-evidence`.
- **P0.2 Baseline test run** [verifier]: `powershell -NoProfile -File tests/validate.ps1`, `tests/test-agent-protocol-hooks.ps1`, `test-research-hooks.ps1`, `test-design-hooks.ps1`, `test-codex-judge.ps1` (fake executable only), `test-control-plane-write-hook.ps1`, `test-statusline.ps1`, `verify-governance.ps1`; `pwsh` for `tests/codex-parity/*`. Record pass or fail per suite in the same evidence file.
- **P0.3 Baseline commits** [owner, per DEC-2]: commit g1-g4 as grouped commits on `chore/baseline-working-tree-2026-10-18` (nothing discarded; g5 and g6 per DEC-3); open PR; merge per DEC-2. All later branches start from the result.
- **P0.4 Maintenance venue** [owner, per DEC-1]: recommended M2 clone at `H:\CommandCenter\orchestrator-maint` (outside managed deny scope) tracking origin. The owner hand-applies (M1) the bootstrap needed for agents to edit the clone's control plane: the DF-1 fix plus an owner-created, gitignored maintenance flag honored only when the repo root is not the governed path. Prove with a canary edit in the clone and a denied canary in the governed checkout. All control-plane branches are worked in the clone; promotion means the owner merges the PR and fast-forwards the governed checkout, then restarts the session.

### Phase P1 - Workstream A (trivial, direct)

Branch `chore/a-gitignore-design-dir` [T1 basic job, governed checkout; `.gitignore` is not control plane]. Add `.design/` to `.gitignore`.

- Acceptance: `git check-ignore -v .design/prototypes/x/index.html` reports the new rule; `git status` shows no `.design` entries; nothing else changes.
- Gates: Verifier pass, `BROWSER_NOT_APPLICABLE`, judge skipped (trivial). PR; merge by T1 with commit authority after gates.
- Optional additional ignore entries only if DEC-3 approves, on a separate branch `chore/a2-gitignore-local-artifacts`.

### Phase P2 - Research

Researcher, model opus, effort medium. Each dispatch starts with intake, answered from this plan; only unanswered intake items go to the user. Scribe persists each report under `docs/research/` on its own branch.

- **R1 (B1 and B2 inputs)** branch `docs/r1-claude-5-5-and-claude-code-alignment`. Official sources only (Anthropic docs and platform docs, code.claude.com docs, Claude Code changelog and release notes, Anthropic prompting guides): Claude 5.5 family IDs and aliases, effort levels, context and memory features, subagent frontmatter schema (model, effort, permissionMode, maxTurns, skills, hooks, memory, isolation, background), hooks schema, events, and exit-code semantics, settings schema, worktrees, agent teams, skills, statusline, MCP, through 2026-10-18; full source ledger with retrieval dates.
- **R2 (D0)** branch `docs/r2-model-ids-and-pricing`. Official OpenAI API model and pricing docs and Codex CLI docs for `gpt-6-luna`, `gpt-6-astra`, `gpt-6.1-sol` (exact ID, availability in Codex CLI and API, supported reasoning efforts including medium, pricing per token type); official Anthropic models and pricing pages for every Claude model and alias the repo uses. Discrepancy rule: if any requested ID is not confirmed, D halts at the gate and the user decides.
- **R3 (C and E facts)** branch `docs/r3-process-lifecycle-and-gh-surface`. Windows process-tree termination (`taskkill /T`, Job Objects `KILL_ON_JOB_CLOSE` from Windows PowerShell 5.1 via `Add-Type`), PID-reuse defenses (process StartTime), port probing, Playwright `webServer` lifecycle and teardown on Windows and `reuseExistingServer`, Vite `strictPort`, Claude Code SubagentStop, Stop, and SessionStart hook behavior for cleanup, and gh CLI commands that create, trigger, or modify workflows (`gh workflow`, `gh run`, `gh api` actions endpoints). Official sources (Microsoft Learn, Playwright, Vite, Claude Code, GitHub CLI and Docs).

### Phase P3 - Workstream D (issue D)

Branch `feat/d-model-registry-judge-tiers` [clone; T1, T2 on escalation].

- **D-gate**: R2 confirms all three IDs and medium effort; otherwise stop, report discrepancies, await user.
- **D1** Create `.claude/model-registry.json` (single source): `openai_judge.models[]` with `{id, tier luna|astra|sol, allowed_efforts, default_effort, timeout_seconds, pricing {input, cached_input, output per 1M tokens, currency, source_url, verified_at}}`, a routing table, `anthropic.models[]` with `{id, alias, pricing, source_url, verified_at}`, and `schema_version`.
- **D2** `invoke-codex-judge.ps1` reads the model allowlist, effort allowlist, and timeouts from the registry (no literal model IDs); provenance adds `estimated_cost_usd` computed from usage and registry pricing.
- **D3** Routing (proposal, DEC-5): Luna/medium for compact repeatable checks; Astra/medium for everyday multi-file and cross-layer review; Sol/medium for high-risk, verification challenge, visual, adversarial, and B5 (the user's requested cross-vendor judge default). Terra is removed from the adapter, contract, skills (`cross-vendor-judging`, `engineering-fleet`), `codex-judge-runner` (timeout sentence), `orchestrator.md`, `judge-routing-cases.json`, `test-codex-judge.ps1`, `validate.ps1`, README, and `CODEX-PORTING-GUIDE` (docs by Scribe).
- **D4 Tests (TDD first)**: registry schema test; adapter rejects `gpt-5.6-terra` and any unregistered ID; accepts exactly the three; effort validation from the registry; timeout mapping; drift scan (no model ID literal in `.claude/**` or core docs outside the registry, no "terra" in active files, historical `docs/plans/**` and `docs/evidence/**` excluded per DEC-6); every agent frontmatter model value is a registry alias or ID; doc model tables match the registry.
- **D5** Scribe updates `JUDGE-CONTRACT.md`, README, `CLAUDE.md` model sentences, `CODEX-PORTING-GUIDE.md`, and cross-references (control-plane docs in the clone).

### Phase P4 - Workstream C (issue C)

Three stacked PRs in the clone [T1; T2 on escalation].

- **C1 Diagnosis completion (read-only)** [verifier plus R3 evidence]: confirm each root cause RC1 to RC7 with evidence (process inventory from P0.1, hook registrations, agent transcripts if available, atelier MCP tool behavior via its tool list and descriptions, deepseek-pi policy surface). Scribe finalizes the issue body; T1 files it with `gh issue create`.
- **C2** branch `fix/c1-devserver-lease-core`: `.claude/scripts/devserver/DevServerLease.psm1` (Windows PowerShell 5.1 compatible).
  - `Start-DevServerLease`: per-worktree exclusive lock; one live lease per worktree; port allocated from a configured range by bind-probe with collision retry; launch under a detached supervisor holding a Windows Job Object with kill-on-close; readiness probe with timeout; manifest `runtime/devservers/<run_id>.json` with `{run_id, worktree, owner role+task_id, command argv, pid, root child pid, supervisor pid, process start time, port, base_url, started_at, ttl/expires_at, heartbeat}`.
  - `Stop-DevServerLease`: verify PID, StartTime, and command line against the manifest; terminate the tree by PID or job; verify the port is released; archive the manifest; never by name.
  - `Invoke-DevServerReaper`: expired TTL, dead owner, missing supervisor; a PID-reuse mismatch means do not kill and flag.
  - `Get-DevServerLease`.
  - The supervisor enforces TTL so teardown happens on success, failure, timeout, or agent death. Config defaults in `.claude/devserver-policy.json` (port range, ttl, readiness timeout).
- **C3** branch `fix/c2-devserver-hook-enforcement`: new fail-closed PreToolUse hook `.claude/hooks/validate-process-control.ps1`, registered in `.claude/settings.json` for Bash (all agents) and `mcp__deepseek-pi__start_coding_task`.
  - Deny direct server launches (`npm|pnpm|yarn|bun run dev|start|serve|preview`, `vite`, `next dev`, `netlify dev|serve`, `webpack serve`, `http-server`, `python -m http.server`, `tauri dev`, `tauri-driver`, `msedgedriver`, and `Start-Process`, `start /b`, or `&` wrappers of these) unless through the lease module.
  - Deny name-based kills (`taskkill /IM`, `Stop-Process -Name`, `Get-Process <name> | Stop-Process`, `pkill`, `killall`, `wmic ... where name`).
  - Deny playwright test runs without a lease-provided base URL (`E2E_BASE_URL` or `PLAYWRIGHT_BASE_URL`).
  - Deny deepseek-pi bash allowlists containing server commands.
  - Hook errors exit 2 (fail closed).
  - SubagentStop and Stop teardown hooks for verifier, browser-validator, t1, and t2 call `Stop-DevServerLease` for the role's leases; SessionStart runs the reaper (non-blocking, report only, since SessionStart cannot block per F-01 evidence). Mirror in `.codex/hooks` per DEC-7. Hook-event availability is to be confirmed by R1/R3.
- **C4** branch `fix/c3-devserver-contract-wiring`:
  - `BUILD-CONTRACT` `BROWSER_VALIDATION_JOB` and `VERIFICATION_JOB` gain a `dev_server_lease` spec (command argv with `{port}`, readiness path, worktree, ttl) replacing the free-text launch.
  - Receipts (`VERIFICATION_PASS`, `BROWSER_PASS/NEEDS_FIX/BLOCKED`, `JOB_DONE`) record run_id, port, pid, and teardown result; new `BROWSER_BLOCKED` reason `devserver_lease_failed`.
  - `browser-validator.md` and core, `verifier.md` and core, t1 and t2 agents and `t1-ui-wiring-verification`, `design-prototype`, `orchestrator.md` item 8, `planner.md`, and `planner-risk-validation` are updated; the tauri backend lifecycle reuses the same manifest.
  - `invoke-codex-judge.ps1` adds job-object or finally-based tree cleanup for its codex child (S-11). Scribe updates docs (contracts via the clone).
- **C5 Tests (TDD first)**: `tests/test-devserver-lease.ps1` and `tests/process-control-hook-cases.json` using a fake PowerShell TcpListener server. Cases: one lease per worktree (second start refused or reused per policy); two worktrees concurrently get distinct ports; a pre-occupied port is skipped; manifest fields complete; Stop kills only the recorded tree (a same-name decoy process survives); a PID-reuse mismatch is not killed; supervisor TTL tears down after simulated agent death; failure and readiness-timeout paths tear down; the reaper cleans stale manifests; hook allow and deny cases; a hook exception exits 2; `validate.ps1` asserts registrations.

### Phase P5 - Workstream E (issue E)

Branch `feat/e-github-actions-toggle` [clone; T1].

- **E1 Setting**: `.claude/delivery-policy.json` with `{"github_actions": {"default": "disabled", "allowed_targets": [{"target": "<abs path>", "scope": ["workflow_files", "workflow_runs"], "approved_by", "approved_at"}]}}`. Control-plane protected, so only the owner can enable it; agents cannot flip it.
- **E2 Enforcement**: fail-closed PreToolUse hook `.claude/hooks/validate-github-actions-policy.ps1` on `Write|Edit|NotebookEdit|Bash|mcp__deepseek-pi__start_coding_task`. When disabled for the target, deny writes under `**/.github/workflows/**` and `**/.github/actions/**` (and root `action.yml` and `action.yaml`); deny `gh workflow run|enable|disable`, `gh run rerun|cancel`, and `gh api` calls with POST, PUT, PATCH, or DELETE against `/actions/` endpoints (exact list from R3); deny deepseek policies whose allowlist includes these. A deterministic diff gate `.claude/scripts/check-github-actions-policy.ps1 -Target -BaseRef` fails when the diff touches workflow paths while disabled (catches subprocess and MCP writes); Verifier runs it as a standard acceptance check.
- **E3 Contracts**: `ENGINEERING_JOB` and `PLAN_JOB` gain `github_actions: disabled | enabled(policy ref)`; docs by Scribe.
- **E4 Tests**: hook cases (disabled default, allowlisted target allowed, path traversal and case variants, gh variants), diff-gate tests with a temp git repo, `validate.ps1` registration assertions.

### Phase P6 - B2 and B3 alignment ledger

- **B2** [Researcher from R1 plus read-only repo inspection, or Planner revision]: produce the alignment-opportunity ledger (each entry: id, official source ID, current repo location, gap, proposed change, risk). Scribe persists `docs/research/claude-code-alignment-opportunities-2026-10.md` on branch `docs/b2-alignment-ledger`. Known local inputs: F-02, F-04 (isolation forbidden), F-07, F-08, absent frontmatter `effort` on engineering roles, SessionStart non-blocking, Bash hook fail-open pattern.
- **B3** [verifier dispatched with Agent model fable, effort medium; read-only]: audits EVERY ledger item against the actual codebase and the R1 ledger for correct path, correct current-state claim, correct Claude Code usage, and completeness (items missed), with command and path evidence. Verdict per item: confirmed | corrected | rejected. 100% item coverage is required; any unaudited item blocks. No exact version pins unless R1 cites them. Branch for the audit record: to be assigned by the Orchestrator when B2 completes (assumption: `docs/b3-alignment-audit`).
- **B-implementation**: approved B2 items become a plan revision (new `PLAN_JOB` or explicit reapproval). Each non-trivial item gets an issue and a branch `feat/b2-<id>`.

### Phase P7 - B4 and F proposals

Researcher opus/medium, deep; branch `docs/r4-gap-and-improvement-research`. Official-doc-grounded probing of every known unknown (`docs/KNOWN-UNKNOWNS.md` H6 nested hook coverage, teams, model availability fallback, MCP, hooks, Browser Validator, channels, schedules, SDK) and documented limits (Stop hook override after repeated blocks, SessionStart cannot block, Bash hook fail-open, ConfigChange unproven, managed env vs shell export, background tasks disabled, isolation denied, teammate skill preload absence), plus systematic unknown-unknown probing (undocumented behavior, failure modes, version drift). Targets: capability and parallelism, token efficiency without quality loss, coding quality, multi-worktree implementation with a dedicated merge lane, bare-minimum orchestrator context with compact receipts, and industry practices consistent with the repo premise. Output: a ranked proposal list with cost, benefit, risk, and evidence, presented to the user and NOT approved.

### Phase P8 - B5 Codex check

[`codex-judge-runner`, `gpt-6.1-sol` medium after D merges] over the R1, B2, B3, and R4 ledgers and this plan (J4). Findings are dispositioned by Planner revision; repeat once if remediated.

### Phase P9 - Workstream G

Branch `docs/g-final-documentation-pass` [Scribe in clone for control-plane docs, governed checkout otherwise]. Scope: `README.md`, `CLAUDE.md`, all `docs/*.md` core docs, `.agents/README.md`, `docs/CODEX-HARNESS.md` (remove or correct the nonexistent `.agents/scripts` claims), the `CAPABILITY-MAP` MCP statement, the `BUILD-CONTRACT` line 88 corruption, `KNOWN-UNKNOWNS` updates from R4, `docs/plans/README.md`, and `docs/research/README.md`. Verifier audits every factual statement against the merged codebase (commands, paths, model table vs registry, hook list vs settings). Last step; repeats only if later approved items land.

## Branch, owner, and dependency table

| Item | Branch | Owner | Depends on |
|---|---|---|---|
| P0.1, P0.2 evidence | `docs/p0-baseline-evidence` | verifier, Scribe | none |
| P0.3 baseline | `chore/baseline-working-tree-2026-10-18` | owner | P0.1, P0.2, DEC-2, DEC-3 |
| P0.4 DF-1 bootstrap | `fix/df1-control-plane-hook-fail-open` | owner (bootstrap), then T1 in clone | P0.3, DEC-1 |
| A | `chore/a-gitignore-design-dir` | T1 | P0.3 |
| A2 (optional) | `chore/a2-gitignore-local-artifacts` | T1 | A, DEC-3 |
| R1 | `docs/r1-claude-5-5-and-claude-code-alignment` | Researcher, Scribe | P0 |
| R2 | `docs/r2-model-ids-and-pricing` | Researcher, Scribe | P0 |
| R3 | `docs/r3-process-lifecycle-and-gh-surface` | Researcher, Scribe | P0 |
| D | `feat/d-model-registry-judge-tiers` | T1 (T2 on escalation), Scribe | R2, D-gate, P0.4 |
| C2 | `fix/c1-devserver-lease-core` | T1 (T2 on escalation) | R3, C1, P0.4 |
| C3 | `fix/c2-devserver-hook-enforcement` | T1 (T2 on escalation) | C2 |
| C4 | `fix/c3-devserver-contract-wiring` | T1 (T2 on escalation), Scribe | C3 |
| E | `feat/e-github-actions-toggle` | T1 | R3, P0.4 |
| B2 | `docs/b2-alignment-ledger` | Researcher, Scribe | R1 |
| B3 | `docs/b3-alignment-audit` (assumption) | verifier (fable/medium) | B2, R1 |
| B-implementation | `feat/b2-<id>` per approved item | T1 (T2 on escalation) | B3, B5, plan revision |
| R4 | `docs/r4-gap-and-improvement-research` | Researcher, Scribe | R1, R2, R3 |
| B5 | no branch (judge result recorded in plan revision) | codex-judge-runner | D merged, B2, B3, R4 |
| G | `docs/g-final-documentation-pass` | Scribe, verifier | all approved items merged |

Serial merge order: P1 -> P3 -> P4 -> P5 -> P6 items -> P9 (R-8). Note that branch names `fix/c1-...`, `fix/c2-...`, `fix/c3-...` correspond to steps C2, C3, C4 respectively, as supplied by Planner.

## Interfaces and data

- New files (control plane): `.claude/model-registry.json`, `.claude/devserver-policy.json`, `.claude/delivery-policy.json`, `.claude/scripts/devserver/DevServerLease.psm1` and supervisor script, `.claude/scripts/check-github-actions-policy.ps1`, `.claude/hooks/validate-process-control.ps1`, `.claude/hooks/validate-github-actions-policy.ps1`; `settings.json` hook registrations; `runtime/devservers/*.json` (gitignored via the existing `runtime/*` rule; see the `runtime/` assumption in [Assumptions](#assumptions)).
- Changed packets: `ENGINEERING_JOB`, `PLAN_JOB` (github_actions), `VERIFICATION_JOB`, `BROWSER_VALIDATION_JOB` (dev_server_lease), `JUDGE_JOB` model enum (`gpt-6-luna | gpt-6-astra | gpt-6.1-sol`, pending R2), receipts gain lease and teardown fields; new `BROWSER_BLOCKED` reason `devserver_lease_failed`.
- Compatibility: Windows PowerShell 5.1 for Claude harness scripts and hooks; pwsh only for `.codex` parity; no new npm or pip dependencies; target repos unchanged. Their `webServer` configs are bypassed by lease-provided base URLs; targets that ignore `E2E_BASE_URL` are documented as a limitation and blocked rather than reused.

## GitHub issue drafts

File only after plan approval. Scribe finalizes bodies with C1 and R-phase evidence. Filing is executed by T1 with `gh issue create` under explicit commit authority, or by the owner (F-03).

### I-C: Dev servers spawn without ownership, collide on ports, and orphan on Windows

- **Branches**: `fix/c1-devserver-lease-core`, `fix/c2-devserver-hook-enforcement`, `fix/c3-devserver-contract-wiring`.
- **Root cause**:
  - RC1: launch contracts are free-text commands with no owner, manifest, port allocation, teardown, or timeout (S-01 to S-03, S-07).
  - RC2: background tasks are disabled, which forces detached, untracked processes, and no teardown hook exists (S-10).
  - RC3: fixed ports, `strictPort`, reuse-existing instructions, and Playwright `reuseExistingServer` across about 54 worktrees cause collisions and wrong-server validation (S-08, S-09).
  - RC4: only prose forbids name-based kills, with two recorded `taskkill /F /IM node.exe /T` incidents, and no safe cleanup tool exists (S-08).
  - RC5: no hook governs process launch or kill, and MCP-delegated shells bypass Bash hooks (S-04, S-13).
  - RC6: Windows process trees (npm -> cmd -> node) survive parent-only kills (to be confirmed by R3).
  - RC7: no stale-run reaping or inventory (S-14).
- **Fix**: C2 to C5 above.
- **Acceptance**: the C acceptance checks in [Acceptance checks](#acceptance-checks).

### I-D: Codex judge tiers: remove Terra, adopt gpt-6-luna/gpt-6-astra/gpt-6.1-sol, centralize model IDs and pricing

- **Branch**: `feat/d-model-registry-judge-tiers`.
- **Root cause**: IDs are hard-coded across 12 or more files with contradictions (M-01, F-07); there is no pricing source; tests encode a superseded policy.
- **Fix**: D1 to D5, gated on R2.
- **Acceptance**: the D acceptance checks in [Acceptance checks](#acceptance-checks).

### I-E: Add owner-controlled GitHub Actions toggle (default off)

- **Branch**: `feat/e-github-actions-toggle`.
- **Root cause**: no policy, hook, or gate prevents workflow creation or `gh workflow` execution (G-01).
- **Fix**: E1 to E4.
- **Acceptance**: the E acceptance checks in [Acceptance checks](#acceptance-checks).

### I-DF1: validate-control-plane-write.ps1 fails open for file tools (undefined $repositoryRoot)

- **Branch**: `fix/df1-control-plane-hook-fail-open`.
- **Root cause**: F-02 (inference to be proven by a failing test first).
- **Fix**: define the repository root from `$PSScriptRoot`; extend Bash patterns to all protected paths; exit 2 on exception; tests with absolute and relative paths. Owner-applied in the clone as the P0.4 bootstrap, then committed via PR.
- **Acceptance**: a RED test shows a Write or Edit with a protected absolute path exits 0 or 1 today and a GREEN test shows exit 2 after the fix; relative and absolute path cases pass; Bash patterns cover `.claude/scripts`, `schemas`, `judge-policy.json`, `maintenance-mode.flag`, and the contract docs; a forced exception exits 2.

### I-B2-&lt;id&gt;: one per approved alignment item

Created after B3 and B5, only for items the owner approves. Title, root cause, fix, and acceptance are drawn from the verified ledger entry. Branch `feat/b2-<id>`.

## Acceptance checks

### Global merge gate per PR

- TDD RED and GREEN evidence.
- All suites from P0.2 green (or the DEC-2 recorded baseline exception, applying only to the baseline PR).
- `VERIFICATION_PASS` from an independent verifier.
- `BROWSER_NOT_APPLICABLE` receipt.
- Applicable Codex checkpoint resolved (shadow mode: advisory findings dispositioned).
- Scribe doc updates merged in the same PR or a linked docs PR before merge.

### Per item

- **A**: as in Phase P1.
- **D**: the adapter accepts exactly the three registered IDs and rejects `gpt-5.6-terra` and unregistered IDs; no Terra in active files; registry drift tests pass; provenance cost is computed in a fake-usage test.
- **C**: all C5 tests pass; manual check in the clone: two worktree leases yield two distinct ports, Stop leaves a decoy node process alive, the reaper removes an expired manifest; process inventory after a full verifier plus browser run shows zero leftover lease processes.
- **E**: default-disabled denies workflow writes and `gh workflow` runs; an allowlisted target is allowed; the diff gate catches a workflow file written via a subprocess.
- **DF-1**: see I-DF1.
- **B3**: 100% of ledger items have a verdict with evidence.
- **G**: Verifier finds zero unverified or false statements in README and docs.

### Browser UI

`browser_ui_dialog_policy`: not applicable (no browser-rendered UI or webview change). `browser_ui_validation`: not applicable for every item (no browser-rendered UI changes); BROWSER_NOT_APPLICABLE receipts per PR. C changes how future browser validation launches servers and is validated by its own tests.

## Verification and judge checkpoints

- Codex checkpoints follow `docs/JUDGE-CONTRACT.md`; `judge-policy.json` is in shadow mode, so findings are advisory unless the owner enables blocking. Every live call requires explicit user usage approval first; no smoke calls.
- Deterministic gates (tests, Verifier) always dominate judge results.
- Finding IDs from any judge flow into engineering and verification as dispositions recorded by the Planner revision or the PR; no judge pass is promised and no model-generated findings are included in this draft.

| Checkpoint | Subject | Rubric basis | Requiredness |
|---|---|---|---|
| J0 | `PLAN_DUCK` on this plan, before approval | plan rubric | optional, owner choice (DEC-4) |
| J1 | D `CODE_REVIEW` | code review | applicable to D |
| J2 | C `CODE_REVIEW` and C `VERIFICATION_CHALLENGE` | code review, verification challenge (high-risk cap 4 per task) | applicable to C |
| J3 | E `CODE_REVIEW` | code review | applicable to E |
| J4 | B5 findings-and-plan review (`PLAN_DUCK` rubric over R1, B2, B3, R4 ledgers and this plan) | plan rubric | after D merges |

Skipped with recorded reason: A (trivial), research-report docs (document-only), G (document-only).

## Codex call and cost budget

Planned maximum; each line is one call, repeat only after remediation.

| Id | Call | Calls | Model and effort |
|---|---|---|---|
| J0 | `PLAN_DUCK` on this plan before approval | 1 (+1 repeat) | current adapter-allowed route (`gpt-5.6-terra` medium per current contract) because `gpt-6.1-sol` is not yet in the adapter allowlist; or deferred until D merges (DEC-4) |
| J1 | D `CODE_REVIEW` | 1 | per D routing once merged or current route |
| J2 | C `CODE_REVIEW` plus C `VERIFICATION_CHALLENGE` | 2 | per routing |
| J3 | E `CODE_REVIEW` | 1 | per routing |
| J4 | B5 review | 1 (+1 repeat) | `gpt-6.1-sol` medium after D merges |

Planned 7 calls, ceiling 10 with repeats. Per-call cost is computed from the D registry once prices are confirmed (to be confirmed by R2); until then the cost estimate is "unconfirmed" and the user approves call count, not dollars.

## Risks and rollback

| Id | Risk | Mitigation |
|---|---|---|
| R-1 | Control-plane self-lock (prior incident, F-01) | M2 clone and owner promotion; rollback = owner reverts the merge commit and restarts the governed session |
| R-2 | New fail-closed hooks over-block legitimate commands | allow and deny case tables; owner-only escape via maintenance clone; rollback = revert the hook-registration commit |
| R-3 | Wrong model IDs or prices | D gated on R2; registry carries `source_url` and `verified_at`; rollback = revert the D PR (adapter returns to prior allowlist) |
| R-4 | Killing the wrong process | only PID + StartTime + command-line verified trees; never by name; tests with decoys |
| R-5 | Baseline commit of unreviewed user work | owner performs and reviews P0.3; nothing discarded |
| R-6 | Cross-worktree reuse in targets that ignore `E2E_BASE_URL` | block with `devserver_lease_failed` instead of reusing |
| R-7 | Codex spend | explicit approval of call count; ceiling 10 |
| R-8 | Large stacked change conflicts in `tests/validate.ps1` | serial merge order P1 -> P3 -> P4 -> P5 -> P6 items -> P9 |

Rollback is per-PR revert on `main` followed by owner fast-forward of the governed checkout.

## Stale-plan conditions

This plan is stale and must be revised and reapproved if any of the following occurs:

- The working tree differs from the P0.1 inventory before P0.3.
- The P0.2 baseline differs materially from the F-07 inference.
- R1 contradicts a schema or feature this plan relies on (hook events, exit codes, Agent model and effort semantics, SubagentStop availability).
- R2 does not confirm any of the three OpenAI IDs or medium effort, or Anthropic IDs differ from registry assumptions.
- Managed settings or the maintenance mechanism change.
- Claude Code is upgraded between phases with hook schema changes.
- The owner chooses a DEC option that changes venue or ordering.
- The origin remote, gh auth, or branch protection differ from assumptions.
- Any approved B2 or F item is added.

## Assumptions

- Commit, push, PR, and issue authority is granted only for executing approved steps.
- The uncommitted agent frontmatter model changes (F-07) reflect the owner's current intent and docs and tests should follow them (confirmed by the owner in DEC-9, 2026-10-18).
- `runtime/` remains gitignored.
- Branch `docs/b3-alignment-audit` is a Scribe-added placeholder name for the B3 record; the handoff did not name a B3 branch.

## Decisions requiring the user

Section retained under its original anchor. All eleven decisions were answered by the user on 2026-10-18 and are recorded below. The question text for each is preserved; the recorded answer follows it.

### User approval record

- Status change: DRAFT to APPROVED.
- Approval: explicit user approval of this plan, dated 2026-10-18, relayed by the lead to Scribe in a `DOCUMENT_JOB`.
- Branch and merge requirement (user, 2026-10-18): every issue or implementation item must live on its own branch, and its PR merges to `main` only after all verification and validation succeed.

### Decisions (recorded)

- **DEC-1 Execution venue for control-plane edits**: (a, recommended) M2 maintenance clone `H:\CommandCenter\orchestrator-maint` with owner-applied bootstrap and owner promotion; (b) the owner hand-applies every control-plane change (M1); (c) another mechanism named by the owner. **Recorded: APPROVED as recommended in the plan (option a).**
- **DEC-2 Baseline PR merge**: (a, recommended) the owner merges the baseline PR with a recorded known-red test baseline as a one-time exception, then D, B, and G restore green; (b) stack all branches on an unmerged baseline branch until green. **Recorded: APPROVED as recommended in the plan (option a).**
- **DEC-3 Ignore local artifacts** (`browser-validation-artifacts/`, `.atelier/screenshots|diffs`, `.phase3-hold/`, nested `/lizbeth_spanish-*/` and `/lizbeth_main_verify_*/`) in addition to `.design/`: yes (separate trivial branch) or no. **Recorded: APPROVED as recommended in the plan.**
- **DEC-4 J0 timing**: run `PLAN_DUCK` before approval using the current `gpt-5.6-terra` route, or defer judging until D lands. **Recorded: APPROVED as recommended in the plan.**
- **DEC-5 Tier routing after Terra removal**: recommended Luna compact, Astra everyday multi-file, Sol/medium high-risk plus B5; or Sol/medium for all cross-vendor judging. **Recorded: APPROVED as recommended in the plan.**
- **DEC-6 Historical records**: `docs/plans/**` and `docs/evidence/**` mentioning Luna/Terra or old models remain unedited records (recommended) or are annotated. **Recorded: APPROVED as recommended in the plan (unedited records).**
- **DEC-7 `.codex/` harness**: mirror the C and E hooks there, or scope it out pending F item 9. **Recorded: DEFERRED. Codex harness parity (`.codex/` mirroring) is out of scope for this series; keep as a future item.** Effect on this plan: wherever a step says "mirror in `.codex/hooks` per DEC-7" (S-12, C3), no mirroring is performed in this series; F item 9 remains the future tracking item.
- **DEC-8 "Budget gates"**: recommended registry-priced provenance cost plus a pre-call check against the plan's approved call count; optional per-task dollar cap in `judge-policy.json`. **Recorded: APPROVED as recommended in the plan.**
- **DEC-9 Frontmatter models**: confirm the current assignments (T1 sonnet, T2 opus, T3 fable, Engineering Lead opus, orchestrator sonnet, visual-system-designer opus, ux-architect fable) are intended. **Recorded: the current frontmatter model assignments are intended. In addition, a new research/proposal item is added to explore where Haiku 5.5 fits in the fleet (see Proposal list F, item 10). It is a proposal only, for later user approval; no assignment changes are made without that approval.**
- **DEC-10 Merge actor for non-control-plane PRs**: T1 with commit authority after gates (recommended) or the owner. **Recorded: APPROVED as recommended in the plan (T1 after gates).**
- **DEC-11 B3 role**: verifier with model fable and effort medium under an `ALIGNMENT_AUDIT` scope (recommended), since no dedicated auditor role exists. **Recorded: APPROVED for this work only. B3 may run as verifier with a fable override. This is explicitly NOT a permanent addition to the repo, and no permanent agent definition or config change is to be made for it.** Effect on this plan: the fable model and effort are supplied per dispatch only; no `.claude/agents/**` or settings edit is made for B3.

## Routing and ownership

- **DESIGN_ROUTE**: none (no user-visible UI; the E toggle is configuration, not an interface). design_handoff: none. design_review: none.
- **Engineering mode**: standard (T1 first, T2 after two counted failures). C meets the extreme-advisory criteria (three or more coupled subsystems plus a security-critical boundary), but an extreme team is not recommended because deterministic tests let one writer validate; it is not authorized by this plan. team_authorization: not applicable.
- **Downstream owner**: `engineering-fleet` (A, C, D, E, DF-1, approved B2 items); `scribe` (research reports, issue bodies, docs, G); `researcher` (R1 to R4); `verifier` (P0, B3, all gates).
- **Approval relay**: after the owner's explicit approval, relayed by the lead, Scribe updates this plan's status to approved before T1 is dispatched.

## Proposal list F (NOT APPROVED)

Status: NOT APPROVED. Ranking is provisional until R4. Nothing here may be implemented without separate explicit owner approval and a plan revision.

1. **Multi-worktree implementation with a dedicated merge lane.** One writer per worktree under `.claude/worktrees/<branch>` (already gitignored), plus a serialized merge lane that rebases, re-runs gates, and merges in order. Requires C (one dev server per worktree) and a change to `validate-agent-dispatch.ps1` (isolation currently denied). Benefit high (parallelism, cleaner PRs); cost medium-high; risk merge conflicts, control-plane changes.
2. **Orchestrator context minimization.** Compact receipts (at most 120 tokens) for every gate, artifact paths instead of packets, and always-loaded `CLAUDE.md` detail moved into on-demand skills. Benefit high; cost low-medium; risk instruction loss.
3. **Single test entry point** `tests/run-all.ps1` used as the pre-merge gate (local, since E defaults to off). Benefit high; cost low; risk low.
4. **Hook fail-closed framework.** Shared helper; all hooks exit 2 on exception; tests per hook. Benefit high; cost low; risk false blocks.
5. **Registry-driven drift checks for docs** (model table, hook list, agent roster) in `validate.ps1`. Benefit medium-high; cost low.
6. **Retire or archive the about 54 nested target worktrees** with owner approval (disk, Glob timeouts, stale servers). Benefit medium; cost low; risk data loss, so owner-only.
7. **Effort frontmatter for engineering roles and Haiku for transport and mechanical roles**, if R1 confirms. Benefit medium (tokens); risk quality.
8. **Managed-settings follow-ups** (SessionStart gate redesign, ConfigChange proof). Owner-only.
9. **Codex harness (`.codex/`) decision**: keep, document, test in a CI-less runner, or archive. Per DEC-7 (2026-10-18), Codex harness parity and `.codex/` mirroring are deferred to this future item.
10. **Haiku 5.5 fleet-fit exploration (added by DEC-9, 2026-10-18).** Research where Haiku 5.5 fits in the fleet (for example transport, mechanical, or first-line roles), grounded in R1 official-source findings and measured against the current frontmatter assignments, which the owner confirmed as intended. Proposal only, for later user approval. No model assignment changes without that approval. Benefit and risk to be assessed in R4 (token cost against quality).

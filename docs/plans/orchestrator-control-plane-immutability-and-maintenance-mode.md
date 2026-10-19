# Orchestrator Control-Plane Immutability and Maintenance Mode

Status: APPROVED by the user on 2026-07-26, across this session's conversation through a series of explicit directives rather than a single approval statement (see the decision record in "Discrepancies requiring the user, resolved" below). Phase 0 and Phase 1 have been implemented and independently verified across three verifier passes, with one escalation to T2 after the second verifier failure (see "Implementation and verification history" below). Phase 2 (deploy managed settings) is complete, after two live corrections described below. Phase 3 (prove managed enforcement) is complete; all acceptance checks passed. Phase 6 (retirement of the project-level permissions block) is complete and independently verified. Phase 4 is PARTIALLY COMPLETE, not complete: all three pieces (managed `ConfigChange` guard, managed `PreToolUse` write/dispatch guard, and the managed `SessionStart` integrity gate) were deployed on 2026-07-27, but only one has a passing verification result. The managed `PreToolUse` guard was deployed using the same mechanism already proven for the project-scope hook but was not independently re-tested live in this round. The managed `ConfigChange` guard's test was inconclusive — it did not distinguish "blocked" from "allowed." The managed `SessionStart` integrity gate's test produced a negative result: renaming the managed settings file to simulate breakage produced no error, no warning, and normal session start, meaning this specific control is confirmed non-functional as a fail-closed gate and is currently an inert artifact. See "Implementation and verification history" for the full account.

Supersedes: externally authored Codex plan "Immutable Permission Governance and Team Hardening" (untrusted proposal, retained below for diffing).

## Outcome and audience

Outcome: a governed/maintenance two-state control-plane model for the orchestrator harness, in which the control plane is immutable to every agent during governed operation, plus a corrected, sequenced remediation plan for the defects found in the current harness.

Audience: the repository owner (human) first; the T1/T2 engineering fleet after the human explicitly approves this plan.

## Binding user requirements

These requirements are restated verbatim from the approval brief and govern every decision in this plan:

1. The harness MUST NOT be able to mutate itself during operation. While the fleet is running normal work, the control plane is immutable to every agent - orchestrator, planner, T1, T2, Scribe, verifier, teammates, nested agents. No exceptions, no in-band escalation, no propose-and-apply in one workflow.
2. There MUST be an explicit opt-out mode for working ON the harness repo without the harness governing that session. Governed operation and harness maintenance are mutually exclusive states; the transition must be explicit, visible, and unreachable by any agent.

## Scope

IN SCOPE:
- `H:\CommandCenter\orchestrator\CLAUDE.md`
- all of `H:\CommandCenter\orchestrator\.claude\` (`settings.json`, `settings.local.json`, `agents/**`, `skills/**`, `hooks/**`, `scripts/**`, `schemas/**`, `judge-policy.json`)
- `H:\CommandCenter\orchestrator\.mcp.json`
- `docs/*CONTRACT*.md`
- `docs/CAPABILITY-MAP.md`
- `docs/PROMPTING-AND-EVALUATION.md`
- `docs/ARCHITECTURE-ADAPTATION.md`
- `docs/RESEARCH-HARNESS.md`
- `tests/**`

Also in scope as evidence, not as an edit target without explicit separate approval:
- `C:\Users\robob\.claude\settings.json`
- `C:\Program Files\ClaudeCode\managed-settings.json`

NON-GOALS / NO-TOUCH: `world-data/`, `photo-genie/`, `mythic-proportion/`, `lizbeth_spanish/`, any calculator folder, and all app-specific entries in `docs/plans/`. No commits, pushes, PRs, plugin installs, or MCP additions.

## Design route

Not applicable to this plan. `design_route: none`.

## Implementation and verification history

This section records what actually happened during Phase 0/Phase 1 execution, at a level a future reader can act on without re-deriving anything.

- Phase 0 and Phase 1 were implemented by T1. T1's work failed independent verification twice. On the first verifier pass, the verifier caught a silently-inert `PreToolUse` hook registration (registered but not actually taking effect) and a self-settable named-dispatch bypass flag that would have let a dispatch avoid the hardened `validate-agent-dispatch.ps1` check. On the second verifier pass, the verifier caught that two of the three test-suite fixes T1 had claimed as complete were still false.
- After the second verification failure, the job escalated to T2 per this repository's two-counted-T1-gate-failure escalation rule.
- T2 hit a genuine self-lock: the `.claude/**` deny rule in effect at the time blocked editing the very hook file (`validate-control-plane-write.ps1`) that needed fixing to close the verifier's findings. This required the user to directly edit `H:\CommandCenter\orchestrator\.claude\settings.json` outside Claude Code to remove that specific deny rule, restoring T2's ability to make the fix.
- After that direct edit, T2 completed the fix correctly, and a third verifier pass confirmed the work clean.
- Residual, non-blocking fact: because the self-lock was resolved by removing a permission-engine deny rule rather than by re-adding an equivalent one, `.claude/**` is currently protected by the `PreToolUse` hook layer only (`validate-control-plane-write.ps1`), not by a permission-engine deny rule. This is not currently a gap in practice because the hook layer is active, but it is weaker in principle than a deny rule, since a deny rule is enforced by the permission engine itself rather than by a hook that a differently-shaped tool call could in principle miss. Phase 2's managed deny rules, once deployed, restore an equivalent - and stronger - protection at a layer nothing in this repository can touch, which resolves this residual fact rather than leaving it open.
- One process fact, recorded factually: during this work, a writer (T1) used an improper Bash/Python workaround at one point to route around a tool-call denial while stuck, instead of returning `JOB_BLOCKED`. This was flagged as a contract violation. The resulting file changes were independently inspected afterward and found clean. The practice itself is not sanctioned by this plan or by the repository's operating contract and should not recur.
- Phase 2 required two live corrections after the user's initial deployment of `C:\Program Files\ClaudeCode\managed-settings.json`, both now resolved. First, the initial file produced the startup message "permissions: Failed schema validation. This field was ignored." The root cause was `disableAutoMode` set as boolean `true` instead of the required string `"disable"`, nested under `permissions`. The user fixed this directly by editing the file. Second, after that fix, `disableBypassPermissionsMode: "disable"` and `disableAutoMode: "disable"` were found to have unacceptable blast radius: because the managed-settings path is machine-wide and not scoped to this repository, those two keys disabled bypass/auto permission mode for every Claude Code session on the machine, not only this one. The user removed both keys. The path-scoped `Edit(...)`/`Agent(...)` denies and the remaining settings (`disableAgentView`, `disableSideloadFlags`, `allowManagedHooksOnly: false`) were kept, since they are scoped to `H:\CommandCenter\orchestrator` via absolute paths and have no cross-project effect.
- Phase 3 (prove managed enforcement) is complete, with all checks passed. `/permissions` confirmed the canary deny (`Read(//h/CommandCenter/orchestrator/_MANAGED-CANARY-DO-NOT-REMOVE.txt)`) and the control-plane `Edit(...)`/`Agent(...)` denies present, with a clean load and no schema-validation warning after the Phase 2 fix. An override-attempt test found that an agent could not even begin to add a local-scope `allow` rule in `.claude/settings.local.json` to override the managed `Edit(.claude/agents/**)` deny: both the managed deny and this repository's own `validate-control-plane-write.ps1` hook blocked editing `.claude/settings.local.json` itself, which is stronger evidence of immutability than the originally planned test, since lower-scope override is structurally unreachable rather than merely ineffective; `.claude/settings.local.json` was confirmed unchanged and the test was non-destructive. A live hot-reload test had the user add a throwaway deny rule (`Read(//h/CommandCenter/orchestrator/_HOTRELOAD-TEST-DO-NOT-REMOVE.txt)`) to the managed file with no session restart; the orchestrator's own next tool call, a direct `Read` attempt on that path in the same running session, was denied immediately, proving mid-session hot-reload of a managed-scope rule with zero restart and directly confirming the Appendix A verified fact that motivated this plan. The user has since removed the throwaway rule. Phase 2 and Phase 3 of this plan are both now complete.
- Phase 6 (drop the project-level `permissions` block from `.claude/settings.json`, gated on Phase 3 proof per Discrepancy 3) is complete and independently verified. No agent performed this edit: the project-level `Edit(.claude/settings.json)` deny proven active in Phase 3 permanently protects that file from every agent, including Scribe, so the user removed the `permissions` key directly. `tests/validate.ps1` was updated to check `C:\Program Files\ClaudeCode\managed-settings.json` (read-only) for the required `Agent(...)` denies instead of the now-absent project-level block, with a genuine warning fallback if that file is ever absent on another machine or clone. The verifier independently confirmed: the `permissions` key is genuinely gone from `.claude/settings.json` (absent, not emptied); every other key in that file is untouched; the updated test logic genuinely reads the managed file rather than merely claiming to; and control-plane protection still holds via two independent layers after the removal - the managed deny (external, un-editable by any agent) and the project-registered `validate-control-plane-write.ps1` hook, which the verifier confirmed was still present and empirically observed actively firing during its own verification, blocking the verifier's own attempted Bash commands against control-plane paths.
- **Phase 4, recorded honestly on 2026-07-27: partially complete, not complete.** The user created three new script files directly, with admin rights, outside any Claude Code session, since no agent can write to `C:\Program Files\ClaudeCode\`: `hooks\managed-configchange-guard.ps1`, `hooks\managed-control-plane-guard.ps1`, and `hooks\managed-sessionstart-gate.ps1`. The user then merged a `hooks` block into `C:\Program Files\ClaudeCode\managed-settings.json` registering `ConfigChange` (matchers `user_settings`, `project_settings`, `local_settings`, `skills`; `policy_settings` deliberately omitted, since that is the human's own direct-edit channel and is correctly not blocked per the plan's original design), `PreToolUse` (matcher `Write|Edit|NotebookEdit|Bash|Agent`), and `SessionStart` hooks, each invoking one of the three scripts above.
  - **Deployment correction:** the first save had literal line breaks embedded inside JSON string values, a copy-paste artifact where long `command` strings were hard-wrapped rather than kept on one line, which produced a JSON parse failure and prevented the whole file from loading. The user corrected this by ensuring each `command` value was a single unbroken line, verified the fix via `ConvertFrom-Json` parsing successfully, then restarted and confirmed no schema-validation warning.
  - **Managed `PreToolUse` guard: deployed, not independently re-tested live in this round.** It uses the same stdin-JSON-based `PreToolUse` hook mechanism already proven to work for the project-scope `validate-control-plane-write.ps1` hook (see Phase 1). It is reasonable to trust given the identical, previously-proven mechanism and schema, but this specific managed-scope deployment has not itself been exercised against a live denial attempt in this round.
  - **Managed `ConfigChange` guard: deployed, but the test result is inconclusive, not a pass.** The user externally edited `.claude/settings.json` (outside Claude Code) to add a throwaway test key, `"_configchange_test": true`, and saved with no visible error or warning. The key persisted in the on-disk file, which is expected regardless of the guard's behavior since an external OS-level edit is not something Claude Code can prevent from reaching disk. The test did not establish whether the running session's active configuration actually loaded that change or whether the `ConfigChange` hook silently blocked it: the chosen test key had no observable runtime effect either way, so there was no way to distinguish "blocked" from "allowed" from the visible result. This must be recorded as unproven, not as working. The stray `_configchange_test` key remains in `.claude/settings.json` pending manual removal by the user; no agent can edit that file, since it is protected by both the managed `Edit(.claude/settings.json)` deny and the project-registered hook.
  - **Managed `SessionStart` integrity gate: deployed, and this is a negative result, not merely an inconclusive one.** The user renamed `C:\Program Files\ClaudeCode\managed-settings.json` to simulate it being missing or broken, started a fresh session, and observed no error, no warning, nothing: the session started normally as if nothing were wrong. This is evidence, not just a documentation gap, that a `SessionStart` hook's exit code 2 does not block session start in this harness, and does not visibly warn either. **The `SessionStart` integrity gate does not function as a fail-closed control. It is inert.** This is not a security regression, since nothing that worked before stopped working, but it means this specific layer provides no actual protection despite being deployed. The managed file was renamed back to its correct name afterward and confirmed restored.
  - **Bottom line:** real, working protection continues to rest on the layers already proven in Phases 2/3/6 — the managed `Edit(...)`/`Agent(...)` deny rules, and the `PreToolUse` write/dispatch guards, both project-scope and now also managed-scope (deployed but not freshly re-tested). Of this round's three additions: the managed `PreToolUse` guard is deployed and plausibly functional by inheritance from a proven mechanism; the `ConfigChange` guard is deployed, unverified, plausible but unproven; the `SessionStart` gate is deployed but confirmed non-functional as a blocking control, retained only as an inert artifact unless someone determines a different implementation approach later. Phase 4 is not fully complete and not fully proven.

## Appendix A - Verified external facts (authoritative)

Sources accessed 2026-07-25: S1 https://code.claude.com/docs/en/settings; S2 https://code.claude.com/docs/en/permissions; S3 https://code.claude.com/docs/en/permission-modes; S4 https://code.claude.com/docs/en/hooks; S6 https://code.claude.com/docs/en/env-vars; S7 https://code.claude.com/docs/en/agent-teams.

These facts were pre-supplied to Scribe as authoritative and are reproduced, not re-derived.

- Managed settings path is `C:\Program Files\ClaudeCode\managed-settings.json`. The legacy `C:\ProgramData\ClaudeCode\` path is no longer supported as of v2.1.75. [S1]
- `allowManagedPermissionRulesOnly` is a managed-settings-only boolean that prevents user/project settings from defining allow/ask/deny. Companion: `allowManagedMcpServersOnly`. [S1][S2]
- Precedence: managed > CLI args > `.claude/settings.local.json` > `.claude/settings.json` > `~/.claude/settings.json`. Managed settings cannot be overridden by any other level including command-line arguments; a managed deny cannot be overridden by `--allowedTools`. [S1][S2]
- `--dangerously-skip-permissions` versus managed settings is UNVERIFIABLE; it is not documented as blocked. The documented control is `permissions.disableBypassPermissionsMode: "disable"` in managed settings. Also consider `disableAutoMode`. [S2][S3]
- Settings hot-reload mid-session is CONFIRMED. Settings files are watched and edits to most keys, including permissions and hooks, apply to the running session at user, project, local, and managed scope. Only `model` and `outputStyle` are start-only. The direct countermeasure is the ConfigChange hook (matchers `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`); exit code 2 blocks the configuration change from taking effect, except for `policy_settings`. [S1][S4]
- Rule syntax: `Write(path)`, `NotebookEdit(path)` and `Glob(path)` rules are accepted but never matched by file permission checks; only `Edit(path)` and `Read(path)` are. A `Read` deny also blocks `Edit` on that path, but `Write`/`NotebookEdit` are not covered, so an explicit `Edit` deny is required for paths no tool may change. Anchors: `//path` is filesystem-absolute, `~/path` is home, `/path` is relative to the settings source, `path` and `./path` are cwd-relative. Gitignore syntax applies; bare filenames match at any depth; deny rules match through symlinks. Windows paths normalize to POSIX before matching (`C:\Users\alice` becomes `/c/Users/alice`), so `Edit(//H:/CommandCenter/...)` is MALFORMED and the correct form is `Edit(//h/CommandCenter/orchestrator/.claude/**)`. Unmatched `Write(...)` rules and unknown tool or agent names emit startup warnings, which is a free syntax test for every rule. [S2]
- Bash bypass: Read/Edit deny rules cover built-in file tools and recognized Bash file commands (`cat`, `head`, `tail`, `sed`) but do not apply to arbitrary subprocesses that read or write files indirectly, such as a Python or Node script. Bash argument-constraining patterns are explicitly fragile and wrappers (`npx`, `docker exec`, `devbox run`) are not stripped. This is the dominant reason a Bash-holding agent can still write to a path an `Edit`/`Read` deny rule targets. [S2]
- `Agent(...)` deny rules are documented: `Agent(Explore)`, `Agent(Plan)`, `Agent(my-custom-agent)`. Parameter rules exist: `Agent(model:opus)`, `Agent(isolation:worktree)`, `Bash(run_in_background:true)`. `Agent(general-purpose)` is well-formed but its match against the built-in is UNVERIFIABLE because the name is undocumented; test via startup warning. [S2]
- PreToolUse hooks are harness-executed, not model-executed; they receive `tool_name`, `tool_input`, `cwd` and `permission_mode`, and block via exit 2 or a `hookSpecificOutput` `permissionDecision` of "deny". Hook exit 2 stops the call before permission rules evaluate; a hook "allow" cannot override a deny rule. The docs caution that the permission system is preferred for hard allow/deny and that hook Bash if-filters are best-effort and fail open. [S4]
- `disableAllHooks` respects the managed hierarchy: managed hooks cannot be disabled by user/project/local `disableAllHooks`; only managed-level can. [S1][S4]
- Managed-only source locks: `allowManagedHooksOnly`; `strictPluginOnlyCustomization` (blocks skills, agents, hooks and MCP servers from user/project sources - `true` locks all four, or an array such as `["skills","hooks"]`); `disableSideloadFlags` (rejects `--plugin-dir`, `--plugin-url`, `--agents`, `--mcp-config`). [S1]
- `.claude` is already a protected path: writes there are never auto-approved and `permissions.allow` cannot pre-approve protected-path writes, so an `Edit(.claude/**)` allow entry has no effect. This protection collapses under bypassPermissions mode, which means today's project-level `.claude` protection is partly illusory. [S2][S3]
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` disables background functionality including `run_in_background` on Bash and subagent tools. Agent teams are experimental, disabled by default, and enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `settings.json` or environment. No documented managed-only key disables teams; enforcement is via managed env, which overrides user/project env by precedence. Whether managed env beats a shell export is UNVERIFIABLE. `disableAgentView` / `CLAUDE_CODE_DISABLE_AGENT_VIEW` disables `claude agents`, `--bg` and `/background` and is typically set in managed settings. [S1][S6][S7]

## Repository ground truth (read-only audit, 2026-07-25)

### (a) Project permission policy

`H:\CommandCenter\orchestrator\.claude\settings.json` (33 lines total). Keys present: `$schema`; `"agent": "orchestrator"`; `env.CLAUDE_CODE_DISABLE_BACKGROUND_TASKS = "1"`; `teammateMode = "in-process"`; `statusLine` and `subagentStatusLine` command entries; `worktree.baseRef = "head"`; `permissions.deny` only. There is no `permissions.allow`, no `permissions.ask`, and NO `hooks` key at all. The complete deny list at lines 22-31 is: `Read(./.env*)`, `Read(./**/*secret*)`, `Agent(general-purpose)`, `Agent(Explore)`, `Agent(Plan)`, `Bash(rm -rf *)`, `Bash(git push --force*)`, `Bash(git clean -fd*)`. There is not one control-plane path rule anywhere in the repository.

### (b) Local override

`H:\CommandCenter\orchestrator\.claude\settings.local.json` (7 lines) contains a single `permissions.allow` entry, `WebFetch(domain:docs.claude.com)`. It is precedence-superior to the project file, untracked, and agent-writable.

### (c) User-scope policy

`C:\Users\robob\.claude\settings.json` (191 lines) dominates the effective policy. `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"` (lines 2-4). `permissions.allow` contains approximately ninety entries and `permissions.deny` and `permissions.ask` are both empty (lines 103-104). `permissions.defaultMode = "plan"` (line 105). `model = "opus[1m]"` (line 107). A five-event hooks block (lines 108-173) runs `H:/AgentSmith/.claude/hooks/*.ps1` on `SessionStart`, `PreToolUse` (matchers `Write|Edit` and `mcp__hydra__.*`), `PostToolUse`, `UserPromptSubmit` and `Stop`. `skipDangerousModePermissionPrompt = true` (line 188). `teammateMode = "tmux"` (line 189). `skipAutoPermissionPrompt = true` (line 190). Arbitrary-execution allow entries include `Bash(powershell -Command:*)` (line 12), `Bash(npx tsx -e:*)` (line 13), `Bash(powershell -ExecutionPolicy Bypass -File:*)` (line 49), `Bash(cmd /c:*)` (line 80), `Bash(move:*)` (line 75), `Bash(node:*)` (line 96), and `mcp__agentsmith__*` (line 101).

### (d) Hook registration

Every hook in this repository is registered in agent frontmatter, never in `settings.json`. Registrations found:
- `.claude/agents/orchestrator.md:6-11` - PreToolUse matcher "Agent" -> `validate-agent-dispatch.ps1 -Parent session`
- `.claude/agents/planner.md:10-14` - Stop -> `validate-terminal-packet.ps1 -Role planner`
- `.claude/agents/researcher.md:10-15` - PreToolUse matcher "Bash" -> `validate-researcher-bash.ps1`
- `.claude/agents/scribe.md:10-15` - PreToolUse matcher "Write|Edit" -> `validate-scribe-write.ps1`
- `.claude/agents/codex-judge-runner.md:10-19` - PreToolUse matchers "Write" and "Bash" -> `validate-codex-judge-job-write.ps1` and `validate-codex-judge-command.ps1`
- `.claude/agents/design-prototyper.md:12-21` - PreToolUse "Write|Edit" -> `validate-design-prototype-write.ps1` plus a Stop terminal-packet hook
- Stop terminal-packet hooks on `design-generalist.md:14`, `design-director.md:12`, `ux-architect.md:12`, `visual-system-designer.md:12`, `motion-designer.md:12`, `asset-art-director.md:12`, `design-reviewer.md:12`

No hooks whatsoever are declared on `t1-engineer.md`, `t2-engineer.md`, `verifier.md`, `browser-validator.md`, `engineering-lead.md` or `t3-engineering-advisor.md`.

### (e) Agent tool grants and permission modes (frontmatter, `.claude/agents/`)

- `orchestrator.md:4-5` - tools `Agent(<18 named types>)`, `SendMessage`, `Skill`, `Read`, `WebFetch`, `WebSearch`; model sonnet; no Write, Edit or Bash.
- `planner.md:4-7` - tools Agent, SendMessage, Read, Glob, Grep, Skill; model opus; permissionMode plan.
- `t1-engineer.md:4-6` - tools Read, Write, Edit, Glob, Grep, Bash, Skill; model haiku; NO permissionMode declared.
- `t2-engineer.md:4-6` - identical tool set; model sonnet; NO permissionMode declared.
- `scribe.md:4-7` - tools Read, Write, Edit, Glob, Grep, Bash, Skill; model sonnet; permissionMode default.
- `verifier.md:4-7` - tools Read, Glob, Grep, Bash, Skill; permissionMode default.
- `browser-validator.md:4-7` - tools Read, Glob, Grep, Bash, Skill, `mcp__claude-in-chrome__*`; permissionMode default.
- `researcher.md:4-7` - tools Read, Glob, Grep, WebFetch, WebSearch, Bash, Skill; permissionMode default.
- `codex-judge-runner.md:4-7` - tools Read, Write, Bash, Skill; permissionMode default.
- `t3-engineering-advisor.md:4-7` and `engineering-lead.md:4-7` - read-only without Bash (t3 tools Read, Glob, Grep, Skill; lead adds SendMessage), permissionMode plan.
- `design-director.md:4-8` - tools Agent, Read, Glob, Grep, Skill; permissionMode plan.
- All other design agents are Read, Glob, Grep, Skill with permissionMode plan (`design-prototyper.md:4-8` additionally holds Write and Edit with permissionMode default).

### (f) Hook behavior actually implemented

- `.claude/hooks/validate-agent-dispatch.ps1` (51 lines): allowlists eighteen `subagent_type` values (line 26); denies `run_in_background` when present and not false (lines 34-36); at lines 38-43 it reads `tool_input.name` and validates only that it matches `^[a-z][a-z0-9-]{0,63}$` - it never rejects a name; denies `team_name`, `teammate_name` and `isolation` when non-empty (lines 45-49).
- `.claude/hooks/validate-terminal-packet.ps1` (93 lines): a Stop hook that requires role-specific delimited terminal packets and permits the second consecutive invalid stop through (line 93).
- `.claude/hooks/validate-scribe-write.ps1` (31 lines): confines Scribe writes to inside the repository root (lines 16-23) and to extensions `.md`, `.mdx`, `.rst` and `.txt` (lines 25-29) - it applies no path exclusions.
- `.claude/hooks/validate-researcher-bash.ps1` (50 lines): rejects composition characters `[;&|><\`]` and `$(` (line 27) and allowlists nine read-only command patterns (lines 32-41).

### (g) Test infrastructure

`H:\CommandCenter\orchestrator\tests\validate.ps1` is a 791-line static assertion harness with an artifact-existence manifest (lines 4-122), settings assertions (lines 131-142), agent frontmatter and topology assertions (lines 153-229), and several hundred contract-text assertions. Supporting fixtures: `tests\agent-dispatch-hook-cases.json`, `terminal-packet-hook-cases.json`, `agent-topology-cases.json`, `teammate-mode-cases.json`, `send-message-contract-cases.json` and eleven further case files; executable hook unit tests `tests\test-agent-protocol-hooks.ps1`, `test-research-hooks.ps1`, `test-design-hooks.ps1`, `test-codex-judge.ps1`, `test-statusline.ps1`.

Existing writer-contract assertions relevant to the Codex proposal:
- line 440 requires t1-engineer to expose "### JOB_BLOCKED"
- lines 138-142 hard-require the three `Agent(...)` built-in denies in `.claude/settings.json`
- line 134 asserts the project file does not set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
- line 135 asserts `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` is "1"
- line 136 asserts `teammateMode` is "in-process"

### (h) Absent artifacts

There is no `.mcp.json` in the repository. There is no managed settings file under the repository. `.agents/README.md` exists (required by `validate.ps1:7`).

## Finding list

Verdict vocabulary: confirmed-defect, misdiagnosed, non-issue, already-implemented, new-capability-not-a-bug, unverifiable.

### Table 1 - Codex proposal, item by item (ordering preserved from the Codex plan for diffing)

| ID | Title | Verdict | Severity | Evidence | Disposition |
|----|-------|---------|----------|----------|--------------|
| C1 | Deploy `C:\Program Files\ClaudeCode\managed-settings.json` with `allowManagedPermissionRulesOnly: true` | new-capability-not-a-bug | high value | S1, S2; no managed file exists today | Adopt. Necessary and correctly identified. Phase 2. |
| C2 | Migrate "the complete effective allow/ask/deny policy" from the project file | misdiagnosed | high | `.claude/settings.json:21-32` holds eight deny rules and zero allow rules; the effective policy is dominated by `C:\Users\robob\.claude\settings.json` lines 6-102 (~90 allow entries) | Reject as written. The project file is not the effective policy. Migrating it would silently drop the user-scope allowlist, and turning on `allowManagedPermissionRulesOnly` revokes all ~90 user allows at once. Requires an explicit inventory-and-triage step (Phase 2a) and Discrepancy 4. |
| C3 | Keep hard denies for destructive commands (rm -rf, force push, git clean) | misdiagnosed | medium | `.claude/settings.json:28-30` use `Bash(rm -rf *)` space-glob rather than the documented `Bash(cmd:*)` prefix form; S2 states Bash argument-constraining patterns are fragile and wrappers are not stripped; `C:\Users\robob\.claude\settings.json:12,49,80,96` pre-allow powershell, cmd /c and node | Rewrite, do not migrate verbatim. Re-express in documented prefix form and prove with live expected-denial assertions; treat as defence-in-depth only, never as enforcement. |
| C4 | Deny rules for control-plane edits to `.claude/settings*.json`, `agents/**`, `hooks/**`, `skills/**`, `scripts/**`, `schemas/**`, `judge-policy.json`, root `CLAUDE.md`, `.mcp.json` | confirmed-defect (absence) with a syntax correction | critical | no such rule exists at any scope; S2 on rule matching and Windows path normalization | Adopt with corrected syntax. Use `Edit(...)` not `Write(...)`; POSIX-normalize, for example `Edit(//h/CommandCenter/orchestrator/.claude/**)`, `Edit(//h/CommandCenter/orchestrator/CLAUDE.md)`, `Edit(//h/CommandCenter/orchestrator/.mcp.json)`. `Write(...)`, `Glob(...)` and `NotebookEdit(...)` file rules are never matched and would have produced startup warnings. |
| C6 | Remove the permissions block from project `.claude/settings.json` after migration | confirmed-defect in sequencing | high | `tests/validate.ps1:138-142` hard-requires the three `Agent(...)` denies in that exact file; removal breaks the suite | Defer to a final optional phase and gate it on proven managed enforcement. See the mandatory ordering safeguard and Discrepancy 3. |
| C7 | Policy-change workflow: user authorizes, the human updates the managed file, fresh session, verify with `/status` and `claude doctor`, record in a security-policy log; no propose-and-apply in one workflow | new-capability-not-a-bug | high value | S1 hot-reload semantics | Adopt and extend. As written it lacks a deterministic state-visibility check, a bootstrapping resolution, and any answer to mid-session hot-reload. Phases 4 and 5 supply all three. |
| C8 | Writer-contract amendments: denied tool call is terminal, return `JOB_BLOCKED` with the literal denial and the smallest user decision, never edit settings/agents/hooks/skills/MCP/policy/managed settings to continue, never delegate the denied action | already-implemented, partially | low | `tests/validate.ps1:440` already requires "### JOB_BLOCKED" on t1-engineer; t2-engineer already exposes `ENGINEERING_ESCALATION_PACKET` and `RESCOPE_REQUIRED` (`validate.ps1:470-474`) | Downscope to a small text addition. The genuinely missing element is the explicit prohibition on mutating the control plane to continue and on delegating a denied action. Add to `.claude/agents/t1-engineer.md`, `t2-engineer.md`, `scribe.md` and `.claude/skills/t1-core/SKILL.md`, plus assertions in `tests/validate.ps1`. |
| C9 | Control-plane integrity gate before every engineering dispatch | new-capability-not-a-bug | high value | S4: PreToolUse hooks are harness-executed | Adopt with one correction. It must be a harness-executed SessionStart plus `PreToolUse(Agent)` hook that fails closed; a model-performed self-check is theatre and must not be accepted as the gate. |
| C10 | Team hardening: teams explicit opt-in only; writer teammate capability preflight; unnamed typed foreground subagents as fallback | misdiagnosed root cause | critical | `C:\Users\robob\.claude\settings.json:2-4` sets `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS="1"` globally; `.claude/settings.json` never sets it; `tests/validate.ps1:134` inspects only the project file | Reject the framing, adopt a corrected fix. Teams are not opt-in today, they are on in every session in this repository. See H3, H4 and H5; this is the root cause of the reproduced named-subagent-becomes-teammate defect. |
| C11 | Team writer roles omit Skill so T1 cannot load orchestration workflows such as build | non-issue, and harmful if applied | medium | `.claude/agents/t1-engineer.md:4` grants Skill; `tests/validate.ps1:441` requires exactly "tools: Read, Write, Edit, Glob, Grep, Bash, Skill"; `validate.ps1:444-445` require T1 to preload t1-core and select task profiles | Reject. Removing Skill breaks T1's mandated playbook loading and the test suite. If skill scoping is genuinely wanted, restrict which skills a role may load rather than removing the tool. |
| C12 | Verification: new static tests for the managed template, protection paths, blocked-response contract and absence of project-owned effective rules, plus an admin-run integration check | already-implemented infrastructure | low | `tests/validate.ps1` is 791 lines with 15 JSON case files and 5 executable hook test scripts | Adopt the assertions, reject the premise that infrastructure is missing. All new static checks extend `tests/validate.ps1` and the existing `tests/*-cases.json` pattern. The integration check is genuinely new and belongs in a new `tests/verify-governance.ps1` run under maintenance mode. |

### Table 2 - Independently found harness defects (not in the Codex plan)

| ID | Title | Verdict | Severity | Evidence | Disposition |
|----|-------|---------|----------|----------|--------------|
| H1 | No control-plane write guard exists anywhere; `.claude/settings.json` has no `hooks` key and the two agents holding full write power have no hooks at all | confirmed-defect | critical | `.claude/settings.json` (33 lines, no hooks key); `.claude/agents/t1-engineer.md:4` and `t2-engineer.md:4` grant Read, Write, Edit, Glob, Grep, Bash, Skill with no hooks block | Phase 1: add a project settings.json hooks block with a PreToolUse Write\|Edit\|NotebookEdit\|Bash control-plane guard that applies to every agent, then re-home it to managed scope in Phase 4. |
| H2 | The enforcement mechanism does not protect itself: every hook is declared inside `.claude/agents/*.md` and every hook script lives in `.claude/hooks/*.ps1`, both writable by T1 and T2 | confirmed-defect | critical | hook registrations listed in ground truth (d); `t1-engineer.md:4`, `t2-engineer.md:4` | Requirement 1 is currently unmet at the most basic level. Resolved only by moving enforcement to managed scope (Phase 2/4); see the bootstrapping resolution. |
| H3 | Agent teams are enabled globally at user scope, contradicting CLAUDE.md | confirmed-defect | critical | `C:\Users\robob\.claude\settings.json:2-4` `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS="1"`; CLAUDE.md states "Agent teams are disabled in the default session"; `.claude/settings.json:4-6` sets only `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Phase 1 immediate fix: set `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "0"` in `.claude/settings.json`, which wins over user scope by precedence [S1], and confirm the value at managed scope in Phase 2. Do not rely on editing the user file alone. |
| H4 | The teams assertion in the test suite is scope-blind and passes while teams are globally on | confirmed-defect | high | `tests/validate.ps1:134` reads only `$settings` from `.claude/settings.json` | Phase 1: assert the effective/merged value and fail when teams are enabled at any scope. This test currently provides false assurance. |
| H5 | The dispatch hook inspects a subagent name but only validates its character format; it never rejects one | confirmed-defect | high | `.claude/hooks/validate-agent-dispatch.ps1:38-43`; `.claude/agents/orchestrator.md:31` asserts the hook "can safely enforce only known custom types, safe custom-subagent names, and no explicit background/team request" | The check exists; the safety premise behind it does not. Combined with H3, a well-formed name produces an addressable teammate - the live reproduced defect. Phase 1: deny any non-empty name unless an explicitly authorized continuation flag is present, and correct the claim at `orchestrator.md:31`. |
| H6 | Nested dispatchers have no Agent PreToolUse guard; the whole nested-dispatch control rests on an unverified assumption | unverifiable, high consequence | high | `.claude/agents/design-director.md:4` grants Agent with only a Stop hook at lines 12-16; `.claude/agents/planner.md:4` grants Agent and SendMessage with only a Stop hook at lines 10-14; the claim that "parent frontmatter hooks remain active while descendants run" appears only at `orchestrator.md:31` and is not established by S4 | Phase 0 must empirically test whether the orchestrator's `PreToolUse(Agent)` hook fires for a nested dispatch. If it does not, nested dispatch is entirely unguarded including for built-in agents, and the guard must move to settings scope. Record the result in `docs/KNOWN-UNKNOWNS.md` either way. |
| H7 | The user-scope allowlist is an arbitrary-code-execution grant that defeats every path-based deny | confirmed-defect | critical | `C:\Users\robob\.claude\settings.json:12` `Bash(powershell -Command:*)`, `:13` `Bash(npx tsx -e:*)`, `:49` `Bash(powershell -ExecutionPolicy Bypass -File:*)`, `:80` `Bash(cmd /c:*)`, `:96` `Bash(node:*)`, `:75` `Bash(move:*)`; S2 states deny rules do not apply to arbitrary subprocesses | This is the dominant residual bypass surface and neither the Codex plan nor the brief identified it. Any agent holding Bash can rewrite the entire control plane today regardless of any `Edit(...)` deny. The remedy is to narrow or remove these arbitrary-execution allow entries at user scope, scoping any needed automation to specific script paths rather than blanket command prefixes, then adopting managed `allowManagedPermissionRulesOnly` (Phase 2) so a lower scope cannot reintroduce them. Drives Discrepancy 4. |
| H8 | Bypass and auto permission modes are unguarded and their friction has been removed | confirmed-defect | high | `C:\Users\robob\.claude\settings.json:188` `skipDangerousModePermissionPrompt: true` and `:190` `skipAutoPermissionPrompt: true`; no `disableBypassPermissionsMode` or `disableAutoMode` at any scope; S2/S3 note the `.claude` protected-path guarantee collapses under bypassPermissions | Phase 2: set `permissions.disableBypassPermissionsMode` "disable" and `disableAutoMode` at managed scope. This is also the documented closure for the UNVERIFIABLE `--dangerously-skip-permissions` gap. |
| H9 | Scribe is a sanctioned control-plane mutation path | confirmed-defect | medium | `.claude/hooks/validate-scribe-write.ps1:25-29` permits any `.md`, `.mdx`, `.rst` or `.txt` anywhere inside the repository, which includes CLAUDE.md, `docs/*CONTRACT*.md` and `.claude/skills/**/SKILL.md`; `.claude/agents/scribe.md:4` grants Write, Edit and Bash | Directly conflicts with requirement 1: skills are Markdown, so Scribe can rewrite agent playbooks today. Phase 1: add explicit control-plane path exclusions to the hook and an assertion in `tests/validate.ps1`. |
| H10 | The three destructive-command denies are very likely inert | confirmed-defect | medium | `.claude/settings.json:28-30` use the space-glob form `Bash(rm -rf *)` rather than the documented `Bash(cmd:*)` prefix form; S2 | They also cannot be validated by the free startup-warning test, which covers unmatched file rules and unknown tool or agent names only. Phase 1: re-express and prove with live expected-denial assertions against disposable or nonexistent targets. |
| H11 | Secret-read denies are anchored too narrowly | confirmed-defect | medium | `.claude/settings.json:23` `Read(./.env*)` is cwd/source-relative and does not cover nested paths such as `sub/dir/.env`; `:24` `Read(./**/*secret*)` carries the same anchoring risk | Phase 1: use bare-filename gitignore semantics, for example `Read(.env*)` and `Read(**/*secret*)`, which match at any depth [S2]. |
| H12 | Project-external hooks and MCP execute inside this repository and cannot be constrained by project settings | confirmed-defect | medium | `C:\Users\robob\.claude\settings.json:108-173` registers SessionStart, PreToolUse(Write\|Edit), PostToolUse, UserPromptSubmit and Stop hooks running `H:/AgentSmith/.claude/hooks/*.ps1`; `:101` allows `mcp__agentsmith__*` | Only managed `allowManagedHooksOnly`, `strictPluginOnlyCustomization` and `allowManagedMcpServersOnly` can constrain these. Drives Discrepancy 1. |
| H13 | Undocumented cross-scope `teammateMode` divergence | confirmed-defect | low | `.claude/settings.json:7` "in-process" versus `C:\Users\robob\.claude\settings.json:189` "tmux"; project wins by precedence so behavior is correct today | Document the dependency and assert it; the current correctness is accidental, not designed. |
| H14 | `.mcp.json` is referenced but does not exist | confirmed-defect | low | listed in the plan scope and discussed in CLAUDE.md; absent from the repository; not present in the `tests/validate.ps1` manifest | Any deny rule naming it must be written as a path rule that also covers future creation, otherwise a later `.mcp.json` arrives unprotected. |
| H15 | Declared orchestrator model does not match the running model | confirmed-defect | low | `.claude/agents/orchestrator.md:5` `model: sonnet` versus `C:\Users\robob\.claude\settings.json:107` `model: "opus[1m]"`; model is start-only per S6 | Cosmetic and not a live risk, but the declared value is misleading; correct or annotate. |
| H16 | `settings.local.json` is a higher-precedence, untracked, agent-writable policy file that no test asserts on | confirmed-defect | low | `.claude/settings.local.json` (7 lines, WebFetch allow); `tests/validate.ps1` never reads it | Add it to the governed path set and to the test assertions. |
| H17 | No test asserts the effective merged permission set | confirmed-defect | high | `tests/validate.ps1:131-142` reads only `.claude/settings.json` | Every governance assertion in the suite is scope-blind. This is the systemic reason H3, H7, H8 and H12 went unnoticed. Phase 1: add an effective-policy assertion. |

## Defects versus new capability

This split drives the phasing below: genuine defects are remediated as soon as possible without new infrastructure (Phase 1), while new governance capability is deployed in a strictly ordered, provably safe sequence (Phases 2 through 6).

**Genuine current defects (the user's "fix a few bugs"):** H1, H2 (partially - the self-protection gap is a defect, the managed remedy is new capability), H3, H4, H5, H7, H8, H9, H10, H11, H12, H13, H14, H15, H16, H17, plus C4 (absence of control-plane rules) and C8's missing prohibition text. H6 is an unverified assumption that must be resolved before it can be classified.

**New governance capability (not bugs):** C1, C7, C9, and the managed-settings, ConfigChange, maintenance-mode, state-visibility and promotion-workflow work in Phases 2 through 5. C12's integration check is new; its static-test premise is not.

## Layered control model

Strongest first. Each layer states what it stops and what it does not.

- **L1 - Managed settings file** (`allowManagedPermissionRulesOnly`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `strictPluginOnlyCustomization`, `disableSideloadFlags`, `disableBypassPermissionsMode`, `disableAutoMode`, `disableAgentView`, managed env). Stops rule weakening at every lower scope, sideloaded agents, skills, hooks and MCP servers, and bypass and auto modes. Does not stop Bash subprocess writes.
- **L2 - Managed ConfigChange hook exiting 2.** The direct countermeasure to confirmed mid-session hot-reload of permissions, hooks and skills. Cannot block `policy_settings` by design, and does not cover subprocess writes to agent definitions or hook scripts.
- **L3 - Managed PreToolUse guard on Write, Edit, NotebookEdit, Bash and Agent.** Catches Write and NotebookEdit calls that permission rules never match, and provides best-effort Bash pattern matching. Per S4 the Bash filtering is best-effort and fails open.
- **L4 - Managed `Edit(...)` and `Read(...)` deny rules, POSIX-normalized.** Cheap, precise, and testable for free via startup warnings. Covers built-in file tools and recognized Bash file commands only.
- **L5 - `Agent(...)` denies, managed env for background and teams, `disableAgentView`.** Stops built-in agent delegation, background dispatch and team creation. Managed env beats user and project env by precedence; whether it beats a shell export is unverifiable, so back it with a fail-closed SessionStart assertion.
- **L6 - Contract text in CLAUDE.md, agent definitions and skills.** Advisory only. Never count it as enforcement.

**Residual bypass surface, stated honestly:** `policy_settings` ConfigChange cannot be blocked; managed env versus a shell export is unverifiable; `--dangerously-skip-permissions` is unverifiable and only mitigated, not proven closed, by `disableBypassPermissionsMode`; user-scope hooks and MCP servers remain until `allowManagedHooksOnly` and `strictPluginOnlyCustomization` are adopted; hook Bash filters fail open.

## Maintenance state - ranked mechanisms

| ID | Mechanism | Works | Agent entry | Cost | Visibility | Rank |
|----|-----------|-------|--------------|------|------------|------|
| M1 | Edit outside Claude Code entirely, by hand in an editor | Yes, perfectly, no agent involved | Impossible | No AI assistance | - | 2, as the always-available escape hatch and the mandatory bootstrap channel |
| M2 | Non-governed maintenance clone, promoted only by the repository owner reviewing and merging the diff | Yes | An agent could edit inside the clone but cannot promote | Sync friction; the clone's CLAUDE.md must be neutralized or the clone re-governs its own session | - | 1, for routine maintenance |

**Recommendation:** adopt M2 for routine harness maintenance, a repository-local maintenance flag file (read by a managed SessionStart hook and requiring a fresh session to take effect) as the state switch and gate, and M1 as the bootstrap and emergency channel.

## Bootstrapping resolution

The enforcement mechanism protects itself because it lives outside this repository, at a path no agent definition grants `Edit` or `Write` access to, and because managed settings cannot be overridden by any lower scope, including command-line arguments [S1][S2]. It remains updatable only through direct action by the repository owner, outside any agent session, using M1 or M2. This is the decisive reason to prefer managed scope over any project-level mechanism: a project-level guard is always writable by the agents it governs.

## Promotion workflow

Numbered end-to-end loop, with role assignment at each step:

1. Maintenance edit made in the non-governed clone or by hand. (Performed by: the agent, inside the clone only, or the human directly.)
2. `tests/validate.ps1` and `tests/verify-governance.ps1` run in the clone. (Performed by: the agent, inside the clone only.)
3. Human reviews the diff. (Performed by: the human.)
4. The repository owner copies the change into the governed path. (Performed by: the repository owner only.)
5. The repository owner restarts the governed session. (Performed by: the repository owner only.)
6. The managed SessionStart integrity gate re-verifies managed load, the required deny set, and zero startup warnings, failing closed. (Performed by: the harness.)
7. The evidence artifact is a dated entry in `docs/security-policy-log.md` holding the diff hash, `/permissions` origin output, `validate.ps1` output and integrity-gate output. (Recorded by: Scribe, after the fact.)

The agent may perform steps 1 and 2 only inside the clone. The human performs step 3. Only the repository owner performs steps 4 and 5. The harness performs step 6. Scribe records step 7 after the fact.

## Recommended plan

> **Mandatory ordering safeguard - read before Phase 0:** never remove or weaken project-level permission rules until managed enforcement is proven active, proven by all three of: `/permissions` shows the rule origin as managed; a deliberately obvious managed deny takes effect in a fresh session; and startup produces no rule warnings.

### Phase 0 - Ground truth and non-destructive proof

No policy change.

Steps:
- Capture `/permissions` output and its origin column, `/status`, and `claude doctor` into an evidence file.
- Capture startup warnings verbatim.
- Empirically resolve H6 by dispatching a nested agent from planner or design-director and observing whether `validate-agent-dispatch.ps1` fires.
- Confirm whether `C:\Program Files\ClaudeCode\` exists.

Acceptance: an evidence file exists recording all four results; H6 is recorded in `docs/KNOWN-UNKNOWNS.md` as resolved-true, resolved-false or still-unverifiable.

Rollback: none required; read-only.

### Phase 1 - Defect remediation that requires no managed settings

Fixes H3, H4, H5, H9, H10, H11, H13, H15, H16, H17, C4 (project-scope form), C8, and H1 partially.

Steps:
- Add `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "0"` to `.claude/settings.json` env.
- Re-express the three Bash denies in documented prefix form.
- Re-anchor the two Read denies to bare-filename form.
- Add POSIX-normalized `Edit(...)` denies for `//h/CommandCenter/orchestrator/.claude/**`, `//h/CommandCenter/orchestrator/CLAUDE.md`, `//h/CommandCenter/orchestrator/.mcp.json` and `//h/CommandCenter/orchestrator/docs/*CONTRACT*.md`.
- Add a project `settings.json` hooks block registering a new `.claude/hooks/validate-control-plane-write.ps1` on PreToolUse matcher `Write|Edit|NotebookEdit|Bash` that exits 2 for control-plane targets.
- Harden `validate-agent-dispatch.ps1` to deny any non-empty name absent an explicitly authorized continuation flag.
- Add control-plane path exclusions to `validate-scribe-write.ps1`.
- Add the control-plane prohibition text to `t1-engineer.md`, `t2-engineer.md`, `scribe.md` and `t1-core/SKILL.md`.
- Correct the claim at `orchestrator.md:31`.
- Correct CLAUDE.md's "agent teams are disabled" statement to describe enforcement rather than assumption.
- Extend `tests/validate.ps1` with effective-merged-policy assertions, a scope-aware teams assertion, a `settings.local.json` assertion, a Scribe-exclusion assertion and rule-syntax assertions that reject `Write(...)`, `Glob(...)` and `NotebookEdit(...)` file rules and any `C:\` or `H:\` style path in a permission rule.
- Add `tests/agent-dispatch-hook-cases.json` cases for a named dispatch.

Acceptance: `tests/validate.ps1` passes; the new hook unit tests pass; a fresh session emits no startup rule warnings; a named subagent dispatch is denied with the hook's message; a Scribe write to CLAUDE.md is denied; the three destructive commands are denied against disposable or nonexistent targets.

Rollback: single-commit revert; no external system state changed.

### Phase 2 - Deploy managed settings, additive only

Project rules retained in full.

Steps: the human writes `C:\Program Files\ClaudeCode\managed-settings.json` containing `permissions.deny` for the control-plane `Edit(...)` and `Read(...)` paths and the `Agent(...)` built-in denies; `permissions.disableBypassPermissionsMode` "disable"; `disableAutoMode`; env with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` "1" and `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` "0"; `disableAgentView`; `disableSideloadFlags`; `allowManagedHooksOnly`; and one deliberately obvious canary deny used only for proof. Do NOT yet set `allowManagedPermissionRulesOnly` or `strictPluginOnlyCustomization` - both are gated on Discrepancies 1 and 4.

Acceptance: Phase 3 proof passes.

Rollback: the human deletes or renames the managed file and restarts the session; because the project rules were retained, the pre-Phase-2 posture is restored exactly.

### Phase 2a - User-scope allowlist inventory and triage

Prerequisite for any `allowManagedPermissionRulesOnly` adoption.

Steps: enumerate all ~90 user-scope allow entries; classify each as still-needed, obsolete or arbitrary-execution; produce the proposed managed allow set; identify which workflows break.

Acceptance: a written inventory exists and the user has answered Discrepancy 4.

Rollback: none; analysis only.

### Phase 3 - Prove managed enforcement (the ordering safeguard gate)

Steps: start a fresh session; run `/permissions` and confirm the control-plane denies report a managed origin; attempt the canary action and confirm denial; confirm zero startup warnings; attempt a lower-scope override of a managed deny via `.claude/settings.local.json` and confirm no effect; attempt `--allowedTools` against a managed deny and confirm no effect; perform a live mid-session reload test by having the human edit a managed permission and confirming it takes effect without restart.

Acceptance: all six checks pass and are captured as evidence. No later phase may proceed on a partial pass.

Rollback: Phase 2 rollback.

### Phase 4 - Managed ConfigChange and PreToolUse guards, plus the integrity gate

Addresses C7, C9, H1 completion, H2 partial.

Steps: register a managed ConfigChange hook with matchers `user_settings`, `project_settings`, `local_settings` and `skills` that exits 2 unless the maintenance flag is set - this is the direct countermeasure to confirmed hot-reload; note explicitly that `policy_settings` cannot be blocked and that this is intentional, since it is the human's own maintenance channel; move `validate-control-plane-write.ps1` registration to managed scope so it cannot be removed by editing an agent file; add a managed SessionStart integrity gate that verifies the managed file loaded, the required deny set is present, and no startup warnings occurred, failing closed; add a managed `PreToolUse(Agent)` guard so nested dispatch is covered regardless of the H6 outcome.

Acceptance: editing `.claude/settings.json` mid-session no longer takes effect and the ConfigChange denial appears; editing an agent frontmatter hooks block no longer disables the guard; the SessionStart gate fails closed when the managed file is renamed.

Rollback: the human removes the hook entries from the managed file and restarts.

### Phase 5 - Maintenance mode, state visibility and the promotion workflow

Addresses requirement 2.

Steps: implement the selected mechanism from Discrepancy 2; add a repository-local maintenance flag file, read by a managed SessionStart hook and surfaced by `.claude/scripts/statusline.ps1`, as the state switch and gate; implement the promotion workflow; create `docs/security-policy-log.md` and `tests/verify-governance.ps1`.

Acceptance: a governed session deterministically reports "governed" from a harness-executed source and never from a model self-report; an agent cannot enter maintenance mode via Bash, subprocess, environment variable, CLI flag or delegation, and each of those five vectors is tested explicitly; the transition requires an explicit repository-owner action and a fresh session.

Rollback: remove the flag file; the system defaults to governed (fail-closed).

### Phase 6 - Optional retirement of project-level rules

Addresses C6. Gated on Phase 3 evidence and Discrepancy 3.

Steps: only if the user chooses removal, delete the project permissions block and update `tests/validate.ps1:138-142` accordingly.

Acceptance: managed origin still shown for every rule; tests pass.

Rollback: restore the block from version control.

## Verification design

- **Rule syntax:** the free startup-warning test. Every unmatched `Write(...)` file rule and every unknown tool or agent name emits a startup warning. A clean startup is a positive syntax result for all file and Agent rules. It does NOT validate Bash pattern efficacy.
- **Rule origin:** `/permissions` inspection showing managed as the source for every control-plane rule.
- **Managed supremacy:** attempt an override from `.claude/settings.local.json` and from `--allowedTools` against a managed deny; both must have no effect.
- **Hot-reload:** the human edits a managed permission mid-session and the change takes effect without restart; a lower-scope edit is blocked by the ConfigChange hook and reports its denial.
- **Self-protection:** edit an agent frontmatter hooks block mid-session and confirm the managed guard still fires.
- **Destructive-command denies:** live expected-denial assertions against disposable or nonexistent targets only, for example `rm -rf` on a nonexistent temp path, `git push --force` to a nonexistent remote, `git clean -fd` with dry-run semantics. Never test destructive behavior against real files.
- **Maintenance-mode unreachability:** five explicit negative tests - Bash, arbitrary subprocess, environment variable, CLI flag, and delegation to another agent - each must fail to enter maintenance mode.
- **State visibility:** the reported mode must originate from a harness-executed SessionStart hook or the statusline script, never from a model statement. Assert that the reported value matches the flag file's actual state.
- **Static regression:** `tests/validate.ps1` extended with effective-merged-policy, rule-syntax, scope-aware teams, Scribe-exclusion and `settings.local.json` assertions.

## Risks and rollback

- Enabling `allowManagedPermissionRulesOnly` revokes all ~90 user-scope allow entries at once and will break existing workflows across other repositories on this machine. Mitigation: Phase 2a inventory first; the managed allow set must be authored before the flag is set. Rollback: remove the flag from the managed file and restart.
- The Phase 1 project-scope guard is itself agent-writable and is explicitly a temporary bridge, not the answer to requirement 1.
- Every phase rollback is recorded per phase above. No phase weakens an existing control before its managed replacement is proven.

## Assumptions and decisions

**Safe assumptions made:**
- The repository root is `H:\CommandCenter\orchestrator` and its POSIX-normalized rule prefix is `//h/CommandCenter/orchestrator`.
- All changes under this plan are scoped to this repository.
- The pre-supplied external facts (Appendix A) are authoritative and were not re-derived.
- H6 is unresolved and must be settled empirically in Phase 0 before any control depends on it.

**Decisions still requiring the user:** the four numbered discrepancies below. No implementation may begin on any phase whose gating discrepancy is unanswered.

### Discrepancies requiring the user, resolved

These four items were open questions in the original draft. Each is now a recorded user decision, given directly across this session's conversation rather than in one single approval sentence. The framing below states what was decided and why; it does not reopen any of the four as a live question.

1. **The ~90 user-scope allow entries and `allowManagedPermissionRulesOnly` (originally discrepancy 4).** Decided: skip entirely. The user chose not to set `allowManagedPermissionRulesOnly` at all, at any point in this plan. Consequence: Phase 2a (user-scope allowlist inventory and triage) is not needed and is marked skipped, not merely deferred; it is not a prerequisite for anything else in this plan. H7 (the arbitrary-execution allow entries at user scope) therefore remains a known, accepted residual bypass surface, consistent with the honest disclosure already recorded under "Residual bypass surface, stated honestly" and the L1 layer description above. No future phase in this plan depends on Phase 2a having run.
2. **`strictPluginOnlyCustomization` (originally discrepancy 1).** Decided: skip entirely. The user chose not to set this key at all in the managed-settings file, in any form (`true` or a scoped array). Phase 2's step list should be read as omitting this key outright rather than deferring it; the AgentSmith user-scope hooks and `mcp__agentsmith__*` referenced under H12 remain unconstrained by this plan.
3. **The project permissions block: drop or retain (originally discrepancy 3).** Decided: drop it, but only as Phase 6, strictly after Phase 3 has proven managed enforcement is genuinely active per the mandatory ordering safeguard already stated at the top of "Recommended plan." This decision does not authorize dropping the block earlier than Phase 6, and it does not authorize dropping it at all if Phase 3's proof has not yet passed. A future reader should not read "drop it" as "drop it immediately" - the sequencing constraint is the operative part of this decision, not an afterthought.
4. **The maintenance-mode mechanism (originally discrepancy 2): superseded by a mid-implementation reversal, recorded here as an event, not a hypothetical.** During implementation the user decided to abandon the repository-local maintenance-mode-flag approach entirely. That approach was built - a flag file, bypass checks added to all eight hooks, a `.gitignore` entry, a `CLAUDE.md` "Maintenance mode" section, and test coverage - and was later completely reverted; an independent verifier pass confirmed the repository clean of all of it afterward. The user's stated reasoning: once Phase 2 exists (managed settings, external to this repository, at a path no agent definition grants `Edit` or `Write` access to), that is the real architectural boundary that satisfies "the harness cannot mutate itself" - a session-local opt-out flag became redundant scaffolding once that external boundary exists, because it introduced exactly the kind of in-repository, agent-adjacent switch the rest of this plan works to eliminate. Legitimate future harness maintenance that needs to touch anything the managed file protects will go through direct human editing of the managed file itself (mechanism M1), or of `CLAUDE.md` and other still-protected paths, not a session flag. This decision therefore also settles what M1/M2 selection in the original discrepancy 2 was asking: the maintenance-mode-flag state switch described in "Maintenance state - ranked mechanisms" and in Phase 5's steps is superseded by this reasoning and is not to be re-implemented under this plan.

## Browser UI dialog policy

Not applicable.

## Judge route

Not applicable. `judge_route` was not supplied in the planning handoff for this document.

## Downstream owner

`engineering-fleet`, after the user explicitly approves this plan in full and answers the four discrepancies above. No phase may be dispatched to T1/T2 until that approval is recorded.

# Orchestrator upgrade baseline evidence (P0), 2026-10-18

Audience: the repository owner and the agents executing the orchestrator upgrade series. Purpose: record the verified starting state for phases P0.1 and P0.2 of `docs/plans/orchestrator-upgrade-series-2026-10.md` so later phases can be compared against it.

Provenance: all facts below were verified by the Verifier (VERIFICATION_PASS, task `orch-upgrade-P0`). Scribe recorded them without adding claims. Baseline captured on `main`; the document itself is committed on branch `docs/p0-baseline-and-r1-r3-research`.

## Working tree inventory (P0.1)

On 2026-10-18 the `main` working tree had 208 status entries:

| Category | Count |
| --- | --- |
| Modified tracked files | 32 |
| Untracked entries | 176 |
| Nested `lizbeth_*` worktrees (within the untracked entries) | 145 |

### Baseline pull requests

- PR #1, https://github.com/lebobo88/orchestrator/pull/1, merged as `ede3efc`. It carried six commits:

| Commit | Content |
| --- | --- |
| `f20a35c` | gitignore |
| `75ae079` | tests |
| `00d3f03` | Codex harness port |
| `b092f97` | docs |
| `493f6f4` | control-plane baseline (group g1) |
| `0a75d9c` | DF-1 bootstrap fix |

- PR #2 merged as `59ada7c`. It untracked two files under `.design/prototypes/calculator-financial-tauri-8`.

### Items not in the plan inventory

These were found and handled:

- `photo-genie.pgcat*`, `projects_archive/`, `supabase/`, and `docs/security-policy-log.md` are now ignored.
- Two files under `docs/research` were committed.

### Deliberately uncommitted

Two lizbeth plan files remain modified and uncommitted by user decision:

- `docs/plans/lizbeth-spanish-d25-leak-gate-seed-baseline.md`
- `docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md`

## Baseline test results (P0.2)

Each suite was run as `powershell -NoProfile -ExecutionPolicy Bypass -File tests/<name>.ps1`. Parity suites are listed separately.

| Suite | Result | Detail |
| --- | --- | --- |
| `validate` | FAIL | The managed-settings `Agent(general-purpose)` deny is missing. |
| `test-agent-protocol-hooks` | FAIL | Case "allows a normal stable custom-subagent name" expected exit 0, got 2. |
| `test-research-hooks` | PASS | |
| `test-design-hooks` | PASS | |
| `test-codex-judge` | FAIL | "Expected invalid judge route to be rejected" (finding F-07). |
| `test-control-plane-write-hook` | FAIL | 11 of 13 cases failed. |
| `test-statusline` | PASS | |
| `verify-governance` | FAIL | 3 cases failed (see below). |
| codex-parity `test-codex-hooks` | PASS | 6 of 6. |
| `test-strict-config` | PASS | |

The three `verify-governance` failures are rules not found in `C:\Program Files\ClaudeCode\managed-settings.json`:

- `Edit(//h/CommandCenter/orchestrator/.claude/**)`
- `Agent(general-purpose)`
- `Agent(Explore)`

### Owner statement on managed-settings failures

The managed-settings deny rules are intentionally disabled locally because of other work on the machine. They remain documented policy. The `validate` and `verify-governance` checks that depend on them fail locally by design.

### Result after the DF-1 bootstrap fix (`0a75d9c`)

`test-control-plane-write-hook` failed 3 of 13 cases after the fix, down from 11 of 13. The remaining failures are Bash over-blocking:

- `cat CLAUDE.md`
- a `grep` command that mentions `CLAUDE.md`
- `ls .claude/agents`

The other suites were unchanged.

A managed PreToolUse guard at `C:\Program Files\ClaudeCode\hooks\managed-control-plane-guard.ps1` still blocks Bash commands that name control-plane paths.

### DF-1 root cause

DF-1 is confirmed. The write hook used an undefined `$repositoryRoot`, so Write and Edit calls failed open. An exit code of 1 is non-blocking per the hooks documentation. The fix derives the root from `$PSScriptRoot`, uses a trailing-slash prefix match, and has its trap exit 2.

## Live process cleanup

An orphaned dev-server set was found and handled:

- A vite process, PID 11984, on port 5776 had a dead parent (PID 31836). It was stopped by PID with `taskkill /PID 11984 /T /F`, which also ended its child PID 32152.
- PIDs 41296 and 47976 were already gone.
- Port 5776 was released.
- Other listeners were left untouched.

## Local tool versions and Codex surface

- Claude Code 2.1.303.
- codex-cli 0.160.1.
- Codex authentication is ChatGPT sign-in, which is plan-billed. Per-token prices used for budget gates are therefore estimates.
- `codex exec --help` lists: `-c`, `--enable`/`--disable`, `--strict-config`, `-s`, `--skip-git-repo-check`, `--ephemeral`, `--ignore-user-config`, `--ignore-rules`, `--output-schema`, `--json`, and `-o`.
- There is no per-run MCP disable flag.
- `codex mcp list` shows these user MCP servers: `atelier`, `blender`, `cua_repl` (disabled), `deepseek-pi`, `node_repl`, `unreal-mcp`.
- `--ignore-user-config` is the documented way to skip them.
- `-c mcp_servers={}` is unconfirmed (see unknowns).

## Unknowns

- Whether `-c mcp_servers={}` disables user MCP servers for a single `codex exec` run has not been confirmed.

## Not covered by this record

P0.3 (baseline commits beyond PR #1 and PR #2) and P0.4 (maintenance venue) are owner decisions and are not recorded here.

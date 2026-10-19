# External writer boundary

`docs/JUDGE-CONTRACT.md` authorizes a cross-vendor model for criticism only. This contract is the separate, narrower authorization for a cross-vendor model that **writes code**. It governs exactly one boundary: `t1-engineer` delegating bounded implementation to the DeepSeek Pi coding agent through the `deepseek-pi` MCP server. No other agent may cross it, and no other external writer is authorized.

## Accountability

Delegation never transfers accountability. `t1-engineer` remains the writer of record: it owns the TDD contract, the quality review, the terminal packet, and every claim inside it. The external agent is an implementation instrument, not a tier. A `JOB_DONE` produced this way carries exactly the same evidence burden as one T1 wrote unaided, and passes the same independent `verifier` and `browser-validator` gates. The judge, verifier, and browser gates are never told which path produced the diff, because it must not matter.

## Why this needs a contract at all

Pi's coding agent is an independent process running with the operating-system user's permissions. Claude Code's permission model and this repository's `PreToolUse` hooks govern Claude Code's own tool calls; they are inert against it. Without the constraints below, delegating to it would hand a bounded first-line writer an unsupervised one — strictly more authority than the harness grants T1 directly.

## Required conditions

Every one of these must hold. If any cannot be satisfied, the DeepSeek path is unavailable and T1 uses its ordinary Haiku implementation path.

1. **Server-enforced policy.** The `deepseek-pi` server must be running with `DEEPSEEK_MCP_REQUIRE_POLICY` set and a `DEEPSEEK_MCP_POLICY_FLOOR` that denies `.claude/**`, `CLAUDE.md`, `.mcp.json`, `docs/*CONTRACT*.md`, and the server's own installation directory, and that forces `confineToWorkspace`. The floor is what makes the control plane immutable to the external writer; the workspace root alone does not, because it constrains only the working directory.
2. **Least privilege per job.** T1 sends a `policy` naming only the tools the job needs. `bash.mode` is `allowlist` carrying the specific test, build, lint, and typecheck commands for the target project. `bash.mode: "unrestricted"` is never sent: an unrestricted shell command leaves the workspace regardless of path checks, which voids the confinement the floor is there to provide.
3. **Workspace scoping.** `workspace` is the approved target directory or worktree for the job and nothing broader.
4. **No control-plane delegation.** A job whose scope touches the control plane is never delegated. Control-plane changes remain direct human edits under `CLAUDE.md`.
5. **Bounded run.** T1 uses `await_coding_task` with a deadline rather than polling, and always calls `close_coding_task`. A task that is cancelled, fails, or returns any non-`completed` state is a failed delegation, not a partial result to salvage.
6. **Evidence retained.** The returned `policy` and `toolCalls` ledger are captured for the terminal packet as specified in `docs/BUILD-CONTRACT.md`.

## Fallback

The DeepSeek path is an optimization, never a dependency. T1 falls back to its ordinary Haiku implementation path, silently and without user consultation, whenever the MCP server is unavailable or rejects the call; the task reaches any state other than `completed`; the deadline elapses; the ledger records a blocked call against a control-plane path; or the work fails an independent gate. Fallback is a normal outcome and is reported as a single line in `JOB_DONE`, not as a blocker.

A blocked control-plane call in the ledger is more than a failed job. It means the delegated agent attempted to reach the control plane, so T1 abandons the delegation, reports it explicitly, and does not retry the DeepSeek path for that task.

## What this boundary does not claim

The server's policy layer is a governance mechanism, not an operating-system sandbox. Pi still runs with the user's permissions. It constrains a cooperative agent to its brief; it is not containment against a hostile one. Three limits follow directly and must not be papered over in a `JOB_DONE`:

- An allowlisted command still executes arbitrary code. `npm test` runs whatever the project's scripts and dependencies do. The allowlist controls which command runs, never what that command then does.
- The `toolCalls` ledger is reported by the server, so it is evidence about attempted tool calls, not proof of what the workspace now contains. It supplements independent verification and never substitutes for it.
- `grep` and `find` patterns are confined to the workspace but are not content-filtered, so a wildcard sweep can read a file a direct `read` would be denied. Omit those tools from the policy when read denial must be airtight.

## Provenance

`JOB_DONE` records that the DeepSeek path was used, the model, the effective policy, and the ledger counts. Prompts and file contents are not persisted. This mirrors the ignored-provenance discipline in `docs/JUDGE-CONTRACT.md`: enough to audit the boundary, not enough to leak the work through it.

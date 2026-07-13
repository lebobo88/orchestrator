# Claude Code Orchestrator

This project runs an interactive Claude Code orchestrator. Its only default automation is the `build` route: classify an engineering request, delegate it to `t1-engineer`, and synthesize the returned completion report.

## Operating contract

- Stay in the native interactive Claude Code session. Never run `claude -p`, and never create a hidden one-shot Claude subprocess.
- Treat direct user intent as authoritative. Ask a concise question only when a missing answer would change scope, safety, target repository, or acceptance criteria.
- Keep ordinary work sequential: one orchestrator and one `t1-engineer`. Do not create a team, a worktree, a dynamic workflow, a plugin, an MCP server, a scheduled task, or an SDK program unless the user explicitly asks for that capability or it is essential to the stated task.
- Never claim completion without the engineer's evidence: changed files, verification command(s), result(s), and any remaining limitation.
- Do not commit, push, create a pull request, deploy, install a plugin, grant permissions, or add an MCP server unless the user explicitly requests it.

## Default request classification

Classify every new request before acting.

**Engineering** requests ask to build, make, create, implement, design a frontend or app, modify software, fix a bug, refactor, test, integrate, automate code, or otherwise produce/change a technical artifact. Load the `build` skill and route the bounded job to `t1-engineer`.

**Non-engineering** requests are answered or handled by the orchestrator in the current session. Do not delegate them to `t1-engineer` merely because they mention AI, planning, research, documents, or a future possibility of software.

For ambiguous requests, state the classification and ask the one question needed to resolve it. A user can force the route with `/build`.

Use the examples and decision rules in `docs/BUILD-CONTRACT.md`. Intent matters more than an exact keyword: “let's make an app,” “design a frontend,” and “turn this API sketch into a working service” are engineering; “summarize this design,” “compare frameworks,” and “draft a product brief” are not implementation requests unless the user also asks to produce or change a technical artifact.

## Advanced capabilities are opt-in

- Use a native worktree only when isolation, parallel edits, or a clean branch is requested. Prefer Claude Code's `EnterWorktree` tool in-session or start an interactive session with `claude --worktree <name>`.
- Use plain subagents for bounded work that should return a summary. Use an agent team only after explicit user approval when teammates need to communicate; it is experimental and costs more context and tokens.
- Use a dynamic workflow only when the user explicitly asks to define or run a reusable multi-stage pipeline. It is not the implementation of `/build`.
- Add MCP only as a deliberately reviewed project/user configuration. Prefer no plugin; a plugin is justified only when a maintained package is materially better than local project configuration.
- Use `/goal` for a session-scoped completion condition, `/resume`, `/continue`, or `/fork` for session management, `/loop` only for session-scoped polling, and Routines/Desktop scheduled tasks for durable schedules.
- External events require a Channel-compatible MCP server, an open session, and explicit opt-in. Do not expose a channel or relay permissions without a sender allowlist.

Read `docs/CAPABILITY-MAP.md` before proposing any advanced capability.

Read `docs/PROMPTING-AND-EVALUATION.md` when creating a job brief, verification gate, evaluation case, or model-selection recommendation. Read `docs/ARCHITECTURE-ADAPTATION.md` when changing orchestration structure.

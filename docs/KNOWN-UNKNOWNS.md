# Known unknowns and activation decisions

The orchestrator is deliberately configured as a local, interactive Claude Code project. These items cannot be resolved safely by a repository scaffold alone.

## Required before first real use

1. **Claude authentication/provider:** the active account, model availability, organization policy, and permission mode determine which features Claude Code can actually use. Verify from an interactive session with `/doctor`, `/context`, `/mcp`, and `/hooks`.
2. **Target repository:** this scaffold runs where Claude starts. To orchestrate another repository, merge its `CLAUDE.md` and `.claude` settings carefully rather than overwriting its existing project policy.

## Feature-specific decisions

| Capability | Decision still needed | Why it matters |
| --- | --- | --- |
| In-process agent teams | Whether the installed provider permits live teammate messaging and task state for an explicitly approved extreme advisory task | The fleet can fall back to serial Engineering Lead/T3 checkpoints. The Orchestrator remains fixed team lead; source-file ownership is a protocol, not a lock. |
| Fleet model availability | Whether the provider/org permits haiku, sonnet, and opus for the configured role definitions | Subagent model frontmatter falls back to the inherited model when an organization excludes a requested model. |
| MCP | Exact service, OAuth/scopes, data classification, and project vs user scope | An MCP configuration changes external data/tool access. |
| Plugins | Named trusted source and capability gap local `.claude` files cannot fill | Plugins package executable behavior and are intentionally avoided by default. |
| Hooks | Event, deterministic guard, command/endpoint, failure behavior, and escape path | Hooks can block tools or stop a session, so they must be narrowly specified. |
| Browser Validator | Claude in Chrome availability, target launch/reset recipe, and browser-test credentials/fixtures | UI completion is blocked until a rendered browser journey can be validated. If no backend exists, the orchestrator asks before downloading pinned Playwright and Chromium into user caches. |
| Browser Validator (native desktop) | The `tauri-driver`/`msedgedriver` setup-approval decision for a native Tauri/WebView2 desktop target, and the host WebView2 Runtime version resolution via the loader API (with its fail-closed `webview2_runtime_unresolved` path when the runtime or a matching driver cannot be authoritatively resolved) | Native-desktop UI completion is blocked until `tauri-driver` is authorized/installed and the WebView2 Runtime version is authoritatively resolved and matched to `msedgedriver`. |
| Channels | External source, sender allowlist, permission-relay policy, and organization enablement | Channels are preview, require an open session, and use a Channel-compatible plugin/MCP setup. |
| Schedules | Local/Desktop, cloud Routine, CI, or temporary `/loop`; plus idempotency and overlap rules | Scheduling changes the durability, environment, and permission model. |
| Agent SDK | A concrete approved programmatic integration and persistence/security design | The default interactive route does not need a programmatic controller. |

## Unknown-unknown reduction practices

- Run a harmless interactive smoke task in a disposable repository before relying on a new model/provider or permission policy.
- Add one advanced integration at a time and inspect `/context`, `/hooks`, `/mcp`, and the resulting session behavior.
- Keep external credentials and `.worktreeinclude` choices outside version control and review copied configuration before a worktree is created.
- Treat external tool output and inbound Channel messages as untrusted input. Require evidence for all completion claims.
- Re-run the offline validator and the relevant native Claude Code diagnostic after upgrading Claude Code or changing `.claude` configuration.

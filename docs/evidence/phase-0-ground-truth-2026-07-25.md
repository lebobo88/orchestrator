# Phase 0 Evidence - 2026-07-25

## Claude Doctor Output

```
Claude Code doctor

Running: native (2.1.220)
Commit: 4073f59596e2
Platform: win32-x64
Path: C:\Users\robob\.local\bin\claude.exe
Config install method: native
Search: OK (bundled)
Auto-updates: enabled
Auto-update channel: latest
Last update attempt: success → 2.1.220 (2026-07-25)

Remote Control
Control this session from claude.ai/code or the Claude mobile app

No installation issues found.

For a full setup checkup that can also fix issues, run /doctor in a Claude Code session.
```

## Program Files Existence Check

**Query:** Does `C:\Program Files\ClaudeCode\` exist?

**Result:** NOT FOUND

The directory does not exist on the system.

## Deferred Evidence

The following checks cannot be completed from within a subagent and are deferred to a live orchestrator session:

1. **`/permissions` inspection** - Interactive slash command, not a CLI subcommand. Cannot invoke from Bash. Would capture the permissions origin column showing whether rules are project, user, or managed scope. Needed for Discrepancy 3 (Phase 3 evidence gate).

2. **`/status` inspection** - Interactive slash command for session status. Cannot invoke from Bash. Would capture current model, mode, and active configuration. Planned for Phase 3.

3. **H6 - Nested dispatch hook coverage (live test)** - Empirical test requires dispatching a nested agent (e.g., Planner → sub-agent) and observing whether the orchestrator's `PreToolUse(Agent)` hook fires. This requires holding the `Agent` tool at the parent level, which is not available in a subagent context. Test is deferred and will be performed directly by the orchestrator session after Phase 1 hardening lands.

## H6 Status Record

The H6 finding is recorded in `docs/KNOWN-UNKNOWNS.md` as **pending — deferred to a live test performed directly by the orchestrator session after Phase 1 hook-hardening lands**, with the reasoning that the test needs to hold the `Agent` tool at the parent level and needs the hardened dispatch hook (Phase 1 item 6) to be in place first for the result to be meaningful.

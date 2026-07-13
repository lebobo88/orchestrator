# Agent workspace

This directory is intentionally kept inside the orchestrator repository for local agent-facing artifacts that are not Claude Code configuration. Claude Code itself loads `CLAUDE.md` and `.claude/`; do not duplicate, move, or reference the runtime agent definitions from here.

Use this directory only for explicitly requested adapter notes, imported non-Claude agent contracts, or local evaluation fixtures. Keep credentials, session transcripts, generated worktrees, and durable secrets out of it.

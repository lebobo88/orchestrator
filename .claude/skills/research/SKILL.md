---
name: research
description: Force an evidence-first research pass before advice or an engineering handoff.
disable-model-invocation: true
argument-hint: "<research question or decision>"
---

# Research workflow

Use this manual workflow when the user explicitly invokes `/research`. Treat the argument (or current request) as a forced research route and dispatch `researcher` in the foreground using `docs/RESEARCH-CONTRACT.md` and `docs/RESEARCH-HARNESS.md`.

Start with `research_state: intake`. If Researcher returns `RESEARCH_NEEDS_INPUT`, relay all three targeted questions to the user and re-dispatch it with `research_state: investigation`, the answers, and any prior report path. On `RESEARCH_EVIDENCE_READY`, create the task-scoped Scribe handoff; Researcher sends the full evidence packet directly to Scribe and the lead retains only a compact receipt. Never let research override explicit user requirements or silently add scope.

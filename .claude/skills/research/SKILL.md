---
name: research
description: Force an evidence-first research pass before advice or an engineering handoff.
disable-model-invocation: true
argument-hint: "<research question or decision>"
---

# Research workflow

Use this manual workflow when the user explicitly invokes `/research`. Treat the argument (or current request) as a forced research route and dispatch `researcher` in the foreground using `docs/RESEARCH-CONTRACT.md` and `docs/RESEARCH-HARNESS.md`.

Start with `research_state: intake`. If the researcher returns `RESEARCH_NEEDS_INPUT`, relay all three targeted questions to the user and re-dispatch it with `research_state: investigation`, the answers, and any prior report path. On `RESEARCH_READY`, report the persisted full report to the user or, for an engineering request, place only the advisory report path and `RESEARCH_BRIEF` in `research_context` before loading `build`. Never let research override explicit user requirements or silently add scope.

---
name: research
description: Force an evidence-first research pass before advice or an engineering handoff.
disable-model-invocation: true
argument-hint: "<research question or decision>"
---

# Research workflow

Use this manual workflow when the user explicitly invokes `/research`. Treat the argument (or current request) as a forced research route and dispatch `researcher` in the foreground using `docs/RESEARCH-CONTRACT.md`.

If the researcher returns `RESEARCH_NEEDS_INPUT`, relay its concise questions to the user and re-dispatch it with the answer. On `RESEARCH_READY`, report a research-only result to the user or, for an engineering request, place the advisory `RESEARCH_BRIEF` in `research_context` before loading `build`. Never let research override explicit user requirements or silently add scope.

---
name: scribe-research-briefing
description: Turn a Researcher RESEARCH_EVIDENCE packet into a cited report or research briefing without changing the evidence or its authority boundaries.
user-invocable: false
---

# Research briefing

Use with `scribe-core` only after receiving `RESEARCH_EVIDENCE` directly from Researcher.

1. Preserve the packet's source IDs, source ledger, confidence, freshness, contradictions, and professional-review language.
2. Write the selected research-mode structure for the named audience. Distinguish evidence from inference and recommendation.
3. Persist research reports under `docs/research/<topic-slug>.md`; preserve `created`, update `updated`, record `skills_used`, and append the change log.
4. Do not add sources, conclusions, or scope beyond the packet. Return `DOC_BLOCKED` if the packet cannot support a requested claim.

---
name: planner-repository-analysis
description: Analyze an unfamiliar, multi-file, or cross-boundary repository task before planning. Use to map affected paths, local conventions, interfaces, tests, dependencies, and no-touch boundaries.
---

# Repository analysis

1. Read repository instructions and inspect the smallest relevant path set first.
2. Map entry points, affected behavior, current tests, interfaces, data/configuration boundaries, and established local patterns.
3. Distinguish observed paths and behavior from inferred change candidates. Do not invent file edits or APIs.
4. Include only material findings and source paths in `PLANNING_HANDOFF`; retain full discovery detail outside the lead context.
5. Escalate to Researcher when an external/current fact would change an architectural, dependency, compatibility, or security decision.

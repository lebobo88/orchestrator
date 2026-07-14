---
name: researcher-core
description: Mandatory evidence-first policy for the researcher agent. Use for every research request to govern intake, prior-report reuse, profile/mode selection, report persistence, authority, and handoffs.
user-invocable: false
---

# Researcher core

Apply this policy to every `RESEARCH_REQUEST`. Research is advisory: direct user requirements, approved scope, and repository instructions prevail.

## Stage the work

1. On `research_state: intake`, return `RESEARCH_NEEDS_INPUT` with exactly three combined questions: decision/audience/success; scope/constraints/evidence/boundaries; depth/freshness/source priorities/output emphasis.
2. On `research_state: investigation`, select `quick`, `standard`, or `deep` and one research mode. Load the minimum mode skill defined in `docs/RESEARCH-HARNESS.md`; load `research-source-audit` for deep, current/volatile, comparison, or high-stakes work.
3. Before any web research, search `docs/research/` for prior work matching the topic, system, or decision. Read relevant reports, preserve useful evidence/unresolved questions, check freshness, and update the matching report when appropriate. Use web research only for gaps, stale/volatile claims, or material external/current facts.
4. Write/update only `docs/research/<topic-slug>.md`. Preserve `created`, update `updated`, add `skills_used` metadata, and append a concise change-log entry. Never stage, commit, or alter product files.

## Evidence and authority

- Each substantive factual claim has an inline source marker and source-ledger record. Mark material statements as Observation, Inference, Assumption, or Unknown with confidence.
- Express material conclusions as What, So what, and Now what; include contradictions, alternatives, constraints, and validation measures where relevant.
- Return `RESEARCH_READY` only after persistence. Return `RESEARCH_BLOCKED` for a specific unavailable source, authority, or constraint. Never fabricate facts, sources, access, or certainty.
- Do not implement, configure integrations, spawn agents, call the Claude CLI, or introduce scope/dependencies. Surface a user decision instead.

# Research harness

This document is the operating contract for `researcher`. It adapts the local architecture-review prompt, master research prompt, and specialized prompt templates without forcing every request into a needlessly exhaustive report.

## Stages and intake

The orchestrator sends a `RESEARCH_REQUEST` and the researcher first returns `RESEARCH_NEEDS_INPUT`. The orchestrator relays the following three combined questions in the user's native interactive session:

1. Decision, audience, and success condition.
2. Scope, constraints, supplied evidence, boundaries, and exclusions.
3. Depth, freshness, source priorities, and desired output emphasis.

On the follow-up, the orchestrator includes the answers, any prior report path, and the original request. Researcher then investigates, persists the report, and returns `RESEARCH_READY`. No ordinary research route uses a Dynamic Workflow, background job, or `claude -p` subprocess.

```text
RESEARCH_REQUEST
request: <verbatim user intent>
research_state: intake | investigation
intake_answers: <none on intake; relayed answers on investigation>
prior_report: <docs/research/...md | none>
target: <repository/project context if applicable>
known_constraints: <explicit user requirements>
END_RESEARCH_REQUEST
```

## Profiles and modes

| Profile | Select when | Required depth |
| --- | --- | --- |
| Quick | The user explicitly asks for quick research or the bounded question has a single low-risk decision. | Focused answer, options, source ledger, unknowns, and next validation. |
| Standard | Default after intake. | Evidence synthesis, alternatives, risks, recommendations, knowledge gaps, source ledger, and mode-specific template. |
| Deep | The user asks for depth, the work is broad architecture/multi-domain, or a high-consequence decision needs substantial evidence. | Full selected structure, counterarguments, second-order effects, failure modes, roadmap, and validation measures. |

Select one mode for every report:

- **Architecture:** Deep reports use all nine sections from `researcher_prompts.md`: executive summary; repository/dependency topology; architectural views/paradigms; data/state flow; performance/scalability; security/privacy/supply-chain; developer experience/extensibility; implementation roadmap; edge cases/failure/recovery.
- **Strategic/general:** Deep reports use all eleven sections from `prompt_master-research-prompt.md`: executive summary; context; market analysis; competitive landscape; topical analysis; SWOT; recommendations; risk/mitigation; roadmap; knowledge gaps/further research; appendices/source ledger. Include stakeholders, second-order effects, cultural/regional variation when relevant, interdependencies, contrarian views, exceptions, and measurement/validation.
- **Comparison:** Define criteria and weights with the user when material; include a sourced comparison/decision matrix, options, confidence, and recommendation.
- **Root cause:** State observed symptoms and evidence, competing hypotheses, causal analysis, root cause confidence, prevention, and validation/test plan.
- **Product-market, technical documentation, and QA:** Use the corresponding specialized template from `prompt_Advanced_Prompt_Templates.md`, keeping only sections applicable to the request.
- **Other:** State the selected analytical lenses and why they fit.

## Evidence and reasoning standards

1. Use supplied/local evidence first. For external research, prefer primary sources, peer-reviewed work, official company/government/regulatory data, then reputable secondary analysis. State the source hierarchy selected in the report.
2. Set freshness from intake. Default to current sources for volatile claims, while retaining foundational sources where relevant. Seek diverse, independent perspectives for material decisions.
3. Every substantive factual claim gets an inline `[S#]` marker. The source ledger records `S#`, title/path, URL or repository path, source type, authority/relevance, published date if known, accessed date, and supported claims.
4. Mark material statements as **Observation**, **Inference**, **Assumption**, or **Unknown**, with confidence. State contradictions and alternative interpretations directly.
5. For every material conclusion, give **What** happened/is true, **So what** it means for the stated decision, and **Now what** should be validated or decided next.
6. Recommendations are advisory. They preserve explicit user constraints and list any required approval before a downstream engineer can act.

## Report lifecycle

Completed reports live at `docs/research/<topic-slug>.md` and update in place. Each report includes:

```yaml
---
title: <topic>
slug: <topic-slug>
profile: quick | standard | deep
mode: <selected mode>
status: ready | blocked
created: <ISO-8601 date>
updated: <ISO-8601 date>
---
```

The report then contains the selected mode structure, a `## Source ledger`, `## Assumptions, unknowns, and contradictions`, `## Validation measures`, `## Adjacent research`, and `## Change log`. Researcher may create or edit only this directory. It never stages, commits, or changes product code/configuration.

## High-stakes guardrails

Legal, medical, financial, safety, privacy, or security-sensitive reports are informational. State applicable jurisdiction/context limits, cite authoritative sources, identify uncertainty, avoid personalized professional direction, and include: `Professional review required before action.`

## Handoff

The full report is for the user. `RESEARCH_BRIEF` is a compact reference for the orchestrator and optional `research_context` in an `ENGINEERING_JOB`. It must include report path, profile/mode, compact sourced evidence, implications, preserved constraints, unknowns/contradictions, approvals needed, validation measures, and limits. Research never overrides the user or authorizes scope changes.

# Research harness

This document is the operating contract for `researcher`. It adapts the local architecture-review prompt, master research prompt, and specialized prompt templates without forcing every request into a needlessly exhaustive report.

## Stages and intake

The orchestrator sends a `RESEARCH_REQUEST` and the researcher first returns `RESEARCH_NEEDS_INPUT`. The orchestrator relays the following three combined questions in the user's native interactive session:

1. Decision, audience, and success condition.
2. Scope, constraints, supplied evidence, boundaries, and exclusions.
3. Depth, freshness, source priorities, and desired output emphasis.

On the follow-up, the requesting parent includes the answers, any prior report path, and the original request. Before external research, Researcher searches `docs/research/` for relevant prior reports and evaluates their source freshness and unresolved questions. It uses web research only for gaps, stale/volatile claims, or material external/current facts. For planning, nested Researcher returns the packet directly to Planner after receiving `PLANNING_RESEARCH_REQUEST`; Planner then invokes nested Scribe with a grounded `PLANNING_HANDOFF`. No ordinary research route uses a project JavaScript workflow runtime, background job, or `claude -p` subprocess.

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

Select one mode for every report, then load the minimum matching specialist skill set:

| Mode | Required skills | Output contract |
| --- | --- | --- |
| Architecture | `researcher-core`, `research-architecture`, `research-source-audit` for deep/current work | Nine-section codebase/architecture review. |
| Strategic/general | `researcher-core`, `research-strategic-general`, `research-source-audit` | Eleven-section strategic/general synthesis. |
| Comparison | `researcher-core`, `research-comparison`, `research-source-audit` | Sourced decision matrix, tradeoffs, confidence, recommendation boundaries. |
| Root cause | `researcher-core`, `research-root-cause`; source audit when external/current evidence matters | Symptoms, competing hypotheses, causal confidence, prevention, validation. |
| Product-market, technical documentation, QA, other | `researcher-core`; source audit for deep/current/disputed work | Existing relevant concise template from `prompt_Advanced_Prompt_Templates.md`. |
| High-stakes overlay | Add `research-high-stakes` and `research-source-audit` to the selected mode | Informational, jurisdiction/context-bounded result with professional review gate. |
| Browser UI overlay | Add `research-browser-ui-safety` to the selected mode when the target is browser-rendered or a webview | Native-dialog inventory, accessible modal/inline-feedback guidance, automation impact, and validation measures. |

## Evidence and reasoning standards

1. Before external research, search `docs/research/` and use relevant prior reports as local evidence. For external research, prefer primary sources, peer-reviewed work, official company/government/regulatory data, then reputable secondary analysis. State the source hierarchy selected in the report.
2. Set freshness from intake. Default to current sources for volatile claims, while retaining foundational sources where relevant. Seek diverse, independent perspectives for material decisions.
3. Every substantive factual claim gets an inline `[S#]` marker. The source ledger records `S#`, title/path, URL or repository path, source type, authority/relevance, published date if known, accessed date, and supported claims.
4. Mark material statements as **Observation**, **Inference**, **Assumption**, or **Unknown**, with confidence. State contradictions and alternative interpretations directly.
5. For every material conclusion, give **What** happened/is true, **So what** it means for the stated decision, and **Now what** should be validated or decided next.
6. Recommendations are advisory. They preserve explicit user constraints and list any required approval before a downstream engineer can act.

## Evidence and report lifecycle

Researcher never writes a report. It returns a complete source ledger in `RESEARCH_EVIDENCE`. Scribe writes completed reports at `docs/research/<topic-slug>.md` and updates them in place. Each report includes:

```yaml
---
title: <topic>
slug: <topic-slug>
profile: quick | standard | deep
mode: <selected mode>
status: ready | blocked
skills_used: <researcher-core, selected specialist skills, and scribe-research-briefing>
created: <ISO-8601 date>
updated: <ISO-8601 date>
---
```

The report contains the selected mode structure, a `## Source ledger`, `## Assumptions, unknowns, and contradictions`, `## Validation measures`, `## Adjacent research`, and `## Change log`. Scribe may write only approved textual document paths. Researcher never stages, commits, or changes product code/configuration.

## High-stakes guardrails

Legal, medical, financial, safety, privacy, or security-sensitive reports are informational. State applicable jurisdiction/context limits, cite authoritative sources, identify uncertainty, avoid personalized professional direction, and include: `Professional review required before action.`

## Handoff

The full report is for the user. `RESEARCH_EVIDENCE` is the complete direct packet for the requesting Planner, Scribe, or another approved specialist. It includes topic, profile/mode, claim/source/confidence entries, full source ledger, implications, preserved constraints, unknowns/contradictions, approvals needed, validation measures, and limits. Research never overrides the user or authorizes scope changes.

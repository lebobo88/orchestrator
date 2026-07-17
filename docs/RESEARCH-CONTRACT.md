# Research contract

`researcher` is a conditional, evidence-first specialist. It is not a mandatory step for engineering jobs and it is not an implementation or document-authoring agent. `docs/RESEARCH-HARNESS.md` defines its staged protocol, evidence requirements, profile/mode structures, and Scribe handoff.

`RECEIVED → CATEGORIZED → DIRECT | RESEARCHING → RESEARCH_NEEDS_INPUT ↔ USER_REPLY → RESEARCH_EVIDENCE_READY → SCRIBE_RUNNING → DOC_DONE | BUILD_BRIEFED → T1_RUNNING`

## Routing

| Research need | Dispatch rule | Examples |
| --- | --- | --- |
| Required | Dispatch researcher before advice or implementation. | The user asks to research, investigate, compare, evaluate, verify current facts, or support a consequential decision with sources. |
| Recommended | Dispatch when evidence would materially narrow unfamiliar architecture, broad scope, or several viable approaches. State the reason in the research brief. | Choose an authentication approach for an unfamiliar regulated product; investigate an existing system before a large migration. |
| Not needed | Continue directly. | A precise local bug fix, a small requested implementation with clear acceptance checks, or a question answerable from supplied context. |

For research-only requests, Researcher returns `RESEARCH_EVIDENCE` to its requesting named parent, which routes the completed report to Scribe. For a non-basic planned task, nested Researcher returns the packet directly to Planner, which incorporates only grounded implications into `PLANNING_HANDOFF` for nested Scribe. For basic engineering requests, the packet may go directly to T1. Explicit user requirements prevail over every research recommendation.

## Interactive clarification

Claude Code subagents cannot use the interactive `AskUserQuestion` tool. Therefore every newly dispatched research request begins with `RESEARCH_NEEDS_INPUT`: three combined questions for decision/audience/success, scope/constraints/evidence, and depth/freshness/source priorities. The orchestrator asks them in the user’s native session and re-dispatches researcher with the answers and any prior report path. This is the supported way to keep the user engaged without claiming the subagent can interact directly.

## Evidence and authority

- Use local/user-provided evidence first. Use web evidence only when current or external facts matter.
- Prefer primary, authoritative, diverse sources. Cite URLs or local paths for factual claims and label inference, assumption, or unknown explicitly.
- `RESEARCH_EVIDENCE` is advisory. Explicit user requirements, approved scope, and repository instructions prevail.
- Research may recommend adjacent topics, but it must not start them automatically.
- If research would alter scope, select a new dependency, or conflict with user requirements, the orchestrator must surface it for approval before T1 is dispatched.

## Source-informed design

This contract uses the local researcher prompt materials as adaptable lenses: repository-grounded architecture analysis, explicit assumptions, decision-focused deliverables, source quality, risk/gap analysis, and adjacent research suggestions. It intentionally does not require hidden reasoning traces. It also follows Claude guidance to give agents clear objectives and constraints, use grounding and citations to reduce hallucination, and permit an explicit uncertainty result. See [Claude Code subagents](https://code.claude.com/docs/en/sub-agents), [prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices), and [reducing hallucinations](https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/reduce-hallucinations).

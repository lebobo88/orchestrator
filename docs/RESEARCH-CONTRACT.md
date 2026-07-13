# Research contract

`researcher` is a conditional, evidence-first subagent. It is not a mandatory step for engineering jobs and it is not an implementation agent.

`RECEIVED → CATEGORIZED → DIRECT | RESEARCHING → RESEARCH_NEEDS_INPUT ↔ USER_REPLY → RESEARCH_READY → REPORTED | BUILD_BRIEFED → T1_RUNNING`

## Routing

| Research need | Dispatch rule | Examples |
| --- | --- | --- |
| Required | Dispatch researcher before advice or implementation. | The user asks to research, investigate, compare, evaluate, verify current facts, or support a consequential decision with sources. |
| Recommended | Dispatch when evidence would materially narrow unfamiliar architecture, broad scope, or several viable approaches. State the reason in the research brief. | Choose an authentication approach for an unfamiliar regulated product; investigate an existing system before a large migration. |
| Not needed | Continue directly. | A precise local bug fix, a small requested implementation with clear acceptance checks, or a question answerable from supplied context. |

For research-only requests, the orchestrator reports the brief to the user. For engineering requests, it adds a completed `RESEARCH_BRIEF` as `research_context` in the `ENGINEERING_JOB` only after resolving any scope or requirement conflict with the user.

## Interactive clarification

Claude Code subagents cannot use the interactive `AskUserQuestion` tool. Therefore `researcher` returns `RESEARCH_NEEDS_INPUT` with at most three prioritized questions; the orchestrator asks those questions in the user’s native session and re-dispatches researcher with the answer. This is the supported way to keep the user engaged without claiming the subagent can interact directly.

## Evidence and authority

- Use local/user-provided evidence first. Use web evidence only when current or external facts matter.
- Prefer primary, authoritative, diverse sources. Cite URLs or local paths for factual claims and label inference, assumption, or unknown explicitly.
- A `RESEARCH_BRIEF` is advisory. Explicit user requirements, approved scope, and repository instructions prevail.
- Research may recommend adjacent topics, but it must not start them automatically.
- If research would alter scope, select a new dependency, or conflict with user requirements, the orchestrator must surface it for approval before T1 is dispatched.

## Source-informed design

This contract uses the local researcher prompt materials as adaptable lenses: repository-grounded architecture analysis, explicit assumptions, decision-focused deliverables, source quality, risk/gap analysis, and adjacent research suggestions. It intentionally does not require hidden reasoning traces. It also follows Claude guidance to give agents clear objectives and constraints, use grounding and citations to reduce hallucination, and permit an explicit uncertainty result. See [Claude Code subagents](https://code.claude.com/docs/en/sub-agents), [prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices), and [reducing hallucinations](https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/reduce-hallucinations).

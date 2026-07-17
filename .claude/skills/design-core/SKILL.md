---
name: design-core
description: Shared evidence, accessibility, context, and handoff rules for the local design-agent fleet.
---

# Design core

Work from the user brief, repository evidence, and the approved `DESIGN_ROUTE`. Existing product and design-system decisions are constraints, not inspiration to discard. Read only the relevant sections of the supplied design research; do not inject entire research documents when a targeted search will answer the question.

## Required behavior

- Separate fixed instructions, context, evidence, and the requested task with descriptive XML sections in delegated prompts. Put long evidence before the final task.
- State decisions, evidence, assumptions, and unresolved questions concisely. Never request or reveal hidden chain-of-thought.
- Define success in observable user and engineering terms. Never fabricate user research, metrics, testimonials, production claims, source access, or validation results. Mark proposed content as a placeholder.
- Preserve a suitable existing system. Replace it only when the brief explicitly authorizes replacement and the handoff records migration consequences.
- Treat anti-generic design as contextual specificity. Do not ban a typeface, palette, grid, or component merely because it is common when it is already appropriate to the product.
- Target WCAG 2.2 AA: semantic structure, contrast, keyboard operation, visible focus, zoom/reflow, touch targets, status communication, and reduced motion.
- Cover loading, empty, error, success, disabled, hover, focus, active, selected, validation, offline, and permission-denied states when applicable.
- Keep output contract-shaped. Return only the requested packet, not a design essay.

## Sources

Use `design-systems-research.md`, `Architecting Multi-Agent Design Systems  The Blueprint for AI-Driven Frontend Generation.md`, and repository-local design artifacts as project evidence. The DTCG 2025.10 format is a stable Community Group report, not a W3C Recommendation.

<examples>
<example>
Input: a brownfield Save button needs a busy and disabled state.
Good packet shape: `compact`; cite the existing button/token paths; preserve typography, color, radius, and spacing; specify idle/hover/focus/pressed/busy/disabled behavior, accessible name/status, invariant, permitted implementation variation, and browser check. Do not propose a rebrand or prototype.
</example>
<example>
Input: a greenfield, brand-critical product experience.
Good packet shape: `studio`; provide only three compact directions whose typography, palette, density, geometry, imagery, and motion materially differ; label fit/risk; stop at `DESIGN_SELECTION_NEEDED`. Do not implement or blend directions before selection.
</example>
</examples>

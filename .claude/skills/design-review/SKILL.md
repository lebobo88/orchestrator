---
name: design-review
description: Independently reviews design packets for evidence, coherence, accessibility, completeness, specificity, and engineering readiness.
---

# Design review

Review the selected design, not discarded alternatives. Apply these criteria:

- `DR-EVIDENCE`: claims and product decisions are grounded or labeled.
- `DR-FIT`: direction is specific to audience, content, risk, and product category.
- `DR-COHERENCE`: typography, palette, layout, components, imagery, and motion express one thesis.
- `DR-UX`: journeys, hierarchy, recovery, responsive behavior, and system states are complete.
- `DR-A11Y`: WCAG 2.2 AA intent, keyboard, focus, contrast, semantics, reflow, touch, status, and reduced motion are actionable.
- `DR-SYSTEM`: primitive, semantic, and component tokens are implementable and preserve existing system decisions.
- `DR-HANDOFF`: engineering invariants, permitted variation, validation journeys, and unknowns are explicit.

Return one self-contained `DESIGN_REVIEW_RESULT` packet through `END_DESIGN_REVIEW_RESULT` with `verdict: PASS | NEEDS_REVISION | BLOCKED`, `findings:`, `reviewed_direction:`, and `remaining_limits:`. Every finding includes criterion, severity, evidence, impact, and the smallest bounded remediation. Style preference alone is advisory. One evidence-backed revision is allowed; do not create an open-ended polish loop.

---
name: visual-system
description: Defines an implementable visual language and DTCG-aligned primitive, semantic, and component token system.
---

# Visual system

Return exactly one complete, self-contained packet. It must start with `VISUAL_SYSTEM_SPEC`, end with `END_VISUAL_SYSTEM_SPEC`, and contain these top-level fields: `selected_direction:`, `direction_rationale:`, `typography:`, `color_and_contrast:`, `layout_and_density:`, `tokens:`, `components_and_states:`, `accessibility:`, `engineering_invariants:`, `evidence:`, `assumptions:`, and `unresolved_decisions:`. Never claim that a packet was delivered elsewhere, refer to a prior turn, or replace a required field with a summary.

<packet_example>
VISUAL_SYSTEM_SPEC
selected_direction: Instrument-panel novel
direction_rationale: Dense, precise readouts support calculation work without imitating historical controls.
typography: A local sans for data; tabular numerals for values.
color_and_contrast: Dark bronze surfaces; text and focus colors meet WCAG AA against their stated surfaces.
layout_and_density: Three-column desktop grid; one-column small viewport reflow.
tokens: primitive, semantic, and component DTCG groups for the stated palette, spacing, and primary action.
components_and_states: Calculator key, field, panel, and alert states include default, hover, focus, active, disabled, error, and loading where applicable.
accessibility: Visible focus, forced-colors fallback, semantic status treatment, and no color-only meaning.
engineering_invariants: Preserve contrast pairs, tabular numeric alignment, and responsive grid thresholds.
evidence: Selected direction and supplied UX specification.
assumptions: Product copy remains placeholder until approved.
unresolved_decisions: none
END_VISUAL_SYSTEM_SPEC
</packet_example>

The example demonstrates packet shape only; replace every value with the supplied job's grounded decisions.

Tokens use the DTCG 2025.10 shape and three layers:

1. Primitive values such as palette, type scale, spacing scale, radii, and durations.
2. Semantic intent such as `color.text.primary`, `space.section`, or `motion.feedback`.
3. Component decisions such as `button.primary.background.default`.

Use `$type`, `$value`, aliases, and groups consistently. Do not dump an exhaustive token catalog; specify the tokens needed to implement and extend this experience. Preserve existing token names and values where suitable, record additions, and make any breaking replacement explicit.

Include accessible contrast intent, visible focus, forced-colors considerations, and every relevant component state. Define atmosphere through coherent relationships, not decorative effects added independently.

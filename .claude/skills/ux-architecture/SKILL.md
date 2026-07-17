---
name: ux-architecture
description: Specifies journeys, information architecture, responsive behavior, content hierarchy, and accessible interaction states.
---

# UX architecture

Return one self-contained `UX_SPEC` packet from `UX_SPEC` through `END_UX_SPEC`. Use the top-level fields `journeys:`, `information_architecture:`, `responsive_behavior:`, `accessibility:`, `states:`, `evidence:`, `assumptions:`, and `unresolved_decisions:`. Populate them with:

- primary and secondary users, jobs, entry points, exit states, and success signals;
- information architecture and ordered journeys, including recovery paths;
- content hierarchy and content requirements, with fabricated content prohibited;
- desktop, tablet, and mobile behavior expressed as layout decisions rather than device labels alone;
- keyboard order, focus movement, status announcements, validation, destructive-action confirmation, and reduced-motion implications;
- applicable loading, empty, partial, error, success, offline, permission, disabled, selected, hover, focus, and active states;
- unresolved product-policy decisions separated from safe design assumptions.

Prefer the smallest coherent flow. Do not add screens, settings, onboarding, or future-proof abstractions that the requested outcome does not need.

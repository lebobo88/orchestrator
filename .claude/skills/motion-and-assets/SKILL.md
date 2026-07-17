---
name: motion-and-assets
description: Defines conditional motion hierarchy and code-native asset direction with accessible fallbacks.
---

# Motion and assets

Invoke only when motion or distinctive assets materially support comprehension, feedback, hierarchy, or brand expression.

Return one self-contained `MOTION_ASSET_SPEC` packet through `END_MOTION_ASSET_SPEC`. For motion use `scope: motion` and include `purpose:`, `reduced_motion:`, and `evidence:`; record trigger, property, duration, easing, orchestration, interruption behavior, performance constraints, and the `prefers-reduced-motion` equivalent. Favor one or two high-impact moments over scattered animation. Never make essential information depend on motion.

For assets use `scope: asset` and include `asset_brief:`, `fallback:`, and `evidence:`; specify subject, composition, crop, aspect ratio, placement, contrast treatment, responsive behavior, alt-text intent, empty/failure fallback, and whether the asset is existing, code-native, or a labeled future placeholder. Do not call image generators, remote design services, or add dependencies.

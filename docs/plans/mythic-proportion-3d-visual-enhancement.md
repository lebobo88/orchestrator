# Plan: mythic-proportion-3d-visual-enhancement — Deep-Field Observatory 3D Visual Enhancement

Status: **APPROVED. Approved by rob.hasselbach@gmail.com on 2026-07-18, covering the plan as a whole (Section 15, item 1). Decision A (Section 5.9) — the community-centroid glyph/badge layer — is APPROVED; Phase 2 (Section 6) implements it. Decision B (Section 5.9) — adding `@react-three/postprocessing` as a new runtime dependency — is APPROVED; Phase 4 (Section 6) adds it, with the exact compatible version (the R3F-v8-compatible v2.x line, matching the installed `@react-three/fiber ^8.17`/`three ^0.169`, per Section 5.9) confirmed by engineering at implementation time — this approval does not pin a version number. Engineering work (`t2-engineer`, per Section 16's routing) may now begin. This approval does NOT cover any commit, push, deployment, or pull-request approval (Section 15 item 3), nor any Codex judge-call overage beyond the standard caps (Section 15 item 4; Section 12); those remain separate, later, explicit user approvals, unaffected by this update.**

task_id: mythic-proportion-3d-visual-enhancement-studio-2026-07-17
plan_id: mythic-proportion-3d-visual-enhancement

This plan recommends work. It does not grant execution authority. No engineering writer (T1/T2/T3/Engineering Lead) may start work against this plan until the user has given explicit approval (Section 15). Once approved, this plan's path becomes `ENGINEERING_JOB.approved_plan` for the engineering fleet. Approval of this plan does not authorize any commit, push, deployment, or pull request; that remains a separate, later, explicit user approval.

## 1. Summary

`mythic-proportion`'s 3D knowledge-graph experience — all four modes (Cloud, Orbital Systems, Strata, Knowledge Terrain) plus their 2D fallbacks and accessibility trees — is fully built and independently verified under the prior governing plan (`docs/plans/mythic-proportion-audit-fix-design.md`, APPROVED, executed to completion, 419 pytest / 413 vitest / 8-journey design validation). What remains is visual quality: the scene currently renders as an unlit debug view of correct data (flat `MeshStandardMaterial`, one ambient light, one directional light, no tone mapping, no post-processing). This plan implements a Studio-tier reviewed refined design direction, "Deep-Field Observatory," that graduates the scene to a calibrated optical instrument: ACES tone mapping, per-theme image-based lighting, per-mode metaphor chrome and atmosphere, focus-as-light, non-color community identity legible at ~4–6px, weighted/legible edges, a two-tier label system, and a structurally-solved light-theme Terrain and light-theme app-chrome contrast fix — all built on the existing architecture, without rearchitecting the single-draw-call render hot path. It also resolves the five evidence-backed `VISUAL_REVIEW` findings from the prior cycle as an acceptance floor.

## 2. Outcome and audience

For the single keyboard-first power user exploring a Leiden-community knowledge graph, with full parity for keyboard-only, reduced-motion, no-WebGL, forced-colors, and assistive-technology use: every 3D mode reads as a distinct astronomical-instrument view; selection/hover reads as light against dimmed context while remaining fully legible without color or luminance; community identity survives at small pixel sizes; edge weight is both visually encoded and numerically inspectable; both themes pass the extended gating contrast test; performance holds toward 10,000 nodes with a graceful safe-tier degradation rig. No prior camera-fit, LOD, selection-fit, extent-aware Terrain-fit, or context-loss behavior may regress.

## 3. Scope and non-goals

### 3.1 In scope

1. **Foundation and tokens.** ACES tone mapping at the R3F `Canvas`; additive DTCG token families for atmosphere/fog, bloom numerics, edge-weight width/opacity, label tiers, node-material fresnel/emissive/outline, pattern identity, per-mode chrome, and terrain-light overrides, plus the five F5 semantic/component token fixes. Extend `graph-colors.ts` with a `readBloomParams` helper mirroring the existing `readCommunityGeneratorParams`, and a terrain-aware/mode-scoped light-lightness branch that stays on the single culori OKLCH path. Extend `contrast.test.ts` with every new gated pairing in **both** themes while keeping the existing 8/16/32 ramp gate green.
2. **Node material and community identity.** A `MeshStandardMaterial.onBeforeCompile` patch adding a fresnel rim plus per-instance emissive (idle 0 / hover 0.6 / selected 1.0); a **second** small data texture carrying a pattern-id that modulates luminance (same mechanism family as the existing `colorsTexture`, still one draw call, never `vertexColors`); a non-luminance outline; O(tens) community-centroid glyph badges; a two-tier label system (~8–12 always-on community titles plus node labels, ~40 total cap, screen-space minimum size for node labels).
3. **Edges and weight readout.** A single fat-line edge pass (Line2/LineMaterial family) with weight-driven width and opacity; a Connections numeric-weight readout in the reading pane plus an a11y-tree Weight column; a `"weight: n/a"` fallback when weight is absent.
4. **Post-processing and safe tier.** Bounded, half-resolution, emissive-driven, token-thresholded selective bloom plus vignette; bloom suppression composed off the existing `transitioning` far-tier-LOD-suppression signal, restored only after far-tier restore; a `PerformanceMonitor`-driven safe-tier degradation ladder; a user-facing effects/quality control (Auto/Full/Balanced/Minimal).
5. **Per-mode metaphor chrome and parity.** Cloud nebula haze; Orbital ecliptic disc, rings, core glow, and inclination; Strata graded floor planes, edge-lit rims, and an etched labeled axis; Terrain hillshade, major/minor contours, theme-paired sky, and the structural light-theme solution — each with matching 2D-fallback chrome and accessibility-tree parity.
6. **Chrome-layer asset capture.** ComfyUI REST plus Trellis2, following `ASSET_MANIFEST.json` discipline: a refreshed dark HDRI (A1), a new light high-key HDRI (A2), a terrain detail/hillshade normal (A3), and optionally matcaps (A4) or landmark GLBs (A5) toward the existing 6-GLB cap. Every asset is placeholder-labeled, enhancement-only, backed by a procedural/token fallback, and loaded asynchronously and non-blockingly.

### 3.2 Non-goals

- No node-layer generated meshes and no revisit of the single-draw-call procedural node/edge boundary; this refined direction explicitly does not revisit that boundary.
- No new graph computation. No rebrand; tokens extend, never replace.
- No new physics or position animation; physics is never faked.
- No native browser dialogs.
- No commit, push, deployment, or pull request without a separate, explicit, later user approval.
- Strata per-level drill control remains carried out of scope from the prior plan.
- The four modes, the enriched Leiden data contract, mode-switch behavior, and the prior accessibility/audit work already shipped and verified under the governing plan are the baseline for this plan, not a re-scope target.

### 3.3 Repository findings (grounded evidence baseline)

The four modes and their supporting machinery are fully built and independently verified (419 pytest / 413 vitest / 8-journey design validation, per the governing prior plan). The following was confirmed by direct source read during this planning pass:

- **Minimal current lighting, no tone mapping, no post chain.** `Graph3DScene.tsx` `SceneContents` renders exactly `<ambientLight intensity={0.5} />` and `<directionalLight position={[10,10,10]} intensity={0.7} />` (confirmed at lines 664–665), and the `<Canvas>` mount (confirmed at line 746) configures no tone mapping and no post-processing composer.
- **Nodes are a single-draw-call `InstancedMesh2`.** `InstancedNodes.tsx` colors instances via `colorsTexture`, never `vertexColors`; an in-code comment (confirmed at lines 174–184) documents that setting `vertexColors: true` alongside a per-instance color texture reintroduces a black-multiply bug (the per-vertex `color` geometry attribute defaults to black and multiplies against the correct `colorsTexture` value, zeroing it out). The onBeforeCompile fresnel/emissive patch this plan adds must take explicit care not to reintroduce this bug. LOD uses an icosahedron-42 / icosahedron-12 / flat-quad chain scaled to camera-fit, with a far-tier suppression sentinel (`LOD_FAR_TIER_SUPPRESSED_DISTANCE`) active during mode transitions.
- **Edges are a single batched pass but do not encode weight.** `InstancedEdges.tsx` renders one batched `LineSegments` with a `LineBasicMaterial({ vertexColors: true, transparent: true, opacity: 0.9 })` (confirmed at line 50) — one draw call, 1px width, no weight-driven width or opacity. `edge.weight` is already served by the backend and typed on the client (`store.py:629`; `VizEdge.weight` optional), so this is client wiring, not new computation.
- **Labels are capped but flat.** `NodeLabels.tsx` caps troika-text labels at ~40 with a 6% black outline; there is no two-tier (community-title vs. node-label) hierarchy today.
- **Orbital and Strata have no metaphor chrome.** They are pure worker force-configuration variants (`modeForces.ts`) layered on the shared node/edge rendering — the direct cause of `VISUAL_REVIEW` Finding 1 (weak per-mode identity).
- **Community identity in 3D is raw hue only** — the direct cause of Finding 3 (identity fails at small pixel sizes).
- **Camera-fit/LOD/context-loss machinery is hard-won and must not regress.** Whole-graph fit, selection-scoped fit with small-focus-set axis correction, extent-aware Terrain flat-shape fit, and WebGL-context-loss auto-2D live in `Graph3DScene.tsx` and `CameraRig.tsx`.
- **Color has one source.** `graph-colors.ts` bridges culori OKLCH to `THREE.Color`, re-reading on a `data-theme` flip; `graph.css`'s light-theme generator lightness override is already at 0.48.
- **`contrast.test.ts` audits only `--color-bg-elevated` pairings and the generative ramp gate** (confirmed: `describe("design-token contrast audit"...)` asserts `color-text-primary`/`color-text-secondary` against `color-bg-elevated` only, plus a separate `describe("generative community color ramp"...)` gate at counts 8/16/32) — it never audits `--color-bg-inset`, which is the direct cause of Finding 5 (F5): light `--color-text-secondary` = `--neutral-300` (oklch 0.42) clears 4.5:1 on `bg`/`bg-elevated` but fails on `--color-bg-inset` (`--neutral-700`, 0.85), affecting the selected-card surface and several meta-text classes (`.mp-search-result-meta`, `.mp-wiki-page-item-meta`, `.mp-wiki-hint`, `.mp-wiki-page-path`, `.mp-detail-pane-path`, `.mp-community-badge-label`). The light-theme search-result `mark` element also uses `--color-accent-muted`, which fails 4.5:1 in light theme.
- **Proven asset workflow.** `web/public/terrain/ASSET_MANIFEST.json` records a working ComfyUI REST + Trellis2 pipeline (FLUX.2-klein-4B fp8, Trellis2 pipeline 512, direct REST at `127.0.0.1:8188`, no Atelier MCP wired). Confirmed present today: two HDRIs (`skybox-dusk.png` default, `skybox-twilight.png` alternate — both dark-theme, no light-theme HDRI exists yet), two matcaps (`matcap-clay.png` default, `matcap-stone.png` alternate, no baked hue), and two landmark GLBs (`obelisk.glb`, `spire.glb`, mesh-only, ~4,400–4,450 triangles each) against the 6-GLB total cap, leaving headroom for up to four more landmark GLBs under this plan's optional A5 item. Every existing entry is already `placeholder: true`, `production_ready: false`, with recorded seeds/prompts/pipeline and documented known limits.

The five `VISUAL_REVIEW` findings (weak per-mode identity, flat label hierarchy, community identity failing at small size, illegible light-theme Terrain, and the F5 sub-AA light-theme text/search-mark contrast) are the evidence-backed acceptance floor for this plan.

## 4. Research evidence

No new research was dispatched for this plan. The prior plan's Section 4 research packets (a ranked comparison of 3D graph metaphors for Leiden-community React-Three-Fiber/`InstancedMesh2`/worker graphs; the Obsidian graph-view affordance checklist; ComfyUI/Flux/Trellis2 generation mechanics) plus this planning pass's direct local code grounding (Section 3.3) are sufficient. Standing freshness caveat: reconfirm library and tooling versions (`three`/`@react-three/*`, drei `Line2`/fatlines/`PerformanceMonitor`, ComfyUI/Flux/Trellis2) at implementation time if material time has passed since this plan was written.

## 5. Design route, handoff, and review

**Design route**: Studio. Reasons recorded by Planner: a genuine visual-quality leap spanning four distinct 3D metaphors plus their 2D fallbacks; flagship, high-value surface; a novel metaphor-legibility problem; dense screenshot evidence; accessibility-critical. Three directions (safe, refined, novel) were presented; the user selected **refined — "Deep-Field Observatory."** Only this selected direction is developed below; no discarded direction is reproduced. `existing_system_mode`: extend — tokens extend, never replace. Model tier: Fable 5 (high) for direction synthesis and development, with Opus 4.8 (high) recorded as the fallback tier, per the standing "Fable for the single highest-value complex synthesis" override. A disposable Studio prototype was **not** used; Planner deferred it because the regression-risk surface is covered by the Gate A prior-machinery re-confirmation (Section 8) plus the existing pytest/vitest suites, consistent with the prior cycle's spike-over-prototype choice.

Task ID on the passed `DESIGN_HANDOFF`: `mythic-proportion-3d-visual-enhancement-studio-2026-07-17`. Unifying thesis: *an observatory renders attention as light and context as depth* — focus glows, context dims and recedes into fog, communities are constellations with names/glyphs/patterns, and each mode is a different instrument pointed at the same sky. Restraint is instrument-grade: no ornamental motion, no pulsing in any state, no decorative saturation, and every effect is a redundant channel behind a static, legible, non-color carrier. Anti-goals recorded in the handoff: no node-layer generated meshes, no `vertexColors`, no new position animation or faked physics, no model-default warm-editorial or ornamental-glass styling, bloom/dim never the sole carrier of any state, no native browser dialogs, and no boundary revisit of the chrome-layer asset caps.

### 5.1 UX_SPEC (reproduced)

**Meta.** Direction refined — "Deep-Field Observatory"; `existing_system_mode` extend; primary user a keyboard-first explorer; entry points the Graph tab (mounted-hidden `GraphView`), Cmd+K jump (`graphFocusBus`), and the Wiki round trip. Success signals: selection plus framed camera survive every mode switch and the Wiki round trip; every glow/color/width encoding is independently legible without luminance or hue; AA contrast and non-color-cue parity hold in both themes and under forced-colors.

**Journeys:**

- **J-CLOUD**: deep-field fog plus faint nebula haze over the dark `--graph-bg` baseline (haze is an enhancement with a plain-background fallback). Default disclosure is the existing top ~1,500-degree node set. Node size continues to map to centrality. Community identity = hue + a per-instance shader pattern (from `communityPatternKind`) + O(tens) centroid glyph badges + always-on community titles. Hover/select transitions to J-FOCUS; selection expands one-hop neighbors and issues the existing selection-scoped fit. Recovery: camera-fit re-frames on settle; the 2D switch preserves state.
- **J-ORBITAL**: an ecliptic disc, orbit rings, and a shell core glow (rings static under reduced motion); a centroid badge at each system core; community titles per system. Selection frames the node plus one-hop neighbors via `computeSelectionFit` with small-focus-set axis correction. A11y parity: an `OrbitalA11yTree` grouped by community with a `CommunityBadge` (glyph, color, member count). Camera re-fits on a fresh worker "end" event.
- **J-STRATA**: graded translucent floor planes per Leiden level plus an etched level axis with text labels; node Y = level; pattern/glyph/title cues per level. Parity: `StrataA11yTree` hierarchy tree with level and `parentCommunity` text plus `CommunityBadge`. An empty level renders no plane; axis labels remain the legibility anchor if translucency is culled at the safe tier.
- **J-TERRAIN**: hillshade surface plus contour lines plus an HDRI sky; all generated assets remain placeholder, enhancement-only, with a procedural/token fallback. Light theme uses a bright high-key sky paired with darkened graph elements. Terrain retains a sequential single-hue elevation ramp plus contours — community identity here still comes from pattern/glyph, not elevation hue. Camera: the extent-aware flat-shape fit (`isFlatExtent`/`resolveFlatShapeElevation`/`computeOrientedFitDistance`) must not regress; new chrome must not alter the extent/radius inputs that fit depends on. Parity: `TerrainA11yList` region list with a tier label, a numeric elevation value, and a glyph bullet. With zero generated assets, Terrain is fully functional; contours carry legibility if hillshade/HDRI are dropped.
- **J-FOCUS** (glow is never the sole carrier): hover = emissive glow + non-luminance outline ring + node label (hovered nodes are always labeled) + a11y-tree reachability; context dims via the existing `entity.opacity` 0.1 model, neighbors stay full-opacity. Selected = a stronger static glow + a persistent outline + size emphasis + an always-on label + `aria-selected`/`aria-current` + the reading pane. Dim is only ever the context cue, never a state carrier on its own. Reduced motion: static bloom, instant dim/undim, no animated ring. Pointer-out clears hover; selection persists until reselect or clear.
- **J5-EDGE-WEIGHT** (numeric readout, required): edges encode weight as fat-line width plus opacity. On selection, the reading pane gains a "Connections" list — neighbor label plus numeric weight (plus edge type); hovering/focusing a row (or in-canvas edge hover, if feasible) surfaces the same numeric value. The a11y links table gains a text `Weight` column. Absent weight renders `"weight: n/a"`, never a fabricated number; width falls back to the token default.
- **J-WIKI-ROUNDTRIP**: Open-in-Wiki → `App.openPage` → Wiki tab; `GraphView` stays mounted-hidden (`visible=false` → paused → `frameloop "never"`, worker/state preserved). Return restores selection, expanded IDs, filters, mode, camera intent, and hierarchy level; no cold restart or refetch. The new visual layer rehydrates from preserved state. A page-fetch failure renders inline, never a dialog.
- **J-THEME-SWITCH**: a `data-theme` flip re-reads OKLCH tokens into `THREE.Color` (`subscribeGraphColors`) — scene, glow tints, ramp, and chrome re-tint without a remount. Light-theme Terrain: high-key sky plus darkened graph elements; glow/bloom intensity is reduced in light theme; outline/label/size still carry state regardless of theme. The contrast gate holds in both themes; `FALLBACK_COLORS` neutral gray covers pre-hydration.
- **J-SAFE-TIER**: `PerformanceMonitor` fps samples, or the effects control, trigger degradation in order: (1) bloom → flat highlight; (2) haze/HDRI/hillshade → token background; (3) shader patterns → centroid badges plus labels; (4) LOD2 flat-quad governs node cost. The minimal rig is never dropped: single-draw-call nodes, centroid glyph badges, community titles, outline focus cue, edge-width encoding, and DOM readouts. Every change is announced politely via `aria-live`; recovery reverses the order; state is untouched.
- **J-CONTEXT-LOSS**: a genuine `webglcontextlost` event (via `isGenuineContextLoss`) triggers auto-2D plus a `role="status"` announcement; every encoding is carried by the 2D fallback plus the a11y tree; `onReady` clears the stale message; the user may retry 3D; state stays intact.

**Information architecture.** The toolbar keeps the 2D/3D toggle, the mode radiogroup (`role="radiogroup"` `aria-label="Graph mode"`), and type filters; it gains a **new** effects/quality control (Auto default / Full / Balanced / Minimal) as a small radiogroup labeled "Graph detail" — the single inspectable home of the safe-tier decision. A collapsible community legend docks at a canvas corner, sourced from the same `CommunityBadge`/`CommunityGlyphIcon` machinery so the legend, in-canvas badges, the 2D fallback, and the a11y tree never disagree. Community titles and centroid badges live in-canvas; the legend is their text mirror. The reading pane (`aside "Selected node"`) gains a Connections list with per-edge numeric weight. `TabNav` stays nav-plus-links; Cmd+K stays the jump surface. Aria-live regions stay at the existing mode-change, selection-status, and context-loss/effects-status set — no new competing region.

**Responsive behavior.** ~1440px: canvas plus a right reading-pane aside plus corner legend, full 40-label cap. ~834px: toolbar wraps to two rows, reading pane narrows or bottom-docks, legend collapses to a toggle, smallest node labels cull first. ~375px: single column, reduced default disclosure, ≥44px targets, reading pane becomes a dismissible app-owned bottom sheet, legend becomes a popover, labels reduce to hovered/selected plus a few top-degree nodes. 400% zoom / 320px reflow: all DOM controls reflow to one column, no horizontal scroll, canvas is not the operable surface — the a11y tree, reading pane, and toolbar carry full function; the focus ring stays ≥2px/≥3:1 at zoom. Label adaptation: titles (8–12) win the shared 40-label cap; node labels drop first, each staying above a screen-space minimum; DOM text remains the guaranteed carrier.

**Accessibility.** The canvas is a pointer surface, not the keyboard surface; keyboard operation runs through `GraphA11yTree` (focusable treeitems) plus the reading pane; selection stays bidirectional through `selectNode` with glow/outline/label/pane/aria updating together. Deterministic canvas-container focus behavior is to be confirmed during implementation (aria-hidden with a labeled equivalent, or a delegating focusable region — never a trap). Focus order: toolbar (toggle → mode radiogroup roving arrows → filters → effects) → legend toggle → a11y tree → reading pane; Escape closes a sheet/popover and restores invoker focus. Parity requirements for new affordances: glow parity via `aria-selected`/`aria-current` plus a status region; community identity via glyph SHAPE plus outline PATTERN plus the text "Community i of n"; edge weight via text in the Connections list plus the Weight column. Forced-colors: canvas hue is decorative; DOM chrome stays legible on system colors via shape/pattern/text; the focus ring maps to the system highlight at ≥3:1. Reduced motion: auto-2D at mount; in-session switches are instant (durationMs 0); no pulsing, static bloom, instant chrome swap, camera snap. AA text plus ≥3:1 UI/accent hold in both themes; touch targets stay ≥44px; troika outlines plus title chips carry label legibility.

**States.** Loading (neutral affordance, no bloom before settle); empty (`.mp-graph-empty` `role="status"` plus an Ingest link, no chrome/glow); error (inline `statusHint`/`readingError`, never a dialog); success (settled plus fit plus chrome plus titles plus badges); disabled (3D toggle disabled without WebGL, with a title; effects "Full" visibly disabled when unsupported); hover (glow plus outline plus label; context dims; a connection-row hover shows weight); keyboard focus (visible ring; a focused node mirrors hover treatment); active (`aria-checked`/`aria-pressed` plus a non-color active class); selected (strong static glow plus persistent outline plus size plus label plus aria plus a populated pane plus selection fit — survives mode switch and the Wiki round trip); context-loss (auto-2D plus status, cleared on ready); reduced-motion (static, instant, auto-2D at mount); safe-tier degraded (bloom→flat highlight, chrome→token background, patterns→badges; the minimal rig is retained, announced, and controllable).

**Evidence** (as recorded in the handoff): `Graph3DScene.tsx` (fit/selection/context-loss/transition wiring), `InstancedNodes.tsx` (single draw call, `colorsTexture` not `vertexColors`, the dim model, LOD), `NodeLabels.tsx` (the 40-cap, hovered+selected+top-degree priority, the outline), `CameraRig.tsx` (bounded interruptible fit, reduced-motion snap, interrupt handoff, flat-extent Terrain fit, axis avoidance), `GraphView.tsx` (radiogroup, live regions, empty state, reading pane, mounted-hidden rendering, reduced/no-WebGL initial 2D), `GraphA11yTree.tsx` (per-mode parity trees, links table, status), `CommunityBadge.tsx` (SVG glyph shape plus pattern), `graph.css` (the generative OKLCH ramp, the light lightness override), and `docs/plans/mythic-proportion-audit-fix-design.md` (served weight at `store.py:629`, its Section 7 tokens, and its Sections 5.1/8/9.3 invariants).

**Assumptions recorded in the handoff.** The effects control and the Connections weight readout are new additive affordances (design intent, not observed today). Selective bloom, pattern shaders, centroid billboards, and per-mode chrome are the new layer to build. "Facets" maps to the existing cross-hatch `CommunityPatternKind`. `GraphA11yTree` is visually-hidden-but-focusable per its own header comment (CSS to confirm). No user research or measured outcomes are asserted anywhere in this spec.

**Unresolved decisions recorded in the handoff.** Effects-control scope (product decision); a deterministic community-title selection rule beyond 12 communities (product decision); edge-weight readout scope — pane-only versus also in-canvas edge picking (feasibility-gated); the light-Terrain darkened-element treatment (deferred to the visual spec — resolved there, Section 5.2); bloom intensity budget per theme/tier (build-time tuning); Strata per-level drill remains the carried out-of-scope open decision from the prior plan.

### 5.2 VISUAL_SYSTEM_SPEC (reproduced)

**Direction rationale.** The product already proves one CSS `--graph-*` palette drives both 2D chrome and the 3D scene without drift (`graph-colors.ts` re-reads on a `data-theme` flip). This direction builds only on that contract: material life (fresnel plus per-instance emissive), a second small data texture for pattern-id (same mechanism family as `colorsTexture`, still one draw call), and a countable chrome layer. Every atmospheric effect is a coherent relationship (light vs. dim, near vs. far fog, sky vs. darkened graph), and none is ever the sole carrier of a state.

**Typography.** DOM typography is unchanged: `--font-family-sans` (Inter) for UI, `--font-family-mono` (JetBrains Mono) for the new Connections weight column and the a11y Weight column (tabular numerics). In-scene, a two-tier SDF label system (troika, Inter source, ~40 cap): Tier 1 community titles (~8–12, always-on) at weight 600, size `--graph-label-tier-community-size` 15, an SDF outline `--graph-label-outline-width` 0.12em in `--graph-label-outline-color`, on a chip (`--graph-label-chip-bg/-fg/-radius/-pad`); titles win the cap under pressure. Tier 2 node labels at weight 500, size `--graph-label-tier-node-size` 12, with a hard minimum `--graph-label-tier-node-min-size` 10px. The outline and chip are the legibility carriers; bloom is never the legibility carrier.

**Color and contrast.** Both themes keep their audited semantic pairs and the generative ramp (≥3:1 community-as-accent at 8/16/32, gated). Fresnel and emissive are additive light only. Focus is a multi-carrier state: `--graph-node-emissive-selected` plus a non-luminance outline (`--graph-node-outline-color`, ≥3:1 against fill and background per theme) plus size plus label plus aria; the existing 0.1 in-scene opacity and the 2D `--focus-context-dim` 0.28 remain context-only cues. Pattern identity modulates **luminance**: `--graph-pattern-luminance-delta` 0.18 shifts pattern lobes around the community color; "facets" maps to the existing cross-hatch pattern in `communityGlyphs.ts`; centroid badges supply the redundant non-color cue.

**Light-theme Terrain (structural, decided by this handoff).** A bright high-key sky (`--graph-terrain-sky-*`) paired with **darkened** graph elements via a Terrain-scoped `--graph-terrain-node-lightness` of 0.38 in light theme (versus the theme-wide 0.48/0.55), applied under `[data-theme="light"][data-graph-mode="terrain"]` through a terrain-aware `graph-colors.ts` branch that stays a single culori OKLCH path. A darkened, non-luminance node outline (`--graph-terrain-node-outline-color/-width`) plus hillshade (`--graph-terrain-hillshade-strength`) together guarantee ≥3:1 node-vs-sky contrast independent of sky brightness. Contour tokens `--graph-terrain-contour-major/minor-*`. This pairing is added to the gating contrast test at the 3:1 floor.

**F5 fixes (offenders identified by this handoff).** (1) Light `--color-text-secondary` = `--neutral-300` (oklch 0.42) clears 4.5:1 on `bg`/`bg-elevated` but fails on `--color-bg-inset` (`--neutral-700`, 0.85) — the selected-card surface and several meta-text classes (`.mp-search-result-meta`, `.mp-wiki-page-item-meta`, `.mp-wiki-hint`, `.mp-wiki-page-path`, `.mp-detail-pane-path`, `.mp-community-badge-label`); the gate never audits `bg-inset`, so this is currently untested. Fix: light `--color-text-secondary` → `--neutral-200` (oklch 0.32), which clears ≥4.5:1 on `bg`/`bg-elevated`/`bg-inset` while remaining visibly secondary. (2) `.mp-search-result-snippet mark` uses `--color-accent-muted` under `--color-text-on-accent` and fails 4.5:1 in light theme. Fix: `--search-mark-bg`/`--search-mark-fg` → `--color-highlight-surface` (`--warning-600`, oklch 0.78 0.15 85) with `--neutral-0` (0.12) text, clearing ≥4.5:1 in both themes, audited. True-disabled: `--wiki-item-fg-disabled`/`--search-card-fg-disabled` = `--color-text-disabled` plus a non-color marker plus `aria-disabled` plus removed pointer events — disabled is never conveyed by dimming alone.

**Layout and density.** The legend extends `.mp-community-badge` (shape plus pattern swatch plus title). The reading pane (320px) gains Connections rows (Inter title, right-aligned mono weight). The hidden a11y links table gains a Weight column. The toolbar gains the effects control from the `.mp-graph-filter` family via `--effects-control-*` tokens (segmented, keyboard-operable, active state = border plus background plus `aria-pressed`). DOM readouts persist at the safe tier; the existing single-column small-viewport reflow is unchanged.

**Tokens (DTCG 2025.10, additive; numeric tokens follow the `--graph-community-generator-*`/`readNumberVar` precedent):**

- *Primitives*: reuse only — `--warning-600`, `--neutral-0`; no new primitives.
- *Semantic*: CHANGED — light `--color-text-secondary` → `var(--neutral-200)` (F5). ADDED — `--color-highlight-surface` (`var(--warning-600)`), `--color-text-on-highlight` (`var(--neutral-0)`), both themes.
- *Component*: `--search-mark-bg`/`-fg`; `--wiki-item-fg`, `--wiki-item-fg-disabled`, `--search-card-fg-disabled`, `--wiki-item-disabled-marker`; `--effects-control-fg`/`-fg-active`/`-bg-active`/`-border`/`-border-active`; `--connections-weight-font`/`-fg`, `--connections-row-border`; `--graph-label-chip-bg` (color-mix in OKLCH, graph-bg 82%), `--graph-label-chip-fg`/`-radius`/`-pad`.
- *Graph, per theme*: environment/IBL `--graph-env-intensity` (dark 1.0 / light 1.15), `--graph-env-sky-top`/`-horizon`; fog `--graph-atmosphere-fog-color-{cloud,orbital,strata,terrain}` plus `--graph-atmosphere-fog-density-{cloud 0.045, orbital 0.02, strata 0.03, terrain 0.015}`; bloom `--graph-bloom-threshold` 0.90, `--graph-bloom-intensity` 0.60, `--graph-bloom-radius` 0.40, `--graph-bloom-resolution-scale` 0.5 (read via the new `readBloomParams` helper); edges `--graph-edge-weight-width-min` 1 / `-max` 4, `--graph-edge-weight-opacity-min` 0.25 / `-max` 0.90; node material `--graph-node-fresnel-power` 2.5 / `-intensity` 0.6, `--graph-node-emissive-idle` 0 / `-hover` 0.6 / `-selected` 1.0, `--graph-node-outline-color` (per theme) / `-width` 2; pattern `--graph-pattern-luminance-delta` 0.18, `--graph-pattern-scale` 3.0; labels `--graph-label-tier-community-size` 15 / `-node-size` 12 / `-node-min-size` 10 / `-cap` 40 / `-community-max` 12, `--graph-label-outline-width` 0.12 / `-color`; Cloud `--graph-cloud-nebula-color`/`-opacity` 0.12; Orbital `--graph-orbital-disc-color`/`-opacity`, `--graph-orbital-ring-color`/`-width`, `--graph-orbital-core-glow-color`/`-intensity`, `--graph-orbital-ring-inclination` 6; Strata `--graph-strata-floor-color`/`-opacity`, `--graph-strata-floor-fog-density`, `--graph-strata-band-rim-color`, `--graph-strata-axis-color`; Terrain `--graph-terrain-sky-top`/`-horizon`, `--graph-terrain-hillshade-strength` 0.8, `--graph-terrain-contour-major`/`minor-color`/`-width`, `--graph-terrain-node-lightness` (light 0.38), `--graph-terrain-node-outline-color`/`-width`.

**Components and states.** Node: idle (type/community fill, fresnel on, emissive 0, pattern texture) / hover (emissive 0.6) / focus (outline plus emissive plus aria plus label) / selected (emissive 1.0 plus outline plus size plus label) / dimmed (0.1, context-only) / safe-tier (single draw call kept, fresnel droppable, outline plus badges kept). Edge: width/opacity interpolate between the four weight tokens; an active edge may bloom but width/opacity independently encode weight; the safe tier keeps width encoding with bloom off. Community title chip (SDF 600 on a chip, ≥4.5:1, wins the cap). Centroid badge (shape plus pattern plus text, O(tens), always present at safe tier, forced-colors-safe). Legend (swatch decorative; shape/pattern/label authoritative). Effects control (default/hover/focus-ring/active `aria-pressed`/disabled; Minimal maps to the safe-tier rig). Connections list (row default/hover/focus/empty; mono weight; a11y table mirror). Per-mode chrome (default plus a transition state with bloom and far-tier LOD suppressed during the ~800ms envelope plus a 2D structural fallback). Wiki item/search card (idle/hover/selected non-color; enabled ≥4.5:1; true-disabled marked). Search mark (≥4.5:1 both themes).

**Accessibility.** Node outline ≥3:1 against fill and background; DOM focus treatment retained; the effects control and Connections rows are keyboard-operable; forced-colors — canvas hue is decorative, DOM chrome relies on shape/pattern/text and respects `forced-color-adjust`; non-color cues are present everywhere (pattern luminance at 4–6px, badges, labels, outline, aria); reduced motion honors the `motion.css` kill-switch; auto-2D fires on reduced motion and on context loss.

**Contrast-test extension scope (assertions to ADD, both themes, no fabricated passes):** text-primary/secondary against `--color-bg-inset`; `--search-mark-fg` against `-bg` ≥4.5:1; `--graph-label-chip-fg` against the chip ≥4.5:1; Terrain-light node/community lightness 0.38 against `--graph-terrain-sky` ≥3:1; `--graph-node-outline-color` against fill and background ≥3:1; the existing 8/16/32 ramp gate stays green throughout.

**Engineering invariants embedded in this spec** (consolidated with the handoff's top-level list in Section 5.6): single-draw-call `InstancedMesh2` via `colorsTexture`, never `vertexColors` (the black-multiply bug — the `onBeforeCompile` patch takes explicit care), never per-node meshes; the pattern-id is a SECOND small data texture, same family, ONE draw call, luminance-modulating; node/edge procedural at O(1,500–10,000); generated assets confined to the O(1)–O(tens) chrome layer; bloom never the sole carrier, half-res, token threshold, suppressed during transitions, safe-tier at 10k; culori single source, no hardcoded hex, tokens extend never replace (F5 is a value fix within an existing token; the fixed `--graph-community-1..8` slots stay); the ramp's hue formula (`hueBase + index * (360/count)`) with level mapping to bounded chroma only (the Terrain override moves lightness via a separate mode-scoped node token, not the ramp); one batched Line2/LineMaterial edge pass; labels ~40 cap, titles win, node-label screen minimum; worker-owned physics, refs-only `onTick`, never `setState` per frame, never faked; LOD scales to camera-fit, far tier suppressed during transitions; camera-fit on "end," including selection and extent-aware Terrain fit, unregressed; 2D fallback plus a11y parity in every mode; auto-2D on context loss and reduced motion; ACES at the `Canvas`; no native dialogs.

**Evidence** (as recorded in the handoff): `primitives/semantic/components/graph/motion.css`; `contrast.test.ts` (audits `bg`/`bg-elevated` only plus the ramp gate); the F5 offenders in `wiki.css`, `search.css`, `page-detail-pane.css`, shell chrome, `base.css` (`.mp-context-dimmed` 0.28); `graph-colors.ts` (`readCommunityGeneratorParams`/`readNumberVar`, `THREE.Color` re-read); `communityGlyphs.ts` (facets → cross-hatch); `graph.css` chrome hooks (`.mp-graph-reading-pane`, `.mp-community-badge`, `.mp-graph-mode-fallback`, `.mp-graph-a11y-tree`, `.mp-graph-toolbar`); the supplied `UX_SPEC`; the prior plan's Sections 3.3/5.1/7/11.

**Assumptions recorded in the handoff.** HDRI, nebula, disc, and sky elements are generated or procedural per the asset spec; Inter is available as the troika SDF source; drei `PerformanceMonitor` drives degradation; all copy is placeholder; all ratios are TARGETS for the extended gate; the Terrain-light override may equivalently land as a mode-scoped numeric token consumed only in Terrain.

**Unresolved decisions recorded in the handoff.** Global light `--color-text-secondary` darkening (chosen) versus a scoped `--color-text-secondary-on-inset` token; exact bloom numerics and per-mode fog densities pending GPU profiling at 10k; nebula/ring billboard counts within O(tens) and whether the safe tier retains the fresnel rim, pending `PerformanceMonitor` thresholds.

### 5.3 MOTION_ASSET_SPEC — motion (reproduced)

**Purpose/hierarchy.** Motion communicates only: mode identity (a chrome/fog/bloom-threshold cross-fade inside the existing ~800ms envelope), focus (glow plus outline plus size plus label plus aria, with luminance the least important channel), settling (the existing camera re-fit on the worker "end" event, choreographed around, never re-authored), and degradation (a safe-tier step-down, announced). No ornamental motion; NO pulsing in any state; motion is never the sole carrier; no new position animation (refs-only `onTick`; physics is never faked); no native dialogs.

**Token alignment.** Reuse `--duration-fast/base/slow`, `--ease-out/standard/emphasized`, and the shared `easeOutCubic` curve (`CameraRig` line 647 equals `modeTransition` line 49 — keep one curve). New tokens (declared in `:root` AND collapsed in the `prefers-reduced-motion` block, like the existing durations): `--graph-motion-glow-in` 150ms, `--graph-motion-glow-out` 225ms, `--graph-motion-dim` 225ms, `--graph-motion-transition-envelope` 800ms (mirrors `MODE_TRANSITION_DURATION_MS` — single source of truth, do not diverge), `--graph-motion-chrome-fade` 800ms, `--graph-motion-bloom-suppress` 150ms, `--graph-motion-bloom-restore` 225ms, `--graph-motion-theme-retint` 0ms, `--graph-motion-ambient-ring-rev` 120000ms. Numeric state targets: emissive idle 0 / hover 0.6 / selected 1.0; bloom threshold 0.90 / intensity 0.60. Tokens are read once per discrete trigger, never per frame; `prefersReducedMotion()` is the single gate.

**Hover glow.** Trigger: `hoveredId` change; emissive 0→0.6 plus outline fade/scale plus a size nudge; in 150ms ease-out, out 225ms ease-standard, concurrent with context dim/undim; hard interruptible (retarget from the current value, no reset pop); the existing 48ms BVH pick throttle is unchanged; interpolate only the in-flight subset in the existing frame loop, refs only, zero allocation, never `setState` in `useFrame`. Reduced motion: instant. Hover is also carried statically by outline plus size plus label.

**Selection.** Emissive → 1.0 plus a persistent heavier outline plus size plus label plus `aria-selected`, superseding hover by retarget. Selection does NOT drive `CameraRig.focusTarget` (stays null); it issues the existing selection-scoped fit request. Glow and camera fit are independent and both interruptible (a user OrbitControls gesture cancels the fit, not the glow). Deselect: 225ms. Reduced motion: instant; the selected state is STATIC elevated emissive plus outline, never a pulse.

**Context dim.** The existing model (non-focused/non-neighbor opacity 1↔0.1) eased over 225ms ease-standard, simultaneous with the glow, retargeting on any focus change, remaining active at the safe tier. Reduced motion: instant.

**Mode-transition cross-fade** (rides entirely inside the existing 800ms interruptible envelope; adds NO position animation; never extends, delays, or gates that envelope): at T0 (transition start, `setTransitioning(true)`), far-tier LOD suppression engages (the existing `transitionActive` → `LOD_FAR_TIER_SUPPRESSED_DISTANCE` path) AND bloom suppression composes off the same `transitioning` flag (intensity 0.60→0 over 150ms — rationale: suppressed far-tier flat quads render near-black at grazing angles, so bloom on transient half-lit geometry would smear) AND chrome/fog begin an 800ms easeOutCubic cross-fade (outgoing↓/incoming↑, fog color/density interpolating, bloom threshold pre-positioning). From T0 to T800: chrome/fog interpolate, bloom stays fully suppressed, the far tier stays suppressed, input is never blocked. At T_end (`isTransitionActive` false): far-tier LOD restores FIRST, then bloom restores 0→0.60 over 225ms — no node may be in the flat-quad tier when bloom returns — and chrome/fog complete. The worker "end" event (separate, later) then drives settle → fit request → camera re-fit; bloom/chrome are already restored, and camera machinery is untouched. Interruption: a second mode switch mid-blend replaces the transition snapshot (existing behavior); chrome/fog retarget from the current interpolated values toward the newest mode with no reset flash; bloom and the far tier stay suppressed across the new envelope; the newest intent wins immediately. Reduced motion: `durationMs 0` — no blend window exists; chrome/fog swap instantly, no suppression window, bloom holds its static token value, camera snaps instantly.

**Camera interplay.** Transition (T0..T800) → physics settles → worker "end" → the existing ~400–500ms eased fit; all interruption semantics are preserved (same-frame user-gesture cancel, in-flight-destination anchoring, selection-vs-whole-graph precedence). The new fades run on refs/uniforms only and never write `camera.position` or `orbit.target`.

**Ambient policy.** Static by default. Nebula: fully static, no drift ever. Orbital rings: at most one bounded rotation ≥120s/rev (≤3 deg/s), linear, no pulsing — DISABLED BY DEFAULT pending a live perf/aesthetic check; it conveys no state. Strata/Terrain: static. Forced to zero (frozen, no snap) under reduced motion, at the safe tier, and while paused (`frameloop "never"`).

**Theme switch.** Instant atomic re-tint (0ms), never routed through the chrome cross-fade; if it coincides with an in-flight transition, the re-tint applies to both the outgoing and incoming targets so the fade continues without a reset or flash; identical behavior under reduced motion.

**Safe-tier choreography** (`PerformanceMonitor onChange`, with hysteresis; each step politely announced via `aria-live`, never a dialog): (1) bloom off (150ms fade; instant under reduced motion); (2) ambient drift freezes; (3) chrome thins to the minimal rig via the chrome-fade (cheap fog for depth is kept; no blackout); (4) LOD drops to the safe tier. Always retained: context dim, outline/size/label/aria focus carriers. Recovery reverses the order with the same fades and hysteresis.

**Reduced-motion summary.** Auto-2D at mount, owned by `GraphView`. When a canvas is shown, it has instant glow/dim, an instant chrome swap with no suppression window, static bloom, zero drift, an instant theme change, instant (still announced) safe-tier steps, and camera snap. Absolutely no pulsing anywhere.

**Accessibility/fallback.** The 2D fallback has zero canvas motion; every state is legible statically (`aria-selected`/`current` plus outline plus non-luminance styling); interrupting any fade mid-flight leaves a valid legible frame; status changes are announced; WCAG 2.2 reduced-motion is honored globally.

**Performance.** All fades run in the existing single frame loop via refs/uniforms, never `setState` in `useFrame`, zero per-node allocation, in-flight-subset easing only; bloom is half-res/emissive-driven/token-thresholded; the single `InstancedMesh2` draw call is unaffected.

**Evidence** (as recorded in the handoff): `motion.css` (tokens plus the reduced-motion kill switch), `lib/motion.ts`, `modeTransition.ts` (800ms, `easeOutCubic`, the `durationMs 0` path, replace-in-flight), `InstancedNodes.tsx` (the far-tier suppression sentinel, `transitionActive`, the dim/color model), `Graph3DScene.tsx`, `CameraRig.tsx`.

**Assumptions recorded in the handoff.** The bloom pass and per-instance emissive drive are ADDED by this handoff (today the material is plain `MeshStandardMaterial` with no composer); the tweens above specify intended, not present, behavior. Chrome objects/tokens are defined by the visual spec. The `transitioning` flag is the shared suppression signal (no new per-tick signal). Safe-tier thresholds and the announcement surface are owned by UX/engineering; auto-2D-at-mount is owned by `GraphView`.

**Unresolved decisions recorded in the handoff.** Ship ring rotation disabled (recommended) unless Browser Validator confirms it reads calm and is free; confirm the exact fog/chrome token names against the visual spec before wiring; whether bloom-restore should wait for the worker "end" event instead of blend-end if live capture shows smear on still-moving geometry (default: restore at blend end); confirm the eased-emissive-subset frame budget at 10k via Browser Validator. No timing or legibility claim is validated by this handoff; live behavior is Browser Validator territory (Section 8).

### 5.4 MOTION_ASSET_SPEC — asset (reproduced)

**Authority note.** This is a specification of placeholder generation briefs only; nothing has been generated by this handoff. No production-readiness claim is made about any asset. Every asset is enhancement-only chrome layer with a procedural/token fallback; the graph is fully functional with zero assets. Tokens (OKLCH/culori) remain authoritative for every contrast-bearing surface; assets never carry state, meaning, or audited contrast.

**Global boundary (non-negotiable, no revisit).** No node-layer generated meshes, ever — nodes stay procedural single-draw-call `InstancedMesh2`; generated assets are confined to the O(1)–O(tens) chrome/environment/landmark layer. Caps inherited verbatim from `ASSET_MANIFEST.json` and the prior plan's Section 6.7: HDRI/skybox ≤2 total, 2048×1024, <~24MB each; a terrain detail normal, 1 image, 1024×1024, <~6MB (a new class at the matcap cap tier); matcaps ≤2, 1024×1024, no baked hue, <~6MB; landmark GLBs ≤6 total including the existing obelisk/spire, each <~5,000 triangles, <~20MB set. Pipelines are fixed to the recorded workflows: images via FLUX.2-klein-4B fp8_e4m3fn through ComfyUI 0.14.1 REST (euler/simple, steps 24, cfg 3.5); GLBs via Trellis2 (`TRELLIS.2-4B`, pipeline 512, simplify to ~4,500 faces), Flux-reference-conditioned. Shared art language: deep-field astronomy through instrument-grade optics, restrained, seamless 2:1 equirect where applicable, no text/watermarks/logos/faces/named constellations, no harsh saturation.

**A1 — dark-theme equirect HDRI (refresh).** Drives both IBL (`scene.environment`, paired `--graph-env-intensity` 1.0) and the dark Terrain sky (`scene.background`) via `TerrainEnvironment.tsx` (extended by engineering to drive `environment`; today it is background-only; lineage is the existing `skybox-dusk.png` slot). Near-black→deep-indigo zenith, faint cool horizon lift, sparse soft zenith stars, an optional faint low-chroma nebula wash below label luminance, an empty flat horizon. 2048×1024 PNG, ~2–3MB target; low-key so nodes/labels always win luminance. The hue must sit inside the `--graph-terrain-sky-*`/`--graph-env-sky-*` OKLCH envelope — regenerate rather than color-correct. Manifest entry follows the existing skybox schema with `placeholder: true`, `production_ready: false`, provenance, the seam caveat, and `theme: dark`. Async loading via `useOptionalEquirectTexture`, never blocking first paint; mipmapped; sRGB background / PMREM IBL; droppable at the safe tier.

**A2 — light-theme high-key equirect HDRI (new — no light skybox exists today).** Drives light-theme IBL (`--graph-env-intensity` 1.15) and the light-Terrain sky. Luminous near-white→pale cool-blue zenith, an even diffuse dome, a faint wisp, no sun disc (a sun disc would blow out the IBL and fight the token palette), no stars. The critical pairing is the paired token darkening (node lightness 0.38, etc.) — the tokens, not the asset, preserve AA; the HDRI itself stays soft and even with no hotspots. Same pipeline and caps; the manifest must flag that engineering confirms the extended gate stays green in light theme before default-enabling this asset — otherwise it ships as a non-default alternate, following the `skybox-twilight.png` precedent.

**A3 — terrain detail/hillshade texture (tri-planar detail normal).** Strengthens Terrain micro-relief on the ground mesh over the existing vertex-color tier banding; normals only, never geometry, tiers, placement, or state. Data-type caveat: Flux generates a seamless GRAYSCALE height source; the tangent-space normal is DERIVED deterministically (Sobel/gradient) as a documented mechanical post-step. 1024×1024 PNG, LINEAR/`NoColorSpace` (an sRGB flag would invert/wash the relief), <1MB target; the manifest records both the Flux source and the derivation method, color space, `tiling: tri-planar`, and a strength hint. Subtle enough to never suggest false tiers; the safe tier drops to flat normals.

**A4 — optional refreshed matcaps.** Cooler, instrument-grade grayscale matcap sphere(s) for the `TerrainSurface` matcap slot; no baked hue (tokens supply hue). ≤2, 1024×1024; the existing `matcap-clay`/`matcap-stone` remain a valid default. Same manifest schema.

**A5 — optional landmark GLBs (Trellis2, ≤4 more toward the 6-GLB cap).** Sparse Terrain chrome flavor (a survey monument, an instrument pillar or small dish, a low standing-stone ring) via the recorded Flux-reference → Trellis2 mesh pipeline, mesh-only, <5,000 triangles each; loaded via `terrainAssetManifest.ts` `landmarks[]`; never on the community ramp, never mistakable for a node; zero landmarks remains fully legible.

**Crop/format summary.** HDRIs: 2:1, 2048×1024 PNG, horizon-centered. Normal: 1024×1024 linear tile. Matcaps: 1024×1024, no hue. GLBs: mesh-only, ≤5,000 triangles.

**Accessibility.** Every asset is decorative and stateless; the extended gating contrast test is the sole contrast authority; no information exists only in an asset; no asset introduces motion.

**Responsive/performance.** All assets load asynchronously via the existing non-throwing loaders (`terrainAssetLoading.ts`), never blocking first paint — procedural rendering shows first, assets swap in; mipmaps; correct color spaces; each asset is independently droppable to its procedural/token/existing fallback for the safe tier.

**Fallback.** A1/A2 absent → procedural token sky plus default lights, environment unset. A3 absent → `computeVertexNormals` flat plus tier banding (an optional in-shader noise intermediate). A4 absent → `MeshStandardMaterial` vertex-color or the existing clay/stone matcap. A5 absent → `TerrainLandmarks` renders nothing (existing guard). The node/edge layer is untouched in every case.

**Evidence** (as recorded in the handoff and independently confirmed by this planning pass): `web/public/terrain/ASSET_MANIFEST.json` (workflows, seeds, caps, known limits — confirmed by direct read to already list two HDRIs, two matcaps, and two landmark GLBs, all `placeholder: true`/`production_ready: false`); the prior plan's Sections 3.2/5.1/6.7/10.3; `terrainAssetManifest.ts` (the optional, non-throwing contract, `NO_TERRAIN_ASSETS` path); `TerrainEnvironment.tsx` (background-only today); `TerrainSurface.tsx` (banding, matcap fallback, landmark guard); a grep confirming `--graph-env-intensity`/`--graph-terrain-sky-*`/`--graph-env-sky-*` do not yet exist (additive, owned by the visual spec).

**Assumptions recorded in the handoff.** The environment/sky tokens are additive and owned by visual/engineering; the `scene.environment` IBL wiring is an engineering extension this packet specifies for but does not implement; suggested seeds continue the `1300xx` family with actuals recorded at generation time; size targets are budgets under the hard caps.

**Unresolved decisions recorded in the handoff.** A2 default-on versus non-default alternate (gate-dependent); A3 strength/tiling, and whether to ship the grayscale source (Browser-validated relief); which A5 subjects, if any (an optional product choice); the exact env/sky OKLCH envelope values (visual owner, regenerate-to-fit discipline); whether A1 displaces or coexists alongside `skybox-dusk.png` (the 2-HDRI cap must hold either way).

### 5.5 Design-handoff evidence citations

The evidence list attached to the `DESIGN_HANDOFF` cites, in addition to the files above: `Graph3DScene.tsx` fit/selection/context-loss/transition wiring at lines 60–180, 214–224, 388–420, 532–578, 619–646, 725–763; `InstancedNodes.tsx` single-draw-call/`colorsTexture` at lines 173–184, the dim model at lines 236–251, LOD at lines 46–143; `NodeLabels.tsx` cap at line 31, hovered/selected/top-degree at lines 52–75, outline at line 99; `CameraRig.tsx` bounded interruptible fit and reduced-motion snap at lines 555–575/643–658, interrupt handoff at lines 523–553, flat-extent Terrain fit at lines 281–435, axis avoidance at lines 149–165; `GraphView.tsx` radiogroup at line 316, live regions at lines 349/371, empty state at line 377, reading pane at lines 442–476, mounted-hidden rendering at lines 68–78, reduced/no-WebGL initial 2D at lines 102–103; `GraphA11yTree.tsx` per-mode parity trees and links table/status at lines 52–250; `CommunityBadge.tsx` SVG glyph shape plus pattern at lines 18–23; `graph.css` generative ramp at lines 46–50 and the light lightness override at lines 92–96. This planning pass directly re-confirmed a representative subset (the lighting/tone-mapping lines, the `vertexColors` black-multiply comment, the edge material, and the asset manifest contents) rather than re-verifying every cited line number; the remainder are carried forward as design-team evidence, not independently re-checked by Scribe.

### 5.6 Consolidated engineering invariants

These are the acceptance-bearing invariants carried across the `DESIGN_HANDOFF`'s top-level `engineering_invariants` field and its embedded specs, consolidated once here as the authoritative list for engineering and Verifier:

1. Nodes: single-draw-call `InstancedMesh2` driven by `colorsTexture`; NEVER `vertexColors` (the documented black-multiply bug — the `onBeforeCompile` fresnel/emissive patch must take explicit care not to reintroduce it); never per-node meshes. The pattern-id ships as a SECOND small data texture in the same mechanism family as `colorsTexture` — still ONE draw call; patterns modulate luminance, not hue alone.
2. The node/edge layer stays procedural at O(1,500–10,000); generated assets are confined to the O(1)–O(tens) chrome/environment/landmark layer; no node-layer generated meshes; asset caps and pipelines follow `ASSET_MANIFEST.json`; no boundary revisit.
3. Edges: one batched fat-line pass (Line2/LineMaterial family); weight drives width plus opacity between the `--graph-edge-weight-*` tokens; width/opacity encode weight independently of bloom.
4. Worker-owned physics; positions mutate only via refs in the single `onTick` path; never `setState` per frame; physics is never faked; no new position animation — only fog/chrome/bloom-threshold cross-fades inside the existing ~800ms interruptible envelope.
5. LOD tiers scale to camera-fit; the far tier is suppressed during transitions; bloom suppression composes off the SAME `transitioning` signal, and bloom restores only after the far-tier restore at blend end. Camera-fit on the worker "end" event — whole-graph, selection-scoped, and extent-aware Terrain fit, plus user-gesture interruption and in-flight-destination anchoring — is hard-won existing machinery and MUST NOT regress; new chrome must not alter its extent/radius inputs, and no new code writes `camera.position` or `orbit.target`.
6. Bloom: half-resolution, emissive-driven, token-driven luminance threshold, suppressed during mode transitions, off-first under `PerformanceMonitor` safe-tier degradation at 10k stress; bloom (and dim) is NEVER the sole carrier of any state — outline, size, label, glyph/pattern, and aria state always carry it.
7. Color: culori is the single source; no hardcoded hex; tokens extend, never replace; the generative ramp hue formula (`hueBase + index * (360/count)`) with level mapping to bounded chroma only (the Terrain-light darkening moves lightness via a separate mode-scoped token, never the ramp chroma path); all new/changed tokens route through the extended gating `contrast.test.ts` in BOTH themes.
8. Labels hard-capped ~40, two-tier, with community titles winning and a node-label screen-space minimum. Transitions bounded (~800ms) and interruptible; strict reduced motion (instant chrome swap, static bloom, no pulsing anywhere, camera snap, zero ambient drift); every mode has a 2D fallback with a11y-tree parity; auto-2D on genuine WebGL context loss and under reduced motion at mount.
9. No native browser dialogs (`alert`/`confirm`/`prompt`, `window.*` forms, `beforeunload`); app-owned accessible modal/inline validation and `aria-live` status only.
10. **Critical regression-risk surface**: post-processing performance at 10k nodes and its interaction with the LOD / camera-fit / selection-fit / extent-aware-Terrain-fit / context-loss machinery from the governing prior plan's Sections 3.3/5.1/11 (`Graph3DScene.tsx`, `InstancedNodes.tsx`, `CameraRig.tsx`). Re-confirming that machinery is a first-class acceptance gate (Gate A, Section 8), not an afterthought.

### 5.7 Permitted variation

- Exact bloom/fog/emissive/fresnel numerics may be tuned during implementation provided they remain token-driven, both-theme-gated, and within the stated budget mitigations.
- The Terrain-light darkening may land either as the `[data-theme="light"][data-graph-mode="terrain"]` scoped override with a terrain-aware `graph-colors.ts` branch, or as an equivalent mode-scoped numeric token consumed only in Terrain — engineering's choice, provided it is one culori path either way.
- The F5 secondary-text fix may land as the chosen global light `--color-text-secondary` → `--neutral-200`, or as a scoped `--color-text-secondary-on-inset` token if review prefers preserving non-inset appearance — both variants must pass the extended inset audit.
- The fat-line implementation choice (drei `Line2` vs. three fatlines) is free provided it stays one batched pass; the emissive-easing granularity (a per-frame eased subset vs. a discrete target with eased opacity only) is free provided the 10k frame budget holds; chrome billboard counts are free within O(tens).
- Orbital ring ambient rotation ships disabled; enabling it is permitted only after a live validation confirms ≤3 deg/s reads calm at no measurable frame cost. A1 may refresh the `skybox-dusk` slot or coexist with it, holding the 2-HDRI cap; A4/A5 are entirely optional.
- The effects-control surface (an Auto-default segmented control vs. automatic-only safe tier) is a product decision recorded under Section 13; the safe-tier rig itself is not optional.

### 5.8 Independent design review

**Result: PASS** (independent Design Reviewer; reviewed direction "Deep-Field Observatory"; all findings recorded as strengths, no revision cycle required). Remaining limits, recorded here as plan-stage acceptable, verification-dependent — not blockers:

- The extended `contrast.test.ts` must actually be authored and pass green in BOTH themes for every new gated pairing, with the existing 8/16/32 ramp gate still green; this is a Phase 1 deliverable, not yet done.
- Every timing and ratio in the specs above is a target requiring Gate A plus Gate B browser validation (Section 8), not a measured or observed result.
- ACES tone mapping remaps in-scene luminance, so the Gate B community-identity-at-~4–6px screenshots must confirm in-scene legibility after tone mapping is applied; identity is redundantly carried by pattern, glyph, title, outline, aria, the 2D fallback, and the a11y tree, so no single channel failing is fatal, but the in-scene channel itself must still be checked.
- `GraphA11yTree`'s visually-hidden-but-focusable behavior, plus deterministic canvas-container focus (never a trap), must be confirmed both in implementation and in a live keyboard pass.

### 5.9 Approval-gated architectural decisions

Two additional decision points are presented here for explicit user sign-off ALONGSIDE plan approval (Section 15), not pre-authorized by the phase sequencing in Section 6. Each requires an explicit accept/reject before its owning phase treats it as settled scope.

**Decision A — Community-centroid glyph-sprite/badge layer (first needed in Phase 2).**

This is an O(tens) billboard chrome layer (Section 3.1 item 2; Section 5.2 "Components and states") that renders as additional draw call(s) BEYOND the single-draw-call node `InstancedMesh2`. The single-draw-call invariant (Section 5.6 item 1) applies specifically to the node/edge layer; this badge layer is a separate chrome-layer addition in the same family as the existing `CommunityHulls`/`NodeLabels` objects, not a violation of that invariant — but its draw-call-budget cost is a real, distinct decision this plan has not separately surfaced until now.

- **If ACCEPTED**: Phase 2 implements the centroid glyph/badge layer as specified in Section 3.1 item 2 and the J-CLOUD/J-ORBITAL/J-STRATA/J-TERRAIN journeys (Section 5.1).
- **If DECLINED**: community identity at small pixel sizes is still carried by the per-instance shader pattern-id (Section 3.1 item 2; Section 5.2 "Color and contrast"), community titles/labels (Section 5.2 "Typography"), the 2D fallback, and the a11y tree (`CommunityBadge`/`GraphA11yTree` parity). The refined direction remains coherent without the badge layer. Phase 2 skips the centroid-badge implementation step, and Section 5.1's centroid-badge journey language becomes conditional on this decision.

Present for accept/reject alongside plan approval.

**Decision B — `@react-three/postprocessing` as a new runtime dependency (first needed in Phase 4).**

`web/package.json` today has NO `@react-three/postprocessing` dependency (confirmed by direct read: `dependencies` lists `@react-three/drei ^9.114.3`, `@react-three/fiber ^8.17.10`, and `three ^0.169.0`, with no postprocessing package present). Adding it for the selective-bloom-plus-vignette post chain (Section 3.1 item 4; Section 5.2/5.3 bloom tokens) would be a NEW runtime dependency, not an existing one.

- Version/compatibility: it must match the repository's `@react-three/fiber ^8` / `three ^0.169` line. The R3F-v8-compatible major of `@react-three/postprocessing` is the v2.x line (wrapping the separate `postprocessing` npm package). Confirm the exact compatible version at implementation time against the installed `@react-three/fiber`/`three` versions; this plan does not fabricate a pinned version number.
- **If ACCEPTED**: Phase 4 adds `@react-three/postprocessing` (v2.x line, exact version confirmed at implementation) and implements the bloom/vignette chain through its `EffectComposer`.
- **If DECLINED**, fallback (engineering's choice unless the user specifies otherwise):
  1. Implement the bloom/vignette chain with three's built-in `EffectComposer` plus `UnrealBloomPass` from `three/examples/jsm/postprocessing` — no new npm dependency, using the already-installed `three` package.
  2. Drop bloom to the safe-tier flat-highlight treatment entirely (Section 5.3 "Safe-tier choreography" step 1).

  In every case the scene stays fully functional per Section 7's backward-compatibility guarantee, and no state is carried by bloom alone (Section 5.6 item 6) regardless of which path is taken.

Present for accept/reject alongside plan approval.

**Phase linkage.** Section 6 Phase 2 proceeds under Decision A's outcome; Section 6 Phase 4 proceeds under Decision B's outcome. If a decision is declined, the owning phase uses the stated fallback rather than the default path. See Section 15 for the approval mechanism.

## 6. Ordered work

No engineering step below may begin before explicit user approval of this plan (Section 15). Deterministic gate failures always dominate advisory judge findings. Owner for every phase is `t2-engineer` (Sonnet), the sole engineering writer for this plan (Section 14); T1 is not used.

### Phase 0 — Readiness and baseline

- **Owner**: T2. **Dependency**: explicit user approval of this plan.
- Establish green baselines: `python -m pytest` (~419 tests, confirm exact count at readiness — labeled assumption), `cd web && npx vitest run` (~413 tests, confirm exact count at readiness), and `make check`.
- Build the static frontend so `/app` serves: `cd web && npm install && npm run build`.
- Capture the current camera-fit/LOD/context-loss test suite results as the explicit regression baseline that Gate A (Section 8) must not fall below.
- Confirm ComfyUI is reachable at `127.0.0.1:8188` for the later asset phase; starting ComfyUI at `H:\LocalAI` locally, as needed, is pre-approved (carried standing override, Section 12).

### Phase 1 — Foundation, tokens, F5, and the contrast gate

- **Owner**: T2. **Dependency**: Phase 0 complete. **Discipline**: test-first for every token-consuming code path.
- ACES tone mapping at the `Canvas`.
- Add every additive DTCG token family listed in Section 5.2, per theme where applicable.
- Extend `graph-colors.ts`: add `readBloomParams` mirroring `readCommunityGeneratorParams`; add the terrain-aware/mode-scoped light-lightness branch as one culori path (per the permitted variation in Section 5.7).
- Land the F5 fixes: light `--color-text-secondary` → `--neutral-200` (or a scoped on-inset token, per Section 5.7); `--color-highlight-surface`/`--color-text-on-highlight`; the search-mark fix; true-disabled styles with a non-color marker plus `aria-disabled`.
- Extend `contrast.test.ts` with every new both-theme pairing listed in Section 5.2's contrast-test-extension scope, and confirm the existing 8/16/32 ramp gate stays green.
- **Gate**: this extended contrast gate must be green before any dependent visual phase (2–5) lands its token-consuming code.

### Phase 2 — Node material, community identity, and labels

- **Owner**: T2. **Dependency**: Phase 1 complete.
- **Decision gate**: this phase proceeds under Decision A's outcome (Section 5.9). If Decision A is declined, skip the centroid-badge implementation step below and rely on the pattern-id/title/2D-fallback/a11y carriers already specified.
- Implement the `onBeforeCompile` fresnel rim plus per-instance emissive, taking explicit care against the black-multiply bug (Section 3.3, Section 5.6 item 1): single draw call, `colorsTexture`, never `vertexColors`.
- Implement the second data-texture pattern-id (luminance-modulating community identity) and the non-luminance outline.
- Implement O(tens) community-centroid glyph badges (conditional on Decision A, Section 5.9).
- Implement the two-tier label system: community titles win the ~40 cap; node labels carry the screen-space minimum size.

### Phase 3 — Edges and weight readout

- **Owner**: T2. **Dependency**: Phase 1 complete (may run in parallel with Phase 2).
- Implement a single fat-line pass (Line2/LineMaterial family) with weight-driven width and opacity.
- Add the reading-pane Connections list with numeric weight, plus the a11y Weight column.
- Implement the `"weight: n/a"` fallback for missing weight.

### Phase 4 — Post chain and safe tier

- **Owner**: T2. **Dependency**: Phases 2 and 3 complete (needs emissive drive from Phase 2 and, for full budget testing, the edge pass from Phase 3).
- **Decision gate**: this phase proceeds under Decision B's outcome (Section 5.9). If Decision B is declined, implement the fallback (three's built-in `EffectComposer`/`UnrealBloomPass`, or drop to the safe-tier flat-highlight treatment) instead of adding `@react-three/postprocessing`.
- Implement half-resolution, emissive-driven, token-thresholded selective bloom plus vignette.
- Compose bloom suppression off the existing `transitioning` signal; restore bloom only after the far-tier LOD restore.
- Implement the `PerformanceMonitor` safe-tier degradation ladder (bloom → ambient freeze → chrome → LOD) with polite `aria-live` announcements.
- Implement the effects/quality control (Auto/Full/Balanced/Minimal).
- **Early exit criterion (before Phase 5 begins)**: run the Gate A 10k post-processing performance benchmark (Section 8.2 item 8) on the target RTX 3080 Ti host across all four modes and all three effects tiers. At least one non-Minimal tier must meet the interactive target (p50 ≥ 30 FPS, p95 ≤ ~50ms) at 10k for post-processing to proceed into Phase 5's per-mode chrome work as currently scoped. If only Minimal meets the target, do not proceed on the assumption that post-processing works at 10k — surface the capped-node-ceiling-or-drop decision back to the user before Phase 5 begins, per the anti-loophole clause in Section 8.2 item 8.

### Phase 5 — Per-mode chrome and 2D/a11y parity

- **Owner**: T2. **Dependency**: Phases 1–4 complete.
- Cloud: nebula haze. Orbital: disc, rings, core glow, inclination. Strata: floor planes, edge-lit rims, etched labeled axis. Terrain: hillshade, contours, theme-paired sky, plus the structural light-theme darkened-elements solution.
- Matching 2D-fallback chrome and a11y-tree parity for every mode.
- Motion cross-fades stay strictly inside the existing ~800ms interruptible envelope, with the strict reduced-motion path (Section 5.3).

### Phase 6 — Chrome-layer assets

- **Owner**: T2, using ComfyUI REST plus Trellis2. **Dependency**: Phase 5 complete; enhancement-only, never blocking.
- Generate A1 (dark HDRI refresh), A2 (light high-key HDRI, new), A3 (terrain detail/hillshade normal, Flux grayscale source plus a documented deterministic Sobel/gradient normal derivation), and optionally A4 (matcaps) and/or A5 (landmark GLBs).
- Extend `TerrainEnvironment.tsx` to drive `scene.environment` IBL (PMREM) plus `scene.background`.
- Every asset is placeholder-labeled in `ASSET_MANIFEST.json`, loaded asynchronously and non-blockingly, with a procedural fallback. Hard caps held: HDRI ≤2 total, normal 1, matcaps ≤2, landmarks ≤6 total including the existing two.

### Phase 7 — Closeout

- **Owner**: T2 plus independent gates. **Dependency**: Phases 0–6 complete.
- Full green pytest/vitest/`make check`.
- The extended contrast gate green in both themes.
- An independent Verifier pass.
- A Browser Validator pass covering Gate A and Gate B (Section 8) across all viewports, both themes, reduced-motion, and forced-colors.
- Applicable Codex judge checkpoints (Section 12).
- A refreshed `ASSET_MANIFEST.json`.
- No commit, push, deployment, or pull request without a separate, explicit, later user approval.

## 7. Interfaces and data

No server or API contract changes. Edge weight is already served (`store.py:629`) and already typed on the client (`VizEdge.weight` optional) — this plan is client wiring and presentation only. All changes are additive DTCG tokens plus client rendering/material/chrome plus generated chrome-layer assets. The `/api/query` legacy mode contract and the P6 egress-gate behavior are preserved untouched. Node data shape (`community`/`level`/`centrality`/`parentCommunity`) already exists from the prior plan's enriched-contract phase and is not changed here. Every change is backward compatible: every generated asset and every new effect has a procedural/token fallback, and both zero-assets and the safe tier leave a fully functional graph.

## 8. Acceptance and validation

Gate order: deterministic tests → independent Verifier → Browser Validator Gate A, then Gate B → applicable Codex checkpoints. Neither writer output nor judge output alone constitutes completion at any phase.

### 8.1 Deterministic gates

Full `pytest`/`vitest`/`make check` green; the extended `contrast.test.ts` green in both themes with the existing 8/16/32 ramp gate still green.

### 8.2 Gate A — prior-machinery re-confirmation (first-class; any failure blocks)

1. LOD tiering: at settled fit, on manual zoom-out, and during a mode transition, the expected tier distribution renders; far-tier suppression engages and restores correctly with no near-black flat-quad frames.
2. Camera-fit: on load, hard reload, every mode switch, and every selection, including small-focus-set axis correction; a user-gesture mid-fit cancels the fit the same frame.
3. Extent-aware Terrain fit: the new chrome does not change the flat-shape fit's framing inputs, in both themes.
4. WebGL context-loss: auto-2D fires correctly with the status announcement and state intact; the manual 2D/3D toggle does not misfire the loss path.
5. Draw calls: exactly one node draw call and one batched edge pass across ALL FOUR modes at ~1,500 nodes and stressed toward 10,000 (via `renderer.info`), with the post chain staying within budget or degrading per the safe tier.
6. Wiki round trip: selection, expansion, filters, mode, and camera all survive with no worker restart.
7. Mode transitions remain ~800ms and interruptible, with no new position animation.
8. **Post-processing performance benchmark at 10k (concrete, reproducible, hardware-specific; required as an early Phase 4 exit criterion, Section 6, not deferred only to closeout).**
   - **Hardware**: MUST run on the target RTX 3080 Ti / 12GB GPU host (`H:\LocalAI`). Results from any other machine do not satisfy this gate.
   - **Environment**: Chrome (record the exact version at run time); viewport ~1440px; DPR recorded at both pinned DPR 1.0 AND with the app's `AdaptiveDpr` range 0.75–2 active (`PerformanceMonitor`/`AdaptiveDpr` are live in this app); tone mapping and the post chain enabled.
   - **Fixture/mode matrix**: `?syntheticGraph=10000` across ALL FOUR modes (Cloud, Orbital, Strata, Terrain), including the worst case — Terrain in LIGHT theme (sky plus hillshade plus contours plus bloom together).
   - **Effects tiers measured separately**: Full, Balanced, Minimal.
   - **Method**: a warm-up window (discard until the graph has settled and camera-fit has completed, approximately the first 2s), then a timed steady-state sample window of at least approximately 10s, captured under both an idle condition and a continuous-orbit condition; capture the full frame-time distribution, not only an average.
   - **Evidence captured**: p50 and p95 frame-time (ms) and FPS per tier/mode/theme combination; `renderer.info` (draw calls — confirm exactly one node `InstancedMesh2` draw call plus one batched edge pass holds under the post chain — geometries, textures, programs); approximate VRAM via `nvidia-smi` on the RTX 3080 Ti host during the run (the browser's JS heap figure is NOT VRAM and must not substitute for it).
   - **Thresholds** (acceptance TARGETS to confirm against captured actuals — never fabricated or assumed measured results): interactive = p50 ≥ 30 FPS (frame-time ≤ ~33ms) and p95 ≤ ~50ms at 10k on the target GPU.
   - **Pass/fail rule per tier**: at least one non-Minimal tier (Full or Balanced) MUST meet the interactive target at 10k on the target GPU for the post-processing feature to be ACCEPTED. Minimal must clear the interactive target comfortably, as the guaranteed floor.
   - **Anti-loophole clause (explicit)**: if ONLY Minimal (safe-tier, bloom off) meets the interactive target, this gate does NOT pass on that basis. That outcome means bloom/post-processing is not feasible at 10k on the target hardware and MUST be surfaced back as a decision — either cap post-processing to a lower node ceiling, or drop it — never silently accepted via the Minimal-tier fallback. If this arises, route it back to the user before Phases 5–6 proceed on the assumption that post-processing works at 10k, following the same accept/reject discipline as Decision B (Section 5.9).

### 8.3 Gate B — new visual acceptance (screenshot-first, both themes)

1. Focus-as-light is legible with bloom forcibly off.
2. Community identity is distinguishable at ~4–6px via pattern plus centroid glyph badges, with the legend, badge, 2D fallback, and a11y tree in agreement.
3. Two-tier labels behave as specified under viewport pressure.
4. Edge-weight width/opacity plus the numeric readout match served data, including the `"weight: n/a"` fallback.
5. Per-mode chrome is screenshotted in both themes, with 2D/a11y parity confirmed for every mode.
6. Light-theme Terrain shows visible node-vs-sky separation, and the extended contrast gate is green.
7. F5: enabled text ≥4.5:1 including the inset/selected card surface, a legible search mark, and a visually distinct true-disabled state.
8. Motion and reduced-motion behavior matches Section 5.3.
9. The safe-tier degradation ladder sheds effects in order with no blackout.
10. A deterministic no-native-dialog scan returns zero matches; app-owned modal/sheet/popover keyboard-focus behavior is verified.

## 9. Browser UI dialog policy

Required and unchanged from the governing prior plan. Prohibited without exception: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`. The current source scan is clean and must remain clean through every phase. Any acknowledge/confirm interaction uses an app-owned accessible Radix `Dialog` (focus trap, initial focus, Escape-to-cancel, focus restoration to the invoking element, visible buttons); inline validation is used for load/error states. The new reading-pane bottom sheet, the legend popover, and the effects control are all app-owned and require keyboard/focus verification: focus enters correctly, is trapped where modal, Escape restores invoker focus, and the visible focus ring is ≥3:1 contrast. The deterministic no-native-dialog scan (zero matches) is a gate on every UI-affecting phase (2, 4, 5).

## 10. `browser_ui_validation` inputs

- **Launch/readiness**: `pip install 'mythic-proportion[web]'` (plus `[graphrag]`/`[privacy]`/`[local]` extras); `mythic serve` reaching `http://127.0.0.1:8765/` and `/app/` only after `cd web && npm install && npm run build` produces `static_next`; Vite dev via `cd web && npm run dev` reaching the printed URL near `http://localhost:5173/app/` (confirm the exact port at launch). Readiness means the route serves and the Graph route mounts with a settled graph (worker "end" reached).
- **Base URL**: `http://127.0.0.1:8765/` (served `/app/`) and the printed Vite dev URL.
- **Fixture/reset**: `?syntheticGraph=N` (for example, N=10000) for deterministic ~1,500-node and stress-toward-10,000 graphs without a live backend; an enriched fixture carrying `community`/`level`/`centrality`/`weight`; a fixture lacking per-node fields to exercise the union-find fallback; an empty-entity fixture for the empty state; for real data, run `mythic index-graph` against a demo vault. Reset between journeys by reloading the owner-scoped route. The LLM path stays mocked in automated tests.
- **Journeys**: Gate A and Gate B (Section 8), across all four modes and both themes.
- **Viewport profiles**: ~1440 desktop, ~834 tablet, ~375 narrow, plus 400% zoom / 320px reflow; each in both light and dark `data-theme`; plus a reduced-motion pass and a forced-colors spot check.
- **Visible outcomes**: `renderer.info` single-node-draw-call and single-edge-pass counts recorded across all four modes at 1.5k and 10k; camera-fit/LOD/context-loss re-confirmation evidenced; extended contrast-gate output recorded; per-mode chrome plus focus-as-light plus community-identity-at-4–6px plus edge-weight plus F5 screenshots in both themes; safe-tier degradation and reduced-motion behavior recorded; zero native dialogs; correct modal/sheet/popover focus behavior confirmed. Chrome-first with a Playwright fallback.

## 11. Risks and rollback

| Risk | Mitigation | Rollback/containment |
|---|---|---|
| Post-processing performance at 10k nodes interacting with the extensively hard-won LOD/camera-fit/selection-fit/extent-aware-Terrain-fit/context-loss machinery. | Gate A re-confirmation as a first-class acceptance gate; half-res/token-thresholded/transition-suppressed bloom; `PerformanceMonitor` safe-tier degradation; every effect additive behind a token/procedural fallback. | Each effect, mode-chrome item, or asset is behind a token or effects-tier switch and independently revertible without touching the others, defaulting to the current working scene. |
| Reintroducing the documented black-multiply bug via the `onBeforeCompile` node-material patch. | Keep the `colorsTexture`/pattern-texture path; never `vertexColors`; a `CODE_REVIEW` Codex checkpoint targets this shader diff specifically. | Revert the `onBeforeCompile` patch; the material falls back to the current plain `MeshStandardMaterial` path. |
| New tokens failing AA or colliding with existing status hues. | The extended both-theme gating test (Phase 1) must pass before any dependent visual phase lands; non-color cues are required everywhere. | Additive tokens are removable without touching existing token values. |
| Asset generation on a 12GB-VRAM local GPU is slow or variable-quality. | Enhancement-only with fallbacks; hard caps; every asset placeholder-labeled. | Any individual generated asset can be omitted; the graph is fully functional and legible with zero assets. |
| Browser-dialog regression. | The deterministic no-native-dialog scan gates every UI-affecting phase; current state is clean. | Preventive gate, not a rollback scenario. |

**Escalation path** (recorded within standard gates — not an extreme-advisory team by default): this repository has a track record of resolving genuinely hard problems via a T3 Opus read-only advisory pass followed by a Fable engineering pass. That escalation stays available for the highest-risk items specifically: post-chain performance at 10k, the shader black-multiply risk, and the extent-aware-fit interaction with new chrome. The standard T2 rule applies unchanged: two counted deterministic-remediation gate failures escalate for user review; research, stale-plan, credential, and unavailable-prerequisite failures do not count toward that threshold.

**Stale-plan condition.** This plan becomes stale if the `mythic-proportion` working tree changes materially, if the current test/build baselines differ materially from Phase 0's findings, if the passed `DESIGN_HANDOFF` or its independent review changes, or if any standing override recorded in Section 12 is withdrawn. A stale plan requires replanning or explicit reapproval before any further engineering continues against it.

## 12. Judge route

Standard Codex cross-vendor judging per `docs/JUDGE-CONTRACT.md`. Deterministic gate failures always dominate any judge opinion; respect the standard two/four call caps and the shadow-versus-blocking policy; provenance from any judge finding is ignored/advisory unless independently evidence-backed. No live smoke calls occur without separate, explicit usage approval. This is a **new** planning/build cycle with a **fresh** standard call budget — the prior plan's cycle consumed 5 total calls, and none of that budget carries forward.

Expected checkpoints:

- **`PLAN_DUCK`** on this plan draft (advisory shadow, unless the orchestrator selects blocking mode) before user approval.
- **`CODE_REVIEW`** on the highest-risk diffs: the `onBeforeCompile` node-material/emissive/pattern-texture shader work (given the documented black-multiply history), the fat-line edge pass, and the post-chain/safe-tier wiring.
- **`VERIFICATION_CHALLENGE`** at closeout.
- **`VISUAL_REVIEW`** on the four-mode, both-theme visual implementation at the browser-validation stage — central to this plan.

**Overage flag**: the four-mode × both-theme `VISUAL_REVIEW` surface may exceed the standard call caps; any overage requires explicit user approval, exactly as the prior cycle's one `VISUAL_REVIEW` overage did.

**Operational correction to apply this cycle**: the prior cycle's `VISUAL_REVIEW` was mis-scoped to the `mythic-proportion` repository and could not read the governing plan, which made its findings screenshot-only. This cycle, set the judge target/path-scope to the orchestrator repository where this plan lives (`H:\CommandCenter\orchestrator`), and/or supply this plan and the `DESIGN_HANDOFF` content directly to the judge run, so `VISUAL_REVIEW` can read the approved design intent alongside the screenshots.

## 13. Assumptions and acceptable open decisions

Acceptable to settle during engineering with product/engineering judgment, labeled, never fabricated:

- The effects/quality-control surface — recommend shipping the inspectable Auto/Full/Balanced/Minimal control.
- A deterministic community-title selection rule beyond 12 visible communities.
- Edge-weight readout scope: reading-pane Connections baseline versus also in-canvas edge picking (feasibility-gated).
- The F5 landing shape: global light `--color-text-secondary` darkening versus a scoped on-inset token — both variants must pass the extended gate.
- Exact bloom/fog/emissive numerics plus per-mode fog densities, pending 10k GPU profiling.
- Orbital ring ambient rotation — recommend shipping disabled, enabling only on live validation.
- A2 light-HDRI default-on versus non-default alternate (light-theme gate-dependent).
- Optional A4/A5 assets, and whether A1 refreshes or coexists with the `skybox-dusk` slot (the 2-HDRI cap holds either way).
- Bloom-restore timing: blend-end default versus worker "end" if live capture shows smear.
- Whether the safe tier retains the fresnel rim.
- Test baselines (~419 pytest / ~413 vitest) are confirmed at Phase 0 readiness, not fabricated here.

## 14. Captured standing overrides (carried forward from the governing prior plan)

- Atelier/ComfyUI standing tool availability (Flux over SDXL, Trellis2); ComfyUI at `H:\LocalAI` pre-approved to start locally.
- Opus-default / Fable-sparing design-model tiering, applied to this plan as Fable 5 (high) for the Studio direction synthesis, with Opus 4.8 (high) as the recorded fallback tier.
- T2 as the sole engineering writer for this plan, with no prior T1 attempt.
- Standard Codex judging (Section 12).
- Work stays on local `main`; no push without a separate, explicit, later user approval.
- The additive-token-family approval precedent from the governing prior plan (its Section 7/10.7): this pass proposes further additive token families (Section 5.2, Section 7) and, consistent with that precedent, those families require the same explicit approval discipline before engineering treats them as final — see Section 15.

## 15. Required approvals

1. **Explicit approval of this plan as a whole**, before any `t2-engineer` work begins (Section 8's phases, Section 6). This approval also constitutes approval of the additive token families listed in Section 5.2/7 as proposed for this plan; consistent with the Section 14 precedent, the user may confirm them as adopted-final either at this approval or via a distinct follow-up confirmation before Phase 1 lands them into `contrast.test.ts` as gated, non-removable pairings. Engineering must not treat any new token value as final ahead of that confirmation.
2. **Decision A and Decision B, accept/reject** (Section 5.9), presented alongside item 1's whole-plan approval and not pre-authorized by it: Decision A governs whether Phase 2 implements the community-centroid glyph/badge chrome layer; Decision B governs whether Phase 4 adds `@react-three/postprocessing` as a new runtime dependency or uses the stated fallback. If either decision is silent at approval time, the owning phase (Section 6) must not proceed past its decision gate until the user resolves it.
3. **Separate, later, explicit approval** of any commit, push, deployment, or pull request; this plan's approval does not cover any of those actions.
4. **Explicit user approval** for any Codex judge call overage beyond the standard caps (Section 12).

## 16. Engineering mode and downstream ownership

- **Engineering mode**: standard. `t2-engineer` (Sonnet) is the sole engineering writer for every phase in Section 6, with no T1 attempt (T1 is unavailable for this plan, per the carried routing override). All standard gates apply: an independent Verifier pass, a Browser Validator pass for every UI-affecting phase, applicable Codex judge checkpoints, and the standard T2 two-counted-failure escalation rule (Section 11).
- **Team authorization**: not applicable to this plan.
- **Downstream owner**: engineering-fleet, and only after explicit user approval of this plan (Section 15). The approved plan path becomes `ENGINEERING_JOB.approved_plan`.

## 17. Approval gate

Status (top of file): **APPROVED**. Approved by rob.hasselbach@gmail.com on 2026-07-18, as the plan as a whole (Section 15, item 1) and covering Decision A and Decision B, both APPROVED (Section 15, item 2; Section 5.9). This plan recommends the work in Sections 6 through 12; execution authority for `t2-engineer` to begin Section 6's phases is now granted, per this approval and Section 16. Separately, and later, any commit, push, deployment, or pull request still requires its own explicit user approval (Section 15, item 3); none of that authority is granted by this approval. Separately, any Codex judge-call overage beyond the standard caps (Section 15, item 4; Section 12) also still requires its own explicit user approval, not granted here. Upon approval, Scribe updated this plan's Status line to record the approval (date and approving party); that update is now complete, and the orchestrator will pass this exact path as `ENGINEERING_JOB.approved_plan` to the engineering fleet.

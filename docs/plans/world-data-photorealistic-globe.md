# Plan: world-data-photorealistic-globe — "Living Signal" Photorealistic Data Globe

## Status

**APPROVED. Explicit user approval received on 2026-07-18.**

This plan recommends work. It does not grant execution authority. No engineering writer (T1/T2/T3/Engineering Lead) may start work against this plan until the user gives explicit approval (see "Required Approval" below). Approval of this plan, if and when given, will not itself authorize any commit, push, deployment, or pull request; those remain separate, later, explicit user approvals.

Phase 1 engineering may now begin under this plan, per the phased ordered work below.

This revision integrates advisory PLAN_DUCK cross-vendor judge findings (launch inputs, Phase 1 accessibility, WebGL fallback correction, performance-degradation ladder, imagery acquisition pipeline, licensing verification, and accessibility acceptance criteria) without changing the design direction or the independent design review PASS.

task_id: `world-data-photorealistic-globe`
plan_id: `world-data-photorealistic-globe`
route: engineering
target: `H:\CommandCenter\orchestrator\world-data`
risk: high (greenfield, browser-UI, novel Studio design direction, multi-phase)
engineering_mode: standard (auto → phased/MVP-first; NOT extreme-advisory-team)

## Outcome & Audience

A public wow-factor exhibit/spectacle web experience — a photorealistic, freely rotatable/pannable/zoomable 3D Earth under the creative thesis "Living Signal" ("Earth is broadcasting; you are tuning in") — that renders real keyless public-API data as luminous per-category emission signatures at correct latitude/longitude, with an orbital filter ring, tethered attributed detail cards, an opt-in client-side "Conduct the Earth" webcam gesture mode, and full accessibility parity.

Audience: walk-up exhibit/kiosk and casual web visitors; curious return visitors; screen-reader/keyboard-only/motion-sensitive users who require equal information access; gesture-mode explorers; attribution-conscious visitors and data-source owners.

## Scope

- Photorealistic 3D Earth rendering (day/cloud/night-lights layers, bump/specular/normal maps) per the research-grounded imagery evidence.
- Mouse/touch/keyboard rotate-pan-zoom camera controls.
- A data-layer/filter UI (orbital ring plus list fallback) toggling categories of geo-mapped data.
- Correct lat/lon placement of data overlays.
- A server-side/edge proxy-and-cache layer wrapping the unauthenticated public APIs per the architecture guardrails.
- Optional, opt-in, locally-processed webcam hand-gesture control ("Conduct the Earth").
- Documented architecture/tech-stack rationale.

## Non-goals

- Custom satellite-imagery pipeline (a live/dynamic satellite-imagery capture-and-processing system — for example, building your own ingestion service that continuously pulls and processes raw satellite feeds, or running your own remote-sensing pipeline). Not: the one-time, build-time task of downloading existing published NASA/Natural Earth static imagery assets and pre-processing them into tiered KTX2 textures for self-hosting — that is a normal asset-pipeline build step, is explicitly required by Phase 1 (see "Ordered Work"), and is not a "custom satellite-imagery pipeline" in the sense this non-goal excludes.
- Authenticated/paid API integrations (recorded only as a future-extension note; not built).
- Custom ML model training for gestures — use pretrained in-browser MediaPipe/TF.js-class models only.
- Native desktop packaging, unless engineering finds strong reason otherwise during execution (not assumed by this plan).
- End-user accounts/authentication.
- Commit, push, deployment, or pull request without a separate, explicit, later user approval.

## Constraints

- **Browser UI invariant.** No native dialogs (see "Browser UI Dialog Policy" below).
- **Webcam privacy.** Gesture mode is strictly opt-in, local-only, and non-uploaded, with full non-gesture parity at all times.
- **Upstream courtesy.** Respect upstream API rate limits, CORS behavior, and fair-use terms.
- **Performance.** Plan for 8K-class textures with a tiered/degradable pipeline.
- **Accessibility — seven non-negotiables** (verbatim from the approved design handoff, preserved as stated requirements, not re-derived):
  1. Radial keyboard operation with roving tabindex plus a straight-list fallback.
  2. Mandatory static equivalents for every animated data signature.
  3. Vestibular-safe motion caps.
  4. A first-class non-visual companion data view with 100% parity.
  5. Fixed-luminance translucent scrims meeting WCAG 2.2 AA analytically.
  6. A discoverable attribution/credits surface.
  7. No native browser dialogs.
- **Licensing verification gate.** No imagery asset or data-API endpoint may be integrated until its license/terms-of-use and attribution line are verified per the Phase 1 checklist (see "Ordered Work" and "Risks & Rollback"); the app must not ship with PLACEHOLDER attribution copy (this reinforces engineering invariants 11 and 12).
- **Stack.** Research-grounded and already fixed (see "Research Evidence"); this plan does not re-derive the stack decision. Frontend scaffold: Vite + React + TypeScript, dev command `npm run dev`, base URL `http://localhost:5479` (see "Repository Findings" and "Browser UI Validation").

## Repository Findings

`H:\CommandCenter\orchestrator\world-data` is greenfield. This was independently confirmed by the design reviewer via a directory listing during the Studio design pass. The only artifact present is a research-evidence markdown file, `Unauthenticated Public Data APIs in 2026 — Landscape, Architecture, and Integration Strategy.md`. There is no prior source code, no build scaffolding, no design system, and no existing UI to preserve.

`existing_system_mode`: **greenfield**. All build scaffolding, source code, tests, and design tokens are new work under this plan. Because the target is uninitialized, this plan fixes the local dev-server launch command and base URL now — Vite + React + TypeScript scaffold, dev command `npm run dev`, base URL `http://localhost:5479`, with the proxy backend on port `3479` — rather than deferring it to future scaffolding. The Phase 1 scaffolding step is responsible for realizing this fixed command, not for deciding it (see "Ordered Work" and "Browser UI Validation").

**Port note.** The frontend and proxy ports were changed from their original Vite/proxy defaults (5173/3001) to the dedicated values above during Phase 1 implementation, with explicit user approval, because port 5173 was found to collide non-deterministically with an unrelated project's dev server on the shared development machine and port 3001 collided with an unrelated pre-existing Docker process; this was verified working (`npm run dev` starts both cleanly, the frontend and proxy both respond correctly including the `/api` proxy rewrite, and the full test suite passed with no regression).

## Research Evidence

Research for this plan is complete and is reused verbatim below, not re-derived. The source packet is `world-data\Unauthenticated Public Data APIs in 2026 — Landscape, Architecture, and Integration Strategy.md`.

**Rendering stack.** react-three-fiber + Three.js, layered PBR sphere; WebGL2 as the default renderer with WebGPU as an opt-in path; 2K/4K/8K KTX2 texture tiers. `globe.gl` was evaluated during research as an alternate WebGL-based rendering library option; like the primary stack, it depends on WebGL and is explicitly not a no-WebGL fallback (see "Risks & Rollback" and "Ordered Work" Phase 2). `deck.gl` was evaluated and rejected because it does not support free rotation.

**Imagery sources.**
- Day albedo: NASA Blue Marble Next Generation.
- Night lights: NASA Black Marble / GIBS.
- Cloud layer: GIBS / community cloud composite.
- Bump/relief: Natural Earth relief data.
- Specular: a water/specular mask.
- Acquisition pipeline: a one-time, build-time download/pre-process step converts the sourced imagery above into the tiered KTX2 texture set (2K/4K/8K, per the design asset spec) using KTX2/Basis compression tooling (for example KTX-Software `toktx`, or gltf-transform/basisu). This runs at build time, not at runtime. The processed KTX2 assets are served as self-hosted static assets from the app's own origin (bundled/served from the app's static-asset path, or an app-controlled CDN); runtime never contacts NASA/GIBS tile servers, which satisfies the no-hotlinking invariant.
- Refresh cadence: day/night/relief layers are effectively static. The cloud composite is the only time-varying layer; the MVP uses a static representative cloud composite baked at build time. An optional scheduled build-time re-fetch/re-tile cadence for cloud freshness is a recorded open decision (see "Assumptions & Open Decisions") — either way it remains a build-time step, never a runtime dependency.
- These sources are believed to be public-domain / open, but this is not yet verified fact: each source requires per-source license and attribution verification before its assets are integrated (see "Constraints", "Ordered Work" Phase 1, and "Risks & Rollback"). Imagery is self-hosted and tiled — no runtime hotlinking of NASA/GIBS tile servers.

**Keyless MVP geo-data roster** (no API key required): USGS earthquakes; NASA EONET (wildfire/volcano/storm); Open-Meteo (per-point weather); wheretheiss.at (ISS live position); NWS US alerts (requires the proxy layer); REST Countries plus World Bank (choropleth); NASA GIBS science rasters.

**Phase-2 candidate roster** (not in this plan's MVP scope, recorded for future extension): GDACS, NHC, NOAA CO-OPS tides, adsb.fi/adsb.lol, aviationweather METAR.

**Explicitly excluded** (now-keyed sources, future-only, out of scope for this plan): OpenSky, OpenAQ, NASA FIRMS, WAQI, N2YO.

**Architecture guardrails.** Edge/server proxy plus cache in front of every upstream API; stale-while-revalidate; circuit-breaker plus token-bucket plus backoff/jitter for 429 responses; multi-provider fallback adapters where available; must-proxy sources (for example NWS alerts) are never exposed as raw client-side calls.

**Freshness caveat.** This research was current at the time it was gathered. Reconfirm library versions (`three`, `@react-three/fiber`, KTX2 tooling), upstream API endpoint stability, and licensing wording at implementation time if material time has passed since this plan was written.

## Design

### Route

**Studio.** The novel direction, "Living Signal," was one of three directions previously presented (safe, refined, novel); the user selected the novel direction, and it is final. No disposable Studio prototype was created for this plan. Model tier: as executed during the design pass.

### Independent design review

**Result: PASS.** The independent design reviewer verdict on the revised handoff was PASS. All four prior findings were verified resolved with no regressions to the independently confirmed contrast math, focus-ring proof, signature grammar, no-dialog coverage, or gesture-mode constraints:

- DR-A11Y — the reduced-motion matrix is now fully enumerated (reproduced below).
- DR-COHERENCE — the choropleth/GIBS shared-waveform rhythm pair is now distinguished (differing cross-fade duration plus distinct static shapes).
- DR-HANDOFF — keyboard-only and gesture-parity journeys are specified.
- DR-HANDOFF — the laptop viewport tier is resolved (laptop resolutions fall inside the desktop breakpoint tier; no separate laptop breakpoint or validation pass is required).

This plan treats the design content on its merits because it passed independent review; it does not cite specialist agent identifiers as evidence of process.

### Reviewed design handoff summary (Studio — "Living Signal")

**Creative thesis.** The planet is the interface. Every UI element orbits, tethers to, or emanates from Earth. Data is rendered as broadcast signal — shape, texture, and rhythm — and the user tunes it by pointer, keyboard, touch, or hand-conducting.

**Anti-goals (recorded, not to be reintroduced by engineering).** Dashboard density; sidebar-of-widgets chrome; pin/marker clutter; hue-only category coding; a stylized/neon Earth; onboarding gates before the globe is visible; gesture-exclusive functionality; emergency-notification-style positioning of any UI element.

**Breakpoints.**

| Tier | Range | Ring behavior | Notes |
|---|---|---|---|
| Phone | <768px | Ring replaced by a horizontal filter bar plus an always-available vertical list | |
| Tablet | 768–1279px | Bottom-anchored 180° arc ring, 44px targets | |
| Desktop | 1280–1919px | Full 360° ring | Laptop resolutions fall within this tier — there is no separate laptop breakpoint or validation pass. |
| Kiosk | ≥1920px | Scaled ring, base type 18px, 56px targets, touch-primary | |

**Category signatures.** Nine ring chips map one-to-one to nine distinct shape-plus-texture emission signatures. Category identity is never carried by hue alone. One shared SVG glyph source per category is reused across the ring, the legend, detail cards, and the companion table:

1. Earthquakes — concentric double-ring pulse.
2. Wildfires — flame plume.
3. Volcanoes — cone plus plume.
4. Storms — spiral vortex.
5. Weather — compass-rose burst.
6. ISS — dashed arc plus diamond.
7. Weather Alerts (NWS) — hatched polygon.
8. Countries — stepped dot-density.
9. Science Overlays (GIBS) — bordered frame.

**Far-side card behavior.** When a selected point's leader line terminates at the globe's silhouette (the point is on the far side from the camera), the detail card collapses to a docked pill showing status text and restores automatically when the point returns into view. The companion table row stays selected throughout. No auto-dismiss occurs.

**Typography and tokens.** Space Grotesk for display, Inter for UI, IBM Plex Mono for data, on a 1.25 modular scale with tabular numerals. Colors, dimensions, typography, and opacity are expressed as DTCG 2025.10 primitive/semantic/component token sets.

**Analytic scrim contrast (independently re-derived and confirmed correct by the reviewer).**

Formula: `L_eff = alpha * L_scrim + (1 - alpha) * L_under`, evaluated at the worst case `L_under = 1`.

| Scrim | Text role | Result | Verdict |
|---|---|---|---|
| `scrim.text.standard` black @ 0.86 | text.primary | 5.15:1 | PASS (body text) |
| `scrim.text.standard` black @ 0.86 | text.secondary | 3.62:1 | Large text / UI-graphic use only |
| `scrim.text.compact` black @ 0.92 | text.primary | 7.52:1 | PASS |
| `scrim.text.compact` black @ 0.92 | text.secondary | 5.29:1 | PASS |
| Any translucent surface | text.tertiary | 1.8:1 | FORBIDDEN — restricted to opaque surfaces only |

**Re-verification rule** (must be applied to any new translucent text surface introduced during engineering): `(1 - alpha) <= (L_text + 0.05) / target - 0.05`.

**Dual-layer focus ring (independently confirmed).** Inner ring white, outer ring near-black, with a luminance crossover at `L ≈ 0.179`, giving a minimum contrast of approximately 4.58:1 against any background and at least 3:1 everywhere. Forced-colors mode: the WebGL canvas cannot be restyled by forced-colors, so the mitigation is that the DOM legend, chips, cards, and companion table always carry the meaning-bearing fact — the canvas is never the sole source of any fact.

**Motion — four-tier purpose hierarchy.** Ambient < data signal < user feedback < focal moments; a higher tier interrupts a lower one. Per-category rhythm is hard-capped at ≤3 Hz everywhere (WCAG 2.3.1):

- Earthquake: 0.15–1.5 Hz, log-magnitude driven.
- Wildfire: 0.5–2 Hz, amplitude-only.
- Volcano: ≥2.5 s period.
- Storm: rotation ≤60°/s.
- Weather: fixed-frequency, displacement-only.
- ISS: deterministic glide plus a fixed-rate blink.
- NWS: boundary "breathing" (not marching-ants).
- Choropleth: cross-fade only, 400ms.
- GIBS: cross-fade only, a distinct 800ms band — this is the one shared-waveform pair with choropleth, differentiated by duration plus distinct static shapes.

Globe camera: idle-drift ≤0.6°/s; camera-fly transitions ≤900ms; fling ≤180°/s. Gesture-driven camera motion is clamped tighter than pointer input: 90°/s rotation max, ±0.4 zoom-units/frame max; loss-of-tracking triggers freeze/resume/exit-suggestion; off-mode parity is a checkable invariant. A same-frame interruptibility rule applies throughout, and a six-step performance-degradation ladder exists that never silently drops a data-signal rhythm.

**Reduced-motion matrix (mandatory, enumerated).** Reproduced faithfully below for downstream engineering to implement against directly:

| # | Signature / element | Full-motion behavior | Reduced-motion equivalent |
|---|---|---|---|
| 1 | Earthquakes — double-ring pulse | Pulsing concentric rings | Frozen glyph at peak-expansion radius; magnitude conveyed via ring count (1–3) plus opacity; no motion. |
| 2 | Wildfires — flame plume | Flickering flame silhouette | Fixed mid-amplitude silhouette; intensity conveyed via fill opacity/size; no flicker. |
| 3 | Volcanoes — cone plus plume | Pulsing plume | Frozen at peak-plume extension; activity conveyed via plume size/opacity; no pulsing. |
| 4 | Storms — spiral vortex | Rotating spiral | Fixed angle; intensity conveyed via arm count/spiral tightness; no rotation. |
| 5 | Weather — compass-rose burst | Displacing spokes | Fully extended peak-burst; wind conveyed via spoke length/count; no displacement. |
| 6 | ISS — dashed arc plus diamond | Blinking diamond, moving track | Current track position shown; diamond rendered solid (no blink); static dash pattern. |
| 7 | Weather alerts (NWS) — hatched polygon | Breathing hatch pattern | Fixed line-weight/hatch-density at the breathing peak; severity conveyed via hatch density/opacity; no breathing. |
| 8 | Countries / choropleth (400ms) | Cross-fade on data change | Stepped dot-density instant swap; no cross-fade. |
| 9 | GIBS science overlays (800ms) | Cross-fade on data change | Bordered-frame instant swap; border weight/opacity encodes confidence/recency; no cross-fade. |
| 10 | Idle-drift | Autonomous slow rotation | Frozen at the last user-set or default framing; no autonomous drift. |
| 11 | Camera-fly (900ms) | Eased camera movement | Hard cut to destination, optionally softened by a same-budget ≤300ms opacity cross-fade; no eased movement. |
| 12 | Gesture-camera | Continuous glide from gestures | Discrete fixed-size stepped increments — one confirmed gesture equals one fixed-angle rotation step or one fixed zoom increment; instant updates; no continuous glide; no gesture-only functionality is created by this substitution. |
| 13 | Loading choreography | Progressive animated load-in | Single 300ms cross-fade to the fully-loaded composite; per-chip and per-emission data populate instantly. |

**Assets.** The planet is physically lit first; spectacle comes from the emission layer, not from a stylized or neon Earth (that treatment was explicitly rejected). Material stack: day albedo, night emissive gated by a day/night mask, a terminator smoothstep, cloud layer, bump, specular water mask, and an atmosphere Fresnel rim. The imagery pipeline is self-hosted with KTX2 tiering — no runtime hotlinking. Emission glyphs are code-native (SDF shader glyphs, procedural meshes/lines/gradients) — no external icon services. Attribution wording is a PLACEHOLDER pending license verification, surfaced through a single persistent app-owned credits surface (never a native dialog). A poster-frame fallback with descriptive alt text exists, with a graceful degradation ladder by device tier.

**Engineering invariants (12) — reproduced faithfully for downstream implementation:**

1. No native dialogs anywhere, enforced by a deterministic no-native-dialog scan gate.
2. The scrim-math re-verification rule applies to any new translucent text surface.
3. One shared SVG glyph source per category; category identity is never hue-alone.
4. The dual-layer focus ring appears on every interactive element.
5. The companion view maintains 100% parity with the canvas; the canvas is never the sole source of a fact.
6. A single shared filter-state source of truth drives the ring, the canvas emissions, and the companion table identically.
7. Motion hard caps are non-overridable.
8. Every animated signature has a mandatory static reduced-motion equivalent, per the matrix above.
9. Gesture mode is opt-in, client-side, nothing is persisted, a non-gesture Stop is always present, and no gesture-mode UI element requires `hasCamera` to be true when gesture mode is off.
10. The radial ring keyboard model plus its list fallback is structural at every breakpoint.
11. Imagery is self-hosted and tiered, with attribution wording marked license-pending until verified.
12. All PLACEHOLDER content is resolved before any launch claim is made.

**Permitted variation** (engineering has latitude here without further design review): scene-graph/shader implementation choices; tiling/LOD algorithm; codec-per-layer mapping; state-management library; named tuning values; minor visual polish; the companion-table implementation pattern; gesture-library choice, provided it is MediaPipe-class, keyless, and client-side; and whether an "Explore more APIs" catalog ships in the MVP.

### Browser validation brief

Browser UI validation is required for this plan because the deliverable is a browser-rendered UI (web, with a Tauri-capable webview target under consideration per the design's engineering invariants). See "Browser UI Validation" below for the full launch/readiness, fixture, viewport, and journey requirements. No engineering phase that produces browser UI may claim completion without a Verifier pass followed by a Browser Validator pass.

## Ordered Work (phased)

This plan is MVP-first and explicitly phased. Each phase requires a Verifier pass before being treated as complete; any phase that produces browser UI additionally requires a Browser Validator pass before being treated as complete. No phase may begin before explicit user approval of this plan.

### Phase 1 — MVP globe and first data tranche (accessible, keyboard-filterable, and independently shippable)

Phase 1 ships a photorealistic globe with the first data tranche that is fully keyboard-operable and filterable, with companion view and attribution — it is honestly independently shippable on its own, not merely a visual-only slice awaiting Phase 2 for basic operability.

- Scaffold the application on Vite + React + TypeScript (react-three-fiber + Three.js for rendering, WebGL2 as default). Rationale: Vite gives fast HMR for iterative WebGL/shader work; react-three-fiber is a React renderer, so React + TS is the native fit; TypeScript gives type safety across the token/state/data layers. This step realizes the fixed dev command `npm run dev` and base URL `http://localhost:5479`, with the proxy backend on port `3479`, established by this plan (see "Repository Findings" and "Browser UI Validation"). The edge/server proxy runs as a companion dev process alongside the Vite frontend; its exact dev wiring (a Vite dev-server proxy config, or a small companion Node service optionally started via a concurrently-style script from the same `npm run dev`) is permitted engineering variation.
- Build the self-hosted imagery acquisition pipeline (a build-time asset-preprocessing step over published static imagery, not a live satellite-capture pipeline — see "Non-goals"): source day albedo (Blue Marble NG), night lights (Black Marble/GIBS), cloud composite (GIBS/community), relief (Natural Earth), and the water/specular mask; run the one-time build-time KTX2/Basis conversion (`toktx`/gltf-transform-class tooling) starting with the 2K tier; serve the processed assets as self-hosted static assets from the app's own origin. This is a build-time pipeline task, not a runtime dependency (see "Research Evidence" → "Imagery sources").
- Complete the per-source license/attribution verification checklist before integrating each source (gating; see "Constraints" and "Risks & Rollback"): imagery (Blue Marble NG; Black Marble/GIBS night; GIBS cloud composite; Natural Earth relief; water/specular mask) and data APIs (USGS earthquakes; NASA EONET; Open-Meteo; wheretheiss.at ISS; NWS US alerts; REST Countries; World Bank; NASA GIBS science rasters). No source's assets or endpoints are integrated, and no non-PLACEHOLDER attribution copy is written, until its checklist entry is verified.
- Implement the photorealistic layered PBR sphere: day, night, cloud, bump, specular, and atmosphere material stack, with a terminator.
- Implement mouse/touch/keyboard rotate-pan(re-center)-zoom camera controls, with the canvas stage exposed as `role="application"`.
- Implement the loading choreography (single 300ms cross-fade to the fully-loaded composite per the reduced-motion matrix, item 13).
- Build the edge/server proxy-and-cache scaffold: stale-while-revalidate, circuit-breaker plus token-bucket plus backoff/jitter.
- Wire the first data tranche through the proxy at correct lat/lon: USGS earthquakes plus NASA EONET (wildfire/volcano/storm) as the initial three emission signatures.
- Establish the shared SVG glyph source and the non-color signature grammar.
- Implement a keyboard-operable filter control for the three initial emission signatures: the straight-list fallback plus the roving-tabindex keyboard interaction model, wired to the single shared filter-state source of truth established below. This gives Phase 1 a genuinely keyboard-operable way to filter the globe without waiting for the full radial ring's per-breakpoint visual geometry (Phase 2).
- Implement fixed-luminance scrims per the analytic contrast table above.
- Implement the dual-layer focus ring.
- Implement the persistent app-owned attribution surface and the app-owned modal primitive (no native dialogs anywhere in this or any later phase).
- Implement the companion data view (a semantic table with 100% parity) and establish the single shared filter-state source of truth from the start — both are foundational, not deferred to a later phase.
- Establish the performance-degradation ladder framework: device-tier detection (`deviceMemory`/`hardwareConcurrency`/GPU-tier heuristic/max texture size), the frame-time monitor, and the poster-frame floor (rung 6). Phase 1 ships only the 2K texture tier, so only the atmosphere/cloud/LOD rungs (1, 2, 5) are active until Phase 2's 4K/8K tiers land (see "Risks & Rollback" → "Performance-degradation ladder").

### Phase 2 — Filters and remaining data layers

- Add the full radial orbital ring's visual geometry per breakpoint (phone/tablet/desktop/kiosk per the breakpoints table), reusing the Phase 1 roving-tabindex keyboard model and the same shared filter-state source of truth rather than re-implementing them. The per-breakpoint geometry and visual ring presentation are the Phase 2 addition; the accessible keyboard-filtering mechanism already exists from Phase 1.
- Wire the remaining MVP roster as the remaining six emission signatures: Open-Meteo per-point weather, wheretheiss.at ISS position, NWS US alerts (via the proxy), REST Countries plus World Bank choropleth, and NASA GIBS science rasters.
- Implement tethered detail cards with frame-accurate leader lines and the far-side docked-pill behavior.
- Implement per-category motion rhythms within the documented caps.
- Implement the complete reduced-motion static matrix (all 13 rows above).
- Implement forced-colors handling per the design's mitigation (DOM chrome carries every fact; canvas hue is decorative only).
- Add the 4K and 8K KTX2 texture tiers, completing the performance-degradation ladder's texture-tier and glyph-LOD rungs (3–5) established in Phase 1 (see "Risks & Rollback" → "Performance-degradation ladder").
- Implement the no-WebGL fallback: the static poster-frame composite (with descriptive alt text) plus the companion table as the primary surface.

### Phase 3 — Gesture mode

- Implement the opt-in, entirely client-side "Conduct the Earth" webcam gesture control using a pretrained MediaPipe/TF.js-class model. Nothing is uploaded; nothing is persisted.
- Build the discoverable entry point.
- Build the app-owned consent modal (focus trap, Escape maps to "Not now" — never a native dialog).
- Implement calibration.
- Build the in-use HUD with a keyboard-reachable Stop control.
- Implement loss-of-tracking freeze/resume/exit behavior.
- Verify full mouse/keyboard/touch parity when gesture mode is off or permission is denied.
- Confirm no gesture-exclusive functionality exists anywhere in the product.
- Confirm permission-denied returns the user to baseline behavior with no nagging.

Each phase requires an independent Verifier pass before being treated as complete. Phases 1, 2, and 3 all produce browser UI and therefore each additionally require a Browser Validator pass before being treated as complete.

## Interfaces & Data

- **Proxy layer.** An edge/server proxy endpoint per upstream data source, with caching and stale-while-revalidate. Reliability wrapping: circuit-breaker, token-bucket rate limiting, and backoff-with-jitter on 429 responses. Multi-provider fallback adapters are used where more than one provider exists for a category. Must-proxy sources (for example NWS alerts) are never exposed as raw client-side calls.
- **Normalized data shape.** Upstream data is normalized to geo-positioned records: latitude/longitude, category, magnitude/severity, a freshness UTC timestamp, and source attribution.
- **State.** A single shared filter-state source of truth drives the ring, the canvas emissions, and the companion table identically — this is engineering invariant 6 and must not be implemented as three independently-synced copies.
- **Imagery.** Self-hosted, tiled KTX2 imagery assets produced by a one-time (or defined-cadence) build-time acquisition/conversion pipeline (source → KTX2/Basis tiling → static self-hosted serving from the app's own origin), not fetched at runtime. No runtime hotlinking of NASA/GIBS tile servers (see "Research Evidence" → "Imagery sources").

## Acceptance & Validation

- The fixed local launch/readiness command (`npm run dev` at `http://localhost:5479`, with the proxy backend on port `3479`, realized by Phase 1 scaffolding) is exercised (see "Browser UI Validation").
- The globe renders photorealistically, correctly oriented, and is rotatable/pannable/zoomable.
- The current phase's real geo-mapped data categories render at correct coordinates with live toggle filters.
- A data detail panel with attribution is present and functions per the far-side/pill behavior described above.
- Webcam gesture mode (Phase 3) provides full parity when off or denied.
- Zero native dialogs anywhere in the product.
- Verifier and Browser Validator journeys pass for every phase that produces browser UI.
- All seven accessibility non-negotiables (see "Constraints") are verified, not merely implemented, per the reproducible checks in "Accessibility acceptance checks" below.
- The architecture rationale is documented and reflected in the actual implementation.
- The deterministic no-native-dialog source scan is a required engineering gate, not an optional check.
- The scrim-math re-verification rule is enforced for any new translucent text surface introduced at any point during engineering.
- The device-tier performance matrix (see "Risks & Rollback" → "Performance-degradation ladder") holds on each defined tier: the app remains interactive and holds at or above its stated minimum sustained frame rate, or steps down the ladder deterministically rather than dropping frames or a data-signal rhythm; Browser Validator confirms a degraded rung on an emulated/throttled profile.
- Every integrated imagery source and data-API source has cleared its per-source license/attribution verification checklist entry (see "Constraints" and "Ordered Work" Phase 1); no PLACEHOLDER attribution copy remains at launch.

### Accessibility acceptance checks

Reproducible, testable acceptance checks keyed to the seven accessibility non-negotiables in "Constraints":

1. **Radial keyboard operation (roving tabindex + list fallback).** Verified by Browser Validation journey 13 (full keyboard-only operation, no mouse/touch) and journey 3 (ring toggling). The dual-layer focus ring must additionally be verified visible against sampled real globe backgrounds — bright ice, dark ocean, the terminator band, the night side, and cloud tops — with measured contrast ≥3:1 everywhere (≈4.58:1 minimum) on the sampled pixels, not only the analytic crossover proof.
2. **Static equivalents for every animated signature.** Verified by the reduced-motion pass against all 13 matrix rows (Browser Validation journey 8).
3. **Vestibular-safe motion caps.** Verified by an automated/measured check confirming no per-category rhythm exceeds 3 Hz and that camera/gesture motion stays within the documented caps (idle-drift ≤0.6°/s, camera-fly ≤900ms, fling ≤180°/s, gesture rotation ≤90°/s, gesture zoom ≤±0.4 units/frame).
4. **Companion-view 100% parity.** Verified by an explicit parity matrix/checklist filled in and checked category-by-category before ship: every category (all 9), every field (latitude/longitude, category, magnitude/severity, freshness UTC timestamp, source attribution), and every action (filter toggle, point select, detail view, and the gesture-equivalent action) available via the radial/tethered UI must have a companion-table equivalent.
5. **Fixed-luminance scrims meeting WCAG 2.2 AA.** Verified against real rendered screens, not only the analytic calculation: capture rendered screenshots over worst-case bright backgrounds (`L_under ≈ 1` — bright cloud, ice, desert, specular-highlight regions), sample the actual text-region pixels, and compute the measured contrast ratio with an automated tool (a screenshot pixel-sampling script or an axe/Playwright-based contrast check); measured ratios must meet or exceed the analytic targets in the scrim contrast table.
6. **Discoverable attribution/credits surface.** Verified by Browser Validation journey 7 (attribution reachability).
7. **No native browser dialogs.** Verified by a deterministic grep/lint rule matching `alert(`, `confirm(`, `prompt(`, `window.alert`, `window.confirm`, `window.prompt`, and `beforeunload` across all source, run as a required pre-merge/CI gate (the same mechanism named in "Browser UI Dialog Policy"), not a narrative promise alone.

## Browser UI Dialog Policy

**Required.** No native `alert`, `confirm`, `prompt`, `window.*` forms of these, or `beforeunload` prompts anywhere in the product, including:

- The webcam-permission flow. Note: the browser's own native permission chrome (the OS/browser camera-permission prompt) is unavoidable and acceptable — this exclusion covers only that one browser-owned surface. No app-triggered JS dialog may wrap, precede, or follow it.
- API-failure states — these render as inline, app-owned states, never as a dialog.
- Gesture-mode toggling, including the consent flow, calibration, in-use HUD, and exit.

App-owned accessible modals and inline states are the only acceptable substitute. This policy is enforced by a deterministic no-native-dialog source scan gate, which is a required part of "Acceptance & Validation" above and must run in every phase.

## Browser UI Validation

**Required** for every phase that produces browser UI (Phases 1, 2, and 3).

**Launch/readiness.** Dev command: `npm run dev`. Base URL: `http://localhost:5479`. Proxy backend: `http://localhost:3479`. Both ports are fixed by this plan and realized by the Phase 1 scaffolding step (Vite + React + TypeScript; see "Repository Findings" and "Ordered Work" Phase 1). The readiness signal is unchanged: the globe canvas has rendered, and at least one ring/filter chip is out of its loading state.

**Fixture/reset.** Seeded or mocked API fixtures are required for deterministic runs, plus a reset procedure back to the default camera framing and default filter state.

**Viewport/device profiles.** Phone, tablet, desktop (this tier covers laptop resolutions — no separate laptop pass is required), and kiosk, plus a 400% zoom pass, a reduced-motion emulation pass, a forced-colors emulation pass, and a low-tier throttled CPU/GPU emulation pass exercising the performance-degradation ladder (see "Risks & Rollback" → "Performance-degradation ladder"). Mobile/touch interaction must be explicitly considered, not assumed to follow from desktop behavior.

**Journeys (14, each with a concrete visible outcome):**

1. Load/progressive-load.
2. Orbit/zoom parity across mouse, touch, and keyboard.
3. Ring toggling with a known-fixture geo-position check.
4. Point selection, including far-side behavior, with an attributed detail card.
5. Companion-view screen-reader parity pass.
6. Full gesture-mode journey: consent, calibrate, use, exit.
7. Attribution reachability.
8. Reduced-motion pass against the static matrix (all 13 rows).
9. Forced-colors pass.
10. Deterministic zero-native-dialog source scan.
11. Degraded/offline/WebGL-disabled states, including an emulated/throttled low-tier profile confirming the app steps down the performance-degradation ladder deterministically (see "Risks & Rollback" → "Performance-degradation ladder") rather than dropping frames or a data-signal rhythm, down to the poster-frame floor when WebGL is disabled.
12. 400% zoom single-column reflow.
13. Keyboard-only full operation: rotate/pan/zoom plus toggling at least two filters via roving tabindex, plus selecting a point — no mouse or touch input at any point in the journey. The dual-layer focus ring must be continuously visible, resulting states must match an equivalent mouse-driven journey, and focus must never be lost, hidden behind the canvas, or trapped.
14. Gesture-mode disable/parity restoration: opt in, perform a gesture, exit via the non-gesture Stop control, then confirm full mouse/keyboard/touch interaction identical to the pre-gesture baseline — no residual gesture-only affordance, no degraded control, and no leftover HUD element.

## Risks & Rollback

- **Upstream API rate limits, 429s, or outages.** Mitigation: the proxy-plus-cache layer, stale-while-revalidate, circuit-breaker plus token-bucket plus backoff/jitter, and multi-provider fallback adapters. Per-feed degraded/offline states are inline and non-modal; a failing feed never blocks the globe.
- **8K-class texture performance or WebGL unavailability.** Mitigation: KTX2 2K/4K/8K tiers and the defined six-rung performance-degradation ladder (see "Performance-degradation ladder" below), which never silently drops a data-signal rhythm. When WebGL is unavailable entirely, the mitigation is the static poster-frame composite plus the companion view as the primary surface (rung 6 of the ladder) — `globe.gl` also depends on WebGL and is not a no-WebGL fallback (see "Research Evidence" → "Rendering stack").
- **Imagery/data licensing.** Imagery and data sources are believed to be public-domain / open, but this is not yet verified fact: each imagery source and each keyless data-API source requires a per-source license and attribution verification, gated as a Phase 1 checklist task before that source's assets or endpoints are integrated (see "Constraints" and "Ordered Work" Phase 1). All attribution copy is PLACEHOLDER until its source clears verification; the app must not ship with PLACEHOLDER attribution copy, and no launch claim may be made until every integrated source has resolved. Self-hosted tiles avoid hotlinking terms of service.
- **Accessibility regressions.** Mitigation: non-overridable motion hard caps, the enumerated reduced-motion static matrix, the companion-view 100% parity invariant (the canvas is never the sole source of a fact), the scrim-math re-verification gate, the dual-layer focus ring on every control, and the roving-tabindex ring plus structural list fallback at every breakpoint. See "Accessibility acceptance checks" under "Acceptance & Validation" for the reproducible pass criteria.
- **Webcam privacy/trust.** Mitigation: opt-in only, entirely client-side processing, nothing uploaded, nothing persisted, an always-present non-gesture Stop, full parity when off or denied, and no nagging on denial.
- **Rollback/containment.** Phased delivery means each phase is independently shippable and revertible. Gesture mode is feature-flagged. A broken feed, texture tier, or gesture stack degrades gracefully rather than failing the exhibit as a whole.

### Performance-degradation ladder

Device-tier detection at startup assigns a starting rung using `navigator.deviceMemory`, `navigator.hardwareConcurrency`, a WebGL renderer/GPU-tier heuristic (a detect-gpu-class check), and max texture size, producing a low/mid/high tier. At runtime a frame-time monitor tracks a rolling median frame time; sustained frame time above the active tier's budget steps the ladder DOWN, and sustained headroom steps it back UP, with hysteresis to prevent oscillation. The degradation order follows the design asset spec's stated priority — atmosphere and cloud layers degrade before texture tiers:

1. Disable the atmosphere Fresnel rim.
2. Freeze, then disable, the animated cloud layer.
3. Drop the day/night texture tier 8K → 4K.
4. Drop the texture tier 4K → 2K and disable the specular water mask / reduce bump-map resolution.
5. Reduce emission-glyph LOD and cap concurrent animated points (apply the animated-LOD threshold, ~500 points, a placeholder pending profiling); lower devicePixelRatio and disable MSAA.
6. Fall back to the static poster-frame composite with the companion table as the primary surface (this rung is shared with the no-WebGL floor described above under "8K-class texture performance or WebGL unavailability").

**Invariant.** No rung silently drops a data-signal rhythm: reduced-motion substitutions follow the enumerated 13-row matrix, and any cap on concurrent animated points is disclosed through the companion view, which always retains 100% parity. Rendering richness degrades; the set of data categories/points and their identity never silently degrades.

**Device-tier matrix** (directional fps budgets pending profiling; the mechanism, order, and matrix structure are fixed):

| Tier | Detection signal | Target | Floor behavior |
|---|---|---|---|
| High | Discrete GPU / `deviceMemory` ≥8 | ≥60fps at full quality | 50fps hard floor before stepping down |
| Mid | Integrated GPU / `deviceMemory` 4–8 | ≥30fps | Degrades down the ladder as needed to hold 30fps |
| Low | `deviceMemory` ≤4 / mobile | 30fps floor | May start on a lower rung; falls to the poster-frame floor (rung 6) if it cannot hold 30fps |

Acceptance: on each defined tier the app remains interactive (responsive input, no input starvation) and holds at or above its stated minimum sustained frame rate; when it cannot, it steps down the ladder deterministically rather than dropping frames or a data-signal rhythm. Browser Validator confirms a degraded rung on an emulated/throttled profile (see "Browser UI Validation" journey 11).

**Phasing.** Phase 1 establishes the ladder framework — device-tier detection, the frame-time monitor, and the poster-frame floor. Phase 1 ships only the 2K texture tier, so only the atmosphere/cloud/LOD rungs (1, 2, 5) are active there. Phase 2 completes the full ladder — rungs 3–5, the 4K/8K texture-tier drops and glyph-LOD — once those tiers land.

## Assumptions & Open Decisions

**Assumptions (recorded as assumptions, not settled facts):**

- The build is greenfield and the stack is research-grounded and fixed (see "Research Evidence").
- Desktop "pan" is implemented as re-center, not literal pan, pending confirmation at implementation time.
- The concurrent-card display cap, the roughly 500-point animated-LOD threshold, and the per-tier fps budgets in the performance-degradation ladder are placeholders pending performance profiling.
- The gesture stack is assumed to be MediaPipe-Hands-class.
- Webfont self-hosting and licensing is an engineering decision, not yet made.
- 44px/56px touch targets deliberately exceed the WCAG 2.5.8 minimum.
- Session-only state restore is assumed (no cross-reload persistence unless decided otherwise, see below).
- The 400ms/800ms choropleth-vs-GIBS cross-fade split is a directional tuning value, not a fixed constant.

**Open decisions** (these do not block engineering planning; several must resolve before any launch claim is made):

- NWS severe-alert escalation policy.
- Whether an optional in-app reduced-motion override toggle ships.
- Whether filter/camera state persists across reloads.
- The exact cycle-next/previous-data-point keybinding, pending an AT/OS collision audit.
- Whether an "Explore more APIs" catalog ships in the MVP.
- The concurrent GIBS overlay hard cap.
- Whether an ISS ground-track freshness indicator ships.
- Final license-verified attribution and consent-modal legal copy — this must resolve before launch.
- The cloud-composite refresh cadence: a static build-time-baked composite (MVP default) versus an optional scheduled build-time re-fetch/re-tile cadence for freshness (see "Research Evidence" → "Imagery sources").

## Engineering Mode & Downstream Owner

**Engineering mode:** standard (auto → phased/MVP-first). This is explicitly **not** an extreme-advisory-team route; `team_authorization` is not applicable.

**Downstream owner:** `engineering-fleet`, routed through the standard T1/T2/T3/Engineering Lead chain per `docs/BUILD-CONTRACT.md` and `docs/PLAN-CONTRACT.md`, using this plan's exact path as `approved_plan` once approval is given.

## Required Approval

**USER APPROVAL of this plan is required before any downstream execution.** This plan grants no authority and no commit authority on its own. Approval must be explicit and given by the user; no teammate, agent, or automated process may substitute for it. Approval of this plan does not itself authorize any commit, push, deployment, or pull request — those require separate, later, explicit user approval.

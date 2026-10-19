# Plan: world-data-earth-visual-fidelity — Real Day-Side Imagery and Visible Progressive LOD

## Status

**APPROVED. Explicit user approval received on 2026-07-19.**

Engineering may now begin under this plan.

This plan recommends work. It does not grant execution authority. No engineering writer (T1/T2/T3/Engineering Lead) may start work against this plan until the user gives explicit approval (see "Required Approval" below). Approval of this plan, if and when given, will not itself authorize any commit, push, deployment, or pull request; those remain separate, later, explicit user approvals.

This plan **extends Phase 2** of the approved plan `docs/plans/world-data-photorealistic-globe.md`. It does not restart, redesign, or re-litigate any part of that plan or the "Living Signal" app already built and verified under it. Where this document repeats material from the sibling plan (breakpoints, motion hierarchy, the 13-row reduced-motion matrix, engineering invariants), it does so only to state what is being extended, not to reopen it.

```text
task_id: world-data-earth-visual-fidelity
plan_id: world-data-earth-visual-fidelity
route: engineering
target: H:\CommandCenter\orchestrator\world-data
engineering_mode: standard (phased/MVP-first; NOT extreme-advisory-team)
```

## Outcome & Audience

Close the two most-visible remaining fidelity gaps in the "Living Signal" globe so it meets the project's original, first-stated requirement: a globe that is "completely photorealistic looking like we're observing actual earth from space, using the highest resolution images of earth available, prefer at least NASA 8K."

Two closely related gaps are in scope:

1. **Real day-side imagery.** Replace the current flat procedural blue-ocean/pale-pole gradient on the day hemisphere with real, photorealistic NASA day-albedo satellite imagery, integrated into the existing day/night/terminator shader stack.
2. **Visible progressive LOD.** Deliver a genuinely visible, working multi-tier level-of-detail experience: a fast low-resolution first paint that visibly sharpens to higher tiers within a few seconds and/or by device capability, using the real KTX2/Basis GPU-compressed tiles that already exist on disk today but that the runtime never loads.

Audience: the same walk-up exhibit/kiosk and web visitors the approved plan targets, including screen-reader/keyboard-only/motion-sensitive users, plus the project owner who filed this explicit fidelity feedback.

## Scope

**In scope:**

- Genuinely sourcing, license-verifying, and self-hosting real day-side Earth imagery at the highest reasonable resolution, integrated into the existing day/night/terminator shader stack.
- Wiring real KTX2/Basis-Universal GPU texture loading into the runtime, with a robust `.jpg` fallback.
- Implementing a visibly progressive LOD experience (load-low-first, then background-load and crossfade to higher tiers), respecting the app's existing reduced-motion matrix.
- Extending the licensing-verification gate, attribution surface, `MANIFEST.json`/`ATTRIBUTION_CHECKLIST.md`, and the unit/browser test suite accordingly.

**Non-goals:**

- Do **not** restart or redesign the app.
- Do **not** re-litigate or modify anything already built and verified under the approved plan: data wiring, ring geometry, tethered cards, motion caps, forced-colors handling, marker click/selection, camera-fly, drag stability, EONET/USGS/etc. data feeds, or the existing night-lights KTX2 build pipeline.
- Do **not** touch Phase 3 (gesture mode) — a separate, concurrent dispatch is implementing it. This plan must not create file-level conflicts with that work (see "Risks & Rollback" → "Phase 3 coordination").
- Do **not** lower the bar to "just brighten the procedural gradient." Real imagery is required if achievable, and research (below) confirms it is achievable. An honestly-labeled enhanced-procedural fallback is permitted **only** as a documented, reasoned contingency if real imagery genuinely proves unreachable at implementation time — never as a silent substitute for it.

## Constraints

- **Browser UI invariant** (unchanged from the approved plan): no native dialogs anywhere. See "Browser UI Dialog Policy" below.
- **No runtime hotlinking.** All imagery remains self-hosted and downloaded/tiled at build time, exactly as the approved plan requires. No new runtime dependency on a NASA/GIBS/Natural Earth host is introduced.
- **Licensing verification gate** (unchanged, extended). No imagery asset may be integrated until its license/terms-of-use and attribution line are verified per the existing `ATTRIBUTION_CHECKLIST.md` process. The app must not ship with PLACEHOLDER attribution copy for any newly integrated source.
- **Motion hierarchy** (unchanged, extended by one row). The progressive-LOD crossfade is a quality-enhancement transition at or below the AMBIENT tier of the existing four-tier motion hierarchy (ambient < data signal < user feedback < focal moments) — it must never compete with or interrupt a data-signal rhythm, user-feedback event, or focal moment.
- **Stack** (unchanged). Three.js `^0.168.0`, `@react-three/fiber ^8.17.0`, Vite 5, React 18. No new heavyweight dependency is required for KTX2 loading — `KTX2Loader` ships inside the already-installed `three` package.
- **Phase 3 non-interference.** This plan is confined to the Earth material/texture-loading regions of the codebase; it must not edit the same functions Phase 3's concurrent gesture-mode work touches. See "Risks & Rollback" → "Phase 3 coordination."

## Repository Findings

Verified by direct inspection of the current `world-data` tree, 2026-07-19:

- The day side is a procedural gradient computed in the GLSL fragment shader: `proceduralDay(uv)` in `src/components/Globe.tsx` (approximately lines 96–101), mixed against the real Black Marble night texture via `mix(night * 4.0 + vec3(0.03), day + vec3(spec), dayMix)` (approximately line 131). No real day imagery is integrated today. The night side's `×4` brightness factor is a documented, night-specific correction for a too-dark source texture and must **not** be applied to the day sampler.
- Real KTX2 tiles already exist on disk but are **unused by the runtime**. `scripts/build-imagery.js` produces `public/imagery/earth-night-{2k,4k,8k}.ktx2` via `@gpu-tex-enc/basis` (UASTC encoding), but `Globe.tsx` loads `earth-night-{tier}.jpg` through `THREE.TextureLoader` instead (`useImageryTexture`, approximately lines 414–457; `nightTextureUrlForTier`, approximately line 399). `KTX2Loader` is referenced only in code comments — it is never imported or wired. There is no `@react-three/drei` dependency in the project.
- There is **no visible progressive-LOD experience today**. `getTextureTier()` in `src/hooks/usePerformance.tsx` (`computeTextureTier`, approximately lines 46–50; consumed at line 172) maps the current rung of the performance-degradation ladder to a single texture tier and loads it once; the ladder only steps **down** under sustained frame-time pressure. On a mid/high-tier device the initial rung selects the 8K tier directly — a single large load with no deliberate low-first fast paint, and no deliberate load-low-then-upgrade-and-crossfade progression. This is the direct cause of the reported "no LOD, no gradually-better textures" experience.
- The runtime already has the safety patterns this work depends on: real-`onLoad`-gated texture binding (documented in `Globe.tsx` to prevent an uninitialized-VRAM "garbage/static" race), GPU texture/material disposal on swap, a reduced-motion hook (`src/hooks/useReducedMotion.tsx`, `useReducedMotionContext`) already consumed by `Globe.tsx`, and pure crossfade-timing primitives in `src/motionConfig.ts` (`computeCrossFadeOpacity`, `CROSS_FADE_CONFIG`).
- Licensing records are hand-maintained and are **not** build output: `public/imagery/MANIFEST.json` and `public/imagery/ATTRIBUTION_CHECKLIST.md`. Day albedo, cloud, relief, and specular are currently recorded `"not integrated"`; night lights is `"verified and integrated"`. `AttributionSurface.tsx` carries a PLACEHOLDER day-albedo entry, ready to be resolved once a real source clears the checklist.
- The current `ATTRIBUTION_CHECKLIST.md` and `scripts/build-imagery.js` comments record that the previously attempted Blue Marble NG URL pattern (`assets.science.nasa.gov/.../world.topo.bathy.2004{MM}.3x21600x10800.jpg`) returned HTTP 404, and that `visibleearth.nasa.gov` resolves to an HTML listing page rather than a direct image. Fresh research for this plan (below), performed via a web-fetch tool on 2026-07-19, strongly indicates this prior conclusion was a **wrong URL path** rather than an unavailable asset — real, working day-albedo source candidates were located at different paths. See "Research Evidence" for exactly what that research did and did not capture, and why the conclusion is treated as contingent on build-time re-verification rather than settled.
- Phase 3 gesture-mode code does not yet exist in `src/` (no gesture/consent/webcam/MediaPipe/`hasCamera` implementation), confirming that the material/texture pipeline this plan changes is presently distinct from the files Phase 3 will add.

## Research Evidence

Research for this plan was performed on 2026-07-19 using a real HTTP GET issued through a web-fetch research tool (not `curl` or a raw HTTP client) against each candidate source URL. That tool observed real JPEG/JFIF image bytes, image dimensions, and byte sizes at the retrieved URLs — 2.4MB for the 5400×2700 BMNG variant, and the 21600×10800 full-resolution file exceeded the fetch tool's 10MB response cap, which is itself corroborating evidence of a real, large file rather than a stub or an error page. That tool did **not** capture raw HTTP status codes, response content-type headers, or a content hash for any request. This is real, corroborating evidence, not an unverified guess, but it is not a complete, durable provenance record on its own.

This research supersedes the "no working day-albedo source exists" conclusion recorded in the current codebase comments and checklist — that conclusion was correct about the specific URL pattern previously tried, but the underlying asset is available at a different path. That "wrong-URL-path, not an access/licensing problem" conclusion is **strongly evidenced** by the above, but it is treated as **contingent, not unconditionally settled**: it must be reconfirmed by the build-time re-verification required below (HTTP status code, content-type header, byte size, decoded-image sanity check, and a content hash — all captured directly by the build pipeline's own `https.get`, which has no response-size cap unlike the research tool used here) before any source is treated as integrated.

**Day albedo — primary, recommended source.** NASA Blue Marble: Next Generation with Topography and Bathymetry (`world.topo.bathy`) — photographic, cloud-free, equirectangular imagery. A working direct-download URL returning real image bytes was observed via the web-fetch research tool on 2026-07-19 (see the evidence-scope caveat above):

```
https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73909/world.topo.bathy.200412.3x21600x10800.jpg
```

This is 21600×10800 pixels — the correct raw source to derive an 8K output tier from, and the same general resolution class as the existing 13500×6750 Black Marble raw source already used for night lights. A 5400×2700 variant at the same path family, and an `assets.science.nasa.gov` mirror on the same host family as the already-integrated Black Marble asset, were also observed via the same tool, serving real JPEG bytes. The previously guessed pattern (`world.topo.bathy.2004{MM}.3x21600x10800.jpg` under an `imagerecords/...` path on `assets.science.nasa.gov`) was simply the wrong path; the candidate current paths are the `eoimages` `imagerecords/73000/73909/` path above and the `assets.science.nasa.gov` `.../bmng/bmng-topography-bathymetry/{monthname}/...` path family — both subject to the same build-time re-verification requirement before either is treated as integrated.

**Day albedo — alternate / build-assembly source.** NASA GIBS WMS `GetMap` returns a single equirectangular global JPEG at any requested width/height in one request, with no tile stitching required:

```
https://gibs.earthdata.nasa.gov/wms/epsg4326/best/wms.cgi?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=BlueMarble_ShadedRelief_Bathymetry&CRS=EPSG:4326&BBOX=-90,-180,90,180&WIDTH=2048&HEIGHT=1024&FORMAT=image/jpeg
```

This was observed via the same tool to return a real JPEG, subject to the same evidence-scope caveat. Note that this specific GIBS layer is **cartographic** (shaded relief plus bathymetry), a stylized rather than photographic rendering — prefer the photographic `world.topo.bathy` BMNG source for the photorealism this plan targets. The separate `VIIRS_SNPP_CorrectedReflectance_TrueColor` GIBS layer is photographic but time-dependent and contains clouds and terminator gaps, making it a worse fit for a clean, static day-albedo base map. Engineering must verify GIBS WMS's maximum per-request output dimension at build time; if an 8192-wide request is capped, use the direct BMNG 21600×10800 file instead (no tile assembly needed).

**Day albedo — public-domain cartographic fallback.** Natural Earth II raster, observed via the same tool at `https://naciscdn.org/naturalearth/10m/raster/NE2_HR_LC_SR_W_DR.zip` (public domain). This is a fallback option only, not the primary recommendation.

**Relief/bump — optional this cycle.** Natural Earth Shaded Relief grayscale, observed via the same tool at `https://naciscdn.org/naturalearth/10m/raster/SR_HR.zip` (public domain). If integrated, this must be encoded as a non-color (linear / `NoColorSpace`) data texture, not sRGB — it carries elevation/shading data, not photographic color.

**Clouds — remains unsolved; leave disabled.** The prior "rainbow noise" result from `MODIS_Terra_Cloud_Fraction_Day` was confirmed (by this and prior investigation) to be a scientific index/palette layer working exactly as designed, not a corrupted file — GIBS does not publish a ready-made photographic cloud-only global RGB layer under that identifier. The BMNG `world.topo.bathy` day-albedo source is itself cloud-free, so integrating it requires no cloud-removal step. The cloud layer stays disabled, as it is today, pending a real photographic cloud RGB source being found in a future cycle. This plan does not attempt to solve the cloud layer.

**Licensing (cited document references).** NASA media-usage guidelines at `https://www.nasa.gov/nasa-brand-center/images-and-media/` state verbatim that NASA content used as texture maps "generally are not subject to copyright in the United States" and that "NASA should be acknowledged as the source." Natural Earth terms of use at `https://www.naturalearthdata.com/about/terms-of-use/` state verbatim that "All versions of Natural Earth raster + vector map data ... are in the public domain," with credit optional. These are the authoritative source documents; Phase 2A's checklist entries must cite each by URL and quoted wording alongside the concrete download-provenance evidence required below, not merely restate the conclusion narratively.

**KTX2 wiring, grounded in the installed `three@0.168` source.**

- `KTX2Loader` ships inside `three` itself — import `three/addons/loaders/KTX2Loader.js` (equivalently `three/examples/jsm/loaders/KTX2Loader.js`). No new heavyweight dependency is required.
- The Basis transcoder assets (`basis_transcoder.js` plus its `.wasm` file) ship at `node_modules/three/examples/jsm/libs/basis/`. Self-host them by copying that folder into Vite's `public/basis/` and calling `.setTranscoderPath('/basis/')` — a directory URL. A Vite `?url` import will not work here because transcoder initialization appends fixed filenames to the configured path.
- `.detectSupport(renderer)` is mandatory and throws if not called first. Obtain the live `WebGLRenderer` via `useThree(state => state.gl)` and call `detectSupport` before the first texture load.
- `three` auto-derives a loaded KTX2 texture's color space from the container's transfer-function metadata. Because it is currently unknown whether the existing UASTC-encoded night-lights tiles carry the sRGB flag, force `THREE.SRGBColorSpace` explicitly (via the existing `configureEquirectangularTexture` helper) for color maps in the loader's `onLoad` callback, and `NoColorSpace`/linear for any bump or relief data map.
- Use one shared `KTX2Loader` instance across the app; dispose textures on swap and call `loader.dispose()` on unmount.
- Graceful fallback is required: on any KTX2 initialization failure, `detectSupport` failure, `onError`, or unsupported-transcode-target result, fall back to the existing `.jpg` `TextureLoader` path. The `.jpg` tier for every KTX2 tile already sits beside it on disk, so this fallback needs no new asset.

**Progressive-LOD pattern.** Load the smallest/fastest tier first for a fast time-to-interactive, then background-load higher tiers and crossfade them in. In a custom `ShaderMaterial`, the robust implementation is two samplers (outgoing, incoming) plus an animated `mix` uniform driven by `computeCrossFadeOpacity`; both tiers are held alive for the fade window, and the superseded tier is disposed only **after** the fade completes (bounded to at most one extra in-flight tier). The incoming sampler must only ever be assigned inside its own `onLoad` callback, and the existing `MeshPhong` loading-fallback gate must stay in place before the `ShaderMaterial` exists — this preserves the already-documented no-black-canvas/no-garbage-texture safety pattern. KTX2-encoded mipmaps are preferred, since runtime `generateMipmaps` is unsupported for compressed texture formats; anisotropy should be `min(desired, renderer.capabilities.getMaxAnisotropy())`; `wrapS` stays `RepeatWrapping` (the existing seam fix must be preserved). Under `prefers-reduced-motion`, the crossfade degrades to an instant swap with no reload — the reduced-motion hook already exists and is already consumed by `Globe.tsx`.

**Validation measures identified by research** (folded into "Acceptance & Validation" below): at build time, re-fetch every source URL and assert HTTP 200, an `image/*` content type, a non-trivial byte length, a decoded-image sanity check (mean and variance of pixel values, to reject a flat gradient or an index-palette "rainbow" result — the exact check that would have caught both the earlier wrong day-albedo path and the cloud-layer noise), and a SHA-256 content hash of the downloaded raw asset as a reproducible fingerprint. For KTX2: assert `detectSupport` runs before the first load, assert `onLoad`-gated binding, assert the `.jpg` fallback triggers on a forced KTX2 error, and assert a color map's `colorSpace === THREE.SRGBColorSpace`. For LOD: a Browser Validator screenshot-based check against the pinned numeric bounds and ROI thresholds in "Acceptance & Validation," a load-timeline ordering assertion, and a reduced-motion instant-swap assertion.

**Freshness caveat.** This research's HTTP-GET observations were made at plan-writing time (2026-07-19) via the web-fetch tool described above, with the capture limits noted there (no raw status code, content-type header, or content hash captured). The durable, complete confirmation is the build-time re-verification required in "Ordered Work" Phase 2A step 1, which must run regardless of how much time has passed since this plan was written. Re-confirm source URL availability, GIBS WMS request-dimension limits, and `three`/KTX2 tooling versions at implementation time if material time has passed.

## Design

### Route

**Compact** (`existing_system_mode: extend`). This work preserves the approved Studio "Living Signal" direction; it introduces no new screens, flows, information architecture, or design tokens, and no new creative direction. Design generalist plus an independent design reviewer; a disposable prototype is explicitly forbidden for this route. Model tier: Sonnet.

### Independent design review

**Result: PASS.** The independent design reviewer's verdict on `DESIGN_HANDOFF` revision 2 ("day-albedo realism + progressive-LOD crossfade") was PASS. Findings 5 (material-lifecycle/crossfade correction), 4 (browser-validation determinism), and 2 (reduced-motion matrix cross-reference count) were confirmed resolved in revision 2. Findings 1 (scrim analytic bound), 3 (focus-ring re-verification against new backgrounds), and 6 (anti-goal and attribution preservation) were confirmed sound without requiring further changes.

### Reviewed design handoff summary (compact — extend)

**Decision A — day-albedo integration.**

- Replace `proceduralDay(uv)` in the fragment shader mix with the sampled real day texture.
- Do **not** apply the night `×4` brightness hack to the day sampler — sample close to as-authored, since the BMNG source is already gamma-correct.
- Preserve the existing smoothstep terminator anchored to the fixed `SUN_DIRECTION`; a modest widening of the smoothstep band is permitted, but a hard day/night cutoff is not.
- The day-side specular sheen is architecturally unchanged (its magnitude may be tuned down, but its mechanism is not redesigned).
- No glyph or emission-layer redesign is authorized by this plan.
- The real day surface must read as observing the real Earth and must not visually overpower the emission-signature layer. A physically-lit Earth is the goal; a stylized or neon-lit Earth remains an explicit anti-goal, unchanged from the approved plan.

**Decision B — progressive-LOD crossfade motion.**

- This is a quality-enhancement transition at or below the AMBIENT tier of the four-tier motion hierarchy. It must never compete with or interrupt a data-signal rhythm, a user-feedback event, or a focal moment.
- It is a single, monotonic, one-shot ease of approximately 400–500ms, within the existing 300–800ms crossfade family already used elsewhere in the app. It must never be a flash, pulse, bounce, or blink.
- **Intended default mechanism:** a true dual-sampler in-shader crossfade — two samplers plus an animated `mix` uniform driven by `computeCrossFadeOpacity`. A two-mesh overlay is an equally acceptable alternative implementation, but the outcome is mandatory either way: the outgoing and incoming textures must be held and rendered **simultaneously** for the fade window.
- **Explicit architectural correction required.** `Globe.tsx`'s current material lifecycle (the `earthMaterial` `useMemo` keyed on `[nightTexture]`, plus an immediate dispose-on-swap effect, approximately lines 560–612) disposes the outgoing material and its texture instantly. Left as-is, this would produce an instant "pop" even if the crossfade math itself were correctly wired. The superseded tier's texture must be disposed only **after** the fade completes, with VRAM bounded to at most one extra in-flight tier.
- Instant swap (no crossfade) is reserved for two cases only: the reduced-motion equivalent (new matrix row 14, below), and as an explicitly-secondary, disclosed fallback if the crossfade proves genuinely infeasible during implementation. If that secondary fallback is taken, the LOD-progression acceptance check below relaxes to accept a discrete tier change instead of a continuous sharpen, and the fallback must be disclosed in the implementation's evidence, never shipped silently.
- A rapid succession of tier swaps must continue from the current mix state, never reset to 0 — mirroring the existing camera-fly stability precedent already in the codebase.
- This behavior applies symmetrically to both the day and the night textures.

**Decision C — accessibility re-verification against real day backgrounds.**

- Extend the existing focus-ring/scrim pixel-sampling set with four new backgrounds: bright desert, an ice/snow sheet, a sharp coastline high-contrast edge, and the terminator band over land.
- The existing dual-layer focus-ring math (luminance crossover at `L ≈ 0.179`, minimum contrast ≥3:1 everywhere, approximately 4.58:1 at the crossover) is unchanged and background-agnostic — only the measured-screenshot pass needs to be re-sampled against the new content, not re-derived.
- The existing analytic scrim bound (evaluated at the worst case `L_under = 1`) holds for real photographic pixels and needs no re-derivation — there is no HDR/bloom/tone-mapping stage in this app that could exceed that worst case. The existing measured-screenshot scrim pass must still be re-run against the new day backgrounds. If any real single-frame specular highlight is found to exceed the analytic worst case, the existing re-verification formula must be reapplied at that pixel's actual `L_under`.

**Decision D — attribution.**

- Resolve `AttributionSurface.tsx`'s existing Day Albedo list entry from PLACEHOLDER to real text once the BMNG licensing checklist entry is verified, following the pattern: "Day Albedo: NASA Blue Marble Next Generation, world.topo.bathy (Public Domain, NASA Earth Observatory)."
- If Natural Earth relief ships in this cycle: "Relief/Bump: Natural Earth (Public Domain)."
- Reuse the existing `<ul>` structure in `AttributionSurface.tsx`. No non-PLACEHOLDER attribution copy may be written before the corresponding checklist entry is verified (this is engineering invariant 12 from the approved plan, unchanged).

### New engineering invariant (extends the approved plan's 12 engineering invariants to 13)

13. **`useFrame` callback signature correctness.** Any new or modified `useFrame` callback introduced by this work must use the correct react-three-fiber callback signature `(state, delta) => ...`, reading `delta` as the second positional argument — never off the `state` object. This is grounded in a real, already-documented prior regression in this exact codebase (`Globe.tsx`, approximately lines 1138–1160, confirmed by direct inspection): reading `delta` from `state` returned `undefined`, which propagated to `NaN` in a rotation accumulator and silently corrupted every transform under the affected group — with no thrown error and no lost WebGL context, producing a black/empty framebuffer. This was confirmed with a real-headless-Chromium repro, not jsdom. No transform-mutating code in the new crossfade path may run without a NaN/finite guard. The tier-crossfade drives a scalar `mix` uniform (0 to 1) rather than a transform; that mix factor must likewise be clamped and finite-guarded so a bad `delta` value or a bad duration configuration can never produce NaN in the shader.

### New reduced-motion matrix row (extends the approved plan's 13-row matrix to 14 rows)

The approved plan's 13-row reduced-motion matrix (`docs/plans/world-data-photorealistic-globe.md`, "Design" → "Reduced-motion matrix") is unchanged by this plan. This plan adds one new row:

| # | Signature / element | Full-motion behavior | Reduced-motion equivalent |
|---|---|---|---|
| 14 | Progressive texture-tier upgrade (2K → 4K → 8K) | One-shot ease crossfade (approximately 400–500ms) | Instant tier swap, no crossfade, no flash, no reload |

Every cross-reference in this plan to the reduced-motion matrix refers to **all 14 rows** (rows 1–13 reproduced unchanged from the approved plan, plus row 14 above). This applies specifically to Browser UI Validation journey 8 and Accessibility Acceptance Check #2 below. The approved plan's Constraints non-negotiable #2 ("mandatory static equivalents for every animated data signature") contains no explicit row count in its own wording and needs no change; it already covers row 14 by its general statement.

### Permitted variation

Consistent with the approved plan's existing "permitted variation" allowance: uniform naming for the new `dayMap` sampler and the dual-sampler crossfade uniforms; the exact dual-sampler-versus-two-mesh crossfade implementation choice (provided the "both textures rendered simultaneously during the fade" outcome holds); minor tuning of the day-side specular sheen magnitude; the exact tier-selection/upgrade algorithm (provided it loads low-first and steps up by capability without removing the ladder's existing down-stepping); and whether Natural Earth relief ships in this cycle or is deferred.

### Browser validation brief

Browser UI validation is required for this plan because every deliverable is browser-rendered UI. See "Browser UI Validation" below for the full launch/readiness, fixture, viewport, and journey requirements. No sub-phase of this plan may be treated as complete without an independent Verifier pass followed by a Browser Validator pass — this code area (the Earth material/texture pipeline) has a documented history of jsdom-invisible regressions in this repository.

## Ordered Work (phased)

This plan extends **Phase 2** of the approved plan. It is MVP-first and explicitly phased: each sub-phase below is independently shippable, and each requires an independent Verifier pass followed by a Browser Validator pass (both sub-phases produce browser UI) before being treated as complete. No sub-phase may begin before explicit user approval of this plan. Engineering may combine Phase 2A and Phase 2B into a single implementation pass if it judges that cleaner, but each shippable increment still requires its own Verifier and Browser Validator pass regardless.

### Phase 2A — Real photorealistic day-side albedo

Closes the "flat blue" gap. This can ship on the existing `.jpg` `TextureLoader` runtime path before the KTX2/LOD work in Phase 2B lands.

1. Add BMNG `world.topo.bathy` as a real source in `scripts/build-imagery.js`: raw source is the `eoimages` 21600×10800 direct file (with the GIBS WMS single-request equirectangular endpoint and the `assets.science.nasa.gov` mirror recorded as documented alternates), `baseName` `earth-day`, format JPEG. Tier it to 2K/4K/8K JPEG plus KTX2, exactly matching the existing night-lights pipeline pattern — genuine downsamples of the raw source, never an upscale of a smaller tier. Add the build-time re-fetch validation, using the pipeline's own `https.get` (which has no response-size cap, unlike the research-time fetch tool): assert HTTP 200, `image/*` content type, non-trivial byte length, a decoded-image sanity check, and compute a content hash (SHA-256) of the downloaded raw asset. This step performs the durable, concrete re-verification the "Research Evidence" section's provisional research findings are contingent on. If a future host move breaks any of these checks, the pipeline degrades gracefully to the existing honestly-labeled procedural day gradient rather than silently shipping a broken or placeholder asset.
2. Complete the licensing/attribution verification checklist entry for BMNG (and for Natural Earth relief, if included) in `ATTRIBUTION_CHECKLIST.md` and `MANIFEST.json`. These remain hand-verified records, never build output. Each entry must record concrete, reproducible provenance evidence, not a narrative claim alone: the exact resolved download URL, the retrieval date, the observed HTTP status code and content-type header (captured by the build's `https.get` in step 1), the image dimensions, the byte size, a SHA-256 content hash of the downloaded raw asset, and a citation (URL plus quoted wording) of the authoritative license source — NASA's media-usage guidelines page for BMNG, or the Natural Earth terms-of-use page for relief — per "Research Evidence" above. No integration and no non-PLACEHOLDER attribution copy may be written before the corresponding entry records all of this evidence.
3. Integrate the real day sampler into `EARTH_FRAGMENT_SHADER`: add a `dayMap` uniform, replace `proceduralDay(uv)` with the sampled day texture, keep the existing smoothstep terminator anchored to `SUN_DIRECTION`, do **not** apply the night `×4` hack to the day sampler, and keep the day-side specular architecturally unchanged. Gate the day sampler with the same real-`onLoad` discipline already used for the night texture (never bind uninitialized VRAM). Keep the existing procedural gradient as the honest fallback if the day texture fails to load, surfaced through an inline app-owned status — never a native dialog.
4. Resolve `AttributionSurface.tsx`'s Day Albedo entry to the verified real attribution text.

### Phase 2B — Real KTX2 GPU loading and visible progressive LOD

Delivers the "gradually better textures" experience for both day and night.

5. Self-host the Basis transcoder (copy `node_modules/three/examples/jsm/libs/basis/` to `public/basis/`) and add a shared `KTX2Loader`-based loader hook mirroring the existing `useImageryTexture` pattern: `setTranscoderPath('/basis/')`, `detectSupport(gl)` via `useThree(state => state.gl)` before the first load, `onLoad`-gated binding, forced `SRGBColorSpace` for color maps and `NoColorSpace`/linear for relief data maps, disposal on swap, `loader.dispose()` on unmount, and a deterministic graceful fallback to the existing `.jpg` `TextureLoader` path on any KTX2 failure or unsupported transcode target. Extend the tier-URL mapping to the `.ktx2` tiers for both day and night.
6. Implement the visible progressive-LOD experience: load the smallest/fastest tier (2K) **first** for a fast time-to-interactive regardless of device tier, then background-load higher tiers toward the device-capability ceiling and crossfade them in. Use the dual-sampler in-shader crossfade (two samplers plus an animated `mix` uniform via `computeCrossFadeOpacity`, approximately 400–500ms one-shot ease); hold both tiers alive during the fade and dispose the superseded tier only after the fade completes; continue from the current mix state on rapid successive swaps; instant swap under reduced motion (matrix row 14). Apply this symmetrically to day and night. Reconcile with the existing performance-degradation ladder: the progressive path selects the target/starting tier by device capability and steps **up** on load, while the existing ladder may still step **down** under sustained frame-time pressure — engineering chooses the single reconciled tiering mechanism, but it must preserve the ladder's existing down-step behavior and the existing poster-frame floor (rung 6).
7. Update `MANIFEST.json`'s `performanceLadder` note to reflect that the runtime now loads KTX2 with a `.jpg` fallback, not `.jpg`-only. Extend or adjust the affected unit tests (`Globe.textureTier.pure.test.ts`, `imageryPipeline.tiers.test.ts`, `usePerformance.textureTier.test.ts`), and add new tests for the crossfade timing, the reduced-motion instant swap, and the KTX2-to-`.jpg` fallback path.

Each of Phase 2A and Phase 2B requires an independent Verifier pass, then a Browser Validator pass, before being treated as complete.

## Interfaces & Data

- **No network/API interface changes.** The proxy layer and data fetchers established under the approved plan are untouched. All imagery remains self-hosted and downloaded/tiled at build time — no runtime hotlinking of NASA/GIBS/Natural Earth hosts, unchanged from the approved plan's invariant.
- **New self-hosted static assets:** `public/imagery/earth-day-{2k,4k,8k}.{jpg,ktx2}`; `public/basis/basis_transcoder.{js,wasm}`; optionally `public/imagery/earth-relief-*.{jpg,ktx2}`.
- **Shader material contract** gains a `dayMap` sampler, plus the dual-sampler crossfade uniforms (outgoing/incoming samplers and an animated mix factor). Exact uniform naming is permitted engineering variation.
- **Hand-maintained records updated:** `MANIFEST.json`, `ATTRIBUTION_CHECKLIST.md`, `AttributionSurface.tsx`. These remain hand-verified and are never regenerated by the build pipeline. Per the strengthened licensing gate above, each newly integrated source's checklist entry must record the resolved download URL, retrieval date, observed HTTP status code and content-type, image dimensions, byte size, and a SHA-256 content hash of the downloaded raw asset, plus a citation of the authoritative license source document.
- **Tier-selection interface extended.** `usePerformance`'s `getTextureTier` and `Globe.tsx`'s tier-URL mapping are extended to (a) the `.ktx2` tiers, and (b) a load-low-first-then-upgrade progression, without removing the existing ladder's down-stepping behavior.
- **Stale-request-cancellation and disposal contract for the tier loader.** The KTX2/`.jpg` tier loader must assign each tier-load request a monotonically incrementing version token. When a load callback resolves (either the KTX2 `onLoad` path or the `.jpg` fallback `onLoad` path), it must compare its own captured version against the loader's current active-request version:
  - If the versions do **not** match (a stale, superseded request resolved late), the callback is a no-op with respect to any shared sampler or material state — it disposes only its **own** just-created texture and returns.
  - If the versions match (the request is still current), normal handling proceeds: the resulting texture becomes the new "incoming" sampler in the crossfade, and the previously-current "outgoing" texture is disposed only **after** the crossfade completes (the existing bounded-to-one-extra-in-flight-tier rule from Decision B, unchanged).
  - This monotonic version-token guard supersedes relying on a boolean `cancelled` flag alone (the pattern used by the existing single-tier `useImageryTexture` hook), and must hold across rapid successive tier swaps, the KTX2-to-`.jpg` fallback path, and component unmount — no late callback may mutate or otherwise touch an already-disposed resource.

## Acceptance & Validation

**Photorealistic day-side present** (falsifiable checklist; all items must pass on a fresh, unthrottled load once the day texture has loaded):

- At least one named continent's coastline silhouette is identifiable (for example, Africa).
- The Sahara reads visibly lighter/tan compared to surrounding vegetated land.
- At least one polar ice sheet reads visibly white compared to ocean.
- Ocean reads distinguishably blue-toned compared to land.
- "Less flat than before" alone is **not** a pass.

**Visible LOD progression** (deterministic plus visual; the following numeric bounds, regions, and thresholds are pinned and committed in the Browser Validator fixture at implementation time, not left to validator judgment at run time):

- Runs under a **cold cache**: a fresh load with an empty HTTP cache. A warm-cache pass may legitimately paint the top tier faster and is explicitly not this test.
- Uses the app's default/reset camera framing (a fixed, reproducible pose), unchanged from the approved plan's existing reset procedure.
- On the unthrottled high-capability profile: the day-side first (low) tier must be painted by a fixed deadline T ≤ 2s after readiness, and the highest tier applicable to that profile must be fully settled by a fixed deadline of ≤ 8s after readiness (this 8s default is a directional value that must be pinned to a specific committed number in the fixture, adjusted only if implementation-time profiling shows it is unrealistic — it may not be silently loosened after the fact). The explicit no-page-reload assertion is retained across the whole window.
- Detail-increase measurement uses named, fixed region-of-interest (ROI) rectangles at the reset camera framing: one over a high-contrast coastline (for example, the Horn of Africa / Red Sea region) and one over a desert region. Within each ROI, a numeric detail metric (edge-energy / Laplacian variance) must increase from the initial-tier capture to the settled-tier capture by at least a fixed, recorded threshold, **or** a reference-image comparison (for example SSIM against an approved settled reference) must meet a recorded bound. The specific metric, threshold, and reference method are pinned and committed in the fixture. "Recognizable features" alone is not a sufficient pass criterion for this journey — that qualitative checklist belongs to the separate "Photorealistic day-side present" check above, not to LOD progression.
- A deterministic tier signal (the actually requested/served tier URL, or an app-exposed tier/uniform value) matches the expected 2K → 4K → 8K progression, captured across the same cold-cache run.
- A paired capability check, using the existing journey-11 throttled CPU/GPU profile, asserts the throttled profile's tier signal is lower-resolution than an unthrottled profile's at matched elapsed time.
- If the disclosed instant-swap fallback (Decision B) was taken, the ROI detail-increase/reference-comparison requirement relaxes to "a single discrete visible tier change" at the swap instant, but the deterministic tier-progression signal and the fixed timing deadlines must still hold.
- **Scene-integrity under rapid tier transitions:** during a rapid, forced succession of tier changes (mirroring engineering invariant 13 and the stale-request-cancellation contract below), the globe must continue to render — no black or corrupted framebuffer, confirmed by a real-browser pixel read, not a jsdom assertion.

**Reduced-motion tier-upgrade pass** (against all 14 matrix rows): under `prefers-reduced-motion`, a tier upgrade is an instant swap. Two consecutive frames straddling the swap show no intermediate blended frame.

**Forced-colors pass re-run:** the real day texture does not alter forced-colors behavior; the canvas stays decorative, and the DOM/companion table remain the sole fact source, unchanged from the approved plan's invariant.

**Focus-ring-over-real-day-backgrounds pass:** during keyboard-only operation, the dual-layer focus ring stays visible with measured contrast ≥3:1 (approximately 4.58:1 target) over bright desert, ice/snow, a coastline edge, and the terminator over land, via the approved plan's existing screenshot pixel-sampling method.

**Scrim measured-screenshot pass** (the approved plan's Accessibility Acceptance Check #5) re-run against the new real day backgrounds; the analytic bound itself is unchanged.

**KTX2 correctness:** `detectSupport` is called before the first load; binding is `onLoad`-gated; a forced KTX2 error triggers the `.jpg` fallback; a color map's `colorSpace === THREE.SRGBColorSpace`.

**`useFrame` signature and NaN-guard correctness (engineering invariant 13):** a deterministic regression test, mirroring the existing `Globe.useFrameDelta.regression.test.tsx` pattern, covers every new or modified `useFrame` callback introduced by this work and confirms `delta` is read as the second positional argument, never from `state`. The crossfade `mix` uniform is clamped and finite-guarded so it can never carry a NaN value into the shader regardless of a malformed `delta` or duration input.

**Stale-request-cancellation and disposal correctness (the tier-loader version-token contract):** tests cover rapid 2K→4K→8K tier changes, a forced KTX2-to-`.jpg` fallback, and unmount-during-load, in each case confirming that no late/stale load callback mutates shared sampler or material state, and that no late callback touches an already-disposed resource. A stale callback disposes only the texture it itself just created.

**Build-time source validation:** asserts HTTP 200, an `image/*` content type, a non-trivial byte length, a decoded-image sanity check, and a SHA-256 content hash for every newly integrated source URL, all captured directly by the build pipeline's own `https.get` (no response-size cap).

**Licensing gate:** every newly integrated imagery source has cleared its `ATTRIBUTION_CHECKLIST.md` entry, with the concrete provenance evidence (resolved URL, retrieval date, HTTP status, content-type, dimensions, byte size, content hash) and the authoritative license-source citation recorded per "Ordered Work" Phase 2A step 2; no PLACEHOLDER attribution copy remains at launch for any source integrated under this plan.

**No regression:** the deterministic no-native-dialog source scan passes, and the full existing test suite passes with no regression to already-verified Phase 1/Phase 2 behavior from the approved plan.

**Verifier and Browser Validator gates:** each browser-UI increment (Phase 2A, Phase 2B) requires an independent Verifier pass, then a real-browser Browser Validator pass — this exact code area has a documented history of jsdom-invisible regressions in this repository.

## Browser UI Dialog Policy

**Required**, unchanged from the approved plan. No native `alert`, `confirm`, `prompt`, `window.*` forms of these, or `beforeunload` prompts anywhere in this work. Day-texture and KTX2 load failures surface as app-owned inline status (or the app-owned modal primitive already established under the approved plan), never as a native dialog. Enforced by the same deterministic no-native-dialog source scan gate required in every increment of the approved plan.

## Browser UI Validation

**Required** for both sub-phases of this plan (Phase 2A and Phase 2B both produce browser UI).

**Launch/readiness.** Dev command: `npm run dev`. Base URL: `http://localhost:5479`. Proxy backend: `http://localhost:3479`. Readiness signal, unchanged from the approved plan: the globe canvas has rendered, and at least one filter chip is out of its loading state.

**Fixture/reset.** Per the approved plan's existing fixture/reset procedure, plus pairing an unthrottled profile with the existing journey-11 low-tier throttled CPU/GPU profile to observe LOD contrast between them. No new profile is introduced.

**Viewport/device profiles.** Phone, tablet, desktop, and kiosk (per the approved plan's breakpoints), plus 400% zoom, reduced-motion emulation, forced-colors emulation, and the low-tier throttled profile.

**Journeys and visible outcomes** (five new/updated journeys, each with the concrete falsifiable outcome stated above under "Acceptance & Validation"):

1. **Photorealistic day-side present.** Fresh unthrottled load; verify the falsifiable day-imagery checklist above.
2. **Visible LOD progression and tier-by-capability.** Cold-cache run at the reset camera framing; verify the fixed T ≤ 2s first-paint deadline and the ≤ 8s settle deadline, the named-ROI detail-increase or reference-image thresholds, the deterministic tier signal, the throttled-versus-unthrottled paired capability check, and the rapid-tier-transition scene-integrity check (no black/corrupted framebuffer), all per the pinned numeric bounds in "Acceptance & Validation."
3. **Reduced-motion instant-swap.** Emulate `prefers-reduced-motion`; verify no intermediate blended frame across a tier upgrade.
4. **Forced-colors re-run.** Emulate forced-colors; verify canvas remains decorative and DOM/companion table remain the sole fact source.
5. **Focus-ring over real day backgrounds.** Keyboard-only operation; verify the dual-layer focus ring's measured contrast over the four new sampled backgrounds (bright desert, ice/snow, coastline edge, terminator-over-land).

Real Browser Validator confirmation (not jsdom) is required for every journey above, given this code area's documented jsdom-invisible-regression history.

## Risks & Rollback

- **Source URL rot or host move** (the exact class of failure that affected prior imagery-sourcing cycles). Mitigation: the build-time re-fetch validation (HTTP status, content type, byte length, decoded-image sanity, content hash), plus graceful degradation to the honestly-labeled procedural day gradient if a download genuinely fails at build time. Multiple candidate alternate hosts (the `eoimages` direct file, the GIBS WMS single-request endpoint, the `assets.science.nasa.gov` mirror, and the Natural Earth public-domain fallback) reduce single-point dependence, each subject to the same build-time re-verification gate before integration.
- **Texture-race / black-canvas regression** (a documented history in this codebase). Mitigation: `onLoad`-gated binding only, keeping the existing `MeshPhong` loading-fallback gate in place before the `ShaderMaterial` exists, and only ever assigning the incoming crossfade sampler inside its own `onLoad` callback.
- **KTX2 colorspace uncertainty.** It is currently unknown whether the existing UASTC-encoded tiles carry the sRGB transfer-function flag. Mitigation: force `SRGBColorSpace` for color maps explicitly in `onLoad`, and verify the actual encode flag as a follow-up task.
- **VRAM pressure holding two 8K tiles during a crossfade.** Mitigation: dispose the superseded tier only after the fade completes (bounded to one extra in-flight tier), and respect the existing low-tier ladder rung.
- **GIBS WMS maximum single-request dimension for an 8192-wide `GetMap`.** Mitigation: verify the limit at build time; fall back to the direct BMNG 21600×10800 file (which needs no assembly) if the request is capped.
- **Phase 3 coordination (non-goal preservation).** Phase 3 (gesture mode) is being implemented concurrently and touches consent-modal/HUD/camera-input files, `App.tsx`, and possibly `useCamera`. This plan's work is confined to the Earth material/texture-loading regions of `Globe.tsx` (the shader source, the imagery-loader hooks, the earth-material construction and its JSX), `usePerformance`'s tier logic, `scripts/build-imagery.js`, a new KTX2 loader hook, and the imagery manifest/checklist/attribution files. `Globe.tsx` is the one plausibly-shared file between the two dispatches: neither may edit the same functions the other touches. This plan does not touch the pointer/gesture/click-selection or camera-input handlers in `Globe.tsx`. The orchestrator should sequence the two landings, or coordinate a careful merge, rather than allowing concurrent edits to `Globe.tsx`. This plan does not touch any Phase 3 file.
- **Rollback/containment.** Phased and independently revertible, matching the approved plan's existing pattern. Each increment degrades gracefully — the procedural day fallback, the `.jpg` texture fallback, and the existing poster-frame floor — rather than failing the exhibit as a whole. This plan does not re-litigate already-built/verified work; if repository state has materially changed since this plan was written, the writer must return `JOB_BLOCKED` with "Plan stale" for replanning or reapproval rather than proceeding on stale assumptions.

## Judge Route

Advisory PLAN_DUCK plan review is **eligible** for this plan per `docs/JUDGE-CONTRACT.md`, given this is a high-risk, browser-UI, shader/texture-pipeline change with a documented history of jsdom-invisible regressions in this exact code area. Running that advisory review before requesting user approval is the orchestrator's decision to make, not a requirement this plan imposes on itself. Any Codex finding from that review is advisory only; deterministic failures (test failures, the no-native-dialog scan, build-time source validation) always dominate regardless of any advisory finding. No code, verification, or visual judge call is authorized by this plan itself — those remain separate, later, explicitly scoped calls under the same contract if the orchestrator determines they are warranted during execution.

## Assumptions & Open Decisions

**Assumptions (recorded as assumptions, not settled facts):**

- The BMNG `world.topo.bathy` URLs verified live on 2026-07-19 remain reachable at implementation time; if not, the documented alternates (GIBS WMS, the `assets.science.nasa.gov` mirror, or the Natural Earth public-domain fallback) are the next options in the stated preference order.
- The existing KTX2/Basis-encoded tiles' sRGB transfer-function flag is unverified; this plan assumes forcing `SRGBColorSpace` explicitly at load time is sufficient and correct regardless of the encoded flag's actual state.
- The approximately 400–500ms crossfade duration is a directional tuning value within the existing 300–800ms crossfade family, not a fixed constant.
- Natural Earth relief/bump integration is optional this cycle; whether it ships is an engineering decision within permitted variation.

**Open decisions** (do not block engineering planning; some should resolve during implementation):

- Whether Natural Earth relief/bump ships in this cycle or is deferred to a future one.
- The exact dual-sampler-versus-two-mesh crossfade implementation choice (permitted variation; outcome is fixed, mechanism is not).
- Whether the GIBS WMS single-request path or the direct BMNG file becomes the primary build-time source, pending the WMS maximum-dimension check at build time.

## Engineering Mode & Downstream Owner

**Engineering mode:** standard (phased/MVP-first; standard T1/T2 escalation with Verifier and Browser Validator gates). This is explicitly **not** an extreme-advisory-team route; `team_authorization` is not applicable.

**Downstream owner:** `engineering-fleet`, routed through the standard T1/T2/T3/Engineering Lead chain, using this plan's exact path as `approved_plan`, only **after** explicit user approval is given.

## Required Approval

**USER APPROVAL of this plan is required before any downstream execution.** This plan grants no execution authority and no commit authority on its own. Approval must be explicit and given by the user; no teammate, agent, or automated process may substitute for it. Approval of this plan does not itself authorize any commit, push, deployment, or pull request — those require separate, later, explicit user approval.

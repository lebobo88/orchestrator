# Plan: mythic-proportion-audit-fix-design - Audit, Fix, and Four-Mode Design Expansion

Status: APPROVED. Approved by rob.hasselbach@gmail.com on 2026-07-16. Engineering work (t2-engineer, per Section 10.1's routing override) may now begin. This approval does not cover the separate additive-token-family approval (Section 7/10.7) or any commit/push/deployment/pull-request approval (Section 10.7/14); those remain open, separate, later approvals, unaffected by this update.

task_id: mythic-proportion-audit-fix-design-2026-07-16
plan_id: mythic-proportion-audit-fix-design

This plan recommends work. It does not grant execution authority. No engineering writer (T1/T2/T3/Engineering Lead) may start work against this plan until the user has given explicit approval. Once approved, the approved plan path becomes `ENGINEERING_JOB.approved_plan` for the engineering fleet. Approval of this plan does not authorize any commit, push, deployment, or pull request; that remains a separate, later, explicit user approval.

## Pre-execution note (read before starting any Phase 2-4 work)

`mythic-proportion/HANDOFF.md` is historical and superseded for this job. It is operationally contradictory with this plan: `HANDOFF.md` directs the next session to continue on branch `feat/3d-graphrag` at Phase 7 and to push that branch (its "Remaining phases" section and its closing "Bottom line" both instruct continuing at P7 using the harness pattern it describes, and its step-by-step execution pattern ends with `git push origin feat/3d-graphrag`). This plan instead anchors all work to local `main @ 0e5e1c5` (the completed merge), defers P7-P10 as explicit non-goals (Section 3.2), and prohibits any commit, push, deployment, or pull request without separate, explicit, later user approval (Section 3.2, Section 10.5, Section 14).

Wherever this plan and `HANDOFF.md` differ, this plan's scope, phase sequencing, and approval gates prevail. `t2-engineer`, and anyone else executing this plan, must follow this plan, not `HANDOFF.md`'s literal "continue at P7 / push `feat/3d-graphrag`" instructions. Phase 3 (Section 6.2) schedules bringing `HANDOFF.md` itself into alignment with this reality, rather than leaving the contradiction in place.

This note originates from an advisory, non-blocking `PLAN_DUCK` finding (J-001; see Section 12) and was independently confirmed against the current contents of `mythic-proportion/HANDOFF.md` before being added here.

## 1. Summary

`mythic-proportion` is a local 3D-GraphRAG "second brain" application. The working tree is the local-only merge of `feat/3d-graphrag` into `main` at commit `0e5e1c5` (not pushed; `origin/feat/3d-graphrag` remains intact). A read-only investigation confirmed this is a real, sophisticated, mostly-built application (Vite + React + React-Three-Fiber frontend, SQLite/GraphRAG backend, hierarchical Leiden community detection already computed server-side) with concrete security gaps, documentation drift, and an existing but visually and functionally incomplete 3D graph view.

This plan sequences four phases: (2) a browser audit of the whole application to produce a concrete punch list, (3) fix/remediation covering security hardening and documentation refresh plus closing audit-identified defects, (4) a design expansion that adds three new switchable graph representations (Orbital Systems, Strata, Knowledge Terrain) alongside the existing standard force-directed view, plus a Standard-tier upgrade of the overall app layout, gated by a bounded engineering spike before full build. Phase 1 (investigation) is already complete and its findings are recorded in Section 3 as the grounded evidence baseline.

## 2. Outcome and audience

Deliver a fully working, secured, and visually upgraded local 3D-GraphRAG application that matches or exceeds its own documented intent, for a single keyboard-first power user, with parity for keyboard-only navigation, reduced-motion preference, no-WebGL fallback, and assistive-technology use. The graph page gains four user-switchable representations of the same underlying data: the existing standard force-directed "neural cloud" view plus three new modes, Orbital Systems, Strata, and Knowledge Terrain. The overall application is upgraded into one coherent instrument across all seven views. Every change in this plan is grounded in the actual merged code identified during investigation, not assumptions.

## 3. Scope and non-goals

### 3.1 In scope: four linked phases

- **Phase 1, Investigate (complete)**: read-only confirmation that the merged tree is the real 3D-GraphRAG application, producing the built/incomplete/broken ledger in Section 3.3.
- **Phase 2, Browser audit**: launch the real application locally and walk all seven views plus both existing graph representations (3D scene and 2D fallback) in Chrome; run a deterministic no-native-dialog scan; produce a concrete punch list of what is broken, incomplete, or regressed relative to the repository's own specs/blueprint, covering the whole application, not only the graph page.
- **Phase 3, Fix/remediation** (the main engineering body): security hardening (CORS policy, CSRF protection on state-changing `/api/*` POST routes, an upload size cap); a refresh of the stale root `README.md` and drifted `docs/` API documentation to match the merged app; confirmation that `static_next` builds and `/app` serves correctly; and closure of concrete defects surfaced by the audit and the investigation.
- **Phase 4, Design expansion**: implementation of the passed, independently reviewed `DESIGN_HANDOFF`, namely the enriched `/api/graph` Leiden projection plus client wiring, the four-mode graph page (Orbital/Strata/Terrain plus mode-switch UX, the shared-state lifecycle fix, the TabNav nav-plus-links fix, the generative community color ramp, and the extended gating contrast test), the Standard-tier overall-app layout upgrade across all seven views plus shell/TabNav plus Cmd+K palette plus a first-class reading/detail pane, and a Terrain-only shipped-asset capture pass using Atelier/ComfyUI (Section 10.3 also makes Atelier/ComfyUI available as a standing tool for design-process exploration across the whole design workflow, not only this shipped-asset pass). A bounded, Browser-validated engineering spike (mode-switch transition continuity plus Terrain heightfield feasibility at roughly 1.5k nodes and stress-tested toward 10k) runs first, before full four-mode implementation, to de-risk the approach.

### 3.2 Non-goals (explicitly out of scope for this plan)

- **P7 agent layer, P8 MCP server, P9 ComfyUI product pipeline** (beyond the Phase 4 design-asset capture pass), **P10 cutover** (retiring the legacy `/` SPA and `web/static`; the branch merge itself is already done). Investigation verified these are genuinely not built: one-line stubs in `agents/__init__.py` and `mcp/__init__.py`, no `mythic mcp` CLI verb, no `tools/` ComfyUI directory. These remain deferred unless the user separately adds them to scope; this plan does not schedule or estimate them.
- **No new graph computation.** Hierarchical Leiden community detection is already computed and stored server-side (`graph/communities.py`, `store.community_memberships`, `store.max_community_level`). The enriched `/api/graph` contract in this plan is a projection of already-computed server data, not new graph algorithm work.
- **No DeepSeek judge integration of any kind.** This is explicitly out of scope and deferred, and is not scheduled, mentioned, or referenced anywhere in this plan as future work.
- **No commit, push, deployment, or pull request** without a separate, explicit, later user approval. Approving this plan authorizes recommended engineering work only.
- Shipped, in-app generated 3D/texture assets are confined to the O(1)-to-O(tens) chrome/environment/landmark layer of the Terrain mode only. The O(1.5k-to-10k) node/edge layer of every mode (including Terrain) stays procedural instanced-primitive plus shader plus matcap plus impostor; unique per-node generated meshes are out of scope because they would break the single-draw-call rendering budget. This is a shipped-asset boundary only: it does not restrict Atelier/ComfyUI use for design-process exploration (concept art, mood/reference boards, UI mockups) anywhere in the design workflow, which is unrestricted and standing, per Section 10.3. Design-exploration artifacts are not shipped into the render hot path, so there is no conflict between the two.

### 3.3 Repository findings (grounded evidence baseline)

The following is grounded in a read-only investigation of the merged tree at `main @ 0e5e1c5`. Paths are cited as found; this section is the evidence baseline the rest of the plan cites against.

- **The app is real and sophisticated.** Frontend `web/` = Vite + React + React-Three-Fiber (`three` ^0.169, `@react-three/fiber` ^8.17, `@react-three/drei` ^9.114, `@three.ez/instanced-mesh` `InstancedMesh2` ^0.3.15, `d3-force-3d` ^3.0.6, `troika-three-text`, `cmdk`, `@radix-ui/react-dialog` plus `tooltip`, `culori`). Base path `/app`; build `outDir` is `../src/mythic_proportion/web/static_next`. Seven views: `web/src/routes/{wiki,search,ask,graph,ingest,lint,settings}/*View.tsx`; `shell/TabNav.tsx`; `command-palette/CommandPalette.tsx`; theming via `lib/theme.ts` plus `ThemeToggle.tsx`; OKLCH design tokens at `web/src/styles/tokens/{primitives,semantic,components,graph,motion}.css`.
- **The 3D graph seam** (Phase 4 centerpiece) lives at `web/src/routes/graph/`: `GraphView.tsx` (owner state, 2D/3D toggle, reduced-motion auto-2D, a progressive-disclosure cap scaling from ~1,500 toward 10,000, an accessibility tree); `three/Graph3DScene.tsx` (R3F canvas, worker tick driving GPU state, camera-fit triggered on the worker's "end" event, `webglcontextlost` triggers auto-2D fallback); `three/InstancedNodes.tsx` (single-draw-call `InstancedMesh2` colored via a `colorsTexture`, deliberately not `vertexColors`; an in-code comment documents a black-multiply bug this avoids; a three-tier level-of-detail chain icosahedron-42 to icosahedron-12 to quad; BVH-based cull and pick); `three/forceLayout.worker.ts` plus `ForceLayoutClient.ts` (d3-force-3d owned by a worker, using recycled transferable `Float32Array` buffers); `NodeLabels.tsx` (troika text); `CommunityHulls.tsx` (`meshBasicMaterial` with alpha, `depthWrite:false`); `Graph2DFallback.tsx`; `a11y/GraphA11yTree.tsx`; `graphMath.ts`; `lib/graph-colors.ts` (the single culori OKLCH-to-`THREE.Color` bridge; an 8-slot `--graph-community` ramp; re-reads colors on a `data-theme` flip).
- **Critical data finding.** `GET /api/graph` today returns only `id`/`label`/`type`/`kind`/`degree` per node. `graphMath.ts`'s `computeCommunities` is a client-side union-find connected-component grouping hashed into 8 buckets, explicitly commented in-code as "intentionally NOT a Leiden implementation." The server's `read_entity_graph` (in `src/mythic_proportion/web`, backed by `store.py:605-633`) projects only `id`/`label`/`type`/`kind`/`degree` per node but **does already return edge weight** (`store.py:629`, `"weight": row["weight"]`, from the `store.py:631` query `SELECT source_id, target_id, type, weight FROM relationships`; `store.py:609` confirms typed, weighted edges). Real hierarchical Leiden plus centrality already exist server-side but are not currently projected onto graph nodes returned to the client. This makes the enriched `/api/graph` per-node projection (community/level/centrality) the mandatory shared data dependency for all three new modes; edge weight is already served and needs only client wiring.
- **Graph state lifecycle defect.** `App.tsx` renders `{activeTab === "Graph" ? <Suspense><GraphView/></Suspense> : null}` (`App.tsx:101-105`), which unmounts and destroys `GraphView`, including its worker, physics state, selection, filters, and expanded-node set, on any tab switch away from Graph. The built-in "Open in Wiki" action (`GraphView.tsx:240-241`, which calls `App.openPage` and sets `activeTab` to `"Wiki"` via `App.tsx:59-63`) is exactly this kind of excursion: it wipes graph state and cold-restarts the physics simulation on return. This defect must be fixed (via mounted-hidden rendering or lifted owner state) so state survives tab excursions.
- **TabNav defect.** `TabNav.tsx` ships a non-conformant ARIA hybrid: `<nav aria-label="Primary"><ul role="tablist">` with `role="tab"` and `aria-selected`, but no `aria-controls`/`role="tabpanel"` pairing and no roving `tabindex` or Arrow/Home/End keyboard support. This must be fixed to a conformant nav-plus-links pattern (`aria-current="page"` plus a non-color underline/bold cue).
- **Backend graph pipeline**: `src/mythic_proportion/graph/{extract,tuples,chunk,claims,communities,reports,store,cache,index}.py` implements delimited-tuple entity/relationship/claim extraction, hierarchical Leiden (`graspologic` primary, `leidenalg` plus `igraph` as the Windows fallback, gated behind the `[graphrag]` extra), community reports, and a `GraphStore` over SQLite. Retrieval `query/modes.py` implements GLOBAL/LOCAL/DRIFT/spreading-activation modes; the `/api/query` mode contract is preserved as-is (omitting `mode` returns the legacy `{text, citations, hits, used_llm, error}` five-key shape; `app.py:226`, `app.py:261-277`) and **must not regress** anywhere in this plan.
- **Backend app** `src/mythic_proportion/web/app.py` routes: `GET /` (legacy SPA), `/app` mount (serves `static_next`, guarded by an `is_dir()` check), `/api/pages`, `/api/page`, `/api/search`, `POST /api/query`, `/api/graph`, `POST /api/ingest`, `/api/upload`, `GET /api/ingest/status`, `/api/jobs/{id}`, `POST /api/index-graph` plus its status route, `/api/lint`, `POST /api/lint/fix`, `GET`/`POST /api/config`, `/api/models`. **Security gaps confirmed**: no CORS middleware; no CSRF protection on state-changing POST routes (`/api/upload`, `/api/ingest`, `/api/index-graph`, `/api/lint/fix`, `/api/config`); no upload size cap (`/api/upload`, `app.py:345-362`). P6 privacy controls are already present and must be preserved: `privacy/redact.py` (Presidio, fail-closed, plus a `SecretScanRecognizer` plus an optional `OpenAIPrivacyFilter`), `llm/ollama.py` (`qwen2.5:7b`, structured outputs, a loopback egress gate enforced both at config-set time and at client-construction time). `docs/security/*` (threat model, control matrix, data classification, SBOM, `security-advisory-graphrag-extraction-20260712.md`) plus `docs/faq-graphrag-extraction-fixes.md` document post-P6 extraction and egress fixes (DEFECT-1 plus the egress gate), enforced by `tests/test_egress_gate.py` and `tests/test_graph_extraction_egress.py`.
- **Native-dialog scan: clean.** A grep of `web/src` (and the legacy `static/` tree) for `alert(`, `confirm(`, `prompt(`, `window.*` dialog forms, and `beforeunload` returned zero matches. A Radix `Dialog` wrapper already exists at `web/src/components/ui/Dialog.tsx`.
- **Built vs. not-built.** `specs/mythic-proportion-3d-graphrag.html` shows phase chips P0-P6 checked, P7-P10 unchecked. `agents/__init__.py` and `mcp/__init__.py` are one-line stubs; there is no `mythic mcp` CLI verb and no `tools/` ComfyUI directory. CLI verbs present: `init`, `ingest`, `reindex` (hidden), `index-graph`, `query`, `lint`, `watch`, `serve`, `ingest-harness` (hidden). The `index-graph` verb, the `/api/index-graph` route, and the `auto_build_graph` toggle all exist (the DEFECT-1 fix).
- **Test baselines to keep green.** 28 pytest files under `tests/` (`pyproject.toml` `testpaths = ["tests"]`); 17 vitest `*.test.ts(x)` files under `web/src` (`web/vitest.config.ts`, jsdom environment). The coordinator's reported current baselines are approximately 351 Python tests and approximately 103 frontend tests (labeled as an assumption to confirm at readiness; see Section 10.6). `src/styles/__tests__/contrast.test.ts` is a real gating harness that parses `primitives.css` plus `semantic.css` and must be **extended** to cover `graph.css` and the generated community ramp. No Playwright or Chrome end-to-end specs currently exist in the repository.
- **Documentation drift.** The root `README.md` still describes only the legacy vanilla SPA, six tabs, and `127.0.0.1:8765/`; it does not mention `/app`, `web/`, `index-graph`, Ollama/privacy, or the seven current views. `docs/architecture.md` and `docs/usage.md` pre-date the 3D/GraphRAG work. API documentation regeneration is pending. Current, non-stale documentation includes `docs/frontend.md`, `docs/CHANGELOG.md`, `docs/security/*`, `docs/faq-graphrag-extraction-fixes.md`, and `specs/parity-checklist.md`.

## 4. Research evidence

Two nested, read-only Researcher packets were consumed directly during planning and are not separately persisted:

1. **Local codebase reconciliation**: a full merged-tree source ledger covering `web/`, `src/mythic_proportion/graph|web|privacy|llm`, `pyproject.toml`, `tests/`, `docs/`, and `specs/`. This packet grounds Section 3.3 above.
2. **External, web-sourced evidence** grounding the Phase 4 design: a ranked comparison of 3D graph metaphors suited to a Leiden-community-rich graph rendered in React-Three-Fiber/`InstancedMesh2`/worker architecture (solar-system, DAG-strata, radial/galaxy, terrain-heightfield, treemap, and hyperbolic layouts, with a live reference implementation, `ChristopherLyon/graphrag-workbench`); the Obsidian graph-view affordance checklist (degree-driven size, community color, hover-highlight-with-fade, a depth slider, a text-fade threshold, a forces panel, zoom-to-fit) used to inform polish on the existing standard view; and ComfyUI generation mechanics for Flux (fp8 quantization on a 12GB GPU) versus SDXL, plus Trellis2 (512-cubed image-to-3D, GLB output), together with the assets-versus-procedural tradeoff that confines generated assets to the O(1)-to-O(tens) chrome/environment/landmark layer (a matcap atlas, an HDRI skybox, and a handful of landmark GLBs are identified as the cost-effective sweet spots).

Both packets are time-sensitive Researcher evidence; the freshness caveat that applies to any externally sourced technical recommendation applies here: reconfirm library versions and generation-tooling specifics at implementation time if a material amount of time has passed since 2026-07-16.

## 5. Design route, handoff, and review

**Design route**: two linked surfaces, both already through independent review.

- **Overall-app layout** = **Standard** tier (Design Director, UX Architect, Visual System Designer, and an independent Design Reviewer).
- **Graph-page second representation** = **Studio** tier. Three directions (safe/refined/novel) were presented; the user selected building all three directions plus retaining the existing standard view, yielding four total graph modes. Asset Art Director and Motion Designer were engaged, and Atelier/ComfyUI (Flux-over-SDXL for images, Trellis2 for 3D) is available to every design specialist across the whole design workflow, not only for Terrain shipped-asset work (Section 10.3). A conditional prototype was considered and Planner deferred it to a Browser-validated engineering spike in Phase 4a instead of a disposable Studio prototype (Section 6.3).

**Model tier used**: Opus 4.8 (high) for the Design Director and all four design specialists, per the user's approved Opus-default design-tiering override (Section 10.2). Sonnet is reserved for genuinely trivial follow-ups; Fable is reserved and unused for this design pass.

**existing_system_mode**: extend. No rebrand. Additive design tokens only, with one flagged optional light-theme community-lightness override (Section 5.3, Section 7).

### 5.1 Passed `DESIGN_HANDOFF` (profile: studio, revision 1)

Task ID `mythic-proportion-graph-four-mode-and-app-instrument-studio-2026-07-16`. Unifying thesis: **encoding invariance**, meaning community maps to the same color, glyph, and text triad across all four graph modes and in 2D chrome; centrality maps to node size; a focus-plus-dim-context motif is generalized app-wide. The full handoff, held in the Planner/design chain, contains:

- A **UX spec**: the mode-switch radiogroup control; a per-mode user journey; shared-state persistence including the Open-in-Wiki round trip; per-mode 2D fallback plus accessibility-tree parity; the TabNav nav-plus-links fix; and the overall-app information architecture.
- A **visual-system spec**: a generative OKLCH community color ramp, `communityColor(index, count, level)`, with hue computed as `20 + index * (360 / count)`; hierarchy level maps to bounded chroma only, never lightness; non-color glyph and pattern cues accompany every color-coded distinction; Terrain uses a sequential single-hue ramp plus elevation contours; troika text labels carry an outline sufficient for local contrast of at least 4.5:1; additive DTCG 2025.10-format tokens; an extended gating contrast test case (Section 6.5).
- A **motion and asset spec**: M1, a bounded (approximately 800ms or less), interruptible matrix-interpolation transition between modes, eased toward worker-computed physics targets (physics itself is never animated/faked); M2, a focus-plus-context dim treatment; M3, camera re-fit triggered on the worker's "end" event; a strict reduced-motion path (auto-2D, or an instant/cross-fade transition with no position interpolation); Terrain-only generated assets (at most 2 Flux fp8 equirectangular HDRI/skybox images, at most 2 Flux fp8 neutral topographic matcap-atlas images, and optionally up to 6 Trellis2 512-cubed landmark GLBs), all explicitly placeholder, enhancement-only, and backed by a procedural/token fallback; code-native SVG icons for mode and community glyphs.
- **Engineering invariants** (Section 6.5 below restates these as acceptance-bearing work items): the enriched `/api/graph` per-node projection; edge weight already served; the graph state lifecycle fix; the TabNav nav-plus-links fix; single-draw-call `InstancedMesh2` via `colorsTexture`, never `vertexColors`; worker-owned physics; culori as the single color source, with the generative ramp extending `readGraphColors` and introducing no second color path and no hardcoded hex values; camera-fit on the worker's "end" event; auto-2D on WebGL context loss; 2D-plus-accessibility-tree parity across all four modes; auto-2D under reduced motion; the ~1,500-node cap scaling toward 10,000; the community-hull material preserved as-is; no native dialogs anywhere; tokens extend, never replace.
- **Permitted variation** and a **browser-validation brief** covering 8 journeys (restated in Section 9.3).

### 5.2 Independent design review

**Result: PASS** (revision 1), after one permitted, evidence-backed revision that closed four findings: the shared-state/tab-unmount reconciliation approach; the TabNav ARIA fix to a nav-plus-links pattern; scoping the gating contrast test to generated ramp members plus chrome pairings; and reclassifying edge weight as already-served (client-wiring-only, not a new server capability). The reviewer's PASS explicitly notes that final acceptance still depends on (a) an independent Browser Validation pass and (b) the extended gating contrast test passing in CI. The reviewer assessed the six non-graph views and the Command Palette internals only at shell/contract level, not in full implementation detail; this is a labeled limit of the review, not a blocking gap for this plan.

### 5.3 Unresolved plan-stage decisions (acceptable open items, not blockers)

The following are explicitly acceptable to leave open at plan approval and settle during Phase 4 engineering, provided no value is fabricated and any missing dimension is labeled as open rather than silently defaulted:

- The exact Leiden hierarchy level depth exposed in the Strata mode.
- Which centrality measure drives node size (degree is the default; betweenness or eigenvector centrality is an additional/selectable channel).
- Whether Orbital mode takes the real Leiden dependency immediately (recommended) versus an interim "approximate" client-bucket grouping.
- Approval of the new additive token families (`--focus-context-dim`, the `--graph-community-glyph`/`pattern` set, the generator parameters, and the optional light-theme `--graph-community-*` lightness override) and adoption of the expanded gating contrast test case.
- The Terrain elevation-aggregation formula and the generator's hue strategy/large-community-count cap.

## 6. Ordered work

Owners and dependencies are stated per step. No engineering step in Sections 6.1-6.7 may begin before explicit user approval of this plan (Section 12). Deterministic gate failures always dominate advisory judge findings.

### 6.0 Readiness and enablement (prerequisite, before Phase 2)

- `pip install 'mythic-proportion[web]'` plus `[graphrag]`, `[privacy]`, `[local]` extras as needed for full feature coverage.
- `cd web && npm install && npm run build`: this produces `src/mythic_proportion/web/static_next` so that `/app` serves. Confirm at execution time whether `static_next` is already committed to the repository; if it is absent, `/app` returns 404 until this build step runs.
- Establish green baselines: `python -m pytest` (approximately 351 tests, per the coordinator-reported baseline in Section 3.3; confirm the exact count at execution); `cd web && npx vitest run` (approximately 103 tests); `make check` (ruff plus mypy plus pytest).
- Initialize a demo vault and run `mythic index-graph` so that entity and "both" graphs are non-empty for the Phase 2 audit.
- **Owner**: T2 engineer (per the routing override in Section 10.1). **Dependency**: none; this is the first executable step after approval.

### 6.1 Phase 2: Browser audit

- **Owner**: Browser Validator, in a read-only assessment role. **Dependency**: Section 6.0 readiness complete.
- Launch `mythic serve` to reach `http://127.0.0.1:8765/` (the legacy `/` route) and `/app/` (the 3D application), and separately launch the Vite dev server (`cd web && npm run dev`, confirming the exact printed port, expected near `http://localhost:5173/app/`), using the `?syntheticGraph=N` query parameter (for example, N=10000) to exercise the graph without live backend data.
- Walk all seven views plus both existing graph representations (the 3D scene and the 2D fallback plus its accessibility tree) across desktop (~1440px), tablet (~834px), and narrow (~375px) viewports, at 400% zoom, and in both light and dark themes.
- Run the deterministic no-native-dialog scan (Section 8); it must return zero matches, consistent with the clean baseline already confirmed in Section 3.3.
- **Output**: a concrete punch list of broken, incomplete, or regressed items across the whole application, each mapped to a specific path or journey and to a proposed fix task, feeding directly into Phase 3 scope.

### 6.2 Phase 3: Fix/remediation

- **Owner**: T2 engineer (per the routing override in Section 10.1), with Scribe authoring the documentation deliverable in item (b); documentation writing is never routed to the engineer directly.
- (a) **Security hardening**: add CORS middleware with a locked-down policy scoped to known local origins; add CSRF protection on every state-changing `/api/*` POST route (`/api/upload`, `/api/ingest`, `/api/index-graph`, `/api/lint/fix`, `/api/config`); add an upload size cap on `/api/upload`.
- (b) **Documentation refresh**: T2 supplies verified, current facts about the merged application; Scribe rewrites the stale root `README.md` and the drifted `docs/` API documentation to match the actual merged app (the seven views, `/app`, `web/`, `index-graph`, Ollama/privacy). T2 does not author this document; Scribe does.
  - **HANDOFF.md correction (explicit item, not folded into the general stale-docs work above)**: update or archive `mythic-proportion/HANDOFF.md` so it matches reality, namely that `main` is the source of truth, P0-P6 are done and merged, P7-P10 are deferred non-goals, and no push occurs without separate, explicit, later user approval. This resolves `HANDOFF.md`'s direct contradiction with this plan, described in the pre-execution note near the top of this document. T2 supplies the verified facts; Scribe authors this document change, consistent with this plan's routing of documentation writing to Scribe.
- (c) **Static build/serve correctness**: confirm `static_next` builds and `/app` serves correctly end to end.
- (d) **Close concrete defects** surfaced by the Section 6.1 punch list and the Section 3.3 investigation, for example confirming whether the two `llm/*.py` `NotImplementedError` occurrences are abstract-base placeholders rather than reachable dead code, and fixing them if they are not.
- **Preserve** the `/api/query` legacy mode contract and all P6 egress-gate behavior throughout this phase; neither may regress.
- **Dependency**: Section 6.1 punch list for item (d); items (a)-(c) may proceed once Section 6.0 readiness is complete.
- **Per-change gates**: pytest and vitest stay green; an independent Verifier pass; a `CODE_REVIEW` Codex judge checkpoint on security-sensitive diffs; a Browser Validator pass on any UI-affecting change.

### 6.3 Phase 4a: De-risking spike (bounded, before full four-mode build)

- **Owner**: T2 engineer, Browser-validated. **Dependency**: Section 6.2 complete (or at minimum, a stable baseline with security/doc fixes landed and tests green).
- Prototype, on synthetic fixtures: (1) mode-switch transition continuity, meaning the matrix-interpolation approach between Cloud/Orbital/Strata/Terrain with shared state and camera re-fit, plus the reduced-motion instant/cross-fade variant; and (2) Knowledge Terrain feasibility, meaning heightfield surface rendering, contour/tier legibility, and procedural nodes riding the surface, at approximately 1,500 nodes and stress-tested toward 10,000, with the single-draw-call node layer preserved throughout.
- Atelier/ComfyUI is available to this spike for design-exploration purposes (reference imagery, mockups, mood boards informing the heightfield/contour treatment); this remains design-process tooling, distinct from the Terrain shipped-chrome-asset pass in Section 6.7, per the standing-tool note in Section 10.3.
- This is a **gate**, not a build-ahead step: if a metaphor proves infeasible or illegible at this bounded scale, that finding is surfaced back into the plan for a decision, rather than forced into the full build.

### 6.4 Phase 4b: Enriched data contract

- **Owner**: T2 engineer. **Dependency**: Section 6.3 spike passes (or its findings are resolved).
- Implement the `/api/graph` per-node projection of the already-computed hierarchical Leiden output: `community` (real Leiden community ID), `level` (hierarchy depth, 0 = coarsest), `centrality` (an object with `degree` plus at least one of `betweenness` or `eigenvector`, each normalized to 0..1), and an optional `parentCommunity` per level.
- Wire the client's `VizEdge` type to consume the edge `weight` field the server already returns (`types.ts`'s `VizEdge.weight` is already optional; only client wiring is new).
- `deriveVizGraph` consumes the new server fields when present and falls back to the existing client union-find grouping (explicitly labeled "approximate") when they are absent, preserving backward compatibility.
- The empty-graph state names the `mythic index-graph` precondition explicitly and links to the Ingest view.

### 6.5 Phase 4c: Four-mode graph and mode-switch UX

- **Owner**: T2 engineer. **Dependency**: Section 6.4 enriched contract available.
- Implement Orbital, Strata, and Terrain as worker force-configuration variants layered over the existing shared `InstancedMesh2` node layer, with no per-node meshes in any mode.
- Implement the mode-switch radiogroup control.
- Implement the graph state lifecycle fix identified in Section 3.3 (mounted-hidden rendering or lifted owner state), ensuring the worker never cold-restarts and that selection, filters, and expanded-node state survive both the Open-in-Wiki round trip and any other tab excursion.
- Implement the TabNav nav-plus-links fix identified in Section 3.3.
- Implement the generative OKLCH community color ramp extending `readGraphColors`, per Section 5.1's visual-system spec.
- Implement per-mode 2D fallback plus accessibility-tree parity: Orbital as a tree grouped by community, Strata as a Leiden-hierarchy tree, and Terrain as a region list with numeric elevation values.
- Implement two `aria-live` regions as specified in the design handoff.
- Extend `contrast.test.ts` with the gating case: generated ramp members at community counts of 8, 16, and 32; level-to-chroma bounds; and community-as-accent pairings, in both themes.

### 6.6 Phase 4d: Overall-app Standard upgrade

- **Owner**: T2 engineer. **Dependency**: may proceed in parallel with or after Section 6.5, since it touches shell/chrome rather than the graph-mode internals; sequence at the engineer's discretion once Section 6.4 is stable.
- Implement a coherent-instrument layout across all seven views plus the shell/TabNav plus the Cmd+K command palette plus a first-class reading/detail pane.
- Extend, never replace, the existing OKLCH tokens, Radix components, and `theme.ts`.
- Carry community color into 2D chrome as an accent, always paired with a non-color cue.
- Implement the generalized focus-plus-context-dim treatment app-wide.

### 6.7 Phase 4e: Terrain asset capture

This step governs shipped, in-app Terrain chrome-layer assets specifically. Atelier/ComfyUI's broader, standing availability across the whole design workflow for design-process exploration is a separate matter, covered in Section 10.3, and is not limited to this step.

- **Owner**: T2 engineer, working with Atelier MCP and ComfyUI at `H:\LocalAI` (RTX 3080 Ti, 12GB VRAM; starting ComfyUI locally is pre-approved per Section 10.3). **Dependency**: Section 6.3 Terrain feasibility spike passes.
- Generate Terrain chrome-layer assets only: Flux (fp8, preferred over SDXL) equirectangular HDRI/skybox images (at most 2, each capped at 2048x1024 and roughly under 24MB); a Flux fp8 neutral topographic matcap atlas (at most 2 images, no baked hue, each capped at 1024x1024 and roughly under 6MB); optionally up to 6 Trellis2 512-cubed landmark GLBs (each roughly under 5,000 triangles, roughly under 20MB total).
- Every generated asset is placeholder, enhancement-only, and backed by a token or procedural fallback; the node/edge layer remains fully procedural. Label every generated asset explicitly as a placeholder in code comments or asset manifests, and make no fabricated production-readiness claims about them.

### 6.8 Closeout

- Full green pytest and vitest runs; `make check` green.
- Independent Verifier pass.
- Browser Validator pass over all 8 design journeys (Section 9.3) plus the whole-app audit journeys (Section 6.1).
- Applicable Codex judge checkpoints: `VISUAL_REVIEW`, `CODE_REVIEW`, and `VERIFICATION_CHALLENGE` as scoped in Section 11.
- Refreshed documentation confirmed current against the final merged state.
- No commit, push, deployment, or pull request without a separate, explicit, later user approval.

## 7. Interfaces and data

- **Enriched `GET /api/graph` node shape** adds: `community` (integer, the real Leiden community ID), `level` (integer, hierarchy depth, 0 = coarsest), `centrality` (an object with `degree` and at least one of `betweenness` or `eigenvector`, each normalized 0..1), and an optional `parentCommunity` keyed by level. This is a **projection of already-computed** `graspologic` hierarchical Leiden output (`store.community_memberships`, `store.max_community_level`); it is not new graph computation. It is backward compatible: the client falls back to its existing union-find grouping when these fields are absent, which keeps rollout safe.
- **Edge shape**: `weight` is already returned by `read_entity_graph` (`store.py:629`/`631`/`609`); only the client's `VizEdge` wiring is new (`types.ts`'s `VizEdge.weight` field is already optional).
- **Preserved contracts**: the `/api/query` mode contract (omitting `mode` returns the legacy 5-key shape) and the P6 loopback egress gate (enforced at both config-set time and client-construction time) must not change.
- **New additive DTCG 2025.10 tokens** (require design-system-owner approval before adoption, per Section 5.3): `--focus-context-dim` (approximately 0.28); a `--graph-community-glyph-*`/`pattern-*` set; `graph.community.generator` parameters; a `terrain.*` family (elevation ramp steps 1 through 5, contour-line/major line tokens, `sky.bg`, `matcap.ref`, `band.*`); edge-weight width/opacity minimum/maximum tokens; component-tier tokens for the mode radiogroup, the Strata level control, the community legend, the community chip, the reading pane, and a focus ring of at least 2px width and at least 3:1 contrast. One flagged optional light-theme `--graph-community-*` lightness override is proposed (dark-theme values unchanged). No other existing token value is replaced.

## 8. Browser UI dialog policy

This policy is required for every browser-rendered surface touched in this plan. Prohibited without exception: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts. The current source scan is clean (Section 3.3) and must remain clean through every phase. Any acknowledgement or confirmation introduced by this plan's work must use an app-owned, accessible Radix `Dialog` (focus trap, initial focus placement, Escape-to-cancel, focus restoration to the invoking element, explicit visible buttons); inline validation is used where it better serves the user (for example, calculation or graph-loading error states). Every browser-UI engineering step in this plan requires a deterministic no-native-dialog source scan (zero matches) plus a modal keyboard/focus verification wherever a new modal is introduced.

## 9. Acceptance and validation

### 9.1 Per-phase acceptance

- **Investigate**: the repository findings in Section 3.3 are accepted as the grounded baseline (already complete).
- **Audit**: a written punch list exists mapping each broken, incomplete, or regressed item to its evidence (path or journey) and to a proposed fix task; the deterministic no-native-dialog scan returns zero matches; the application launches and every one of the seven views is reachable.
- **Fix**: CORS policy, CSRF protection on state-changing `/api/*` routes, and an upload size cap are implemented and tested; the root `README.md` plus API documentation are refreshed to match the merged app (Scribe-authored, per Section 6.2); `static_next` builds and `/app` serves; the `/api/query` legacy mode contract and the egress-gate tests remain green; pytest (~351) and vitest (~103) and `make check` are all green; an independent Verifier pass is obtained; a `CODE_REVIEW` judge checkpoint is clean on security-sensitive diffs.
- **Design**: the enriched contract is implemented and client-wired, with a working fallback and a working empty state; all four modes render with the single-draw-call node layer preserved at approximately 1,500 nodes and stress-tested toward 10,000; mode switching preserves selection, filters, expanded-node IDs, camera intent, layout mode, and active hierarchy level across mode switches **and** across the Open-in-Wiki round trip, with no worker cold-restart; per-mode 2D fallback plus accessibility-tree parity is present; TabNav is a conformant nav-plus-links pattern (`aria-current` plus a non-color cue); the generative ramp plus the extended gating contrast test pass in both themes; motion is bounded and interruptible, with a strict reduced-motion path; Terrain-generated assets are enhancement-only with working fallbacks and are labeled as placeholders; the overall-app upgrade extends, rather than replaces, existing tokens. An independent Verifier pass, a Browser Validator pass over all 8 journeys plus the whole-app audit, and a `VISUAL_REVIEW` judge checkpoint are all obtained.

### 9.2 Whole-app audit journeys (Phase 2, Section 6.1)

Across Wiki, Search, Ask, Ingest, Lint, and Settings (the six non-graph views) plus the Graph view itself, in the current merged application, at each of the viewport profiles in Section 9.4: confirm each view loads without error, confirm the deterministic no-native-dialog scan stays clean, and record every broken/incomplete/regressed observation with its exact path or reproduction step for the Phase 3 punch list.

### 9.3 Design-phase browser journeys (8 journeys, from the passed `DESIGN_HANDOFF`)

1. **Four-mode switch with state persistence**: selection, expanded neighbors, filters, search focus, and the framed camera target all survive Cloud to Orbital to Strata to Terrain and back to Cloud, with no refetch, correct re-fit in each geometry, and an `aria-live` announcement on each mode change.
2. **Per-mode transition and reduced motion**: the bounded, interruptible matrix-interpolation transition plus camera re-fit occurs under normal motion; under `prefers-reduced-motion`, the transition is either auto-2D or an instant/cross-fade with no position interpolation.
3. **Per-mode 2D fallback**: Cloud renders a node-link diagram, Orbital renders nested clusters, Strata renders a dendrogram plus a links table, Terrain renders a contour/region map with numeric elevation; state remains intact; WebGL context loss triggers auto-2D plus an announcement.
4. **Per-mode accessibility-tree parity**: Standard is a flat list plus neighbors, Orbital is a tree grouped by community, Strata is a Leiden-hierarchy tree with level and ancestor information, Terrain is a region list with tier and numeric elevation; Enter selects; two `aria-live` regions are present; nothing is communicated by color alone.
5. **Enriched contract and empty state**: community, level, and centrality are consistent across modes; edge weight drives both width/opacity and a numeric readout; a fixture lacking the new per-node fields exercises the "approximate" client fallback; an empty-entity fixture exercises the empty state naming `mythic index-graph` and linking to Ingest.
6. **Performance**: a single draw call for the node layer holds across all four modes at approximately 1,500 nodes and when stress-tested toward 10,000; the interface remains responsive; transitions stay bounded.
7. **Overall-app journey**: TabNav is nav-plus-links across all seven views with `aria-current` plus a non-color cue; Cmd+K opens, accepts typed input, supports arrow-key navigation and Enter to navigate, closes correctly, and has defined empty/no-results/keyboard states, reachable via a visible header button; a first-class reading/detail pane appears in Wiki, Search, Ask, and Graph with loading/empty/error/populated states; the theme toggle flips `data-theme` and the 3D scene re-reads its colors; focus-plus-context dim is consistent; contrast holds in both themes, including generated ramp members and accent pairings.
8. **Cross-tab persistence**: the Open-in-Wiki round trip and any other tab excursion leave selection, expanded-node IDs, filters, camera intent, layout mode, and active hierarchy level intact, with no physics cold-restart.

### 9.4 `browser_ui_validation` inputs

- **Launch/readiness commands**: backend: `pip install 'mythic-proportion[web]'` (plus `[graphrag]`, `[privacy]`, `[local]` extras for full features), then `mythic serve [--vault PATH] [--host 127.0.0.1] [--port 8765] [--no-browser]`, reaching `http://127.0.0.1:8765/` for the legacy SPA at `/`, and `/app/` for the 3D React app **only after** `cd web && npm install && npm run build` produces `src/mythic_proportion/web/static_next`. Frontend dev: `cd web && npm run dev` (Vite), reaching `http://localhost:5173/app/` (confirm the exact port from the Vite startup output at launch time); the dev server needs the backend reachable for live `/api` calls. Readiness is defined as: the dev or prod URL serves, and the Graph route mounts with a settled graph (the worker's "end" event has been reached). `make check` runs ruff, mypy, and pytest.
- **Base URL**: `http://127.0.0.1:8765/` (served build, `/app/`) and the printed Vite dev URL (expected near `http://localhost:5173/app/`).
- **Fixture/reset procedure**: the `?syntheticGraph=N` route parameter (via `syntheticGraphSizeFromLocation`/`generateSyntheticGraph`) for deterministic ~1,500-node and stress-toward-10,000-node graphs without a live backend; an enriched `/api/graph` fixture carrying `community`/`level`/`centrality`/`weight`; a variant fixture lacking the per-node fields, to exercise the client union-find fallback; an empty-entity fixture, to exercise the `mythic index-graph` empty state. For real data, run `mythic index-graph` against a demo vault. Reset between journeys by reloading the route (state is owner-scoped). The LLM path is mocked in automated tests; real extraction needs either `AUTHHUB_API_KEY` at `localhost:3000` (spends credits, so keep usage minimal) or the local Ollama provider.
- **User journeys**: the 8 journeys in Section 9.3, plus the whole-app audit journeys in Section 9.2.
- **Viewport profiles**: desktop (~1440px), tablet (~834px), narrow (~375px), plus 400% zoom / 320px reflow; each combination is checked in both light and dark `data-theme`.
- **Deterministic checks**: a static no-native-dialog source scan of `web/src` (`alert(`, `confirm(`, `prompt(`, `window.alert|confirm|prompt`, `onbeforeunload`, `beforeunload`; must return zero matches); a runtime confirmation check on any confirm/acknowledge/destructive path (for example, a Settings reset or an Ingest cancel action) rendering an app-owned Radix `Dialog`; a modal keyboard/focus verification (Cmd+K plus any confirm/reading-pane modal: focus enters correctly, focus is trapped, Escape restores focus to the invoking element, the visible focus ring is at least 3:1 contrast).
- **Visible outcomes summary**: state persistence across modes and across tab excursions; bounded, interruptible transitions with a strict reduced-motion path; full per-mode 2D and accessibility parity; a conformant TabNav nav-plus-links pattern; zero native dialogs; correct modal focus behavior; the single-draw-call node layer intact; AA contrast plus non-color-cue compliance, including generated ramp members, in both light and dark themes.

### 9.5 Verification gate order

An independent Verifier pass is required first. A Browser Validator pass executing Sections 9.2 and 9.3 is required second. Applicable Codex judge checkpoints (Section 11) run according to their own trigger conditions. Neither writer output nor judge output alone constitutes a completion claim at any phase of this plan.

## 10. Captured user overrides and assumptions

### 10.1 Engineering-writer routing override (approved; capture verbatim)

Route the **first** and **all subsequent** `ENGINEERING_JOB`s for this plan directly to `t2-engineer` (Sonnet) as the sole engineering writer, with **no prior T1 attempt**, to avoid regression and churn on this complex, unfamiliar codebase. `engineering_mode` is **standard**; this is explicitly **not** an extreme-advisory team, and no team authorization applies. All normal downstream gates apply unchanged: an independent Verifier pass, a Browser Validator pass for UI/webview work, applicable Codex judge checkpoints, and T2's own standard rule (two counted deterministic-remediation gate failures then a block for user review). Research, stale-plan, credential, and unavailable-prerequisite failures do not count toward that two-failure threshold.

### 10.2 Design model-tiering override (applied)

Opus is the default design model tier for this plan's design work; Sonnet is used only for genuinely trivial or compact design items; Fable is reserved, used very sparingly, for the single highest-value complex synthesis or a bounded escalation, within the premium-escalation and Fable-reservation discipline of `docs/DESIGN-CONTRACT.md`. This override changes the default design tier only; it does not change the escalation discipline itself. No automatic model ladder was run, and none will be.

### 10.3 Generation tooling (approved)

Atelier MCP (user scope, with ComfyUI built in) plus ComfyUI at `H:\LocalAI` (starting it locally, as needed, is pre-approved). Prefer Flux over SDXL for image generation; use Trellis2 for 3D asset generation.

**Standing tool availability across the whole design workflow.** Atelier (ComfyUI-backed; Flux-over-SDXL for images; Trellis2 for 3D) is a standing, available tool for the entire design workflow, not narrowly scoped to the Knowledge Terrain chrome-asset layer. It may be used wherever and whenever useful by the Design Director, UX Architect, Visual System Designer, Motion Designer, and Asset Art Director for concept art, UI mockups, mood and reference generation, and any design-phase visual exploration across all four graph modes and the overall-app visual upgrade. It is likewise available to the Phase 4a de-risking spike and any design-prototyper work described in Section 6.3. This standing availability also applies to any future Studio or design work in later phases. Starting the ComfyUI server at `H:\LocalAI` locally as needed remains pre-approved.

**Rendering hard boundary, unchanged.** This broadening applies to design-process tooling only, not to what ships in the running application. Using Atelier for design-process exploration, concept art, mockups, and references is unrestricted. Shippable, in-app generated 3D/texture assets remain confined to the O(1)-to-O(tens) chrome/environment/landmark layer (a matcap atlas, an HDRI/skybox, at most 6 Trellis2 landmark GLBs, icons), per Section 6.7. The O(1.5k-to-10k) node/edge layer of every graph mode stays procedural instanced-primitive plus shader plus matcap plus impostor; unique per-node generated meshes are out of scope because they would break the single-draw-call rendering budget. Design-exploration artifacts (concept art, mood boards, mockups) are not shipped into the render hot path, so there is no conflict between the standing tool availability above and this boundary.

Any generated or sample asset shown in a mockup, or shipped in the application, continues to be labeled a placeholder with no fabricated production-readiness claim, whether it originates from the Terrain shipped-asset pass (Section 6.7) or from broader design-process exploration under this section.

### 10.4 Judging (approved; no scope change)

Standard Codex cross-vendor judging applies, per `docs/JUDGE-CONTRACT.md`. No DeepSeek judge integration is designed, scoped, or mentioned anywhere in this plan, as future work or otherwise.

### 10.5 Branch state

Work proceeds on local `main @ 0e5e1c5` (the already-completed merge). No push to `origin`, and no branch deletion, without a separate, explicit, later user approval. `origin/feat/3d-graphrag` remains intact and untouched by this plan.

### 10.6 Safe assumptions (labeled; confirm during execution, not blocking approval)

- The current test baselines are approximately 351 pytest tests and approximately 103 vitest tests, per the coordinator's report; confirm the exact counts at Section 6.0 readiness.
- `static_next` may need to be built before `/app` serves; confirm at Section 6.0 whether it is already committed.
- The two `llm/*.py` `NotImplementedError` occurrences are presumed to be abstract-base placeholders rather than reachable dead code; confirm this during Phase 3, item (d) (Section 6.2).
- The Section 5.3 unresolved design decisions (Strata level depth, the centrality measure driving node size, whether Orbital takes the real Leiden dependency immediately, the new token-family approvals, and the Terrain aggregation formula and hue strategy) are acceptable open items to settle with product and engineering judgment during Phase 4. They are not blockers to approving this plan. No engineer may fabricate a value for any of these; any dimension left unresolved at implementation time must be labeled as such in the code or in the handoff back to Verifier.

### 10.7 User approvals still needed before downstream execution

- Explicit approval of this plan (Section 12), before any `t2-engineer` work begins.
- Separate approval of the new additive token families listed in Section 7, before they are adopted as final (not merely proposed).
- Separate, later, explicit approval of any commit, push, deployment, or pull request; this plan's approval does not cover any of those actions.

## 11. Risks and rollback

| Risk | Mitigation | Rollback/containment |
|---|---|---|
| Four maintained rendering paths increase surface area and regression risk (physics variants, transitions, per-mode fallback, per-mode accessibility parity). | Shared worker/instanced/color architecture across all modes; the Phase 4a spike (Section 6.3) gates feasibility before full build; pytest/vitest stay green at every step; the single-draw-call performance journey is checked at 1,500 and 10,000 nodes. | Modes are additive behind the mode-switch control, defaulting to "cloud" so first paint is unchanged; any single mode can be reverted without touching the others. |
| The enriched `/api/graph` contract could regress the existing graph view or the `/api/query` mode contract. | Backward-compatible additive node fields plus the client's existing union-find fallback; `query/modes.py` mode dispatch is not touched; egress-gate and parity tests stay green. | The client falls back to the existing union-find grouping automatically if the server projection is reverted. |
| Security hardening (CORS/CSRF) could break same-origin dev or prod flows, or the Vite dev proxy. | Scope CORS to the known local origins; verify both the `mythic serve` (:8765) and Vite dev (:5173/app) flows explicitly; a `CODE_REVIEW` judge checkpoint on the diff. | The middleware is additive and removable. |
| The graph state lifecycle fix (mounted-hidden rendering) risks a background canvas continuing to burn frames while hidden. | Pause the render loop and worker ticks when the Graph tab is hidden, or lift state out of the component instead of keeping it mounted-hidden. | Revert to the current conditional-mount behavior (accepting the known state-loss regression) if the hidden-mount approach proves too costly. |
| New token additions could collide with existing semantic status hues or fail contrast requirements. | The gating contrast test (Section 6.5/9.1) covering generated ramp members, chrome pairings, and status non-confusability must pass before shipping more than 8 communities; non-color cues are required everywhere a color distinction is made. | Additive tokens are removable without touching existing token values. |
| Asset generation (Atelier/ComfyUI/Trellis2 on a 12GB GPU) may be slow or produce variable-quality results. | All generated assets are enhancement-only with a procedural or token fallback; Terrain remains fully functional with zero generated assets; hard caps apply on count, size, and VRAM usage (Flux fp8, Trellis2 512-cubed). | Any individual generated asset can be omitted; fallbacks cover all encoded meaning without it. |
| Browser UI dialog-policy regression. | The deterministic no-native-dialog scan is a gate at every phase; an app-owned Radix `Dialog` is required for any confirm/acknowledge path; modal keyboard/focus verification is required wherever a modal is introduced. Current state is clean (Section 3.3). | Not applicable: this is a preventive gate, not a rollback scenario. |

**Stale-plan condition**: this plan becomes stale if the merged-tree commit changes materially, if the current test baselines in Section 3.3/10.6 turn out to differ materially from what execution finds, if the passed `DESIGN_HANDOFF` or its independent review result changes, or if any of the Section 10 overrides is withdrawn. A stale plan requires replanning or explicit reapproval before any further engineering edits continue against it.

## 12. Judge route (selective, advisory unless blocking)

Per `docs/JUDGE-CONTRACT.md`, standard Codex cross-vendor judging applies, unchanged from the default policy. Deterministic failures always dominate any judge opinion; Codex is never treated as implementation or as a substitute for deterministic validation. Respect the standard two/four call caps and the shadow-versus-blocking policy; provenance from any judge finding is treated as ignored/advisory unless the finding is independently evidence-backed. No live smoke calls occur without separate, explicit usage approval.

Expected checkpoints for this plan:

- **`PLAN_DUCK`** on this plan draft (advisory shadow, unless the orchestrator selects blocking mode) before the user approves the plan. One advisory, non-blocking finding from this checkpoint (J-001) has already been folded into this draft: it flagged that `mythic-proportion/HANDOFF.md` operationally contradicts this plan's branch, phase, and push-approval scope. That finding is addressed by the pre-execution note near the top of this document and by the explicit `HANDOFF.md` correction item in Section 6.2.
- **`CODE_REVIEW`** on security-sensitive changes: the CORS/CSRF/upload-cap work (Section 6.2), the enriched-contract data projection (Section 6.4), and anything touching privacy or egress-gate code. Security-flagged work in this plan will trigger cross-vendor judging.
- **`VERIFICATION_CHALLENGE`** on writer completion claims at each phase closeout.
- **`VISUAL_REVIEW`** on the graph UI and the four-mode design implementation (Section 6.5/6.6), at the browser-validation stage.

No DeepSeek judge checkpoint of any kind is scoped, scheduled, or mentioned as future work in this plan.

## 13. Engineering mode and downstream ownership

- **Engineering mode**: standard, per the explicit routing override in Section 10.1 (T2 as the sole engineering writer from the first `ENGINEERING_JOB`, no prior T1 attempt, all standard gates intact). This is not an extreme-advisory-team route.
- **Team authorization**: not applicable to this plan.
- **Downstream owner**: engineering-fleet, and only after explicit user approval of this plan. The approved plan path becomes `ENGINEERING_JOB.approved_plan`.

## 14. Approval gate

This plan's Status line (top of file) now reads **APPROVED. Approved by rob.hasselbach@gmail.com on 2026-07-16. Engineering work (t2-engineer, per Section 10.1's routing override) may now begin.** This plan recommends the work in Sections 6 through 11; it grants no execution authority on its own. Before any `t2-engineer` work begins, the user must explicitly approve this plan as a whole. Separately, before the new additive token families in Section 7 are treated as final, the user must approve that token-family set. Separately again, and later, any commit, push, deployment, or pull request requires its own explicit user approval; none of that authority is granted by approving this plan. Upon approval, Scribe updates this plan's Status line to reflect the approval (date and approving party); that update is now complete, and the orchestrator will pass this exact path as `ENGINEERING_JOB.approved_plan` to the engineering fleet.

# Plan: photo-genie-p3-collections — Phase 3 (P3) Collections Create/Add UI Specification

## 1. Status

**APPROVED — approved by user on 2026-07-18.** No work described in this document has been built. This approval authorizes P3 implementation only; it grants **no** commit, push, pull-request, or deployment authority, each of which remains a separate, later, explicit user approval (Section 17). All four Section 14.3 decisions were resolved by the user at approval: Decision 1 (DESIGN_ROUTE Compact→Standard upgrade) — approved; Decision 2 (duplicate collection-name policy) — resolved to block, case-insensitive, checked against existing manual collection names; Decision 3 (active-collection-filter persistence) — resolved to persist across an app reload/relaunch; Decision 4 (optional drag-and-drop affordance) — resolved to include in P3 scope alongside the mandatory keyboard/menu baseline. T1/T2 implementation may now begin using this exact approved plan as `ENGINEERING_JOB.approved_plan`.

task_id: photo-genie-p3-collections
plan_id: photo-genie-p3-collections

**Target:** `H:\CommandCenter\orchestrator\photo-genie` (Tauri 2 + React 18 + TypeScript + Vite + Zustand + WebGPU; Rust `src-tauri`; Vitest). Windows host. This is a nested Git repository with its own `.git`, branch `main`, `HEAD 4dea8eb`.

### 1.1 Relationship to the parent plan and to P2

This is Phase 3 (P3) of the approved parent plan `docs/plans/photo-genie-audit-and-develop-fixes.md`, Section 7.3 (Library track). Per that parent plan's Section 5 and its Phase 0-1 completion record (Section 16.1), each Phase 2+ phase requires its own separate approval and, for UI-bearing work, its own independent design-review PASS at entry. **P2 (`docs/plans/photo-genie-p2-catalog-backup.md`) is COMPLETE and committed** — `HEAD 4dea8eb` on branch `main`. P3-P7 are **not started**. This document is the P3 entry specification; it does not modify P2 or any earlier phase and does not expand into P4-P7, which keep their existing one-line summaries in the parent plan.

For the record: a pre-existing `handoff.md` claim that "nothing has been committed" is **stale and contradicted** by the current repository state — P2 is committed at `HEAD 4dea8eb` on `main`. This plan proceeds from that current, verified state.

## 2. Summary

P3 delivers in-app **manual collections management** for photo-genie, satisfying PRD requirement **LIB-05** (today only partially met — collections are read-only in the UI) and gap-analysis finding **R14** ("Collections — create/add-to UI"). The user will be able to create a named manual collection, add one or more selected images to a collection, remove images from a collection, rename a collection, delete a collection (with an app-owned confirmation, never a native dialog), and click a collection in the sidebar to filter the library grid to its members with a clear return path to All Photographs. All mutations persist across an app reload. Smart collections continue to display read-only and are not broken; smart-collection rule authoring remains out of scope (deferred to P7, R8/LIB-06).

### 2.1 Flagged deviation from the parent plan's P3 pre-classification (stated prominently, not silently applied)

The parent plan's one-line P3 pre-classification (parent plan Section 7.3, Library track) reads: `P3 — Collections create/add UI (R14; DESIGN_ROUTE: Compact — brownfield addition, backend already ready)`. The fully elaborated P3 scope specified in this document is materially larger than that one-line classification anticipated, and this plan therefore classifies P3 as **DESIGN_ROUTE: Standard** instead of Compact. The grounded reasons, developed during this planning pass:

- P3 is a new user-flow change spanning **three surfaces**: the LeftPanel sidebar, the LibraryGrid, and new modals.
- It introduces a **net-new multi-select interaction model** — the app is single-select only today (`selectedLibraryImageId: number | null`, `LibraryGrid.tsx:249` `aria-multiselectable="false"`, every grid cell `tabIndex={-1}`).
- It adds an **add-to-collection affordance where none exists today** — there is no context menu, no selection-toolbar action, and no drag-and-drop anywhere in `src/` (grep-confirmed).
- It adds **collection-as-active-filter navigation**, a net-new store field and grid-filter behavior.
- It adds a **destructive delete** requiring an app-owned confirmation modal, distinct from any existing dialog pattern in the repository.
- It spans many net-new component states: create form idle/validating/duplicate-error/submitting/error; inline rename idle/editing/duplicate-error/submitting; delete-confirm; add-to-collection target/success/duplicate; collection-selected filter; grid-cell empty/populated/selected/multi-selected/drag-over.

This exceeds "bounded brownfield UI" (Compact) and matches the Standard profile's own trigger ("new screen, multi-state component, or user-flow change"). This mirrors P2's own Compact→Standard upgrade at phase entry (P2 plan Section 2.1), and is consistent with the parent plan's own mechanism (Section 5) of confirming each phase's design route at that phase's entry against its actual, fully elaborated requirements, not against the parent plan's one-line pre-classification. **This deviation was Decision 1 at approval and has been approved by the user** (Section 14.3, Decision 1, resolved), exactly as P2's Compact→Standard upgrade was Decision 1 in that plan.

## 3. Outcome and audience

**Audience:** the user approving this P3 specification, and the engineering fleet (T1 first-line, T2 on escalation) that executes it after approval, with independent Verifier and Browser Validator (tauri-driver native backend) gates on the resulting work.

**Observable result:** photo-genie gains in-app manual collections management. The user can:

- create a named manual collection;
- add one or multiple selected images to a collection;
- remove images from a collection;
- rename a collection;
- delete a collection, with an app-owned confirmation;
- click a collection in the sidebar to filter the library grid to its members, with a clear return to All Photographs;
- rely on every mutation persisting across an app reload.

This satisfies PRD **LIB-05** and gap-analysis **R14**. Smart collections remain read-only and unbroken.

## 4. Scope and non-goals

### 4.1 In scope

1. Manual collection CRUD: create, rename, delete.
2. Collection membership: add images to a collection, remove images from a collection.
3. Collection-as-filter navigation: click a manual or smart collection to filter the library grid to its members, with a return path to All Photographs.
4. A net-new grid multi-select model, used as the selection basis for add-to-collection.
5. The primary add-to-collection affordance: context menu plus a selection toolbar, with a full non-pointer keyboard equivalent.
6. A secondary drag-and-drop affordance, **included in P3 scope** (Section 14.3, Decision 4, resolved). The keyboard/menu baseline (item 5) remains the primary, required equivalent per the design review's accessibility requirement, and is delivered regardless of whether drag-and-drop is used.

### 4.2 Non-goals

- **Smart-collection rule creation or editing** — reserved for P7 (R8/LIB-06). Smart collections remain read-only in P3, are visibly marked, and their Rename/Delete/Add/Remove controls are **omitted**, not disabled.
- **Quick Collection / Target Collection** one-key gathering — a distinct P1 item. The existing inert Catalog-tab placeholder (`LeftPanel.tsx:145-147`) is left untouched; the P3 information architecture must not preclude it.
- **Collection Sets / nested hierarchy** — the backend already models `kind='set'` / `parent_id`, but P3 keeps the manual list flat. **Canonical predicate (binding, PLAN_DUCK finding J-P3-001):** manual rows are exactly `kind === 'manual'`; smart rows are exactly `kind === 'smart'`; `kind === 'set'` rows render in **neither** list in P3 and must never surface as manual or as smart. This single predicate is used consistently everywhere the plan distinguishes manual, smart, and set rows (Sections 5, 7.1, 9.4, 12.2, and every acceptance journey below).
- **Cloud/mobile sync.**
- **Batch-applying culling/rating/color-label keys** (P/X/U/0-9) across a multi-selection — deferred past P3; those keys stay anchor-scoped in P3.
- **No engineering starts from this document.** This is a specification pending explicit user approval; approving it authorizes P3 implementation only.
- **No schema change.** The `collections` and `collection_images` tables already exist (`schema.rs:237-259`); `CURRENT_VERSION` is unchanged.
- **No commit, push, pull request, or deployment.**
- **Preserve the Tauri 2 + React 18 + WebGPU architecture** and existing conventions, including the single `Mutex<Connection>`, WAL mode, the zero-IPC slider loop, and the linear working space invariants carried from the parent plan.

## 5. Repository findings — evidence baseline

The following is grounded, read-only evidence verified during planning. Every file:line reference below is cited verbatim from the planning evidence and governs the ordered work in Section 9.

- **Backend present, reuse as-is:** Tauri commands `get_collections()` (`lib.rs:972`, registered `:1676`), `create_collection(name, kind)` (`lib.rs:1556`, registered `:1708` — the command layer exposes `name`+`kind` only; `parent_id`/`rule_json` are not exposed, which is fine for P3 manual collections: `parent_id` NULL, `rule_json` NULL), `add_image_to_collection(collection_id, image_id)` (`lib.rs:1574`, registered `:1709`). `CatalogDb` methods: `get_collections` returns `image_count` via `COUNT(ci.image_id) LEFT JOIN` (`mod.rs:1093-1100`); `create_collection(name, kind, parent_id, rule_json)` (`mod.rs:1120`); `add_image_to_collection` uses `INSERT OR IGNORE` — idempotent, so redundant adds are safe no-ops (`mod.rs:1129-1133`); `evaluate_smart_collection` (`mod.rs:1189`); `collection_images` delete logic already exists (`mod.rs:1230-1236`). List-images-by-collection is fully wired frontend-to-command-to-database via `ImageFilter.collection_id`, a subquery `i.id IN (SELECT image_id FROM collection_images WHERE collection_id = ?)` (`mod.rs:497-501`; `client.ts:200`; `types.ts:184`) — the collection-filter journey (J11) needs **no new backend**.
- **Backend missing, net-new:** `delete_collection` (must clean up `collection_images` membership rows; manual collections only), `remove_image_from_collection`, and `rename_collection`/`update_collection`. Each requires a `CatalogDb` method, a Tauri command, a devbridge route, and a Rust unit test following the `mod.rs:1491` `test_collection_create_and_add_image` pattern. Confirmed absent repo-wide.
- **Schema, no change needed:** `collections(id, name, kind CHECK manual|smart|set, parent_id, rule_json, created_at, modified_at)` and `collection_images(collection_id, image_id, sort_order, added_at)` already exist (`schema.rs:237-259`).
- **Frontend today:** collections DO load into the Zustand store on mount (`App.tsx:263` `getCollections()` → `setCollections`; `mapCatalogCollection` maps `image_count` → `imageCount` and `kind === 'smart'` → `smart`, `App.tsx:68-77`); `reloadCatalogNav` re-fetch precedent at `App.tsx:290-304`. The Collections tab renders them (`LeftPanel.tsx:165-184`), but `CollectionItem` is **inert** — a static row with no `onClick` and no filter behavior (`LeftPanel.tsx:79-87`). `client.createCollection` (`client.ts:277`) and `client.addImageToCollection` (`client.ts:285`) exist but have **zero callers** — there is no in-app create or add path today.
- **Model-shape seam — RESOLVED by a canonical numeric-id data-model decision (PLAN_DUCK finding J-P3-003; supersedes design-review Finding 3's "name it as an invariant" framing):** there are three divergent `Collection` shapes today — Rust `models.rs` (`id`, `name`, `kind`, `parent_id`, `rule_json`, `created_at`, `modified_at`, `image_count`, `children`); TS `catalog/types.ts:156-164` (`id: number`, `kind`, `smart_filter`, `image_count`, no `modified_at`); Zustand `useAppStore.ts:40-45` (`id: string`, `name`, `smart: boolean`, `imageCount`). These are bridged only by `mapCatalogCollection` (`App.tsx:68-76`), invoked today via an `as never` cast that bypasses type-checking and collapses `kind === 'set'` into "not smart" — which would render a `kind='set'` row as manual under the old `kind !== 'smart'` predicate (corrected above to `kind === 'manual'`). `activeCollectionId` is numeric for `ImageFilter.collection_id`, while store collection ids are strings today. **Canonical identity (binding):** a collection's identity is a numeric integer id end to end — SQLite primary key / Rust `i64` / TypeScript `number` — matching `catalog/types.ts`'s already-numeric `Collection.id` and `ImageFilter.collection_id`. The Zustand store's current `Collection.id: string` is a legacy display-only coercion and is the sole source of this seam. **Resolution (binding for engineering, Track B):** normalize the store so `Collection.id` is `number`, not `string`; remove the `as never` cast at `mapCatalogCollection`'s call sites (`App.tsx:264`/`:297`) so the mapping is genuinely type-checked; `mapCatalogCollection` is the single conversion boundary and passes the catalog's numeric id straight through with no string coercion. This closes the seam by data-model decision; it is not deferred to implementation-time judgment.
- **Selection model today is single-only:** store `selectedLibraryImageId: number | null` (`useAppStore.ts:95`), `selectedImageIndex` (`:102`); no selected-ids array. `LibraryGrid` `role="listbox"` `aria-multiselectable="false"` (`LibraryGrid.tsx:249`); `GridCell` `onClick = onSelect(single id)` (`:77`); every cell `tabIndex={-1}` (`:78`, no cell is ever in Tab order today). Keyboard culling/rating/arrows are handled on the window (`:143-218`). There is no context menu (`onContextMenu` absent), no toolbar action on selection, and no drag-and-drop anywhere in `src/` (`draggable`/`onDrop`/`DataTransfer` absent, grep-confirmed). No `ctrlKey`/`metaKey` handling exists anywhere (Ctrl/Cmd-click, Ctrl/Cmd+A, Shift+Arrow are all collision-free, grep-confirmed).
- **Modal pattern to reuse:** `src/components/backup/useModalA11y.ts` (`:48-100`) — initial focus via `initialFocusRef`, Tab/Shift+Tab focus trap, optional Escape via `onEscape`, focus-return on cleanup. Do **not** reuse `ImportDialog.tsx:132`'s weaker pattern (`role`/`aria-modal` but no Escape, no focus trap). The reusable P2 `.pg-*` dialog kit is `src/components/backup/backup-ui.css` (additive over `#1c1c1e`/`#111`/`#4b7bec`, no shipped hex/class modified, header comment `:1-4`); `.pg-btn--destructive` (`backup-ui.css:139`, bg `#5a2020`/border `#7a3030`/text `#fdd`); `RestoreDialog.tsx:188-193` shows the Cancel-first/destructive-second footer precedent.
- **Keyboard guards:** the single-letter-shortcut suppressor at `App.tsx:343-350` (reads `showImportDialog || showBackupSettingsDialog || showRestoreDialog || showIntegrityFailureAlert || showExitBackupPrompt`) and a second guard at `LibraryGrid.tsx:148`. Every new modal boolean must be added to **both**; the transient context-menu-open state must also suppress shortcuts.
- **Native dialog scan:** 0 real native-dialog calls repo-wide today (only comments/test descriptions). Must stay 0.
- **Filter bar:** `FilterBar` renders `role="search"` `aria-label="Library filters"` (`FilterBar.tsx:71`; `FilterBar.css:1-10`, min-height 34px) and is the only header strip above `LibraryGrid`.

## 6. Research evidence and disposition

No external/web research was required for P3: the SQLite schema is already built, and the relevant conventions are already documented in-repo. This section records the in-repo evidence a nested read-only repository recon consumed directly in the planning chain.

- **Lightroom-parity and gap-analysis grounding** (`photo-genie/docs/research/lightroom-parity.md`; `photo-genie/docs/research/gap-analysis-2026-07-05.md`): gap-analysis **R14**, "Collections — create/add-to UI" (lines 458-462), specifies a "New Collection" action and "Add to Collection" context-menu items, noting the backend already handles this. Gap-analysis Section 1.2 (lines 73-80) distinguishes manual Collections/Sets (a P0 gap) from Quick/Target Collection (a P1 item) and from smart collections (R8/LIB-06, a separate, later item). The add-to-collection interaction affordance (context menu plus selection toolbar) is grounded in this documented convention rather than invented.
- **Drag-and-drop feasibility:** HTML5 drag-and-drop is a WebView2-supported web standard and needed no dedicated research; it is scoped as an optional secondary affordance (Section 4.1, item 6) precisely because the keyboard/menu baseline must not depend on it.
- **Stale-claim correction:** the pre-existing `handoff.md` claim "nothing committed" is stale and contradicted by the current repository state — P2 is committed at `HEAD 4dea8eb` on branch `main` (Section 1.1).

## 7. Design route, handoff, and review

**DESIGN_ROUTE: Standard** (see Section 2.1 for the deviation rationale from the parent plan's Compact pre-classification). `profile = standard`, `existing_system_mode = extend`, `model_tier = sonnet`, `prototype = forbidden`. Roles run: design-director (lead), ux-architect, visual-system-designer, and an independent design-reviewer. Motion-designer and asset-art-director were deliberately not invoked — justified because P3 introduces no new choreography beyond already-shipped fade/reduced-motion patterns, and uses unicode glyphs only (no new iconography asset work).

### 7.1 Design handoff

A full `DESIGN_HANDOFF` was delivered and **PASSED** independent design review (Section 7.2). `selected_direction` = **"Extend the existing dark, dense, Lightroom-Classic-parity chrome additively; every new Collections surface is built from already-shipped visual primitives and the P2 `.pg-*` dialog kit plus `useModalA11y`; no new palette, glassmorphism, gradient, or shadow language."**

**Eight journeys with full state vocabularies** are specified (numbered independently of the browser-validation J-numbers used in Section 12):

1. **create_collection** — `showNewCollectionModal`; states idle / validating / duplicate_name_error (`aria-invalid`, `role="alert"`, Create stays enabled) / submitting / error_backend / success; a live-region announcement; the new row appears with `imageCount 0`; persists via `App.tsx:263`. **Resolved (Section 14.3, Decision 2):** the duplicate-name check is a case-insensitive exact-match comparison against existing **manual** collection names only, performed client-side, and blocks creation (the `duplicate_name_error` state above) rather than allowing or auto-suffixing.
2. **multi_select_then_add_via_context_menu** — a net-new store field `selectedLibraryImageIds: number[]` alongside the retained `selectedLibraryImageId` anchor. Plain click replaces selection and anchor (no regression); Ctrl/Cmd-click toggles; Shift-click selects a range from the anchor; arrow keys collapse to the anchor as today; Shift+Arrow extends; culling/rating keys stay anchor-scoped; `aria-multiselectable` becomes permanently `"true"`; per-cell `aria-selected` reflects the array. Context menu is `role="menu"`/`menuitem`, opened via right-click, the ContextMenu key, or Shift+F10, with its own arrow/Enter/Escape handling and focus-return to the originating cell — or a selection toolbar shown when one or more images are selected. The picker is a checklist of **manual collections only** with a tri-state checkbox per row (checked = all selected images are members / unchecked = none are / indeterminate = some are — this is how partial/duplicate membership is surfaced, never as an error). Toggling calls `add_image_to_collection` (idempotent `INSERT OR IGNORE`) or the new remove path. Success announces a backend-grounded count via the live region; sidebar `imageCount` refreshes via a `get_collections` re-fetch mirroring `App.tsx` `reloadCatalogNav`. `showAddToCollectionPicker`; states empty_no_collections (still offers "New Collection…") / loading / per-row error+retry. A full keyboard-only path is specified.
3. **add_via_new_collection_inline** — "New Collection…" inside the picker swaps the same dialog body to a name sub-view with a Back control, avoiding a nested focus-trap conflict; on success it creates the collection then adds all selected images, announcing both outcomes with explicit partial-failure wording.
4. **remove_images_from_collection** — context menu "Remove from '<name>'", or toolbar, or Delete/Backspace scoped to grid-cell focus plus an active manual (`kind === 'manual'`) filter. This affects **membership only**, never the image or file; it is non-destructive, so no confirmation modal is used. Removed images leave the filtered grid immediately. **Resolved (not an open decision, PLAN_DUCK finding J-P3-002):** removing the last image leaves the collection retained intact-but-empty; it is never auto-deleted. Auto-deleting a collection as a side effect of a non-destructive membership removal would be a surprising destructive action; retention is the safe, coherent default and matches the passed design handoff. Unavailable for smart or set collections. Durable across reload.
5. **rename_collection** — context menu "Rename" or F2 on a focused manual sidebar row; **inline edit-in-place**, not a modal — justified as a single-field, low-risk edit matching Lightroom, and already covered by the existing `tag === 'INPUT'` guard, so no new keyboard-guard boolean is needed. States idle / editing (pre-selected text) / validating / duplicate_name_error (`role="alert"`, commit blocked) / submitting / success / unchanged_noop. Enter commits, Escape reverts. Never available for smart collections. **The duplicate-name check uses the same resolved policy as journey 1 (Section 14.3, Decision 2): case-insensitive exact-match against existing manual collection names, blocking the rename on collision.**
6. **delete_collection** — context menu "Delete…" or Delete/Backspace scoped to **sidebar-row** focus (a distinct focus context from journey 4's grid-cell focus). Must be an app-owned `useModalA11y` modal, never a native confirm; title "Delete Collection?"; body names the collection and its member count and states that member images are untouched. Cancel receives initial focus; the destructive action uses a clearly labeled button (never a bare "OK") via `.pg-btn--destructive` unmodified; Cancel is disabled during the in-flight request. On success the modal closes and focus moves to an **explicit named fallback target** (the All Photographs nav item — design-review Finding 5); the grid falls back to All Photographs if the deleted collection was the active filter. Errors keep the modal open with an inline recoverable message. Never available for smart collections. `showDeleteCollectionConfirm`.
7. **filter_grid_to_collection_and_return** — a new store field `activeCollectionId`; the left-panel tab stays on Collections; a row's `aria-selected` is distinct from keyboard focus; the grid updates via the already-wired `ImageFilter.collection_id` (`mod.rs:497-501`) — no new backend needed. A persistent breadcrumb/"viewing" chip (e.g. "Vacation 2024 · 12 photos") with an explicit "× All Photographs" control renders above the grid. The Catalog tab's "All Photographs" row becomes dynamically active only when `activeCollectionId` is null — a second return path. Smart collections are browsable by filter in P3; only rule authoring is out of scope. **Resolved (Section 14.3, Decision 3):** the active collection filter persists across an app reload/relaunch — `activeCollectionId` is restored from durable storage on launch rather than resetting to All Photographs; membership always persists regardless.
8. **drag_and_drop** (secondary affordance, **included in P3 scope**, Section 14.3 Decision 4 resolved) — the whole current selection drags; drag-over a manual row highlights with a copy cursor; a smart/folder/non-target row shows a not-allowed cursor; drop performs the identical idempotent add as journey 2. The keyboard equivalent (journeys 2-3) remains the primary, required equivalent per the design review's accessibility requirement and ships regardless. A reduced-motion fallback is specified.

**Information architecture:** the Collections tab renders, top to bottom: a "Collections" header plus a new "+ New Collection" button; manual rows (`kind === 'manual'`) with an icon, name, `imageCount` badge, Rename/Delete context actions, and `aria-selected`; a "Smart Collections" header (no "+"); smart rows (`kind === 'smart'`) with a small read-only marker (proposed glyph "⚿", color `#888`) plus `aria-label="Read-only smart collection"` — filter-by-click works, but no Rename/Delete/Add/Remove control ever renders (omitted, not disabled). **`kind === 'set'` rows render in neither list** (Collection Sets remain deferred/out of scope, Section 4.2) and must never surface as manual. The empty state (`CollectionsEmpty`) is reworded to "No collections yet." with the "+ New Collection" action surfaced directly, so it is never a dead end. The Quick Collection placeholder (`LeftPanel.tsx:145-147`) is left untouched.

**Visual system** (all additive; WCAG 2.2 AA verified and independently recomputed by the reviewer): surfaces `#1c1c1e`/`#111`/`#4b7bec` confirmed unchanged; DTCG primitive/semantic/component tokens are scoped to P3. Verified contrasts: text `#c8c8c8` on `#1c1c1e` 10.18:1; `#e0e0e0` 12.91:1; `#4b7bec` focus border 4.34:1 (non-text, > 3:1 threshold); `.pg-btn--destructive` text `#fdd` on `#5a2020` 10.01:1 (fill-vs-panel 1.35:1 flagged as inherited/unmodified, mitigated by the 10:1 text contrast plus label plus fixed position plus rectangular form); inline error `#ee8888` on `#2e1010` 7.11:1; secondary/read-only glyph `#888` 4.81:1 (deliberately not the sub-AA decorative `#555` at 2.29:1); checkbox unchecked border `#666` on picker-row `#16171a` 3.12:1; checked glyph white on `#4b7bec` 3.93:1 plus text-shadow. The only genuinely new tokens are `selection.member` `rgba(255,255,255,0.55)` (the multi-selected outline, distinct from the anchor's existing `.grid-cell--selected` 2px solid white), `gridCell.focusRing` box-shadow `(0 0 0 2px #4b7bec, 0 0 0 4px rgba(0,0,0,0.6))` — a distinct hue/mechanism from selection so focus and selection never conflate — and the glyphs ⚿ / ▸ / ×. The context menu is a net-new pattern (no popover precedent exists, grep-confirmed): `role="menu"` floating panel, bg `#232326`/border `#3a3a3c`/radius ~8px/shadow `0 8px 24px`, items ~26px tall with hover `#2a2a2e`, reusing `.pg-fade-in` (200ms, with the reduced-motion fallback). The selection toolbar and breadcrumb chip render as additional flex children inside the existing `.filter-bar`, with a flex-wrap fallback if they cannot fit at 1440x900 — subject to Finding 2's landmark correction below. The multi-select cell adds `.grid-cell--multi-selected` plus a checkbox badge top-right (top-left is occupied by `.grid-cell__badges`). Inline rename occupies the `.collection-name` slot with no layout shift. The new "+ New Collection" button reuses `.left-panel__import-btn` verbatim. Reduced-motion reuses the shipped fallbacks at `backup-ui.css:232-234` / `274-276`. `forced-colors` support has zero existing handling repo-wide — a disclosed pre-existing gap that P3 must not regress but is not obligated to close.

**Engineering invariants carried from the handoff:** never change any cited hex/class/property value; additive new classes/modifiers only (e.g. `.pg-input--invalid`, `.collection-item--active`, `.grid-cell--multi-selected`); reuse `.pg-modal-*`/`.pg-field`/`.pg-input`/`.pg-btn*` and `.pg-btn--destructive` unmodified; reuse `useModalA11y` for all three new modals; add all three new modal booleans to both keyboard guards plus context-menu-open suppression; `selectedLibraryImageIds: number[]` alongside the unchanged anchor; culling/rating keys stay anchor-scoped; `aria-multiselectable` permanently `"true"` with per-cell `aria-selected`; roving tabindex (exactly one cell `tabIndex={0}` = the anchor, all others `-1`, an explicit `.focus()` call on anchor change, a visible focus outline distinct from selection); one shared `role="status"` `aria-live="polite"` region near `App.tsx:493`; every mutation proven to persist across reload via a `get_collections`/grid re-fetch, not in-memory only; zero native dialogs. Permitted variation: context-menu radius 6-8px, shadow blur/spread ±20%, menu-item height 24-28px, chip padding 2-4px, checkbox glyph 10-14px, drag-ghost opacity 0.5-0.7; F2 rename and Ctrl/Cmd+A are optional; **drag-and-drop ships in P3** (Section 14.3, Decision 4, resolved); all copy strings are placeholders.

### 7.2 Design review

`DESIGN_REVIEW_RESULT = PASS` (independent design-reviewer, sonnet). Every load-bearing file:line fact was independently re-verified and every contrast ratio independently recomputed — all accurate, with no wrong facts and no fabricated evidence found. The browser UI invariant was confirmed honored: delete uses an app-owned `useModalA11y` modal reusing the unmodified `.pg-btn--destructive`; zero native `alert`/`confirm`/`prompt`/`window.*`/`beforeunload` calls exist repo-wide, and none are introduced. The smart-collection scope boundary was confirmed honored: read-only P3 display is consistent with the server-side `evaluate_smart_collection` (`mod.rs:1189`, `1230-1236`); rule editing is correctly deferred to P7.

Five findings were returned, **all folded here as non-blocking implementation-time closures** — no second design pass is required. This plan carries the four bounded closures below as **binding acceptance items** (Section 9, Track D and Track F). Finding 3 has since been fully resolved by a subsequent `PLAN_DUCK` remediation pass (Section 8) and is recorded below as resolved rather than merely flagged.

| Finding | Severity | Category | Binding closure |
|---|---|---|---|
| Finding 2 | Medium | DR-COHERENCE / DR-A11Y | The new selection toolbar and breadcrumb chip must **not** be plain children of the `.filter-bar` node that carries `role="search"` (landmark mismatch, WCAG 1.3.1/4.1.2). Wrap them in a sibling element with its own role (e.g. `role="toolbar"` or `role="group"`) and a distinct `aria-label`. |
| Finding 3 — **RESOLVED** (J-P3-003) | Medium | DR-EVIDENCE / DR-HANDOFF | Originally: name the `mapCatalogCollection` / store (`id: string`) vs. catalog (`id: number`) `Collection`-type seam (`App.tsx:68-76`, the `as never` cast at `:264`/`:297`) as an explicit engineering invariant. **Now resolved by a concrete data-model decision** (Section 5, Section 9.2 Track B, Section 10): collection identity is canonically numeric end to end; the store's `Collection.id` is normalized to `number`; the `as never` cast is removed; `mapCatalogCollection` remains the single, now genuinely type-checked, conversion boundary. `kind === 'set'` rows (`schema.rs:237-241`, `types.ts:19`) stay excluded from the P3 manual/smart flat list under the canonical `kind === 'manual'` / `kind === 'smart'` predicates (Section 4.2) and must never render as manual. `activeCollectionId` is typed `number \| null` and set directly from a collection's numeric id. |
| Finding 4 | Low | DR-A11Y | Re-verify the checkbox border (`#666` on `#16171a`, 3.12:1) and checked-glyph (white on `#4b7bec`, 3.93:1) contrast against **rendered** output, not just token math — both are near the AA threshold. |
| Finding 5 | Low | DR-HANDOFF | The delete-focus-return "exception" must wire an **explicit named fallback focus target** (e.g. the All Photographs nav item) via a manual `.focus()`/ref. `useModalA11y`'s default `.focus()` call on the now-detached row silently no-ops (WCAG 2.4.3). |

(A fifth finding, not itemized in the table, was folded into the general contrast/coherence verification above and produced no additional binding closure beyond Findings 2-5.)

### 7.3 Product decisions the design pass surfaced — status: resolved at approval

Four decisions this design pass surfaced for P3 were owned by the user at this plan's approval and have now been resolved (Section 14.3): the Compact→Standard route deviation itself (Decision 1) — approved; duplicate-collection-name policy (Decision 2) — resolved to block, case-insensitive, against existing manual collection names; whether the active collection filter persists across reload (Decision 3) — resolved to persist; and whether the drag-and-drop affordance ships in P3 (Decision 4) — resolved to include in P3 scope. One further item this design pass surfaced — last-image-removed behavior — was never an open decision: a subsequent `PLAN_DUCK` remediation pass (Section 8, finding J-P3-002) resolved it as retention (design journey 4 above, Section 14.2), because the remove journey and the backend already hard-code retention and treating it as open would have contradicted that.

## 8. Judge route

Consistent with `docs/JUDGE-CONTRACT.md` and with the precedent set in P2, this plan received an orchestrator-run `PLAN_DUCK` checkpoint — advisory, shadow mode — against the prior draft, at the assessed **Medium** risk (multi-select interaction change, a delete-cascade path, and a type seam), not the High rating that applied to P2's data-safety work. A `CODE_REVIEW` checkpoint remains separately recommended on the net-new multi-select/state-model changes (Track B/C) and on the `delete_collection` membership-cleanup path (Track A) as those reach implementation.

### 8.1 PLAN_DUCK disposition (this revision)

The shadow-mode `PLAN_DUCK` pass returned three findings, all now folded into this plan's binding structure. None is dropped or silently reinterpreted.

| Finding | Severity | Remediation in this plan |
|---|---|---|
| J-P3-001 | scope-boundary predicate consistency | The plan previously mixed two predicates for "manual" — `kind === 'set'`-exclusion in some sections and `kind !== 'smart'` (which wrongly includes sets) in Section 7.1's IA and the Track D ordered-work section. Resolved to a single explicit predicate used everywhere: manual rows are `kind === 'manual'`; smart rows are `kind === 'smart'`; `kind === 'set'` rows render in neither list and must never surface as manual (Sections 4.2, 5, 7.1, 9.1, 9.4, 12.2). |
| J-P3-002 | open-decision vs. already-decided contradiction | "Last-image-removed behavior" was listed as a user-owned open decision while the remove journey and backend already hard-coded retention. Resolved as retention (non-destructive membership removal; a collection is retained intact-but-empty and never auto-deleted) and removed from the open-decisions list (Sections 7.1 design journey 4, 7.3, 14.2, 14.3). |
| J-P3-003 | ID data-model contract deferred to implementation time | The plan previously told engineering to "resolve the string/number id seam deliberately" at implementation time. Resolved now as a concrete, binding, canonical-numeric-id contract: collection identity is numeric end to end (SQLite PK / Rust `i64` / TS `number`); the store's `Collection.id` is normalized to `number`; the `as never` cast at `mapCatalogCollection`'s call sites is removed; `mapCatalogCollection` is the single, now type-checked, conversion boundary (Sections 5, 9.2 Track B, 10, 11, 13). |

Deterministic build, test, Verifier, and Browser Validator gates always dominate any judge opinion; Codex is never implementation and never a substitute for those required gates; the contract's call caps and shadow-vs-blocking policy are respected; no live smoke calls occur without a separate, explicit usage approval. This disposition applies only to the three findings above; it does not otherwise alter Section 4.1's directed scope or expand P3 beyond it.

## 9. Ordered work

No step in any track begins before explicit user approval of this plan (Section 17).

### 9.1 Track A — Backend mutation commands (foundational; blocks the delete/remove/rename journeys)

Implement three net-new `CatalogDb` methods, each exposed as a Tauri command (registered in `invoke_handler`) and a devbridge route, following the existing thin-wrapper pattern:

- `delete_collection(collection_id)` — manual collections only; deletes `collection_images` membership rows, then the `collections` row, transactionally.
- `remove_image_from_collection(collection_id, image_id)`.
- `rename_collection`/`update_collection(collection_id, new_name)`.

`create_collection`, `add_image_to_collection`, `get_collections`, and the `collection_id` grid filter are reused as-is with no changes.

**Acceptance:**
- Each new operation has a deterministic Rust unit test, following the `mod.rs:1491` `test_collection_create_and_add_image` pattern, proving create/add/remove/rename/delete round-trip correctly.
- Deleting a collection removes its membership rows without orphaning any `collection_images` rows.
- These new mutation paths (`delete_collection`, `remove_image_from_collection`, `rename_collection`) accept `kind === 'manual'` collections only; smart (`kind === 'smart'`) and set (`kind === 'set'`) collections cannot be renamed, deleted, or otherwise mutated via them — guarded by `kind`.

### 9.2 Track B — Frontend state model and client wrappers

**Canonical ID contract (binding, resolves `PLAN_DUCK` finding J-P3-003; supersedes the prior "resolve deliberately" framing):** normalize the Zustand store's `Collection.id` from `string` to `number`, matching the catalog's already-numeric `Collection.id` and `ImageFilter.collection_id`. Remove the `as never` cast at `mapCatalogCollection`'s call sites (`App.tsx:264`/`:297`) so the mapping is genuinely type-checked. `mapCatalogCollection` (`App.tsx:68-76`) is the single conversion boundary and passes the catalog's numeric id straight through with no string coercion. `activeCollectionId` is typed `number | null` in the store and is set directly from a collection's numeric id; **resolved (Section 14.3, Decision 3):** `activeCollectionId` is persisted to durable storage (not Zustand in-memory state alone) and restored on app launch/reload, so the active collection filter survives a reload rather than resetting to All Photographs; the grid filter continues to use the existing `ImageFilter { collection_id?: number }` command input unchanged — no new backend for the filter path. All new mutation client wrappers (`deleteCollection`, `removeImageFromCollection`, `renameCollection`) and the reused `createCollection`/`addImageToCollection` take a numeric `collection_id`; there are no `parseInt`/`String()` conversions at call sites, and any conversion exists only inside `mapCatalogCollection`.

Add store fields `selectedLibraryImageIds: number[]` (retaining the `selectedLibraryImageId` anchor) and `activeCollectionId: number | null` per the contract above; add booleans `showNewCollectionModal`, `showAddToCollectionPicker`, `showDeleteCollectionConfirm`; add all three to **both** keyboard guards (`App.tsx:343-350`, `LibraryGrid.tsx:148`) plus context-menu-open suppression. Add TS client wrappers `deleteCollection`, `removeImageFromCollection`, `renameCollection`, mirroring `client.ts:277-294`. Exclude `kind === 'set'` from the manual/smart split per the canonical predicate (Section 4.2).

**Acceptance:**
- A store unit test for multi-select set operations (add/toggle/range) and anchor retention across selection changes.
- `npm run build` (`tsc -b`) passes with the `as never` cast removed — i.e. the numeric-id normalization type-checks cleanly, proving the seam is closed rather than masked.

### 9.3 Track C — Multi-select grid interaction

Implement plain click, Ctrl/Cmd-click, Shift-click, and Shift+Arrow selection; `aria-multiselectable="true"`; per-cell `aria-selected` driven from the selection array; roving tabindex (anchor `tabIndex={0}` plus an explicit `.focus()` call on anchor change); `.grid-cell--multi-selected` plus a checkbox badge plus a distinct focus ring. Culling, rating, and arrow-key navigation remain anchor-scoped with no regression.

**Acceptance:**
- Journey J3 (Section 12) passes.
- A protected-behavior check confirms single-select culling, rating, and develop routing are unregressed by the new multi-select code paths.

### 9.4 Track D — Collections sidebar CRUD and navigation

Add a "+ New Collection" button and New Collection modal (`useModalA11y`); a net-new context menu (`role="menu"`) with Rename/Delete for `kind === 'manual'` rows only (never for `kind === 'smart'` or `kind === 'set'` rows); inline rename (F2 or context menu, using the existing `tag === 'INPUT'` guard); a collection click that sets `activeCollectionId` (numeric) and filters the grid via `ImageFilter.collection_id`; per Decision 3 (Section 14.3, resolved), `activeCollectionId` is written to durable storage and restored on app launch so the active filter survives a reload; a breadcrumb chip plus an All Photographs return (both return paths); smart (`kind === 'smart'`) rows shown read-only with the ⚿ marker and `aria-label`; `kind === 'set'` rows rendered in neither list; the `CollectionsEmpty` rework. Wrap the selection toolbar and breadcrumb chip in a non-`search`-landmark sibling per Finding 2.

**Acceptance:** journeys J1, J2, J9, J11, J12 (Section 12) pass.

### 9.5 Track E — Add/remove membership

Implement the context-menu and selection-toolbar "Add to Collection" tri-state-checkbox picker (idempotent adds), the "New Collection…" inline body-swap, remove-from-collection (membership only, non-destructive), the shared `role="status"` `aria-live` announcements, and `imageCount` refetch after every mutation.

**Acceptance:** journeys J4, J5, J6, J7, J8 (Section 12) pass.

### 9.6 Track F — Delete confirmation modal

Build an app-owned `useModalA11y` modal reusing `.pg-btn--destructive` unmodified; Cancel receives initial focus and is disabled while the request is in flight; an explicit named fallback focus target is wired for the post-delete focus-return case (Finding 5); the grid falls back to All Photographs if the deleted collection was the active filter.

**Acceptance:** journey J10 (Section 12) passes, verifying `document.activeElement` lands on Cancel at open, the Tab trap cycles only between Cancel and Delete, Escape aborts with no deletion, member images remain intact, and the post-delete fallback focus lands on a real, verifiable element.

### 9.7 Track G — Drag-and-drop secondary affordance

Included in P3 scope, resolved at approval (Section 14.3, Decision 4). The keyboard/menu baseline (Tracks C and E) remains the primary, required equivalent per the design review's accessibility requirement and is delivered regardless of this track. Includes a reduced-motion fallback.

**Acceptance:** journey J15 (Section 12).

### 9.8 Track H — Design-review closures and quality gate

Implement Findings 2-5 (Section 7.2) as binding closures; re-verify Finding 4's contrast ratios in rendered output, not just token math; keep the deterministic no-native-dialog scan at 0; `npm run build` (`tsc -b && vite build`) green; `vitest` green, including a new collections frontend test (none exists today) and the Track A Rust unit tests.

## 10. Interfaces and data

- **New Rust Tauri commands** (plus matching devbridge routes and TS client wrappers): `delete_collection(collection_id)` → result; `remove_image_from_collection(collection_id, image_id)` → result; `rename_collection(collection_id, new_name)` → result. **Reused unchanged:** `get_collections`, `create_collection`, `add_image_to_collection`, `get_catalog_images(ImageFilter with collection_id)`.
- **No schema/migration change** — `collections` and `collection_images` already exist (`schema.rs:237-259`); `CURRENT_VERSION` is unchanged.
- **Canonical collection-identity contract (binding, resolves `PLAN_DUCK` finding J-P3-003):** a collection's identity is a numeric integer id end to end — SQLite primary key / Rust `i64` / TypeScript `number` — matching `catalog/types.ts`'s already-numeric `Collection.id` and `ImageFilter.collection_id`. The Zustand store's `Collection.id` is normalized to `number` (no longer `string`); the `as never` cast at `mapCatalogCollection`'s call sites (`App.tsx:264`/`:297`) is removed; `mapCatalogCollection` (`App.tsx:68-76`) is the single conversion boundary and passes the catalog's numeric id straight through with no string coercion. `activeCollectionId` is `number | null`, set directly from a collection's numeric id. The new mutation client wrappers and the reused `createCollection`/`addImageToCollection` all take a numeric `collection_id`; no `parseInt`/`String()` conversions exist at call sites.
- **New store fields/booleans** (Track B). New CSS classes are additive only; no shipped hex/class is modified. `kind === 'set'` is excluded from the P3 manual/smart split under the canonical predicates (Section 4.2): manual is `kind === 'manual'`, smart is `kind === 'smart'`.
- **Compatibility:** preserve the single `Mutex<Connection>`, WAL mode, the zero-IPC slider loop, and the linear working space invariants carried from the parent plan; keep `cargo build` green and `npm run build` green; do not regress single-select culling, rating, or develop routing, or any of the nine protected develop groups referenced by the parent plan.

## 11. Acceptance and validation

- `npm run build` (`tsc -b && vite build`) passes, **with the `mapCatalogCollection` `as never` cast removed** (Section 5, Section 9.2 Track B) — the numeric-id normalization must type-check cleanly, proving the store/catalog id seam is closed rather than masked.
- `vitest run` passes, including a new collections frontend test and the new Track A Rust unit tests.
- The deterministic no-native-dialog scan (grep `src/` for `alert(`/`confirm(`/`prompt(`/`window.alert|confirm|prompt`/`beforeunload`) stays at 0.
- An independent, read-only **Verifier PASS is required** before completion is claimed — writer or judge evidence alone is never sufficient.
- A **Browser Validator PASS via the tauri-driver native backend is required** for this rendered-UI work (Section 12).
- All mutations must be proven to persist across an app reload (via `get_collections`/grid re-fetch), not merely in-memory.
- The active collection filter (`activeCollectionId`) must be proven to persist across an app reload/relaunch (Section 14.3, Decision 3, resolved), restoring the same filter rather than resetting to All Photographs.

## 12. Browser UI dialog policy and validation

### 12.1 Dialog policy (required)

Native Tauri/WebView2 desktop target. Prohibited: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`. Every acknowledgement or confirmation is an app-owned accessible modal (reusing `useModalA11y`) or inline validation. The delete-collection confirmation specifically is an app-owned modal with a clearly labeled destructive button (never a native confirm) and Cancel carrying initial focus. The deterministic no-native-dialog scan of `src/` must stay at 0. Modal keyboard/focus verification is required for all three new modals (New Collection, Add-to-Collection picker, Delete Collection).

### 12.2 Browser UI validation (required)

Reuses the P2/session tauri-driver infrastructure, already authorized and working; this plan does not re-litigate that infrastructure.

- **Launch/readiness:** `npm run dev` runs `scripts/dev-server.js`, a wrapper with dynamic free-port detection (default port 1420) that launches `tauri dev` with an inline `--config` JSON override; it does **not** mutate `tauri.conf.json` on disk. For plain-browser catalog images, also run devbridge: `cd photo-genie && cargo run --manifest-path src-tauri/Cargo.toml --bin devbridge --features devbridge` (Axum on `http://localhost:7777`; the process CWD must stay the project root, since devbridge resolves `photo-genie.pgcat` relative to its own CWD — use `--manifest-path`, not a `cd` into `src-tauri`).
- **Backend and target surface:** tauri-driver, the selected backend for this native Tauri/WebView2 desktop target (one backend per `target_surface`, not an added fallback rung) — tauri-driver 2.0.6 plus msedgedriver matched to the host WebView2 Runtime. WebDriver capabilities **must** be sent as `{"capabilities":{"alwaysMatch":{"tauri:options":{"application":"<path>"}}}}` using `alwaysMatch`; `firstMatch` is silently ignored by tauri-driver 2.0.6 and launches an unrelated blank window while reporting success. Target-bound identity verification (specificity floor plus PID/process cross-check), fresh-run provenance, and fail-closed behavior on ambiguity are all required. Reference `photo-genie/test-assets/TAURI-DRIVER-SETUP.md`.
- **Base URL:** for the browser target, the Vite dev server (dynamic port via the wrapper, conventionally 1420); for the native target, the Tauri window driven by tauri-driver.
- **Viewport profiles:** 1440x900 (matches `tauri.conf.json` window dimensions) and 1920x1080 — both required.
- **Fixture/reset:** reuse `photo-genie/test-assets/SEED-PROCEDURE.md` — generate deterministic fixtures (`node scripts/generate-fixtures.mjs --generate`), seed via devbridge import-folder (`node scripts/seed-catalog.mjs --seed`; pinned nonzero IDs in `SEEDED-IMAGE-IDS.json`). The P3 fixture additionally requires: at least one manual collection with members; one manual collection with 0 members; one smart collection (`kind='smart'`) from a `.lrcat` import (`gen_lrcat_fixture` path); and more than 20 images to exercise multi-select and virtualization. Reset is clean (`node scripts/seed-catalog.mjs --clean` deletes `.pgcat` plus `-wal`/`-shm` and `.pgcache`) then reseed; a restore/replace-catalog journey needs the full stop-clean-restart-seed cycle. Hand the Browser Validator a copy-pasteable sequence.
- **User journeys with visible outcomes:**
  - **J1** — create happy path: row appears with `imageCount 0`, live-region announces, persists across reload.
  - **J2** — create with a duplicate/empty name: inline `role="alert"`, Create stays actionable, focus stays put, no backend call, no new row.
  - **J3** — multi-select: click / Shift-click range / Ctrl-Cmd-click toggle; the anchor's `.grid-cell--selected` is visually distinct from `.grid-cell--multi-selected`; `aria-selected` matches the selection set.
  - **J4** — add multiple images via the context menu: live-region reports the correct count, sidebar `imageCount` reflects the true backend delta, persists across reload, the filtered view shows exactly those images.
  - **J5** — add a duplicate membership: the row is already checked when the picker opens, no double-count occurs.
  - **J6** — create-and-add via the picker's "New Collection…": the dialog body swaps in place, no second overlay appears, Back returns to the checklist without closing the picker.
  - **J7** — keyboard-only add: Tab into the grid, Shift+Arrow to build a selection, ContextMenu key or Shift+F10 to open the menu, Enter/arrows/Space/Enter to complete — identical end state to J4; the selection-toolbar button is also Tab+Enter reachable.
  - **J8** — remove images: they leave the filtered grid immediately, live-region announces, sidebar `imageCount` decreases, images remain visible in All Photographs.
  - **J9** — rename: label becomes a pre-selected input, commit updates in place with no truncation at either viewport, persists across reload; Escape restores the original name with no backend call.
  - **J10** — delete: modal opens with `document.activeElement` on Cancel, Tab cycles only between Cancel and Delete, Escape aborts with no deletion, confirming removes the row and falls back to All Photographs if it was the active filter, member images remain, and post-delete focus lands on a real, verifiable fallback element.
  - **J11** — filter and return: the grid shows only members; the breadcrumb chip's "×" returns to All Photographs; also test the Catalog-tab All Photographs row as the alternate return path; **reload/relaunch the app while a collection filter is active and confirm the same filter is restored (Section 14.3, Decision 3, resolved), not reset to All Photographs.**
  - **J12** — smart-collection read-only guard (applies to `kind === 'smart'` rows; `kind === 'set'` rows are separately confirmed to render in neither the manual nor the smart list, Section 4.2): filtering works; right-click shows no Rename/Delete items (omitted, not disabled); a smart collection is never a valid add/remove target or source.
  - **J13** — modal keyboard/focus for all three new modals: Tab never escapes the trap, Escape closes without side effects, focus returns to a sensible, verifiable element.
  - **J14** — reduced motion (OS `prefers-reduced-motion`): repeat J1, J4, J10, and a context-menu open; confirm no animated fade/slide occurs.
  - **J15** (in scope for P3, Section 14.3 Decision 4 resolved) — drag over a valid then an invalid target, drop success, Escape mid-drag cancel.
  - **Cross-viewport:** repeat J1, J3, J4, J9, J10, J11 at both 1440x900 and 1920x1080 — no truncation, overlap, or reflow; verify the `.filter-bar` flex-wrap fallback.
- **Deterministic no-native-dialog scan** on all new Collections code paths, with special attention to the Delete confirmation as the highest-risk accidental-native-confirm candidate; the baseline of 0 must remain 0.

## 13. Risks and rollback

**Medium risk.** A net-new multi-select interaction model over a single-select codebase and a delete-cascade path each carry real correctness and accessibility consequences, but none carries the data-durability stakes of P2's backup/restore work. The store/catalog id-type seam, previously an open risk, is now closed by the binding canonical-numeric-id contract (Sections 5, 9.2, 10); the residual risk is implementation fidelity to that contract, not an unresolved design question.

| Risk | Mitigation |
|---|---|
| Multi-select regression over a single-select codebase | Retain the anchor; keep culling, rating, and arrow-key navigation anchor-scoped; add a protected-behavior test; each track is independently revertable. |
| Id-model normalization (store `Collection.id` changes from `string` to `number`; the `as never` cast is removed; `kind === 'set'` must stay excluded from the manual/smart split) | Follow the binding canonical-numeric-id contract exactly (Sections 5, 9.2 Track B, 10); `npm run build` (`tsc -b`) must pass with the cast removed, proving the seam is closed rather than masked (Section 11). |
| Delete-cascade integrity (orphaned `collection_images` rows, or deleting a smart or set collection) | Transactional membership cleanup, a `kind === 'manual'`-only guard, and a dedicated Rust unit test (Track A). |
| Context-menu accessibility (a net-new UI pattern) | `role="menu"`/`menuitem` keyboard model, focus-return, keyboard-guard suppression, and the keyboard-only journey J7. |
| Drag-and-drop accessibility | The keyboard/menu baseline is mandatory and primary; drag-and-drop is a secondary affordance, now in scope for P3 (Section 14.3, Decision 4, resolved). |
| `forced-colors` pre-existing gap | Disclosed; P3 must not regress it further but is not obligated to close it. |
| Stale-plan condition | This plan becomes stale if photo-genie `HEAD` (`4dea8eb`) changes materially, if the collections schema or existing commands change before execution, or if any assumption or decision below is withdrawn; a stale plan requires re-planning or explicit re-approval. |

**Rollback/containment:** additive-only, no schema change, no commit/push occurs without separate explicit approval; standard Git revert within `photo-genie`; each track is independently revertable.

## 14. Assumptions and decisions the user owns

### 14.1 Safe assumptions (planner judgment, not user-gated)

- Manual collections only in P3; smart collections stay read-only (rule editing is P7).
- Collection Sets/nesting and Quick/Target Collection are deferred; the P3 information architecture does not preclude either being added later.
- Multi-collection membership per image is supported (the `collection_images` join plus idempotent `INSERT OR IGNORE` already allow it).
- Ctrl/Cmd+A "select all" is an optional low-risk addition; its virtualization semantics are to be confirmed at implementation time.
- Destructive-button wording and the ⚿ glyph are placeholders needing a rendered-webview check (adjacent to Finding 4).
- Engineering mode is standard (T1 first-line, T2 on escalation), each with Verifier and Browser Validator gates. This is not an extreme-advisory-team route; `team_authorization` is not applicable.

### 14.2 Planner design judgment and PLAN_DUCK resolutions taken (flagged, justified; not user-gated)

- `DESIGN_ROUTE` classified as Standard rather than the parent plan's one-line Compact pre-classification (rationale in Section 2.1). This was flagged here, not silently applied, and is recorded below as Decision 1, approved by the user (Section 14.3).
- **Last-image-removed behavior is RESOLVED, not an open decision** (Section 8.1, finding J-P3-002): removing an image from a collection is membership-only and non-destructive; when the last image is removed, the collection is retained intact-but-empty and is never auto-deleted. Auto-deleting a collection as a side effect of a non-destructive membership removal would be a surprising destructive action; retention is the safe, coherent default and matches the passed design handoff (Section 7.1, design journey 4). No section of this plan treats this as open or user-owned.
- **Collection identity is RESOLVED as canonically numeric end to end**, closing the store/catalog id-type seam (Section 8.1, finding J-P3-003; Sections 5, 9.2 Track B, 10) — not deferred to implementation-time judgment.
- **The manual/smart/set predicate is RESOLVED as a single canonical rule** used everywhere in this plan: manual is `kind === 'manual'`, smart is `kind === 'smart'`, and `kind === 'set'` renders in neither list (Section 8.1, finding J-P3-001; Section 4.2).

### 14.3 Decisions resolved by the user at approval (2026-07-18)

All four decisions below were open at the prior draft revision and have now been resolved by the user's explicit approval on 2026-07-18. None remains open or pending; each resolution is also recorded inline at the body section(s) noted.

1. **DESIGN_ROUTE Compact→Standard upgrade** (Section 2.1): **Approved.** The deviation from the parent plan's P3 pre-classification, on the grounded reasons stated in Section 2.1, is approved as this plan's design route. (Also recorded in Section 2.1 and Section 14.2.)
2. **Duplicate collection-name policy:** **Block.** Creation and rename attempts that collide with an existing manual collection name are rejected (the `duplicate_name_error` state in design journeys 1 and 5, Section 7.1). The comparison is **case-insensitive** exact-match, checked client-side, and scoped to existing **manual** collection names only (not checked against smart-collection names) — this matches the plan's previously stated assumed default; no other section of this plan specified case-sensitive comparison, so there is no conflict to flag. (Also recorded in Section 7.1 design journeys 1 and 5.)
3. **Active-collection-filter persistence:** **Persist.** The active collection filter selection (`activeCollectionId`, journey J11/design journey 7) must survive an app reload/relaunch — it is written to durable storage and restored on launch, not reset to All Photographs. Collection **membership** always persisted regardless of this decision and is unaffected. (Also recorded in Section 7.1 design journey 7, Section 9.2 Track B, Section 9.4 Track D, Section 11, and Section 12.2 journey J11.)
4. **Drag-and-drop affordance (Track G):** **Included in P3 scope.** Drag-and-drop image-to-collection ships in this phase alongside the keyboard/menu baseline (Section 4.1 item 5), which remains the primary, required equivalent per the design review's accessibility requirement and is delivered regardless. (Also recorded in Section 4.1 item 6, Section 7.1 design journey 8 and the engineering-invariants paragraph, Section 9.7 Track G, Section 12.2 journey J15, and Section 13.)

### 14.4 Remaining non-blocking engineering electives (not user decisions; not blocking approval)

- Exact wording of all placeholder copy strings (button labels, empty-state text, error messages).
- Whether F2 rename and Ctrl/Cmd+A "select all" are implemented in the initial P3 pass or added as a small immediate follow-up, given both are explicitly optional per the design handoff.
- Context-menu radius, shadow blur/spread, menu-item height, chip padding, checkbox glyph size, and drag-ghost opacity may vary within the permitted-variation ranges stated in Section 7.1.

### 14.5 Remaining approvals

Any commit, push, or pull request remains separate and later, per Section 4.2 and Section 17.

## 15. Judge route (recap)

As stated in Section 8: an orchestrator-run `PLAN_DUCK` pass (advisory, shadow mode) has been performed against this draft and returned three findings (J-P3-001/002/003), fully disposed of in Section 8.1 and folded into Sections 4, 5, 7, 9, 10, 11, 13, and 14 above. This single permitted judge-driven remediation loop is now closed; this plan does not anticipate a further `PLAN_DUCK` pass before approval. A `CODE_REVIEW` checkpoint remains recommended during implementation on the net-new multi-select/state-model changes and on the `delete_collection` membership-cleanup path. Deterministic test/build failures, the independent Verifier pass, and the Browser Validator pass always dominate any judge opinion; the contract's call caps and shadow policy are respected; no live smoke calls occur without separate usage approval.

## 16. Engineering mode and downstream ownership

**Engineering mode:** standard (T1 first-line, T2 on escalation; each with independent Verifier and Browser Validator gates). No extreme-advisory-team justification is present for this phase.

**Team authorization:** not applicable.

**Downstream owner:** Scribe (this plan) → then, only after explicit user approval, the engineering fleet (T1), with this approved plan path as `ENGINEERING_JOB.approved_plan`.

## 17. Approval gate

This plan's Status line (Section 1) reads **APPROVED — approved by user on 2026-07-18**. The user explicitly approved this exact plan and explicitly resolved Decisions 1-4 (Section 14.3) at approval. This plan authorizes the work in Sections 4-15 as P3 implementation only — it does not authorize P4-P7 of the parent plan, and it does not authorize any commit, push, deployment, or pull request; those each remain a separate, later, explicit user approval. Scribe has updated this plan's Status line with the approval date, the approving party, and the resolution of each Section 14.3 decision; the orchestrator passes this exact path as `ENGINEERING_JOB.approved_plan` to the engineering fleet.

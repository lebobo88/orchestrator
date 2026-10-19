# Plan: photo-genie-p4-iptc-metadata — Phase 4 (P4) IPTC Metadata Panel and Presets Specification

## 1. Status

**APPROVED — 2026-07-19, approved by user directly to the orchestrator.** No work described in this document has been built yet. The Section 17 approval gate is now satisfied, and engineering may proceed against this exact plan version. This document remains a specification; nothing in it grants commit, push, pull-request, or deployment authority, each of which remains a separate, later, explicit user approval (Section 17).

This revision incorporates six decisions and a bounded Design Director addendum, all **resolved by the user, as relayed by the orchestrator, and confirmed at the Section 17 approval gate on 2026-07-19** — the user's approval of this exact plan version confirmed these resolutions; they are no longer pending. The Section 14.3 open-user-decisions list is empty: all eight decisions surfaced across this plan's revisions (the two resolved by planner judgment in the prior revision, plus these six) are recorded in Section 14.2 as this plan's confirmed resolutions. Two engineering-implementation follow-ups remain (Section 14.3a); these are not user decisions and did not block approval.

This version also reflects a **materially expanded scope** versus the previously-circulated draft — a new Sync Metadata feature, a backend atomic-write contract change, and deferral of export-time XMP embedding out of this phase's gate (Section 2.2). Because of that expansion, this exact version required the user's own fresh, explicit approval before any engineering work began; no earlier approval or intent carried over, and no agent message, from any session, substituted for that approval. The user explicitly approved this exact plan on 2026-07-19, directly to the orchestrator, and the Status line records that approval, per Section 17. T1/T2 implementation may now proceed against this exact plan version.

task_id: photo-genie-p4-iptc-metadata
plan_id: photo-genie-p4-iptc-metadata

**Target:** `H:\CommandCenter\orchestrator\photo-genie` (Tauri 2 + React 18 + TypeScript + Vite + Zustand + WebGPU; Rust `src-tauri`; Vitest). Windows host. This is a nested Git repository with its own `.git`, branch `main`. This plan document itself lives in the orchestrator repository's `docs/plans/`, not inside `photo-genie`.

### 1.1 Relationship to the parent plan and to prior phases

This is Phase 4 (P4) of the parent plan `docs/plans/photo-genie-audit-and-develop-fixes.md`, Section 7.3 (Library track). The parent plan's P4 pre-classification reads, verbatim: *"P4 - IPTC panel editable, plus metadata presets (R11; DESIGN_ROUTE: Standard — new editable metadata panel/flow). Edit creator/copyright/contact fields; apply-on-import preset. Acceptance: fields persist to the catalog and to export."* Per the parent plan's Section 5, each Phase 2+ item requires its own separate approval and, for UI-bearing work, its own independent design-review PASS at entry. Section 2.2 flags a resulting deviation from this pre-classification's acceptance line: this revision defers the "and to export" half to a future phase.

**P2 (catalog backup) and P3 (collections) are COMPLETE**, committed to `origin/main`, verified, and browser-validated. A stale-doc correction is noted for the record: `photo-genie/handoff.md` (written 2026-07-18) states that P2/P3 are uncommitted; the current, live repository state contradicts that note — P2 and P3 are complete and committed. This plan proceeds from that current, verified state, not from the stale handoff note.

A close-hang bug fix and an uninstaller data-retention prompt were also built and independently verified but are **not yet committed**; they are unrelated to P4 and are explicitly out of scope for this document.

## 2. Summary

P4 delivers a professional, **catalog-only** IPTC metadata capability for photo-genie, completing the catalog-editing half of Lightroom-parity gap-analysis requirement **R11**: (1) an expanded editable IPTC panel covering the IPTC Core 1.5 field set, including a collapsible Creator Contact Info block (satisfying **MET-03**); (2) batch-safe multi-selection editing using a mixed-value/touched-only contract, saved through a single atomic, transactional batch-write backend command that never partially applies across a selection; (3) reusable, named **Metadata Presets** — create, edit, delete, apply-to-current-selection, and apply-on-import (satisfying **MET-04**), with an optional per-field "explicitly clear" authoring control; and (4) a new **Sync Metadata** feature that copies selected IPTC fields from one designated source image onto the rest of a multi-selection, independent of and additional to the preset system. An app-owned modal warns the user before discarding unsaved edits on navigation. All edits persist to the catalog only; **this phase writes metadata to no file on disk, neither originals nor exports** — export-time XMP embedding, previously scoped as part of P4, is deferred to a future phase (Section 2.1, Section 2.2).

### 2.1 Storage and embedding decision (binding, stated prominently)

P4 keeps the **catalog as the single source of truth** for all IPTC metadata. **In this phase, P4 writes metadata to no file on disk at all — neither the user's original image files nor any newly-created export file.** Export-time XMP embedding into exported copies, previously scoped as part of this phase, is **deferred to a future phase** (Section 2.2; Section 9, Track E; Section 14.2, Decision 6).

Rationale:

1. This matches the schema's already-documented design intent (`schema.rs` V1 DDL comment: "IPTC editable fields (persisted to catalog, XMP sidecar mirror deferred Phase 2+)").
2. Writing metadata back into original files is a genuine data-corruption risk to irreplaceable user photos; this remains permanently out of scope regardless of phase, and no P4 operation attempts it.
3. Limiting this phase's write surface to the catalog database alone strengthens, rather than weakens, the "never touches original files" guarantee: nothing on disk, of any kind, is written by any P4 operation.

Deferring export-time embedding is a flagged deviation from the parent plan's one-line P4 acceptance ("persist to the catalog and to export," Section 1.1) — see Section 2.2 for the full disclosure. Writing to originals, or to XMP sidecar files placed adjacent to originals, remains out of scope for any phase without its own distinct, higher-risk plan addressing in-place mutation and backup/undo safety; this is unrelated to, and unaffected by, the export-embedding deferral. This decision is not itself one of the open decisions in Section 14.3 (now empty); it is recorded among the resolved decisions in Section 14.2 (Decision 6).

### 2.2 Materially expanded scope versus the previously-circulated draft (flagged deviation; approved by the user on 2026-07-19)

This version of the plan differs materially from the draft previously circulated for review, incorporating six decisions the user resolved (as relayed by the orchestrator) and a bounded Design Director addendum that passed a second independent design review (Section 7.4). Three of the resulting changes are significant enough to require the user's fresh, explicit approval of this exact version, not carryover of any earlier intent:

1. **A new Sync Metadata feature** (Section 9, Track I) is added: copying selected IPTC fields from one designated source image onto other images in a multi-selection, independent of and additional to the Metadata Preset system. This was previously a stated non-goal (Section 4.2, prior revision) and is now explicitly in scope.
2. **A backend contract change:** all multi-image metadata writes (panel Save, preset apply, and Sync Metadata) now go through a single atomic, transactional batch-write command with per-field tri-state semantics (set-to-value / explicitly-clear / leave-untouched), replacing the previously-specified N-sequential-calls model and its "partial (M of N)" outcome state everywhere it appeared.
3. **Export-time XMP embedding (previously Track E) is deferred out of this phase's gate.** P4 now ships catalog-only IPTC editing, which is a flagged deviation from the parent plan's one-line P4 acceptance, which read "persist to the catalog and to export" (Section 1.1). P4 now delivers the catalog half and defers the export half to a future phase, by decision at this step (Section 14.2, Decision 6).

The user explicitly approved this expanded version at the Section 17 gate on 2026-07-19; all three changes above are authorized as part of that approval, and engineering work may now proceed under Section 9's ordered work.

## 3. Outcome and audience

**Audience:** the user approving this P4 specification, and the engineering fleet (T1 first-line, T2 on escalation) that would execute it after approval, with independent Verifier and Browser Validator (tauri-driver native backend) gates on the resulting work.

**Observable result:** photo-genie gains a complete, professional, catalog-only IPTC metadata capability. The user will be able to:

- edit the full IPTC Core 1.5 field set on a single image, including a collapsible Creator Contact Info block (default collapsed, with a visible indicator whenever a collapsed field is dirty or mixed), through an expanded metadata panel;
- edit fields across a multi-image selection with a mixed-value/touched-only contract, saved by a single atomic batch-write call that either fully succeeds or fully rolls back, never partially applying and never clobbering untouched, differing field values;
- create, edit, and delete named Metadata Presets; apply a preset to the current selection or automatically on import; and, per preset, optionally opt in to explicitly clearing specific fields rather than leaving them untouched;
- designate one image within a multi-selection as a metadata source and copy chosen IPTC fields onto the rest of the selection (Sync Metadata), independent of the preset system;
- be warned, via an app-owned modal (never a native dialog), before unsaved edits are discarded when changing the selected image or leaving the panel;
- rely on every edit persisting to the catalog; this phase writes metadata to no file on disk, neither originals nor exports.

This completes the catalog-editing half of the parent plan's R11 (MET-03 editable IPTC panel including contact fields, and MET-04 metadata presets); the export-embedding half is deferred (Section 2.2).

## 4. Scope and non-goals

### 4.1 In scope

1. **Schema V5 migration** (`CURRENT_VERSION` 4 → 5), following the existing transactional, version-gated migration runner in `src-tauri/src/catalog/schema.rs`. Adds extended/contact IPTC columns to the `images` table: `headline`, `rights_usage_terms`, `creator_job_title`, `credit_line`, `source`, `contact_address`, `contact_city`, `contact_region`, `contact_postal_code`, `contact_country`, `contact_phone`, `contact_email`, `contact_website` (all nullable `TEXT`). Adds a new `metadata_presets` table, named **distinctly** from the existing develop-recipe presets table (Section 5, naming-collision finding; Section 7.1, invariant 4). The `metadata_presets` table's representation must additionally support the per-field **tri-state** contract required by Decision 2 (Section 14.2): for each field, a preset definition can set-to-value, explicitly-clear, or leave-undefined (not touched by the preset). The exact column/serialization design for this is an engineering-implementation detail within the V5 migration, not dictated by this plan beyond the contract requirement. No existing column changes; additive only.
2. **Backend (Rust):**
   - (a) **FINDING-1 FIX — data-integrity-critical.** Refactor `update_iptc` (`src-tauri/src/catalog/mod.rs:1082-1089`, currently an unconditional 4-column `UPDATE` that would NULL-clobber omitted fields) and its Tauri command `update_image_iptc` (`lib.rs:1013-1028`), plus the devbridge route (`handle_set_iptc`, `devbridge.rs:335`, route at `:1132`), to **column-scoped partial-write semantics** (a dynamic `SET` clause, or `COALESCE(?, column)` per column) that distinguish "field key omitted from the request → leave the column unchanged" from "field present as an empty string → clear the column to blank." Extend the write path to all new extended/contact fields. This remains the write primitive for a **single-image** panel Save.
   - (a2) **NEW — atomic multi-image batch-write command (Decision 5, Section 14.2).** A single transactional Tauri command plus `CatalogDb` method that applies a per-image field-payload set across N images within one database transaction: all images succeed, or the whole batch rolls back with nothing written. This command carries the per-field tri-state (set-to-value / explicitly-clear / leave-untouched) from Decision 2, and is the single shared primitive behind panel multi-select Save, Metadata Preset apply, and Sync Metadata; each caller differs only in how it derives field values (typed panel values, a stored preset definition, or a live source image's current values).
   - (b) New `MetadataPreset` CRUD commands, plus `CatalogDb` methods, devbridge routes, TS client wrappers, and Rust unit tests (following the `mod.rs` test patterns): create/list/update/delete metadata presets; apply a preset to a set of image ids using the atomic batch-write command from (a2).
   - (c) Apply-on-import wiring: apply a selected metadata preset to all images in an import batch.
   - (d) Import-time embedded IPTC/XMP **read** on folder import, to populate the new catalog fields. Today `src-tauri/src/catalog/import.rs` reads EXIF only, via `kamadak-exif` plus `rawler` for RAW; embedded IPTC/XMP is not read on folder import.
   - (e) **REMOVED from this phase's in-scope list.** Export-time XMP embedding is deferred (Section 2.1, Section 2.2, Section 9 Track E).
   - (f) **NEW — Sync Metadata backend.** No new Tauri command beyond the atomic batch-write command in (a2); the frontend derives the payload from the live source image's current field values and calls the same primitive.
3. **Frontend (React/TS):** extend `src/components/LibraryMetaPanel.tsx` plus its stylesheet per the design handoff (grouped field information architecture, single-select and multi-select mixed-value/touched-only contract, email/website inline validation, a single explicit Save, live-region announcements); a new Metadata Preset Management modal reusing the P2/P3 `.pg-*` kit (`src/components/backup/backup-ui.css`) and `useModalA11y` verbatim; an in-panel Apply Metadata Preset row; a Metadata Preset selector added to both tabs of `src/components/ImportDialog.tsx`; an app-owned unsaved-navigation-guard modal (Decision 1); a permanent, preset-scoped clear-blanks `.pg-checkbox` and "Will clear" preview line in the Apply Metadata Preset row (Decision 2); a collapsible, default-collapsed Contact Info disclosure with dirty/mixed indicators in its collapsed state (Decision 4); a new "Sync Metadata…" button in `CollectionToolbar.tsx`'s existing selection toolbar and a new Sync Metadata modal (Decision 3, Track I).
4. All 16 design `engineering_invariants` from the original design handoff (Section 7.1), plus the addendum's 10 engineering invariants (Section 7.4), and the combined browser-validation brief (Section 12).

### 4.2 Non-goals (binding)

- **No writing metadata to any file on disk in this phase** — neither the user's original image files nor any newly-created export file. Metadata source of truth is the catalog only. Export-time XMP embedding, previously scoped as part of P4, is deferred to a future phase (Decision 6, Section 14.2; Section 9, Track E). Writing to originals, or to XMP sidecars adjacent to originals, remains out of scope for any phase without its own distinct, higher-risk plan addressing in-place mutation and backup/undo safety.
- **No legacy IPTC-IIM embedding — XMP only.** The Creator Contact Info block has no IIM equivalent, and modern consumers prefer XMP. This was originally flagged as a user decision (formerly Decision 5 in the two-decision judge-remediation pass) and is now **resolved** by planner judgment, consistent with this section and Section 2.1 (Section 14.2).
- **Free-form, non-preset "sync metadata across selection" is now IN SCOPE.** The previously-circulated draft listed this as a non-goal; Decision 3 (Section 14.2) reverses that and adds it as the new Sync Metadata feature (Section 9, Track I), independent of and additional to the Metadata Preset system.
- **No GPS/map/geotag metadata UI** (a P2-era backlog item from the gap analysis).
- **Keywording UI (P5), Filter Bar (P6), and Smart-collection rule authoring (P7) remain out of scope**; this plan must not preclude any of them.
- **No schema change to any existing column**; no commit, push, pull request, or deployment (each remains a separate, later, explicit approval).
- **Preserve the Tauri 2 + React 18 + WebGPU architecture**, the single `Mutex<Connection>`, WAL mode, the zero-IPC slider loop, and the linear working space invariants.
- **Engineering authorized by this document is limited to P4.** This specification was approved by the user, directly to the orchestrator, on 2026-07-19; that approval authorizes P4 implementation only.

## 5. Repository findings — evidence baseline

The following is grounded, read-only evidence verified during planning, and re-verified independently during this revision where noted. Every file:line reference below is cited from the planning evidence and governs the ordered work in Section 9.

- **Already built — the base of MET-03 exists; extend, do not reinvent.** The `images` table already has IPTC columns `title`/`caption`/`copyright`/`creator` (`schema.rs` V1 DDL lines 189-194, with the comment "IPTC editable fields (persisted to catalog, XMP sidecar mirror deferred Phase 2+)"); the Rust `Image` model has these fields (`models.rs:86-90`); the full edit pipeline is wired end to end: `CatalogDb.update_iptc` (`mod.rs:1082`), Tauri command `update_image_iptc` (`lib.rs:1013`, registered at `:1729`), devbridge route `POST /api/catalog/images/:id/iptc` → `handle_set_iptc` (`devbridge.rs:335`, `:1132`), TS client `updateIptc` (`client.ts:258`) and `getImage` (`client.ts:215`), and the editable UI `LibraryMetaPanel.tsx` (renders in `App.tsx:558`, Library-mode right column, driven by `selectedLibraryImageId`) with a read-only EXIF "Camera Info" table plus editable title/caption/copyright/creator fields, a dirty indicator, and a manual "Save Metadata" button.
- **Current panel styling:** bespoke `.lib-meta-panel` / `.meta-*` classes (`LibraryMetaPanel.css`) on panel background `#181818`; it does **not** use the P2/P3 `.pg-*` kit, `useModalA11y`, or any `aria-live` region today.
- **Missing / net-new:** extended and contact IPTC fields (no columns today); a `metadata_presets` table plus CRUD; apply-on-import; import-time embedded-IPTC read; a Sync Metadata feature; an atomic multi-image batch-write command.
- **Import reads EXIF only:** `import.rs`'s `extract_exif` uses `kamadak-exif` 0.5 plus `rawler` 0.7 (RAW); there is no embedded IPTC/XMP read on folder import (only `.lrcat` imports populate IPTC via `lrcat` mapping).
- **Export writes no metadata:** `export.rs` uses `image` 0.25 (features `png`/`jpeg`/`tiff`); a grep confirms zero XMP/IPTC code in the export path today. This phase does not change that (Track E deferred).
- **`update_iptc` clobber risk:** `mod.rs:1082-1089` runs an unconditional `UPDATE` of all 4 columns; `LibraryMetaPanel.tsx:78-81` null-coerces omitted values. Any future per-image partial call would NULL-clobber untouched, differing fields across a multi-selection — this is why the FINDING-1 backend partial-write fix (Section 4.1 item 2a) is mandatory and must land before, or atomically with, the frontend touched-tracking work.
- **Reusable patterns from P2/P3:** the `.pg-*` dialog kit (`backup-ui.css`: `.pg-modal-overlay`/`.pg-modal-dialog`/`.pg-modal-dialog--wide` (560px)/`.pg-field`/`.pg-input`/`.pg-select`/`.pg-btn`/`.pg-btn--neutral`/`.pg-btn--destructive`/`.pg-banner--info|warning|error` triads/`.pg-hint`/`.pg-status-line`/`.pg-backup-list`/`.pg-spinner`); `useModalA11y.ts` (focus trap, Escape, focus-return, `suppressFocusRestoreOnClose`); the project-wide `document.querySelector('[role="status"]')` announcement idiom (`App.tsx:625` region, reused across P3 components); the tauri-driver native browser-validation backend; existing SEED/fixture scripts.
- **Naming collision (binding constraint):** an exported `Preset` interface (`client.ts:75`) and a `presets` table already ship for develop-recipe presets (`PresetsPanel.tsx`) in this same phase-4-era codebase. The new metadata-preset type/table **must** be named distinctly (`MetadataPreset` / `metadata_presets`), and all user-facing copy **must** read "Metadata Preset(s)."
- **Schema migration runner:** `schema.rs` has a transactional, version-too-new-gated migration list (`CURRENT_VERSION = 4`); the V5 migration must follow that exact pattern; P2's pre-migration automatic backup safety applies.
- **Design-closure evidence, independently re-verified during this revision (Closure A):** `CollectionsModals.css:298-311` defines `.selection-toolbar__btn` with `:hover` and `:focus` rules but **no `:disabled` rule**. `CollectionToolbar.tsx:104-112` already uses a plain `disabled={isRemoving}` attribute on a sibling "Remove from" button with no corresponding CSS rule, so a disabled "Sync Metadata…" button would render visually identical to an enabled one unless a rule is added (Section 7.4).
- **Existing selection toolbar, reused (Closure-adjacent evidence):** `CollectionToolbar.tsx:79-116` is the existing `role="toolbar"` selection toolbar (`aria-label="Collection view and selection actions"`) that already carries the "Add to Collection" button (`.selection-toolbar__btn`, shown when `selectedLibraryImageIds.length > 0`, `CollectionToolbar.tsx:95-103`); the new "Sync Metadata…" button is added here, following the same no-context-menu-duplicate precedent (Section 9, Track I).
- **Modal-shell evidence, independently re-verified during this revision (Closure B):** `AddToCollectionPicker.tsx` supplies the checklist-plus-in-place-sub-view-swap **interaction pattern** reused by the new Sync Metadata modal (Section 7.4, Section 9 Track I) — but its own shell renders `className="pg3-modal-overlay"` plus `className="pg-modal"` (`AddToCollectionPicker.tsx:180-188`, both defined in `CollectionsModals.css`), the P3-specific modal classes, **not** the P2 `.pg-modal-dialog` shell. `backup-ui.css:22-34` already defines `.pg-modal-dialog` and a `.pg-modal-dialog--wide { width: 560px; }` variant; the new Sync Metadata modal uses that P2 shell, reusing only `AddToCollectionPicker`'s interaction pattern, never its `.pg3-*` classes.
- **New shared components confirmed genuinely new:** neither `.pg-checkbox` nor `.pg-disclosure` exists anywhere in the repository today (grep-confirmed during this revision); both are net-new, shared components introduced by this revision's addendum (Decision 2's clear-blanks checkbox and Decision 4's Contact Info disclosure, the latter also used by the Sync modal's "Change source" control). `backup-ui.css` already defines `.pg-btn--neutral`, `.pg-btn--destructive`, `.pg-banner--warning`, and `.pg-spinner`; the addendum reuses the first three but deliberately does not reuse `.pg-spinner` (a "Saving…"/"Syncing…" label swap is used instead, no spinner).

## 6. Research evidence and disposition

The following research disposition was consumed directly from a nested Researcher `RESEARCH_EVIDENCE` packet during planning.

- **Storage/embedding feasibility confirmed export-only, without a native DLL.** Primary recommended pure-Rust stack: `img-parts` (~0.4, MIT/Apache) for JPEG/PNG container segment splice — inserting an APP1 XMP segment or a PNG `iTXt` "XML:com.adobe.xmp" chunk; also usable to extract raw XMP/IPTC segments on import. The low-level `tiff` crate's `DirectoryEncoder` (already a transitive dependency of `image` 0.25) for the TIFF export branch, to write custom IFD tags 700 (XMP) / 315 (Artist) / 33432 (Copyright) / 270 (ImageDescription). `xmp-writer` (~0.3, MIT/Apache, Typst-maintained) to serialize the XMP RDF/XML packet with custom `Iptc4xmpCore:` / `photoshop:` / `xmpRights:` properties. A small, mature XML parser (`quick-xml` or `roxmltree`) to parse the known target properties on import. Fallbacks, in order: Adobe's `xmp_toolkit` (native C++ but statically compiled via `cc`, no runtime DLL) if the pure-Rust path proves fragile; a bundled `exiftool.exe` as a last resort, which would be a deployment-footprint change needing its own explicit sign-off. **Ruled out:** `rexiv2`/`gexiv2` (GPL-3.0, requires bundling native DLLs on Windows, and stale since 2023).
- **Field set — IPTC Core Schema 1.5** (all covered without needing the IPTC Extension; consistent with the current standard, IPTC Photo Metadata 2025.1): Title → `dc:title`; Headline → `photoshop:Headline` (IIM 2:105); Caption/Description → `dc:description` (IIM 2:120); Copyright Notice → `dc:rights` (IIM 2:116); Rights Usage Terms → `xmpRights:UsageTerms` (XMP-only); Creator → `dc:creator` (IIM 2:80); Creator's Job Title → `photoshop:AuthorsPosition`; Credit Line → `photoshop:Credit`; Source → `photoshop:Source`; Creator Contact Info → `Iptc4xmpCore:CreatorContactInfo` struct (`CiAdrExtadr`, `CiAdrCity`, `CiAdrRegion`, `CiAdrPcode`, `CiAdrCtry`, `CiTelWork`, `CiEmailWork`, `CiUrlWork`) — the entire Contact Info block is XMP-only, with **no** legacy IIM equivalent. This is the decisive reason XMP, not IIM, is the embedding target (Section 4.2).
- **Import read:** `kamadak-exif` exposes EXIF only, with no IPTC/XMP; a companion crate is needed — either `img-parts` segment extraction plus a small XML parse, or `nom-exif` for a raw XMP read. This is still needed this phase for Track D.
- **Required validation measure (for the deferred future phase):** a standalone Rust spike must encode representative JPEG/PNG/TIFF files, embed the full field set including Contact Info, then re-read with an independent tool (ExifTool CLI or Windows Explorer Details) to confirm round-trip fidelity **before** wiring the embedding path into `export.rs`. The TIFF custom-tag path additionally must open cleanly in an independent TIFF viewer, since a malformed custom IFD entry can corrupt the file. Exact license text must be confirmed before shipping any fallback crate or tool.
- **Windows build note:** all primary-stack crates are pure-Rust with no `build.rs` native compile step; versions must be pinned, and `cargo build --release` should be run early after adding any new crate.
- **Researcher-flagged scope item, since resolved:** whether P4 includes legacy IPTC-IIM embedding at all — the research recommendation was no, XMP-only, and this is now resolved on that basis (Section 4.2, Section 14.2).
- **Research disposition update (this revision):** the export-embedding research above (the pure-Rust `img-parts`/`tiff`/`xmp-writer` stack, the field-set mapping, and the required round-trip validation measure) is **retained as forward input for the deferred future phase** (Section 2.2, Section 9 Track E) and is **not consumed by this phase's gate** — P4 ships catalog-only IPTC editing and does not exercise or depend on this research to complete.

## 7. Design route, handoff, and review

**DESIGN_ROUTE: Standard.** `profile = standard`, `existing_system_mode = extend`, `model_tier = sonnet`, `prototype = forbidden`. Roles run: design-director (lead), ux-architect, visual-system-designer, and an independent design-reviewer. Motion-designer and asset-art-director were deliberately not invoked — no new choreography beyond the already-shipped `.pg-fade-in`, and unicode glyphs only, with no new iconography.

Grounded reasons for Standard (consistent with the parent plan's own pre-classification, which already read Standard): a multi-state metadata editor with a net-new mixed-value/touched batch-safety contract, a new preset-management modal flow, apply-on-import integration, and email/website validation — matching the Standard profile's own trigger ("new screen / multi-state component / user-flow change"). Not Studio — the work extends the existing dark chrome and reuses the P2/P3 kit; it is not greenfield, brand-critical, or novel. Not Compact — the work exceeds bounded brownfield UI. The Section 7.4 addendum does not change this classification (see Section 7.4).

### 7.1 Design handoff

A full `DESIGN_HANDOFF` was delivered and **PASSED** independent design review (Section 7.2). `selected_direction` = **"Additive extension of the shipped photo-genie dark utility chrome; extends `LibraryMetaPanel` in place and reuses the `.pg-*` modal kit plus `useModalA11y` for a new Metadata Preset Management modal."**

**Panel information architecture (top to bottom):** Camera Info (unchanged, read-only EXIF) → selection banner (multi-select only, "{N} images selected") → Apply Metadata Preset row (dropdown plus clear-blanks checkbox plus Apply button plus a "Manage Metadata Presets…" link) → Description group (Title, Headline, Caption/Description) → Rights group (Copyright Notice, Rights Usage Terms) → Creator group (Creator, Job Title, Credit Line, Source, plus a nested, collapsible Contact Info sub-block of 8 XMP-only fields, default collapsed) → one panel-level Save button.

**Three-state per-field legibility contract (binding):**

1. Clean.
2. Mixed-values (multi-select only): inert, native placeholder "<multiple values>" in italic `#8f8f8f`, plus a visually-hidden companion string for assistive technology.
3. Touched/pending: a typed value plus a 3px left amber (`#f0b040`) stripe plus a "will update N" tag from the reused `.pg-banner--warning` triad, plus a visually-hidden `aria-describedby` suffix.

Only state-3 (touched/pending) fields enter the Save payload.

**Save model:** one explicit panel Save button — not autosave, not per-group. A single-image Save uses the column-scoped partial-write primitive (Section 4.1 item 2a). A multi-select Save, a Metadata Preset apply, and Sync Metadata (Section 7.4) all use the single atomic, transactional batch-write command (Decision 5, Section 14.2): all images in the operation succeed, or the whole batch rolls back with nothing written. The previously-specified "partial (M of N)" outcome state is removed everywhere it appeared and replaced by a single atomic-failure/rolled-back state: all typed values, preset choices, or sync selections are preserved, a `.pg-banner--error` is shown, and a "Retry" action is offered. Inputs are disabled while saving (opacity 0.4, aliasing `.meta-save-btn`), with a "Saving…" label swap rather than a spinner.

**Color/contrast tokens (binding, independently reviewed):** new fields use `.meta-field--accent` (`#4b7bec` focus border, ≈4.80:1) and `.meta-field__label--accent` (`#999` label, ≈6.23:1 on `#181818`); the original 4 fields keep the shipped `#555` focus and `#777` label unchanged (a disclosed, pre-existing two-tier gap — `#777` on `#181818` is ≈3.96:1, which fails AA, so new labels must **not** reuse it). The sole genuinely new primitive hex is `#8f8f8f` (mixed-value field content on `#111` input, ≈5.83:1). All other new tokens alias already-shipped AA-passing hexes.

**Metadata Preset Management modal:** shell `.pg-modal-overlay` (standard `z-300`) plus `.pg-modal-dialog` (480px) verbatim; list reuses `.pg-backup-list`/`.pg-backup-list__item`; the create/edit form reuses `.pg-field`/`.pg-input`/`.pg-select` and mirrors the panel's group grammar, including Contact Info; rename is editing the Name field; inline duplicate-name error under Name (`role="alert"`); a nested delete-confirmation `alertdialog` (standard tier, `.pg-btn--destructive`); post-delete focus moves to "+ New Metadata Preset" via `suppressFocusRestoreOnClose`. This modal uses the `.pg-*` kit (`backup-ui.css`), **not** `.pg3-*` (`CollectionsModals.css`). The Apply Metadata Preset row additionally carries a permanent `.pg-checkbox` (Decision 2, Section 7.4), visible but `aria-disabled` until a preset is chosen, default OFF; see Section 7.4 for its full state contract.

**Apply Metadata Preset (in-panel):** dropdown plus the permanent clear-blanks checkbox (default OFF, Decision 2) plus Apply plus a preview line inside a `.pg-banner--info`, shown before writing — "Will set: …" always, plus "Will clear: …" when the toggle is ON and the preset defines blank fields; Apply flips the preset's defined fields to touched/pending (set-to-value fields) or explicitly-clear/pending (toggle-covered blank fields), using the identical no-clobber rule for every field the preset does not define; Apply never auto-saves.

**Apply-on-import:** a "Metadata Preset" row is added identically to both the Folder and Lrcat tabs of `ImportDialog`, above the path-input row; selecting a preset commits immediately; the dropdown is disabled while `importing === true`; a no-presets state degrades gracefully.

**Validation scope (binding, narrow by design):** Email and Website are the **only** format-validated Contact Info fields; Address/City/Region/Postal/Country/Phone remain free text — deliberately, to avoid international-format false rejections.

**Accessibility requirements:** keyboard order follows DOM order (row grouping in source order, never CSS order); an optional Contact Info two-column pairing is gated by a container query on `.lib-meta-panel` width, with a fixed DOM order regardless of the visual layout — Contact Info's default-collapsed state (Decision 4, Section 7.4) does not change this: when expanded, keyboard order still follows DOM order; announcements use the existing `document.querySelector('[role="status"]')` idiom (not the sole region, described as reused); `forced-colors` support carries meaning in text, not fill, and borders stay visible; no new motion is introduced — any transition reuses `.pg-fade-in` with the existing `prefers-reduced-motion` instant-cut fallback.

**Engineering invariants (binding acceptance items).** The design handoff specifies 16 total engineering invariants; the planning evidence received explicitly detailed the following, described as "most important," and this plan carries them verbatim as binding acceptance items:

1. Mandatory backend column-scoped partial-write (`COALESCE`/dynamic `SET`), distinguishing omit from empty, landing before or atomically with the frontend touched-tracking work.
4. `MetadataPreset`/`metadata_presets` distinct naming, plus "Metadata Preset(s)" user-facing copy.
5. Export-time XMP embedding is net-new backend work needing its own feasibility check (the pure-Rust stack in Section 6); no trust-framing copy ships before the pipeline exists and is verified. (This invariant now applies to the deferred future phase, Section 9 Track E; it creates no acceptance requirement in this phase's gate, since no export pipeline is built this phase.)
9. Per-field touched tracking; only touched keys are ever sent on Save.
12. No native `alert`/`confirm`/`prompt`/`window.*`/`beforeunload`; `useModalA11y` reused verbatim.
14. No copy implying writes to original files. (Reinforced by addendum invariant 10, Section 7.4: no copy implies writes to export files either, this phase.)
15. Two-column Contact Info layout via DOM-order grouping, never via CSS order.
16. Disabled-state opacity aliases the shipped `0.4` value.

The evidence received did not detail invariants 2, 3, 6, 7, 8, 10, 11, and 13 individually beyond the above. This plan does not invent their content; engineering and the independent Verifier should confirm the complete 16-item invariant list against the underlying design record before or during implementation, and any additional invariant surfaced there is binding on the same footing as the eight reproduced above. The Section 7.4 addendum carries its own, separate set of 10 engineering invariants; the two lists are not merged, and both are binding.

### 7.2 Design review

`DESIGN_REVIEW_RESULT = PASS` (independent design-reviewer, sonnet), reached after one evidence-backed NEEDS_REVISION → revision cycle. The reviewer independently re-verified the backend clobber finding (`mod.rs:1082-1089`, `lib.rs:1013-1028`, unchanged at review time), recomputed the contrast math (`#999` on `#181818` ≈6.23:1; `#8f8f8f` on `#111` ≈5.83:1; `#555` on `#111` ≈2.53:1, a pre-existing, disclosed gap; `#4b7bec` ≈4.80:1), confirmed zero native dialogs project-wide, confirmed that `.pg-*` versus `.pg3-*` reuse is correct and collision-free, and confirmed verbatim reuse of `useModalA11y`. Findings 1-5 from the review were resolved; advisory findings 6-7 were resolved. Eight `unresolved_decisions` were legitimately deferred to the user and do not block the PASS verdict. Two of those eight (metadata preset name uniqueness; legacy IPTC-IIM embedding scope) were subsequently resolved by planner judgment following a shadow-mode `PLAN_DUCK` finding (Section 14.2); the remaining six were addressed by a subsequent Design Director addendum (Section 7.4), which passed a **second**, independent design review.

### 7.3 Decisions the design pass surfaced — status: all resolved and confirmed at approval

The design pass originally surfaced eight decisions for the user to own. Two were resolved by planner judgment in a prior revision (Section 14.2; a shadow-mode `PLAN_DUCK` finding). The remaining six were subsequently addressed by a bounded Design Director addendum (Section 7.4), which PASSED a second independent design review. All eight are recorded as this plan's specified resolutions in Section 14.2; the Section 14.3 open-user-decisions list is empty. The user explicitly approved this expanded version, and these resolutions, at the Section 17 gate on 2026-07-19; engineering work is authorized to begin.

### 7.4 Design Director addendum and second independent design review

Following the user's resolution of the six decisions listed in Section 14.2 (Decisions 1-4 for the UI-bearing items, plus the atomic-write and export-deferral consolidation reflected in Decisions 5-6), a bounded Design Director addendum specified the UI-bearing items and the resulting cross-cutting write-model change. `DESIGN_REVIEW_RESULT = PASS` on a **second, independent** design review (design-reviewer, sonnet), with two advisory closures (A and B below) folded in as binding. The route classification is unchanged: **Standard** — the addendum introduces zero new hex values, reuses the P3 selection-toolbar/anchor model and the `.pg-*` kit, and does not warrant a Studio or Compact reclassification.

**Addendum Item 1 — Unsaved-navigation guard (Decision 1).** When the user changes the selected image, or leaves the panel context, while one or more fields are in the touched/dirty state (a mixed-but-untouched field does not count), an app-owned modal (`.pg-modal-dialog`, 480px, `useModalA11y`, never native) offers three actions: "Keep Editing" (default focus, safe; Escape maps to this), "Discard Changes" (`.pg-btn--destructive`, leftmost with extra margin), and "Save and Continue" (`.pg-btn` primary, rightmost). State vocabulary: shown → confirming (controls disabled at opacity 0.4, a "Saving…" label swap, no spinner) → dismissed-kept / dismissed-discarded (fields revert, touched state clears, navigation proceeds, announces "Changes discarded.") / dismissed-saved (the atomic write succeeds, navigation proceeds, announces "Changes saved.") / error (the atomic write fails and rolls back; the modal stays open; a `.pg-banner--error` renders above the footer; buttons re-enable, relabeled "Retry Save and Continue"; all touched values are preserved; announces "Could not save changes. Nothing was changed.").

**Addendum Item 2 — Preset clear-blanks user option (Decision 2).** A `.pg-checkbox` lives permanently in the Apply Metadata Preset row, visible but `aria-disabled` until a preset is chosen; default OFF (leave-untouched, the safer default). OFF: the preview shows only "Will set: {fields}". ON: the preview adds a visually distinct "Will clear: {fields}" line, differentiated by verb text plus weight plus a bounded `.pg-banner--warning` chip — never by color alone — and marks the preset's own blank fields as explicitly-clear/touched-pending. The toggle concerns only fields the preset itself leaves blank; fields the preset does not define at all are never affected. **Backend contract requirement:** preset-apply must carry a per-field tri-state (set-to-value / explicitly-clear / leave-untouched), distinct from the plain omit-vs-empty binary used by the single-image partial-write path (Section 4.1 item 2a2, Decision 5).

**Addendum Item 3 — Contact Info collapsible, default collapsed (Decision 4; overrides the original design handoff's "never default-collapsed").** A standard disclosure (`aria-expanded`/`aria-controls`, keyboard-operable, normal Tab order, ▸/▾ glyph, `#4b7bec` focus ring) — a new, shared `.pg-disclosure` component, also used by the Sync Metadata "Change source" control (Item 4 below). Default collapsed. The collapsed state must always show an indicator when any Contact Info field is touched/dirty or mixed, so pending state is never hidden: collapsed-clean ("Contact Info"); collapsed-dirty ("Contact Info ({N} unsaved)", reusing the `.meta-dirty` amber, taking priority over mixed); collapsed-mixed ("Contact Info (mixed values)", shown only when zero fields are touched but one or more are mixed, reusing `#8f8f8f`); expanded. The expand/collapse transition is instant, no fade.

**Addendum Item 4 — Sync Metadata (Decision 3; new feature, Track I).** With `selectedLibraryImageIds.length > 1`, the user designates one selected image as the **source** and copies chosen IPTC fields from that live image's current values onto the other selected images — independent of, and additional to, the Metadata Preset system. Source model: the existing P3 anchor (`selectedLibraryImageId`, retained inside `selectedLibraryImageIds`) is the default source, shown with a visible "Source: {filename}" indicator; an in-modal "Change source" control is an inline `role="radiogroup"` of the other selected images (immediate-commit, auto-collapses on selection), built on the new `.pg-disclosure` component. Field selection: a checklist of the full P4 field set, default **OFF** for Title/Headline/Caption-Description (per-photo descriptive fields), default **ON** for Copyright Notice/Rights Usage Terms/Creator/Creator's Job Title/Credit Line/Source and all 8 Contact Info fields. UI carrier: a new "Sync Metadata…" button in `CollectionToolbar.tsx`'s existing `role="toolbar"` selection toolbar (`CollectionToolbar.tsx:79-116`), alongside "Add to Collection," enabled only when more than one image is selected, with **no context-menu duplicate** (following the Add-to-Collection precedent). Modal: reuses `AddToCollectionPicker.tsx`'s **interaction pattern** (checklist plus in-place sub-view swap) rendered in the P2 `.pg-modal-dialog` / `.pg-modal-dialog--wide` (560px) shell plus `useModalA11y` (initial focus on "Change source"; `onEscape` closes; footer Cancel/`.pg-btn--neutral` plus Sync/`.pg-btn`) — see Closure B below for why this shell, not `AddToCollectionPicker`'s own `.pg3-modal-overlay`/`.pg-modal` shell, is used. Clear-blank write semantics mirror Decision 2: a blank source field leaves the target untouched by default, unless the user opts in via the identical toggle grammar. State vocabulary: default-source-selected → changing-source → source-designated → field-selection → preview (continuously live) → applying ("Syncing…" label swap, no spinner) → applied (announces "Copied {K} field(s) from {source} to {M} image(s).") / atomic-failure/rolled-back (nothing written, all choices preserved, `.pg-banner--error`, footer Cancel/Retry) / no-eligible-targets (the selection drops below 2 while the modal is open; the body is replaced with an explanatory notice, only Close remains active). A full keyboard-only journey is specified: toolbar Enter/Space opens the modal → focus lands on "Change source" → Space/Enter expands the radiogroup → arrow keys move and commit the source → Tab into the field checklist and the clear-blanks toggle → Enter submits → focus returns to the toolbar button. Source/target roles are conveyed via visible text only, never color alone.

**Closure A (binding, required, not contingent).** `CollectionsModals.css:298-311` defines `.selection-toolbar__btn` with `:hover` and `:focus` rules but no `:disabled` rule (independently re-verified during this revision); a disabled "Sync Metadata…" button would therefore render identical to an enabled one. Add `.selection-toolbar__btn:disabled { opacity: 0.4; cursor: not-allowed; }` (aliasing the shipped `0.4` disabled value, for example `.meta-save-btn:disabled`) before the Sync button ships. This is a concrete, required engineering acceptance item in Track I and in Track J's quality gate, not a contingency.

**Closure B (binding).** The Sync Metadata modal renders in the P2 `backup-ui.css` `.pg-modal-dialog` / `.pg-modal-dialog--wide` shell (bordered header with title plus close, 560px), reusing only `AddToCollectionPicker.tsx`'s interaction pattern (checklist plus in-place sub-view swap) — **not** P3's `.pg3-modal-overlay` / `.pg-modal` shell (`AddToCollectionPicker.tsx:180-188`, `CollectionsModals.css`). This is stated explicitly so no implementer copies the wrong overlay/shell classes.

**The addendum's 10 engineering invariants (binding acceptance items, a separate list from Section 7.1's 16):**

1. Atomic batch write, all-or-nothing; no "M of N" partial-success state anywhere in the plan.
2. A single shared batch-write primitive serves panel multi-select Save, Metadata Preset apply, and Sync Metadata, differing only in how the UI derives field values.
3. The shared primitive carries a per-field tri-state (set-to-value / explicitly-clear / leave-untouched).
4. No native dialogs anywhere in the addendum's new surfaces; `useModalA11y` reused verbatim.
5. New modals use the `.pg-*` kit, never `.pg3-*` (Closure B).
6. `.pg-checkbox` and `.pg-disclosure` are each defined once and reused twice (the clear-blanks toggle and, respectively, Contact Info plus the Sync "Change source" control).
7. No `.pg-spinner` anywhere in the addendum; progress is a label swap ("Saving…"/"Syncing…") only.
8. `.selection-toolbar__btn:disabled` is added per Closure A before the Sync button ships.
9. The original two-tier disclosed accessibility gap (Section 7.1's `#777`/`#555` on the original 4 fields) is preserved, not regressed, and not obligated to be fixed by this addendum.
10. A single, consolidated `.pg-banner--error` pattern is used across all multi-write surfaces (panel Save, preset apply, Sync); export-time XMP embedding is deferred, so no copy anywhere implies metadata is written to export files or to originals.

## 8. Judge route

Consistent with `docs/JUDGE-CONTRACT.md` and the P2/P3 precedent, this plan recommends an orchestrator-run `PLAN_DUCK` checkpoint (advisory, shadow mode) at **Medium** risk, reflecting the backend write-path data-integrity work and the schema migration. The earlier `PLAN_DUCK` remediation loop (Section 15.1) is closed. This revision's expanded scope change (the Sync Metadata feature, the atomic-write contract change, and the Track E deferral) was relayed as user-directed and was design-reviewed a second time (Section 7.4) before approval; the user explicitly approved this exact scope at Section 17 on 2026-07-19. A `CODE_REVIEW` checkpoint is recommended during implementation on: the atomic batch-write/tri-state command and the Sync Metadata write path (new, this revision); the `update_iptc` single-image partial-write refactor (Track B); and the V5 migration (Track A). The export-embedding `CODE_REVIEW` recommendation moves to the deferred future phase (Section 9, Track E) and does not apply to this phase's gate. Deterministic build/test/Verifier/Browser-Validator gates always dominate; Codex is never implementation and never substitutes for those gates; the contract's call caps and shadow policy are respected; no live smoke calls occur without a separate, explicit usage approval.

## 9. Ordered work

The user explicitly approved this plan on 2026-07-19 (Section 17), and the tracks below may now proceed. All decisions surfaced across this plan's revisions are recorded as resolved in Section 14.2, and Section 14.3's open-user-decisions list is empty.

### 9.1 Track A — Schema V5 migration

Add the extended/contact IPTC columns to `images`, plus the new `metadata_presets` table, as V5 DDL in `schema.rs`, following the transactional, version-gated migration runner already in place; bump `CURRENT_VERSION` to 5. The `metadata_presets` table's representation must support the per-field tri-state contract (set-to-value / explicitly-clear / leave-undefined) required by Decision 2 (Section 14.2); the exact column/serialization design is an engineering-implementation detail, not dictated by this plan beyond that contract requirement. P2's pre-migration automatic backup safety applies.

**Acceptance:**
- A migration test proves V5 applies transactionally and is idempotent.
- The version-too-new gate remains intact.
- No existing column is altered.
- A dedicated test proves the tri-state representation round-trips all three states (set-to-value, explicitly-clear, leave-undefined) for a preset definition.

### 9.2 Track B — Backend partial-write refactor and atomic batch-write command (data-integrity critical; blocks multi-select)

Two related backend changes:

1. **Single-image partial-write (FINDING-1 fix):** refactor `update_iptc`, `update_image_iptc`, and `handle_set_iptc` to column-scoped partial semantics — an omitted field leaves its column unchanged; an explicit empty string clears it. Extend this contract to all new extended/contact fields. This remains the write primitive for a single-image panel Save.
2. **New atomic multi-image batch-write command (Decision 5, Section 14.2):** a single transactional Tauri command plus `CatalogDb` method that applies a per-image field-payload set across N images within one database transaction — all images succeed, or the whole batch rolls back with nothing written. This command carries the per-field tri-state (set-to-value / explicitly-clear / leave-untouched) required by Decision 2, and is the single shared primitive behind panel multi-select Save, Metadata Preset apply (Track C), and Sync Metadata (Track I). The previously-specified per-image sequential-calls model, and its "partial (M of N)" outcome, are removed; only an all-succeed or an atomic-failure/rolled-back outcome exists.

Update `models.rs`'s `Image` struct, the TS `CatalogImage`/types definitions, and the client signatures for the new fields and for the new atomic batch-write command.

**Acceptance:**
- Rust unit tests prove that a single-image partial update leaves omitted columns unchanged, and that an explicit empty string clears a column (the FINDING-1 guarantee).
- A Rust unit test proves the atomic batch-write command is all-or-nothing: an induced mid-batch failure leaves every image in the batch unchanged (no partial application), and a successful batch applies to every image in the batch.
- A Rust unit test proves each of the three per-field tri-state outcomes (set-to-value, explicitly-clear, leave-untouched) is applied correctly within a batch call.

### 9.3 Track C — MetadataPreset backend

Implement `CatalogDb` CRUD methods, Tauri commands, devbridge routes, and TS client wrappers for the `MetadataPreset` type and the `metadata_presets` table: create/list/update/delete metadata presets, plus apply-a-preset-to-a-set-of-image-ids using the atomic batch-write command from Track B, carrying the per-field tri-state so a preset's own blank fields can be applied as explicitly-clear only when the clear-blanks toggle (Decision 2, Section 7.4) is on.

**Acceptance:**
- Rust unit tests cover create/list/update/delete.
- A Rust unit test proves apply-to-images via the atomic batch-write command: default (clear-blanks OFF) leaves target fields the preset leaves blank untouched; clear-blanks ON explicitly clears them; fields the preset does not define at all are never touched either way; a mid-batch induced failure rolls back the entire apply with nothing written.

### 9.4 Track D — Import-time embedded-IPTC read

Read embedded IPTC/XMP metadata on folder import (using `img-parts`/`nom-exif` plus an XML parse) to populate the new catalog fields. Cover this with unit/integration tests against a fixture containing embedded metadata.

This track remains the one arguably-trimmable piece if a tighter P4 is wanted; the recommendation is to keep it for a faithful, complete panel, but it is separable from the rest of P4 without blocking the other tracks.

### 9.5 Track E — Export XMP embedding — DEFERRED to a future phase (Decision 6, Section 14.2)

This track is **not implemented in this phase.** P4 ships catalog-only IPTC editing (extended fields, presets, Sync Metadata, atomic batch editing, and import-time embedded-IPTC read); no metadata is embedded into exported files this phase, and this document's acceptance gate (Section 11) carries no export-related check.

For a future phase, this track would cover: a standalone Rust spike proving JPEG/PNG/TIFF round-trip of the full field set, including Contact Info, verified against an independent tool (ExifTool or Windows Explorer Details), plus a TIFF-opens-cleanly check in an independent viewer, before any wiring into `export.rs`; then wiring the embedding path using `img-parts` plus the `tiff` crate's `DirectoryEncoder` plus `xmp-writer` (Section 6). The research behind this pure-Rust stack (Section 6) remains the recommended starting point for that future phase and is not consumed by this phase's gate.

### 9.6 Track F — Panel frontend

Extend `LibraryMetaPanel` per the design handoff's information architecture (Section 7.1), the three-state contract, the single Save button now backed by the atomic batch-write command for multi-select (Track B), email/website inline validation, and the live-region announcement. Add the unsaved-navigation-guard modal (Decision 1, Section 7.4, Addendum Item 1). Add the default-collapsed Contact Info disclosure with its dirty/mixed collapsed-state indicators (Decision 4, Section 7.4, Addendum Item 3). CSS changes are additive only, including the new shared `.pg-disclosure` component.

### 9.7 Track G — Metadata Preset Management modal and Apply row

Build the new Metadata Preset Management modal (`.pg-*` kit plus `useModalA11y`) and the in-panel apply-to-selection row with its preview line, now including the permanent clear-blanks `.pg-checkbox` (default OFF), the "Will clear: {fields}" preview line shown when the toggle is on, and the tri-state apply semantics (Decision 2, Section 7.4, Addendum Item 2).

### 9.8 Track H — Apply-on-import

Add the Metadata Preset selector to both tabs of `ImportDialog`, per the design handoff's specified placement and disabled-while-importing behavior.

### 9.9 Track I — Sync Metadata (new feature; Decision 3, Section 7.4 Addendum Item 4)

Build the "Sync Metadata…" button in `CollectionToolbar.tsx`'s existing selection toolbar (enabled only when more than one image is selected, with the `.selection-toolbar__btn:disabled` rule from Closure A) and the new Sync Metadata modal: the P2 `.pg-modal-dialog`/`.pg-modal-dialog--wide` shell plus `useModalA11y`, reusing `AddToCollectionPicker.tsx`'s checklist-plus-sub-view-swap interaction pattern only (Closure B); the default-source-selected/change-source `role="radiogroup"` control built on the shared `.pg-disclosure` component; the field checklist with its default ON/OFF split; the live preview; and the atomic apply via the Track B batch-write command with tri-state clear-blank semantics mirroring Decision 2.

**Acceptance:**
- The source image's own catalog fields are verified unchanged after a sync (the source is never a target of its own operation).
- Only the fields the user selected in the checklist are copied; unselected fields are unaffected.
- Default field-selection state matches the addendum specification (OFF for Title/Headline/Caption-Description; ON for Copyright Notice/Rights Usage Terms/Creator/Creator's Job Title/Credit Line/Source and all 8 Contact Info fields).
- An induced mid-batch failure rolls back the entire sync: no target image is partially updated, and all field/source selections remain intact in the modal for retry.
- A full keyboard-only journey passes: toolbar Enter/Space → focus "Change source" → Space/Enter expands the radiogroup → arrow keys move and commit the source → Tab into the checklist and the clear-blanks toggle → Enter submits → focus returns to the toolbar button.
- The "Sync Metadata…" button is disabled (with the Closure A `:disabled` styling, opacity 0.4) when 1 or 0 images are selected, and this disabled state is visually distinguishable from the enabled state.
- The no-eligible-targets state (selection drops below 2 while the modal is open) is exercised: the body is replaced with an explanatory notice, only Close remains active.

### 9.10 Track J — Design-closures and quality gate

Implement all 16 design engineering invariants from the original design handoff (Section 7.1) plus the addendum's 10 engineering invariants (Section 7.4), including the required `.selection-toolbar__btn:disabled` rule (Closure A); verify `#999` label contrast and other tokens in rendered output, not just token math; keep the deterministic no-native-dialog scan at 0 across every new surface, including the unsaved-navigation-guard modal and the Sync Metadata modal; keep `npm run build` (`tsc -b && vite build`) green; keep `vitest` green, including new frontend tests for the atomic batch-write outcomes, the clear-blanks toggle, Contact Info collapse, and Sync Metadata; keep `cargo build`/`cargo test` green.

## 10. Interfaces and data

- **New Rust Tauri commands, devbridge routes, and TS client wrappers:** metadata-preset CRUD (create/list/update/delete); a single atomic, transactional multi-image batch-write command carrying the per-field tri-state (set-to-value / explicitly-clear / leave-untouched), shared by panel multi-select Save, Metadata Preset apply, and Sync Metadata. **Refactored:** `update_image_iptc` (single-image partial semantics, extended fields). **Reused unchanged:** `get_catalog_image`, `get_catalog_images`, the import commands. **Not changed this phase:** the export command (Track E deferred; no export-side metadata writing exists in this phase).
- **Schema V5:** additive columns on `images`, plus a new `metadata_presets` table whose representation supports the per-field tri-state contract; `CURRENT_VERSION` moves from 4 to 5.
- **New dependencies:** for Track D (import-time embedded-IPTC read, in scope this phase): `img-parts` (or `nom-exif`) plus a small XML parser (`quick-xml` or `roxmltree`). **Deferred to the future Track E phase, not required for this phase's gate:** `xmp-writer` and low-level use of the `tiff` crate's `DirectoryEncoder` for export-time embedding. All versions must be pinned; `cargo build --release` should be run early after any new crate is added.
- **Compatibility:** preserve the single `Mutex<Connection>`, WAL mode, the zero-IPC slider loop, and the linear working space invariants; keep `cargo build` and `npm run build` green; do not regress P2 or P3, or the develop-recipe presets routing.

## 11. Acceptance and validation

- `npm run build` (`tsc -b && vite build`) passes; `vitest run` passes, including new metadata-panel, metadata-preset, Sync Metadata, unsaved-navigation-guard, and Contact-Info-collapse frontend tests, and the Track A/B/C Rust unit tests.
- The single-image backend partial-write guarantee is proven by test: a per-image update that omits a field leaves that column unchanged; an explicit empty string clears it (the FINDING-1 guarantee, Section 9.2).
- The atomic batch-write guarantee is proven by test: an induced mid-batch failure leaves every image in the batch unchanged (no partial application); a successful batch applies to every image; each of the three per-field tri-state outcomes (set-to-value, explicitly-clear, leave-untouched) is verified.
- Sync Metadata acceptance: the source image's own fields are unchanged after a sync; only user-selected fields are copied; default field-selection state matches the addendum specification; an induced atomic-failure preserves all field/source selections for retry; the full keyboard-only journey passes; the toolbar button is disabled (with visible Closure A styling) when 1 or 0 images are selected.
- Unsaved-navigation-guard acceptance: all three modal actions (Keep Editing, Discard Changes, Save and Continue) behave per Section 7.4 Addendum Item 1, including the error/rollback state with all touched values preserved.
- Preset clear-blanks acceptance: both toggle states are exercised, including the "Will clear" preview line and the tri-state apply semantics.
- Contact Info collapse acceptance: default-collapsed is verified at both required viewports; collapsed-dirty and collapsed-mixed indicators are visible without expanding the disclosure.
- The deterministic no-native-dialog scan of `src/` (`alert(`/`confirm(`/`prompt(`/`window.*`/`beforeunload`) stays at 0, including on the unsaved-navigation-guard and Sync Metadata modals.
- An independent, read-only **Verifier PASS is required** before completion is claimed — writer or judge evidence alone is never sufficient.
- A **Browser Validator PASS via the tauri-driver native backend is required** for this rendered-UI work (Section 12).
- This phase's gate carries **no export-related acceptance check**; Track E is deferred (Section 9.5) and is out of scope for this document's completion criteria.

## 12. Browser UI dialog policy and validation

### 12.1 Dialog policy (required)

Native Tauri/WebView2 desktop target. Prohibited: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`. The metadata-preset delete confirmation, the unsaved-navigation-guard prompt, and every other acknowledgement, must be an app-owned `useModalA11y` modal, or inline validation. The deterministic no-native-dialog scan must stay at 0. Modal keyboard/focus verification is required for the Metadata Preset Management modal and its nested delete-confirmation, the unsaved-navigation-guard modal, and the Sync Metadata modal.

### 12.2 Browser UI validation (required)

Reuses the P2/P3 tauri-driver infrastructure, already authorized.

- **Launch/readiness:** `npm run dev` (`scripts/dev-server.js`, a dynamic free-port wrapper, default port 1420, with an inline `--config` override that does not mutate `tauri.conf.json`). For plain-browser catalog images, also run devbridge (`cargo run --manifest-path src-tauri/Cargo.toml --bin devbridge --features devbridge`; Axum on `http://localhost:7777`; process CWD must be the project root).
- **Backend/target surface:** tauri-driver native backend (2.0.6 plus msedgedriver matched to the host WebView2 runtime), one backend per `target_surface`. WebDriver capabilities must use `alwaysMatch` `tauri:options` (`firstMatch` is silently ignored). Target-bound identity verification (specificity floor plus PID cross-check), fresh-run provenance, and fail-closed behavior are all required. Reference `photo-genie/test-assets/TAURI-DRIVER-SETUP.md`.
- **Viewports:** 1440x900 (matches `tauri.conf.json`) and 1920x1080 — both required.
- **Fixture/reset:** reuse `test-assets/SEED-PROCEDURE.md`. The P4 fixture additionally needs: at least one image with populated legacy IPTC (title/caption/copyright/creator); at least 3 images selectable as a multi-selection with deliberately differing field values, with the P3 anchor retained inside `selectedLibraryImageIds` so it is available as Sync Metadata's default source; at least one image with embedded IPTC/XMP already in the file (for the import-read track); at least one saved metadata preset with at least one blank field (to exercise the clear-blanks toggle); and an empty-presets state. Provide a copy-pasteable clean-and-reseed sequence to the Browser Validator.
- **Journeys with visible outcomes:**
  - (a) Single-image edit: dirty state, Save, success, live-region fires, persists across reload.
  - (b) Multi-select with 3+ images with differing values: mixed-value fields render inert with the assistive-technology companion string; typing into one mixed field shows only that field's "will update N" tag/accent and makes it the only key sent on the atomic batch-write Save; untouched, differing fields are verified **unchanged** post-save. This is the direct browser-observable proof of the FINDING-1 backend fix and the atomic batch-write contract; a clobber or a partial application here is a **blocking regression**.
  - (c) Open Manage Metadata Presets → create → duplicate-name inline error (not native; case-insensitive exact-match rejection per the resolved preset-name-uniqueness decision, Section 14.2) → edit → delete via the nested standard-tier confirmation → focus lands on "+ New Metadata Preset".
  - (d) Apply a metadata preset to a multi-selection with the clear-blanks toggle OFF: the preview shows only "Will set: …"; blank preset fields are left untouched on target images. Repeat with the toggle ON: the preview additionally shows "Will clear: …"; blank preset fields are explicitly cleared on target images. Neither run auto-saves before Apply is pressed.
  - (e) Select a metadata preset in both `ImportDialog` tabs: the dropdown disables once import starts; imported images carry the preset's fields.
  - (f) Import a file with embedded IPTC: its metadata populates the panel.
  - (g) Sync Metadata full journey: with 3+ images selected, open the modal, confirm the P3 anchor is the default source, change the source via the "Change source" `role="radiogroup"`, select fields (verifying the default ON/OFF split), confirm the live preview, apply, and confirm the success announcement; verify the source image's own fields are unchanged and only the selected fields changed on the other images.
  - (h) Modal keyboard/focus for the preset modal and its nested confirmation, the unsaved-navigation-guard modal, and the Sync Metadata modal (Tab trap, Escape topmost or mapped to the safe default, initial/return focus).
  - (i) Unsaved-navigation guard: dirty a field, then change the selected image or leave the panel; confirm the modal opens with "Keep Editing" focused; exercise Discard Changes (fields revert, announcement fires), Save and Continue (the atomic write succeeds, navigation proceeds, announcement fires), and an induced-failure retry path (the error banner appears, all touched values are preserved, "Retry Save and Continue" is offered).
  - (j) Contact Info collapse: verify default-collapsed on initial render at both viewports; dirty a Contact Info field while collapsed and confirm the "Contact Info ({N} unsaved)" indicator appears without expanding; verify a mixed-only state (zero touched, one or more mixed) shows "Contact Info (mixed values)"; expand and collapse via keyboard (Enter/Space) and confirm DOM order, not CSS order, still governs Tab order when expanded.
  - (k) Reduced motion; cross-viewport repeat of (a), (b), (c), (i), and (j) at both viewport sizes; no field is ever hidden (Contact Info stays single-column unless width allows the optional two-column pairing, and remains reachable regardless of collapse state); every new field label renders `#999`, not `#777`; no user-facing bare "Preset" without the "Metadata" qualifier; no copy anywhere implies metadata is written to export files or to originals.
- **Deterministic no-native-dialog scan** on all new code paths (0 stays 0), with special attention to the preset delete confirmation, the unsaved-navigation-guard modal, and the Sync Metadata modal.

## 13. Risks and rollback

**Medium risk** (comparable to P3; below P2's data-durability stakes).

| Risk | Mitigation |
|---|---|
| Catalog data-integrity: the single-image partial-write and the new atomic batch-write command are the linchpin. A wrong implementation could NULL-clobber real IPTC fields across a multi-selection, or partially apply a multi-image batch. | The `COALESCE`/dynamic-`SET` contract for single-image writes; the atomic all-or-nothing transaction for batch writes; dedicated Rust unit tests for both (omit-vs-empty, and induced mid-batch failure/rollback); the browser journey (b) as a blocking check; a recommended `CODE_REVIEW` on both paths. |
| Atomic transactional batch-write correctness (new, this revision): an incorrectly-scoped transaction could leave a batch partially applied despite the "all-or-nothing" contract. | An induced-failure rollback test (Section 9.2, Section 11) plus a recommended `CODE_REVIEW` on this command (Section 8). |
| Sync Metadata copying the wrong fields across images, or corrupting the source image. | Per-photo-content fields (Title/Headline/Caption-Description) default OFF; the live pre-apply preview; a dedicated source-image-unchanged verification; atomic rollback on failure (Section 9.9). |
| The tri-state clear-blanks path can clear populated target fields if misapplied. | Default OFF; explicit opt-in required; the "Will clear" preview line, distinguished by text and weight, never color alone; dedicated tests for both toggle states (Section 9.3, Section 11). |
| New dependency risk (`img-parts`/the XML parser for Track D's import-time read). | Pin versions; run `cargo build --release` early; pure-Rust, no DLL. (`xmp-writer` and the `tiff` crate's `DirectoryEncoder` are deferred to the future Track E phase and carry no risk to this phase's gate.) |
| Naming collision with the existing develop-recipe Preset feature. | Distinct `MetadataPreset`/`metadata_presets` naming and "Metadata Preset" copy (invariant 4). |
| Accessibility: new labels/focus tokens, and the addendum's new components (`.pg-checkbox`, `.pg-disclosure`), must not regress the disclosed pre-existing gap. | New labels use the passing `#999`; new-field focus uses `#4b7bec`; the disclosed pre-existing gap (original-4 `#777` label / `#555` focus) is not regressed but is also not obligated to be fixed (addendum invariant 9). |
| Stale-plan condition. | This plan becomes stale if photo-genie `HEAD` changes materially, if the images/collections schema or the `update_iptc`/import/`CollectionToolbar` surfaces change before execution, or if any assumption or decision in Section 14 is withdrawn; a stale plan requires re-planning or explicit re-approval. |

**Rollback/containment:** additive schema (V5, no existing column altered); additive CSS/classes only; each track is independently revertable; Track E is not implemented this phase, so there is nothing to roll back there; standard git revert within `photo-genie`; no commit or push without a separate, explicit approval.

## 14. Assumptions and decisions the user owns

### 14.1 Safe assumptions (planner judgment, not user-gated)

- `DESIGN_ROUTE` Standard, consistent with the parent plan's own P4 pre-classification and unchanged by the Section 7.4 addendum.
- The catalog is the sole source of truth; this phase writes metadata to no file on disk, neither originals nor exports (Section 2.1, Section 2.2).
- XMP-only embedding, no legacy IIM — resolved by planner judgment, consistent with Sections 2.1 and 4.2 (Section 14.2).
- Metadata preset names are unique, checked case-insensitively, following the P3 collection-name precedent — resolved by planner judgment (Section 14.2).
- Engineering mode is standard (T1 first-line, T2 on escalation), each with Verifier and Browser Validator gates.
- Track D (import-time embedded-IPTC read) remains separable from the rest of P4 if a tighter phase is wanted.

### 14.2 Resolved decisions, confirmed at the Section 17 approval gate on 2026-07-19

This subsection records eight decisions this plan specifies: two resolved by planner judgment during an earlier revision (a shadow-mode `PLAN_DUCK` finding), and six resolved by the user, as relayed by the orchestrator, following a bounded Design Director addendum that passed a second independent design review (Section 7.4). The user explicitly approved this complete, expanded version, and each of these eight resolutions, at the Section 17 gate on 2026-07-19; engineering work, in any track, is authorized to begin.

**Resolved by planner judgment (prior revision, `PLAN_DUCK` finding):**

- **Metadata preset name uniqueness — RESOLVED.** Preset names must be globally unique. A duplicate is rejected with the inline `duplicate_name_error` state already described for the Metadata Preset Management modal (Section 7.1) and exercised in browser journey 12.2(c). The comparison follows the P3 collections precedent exactly: a case-insensitive exact-match check against existing metadata-preset names, performed client-side, blocking create and rename on collision.
- **Legacy IPTC-IIM embedding UI vs. XMP-only — RESOLVED.** P4 is XMP-only; there is no legacy IPTC-IIM embedding and no IIM UI surface. This matches the already-binding language in Sections 2.1 and 4.2 and the research rationale that the Creator Contact Info block has no IIM equivalent and modern consumers prefer XMP (Section 6).

**Resolved by the user, as relayed by the orchestrator, and confirmed at approval on 2026-07-19 (this revision):**

- **Decision 1 — Unsaved-navigation guard: WARN/GUARD via an app-owned modal.** Full specification in Section 7.4, Addendum Item 1. Replaces the former open decision on this topic.
- **Decision 2 — Preset clear-blanks: a user option, default OFF.** Full specification in Section 7.4, Addendum Item 2, including the backend tri-state contract requirement. Replaces the former open decision on preset field-membership.
- **Decision 3 — Free-form metadata sync: confirmed IN SCOPE as the new Sync Metadata feature (Track I).** Full specification in Section 7.4, Addendum Item 4, with full acceptance checks in Section 9.9 and Section 11. Reverses the former non-goal (Section 4.2) and the former open decision that had assumed this stayed out of scope.
- **Decision 4 — Contact Info: collapsible, default collapsed.** Full specification in Section 7.4, Addendum Item 3; this overrides the original design handoff's "never default-collapsed" instruction (Section 7.1). Replaces the former open decision on the Contact Info collapse/expand affordance.
- **Decision 5 — Batch writes: one atomic backend call, not N sequential per-image calls.** A single atomic, transactional multi-image batch-write command, carrying the per-field tri-state from Decision 2, replaces the previously-specified per-image sequential-calls model and its "partial (M of N)" outcome everywhere it appeared (panel Save, preset apply, Sync Metadata); see Section 9.2, Section 10. Replaces the former open decision on an atomic endpoint versus N sequential calls.
- **Decision 6 — Export XMP embedding (Track E): deferred to a future phase.** P4 now ships catalog-only IPTC editing this phase (Section 2.1, Section 2.2, Section 9.5); this is a flagged deviation from the parent plan's one-line P4 acceptance ("persist to the catalog and to export," Section 1.1), delivering the catalog half now and deferring the export half. The research behind the pure-Rust embedding stack (Section 6) is retained as forward input for that future phase and is not consumed by this phase's gate. Replaces the former open decision on XMP export-embedding feasibility/timeline.

### 14.3 Open decisions the user owns — none remain

All eight decisions surfaced across this plan's revisions are recorded as resolved above (two by planner judgment, six relayed from the user). **This list is empty.** Any further decision the user wishes to change requires a new revision of this plan, not an edit to this section alone.

### 14.3a Engineering-implementation follow-ups (not user decisions)

Two items remain that are engineering-implementation judgment calls, not user decisions, and do not block approval:

1. Implementing the `.selection-toolbar__btn:disabled` rule (Closure A, Section 7.4) is required before the Sync Metadata button ships; it is a mandatory engineering acceptance item (Section 9.9, Section 9.10), not a contingency.
2. Whether the Sync Metadata "Change source" `role="radiogroup"` needs virtualization for a very large selection is an implementation detail for engineering to resolve during Track I, consistent with the addendum's specification.

### 14.4 Remaining approvals

Any commit, push, pull request, or deployment remains separate and later, per Section 4.2 and Section 17, regardless of this plan's now-APPROVED status.

## 15. Judge route (recap)

As stated in Section 8: an orchestrator-run `PLAN_DUCK` checkpoint (advisory, shadow mode) is recommended for this plan at Medium risk, given the backend write-path data-integrity work and the schema migration. A `CODE_REVIEW` checkpoint remains recommended during implementation on: the atomic batch-write/tri-state command and the Sync Metadata write path (Section 9.2, Section 9.9); the `update_iptc` single-image partial-write refactor (Track B); and the V5 migration (Track A). The export-embedding `CODE_REVIEW` recommendation moves to the deferred future phase (Section 9.5) and does not apply to this phase's gate. Deterministic test/build failures, the independent Verifier pass, and the Browser Validator pass always dominate any judge opinion; the contract's call caps and shadow policy are respected; no live smoke calls occur without a separate, explicit usage approval.

### 15.1 PLAN_DUCK disposition (prior revision, closed)

A shadow-mode `PLAN_DUCK` pass reviewed an earlier revision of this plan and returned one finding, folded into this plan's binding structure and disposed of below. This was the single permitted judge-remediation loop of that kind for this plan and is now closed.

| Finding | Severity | Remediation in this plan |
|---|---|---|
| Open-decision-vs-already-assumed contradiction on preset-name uniqueness and IIM/XMP scope | Medium (plan-consistency) | An earlier revision listed "metadata preset name uniqueness" and "legacy IPTC-IIM embedding UI" as open decisions the user owns, while Sections 2.1, 4.2, and the P3-precedent assumption already effectively settled both. Resolved by planner judgment: preset names are unique, case-insensitive exact-match, rejected inline on collision (Section 14.2); embedding is XMP-only, no IIM (Section 14.2). |

### 15.2 Second independent design review disposition (this revision)

A bounded Design Director addendum (Section 7.4), specifying Decisions 1-4's UI-bearing items and the atomic-write/export-deferral consolidation (Decisions 5-6), was independently reviewed a second time. `DESIGN_REVIEW_RESULT = PASS`, with two advisory closures folded in as binding.

| Closure | Severity | Remediation in this plan |
|---|---|---|
| A | Low-Medium | `.selection-toolbar__btn` has no `:disabled` CSS rule (independently re-verified, `CollectionsModals.css:298-311`); add `.selection-toolbar__btn:disabled { opacity: 0.4; cursor: not-allowed; }` before the Sync Metadata button ships (Section 7.4, Section 9.9, Section 9.10). |
| B | Low-Medium | The Sync Metadata modal must render in the P2 `.pg-modal-dialog`/`.pg-modal-dialog--wide` shell, reusing only `AddToCollectionPicker.tsx`'s interaction pattern, not its `.pg3-modal-overlay`/`.pg-modal` shell classes (Section 7.4, Section 9.9). |

Route classification remains Standard; this addendum did not introduce any new hex value and reuses the P3 anchor/toolbar model and the `.pg-*` kit. Deterministic build/test failures, the independent Verifier pass, and the Browser Validator pass always dominate any judge or design-review opinion; this disposition does not itself constitute or substitute for the user's approval at Section 17.

## 16. Engineering mode and downstream ownership

**Engineering mode:** standard (T1 first-line, T2 on escalation; each with independent Verifier and Browser Validator gates). No extreme-advisory-team justification is present for this phase.

**Team authorization:** not applicable.

**Downstream owner:** Scribe (this plan) → the user's explicit approval of this exact, expanded version at the Section 17 gate was given on 2026-07-19 → the engineering fleet (T1) now proceeds, with this approved plan path as `ENGINEERING_JOB.approved_plan`. No agent message, including any relayed by the orchestrator, substituted for that approval; Section 14.2's resolutions were confirmed by that approval, not a substitute for it.

## 17. Approval gate

**This gate is satisfied.** This plan's Status line (Section 1) reads **APPROVED — 2026-07-19, approved by user directly to the orchestrator.** This version reflected a materially expanded scope versus the previously-circulated draft (Section 2.2): a new Sync Metadata feature, a backend atomic-write contract change, and deferral of Track E export-XMP embedding out of this phase's gate (a flagged deviation from the parent plan's one-line P4 acceptance line, Section 1.1). Because of that expansion, this exact version required the user's fresh, explicit approval, not carryover of any earlier intent or of any agent's relay of intent — and that fresh, explicit approval has now been given.

The user explicitly approved this exact plan directly to the orchestrator, in the live conversation turn immediately following the orchestrator's presentation of the six decisions, the new Sync Metadata feature, the atomic-batch-write contract change, and the Track E deferral. That approval confirms acceptance of all eight resolutions recorded in Section 14.2 (the two planner-judgment resolutions and the six decisions relayed this revision) and of the expanded scope in Section 2.2, including Track I Sync Metadata (Section 9.9), the atomic-batch-write contract (Decision 5, Section 9.2), and the deferral of Track E export-XMP embedding (Decision 6, Section 9.5). **Engineering may now proceed against this exact plan version.** This plan authorizes the work in Sections 4-15 as P4 implementation only — it does not authorize P5-P7 of the parent plan, and it does not authorize any commit, push, deployment, or pull request; those each remain a separate, later, explicit user approval. The orchestrator may now pass this plan's path as `ENGINEERING_JOB.approved_plan` to the engineering fleet.

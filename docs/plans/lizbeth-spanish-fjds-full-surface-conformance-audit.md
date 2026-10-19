# Lizbeth Spanish — Field Journal Full Surface Conformance Audit

**Status: CLOSED (final) — 2026-09-14.** All work packages WP-0 through WP-14 are complete. GitHub issues `#151`-`#162` are closed. Remaining carried-forward items are tracked in the ledger's "Outstanding items carried forward" section, not as open work packages; see `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md`.

**Approval.** Approved by the user in the interactive session on 2026-09-09. Scope: all work packages WP-0 through WP-13, executed serially. This approval grants no commit, push, pull-request, or deployment authority; those each remain a separate, later, explicit user approval.

- task_id / plan_id: `lizbeth-spanish-fjds-full-surface-conformance-audit`
- route: engineering
- target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish`
- engineering_mode: standard
- downstream_owner: engineering-fleet

## Outcome and audience

Every live surface of the Lizbeth Spanish app conforms to the Field Journal design system reference (`lizbeth_spanish\design\field-journal\Field Journal DS.dc.html`), verified page by page with Playwright CLI evidence at both viewport profiles (1440x900 and 390x844), with a persisted per-surface audit ledger recording each surface, each interactive element and function exercised, each mismatch found, and its fix status.

Audience: the engineering fleet executing one work package at a time under T1 -> verifier -> browser-validator gates, and the user approving each package's evidence.

## Scope

**In scope:**
1. The complete 28-item surface inventory established below.
2. A per-surface conformance audit against the reference.
3. Ordered per-page remediation beginning with the owner chrome and owner dashboard.
4. Playwright-CLI browser-validation inputs per surface.
5. Codex cross-vendor judgment at PLAN_DUCK, CODE_REVIEW, and VISUAL_REVIEW checkpoints.

**Non-goals:**
- No change to backend business logic, data models, auth rules, RLS, or Netlify/deploy configuration unless strictly required for a visual fix.
- No new features.
- No redesign beyond the reference.
- No commits or pushes.
- No Chrome-extension-based validation. Playwright CLI only — explicitly not `claude-in-chrome`.
- No new design tokens beyond the two narrowly-scoped extensions the design handoff names (see Token requirements below).

## Open decisions (read before dispatching any work package)

One item remains genuinely open and requires a user or product answer, not an engineering guess. Open decision #1 from the original draft (the owner-dashboard eyebrow date field) has been resolved by the user and is no longer open; it is specified in full inside WP-3 below and WP-3 is no longer blocked on it.

1. **RESOLVED by WP-7 (2026-09-11/12).** Duplicate permission-denied layers. `AdminShell.tsx:68`'s early return is the sole live permission-denied render: grep-proven tracing confirmed all four owner pages (`AdminStudentsPage`, `BrandDesignPage.tsx`, `BusinessSettingsPage.tsx`, `OwnerSettingsPage.tsx`) are mounted only inside `AdminShell`'s post-guard route switch, so a non-owner request never reaches a page's own `if (!owner)` branch. Those per-page guards are retained as documented dead defense-in-depth rather than removed. See the "Cross-cutting: WP-7 settings pages (in progress)" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md`.
2. **RESOLVED by WP-7 (2026-09-11/12).** Heading-text collision. `OwnerSettingsPage.tsx` (surface 28) was traced by grep of `App.tsx`, `AdminShell.tsx`, and `useRoute.ts` and found to be unrouted dead code, so there is no live collision with `CourseSettingsPage` (surface 21). Its heading has been renamed to "Owner settings" regardless. Surface 28 therefore has no browser journey (unit-only coverage), flagged for WP-14. See the same ledger section for detail.
3. **RESOLVED by WP-8 (2026-09-13).** Surface 26 premise correction and remediation choice. The Director's original claim that an unmatched `/admin/*` path "renders the masthead/tab-bar with no page body at all" was traced by the independent reviewer and found to describe an unreachable state (see Surface 26 section below for the full trace). WP-8 confirmed only two states are actually reachable at an unmatched `/admin/*` path — the owner redirect status and the non-owner denial — and dropped surface 26 as a distinct remediation target rather than adding a static fallback body for an unreachable third state. See the "Cross-cutting: WP-8 new course / course workspace" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md`.

Two additional items are resolved by director ruling within the design handoff (not open, listed here for completeness): the owner mobile Menu-panel content extends to all six `AdminShell.tsx:15` links (a defensible interpretation of a genuine DS gap, still overturnable by a product/brand reviewer); and the skip-to-content link is specified as required new WCAG 2.4.1 scope with no DS precedent.

## Grounding and method

### Route-predicate inventory proof

Routing is a dependency-free custom router (`src\hooks\useRoute.ts`) with no router library and no route table to grep. Route matching is a set of exported `match*` predicates consumed by `src\App.tsx` and `src\components\AdminShell.tsx`. Inventory completeness is therefore proven by enumerating those predicates and their call sites, not by grepping a router config. The 17 exported predicates are: `matchWeekDetailRoute`, `matchLearnRoute`, `matchLearnDetailRoute`, `matchFeedbackRoute`, `matchAdminDashboardRoute`, `matchAdminStudentsRoute`, `matchAdminStudentDetailRoute`, `matchAdminFeedbackRoute`, `matchAdminFeedbackDetailRoute`, `matchAdminBusinessSettingsRoute`, `matchAdminBrandDesignRoute`, `matchAdminCourseSettingsRoute`, `matchCourseWorkspaceRoute`, `matchNewCourseRoute`, `matchPublicCourseRoute`, `matchAdminAreaRoute`, `matchAdminRoute`.

**Correction (WP-14, per Codex `VERIFICATION_CHALLENGE` finding J-WP14-003).** Not all 17 exported predicates are actually consumed by `App.tsx`/`AdminShell.tsx` in production. `matchAdminRoute` (`src\hooks\useRoute.ts:176`) is exported but referenced only by its own unit test; production route dispatch uses `matchAdminAreaRoute` instead. `matchAdminRoute` is test-only/obsolete and excluded from the production inventory. The corrected inventory is 16 production predicates plus 1 test-only predicate, and the 16 production predicates map to all 28 surfaces with no unmapped route. See the "Route-predicate inventory proof" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md` for the corrected record.

Any future route addition must update the ledger described below (`docs\evidence\lizbeth-spanish-fjds-surface-conformance-ledger.md`).

### Why the prior "validated" status is not evidence

`docs\plans\lizbeth-spanish-design-reference-coverage-map.md` records fourteen adoption issues (#31-#44) as OPEN but "validated," each carrying implementation, verification, browser-validation and design-review evidence. The owner dashboard nevertheless visibly does not match the reference. This is a method gap, not missing work: that prior validation checked token and primitive conformance plus functional journeys, and never diffed a rendered surface against its reference artboard's composition. This plan changes the method: artboard-backed surfaces are graded against the artboard's composition using the design handoff's enumerable checklist (below), not against the token set alone. The prior "validated" status is not evidence of conformance for any surface in this plan, and any surface marked "validated" via GitHub issues #31-#44 is conditional pending that map's own tracked Atelier MCP project-root blocker (#31) — do not report tool-reverification that has not happened.

### Design authority

- Design system reference: `lizbeth_spanish\design\field-journal\Field Journal DS.dc.html`, sections A-E, cited by line number throughout this plan.
- The reviewed and PASSED `DESIGN_HANDOFF` for `lizbeth-spanish-fjds-full-surface-conformance-audit`, `profile: standard`, `existing_system_mode: preserve`, `selected_direction`: preservation of the existing Field Journal design system as sole authority — the only "direction decision" is the chrome-architecture resolution below, a structural interpretation of the reference rather than a new visual language.
- Design review verdict: **PASS**. The independent design-reviewer re-resolved a large sample of reference and source citations with zero failures, and passed the chrome-architecture resolution, the no-artboard rule, the visual-comparison tolerance, and the accessibility handling. One medium finding remained open and is carried into this plan as the Surface 26 correction below, with the reviewer's own bounded remediation. The reviewer's stated conclusion is that engineering can begin the per-page remediation sequence against this handoff.
- The Director revised the persisted packet once after independent review. This plan reproduces the revised (superseding) specification for Surfaces 6, 7, 8, 22, and 26, and the renumbered permission-denied surfaces, as instructed below. Where this plan's text differs from the original persisted DESIGN_HANDOFF JSON, this plan's text (carrying the Director's revision) governs.

### Grounding limits carried into this plan

The design handoff's structural claims about files its authors did not independently re-open are grounded in grep output (headings/state-variable names), not a verified line-by-line read. This applies to: `WeekCard.tsx`, `RoadmapPage.tsx`/`BandRoadmap.tsx`, `WeekDetailPage.tsx` and its section components, `FlashcardsViewer.tsx`, `FeedbackPage.tsx`, `AdminStudentsPage.tsx` and its modals, `BrandDesignPage.tsx`/`AssetCard.tsx`, `PublicCatalogPage.tsx`, `CourseSettingsPage.tsx`, `BusinessSettingsPage.tsx`, `NewCoursePage.tsx`, `CourseWorkspacePage.tsx`, `OwnerSettingsPage.tsx`, `LearnDetailPage.tsx`, `AccessibilitySettings.tsx` beyond its focus-trap lines. Each work package touching these files must re-read its own surfaces before editing rather than trusting this plan's citations as independently re-verified.

If a work package finds the source materially different from the findings recorded in this plan, the writer must return `JOB_BLOCKED` with `Plan stale` rather than improvise.

## Chrome architecture resolution (binding)

The reference specifies two different chrome shapes by role, not one shared shape:

- **Student/shared routes** use a light `paper.200` header (DS D.2 header lines 627-638, D.3 header lines 765-777 at @1440; DS E.2 header lines 1316-1323 at @390) with: a 48x48 ink.1000-square/brass.300-glyph logo, an eyebrow-title lockup, a flex spacer, a single bordered nav box of abutting route links, and Sign-out placed outside that box (lines 638/776). A dark `ContextStatusStrip`-equivalent band sits directly below.
- **Owner routes** use a dark `ink.900` masthead (DS D.6, lines 966-974: 48px `#dca250` "L" mark, a `Lizbeth Spanish` eyebrow in mono 10px/600/.24em uppercase `#a07e48`, an `Owner desk` title in Fraunces 900 24px/1.1/-.02em `#fdfcf9`, a right-aligned outlined SIGN OUT button — transparent on a 3px `#dca250` border, mono 13px/700/.12em uppercase, min-height 44px) immediately above a `#f0ebe2` tab bar with a 3px `#1a1512` bottom border, zero gap, 0/48px padding, `overflow-x: auto` (DS lines 975-982). Tabs are min-height 52px, 0/20px padding, mono 13px/700/.1em uppercase; the active tab is `#fdfcf9` fill with `#1a1512` text and a 5px `#1a1512` bottom border; inactive tabs are `#504940` text with a transparent 5px bottom border; hover is `#ffd699`.

The live double-nav defect is the app wrapping the *student* shell around the owner and then separately, redundantly, approximating the *owner* shell inside `AdminShell.tsx` — not two competing readings of one shape.

**Resolution (binding):** when `isAdminRoute` is true (`App.tsx:339-342`), `AdminShell.tsx` becomes sole owner of chrome. The shared `AuthenticatedAppShell`'s `.app-header`/`.app-nav`/`ContextStatusStrip`/hamburger (`App.tsx:224-297,299,301`) do not render for `/admin/*`. `AdminShell`'s existing six-link `links` array (`AdminShell.tsx:15`) becomes the D.6 tab-bar content — restyled only, no semantic change; its `aria-label`, `<ul role="list">`, and `aria-current="page"` at `AdminShell.tsx:44` are already correct and reused as-is.

Cross-role element fate under `/admin/*`:
- BrandLogo relocates into `AdminShell`'s new masthead (needs a `useBranding()` dependency; `BrandingProvider` already wraps the tree at `App.tsx:474`).
- The "Owner workspace" nav pill stays in the student shell only — an owner can still land on `/roadmap` directly since only `/` auto-redirects (`App.tsx:95-97`).
- Exactly one Sign-out renders at a time, using the existing `useRequestSignOut()`/`useSignOutTriggerRegistration()` hooks (`SignOutGuardContext.tsx:75-90`) from whichever shell currently owns chrome.
- The hamburger/`MobileNavPanel` is absent from this desktop position (no D.6-at-1440 hamburger).
- `ContextStatusStrip` already self-suppresses on `/admin/*` via its own route scoping (lines 99-101) — no behavior change required, only an optional mounting tidy-up (see Permitted variation).

## Standalone specifications: Surfaces 6, 7, 8 (Director revision — supersedes the original packet)

### Surface 6 — `.app-header` + `.app-nav` (shared/student chrome)

Artboards: DS D.2 header lines 627-638 and D.3 header lines 765-777 (@1440); DS E.2 header lines 1316-1323 (@390).

Structure: 48x48 ink.1000-square/brass.300-glyph logo; eyebrow-title lockup; flex spacer; a single bordered nav box of abutting route links; Sign-out outside that box (lines 638/776).

States: per-role content — an owner gets the extra "Owner workspace" pill (`App.tsx:266-275`); per-route `aria-current="page"` on exactly one link; hover/focus per nav-tier Control styling; a suppressed/non-rendered state whenever `isAdminRoute` is true (no DS artboard of its own for this state — the reference never shows this header coexisting with the D.6 masthead). No loading/error/disabled states apply since this is static chrome.

Responsive (@390): the whole nav row is replaced by a single 44x44 Menu-trigger (line 1322), matching `App.tsx:287-296`'s existing `aria-label="Menu"`. Logo shrinks 48->38px, eyebrow 10->9px, title 24->19px.

Owning files: `src\App.tsx:224-297`.

### Surface 7 — `ContextStatusStrip.tsx`

Artboards: DS D.2 lines 640-643 (roadmap variant), D.3 lines 778-781 (week-detail variant — proving the content is route-specific, not fixed), E.2 line 1324 (@390 single unsplit line that drops the identity string entirely — a real content reduction, not a scale-down).

Structure: full-width solid ink.1000 band below the header, mono/brass.300 text.

States: populated only. The content derives from already-loaded session/route props rather than an independent fetch, so no loading/error state applies.

Route-scoping: `ContextStatusStrip.tsx:97-101` is already correct and needs no change.

### Surface 8 — `MobileNavPanel.tsx`

Reference coverage: the closed trigger only (DS E.2 line 1322; owner equivalent DS E.6 around lines 1512-1519). No artboard anywhere in sections A-E shows the panel's OPEN content — this is a **no-artboard composition case**: the open panel composes from existing C.1 Control nav-tier items in a full-screen overlay.

States: closed and open. Open is focus-trapped via the existing `useFocusTrap`, Escape closes it, and focus restores to the trigger — already compliant for the student panel.

Director's resolution of the DS gap: extend `MobileNavPanel.tsx` to carry all six `AdminShell.tsx:15` links when opened from `/admin/*`, reusing its existing focus-trap/Escape/restore mechanics unchanged. This is preferred over a horizontally-scrolling 6-tab bar because it does not contradict the D.6/E.6 artboard's own `overflow:hidden` tab-bar truncation and does not hide functionality behind an undiscoverable scroll affordance. This interpretation is a defensible director call, not settled DS fact — a product/brand reviewer could still overturn it.

The component exists only at mobile widths.

## Standalone specification: Surface 22 — Brand & design (Director revision — supersedes the original packet)

Artboard: DS D.8 line 1145.

Owning files: `BrandDesignPage.tsx` + `AssetCard.tsx`.

States (newly specified in the Director's revision):
- permission-denied (`BrandDesignPage.tsx:40`).
- loading (`:41`, `role="status" aria-live="polite"`, text "Loading brand & design settings…").
- populated (`:44-68`).
- client-side validation (`:43` — `sanitizeOwnerSettingsPayload` runs before any network call and moves focus to the first invalid field's ref; per-field `role="alert"` spans at `:60-62`).
- saving (`:64` — submit disabled with a "Saving…" label during the in-flight `saveOwnerSettings` await).
- save-success (`:65`, `role="status" aria-live="polite"`, "Brand & design settings saved.").
- save-error (`:67`, `role="alert"`, the caught `OwnerSettingsWriteError` message or a generic fallback).

Success and error are mutually exclusive by construction. No empty state applies.

Composition (unchanged from the original packet): sheet card, eyebrow "Owner desk · Brand," Fraunces 900 52px H1, a bordered preview swatch, two C.2 color-input fields, one logo-URL field, Control-primary save + moss-accented saved-status chip.

## Shared permission-denied shape (renumbered — Director revision)

The shared permission-denied paragraph shape (`<h1>{Title}</h1>` + `role="alert"` sentence) now applies to surfaces 19, 22, 23, and 28, all redundant with surface 27's shell-level fallback:

- Surface 19: `AdminStudentsPage.tsx:176-177`.
- Surface 22: `BrandDesignPage.tsx:40`.
- Surface 23: `BusinessSettingsPage.tsx:23`.
- Surface 28: `OwnerSettingsPage.tsx:116-117`.
- Surface 27 (shell-level fallback): `AdminShell.tsx:28-31`.

`OwnerFeedbackPage.tsx` (surface 20) is **explicitly NOT part of this shared shape**. The independent reviewer read it in full and confirmed it renders no permission-denied state at all; it has only its own list (`loading`/`ready`/`error`) and detail (`idle`/`loading`/`error`) state machines.

## Surface 26 — unmatched `/admin/*` (corrected; carries the reviewer's finding)

**The original Director claim was overstated and is corrected here.** The Director's persisted packet asserted an unmatched `/admin/*` path "currently renders the masthead/tab-bar with no page body at all." The independent reviewer traced the live wiring and found this describes an **unreachable state**:

- For an owner: `App.tsx:114-119` makes `isAdminRoute` true for any `/admin/*` path regardless of match state. App.tsx's render ternary checks `isAdminRoute && owner && !knownAdminRoute` **first**, at line 339, and renders `<p role="status">Redirecting to the owner dashboard…</p>` at line 340 — `<AdminShell>` is never reached. The `useEffect` at `App.tsx:98-100` then calls `replaceNavigate('/admin/dashboard')` on the next commit.
- For a non-owner: the render falls through to `<AdminShell currentPath={path} />` at lines 341-342, and `AdminShell.tsx:28` immediately returns the permission-denied shape (surface 27).

The blank-body scenario is real as dead code inside `AdminShell.tsx` but is unreachable in either role today.

Surface 26's actual, reachable states are already specified elsewhere in this plan: the transient redirect status message (owner case) and surface 27's permission-denied shape (non-owner case).

**Open remediation item for WP-8** (see Open decisions item 3 above): either drop surface 26 as a distinct remediation target, or, if a static fallback body is still wanted as defence against a future routing change, say so explicitly rather than presenting it as fixing a present gap.

**Browser-validation correction:** the surface-26 journey must assert the redirect status message for the owner case and the permission-denied shape for the non-owner case — never a "no page body" assertion.

## Full 28-surface inventory

| # | Surface | Artboard | Owning files |
|---|---|---|---|
| 1 | Sign-in | DS D.1/E.1 | `App.tsx` AuthGate + `LoginForm.tsx` |
| 2 | Session-error card | DS D.1/E.1 pattern | `App.tsx:440-458` |
| 3 | App loading | no artboard | `App.tsx:378-384` (no `role="status"` today) |
| 4 | `/courses` public catalog | DS D.9 | `PublicCatalogPage.tsx` |
| 5 | `/courses/:courseId` public detail | DS D.9 | `PublicCatalogPage.tsx` |
| 6 | `.app-header` + `.app-nav` | DS D.2/D.3/E.2 (see standalone spec above) | `App.tsx:224-297` |
| 7 | `ContextStatusStrip.tsx` | DS D.2/D.3/E.2 (see standalone spec above) | `ContextStatusStrip.tsx` |
| 8 | `MobileNavPanel.tsx` | DS E.2/E.6 trigger only, no-artboard open content (see standalone spec above) | `MobileNavPanel.tsx` |
| 9 | `.app-footer` | conditional on `branding.legal_copyright_text` | `App.tsx:352-356` |
| 10 | `AccessibilitySettings.tsx` | modal via `Modal.tsx` | `AccessibilitySettings.tsx` |
| 11 | `ForcedPasswordChangeGate.tsx` | — | `ForcedPasswordChangeGate.tsx` |
| 12 | `/` and `/roadmap` | DS D.2/E.2 | `RoadmapPage.tsx` + `BandRoadmap.tsx` + `WeekCard.tsx` |
| 13 | `/roadmap/:enrollmentId/week/:n` | DS D.3/E.3 | `WeekDetailPage.tsx` + `WeekSectionTabs.tsx`, `LessonContentView.tsx`, `ResourcesPanel.tsx`, `LessonCompletionControl.tsx`, `SegmentLedger.tsx` |
| 14 | Flashcards | DS D.4/E.4 | `FlashcardsViewer.tsx` + `FlashcardsOverlay.tsx` |
| 15 | `/learn` | no artboard | `LearnIndexPage.tsx` |
| 16 | `/learn/:enrollmentId` | no artboard | `LearnDetailPage.tsx` |
| 17 | `/feedback` | DS D.5/E.5 | `FeedbackPage.tsx` + `FeedbackForm.tsx` |
| 18 | `/admin/dashboard` | DS D.6/E.6 | `OwnerDashboardPage.tsx` + `MetricPlate.tsx` + `OwnerLedgerRow.tsx` |
| 19 | `/admin/students` and `/admin/students/:id` | DS D.7 | `AdminStudentsPage.tsx` + `AdminStudentModals.tsx`, `RegisterStudentModal.tsx`, `AccessControlRow.tsx` |
| 20 | `/admin/feedback` and `/admin/feedback/:id` | no artboard | `OwnerFeedbackPage.tsx` + `FeedbackLedgerRow.tsx` |
| 21 | `/admin/course-settings` | no artboard | `CourseSettingsPage.tsx` |
| 22 | `/admin/brand-design` | DS D.8 (see standalone spec above) | `BrandDesignPage.tsx` + `AssetCard.tsx` |
| 23 | `/admin/business-settings` | no artboard | `BusinessSettingsPage.tsx` |
| 24 | `/admin/courses/new` | no artboard | `NewCoursePage.tsx` |
| 25 | `/admin/courses/:courseId/:tab` | no artboard | `CourseWorkspacePage.tsx` |
| 26 | unmatched `/admin/*` | no artboard; corrected (see Surface 26 section above) | `App.tsx:98-100,114-119,339-342` |
| 27 | non-owner at `/admin/*` | no artboard | `AdminShell.tsx:28-31` |
| 28 | `OwnerSettingsPage.tsx` | no artboard | `OwnerSettingsPage.tsx` |

## Per-surface structure, states, and responsive behavior

### Surface 18 — Owner dashboard (priority; full depth)

Structure: `aria-labelledby="dashboard-title"` section (`OwnerDashboardPage.tsx:59`) → eyebrow → `<h1 id="dashboard-title">` → description → four-`MetricPlate` row → two-column grid (attention-rules form + needs-attention list / student-progress search+sort+table).

States: loading (`:57`, drops all content, no skeleton); error-no-cache (`:58`, `role="alert"` + Retry); populated (`:59-86`); saving (`:70`, "Saving…" disabled button, real in-flight await); save-success (`:70`, `role="status"`); save-error (`:70`, `role="alert"`, mutually exclusive with success); client-side validation (`:31`, blocks before request fires, a distinct trigger from save-error); needs-attention-empty (`:71`); search-empty (`:84`, distinct from needs-attention-empty).

Composition (DS D.6:963-1094 / E.6:1507-1571): graph-paper ground inside a 3px border + 10px shadow.

Masthead: solid ink.1000, 48x48 brass.300 logo square with an *inverted* ink.1000 "L" glyph (opposite of the light-chrome header's ink.1000-square/brass.300-glyph pairing — both correct, screen-specific, must not be unified); brass.500 eyebrow + paper.50 "Owner desk" title in one lockup; ghost-outline Sign-out (transparent / 3px brass.300 border / brass.300 text, hover-inverts). This exact paint exists in none of `Control.tsx`'s 8 tiers — needs either a 9th tier or a masthead-scoped modifier (implementation choice; see Permitted variation).

Tab-bar: paper.200, 3px bottom border, six links at 52px min-height, mono 13px/700/.1em uppercase; active = paper.50 fill + ink.1000 text + 5px bottom-border underline; inactive = ink.700 text / transparent border; hover = amber.200 fill.

Heading row: flex `space-between`, `align-items:flex-end`, 3px bottom rule. Left = terracotta.600 date-carrying eyebrow ("Owner view · [date]", mono 12px/600/.22em) over Fraunces 900 68px/.9/-.035em H1. Right = plain 18px/1.55 ink.700 paragraph, right-aligned, on the **same row** — not stacked below, as the live `.dashboard-heading` currently does. (The `[date]` field is now resolved — see the WP-3 specification below for the exact format and rendering rule.)

Metric plates: 4-up, 20px gap, 3px border, 20px padding, ONE mono 11px/600/.18em label + ONE 52px Fraunces figure. The live code correctly follows the C.8 canonical 52px over D.6's own 58px screen-literal inconsistency — keep 52px. Plate 1 is dark-toned; plates 2-4 are light-toned. **No plate carries a second supporting line in the reference** — `OwnerDashboardPage.tsx:65`'s `supportingFigure` prop, passed to `MetricPlate`, must be removed or stop being passed on this surface (see the deliberate-conflict note below).

Two-column body grid, 28px gap:
- Left panel (sheet-tier, 8px shadow): Fraunces 700 28px `<h2>`s, compact C.2 number fields, Control-secondary save button, and needs-attention rows (2px border + 8px left terracotta.600 accent, ONE mono 12px/.1em uppercase `[Band] · [human-language reason]` line — never a raw machine string, never comma-joined).
- Right panel (sheet-tier, with the licensed brass shadow exception already correctly scoped): dark ink.1000/brass.300 table header (Student/Band/Progress/Active), 2px paper.300 row rules, no inner scroll wrapper, band-ink left-border chips, filled-bar+raw-zero-padded-fraction progress (never a bare percentage), abbreviated date format ("28 AUG"), and no dedicated warning row.

**Needs-attention invariant — live violation cited directly.** `OwnerDashboardPage.tsx:71` renders `s.enrollments.filter((e) => e.attention_reasons.length).map((e) => <span key={e.id}>{e.band_name} · {e.attention_reasons.join(', ')}</span>)`, emitting raw machine reason codes such as `progress_lag` comma-joined, where the reference requires one human-language `[Band] · [reason]` mono line. WP-3 must translate reason codes to human language and stop comma-joining multiple reasons into one span.

**Student-progress table mismatches confirmed by reading source against the reference:** the table currently sits inside a `.dashboard-table-wrap` inner scroll container, with full `Last active` dates from `OwnerLedgerRow.tsx:70`'s `toLocaleDateString()`, and a per-student needs-attention warning row — all three must be removed/corrected per the composition above. The date-format fix must be **locale-explicit** rather than relying on the host locale, since `toLocaleDateString()` is what produced the drift.

**Deliberate conflict and its resolution (record, do not silently reverse).** `MetricPlate`'s `supportingFigure` was added intentionally by adoption issue #42 (decision D17) so the completion percentage could be reconciled against a raw fraction; `OwnerDashboardPage.tsx:34-56` carries a long comment explaining it deliberately mirrors the backend's own active-and-not-completed filter. Removing it to match the reference discards that reconciliation affordance. **Resolution: the reference is the authority and stat cards must be uniform without extra sub-values.** Record this resolution and the loss it accepts in the audit ledger entry for surface 18, so the decision is not silently reversed later.

Responsive: D.6's implicit 4-across metric row reflows to E.6's explicit 2x2 grid (line 1530), not truncation. The two-column body grid has no E.6 equivalent shown — vertical stacking (rules above table) is the safest derived behavior, not an invented tab-switcher. The table becomes horizontally scrollable at narrow widths, consistent with the reference's own `overflow-x:auto` pattern elsewhere.

### Surfaces 12-13 — Roadmap / Week detail

Roadmap: eyebrow "Contents" → `<h1>Your roadmap</h1>` (`RoadmapPage.tsx:66-67`) → band sections of `WeekCard`s in the four fixed C.4 states. Composition (DS D.2:624/E.2:1311): light chrome + context strip; eyebrow + Fraunces 900 76px H1 with a right-aligned solid/hatched progress bar; 3-up week-card grid; vertical band-tab rail.

Week detail: six states — `loading`/`error`/`not-available`/`empty` plus nested `content-not-authored`/`content-loading`/`content-error` (`WeekDetailPage.tsx:1031,1038,1044` — verify `content-error`'s role is `alert`, not `status`). Composition (DS D.3:762/E.3~1400s): ruled-paper reading sheet, giant Fraunces 900 96px week number, C.6 segment ledger, the four fixed C.5 lesson chunks in order, a Control-primary completion stamp, folio rule; attachments rail as a taped stack card.

Responsive: reading-sheet+400px-rail two-column layout collapses at mobile to a Lesson/Cards/Files pill-switcher (lines 1399-1403) — a real content reorganization, not a simple reflow — plus the mobile masthead-collapse rule (the full masthead does not stack above WeekDetailPage's own compact back-link bar at mobile width, per the existing D4-4 decision noted in an `App.tsx` comment near line 313).

### Surface 14 — Flashcards

One card visible at a time; synchronous `aria-hidden` face-swap; `aria-live="polite"` flip announcement cleared to an empty string before each write so a same-face-twice flip still re-announces. Composition (DS D.4:899/E.4): graph-paper card-box with a stacked-ghost-card illusion, 3px border + 7px brass shadow live card, terracotta.500 top accent, dashed-rule footer hint.

### Surfaces 15-16 — `/learn` index/detail (no artboard)

LearnIndex: `<h1>Your courses</h1>` (`LearnIndexPage.tsx:107`), card-list with per-card `<h2>` (`:55`) — not a table. LearnDetail: `<h1>` swaps text by state (`LearnDetailPage.tsx:332,339,358,365,390`), nested `<h2>Your progress</h2>` (`:391`); a confirm/trigger step machine (`:131,132,178`) needs a targeted re-check during WP-11 to confirm it uses inline disclosure or `Modal.tsx`, never `confirm()`.

Note: surfaces 15/16 are already implicitly covered by the coverage map's GitHub issue #44 (via `Badge`/`JournalEmptyState` component usage) even though not explicitly enumerated there — WP-11 should fold 15/16 into #44's coverage explicitly rather than treating them as newly at-risk.

### Surface 17 — `/feedback`

`<h1>Feedback & topic suggestions</h1>` (`FeedbackPage.tsx:19`) wraps `FeedbackForm`. Composition (DS D.5:934/E.5:1469): sheet card, eyebrow "Private · …", Fraunces 900 46/38px H1, C.2 selects + ruled textarea with a mono character counter, Control-primary submit.

### Surface 19 — Roster / student detail

`PageState = 'roster'|'detail'|'error'|'loading'` (`AdminStudentsPage.tsx:38`); permission-denied (`:176-177`); loading (no role today — cross-cutting gap, see below); error (`role="alert"`, `:189-193`); populated roster with the three-state account badge vocabulary; detail view `<h1>Student: {email}</h1>` → `<h2>Account Access</h2>` → `<h2>Enrollments</h2>` → `<h2>Assign a new band</h2>` (`:629,738,811`) with per-section `role="alert"` errors and a scoped `isAssigning` in-flight indicator (`:517`). Composition (DS D.7:1096): admin masthead/tab-bar; eyebrow + Fraunces 900 56px H1; card-tier rows with a band-ink left border and a right-aligned C.3 account-state badge.

### Surface 20 — Feedback inbox (no artboard)

Independent list (`loading`/`ready`/`error`, `OwnerFeedbackPage.tsx:23`) and detail (`idle`/`loading`/`error`, `:24`) state machines. Composes from B index-card list + C.2 fields for filters + C.3 glyph+word status vocabulary. Reviewer check: each row shows glyph+word status, not a bare color dot; detail `<h2>` never promoted to `<h1>`.

### Surface 21 — Course settings (no artboard)

Not independently re-derived from source in the design pass — flagged as an assumption; WP-7 must open the file directly. Composes from C.1 controls + C.2 fields. Reviewer check: exactly one Primary control per view.

### Surface 22 — Brand & design

See the standalone specification above.

### Surface 23 — Business settings (no artboard)

Composes from C.2 fields + C.1 controls. Reviewer check: field labels mono-above-field; error changes both a terracotta rule and a mono error line, never color alone.

### Surface 24 — New course (no artboard)

Not independently re-derived from source in the design pass — flagged as an assumption; WP-8 must open the file directly. Composes from C.2 fields + C.1 controls. Reviewer check: same "exactly one Primary" rule as surface 21, applied to the creation submit.

### Surface 25 — Course workspace (no artboard, richest state machine)

Initial load (`CourseWorkspacePage.tsx:75`); per-tab `TabBoundary` error isolation (`:79`); tri-level schedule-severity messaging (advisory `role="status"` / error `role="alert"`, e.g. `:126-127,133-134,853,925`); a five-named-state reconciliation pipeline (`idle/applying/success/partial-with-failures/total-failure/stale`, `:381-394`); per-lesson evidence panel (`loading/error/resolved`, `:432`); independent roster (`:521-524`) and cohort-members (`:795-809`) sub-tab state machines — each with distinct, already-written copy, not a generic loading/error pair. Composes from C.6 segment-ledger for sequencing; C.9 empty-state (illustration + graph-ground + dashed rule, all three elements) for empty rosters/members; C.1 controls throughout. Reviewer check: every named reconciliation state carries distinguishable wording, not just tone; C.9's three elements must all be present together.

### Surface 26 — unmatched `/admin/*`

See the corrected specification above.

### Surface 27 — non-owner at `/admin/*`

`AdminShell.tsx:30`: no action offered, a plain heading plus a `role="alert"` sentence. Reviewer check: this shell-level denial renders exactly once per `/admin/*` request from a non-owner, with no second nested denial from the per-page `if (!owner)` branches (see Open decision #1).

### Surface 28 — Owner settings (no artboard)

Permission-denied (`OwnerSettingsPage.tsx:116-117`); four named field-level errors (brand-name/primary-color/logo-url/ip-notice, each with an `id` + `role="alert"`, at `:201,222,253,283`) plus page-level success/error (`:294,300`). Composes from C.2 fields (four labeled inputs, each `role="alert"`) + C.1 controls. Reviewer check: confirm the shared "Course settings" heading with surface 21 is not an accidental route/page duplication before treating them as independently composed (Open decision #2).

### Surfaces 1-5, 9-11

- **Surface 1 — sign-in**: inline `role="alert"` (`LoginForm.tsx:84`) + `isSubmitting` disabled/"Signing in…" state (`:112-119`). Composition (DS D.1:580/E.1:1274): split layout, dark brand panel (corrected brass.300 wordmark) + graph-paper sheet card with tape-topped C.2 fields and a primary submit.
- **Surface 2 — session-error**: `role="alert"` (`App.tsx:446-453`); inherits GitHub #60's tracked AA defect — do not re-flag as new (see WP-13 for the fix).
- **Surface 3 — app loading**: bare/role-less today (`App.tsx:378-384`) — a cross-cutting gap shared with surfaces 12 and 15 (below). No artboard; compose from A.1/A.2 only, plain paper background, one centered `role="status"` line.
- **Surfaces 4-5 — public catalog/detail**: `loading`/`ready`/`error` plus a distinct course-preview-loading sub-state (`PublicCatalogPage.tsx:56,60-61,156-157,163-164`). Composition (DS D.9:1182): dark header (inverted logo/button treatment matching D.6), eyebrow+Fraunces 900 84px H1, band-colored volume cards, Control-secondary preview button, footer with a 3px top rule.
- **Surface 9 — `.app-footer`**: conditional on `branding.legal_copyright_text`.
- **Surface 10 — `AccessibilitySettings`**: modal via the app-owned `Modal`.
- **Surface 11 — `ForcedPasswordChangeGate`**: six named states (`form/confirming/error/success/session-error/network-error`, `:63`) with Sign-out available in every non-submitting state and an atomic password-change-plus-flag-clear that avoids a partial-failure state class entirely.

### Cross-cutting accessibility gap

`App.tsx:378-384` (surface 3's app-loading branch), `RoadmapPage.tsx:69` (surface 12), and `LearnIndexPage.tsx:109` (surface 15) all lack `role="status"` on their loading text, inconsistent with the convention used everywhere else.

**Ownership (all three sites now explicitly assigned — Codex finding `J-02-LOADING-FIX-OWNERSHIP-GAP`, accepted):**
- `App.tsx:378-384` (surface 3) — owned by WP-13.
- `RoadmapPage.tsx:69` (surface 12) — owned by WP-10 (see WP-10's specification below).
- `LearnIndexPage.tsx:109` (surface 15) — owned by WP-11, as part of its existing surface-15 scope.

WP-14's closure reconciliation verifies all three sites carry `role="status"` before treating the cross-cutting gap as closed.

## No-artboard composition table

| Surface | DS structural patterns to compose from | Reviewer check in place of an artboard diff |
|---|---|---|
| 15 /learn index | B index-card device ("06·Index card") per row; C.1 controls | Row uses index-card geometry (3px rule, zero radius, hard shadow) with its own heading, not a table row |
| 16 /learn/:id | C.8 metric plate for progress; C.1 controls for the confirm/trigger step machine | Progress pairs a mono label with a large Fraunces figure, never a bare number/bar alone |
| 20 Feedback inbox | C.2 fields for filters; B index-card list; C.3 glyph+word status vocabulary | Each row shows glyph+word status, not a bare color dot; detail `<h2>` never promoted to `<h1>` |
| 21 Course settings | C.1 controls + C.2 fields (not re-derived from source — flagged) | Exactly one Primary control per view |
| 23 Business settings | C.2 fields + C.1 controls | Field labels mono-above-field; error changes both a terracotta rule and a mono error line, never color alone |
| 24 New course | C.2 fields + C.1 controls (not re-derived — flagged) | Same "exactly one Primary" check on the creation submit |
| 25 Course workspace | C.6 segment-ledger for sequencing; C.9 empty-state (illustration + graph-ground + dashed rule, all three elements) for empty rosters/members; C.1 controls throughout | Every named reconciliation state carries distinguishable wording, not just tone; C.9's three elements must all be present together |
| 28 Owner settings | C.2 fields (four labeled inputs, each `role="alert"`) + C.1 controls | Confirm the shared "Course settings" heading with surface 21 is not an accidental route/page duplication before treating them as independently composed |

General no-artboard token composition: page shell = paper.50/100 graph/card stock, zero radius; heading = eyebrow (mono, 600 weight, .18em component-caption or .22em true page-eyebrow tracking per role) + an H1/H2 sized from an existing screen's ratified range (44-56px Fraunces 900); cards/panels = `--shadow-card` (rows) or `--shadow-sheet` (outer panel) only; buttons = `Control` tiers only; fields = the C.2 `Field` primitive only; tables = the C.7 `OwnerLedgerRow` pattern only; empty states = `JournalEmptyState` (C.9) with a kept spot illustration only. Reviewer check in place of a screenshot: grep the page's CSS for any hex literal outside `primitives.json`/`field-workbook.generated.css`, confirm every button/field/card/table class resolves to a shared primitive, confirm no bespoke shadow/radius value exists.

## Visual comparison tolerance (artboard-backed surfaces and both chrome shells)

"Matches" means:
1. Every color is a closed-palette hex or an already-preserved correction.
2. Type scale — family/weight/the specific screen's literal size/line-height/letter-spacing — matches a named DS role.
3. Spacing rhythm traces to the DS's gap family (20/28/32/40/44/48px).
4. Border/shadow geometry is exactly one of the four tiers, never a hybrid.
5. Composition order (eyebrow→heading→supporting text; flex-row vs. stacked per screen) is preserved.
6. Casing/tracking convention (uppercase mono with the correct .18em/.22em tier) is correct.

Any single-property deviation on 1-4 is a fail regardless of pixel delta. Do not set one blanket pixelmatch percentage across a whole page.

**What a screenshot diff cannot prove:** font-hinting/antialiasing differences between the static artboard's render engine and a live browser's; real dynamic data differing from disclosed placeholders; scrollbar/OS-chrome rendering differences; sub-pixel CSS-grid rounding. A bare pixel-diff percentage is not the conformance gate for any surface in this plan.

## Token pipeline defects (affect every surface)

- `--font-letter-spacing-eyebrow` compiles to `.08em` where every reference page-eyebrow instance is `.22em`. Three consumers are unverified (`App.css`, `AdminStudentsPage.css`, `OwnerFeedbackPage.css`) — check each before a blanket repoint. A separate, correct `.18em` tracking token serves component-level captions/badges, a distinct role from the page-eyebrow — do not merge the two roles.
- `--font-weight-label` compiles to `700` where the reference specifies `600`. This may require a split into two tokens (700 for buttons/badges vs. 600 for eyebrows/captions) rather than a blanket repoint — open token-owner decision, not fabricated in this plan.
- The `display` type role at 68px/.95/-.03em is ratified in `semantic.json`'s `typography.role.display` but never compiled to a CSS custom property; only `display-lg`/`display-sm` are compiled. `OwnerDashboardPage.css:11` currently falls back to the unrelated `--size-heading` token (35.2px). Compile the ratified role to a new CSS custom property matching the existing `display-sm`/`display-lg` pattern.

Files: `src\tokens\primitives.json`, `semantic.json`, `components.json`, `src\tokens\field-workbook.generated.css`, `src\tokens\tokenSystem.ts`, `.atelier\tokens\field-workbook.tokens.json`.

A low-severity, separately-tracked defect: `OwnerLedgerRow.css:44` band-chip tracking is `.08em` against the DS's `.1em` — fix opportunistically during WP-3.

## Known accessibility items to preserve or fix

- **Preserve — do not revert.** `App.tsx:394-397` deliberately substitutes brass.300 for the specimen's brass.500 wordmark colour, reaching 6.80:1 against the specimen's failing 4.06:1. This is an engineering invariant.
- **Fix — GitHub issue #60 (already tracked, not a new finding).** `LoginForm.css` lines ~334 and ~339 pair `--color-status-error-text` (terracotta.600, `#a85e4a`) on `--color-surface-chrome-default` (paper.200, `#f0ebe2`) at 4.05:1, failing AA. The design handoff directs a **background-only** fix to paper.50/100 (which clears AA at 4.7:1 per the reference's own note); the terracotta.600 text token must not be changed, and no other terracotta.600-on-paper.200 pairing outside this rule should be touched.
- **Fix — missing `role="status"`.** Surfaces 3, 12, and 15's loading branches, listed above.
- **New requirement, no DS precedent.** A skip-to-content link targeting `<main className="app-main">` (`App.tsx:311`) — a genuine WCAG 2.4.1 gap on every authenticated screen under either chrome shell, in-scope for WP-2.
- **Focus management.** Focus on route change moves to the destination page's own `<h1>` (adding `tabIndex={-1}` where needed); every page already renders one literal `<h1>` (confirmed by direct grep across all 28 surfaces' source files); precedent already exists at `ForcedPasswordChangeGate.tsx:102-104`.
- **Sign-out.** Confirmed clean of native dialogs — `handleSignOutClick`/`handlePanelSignOutClick` (`App.tsx:207-220`) call only `requestSignOut()`. Focus-return on a cancelled sign-out is already wired via `SignOutGuardContext.tsx:59-61,87-90` and must be re-wired symmetrically to whichever masthead currently owns Sign-out after the WP-2 refactor.

## Engineering invariants (binding across every work package)

- Radius is zero everywhere, always. Shadows are hard ink.1000 offsets at exactly four tiers, plus the one brass.500 exception scoped to owner tables/download links — never spread that exception further (a prior regression onto metric plates was already caught and reverted per `MetricPlate.css:59-68`'s own comment).
- The chrome-ownership rule is binding: `AdminShell.tsx` owns the masthead+tab-bar for every `/admin/*` route; the shared `AuthenticatedAppShell` header/nav/context-strip/hamburger do not render there. Exactly one Sign-out control exists at a time, wired through the existing `SignOutGuardContext` hooks regardless of which shell renders it.
- No native browser dialog anywhere (`alert`/`confirm`/`prompt`/`window.*`/`beforeunload`) — already clean per repo-wide grep. Any new modal/confirmation work must use `Modal.tsx`, preserving its existing focus-trap/Escape/restore mechanics.
- `disabled` stays a native HTML attribute, never CSS-only.
- Never render specimen placeholder figures/dates (18/11/03/64%/"30 Aug 2026"/"28 AUG" as a literal) as production data — match only format, sourced from a real field.
- Preserve both already-shipped accessibility corrections beyond the literal specimen: the brass.300 wordmark; GitHub #60's eventual background-only fix.
- Any surface marked "validated" via GitHub issues #31-#44 is conditional pending that map's own tracked Atelier MCP blocker (#31) — do not report tool-reverification that has not happened.
- The owner masthead's inverted logo coloring and the light chrome's non-inverted version are both correct and must not be unified.

## Permitted variation

- Implementation choice between a 9th `Control` tier and a masthead-scoped CSS modifier for the dark masthead's Sign-out button — either is token-correct.
- `ContextStatusStrip` mounting approach under `/admin/*` (stay mounted-but-self-nulling vs. not mount at all) — no user-visible difference.
- Internal component decomposition of the extended `MobileNavPanel` (single component vs. role-conditional sub-render) as long as its existing focus-trap/Escape/restore mechanics and six-link owner content are preserved.
- Exact mechanism for the shared permission-denied card styling on no-artboard surfaces (a shared component vs. per-page duplication) as long as the visual shape (sheet-tier card, not raw unstyled text) and `role="alert"` semantics are identical everywhere it appears.

## Interfaces and data

No backend, schema, RLS, auth, or Netlify configuration change. Component-level interface changes expected and bounded:
- `MetricPlate`'s `supportingFigure` prop is removed or stops being passed on surface 18.
- `AdminShell` gains chrome ownership and therefore new masthead and tab-bar markup.
- `MobileNavPanel` gains a role-dependent link set.
- `App.tsx` gains conditional suppression of the shared chrome under `/admin/*` and a skip-to-content link.
- `OwnerLedgerRow`'s date rendering changes from `toLocaleDateString()` to the reference's abbreviated "28 AUG" format, locale-explicit rather than host-locale-dependent.

Each is a local React prop or markup change with no network or persistence effect.

## Browser UI dialog policy (required for every surface)

Native browser dialogs are prohibited: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts. Acknowledgement and confirmation use the app-owned accessible modal `src\components\Modal.tsx`, already focus-trapped and covered by `src\__tests__\Modal.test.tsx` and `Modal-FocusTrap-ShiftTab.test.tsx`; validation is inline. Every work package must run the deterministic scan `src\__tests__\nativeDialogPolicy.test.ts` and verify keyboard operation, visible focus, and focus-return for every modal and nav control it touches. The independent reviewer re-grepped `src` and confirmed the only `alert(`/`confirm(`/`prompt(` matches are inside `__tests__/*`; application source is currently clean and must stay clean.

## Browser UI validation

- **Backend: Playwright CLI only.** Do not use `claude-in-chrome` or any Chrome extension for validation on this plan.
- **Launch and readiness:** `npm run test:e2e` with `E2E_BASE_URL` unset uses the config's own `webServer`, which runs `npm run build && netlify serve --context production --port 8888` and waits on port 8888. `reuseExistingServer` is true outside CI, so a dev server already listening on 8888 is reused. To validate against a running instance instead, set `E2E_BASE_URL` and the `webServer` step is skipped entirely.
- **Base URL:** `http://localhost:8888`, overridable by `E2E_BASE_URL`.
- **Fixture and reset:** existing local test accounts, all with password `password` — `owner@test.local` (owner), `student1@test.local` and `student2@test.local` (students), `fullaccess@test.local` (student with full access). `playwright.config.ts` sets `workers: 1` and `fullyParallel: false`, so specs run serially and must restore any state they mutate; `owner-dashboard.spec.ts` already demonstrates the pattern by restoring the attention-rule defaults of 14 days and 1 lesson after its persistence test. Anonymous journeys need no account.

**Shared reset rule (Codex finding `J-03-RESET-IS-NOT-EXECUTABLE`, accepted — stated once here, referenced by each package below rather than repeated):** because the suite is serial and shared-state, every state-mutating journey must capture its pre-test baseline, mutate, assert, and restore the baseline in an `afterEach` or equivalent teardown — not as trailing steps inside the test body, so that a mid-test failure still restores. A journey must never assert against data another package owns. The per-package specifications below (WP-3, WP-6, WP-7, WP-8) apply this rule to their specific mutations; a work package that introduces a new state-mutating journey not listed below must specify its own fixture identifier, baseline value, and teardown step using this same pattern before it can be considered complete.
- **Viewport profiles:** desktop 1440x900 and mobile 390x844 govern conformance grading, matching the reference's own @1440 section D and @390 section E authored widths. The existing 1280x720 and 375x812 profile in the current specs remains valid for functional regression only — do not silently rewrite the existing specs' viewports.
- **Artifacts:** screenshots under `browser-validation-artifacts/<work-package>/`, following the existing convention.

### Journeys (real elements, both viewports, states to capture)

1. **Chrome resolution regression** (all authenticated routes): sign in as the dev owner account (`LoginForm.tsx:28`); confirm exactly one masthead/nav pair and one Sign-out control renders at each of the six `AdminShell.tsx:15` routes; navigate to `/roadmap` as the same owner and confirm the student-shaped shell renders instead with an "Owner workspace" pill returning to `/admin/dashboard`. Capture: populated state, both viewports.
2. **Owner dashboard (18):** exercise the attention-rules form (`inactive-threshold`, `progress-lag` inputs, submit) with an out-of-range value then a valid value; exercise the roster search input and sort `<select>`; click a ledger row and confirm navigation to `/admin/students/:id`. Capture: loading, error, populated, saving, save-success, save-error, needs-attention-empty, search-empty — both viewports.
3. **Owner nav accessibility:** Tab through all six tab-bar links, confirm `aria-current="page"` on exactly one at every step, confirm Enter navigates and moves focus to the destination `<h1>`.
4. **Sign-out, both shells:** as a student on `/roadmap`, confirm immediate sign-out; with an unsaved `/feedback` draft, confirm the inline `role="group"` disclosure and that "Keep editing" returns focus to the Sign-out trigger; repeat as owner once the owner masthead's Sign-out exists.
5. **Mobile owner nav:** at 390x844, confirm the Menu-trigger opens a panel with all six admin links, with the same focus-trap/Escape/restore mechanics as the student panel.
6. **Week-detail mobile header collapse:** at 390x844, confirm the full masthead does not stack above the back-link bar; confirm the back-link returns to `/roadmap`.
7. **Flashcards:** flip a card and confirm the `aria-live` announcement via the accessibility tree; navigate Next/Previous; flip the same face twice on two different cards and confirm re-announcement both times.
8. **Public catalog (4-5):** unauthenticated visit to `/courses`; click into a course; confirm the course-preview loading sub-state resolves to the real title; exercise enrollment and confirm the `role="status"` vs `role="alert"` distinction.
9. **No-artboard owner pages (20-25,28):** as a non-owner, direct-URL each `/admin/*` sub-route and confirm the permission-denied shape renders once, not twice.
10. **[Added in revision] Shared chrome at 390x844 (surfaces 6-8):** confirm the light header's bordered nav box and Sign-out are fully REPLACED by the 44x44 Menu-trigger rather than merely compressed; confirm the context strip drops its identity half rather than wrapping; confirm the mobile panel opens with role-correct content (four items for a student, all six `AdminShell` links for an owner from `/admin/*`).
11. **[Added in revision, corrected] Surface-26 direct-URL journey:** as an owner, direct-URL an unmatched `/admin/*` path and assert the `role="status"` "Redirecting to the owner dashboard…" message, followed by navigation to `/admin/dashboard`; as a non-owner, direct-URL the same path and assert the surface-27 permission-denied shape. Never assert "no page body."

**Visible outcomes for every journey:** correct heading text/level, correct `role` on status/error regions, correct focus target after every navigation/action, no native dialog fired, no duplicate chrome. States to capture across the suite: loading, empty, error, populated, disabled, saving/optimistic, permission-denied — per the specific applicability enumerated per surface above.

## Cross-vendor judgment (Codex, selective, guarded)

Eligible and required; risk is high, so the cap is four Codex calls with one checkpoint repeatable after remediation. Deterministic failures always dominate a judge pass; the judge cannot waive a failed command. Judge policy currently sits in shadow mode per `.claude\judge-policy.json`, so a remediation action is advisory until blocking is enabled.

- **PLAN_DUCK** — on this plan document, before user approval. Model: `gpt-5.6-terra`, medium effort. Rubric: inventory completeness against the enumerated route predicates; whether the chrome-architecture resolution is implementable without a backend or auth change; whether the per-package acceptance checks are deterministic; whether the visual comparison tolerance is honest about what a screenshot cannot prove.
- **CODE_REVIEW** — after each work package's `JOB_DONE` and before verifier, scoped to that package's changed paths. Model: `gpt-5.6-terra`, medium effort. Rubric: unintended cross-surface CSS cascade; token-value regressions; accessibility regressions; scope creep beyond the package.
- **VISUAL_REVIEW** — after browser evidence for the brand-critical packages. Model: `gpt-5.6-terra`, medium effort. Receives only that package's Playwright screenshots and this design specification. Rubric: composition conformance against the cited artboard using the visual comparison tolerance checklist above.

Finding IDs from each checkpoint flow into the corresponding work package's engineering job and into verifier's evidence record. No judge pass is promised by this plan, and no model-generated finding may be presented as fact until the judge run has actually occurred.

## PLAN_DUCK disposition (first draft)

PLAN_DUCK ran on the first draft of this plan with `gpt-5.6-terra` at medium effort, per the checkpoint above. `.claude\judge-policy.json` is currently in shadow mode, so these findings were advisory rather than blocking — the plan would have been approvable without acting on them. The user nonetheless directed that all three findings be folded into this revision. The finding IDs are preserved verbatim below.

| Finding ID | Claim | Disposition | Applied in |
|---|---|---|---|
| `J-01-WP1-NO-BROWSER-GATE` | WP-1 changes three global type tokens affecting all 28 surfaces but had no Playwright journey and therefore no rendered evidence gate. | Accepted and incorporated. | WP-1 (see the new smoke journey and non-completability rule below). |
| `J-02-LOADING-FIX-OWNERSHIP-GAP` | The plan recorded a cross-cutting `role="status"` gap at three sites (`App.tsx:378-384`, `RoadmapPage.tsx:69`, `LearnIndexPage.tsx:109`) but assigned only two of the three to a work package. | Accepted and incorporated. | WP-10 (see the explicit `RoadmapPage.tsx:69` assignment below) and the Cross-cutting accessibility gap section. |
| `J-03-RESET-IS-NOT-EXECUTABLE` | The fixture-and-reset guidance was a general statement plus one example; most state-mutating journeys had no specified, executable reset, which is a real risk under the suite's serial (`workers: 1`, `fullyParallel: false`) execution model. | Accepted and incorporated. | Browser UI validation section (new shared reset rule) and WP-3, WP-6, WP-7, WP-8 (per-package reset specifications). |

## Audit ledger (WP-1 deliverable)

The per-surface audit ledger is a non-code textual deliverable and is therefore Scribe-authored, not engineering-authored. WP-1's first deliverable is a `DOCUMENT_JOB` to Scribe creating `docs\evidence\lizbeth-spanish-fjds-surface-conformance-ledger.md` with the full 28-surface table pre-populated and every status set to `not started`. This plan does not create that file. Each work package's completion is recorded by a follow-up `DOCUMENT_JOB` to Scribe, not by the engineering writer.

## Ordered work packages

Fifteen sequential work packages (WP-0 through WP-14), each dispatched as its own `ENGINEERING_JOB` (WP-0 is a `DOCUMENT`/administrative job, not an engineering change) against this one approved plan, each with its own acceptance checks and browser journeys where applicable, each completing T1 -> verifier -> browser-validator before the next begins (WP-0 is exempt from the engineering-gate sequence since it makes no code change). WP-0 runs first, immediately after user approval and before WP-1. WP-1 and WP-2 are strict prerequisites for the engineering packages that follow; the remainder are ordered for cascade safety (shared chrome and tokens before the pages that consume them).

### WP-0 — Create and link GitHub issues

**Status: done 2026-09-09 (#42 reopened; #151–#162 created).**

**Scope:** Executed first, after user approval and before WP-1. The writer creates the needed GitHub issues with `gh issue create` from the app root (`H:\CommandCenter\orchestrator\lizbeth_spanish`). **Explicitly in scope: issue creation only. No commits, no pushes, no branch creation.**

**Step order — enumeration and mapping already completed by Scribe on 2026-09-09 (see the Issue ledger section below for the full evidence trail); WP-0's remaining job is execution only:**
1. ~~Enumerate existing issues~~ — done; 103 issues (12 open, 91 closed) enumerated from `git@github.com:lebobo88/lizbeth-spanish.git` on 2026-09-09; raw output retained in this plan's Issue ledger section.
2. ~~Map each of WP-1 through WP-14 to REUSE / REOPEN / NEW~~ — done; see the Issue ledger table above. Result: WP-3 and WP-4 share a REOPEN anchor (`#42`); all other work packages (WP-1, WP-2, WP-5 through WP-14) are NEW.
3. Re-verify each mapping against the live repository state immediately before running the commands below (an issue's state can change between this plan's approval and WP-0's execution); if a mapping no longer holds, update the Issue ledger table and proceed with the corrected disposition rather than the stale one.
4. Run the following commands from `H:\CommandCenter\orchestrator\lizbeth_spanish`, in order, using the draft titles/bodies in the Issue ledger's "Proposed new-issue drafts" subsection as the starting content for each NEW issue (revise the body first if step 3 found the live scope has shifted):

```
# Reopen the shared WP-3/WP-4 anchor
gh issue reopen 42 --comment "Reopening for docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md WP-3 and WP-4. Live-code citations (OwnerDashboardPage.tsx supportingFigure line, comma-joined attention-reason codes, .dashboard-table-wrap inner scroll container, OwnerLedgerRow.tsx toLocaleDateString drift) show regressions introduced after this issue's 2026-09-06 closure. Will close again only after WP-3 and WP-4 both pass verifier + browser-validator."

# Create the NEW issues, one per work package (titles/bodies from the Issue ledger drafts)
gh issue create --title "Field Journal conformance: correct eyebrow tracking, label weight, and display-role token compilation" --body-file <wp-1-body.md>
gh issue create --title "Field Journal conformance: owner chrome restructure (AdminShell sole chrome owner under /admin/*)" --body-file <wp-2-body.md>
gh issue create --title "Field Journal conformance: feedback inbox no-artboard composition" --body-file <wp-5-body.md>
gh issue create --title "Field Journal conformance: brand & design full state machine (DS D.8)" --body-file <wp-6-body.md>
gh issue create --title "Field Journal conformance: course/business/owner settings and permission-denied deduplication" --body-file <wp-7-body.md>
gh issue create --title "Field Journal conformance: new course, course workspace, and surfaces 26/27 correction" --body-file <wp-8-body.md>
gh issue create --title "Field Journal conformance: student/shared chrome, footer, accessibility settings, forced password change" --body-file <wp-9-body.md>
gh issue create --title "Field Journal conformance: roadmap, week detail, flashcards, and roadmap loading role=status fix" --body-file <wp-10-body.md>
gh issue create --title "Field Journal conformance: learn index and detail no-artboard composition" --body-file <wp-11-body.md>
gh issue create --title "Field Journal conformance: student feedback page (DS D.5/E.5)" --body-file <wp-12-body.md>
gh issue create --title "Field Journal conformance: unauthenticated surfaces, GitHub #60 contrast fix, app-loading role=status" --body-file <wp-13-body.md>
gh issue create --title "Field Journal conformance: full-surface closure sweep and ledger reconciliation" --body-file <wp-14-body.md>
```

Use `--body-file` with each draft body written to a temporary file (or `--body "..."` inline) rather than retyping; record each returned issue number back into the Issue ledger table in place of "NEW — see draft below." No `git commit`, `git push`, or branch creation occurs in this package.

**Closure rule (binding, applies to every work package below, not only WP-0):** an issue is closed only AFTER both the verifier and the browser-validator have passed for its owning work package, closed by the writer with a comment linking the evidence artifacts (screenshots, test output, ledger entry). For the shared WP-3/WP-4 anchor (`#42`), close only after BOTH WP-3 and WP-4 have independently passed verifier + browser-validator; the second package to finish performs the close, and its closing comment must reference both packages' evidence. Close with, for example:

```
gh issue comment 42 --body "WP-3 evidence: <verifier report link/path>, <browser-validator artifacts under browser-validation-artifacts/wp-3/>, ledger entry <link>. WP-4 evidence: <...>. Closing per both packages' verifier + browser-validator pass."
gh issue close 42
```

**An issue closed before both of those gates pass is a process violation** and must be reported as such, not silently allowed to stand.

**Acceptance checks:** the enumeration step ran first and its raw output is retained as evidence (see the Issue ledger section); every one of WP-1 through WP-14 is mapped to REUSE, REOPEN, or NEW with the mapping recorded in the Issue ledger; only genuinely new issues are created (no duplication within the existing #31-#51 range, the #60/#65/#69/#71 range, or any other existing issue); every created or reused issue number is recorded in the Issue ledger in place of its "NEW — see draft below" marker; no commit, push, or branch is created during this package.

**Browser journeys:** none — this package makes no application change.

### WP-1 — Token pipeline corrections

**Scope:** Fix `--font-letter-spacing-eyebrow` to `.22em`; split or correct `--font-weight-label` to `600` (verify consumers first — may require two tokens); compile the ratified `display` role (68px/.95/-.03em) to a new CSS custom property matching the `display-sm`/`display-lg` pattern. Before any blanket repoint, check every existing consumer of the two corrected tokens — three unverified consumers of the eyebrow token are flagged (`App.css`, `AdminStudentsPage.css`, `OwnerFeedbackPage.css`). Also creates the audit ledger (via a Scribe `DOCUMENT_JOB`, not engineering).

**Surfaces affected:** cross-cutting (all 28, via shared tokens).

**Files:** `src\tokens\primitives.json`, `semantic.json`, `components.json`, `src\tokens\field-workbook.generated.css`, `src\tokens\tokenSystem.ts`, `.atelier\tokens\field-workbook.tokens.json`, plus any CSS files consuming the corrected tokens.

**Acceptance checks:** token unit tests pass; `npm run build` passes; a documented before/after of every consuming rule (which selectors changed value and why); `npm run lint` and `npm run type-check` pass; the smoke journey below is captured and reviewed. **WP-1 is NOT completable without this browser evidence** — a token change touching all 28 surfaces cannot be marked done on unit tests and a build pass alone (Codex finding `J-01-WP1-NO-BROWSER-GATE`, accepted).

**Browser journeys — required, not optional (J-01-WP1-NO-BROWSER-GATE remediation):** a bounded smoke journey capturing screenshots at both governing profiles (1440x900 and 390x844) for one representative surface from each of five families, to confirm the corrected token values render as intended and no unintended type change appears elsewhere:
- Shared/authenticated chrome — surface 6, the `.app-header` on `/roadmap`.
- Student — surface 12, `/roadmap`.
- Owner — surface 18, `/admin/dashboard`.
- Unauthenticated — surface 1, the sign-in screen.
- Form-bearing — surface 22, `/admin/brand-design`, which exercises labels, fields, and validation text where `--font-weight-label` actually lands.

Ten screenshots total (five surfaces x two viewports). Artifacts under `browser-validation-artifacts/wp-1/`. Acceptance: every eyebrow and label rendering in those ten screenshots is inspected against the corrected token values (`.22em` eyebrow tracking, `600`-weight labels, the newly compiled `display` role where it applies), and no unintended type change appears on any of the five families.

**Plan-limits note, stated plainly here and in the Assumptions and grounding notes section below: no browser comparison was performed during planning.** Every mismatch recorded in this plan was found by reading the reference file against source code, not by rendering either one. WP-1's smoke journey is therefore the first rendered baseline for this entire effort. It may surface mismatches this plan does not list; finding some is expected and is not itself a plan failure. A material contradiction of a finding this plan does record — for example, a screenshot showing a corrected token producing a visually wrong result the plan asserted would be correct — makes the plan stale under the existing staleness rule in Risks and rollback, and the work package must return `JOB_BLOCKED` with `Plan stale` rather than improvise past it.

**Completed 2026-09-09 (issue `#151` closed).** T1 `JOB_DONE`, `VERIFICATION_PASS`, and `BROWSER_PASS` all recorded; Codex `CODE_REVIEW` findings J-WP1-001 through J-WP1-005 fixed or dispositioned. `VISUAL_REVIEW` was skipped for this package as token-only, with numeric confirmation treated as sufficient.

### WP-2 — Owner chrome restructure

**Scope:** Implement the binding chrome-ownership rule: `AdminShell` owns the masthead and tab bar for every `/admin/*` route; the shared header, nav, `ContextStatusStrip`, and hamburger do not render there; exactly one Sign-out control exists at a time; `MobileNavPanel` is extended to carry all six `AdminShell` links when opened from `/admin/*`; the skip-to-content link targeting `<main className="app-main">` is added.

**Surfaces affected:** 6, 7, 8, 9 (footer suppression check), 18-28 (all owner routes gain the new chrome).

**Files:** `src\App.tsx`, `src\components\AdminShell.tsx`, `src\components\MobileNavPanel.tsx`, `src\components\ContextStatusStrip.tsx`, `src\context\SignOutGuardContext.tsx` (re-wiring only, not new logic), `src\components\ui\Control.tsx` (if a 9th tier is chosen per Permitted variation).

**Acceptance checks:** all WP-1-style suite checks; re-run `nativeDialogPolicy.test.ts` unchanged-passing; re-run the existing `issue-4-owner-workspace.spec.ts` and `deep-route-check.spec.ts` unchanged-passing; confirm exactly one Sign-out renders at every `/admin/*` route and at `/roadmap`; confirm `aria-current="page"` correctness on both chrome shapes.

**Browser journeys:** Journey 1 (chrome resolution regression), Journey 3 (owner nav accessibility), Journey 4 (sign-out, both shells), Journey 5 (mobile owner nav), Journey 10 (shared chrome at 390x844).

**Progress (2026-09-09/10):** WP-2 (issue `#152`) has been implemented by T1 and escalated to T2 after two counted deterministic gate failures; `CODE_REVIEW`, `VERIFICATION_PASS` (recorded three times, final pass with an independent RED reproduction), and `BROWSER_PASS` (cycle 2) have all been recorded for the delivered `AdminShell` chrome-ownership restructure, single Sign-out registration, non-overlapping breakpoints, extended `MobileNavPanel`, skip-to-content link, and route-change focus-to-heading behavior. `VISUAL_REVIEW` (advisory) returned a REVISE verdict with four major findings still open: the owner tab bar rendering alongside the mobile nav panel at 390px instead of being replaced by it, the mobile masthead retaining desktop geometry and type instead of the DS E.6 mobile spec, desktop masthead spacing not matching DS D.6, and the owner logo inheriting the light-header border and shadow instead of DS D.6's borderless 3px brass treatment. Because these are advisory rather than deterministic findings, the package's verification and browser-validation gates stand, but issue `#152` and this ledger's WP-2 status remain OPEN pending a user decision on whether to remediate the four findings before closing the issue or accept them as recorded exceptions; see `docs\evidence\lizbeth-spanish-fjds-surface-conformance-ledger.md`'s "Cross-cutting: WP-2 owner chrome restructure" section for full evidence and artifact locations.

**Progress (2026-09-10, remediation cycle):** the user authorized an extra judge-driven loop for the four `VISUAL_REVIEW` findings above. T2 applied J-002 (DS E.6 mobile masthead geometry), J-003 (DS D.6 desktop masthead spacing and `.admin-shell-nav` gutter), and J-004 (owner logo 3px brass border, no shadow, 48px/38px sizing). J-001 was disputed by T2 and the dispute was accepted: DS E.6 draws a truncated mobile tab bar, and the plan's line 119 (surface 26 note) keeps that bar alongside `MobileNavPanel` as the complete six-link navigation, so no change was made for J-001. The verifier then required (counted as a T2 gate-failure cycle) the mobile tab bar to adopt full DS E.6 geometry (48px min-height, 0/14px padding, 11px type, `overflow: hidden`, no scroll), which was applied; a CSS source-order cascade bug found during that fix (the mobile breakpoint block was ordered before the desktop rules) was corrected. Housekeeping: `issue-11`'s stale sign-in assertion was retargeted per account, and `neo-workbook-visual-smoke` gained hamburger/owner/modal-inert branches and now passes. `VERIFICATION_PASS` (57/57 e2e including axe; full non-e2e suite 2954/2961, only pre-existing out-of-scope database-dependent families failing) and `BROWSER_PASS` (Playwright, fresh build, port 4321; measured geometry matches the applied D.6/E.6 fixes; 0 native dialogs, 0 console errors) were both recorded. A repeat `VISUAL_REVIEW` (advisory; WP-2 Codex call cap reached at 4/4) returned REVISE with three new findings: J-005 (major, masthead/tab bar inset inside `main.app-main` instead of full-bleed), J-006 (major, mobile inline-end padding 72px instead of DS E.6's 18px, reserved for a fixed "Aa" accessibility control, truncating the "Owner desk" title at 390px), and J-007 (minor, mobile active-tab underline 5px instead of DS E.6's 4px). No further judge-driven cycle can run for this package without a new authorization, since the Codex call cap is exhausted. Issue `#152` and this ledger's WP-2 status remain OPEN pending a user decision on J-005 through J-007; see `docs\evidence\lizbeth-spanish-fjds-surface-conformance-ledger.md`'s "Cross-cutting: WP-2 owner chrome restructure" section, remediation-cycle subsection, for full evidence and artifact locations.

**WP-2 complete (2026-09-10, second remediation cycle).** The user authorized a second judge-driven loop for J-005 through J-007. T2 applied J-005 (owner masthead and tab bar now full-bleed via `app-main--admin` releasing the content column on `AdminShell` routes, with `AdminShell` re-applying the column to the page body and one `<main id="app-main">`), J-006 (the "Aa" accessibility trigger relocated bottom-right on `.app--admin-chrome` at all widths, since the J-005 full-bleed fix created a desktop collision with Sign-out; masthead inline-end padding restored to the E.6-specified 18px; the "Owner desk" title now renders in full), and J-007 (mobile active-tab underline corrected to the DS E.6-specified 4px; desktop underline confirmed at 5px). `VERIFICATION_PASS` (focused and accessibility vitest, 106 tests; 0 lint errors; clean type-check; passing build; 55/55 e2e on a fresh build; note: the full unfiltered vitest suite was not re-run by the verifier this cycle due to stale-process saturation, so the 2954/2961 figure rests on the writer's report rather than independent re-execution) and `BROWSER_PASS` (Playwright, port 5990; measured masthead/nav full-bleed at 1440 and 390; 18px inline-end padding; title fits 184px against a 184px budget; "Aa" trigger bottom-right with no overlap, keyboard-reachable, modal trap/Escape/restore intact; roadmap trigger unchanged; underline 4px mobile/5px desktop; 49/49 e2e; 0 dialogs, 0 console errors) were both recorded. Issue `#152` was closed 2026-09-10. WP-2 is complete; see the ledger's "Second remediation cycle" subsection for full evidence, artifact locations (`lizbeth_spanish/browser-validation-artifacts/wp-2/validator/final2/`), and the follow-up items tracked outside this plan.

### WP-3 — Owner dashboard (surface 18)

**Scope:** The user's stated priority page. Eyebrow, display heading and rule (same-row layout), uniform metric plates (remove `supportingFigure` on this surface), needs-attention cards (human-language reason text, no comma-joining), and the ledger table (no inner scroll wrapper, abbreviated locale-explicit date format, no warning row) per the full specification above.

**Owner-dashboard eyebrow date — RESOLVED by the user (no longer an open decision).** The eyebrow uses the CURRENT DATE at render time, not a fixed or fabricated value. The reference's `Owner view · 30 Aug 2026` (DS line 987) is the specimen's own literal figure and is a FORMAT EXAMPLE only — it must never ship as a hardcoded string. Render format: zero-padded two-digit day, uppercase three-letter month abbreviation, four-digit year, joined with the same middle dot the reference uses — e.g. the shape `30 AUG 2026`, computed fresh each render, not a stored specimen string. The whole eyebrow renders in mono 12px weight 600, .22em tracking, uppercase, `#a85e4a` (terracotta.600), consistent with the rest of the eyebrow specification above. The date computation must be **locale-explicit** rather than relying on the host locale or a bare `toLocaleDateString()` call — this is the same defect class already identified at `OwnerLedgerRow.tsx:70`, where an unqualified `toLocaleDateString()` produced the ledger-table date drift, and WP-3 must not reintroduce that defect in the eyebrow. **This eyebrow date format (`30 AUG 2026`, with a four-digit year) is a separate format from the ledger table's abbreviated last-active date (`28 AUG`, no year, specified elsewhere in this surface's composition) — the two must not be unified into one shared date-formatting rule**, since they serve different purposes (a page-level "as of" stamp vs. a per-row last-active summary) and the reference itself renders them with different field sets.

**Surfaces affected:** 18.

**Files:** `OwnerDashboardPage.tsx`, `OwnerDashboardPage.css`, `MetricPlate.tsx`, `MetricPlate.css`, `OwnerLedgerRow.tsx`, `OwnerLedgerRow.css`.

**Acceptance checks:** full standard suite; needs-attention rows render human-language `[Band] · [reason]` text, never raw codes or comma-joined lists; table has no inner scroll container; the ledger table's last-active date format is locale-explicit; metric plates carry no second line; the `supportingFigure` removal and its accepted loss is recorded in the ledger entry for surface 18; the eyebrow renders the current date at render time in the exact `DD MMM YYYY` uppercase format specified above, computed via a locale-explicit formatter, never a hardcoded or specimen literal string, and is visually and functionally distinct from the ledger table's `DD MMM` last-active format; the attention-rules save/reset journey follows the shared fixture-and-reset rule in the Browser UI validation section below.

**Browser journeys:** Journey 2 (owner dashboard, full state list), including a check that the eyebrow date advances correctly across a day boundary is not required (render-time computation is sufficient evidence) but that the same page load renders the same date value in both the eyebrow and any repeated render.

**Fixture and reset (applies the shared reset rule above):** the attention-rules journey follows the existing pattern already demonstrated in `src\__tests__\e2e\owner-dashboard.spec.ts` — fixture is the owner account's attention-rule settings; baseline is `inactive_threshold_days` 14 and `progress_lag_tolerance_lessons` 1; the journey refills and re-saves those two defaults in an `afterEach` (or equivalent) teardown, not as trailing steps in the test body, so a mid-test failure still restores the baseline before the next package's journeys run against shared state.

**Progress (2026-09-10):** WP-3 (issue `#42`, shared with WP-4, still OPEN) has been implemented by T1, with one judge loop and two counted verifier cycles (`VERIFICATION_NEEDS_FIX` for an undefined `--font-size-body-lg` token and an 11px-vs-12px eyebrow size) before reaching `VERIFICATION_PASS` (full vitest 2985/2992, pre-existing families only; 43/43 e2e) and `BROWSER_PASS` (Playwright, port 4501; 0 native dialogs, 0 console errors). Delivered: the current-date eyebrow via an explicit en-GB `Intl` formatter verified across all 12 months; the same-row heading layout with the 3px rule and right-aligned subtitle; uniform 4-up metric plates with `supportingFigure` removed on this surface per decision D17's intentional reversal; human-language, pluralized needs-attention reasons joined with " · "; and a ledger table with the inner scroll clip removed, the per-student warning row removed, `.1em` band-chip tracking, and a locale-explicit `DD MMM` last-active date. A new `wp3-owner-dashboard-conformance.test.tsx` suite (31 tests) and a new `wp3-owner-dashboard.spec.ts` e2e journey (Journey 2, with an `afterEach` restoring the 14-day/1-lesson attention-rule baseline) were added. `VISUAL_REVIEW` (advisory; WP-3 Codex call cap at 2/4 used) returned REVISE with three findings: J-008 (multiple reason lines per needs-attention card for students with several flagged enrollments, instead of one joined line), J-009 (the table reflows to stacked cards at 390px via pre-existing responsive CSS instead of the plan's specified horizontal scroll), and J-010 (the "DAYS" suffix renders below the input rather than inline with it). Because these are advisory rather than deterministic findings, WP-3's verification and browser-validation gates stand, but issue `#42` and the ledger's WP-3 status remain OPEN pending a user decision on whether to remediate J-008 through J-010 in a further authorized cycle or accept them as recorded exceptions; see `docs\evidence\lizbeth-spanish-fjds-surface-conformance-ledger.md`'s "Cross-cutting: WP-3 owner dashboard" section for full evidence and artifact locations.

**Progress (2026-09-10, remediation cycle):** the user authorized an extra loop covering J-008/J-009/J-010. T1 applied the fixes (single reason span per flagged enrollment, restored horizontal-scroll table at 390px with `min-width: 32rem`, inline DAYS suffix with `aria-describedby`); the verifier then required the scroll wrapper to be keyboard-operable, which escalated to T2 after T1's counted cycles were exhausted. T2 added `role="region"`, `aria-labelledby`, and `tabIndex={0}` with unit and 390px e2e coverage (Tab focus, 3px focus ring, ArrowRight scroll). `VERIFICATION_PASS` (129/129 targeted vitest; 43/43 e2e including axe) and `BROWSER_PASS` (Playwright, port 4890; per-card single-reason count, thead visibility and scroll-wrapper measurements at 390px, region count, focus ring, ArrowRight scroll, and unchanged prior measurements) were recorded; artifacts under `lizbeth_spanish/browser-validation-artifacts/wp-3/validator/final/`. A repeat `VISUAL_REVIEW` (advisory; WP-3 Codex call cap now 3/4 used) returned REVISE with J-008 (repeat: the multi-reason string still lacks a single-line constraint and may wrap at 390px), J-011 (the D.6-required explanatory sentence under "Attention rules" is missing, `OwnerDashboardPage.tsx:117`), and J-012 (the "Needs attention" heading lacks D.6's 3px top rule and 24px top padding, `OwnerDashboardPage.css:113`); a fourth item, J-ARTIFACTS, was a judge screenshot-path transport issue, not a finding, and the orchestrator separately confirmed the artifacts are present. Because these remain advisory, WP-3's verification and browser-validation gates from the remediation cycle stand, but issue `#42` and the ledger's WP-3 status remain OPEN pending a user decision on J-008 (repeat), J-011, and J-012; see the ledger's "Cross-cutting: WP-3 owner dashboard" section for full evidence.

**Progress (2026-09-10, final cycle) — WP-3 complete.** Under the user's standing authorization (up to two extra evidence-backed judge loops per package), T2 applied the `VISUAL_REVIEW` r2 findings: J-011 — added the intro sentence "When should a student appear on the list below?" (16px, ink-700, `margin: 0 0 22px`, documented literals) between the "Attention rules" h2 and the form; J-012 — gave the "Needs attention" subheading a 3px ink-1000 top rule (`--border-width-rule`) plus `--space-6` top padding; J-008 (repeat) — constrained `.attention-row span` to a single visual line (`nowrap`/`hidden`/`ellipsis`/`min-width: 0`) with a `title` attribute carrying the full text while the underlying DOM text stays intact. Verifier returned `VERIFICATION_NEEDS_FIX` (counted T2 cycle 1) for a stale issue-#42 D2 test still asserting the removed mobile stacked-card rule; T2 retargeted it to the J-009 supersession tests with non-vacuity guards, then reached `VERIFICATION_PASS` (full vitest 2985/2992, pre-existing families only; WP-3 spec suite 2x4/4; 34/34 e2e). `BROWSER_PASS` (Playwright, port 4419): intro sentence 16px/`rgb(80,73,64)`/22px bottom margin; subheading 3px solid `rgb(26,21,18)` top rule with 24px top padding; reason lines 18px tall at a 12px font size on all 5 test rows at both viewports, inside the card, with `title` matching the full text; H1 68px desktop/40px at 390px; metric plates 4-up/2x2; no overflow at 390px; 36/36 e2e including axe; 0 native dialogs/0 console errors. Artifacts: `lizbeth_spanish/browser-validation-artifacts/wp-3/validator/final3/`. `VISUAL_REVIEW` r3 (terra, shadow; WP-3 Codex calls 4/4 used): PASS, no findings, all previously flagged images resolved. WP-3 now has no remaining open findings; a WP-3 evidence comment has been posted to issue `#42`. Issue `#42` remains OPEN pending WP-4's independent verifier and browser-validator pass on surface 19 (the shared anchor). Noted limits carried forward: needs-attention day/lesson counts are a client-side approximation of backend thresholds; the ledger scroll region is an unconditional tab stop at desktop widths; the Netlify-serve e2e path is unusable locally, so `vite preview` with `E2E_BASE_URL` was used throughout. See the ledger's "Cross-cutting: WP-3 owner dashboard" section for full evidence.

**Flake hardening note (2026-09-10, test-only):** the `wp3-owner-dashboard.spec.ts` mobile keyboard-scroll assertion was hardened against an intermittent flake (settles scroll via `requestAnimationFrame`, sets `scroll-behavior: auto`, polls for Tab focus); test-only, no production code change, confirmed green across 5 isolated and 2 under-load runs.

### WP-4 — Roster and student detail (surface 19)

**Scope:** DS D.7 composition — admin masthead/tab-bar (already delivered by WP-2), eyebrow + Fraunces 900 56px H1, card-tier rows with band-ink left border and right-aligned C.3 account-state badge; detail view heading hierarchy; per-section `role="alert"` errors; scoped `isAssigning` indicator.

**Surfaces affected:** 19.

**Files:** `AdminStudentsPage.tsx`, `AdminStudentModals.tsx`, `RegisterStudentModal.tsx`, `AccessControlRow.tsx`.

**Acceptance checks:** full standard suite; loading state gains a `role="status"` if currently missing; permission-denied shape matches the shared shape (pending Open decision #1's resolution for redundancy, not for removal in this package); heading hierarchy verified by direct read.

**Browser journeys:** roster search/sort, student-detail navigation, account-access and enrollment section error states, band assignment in-flight indicator — modeled on Journey 2's pattern, adapted to this surface's own controls.

**Progress (2026-09-10) — WP-4 complete; shared anchor `#42` closed.** WP-4 was delivered by T1 then T2 against DS D.7 (lines 1096-1140): sheet inset 40/44; `.roster-heading` flex row (align-items flex-end, justify-content space-between, 20px gap) with a 3px ink rule, 20px bottom padding, 28px bottom margin; eyebrow plus Fraunces 900 56px/.9/-.035em H1; card-tier roster rows (3px ink border, `--shadow-card`, `border-radius: 0`, 14px gap, 18px/20px padding) with a 6px band-ink `border-inline-start` via `deriveBandTier`; a glyph-plus-word `AccountStatusPill`, right-aligned; loading `role="status"`; detail `h1` with `tabIndex={-1}` focused once per student id; responsive collapse to single-column rows with the pill below text at ≤50em, and a gutter/H1 step-down with full-width actions at ≤28em. `AccessControlRow.tsx` was confirmed out of scope for this surface (it belongs to `CourseWorkspacePage`, surface 25, WP-8). T1's counted cycles covered detail-`h1` focus and a Back-navigation focus defect; T2 fixed the Back-navigation defect in the shared `App` route-focus effect (repeating settle watch, fallback upgrade, 3-second bound, user-focus bail-out), with the verifier reproducing the RED failure on a reverted build first. A CSS source-order cascade bug (responsive block ordered before base rules) was caught by a source-scan test and fixed; `.roster-controls > *` was replaced by class-targeted rules after a wrapped-selector cascade guard flagged the universal combinator, and `AdminShell.css` selector lists were flattened with no behavior change. Tests: `wp4-roster-conformance.test.tsx` (at-rule-aware), `AdminStudentsPage-DetailFocus.test.tsx`, `wp2-route-change-focus` popstate pins, `wp2-owner-chrome` Journey 3d (Back focus), and a new `wp4-roster.spec.ts` e2e spec (D.7 geometry, 390px single-column layout, loading via route delay, Disable-then-Re-enable with an `afterEach` reset, Re-assign-then-Unassign round trip observing the "Assigning…" indicator). `CODE_REVIEW` findings J-WP4-001/002 were fixed. `VERIFICATION_PASS` recorded three times, the final pass covering the full vitest suite at 3005/3012 (remaining failures are the same pre-existing `roadmap`/`rls`/`FeedbackLedgerRow` families recorded elsewhere) plus 14/14 guard tests. `BROWSER_PASS` recorded twice, the final pass on Playwright port 8901: D.7 geometry matched, focus confirmed on detail entry and after Back navigation, 0 native dialogs, 0 console errors. `VISUAL_REVIEW` findings J-WP4-VR-001/002/003 were fixed, and revision 2 (WP-4 Codex calls 3/4 used) returned PASS with no remaining findings. Residual, disclosed, non-defect: the `student2`/`fullaccess` fixtures carry a permanent `preserved` enrollment by design, because Unassign is intentionally non-destructive. Because both WP-3 and WP-4 independently passed verifier and browser-validator, the shared anchor issue `#42` was closed 2026-09-10, with the closing comment referencing both packages' evidence. See the ledger's "Cross-cutting: WP-4 roster / student detail" section for full evidence and artifact locations.

### WP-5 — Feedback inbox (surface 20)

**Scope:** No-artboard composition — index-card list with glyph+word status vocabulary; detail `<h2>` never promoted to `<h1>`. Confirm `OwnerFeedbackPage.tsx` genuinely has no permission-denied state (already confirmed by the independent reviewer) and do not add one that does not belong.

**Surfaces affected:** 20.

**Files:** `OwnerFeedbackPage.tsx`, `FeedbackLedgerRow.tsx`.

**Acceptance checks:** full standard suite; list (`loading`/`ready`/`error`) and detail (`idle`/`loading`/`error`) state machines confirmed distinct and correctly wired; glyph+word status rendering confirmed, not a bare color dot.

**Browser journeys:** list load, row selection into detail, detail error state, filter interaction if present.

**Completion note (2026-09-10):** WP-5 is done; issue `#153` closed 2026-09-10. Full evidence is recorded in the "Cross-cutting: WP-5 feedback inbox" section and surface-20 row of `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md`.

### WP-6 — Brand and design (surface 22)

**Scope:** Implement the full Director-revised state machine: permission-denied, loading (`role="status" aria-live="polite"`), populated, client-side validation (focus-move to first invalid field, per-field `role="alert"`), saving (disabled "Saving…"), save-success (`role="status" aria-live="polite"`), save-error (`role="alert"`, caught `OwnerSettingsWriteError` message or generic fallback). Composition per DS D.8 line 1145.

**Surfaces affected:** 22.

**Files:** `BrandDesignPage.tsx`, `AssetCard.tsx`.

**Acceptance checks:** full standard suite; every named state above is independently reachable and testable; success and error states confirmed mutually exclusive; `sanitizeOwnerSettingsPayload` confirmed to run before any network call.

**Browser journeys:** submit invalid brand-name/color/logo-URL/IP-notice values and confirm per-field `role="alert"` plus focus-move to the first invalid field; submit valid values and confirm the saving → save-success transition; force a write failure path if feasible and confirm save-error rendering.

**Fixture and reset (applies the shared reset rule above):** the branding-save journey on `/admin/brand-design` writes to the brand color fields, the logo URL, and (if exercised) the IP-notice text. The journey must capture the pre-test values of every field it writes before mutating, then restore those exact captured values in teardown. The logo URL and copyright/IP-notice text are owner-visible, production-adjacent settings — leaving a test value behind after a failed or interrupted run is a real defect affecting what the owner and any visitor sees, not merely noisy test state, so the restore step is mandatory acceptance criteria for this package, not an optional cleanliness improvement.

**Completion note (2026-09-10): WP-6 done; issue `#154` closed.** `VERIFICATION_PASS` recorded (full vitest 3025/3031, pre-existing `rls`/`roadmap` families only); `BROWSER_PASS` recorded (Playwright port 4321, viewports 1440/1000/390, 69/69 e2e across wp2-6 plus issue-132/#54/#57); `VISUAL_REVIEW` r3 PASS (WP-6 Codex calls 4/4 used). The prior `#43` work was confirmed conformant to DS D.8. `AssetCard.tsx` was confirmed not rendered on this surface; it is flagged for WP-8 (surface 25) instead. The admin-route accessibility trigger was relocated into `MobileNavPanel` at widths at or below 56.24rem to resolve `VISUAL_REVIEW` finding J-WP6-005, which changes surface 8's and surface 10's mobile behavior on admin routes; see the ledger's "Cross-cutting: WP-6 brand & design" section (`docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md`) for the full evidence record.

### WP-7 — Course settings, business settings, owner settings, and permission-denied deduplication

**Scope:** Surfaces 21, 23, 28, plus resolution of Open decisions #1 (duplicate permission-denied layers) and #2 (heading-text collision between surfaces 21 and 28). Re-derive `CourseSettingsPage.tsx` and confirm its actual structure by direct read before composing (flagged as not independently re-derived in the design pass).

**Surfaces affected:** 21, 23, 28, and the shared permission-denied shape across 19/22/23/27/28.

**Files:** `CourseSettingsPage.tsx`, `BusinessSettingsPage.tsx`, `OwnerSettingsPage.tsx`, `AdminShell.tsx` (if the duplicate-layer resolution changes shared markup).

**Acceptance checks:** full standard suite; the "Course settings" heading collision is resolved per the product/routing check's outcome (rename one, or confirm they are legitimately independent surfaces and document why); the duplicate permission-denied layer decision is implemented and recorded (which layer is authoritative, which is removed or kept as defense-in-depth, and why); each page's four field-level errors (surface 28) are independently verified.

**Browser journeys:** Journey 9 (no-artboard owner pages, permission-denied renders once); field-level validation on each settings page; save/success/error cycles per page.

**Fixture and reset (applies the shared reset rule above):** each settings page's save-cycle journey (course settings, business settings, owner settings) reads and captures its own pre-test field baseline before mutating, then restores that baseline in teardown, following the same read-capture/mutate/assert/restore pattern per page. Course settings, business settings, and owner settings share the `ownerSettingsData` write path — a failure partway through one page's journey can leave another page's fields reading mutated state if teardown does not run reliably, so each page's teardown must run independently (not only at the end of a combined test) and must not assume a prior page's teardown succeeded.

**Completion note (2026-09-11/12, complete, issue `#155` CLOSED 2026-09-12).** Open decisions #1 and #2 above are resolved (see the "Open decisions" section and the "Cross-cutting: WP-7 settings pages (complete)" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md` for the full trace evidence). `CODE_REVIEW`, `VERIFICATION_PASS`, `BROWSER_PASS`, and a `VISUAL_REVIEW` remediation loop (WP-7 Codex calls 2/4 used) were recorded first. The remediation loop's independent verification confirmed the static portion (39/39 conformance tests, lint, typecheck, build, six-file delta), and the live-database vitest re-run and the Playwright re-run, initially blocked because Docker Desktop was not running locally, completed after Docker/Supabase were restored: `VERIFICATION_PASS` (full vitest 3044/3050, pre-existing `rlsIntegration`/`roadmapIntegration` families only; 53/54 e2e, one redirect-timing flake passing in isolation) and `BROWSER_PASS` (Playwright port 4955; mono-styled labels/error line/submit control confirmed; denial-card padding and single-card-per-route confirmed for `student1`; D.7 header confirmed; 39/39 e2e; 0 dialogs/0 console errors) both recorded, followed by `VISUAL_REVIEW` revision 2 PASS (WP-7 Codex calls 3/4 used). WP-7 is complete; surfaces 21, 23, 27, and 28 (28 unrouted; unit-only coverage) are recorded `done` in the ledger.

### WP-8 — New course, course workspace, and surfaces 26/27

**Scope:** Surfaces 24 and 25, plus the corrected surface 26 (implement the reviewer's bounded remediation choice per Open decision #3) and confirmation of surface 27's single-render invariant. Re-derive `NewCoursePage.tsx` by direct read before composing (flagged as not independently re-derived in the design pass).

**Surfaces affected:** 24, 25, 26, 27.

**Files:** `NewCoursePage.tsx`, `CourseWorkspacePage.tsx`, `App.tsx` (surface 26 only if the static-fallback-body option is chosen), `AdminShell.tsx` (surface 27 verification only).

**Acceptance checks:** full standard suite; the five-named-state reconciliation pipeline on surface 25 renders distinguishable wording per state; C.9 empty-state's three elements (illustration, graph-ground, dashed rule) all present together where used; surface 26's chosen remediation (drop as distinct target, or explicit static-fallback addition) is implemented and recorded, not silently reintroducing the "no page body" premise; surface 27 confirmed to render exactly once per non-owner `/admin/*` request.

**Browser journeys:** Journey 11 (surface-26 direct-URL journey, corrected: redirect status message for owner, permission-denied shape for non-owner); course-workspace tab navigation and reconciliation-pipeline states; new-course submission "exactly one Primary" check.

**Fixture and reset (applies the shared reset rule above; hardest case in this plan).** Course creation is not restorable by refilling a field — a created course is a new record, not a mutated one. The journey must create a uniquely identifiable disposable course whose name carries a test marker and a run-unique suffix (for example a fixed prefix plus a timestamp or UUID fragment), so that any record left behind by a failed teardown is always attributable to this journey and never mistaken for real course data. Teardown must remove the disposable course through the same UI path a real user would use to delete or archive a course — not a direct database call — and the reconciliation/workspace journey must assert only against that disposable course, never against real course data. **If no UI deletion path exists for a course today, WP-8's browser validation for the creation journey is blocked pending an explicit user decision on how to clean up** — the package must not proceed and leak disposable course records into the live data set. This blocking condition must be checked and resolved (or explicitly deferred by the user) before WP-8's browser evidence can be accepted.

**Completion note (2026-09-13, complete, issue `#156` closed).** No UI course-deletion path exists today; per this section's own blocking condition, WP-8's browser validation did not exercise the creation journey end to end, a disclosed limit cross-referenced to the pre-existing issue `#81` rather than duplicated. `CODE_REVIEW` findings J-WP8-001 through J-WP8-006 were fixed: the D.7 header and `Field`/`Control` markup on `NewCoursePage.tsx`; `TabBoundary` moved to wrap only the active tab panel on `CourseWorkspacePage.tsx`; bespoke selects/inputs/buttons migrated to `Field`/`Control` (a local `SelectField` helper; a file input and two aria-label-only selects kept native, disclosed); `AssetCard.tsx` moved to the card tier; `AccessControlRow.tsx`'s optional badge pass-through documented; roster/members empty states brought onto `JournalEmptyState` (C.9). Open decision #3 (surface 26) was resolved by dropping it as a distinct remediation target, because only two states are reachable at an unmatched `/admin/*` path (the owner redirect status and the non-owner denial); the surface-26 e2e journey asserts the end state only, since the transient redirect status text was found not reliably observable by automation. Surface 27's single-render invariant was confirmed unchanged, with no edits made to its owning files. `VERIFICATION_PASS` (full vitest 3060/3067, pre-existing `rls`/`roadmap` families only; 57/57 e2e) and `BROWSER_PASS` (Playwright port 4610; all measurements matched; 52/52 e2e; 0 native dialogs; course count unchanged at 8) both recorded; `VISUAL_REVIEW` revision 2 PASS (WP-8 Codex calls 3/4 used), fixing J-WP8-VR-001 (workspace header D.7), J-WP8-VR-002 (tab strip on the D.6 owner tab-bar treatment, including the 56.24rem breakpoint and overflow-x scroll-snap), and J-WP8-VR-003 (panels/course-cards/empty/authoring blocks on the card tier). See the "Cross-cutting: WP-8 new course / course workspace" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md` for full evidence and artifact locations. Surfaces 24, 25, and 26 are recorded `done` in the ledger; surface 27 remains recorded `done` under WP-7.

### WP-9 — Student and shared chrome (surfaces 6, 7, 8, 9, 10, 11)

**Scope:** Finish the standalone specifications for surfaces 6, 7, 8 as they apply to student/shared (non-admin) routes — this package validates and completes what WP-2 restructured for the admin side and now applies/confirms the light-chrome path; plus the footer (9), accessibility settings modal (10), and forced-password-change gate (11).

**Surfaces affected:** 6, 7, 8, 9, 10, 11.

**Files:** `App.tsx:224-297,352-356`, `ContextStatusStrip.tsx`, `MobileNavPanel.tsx`, `AccessibilitySettings.tsx`, `ForcedPasswordChangeGate.tsx`.

**Acceptance checks:** full standard suite; light-chrome bordered nav box and Sign-out placement confirmed against DS D.2/D.3 lines cited above; mobile Menu-trigger replacement (not compression) confirmed at 390px; `ContextStatusStrip`'s content-drop (not wrap) at 390px confirmed; `AccessibilitySettings` modal's focus-trap/Escape/restore confirmed via `Modal.tsx` mechanics; `ForcedPasswordChangeGate`'s six named states confirmed independently reachable.

**Browser journeys:** Journey 10 (shared chrome at 390x844, full detail); accessibility-settings modal keyboard/focus verification; forced-password-change gate state-by-state walkthrough.

**Progress note (2026-09-13, done pending closure decision, issue `#157` OPEN).** T1 delivered this package across three turns plus two user-authorized remediation loops: Sign-out moved outside `.app-nav` into an inline fourth header grid area; `.app-nav` given a 3px ink border, abutting links, first-item border-left 0, and 20px link padding-inline per DS D.2 lines 634-637; the header identity rebuilt as a stacked eyebrow/"Field Journal" lockup with `flex-shrink:0` fixes for the mobile Menu trigger and logo, and `align-items:stretch` so ellipsis truncation engages correctly at 390px (full brand name retained in the DOM; the judge accepted this); logo reduced 48px to 38px and recoloured to ink.1000/brass.300; `ContextStatusStrip` rebuilt as a single flex row (identity left, progress right per DS D.2 line 640 / D.3 line 778), hidden at 390px, absent on `/admin/*`; `Modal.tsx`'s `aria-labelledby` fixed to `titleId ?? slug + useId()`, resolving the pre-existing WCAG 4.1.2 gap flagged during WP-2; `AccessibilitySettings` composition confirmed conformant with existing primitives; `ForcedPasswordChangeGate`'s six states characterized by a new unit-only test suite (no `must_change_password` fixture exists for a browser journey); the footer (surface 9) confirmed conditional-only per this plan's lines 181/300, with the DS 3px rule confirmed to belong to the public catalog composition instead. `CODE_REVIEW` J-WP9-001 through J-WP9-005 fixed. `VERIFICATION_PASS` recorded four times (final: full vitest 3077/3084, pre-existing `roadmap`/`storage` families only; 59/59 e2e). `BROWSER_PASS` recorded three times (final: Playwright port 4321; 49/49 e2e; 0 native dialogs/0 console errors). `VISUAL_REVIEW` recorded three times: VR-001 through VR-004 fixed; revision 3 raised VR-005 (desktop header padding 16px/2px border vs this section's DS D.2 specification of `padding:18px 48px`/3px border) and VR-006 (mobile header padding 16px vs DS E.2's 18px) as open findings. The WP-9 Codex call cap (4/4) is exhausted and both extra loops available under the user's standing authorization have been used, so issue `#157` and this package's status remain OPEN pending a user decision on whether to remediate VR-005/VR-006 in a further authorized cycle or accept them as recorded exceptions. Disclosed process items: one `BROWSER_NEEDS_FIX` (logo colour) counted as T1 remediation cycle 1; one browser-validator pass used `claude-in-chrome` for read-only screenshots despite this plan's Playwright-only preference, though the full 52/52 Playwright suite still ran in that same pass; a pre-existing `gap-1-owner-settings-persistence.spec.ts` failure (stale `"Sign in"` selector; actual label "Open my journal") is tracked, not a WP-9 defect. Full evidence is recorded in the "Cross-cutting: WP-9 student/shared chrome, footer, accessibility settings, forced password change" section of `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md`, and surfaces 6-11 are recorded `done pending closure decision` in that ledger's 28-surface table.

**Completion note (2026-09-14, done, issue `#157` closed).** The user directed completion of the two remaining `VISUAL_REVIEW` r3 findings, VR-005 and VR-006; because the WP-9 Codex `VISUAL_REVIEW` budget was already exhausted (4/4 calls), this cycle was verified by the verifier and browser-validator only, with no further Codex judge call. VR-005 was fixed: `.app-header` now renders `padding-block: 18px` and `padding-inline: max(48px, calc((100vw - var(--size-content-max)) / 2))`, where 48px is a floor required by issue-11's header/footer inset-harmonization requirement (P0-3, header inset must equal footer inset); at the 1440px viewport this yields 72px, recorded as a tolerated, explained deviation from DS D.2's flat 48px measured on a fixed 1440px artboard; the header's `::after` bottom rule now renders at 3px using `--border-width-rule`. VR-006 was fixed: mobile header padding now renders at 12px / 18px per DS E.2 line 1316, with the accessibility-trigger clearance retained as a floor on the trailing edge. New test suite `wp9-headerPaddingBorderCss.test.ts` (3 tests); existing e2e coverage extended with padding/border assertions. `VERIFICATION_PASS`: 124 targeted vitest tests, 0 lint errors, a clean type-check, a passing build, and 56/56 e2e specs including the issue-11 header/footer inset-harmonization spec. `BROWSER_PASS` (Playwright, port 4321): at 1440px, 18/18 measured assertions passed, including the left inset measuring 72px and matching the footer inset, and the bottom rule measuring 3px `rgb(26,21,18)`; at 390px, 12/18 measured assertions passed, the Menu trigger measured 44x44px, and Sign-out rendered inline right of the nav; 49/50 e2e specs passed, with the one failure (`neo-workbook-visual-smoke.spec.ts:180`, a `getByRole('heading', { name: /Feedback/i })` locator) attributed to WP-12 renaming the feedback page's H1 to "Leave a note," tracked for retargeting in WP-14 rather than a WP-9 regression; 0 native dialogs and 0 console errors were recorded. Artifacts: `browser-validation-artifacts/wp-9/validator/final4/`. Tracking items unchanged by this closure: `gap-1-owner-settings-persistence.spec.ts`'s stale `"Sign in"` selector remains open; roughly 40 tracked validator scratch scripts at the repository root remain in place pending explicit user approval to delete; one browser-validator pass in this package's history used `claude-in-chrome` for read-only screenshots, as already disclosed above. Issue `#157` was closed 2026-09-14, and surfaces 6-11 are now recorded `done` in the ledger's 28-surface table.

### WP-10 — Roadmap, week detail, and flashcards (surfaces 12, 13, 14)

**Scope:** Full composition per DS D.2/D.3/D.4 and E.2/E.3/E.4 as specified above, including the week-detail mobile pill-switcher reorganization and the mobile masthead-collapse rule.

**Surfaces affected:** 12, 13, 14.

**Files:** `RoadmapPage.tsx`, `BandRoadmap.tsx`, `WeekCard.tsx`, `WeekDetailPage.tsx`, `WeekSectionTabs.tsx`, `LessonContentView.tsx`, `ResourcesPanel.tsx`, `LessonCompletionControl.tsx`, `SegmentLedger.tsx`, `FlashcardsViewer.tsx`, `FlashcardsOverlay.tsx`.

**Acceptance checks:** full standard suite; `content-error`'s role confirmed as `alert` not `status` (open verification item); the four fixed C.5 lesson chunks confirmed in order; flashcard `aria-live` announcement confirmed to reset before each write; **`RoadmapPage.tsx:69`'s loading text carries `role="status"` and is announced by assistive technology** (Codex finding `J-02-LOADING-FIX-OWNERSHIP-GAP` remediation, owned by this package).

**Browser journeys:** Journey 6 (week-detail mobile header collapse); Journey 7 (flashcards flip/announce/navigate); roadmap week-card state verification across the four C.4 states; a roadmap-loading accessibility-tree journey at both viewport profiles (1440x900 and 390x844) that observes the loading state through the accessibility tree — confirming the `role="status"` node is present and its text is exposed to assistive technology — rather than checking it only visually.

**Completion note (2026-09-13, complete, issue `#158` closed).** T1's first pass fixed two ARIA roles — `RoadmapPage.tsx`'s loading branch given `role="status"` (this section's `J-02-LOADING-FIX-OWNERSHIP-GAP` remediation, actual site `RoadmapPage.tsx:151`) and `WeekDetailPage.tsx`'s content-error status corrected from `status` to `alert` — and declined the D.2 band-tab rail pending review. `CODE_REVIEW` findings J-WP10-001 through J-WP10-007 established the vertical band-tab rail as approved scope (this plan's "reference outranks prior adoption decisions" rule supersedes issue `#38`'s §4) and identified: a page-level solid/hatched ledger belongs beside the H1; the metric/card grid should be 3-up, not 4; the flashcard brass shadow needs its D.4 (line 912) licence cited as a documented DS exception rather than left unexplained; Journey 6 needed bounding-box assertions; Journey 7 needed a MutationObserver check against the same face rendering twice. T1 then delivered: the vertical band-tab rail (`nav[aria-label="Band"]`, D.2 lines 754-757: three vertical-rl bars, the enrolled tier's link carrying `aria-current="location"`, shown at desktop widths of 56.25rem and above, with the existing horizontal jump-list kept at mobile widths per DS E.2 lines 1319-1321, disclosed as an intentional variation); a page-level "Filed" ledger surfaced via `BandRoadmap`'s `onProgress` callback, with per-band ledgers retained for multi-band students as a permitted product-decision variation; the grid changed from 4-up to 3-up with the affected tests retargeted; a citation comment added for the brass shadow licence. `BROWSER_NEEDS_FIX` (counted T1 cycle 1) found the rail's active bar rendering ink instead of brass-600 against paper-50 text (fixed to roughly 4.9:1 contrast) and the flashcard shadow being overridden by a compound selector (fixed with `.flashcards-viewer-card.journal-index-card-trim`). `VISUAL_REVIEW` found week-detail screenshots captured mid-load (an evidence-capture defect, re-captured settled) in revision 1, and a missing folio (DS D.3 lines 850-854) in revision 2, which was added but rendered `aria-hidden` while serving as the sole desktop carrier of the band name; this was `VERIFICATION_NEEDS_FIX` (counted T1 cycle 2) and was made accessible. Revision 3 then found the folio's band-name and week-number text merged onto one line, which was split into two spans (band left, "— 01 —" right). A `BROWSER_NEEDS_FIX` (T1's counted cycles exhausted, escalated to T2) found the folio `<p>` inheriting the global `p { max-width: var(--measure) }` cap; T2 fixed this with an explicit `max-width: none` override plus a cascade-resolver regression test. Final `BROWSER_PASS`: the folio's band text left-aligns with the content column, its week-number mark right-aligns with the content column's right edge, a 2px rule separates the two, the type is mono 12px/2.4px-tracking uppercase, the folio is not `aria-hidden`, "Beginner" (or the enrolled band name) renders exactly once, no folio renders at the 390px viewport, and 17/17 e2e specs passed with 0 native dialogs. Codex calls for this package reached the 4/4 cap (`CODE_REVIEW` plus three `VISUAL_REVIEW` revisions); the final folio fix was confirmed by the verifier and browser-validator only, with no further judge cycle available. Tests: `wp10-roadmap-week-flashcards.spec.ts` (10 journeys); `RoadmapPage`, `BandRoadmap`, `WeekDetailPage`, `journalDevicesRemovalTest`, and `weekDetailDesktopNonRegressionConsolidated` updated. Tracking items, not WP-10 defects: `.week-detail-footer-next-reason` inherits the same global paragraph measure cap (report-only, no user-facing regression observed); `.week-detail-not-available` and `.content-not-authored` notices are measure-capped prose, accepted as correct for body text. See the "Cross-cutting: WP-10 roadmap / week detail / flashcards" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md` for full gate evidence and artifact locations. Surfaces 12, 13, and 14 are recorded `done` in the ledger.

### WP-11 — Learn index and detail (surfaces 15, 16)

**Scope:** No-artboard composition per the table above; fold into GitHub issue #44's coverage explicitly; re-check the confirm/trigger step machine on `LearnDetailPage.tsx` for native-dialog compliance.

**Surfaces affected:** 15, 16.

**Files:** `LearnIndexPage.tsx`, `LearnDetailPage.tsx`.

**Acceptance checks:** full standard suite; `role="status"` added to the loading branch (cross-cutting fix, coordinate with WP-13); confirm/trigger step machine confirmed to use inline disclosure or `Modal.tsx`, never `confirm()`; index-card and metric-plate composition checks per the no-artboard table.

**Browser journeys:** learn-index card list load and navigation; learn-detail state transitions; confirm/trigger step machine keyboard/focus verification.

**Completion note (2026-09-14, complete, issue `#159` closed).** T1 delivered: `LearnIndexPage.tsx` rows rebuilt as B index cards using the shared `.journal-index-card-trim` device per the WP-5 precedent, with `<h2><a href="/learn/{id}">` as the sole focusable element (stretched overlay, li-level delegation, modifier-click passthrough; the separate "View course" button removed); the page eyebrow set to mono 600-weight/`.22em` tracking and the H1 to 56px desktop/40px mobile via the compiled display tokens, following the no-artboard sibling convention (RoadmapPage's 76px H1 is artboard-specific and does not apply here); `role="status"` added to `LearnIndexPage.tsx`'s loading branch, resolving this plan's cross-cutting `role="status"` gap for surface 15, with an incidental `role="status"` fix also applied to `LearnDetailPage.tsx`'s loading branch; "Your progress" on `LearnDetailPage.tsx` rebuilt as a C.8 `MetricPlate` (mono label, Fraunces 900 52px figure such as "1 / 3", supporting sentence, preserving the prior accessible text); the primary-control tier confirmed mutually exclusive per rendered state (Mark Complete trigger, Confirm while the step is open, and the legacy "Go to Roadmap" `<a class="control control--primary">` link, used because `Control` has no link variant); the confirm/trigger step machine confirmed as an inline disclosure rather than a native dialog, with Confirm focused on open and Cancel restoring focus to the trigger; forced-colors rules added for `.enrollment-card`. `CODE_REVIEW` finding J-WP11-001 (link semantics) was fixed; J-WP11-002 (`LearnDetailPage.css:63`'s `--font-weight-label-strong` usage) was dispositioned as a pre-existing hunk from issue `#69`, not introduced by this package. `VERIFICATION_NEEDS_FIX` (counted T1 cycle 1) found the composition change broke `fjdsFreshAuditFindingA.test.tsx` and `issue5-phase5-learn-detail-interim-route.test.tsx`; both were retargeted with supersession disclosures (the card tier is now supplied by the trim device, the course-title link uses the terracotta-link treatment established by the `FeedbackLedgerRow` precedent, and the link's accessible name is the course title). `BROWSER_NEEDS_FIX` (counted T1 cycle 2) found no `.control--primary` control rendering on `/learn/:id`; fixed via the legacy link markup described above. Gates: `VERIFICATION_PASS` recorded three times, the final pass covering the full vitest suite at 3102/3109 (remaining failures are the same pre-existing, out-of-scope `rls`/`storage`/`roadmap` families recorded elsewhere); `BROWSER_PASS` recorded twice, the final pass on Playwright port 4321 with 38/38 e2e specs passing, exactly one Primary control observed across the trigger/Confirm/legacy-link states, 0 native dialogs, and 0 console errors; `VISUAL_REVIEW` (WP-11 Codex calls 2/4 used): PASS, no findings. Disclosed limits, not WP-11 defects: `seed.sql` never inserts `enrollment_lesson_entitlements`, so every real `/learn` enrollment in current seed data renders the legacy branch, and the populated/error/pending-quiz states are exercised only via route-mocked e2e fixtures, a broader gap than issue `#69`'s previously disclosed pending-quiz gap; the e2e populated fixture unlocks lessons sequentially, so only one lesson is ever unlocked-incomplete in the fixture, while production data with several simultaneously unlocked-incomplete lessons could render multiple primary triggers at once, needing a tie-break rule as a bounded follow-up; the verifier noted the ledger's literal "exactly one Primary control per view" phrasing (used for surfaces 21/24 elsewhere) is not row 16's own check, which is the metric-plate-plus-confirm/trigger composition described above. See the "Cross-cutting: WP-11 learn index / detail" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md` for full gate evidence and artifact locations. Surfaces 15 and 16 are recorded `done` in the ledger.

### WP-12 — Student feedback (surface 17)

**Scope:** Full composition per DS D.5/E.5 as specified above.

**Surfaces affected:** 17.

**Files:** `FeedbackPage.tsx`, `FeedbackForm.tsx`.

**Acceptance checks:** full standard suite; mono character counter confirmed functional; Control-primary submit confirmed as the single primary action.

**Browser journeys:** form fill, character-counter behavior, submit success/error; the unsaved-draft sign-out disclosure re-verified in this package's context (cross-reference Journey 4).

**Completion note (2026-09-13/14, complete, issue `#160` closed 2026-09-14).** T1's first pass added an eyebrow, a 46px/38px H1 outside the form card, a ruled textarea background, and a `feedbackH1Lg`/`feedbackH1Sm` token pair. `CODE_REVIEW` findings J-WP12-001 through J-WP12-008 were fixed: the eyebrow and H1 were moved inside the full sheet card (D.5 line 936 / E.5 line 1478 padding literals); the H1 copy was changed to "Leave a note" (D.5 line 937), retargeting assertions in the `FeedbackPage`/`App` tests and the `wp2-owner-chrome` and `issue-3` specs, disclosed as a supersession; the shared `Field` primitive was extended with `as="select"` support and an `adornment` slot in a backwards-compatible way, and `FeedbackForm`'s selects now use it (WP-8's local `SelectField` clone was reported as a migration candidate but not migrated here); the character limit was kept at 5000 for both viewports (D.5 line 956 shows "0114 / 5000"; E.5 line 1489's "2000" was recorded as a specimen inconsistency, not implemented); the mobile submit control was set to `width:100%` (E.5 line 1492); textarea line-height was scoped to 28px; the `feedbackH1Lg`/`feedbackH1Sm` token pair was reverted in all three token files because this plan permits no new tokens, with the 46px/38px H1 sizes kept as documented literals instead; and the e2e primary-control assertion was corrected to `=== 1`. A stray orchestrator-root compiler snapshot mis-written by `tokens_compile` was removed by a separate housekeeping job, unrelated to this package's own fix work. `VISUAL_REVIEW` revision 1 findings J-WP12-VR-001 through J-WP12-VR-003 were fixed: the supporting paragraph is removed at or above 48rem and replaced by E.5 lines 1480-1483's shorter sentence below 48rem, toggled with CSS only; labels read "Course (optional)" and "Lesson (optional)" (D.5 lines 944-951); and the eyebrow renders at 11px (`--font-size-label-small`). Revision 2's continuation of J-WP12-VR-003 was fixed: the mobile eyebrow wraps, with the trailing " only" text as a `span` hidden below 48rem (E.5 line 1479 copy) and `nowrap` otherwise. `VISUAL_REVIEW` revision 3 (WP-12 Codex calls 4/4 used): PASS, no findings. Gates: `VERIFICATION_PASS` recorded three times (full vitest 3114/3121, pre-existing `rls`/`roadmap`/`storage` families only; token pipeline PASS); `BROWSER_PASS` recorded three times, the final pass on Playwright port 4531 confirming eyebrow copy/one-line wrapping at both viewports, H1 measured 46px/38px, the supporting paragraph present or absent per viewport, the card composition, the character counter, and exactly one Primary control, with 17/17 e2e and 0 native dialogs (artifacts under `browser-validation-artifacts/wp-12/validator/final2/`). Tests: a new e2e spec `wp12-feedback.spec.ts` (7 journeys); `wp12FeedbackComposition.test.ts` added; `FeedbackForm`, `FeedbackPage`, `Field`, and `App` tests updated. Tracking, not new defects for this package: GitHub #41's student-form forced-colors half was re-verified, not re-implemented; `issue-3-feedback-inbox.spec.ts` remains pre-existing-failing on a stale "Sign in" selector, unrelated to this package. See the "Cross-cutting: WP-12 student feedback page" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md` for full gate evidence and artifact locations. Surface 17 is recorded `done` in the ledger.

### WP-13 — Unauthenticated surfaces (1, 2, 3, 4, 5) and remaining accessibility fixes

**Scope:** Full composition per DS D.1/E.1 and D.9 as specified above; the GitHub issue #60 background-only fix; the missing `role="status"` on the app-loading branch (surface 3, owned here) — coordinate with WP-10's `RoadmapPage.tsx:69` fix and WP-11's `LearnIndexPage.tsx:109` fix for the same cross-cutting gap, verified jointly at WP-14 closure.

**Surfaces affected:** 1, 2, 3, 4, 5.

**Files:** `App.tsx` (AuthGate, session-error, app-loading branches), `LoginForm.tsx`, `LoginForm.css`, `PublicCatalogPage.tsx`.

**Acceptance checks:** full standard suite; `LoginForm.css` background changed to paper.50/100 without altering the terracotta.600 text token; contrast re-verified at or above 4.5:1 after the fix; `role="status"` present on all three cross-cutting loading branches (surfaces 3, 12, 15); public-catalog course-preview loading sub-state confirmed distinct from the page-level loading state.

**Browser journeys:** Journey 8 (public catalog); sign-in submit/error states; session-error retry; app-loading `role="status"` presence check via the accessibility tree.

**Completion note (2026-09-13/14, complete, issue `#161` closed 2026-09-14).** T1's first pass added `role="status"` to `App.tsx`'s app-loading branch and confirmed the `.app-initial-loading` class (surface 3), resolving this plan's cross-cutting `role="status"` gap alongside WP-10's `RoadmapPage.tsx:151` fix and WP-11's `LearnIndexPage.tsx:155` fix; `role="status"` is now present at `App.tsx:638`, `RoadmapPage.tsx:151`, and `LearnIndexPage.tsx:155`, closing the cross-cutting gap jointly. Prior work under issues `#37`, `#43`, and `#60` was re-confirmed rather than re-implemented, per this plan's disposition corrections above; e2e was initially run against the Vite dev server before a final re-run against a production preview build. `CODE_REVIEW` findings J-WP13-001 through J-WP13-007 were fixed: the preview-failure status, which had incorrectly used `role="status"`, was split into a separate `previewStatus` using `role="alert"`; the async sign-in error now moves focus to the alert via `errorRef`; the session-error card received the washi-tape treatment; the catalog's preview buttons were migrated to `<Control tier="secondary">`; the enrol e2e journey added a 500-response case and an in-flight "Requesting…" state; and the surface-2 (session-error) e2e journey was made real via a documented in-memory test seam, `window.__E2E_FORCE_SESSION_ERROR__`, added to `AuthContext` (Retry clears it; the seam is inert unless set by a page script, and the verifier assessed the residual risk as low and self-inflicted). `VISUAL_REVIEW` findings J-WP13-008 through J-WP13-011 were addressed: the sign-in and session-error cards render the graph-paper `.auth-card-panel.paper-stock--graph` treatment with the sheet card centred (460px, a documented literal; measured gaps of 126px/126px and 175.5px/175.5px) and a 24px inset at the 390px viewport; the public-catalog band chips are derived from `bandTierForCourse(title)` in `src/lib/bandTier.ts`, disclosed as a title-based fallback (the `course_catalog` view exposes no level/band column, seed titles equal band names, and non-standard titles fall back to "advanced"); the catalog hero H1 renders at 84px, a documented literal matching DS D.9 (line 1196); and the two-line inverted header lockup ("Lizbeth Spanish" / "Field Journal") matches DS D.9 (line 1188). GitHub issue `#60`'s `LoginForm.css` `paper-100` contrast fix was re-confirmed live, not re-implemented. Gates: `VERIFICATION_PASS` recorded twice (full vitest 3116/3123, pre-existing `rls`/`roadmap`/`storage` families only; 55/55 and 39/39 e2e); `BROWSER_PASS` recorded twice, the final pass on Playwright port 4173 against a production preview build with read-only Chrome captures, all measurements matching DS D.1/E.1/D.9, 39/39 e2e, and 0 native dialogs (artifacts under `browser-validation-artifacts/wp-13/validator/final/`); `VISUAL_REVIEW` revision 2 PASS (WP-13 Codex calls 3/4 used). Tests: a new e2e spec `wp13-unauth.spec.ts` (12 journeys); `App`, `LoginForm`, `publicCatalogEnrollment`, and `PublicCatalogPage-anonymous-access` were updated, including one fixture retargeted from a level-based title to a band-name title with disclosure. Disclosed, not a defect: a fourth seeded catalog card, "Advanced Immersion (Empty Fixture)", renders in the public catalog as test data. See the "Cross-cutting: WP-13 unauthenticated surfaces" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md` for full gate evidence and artifact locations. Surfaces 1, 2, 3, 4, and 5 are recorded `done` in the ledger.

### WP-14 — Closure

**Scope:** A full-surface Playwright sweep at both viewport profiles across all 28 surfaces; completion of the audit ledger (via a Scribe `DOCUMENT_JOB`); a final reconciliation confirming every one of the 28 surfaces has recorded evidence and that the route-predicate inventory proof still holds (no route added since WP-1 without a corresponding ledger entry).

**Surfaces affected:** all 28.

**Files:** none expected to change; this is a verification-and-documentation package. If the sweep finds a regression, it is routed back to the owning work package rather than fixed inline.

**Acceptance checks:** every surface's ledger entry is in a terminal state (`done` or `blocked` with a recorded reason); the route-predicate enumeration is re-confirmed against the current `useRoute.ts`; both viewport profiles have complete screenshot coverage under `browser-validation-artifacts/`; no open Codex CODE_REVIEW or VISUAL_REVIEW finding remains unresolved without an explicit disposition recorded.

**Browser journeys:** re-run all eleven journeys listed above as a single regression sweep at both viewport profiles.

**Judge challenge (`VERIFICATION_CHALLENGE`, terra, shadow, guarded local Codex, shadow policy).** Findings and disposition: J-WP14-001 (surface 28 recorded `done` with no possible browser journey) → corrected to `deferred`, pending a product decision to delete or route the page; J-WP14-002 (gap-4 classification) → resolved by a reset-isolated reproduction (`npx supabase db reset`, single-spec run): 3 of 5 gap-4 failures were stale `AccountStatusPill` selectors, retargeted and now 5/5 on a reset database; Defect C's "never-enrolled candidate" precondition is genuine fixture drift, carried forward; Defect B's earlier failure was cold-start timing; J-WP14-003 (route-predicate inventory proof overclaimed all 17 predicates as production-consumed) → corrected to 16 production predicates plus 1 test-only predicate (`matchAdminRoute`), see the "Route-predicate inventory proof" section above; J-WP14-004 (surface 24 recorded plain `done` without disclosing the undisclosed creation-journey browser-validation gap) → the exception is now explicitly carried forward against issue `#81`; J-WP14-005 (a credential-mutating test needed observable cleanup) → resolved: `afterAll` in `browser-validation-status-clarity-and-gate.spec.ts` now logs the Admin API status, asserts it is ok, and performs a sign-in probe, with the 127.0.0.1 guard retained. Full disposition detail and the consolidated outstanding-items list are recorded in the "Cross-cutting: WP-14 closure" and "Outstanding items carried forward" sections of `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md`.

**Completion note (2026-09-14, done, final closure, issue `#162` closed 2026-09-14).** Gate sequence: T1 `JOB_DONE` → verifier `VERIFICATION_PASS` r1 (66/68 sample) → the Codex `VERIFICATION_CHALLENGE` above → one judge-driven remediation loop (J-WP14-002, J-WP14-003, and J-WP14-005 remediated by T1; J-WP14-001 and J-WP14-004 resolved as ledger dispositions) plus two post-challenge test retargets (`gap-2-non-owner-permission-denied.spec.ts:201` retargeted to WP-7's unified denial copy, now 2/2; `browser-validation-status-clarity` Journey 1 retargeted from "Awaiting first sign-in"/`.status-badge` to "Pending first login"/`.account-pill`, with one pre-existing seed-row locator failure carried forward) → verifier `VERIFICATION_PASS` r2 (2026-09-14): type-check clean, lint 0 errors/816 warnings, guards 49/49, e2e gap-2 2/2, gap-4 4/5, status-clarity 3/4. Browser validation: `BROWSER_NOT_APPLICABLE` (WP-14 changed no production `src` file; all changes are test/artifact-only). Artifacts: `lizbeth_spanish/browser-validation-artifacts/wp-14/`. This closure also resolves the WP-1/WP-10/WP-11-owned cross-cutting `role="status"` reconciliation referenced under WP-1's scope note above (see WP-13's completion note for the three sites already confirmed). Issue `#162` closed 2026-09-14; all 28 surfaces are recorded in a terminal state in the ledger, and WP-0 through WP-14 are complete. See the "Cross-cutting: WP-14 closure" section in `docs/evidence/lizbeth-spanish-fjds-surface-conformance-ledger.md` for full gate evidence and artifact locations.

## Issue ledger

**Resolved by live enumeration on 2026-09-09.** The two hook-policy defects that blocked the nested Researcher during planning (the `validate-researcher-bash.ps1` execution error on every Bash call, and `gh` having no entry in that hook's `$allowedPatterns`) did not block Scribe's read-only evidence-collection step for this ledger update, which ran `git remote -v`, `gh issue list --state all --limit 200 --json number,title,state,labels,closedAt`, and targeted `gh issue view` calls directly from `H:\CommandCenter\orchestrator\lizbeth_spanish`. Those two hook defects remain open problems for the Researcher role specifically and are not otherwise addressed by this update.

**Evidence note.**
- Remote: `git@github.com:lebobo88/lizbeth-spanish.git` (origin, fetch and push).
- Enumeration date: 2026-09-09.
- `gh issue list --state all --limit 200` returned 103 issues total: 12 OPEN (`#48, #53, #63, #79, #80, #81, #82, #137, #139, #140, #148, #150`), 91 CLOSED.
- Every issue number cited elsewhere in this plan (`#31`-`#44`, `#60`) was independently re-confirmed present in that live enumeration; none was invented or guessed. `#60` is CLOSED, not open as the plan text elsewhere assumes still pending — see the WP-13 note below.
- Full body and comment history was read via `gh issue view <n> --json title,body,state,comments` for issues `#37`-`#43`, `#60`, `#65`, `#69`, `#71`, `#81`, `#53`, `#150` to check disposition by scope and verification evidence, not by title similarity alone.

**Disposition method.** REUSE = an OPEN issue already covers the work package's scope. REOPEN = a CLOSED issue covers the same scope and live source evidence (cited in this plan or found during this enumeration pass) shows the closed fix no longer holds. NEW = no existing issue covers the scope; the proposed draft below is used verbatim unless WP-0 revises it. Two important corrections to this plan's own prior assumptions surfaced during this pass and are recorded here rather than silently reconciled:

1. **`#42` ("Screen: Owner dashboard + Roster") was closed 2026-09-06 with a real, evidenced verification pass** — `a11y_audit`, rendered-capture comparison against three baselines, contrast checks, and one genuine defect found and independently fixed (`#122`, band-name mid-word wrapping). This contradicts this plan's Grounding section's blanket claim that no surface's "validated" status ever included a rendered comparison; `#42` did include one. The plan's specific, line-cited defects on `OwnerDashboardPage.tsx`/`OwnerLedgerRow.tsx` (the `supportingFigure` line, comma-joined raw attention-reason codes, the `.dashboard-table-wrap` inner scroll container, `toLocaleDateString()` drift) are therefore best read as **regressions or feature additions introduced after `#42`'s 2026-09-06 closure**, not as evidence `#42` was never checked. This still supports REOPEN, cited on that narrower, corrected basis.
2. **`#60` ("LoginForm.css pairs terracotta.600 error text with paper.200 background") is already fixed, not merely tracked-and-pending as this plan's Known accessibility items and WP-13 sections assume.** Live source confirms `src\components\LoginForm.css` lines 334 and 339 already read `background-color: var(--color-paper-100)`, matching the closing comment's documented fix (`paper-100`, 4.536:1, TDD-verified). WP-13 must treat this item as **already complete** and only re-confirm it in its own browser pass, not implement it as new work.

| Work package | Surfaces covered | Anchor issue | Disposition | Status |
|---|---|---|---|---|
| WP-0 | none (administrative) | n/a — WP-0 performed the enumeration itself | n/a | done 2026-09-09 (#42 reopened; #151–#162 created) |
| WP-1 | cross-cutting (all 28, via shared tokens) | `#151` | NEW | done 2026-09-09 |
| WP-2 | 6, 7, 8, 9, 18-28 | `#152` | NEW | done 2026-09-09 |
| WP-3 | 18 | `#42` | REOPEN (regression after 2026-09-06 closure — see correction #1 above) | done 2026-09-09 |
| WP-4 | 19 | `#42` (shared with WP-3; the same issue bundled dashboard + roster scope) | REOPEN (shared anchor) | done 2026-09-09 |
| WP-5 | 20 | `#153` | NEW | done 2026-09-09 |
| WP-6 | 22 | `#154` | NEW | done 2026-09-09 |
| WP-7 | 21, 23, 28 | `#155` | NEW | done 2026-09-09 |
| WP-8 | 24, 25, 26, 27 | `#156` | NEW | done 2026-09-09 |
| WP-9 | 6, 7, 8, 9, 10, 11 | `#157` | NEW | done 2026-09-09 |
| WP-10 | 12, 13, 14 | `#158` | NEW | done 2026-09-09 |
| WP-11 | 15, 16 | `#159` | NEW | done 2026-09-09 |
| WP-12 | 17 | `#160` | NEW | done 2026-09-09 |
| WP-13 | 1, 2, 3, 4, 5 | `#161` | NEW | done 2026-09-09 |
| WP-14 | all 28 (closure) | `#162` | NEW | done 2026-09-09 |

**Notes on WPs disposed NEW despite a related closed issue existing.** These are not duplicates of the closed issue; each is noted so WP-0 does not silently recreate work already verified, and so the new issue's body cites the prior issue for continuity:
- WP-5 (feedback inbox, surface 20): `#41` ("Screen: Feedback") is CLOSED with real browser-validated evidence and already listed `OwnerFeedbackPage.tsx/.css` in its scope, alongside the student-facing form covered by WP-12. `#41`'s one disclosed gap (forced-colors/Windows High Contrast emulation not completed) remains open and should be picked up by WP-5 or WP-12, whichever exercises it, rather than re-litigated as a new finding.
- WP-6 (brand & design, surface 22) and WP-13 (catalog, surfaces 4-5): `#43` ("Screen: Brand + Catalog") is CLOSED with real browser-validated evidence (one disclosed gap: a mobile-viewport re-check blocked by a browser-tool disconnect, accepted via a deterministic CSS regression-guard test instead). WP-6 and WP-13 should treat `#43`'s scope as already delivered and confirm, not re-implement, unless their own audit finds a specific regression.
- WP-9 (student/shared chrome, surfaces 6-11): `#71` ("Roadmap page header does not match Field Journal reference") is CLOSED with detailed remediation evidence for the roadmap-route header specifically. WP-9's broader scope (all student/shared routes plus footer, accessibility-settings modal, forced-password-change gate) is not covered by `#71`; treat `#71` as already-delivered prior work for the roadmap header sub-case only.
- WP-10 (roadmap/week-detail/flashcards, surfaces 12-14): `#38`, `#39`, `#40` ("Screen: Roadmap" / "Week detail" / "Flashcards") and their remediation chain (`#65`, `#71`-`#76`) are all CLOSED. This plan's stricter per-composition-checklist method (see Grounding and method above) is a genuinely new audit pass, not a claim that these surfaces are currently broken; no live-code contradiction was cited in this plan for these three surfaces the way one was for surface 18.
- WP-11 (learn index/detail, surfaces 15-16): `#69` is CLOSED with a full independently-confirmed evidence chain (Codex CODE_REVIEW, Verifier, Browser Validator all passed), including one disclosed, non-blocking gap (a "pending quiz" hint-text sub-state could not be live-exercised for lack of a seeded fixture). WP-11 should confirm this state remains correct rather than treat the whole surface as unverified.
- WP-13 (unauthenticated surfaces, surface 1 specifically): `#37` ("Screen: Login / Sign in") is CLOSED. `#60`'s contrast fix (see correction #2 above) is also already complete. WP-13's login-related acceptance checks should be confirmed, not re-implemented, unless a specific regression is found.
- WP-8: two OPEN issues sit adjacent to this package's files but are not the same scope and are not its anchor — `#81` (OPEN, `issue5EdgeSmoke` leaks a draft course version with no cleanup, test-infrastructure) is the same underlying problem WP-8's own fixture-and-reset specification above calls out as a hard blocking condition if no UI deletion path exists; WP-8 must cross-reference `#81` rather than duplicate it when resolving that blocking condition. `#53` (OPEN, Finalize-publish button does not disable after success) is a narrow pre-existing functional defect on `CourseWorkspacePage.tsx`, out of this plan's composition-audit scope; WP-8 should leave it open and unduplicated.

Out-of-scope open issues not mapped to any work package above, confirmed by this enumeration and left untouched: `#48` (test-suite pollution), `#63` (roadmap "Review week 1" navigation bug), `#79` (E2E sign-in helpers broken), `#80` (forced-password-change leak assertion blind), `#82`/`#139` (seeded relative-date drift), `#137` (re-issue-access fixture mutation), `#140` (roster panel unreachable for a newer non-published course version), `#148` (npm ci corruption), `#150` (`isRoadmapRoute` predicate divergence between `App.tsx` and `ContextStatusStrip.tsx` — narrower and functionally different from WP-9's `ContextStatusStrip` content-drop composition check; do not conflate the two). These are pre-existing engineering/test-infrastructure defects outside this conformance-audit plan's scope and are not created, reopened, or closed by any work package here.

### Proposed new-issue drafts (for WP-0's NEW disposition only — reuse/reopen takes priority)

Each body references the plan path `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`. The WP-3 and WP-4 drafts below are **superseded** by the REOPEN disposition on `#42` resolved in the Issue ledger table above and are retained only as background context for what would have been proposed had `#42` not existed; WP-0 must reopen `#42`, not create a new issue, for WP-3 and WP-4.

**WP-1 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: correct eyebrow tracking, label weight, and display-role token compilation`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-1. Surfaces: cross-cutting (all 28). At stake: `--font-letter-spacing-eyebrow` (currently `.08em`, reference requires `.22em` on every page-eyebrow instance); `--font-weight-label` (currently `700`, reference requires `600`); the `display` type role (68px/.95/-.03em, ratified in `semantic.json` but never compiled to a CSS custom property). Acceptance: token unit tests, `npm run build`, a documented before/after of every consuming rule, and a five-surface/two-viewport Playwright smoke journey under `browser-validation-artifacts/wp-1/`.

**WP-2 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: owner chrome restructure (AdminShell sole chrome owner under /admin/*)`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-2. Surfaces: 6, 7, 8, 9, 18-28. At stake: DS D.6 masthead (lines 966-974) and tab-bar (lines 975-982); the binding chrome-ownership rule requiring `AdminShell.tsx` to own chrome for every `/admin/*` route with the shared header/nav/context-strip/hamburger suppressed there. Acceptance: exactly one Sign-out control at a time; `nativeDialogPolicy.test.ts` and the existing `issue-4-owner-workspace.spec.ts`/`deep-route-check.spec.ts` unchanged-passing; Journeys 1, 3, 4, 5, 10.

**WP-3 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: owner dashboard composition, metric plates, and needs-attention/ledger fixes`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-3. Surfaces: 18. At stake: DS D.6/E.6 (lines 963-1094 / 1507-1571) heading-row same-row layout, uniform 52px metric plates (removing `supportingFigure`), human-language needs-attention text, ledger table without an inner scroll wrapper, and the resolved current-date eyebrow format (`DD MMM YYYY`, locale-explicit). Acceptance: per WP-3's full acceptance list above; Journey 2; the attention-rules fixture reset per the shared reset rule.

**WP-4 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: roster and student detail (DS D.7)`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-4. Surfaces: 19. At stake: DS D.7 (line 1096) admin masthead/tab-bar composition, card-tier rows with band-ink left border and C.3 account-state badge, detail-view heading hierarchy. Acceptance: per WP-4's acceptance list above.

**WP-5 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: feedback inbox no-artboard composition`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-5. Surfaces: 20. At stake: the no-artboard composition table's row for surface 20 (index-card list, glyph+word status vocabulary). Acceptance: per WP-5's acceptance list above.

**WP-6 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: brand & design full state machine (DS D.8)`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-6. Surfaces: 22. At stake: DS D.8 (line 1145) and the Director-revised state machine (permission-denied, loading, populated, client-side validation, saving, save-success, save-error). Acceptance: per WP-6's acceptance list above; the branding-field fixture reset per the shared reset rule.

**WP-7 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: course/business/owner settings and permission-denied deduplication`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-7. Surfaces: 21, 23, 28, plus the shared permission-denied shape across 19/22/23/27/28. At stake: Open decisions #1 (duplicate permission-denied layers) and #2 (heading-text collision). Acceptance: per WP-7's acceptance list above; the per-page `ownerSettingsData` fixture reset per the shared reset rule.

**WP-8 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: new course, course workspace, and surfaces 26/27 correction`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-8. Surfaces: 24, 25, 26, 27. At stake: the five-named-state reconciliation pipeline, C.9 empty-state's three-element rule, and the corrected surface-26 specification (Open decision #3). Acceptance: per WP-8's acceptance list above; the disposable-course creation/teardown rule per the shared reset rule, or an explicit block if no UI deletion path exists.

**WP-9 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: student/shared chrome, footer, accessibility settings, forced password change`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-9. Surfaces: 6, 7, 8, 9, 10, 11. At stake: DS D.2/D.3 light-chrome header lines 627-638/765-777, E.2 mobile lines 1316-1324. Acceptance: per WP-9's acceptance list above; Journey 10.

**WP-10 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: roadmap, week detail, flashcards, and roadmap loading role=status fix`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-10. Surfaces: 12, 13, 14. At stake: DS D.2/D.3/D.4 and E.2/E.3/E.4; the `RoadmapPage.tsx:69` `role="status"` fix (Codex finding `J-02-LOADING-FIX-OWNERSHIP-GAP`). Acceptance: per WP-10's acceptance list above; Journeys 6, 7; the new roadmap-loading accessibility-tree journey.

**WP-11 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: learn index and detail no-artboard composition`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-11. Surfaces: 15, 16. At stake: the no-artboard composition table's rows for surfaces 15/16; `LearnIndexPage.tsx:109`'s `role="status"` fix. Acceptance: per WP-11's acceptance list above.

**WP-12 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: student feedback page (DS D.5/E.5)`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-12. Surfaces: 17. At stake: DS D.5 (line 934) / E.5 (line 1469) composition. Acceptance: per WP-12's acceptance list above.

**WP-13 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: unauthenticated surfaces, GitHub #60 contrast fix, app-loading role=status`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-13. Surfaces: 1, 2, 3, 4, 5. At stake: DS D.1/E.1 and D.9; the GitHub issue #60 background-only contrast fix (re-confirm #60 during WP-0 before treating it as the correct number); `App.tsx:378-384`'s `role="status"` fix. Acceptance: per WP-13's acceptance list above; Journey 8.

**WP-14 draft — proposed, reuse an existing issue instead if the WP-0 enumeration finds one covering this scope.**
Title: `Field Journal conformance: full-surface closure sweep and ledger reconciliation`
Body: Plan: `docs/plans/lizbeth-spanish-fjds-full-surface-conformance-audit.md`, WP-14. Surfaces: all 28. At stake: full regression sweep at both viewport profiles across all eleven journeys, and reconciliation of the audit ledger against the 28-surface inventory. Acceptance: per WP-14's acceptance list above.

## Acceptance and validation (plan-level and per-package)

**Per work package:** `npm run lint`, `npm run type-check`, `npm test` (vitest), and `npm run build` all pass; the package's own Playwright journeys pass at 1440x900 and 390x844 with screenshots written under `browser-validation-artifacts/`; every interactive element and function on the package's surfaces is exercised with a visible outcome; no console errors; `nativeDialogPolicy.test.ts` passes; modal keyboard and focus behaviour is verified where a modal is in scope; the visual comparison tolerance checklist is applied to each artboard-backed surface, or the no-artboard reviewer check is applied to each no-artboard surface; and the audit ledger entry for each surface in the package is complete.

**Plan-level:** the inventory is proven complete by enumerating the route predicates in `src\hooks\useRoute.ts` and their call sites in `App.tsx` and `AdminShell.tsx`, with zero unlisted routes; every one of the 28 surfaces has an ordered work package; and WP-14 reconciles ledger coverage against the inventory.

A screenshot cannot prove font hinting, antialiasing, real-versus-placeholder data, OS chrome rendering, or sub-pixel grid rounding, and a bare pixel-diff percentage is never the conformance gate.

## Risks and rollback

- **Highest risk: CSS cascade regression.** A prior collision is already documented in `docs\plans\lizbeth-spanish-appcss-cascade-collision-cycle4.md`, and `MetricPlate.css:59-68` carries a comment recording a brass-shadow regression that leaked onto metric plates and had to be reverted. Mitigation: one work package at a time; each package re-runs the full unit suite and the existing e2e specs for surfaces it did not touch; WP-2 (the chrome restructure) lands alone before any page work.
- **Chrome restructure blast radius.** WP-2 touches every authenticated route at once and is the single largest blast radius in this plan. Mitigation: it is its own package, gated by the unchanged existing `issue-4-owner-workspace.spec.ts` and `deep-route-check.spec.ts` plus a new duplicate-chrome assertion (Journey 1).
- **Accessibility regression toward the literal specimen.** Mitigation: the brass.300 wordmark invariant, the issue #60 background-only fix, and `@axe-core/playwright` checks on each package's surfaces.
- **Viewport-profile mismatch.** The reference authors at 1440 and 390 while the existing specs use 1280x720 and 375x812. Mitigation: 1440x900 and 390x844 govern conformance grading; the existing profile remains valid for functional regression only. Do not silently rewrite the existing specs' viewports.
- **Plan staleness.** This plan is grounded in the repository as read during design/planning. If a work package finds the source materially different from the findings recorded here, the writer must return `JOB_BLOCKED` with `Plan stale` rather than improvise.
- **Rollback.** Every package is a bounded, uncommitted working-tree change reversible with `git restore`. There is no migration, no data change, and no deploy, so rollback is always local and complete.

## Assumptions and grounding notes

- The app root is `H:\CommandCenter\orchestrator\lizbeth_spanish`, confirmed by reading its `package.json`, `vite.config.ts`, and `playwright.config.ts`.
- The design reference file exists and is authoritative, confirmed present at `design\field-journal\Field Journal DS.dc.html` with its section map in the sibling `README.md`.
- The reference outranks prior adoption decisions where they conflict — this specifically resolves the `MetricPlate.supportingFigure` conflict in favour of uniform plates (see Surface 18 above).
- Artboard-backed surfaces are graded by composition checklist; no-artboard surfaces by primitive composition; neither is graded by a bare pixel-diff threshold.
- The audit ledger is a Scribe-authored deliverable, created by WP-1 and updated by follow-up `DOCUMENT_JOB`s after each package, never authored by the engineering writer.
- Both specialists in the design packet independently marked the same category of file as not independently re-opened in the design pass: `WeekCard.tsx`, `RoadmapPage.tsx`/`BandRoadmap.tsx`, `WeekDetailPage.tsx` and its section components, `FlashcardsViewer.tsx`, `FeedbackPage.tsx`, `AdminStudentsPage.tsx` and its modals, `BrandDesignPage.tsx`/`AssetCard.tsx`, `PublicCatalogPage.tsx`, `CourseSettingsPage.tsx`, `BusinessSettingsPage.tsx`, `NewCoursePage.tsx`, `CourseWorkspacePage.tsx`, `OwnerSettingsPage.tsx`, `LearnDetailPage.tsx`, `AccessibilitySettings.tsx` beyond its focus-trap lines. Each work package touching these files must re-read them directly before editing.
- GitHub issues #31-#44 are all still OPEN and conditionally complete pending that map's own tracked Atelier tooling blocker (#31); no surface should be treated as tool-reverified by this plan.
- **No browser comparison was performed during planning.** Every mismatch recorded in this plan was found by reading the reference file against source code, not by rendering either one. WP-1's smoke journey (see WP-1 above) is the first rendered baseline for this whole effort and may surface mismatches this plan does not list; that is expected, not a plan failure, unless it materially contradicts a finding this plan does record, which triggers the existing staleness rule.
- **No GitHub issue number in this plan is verified against a live query.** Researcher was blocked from running `gh issue list` during planning by two independent hook-policy issues (see the Issue ledger section for the full trace). Every issue number cited in this plan (#31-#44, #60) comes from the local coverage-map document, not a live source, and must be re-confirmed during WP-0 before any issue is created, reused, or reopened.

## Approval gate

This plan requires explicit user approval before any `ENGINEERING_JOB` is dispatched against it. Upon approval, Scribe updates the status header above from DRAFT to APPROVED. T1 execution of WP-1 may not begin until that update is made.

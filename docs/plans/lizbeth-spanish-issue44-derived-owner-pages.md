
# Lizbeth Spanish, Issue #44: Screens — Derived Pages with No Reference Artboard

**Status: Approved for engineering under standing authorization. Dated 2026-09-02.** See "Approval basis" immediately below for the basis and provenance of this approval.

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference and follows the same provenance discipline the #31-#43 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished" and "don't stop until all the DS gh issues are implemented and browser validated." The orchestrator reports both statements as the user's own live-session standing authorization plus the explicit session goal, together covering this plan's approval on the same basis already recorded on the #31-#43 plans.
- **Application:** issue #44 is the fourteenth and final issue of the Field Journal Design System milestone (#31-#44) and the last issue in the exact chain the user directed continuation through. #31-#43 all landed: verified, browser-validated, design-reviewed PASS, all left OPEN tracking one shared binding follow-up (a disclosed, user-authorized Atelier MCP compiler gap). This is the last plan document the milestone requires.
- **Pre-flight staleness check performed.** The orchestrator independently fetched the live GitHub issue #44 body via `gh issue view` and relayed it directly into Planner's context, satisfying the plan's pre-flight staleness check, consistent with the practice established for #40-#43.
- **`PLAN_DUCK` Codex judge checkpoint (Terra tier), run given this plan's size and blast radius**, unlike #43. This is the largest and highest-blast-radius plan of the entire milestone: it touches `CourseWorkspacePage.tsx` (the app's single largest and most complex file) plus six other owner-side files. It returned two evidence-backed findings, both resolved as binding Planner decisions before approval:
  1. **Major finding.** The plan had deferred three Control-tier button assignments (Outline "Remove lesson," Versions "Apply migration," Publishing "Finalize publish") as "pending product decisions," despite the plan's own acceptance criterion requiring full composition from existing primitives with no product-policy holds. Resolved: Planner assigned all three tiers directly from fresh code inspection using the app's already-established reversibility convention documented in `Control.css:66,82` — Remove lesson and Apply migration both mutate reversible state and take `caution-reversible`; Finalize publish takes `caution-irreversible`, justified by tracing the codebase's own comment block (`CourseWorkspacePage.tsx:894-906`) documenting it as a genuinely one-way transition once a version moves past `draft`. See "Per-section composition spec."
  2. **Minor finding (J-44-02).** A planned `CourseSettingsFix.css` checkbox-CSS deletion would have dropped an explicit `width`, risking the checkbox shrinking to its roughly 13px intrinsic size once the surviving `width:auto!important` rule took over. Resolved: an explicit `width:20px!important` floor was added to `.checkbox-label input` in the same Phase 0 change, matching the app's own already-established 20px checkbox convention. See "`CourseSettingsFix.css` verdict."
  Deterministic checks, Verifier, and Browser Validator passes remain mandatory regardless of the judge checkpoint's outcome.
- **Three major scope-grounding findings from planning research, preserved here for the approval record:**
  1. **`OwnerSettingsPage.tsx` is unrouted dead code, not reachable in the live app.** `AdminShell.tsx` imports and renders eight admin page components, and `OwnerSettingsPage` is not among them; `App.tsx`'s allowlist redirects any unknown owner-area path, including `/admin/owner-settings`, to the dashboard. The actually-live consumer of `OwnerSettingsPage.css`, the stylesheet this plan touches, is `BrandDesignPage.tsx` — a page the GitHub issue body never mentioned. `BrandDesignPage.tsx` was added to this plan's in-scope file list as a required non-regression check specifically because of this finding.
  2. **`CourseSettingsFix.css`, the technical-debt file the issue explicitly requires eliminating, has nine rules, not the six initially assumed.** The corrected rule-by-rule audit folds three rules into the surviving system and drops six as genuinely obsolete, with the checkbox-width companion amendment above closing the one deletion that would otherwise have been unsafe.
  3. **Three genuine primitive gaps were found and are deliberately deferred, not implemented, in this plan:** a Tiptap rich-text editor surface, an asset-card grid, and a `StudentRoster` per-lesson access row. Each receives foundation-only interim treatment and is recorded as a disclosed follow-up-issue candidate, per the GitHub issue's own hard constraint against inventing new primitives.
- **Atelier disclosed-unavailable.** The hand-transcription / documented-manual-visual-diff substitute precedent from #31-#43 is pre-authorized and carries forward. Explicitly: because no screen-level artboard exists for any of these five pages, the issue's `visual_diff` verification criterion means diffing against the primitives' own reference sections (A/B/C), never a screen-level mock.
- **Provenance label:** this basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements, the `gh issue view` fetch, the `PLAN_DUCK` run, or the Planner findings beyond what is already recorded elsewhere in this document. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval. If the standing authorization is later withdrawn or found not to cover this issue, the plan reverts to requiring explicit per-document approval.
- **Date:** 2026-09-02.

---

Plan ID: `lizbeth-spanish-issue44-derived-owner-pages`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: standard (`design-director`, `ux-architect`, `visual-system-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome and audience

GitHub issue #44, "Screens: derived pages with no reference artboard," labels `enhancement`, `role:owner`, `design:screen`. Depends on #37-#43, all landed. Reference: `design/field-journal/Field Journal DS.dc.html` sections A + B + C only — these pages have no D/E artboard.

Observable result: five owner-side pages composed strictly from already-shipped A/B/C primitives; `CourseSettingsFix.css` deleted; the disclosed zero-`@media` reflow gap in `OwnerSettingsPage.css` closed; all pages reflowing cleanly at 390 with no horizontal body scroll; every existing course-authoring test still green.

Audience: the T1/T2 engineer implementing this plan; the app owner who uses these screens.

## Scope

**In scope**, seven named files:

- `src/pages/CourseWorkspacePage.tsx` (919 lines)
- `src/pages/CourseWorkspace.css` (67 lines)
- `src/pages/CourseSettingsPage.tsx` (8 lines)
- `src/pages/CourseSettingsFix.css` (1 minified line — target: DELETE)
- `src/pages/NewCoursePage.tsx` (5 lines)
- `src/pages/BusinessSettingsPage.tsx` (46 lines)
- `src/pages/OwnerSettingsPage.tsx` (307 lines) + `src/pages/OwnerSettingsPage.css` (332 lines)

**Plus one required affected consumer not named in the issue body:** `src/pages/BrandDesignPage.tsx` (70 lines). This addition is justified prominently: it imports `./OwnerSettingsPage.css` (`BrandDesignPage.tsx:9`), so the new media block lands in a stylesheet it consumes, making it materially affected and requiring 390px non-regression verification. It is live at `/admin/brand-design` (`AdminShell.tsx:9,27,52`) and was shipped by #43. This is a non-regression check, not a redesign.

**Non-goals (binding — the writer returns `JOB_BLOCKED` rather than exceed these):**

- No new component, no new variant of an existing component, no new prop, no new design token. This is the issue's own hard constraint.
- No redesign of `BrandDesignPage.tsx` — non-regression verification only.
- No migration of `.owner-settings-field` / `.owner-settings-save-button` to `Field`/`Control` on any of the three consumer pages.
- No confirmation Modal added to "Finalize publish" — that is a behavior change requiring separate product sign-off.
- No interactive controls added to `CourseSettingsPage`'s non-owner branch, which is locked at zero buttons/links/textboxes.
- No conversion of any list to a table or any tabular data to CSS grid.
- No remediation of the pre-existing WCAG 2.5.3 Label-in-Name mismatch on the bulk-fill inputs.

### Critical scope correction — `OwnerSettingsPage.tsx` is unrouted and unreachable

**CRITICAL SCOPE CORRECTION, evidence-backed.** `src/pages/OwnerSettingsPage.tsx` is currently unrouted and unreachable as a page in the shipped app. `AdminShell.tsx:5-12` imports eight page components (`OwnerDashboardPage, AdminStudentsPage, OwnerFeedbackPage, BusinessSettingsPage, BrandDesignPage, CourseSettingsPage, CourseWorkspacePage, NewCoursePage`) and renders exactly those eight at `:45-52` — `OwnerSettingsPage` is absent from both. `App.tsx:86`'s `knownAdminRoute` allowlist excludes `/admin/owner-settings`, and `App.tsx:91-92` fires a real `replaceNavigate('/admin/dashboard')` for any unknown owner-area path, with the render-time `role="status"` "Redirecting to the owner dashboard…" at `App.tsx:195-196`. The only importer of the page component is `src/__tests__/OwnerSettingsPage.test.tsx:5`.

The file is not fully dead: its named export `ColorPreview` (`OwnerSettingsPage.tsx:40-46`, `<p className="owner-settings-color-preview" aria-live="polite">`) is live, consumed by `BrandDesignPage.tsx:8,60-61`.

Consequence: it stays in scope per the issue body, but its validation is component-level only, never a URL journey — `/admin/owner-settings` does not resolve. Whether it should be routed, retired, or kept as an intentional unrouted fixture is an open product question (recorded in "Assumptions and decisions," non-blocking).

## Verified repository findings

**Migration state.** `CourseWorkspace.css` and `OwnerSettingsPage.css` are ~90%+ token-compliant on values but 0% component-compliant — none of the seven files' `.tsx` uses any journal/C component or the shared `Control`/`Field` primitives. All buttons are raw `<button className="demo-button ...">`; all inputs are raw HTML. `CourseSettingsFix.css` is 0% token-compliant (all raw px, no `var()` at all). `OwnerSettingsPage.css` has zero `@media` queries anywhere, self-documented as a known disclosed gap at its lines 51-52 and 197-198, carried forward from #43. `NewCoursePage.tsx` has no CSS import of its own and depends fragilely on an ancestor having loaded `CourseWorkspace.css`.

**`CourseWorkspacePage.tsx` section map** (verified line ranges): 1-73 module scope + `TABS` (`outline, content, students, progress, activity, settings, versions, publishing`); 75 `TabBoundary` error boundary; 79-140 `Outline`; 142-158 `Content`/`Editor`/`LessonEditor`/`StructuredRows`; 184-256 `ReconciliationPanel`; 258-483 `StudentRoster` (largest single function); 485-517 `Students` wrapper; 519-682 `CohortList`/`CohortRow`; 684-714 `CohortForm`; 715 `DataList`; 722-735 `ModeSwitchModal`; 754-818 `PrerequisiteField` (six states); 842-853 `CompletionThresholdField` (four validation states); 855-891 `Settings` (the `.settings-grid` form); 892 `Versions`; 893-918 `Publishing`.

**Primitive inventory** (authoritative, all read in full):

- C.1 `Control.tsx`: `{tier?: 'primary'|'secondary'|'caution-reversible'|'caution-irreversible'|'quiet'|'quiet-outline'}`, default secondary, `--control-height:48px` (`field-workbook.generated.css:40`), disabled requires native `disabled`.
- C.2 `Field.tsx`: `{label, id, error?, className?, as?:'input'|'textarea'}`, root is `<div className="field">` (`Field.tsx:72`), error `<div>` has no `role` (`Field.tsx:87`), `aria-describedby` set before the `...rest` spread (`Field.tsx:58-64`).
- C.3 `Badge.tsx`, `AccountStatusPill.tsx` (fixed states `active|pending|disabled`, `:16-20`, no label override).
- C.4 `WeekCard.tsx`.
- C.5 embedded in `LessonContentView.tsx`.
- C.6 `SegmentLedger.tsx` (`role="tablist"`, requires per-segment `minutes` for proportional `flexGrow`, `:6-7,89`) — this replaced the old "stepper."
- C.7 `OwnerLedgerRow.tsx` (one `<tr>`, 4 `<td>`, mounts in a caller-owned `<table><tbody>`).
- C.8 `MetricPlate.tsx`: `{label, value, tone?:'default'|'dark'|'attention', zeroPad?, supportingFigure?}`, label renders in its own `<p className="metric-plate-label">` (`:37`), no slot for extra prose (`:31-42`).
- C.9 `journal/JournalEmptyState.tsx`: `{illustrationSrc (required), eyebrow?, bodyText, className?}`.
- B devices: `ClipRing`, `Folio`, `Stamp`, `TabStack` — all `aria-hidden` decorative; `TabStack` is never interactive, never `role="tab"`, never focusable.
- `Modal.tsx`: `{isOpen, onClose, title, children, ariaDescribedBy?, suppressDismiss?, triggerElement?}`.

**Naming note.** The README section map's labels "stepper" (C.6), "index card" (C.7), and "table" (C.9) are the original reference-doc terminology, not shipped component names. All nine C-slots have shipped implementations. There is no missing stepper/index-card primitive — that is naming drift, not a gap.

**Native dialog scan.** A grep for `alert(|confirm(|prompt(|window.alert|window.confirm|window.prompt|beforeunload` across `src/pages/` returns zero matches. All confirmations already use the app-owned `Modal`. `issue5-phase3-reconciliation-panel.test.tsx` explicitly asserts `window.confirm` is never called; `cohortInviteEnrollmentUi.test.tsx` explicitly asserts no alert/confirm/prompt/beforeunload. The invariant is currently clean and must stay clean.

**Build-breaking lint, `src/__tests__/tokenFallbackAuditLint.test.ts`.** No `var(--x)` referencing an undefined custom property; no raw hex outside `src/tokens/` including inside `var(--x,#hex)` fallbacks; no non-zero `border-radius` in any form (`50%`, `999px`, longhands, vendor-prefixed) except literal `0` or `var(--radius-square)`/`var(--radius-none)`; no `box-shadow` with non-zero blur.

`issue36Tokens.test.ts` locks exact values including `--font-letter-spacing-wider:.18em`, `--font-size-label-small:0.6875rem`, `--border-width-accent:6px`, `--shadow-muted-card`, `--color-rule-tint-slate:#cddadd` (the one ratified lint-exempt raw hex, inside `src/tokens/`), and band aliases `--color-band-beginner:var(--color-brass-600)` / `-intermediate:var(--color-terracotta-600)` / `-advanced:var(--color-ink-slate)`.

`fieldJournalTokens.test.ts` has a known, disclosed, pre-existing partial-RED state on its mechanism-2 assertions pending an Atelier regeneration — unrelated to #44; do not attempt to fix it, and do not treat it as a #44 regression.

**Confirmed present at claimed values:** `--space-2:.5rem`, `--space-3:.75rem`, `--space-4:1rem`, `--border-width-hairline:1px`, `--hit-target-min:44px`. `--typography-fontSize-sm:0.875rem` is real but hand-declared at `App.css:50`, not from the DTCG pipeline — this provenance is recorded here deliberately.

**Scripts** (`package.json`): `dev` = `vite` with a `predev` = `npx tsx scripts/ensure-lesson-assets-bucket.ts` pre-hook; port 5173 from `vite.config.ts`; `test` = `vitest`; `lint` = `eslint src --ext ts,tsx`; `type-check` = `tsc --noEmit`; `build` = `tsc && vite build`; `verify:build` = build plus three leak/config check scripts; `preview:prod` = `vite preview --port 4173 --strictPort`.

## Research evidence and its limits

Two nested Researcher passes returned local-repository evidence packets, grounded entirely in repository inspection; no web sources used.

**One acknowledged limit, carried prominently.** The Researcher's Bash allowlist (`.claude/hooks/validate-researcher-bash.ps1`) blocks `npx`, `npm run`, and `vitest`, so no planning-stage agent executed any test. The green baseline is unverified. Establishing it is ordered-work step 1, mandatory and blocking.

**Also disclosed:** `cohortMembersAndInvite.test.tsx`, `cohortInviteEnrollmentUi.test.tsx`, and `publishJobHydration.test.tsx` were grep-sampled, not fully read, during planning — their byte-exact strings below are paraphrased, not verbatim. The engineer must read them in full before touching those flows (ordered-work step 2).

## Locked test invariants

Reproduced in full — this is the plan's most load-bearing section and must not be compressed.

**`issue5-phase3-student-roster.test.tsx`.** Roster toggle is `getByRole('button',{name:/StudentName/i})` with `aria-expanded`; expanded region is `getByRole('region',{name:/StudentName/i})`; no-entitlement cell is a `<select disabled>` inside `.roster-lesson-row` with text `/no entitlement row exists yet/i` and `setLessonAccessState` must not be called; every real select exposes exactly option values `['automatic','released','held','revoked']` in that literal order; selecting "released" opens `getByRole('dialog')` with text matching `/immediately/i` and `/cannot be undone/i`, and `setLessonAccessState` must not fire until the dialog's `/^release$/i` button is clicked, then called with exact args `('enr-1','l1','released')`; cancelling leaves it uncalled and removes the dialog; "held" must not open a dialog, calls `setLessonAccessState('enr-1','l1','held')`, surfaces `/held from maria lopez/i` with `role="status"`; "automatic" on a past-`unlock_at` row surfaces `/stays unlocked.*will not re-lock/i` with `role="status"`; `held_not_completed_count>0` renders `/2 lesson\(s\) currently held and not completed/i` with `role="status"` and class `schedule-severity-advisory`, absent when zero; for a draft course the whole `StudentRoster` panel (`heading /student roster/i`) is absent while `/cohorts and enrollment/i` still renders.

**`issue5-phase3-reconciliation-panel.test.tsx`.** Heading `/retroactive entitlement reconciliation/i`; Preview button `/preview reconciliation/i`; after preview, bucket labels `/unlocking now/i`, `/still locked/i` (2+ matches), `/newly eligible/i`, `/excluded/i`, `/already visible/i` (2+ matches) must all remain findable by text; anchor text `/each student's own enrollment date/i` or `/the cohort's start date/i`; preview error is `getByRole('alert')` `/not authorized/i` with class `schedule-severity-error` plus a `/retry/i` button; **`window.confirm` must never be called**; Apply opens a dialog showing the unlock count and excluded-override count as visible text, closing only after the dialog's exact `/^apply$/i` click, calling `applyReconciliation('version-1','token-abc')`; cancel leaves it uncalled; partial failure renders a `role="status"` `/2 succeeded/i` plus a separate `role="alert"` list with the failure reason; stale-token rejection renders `role="alert"` `/out of date|refresh|fresh preview/i` with class `schedule-severity-error`; panel absent for draft, present for published.

**`issue5-phase3-prerequisite-and-threshold.test.tsx`.** `listOwnerCourseVersions` called with `('course-1')` and the current course's own title never appears in the Course select. Six states: loading `/loading your other courses/i`; none-selected `courseSelect.value===''`; valid renders the exact enforced-copy string byte-for-byte; unresolvable shows `role="alert"` with both `/no requirement is currently enforced/i` and the literal saved ghost ID, resets both selects to `''`, and a Save still sends the original unresolvable ID (`prerequisite_version_id === 'ghost-version-id'`); load-error shows `/any saved requirement remains enforced/i` and Save preserves the original; course-changed resets the version select to `''`, shows `/choose a version of intermediate spanish/i`, and Save sends `null`. Threshold: populated `input.value==='80'`; blank `input.value===''` plus `/blank means all lessons are required \(100%\)/i`; literal `0` shows `/entering 0 means a student is considered complete/i` with `role="status"` and class `schedule-severity-advisory`; out-of-range blocks save with alert text exactly `"Enter a whole percent from 0 to 100, or leave blank for 100%."`, alert `id==='completion-threshold-error'`, input `aria-describedby` containing that id, `updateCourse` not called; blank always saves `completion_threshold: null`, never `0`; the input's `aria-describedby` always contains `completion-threshold-hint`. **Field-order regression guard: inside `.settings-grid`, a `<label>` must never immediately follow a `<fieldset>` as a DOM sibling**, checked by direct `container.querySelector('.settings-grid').children` iteration (`:210-223`).

**`issue5-phase3-enrollment-blocked-alert.test.tsx`.** A P4001 rejection from `approveEnrollmentRequest` renders `role="alert"` with the exact composed string from `formatPrerequisiteBlockedAlert`, class `schedule-severity-error`; the raw `user_id` UUID must never appear in the DOM anywhere in the enrollment-request list; the Approve button stays `toBeEnabled()` for retry; every other approval failure keeps `role="status"`, not alert.

**`issue5-phase4-revoke-action.test.tsx`.** Dialog title exactly `"Revoke access to this lesson?"`; `aria-modal="true"`; warning paragraph must match `/Nothing is deleted/`, `/You can restore access later/`, `/any time lost while access was revoked isn't restored/`, and must not match `/permanent|forever|cannot be undone|irreversible/i`; `dialog.aria-describedby` equals the warning paragraph's own `id` (`revoke-warning`, `CourseWorkspacePage.tsx:452,454`); the student-visibility caveat paragraph has no `role`; confirm button name exactly `/^revoke access$/i` with classes `demo-button` and `caution`, enabled, no typed-literal gate; cancel has `demo-button` and `secondary`; `.destructive-warning` must be absent; no `role="textbox"` in the dialog; a `/close/i` button present. Cancel and Escape both close with zero `setLessonAccessState` calls, select stays `'automatic'`. Confirm closes the dialog before the write resolves, then calls `setLessonAccessState('enr-1','l1','revoked')`, then shows exactly `"Greetings access is now revoked for Maria Lopez."` with `role="status"`. A failed write still closes first, shows exactly `"Could not revoke access to Greetings."`, select reverts to `'automatic'`. No-entitlement select is `disabled` and never exposes a Revoked option.

Evidence block, four states: loading `role="status"` exactly `"Loading what Maria Lopez has done in this lesson…"` with Confirm still enabled; resolved-with-data matches `/Completed on/`, exactly `"2 attempt(s) recorded"`, plus the always-shown limitation sentence; resolved-zero exactly `"Not completed"` and `"No quiz attempts recorded"` using the same two row labels `"Completed:"`/`"Quiz attempts:"` with no distinct empty-state markup; error `role="alert"` exactly `"Couldn't load completion and quiz details for this lesson."` plus `"You can still revoke access without this information."`, Confirm still enabled, and a `/try again/i` retry that re-fetches.

Reversal transitions: revoked→automatic (future unlock) exactly `"...Access is restored, but the time it was revoked has already passed and is not restored."`; revoked→automatic (past unlock) appends the reversal sentence to the existing "stays unlocked" sentence, both present; a non-revoked row gets no reversal sentence; revoked→released appends `/This lesson was previously revoked; the time it was unavailable is not restored\./` while preserving `/becomes visible to Maria Lopez immediately/`; non-revoked→released has no "previously revoked" text; revoked→held gets only the ordinary held message and its textContent must not match `/revoked|restored/i`.

Advisories: `/2 lesson\(s\) currently revoked and not completed/i` with `role="status"` class `schedule-severity-advisory`; when both held and revoked counts are nonzero exactly 2 render with held first, verified by both array order and `compareDocumentPosition`/`DOCUMENT_POSITION_FOLLOWING`; only-revoked renders one; both-zero renders neither.

**`issue5-phase4-revoked-rendering.test.tsx`** (ordering gate — must pass before revoke-action tests are meaningful). Every select's 4 options in exact value order `['automatic','released','held','revoked']` and exact label order `['Automatic','Released','Held','Revoked']`; exactly one combobox per row; select `aria-label` exactly `'Access for Numbers'`; a pre-seeded revoked row's `select.value==='revoked'`; revoked-hint text exactly `"Access revoked. Maria Lopez cannot open this lesson while it's revoked. Set it back to Automatic or Released to restore access."`, no `role`, class contains `revoked-hint`, textContent must not match `[⚠🚫❗]`; hint absent on non-revoked rows; `aria-describedby` present only on the revoked row's select and must resolve via `document.getElementById` to an element whose text starts with `/^Access revoked\./`; the non-revoked select must not have `aria-describedby` at all; both "Automatic" and "Released" stay `toBeEnabled()` on a revoked row; selecting "revoked" opens a `role="dialog"` and must not call `setLessonAccessState` until confirmed.

**`issue5-phase2-components.test.tsx:197-198`.** `getByLabelText(/bulk fill start offset/i)` resolves via the `aria-label` at `CourseWorkspacePage.tsx:118`; the second input at `:119` carries `aria-label="Bulk fill step"`.

**`courseAuthoringUi.test.tsx`.** Headings `/content studio/i`, `/course outline/i`; button names `/add lesson/i`, `/try again/i`, `/dictionary check/i`; label `/upload asset/i`; a legacy lesson with `body.en: null` must not surface `/cannot read|undefined/i` anywhere.

**`Issue4SettingsPages.test.tsx`.** Loading = `role="status"`, zero buttons, zero textboxes. Hydration reads exact field values (`/instructor.*company name/i`, `/copyright text/i`, `/ip.*copyright notice/i` for Business; `/primary brand color/i`, `/secondary brand color/i`, `/logo url/i` for Brand). Non-owner on business/brand/course shows the page's own heading plus `role="alert"` `/permission/i`, zero buttons, zero textboxes. Business save sends exactly `{brand_name, legal_copyright_text, legal_ip_notice}`, no extra keys. Brand save always sends both colors and logo even when one changed. Overlong-name validation sets `aria-invalid="true"`, `aria-describedby` to the exact per-page error id (for example `business-brand-name-error`), and moves focus. A successful save re-hydrates from the returned values and calls `refresh()` exactly once. Null optional brand fields normalize to empty string, never `"null"`/`undefined`. A write failure preserves the user's edited value and shows `role="alert"`. The brand form stays mounted through a `loading:true` re-render. Brand live preview `data-testid="brand-live-preview"` mark has `aria-hidden="true"`, exactly 2 `.owner-settings-preview-swatch` elements, none `--empty` when both colors complete; an incomplete value (`#abc1`) makes swatch 0 carry `owner-settings-preview-swatch--empty`. **`CourseSettingsPage` for an owner renders both headings `/course settings/i` and `/planned course workspace/i`, texts `/daily and weekly course creation/i`, `/progress and activity tracking/i`, `/content curation/i`, and has zero `form`/`button`/`link` roles** — flagged loudly; this directly conflicts with adding any interactive control to that branch.

**`OwnerSettingsPage.test.tsx`.** Non-owner shows `role="alert"` `/permission/i` and the name field must be absent, not merely disabled; owner form pre-fills exactly (`/instructor.*company name/i` = `'Lizbeth Spanish'`, `/ip.*copyright notice/i` = `'Enrolled students only.'`); a non-compliant hex shows `/adjusted for readability/i` live without submit, a compliant one shows nothing; successful save shows `role="status"` `/saved/i` with `aria-live="polite"` and calls `refresh()`; save failure shows `role="alert"` `/permission/i`, never a dialog; a >200-char brand name blocks save, shows `/200 characters or fewer/i`, moves focus to the name input, `saveOwnerSettings` never called.

**`cohortMembersAndInvite.test.tsx`** (paraphrased, grep-sampled — the engineer must read in full). Cohort row is a `button` with `aria-expanded`; loading `/loading members/i` has `role="status"`; empty-members text has explicitly no role; member-load failure is `role="alert"` + `schedule-severity-error` with a `/try again/i` retry; invite submit is `aria-disabled="true"` until a student is selected; invite success `role="status"`, failure `role="alert"` + `schedule-severity-error` with the button staying enabled; members load lazily on first expand and are cached.

**`cohortInviteEnrollmentUi.test.tsx`** (paraphrased, grep-sampled). Member status labels are exactly `"Enrolled"` and `"Invited (legacy)"`; a successful invite announces enrollment (not "invitation") with `role="status"` and clears the selection; capacity refusal is `role="alert"` + `schedule-severity-error`, adds no row, preserves the selection for retry; a prerequisite refusal renders through `formatPrerequisiteBlockedAlert` with the student's email in the name position; the roster refetches after invite and must never flash "No enrolled students yet." between invite and refresh; **explicitly asserts this flow never calls `alert`, `confirm`, `prompt`, or registers `beforeunload`**.

**`publishJobHydration.test.tsx`** (paraphrased). A fresh mount resumes an already-staged, unfinalized publish job without re-staging (the issue #46 fix at `CourseWorkspacePage.tsx:894-906`); an already-finished job is not resurfaced on mount.

**Out of scope for UI invariants:** the `issue5-phase5-learn-*` tests (student-facing) and every `*sql*`/`*live*`/`*edge-allowlist*` test (data layer, mocked at the `services/courseAuthoring` boundary) — they touch no rendered markup in these seven files.

## Design route and handoff

```
DESIGN_ROUTE
profile: standard
reasons: five owner-side pages with no reference artboard; multi-state components; an authored-from-scratch 390px reflow; a technical-debt CSS file to fold or delete. Composition-only bounds creative risk but the surface area is the milestone's largest.
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

**Selected direction: Preserve** — composition-only assembly from shipped primitives. No new creative direction is authorized or needed.

### Composability verdicts (the issue's hard constraint in action)

Three genuine gaps, each a disclosed follow-up-issue candidate, not to be implemented:

1. **Tiptap rich-text editor surface** (`CourseWorkspacePage.tsx:142-158`). No primitive renders a `contentEditable` region; `Field` is typed `input|textarea` only. Follow-up: a rich-text-editor primitive. Foundation-only interim treatment: paper-stock chrome (toolbar, paper.200) / interactive (body, paper.100) matching `semantic.json:12-15`; rule 2px ink.800; focus 3px terracotta.600 / 2px offset per the existing page-chrome convention (`CourseWorkspace.css:3`).
2. **3-column asset library card grid** (`:153`). No primitive supports thumbnail + content-type + byte-size + copy-reference/remove. Follow-up: an "asset card" primitive. Foundation-only: interactive tier inherited; 1px ink.700 hairline; `var(--space-2)`; inherited body type + `<small>` in ink.700.
3. **StudentRoster per-lesson row/container** (`:396-430`). `OwnerLedgerRow`'s prop shape has zero overlap with the per-lesson-access need; per the `FeedbackLedgerRow` precedent (#41 decision D3) the codebase builds a disclosed sibling rather than force-fitting. Follow-up: a "labeled access-control row" primitive. Foundation-only: interactive tier; 1px ink.800 divider (consistent with the page's 3px primitive / 2px panel / 1px interior hierarchy); existing `--space-*`; revoked-state differentiation weight-only, never color-only (matching `CourseWorkspace.css:55-58`). The select, revoked-hint, and both Modals inside already compose fully and need no follow-up.

One composable-with-layout-only: **ReconciliationPanel's six buckets** → six `MetricPlate` instances in the existing card grid, with each bucket's `describe()` sentence as a plain sibling `<p>` immediately after the MetricPlate, never inside it (no slot exists, `MetricPlate.tsx:31-42`). `MetricPlate`'s label renders in its own `<p className="metric-plate-label">` (`:37`), so every locked `getByText`/`getAllByText` bucket query stays satisfiable, including the two 2+-match ones (traced against `CourseWorkspacePage.tsx:176-181`). The container never becomes tabular.

### Per-section composition spec

All six shipped `Control` tiers are now in play across this plan: secondary, primary, quiet, quiet-outline, caution-reversible, and caution-irreversible. The three buttons previously held for product policy (Outline Remove, Apply migration, Finalize publish) are assigned below using the reversibility convention `Control.css` itself documents — "Caution-reversible (amber) — e.g. Disable" (`Control.css:66`) and "Caution-irreversible (terracotta) — e.g. Delete" (`Control.css:82`). The Revoke confirm button remains the sole exception, staying fully native because `Control` never emits a bare `.caution` class.

**Header** (`:72`). "Create draft"/"Save draft" → Control secondary/primary, disabled via `aria-disabled` when `invalidOffsetCount>0`. Tab strip (`:72`, `role="tablist"`): preserved exactly, not a `SegmentLedger` candidate (`SegmentLedger.tsx:6-7,89` requires per-segment minutes; no analog for 8 unrelated sections); the sanctioned horizontal-scroll strip (`CourseWorkspace.css:3,6`) is unchanged and must never leak scroll to the page body.

**Outline** (`:79-140`). Bulk-fill inputs (`:118-119`) → Field, and the engineer must pass `aria-label="Bulk fill start offset"` / `"Bulk fill step"` through verbatim (`Field.tsx:58-64` spreads `...rest` after its own attributes so it survives, but dropping it as "redundant" breaks `issue5-phase2-components.test.tsx:197-198`). "Apply to all" → secondary; advisory/error banners stay native; title inputs (`:124`) → Field with new ids; lesson-type select stays native; **unlock-offset field (`:127-134`) stays fully native** — its error is a sibling `<p role="alert">` and `Field.tsx:87`'s error div has no `role`, and its `aria-describedby` composes two ids that Field's ordering would override. Row actions (`:137`) → quiet (reorder) / secondary (Duplicate) / **caution-reversible (Remove)** — `Remove lesson` mutates only local unsaved draft state (`onDirty(); setBlocks(items => items.filter(item => item.id !== block.id))`) and is reversible by not saving, so it takes the amber tier per `Control.css:66`'s reversibility convention. Every row-action button's `aria-label` — `Move lesson ${index+1} up`, `Move lesson ${index+1} down`, `Duplicate lesson ${index+1}`, `Remove lesson ${index+1}` — must be passed through the `Control` migration verbatim via its `...rest` spread (`Control.tsx:53`); these are the buttons' accessible names. "Add lesson" → secondary.

**Content** (`:142-158`). Toolbar → secondary; "Find a lesson" / asset search / media-URL → Field; StructuredRows prompt/answer → Field, Remove → caution-reversible, Add → secondary; **the file-upload trigger is a `<label className="demo-button secondary">` wrapping a hidden input — not a Control candidate** (Control renders a `<button>`); Remove-asset → caution-reversible; Copy-reference → secondary; pagination → secondary.

**StudentRoster** (`:258-483`). Toggle (`:382-384`) → Control `tier="quiet-outline"` (`Control.tsx:31-38` documents exactly this pattern). Held/revoked advisories stay native, held rendered first. Per-lesson row/select/hint (`:396-430`) stays fully native. **Revoke confirm button (`:478`) stays fully native** — its `demo-button caution` classes are locked verbatim and `Control` never emits a bare `.caution` class (only `control--caution-reversible`/`-irreversible`), so there is no collision.

**Students/Cohorts** (`:485-682`). Approve/Decline → primary/secondary; CohortRow toggle (`:646`) → quiet-outline; member-status text stays plain (`AccountStatusPill`'s fixed `active|pending|disabled` vocabulary cannot express "Enrolled"/"Invited (legacy)" and has no label override); Invite button (`:672`, already `aria-disabled`) → Control primary (forwarded via spread, `Control.tsx:53`). CohortForm (`:684-714`): Submit → primary, inputs keep external `role="alert"` siblings. DataList (`:715`): "Try again" → secondary, rows stay plain `<li>`. ModeSwitchModal (`:722-735`): Cancel/Confirm → secondary/primary.

**PrerequisiteField** (`:754-818`) **and CompletionThresholdField** (`:842-853`) stay fully native — both have native `<fieldset>` roots and need simultaneous dual `aria-describedby` composition plus `role="alert"` that Field cannot provide.

**Settings** (`:855-891`). Title/description/capacity/preview-search → Field with new ids; selects and the manual-release checkbox stay native (the latter already uses the shipped `.checkbox-label`); Save → primary. Verified: no `<label>` currently follows a `<fieldset>` as a sibling at `:870-879`, and Field's root is `<div className="field">` not a bare `<label>` (`Field.tsx:72`), so migration cannot itself trip the field-order guard — but relative order must be preserved exactly.

**Versions** (`:892`). Raw `<pre>` diff, no primitive fits, not a gap; View diff → secondary, **Apply migration → caution-reversible** — `applyMigration(enrollment, target)` writes server-side but is reversible, since the same control can migrate the enrollment to another version and the version select stays populated with every available version. **Publishing** (`:893-918`): stage/retry → secondary; **Finalize publish → caution-irreversible** — `finalizePublish(job.id)` is a one-way transition once a version moves past `draft` (the edge function rejects further asset registration, and the issue #46 comment block at `:894-906` confirms a succeeded job is deliberately excluded from resumption because it has "nothing left to finalize or retry"); it currently fires with no confirmation Modal — flagged, deliberately not added.

**`CourseSettingsPage.tsx`.** Non-owner branch locked, preserve exactly. Owner branch buttons → primary/primary/secondary. `.status-pill` stays native. The empty state is not a `JournalEmptyState` fit — that primitive requires a real `illustrationSrc` and is built for the student-facing register; this owner tier is deliberately more utilitarian per `OwnerSettingsPage.css:3-6`'s own comment. Keep the plain `.workspace-empty` text.

**`NewCoursePage.tsx`.** Name input → Field; band select and enrollment radios stay native; "Create course" → primary. Two pre-existing structural bugs fixed as part of this issue: (1) it has no CSS import of its own — add `import '../pages/CourseWorkspace.css'`; (2) three classless radio `<label>` elements inherit `.course-workspace label{display:grid;gap:6px}` and stack the radio above its text — apply the existing shipped `.checkbox-label` class (already used correctly at `CourseWorkspacePage.tsx:879-880`).

**`OwnerSettingsPage.tsx` / `BusinessSettingsPage.tsx` / `BrandDesignPage.tsx`.** The `.owner-settings-field` / `.owner-settings-save-button` patterns are deliberately not migrated — `Field.tsx:87`'s error div has no `role`, and migrating would silently downgrade currently-tested `role="alert"` field errors. `BrandDesignPage.tsx:60-62` confirms all three of its fields (primary color, secondary color, logo URL) carry `<span role="alert" className="owner-settings-field-error">` siblings, so the exclusion applies to all three.

### `CourseSettingsFix.css` verdict: DELETE — rule by rule

The file contains nine rules, not six (the first audit undercounted; corrected in review). Sole importer `CourseWorkspacePage.tsx:15`; sole consumer `.settings-grid` at `:870`.

- **(a)** `.settings-grid{align-items:start;grid-auto-rows:max-content}` — FOLD, load-bearing (fixes grid row-stretching).
- **(b)** `.settings-grid>label{align-self:start;min-height:0}` — FOLD, load-bearing.
- **(c)** `input:not([type=checkbox]):not([type=radio]),select{height:44px;min-height:44px;max-height:44px}` — DROP, redundant; `.course-workspace input{min-height:44px}` (`CourseWorkspace.css:3`) already applies, and `.settings-grid` always nests inside `.course-workspace` (verified).
- **(d)** `textarea{min-height:110px;max-height:220px}` — DROP; `max-height` is 390px-hostile, `min-height` redundant with `.course-workspace textarea{min-height:110px}`.
- **(e)** `fieldset{grid-column:1/-1;max-height:320px;overflow:auto;align-self:start}` — PARTIAL: FOLD `grid-column`/`align-self`; DROP `max-height`/`overflow` as 390px-hostile — the one genuinely unbounded fieldset already has its own purpose-built inner scroll region `.preview-list{max-height:220px;overflow:auto}` (`CourseWorkspace.css:8`, verified to exist).
- **(f)** `fieldset+label{display:flex;align-items:center;gap:.5rem}` plus its 20px input sizing — DROP, dead code: the selector matches only a `<label>` immediately following a `<fieldset>`, which the locked field-order guard forbids and which does not occur in the current render order.
- **(g)** `label:has(input[type=checkbox]){display:flex;align-items:center;gap:.5rem}` and `label:has(input[type=checkbox]) input{width:20px;height:20px;min-height:20px;max-height:20px}` — DROP, with a companion amendment. Rule (f)'s dead-code reasoning does not transfer, because this `:has()` selector is not fieldset-adjacency-gated and does match real DOM at `:879`. `display`, `align-items`, and `gap` are safely covered by the surviving `.checkbox-label{display:flex!important;grid-template-columns:none!important;align-items:center;gap:8px;font-weight:400!important}` (`CourseWorkspace.css:8`) — `gap:.5rem` and `gap:8px` are numerically identical at the app's fixed root font-size, since the `--text-size-multiplier` accessibility feature scales individual `calc()` font-size declarations per `AccessibilityContext.tsx:59`, not root `<html>` font-size, and no `html{font-size:...}` override exists. **However, `width`, `height`, and `max-height` are not covered by the shipped rule and would be lost outright on a bare deletion.** The surviving `.checkbox-label input{width:auto!important;min-height:20px!important}` covers `min-height` but not `width` — worse, `width:auto!important` actively overrides any width, so a native checkbox would fall back to its ~13px intrinsic width, a genuine shrink from 20px to roughly 13px. This is `PLAN_DUCK` finding J-44-02, resolved below: `width`, `height`, and `max-height` are explicitly re-established by the amended `.checkbox-label input` declaration in the same Phase 0 change, not silently dropped.

**Companion amendment, binding, folded into the same Phase 0 CSS change.** Amend `.checkbox-label input` in `CourseWorkspace.css:8` from `{width:auto!important;min-height:20px!important}` to:

```css
.checkbox-label input{width:20px!important;height:20px!important;min-height:20px!important;flex:none}
```

Reasoning: (1) 20px is the app's own already-established checkbox dimension — both rule (g) and the surviving `min-height:20px!important` independently agree on it, so this preserves shipped behavior rather than introducing a new value; (2) an explicit `width:20px!important` supersedes the `width:auto!important` that existed only to defeat a `width:100%` inherited from the generic `.course-workspace input` rule, and achieves that same goal more precisely; (3) `flex:none` is added because `.checkbox-label` is `display:flex!important` and a flex item with a fixed width can still be shrunk by the default `flex-shrink:1` — this is exactly the 390px squeeze class this milestone keeps hitting, and it hardens the control at narrow widths; (4) raw px dimensions are not lint-restricted — `tokenFallbackAuditLint.test.ts` bans undefined `var()`, raw hex, non-zero `border-radius`, and blurred `box-shadow`, none of which this touches; (5) `--hit-target-min` (44px) is deliberately not used here — that token governs full control hit targets (`AccessibilitySettings.css:85-86,105-106`), and a 44px inline checkbox would break the label row; the accessible target is the whole `<label>`, which wraps both the box and its text. This also benefits `NewCoursePage.tsx`, which newly adopts `.checkbox-label` for its three radio inputs under this plan — the 20px square applies correctly to radios too.

Net: after folding (a)/(b)/(e-partial) and dropping (c)/(d)/(f)/(g), the file is empty. Delete it and remove `import './CourseSettingsFix.css'` at `CourseWorkspacePage.tsx:15` in the same change. Zero new tokens required. The (g) companion amendment above is a required, binding part of the same Phase 0 change — the deletion is only safe with it applied.

Engineering-ready replacement block for `CourseWorkspace.css`:

```css
.settings-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:var(--space-4);align-items:start;grid-auto-rows:max-content}
.settings-grid>label{align-self:start;min-height:0}
.settings-grid fieldset{grid-column:1/-1;align-self:start}
```

### 390px reflow spec (authored; no reference artboard)

Breakpoint `@media (max-width:700px)` throughout, matching the established convention (`CourseWorkspace.css` already has four separate 700px blocks at lines 1, 2, 3, 6).

**Recurring-defect-class audit**, each explicitly closed:

1. Unwrapped flex rows — most panels already wrap; `.owner-settings-color-preview` (`OwnerSettingsPage.css:74-81`) had no `min-width:0` — add it. This also benefits `BrandDesignPage.tsx`'s two live `ColorPreview` instances.
2. Missing `min-width:0` — `.workspace-panel{min-width:0;overflow:hidden}` (`CourseWorkspace.css:3`) already covers every panel in scope.
3. Grid-on-tabular-data — confirmed not reintroduced. The bucket grid holds independent MetricPlate cards; `.roster-lesson-row{grid-template-columns:1fr auto}` is a 2-column label+control row, preserved unchanged, never converted to a table, matching the `FeedbackLedgerRow` precedent (real `<table>`, `table-layout:fixed`, adopted because CSS-grid-on-list caused a real column-overlap bug).
4. Fixed px widths — isolated entirely to `CourseSettingsFix.css`, resolved by deletion.
5. `white-space:nowrap` outside the sanctioned tab strip — one real violation: `.studio-actions button,.asset-card button{width:100%;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}` inside `CourseWorkspace.css:6`'s 700px block was truncating labels like "Grammar check (EN)" at 390px. Fix: `.studio-actions button,.asset-card button{width:100%}` — drop nowrap/overflow/ellipsis and let labels wrap within the existing ≥44px min-height.
6. Long unbroken strings — `CourseWorkspace.css` already handles this; `OwnerSettingsPage.css` did not.

New `OwnerSettingsPage.css` block, closing its self-disclosed zero-`@media` gap (lines 51-52, 197-198), serving all three consumer pages:

```css
@media (max-width: 700px) {
  .owner-settings-color-preview { min-width: 0; }
  .owner-settings-page, .owner-settings-error, .owner-settings-success { overflow-wrap: anywhere; }
}
```

Verified in review: none of these four selectors collides on any property with any `.owner-settings-page--brand`-scoped rule at `OwnerSettingsPage.css:137-331` (#43's block), and where a brand-scoped compound selector exists it already carries higher specificity regardless of append order. The #43 block is undisturbed.

`padding-inline:var(--space-2)` is verified not needed: `.app-main`'s base padding is `var(--space-6)` (`App.css:456`), dropping to `var(--space-4)` at ≤640px (`App.css:649-651`) — never zero across that boundary, already subsuming 390px. Review specifically confirmed no dead gutter band exists between 641px and 700px.

**Required post-migration specificity fix:** `.roster-student-toggle.control{display:block;width:100%;text-align:left}` — a compound selector, because `.roster-student-toggle` (`CourseWorkspace.css:51`) and `.control--quiet-outline` (`Control.css:118`) are equal single-class specificity. Review confirmed this is necessary and sufficient.

### Contrast (WCAG 2.2 AA, all PASS; four independently recomputed in review)

ink.900 `#2a2420`/paper.50 `#fdfcf9` 14.92:1; ink.900/paper.100 `#faf8f4` 14.43:1; Control primary paper.50/ink.1000 `#1a1512` 17.65:1; secondary ink.1000/paper.100 17.07:1; caution-reversible ink.1000/amber.200 `#ffd699` 13.22:1; **caution-irreversible paper.50 `#fdfcf9`/terracotta.600 `#a85e4a`** (`.control--caution-irreversible{background:var(--color-terracotta-600);color:var(--color-paper-50)}`, `Control.css:83-86`) **= 4.690:1, PASS AA** — not large text (`Control`'s label is `--font-size-button-label` [.875rem/14px] at `--font-weight-label` [700], below the 18.66px-bold large-text threshold, so the 4.5:1 floor applies and is met with a thin margin; treat as a hard floor, do not lighten terracotta.600 or darken paper.50); quiet/quiet-outline brass.700 `#7c6136`/paper.100 **5.460:1** (reviewer-recomputed; APCA 74.85 marginal, non-blocking, pre-existing) and brass.700/paper.50 **5.645:1** (reviewer-recomputed); quiet-outline hover wash brass.700/~`#fcecd4` 5.00:1 (transient); `:disabled` ink.700 `#504940`/paper.200 `#f0ebe2` 7.47:1; Field label ink.1000/paper.50 ~17:1; **Field error terracotta.600 `#a85e4a`/paper.50 = 4.690:1** and **terracotta.600/paper.100 = 4.536:1** (both reviewer-recomputed, PASS-marginal, pre-existing — treat as a hard floor, do not darken the paper or lighten the terracotta); MetricPlate default label brass.700/paper.50 5.645:1, value ink.1000/paper.50 17.65:1; dark label amber.200/ink.1000 13.22:1, value paper.50/ink.1000 17.65:1; attention terracotta.600/paper.50 4.690:1; `schedule-severity-error` ink.800/paper.200 10.10:1; `schedule-severity-advisory` ink.800/paper.100 11.31:1; `.owner-settings-color-preview` text ink.700/paper.50 8.64:1 (the swatch fill is runtime contrast-clamped via `colorClamp`, out of static-token scope); `.field-hint`/roster hint ink.700/paper.100 8.36:1.

No `--color-band-*` pairing appears on any of these pages. Corrected full consumer list: `PublicCatalogPage.tsx`, `PublicCatalogPage.css`, `OwnerLedgerRow.css`, `RoadmapPage.css`, `BandRoadmap.css:149,152,155`.

## Design review

`DESIGN_REVIEW_RESULT` verdict **PASS** on the revised packet, after one evidence-backed `NEEDS_REVISION` cycle with five findings, all resolved.

- **F1 (HIGH, genuinely material).** The original handoff targeted `OwnerSettingsPage.tsx` — unrouted dead code — while entirely omitting `BrandDesignPage.tsx`, the live page that imports the same stylesheet and carries the identical field-error pattern. Without this catch, the browser-validation brief would have been unexecutable (`/admin/owner-settings` does not resolve) and the actually-affected live page would have received zero verification.
- **F2 (MEDIUM).** The `CourseSettingsFix.css` inventory undercounted by three rules, missing the `:has()` block entirely. The re-review then further corrected the director's own `!important`-dominance justification as imprecise, producing the earned per-property reasoning recorded above.
- **F3 (MEDIUM).** The bulk-fill `Field` migration left the `aria-label` handling ambiguous — an engineer dropping it as redundant would have broken a locked test.
- **F4/F5 (LOW).** An incomplete `--color-band-*` consumer grep, and a token-provenance misattribution.

Review also independently verified and confirmed correct: all cited token values; the field-order guard cannot be newly tripped; `.settings-grid` nests inside `.course-workspace`; `.preview-list`'s inner scroll region exists; the three `Field` exclusions; the MetricPlate query preservation; every `Modal.tsx` citation; both `NewCoursePage.tsx` bugs; the compound-selector fix; and that no dead gutter band exists between 641-700px.

One non-blocking residual: the review noted the handoff's "imports exactly seven admin pages" phrasing undercounts by one (`AdminShell.tsx:5-12` imports eight); the conclusion is unaffected.

## Judge route

`PLAN_DUCK` was run given this plan's size and blast radius. It returned two evidence-backed findings: (1) the three Control-tier assignments left as product-policy holds were answerable from the code using the shipped reversibility convention; (2) the `CourseSettingsFix.css` rule (g) deletion justification addressed checkbox height but not width (J-44-02). Both are resolved as binding Planner decisions — see "Per-section composition spec" and "`CourseSettingsFix.css` verdict" — grounded in fresh reads of `Control.css:66,82-86`, `CourseWorkspacePage.tsx:137,892,894-906,918`, and `CourseWorkspace.css:8`. No `CODE_REVIEW`/`VERIFICATION_CHALLENGE`/`VISUAL_REVIEW` trigger is mandatory: the change is CSS/markup-dominant with very strong deterministic gates (roughly 35 locked test files, a build-breaking CSS lint, plus browser validation at two viewports). Deterministic failures always dominate any judge finding. Standard call caps and shadow policy from `docs/JUDGE-CONTRACT.md` apply.

## Ordered work

Owner: T1 engineer, standard mode; escalate to T2 on two counted gate failures.

1. **Baseline first, before any edit (blocking; no planning-stage agent could run this).** Run `npx vitest run` scoped to at minimum every `src/__tests__/issue5-phase*.test.*`, `courseAuthoringUi.test.tsx`, `Issue4SettingsPages.test.tsx`, `OwnerSettingsPage.test.tsx`, `cohortMembersAndInvite.test.tsx`, `cohortInviteEnrollmentUi.test.tsx`, `publishJobHydration.test.tsx`, `tokenFallbackAuditLint.test.ts`, `fieldJournalTokens.test.ts`, `issue36Tokens.test.ts`. Record verbatim pass/fail counts. `fieldJournalTokens.test.ts`'s mechanism-2 partial RED is known and pre-existing — record it, do not fix it, do not let it block. If anything else is already red, return `JOB_BLOCKED` rather than redesigning over a broken baseline. **This baseline is a hard gate re-run after every phase, not just at the end** — "existing course-authoring tests stay green" is an explicit issue criterion.
2. **Read in full** `cohortMembersAndInvite.test.tsx`, `cohortInviteEnrollmentUi.test.tsx`, and `publishJobHydration.test.tsx` — these were only grep-sampled during planning and their byte-exact strings are not in this plan.
3. **Proactive overflow audit before implementation.** Statically audit all eight files (seven plus `BrandDesignPage.tsx`) for the recurring defect class. Confirm and close the two known-in-advance findings: the `.studio-actions`/`.asset-card` nowrap-ellipsis truncation and the missing `min-width:0` on `.owner-settings-color-preview`. Record findings as evidence.
4. **Phase 0 — CSS foundation.** Fold/delete `CourseSettingsFix.css` per the rule-by-rule verdict; apply the replacement `.settings-grid` block; remove the import at `:15`. Doing this first stabilizes DOM/CSS ground truth before any component migration touches `.settings-grid`. Re-run the baseline.
5. **Phase 1 — Control tier swap page-wide.** Mechanical, high volume, low per-item risk. Covers every button including Remove lesson (`caution-reversible`), Apply migration (`caution-reversible`), and Finalize publish (`caution-irreversible`) — all three tiers are binding Planner decisions resolved by the reversibility convention in `Control.css:66,82`, not held for product policy. Pass every Outline row-action button's index-interpolated `aria-label` through verbatim. Exclude the Revoke confirm button (`:478`) entirely — that exclusion is unrelated and unchanged. Re-run the baseline.
6. **Phase 2 — quiet-outline toggles.** `StudentRoster` (`:382`) and `CohortRow` (`:646`) together, sharing the same documented pattern and the same `.roster-student-toggle.control` specificity fix. Preserve every `aria-expanded`/`aria-controls`/`role="region"` wiring. Re-run the baseline.
7. **Phase 3 — Field migration (highest risk).** TDD-first: write failing tests before production edits. Every target needs a newly assigned id. Pass the bulk-fill `aria-label`s through verbatim. Two fields are permanently excluded, not deferred (Outline unlock-offset, CompletionThresholdField), as are `PrerequisiteField` and all three owner/business/brand field patterns. Preserve `.settings-grid`'s relative child order exactly. Re-run the baseline.
8. **Phase 3b — ReconciliationPanel MetricPlate composition.** Verify every locked `getByText`/`getAllByText` bucket query still resolves, including the two 2+-match ones. Re-run the baseline.
9. **Phase 4 — reflow CSS last**, so DOM shape is stable before 390px verification: the nowrap fix, the new `OwnerSettingsPage.css` media block, and the `min-width:0`. Then Group B small-page work: `CourseSettingsPage` owner-branch buttons, `NewCoursePage`'s button plus its two structural fixes (the missing CSS import and the `.checkbox-label` application).
10. **Re-run the full suite plus lint plus type-check plus build.** Every previously green test must remain green.
11. **Deterministic no-native-dialog source scan** across all eight files.
12. **Independent Verifier pass** (read-only), re-running grounded checks and auditing the diff against approved scope.
13. **Browser Validator pass** at both 1440x900 and 390x844.
14. **Open the three follow-up issues** for the disclosed genuine gaps (rich-text-editor primitive, asset-card primitive, labeled-access-control-row primitive), referencing this plan. Per the issue's own hard constraint, raising these is the correct outcome, not a shortfall.

## Interfaces and data

No API, schema, migration, or data-contract change. `updateCourse`, `setLessonAccessState`, `applyReconciliation`, `approveEnrollmentRequest`, `listOwnerCourseVersions`, `saveOwnerSettings`, and every publish/asset service call are unchanged. New CSS classes and newly assigned field ids are the only additive interfaces. One file deletion (`CourseSettingsFix.css`) and one import removal.

## Acceptance and validation

- Every page composed only from existing A/B/C primitives. Zero new components, zero new variants, zero new props, zero new tokens.
- Genuine gaps raised as follow-up issues, never invented — the issue's explicit criterion.
- `CourseSettingsFix.css` deleted; no `*Fix.css` file survives.
- All five pages plus `BrandDesignPage` reflow cleanly at 390 with no horizontal body scroll. The `.workspace-tabs` strip's own contained `overflow-x:auto` is sanctioned and must not leak to the body.
- No native browser dialogs anywhere in the course-authoring flows; deterministic source scan passes.
- Every existing course-authoring test stays green, no assertion weakened or deleted.
- `tokenFallbackAuditLint.test.ts` and `issue36Tokens.test.ts` stay green: zero raw hex outside `src/tokens/`, zero undefined `var()`, zero non-zero `border-radius`, zero blurred `box-shadow`.
- Type-check, lint, and production build clean.
- Judged against the primitives, not a screenshot — no reference artboard exists for any of these five pages.
- Independent Verifier pass, then Browser Validator pass at both viewports. T1 cannot self-approve.

## Binding engineering invariants

- `Field.tsx:87`'s error `<div>` has no `role` — never migrate a field with a currently-tested `role="alert"` error.
- `Control` never emits a bare `.caution` class — the Revoke confirm button (`:478`) stays fully native.
- `MetricPlate` has no slot for the `describe()` sentence — render it as a plain sibling `<p>`, never inside the primitive.
- The bulk-fill inputs' `aria-label`s are passed through verbatim.
- Every Outline row-action button's `aria-label` — including the index interpolation (`Move lesson ${index+1} up`, `Move lesson ${index+1} down`, `Duplicate lesson ${index+1}`, `Remove lesson ${index+1}`) — must be passed through the `Control` migration verbatim; these are the buttons' accessible names and dropping them as redundant would break name-based queries. The same rule already stated for the bulk-fill inputs applies here.
- Inside `.settings-grid`, a `<label>` must never immediately follow a `<fieldset>` as a DOM sibling.
- Every locked string, role, element type, class name, ARIA attribute, ordering, and count enumerated in "Locked test invariants" stays byte-identical.
- No native browser dialog may be introduced; all confirmations route through `Modal.tsx` with its documented focus-trap / Escape / backdrop / focus-restore contract.
- `CourseSettingsFix.css` must be fully deleted, not partially retained, with its import removed in the same change.
- The new `OwnerSettingsPage.css` media block must not alter the `.owner-settings-page--brand` block (`:137-331`).
- `.roster-student-toggle.control` must be written as a compound selector.
- Held advisories always render before revoked advisories.
- `CourseSettingsPage`'s non-owner branch keeps zero `form`/`button`/`link` roles.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | High | The step-1 baseline was never executed by any planning-stage agent (Researcher's Bash allowlist blocks `npx`/`vitest`); ~35 relevant test files' true state is unknown | Baseline capture is the mandatory, blocking first step and a hard gate re-run after every phase; a red baseline returns `JOB_BLOCKED` |
| R2 | High | `CourseWorkspacePage.tsx` is the largest, most-repeatedly-expanded file in the app (919 lines, ~14 internal components) and has grown enormous scope in every prior engagement | Five dependency-ordered internal phases with a baseline gate between each; the two highest-risk boundaries (StudentRoster at Phase 2/3, `.settings-grid` at Phase 0/3) named explicitly |
| R3 | High | Silently breaking a locked test by renaming a string, changing a role, reordering DOM, or dropping an `aria-label` | The full locked-invariants enumeration above, TDD-first in Phase 3, the per-phase baseline gate; rollback is a straight revert |
| R4 | High | 390px horizontal overflow, this milestone's dominant recurring defect (#37/#39/#41/#42/#43), with `OwnerSettingsPage.css` having zero media queries at all | Mandatory pre-implementation static audit (step 3), the two known-in-advance fixes, the new media block, and a measured 390 check in every browser journey |
| R5 | Medium | Deleting `CourseSettingsFix.css` causes a layout regression with zero test coverage — no test references `.settings-grid` or the file by name | The earned rule-by-rule verdict with per-property justification; a visual 390 and 1440 check of the Settings tab is a required browser journey |
| R6 | Medium | Pressure to invent a primitive for one of the three genuine gaps rather than raise a follow-up issue | The hard constraint is a binding non-goal; foundation-only interim treatments are specified; step 14 makes raising the follow-ups an explicit deliverable |
| R7 | Medium | `BrandDesignPage.tsx` (shipped by #43) regressing because the new media block lands in a stylesheet it imports | It is added to scope as an explicit non-regression check with its own browser journey at both viewports; review verified no selector/property collision with the `--brand` block |
| R8 | Low | Build-breaking CSS lint failure on a raw hex, undefined token, or non-zero radius | Zero new tokens are required; run the lint in step 10 |
| R9 | Low | Contrast regression at the terracotta.600 floor (4.690:1 on paper.50, 4.536:1 on paper.100) | Treat as a hard floor; do not darken the paper or lighten the terracotta |
| R10 | Medium | Three newly assigned caution tiers change the visual weight of destructive controls that previously rendered as plain `demo-button`s | Tiers are assigned strictly by verified reversibility, reuse shipped `Control` tiers with no new variant, and every one is exercised in browser journey 3 at both viewports; the terracotta-on-paper pairing sits at the 4.690:1 hard floor |

**Rollback.** Every change is presentation-layer — markup, CSS, and one file deletion — with no data, schema, or backend change. Independently revertible by reverting the commit. The phase structure means a single phase can be reverted without unwinding the others.

## Assumptions and decisions

**Binding Planner decisions:**

- `OwnerSettingsPage.tsx` remains in scope per the issue body despite being unrouted; its validation is component-level only, never a URL journey.
- `BrandDesignPage.tsx` is added to scope as a required non-regression consumer, not a redesign target, because it imports the stylesheet this issue edits.
- The three genuine gaps (rich-text editor, asset card, labeled access-control row) are foundation-only interim treatments plus disclosed follow-up issues, never invented primitives — the issue's own hard constraint.
- `CourseSettingsFix.css` is deleted in full, per the rule-by-rule verdict, in the same change as its import removal.
- Breakpoint `700px`, matching the existing `CourseWorkspace.css` convention.
- **Control tier for "Remove lesson" (`:137`) → `caution-reversible`.** Resolved by a `PLAN_DUCK` cycle, not held for product policy. The handler mutates only local unsaved React draft state (`onDirty(); setBlocks(items => items.filter(item => item.id !== block.id))`) and marks the form dirty; nothing is persisted until the separate "Save draft" action, so the change is reversible by simply not saving, while it destroys authored content — the amber "reversible caution" semantic `Control.css:66` documents ("Caution-reversible (amber) — e.g. Disable"). Not `secondary` (genuinely destructive of work in progress); not `caution-irreversible` (nothing is permanently lost).
- **Control tier for "Apply migration" (`:892`) → `caution-reversible`.** `applyMigration(enrollment, target)` writes server-side, reassigning a real enrolled student to a different course version — consequential but reversible, since the same control can migrate that enrollment to another version and the version select remains populated with every available version. Amber, never `primary`.
- **Control tier for "Finalize publish" (`:918`) → `caution-irreversible`.** `finalizePublish(job.id)` sets "Version published." The file's own issue #46 comment block (`:894-906`) documents the one-way nature of this transition: once a version moves past `draft`, the edge function rejects further asset registration ("Assets can only be registered on draft versions."), and a succeeded job is deliberately excluded from resumption because it has nothing left to finalize or retry. Publishing a version to students cannot be undone in place; recovery means authoring a new version — the milestone's clearest irreversible action and the correct home for the terracotta tier (`Control.css:82`, "Caution-irreversible (terracotta) — e.g. Delete"). It still fires with no confirmation Modal, and adding one remains a deliberate non-goal (see "Open, non-blocking items" below).
- **`CourseSettingsFix.css` rule (g) deletion requires the companion `.checkbox-label input` amendment** specified in the "`CourseSettingsFix.css` verdict" section. The surviving shipped rule covers `min-height` but not `width`, and its `width:auto!important` would otherwise shrink the checkbox from 20px to roughly 13px. Resolved by the same `PLAN_DUCK` cycle (finding J-44-02).

**Open, non-blocking items recorded for the implementer (each has a stated default; none gates the work):**

1. Whether "Finalize publish" should also gain a confirmation Modal, matching Reconciliation's Modal-gated Apply for a comparably consequential transition. Adding one is a behavior change. Default: do not add; raise separately.
2. Visual unification of the owner-settings field/save patterns with `Control`/`Field` across all three consumers. Default: preserve as-is; requires explicit product approval and would need `Field` to gain a component-level `role="alert"` first.
3. Whether `OwnerSettingsPage.tsx` should be routed, retired, or kept as an intentional unrouted fixture. Default: leave as-is; out of this issue's authority.
4. The non-blocking hygiene token substitutions (Tiptap toolbar and asset-card padding/border/min-height literals → existing tokens; `.field-hint` font-size → `--typography-fontSize-sm`). Default: optional, zero visual change either way, may be deferred.

**Safe assumptions applied:** composition-only assembly from shipped primitives, preserve existing-system mode, standard design route with prototype forbidden; the plan's static findings are provisional until ordered-work step 1 confirms them.

## Required approvals

This plan document's engineering-dispatch approval is recorded in "Approval basis" at the top of this document, under the orchestrator's application of the recorded standing authorization. That record, not this section, is the operative approval statement. If the standing authorization is later withdrawn or found not to cover this issue, this plan reverts to requiring explicit per-document user approval before further T1/T2 work proceeds.

## Browser UI dialog policy

Required — browser-rendered React/Vite UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited absolutely across all eight files. The codebase is currently clean (zero grep matches in `src/pages/`) and must stay clean. All acknowledgement and confirmation uses the app-owned `src/components/Modal.tsx`. Two existing tests actively assert this (`issue5-phase3-reconciliation-panel.test.tsx` on `window.confirm`; `cohortInviteEnrollmentUi.test.tsx` on all four). A deterministic source scan is a required acceptance check. Modal keyboard/focus behavior must be verified: on open the dialog container receives programmatic focus (`Modal.tsx:58`); Tab/Shift+Tab cycles only the dialog's own focusable descendants, wrapping first-to-last (`:77-114`); Escape and backdrop-click both close (none of the four usages sets `suppressDismiss`); on close focus restores to the triggering control (`:55,118-129`); the heading id drives `aria-labelledby` (`:154,161`); the Revoke modal's `ariaDescribedBy="revoke-warning"` matches its `<p id="revoke-warning">` (`CourseWorkspacePage.tsx:452,454`).

## Browser UI validation

**Launch/readiness:** `npm run dev -- --port 5827` in `H:\CommandCenter\orchestrator\lizbeth_spanish`. Port 5827 is deliberately non-standard, avoiding 4319, 5199, 5211, 5299, 5317, 5321, 5331, 5407, 5443, 5471, 5613, and 5741 used earlier in this session, the 5173 Vite default, and the 4173 `preview:prod` port. Note the `predev` hook (`npx tsx scripts/ensure-lesson-assets-bucket.ts`) runs first. Readiness = the Vite ready line plus a successful load of the base URL.

**Base URL:** `http://localhost:5827`

**Fixture/reset:** use the existing owner/non-owner fixtures and stubbed service responses from the current suites; reset browser state between journeys. Loading, empty, error, partial-failure, and stale-token states are reached by stubbing the corresponding `services/courseAuthoring` calls. Owner and non-owner states are reached by switching the authenticated session.

**Viewport profiles:** 1440x900 and 390x844. Both are required for every journey. The 390 pass is judged against this plan's authored spec and the A/B/C primitives, not against a mock — none exists.

**Journeys** (each at both viewports, each including an explicit no-horizontal-body-scroll assertion at 390 and a no-native-dialog check):

1. `/admin/course-settings` — owner course-grid; empty state at zero courses; "New course"/"Open workspace" navigate; non-owner shows only the heading plus one `role="alert"` permission paragraph with zero buttons, links, and textboxes; at 390 the grid collapses with no body scrollbar.
2. `/admin/courses/new` — styling loads correctly on a direct/refreshed navigation (the regression check for the fixed missing-CSS-import bug); the three enrollment-mode radio labels sit inline with their text, not stacked, after the `.checkbox-label` fix; confirm the computed radio box measures 20x20 with an adequate hit area at both 1440x900 and 390x844 and that it does not shrink inside its flex row — the explicit regression check for the deleted `CourseSettingsFix.css` `:has()` sizing rule and its companion `.checkbox-label input` amendment; submit success navigates to the new course's outline tab; submit failure shows `role="alert"` with the form still populated.
3. `/admin/courses/:id/{outline,content,students,progress,activity,settings,versions,publishing}` — at 1440 all eight tabs render with no overflow. At 390: `.workspace-tabs` scrolls horizontally within itself while the page body never does; `.studio-actions`/`.asset-card` buttons wrap full label text with no ellipsis truncation; `.settings-grid`, `.asset-library ul`, and `.roster-lesson-row` each collapse to one column; the Settings tab's manual-release checkbox measures 20x20 with an adequate hit area at both viewports and does not shrink inside its flex row (same regression check as journey 2); Remove lesson, Apply migration, and Finalize publish render with their assigned `caution-reversible`/`caution-irreversible` tiers, including the terracotta Finalize button's contrast at both viewports. Sub-journeys: Outline add/remove/reorder/duplicate plus bulk-fill (verify the accessible names stay "Bulk fill start offset"/"Bulk fill step" post-migration); Content lesson switch, proofread, asset upload/remove/copy-reference, PDF/PPTX export; ReconciliationPanel preview → Apply via Modal → success/partial/stale states with all six bucket labels visible; StudentRoster expand/collapse, Release via Modal, Revoke via Modal including the evidence block's loading/error/resolved-with-data/resolved-zero states, plus the held-before-revoked advisory ordering; CohortRow expand and invite; Settings save including a cadence switch via ModeSwitchModal; Versions diff/migrate; Publishing stage then finalize.
4a. `/admin/business-settings` — field-level `role="alert"` errors preserved at both viewports; success is `role="status"` `aria-live="polite"`; non-owner shows heading plus alert with zero buttons and textboxes.
4b. `/admin/brand-design` — non-regression check on the #43-shipped page. All three field errors keep `role="alert"`; the two live `ColorPreview` swatch/text rows do not overflow at 390 after the `min-width:0` fix; the `.owner-settings-page--brand` visual treatment is undisturbed at both viewports; success is `role="status"` `aria-live="polite"`; non-owner shows heading plus alert with zero buttons and textboxes.
4c. `OwnerSettingsPage.tsx` — component-level validation only, explicitly not a URL journey, because `/admin/owner-settings` does not resolve in the shipped app. Confirm via isolated/test-level render that its markup and CSS remain internally consistent with the unmigrated `.owner-settings-field`/`.owner-settings-save-button` pattern. Its exported `ColorPreview` is exercised live through journey 4b.
5. No-native-dialog check across all pages at both viewports, especially the four Modal-driven flows.
6. Modal keyboard/focus-trap check on all four usages, including that the Revoke modal's confirm button retains its native `demo-button caution` classes and its `aria-describedby` still equals the warning paragraph's own id.

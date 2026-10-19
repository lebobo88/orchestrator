# Lizbeth Spanish — Issue #5: course settings enforcement and entitlement reconciliation

Status: Revised draft, awaiting explicit user approval (not approved)

Plan ID: `lizbeth-spanish-issue5-release-cadence-enforcement`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet` (after explicit user approval of this plan)

This is a revision of the prior draft of this plan. The "what already exists" assessment below is materially unchanged from that draft. Everything from "Decisions now settled" onward reflects a substantially wider scope, resolved by the user's own decisions on D1-D3 below, plus two independently reviewed design findings that changed what "safe" means for this work. **This revision itself is not approved.** The user resolved the open decisions that shaped its scope; they have not yet approved the resulting plan.

## Read this first: issue #5 is largely already built

GitHub issue #5 asks for a "student and course management portal" covering four things: creating daily and weekly courses and workspaces, managing students, tracking progress and activity, and curating content for everyone. The repository evidence below shows that three of those four asks are substantially implemented today, with dedicated schema, backend actions, UI, and tests already in place. The originally identified gap — the daily/weekly/custom release-cadence controls exist in the UI and database but do nothing — is real and remains in scope. This revision adds three more settings found to have the identical defect pattern (UI and schema exist, no consumer reads them) and a retroactive reconciliation requirement, per the user's resolved decisions below.

## What already exists (evidence-backed assessment)

### Schema and backend

`supabase/migrations/202608280003_issue5_course_authoring.sql` is a migration named for this exact issue. It creates the full authoring/enrollment data model: `courses`, `course_versions`, `lesson_revisions`, `course_version_lessons`, `course_assets`, `cohorts`, `cohort_memberships`, `enrollment_requests`, `enrollment_lesson_entitlements`, `quiz_attempts`, `assessment_answer_keys`, `activity_events`, and `publish_jobs`. Every table has row-level security; grants are service-role-only; and owner-scoped security-definer RPCs cover the full lifecycle: `save_outline`, `create_course_with_version`, `clone_course_version`, `update_course_settings`, `materialize_enrollment_entitlements`, `apply_version_migration`, `stage_publish_job`, `finalize_publish_job`, `approve_enrollment_request`, `request_cohort_enrollment`, `invite_cohort_member`, `submit_quiz_attempt`, `record_activity_event`, `list_migration_enrollments`, and `backfill_legacy_courses`.

`supabase/functions/course-authoring/index.ts` exposes roughly 33 actions that surface that data model end to end: catalog, preview, list/get courses and versions, create/update course, create version, save revision, save outline, map lesson, asset list/upload/register/remove, cohorts, invites, enrollment-request approve/decline, progress, activity, grading, version diff, migration, and stage/finalize/retry publish.

### Frontend

`src/pages/CourseWorkspacePage.tsx` implements eight tabs: outline, content, students, progress, activity, settings, versions, and publishing. This includes cohort creation, enrollment-request approve/decline, version diff with per-enrollment migration, and checksummed PDF/PPTX artifact staging through publish/retry/finalize.

`src/pages/CourseSettingsPage.tsx` literally renders the issue's own language as its subtitle: "Daily and weekly course creation · progress and activity tracking · content curation." `src/__tests__/Issue4SettingsPages.test.tsx:103` asserts that exact copy, confirming the UI was built with issue #5's wording in mind.

### Mapping issue #5's four asks to what exists

| Issue #5 ask | Status | Evidence |
|---|---|---|
| (a) "Create daily and weekly courses and workspaces" | Structure built; four settings governing it are inert | Course/version/lesson schema, New Course flow, full workspace UI all exist. Cadence, manual release, completion threshold, and prerequisite are all present in Settings but none currently changes student-visible behavior. This is the gap this plan fixes. |
| (b) "Managing students" | Built, with one gap this plan adds | `AdminStudentsPage`, student detail and enrollment/access modals, plus cohorts, invites, and enrollment requests inside the workspace. No per-student-per-lesson manual release control exists yet; this plan adds one. |
| (c) "Tracking progress and activity" | Built | `/admin/dashboard` progress table, plus dedicated `progress` and `activity` workspace tabs backed by `activity_events` and the `record_activity_event` RPC. |
| (d) "Curating all content for everyone" | A shared public content surface exists | `courses.visibility` (`private`/`catalog`/`unlisted`), the `course_catalog` and `course_preview_lessons` views (granted to `anon`), `PublicCatalogPage`, and per-lesson `is_preview` selection. This is a per-course visibility model, not a single cross-course shared library. Per resolved decision D1 below, that remains out of scope for this plan. |

### Dedicated tests already exist

`src/__tests__/issue5BackendContract.test.ts` and `src/__tests__/issue5BackendIntegration.test.ts` already cover backend behavior for this issue's data model.

## Decisions now settled

The user resolved the three open decisions from the prior draft. They are recorded here as settled scope, not as open questions.

**D1 — RESOLVED: the release-cadence-enforcement interpretation of issue #5 is correct for now.** No cross-course shared content library is built by this plan. "Curating all content for everyone" continues to be served by the existing per-course `visibility: catalog` plus per-lesson `is_preview` plus the public `PublicCatalogPage`. If the owner later wants a genuine cross-course shared content library, that remains a separate, explicitly scoped build with its own plan.

**D2 — RESOLVED: fold in.** `manual_release`, `completion_threshold`, and `prerequisite_version_id` are the same class of bug as `release_cadence` — a setting with a UI control and a database column but no code that reads it to change student-visible behavior. All four are implemented together in this one plan rather than tracked as separate follow-up work. `completion_threshold` remains an exception within this fold-in: see its own entry below, where the resolution is a visible "not yet enforced" disclosure rather than a consumer, because no enforcement point currently exists to wire it to without inventing new completion semantics this plan does not scope.

**D3 — RESOLVED: retroactive.** Existing enrollments' entitlements are recomputed and reconciled against the newly enforced settings, not left forward-only. This is the decision that introduces the safety-critical work in the next section, because retroactive recomputation against a live table that currently has no permanence guarantee is capable of hiding content a student can already see.

## THE SAFETY ANSWER

**Question:** does retroactive enforcement risk re-locking content a student has already accessed?

**Answer: yes, by default it would, and this plan prevents it by construction.**

The verified hazard:

- `materialize_enrollment_entitlements` (`supabase/migrations/202608280003_issue5_course_authoring.sql:235-248`) upserts with `on conflict (enrollment_id,lesson_revision_id) do update set unlock_at=excluded.unlock_at` (line 247) with no guard of any kind. It moves `unlock_at` in either direction, unconditionally, on every call.
- Every student-read RLS policy gates purely on `unlock_at <= now()` AND `manual_release_state not in ('held','revoked')`, with no permanence clause: `course_versions_student_read` (line 520), `lesson_revisions_student_read` (line 521), `course_version_lessons_student_read` (line 522), `course_assets_student_read` (line 523), and `entitlements_own` (line 527) — all verified directly against the migration source.
- A naive retroactive re-run of the existing function would therefore silently remove lessons a student can currently see, the instant `unlock_at` is recomputed later than the row's live value.
- This collides with a documented product invariant. `src/lib/weekUnlock.ts` states the core model in its own file header (verified, lines 1-8): "Previously unlocked weeks remain permanently accessible." The legacy band path honors this. The new entitlement path, as originally written, does not.
- Compounding factor: the usual "did the student already open this?" signal is unavailable for exactly the affected courses. `student_lesson_progress` is read by `.eq('lesson_id', lessonId)` (`src/services/adminStudentData.ts:181`) against the legacy `public.lessons` table. `save_outline` creates `lesson_revisions` rows through the authoring path with no `legacy_lesson_id` populated for workspace-authored lessons (only the backfill path at migration lines 223-227 populates it, for lessons copied from the legacy table). Workspace-authored lessons therefore have no `student_lesson_progress` rows at all. The only per-entitlement evidence available is `enrollment_lesson_entitlements.completed_at`, `quiz_attempts`, and the current `unlock_at` value itself.

**The guarantee this plan adopts:** reconciliation never moves `unlock_at` later for a row whose current `unlock_at <= now()`. Anything a student can already see stays visible, permanently. Tightening applies only to still-locked lessons.

Implemented as a monotonic forward-only guard:

```sql
unlock_at = case
  when old.unlock_at <= now() then least(old.unlock_at, new_computed)
  else new_computed
end
```

applied only to rows with `manual_release_state = 'automatic'`.

**Independent design review verification (quoted in substance).** The reviewer confirmed three points directly:

1. `least()` can only hold the result at or below the row's current value, so once a row is visible, no apply can push it later.
2. The guard is evaluated against the live on-disk row at `ON CONFLICT DO UPDATE` time rather than against a cached preview snapshot, so it is safe against preview/apply races independently of the stale-preview token described below — the token is a redundant second layer of protection, not the sole one.
3. The `automatic`-only filter means manually held, released, or revoked rows are never touched by bulk reconciliation.

The reviewer separately confirmed that the `released` exemption (the next section) cannot reopen this hazard: setting `unlock_at = now()` at write time is, by construction, never later than "now" at that same instant, so that exemption can only grant or preserve visibility, never remove it.

**Honest bound on the blast radius.** For a student enrolled long enough that everything is already unlocked under today's always-unlocked behavior, retroactive enforcement is a no-op for them. The fix meaningfully affects only lessons that are still locked, or lessons whose computed unlock date moves earlier than before.

**D4 — the one remaining open decision.** If the owner ever wants a harder re-lock that does remove already-granted access, that is a separate, explicit, owner-confirmed action, and it must never happen as a side effect of this work. This plan does not implement it. The user should treat any future request along these lines as its own decision requiring its own plan, not an extension of the reconciliation feature built here.

## Second critical finding: "release early" would have been a silent no-op

No RPC anywhere currently sets `manual_release_state` away from `'automatic'`. The only occurrences of that column in the repository are the column definition (migration line 191), the RLS policies (lines 520-527), and the quiz-lock check (line 496) — verified by direct grep and read of the migration file. Critically, every student-read policy requires **both** `unlock_at <= now()` **and** `manual_release_state not in ('held','revoked')`; none of them special-cases `'released'` to bypass the `unlock_at` check. Releasing a lesson whose `unlock_at` is still in the future would therefore succeed as a database write for the owner and change nothing for the student — a silent no-op exactly of the kind this whole plan exists to eliminate.

**Resolution adopted.** The manual-release setter, when transitioning a row to `'released'`, must set `unlock_at = now()` in the same mutation. This write is explicitly exempt from the monotonic guard, because it is a single-row, owner-confirmed action rather than a bulk recompute, and the guard's purpose is to protect against unintended bulk tightening, not to block an owner's deliberate one-row release.

**Alternative considered and rejected.** Amending RLS so `'released'` bypasses `unlock_at` entirely was considered. It was rejected because it would widen the security-policy reasoning surface across five tables (`course_versions`, `lesson_revisions`, `course_version_lessons`, `course_assets`, `enrollment_lesson_entitlements`) for what is a one-column edge case. Setting `unlock_at = now()` achieves the identical visible effect through the RLS shape that already exists and is already reviewed, touches zero policies, and preserves what `unlock_at` has always meant in this schema.

## Confirmed fact that closes a prior uncertainty

`update_course_settings` (migration, function body starting at the `create or replace function public.update_course_settings` statement, verified against source) writes only to `courses`, and conditionally to `course_version_lessons.is_preview` when a preview-lesson selection is supplied. It never touches `enrollment_lesson_entitlements`. Saving settings today is therefore genuinely inert in every case — which is exactly what makes a separate, previewable reconciliation step both possible and necessary: settings changes and entitlement changes are two different actions with two different blast radii, and this plan keeps them that way rather than making a settings save silently rewrite live access.

## The four settings, each with its verified gap

1. **`release_cadence` / `custom_schedule`.** `src/services/courseAuthoring.ts:48` (`saveDraft`) hardcodes `unlock_offset_days: 0` for every lesson regardless of the course's selected cadence. A repository-wide search finds no consumer of `release_cadence` or `custom_schedule` anywhere. `src/services/courseAuthoring.ts:35` (`mapLesson`) already accepts an `unlockOffsetDays` parameter, and `save_outline` already reads `coalesce((item->>'unlock_offset_days')::integer, 0)` per lesson — the downstream plumbing already exists and works. Only the client payload construction is wrong.
2. **`manual_release`.** The Settings checkbox never sets `enrollment_lesson_entitlements.manual_release_state`, which stays `'automatic'` for every row. No owner UI exists anywhere to hold or release a lesson for a specific student. See the second critical finding above.
3. **`completion_threshold`.** Stored by `update_course_settings`, read by nothing. A repository-wide search returns only the settings-save path, the migration column and setter, the Edge-function passthrough, and one contract-test string assertion.
4. **`prerequisite_version_id`.** A raw free-text UUID input in Settings today. Validated for existence on save inside `update_course_settings` (it must point at a version the owner also owns), but never checked or enforced at enrollment time.

## Scope and non-goals

**In scope:**

- Make `release_cadence` and `custom_schedule` real: thread a per-lesson `unlockOffsetDays` value from Outline through `saveDraft` to `save_outline`, with cadence-to-offset derivation exposed as a confirmed recompute action in Settings.
- Make `manual_release` real: a new per-student-per-lesson manual release control in the Students tab, backed by a new setter RPC with the `released` → `unlock_at = now()` behavior described above.
- Disclose `completion_threshold` honestly: a visible, unambiguous statement in Settings that the value is saved but not enforced by any code path today. This plan does not invent new completion semantics to wire it to; doing so is out of scope and would require its own decision about what "completion" means across quiz-graded, view-graded, and manually-graded lessons.
- Enforce `prerequisite_version_id`: replace the raw UUID input with a real course+version picker, and enforce the prerequisite at enrollment time.
- Build the retroactive reconciliation flow: a preview-then-apply pair of actions that recomputes entitlements for an already-published version's existing enrollments, honoring the monotonic forward-only guard and the automatic-only filter.
- Build a new student-facing `/learn` and `/learn/:enrollmentId` surface, because the entitlement model this plan makes load-bearing currently has no reachable student view at all (see the DESIGN_ROUTE section for the verification behind this).
- Tests covering the cadence derivation, the manual-release setter, the reconciliation monotonic guard, the prerequisite enforcement, and the new student surface's lock-state rendering.

**Non-goals (explicitly excluded from this plan):**

- A cross-course shared content library (D1, resolved: not needed for issue #5 as currently understood; a separate build if the owner wants one later).
- A harder re-lock that removes already-granted student access (D4, the one remaining open decision: explicit and separate if ever requested).
- Inventing new completion semantics to give `completion_threshold` a consumer. This plan discloses its current inertness honestly instead.
- Amending RLS policies to special-case `'released'`. The chosen approach (`unlock_at = now()`) achieves the same effect without touching the policy surface.
- Any change to `update_course_settings`'s existing behavior of writing only to `courses` and conditionally to `course_version_lessons.is_preview`. It must continue never touching entitlements directly.
- Reusing or aliasing `materialize_enrollment_entitlements` for reconciliation. See the binding invariants below.

## DESIGN_ROUTE: re-classified from compact to Standard

**Re-classification grounds.** The prior draft classified this as compact (a single inert setting, no new screen). That framing no longer holds: this revision covers four settings rather than one, introduces a safety-critical retroactive reconciliation flow that changes live student access state, adds a new per-student-per-lesson access control, and — independently verified — requires a genuinely new student-facing surface where none currently exists.

**Route taken.** Design Director led. UX Architect and Visual System Designer were engaged for the reconciliation panel, the manual-release control, the prerequisite picker, and the new student surface. Motion Designer and Asset Art Director were not engaged; nothing in this scope introduces motion or new imagery. The independent Design Reviewer returned `NEEDS_REVISION` on the first pass, with two critical findings: the safety invariants (the monotonic guard and the automatic-only filter) existed only as narration and would have been violated by the natural reuse of `materialize_enrollment_entitlements`; and the `'released'` transition would have been a silent no-op as originally conceived. Both were resolved in the single permitted revision. The re-review returned `PASS`, with the safety model explicitly re-verified against source as documented in "The safety answer" above.

### Design summary

**Cadence UI** (carried forward unchanged from the prior compact-route packet, which passed its own review): `saveDraft` reads a real per-lesson `unlockOffsetDays` (default 0). Formulas: self-paced = 0; daily = position − 1; weekly = (position − 1) × 7; custom = explicit per-lesson value. `Outline` gains an additive full-width `.lesson-schedule` row: a read-only indicator for non-custom cadence, and a `type="number" min="0" step="1"` input with `aria-label="Unlock day for lesson N"` for custom cadence. The cadence-change confirmation is an inline, non-modal `<fieldset className="schedule-confirm">`, because it mutates only reversible client draft state, not a committed backend record. Invalid offsets get per-row `aria-invalid` plus a visible, `aria-describedby`-associated error, plus an aggregated `role="alert"`; "Save draft" is disabled while any row is invalid. The Custom JSON textarea is removed entirely. `Outline` must receive `course.release_cadence` as a prop — `CourseWorkspacePage.tsx:26` currently calls `<Outline blocks={blocks} update={update} setBlocks={setBlocks} onDirty={...} />` against the `function Outline({ blocks, update, setBlocks, onDirty })` signature at line 31, and without the cadence value the read-only-vs-editable split described above cannot be implemented. `Settings` must additionally receive `setBlocks` and `onDirty` so it can write recomputed offsets back into shared `blocks` state.

**New `.reconciliation-panel`** in the Settings tab: an explicit preview-then-apply flow. Six neutral, zero-color-valence count buckets: `unlocking_now`, `still_locked_earlier`, `still_locked_later`, `newly_eligible_locked`, `excluded_manual_override`, `already_visible_unaffected`. A capped "first 10 affected students" disclosure. An apply confirmation using the existing `Modal` component with `suppressDismiss`. Required states: not-yet-published, idle, loading, error, stale-preview-rejected, empty-populated, populated, apply-idle-disabled, apply-in-flight, apply-success, apply-partial-failure, apply-total-failure. The panel's standing copy states plainly: "This will never hide a lesson a student can already see."

**New per-student-per-lesson manual release control** in the Students tab (`.student-roster-list` / `.lesson-access-row`), with states `automatic`, `released`, `held`, `revoked`, behind a dismissible `Modal`. Confirm button uses `.demo-button.caution` for any visibility-reducing transition (to `held` or `revoked`) and `.primary` for additive transitions (to `automatic` or `released`).

**A real prerequisite course+version picker**, replacing the raw UUID input, including an explicit unresolvable-saved-value state for a stored ID that no longer resolves to a real version.

**A static `.field-hint`** under the completion-threshold input, stating plainly that the percentage is saved but not yet enforced anywhere in the product.

**A new student-facing `/learn` and `/learn/:enrollmentId` surface**, with `.lesson-card` states `date-locked`, `instructor-held`, `prerequisite-incomplete`, `unlocked`, `completed`. Justification, independently verified: a repository grep of `src/` for `enrollment_lesson_entitlements|lesson_revisions|course_version_lessons` returns only `courseAuthoring.ts` and its tests; `App.tsx` confirms students are still routed to `RoadmapPage`/`WeekDetailPage`, which read the legacy tables, not the new entitlement model; and `useRoute.ts` has no existing `/learn` collision. The entitlement RLS added by the issue-5 migration is live in the database today and unreachable by any enrolled student through any existing page. This is sized as its own workstream: two new route matchers, a new `App.tsx` dispatch branch, a nav link, two page components with their own `.learn-page` CSS scope, and the five-state `.lesson-card`.

**Lock-cause differentiation.** The three locked states (`date-locked`, `instructor-held`, `prerequisite-incomplete`) must be distinguishable by text, not color. They deliberately share one hue (the `roadmap.locked` semantic token), with the label as the sole differentiator, matching this project's own documented token convention: "Always paired with icon + visible text, never the sole state signal." The owner-facing four-value badge (`automatic`/`released`/`held`/`revoked`) uses three state hues plus one neutral.

**Grandfathered lessons.** A lesson whose `unlock_at` was moved earlier (or held constant) by reconciliation, and which is therefore now visible to a student who could not previously see it under the old computed schedule, renders with markup, classes, and copy identical to any ordinary unlocked lesson. There is deliberately no "grandfathered" visual state, because the server has no field distinguishing "unlocked by schedule" from "unlocked because reconciliation moved it earlier or held it," and inventing one client-side would misrepresent data that does not exist.

**Accessibility.** No native dialogs anywhere in this scope. The existing `Modal` (role="dialog", `aria-modal`, focus trap, Escape respecting `suppressDismiss`, focus restoration on close) is used for both backend-mutating confirmations (reconciliation apply, manual release transitions). Disclosures use the `aria-expanded`/`aria-controls`/`role="region"` pattern already established by `WeekCard`.

**Correction the reviewer forced on the `Modal` usage precedent.** `HardDeleteStudentModal` and `WipeSaveModal` are actually `suppressDismiss={false}` (`src/components/AdminStudentModals.tsx:125` and `:391`, verified directly against source), despite comments elsewhere in the file (lines 8, 11, 353) claiming otherwise. Only `ReissueAccessModal`'s phase-2 reveal (line 651) is truly `suppressDismiss={true}`. Typed-literal confirmation text and dismiss-suppression are independent axes in this codebase, not one ladder; do not assume a destructive action always implies `suppressDismiss={true}`, and do not trust the stale in-file comments over the actual prop values.

**Token correction.** `--color-ink-600` does not exist in this repository. `src/tokens/primitives.json` defines the `ink` scale only at 700 (`#504940`), 800 (`#3d3530`), and 900 (`#2a2420`) — verified directly. Use `--color-ink-700`, which `semantic.json` aliases as `color.roadmap.locked`.

**Known implementation-time fix, flagged non-blocking by the reviewer.** The design packet's original citation of `error-700 #b91c1c` on `error-50 #fff5f5` for the "revoked" badge does not match the repository. `src/tokens/primitives.json` defines the `error` scale only at 50 (`#fef2f2`), 400 (`#f87171`), and 600 (`#dc2626`) — verified directly; there is no `error-700`, and the quoted `error-50` hex does not match the real value (`#fef2f2`, not `#fff5f5`). At implementation time, substitute an existing token (for example `color.error.600`) or add a real `error.700` primitive, and recompute the contrast ratio against the actual `error.50` value before shipping. This is recorded as a required implementation-time correction, not resolved by this plan.

## Binding engineering invariants

1. `update_course_settings` writes only to `courses` and conditionally `course_version_lessons.is_preview`. It must continue never to touch `enrollment_lesson_entitlements`.
2. Reconciliation must be implemented as a **new** function, distinct from and never delegating to or aliasing `materialize_enrollment_entitlements`. It must update only `manual_release_state='automatic'` rows, apply the monotonic forward-only guard exactly as specified above, and be gated by a stale-preview token.
3. The manual-release setter transitioning a row to `'released'` must set `unlock_at = now()` in the same mutation, exempt from the monotonic guard. Do not amend RLS as an alternative implementation.
4. Preview response contract:
   ```
   {
     scope: { course_id, version_id, version_label },
     computed_at,
     preview_token,
     totals: { enrollments_evaluated, entitlements_evaluated },
     changes: {
       unlocking_now, still_locked_earlier, still_locked_later,
       newly_eligible_locked, excluded_manual_override, already_visible_unaffected
     },
     affected_students_sample: [
       { enrollment_id, student_display_name, lesson_title, change_kind }
     ], // capped at ~10
     warnings: []
   }
   ```
5. Apply must present the `preview_token` and reject a stale one. Response contract: `{ applied, failed, failures: [{ enrollment_id, lesson_title, reason }] }`, with either a retry-failed-subset path or a safe idempotent full-rerun path.
6. New write: a per-enrollment/per-lesson `manual_release_state` setter with the `released`/`unlock_at=now()` behavior described above.
7. New read: cross-course version listing for the prerequisite picker. The existing `listVersions(courseId)` is single-course-scoped and insufficient; the picker needs the owner's `course_versions` across all of their courses. `update_course_settings`'s existing validation already permits any of the owner's own courses as a prerequisite source, so this read only needs to expose what validation already allows.
8. New read: an enrollment/lesson-access roster for the Students tab, returning `manual_release_state` and `unlock_at` per student per lesson, with an explicit "no entitlement row yet" value distinct from any of the four manual-release states.
9. New read: an enrollment-scoped lesson roster for `/learn/:enrollmentId` with computed lock classification, including lessons that have no entitlement row at all (the prerequisite-incomplete case). Existing content-gated queries omit rows with no entitlement entirely, which is wrong for this surface — the student needs to see a locked card, not nothing. Only lightweight roster metadata (title, position, lock classification) is newly exposed by this read; gated lesson content itself stays exactly as protected as it is today, behind the existing RLS.
10. `.lesson-card` locked-state styling must never depend on markup that assumes gated content is present in the DOM. A locked card renders with no lesson body content at all.
11. Do not reintroduce `brass-500`/`terracotta-500` as light-surface text or button fills. Both are documented AA failures in this codebase's own inline comments.
12. Do not use `.destructive-warning` for either new `Modal`. That class is reserved for the hard-delete/wipe-save tier of destructive action.
13. Preserve four-hue separation for the owner-facing badge states `automatic`/`released`/`held`/`revoked`.
14. `/learn` gets its own `.learn-page` CSS scope replicating `CourseWorkspace.css:3`'s exact focus-visible rule (3px `--color-terracotta-600` outline, 2px offset), rather than falling back to `App.css`'s unscoped 2px global ring.

**Permitted variation** (engineering discretion, does not require further design review): exact function/RPC naming; whether the new reads are RPCs, views, or extended Edge actions; whether preview and apply are one call or two; whether retry targets a failed subset or safely re-runs in full; optional icon differentiation across the three lock causes beyond the base lock icon, provided the text label remains the mandatory differentiator.

## Ordered work — dependency-aware batching

**Batch A — cadence enforcement.** Foundation; everything else in this plan builds on real per-lesson offsets.

- A1. Reproduce the defect on a clean environment (`npx supabase start`, `npx supabase db reset`, `npm run dev`). Author a course, set Weekly cadence, save, and confirm every `unlock_offset_days` is 0 and all `unlock_at` values are identical. This is the RED evidence.
- A2. Add `unlockOffsetDays?: number` to `CourseBlock`/`AnyBlock` in `src/lib/courseAuthoring.ts`.
- A3. Failing tests first: cadence-to-offset derivation across all four cadences including the position-1 boundary, the `saveDraft` payload shape, and offset validation rejecting negative, non-integer, or blank values.
- A4. Fix `saveDraft` to read `b.unlockOffsetDays ?? 0` instead of hardcoding 0.
- A5. Thread `course.release_cadence` into `Outline`; pass `setBlocks`/`onDirty` into `Settings`.
- A6. Implement the `.lesson-schedule` row and the inline `.schedule-confirm` recompute; remove the Custom JSON textarea; handle the orphaned `schedule`/`setSchedule`/`scheduleError` state.

**Batch B — backend enforcement primitives.** Depends on A. Independently testable at the SQL layer before any UI exists.

- B1. New reconciliation function with the automatic-only filter and the monotonic guard. SQL-level tests proving an already-unlocked row never moves later, across repeated runs.
- B2. Preview/apply endpoints with the token contract from invariants 4-5.
- B3. Manual-release setter with the `released`/`unlock_at=now()` behavior. SQL-level test proving a released, future-dated lesson becomes visible.
- B4. Prerequisite enforcement at enrollment, and the cross-course version listing read.
- B5. The Students-tab roster read and the `/learn` roster read.

**Batch C — owner UI.** Depends on B.

- C1. `.reconciliation-panel` with all twelve states.
- C2. Students-tab manual release control.
- C3. Prerequisite picker.
- C4. Completion-threshold `.field-hint`.

**Batch D — student surface.** Depends on B5. The largest single workstream in this plan.

- D1. Route matchers, `App.tsx` dispatch branch, nav link.
- D2. `/learn` index and `/learn/:enrollmentId`, with the five `.lesson-card` states and the `.learn-page` CSS scope.

**Batch E — validation.**

- E1. Deterministic no-native-dialog source scan across every touched file.
- E2. Full test suite after `npx supabase db reset`.
- E3. Independent Verifier pass.
- E4. Browser Validator pass.

**Ownership.** T1 for Batch A. Batches B through D are substantial enough that a T2 escalation should be anticipated rather than treated as a failure signal in itself — this is stated here explicitly so an escalation is not mistaken for a gate failure. Standard engineering mode; no team authorization required.

**Note on verification, stated prominently because it has mattered before in this engagement.** Unit-test-only completion claims have repeatedly missed real bugs in this repository. Every batch requires live browser verification of its user-visible effect, not just a green test suite. Batch B's SQL-level tests are necessary but explicitly not sufficient on their own — they prove the database behaves correctly; they do not prove any UI correctly reflects or triggers that behavior.

## Acceptance and validation

- Weekly cadence produces `unlock_offset_days` values 0, 7, 14, ... by lesson position. Daily produces 0, 1, 2, ... Self-paced produces all 0. Custom produces exactly the entered values.
- `materialize_enrollment_entitlements` yields correspondingly staggered `unlock_at` values for a **new** enrollment (unchanged legacy behavior for new enrollments).
- Reconciliation, run twice in immediate succession against an already-unlocked lesson, never moves its `unlock_at` later. This is the monotonic-guard proof and must be demonstrated, not merely asserted.
- Reconciliation never modifies a row whose `manual_release_state` is `held`, `released`, or `revoked`.
- A stale `preview_token` is rejected rather than silently applied.
- A lesson set to `released` with a future scheduled `unlock_at` becomes immediately visible to that student.
- A lesson set to `held` becomes invisible to that student.
- A prerequisite-gated lesson is not accessible until its prerequisite is satisfied.
- The three student lock causes render distinct text labels, not merely distinct colors.
- A grandfathered lesson's DOM is identical to an ordinary unlocked lesson's DOM. Diff the DOM directly; do not eyeball it.
- No gated lesson content appears in the DOM or network payload for any locked card.
- Deterministic scan: no `alert(`, `confirm(`, `prompt(`, `window.alert`/`confirm`/`prompt`, or `beforeunload` in any touched file.
- Full test suite passes after `npx supabase db reset`, with no console errors.
- Independent Verifier pass, then Browser Validator pass, both required.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Critical | Retroactive reconciliation silently re-locks content a student already has access to | Monotonic forward-only guard (`least(old, new)` applied only when the row is currently visible), the `automatic`-only filter, and a mandatory preview-before-apply flow. This is the single highest-severity risk in this plan and is the subject of "The safety answer" above. |
| R2 | High | Reconciliation is implemented by reusing or aliasing `materialize_enrollment_entitlements`, silently reintroducing R1 | Named as a prohibited implementation path in a binding invariant (invariant 2), enforced by a dedicated SQL test asserting the two functions are distinct and that the new function never delegates to the old one |
| R3 | Medium | The `released` transition appears to work in the database while changing nothing for the student, as it would have under the original design | Resolved by the mandatory `unlock_at = now()` write in the same mutation, with its own dedicated SQL test |
| R4 | Medium | A stale preview is applied against changed underlying state | Mitigated by the `preview_token` check; the monotonic guard is an independent second layer, evaluated against the live row at conflict time, so it holds even if the token check were ever bypassed or misconfigured |
| R5 | Low | An owner is surprised that a previously cosmetic setting now takes effect on save or on apply | Mitigated by the preview flow and the reconciliation panel's standing "never hide a lesson a student can already see" promise, shown before any apply |
| R6 | Medium | The four-batch scope size invites a premature completion claim before the student-facing surface (Batch D) is actually built and verified | Mitigated by per-batch browser verification and the explicit anticipated-T2-escalation note in "Ordered work" |
| R7 | Low | A stale local database produces confusing or false-failing test results | Mandatory `npx supabase db reset` before every validation pass |
| R8 | Low | The `error-700`/`error-50` token mismatch in the "revoked" badge ships unverified | Recorded as a required implementation-time correction in the design summary above; must be resolved before the badge ships, not deferred silently |

**Rollback.** Batch A is revert-safe with no schema change: reverting it restores the hardcoded `0` and the JSON textarea. Batch B onward adds new functions and new reads; the reconciliation function is additive and is never invoked automatically by any existing code path, so leaving it built but unused is itself a safe rollback state for Batches B-D. Any reconciliation that has actually been applied cannot be blanket-reverted, because by construction it only ever grants or preserves access, never removes it. State that plainly to the user: this asymmetry is a deliberate property of the safety design in this plan, not a gap in it.

## Interfaces and data

- No schema migration is required for Batch A. `course_version_lessons.unlock_offset_days` and `save_outline` already accept the value; only the client's payload construction is wrong.
- Batches B-D require new database functions (reconciliation preview/apply, manual-release setter), new reads (cross-course version listing, Students-tab roster, `/learn` roster), and possibly a schema addition for the stale-preview token, at engineering discretion per the permitted-variation note above.
- Backward compatible throughout: absent or zero offsets reproduce today's behavior exactly for cadence. Legacy band-derived courses are untouched, because `backfill_legacy_courses` supplies real offsets from `lessons` directly and is not touched by this plan.

## Assumptions and decisions

**Safe assumptions:**

- Owner-facing chrome copy stays English-only; bilingual ES/EN applies to course content fields only, not to owner workspace chrome.
- The cadence formulas (self-paced = 0, daily = position − 1, weekly = (position − 1) × 7) are the intended semantics of "daily" and "weekly" course cadence, consistent with the prior draft's design review.

**Resolved decisions:** D1, D2, D3, recorded above under "Decisions now settled."

**Remaining open decision:** D4, recorded above under "The safety answer" — a harder re-lock that removes already-granted access is out of scope and requires its own explicit, separate, owner-confirmed request if ever pursued.

This plan grants no authority by itself. Explicit user approval of this document, recorded against the status header above, is required before any engineering writer begins work.

## Browser UI dialog policy

Required and applicable. This is browser-rendered React UI across multiple surfaces (Outline, Settings, Students tab, and the new `/learn` pages). Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited everywhere in this scope. The cadence-recompute confirmation remains the existing inline, non-modal `<fieldset>` with a `role="status"` message. The reconciliation-apply confirmation and the manual-release transition confirmation both use the existing `Modal` component with `suppressDismiss`, never a native dialog and never `role="alertdialog"`. Validation is inline with `aria-invalid` and a visible, `aria-describedby`-associated error. A deterministic source scan of every touched file confirming no native dialog usage is a required acceptance check for every batch, not only Batch A.

## browser_ui_validation

- **Launch/readiness:** `cd H:\CommandCenter\orchestrator\lizbeth_spanish`; Docker running; `npx supabase start`; `npx supabase db reset`; `npm run dev`; wait for Vite's printed ready URL.
- **Base URL:** the actual printed dev-server URL, expected in the `http://localhost:5173`-`5178` range. Capture it; never hardcode. The design packet assumed 5173; this repository has been observed on 5174, so capture the real value each run.
- **Fixture/reset:** clean `npx supabase db reset`. Owner account `owner@test.local` / `password` (`supabase/seed.sql:78`). Needs a published course version with 2+ active enrollments covering one already-unlocked lesson, one still-locked lesson, and one prerequisite-gated lesson, plus a draft version with unsaved cadence changes.
- **Journeys:**
  1. The cadence journeys: self-paced, daily, weekly, custom, an invalid offset, and a keyboard-only pass through the Outline row and the Settings confirm fieldset.
  2. The full reconciliation preview-to-apply cycle, including a forced partial failure, a forced total failure, and a forced stale-preview rejection. Verify Cancel/close is removed from the DOM during in-flight apply, rather than merely hidden.
  3. Reconciliation run twice against an already-unlocked lesson, confirming its `unlock_at` and visibility do not change between the two runs.
  4. A manual release transition to Held and one to Released on a future-dated lesson, confirming the student-visible effect of each.
  5. The prerequisite picker's unresolvable-saved-value state.
  6. All three student lock causes, confirming correct label text, correct disclosure copy, and no gated content present in the DOM for any of them.
  7. A grandfathered lesson, DOM-diffed against an ordinary unlocked lesson to confirm they are identical.
- **Viewport profiles:** desktop ≥1280px and the existing 700px breakpoint, verifying `.reconciliation-summary` and `.lesson-access-row` collapse to a single column and `.student-roster-row` wraps rather than truncating a long name.
- **Visible outcomes:** zero native dialogs in any flow; focus lands and restores correctly across every `Modal` open/close and every disclosure toggle; every `role="status"`/`role="alert"` actually announces; the four owner badge hues render distinctly and pass automated contrast checks; the three student lock labels render distinct text; and `/learn`'s focus ring renders at 3px terracotta-600 rather than the 2px global fallback.

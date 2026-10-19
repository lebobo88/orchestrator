# Lizbeth Spanish, Issue #5 Phase 4: hard re-lock (revoke access)

Status: **Approved. Approval authorizes Phase 4 only; it does not authorize Phase 5. Revised after a cross-vendor judge review; see "Judge findings and disposition" below. See "Approval record" for the exact basis. Amended on 2026-08-31 for one narrow shared-`Modal.css` overflow-context carve-out, live-verified through Phase 4's own browser validation; see "Other engineering invariants" and acceptance item 17.**

Plan ID: `lizbeth-spanish-issue5-phase4-hard-relock`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`, after explicit user approval of this plan
Roadmap: `docs/plans/lizbeth-spanish-issue5-roadmap.md`
Sibling plans (approved): `docs/plans/lizbeth-spanish-issue5-phase1-entitlement-primitives.md`, `docs/plans/lizbeth-spanish-issue5-phase2-cadence-authoring.md`, `docs/plans/lizbeth-spanish-issue5-phase3-owner-enforcement-controls.md`
Design route for Phase 4: **standard**, a new design pass, not carried forward. The roadmap states explicitly that Phase 4's owner-facing UI was never designed by the earlier packet, which covered only the `held`/`released` states.

## Blocking prerequisites

The roadmap's phase-breakdown section states Phase 4 depends on Phase 1's setter (the `revoked` state and its audit entry), Phase 1's audit trail, and, separately, on Phase 3 having satisfied ship-gate G-ENT-1, "since Phase 4's revoke action shares entitlement-safety semantics with the migration path that gate closes." This section states, per the roadmap's Clause 3, either the gates that constrain this phase or an explicit `none`.

**None. All three dependencies are satisfied, and G-ENT-1 was verified against the working tree rather than trusted from Phase 3's own completion claim.**

- **G-ENT-1 verification.** `apply_version_migration` was rewritten at `supabase/migrations/202608300002_issue5_phase3_enforcement_sql_core.sql:57-116` as a guarded upsert. The unconditional delete-and-reinsert is gone; the one remaining delete (lines 80-86) is a targeted removal of rows whose lesson is absent from the target version, which the gate explicitly permits — it is not the blanket delete the gate prohibits. Rows present in both the source and target version are updated in place (`on conflict ... do update`, lines 100-112), so `manual_release_state`, `completed_at`, and `granted_at` survive by construction rather than by being copied field-by-field. `unlock_at` reuses Phase 1's guard shape verbatim, plus a stronger clause: a row under any explicit manual override keeps its `unlock_at` entirely untouched (lines 104-106). The migration's own comment (lines 20-56) states the intent in words, including the documented change in the function's return-value meaning from "rows inserted" to "rows affected," matching the gate's own requirement that intent be stated in words as well as code.
- **Evidence exists as tests, not prose.** `src/__tests__/issue5-phase3-sql-core.test.ts` carries all five mandatory G-ENT-1 assertions as named tests: G-ENT-1.1 (no later `unlock_at` for an already-visible row, asserted as the student database role) at line 226; G-ENT-1.2 (all three of `released`, `held`, and `revoked` preserved, individually asserted) at lines 243-262; G-ENT-1.3 (`completed_at` and every `quiz_attempts` row survive) at line 265; G-ENT-1.4 (no unguarded blanket delete, with the worded intent) at line 289; G-ENT-1.5 (the migration path and the bulk-reconciliation path remain structurally separate functions) at line 307; plus a supporting assertion at line 320 that rows for lessons absent from the target version are still correctly removed.
- **`revoked` preservation is already asserted at the database level.** G-ENT-1.2 (line 243-262) individually asserts that a `revoked` row's `manual_release_state` survives a migration. Phase 3 recorded this as a deliberate Phase 4 dependency rather than scope creep. That dependency is met.

State this plainly: G-ENT-1 is genuinely satisfied, not merely claimed satisfied, and Phase 4 is unblocked. No other open gate constrains this phase.

## Outcome and audience

Give the course owner the hard re-lock (revoke) control the roadmap's decision D4 put in scope: a deliberate, explicitly-triggered, separately-confirmed, per-student per-lesson action that removes a student's ability to view a lesson without destroying any of their history (completion record or quiz attempts).

Audience is the course owner, working in the authoring workspace's Students tab (the student roster panel Phase 3 built).

Phase 1 shipped the entire backend for this capability, dark. Phase 4 is the UI completion of an already-built, already-RLS-verified capability, plus four small, additive client and read changes. No new SQL setter is written this phase.

## Scope and non-goals

**In scope:**

1. A fourth `Revoked` option on the roster's existing three-state lesson `<select>`, appended last (`automatic, released, held, revoked`), with no relocation of the control.
2. A new Tier B+ confirmation modal for the revoke action, carrying the binding warning copy, an evidence block (completion and quiz-attempt data for the lesson being revoked), and a student-visibility caveat.
3. A persistent resting-state hint on a revoked row, disclosing that the student cannot open the lesson while it is revoked.
4. Updated copy on all four reversal transitions (to Automatic with `unlock_at` in the future or in the past, to Released, to Held) reflecting that time lost while revoked is not restored.
5. A new `revoked_not_completed_count` per-student advisory, parallel to and rendered alongside the existing `held_not_completed_count` advisory, held first then revoked.
6. A `getProgressEvidence` client wrapper for the already-wired `get_progress_evidence` Edge action, used to populate the evidence block.
7. The `.demo-button.caution` CSS relocation from `AdminStudentModals.css` into `App.css`, with three defect fixes (undeclared `--color-warning-*` tokens replaced, hardcoded `color: white` replaced), and a regression test covering every consumer of that class.
8. `setLessonAccessState`'s TypeScript union widened to accept `'revoked'`.
9. `RosterStudent`'s client type widened to carry `revoked_not_completed_count`.
10. **(Added by cross-vendor judge finding J-01.)** An explicit server-side allow-list check in the `set_lesson_access_state` Edge action, rejecting anything outside `automatic`/`released`/`held`/`revoked` with a 422 before the RPC is called. See "Judge findings and disposition" below for why this is defense in depth over an already-correct database check, not a fix for a reachable data-integrity bug.
11. Tests for all of the above, including the RLS-as-student-role assertions, the audit-trail assertion, and the Edge allow-list assertion.

**Out of scope:**

- Any new SQL setter. `set_lesson_access_state` already accepts `'revoked'` (Phase 1) and is used as-is.
- The Phase 3 roster completion column (the "Mark complete" button with its four states). Approved in Phase 3's own design delta but not built; see finding 9 below. Not a Phase 4 dependency. Left as an explicit open decision for the user, not silently folded into this phase and not silently dropped.
- The student `/learn` surface and any student-facing messaging explaining a revoked lesson to the student who encounters it. That ships in Phase 5. This phase's evidence panel and copy are honest about that gap; see the copy under "Design handoff" below.
- A seventh reconciliation-preview bucket. The existing `excluded_manual_override` bucket already counts a revoked row correctly (finding 7 below); no change to the reconciliation panel.
- Reversal to Held gains no new copy; access stays blocked and the ordinary Held message is unchanged.
- No commit, push, PR, or deploy.

## Verified repository findings

All findings below were verified directly against the current working tree, with Phases 1 through 3 merged.

**1. The entire backend already exists and ships dark.** `set_lesson_access_state(p_enrollment_id, p_lesson_revision_id, p_new_state, p_owner_id)` at `supabase/migrations/202608290001_issue5_phase1_entitlements.sql:43-133` accepts `'revoked'` in its validation list (line 59), requires owner authorization through the enrollment's course version (lines 70-76), raises `entitlement not found` for a missing row (lines 83-85), leaves `unlock_at` untouched for `revoked` (lines 95-98), and writes an audit entry through `record_activity_event_with_actor` carrying `old_state`, `new_state`, `old_unlock_at`, and `new_unlock_at` (lines 106-121). The function's own comment at line 587 documents all four states. Phase 4 builds no new setter.

**2. Revocation is genuinely non-destructive, verified.** `set_lesson_access_state`'s `UPDATE` (lines 101-104) touches only `manual_release_state` and `unlock_at`. `completed_at` and every `quiz_attempts` row are untouched. This is what makes the plan's central copy claim, "nothing is deleted," true rather than reassuring language.

**3. RLS genuinely blocks a revoked row, on five policies plus the asset path.** `supabase/migrations/202608280003_issue5_course_authoring.sql` lines 520-527 each carry `manual_release_state not in ('held','revoked')`: `course_versions_student_read`, `lesson_revisions_student_read`, `course_version_lessons_student_read`, `course_assets_student_read`, and `entitlements_own`. Line 496 raises `'lesson is locked'` on the same predicate for the signed-URL/asset path. `record_lesson_completion` also refuses a `held`/`revoked` lesson (`202608300002...sql:391-393,448`), so a revoked lesson cannot be completed either.

**4. A live latent rendering defect this phase closes.** The roster read `list_enrollment_lesson_entitlements` (`202608300002...sql:627-700`) returns the raw `manual_release_state` per lesson (line 677), so a `revoked` row already reaches the client today. But the roster `<select>` at `src/pages/CourseWorkspacePage.tsx:361-369` carries exactly three options, so a revoked row has no matching option and misrenders. This is stated as a defect Phase 4 closes, not merely a feature it adds.

**5. `revoked` is already reachable at the Edge boundary; only the client's TypeScript union gates it.** The Edge action passes `payload.new_state` straight through to the RPC with no whitelist (`supabase/functions/course-authoring/index.ts:430-434`); the SQL does the validation. What prevents an owner from revoking today is `setLessonAccessState`'s narrowed union at `src/services/courseAuthoring.ts:144` (`'automatic' | 'released' | 'held'`) and the three-option select, not any server-side restriction. Phase 4 is therefore a UI completion, and the "no revoke UI ships in Phase 3" guarantee was a client-side convention, not a server-enforced one.

**6. The evidence source for "what the student will lose" exists and is unused.** `get_lesson_progress_evidence(p_enrollment_id, p_lesson_revision_id, p_owner_id)` at `202608290001...sql:508-568` returns `{completed_at, quiz_attempt_count, limitations:{description, reason, consequence}}` with owner authorization. Its own honest limitation, which the plan's copy must not paper over: it cannot distinguish viewed from not-viewed for workspace-authored lessons, because those have no `student_lesson_progress` rows, so it reports completion and quiz attempts, never view history. The Edge action `get_progress_evidence` is wired (`supabase/functions/course-authoring/index.ts:445-449`) and is in the `CourseAction` union (`courseAuthoring.ts:6`), but no client wrapper calls it. Phase 3's ordered-work step 7 said to add one; verified absent.

**7. Reconciliation already excludes revoked by construction.** The `excluded_manual_override` preview bucket counts `manual_release_state in ('held','released','revoked')` (`202608290001...sql:236-240`), and apply only modifies `automatic` rows (documented at line 584). The shipped panel copy at `CourseWorkspacePage.tsx:180,248` already names "hold, release, or revoke." The roadmap's question of whether the reconciliation preview correctly excludes revoked rows is answered yes, already, with no Phase 4 change required. The design deliberately rejected a seventh bucket, because it would break the panel's deliberate zero-colour-valence six-bucket uniformity for no informational gain.

**8. The denominator advisory currently counts held only.** `held_not_completed_count` (`202608300002...sql:664-670`) counts `manual_release_state = 'held'` and `completed_at is null`; the roster renders it as a `.schedule-severity-advisory` at `CourseWorkspacePage.tsx:344`. A revoked-and-not-completed lesson has the same denominator-capping effect and is currently invisible. The design specifies a parallel `revoked_not_completed_count` rather than merging revoked into the held count, because merging would misreport the row's actual state to the owner.

**9. A Phase 3 acceptance gap, found while grounding this plan, recorded rather than absorbed.** Phase 3's approved design delta section C specified a roster completion column, a "Mark complete" button with four states (Completable, Completed, Held-blocked, No-entitlement-row), with its own acceptance items and browser journeys 10 and 12. It is not built. Verified: no "Mark complete", `roster-complete-button`, or `set_lesson_completion` reference exists in `src/pages/CourseWorkspacePage.tsx` or `src/__tests__/issue5-phase3-student-roster.test.tsx`; the SQL RPCs behind it do exist. This is NOT a Phase 4 dependency and does not block this phase; the roadmap's stated Phase 4 dependencies are Phase 1's setter, Phase 1's audit trail, and G-ENT-1, all satisfied (see "Blocking prerequisites" above). But it means Phase 3's completion claim is narrower than its own approved plan, and it is the user's decision whether to remediate it before, alongside, or after Phase 4. Recorded as an explicit open decision below. This phase's design was deliberately specified NOT to depend on that unbuilt control.

**10. Existing confirmation tiers this phase draws from**, all in `src/components/AdminStudentModals.tsx`:

- Tier A, no modal, reversible plus inline `role="status"`: the roster's Held/Automatic transitions; "Re-enable" deliberately has no modal (comment at line 74).
- Tier B, app-owned `Modal` plus a plain confirm: `UnassignModal:236`, `ConfirmEmailModal:507`, the roster's Released modal at `CourseWorkspacePage.tsx:379-387`, and Phase 3's reconciliation-apply modal.
- Tier B+, `Modal` plus `.demo-button.caution`: `DisableStudentModal:48-67`, "blocks sign-in, can be re-enabled later."
- Tier C, dismiss-suppressed `Modal` plus a `.destructive-warning` block with a `⚠` icon plus a typed literal confirmation before Confirm enables: `HardDeleteStudentModal:91-188` types the exact email; `WipeSaveModal:353-450` types `WIPE`. Both Tier C precedents are reserved for actions that genuinely destroy data.

**11. The app-owned modal**, `src/components/Modal.tsx`: an always-active Tab-cycling focus trap, Escape and backdrop close unless `suppressDismiss`, focus restoration to the trigger, `role="dialog"` `aria-modal="true"`, optional `ariaDescribedBy` and `triggerElement`. When `suppressDismiss` is true no ✕ button renders (line 164). Verified to have no portal, which is why the page's existing focus-ring and hover rules reach modal content by DOM descendance.

## Judge findings and disposition

A cross-vendor advisory review was run on this draft after it was first written and returned three findings. This section records each finding and its disposition plainly, per this plan's own established discipline: a correction is stated, never silently absorbed. Deterministic checks and the passed `DESIGN_REVIEW_RESULT` remain authoritative over advisory judge output; where a finding's premise did not hold, that is recorded rather than acted on.

**J-01 — server-side allow-list validation of `new_state`. ACCEPTED as required in-scope acceptance criteria, with a premise correction.**

The judge stated the endpoint accepts `new_state` "completely unvalidated." That is accurate about the Edge layer and inaccurate about the system as a whole. Both halves:

- True: `supabase/functions/course-authoring/index.ts:430-434` checks only that `new_state` is present, then passes it straight to the RPC. There is no allow-list at the Edge boundary.
- Also true, and the correction: the value cannot reach the database unvalidated. `set_lesson_access_state` validates it as its very first action: `if p_new_state not in ('automatic','released','held','revoked') then raise exception 'invalid manual_release_state: %'` at `supabase/migrations/202608290001_issue5_phase1_entitlements.sql:58-61`. An out-of-set value is rejected, so there is no path to writing an invalid `manual_release_state`.

The genuine gap is narrower than "unvalidated" but real and worth closing while this phase is already in this exact code path: it is a missing defense-in-depth layer, and it means a malformed request is surfaced to the client as a raw Postgres exception string rather than a clean 422 from the boundary that should have rejected it. Absorbed into Scope item 10, Ordered work step 2, Acceptance item 6, and Risk row R8 below (see each section for the exact language).

**J-02 — fix the roster's rendering model before exposing the revoke action. ACCEPTED as a required in-scope sequencing constraint.**

This aligns exactly with this plan's own finding 4 above (the roster read already returns raw `manual_release_state`, so a `revoked` row reaches the three-option select today and misrenders). The judge's contribution is to make the ordering binding rather than incidental. The plan's passed design packet already specifies both things the judge requires: the deterministic label (`Revoked`, appended last, control not relocated) and the visible recovery path (the persistent resting hint naming setting it back to Automatic or Released, plus the conditional `aria-describedby`). This finding changes sequencing and acceptance strictness, not the design. Absorbed into Ordered work (steps 4 and 5 below, split from the former single step), Acceptance item 7 (strengthened as the ordering gate), and Risk row R6 below.

**J-03 — confirmation copy calibration. ALREADY SATISFIED; record the correction, change nothing.**

This finding's premise does not match the plan. The judge describes the plan as "reusing the permanent-deletion framing verbatim" and says "the type-to-confirm interaction pattern itself (the mechanism) can still be reused." The plan uses neither. The design deliberately selected Tier B+ (`Modal` + `.demo-button.caution`, the `DisableStudentModal` weight) and explicitly rejected Tier C, the typed-literal confirmation and `.destructive-warning` treatment of `HardDeleteStudentModal` and `WipeSaveModal`, for exactly the reason the judge gives: revoke destroys no data and is reversible as a state, so a typed confirmation would overstate permanence. There is no type-to-confirm interaction in this plan to retain, and adopting one now would invert a decision an independent design review verified against source and upheld; see "Recorded asymmetry, considered and knowingly accepted" under "Design handoff" above, where this exact tier question was already examined on its merits, not settled by convenience.

The three substantive points the judge asks for are already binding verbatim copy: the warning paragraph states that access is blocked right away, that "Nothing is deleted — their completion record and quiz attempts for this lesson stay exactly as they are," and that "You can restore access later by setting this back to Automatic or Released." The plan additionally carries an honest limit the judge did not ask for and which is preserved unchanged: "any time lost while access was revoked isn't restored." Acceptance item 10 already asserts that the copy never implies deletion and never implies permanence.

**Disposition: no change.** The finding's substance is met; its premise about the confirmation mechanism was mistaken. Adopting the suggested type-to-confirm mechanism is specifically rejected because it would contradict the passed `DESIGN_REVIEW_RESULT`.

## Design route

**Standard.** Grounded triggers: a destructive-action confirmation tier is being selected for the first time on this page; an existing shipped multi-state control gains a fourth state; a new owner-facing evidence-disclosure surface with loading/error/zero/resolved states is introduced; and the flow changes with irreversible-consequence framing. Not Studio: this is brownfield work inside the existing "Field Workbook" system, with no brand or greenfield question and no ambiguity worth three competing directions. Not Compact: more than one bounded change is involved (tier selection, an evidence panel, multi-state copy across four reversal transitions, and a cross-file CSS reachability decision).

`design-director` led `ux-architect` and `visual-system-designer`. `motion-designer` and `asset-art-director` were correctly skipped: no motion, no new imagery, and the design is explicitly icon-free. Prototype forbidden and none was created. Model tier: Sonnet 5 default; no Opus or Fable escalation trigger applied, and no model ladder was run. Existing-system mode: preserve.

`design-reviewer` ran independently on the handoff and returned an evidence-backed `NEEDS_REVISION` with three findings: one MEDIUM (DR-EVIDENCE), one LOW (DR-HANDOFF), and one advisory (DR-FIT). The original Design Director was resumed exactly once, revised, and the reviewer independently re-verified the remediations against source and returned `PASS` with no blocking findings.

### Design handoff (standard, passed)

**Confirmation tier: Tier B+ (`Modal` plus `.demo-button.caution`), the `DisableStudentModal` weight.** Justified against both alternatives rather than asserted. Not Tier B (the plain-confirm treatment Released uses), because that would equate revoke with a reversible, no-loss action. Not Tier C (the typed-literal `.destructive-warning` treatment of HardDelete and WipeSave), because those precedents are reserved for actions that genuinely destroy data, and revoke destroys nothing and is reversible as a state; a typed confirmation would overstate permanence and add disproportionate friction to a time-sensitive access-control decision. The reviewer independently verified this precedent mapping against source and upheld it.

**Recorded asymmetry, considered and knowingly accepted, not resolved by silent analogy (the reviewer's DR-FIT advisory).** Revoke's warning copy carries an explicit irreversible side effect, that the time a student lost while access was revoked is not restored, whereas the Tier B+ precedent `DisableStudentModal` carries no equivalent framing. Revoke is therefore marginally more consequential than the precedent it is matched to on styling weight. No codebase evidence forces escalation to Tier C. This is recorded as a deliberate acceptance; it changes nothing about the tier.

**The fourth option.** Label `Revoked`, appended last (`automatic, released, held, revoked`), no `<optgroup>`, the control is not relocated, honouring Phase 3's forward-compat note verbatim. The existing `aria-label={"Access for " + lessonTitle}` is retained unchanged; the resting-state consequence text is delivered through a new conditional `aria-describedby` rather than by mutating the accessible name.

**The modal.** `suppressDismiss={false}`. Title "Revoke access to this lesson?". Body order: warning paragraph, then evidence block, then student-visibility caveat, then `.modal-actions` (Cancel `.demo-button.secondary`, Confirm `.demo-button.caution`). `ariaDescribedBy` points at the warning paragraph's id. Confirm closes the modal first and then calls `setLessonAccessState(..., 'revoked')`, with success and failure reported through the roster's existing inline `role="status"` feedback slot, deliberate parity with the shipped `confirmRelease` pattern at `CourseWorkspacePage.tsx:316-328`, which the reviewer confirmed does close before awaiting.

**Binding copy, verbatim:**

- Warning: "Revoking access blocks {studentDisplayName} from opening {lessonTitle} right away. Nothing is deleted — their completion record and quiz attempts for this lesson stay exactly as they are. You can restore access later by setting this back to Automatic or Released, but any time lost while access was revoked isn't restored."
- Student-visibility caveat, after the evidence block, plain `<p>`, no role: "This takes effect immediately for the student's account — a revoked lesson cannot be opened, and no new quiz attempt can be submitted for it. There isn't yet a dedicated screen that explains this to the student if they try; that student-facing messaging ships in a later release."
- Success: "{lessonTitle} access is now revoked for {studentName}."
- Failure: "Could not revoke access to {lessonTitle}."

**The evidence block**, sourced from `get_lesson_progress_evidence`, fetched eagerly on modal open. A fetch failure never disables or blocks Confirm; the two RPCs are independent.

- Resolved: a "Completed:" row ("Completed on {date}" or "Not completed") and a "Quiz attempts:" row ("{n} attempt(s) recorded" or "No quiz attempts recorded"), plus an always-shown honest-limitation line: "This does not show whether {studentDisplayName} has viewed or opened the lesson — only completion and quiz attempts are tracked for workspace-authored lessons."
- Loading: `<p role="status">Loading what {studentDisplayName} has done in this lesson…</p>`.
- Error: `<p role="alert">Couldn't load completion and quiz details for this lesson.</p>` plus a "Try again" secondary button plus "You can still revoke access without this information."
- Zero-evidence is deliberately NOT a separate branch; the same two rows render the "not yet" values, so no empty-state component exists to drift.

**Resting state.** A persistent `<p id="roster-lesson-{lessonRevisionId}-revoked-hint">Access revoked. {studentDisplayName} cannot open this lesson while it's revoked. Set it back to Automatic or Released to restore access.</p>`, rendered as the second child of the existing select wrapper at `CourseWorkspacePage.tsx:360-371`. It reuses `.field-hint` with weight-only differentiation (`.roster-lesson-row .revoked-hint{font-weight:var(--font-weight-label)}`), never a colour-only cue, and carries no icon and no `role` (static content, matching the existing precedent at line 353). The select's conditional `aria-describedby` points at this id only when the row is revoked.

**All four reversal transitions:**

- To Automatic with `unlock_at` in the future: "{lessonTitle} is set to Automatic for {studentName}. Access is restored, but the time it was revoked has already passed and is not restored."
- To Automatic with `unlock_at` in the past: the same reversal sentence appended to Phase 3's existing "It stays unlocked and will not re-lock." disclosure.
- To Released: "This lesson was previously revoked; the time it was unavailable is not restored." appended to the existing Release-modal paragraph.
- To Held: no reversal sentence, the ordinary Held message only, because access stays blocked.

This requires passing the previous `manual_release_state` into the Automatic/Released transition handlers, a small, scoped signature change.

**Denominator advisory.** Do not merge revoked rows into `held_not_completed_count`; that would misreport the row's state. Add a parallel `revoked_not_completed_count` and a sibling `.schedule-severity-advisory` line rendered directly after the held advisory (held first, then revoked).

**Reconciliation panel: no change.** Grounded in finding 7 above.

**The CSS reachability decision, binding.** `button.demo-button.caution` is relocated from `src/components/AdminStudentModals.css:201-219` into `src/App.css`, immediately after `.demo-button.secondary`. `CourseWorkspacePage.tsx` must NOT import `AdminStudentModals.css`; Phase 3 already tried and rejected that exact import for this exact page, and it would drag roughly twenty unrelated selectors into page-global scope for one button class. As part of the same move, three defects in that rule are fixed: the undeclared `--color-warning-600`/`--color-warning-700` background references become `var(--color-brass-600)` and `var(--color-terracotta-600)`, and the hardcoded `color: white` at line 203 becomes `var(--color-paper-50)` on both the default and hover declarations. Do not relocate the rule with `color: white` left intact. The `:disabled` block sets only `opacity`/`cursor` with no separate colour, so scoping the colour fix to default and hover is complete.

**Contrast, two distinct and correctly attributed pairs.** Default `brass-600` background on `paper-50` text = 5.02:1, the pairing already proven by `WeekCard.css`'s documented J-001 fix. Hover `terracotta-600` on `paper-50` = 4.689:1, the pairing from the documented J-003 fix. This is the correction the reviewer's DR-EVIDENCE finding forced: had `color: white` been left in place, hover would instead have been white-on-terracotta-600 at 4.81:1, a different pairing that must not be cited as the WeekCard-verified value. Both clear AA's 4.5:1 floor for this button's 16px/700 text, which is below the 18.66px bold large-text exemption so the stricter threshold applies; the correction is about accurate citation plus a real in-scope code change, not a contrast failure. Terracotta-600 is deliberately reserved for the hover moment rather than the resting fill, because terracotta-600 already carries this page's error and focus meaning and using it at rest would visually equate Tier B+ with Tier C.

Reused verbatim and unmodified: `.schedule-severity-error` 10.10:1, `.schedule-severity-advisory` ~11.3:1, `.field-hint` 8.37:1, `.demo-button.secondary` 14.43:1.

**Reviewer verification that went beyond what was asked, recorded here because the packet's own documentation of the rule's "existing consumer" needed correcting.** The reviewer independently established that `button.demo-button.caution`'s consumer set is larger than `DisableStudentModal` alone: `ReissueAccessModal` (`AdminStudentModals.tsx:632`), `TogglePasswordChangeModal` (line 772), and five buttons in `src/pages/AdminStudentsPage.tsx` (lines 601, 653, 680, 717, 746) carry the same class, for eight total consumers including `DisableStudentModal`. The reviewer verified the relocation is safe for all of them: `button.demo-button.caution` has specificity (0,2,1), strictly higher than `AdminStudentsPage.css`'s single-class `button.caution` rules at (0,1,1), so it wins on every property it declares regardless of source order; and `paper-50` (#fdfcf9) is visually near-indistinguishable from white. It also noted, out of scope, a pre-existing redundant redefinition of `button.caution` at `AdminStudentsPage.css:427-430`. This plan carries the correction forward for future maintainers: the rule's true consumer scope is eight components, not one.

**Other engineering invariants.** No new hex, spacing, or font primitive. `.revoke-modal-body`, `.revoke-evidence-block`, `.revoke-evidence-row strong`, and `.roster-lesson-row .revoked-hint` are declared locally in `src/pages/CourseWorkspace.css`, all ancestor-scoped, matching the discipline already enforced for `.roster-lesson-row select:disabled{opacity:.6}`, never a bare or global selector. Do not reuse `.modal-confirmation-content` for the new modal: the reviewer confirmed it is already a silent no-op on this page today (used three times in `CourseWorkspacePage.tsx` but styled only in the unimported `AdminStudentModals.css`); a companion fix declaring it locally is optional adjacent scope, not required. No icon anywhere in the revoke modal or the resting hint. `Modal.tsx`, `.field-hint`, `.schedule-severity-*`, `.modal-actions`, `.demo-button.secondary`, and the `.course-workspace *:focus-visible` 3px terracotta-600 / 2px-offset ring remain reused exactly, unmodified.

**Amendment (2026-08-31): one narrow, named exception to `Modal.css`'s otherwise-unmodified reuse.** `Modal.css` is reused unmodified in every respect except one: its overflow-context CSS may be corrected, specifically the `display`, `flex-direction`, `flex`, and `min-height` properties on `.modal` and `.modal-content`, and the removal of `.modal-content`'s non-resolving `height: 100%`, to close a confirmed scroll-blocking defect. Everything else about `Modal.css` stays unmodified: colors, backgrounds, spacing and padding, typography, the focus outline, the class names and structure, and the `max-width: 640px` responsive block. `Modal.tsx`'s focus-trap logic, Escape/backdrop handling, focus restoration, and ARIA are untouched.

The defect: `.modal` was sized by `max-height: 90vh` only, with no resolved definite height, so `.modal-content`'s `height: 100%` never resolved and its `overflow: auto` never activated. Genuinely overflowing content therefore extended past the viewport with no scroll path to the `.modal-actions` buttons. The defect was latent before Phase 4, because no shipped modal's content was tall enough to trigger it; the new revoke modal (warning paragraph, evidence block, and honest-limit caveat) is the first content tall enough to expose it.

This exception was added by amendment after Phase 4's own browser validation found the defect; it was not anticipated at plan approval. The fix was implemented and live-verified across the revoke modal, `HardDeleteStudentModal`, the Release modal, and `UnassignModal` at 375×667, 768×1024, and 1440×900, with no regression to the existing Modal test suite. This exception authorizes no other change to any shared component.

**Permitted variation.** The exact `pendingRevoke` prop/state shape, the exact id-generation scheme for `aria-describedby` targets, and whether the optional `.modal-confirmation-content` companion fix ships in the same change, provided every invariant above holds and no copy deviates beyond grammar and interpolation mechanics.

## Ordered work

TDD is mandatory throughout: no production code before a failing test exists for it. This engagement has caught a real bug through live browser verification in every phase so far, so a Browser Validator pass is mandatory and unit tests alone are explicitly insufficient.

1. **Failing tests first**, for every acceptance guarantee in the section below, including the RLS-as-student-role assertions, the audit-trail assertion, and the Edge allow-list assertion. Owner: T1.
2. **The `revoked_not_completed_count` migration and read work, plus the Edge allow-list check (added by cross-vendor judge finding J-01).** Add the new subquery to `list_enrollment_lesson_entitlements`'s per-student JSON (`202608300002...sql:664-670`), mirroring `held_not_completed_count` but keyed on `manual_release_state = 'revoked'`, as a new migration following the established naming pattern; the function's signature is unchanged. Add the `getProgressEvidence(enrollmentId, lessonRevisionId)` client wrapper in `src/services/courseAuthoring.ts` for the already-wired `get_progress_evidence` Edge action (no Edge change needed). Widen `setLessonAccessState`'s `newState` union to include `'revoked'` and widen the client `RosterStudent` type to carry `revoked_not_completed_count`. Add an explicit allow-list check in the `set_lesson_access_state` Edge action, rejecting anything outside `automatic`/`released`/`held`/`revoked` with a 422 in the same shape as the existing `if (!payload.enrollment_id ...)` guard immediately above it, before the RPC is called; cite the SQL allow-list's line number in a comment at the Edge check, per Risk R8's mitigation below. This step is sequenced before step 4 exposes the fourth option to the UI. Owner: anticipated T1, since this step is one additive read subquery, one boundary validation check, and four small client changes with no new correctness-sensitive SQL logic; stated as an expectation, not a failure condition, matching how the sibling phases framed T1/T2 ownership.
3. **The `.demo-button.caution` relocation** into `App.css` with its three defect fixes (the two undeclared `--color-warning-*` tokens, the hardcoded `color: white`), and its regression test covering all eight known consumers. Owner: T1.
4. **The roster's rendering model for `revoked`, fixed and independently verified before the revoke action is exposed (added by cross-vendor judge finding J-02).** Extend the roster's state-rendering model to handle `revoked` explicitly: the fourth select option, the deterministic `Revoked` label, the resting-state hint, and the conditional `aria-describedby`. Verify this step against a pre-seeded revoked row (Fixture B) with no owner-facing way yet to create one, since step 5 has not shipped. State the reason plainly: until a revoked row renders correctly and shows its own recovery path, shipping the action that creates one would let an owner produce a state the UI cannot represent or reverse. This is a binding ordering requirement, in the same register this plan's sibling (`lizbeth-spanish-issue5-phase3-owner-enforcement-controls.md`) already used for the apply-migration note's ordering gate. Owner: T1.
5. **Expose the revoke action itself (added by cross-vendor judge finding J-02).** The `pendingRevoke` state and the revoke modal with all evidence states (loading, error-with-retry, resolved, resolved-zero). Only after step 4 has independently rendered and verified the `revoked` resting state. Owner: T1.
6. **The four reversal-transition copy paths and the previous-state signature change** for the Automatic/Released transition handlers. Owner: T1.
7. **The revoked denominator advisory and its ordering** (held first, then revoked). Owner: T1.
8. **Full suite after `npx supabase db reset`. Verifier pass. Browser Validator pass.**

**Ownership summary.** T1 for the client, UI, CSS, and copy steps throughout. Anticipate T1 for step 2 as well, since no new SQL logic beyond one additive read subquery is written this phase; stated as an expectation, matching how the sibling phases framed it, not as a failure condition if escalation proves warranted.

## Interfaces and data

No schema change. No new SQL function for the setter; Phase 1's `set_lesson_access_state` is used as-is.

Four additions, all small and additive:

1. A `getProgressEvidence(enrollmentId, lessonRevisionId)` client wrapper in `src/services/courseAuthoring.ts` for the already-wired `get_progress_evidence` Edge action. No Edge change needed.
2. `revoked_not_completed_count` added to `list_enrollment_lesson_entitlements`'s per-student JSON (`202608300002...sql:664-670`), as a new subquery mirroring `held_not_completed_count` but keyed on `manual_release_state = 'revoked'`. This is a new migration following the established naming pattern; the function's signature is unchanged.
3. `setLessonAccessState`'s `newState` union at `src/services/courseAuthoring.ts:144` gains `'revoked'`.
4. The client-side `RosterStudent` type gains `revoked_not_completed_count`.

Backward compatibility: additive throughout. No existing caller's signature or behavior changes.

## Acceptance and validation

TDD is mandatory; no production code before a failing test exists for it. A Browser Validator pass is mandatory and unit tests alone are explicitly insufficient, because this engagement has caught a real bug through live browser verification in every phase so far. All items below are mandatory.

1. Setting a lesson to `revoked` through the UI makes it invisible to that student. Assert by querying as the **student database role** so RLS is genuinely exercised, never by a service_role read that would pass even if the policy were broken. Assert across the entitlement row itself and at least one dependent policy (`lesson_revisions` or `course_version_lessons`).
2. Revoking preserves `completed_at` and every `quiz_attempts` row for that student and lesson, asserted directly.
3. Every revoke writes an audit entry. Assert the `activity_events` row exists with `event_type = 'lesson_access_state_changed'`, the correct actor/owner, and a detail payload carrying `old_state`, `new_state`, `old_unlock_at`, and `new_unlock_at`, so the action is genuinely attributable and explainable, per the roadmap's own reason for making the audit trail a Phase 4 dependency.
4. Reversal genuinely restores access: revoked → automatic and revoked → released each make the lesson visible again, asserted as the student database role. Assert that revoked → automatic does not move `unlock_at`.
5. Revoking a row that has no entitlement is impossible from the UI (the control is disabled) and raises `entitlement not found` at the RPC.
6. **(Added by cross-vendor judge finding J-01.)** The Edge action rejects an out-of-set `new_state` with a 422 before reaching the database, asserted at the boundary and not only through the RPC's own exception; and the four valid states each still pass through unchanged. This is defense in depth layered over an already-correct database check, not a fix for a reachable data-integrity bug: `set_lesson_access_state`'s own allow-list already rejects an out-of-set value (see "Judge findings and disposition" above), and this item must not be read as evidence the database was unprotected.
7. **(Strengthened as the ordering gate for cross-vendor judge finding J-02.)** The roster select renders exactly four options in the order automatic, released, held, revoked, and a row whose stored state is `revoked` renders with Revoked selected. This is the finding-4 misrender regression test. This item must be satisfiable, and satisfied, against Fixture B (a pre-seeded revoked row) before the revoke action itself is wired, per Ordered work steps 4-5 above. Additionally assert that the recovery path is visible and operable from the revoked resting state, that is, the owner can both see the row is revoked and set it back to Automatic or Released, asserted through the accessibility tree, not visually.
8. The reconciliation preview's `excluded_manual_override` bucket counts a revoked row, and an applied reconciliation never modifies it. Assert both.
9. `revoked_not_completed_count` is correct, is NOT merged into `held_not_completed_count`, and the two advisories render in the specified order (held first, then revoked) when both apply.
10. Every specified copy string renders verbatim, including all four reversal transitions and the honest-limitation line. Assert the warning copy never implies deletion and never implies permanence.
11. All four evidence-block states render (loading, error with retry and reassurance, resolved-with-data, resolved-zero) and Confirm stays enabled through the error state.
12. `aria-describedby` on the select is present only when the row is revoked and resolves to the resting hint, verified through the accessibility tree rather than visually.
13. A relocation regression test: `button.demo-button.caution` resolves on `CourseWorkspacePage` without importing `AdminStudentModals.css`, and `DisableStudentModal`, `ReissueAccessModal`, `TogglePasswordChangeModal`, and the five `AdminStudentsPage` buttons still render correctly after the move. Assert no `--color-warning-*` reference and no hardcoded `color: white` remains in the relocated rule.
14. `src/__tests__/nativeDialogPolicy.test.ts` passes, and the deterministic no-native-dialog source scan finds zero matches in every changed file.
15. Full suite passes after `npx supabase db reset`.
16. Verifier pass, then Browser Validator pass.
17. **(Added by amendment, 2026-08-31.)** The revoke modal's action buttons (Cancel and Confirm) must be reachable and operable at all three standard viewport profiles (1280×800, 768×1024, 375×667). When the modal's content exceeds the available height, the modal body must genuinely scroll so the actions can be reached, asserted in the browser and not only in unit tests. This is the named, tracked requirement covering the shared `Modal.css` overflow-context fix carved out under "Other engineering invariants" above, so the fix is a tracked acceptance requirement rather than an untracked patch. The existing Modal test suite must still pass unchanged, and `HardDeleteStudentModal`, the Release modal, and `UnassignModal` must show no regression.

**Honest limit, in the roadmap's own register.** Items 1 and 4 prove revoke is correct at the database level. Per the roadmap's reframing finding, that is not the same as a student having experienced it, and it cannot be until Phase 5 ships a student-facing surface. Phase 5 re-validates it through a real student session. This is stated plainly rather than letting the browser pass imply end-to-end student proof.

## Risks and rollback

This is the only genuinely destructive-to-access action in the programme, so it is weighted accordingly.

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Critical | An owner revokes without understanding the consequence | Mitigated by the Tier B+ modal, the binding warning copy, and the evidence block showing real completion and quiz-attempt data before the decision |
| R2 | Critical | Revoke is wired to a bulk or multi-row path | Must remain strictly single-row, single-student, explicitly triggered. The bulk reconciliation path must never be able to reach it, per roadmap decision D4's exact requirement, already structurally satisfied because reconciliation only touches `automatic` rows |
| R3 | High | The evidence block's honest limitation is dropped, so an owner believes "not completed / no attempts" means "hasn't used it" | Mitigated by the always-shown limitation line and acceptance item 10 |
| R4 | High | The warning copy is softened during implementation and implies data deletion or permanence | Mitigated by the verbatim-copy requirement and acceptance item 10 |
| R5 | High | The audit entry is not written or is written without the actor, making a revoke unexplainable | Mitigated by acceptance item 3 |
| R6 | High | **(Added by cross-vendor judge finding J-02.)** The revoke action ships before the rendering model handles `revoked`, letting an owner create a row the roster cannot represent or reverse | Mitigated by the binding Ordered work step order (steps 4-5) plus the strengthened acceptance item 7 gate |
| R7 | Medium | The `.demo-button.caution` relocation regresses one of the eight other consumers | Mitigated by acceptance item 13 and the reviewer's specificity analysis |
| R8 | Medium | **(Added by cross-vendor judge finding J-01.)** The Edge allow-list drifts out of sync with the SQL allow-list if a fifth state is ever added, leaving one layer silently permissive or wrongly restrictive | Mitigated by keeping the two lists textually adjacent in review, citing the SQL line number in a comment at the Edge check, and covering both layers in acceptance item 6 |
| R9 | Medium | Revoke leaks into the reconciliation apply path or the migration path | Mitigated by acceptance item 8 and by G-ENT-1.5's existing structural-separation assertion |
| R10 | Medium | A revoked row silently caps a student's completion ratio and blocks a downstream prerequisite with no visible cause, the same hazard Phase 3 recorded as R18 for held | Mitigated by the new `revoked_not_completed_count` advisory |
| R11 | Medium | Reversal copy overstates recovery, implying the student lost nothing | Mitigated by the four verbatim reversal strings |
| R12 | Low | A stale local database produces false results | Mandatory `npx supabase db reset` before every validation pass |
| R13 | Medium | **(Added by amendment, 2026-08-31.)** The shared `Modal.css` overflow-context fix changes a component used by every modal in the app, so a mistake would regress modals outside Phase 4's scope | The change is confined to flex/overflow-context properties with no color, spacing, token, ARIA, or focus change; it was live-verified across four modals at three viewports; the existing Modal test suite passes unchanged; and acceptance item 17 tracks it |

**Amendment note (2026-08-31).** Because `Modal.css` is shared, this fix incidentally benefits every other modal in the app that carried the same latent defect pattern. That set includes, but is not limited to, the AccessibilitySettings modal referenced in the separately-parked GitHub issue #28. Explicitly and unambiguously: this amendment does NOT close, resolve, or reduce the scope of issue #28. Issue #28 remains parked for its own future ground-up redesign under the Field Journal DS milestone, and nothing here authorizes, begins, or pre-empts that redesign.

**Rollback.** Every change is additive and confined to the authoring workspace plus one additive read field. Reverting the UI removes the control and returns `revoked` to being unreachable from the client, exactly as today; the CSS relocation reverts as a file move; the read-field migration is additive with no data migration. No student-facing behavior exists to regress, per the roadmap's reframing finding. Reverting does not un-revoke any row already revoked while the control was live; those rows keep their state and must be reversed individually through the same setter.

## Assumptions and decisions

**Safe assumptions:**

- `App.css` is root-loaded and reaches this page. Inferred from `.demo-button.primary`/`.secondary` already rendering correctly there with no page-level import, and independently confirmed by the reviewer through `main.tsx` → `App.tsx` → unconditional `import './App.css'`.
- The revoke modal nests inside the same `.workspace-panel.roster-panel` as the existing Release modal, which is what lets the existing focus-ring and hover rules reach it with no new CSS. If engineering places it elsewhere, this DOM-descendant assumption must be re-verified.
- `pendingRevoke` is a direct sibling of `pendingRelease` in the same component, with no new component file.
- `formatShortDate` (`CourseWorkspacePage.tsx:132`) is reused as-is.

**Explicitly unverified limits, stated rather than buried:**

- The design's contrast verification covers only the specific cited pairs, not a full re-audit of `CourseWorkspace.css` or `AdminStudentModals.css`.
- Quiz-attempt submission gating was verified through the shared `manual_release_state in ('held','revoked')` pattern at three confirmed call sites; a fourth quiz-specific RPC was not traced line by line.
- Source-order precedence between `App.css`'s flat hover-transform reset and `CourseWorkspace.css`'s `-1px` hover lift is specificity-tied to bundle import order and was not verified; it is cosmetically minor either way and is left for engineering-time confirmation.
- Phase 3's carried limit that cross-file CSS reachability analysis on this page is source-level only, not confirmed against a real build's chunking, applies to this phase too.

**Open decisions, resolved at approval (see "Approval record" below):**

1. **The Phase 3 roster completion column (finding 9).** Approved in Phase 3's design delta section C but not built. **Resolved: track separately, not folded into Phase 4**, per the recommended default. Phase 4's design remains deliberately specified not to depend on it. This gap is not remediated by this plan and is not this phase's scope; it is carried forward as a separate, unscheduled item.
2. **Revoke-failure reporting parity with Released.** A failed revoke is reported only through the inline `role="status"` slot, with the modal already closed and no blocking in-modal error state, exact parity with the shipped Released flow. **Resolved: accept the parity**, per the recommended default. Acceptance item 7's ordering gate and the rest of this plan's acceptance criteria are unchanged by this resolution. If this is revisited later, both the Released and Revoke flows change together rather than diverging.
3. Optional companion fix declaring `.modal-confirmation-content` locally in `CourseWorkspace.css`, which would also fix the pre-existing Release-modal no-op. **Resolved: deferred, not built in this phase.** It remains available as a future minor fix and stays listed under "Permitted variation" above as optional adjacent scope, not required.

**Not blocking, recorded:** the exact caveat-paragraph phrasing may be shortened once real modal-body length is seen in the browser; its required presence and grounding are settled.

## Browser UI dialog policy

Required and binding. `alert`, `confirm`, `prompt`, all their `window.*` forms, and `beforeunload` prompts are prohibited. Every acknowledgement and confirmation is the app-owned `src/components/Modal.tsx`, verified to have a real Tab-cycling focus trap, Escape handling, and focus restoration to the trigger, or inline `role="status"`/`role="alert"` messaging. The revoke modal uses `suppressDismiss={false}` and must not use `.destructive-warning`, which stays reserved for the Tier C hard-delete/wipe-save tier. Enforced by `src/__tests__/nativeDialogPolicy.test.ts` plus a deterministic source scan of every changed file.

## Browser UI validation

This section is complete and defers nothing to the writer's completion claim.

- **Launch and readiness:** `npx supabase start`, then `npx supabase db reset`, then `npm run dev`. Capture the actual printed Vite URL; observed in the 5173-5178 range and never hardcoded.
- **Base URL:** the captured Vite dev URL. Relevant route is the course workspace's Students tab (the Student roster panel).
- **Credentials:** owner account `owner@test.local` / `password`, per `supabase/seed.sql:78`.
- **Fixture and reset:** `npx supabase db reset` before each pass.
  - Fixture A: a published course version with 3+ lessons and an enrolled student, one row `has_entitlement: true` / `manual_release_state: 'automatic'` / `completed_at: null`, one row with `completed_at` set and 2 `quiz_attempts`, and one lesson with no entitlement row.
  - Fixture B: a pre-seeded row already at `manual_release_state: 'revoked'`, for the resting state and the misrender regression.
  - Fixture C: a student with one revoked-and-not-completed lesson and one held-and-not-completed lesson, for advisory ordering.
  - Fixture D: a revoked row whose `unlock_at` is in the past, and one whose `unlock_at` is in the future, for the two Automatic-reversal copy variants.
  - Roster reload is re-triggerable through the existing `reload()`, not a page reload.
- **Journeys, all sixteen:**
  1. Evidence-loading state: select Revoked, modal opens titled "Revoke access to this lesson?", warning and caveat visible immediately, evidence area shows the `role="status"` loading text, the select's displayed value is unchanged, both buttons enabled.
  2. Evidence resolves non-empty: "Completed on {date}", "2 attempt(s) recorded", limitation sentence visible, loading text gone.
  3. Evidence resolves zero: "Not completed" / "No quiz attempts recorded" render with no distinct empty-state banner or styling.
  4. Evidence fetch fails: `role="alert"` error text plus "Try again" plus the reassurance line, and Confirm remains clickable.
  5. Cancel, Escape, and backdrop from any evidence state: modal closes, select unchanged, no write call, focus returns to the select.
  6. Confirm success: modal closes immediately without awaiting the network, inline `role="status"` success message appears, roster reloads, select shows Revoked, the persistent resting hint is now present, focus is on the select.
  7. Confirm failure: modal already closed, inline failure message shown, select's value unchanged.
  8. Revoked row at rest on Fixture B: select shows Revoked, the persistent hint is present and `aria-describedby`-associated (verify through the accessibility tree), no icon is present, and the row remains legible under a grayscale rendering check, confirming non-colour differentiation.
  9. Collapsed-header advisories on Fixture C: one revoked-and-not-completed and zero held renders only the revoked advisory; one of each renders both, held first then revoked.
  10. Reversal to Automatic with `unlock_at` in the past: immediate, no modal, the inline status combines the existing "stays unlocked" disclosure with the new reversal sentence, select shows Automatic, resting hint removed.
  11. Reversal to Released: the existing Release confirmation modal opens with the appended previously-revoked sentence, and confirming behaves exactly as the shipped Released flow.
  12. Reversal to Held: immediate, no modal, ordinary Held message only, no reversal sentence appended.
  13. Keyboard-only full path: reach the select by Tab, choose Revoked by arrow or typeahead, modal opens with focus trapped inside, Tab cycles only Cancel and Confirm, Shift+Tab from Cancel wraps to Confirm, Escape closes and restores focus to the select; repeat confirming by Enter and verify post-close focus lands on the select.
  14. The no-entitlement row is unaffected: still a disabled select plus its existing explanation, entirely unreachable by this flow.
  15. Viewport sweep: repeat journeys 1, 6, and 8 at 768×1024 and 375×667; no layout breakage, no truncated or overlapping text in the modal body or the resting hint, every interactive element reachable and at least as large as this page's existing touch targets.
  16. No-native-dialog scan: deterministic source scan of every changed file confirms zero matches.
- **Viewport profiles:** desktop 1280×800 primary, tablet 768×1024, and mobile 375×667, which sits below the existing `max-width:700px` breakpoint. No new breakpoint is introduced.
- **Visible outcomes:** the revoked resting state is distinguishable from the other three by select text and hint weight alone, with no colour cue and no icon; the Confirm button reads as heavier than the Released modal's primary button but is visibly not the `.destructive-warning` treatment; the evidence block's four states are each distinguishable; the two advisories are visibly ordered held-then-revoked; and the focus ring on every new control is the existing 3px terracotta-600 ring at 2px offset, unchanged.

## Judge route

`PLAN_DUCK` eligibility is the orchestrator's call after this draft exists, under `docs/JUDGE-CONTRACT.md`. A cross-vendor advisory review was run on this draft and returned three findings; J-01 and J-02 were absorbed as required in-scope acceptance criteria, J-03 was assessed and dismissed with its premise corrected. See "Judge findings and disposition" above for the full record. Deterministic checks and the passed design review remain authoritative over advisory judge output.

## Approval

Explicit user approval of this document is required before any engineering writer begins. Approval authorizes Phase 4 only and does not authorize Phase 5, which requires its own plan document and its own explicit approval.

### Approval record

**Approved.** Approved by rob.hasselbach@gmail.com on 2026-08-31, via standing authorization given directly to the orchestrator in the live interactive session (not relayed through a teammate or subagent), applied by the orchestrator to this plan's three remaining open decisions.

**Standing authorization, exact user statement:** "i'm ready for you to stop fucking asking me and just keep going as planned like i asked you to do until it's all finished." Given earlier in this same live interactive session, establishing standing authorization for the orchestrator to proceed through subsequent bounded planning decisions using stated recommended defaults, without re-confirming each one individually, for the remainder of the engagement.

**This document's specific application of that standing authorization.** This plan carried three remaining open decisions, each with an explicit "recommended" default stated in "Assumptions and decisions" above. No further per-item confirmation was sought from the user for this specific plan; the orchestrator applied the standing authorization instead, on the following three items:

1. The Phase 3 roster completion column (finding 9): tracked separately, not folded into Phase 4. Recommended default adopted.
2. Revoke-failure reporting parity with the shipped Released flow: parity accepted. Recommended default adopted.
3. The optional `.modal-confirmation-content` companion fix: deferred, not built now. Recommended-but-not-required default adopted (this item's own text already stated no default was needed to resolve it either way, since it was optional; deferral is the conservative reading and changes no in-scope acceptance item).

**Distinction from a per-item confirmed approval.** Unlike the sibling Phase 3 approval (see `docs/plans/lizbeth-spanish-issue5-phase3-owner-enforcement-controls.md`, where the user replied directly to two specific presented questions), this approval rests on a general standing authorization stated earlier in the session, applied here by the orchestrator to this plan's specific open items rather than obtained through a fresh, item-by-item reply. This is recorded plainly rather than presented as an item-by-item confirmation that did not occur.

**Scope this approval authorizes.** The full Phase 4 plan as it now stands, including scope items 1 through 11, the judge-finding absorptions (J-01, J-02) as binding acceptance criteria and ordering constraints, and the three open-decision resolutions recorded above. This approval authorizes Phase 4 only; it does not authorize Phase 5, which requires its own plan document and its own explicit approval.

### Amendment approval record (2026-08-31)

**Amendment approved.** This is a record of a narrow amendment to an already-approved plan. It does not re-open, re-flip, or restate the main "Approved" status header above, which remains as written and continues to govern the plan as a whole.

**What was approved.** The single named amendment to `Modal.css`'s otherwise-unmodified reuse, carving out the `display`, `flex-direction`, `flex`, and `min-height` properties on `.modal` and `.modal-content` from the "reused exactly, unmodified" invariant (see "Other engineering invariants" above), together with:

- Acceptance item 17, covering the modal action buttons' reachability and operability at all three standard viewport profiles and requiring the existing Modal test suite to pass unchanged with no regression to `HardDeleteStudentModal`, the Release modal, or `UnassignModal`.
- Risk R13, covering the shared-component blast radius of a `Modal.css` change and its stated mitigations.
- The explicit non-closure note recorded under "Amendment note (2026-08-31)" in the Risks and rollback section: this amendment does not close, resolve, or reduce the scope of GitHub issue #28, which remains parked for its own future ground-up redesign.

**Basis for this approval.** Approved by rob.hasselbach@gmail.com on 2026-08-31, under the same standing authorization recorded in "Approval record" above and given directly to the orchestrator in the live interactive session: "i'm ready for you to stop fucking asking me and just keep going as planned like i asked you to do until it's all finished." This amendment is the kind of bounded decision that standing authorization covers: a single named exception with a stated boundary, evidence-grounded (live-verified across four modals — the revoke modal, `HardDeleteStudentModal`, the Release modal, and `UnassignModal` — at three viewport profiles, 375×667, 768×1024, and 1440×900), introducing no new visual language, and not reopening any other part of the plan's already-approved scope.

**Distinction from the main approval.** The main plan approval above authorized Phase 4 as originally drafted. This amendment approval separately authorizes only the one narrow addition described here, made after Phase 4's own browser validation surfaced the underlying scroll-blocking defect. It does not re-authorize, re-confirm, or alter any other part of the plan, and it does not authorize Phase 5.

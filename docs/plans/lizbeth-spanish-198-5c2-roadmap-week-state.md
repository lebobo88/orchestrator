# Sub-plan: Lizbeth Spanish #198 follow-up, roadmap and week-detail entitlement state (PR 5c-2)

- Plan id: `lizbeth-spanish-198-5c2-roadmap-week-state`
- Task id: `lizbeth-wave5c2-roadmap-entitlement-state`
- Status: **APPROVED 2026-10-15 (Revision 1).** User words, verbatim, 2026-10-15: "Approve all four plans as recommended". Decisions D-5c2-1 to D-5c2-14 are adopted at their recommendations. Each hosted step (H1 to H5) and any rollback still needs its own separate explicit approval. Lizbeth must approve any drafted Spanish before it ships. Written 2026-10-15.

**Revision 1 (PLAN_DUCK J-5C2-01..05, shadow, Codex gpt-6-astra).** One revision applied in place. Planner re-checked all five findings against the code in the evidence base and confirmed each. Design review of the revised handoff (revision 3) is PASS; reviewer notes G1 to G6 are folded in. The status stays DRAFT.

- J-5C2-01 (major, deploy skew). Finding: with the new frontend live before the RPC, the fail-closed rule would disable every roadmap grid and week detail. Re-check: confirmed. Netlify builds `main`, the lock state is Unknown (3.7), a missing PostgREST function returns PGRST202 / HTTP 404, and the plan treated every error as fail closed. Fix: a narrow capability gate (new Case 12, D-5c2-14). Only a function-not-found response naming `get_student_roadmap_week_states`, and only while the hook instance has seen no server data, falls back to today's display. Every other error still fails closed. "Migration before publish" stays recommended but is no longer load-bearing. Sections touched: 2, 3.8, 4.3, 4.4, 4.11, 4.13, 5, 6 (Step 3), 7, 9.2, 9.3 (J20), 10.2, 11 (R5C2-3), 12 (H0, H1), 13 (D-5c2-14), 15.
- J-5C2-02 (major, recovery loses text). Re-check: confirmed. `App.tsx:827-831` and `:914-929` replace the authenticated tree with sign-in on session loss and `replaceNavigate('/')`. Task text lives only in component state (`useLessonTask.tsx:227-299`, `:283-288`), so "Reload the page or sign in again" can destroy unsaved answers. Fix: a text-preserving recovery (new Case 13) with a `sessionStorage` stash, a Copy action, and a restore banner; it replaces the revision-2 neutral line. Sections touched: 2, 3.8, 4.6, 4.7, 4.14, 5, 6 (Step 5), 7, 9.2, 9.3 (J21, J22, J25), 10.2, 11 (R5C2-9), 13 (D-5c2-11, D-5c2-13), 15.
- J-5C2-03 (major, completion and access). Re-check: confirmed. Revision 2 handled only completed plus paused and treated a completed week with any other non-open access as plain completed. Completed plus locked can arise only through superuser-level edits (reconciliation is monotonic); completed plus unavailable arises if a row is removed; both are handled generically. Fix: completion and access are two independent axes (Case 8 generalized). Sections touched: 4.3, 4.4, 4.16, 9.2, 9.3 (J23).
- J-5C2-04 (major, freshness). Re-check: confirmed. The plan named a cache without a contract. `BandRoadmap` remounts on navigation (`BandRoadmap.tsx:51-57`), but focus, identity and boundary changes were unspecified. Fix: a freshness contract (new Case 14, D-5c2-12). Sections touched: 3.8, 4.15, 6 (Step 3), 9.2, 9.3 (J24), 11 (R5C2-10), 13 (D-5c2-12).
- J-5C2-05 (minor, revision contract). Re-check: confirmed. `WeekDetailPage.tsx:699-725` resolves the task revision through `getEnrollmentCompletion().revisionByLegacyLessonId`; `completionData.ts:66-71` iterates rows in `cvl.position` order, so the last row wins, while the RPC draft selected "prefer open, then lowest `revision_no`". They could disagree when several revisions of one legacy lesson are mapped. Fix: the RPC returns `lesson_revision_id` per week by one documented rule, `access_state` aggregates over all mapped revisions as the 5c-1 helper does, and the page uses the RPC's revision (the legacy lookup remains only in fallback mode). Sections touched: 4.2, 6 (Step 2), 9.1 (W11).
- Parent: approved sub-plan `docs/plans/lizbeth-spanish-198-legacy-entitlement-rule.md` (PR 5c-1, #258 merged; closes #198 after its hosted rollout). Decision D-198-5 of that plan: "fix the roadmap UI in a separate follow-up PR 5c-2 with its own design route"; its section 4 "Known interim UI limitation". Parent of that plan: `docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md`.
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team.
- Target: `lebobo88/lizbeth-spanish` (private), `main` at `f8a95a3`.
- Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013`. Every `file:line` below refers to it. The PR worktree is created by T1 from current `main` at Step 0. Migration filenames are given by numeric prefix and slug under `supabase/migrations/`.
- Evidence labels: Observed (read in code or an approved plan), Inference (derived from Observed facts, with the test that verifies it), Unknown (not established).

Reading guide: approvers need sections 1, 2, 3.1, 12, 13 and 14. Sections 3.2 to 3.7 hold the evidence. Sections 4 to 11 are execution detail for the engineering fleet.

### Standing constraint: production is live

Recorded 2026-10-13 from the user's words: "from this point forward we must consider the project live and production supabase as live with real student and course tracking data. moving forward nothing can be lost in production supabase and all migrations must account for that."

- Production is live, with real student and course tracking data, as of 2026-10-13.
- No production data may be lost.
- Every migration must be non-destructive and account for existing production rows. That means:
  - no DROP, TRUNCATE or DELETE of student, enrollment, progress, submission, attempt, entitlement, course or content data without an approved, logged and reversible data plan;
  - additive or backfilled schema changes with safe defaults;
  - rollbacks that preserve data written after apply;
  - a read-only production preview before any apply that changes access or data.
- Hosted actions still need separate explicit approval.

### Standing constraints

Carried forward from the user, most recently restated 2026-10-13:

- Accomplish the goal, with proper root-cause analysis.
- Pull requests only: no push to `main`, no merge by the fleet.
- Production is live with real student and course tracking data. No production data may be lost. Every migration is non-destructive and additive. Rollbacks preserve data written after apply. A read-only production preview precedes any apply that changes access or data. (This PR changes neither access nor data on hosted: the new function is read-only. The audit script in Step 6 is the read-only preview.)
- Every hosted action needs a separate explicit approval. The user runs all hosted actions.
- The student UI is bilingual. Every new Spanish string is drafted and marked "DRAFT - pending Lizbeth's approval".

---

## 1. Outcome and audience

Audience: the owner (Rob), who approves this plan and answers the decisions in section 13, and the engineering fleet, which executes it.

Outcome: the `/roadmap` week cards, the week detail page (`/roadmap/:enrollmentId/week/:n`, including direct deep links), the `BandRoadmap` metrics and ledger, and the `ContextStatusStrip` show each week's true server-derived entitlement state, aligned with `/learn`: open, locked with "Opens <date>", paused by the instructor, or not yet available. Today, after PR 5c-1, a held, revoked, pre-cohort or cadence-delayed week renders as an unlocked card with an empty Files area.

Delivery: one pull request against `main`, titled as a #198 follow-up, body "Refs #198" (5c-1 already carries "Closes #198"). No merge. No hosted action.

## 2. Scope and non-goals

In scope (one PR, 5c-2):

1. One additive migration creating a new read-only SECURITY DEFINER RPC `public.get_student_roadmap_week_states(p_enrollment_id uuid) returns jsonb`, plus its rollback file.
2. A client service, a pure mapper, and one shared per-enrollment week-state hook (cache with cache-bypassing refetch) consumed by `BandRoadmap`, `WeekDetailPage` and `ContextStatusStrip`.
3. `WeekCard` states `paused` and `unavailable`, a completed-then-paused variant, a band-level unmaterialized notice, and a fail-closed error block.
4. `WeekDetailPage` ViewState `paused`, `unavailable`, `state-error`, and `locked` with an anchor kind; `empty` only after a re-check.
5. A bilingual copy module (EN plus ES DRAFT) per decision D-5c2-4.
6. A conditional mid-session-hold save status (decision D-5c2-3).
7. A read-only hosted parity and impact audit script.
8. RED tests (SQL, unit, component, e2e) and updates to existing suites without weakening.
9. The #222 EXECUTE allowlist update.
10. A narrow deploy-skew capability gate (Case 12, 4.13).
11. A text-preserving recovery for failed task saves: `sessionStorage` stash, "Copy my answers", restore banner (Case 13, 4.14).
12. A freshness contract for the shared hook, with in-place updates and a live-region announcement (Case 14, 4.15).

Non-goals:

- No change to the 5c-1 policies or helpers, to `get_student_learn_course`, `get_student_learn_index`, `get_enrollment_lesson_completion`, `get_lesson_task_summaries`, the lesson task RPCs, or the #210 keepalive path.
- No change to the `/learn` UI. Its client-clock date comparison at `LearnDetailPage.tsx:73` is recorded as a limit; released rows carry `unlock_at` = release time, so the practical impact is nil.
- No Edge Function change. The RPC is called directly with `.rpc()`, following the precedent of `get_enrollment_lesson_completion` and `get_lesson_task_summaries`.
- No `FeedbackForm` week-list change. `feedbackForm.helpers.ts:14-18` still uses the legacy date rule; follow-up issue (D-5c2-8).
- No owner-editable site-content keys.
- No data writes.
- No hosted action, deploy or merge without separate approval.
- No change to held/revoked semantics on the server.

## 3. Repository findings

### 3.1 Root cause (Observed)

`/roadmap` derives week state in the browser from `enrollment_date` plus `lessons.unlock_offset_days`. It does not use the entitlement rule that the database now enforces.

| Area | Location | Behavior |
|---|---|---|
| Page | `RoadmapPage.tsx:41-48`, `:204-219` | Renders one `BandRoadmap` per enrollment from `useEnrollments`. No state logic. Jump-list order by `enrollment_date` at `:76-80` is cosmetic |
| Band | `BandRoadmap.tsx:66-110` | `Promise.all` of `fetchLessonsForBand` and `getLessonProgressForEnrollment`, then `computeWeekRoadmap({enrollment_date, completed_at}, lessons, completion)` at `:76-86`. Task chips from `getLessonTaskSummaries` at `:89-100`. "Current week" metric and next-milestone fallback at `:152-172`. Metrics and ledger gated on ready and weeks > 0 at `:209-225`. Per-band alert at `:187-191` |
| Library | `lib/roadmap.ts:118-152` `computeWeekRoadmap` | `bandCompleted` shortcut (enrollment `completed_at` makes every week completed) at `:125-131`. Unlocked set from `computeUnlockedWeeks` at `:133`. Current = `Math.max(unlocked)` at `:134-135` (J-01-36 Option B, doc `:107-117`). Locked weeks get `getNextUnlockDateForWeek` at `:139`, `:158-170` |
| Library | `lib/weekUnlock.ts:41-58`, `:67-81`, `:91-110` | `computeUnlockedWeeks`; `isWeekUnlockedForStudent` (unlock = `enrollment_date + unlock_offset_days`, completion bypass at `:46`, `:71`); `getNextUnlockDate` |
| Data | `services/roadmapData.ts:60-82` | `fetchEnrollmentsWithBand` selects only `id, band_id, enrollment_date, completed_at, bands(name)`. No `cohort_id`, no `course_version_id` |
| Data | `services/roadmapData.ts:84-105` | `fetchLessonsForBand` reads `lessons.unlock_offset_days` and documents "the client computes unlock state" |
| Data | `services/roadmapData.ts:107-132` | `fetchResourcesForLesson` is the RLS-gated read |
| Detail | `WeekDetailPage.tsx:756-840` `load()` | `:783` always queries resources. `:785-801` resources > 0 means available. `:803-829` zero rows calls `computeWeekRoadmap` with `new Map()`, giving locked (client date) or empty. `:1006-1009` empty copy "No resources published for this week yet." `:258-302` `computeNextWeekTarget` uses the same legacy math for the mobile Next footer. `:693-736` task and quiz machines are enabled only when state is available and lesson content is loaded |
| Card | `WeekCard.tsx:88-114` | Four-state exhaustive switch. `:176-184` every non-locked state renders Open/Review. `:187-219` locked "Why locked?" disclosure |
| Strip | `ContextStatusStrip.tsx:154`, `:185-194` | `computeCurrentWeekNumber` via `computeUnlockedWeeks` |

Divergence from the canonical entitlement rule (Observed):

- Anchor is `coalesce(cohorts.starts_at, se.enrollment_date)` (`resolve_entitlement_anchor`, `202608300001:34-40`).
- `unlock_at` is stored per entitlement (`materialize_enrollment_entitlements`, `202608300001:50-65`) and changes only by reconciliation or migration. `lessons.unlock_offset_days` is never updated (parent G5).
- `manual_release_state` held and revoked deny; released opens early (`set_lesson_access_state`, `202608290001:43`; comment `:586-587`: "Released sets unlock_at=now(). Revoked/held/automatic preserve unlock_at").
- The completion bypass was removed by 5c-1 (D-198-2; `202610130002`).

After 5c-1 (migrations `202610130001` backfill and `202610130002` rule on `main`) the resources and storage RLS enforce the canonical rule. For held, revoked, pre-cohort and cadence-delayed weeks, the resources query returns zero rows while the client date math says unlocked, so `WeekDetailPage` falls into the empty branch. Late joiners and released-early weeks diverge the other way: the client says locked while the server allows. #198 browser validation confirmed that student1 held week 3 and revoked week 4 rendered as unlocked cards with empty Files (reported by the lead from the #198 validation).

### 3.2 How `/learn` does it (Observed)

- `get_student_learn_course` (`202608310002:74-160`) is `language sql stable SECURITY DEFINER`, `search_path public`, `auth.uid()`-bound, active enrollment, `is_account_active`, `not user_requires_password_change`, fail-closed NULL. It builds the roster from `course_version_lessons` LEFT JOIN `enrollment_lesson_entitlements`.
- It returns `has_entitlement`, `unlock_at`, `anchor_kind`, `cohort_starts_at`, `completed_at`, and `manual_release_state` with held and revoked merged to `'paused'` (`:119-124`; binding constraint 2 at `:32-34`). Rationale in `docs/plans/lizbeth-spanish-issue5-phase5-student-learn-surface.md:235`: "avoids implying wrongdoing or alarming a student over an internal admin-state distinction".
- Called through the course-authoring Edge function (`learnData.ts:55-68`, `course-authoring/index.ts:55-62`).
- Client `deriveLessonState` (`LearnDetailPage.tsx:63-77`): no entitlement gives prerequisite/unavailable; completed first; paused gives on-hold "Paused by your instructor" (`:115-116`) with body "Your instructor has paused this lesson for now. Reach out to them if you have questions." (`:101-102`); `unlock_at > Date.now()` gives date-locked rolling or cohort (`:73-75`, copy `:93-100`).

Why it cannot be reused as-is for `/roadmap`: it is keyed by `lesson_revision_id` and position with no `legacy_lesson_id` or week mapping, it takes an Edge round trip, and the client clock decides lockedness. `get_enrollment_lesson_completion` (`202610030001:487-519`) returns only rows that exist (inner join), so a missing entitlement is indistinguishable from absence. `get_lesson_task_summaries` (`202610040006:377-416`) excludes held, revoked and future rows (`:412-413`).

### 3.3 Lesson tasks and #210 (Observed)

- `lesson_task_student_template` (`202610040003:153-171`) returns NULL for no `auth.uid()`, password change, inactive account, non-active enrollment, no entitlement row, held or revoked, or not yet unlocked.
- `save_lesson_task_draft` (`202610040007:16-17`) raises 42501 "Access denied" when that is NULL, before any write. `saveLessonTaskDraft` throws `LessonTaskDataError` on error (`lessonTaskData.ts:105`). `performSave` maps a throw to saveState `'error'` with "Couldn't save. Your answers are still here. Try again." (`useLessonTask.tsx:279-288`, copy `lessonTaskCopy.ts:32`).
- The pagehide/unmount keepalive (#210, `useLessonTask.tsx:509-583`; `lessonTaskData.ts:183-219`) returns null for any non-ok response and cannot read the code. `LessonTaskLeaveGuard.tsx` (app-owned Modal, flush then Stay/Leave) has no native dialog.
- A hold never deletes `lesson_task_submissions`; the last saved draft stays server-side and is readable again after release. Inference from the functions above; verified by test T-HOLD and journey J16.

### 3.4 Bilingual copy (Observed)

- `PublicContentContext.tsx:162-165` `useSiteLanguage`.
- `signInCopy.ts:1-14`, `:49`: `Record<'en'|'es', ...>` is the precedent for fixed functional copy.
- `content/privacyPolicy/es.ts:4` carries the marker "DRAFT translation, PENDING LIZBETH'S APPROVAL".
- `siteContentRegistry.ts:7-8`: Spanish defaults exist only for sign-in.
- Current `WeekCard`, `WeekDetailPage` and `BandRoadmap` strings are English literals. `WeekCard` dates use `'en-US'` (`WeekCard.tsx:24`, `:43`) or the browser default (`:48`; `WeekDetailPage.tsx:995`).
- The authenticated header renders `LanguageToggle` (`App.tsx:585`, cited by the design reviewer).

### 3.5 Test infrastructure (Observed)

- `src/__tests__/helpers/testConfig.ts:1-87`: env-driven `SUPABASE_API_URL`; `SUPABASE_DB_PORT` (then `LIZBETH_TEST_DB_PORT`, `E2E_DB_PORT`, `PGPORT`); loopback-guarded.
- `src/__tests__/helpers/issue198Fixtures.ts`: `enroll`, `createCohort`, `asStudent`, `visible()`, `revisionFor`, `STUDENT5-7`, `OWNER`; per-test BEGIN/ROLLBACK.
- e2e precedents: `issue210-draft-flush-on-leave.spec.ts` (failing dialog listener at `:61-71`, Chromium and WebKit, 1440x900 and 390x844); `polish-submissions-pager-and-forced-colors-tab.spec.ts:204-210` (`forcedColors: 'active'`); `wp10-roadmap-week-flashcards.spec.ts`; `wp11-learn.spec.ts`.
- #222 allowlist test: `authenticatedFunctionExecuteGrants.test.ts:33`.
- Latest migration prefix on `main`: `202610140001`. The next free prefix is chosen at Step 0 (expected `202610150001` or later).

### 3.6 Mirror (Observed)

`H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run`: `supabase/config.toml` API port 64321, DB 64322, studio 64323; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`. Windows reserves 54314-54413. Per-file copies only, never `robocopy /MIR`. New Edge files need a full `supabase stop`/`start` (none here).

### 3.7 Netlify (Observed, Unknown state)

`docs/plans/lizbeth-spanish-netlify-deploy-safety.md:284-288`: locking production auto-publish ("Lock to stop auto publishing") makes promotion an explicit "Publish deploy". Whether the lock is currently on is Unknown; Step H0 records it.

### 3.8 Revision 1 re-check evidence (Observed)

- Session loss: `App.tsx:827-831` and `:914-929` replace the authenticated tree with sign-in and `replaceNavigate('/')`. Task text exists only in component state (`useLessonTask.tsx:227-299`, `:283-288`).
- Quiz answers are memory-only by design (`useLessonQuiz.tsx:34`). Known limit: quiz answers are lost on session loss.
- Leave-guard copy at `lessonTaskCopy.ts:93-96` must stay true after the stash is introduced (see "Leave without saving" in 4.14).
- `BandRoadmap.tsx:51-57`: `BandRoadmap` remounts on navigation.
- Revision lookup: `WeekDetailPage.tsx:699-725` uses `getEnrollmentCompletion().revisionByLegacyLessonId`; `completionData.ts:66-71` iterates in `cvl.position` order, last row wins.
- Deploy skew: a missing PostgREST function returns PGRST202 / HTTP 404; Netlify builds `main` and the lock state is Unknown (3.7).

## 4. Design route and reviewed design handoff

```text
DESIGN_ROUTE
profile: compact
reasons: bounded brownfield change to existing /roadmap cards and week detail; reuses the /learn paused concept; no new screen or flow
agents_required: design-generalist (Sonnet, medium), design-reviewer (independent)
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve (extend WeekCard state set)
END_DESIGN_ROUTE
```

Design review: `DESIGN_REVIEW_RESULT` verdict PASS on revision 3 by the independent design-reviewer (revision 2 was also PASS; the reviewer's G1 to G6 are folded in below). The unmaterialized notice wording N2 is kept exactly as in 4.7; the revision 3 packet reverted it by mistake and that reverted text is not used. Revision 1 was NEEDS_REVISION with findings F1 to F10, all resolved: F1 chip and draft line source, F2 unmaterialized enrollments (the reviewer's client-fallback suggestion was withdrawn; the planner approach is adopted), F3 bare 42501 not mapped to paused, F4 server-computed `access_state`, F5 J-01-36 and shared hook, F6 localization scope, F7 "View week N", F8 aria-hidden glyphs, ButtonText and `--color-ink-700`, F9 `supportingFigure`, F10 known limit.

Non-blocking notes carried into this plan: N1 (the re-check must not unmount a dirty task form; invariant plus test), N2 (notice wording, adopted below), N3 (an enrollment "Completed on" line can sit beside "Weeks complete 04/12" for an enrollment-completed student; decision D-5c2-7), N4 (ES stamp and OPENS overlap check at 320 in the ES journey).

Remaining design limits: the contrast of the `--color-ink-700` dashed border is to be measured; the ES strings are drafts; quiz answers are lost on session loss (memory-only by design, `useLessonQuiz.tsx:34`).

### 4.1 Direction

Field Workbook, extend only. Two new week states, `paused` and `unavailable`, plus a band-level notice. Paused and unavailable use no LOCKED stamp, no OPENS line and no hatch. A dashed `--color-ink-700` border (at least 3:1 for non-text; forced-colors `ButtonText`, matching `WeekCard.css:189-192`), a distinct icon (`icon-pause`, `icon-unavailable` added to `ICON_BY_KEY` in the existing 24px, 2px stroke, `currentColor`, `aria-hidden` style) and a visible word separate them from locked and open. Tone is calm and instructor-centric. Held and revoked are indistinguishable to students.

### 4.2 RPC contract (planner-fixed)

Enrollment level: `has_any_entitlement_row`, `anchor_kind` (`'rolling'|'cohort'`), `cohort_starts_at`.

Per legacy week: `legacy_lesson_id`, `lesson_revision_id`, `week_number`, `access_state`, `unlock_at` (display only), `completed_at`, `task_work_saved`.

`lesson_revision_id` is chosen by one documented rule: among the enrollment version's `course_version_lessons` rows whose revision's `legacy_lesson_id` is this lesson, prefer the row whose entitlement is open, then the lowest `cvl.position`, then the lowest `revision_no`. `access_state` aggregates over all those mapped revisions exactly as the 5c-1 helper does: open if any is open, then paused, then locked, then unavailable. `WeekDetailPage` uses the RPC's `lesson_revision_id` for the task, quiz and completion machines; the legacy `revisionByLegacyLessonId` lookup is kept only in fallback mode (Case 12).

`access_state` is computed on the SERVER, in `'open'|'locked'|'paused'|'unavailable'`:

- held or revoked gives `paused`;
- released gives `open` regardless of `unlock_at`;
- no entitlement row for the enrollment's version mapping gives `unavailable`;
- otherwise `unlock_at <= now()` gives `open`, else `locked`.

`task_work_saved` is a boolean: an own `lesson_task_submissions` row exists for this enrollment and revision, any status, regardless of `manual_release_state`.

### 4.3 Client mapping (pure; never compares dates to decide state)

- `has_any_entitlement_row = false` gives the band-level notice instead of the grid.
- RPC error, timeout or malformed payload gives the fail-closed error view. The only exception is the Case 12 capability gate (function not found, before any server data).
- Completion and access are two independent axes. `completed_at` present marks the week completed; `access_state` independently gives open (current or unlocked), locked, paused, or unavailable. Completion never hides non-open access (generalized Case 8, 4.16).
- Precedence among access values on the server value: unavailable > paused > locked > open. Completion is orthogonal to this order. "Weeks complete" counts every completed week regardless of access. Cards carry `data-week-access="open|locked|paused|unavailable"`, which never distinguishes held from revoked.
- Current week (J-01-36 preserved): the highest-numbered open week. If that week is completed there is no current week. Paused and unavailable weeks are never current.
- Enrollment-completed: per-week entitlements win (the `bandCompleted` shortcut is removed on this surface). The "Completed on <date>" band line stays.
- Known limit: legacy lessons have no prerequisites, so no prerequisite title is shown.

### 4.4 Cases

| # | Case | Required behavior |
|---|---|---|
| 1 | Locked, rolling | Card unchanged (lock icon, Locked, LOCKED stamp, hatch, OPENS line). Disclosure: "This week unlocks on {date}, based on your enrollment date." Detail: existing locked panel with compass and dimmed numeral, "Not available yet. " plus body |
| 2 | Cohort | Pre-start: "when your cohort's course starts". Cohort started but week later: neutral "This week unlocks on {date}." Wording uses `anchor_kind` and `cohort_starts_at` and never affects state |
| 3 | Cadence-delayed | Server `locked` with the moved date, no extra wording |
| 4 | Paused | Card `week-card--paused`, `data-week-state="paused"`, glyph "‖" in an aria-hidden span plus word "Paused", sentence-case line "Paused by your instructor", no chip, no Open control, "Why paused?" disclosure (`aria-expanded`, `aria-controls`, Escape closes, focus returns to toggle; aria-label "Why is week N paused?"). Detail reuses the `week-detail-locked` layout without compass, dimmed numeral, `role=status`, heading "Paused by your instructor", body, plus "Your saved work is kept." only when `task_work_saved` is true. No resources, signed URL, `get_lesson_task` or task form |
| 5 | Revoked | Equals paused. Alternative distinct "Not available" copy only if the user overrides the merge (D-5c2-2): EN "This week is not available to you right now. Reach out to your instructor if you have questions." ES "Esta semana no está disponible para ti por ahora. Escríbele a tu instructor si tienes preguntas." This needs a distinct server value |
| 6 | Released early | Normal open card, no note. The mapper must not turn a future `unlock_at` into locked |
| 7 | Unavailable (materialized enrollment, no row) | `week-card--unavailable`, "– Not yet available" (glyph aria-hidden), no date, stamp, chip, action or disclosure, not focusable. Detail: "Not yet available. This week is not currently available." with dimmed numeral, no illustration |
| 8 | Completed with non-open access (paused, locked, unavailable) | Generalized in 4.16. A completed card keeps the Completed row and DONE stamp, adds a sentence-case access line, and the action becomes "View week N". For paused: line "Paused by your instructor"; detail panel "You completed this week on {date}. Your instructor has paused it for now, so its materials are hidden. Reach out to them if you have questions." plus the saved-work line rule |
| 9 | Open with zero resources | Keep the empty text. Race guard: re-check state once (cache bypass) before showing it. If it is now paused, locked or unavailable, show that panel. Re-check failure gives `state-error` |
| 10 | RPC failure | `/roadmap`: one `role=alert` block with Try again replaces the grid; metrics and ledger hidden by existing gating. Detail: kind `state-error`, `role=alert`, no content request. The only exception is a function-not-found response under Case 12; every other error fails closed |
| 11 | `has_any_entitlement_row = false` | One calm `role=status` band-level notice replaces the grid; metrics and ledger hidden; deep link gives the unavailable panel. Never fall back to client date math (after 5c-1 a zero-row enrollment reads nothing) |
| 12 | Deploy skew: new frontend, RPC not yet applied | Capability gate, 4.13. Only a PostgREST function-not-found response (PGRST202 / 404) naming `get_student_roadmap_week_states`, and only while the hook instance has seen no server data, falls back to today's display with no new alert or banner UI |
| 13 | Failed task save (hold, expired session, other) | Text-preserving recovery, 4.14: `sessionStorage` stash, "Copy my answers", restore banner, device note on the paused panel |
| 14 | Freshness | Cache, revalidation, boundary timer, in-place updates and live-region announcements, 4.15 |

### 4.5 Roadmap-level behavior

- "Current week" metric value is the week number or "None". Fallback: the nearest locked week with "Opens {date}" in the `MetricPlate` `supportingFigure`. If only paused or unavailable weeks remain, "None" without a date.
- "Weeks complete" counts completed weeks, including completed-then-paused.
- Ledger: solid for completed, hatched for current only.
- `ContextStatusStrip` reads the same hook. Single enrollment: "{band} · Week N of M" using the hook's current week, with the band name only when there is none, the call failed, or the enrollment is unmaterialized. Multiple enrollments: "N bands enrolled". The detail page shows the viewed week.
- Mobile Next footer stays available-only. Next paused gives a non-interactive "Next: week N+1 · Paused". Next unavailable gives "Next: week N+1 · Not yet available". Locked keeps the existing label (localized).

### 4.6 Mid-session hold (conditional option B, recommended)

On a draft-save 42501, re-call the state RPC (cache bypass).

- If that week is now `'paused'`: show the paused failed-save `role=status` line (stored or storage-unavailable variant, 4.14) with "Copy my answers" and no Try again.
- Otherwise (any other state, the re-check fails, or fallback mode): show the neutral failed-save `role=status` line (stored or storage-unavailable variant, 4.14) with the existing Try again and "Copy my answers". This replaces the revision-2 neutral line "Reload the page or sign in again.", which could destroy unsaved answers on session loss.

Never map a bare 42501 to paused. The keepalive path is unchanged. The leave-guard Modal is unchanged. Invariant N1: the re-check only selects the status line. It must not drive the page-level ViewState while a task form is mounted and dirty, so the form and its text stay mounted. Option A is no change, documented.

### 4.7 String table

`{date}` is formatted with `toLocaleDateString(site language, ...)`. For ES, the month abbreviation is uppercased and the trailing period removed. Every ES entry is **DRAFT - pending Lizbeth's approval**.

WeekCard:

| EN | ES (DRAFT) |
|---|---|
| Semana (eyebrow) | Semana |
| ✓ Completed {dd Mon} | ✓ Completada el {dd Mon} |
| ✓ Completed | ✓ Completada |
| ◆ This week | ◆ Esta semana |
| you're here (annotation) | estás aquí |
| ○ Unlocked · not started | ○ Desbloqueada · sin empezar |
| ○ Unlocked | ○ Desbloqueada |
| Locked | Bloqueada |
| ‖ Paused | ‖ En pausa |
| – Not yet available | – Aún no disponible |
| Paused by your instructor | Pausada por tu instructor |
| DONE (stamp) | HECHA |
| LOCKED (stamp) | BLOQUEADA |
| OPENS {DD MON YYYY} · IN N DAYS | ABRE {DD MON YYYY} · EN N DÍAS |
| IN 1 DAY | EN 1 DÍA |
| TODAY | HOY |
| Open week N | Abrir la semana N |
| Review week N | Revisar la semana N |
| View week N | Ver la semana N |
| Why locked? | ¿Por qué está bloqueada? |
| Why is week N locked? (aria) | ¿Por qué la semana N está bloqueada? |
| Why paused? | ¿Por qué está en pausa? |
| Why is week N paused? (aria) | ¿Por qué la semana N está en pausa? |
| This week unlocks on {date}, based on your enrollment date. | Esta semana se desbloquea el {date}, según tu fecha de inscripción. |
| This week unlocks on {date}, when your cohort's course starts. | Esta semana se desbloquea el {date}, cuando comienza el curso de tu cohorte. |
| This week unlocks on {date}. | Esta semana se desbloquea el {date}. |
| This week is not open yet. (locked with null `unlock_at`) | Esta semana aún no está abierta. |
| Your instructor has paused this week for now. Reach out to them if you have questions. | Tu instructor pausó esta semana por ahora. Escríbele si tienes preguntas. |

WeekDetailPage:

| EN | ES (DRAFT) |
|---|---|
| Loading… | Cargando… |
| Not available yet.  (locked prefix) | Aún no está disponible.  |
| Paused by your instructor (heading) | Pausada por tu instructor |
| Your saved work is kept. | Tu trabajo guardado se conserva. |
| You completed this week on {date}. Your instructor has paused it for now, so its materials are hidden. Reach out to them if you have questions. | Completaste esta semana el {date}. Tu instructor la pausó por ahora, así que sus materiales están ocultos. Escríbele si tienes preguntas. |
| Not yet available. This week is not currently available. | Aún no disponible. Esta semana no está disponible por ahora. |
| No resources published for this week yet. | Aún no hay recursos publicados para esta semana. |
| Could not load this week. Please try again. | No se pudo cargar esta semana. Inténtalo de nuevo. |
| We couldn't load your weeks. Please try again. (state and roadmap error) | No pudimos cargar tus semanas. Inténtalo de nuevo. |
| Try again | Intentar de nuevo |
| Not available. This week either does not exist or is not part of one of your enrollments. | No disponible. Esta semana no existe o no forma parte de ninguna de tus inscripciones. |
| Failed-save lines (paused and neutral, stored and storage-unavailable variants), restore banner, Copy, Discard, device note, freshness announcements, completed-with-access lines | See 4.14, 4.15 and 4.16 (Revision 1). They supersede the revision-2 save-paused and save-neutral rows |
| Next: week N+1 · Paused | Siguiente: semana N+1 · En pausa |
| Next: week N+1 · Not yet available | Siguiente: semana N+1 · Aún no disponible |

The existing open and locked Next footer wording is localized through the same module with ES drafts written by T1 and marked DRAFT.

BandRoadmap:

| EN | ES (DRAFT) |
|---|---|
| Weeks complete | Semanas completadas |
| Current week | Semana actual |
| None | Ninguna |
| Opens {date} | Abre el {date} |
| Filed | Archivadas |
| Your weeks aren't ready yet. Please check back soon, or reach out to your instructor. (unmaterialized notice; reviewer N2 wording adopted) | Tus semanas aún no están listas. Vuelve a revisar pronto o escríbele a tu instructor. |

The existing "Completed on <date>" band line keeps EN; its ES wording is decision D-5c2-5 (U5).

### 4.8 Responsive behavior

- 1440x900: the existing grid is unchanged.
- 390x844: mobile header chrome (eyebrow, "03 / 26") for locked, paused, unavailable, empty and available.
- 320x568: single column, no horizontal scroll, `overflow-wrap:anywhere` on the new line. ES strings up to about 30% longer must not clip. The ES OPENS line and stamps (the stamp is absolutely positioned top-right, `WeekCard.css:98-102`) must not overlap or clip at 320 (reviewer N4).

### 4.9 Accessibility

- Icon plus visible word on every state. Glyphs sit in `aria-hidden` spans and the state word is in the accessible name.
- Disclosure keyboard behavior as in case 4.
- Paused, unavailable and the unmaterialized notice use `role=status`. State-error and the roadmap error use `role=alert`.
- The unavailable card is not a tab stop. Tab order contains only Open, View, Review, toggles and Try again. Visible focus uses the existing Control ring.
- No new motion, no native dialogs, no new modal.

### 4.10 Visual tokens

No new primitives. Component aliases: `weekCard.paused.border.style` `{"$type":"strokeStyle","$value":"dashed"}`, `weekCard.paused.border.color` `{--color-ink-700}`, `weekCard.paused.background` = the plain unlocked background (not `paper-stock--graph`), and `weekCard.unavailable.*` the same. CSS only in `WeekCard.css`; classes via the existing `week-card--${state}`.

### 4.11 Engineering invariants

- The client mapper never compares dates for state. Tests: released with a future `unlock_at` is open; locked with a past `unlock_at` is locked. Date comparison is for display only (relative label, cohort wording).
- Fail closed. Never fall back to `computeWeekRoadmap` or client date math, with exactly one exception: the Case 12 capability gate (function-not-found response only, before any server data has been seen by that hook instance). Client dates never authorized anything; RLS (5c-1) remains the gate, so fallback is no worse than production today.
- One shared hook.
- Paused, unavailable and unmaterialized weeks never request resources, signed URLs, content or `get_lesson_task`, and never mount the task form or show a chip.
- Deep links resolve state before content. Empty text appears only after a successful empty read and a re-check that is still open.
- 42501 handling as in 4.6, with N1. No path discards a stashed answer except the listed clears (4.14), and no path exposes it to another user.
- A dirty form (task `hasUnsaved` OR quiz `hasUnsaved`, reviewer G3) is never unmounted by a state change (4.15).
- Held and revoked are indistinguishable in props, DOM, test ids, aria text and logs (a single merged `isPaused`).
- Exhaustive `never` switches are kept in `WeekCard.tsx` and `WeekDetailPage.tsx`.
- Copy lives in a `Record<'en'|'es', ...>` module resolved through `useSiteLanguage()`, each ES entry marked "DRAFT - pending Lizbeth's approval". No site-content keys. No `completion_threshold`.

### 4.12 Permitted variation

Icon drawings, if distinct at small size and in forced colors. Another non-color, non-hatch differentiator instead of the dashed border, if it survives forced colors and 3:1. ES wording after Lizbeth's review. Module, hook and mapper naming. Saved-work line placement. ES stamp words, if they do not fit at 320.

### 4.13 Case 12: capability gate (deploy skew)

- Trigger: only a PostgREST function-not-found response (code PGRST202 / HTTP 404) that names `get_student_roadmap_week_states`, and only while the hook instance has seen no server data (D-5c2-14).
- Effect: the hook falls back to today's `computeWeekRoadmap` display. The week detail uses today's client-derived ViewState and the legacy `revisionByLegacyLessonId` lookup.
- Safety: client dates never authorized anything. RLS (5c-1) remains the gate, so this is no worse than production today.
- Fallback mode shows no paused, unavailable, notice, banner or alert UI. An optional hidden `data-week-source="client-fallback"|"server"` attribute marks the mode.
- Every other error still fails closed (Case 10). A 500 or any other 404 shows the alert.
- In fallback, the 42501 re-check takes the neutral branch.
- Focus or visibility revalidation re-probes and switches to server mode in place once the RPC exists.
- If the function disappears after server data was seen (a rollback), the page fails closed.

### 4.14 Case 13: text-preserving recovery

Storage:

- `sessionStorage` only, never `localStorage`.
- Key: user id + enrollment id + lesson revision id + base revision. The user id is also embedded in the value and is captured when the form mounts.
- Writes happen on any failed save, on every edit while the save is failed, and on unmount, pagehide and visibility-hidden while the form is dirty.
- The entry is cleared: on a successful `performSave`; in `applyFlushResult` when the keepalive-saved snapshot equals the stashed text (reviewer G1); on Discard; on explicit sign-out after the leave guard; and on the leave-guard "Leave without saving" action (reviewer G2, planner-adjudicated: set a suppress flag and clear, so the existing copy at `lessonTaskCopy.ts:93-96` stays true).
- The keepalive request path itself is unchanged; only its result handler clears the entry.
- The restore banner shows only when the stashed responses differ from the server's current draft responses (G1).
- If a write or read-back fails, the "storage unavailable" copy variant is used. The UI never claims device storage that did not happen.

Failed-save line (`role=status`): it has Try again and "Copy my answers". The paused variant has Copy but no Try again. Strings (EN | ES **DRAFT - pending Lizbeth's approval**):

| Variant | EN | ES (DRAFT) |
|---|---|---|
| Neutral, stored | Your answers are still here and kept on this device while this tab stays open. Copy them, or reload the page or sign in again. After you sign in, open this week again to restore your answers. | Tus respuestas siguen aquí y se guardan en este dispositivo mientras esta pestaña siga abierta. Cópialas, o recarga la página o vuelve a iniciar sesión. Después de iniciar sesión, vuelve a abrir esta semana para restaurar tus respuestas. |
| Neutral, storage unavailable | Your answers are still here, but they can't be saved right now. Copy them before you reload the page or sign in again. | Tus respuestas siguen aquí, pero no se pueden guardar por ahora. Cópialas antes de recargar la página o volver a iniciar sesión. |
| Paused, stored | Paused by your instructor. Your answers are still here and kept on this device while this tab stays open, but they can't be saved to your course right now. Copy them, or reach out to your instructor if you have questions. | Pausada por tu instructor. Tus respuestas siguen aquí y se guardan en este dispositivo mientras esta pestaña siga abierta, pero no se pueden guardar en tu curso por ahora. Cópialas, o escríbele a tu instructor si tienes preguntas. |
| Paused, storage unavailable | Paused by your instructor. Your answers are still here, but they can't be saved right now. Copy them, and reach out to your instructor if you have questions. | Pausada por tu instructor. Tus respuestas siguen aquí, pero no se pueden guardar por ahora. Cópialas, y escríbele a tu instructor si tienes preguntas. |

The last sentence of the neutral stored line is reviewer G6, because sign-in lands on `/`.

Copy my answers:

- Control: a quiet-outline button, "Copy my answers" | "Copiar mis respuestas", placed after Try again.
- It writes plain prompt-and-answer text with `navigator.clipboard.writeText`.
- Success: an inline `role=status` "Answers copied." | "Respuestas copiadas." Focus stays on the button; there is no timer.
- Failure: "Couldn't copy. Select your answers and copy them yourself." | "No se pudo copiar. Selecciona tus respuestas y cópialas tú."

Restore banner:

- Inline `role=status` at the top of the task form, shown only to the same user.
- Same-revision text: "We found unsaved answers from earlier on this device. Choose one to keep editing." | "Encontramos respuestas sin guardar de antes en este dispositivo. Elige una opción para seguir editando."
- Text when the server is newer: "We found unsaved answers from earlier on this device, but your saved work has changed since then. Restoring puts them back as an unsaved edit. Choose one to keep editing." | "Encontramos respuestas sin guardar de antes en este dispositivo, pero tu trabajo guardado cambió desde entonces. Al restaurarlas, vuelven como una edición sin guardar. Elige una opción para seguir editando."
- Actions: "Restore unsaved answers" | "Restaurar respuestas sin guardar", using the secondary tier per the design-system one-Primary rule (reviewer G5, planner-adjudicated), and "Discard" | "Descartar" (quiet-outline).
- Until the student chooses, fields use native `readOnly` with `aria-describedby` pointing to the banner (G5). Autosave and the leave guard ignore the banner's text.
- Restore inserts the stored text as an unsaved edit. A newer server revision goes through the normal conflict handling and nothing is merged silently. Focus moves to the first field. Status: "Answers restored. They are not saved yet." | "Respuestas restauradas. Aún no se han guardado."
- Discard asks for inline confirmation: "Discard these unsaved answers? This can't be undone." with "Yes, discard" | "Keep them". ES: "¿Descartar estas respuestas sin guardar? No se puede deshacer." with "Sí, descartar" | "Conservarlas". Focus goes to "Keep them". Escape cancels and returns focus to Discard (G5).
- After discarding, the status "Unsaved answers discarded." | "Respuestas sin guardar descartadas." shows, the entry is deleted, and focus moves to the first field.
- The banner comes before the fields in tab order. At 320 the buttons stack full width with targets of 44px or larger. Forced colors uses a 1px `ButtonText` border. No new motion and no modal.

Paused panel device note, shown when an entry exists: "You have unsaved answers on this device. They will be offered again when the week reopens." | "Tienes respuestas sin guardar en este dispositivo. Se te ofrecerán de nuevo cuando la semana se reabra."

Privacy: device drafts are a new surface on shared computers. Mitigations are `sessionStorage` only, same-user scope, the leave and sign-out clears, and D-5c2-11. Quiz answers stay memory-only by their own design (`useLessonQuiz.tsx:34`); this is a known limit (quiz answers are lost on session loss).

### 4.15 Case 14: freshness

- Cache: in memory, keyed by (auth user id, enrollment id), cleared on identity change and sign-out. Late responses from a previous identity are discarded.
- Revalidation: on `/roadmap` and week route mount, on window focus and on `visibilitychange` to visible. Stale data stays shown while revalidating, with no spinner. Requests are de-duplicated and throttled to about 5 s. A failed revalidation keeps the last good data; data older than about 15 minutes counts as failed (Case 10). Numbers are D-5c2-12.
- Boundary timer: one per enrollment, set for the earliest future `unlock_at`. The delay is clamped to at most 1 hour and re-evaluated when it fires (reviewer G4; browser timers overflow at about 24.8 days). Retry with a short backoff if the server still says locked. The client never flips a state itself. Focus and visibility revalidation is the correctness backstop, because background tabs throttle timers.
- Cards update in place, keyed by week. If a focused control disappears, focus moves to the card's first remaining control, or to the `li` (`tabindex="-1"`).
- One hidden polite live region at the roadmap root announces real changes only, never on first load or a no-op (EN | ES **DRAFT - pending Lizbeth's approval**):

| EN | ES (DRAFT) |
|---|---|
| Week N is now paused. | La semana N ahora está en pausa. |
| Week N is now open. | La semana N ya está abierta. |
| Week N now opens on {date}. | La semana N ahora se abre el {date}. |
| Week N is no longer available. | La semana N ya no está disponible. |
| Your weeks were updated. (3 or more changes) | Tus semanas se actualizaron. |

Detail page:

- Clean form: swap the panel in place and focus its heading.
- Dirty form (task `hasUnsaved` OR quiz `hasUnsaved`, reviewer G3): never unmount. Materials are replaced by a notice. Task autosave is suppressed while the week is closed (existing `holdAutosave` ref) and edits mirror to `sessionStorage`. Quiz submit is disabled with inline status, and there is no quiz storage.
- Notice for locked or unavailable: "This week isn't open right now. Your answers are still here and kept on this device while this tab stays open. Copy them if you need them." | "Esta semana no está abierta por ahora. Tus respuestas siguen aquí y se guardan en este dispositivo mientras esta pestaña siga abierta. Cópialas si las necesitas." Omit the device sentence when storage is unavailable. Paused uses the paused failed-save line (4.14).
- Closed to open: content loads in place with "This week is now open." | "Esta semana ya está abierta." Autosave resumes.

Optional (D-5c2-13, default off): a roadmap card line "Unsaved answers on this device" | "Respuestas sin guardar en este dispositivo".

### 4.16 Completion and access axes (Case 8 generalized)

A completed card keeps the Completed row and DONE stamp. When access is not open, it adds a sentence-case access line and the action becomes "View week N". Completed with open access is unchanged ("Review week N"). EN | ES **DRAFT - pending Lizbeth's approval**:

| Access | Card line EN | Card line ES (DRAFT) | Detail panel EN | Detail panel ES (DRAFT) |
|---|---|---|---|---|
| paused | Paused by your instructor | Pausada por tu instructor | You completed this week on {date}. Your instructor has paused it for now, so its materials are hidden. Reach out to them if you have questions. | Completaste esta semana el {date}. Tu instructor la pausó por ahora, así que sus materiales están ocultos. Escríbele si tienes preguntas. |
| locked | Opens again {dd Mon YYYY} | Se abrirá de nuevo el {dd Mon YYYY} | You completed this week on {date}. It reopens on {date2}. | Completaste esta semana el {date}. Se abrirá de nuevo el {date2}. |
| locked, null `unlock_at` | (no date line) | (no date line) | You completed this week on {date}. It is not open right now. | Completaste esta semana el {date}. No está abierta por ahora. |
| unavailable | Not currently available | No disponible por ahora | You completed this week on {date}. It is not currently available. | Completaste esta semana el {date}. No está disponible por ahora. |

Completed plus locked can arise only through superuser-level edits (reconciliation is monotonic); completed plus unavailable arises if a row is removed. Both are handled generically.

Design unresolved decisions U1 to U10 map to plan decisions in section 13. Each remains open until the user answers: U1 (mid-session hold, A or conditional B) is D-5c2-3; U2 (ES "instructor" or "instructora") and U5 (ES wording for the band "Completed on <date>" line) are D-5c2-5; U3 (held and revoked merged or distinct) is D-5c2-2; U4 (the saved-work line) is D-5c2-6; U6 (localization scope) is D-5c2-4; U7 is D-5c2-11; U8 is D-5c2-12; U9 is D-5c2-13; U10 is D-5c2-14.

## 5. Judge route

Policy: shadow (advisory). Risk medium. Call cap two. Per `docs/JUDGE-CONTRACT.md`.

- PLAN_DUCK is eligible on this draft (the orchestrator runs it before approval).
- CODE_REVIEW is required after `JOB_DONE` and before Verifier (new SECURITY DEFINER RPC). Rubric ids:

| Rubric id | Check |
|---|---|
| R5C2-AUTHZ | RPC returns NULL for foreign, preserved, inactive and password-change cases; anon cannot execute; only the caller's own enrollment |
| R5C2-NOLEAK | Payload key allowlist: no content, asset paths, URLs, answer keys, thresholds, submission text or status; held and revoked merged |
| R5C2-PARITY | `access_state = 'open'` iff the 5c-1 RLS lets the student read that week's resources |
| R5C2-FAILCLOSED | The client never shows open on error, malformed payload or unmaterialized enrollment; no client date math |
| R5C2-SKEW | The capability gate is exact and narrow: function-not-found naming the RPC only, only before any server data, every other error fails closed, no new UI in fallback |
| R5C2-TEXTSAFE | (Merges the former R5C2-DRAFTSAFE.) No task or quiz form unmount while dirty; no new server write path; keepalive request path untouched; bare 42501 never maps to paused; no path discards a stashed answer except the listed clears; no path exposes stashed text to another user |
| R5C2-I18N | Every new string has EN and ES; ES marked DRAFT |
| R5C2-TESTS | RED then GREEN |

- One repeat after remediation is allowed.
- VERIFICATION_CHALLENGE is optional if coverage risk remains.
- VISUAL_REVIEW is not applicable (compact route, not brand-critical).
- Deterministic failures dominate. Finding ids flow into the engineering job and the Verifier brief. No judge pass is promised and no model-generated findings are included.

## 6. Ordered work

**Step 0 (T1): preflight.**

- Branch from current `main`; record the base SHA.
- Re-verify every cited `file:line`.
- Confirm `202610130001` and `202610130002` are present.
- Choose the next free migration prefix after `202610140001`.
- Record vitest and e2e baselines.
- Stale-plan triggers (section 15): any change to `get_student_learn_course`, `student_can_read_legacy_lesson`/`student_can_read_legacy_object`, `set_lesson_access_state`, `lesson_task_student_template`, `save_lesson_task_draft`, the `useLessonTask` leave-flush, the structure of `WeekCard`/`WeekDetailPage`/`BandRoadmap`/`ContextStatusStrip`, or the `issue198Fixtures` helper.

**Step 1 (T1): RED first.** Write the tests in section 9. Record the failing runs (the RPC does not exist; the current UI renders held weeks as unlocked or empty).

**Step 2 (T1): migration** `<prefix>_issue198_5c2_roadmap_week_states.sql`, additive only.

- Create `public.get_student_roadmap_week_states(p_enrollment_id uuid) returns jsonb language sql stable security definer set search_path = public`.
- Shape: from `student_enrollments se left join cohorts coh on coh.id = se.cohort_id where se.id = p_enrollment_id and auth.uid() is not null and se.user_id = auth.uid() and se.status = 'active' and public.is_account_active(auth.uid()) and not public.user_requires_password_change()`. Zero rows gives NULL.
- Returns `jsonb_build_object('enrollment_id', se.id, 'has_any_entitlement_row', exists(select 1 from enrollment_lesson_entitlements where enrollment_id = se.id), 'anchor_kind', case when coh.starts_at is not null then 'cohort' else 'rolling' end, 'cohort_starts_at', coh.starts_at, 'weeks', coalesce(jsonb_agg over public.lessons l where l.band_id = se.band_id order by l.week_number, '[]'))`.
- Per week: left join lateral the enrollment-version mapping (`course_version_lessons cvl on cvl.course_version_id = se.course_version_id` joined to `lesson_revisions lr on lr.id = cvl.lesson_revision_id and lr.legacy_lesson_id = l.id`) to the entitlement (`enrollment_lesson_entitlements ele on ele.enrollment_id = se.id and ele.lesson_revision_id = cvl.lesson_revision_id`).
- Choose `lesson_revision_id` deterministically when several revisions of one legacy lesson are mapped, by the rule in 4.2: among the enrollment version's `course_version_lessons` rows whose revision's `legacy_lesson_id` is this lesson, prefer the row whose entitlement is open, then the lowest `cvl.position`, then the lowest `revision_no`. `access_state` aggregates over all mapped revisions as the 5c-1 helper does (open if any is open, then paused, then locked, then unavailable), so that open iff readable (`202610130002`).
- `access_state` case: no row gives `'unavailable'`; `manual_release_state in ('held','revoked')` gives `'paused'`; `manual_release_state = 'released'` or `unlock_at <= now()` gives `'open'`; else `'locked'`.
- Fields: `legacy_lesson_id`, `lesson_revision_id`, `week_number`, `access_state`, `unlock_at`, `completed_at`, `task_work_saved` (`exists lesson_task_submissions s where s.enrollment_id = se.id and s.lesson_revision_id = chosen revision`).
- Never select `lessons.title` content beyond what lessons RLS already shows (the title may be omitted; the client has titles), `course_assets`, resources paths, `lesson_revisions.content`, answer keys, thresholds, submission text or status.
- `revoke all ... from public, anon`; `grant execute ... to authenticated, service_role`; `comment on function` stating the canonical rule, the held/revoked merge, read-only, #198/5c-2.
- Rollback file `supabase/rollbacks/issue198_5c2_roadmap_week_states_rollback.sql`: `drop function if exists` (apply only after the frontend is rolled back). No other schema change.

**Step 3 (T1): client.**

- `services/roadmapWeekStates.ts`: direct `.rpc` call; error becomes a typed error; NULL becomes a fail-closed result.
- `lib/roadmapWeekState.ts`: pure mapper (precedence, J-01-36 current, no date comparison for state).
- One shared per-enrollment hook with cache and cache-bypassing refetch, consumed by `BandRoadmap`, `WeekDetailPage`, `ContextStatusStrip`.
- Extend the `RoadmapWeekState` and `iconKey` unions.
- Copy module (`Record<'en'|'es'>`) per D-5c2-4.
- Hook freshness contract per 4.15 (identity-keyed in-memory cache, revalidation on mount, focus and visibility, throttle, staleness, clamped boundary timer, in-place updates, live region).
- Capability gate per 4.13 (function-not-found before any server data falls back to the client display; every other error fails closed). The week detail uses the RPC's `lesson_revision_id` in server mode and the legacy lookup only in fallback mode.

**Step 4 (T1): UI.**

- `WeekCard`.
- `BandRoadmap`: notice, error, metric `supportingFigure`, ledger.
- `WeekDetailPage`: state resolution before any resources, content or task request; ViewState `paused`, `unavailable`, `state-error`; `locked` anchor kinds; `empty` after re-check; Next footer.
- `ContextStatusStrip`.
- `WeekCard.css` states and forced colors; icons.

**Step 5 (T1): mid-session hold** per D-5c2-3 (conditional B). `useLessonTask` maps a thrown `LessonTaskDataError` whose cause code is 42501 to a re-check through the hook and a new status line. N1 invariant. No change to the keepalive request path. `lessonTaskCopy` keys with ES drafts. Also covers the `sessionStorage` stash module (4.14: key, writes, clears), the restore banner with Restore and Discard, "Copy my answers", the `applyFlushResult` clear, the leave-guard "Leave without saving" suppress-and-clear (keeping `lessonTaskCopy.ts:93-96` true), the sign-out clear, and the dirty-form notice for task and quiz (4.15).

**Step 6 (T1): read-only audit script** `scripts/audit/issue198-5c2-roadmap-state-parity.sql` (`begin transaction read only; ... rollback;`):

- Q1: distribution of `access_state` per band for active enrollments (counts only).
- Q2: parity. Rows where the RPC's open derivation differs from the 5c-1 helper predicate inlined with `se.user_id` (must be 0).
- Q3: count of active enrollments with `has_any_entitlement_row = false`.

A vitest check confirms it runs read-only locally and contains no DML or DDL outside comments (precedent `scripts/audit/issue176-completion-audit.sql` plus `issue176-audit-script.test.ts`).

**Step 7 (T1): update existing suites without weakening:** `BandRoadmap` tests, `WeekCard` tests, `WeekDetailPage` tests, `roadmap.ts` tests if consumers change, `ContextStatusStrip` tests, `wp10-roadmap-week-flashcards`, the issue210 spec if affected, the `authenticatedFunctionExecuteGrants` allowlist. Remove `computeWeekRoadmap`/`weekUnlock` only if no consumer remains (`FeedbackForm` keeps its own helper), with reasons in the PR body (D-5c2-10).

**Step 8 (T1): full gates:** `npm ci`, type-check, lint with 0 errors, `verify:build`, full vitest on a fresh reset (no new failures versus baseline), targeted e2e (the new spec, wp10, wp11, issue210, issue198 suites), and the no-native-dialog scan. Then Verifier, CODE_REVIEW, Browser Validator. Open the PR against `main`, body "Refs #198", listing the hosted steps, stating that no hosted action was taken, and listing every ES string as DRAFT pending Lizbeth.

Owners: T1 first-line, T2 per fleet escalation; Verifier; Browser Validator; `codex-judge-runner` (CODE_REVIEW); Scribe for evidence records; the user runs every hosted step.

## 7. Interfaces and data

- New function `public.get_student_roadmap_week_states(uuid) -> jsonb`, EXECUTE for `authenticated` and `service_role`, revoked from `public` and `anon`. JSON contract as in 4.2.
- No table, column, policy, trigger, index or data change.
- Client contracts: `RoadmapWeekState` gains `'paused' | 'unavailable'`; `iconKey` gains `'icon-pause' | 'icon-unavailable'`; `ViewState` gains `paused`, `unavailable`, `state-error`; the `useLessonTask` save state gains a paused or neutral access-denied status (D-5c2-3).
- Client storage: a `sessionStorage` entry per (user id, enrollment id, lesson revision id, base revision) holding unsaved task answers (4.14). No `localStorage`, no server write.
- Compatibility: the old frontend ignores the new function, so applying the migration first is safe. If the new frontend is published before the migration, the capability gate (4.13) renders today's roadmap and week detail until the function exists, then switches to server mode in place. The order "migration before publish" stays recommended but is no longer load-bearing.
- Hosted: migration apply needs separate approval. Netlify publish needs separate approval. Edge: none.

## 8. Audit script

See Step 6. The user runs it read-only on hosted at H3, after the migration is applied. The Verifier checks the script against Step 6. Formatting may change, logic may not.

## 9. Acceptance and validation

### 9.1 SQL RED tests

File `src/__tests__/issue198RoadmapWeekStatesSql.test.ts` (`pg` Client, `asStudent`, `issue198Fixtures`, loopback, per-test rollback).

| Id | Case | Expected |
|---|---|---|
| W1 | Held | `paused` |
| W2 | Revoked | `paused`; payload identical in shape to W1 (no field distinguishes) |
| W3 | Cohort `starts_at` now()+14d | Week 1 `locked` with `unlock_at` = `starts_at` + offset; `anchor_kind` cohort |
| W4 | Late joiner (cohort started 60 days ago, enrolled now) | Offset-14 week `open` |
| W5 | Cadence: entitlement `unlock_at` moved later (labelled superuser simulation if no real reconciliation path reaches a legacy version) | `locked` with the new date |
| W6 | Released with a future `unlock_at` (labelled superuser simulation; `set_lesson_access_state` sets `unlock_at = now()`), plus a real `set_lesson_access_state` release | `open` |
| W7 | Materialized enrollment with one week's row absent | `unavailable` |
| W8 | Zero-row enrollment (prerequisite-unmet or unpublished-version fixture, the only zero-row states after 5c-1) | `has_any_entitlement_row` false |
| W9 | Foreign enrollment, preserved enrollment, inactive account, password-change flag; anon EXECUTE | NULL for each; anon denied |
| W10 | Parity: for every fixture week | `access_state = 'open'` equals `visible(db, user, lesson).row` and `.object` from `issue198Fixtures` |
| W11 | Multi-revision: (a) #202 revision_no 2 preserved link; (b) a version where two revisions of one legacy lesson are mapped, one held and one open (labelled superuser simulation) | Parity holds; RLS parity, RPC `access_state`, RPC `lesson_revision_id` and the revision the week page's task machine loads all agree; selection follows open, then lowest `cvl.position`, then lowest `revision_no` |
| W12 | `task_work_saved` for a held week with a draft row, and without | true; false |
| W13 | Payload key allowlist | No content, paths, URLs, status, text or threshold |
| W14 | Catalog | `prosecdef` true, `proconfig` `search_path=public`, `provolatile` `'s'`, `has_function_privilege` anon false and authenticated true; #222 allowlist updated |
| W15 | Audit script | Read-only; Q2 parity = 0 on the seeded stack |

### 9.2 Unit and component RED tests (vitest and RTL)

- Mapper precedence pairs; J-01-36 current; released-future = open and locked-past = locked under fake timers; malformed row fails closed.
- `WeekCard` paused, unavailable and completed-then-paused (no Open, "View week N", no chip, aria-hidden glyph, disclosure keyboard).
- `WeekDetailPage` deep link to paused or unavailable makes no `fetchResourcesForLesson`, signing or `getLessonTask` call; empty only after re-check; `state-error`.
- `BandRoadmap` unmaterialized notice and error gating.
- `ContextStatusStrip` agreement.
- Copy module: every key has `en` and `es`; every `es` entry carries the DRAFT marker.
- `useLessonTask`: 42501 then re-check then paused line only when paused, neutral otherwise; form and text stay mounted (N1); a bare 42501 is never paused.
- Capability gate: PGRST202 leads to fallback; a 500 or another 404 leads to fail closed; a missing function after server data was seen leads to fail closed; focus re-probe switches to server mode.
- Stash: write, clear and suppress paths (success, `applyFlushResult` equality, Discard, sign-out, leave-guard "Leave without saving"); banner only on a difference from the server draft; a storage throw selects the storage-unavailable variant; different-user entries are not offered (D-5c2-11).
- Mapper: every completed x access combination (4.16), including fixture student F (a completed week moved to locked and one to unavailable, labelled superuser simulations).
- Freshness: cache keyed by user; identity change discards late responses; throttle; far-future `unlock_at` clamp; boundary refetch with fake timers; the client never flips state itself; no announcement on first load or a no-op.

### 9.3 e2e RED spec

File `src/__tests__/e2e/issue198-5c2-roadmap-week-states.spec.ts` (Playwright; Chromium for all, WebKit additionally for the mid-session hold and expired-session journeys, following issue210).

- Viewports 1440x900, 390x844, 320x568, and `forcedColors: 'active'` at 1440x900 and 320x568.
- A failing `page.on('dialog')` listener on every page.
- Disposable fixtures through a loopback-guarded `pg` client created per test and removed in `afterEach`: held and revoked via owner `set_lesson_access_state`; released-early; cadence-delayed; no-row week; zero-resource open week; future-cohort student; completed-then-paused; unmaterialized enrollment; enrollment-completed with a later future week and a held week; one paused week with a draft row and one without. Revision 1 adds fixture F (a student with a completed week moved to locked and one to unavailable, labelled superuser simulations), fixture G (a task form for freshness and preservation journeys) and fixture H (a second user for the same-tab journey).
- State RPC failure via `page.route` on `/rest/v1/rpc/get_student_roadmap_week_states` returning 500, and a route-intercepted PGRST202 / 404 for the capability gate.

| Id | Journey |
|---|---|
| J1 | Held and revoked produce identical paused cards (no Open, stamp, OPENS line or chip) |
| J2 | "Why paused?" keyboard behavior |
| J3 | Date-locked and cadence-delayed server dates |
| J4 | Released-early week is open |
| J5 | Unavailable card |
| J6 | Empty text only on the open zero-resource week; a hold during load shows paused via re-check |
| J7 | Deep links to held, revoked, delayed and unavailable weeks; the network log shows no resources, signed-URL, content or `get_lesson_task` call |
| J8 | Saved-work line presence and absence |
| J9 | Cohort wording pre-start and neutral after start |
| J10 | Completed-then-paused card and panel |
| J11 | Unmaterialized notice, metrics and ledger hidden, deep link unavailable |
| J12 | Enrollment-completed student sees server states and the band "Completed on" line |
| J13 | Fail closed and Try again recovery |
| J14 | Current metric, `supportingFigure`, ledger and `ContextStatusStrip` agree |
| J15 | Mobile Next footer for a paused or unavailable next week (390) |
| J16 | Mid-session hold: paused save status, no retry; release shows the draft again; the server draft row is unchanged by the hold |
| J17 | Expired session: neutral line with Try again, never paused copy; leave-guard Modal keyboard and focus; field text persists |
| J18 | ES card face at 1440 and 320 (no stamp or OPENS overlap or clipping, N4), plus the restore banner and the failed-save lines at 320 with no overflow or clipping |
| J19 | ES journeys 1, 5, 11, 13 at 390 |
| J20 | Deploy skew: run the new frontend against the previous schema (migrate the mirror without the 5c-2 migration, or drop the function), and also a route-intercepted PGRST202 404. Expected: today's roadmap and week detail with no alert or crash. A 500 still shows the alert. Adding the function, then focusing the page, switches to server mode in place |
| J21 | Real session loss mid-draft (token revoked server-side or signed out from another tab), then re-sign-in and reopen leads to Restore. Variants: hard reload; Discard; a newer server revision; a guard "Leave without saving" leaves no stash and no banner; normal navigation with a pending debounce shows no banner on return (G1); the sign-in-and-reopen wording is asserted. Storage inspection shows only `sessionStorage` holds the entry |
| J22 | "Copy my answers": success, clipboard denied, and storage forced to throw (storage-unavailable variants) |
| J23 | Completed-with-access cards and panels (fixture F): completed then paused, locked, unavailable; `data-week-access` never distinguishes held from revoked |
| J24 | Freshness: hold while on `/roadmap` then focus gives an in-place update with one announcement; hold with a clean detail page; hold with a dirty task form (text kept) and with dirty quiz answers (kept); release resumes; an unlock boundary passes and the card opens without reload; nothing is announced on first load |
| J25 | A different user on the same tab sees no banner and no cached state, and the network log shows a fresh RPC call |

Checks at every viewport: no horizontal scroll at 320; icon plus word per state; forced colors keep the border (`ButtonText`), icon and text; tab order only real controls with visible focus; the state word in the accessible name and glyphs not announced; no new animation. Each RED failure is recorded before implementation and GREEN after.

### 9.4 Gates

Step 8 gates; Verifier PASS; CODE_REVIEW per section 5; Browser Validator PASS.

## 10. Browser UI dialog policy and browser validation

### 10.1 Dialog policy

Required. No `alert`, `confirm`, `prompt`, `window.alert`/`window.confirm`/`window.prompt`, or `beforeunload`. Only the app-owned accessible Modal (`src/components/Modal.tsx`, the existing leave guard) and inline content. This change adds no modal. Deterministic scan, expecting zero product hits:

```text
rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"
```

A failing `page.on('dialog')` listener runs in every journey. Modal keyboard and focus verification applies to the existing leave-guard Modal in J17 (Escape, X and backdrop act as Stay; focus returns to the trigger).

### 10.2 `browser_ui_validation`

- Mirror: the port-shifted untracked mirror pattern of `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` (API 64321, DB 64322, studio 64323; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`). Copy the PR files per file, never `robocopy /MIR`; never commit the mirror.
- Launch and readiness:

```text
npx supabase start
npx supabase db reset
docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish   (first request may 502)
npx vite --host 127.0.0.1 --port 5180 --strictPort
```

  Ready when `http://127.0.0.1:5180` serves sign-in.
- Test environment: `SUPABASE_API_URL=http://127.0.0.1:64321`, `SUPABASE_DB_PORT=64322`, `SUPABASE_SERVICE_ROLE_KEY=<from npx supabase status>`, `E2E_BASE_URL=http://127.0.0.1:5180`; then `npx playwright test src/__tests__/e2e/issue198-5c2-roadmap-week-states.spec.ts` with one worker.
- Base URL: `http://127.0.0.1:5180`.
- Fixture and reset: `db reset` plus seed (`owner@test.local`, `student1@test.local`, `fullaccess@test.local`; password "password"). Per-journey disposable fixtures through a loopback-guarded `pg` client, removed in `afterEach`. Language reset to English after ES journeys.
- Journeys J1 to J25 and the checks in 9.3, with fixtures F, G and H and the PGRST202 interception added by Revision 1. Viewports 1440x900, 390x844, 320x568; forced colors at 1440x900 and 320x568.
- Evidence: screenshots per state, viewport and language, plus network logs, under `browser-validation-artifacts/198-5c2/`.

## 11. Risks and rollback

| Id | Risk | Containment |
|---|---|---|
| R5C2-1 | New definer RPC leaks data | Boolean, enum and timestamp fields only; key allowlist test; `auth.uid()`-bound; NULL fail-closed; EXECUTE for `authenticated` only; CODE_REVIEW R5C2-AUTHZ and R5C2-NOLEAK |
| R5C2-2 | UI and RLS disagree (state says open and RLS denies, or the reverse) | W10 and W11 parity tests; hosted audit Q2 = 0; race re-check before empty text |
| R5C2-3 | Frontend published before the migration | The capability gate (4.13) renders today's roadmap and week detail (no outage); RLS from 5c-1 remains the gate. Hosted order "migration before publish" stays recommended; Netlify lock check; rollback by instant republish of the previous deploy |
| R5C2-4 | Mid-session hold or session loss loses typed text | No new server write path; keepalive request path untouched; N1 invariant; text-preserving recovery (4.14); J16, J17, J21; a hold never deletes the server draft |
| R5C2-5 | Student confusion or alarm | Merged calm paused copy aligned with `/learn`; ES drafts reviewed by Lizbeth before publish (D-5c2-5) |
| R5C2-6 | Regressions in existing roadmap tests and flows (J-01-36, flashcards, task chips) | Suites updated with reasons, never weakened; wp10, wp11, issue210 e2e |
| R5C2-7 | Performance: one extra RPC per enrollment | A single call replaces `getLessonProgressForEnrollment` in `BandRoadmap` where possible; EXPLAIN on the seeded stack under 50 ms |
| R5C2-8 | 5c-1 not yet applied on hosted | The RPC is still correct (it reads entitlements) but RLS is still legacy, so the UI may show paused while resources would be readable (stricter UI, no leak). Sequence after 5c-1 H3/H4 (D-5c2-9) |
| R5C2-9 | Device-stored drafts on shared computers | `sessionStorage` only (cleared when the tab closes), same-user scope with the user id in key and value, clears on success, Discard, sign-out and "Leave without saving", deletion of another user's entries on a different sign-in (D-5c2-11); J21, J25. Quiz answers stay memory-only (known limit) |
| R5C2-10 | Stale cache shows outdated state | Case 14 contract (revalidate on mount, focus and visibility; throttle; 15 minute staleness counts as failed; clamped boundary timer); RLS still enforces access; J24 |

Rollback: Netlify instant rollback to the recorded previous deploy (frontend). Then, optionally and under a separate approval, apply the rollback file to drop the function. No data rollback is needed because no data is written.

## 12. Hosted rollout order

Each step is a separate explicit approval. The user runs all hosted actions.

| Step | Action |
|---|---|
| H0 | Preconditions: 5c-1 hosted H3/H4 complete (migrations `202610130001` and `202610130002` applied and verified). Check whether Netlify production auto-publish is locked (Unknown) and record it. The result informs the order but is no longer load-bearing, because the capability gate (4.13) covers a frontend published before the migration |
| H1 | The user merges PR 5c-2. H2 no longer has to run before the merge; "migration before publish" stays recommended (D-5c2-9). If auto-publish is not locked, a merge may publish before H2, and students then see today's roadmap until H2 completes |
| H2 | Read-only check that hosted migration history contains `202610130001` and `202610130002`; then `supabase db push` applies only the new 5c-2 migration (approval required) |
| H3 | Post-apply read-only verification: `has_function_privilege('anon', fn, 'execute')` false and `'authenticated'` true; `prosecdef` true; run `scripts/audit/issue198-5c2-roadmap-state-parity.sql` read-only. Q2 parity must be 0; record the Q1 and Q3 counts (the owner reviews how many students will now see paused, locked or unavailable weeks) |
| H4 | Lizbeth's approval of the ES strings recorded (or the user's explicit waiver) before publishing |
| H5 | Record the current production deploy ID, then "Publish deploy" of the 5c-2 build (approval required) |
| H6 | Production smoke with a test student if one exists (Unknown) or owner observation; Scribe evidence record `docs/evidence/lizbeth-spanish-prod-issue198-5c2-<date>.md`; then the 5c-1/5c-2 limitation is closed on #198 |

## 13. Decisions

Each requires an explicit user answer. None carries a silent default.

| Id | Decision | Recommendation |
|---|---|---|
| D-5c2-1 | Single source of truth: a new additive read-only RPC `get_student_roadmap_week_states`, or reuse `get_student_learn_course` through Edge (no legacy week mapping, client clock, Edge hop), or change `get_enrollment_lesson_completion` (inner-join shape, shared completion layer) | New RPC |
| D-5c2-2 | Held and revoked: merged into one "Paused by your instructor" state, matching `/learn` constraint 2 and the issue5 Phase 5 planning default, or a distinct "Not available" for revoked (needs a distinct server value; diverges from `/learn`). The planning job listed "unavailable (revoked)" as its own case; the merge is the recommendation, not a silent default | Merged |
| D-5c2-3 | Mid-session hold: conditional option B (re-check, paused line only when paused) or option A (no change, documented) | Conditional B |
| D-5c2-4 | Localization scope: full `WeekCard`, touched detail panels, `BandRoadmap` labels and notices, Next footer, language-aware dates, or new strings only (mixed-language cards in ES) | Full scope |
| D-5c2-5 | Spanish approval: Lizbeth approves all ES drafts before the H5 publish. Her calls include "instructor" versus "instructora" (U2) and the ES wording for the existing band "Completed on <date>" line (U5) | Lizbeth approves before H5 |
| D-5c2-6 | Show "Your saved work is kept." on paused weeks when `task_work_saved` is true | Yes |
| D-5c2-7 | Enrollment "Completed on <date>" line beside a partial "Weeks complete" figure (reviewer N3): keep the line and record the known limit, or show it only when all weeks are complete | Keep and record the limit |
| D-5c2-8 | `FeedbackForm` week list (legacy date rule): out of scope, open a follow-up issue | Follow-up issue |
| D-5c2-9 | Hosted order: after 5c-1 H3/H4; migration live before frontend publish; confirm the Netlify lock first | As stated |
| D-5c2-10 | Retire client unlock math on roadmap surfaces; delete `lib/roadmap.ts`/`weekUnlock.ts` code only if no consumer remains. The Case 12 fallback is a consumer, so the code stays while the gate exists | As stated |
| D-5c2-11 | Delete another user's `sessionStorage` task entries when a different user signs in on the same tab (U7) | Delete; privacy over recovery |
| D-5c2-12 | Freshness numbers: revalidation throttle about 5 s, staleness about 15 minutes, boundary timer clamp 1 hour (U8) | As stated |
| D-5c2-13 | Optional roadmap card line "Unsaved answers on this device" (ES DRAFT: "Respuestas sin guardar en este dispositivo") (U9) | Include only if approved; default off |
| D-5c2-14 | Capability fallback only before any server data has been seen by the hook instance (U10) | Yes |

## 14. Assumptions, unknowns and approvals

Safe assumptions:

- Legacy lessons have no prerequisites (Inference, tested).
- A hold never deletes `lesson_task_submissions` (Inference; T-HOLD and J16).
- One active enrollment per band per student in practice (Inference). The RPC is per enrollment and the 5c-1 helper is per user, so W10 parity uses single-enrollment fixtures.

Unknowns:

- The Netlify auto-publish lock state.
- Whether a production test student exists.
- The hosted distribution of paused, locked and unavailable weeks (answered by H3 Q1).

Research: none. Researcher was not invoked. Every decision is grounded in local code, migrations and approved plans, and no current external fact would change the plan.

Approvals required:

1. Explicit approval of this plan.
2. Answers to D-5c2-1 to D-5c2-14.
3. Separate approvals for each hosted step H1 to H5 and any rollback.
4. Lizbeth's ES approval (or the user's explicit waiver).
5. No commit to `main`, merge, deploy or live Codex call without explicit instruction.

## 15. Stale-plan conditions

This plan is stale and must be re-planned (or re-verified at Step 0) if any of these occur:

- Any Step 0 trigger changes.
- 5c-1 is rolled back or altered.
- A new enrollment path or access state is added.
- The `/learn` merge rule changes.
- The #210 leave-flush is redesigned.
- `App.tsx` session-loss handling changes.
- The `lessonTaskCopy` leave-guard strings (`lessonTaskCopy.ts:93-96`) change.
- The `useLessonQuiz` memory-only policy (`useLessonQuiz.tsx:34`) changes.

## 16. Engineering mode and downstream owner

- Engineering mode: standard (T1 first-line; two counted T1 gate failures escalate to T2; two counted T2 gate failures block for user review). No extreme-advisory team. Team authorization: not applicable.
- Downstream owner: engineering-fleet (PR 5c-2); Scribe for evidence records; the orchestrator relays hosted steps to the user.

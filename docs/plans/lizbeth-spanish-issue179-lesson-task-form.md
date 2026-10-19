# Lizbeth Spanish: Issue #179 Lesson Task Form (Students Submit Translation Tasks and Practice; Owner Reviews)

Status: APPROVED by the user on 2026-10-04. Cleared for engineering per this plan.

Plan ID: `lizbeth-spanish-issue179-lesson-task-form`. Task ID: `lizbeth-spanish-issue179-lesson-task-form`. Route: engineering.

Target repository: `lebobo88/lizbeth-spanish` (local family under `H:\CommandCenter\orchestrator\lizbeth_spanish*`). Build on NEW branches from `origin/main` in fresh worktrees, one branch and one pull request per phase (PR A, PR B, PR C). `origin/main` includes #171, #173, #176, #177, #178.

**Sequencing (revision 1).** #174 (PR #195, handout/resources on `/learn`, migration `202610040002`) is about to merge. PR A branches from `origin/main` only AFTER #174 merges. PR B and PR C each branch from `main` after their predecessor merges. Every #179 migration timestamp must sort after `202610040002` (use `2026100400xx` or later), re-checked against `main` at each PR's Step 0.

Planner's read-only reference checkout is `H:\CommandCenter\orchestrator\lizbeth_spanish-174` (branch `feat/issue-174-student-handout-links`, HEAD equals `origin/main` 20664c5, plus uncommitted in-progress #174 work). Planner evidence came from that worktree; after #174 merges, Step 0 re-verifies `LearnDetailPage` (materials block), `learnData`, and every line number. The main checkout `H:\CommandCenter\orchestrator\lizbeth_spanish` is stale (branch `release/fjds-course-management-20260915`; no `completionData.ts`) and must not be used as a base. All line numbers below come from the 174 checkout and must be re-verified in Step 0.

Audience: students (enrolled learners), Lizbeth (owner), engineering fleet (executor), and the user (approver).

GitHub reference: issue `lebobo88/lizbeth-spanish#179` (epic #172), "Lesson task form: students fill out and submit translation tasks and practice; owner reviews in progress tracking".

Evidence labels: **Observed** means read at file level in the 174 checkout by Planner. **Inference** is a conclusion drawn from observations. **Assumption** is taken as true until a runtime step verifies it. **Unknown** is not yet established.

## Plan revision 1 (PLAN_DUCK shadow, advisory)

`PLAN_DUCK` (Codex) ran in shadow/advisory mode on the first draft and returned REVISE. Planner verified each finding at file level in `H:\CommandCenter\orchestrator\lizbeth_spanish-174`. This revision was applied once, in place, and adds no scope beyond the dispositions below. The design handoff is unchanged (the XSS invariant and the cutover definition need no visual or UX change), so design review was not re-run. Judge call accounting: PLAN_DUCK used 1 of 4 (high-risk cap); CODE_REVIEW #1, CODE_REVIEW #2 and one optional VISUAL_REVIEW or repeat remain.

| ID | Disposition | Summary | Sections changed |
| --- | --- | --- | --- |
| J-179-PLAN-001 (major) | accepted | Every new internal or owner function (`resolve_lesson_task_template`, `review_lesson_task_submission`, `edit_lesson_task_review`, `lesson_completion_blockers`, `finalize_lesson_completion`) is SECURITY DEFINER with `set search_path = public`, `revoke all ... from public, anon, authenticated`, and `grant execute ... to service_role` only. Student RPCs call them internally. Live privilege tests and direct-invocation negative tests added. | 5, 6 (A4, A6, C4), 8 |
| J-179-PLAN-002 (major) | accepted | All completion-sync and materialization paths enumerated (F13). PR C adds the `completion_gate_settings` cutover marker and a precise grandfathering definition; `sync_enrollment_completions` and `sync_legacy_completion_to_entitlement` are gated; regression tests per path. "No submission" is no longer the grandfathering definition. | 3 (F13), 4 (J9, 4.13 invariant 5), 6 (A4, C1, C4), 8, 10 (R13), 12 (AD3) |
| J-179-PLAN-003 (major) | accepted | New engineering invariant 16 and acceptance check: all student responses, feedback, prompts, and answer keys render as escaped plain text nodes. Source scan for `dangerouslySetInnerHTML` in PR B and PR C, plus RTL and Playwright inert-payload tests. | 4 (4.13 invariant 16), 6 (B3, C4), 8, 10 (R14) |
| J-179-PLAN-004 (minor) | accepted | Activity-event contract: `set_lesson_completion` payload gains `bypassed_blockers` and `source`; `reset_lesson_completion` gains `p_actor_id` and records the acting owner; review and finalize events specified; tests assert exactly one correctly attributed event per successful action and none on failure. | 6 (A4, C1, C4), 8 |

Also applied in this revision (orchestrator instructions, no new finding ID):

- Sequencing after #174 (header), migration timestamp rule, and the reference-checkout note (header, Step 0, Section 11).
- D1 to D6 are relabeled "Recorded decisions (stated defaults; changeable before approval)" rather than open questions; Section 13 approvals updated. AD1 to AD7 remain adopted defaults.
- Risks R13 (grandfathering cutover boundary errors) and R14 (stored XSS via responses and feedback) added to Section 10.
- Judge route (Section 5) updated for the accounting above.

---

## 1. Outcome

Students fill out a template form per lesson: one translation item per phrase group plus the single practice activity. They save drafts, submit, receive owner feedback or a return for revision, and resubmit. The owner (Lizbeth) reviews submissions in an inbox and in progress tracking (dashboard attention reason, student detail, course-workspace roster).

Lesson completion now requires the student's existing "mark complete" action AND the task submitted AND owner-reviewed (and, after #180, quiz pass). Existing completions are grandfathered. Answers are removed from student-visible text and kept in owner-only keys as part of this item.

## 2. Scope and non-goals

**In scope (user decisions, final):**

- Both task types: `PhraseGroup.translationTask` per phrase group, and the single practice activity.
- Template form, drafts, return for revision then resubmit, owner feedback and optional score.
- In-app notifications only (derived indicators; no email, no realtime).
- Answers removed from student-visible text into owner-only keys as part of this item.
- Completion equals existing mark plus submitted plus reviewed (plus quiz pass from #180 through a defined extension point). Existing completions are grandfathered.
- Text responses only (no audio).
- Shared components rendered on BOTH student surfaces: Roadmap `WeekDetailPage` via `LessonContentView`, and `/learn`.

Specifically:

- (a) Data model, RLS, and security-definer RPCs.
- (b) Answer-key separation and content pipeline (generator, validation, seed migration, leak guards).
- (c) Owner Edge actions and owner UI (inbox, detail, dashboard attention reason, student-detail panel, workspace roster status, nav count).
- (d) Student shared form on Roadmap and a new `/learn` task route.
- (e) Completion integration with #176 RPCs.
- (f) Tests (SQL, RLS, RPC, Edge, unit, generator 78-coverage, Playwright at 390 and 1440).
- (g) Three reviewable PRs.

**Non-goals:**

- Quiz answers and the Q&A segment "Answer:" rendering (`LessonContentView.tsx` ~308-316; `lesson-content.json` "quiz"), and weekly-review-recap "**Answer:**" text in storage. Both are owned by #180 per `docs/plans/lizbeth-spanish-issue175-vocabulary-review-in-app.md` lines 40 and 405.
- Audio.
- Email or push notifications; realtime channels.
- Authored (non-legacy) course task templates, or an authoring UI for templates.
- Changing `get_student_learn_course` or legacy resources/storage RLS.
- Enforcing `completion_rule` 'manual' or 'quiz_pass' (observed unenforced in `record_lesson_completion`; #180 or follow-up).
- Showing model answers to students.
- Regenerating PDFs or PPTX (not needed, see F11).
- Any hosted or production write (separate user-gated steps).
- Commit, push, or PR creation unless authorized at execution time.

## 3. Repository findings (evidence)

All Observed unless labelled. Line numbers are from the 174 checkout.

- **F1. Completion foundations (#176).** `supabase/migrations/202610030001_issue176_single_completion_record.sql`. `enrollment_lesson_entitlements.completed_at` is the single completion record; `student_lesson_progress.completed_at` is a write-through mirror.
  - `record_lesson_progress(p_enrollment_id, p_lesson_id, p_action 'open'|'complete')` ~217-288 guards `auth.uid`, `user_requires_password_change`, `is_account_active`, own active enrollment, and the legacy date lock. On 'complete' it materializes if needed, resolves `v_rev` (`lesson_revisions.legacy_lesson_id`, order by `revision_no` limit 1), applies the canonical unlock rule (`manual_release_state` not held/revoked AND (released OR `unlock_at <= now()`)), calls `sync_legacy_completion_to_entitlement`, then UNCONDITIONALLY inserts progress with `completed_at = now()` (~272-278), then `grant_newly_eligible_dependents` and `recalculate_progress_completion`.
  - `record_lesson_completion(p_enrollment_id, p_lesson_revision_id)` ~294-337 (used by `/learn` `markLessonComplete`, `src/services/learnData.ts:139-151`) has the same guards, sets `completed_at`, mirrors, grants dependents, and calls `recalculate_course_version_completion`.
  - `set_lesson_completion` (owner, service_role) ~339-425 and `reset_lesson_completion` ~431-478 (service_role; via `admin-student-operations` `reset-lesson-completion`).
  - `sync_enrollment_completions` ~134-182 union-syncs progress and entitlements, set-only (used by resume and lazy materialization).
  - `get_enrollment_lesson_completion` ~487-519 returns `lesson_revision_id`, `legacy_lesson_id`, and `completed_at` per lesson for the own active enrollment (fail-closed NULL).
  - Rollback precedent: `supabase/rollbacks/issue176_single_completion_record_rollback.sql`. Latest migration on main: `202610040001_issue177_site_content.sql`.
- **F2. `completion_rule`.** `supabase/migrations/202608280003_issue5_course_authoring.sql:192`: `enrollment_lesson_entitlements.completion_rule text default 'view' check in ('view','quiz_pass','manual')`. Returned by `get_student_learn_course` (`202608310002:125`). `LearnDetailPage.tsx:64` maps non-'view' to 'unlocked-pending-quiz' ("No action needed here."). Neither completion RPC checks `completion_rule`. A single enum cannot express AND-combinations (task plus quiz).
- **F3. Task text today.** `src/content/lessonContent.ts` `PhraseGroup.translationTask` string (~31-39), `PracticeActivity {title, summary, durationMinutes}` (~46-50), `RHYTHM_SEGMENTS` 30/10/20 (~63-67). `src/components/LessonContentView.tsx` renders the "Translation task" chunk (~278-282) and practice title plus summary (~320-325), display-only. `lesson-content.json` (`supabase/storage-seed/lesson-assets/<band>/week-NN/`) is a student-readable `lesson_content` resource (gated by `students_read_unlocked_resources` and `students_read_unlocked_lesson_assets`) generated by `scripts/generate-lesson-content-json.ts` from `content-source/<band>WeekNN.ts` (outside `src`; not bundled; G13.2).
- **F4. Answers embedded.** "**Answer:**" occurs in 61 of 78 content-source modules (24 advanced, 11 beginner [16-26], 26 intermediate), ~224 occurrences, inside `translationTask` strings (for example `content-source/beginnerWeek20.ts:23` `'... "My sister is more intelligent than my cousin (f.)." **Answer:** Mi hermana es más inteligente que\nmi prima.'`), and in the generated student-readable `lesson-content.json`. Additional unmarked inline answers exist, for example beginner week-01 `lesson-content.json:11` "Buenos días → Good morning; ..." and `:52` "Nombre → Name; ...". "→" occurs 22 times in 11 content-source files (advanced 01, 02, 08; beginner 01, 03, 04, 14, 16; intermediate 08, 10, 14). **Inference:** some of these are answers given inside prompts; full extent is **Unknown** until audited. The curriculum source `curriculum/lessons/<band>-week-NN/phrases-and-qa.md` also holds the same translation tasks with **Answer:** (instructor source; not uploaded to storage). Storage-seed per week holds only `instructor.pptx`, `student-handout.pdf`, `weekly-review-recap.md`, `flashcards.md`, `flashcards.yaml`, `lesson-content.json`.
- **F5. Practice task prompt (#178).** All 78 `curriculum/lessons/*/practice-activity.md` have "## Task prompt" with eight fields in fixed order: Scenario, Your role(s), What to write, Length and format, Register and dialect, Use these phrases, Success checklist (3-6 bullets citing CD1-CD5), Model answer. Reference parser `src/__tests__/helpers/parsePracticeActivity.ts` (`TASK_PROMPT_FIELDS`, `parsePracticeActivity`) is "the REFERENCE CONTRACT that issue #179 templates". "What to write" uses numbered parts, for example beginner-week-01: "(1) Three informal exchanges ... (2) One formal usted exchange ... (3) An English translation ...". #178 decision 3: model answers stay in markdown; showing them to students was deferred to #179 (this plan: owner-only). The `lesson-content.json` practice shape is unchanged.
- **F6. Seed order.** `supabase/seed.sql` inserts the 78 lessons (~123-168) AFTER migrations run locally; hosted lessons already exist. **Inference:** a template-seed migration cannot FK to lessons or lesson_revisions locally. Templates must be keyed by a stable content key (for example 'beginner-week-01' from `lower(bands.name)` plus `week_number`) and resolved at read time via `lesson_revisions.legacy_lesson_id` to `lessons(band_id, week_number)` to `bands.name`. Verify band names in Step 0.
- **F7. Student surfaces.** `src/pages/WeekDetailPage.tsx` renders `LessonContentView` (~1013-1028) with one page-level completion machine (`useLessonCompletion`) shared with the mobile footer (`buttonTier` primary ~1436); `lessonId` is the legacy lesson id of the `lesson_content` resource. `src/pages/LearnDetailPage.tsx` (`/learn/:enrollmentId`) shows lesson CARDS only (no content view); `MarkCompleteControl` is an inline two-step (binding no-Modal); WP-G one-primary tie-break among 'unlocked-incomplete' rows (~566-600 in 174 numbering); `handleCompleted` fabricates `completed_at` (`result.completed_at ?? new Date().toISOString()`, ~246/258) and increments `completed_count`. `src/lib/useLessonCompletion.ts` `record()` discards `completed_at` and `saveCompletion` always sets completed and `justCompleted` (Stamp). `src/components/LessonCompletionControl.tsx` desktop is a plain `<button>` (no tier). `src/services/adminStudentData.ts` `recordLessonProgress` returns `{completed_at}`; `getLessonProgress` reads `completionData` `byLegacyLessonId`.
- **F8. Owner patterns.** `supabase/functions/admin-student-operations/index.ts`: owner-gated dispatch (~178-246), `handleFeedbackInbox`/Detail (~648-676; page size 25, newest first, `listAllAuthUsers` for emails), `handleDashboard` (~712-768; `attention_reasons` 'inactive', 'progress_lag'), `handleGetStudentDetail` (~790-867), `fetchEntitlementCompletions` (~693-710), `handleWipeSave` (~536); `clear-password-change` is the only student action. `supabase/functions/course-authoring/index.ts`: student actions before the owner gate via RLS-scoped caller (~35-58); owner gate plus service-role db (~59-61); `get_version` hydrates `lesson-content.json` for the owner editor (~126-147); `list_lesson_entitlements` read (`src/services/courseAuthoring.ts:175` `RosterLesson`). UI: `src/pages/OwnerFeedbackPage.tsx`, `OwnerDashboardPage.tsx`, `AdminStudentsPage.tsx`, `CourseWorkspacePage.tsx`; `src/components/Modal.tsx` (role=dialog, aria-modal, focus trap, focus return, `suppressDismiss`); `src/components/FeedbackForm.tsx` plus `src/context/SignOutGuardContext.tsx` (single sync guard slot); `src/components/ui/Field.tsx` (~96-97 aria-describedby override hazard). `feedback_submissions` RLS precedent: `202608280001_issue3_feedback_inbox.sql`, `202608280002_issue3_feedback_inbox_hardening.sql`.
- **F9. No notification system and routing.** No "notification" in `src` or `supabase`. `src/hooks/useRoute.ts` `LEARN_DETAIL_PATTERN` is `^/learn/([^/]+)$`; `App.tsx` `knownAdminRoute` (~82-87).
- **F10. Leak guards.** `scripts/check-no-lesson-content-leak.js` (dist scan for 78 week-title fingerprints; run by `npm run verify:build`). `package.json` scripts: `type-check`, `lint`, `test` (vitest), `verify:build`, `check:practice-complete`, `check:asset-content-types`.
- **F11. PPTX/PDF parity.** Observed in nested `tools/lesson-generation/lesson_generator.py` (main checkout only, untracked nested repo): PPTX slides are title, vocabulary, practice, review; PDF sections are title, vocabulary, flashcards, review. **Inference:** neither carries translation tasks or the practice model answer, so no regeneration is needed. The review sections may carry recap answers (#180). Verify by text extraction in PR A (report-only check).
- **F12. Design-relevant.** `src/lib/weekDetailBreakpoint.ts` `WEEK_DETAIL_BREAKPOINT_REM` 56.24rem; design system `design/field-journal/`; `scripts/lib/tokenDeprecationRegistry.ts`.
- **F13. Completion-sync and materialization paths** (Observed, 174 checkout equal to `origin/main` 20664c5; verified by Planner at file level).
  - `sync_enrollment_completions` (`202610030001:134-182`; service_role only) is called by the `record_lesson_progress` lazy path (`:247-248`), `resume_band_enrollment` (`:609`), the one-time backfill migration `202610030002_issue176_band_enrollment_backfill.sql` (`:86-89`), and `supabase/seed.sql` (`:520` materialize, `:535` sync).
  - `sync_legacy_completion_to_entitlement` (`:107-128`; service_role only) is called only by `record_lesson_progress` (`:269`).
  - `materialize_enrollment_entitlements` (latest definition `202608300001_issue5_phase2_cadence_sql_core.sql:50`; grants `202608280003:538` service_role) is called by assign, resume, and cohort-invite paths (`202608300005:85,143`; `202610030001:114,247,583,607`).
  - **Inference:** materialization inserts or updates unlock data and does not set `completed_at`. T1 must confirm this in PR C Step 0 and add a test.
  - Precedent for function privilege lockdown: `202610030001` lines 127-128 and 181-182; privilege test pattern in `src/__tests__/issue176-completion-foundations-sql.test.ts` ~541-547.
  - Precedent for owner-event attribution: `set_lesson_completion` writes `lesson_completion_set` with actor `p_owner_id` (`:403-414`); `reset_lesson_completion` attributes its event to the course owner looked up from the version (`v_owner`, `:459-475`), not the acting owner.

Research evidence: none. Research not needed: all decisions are grounded in local code, migrations, and prior approved plans (#174, #175, #176, #178).

## 4. Design route and handoff

DESIGN_ROUTE profile standard. Reasons: new multi-state student form on two surfaces, new owner review surfaces, changed completion flow. Agents: design-director (Sonnet), ux-architect, visual-system-designer, independent design-reviewer (Sonnet). Prototype forbidden. Model tier sonnet. `existing_system_mode`: extend.

Design review: DESIGN_REVIEW_RESULT verdict PASS on revision 1. The first pass was NEEDS_REVISION with findings DR-1 to DR-12 (high: DR-1 submission key and Roadmap eligibility, DR-2 completion-control deltas versus desktop non-regression, DR-3 mobile footer reflow); all resolved in revision 1.

Engineering notes carried from the reviewer into the work and Verifier gates:

- **EN-1.** Clear the unseen marker via a separate idempotent call when the feedback card is mounted and visible, not as a side effect of the load call.
- **EN-2.** `WeekDetailPage` obtains the legacy-to-revision map from `getEnrollmentCompletion` and passes `markRecordedAt` to `useLessonCompletion` without re-firing 'open' (`announcedOpenFor` guard).
- **EN-3.** The `WeekCard` chip joins summaries via the same map with one batched call per enrollment (no N+1).
- **EN-4.** Navigation guard is a registered pre-navigation guard in `useRoute` `navigate()` plus an async-aware extension of `SignOutGuardContext` that keeps `FeedbackForm`'s sync guard working (keep the `/feedback` sign-out test).
- **EN-5.** Run `contrast_check` on the over-limit counter status-error pair.
- **EN-6.** Textarea `aria-describedby` references the visible counter, not the hidden live span.
- **EN-7.** Error-summary links focus the field only after the segment panel is shown (next frame or layout effect).

Remaining design limits: static review only. Accepted limits: Back/Forward/unmount may lose up to the 2 s debounce window; no primary on mobile Cards/Files tabs while a task is actionable; quiz answers stay student-visible until #180.

### Design handoff (reviewed, revision 1)

Task ID `lizbeth-spanish-issue179-lesson-task-form`. Profile standard. Revision 1 of 1 resolves reviewer findings DR-1 to DR-12 and planner inputs P1 to P6. Motion and asset spec: not applicable (no new imagery and no animation; the existing Stamp is triggered only by a real in-session completion save, as today). Prose below is condensed; every journey, state, copy string, invariant, permitted variation, validation journey, and deterministic check is preserved.

#### 4.1 Selected direction

"Field Journal worksheet insert", mode EXTEND. The student form reads as a ruled worksheet page tipped into the existing reading sheet.

- Prompts use printed body type. Response areas are bounded inserts on ruled paper.
- Teacher feedback uses the shipped index-card device (B.06).
- Every status is a glyph plus word chip, never color alone.
- The owner-only reference is an "answer-key sheet": chrome-paper ground, brass edge rule, and the label "Owner only: never shown to students".
- Students get calm, roomy density because the writing space is the point. The owner gets scan-first density.
- No new tokens, typefaces, radii, or shadows.

#### 4.2 Design brief

- **Goal.** Students answer one translation item per phrase group plus one practice item per lesson. They save drafts, submit, and read teacher feedback or a return for revision. Lesson completion needs three things: the student's "Mark this lesson complete", a submitted task, and owner review. The owner reviews, returns, or marks reviewed from an inbox.
- **Shared component rule.** Item fieldset, task bar, status chip, feedback card, and accent strip are each built once. The Roadmap lesson page and the new `/learn` task route both consume them.
- **Fixed user decisions.** Both task types; text only; drafts; return with feedback; mark reviewed with feedback and an optional score; in-app notification only; answers never in student-visible text; completion needs mark and submit and review; prior completions grandfathered; one shared build.
- **Planner fixed inputs honored.**
  - P1 environment: base URL `http://localhost:5179` (launch `npx vite --port 5179 --strictPort`). Owner `owner@test.local`. Students `fullaccess@test.local` and `student1-6@test.local`. Password `password`.
  - P2: answers are stripped at source (content-source `translationTask` and regenerated `lesson-content.json`). The Q&A quiz "Answer:" rendering is untouched and belongs to #180.
  - P3: templates and submissions are keyed by (`enrollment_id`, `lesson_revision_id`). `get_lesson_task(enrollment_id, lesson_revision_id)` applies the canonical eligibility rule server-side and returns NULL when ineligible or when no template exists. Roadmap resolves legacy lesson id to `lesson_revision_id` from the existing `get_enrollment_lesson_completion` rows and treats NULL as "render as today". Templates exist only for the 78 legacy lessons, so authored-course lessons render unchanged and are reachable only via `/learn`.
  - P4 mark intent: a mark on a templated lesson whose task is not reviewed stores `student_marked_complete_at` on the entitlement. `record_lesson_progress` 'complete' and `record_lesson_completion` then return `completed_at` NULL. `get_lesson_task` returns `mark_recorded_at`. Completion finalizes server-side in the owner review transaction.
  - P5: the owner sees a draft's status only, never its text.
  - P6: no native `maxLength`. A visible counter plus a field error at submit. The server counts `char_length`: 4000 translation, 8000 practice. Drafts may save up to 20000 characters.
- **Director resolutions.**
  - Roadmap placement is a hybrid on one shared form state. Fields sit inline in each Translation task chunk and in the Practice panel. One Lesson task bar sits below the three segment panels and above the completion control.
  - `/learn` gets a dedicated route, not an inline disclosure on the card.
  - Owner submission detail is a full-width page. Three item columns cannot fit the narrow detail pane of the feedback-inbox split (about 520 px at 1440). The list route is list-only. The detail route has "Back to submissions" and "Next awaiting review".
  - Automatic completion at owner review does not fire the Stamp. A student's own real in-session completion save still fires it, as today.
  - The accent strip is per field.
  - The item legend is short. The prompt is a visible paragraph referenced by the textarea's `aria-describedby`.
  - Task textareas use the field CSS classes directly, not the `<Field>` component, because `Field.tsx` spreads `...rest` after its own `aria-describedby` (lines 96-97), so a caller value silently replaces the error wiring.

#### 4.3 UX spec: journeys

- **J1 Roadmap fill and save** (student; 1440 reading sheet and 390 Lesson panel plus footer).
  - `WeekDetailPage` owns one `LessonTaskProvider` instance, like the single `useLessonCompletion` machine. It resolves `lesson_revision_id` from the `get_enrollment_lesson_completion` rows, then makes one `get_lesson_task` call. NULL, or no resolvable revision id, means render exactly as today. A response with a template renders the form. The load result also carries the submission, `mark_recorded_at`, and a completed indicator (see the completion contract), so the first render decision is single-shot with no flicker.
  - Loading shows ONE page-level `<p role="status">` "Loading your lesson task…" in the task bar region. Per-slot placeholders render nothing and are silent. The rest of the lesson renders immediately.
  - Each Translation task chunk keeps its ChunkTab and h4. The raw paragraph is replaced by the template student prompt. Under it sits the item fieldset: short legend (group title), optional hint, one textarea labelled "Your answer", the accent strip, and the counter.
  - The Practice panel keeps its title and summary. After them come read-only blocks as a `<dl>` (dt label, dd value): Scenario, Your role(s), What to write, Length and format, Register and dialect, Use these phrases, Success checklist (a plain ul, no checkbox state). Then one textarea per template part (labels "Part N", or "Your answer" for a single part).
  - Autosave fires 2000 ms after the last keystroke. It also fires on blur of a dirty field and, best-effort, via a keepalive request on `visibilitychange` hidden or `pagehide`. The explicit "Save draft" button always works.
  - Segment switching never unmounts the task bar, because it sits outside the hidden panels. Reload restores text and the "Draft saved" chip.
- **J2 `/learn` standalone.**
  - A summary call (indicative name `get_lesson_task_summaries(enrollment_id)`) returns, per eligible lesson, {status, unseen, mark_recorded_at}. It is batched once per page and loaded like the #174 materials adapter. This is required engineering because `get_lesson_task` is per lesson. Cards are never blocked by it.
  - An eligible templated card shows a compact chip after the state label and a task link inside `.lesson-card-text`.
  - Link labels: Not started "Open task". Draft saved "Continue task". Returned "Revise and resubmit". Submitted "View your submission" (quiet). Reviewed "View feedback" (quiet). Feedback is always reachable.
  - Route `/learn/:enrollmentId/lessons/:lessonRevisionId/tasks`. Content: Back link "← Back to {course title}", h1 lesson title, h2 "Translation tasks" (items in template order), h2 "Practice", then the task bar.
  - If `get_lesson_task` returns NULL, show one generic message "This task isn't available right now." plus the Back link. No distinct reasons.
- **J3 Owner return.** Nav "Submissions (N awaiting review)" goes to the list-only `/admin/submissions` (default "Awaiting review"), then to the full-width detail. A "Jump to review" skip link sits at the top of the detail. The owner reads each item as prompt | student answer | owner-only reference, enters feedback (required), presses "Return for revision", and gets an inline `role=status` confirmation.
- **J4 Student return and resubmit.** The unseen marker shows on the chip. Opening the task clears it (idempotent write on open; see EN-1 for the separate-call rule). The feedback card "Feedback from your teacher" sits above the first item. Prior answers are prefilled and editable. "Revise and resubmit" opens the same Modal. After submit, prior feedback moves under a collapsed "Earlier feedback".
- **J5 Owner mark reviewed.** Feedback is required (Decision AD1). Score is an optional integer 0-100. A caption states the consequence. Review writes `reviewed_at`, and if `student_marked_complete_at` is set, the lesson completes in that same server transaction.
- **J6 Student reviewed.** Chip "✓ Reviewed", feedback card, "Score: N / 100" only when given, fields permanently read-only. If the mark was not yet pressed, Mark complete now completes through the existing machine. That is a real in-session save, so the Stamp fires as today.
- **J7 Mark before review.** Pressing Mark complete on a templated lesson with an unreviewed task makes the server store mark intent and return `completed_at` NULL. The client enters the new "recorded" state (see completion contract). There is no completed flag, no `justCompleted`, and no Stamp. The label is "Mark recorded" (native disabled) with the visible note. After the owner reviews, a reload shows the existing Completed presentation with no Stamp.
- **J8 Ineligible: locked, held, revoked.**
  - `/learn` cards use the single exported #174 predicate: `has_entitlement` AND `manual_release_state` in ('automatic','released') AND (released OR `unlock_at <= now`). Client predicate reuse is `/learn`-only.
  - The Roadmap does NOT evaluate the predicate client-side. It relies on `get_lesson_task` returning NULL. Legacy resources RLS ignores held/revoked, so a held student can still see an available week. That is existing behavior, and the task UI simply does not appear.
  - Ineligible means no form, task bar, chip, placeholder, or hint, and a byte-identical DOM.
- **J9 Grandfathered completed.** The load includes a completed indicator. A grandfathered lesson (cutover definition in C1: entitlement `completed_at` not null AND `completed_at < cutover_at` AND no submission row) renders as today (no task UI) and is never un-completed. If a real submission row exists, the task UI renders normally.
- **J10 No template or authored.** `get_lesson_task` NULL, or an authored-course lesson, renders exactly as today.
- **J11 Owner other surfaces.**
  - The student-detail panel lists submissions per enrollment (lesson, chip, dates, link). Draft rows show status only and are not links.
  - The roster gets an expandable per-student row with one compact chip per lesson. No `RosterLesson` component exists in the checkout, so this is new work on the existing roster disclosure.
  - The Roadmap `WeekCard` shows a compact chip for Draft saved, Submitted, Returned, Reviewed, and the unseen marker (never "Not started").
- **J12 Keyboard only.** Tab order is segment tabs, then each item (textarea, then the accent strip as one tab stop), then the task bar (Save draft, Review and submit), then the completion control.

#### 4.4 Completion contract (DR-2)

- `LessonCompletion` (`useLessonCompletion.ts`) gains `recorded: boolean`. The hook takes an optional `markRecordedAt` input to hydrate it from `get_lesson_task`.
- After a successful 'complete' write whose response has `completed_at` NULL, set `recorded = true`. Do not set `completed`. Do not set `justCompleted`. This requires the progress write to expose `completed_at` to the hook. The fire-once rule is otherwise untouched.
- `LessonCompletionControl`: when recorded, label "Mark recorded", native disabled, and a new optional `describedById` renders as `aria-describedby`. It adds no paragraph and no Stamp. Recorded is announced through the task bar's single polite region ("Mark recorded. Waiting for your teacher's review.").
- Desktop completion control remains a plain `<button>` with its existing class. It never becomes `.control--primary` and gets no tier.
- Mobile footer keeps passing `buttonTier`. Only the tier value, label, and `aria-describedby` change, and only for templated lessons.
- `/learn` `LearnDetailPage` line 258 fabricates `completed_at` (`?? new Date().toISOString()`) and increments the completed count. Replace: if `completed_at` is NULL, do not call `onCompleted`. Mark the card "recorded" locally (and refresh from the summary), and do not change the completed count or show a completed date.

#### 4.5 Permitted DOM deltas

Applies to templated, eligible, non-grandfathered lessons only. For templateless, ineligible, and grandfathered lessons the desktop and mobile DOM must be byte-identical to today.

1. Translation chunk paragraph replaced by prompt paragraph plus fieldset.
2. Practice panel gains the dl blocks and fieldsets.
3. Task bar plus the single overlay note inserted between the panels and the completion control.
4. Completion control: recorded label, disabled, `aria-describedby`.
5. Mobile footer: tier value (secondary while the task is actionable), recorded label, `aria-describedby`.

#### 4.6 Completion overlay matrix

One in-flow note instance with a shared id, directly under the task bar on both viewports. Rows are task status and mark recorded. Keys `lesson_task.completion.*`.

| Task status and mark | Note text |
| --- | --- |
| Not started or draft, unmarked | "This lesson completes after you mark it complete, submit your task, and your teacher reviews it." |
| Not started or draft, recorded | "You've marked this lesson. Submit your task next. It completes after your teacher reviews it." |
| Submitted, unmarked | "Your task is waiting for teacher review. Mark this lesson complete now and it finishes once your teacher reviews your task." |
| Submitted, recorded | "Waiting for teacher review. Your lesson will complete automatically once your teacher reviews your task." |
| Returned, unmarked | "Your teacher returned your task. Revise and resubmit. The lesson completes after the next review." |
| Returned, recorded | "You've marked this lesson. Revise and resubmit your task. It completes after your teacher reviews it." |
| Reviewed, unmarked | "Your teacher reviewed your task. Mark this lesson complete to finish." |
| Reviewed, recorded | Cannot persist, because it completes automatically. |

- Mobile (DR-3): the full note is in-flow in the Lesson tabpanel next to the task bar, never inside the footer. The footer control references it via `aria-describedby` (referenced hidden content is still computed), and the footer shows at most the short one-line label "Mark recorded". Footer geometry stays unchanged (`flex-shrink:0`).
- `/learn` card: the two-step inline Confirm/Cancel (no Modal) is unchanged. After a confirm with an unreviewed task, the card label becomes "Waiting for teacher review" with a one-line note from this matrix, the Mark control is replaced by the disabled "Mark recorded", and no completed date or count change occurs.

#### 4.7 One-primary rule (DR-2, DR-4)

At most one `.control--primary` per view, and exactly one while a primary-eligible action remains.

- Roadmap desktop: the plain Mark button is never primary and gets no tier change. The task bar's "Review and submit" / "Revise and resubmit" is primary while the task is actionable (not started, draft, returned). When no task action remains, no primary comes from this feature, as today.
- Roadmap mobile: the footer is primary today. For a templated lesson while the task is actionable, the footer passes tier "secondary" and the task bar is the single primary on the Lesson tab. Otherwise the footer stays primary. On the Cards and Files tabs while the task is actionable, no primary is visible. That is accepted and documented.
- `/learn` course page: the tie-break input set is eligible-and-not-completed cards (not only unlocked-incomplete). The single primary is the lowest-position card in that set that has a primary-eligible action: its task link if the task is actionable, else its Mark complete (including its Confirm step). Every other card's actionable task link is secondary; non-actionable task links are quiet; other Mark controls are secondary. The "Up next" marker follows the same card. Test with several actionable tasks.
- Task page: one primary only (Review and submit / Revise and resubmit); Save draft is secondary.
- Owner detail: "Mark reviewed" is the only primary; "Return for revision" is caution-reversible.

#### 4.8 Information architecture

- **Components.** `LessonTaskProvider`/`useLessonTask` (one per page), `LessonTaskItem` (embedded|standalone), `LessonTaskBar`, `LessonTaskStatusChip` (shared by 9 mount sites), `LessonTaskFeedbackCard` (reused read-only in owner detail), `AccentStrip`, `OwnerSubmissionsPage` (list) and `OwnerSubmissionDetailPage`, `ReviewForm`, `SubmissionLedgerRow` (new), `SubmissionSummaryList`. Touched existing: `LessonContentView`, `LessonCompletionControl`, `useLessonCompletion`, `WeekDetailPage` (footer tier and describedby), `LearnDetailPage`, `learnData`, `WeekCard`, `useRoute`, `App`, `AdminShell`, `MobileNav`, `OwnerDashboardPage`, `AdminStudentsPage`, `CourseWorkspacePage`.
- **Headings.** Roadmap desktop h1, h2 lesson title, h3 group, h4 "Translation task". Roadmap mobile h1, then h3 group (existing deliberate skip). `/learn` task page h1, h2 "Translation tasks", h3 per item, h2 "Practice". Owner h1 "Submissions". The task bar is `role=group aria-label="Lesson task"` with no heading. The error summary is `role=alert` with its own heading.
- **DOM order.** Roadmap is title, SegmentLedger, panels, task bar, overlay note, completion control. Owner detail has DOM order equal to visual order, with no CSS `order`.
- **Routing touchpoints (DR-5).** Each needs a test, including direct-URL load.
  - `useRoute.ts`: new matchers. `LEARN_DETAIL_PATTERN` `^/learn/([^/]+)$` will not match the task route. Add `/learn/:enrollmentId/lessons/:lessonRevisionId/tasks`, `/admin/submissions`, and `/admin/submissions/:id`. Malformed ids fail closed.
  - `App.tsx` `knownAdminRoute` (about lines 82-87) and the learn fall-through must recognize the new routes.
  - `AdminShell` links and active state (about line 141) and `MobileNav` gain "Submissions" with the count.
  - Owner filters live in the query string: `?status=awaiting_review|returned_for_revision|reviewed|in_progress|all` and `&band=` or `&course=` and `&page=`. The App route listener keys on path, so add a popstate plus custom-event listener for query-only changes.
  - On a filter or page change, focus the list heading or the status line, never the h1.
  - Non-owner on `/admin/submissions*` gets the existing inline permission-denied convention. A student requesting another student's task gets the generic NULL message.

#### 4.9 Responsive behavior

- Roadmap-embedded task elements switch at `WEEK_DETAIL_BREAKPOINT_REM` = 56.24rem (`src/lib/weekDetailBreakpoint.ts`; `LessonContentView.css` line 382). The `/learn` task page, owner surfaces, and `WeekCard` chip use 48rem.
- At 390: task bar controls stack full width at `--control-height`. The field footer wraps (strip, then counter). Owner columns stack in order.
- Owner detail columns use `repeat(auto-fit, minmax(min(100%, 18rem), 1fr))`, so a column never gets narrower than about 18rem. Wrapping keeps DOM order. About three columns at 1440; two at about 1024.
- Mobile focus not obscured (DR-3): the Lesson panel has `scroll-padding` or `scroll-margin` equal to the footer height so a focused field clears the persistent footer.
- 320 and 400% zoom: no clipping and no horizontal scroll. The accent strip wraps by flex-wrap. At 320×256 effective viewport (400% zoom), focused controls are not obscured by the footer.

#### 4.10 States and copy (keys `lesson_task.*`, English defaults)

- **Chips** (glyph aria-hidden, word always visible): "○ Not started", "✎ Draft saved", "◆ Submitted, awaiting review", "↺ Returned for revision", "✓ Reviewed". Unseen marker: "▪ New" (sr text "New feedback").
- **Save status:** "Saving…" (visual only), "Draft saved at HH:MM", "Couldn't save. Your answers are still here. Try again." with Retry, "You're offline. We'll try again when you're back online.", "Nothing to save yet."
  - Draft ceiling: "This answer is too long to save as a draft (limit 20,000 characters). Shorten it to keep saving."
- **Draft privacy caption** in the task bar: "Your teacher sees your answers only after you submit." (Decision AD5)
- **Errors:**
  - Load failure (`role=alert`): "We couldn't load your lesson task. Please try again." with Retry.
  - Submit failure (in the Modal): "Couldn't submit right now. Your answers are safely saved as a draft. Please try again."
  - Per-field at submit: "Write an answer for this item before submitting." and "This answer is {n} characters over the {max}-character limit."
  - Conflict (`role=alert`): "This task changed since you opened it. Reload to see the latest version, or keep editing. Your changes are still here." Actions: "Reload task", "Keep editing". No silent merge.
- **Read-only captions:** "Submitted: read only until your teacher responds." and "Reviewed: read only."
- **Owner copy:**
  - "No submissions match this filter yet."
  - "Couldn't save your review. Please try again." (feedback and score kept)
  - "Add feedback before returning this for revision."
  - "Enter a whole number from 0 to 100, or leave it blank."
  - "Owner only: never shown to students." and "No reference answer for this item."
  - In-progress row: "Draft text is private until the student submits."
- **Status matrix.**
  - Student: not started (editable), draft (editable), submitted (read-only), returned (editable, prefilled, feedback card, unseen marker until opened), reviewed (read-only, feedback, optional score).
  - Owner: Submitted in the default view with Mark reviewed and Return. Returned and Reviewed show read-only with attempt history. Drafts under "In progress" show status only (chip, student, lesson, last saved), no link, no text.

#### 4.11 Accessibility

- Item `<fieldset>` has a short legend (group title, or "Practice, part N"). The full prompt is a visible paragraph with `lang` es or en. The textarea has the visible label "Your answer" and one pre-joined `aria-describedby`: prompt id, hint id, counter-state id, and the error id when present. Hints derive from `response_lang`, for example "Write your answer in Spanish".
- `lang="es"` on Spanish prompts and on es response fields. `lang="en"` on en fields. Mixed or unspecified gets no `lang` attribute.
- No native `maxLength` (P6). The visible counter "0041 / 4000" updates per keystroke without `aria-live`. It counts code points (`Array.from`), matching Postgres `char_length`, with no normalization. Over the limit it shows the non-color text "N over the limit" immediately. A separate visually hidden polite span announces at most once per crossing: 80%, 95%, 100%, and "Over the limit by N characters". Each re-arms after the count drops back below.
- The error summary is a freshly mounted `role=alert` with `tabIndex -1`. It takes focus on mount and has a heading and an ordered list of links. Each link first activates the owning segment via SegmentLedger's `onActivate`, then focuses the field. Fields get `aria-invalid=true`. Inline field errors are plain text linked by `aria-describedby` and do NOT use `role=alert`, because the summary is the alert. A non-color border change accompanies them.
- The save region is one `role=status` polite region that announces transitions only: "Draft saved at HH:MM", "Couldn't save", "Submitted. Your answers are now read-only until your teacher responds.", "Mark recorded. Waiting for your teacher's review.", "Your teacher has reviewed this task." It never announces "Saving…".
- Review and submit is never disabled for incompleteness. Native disabled applies only while a request is in flight.
- Submit Modal uses `Modal.tsx` unmodified (role=dialog, aria-modal, focus trap, Escape except while submitting, focus return). Title "Submit final answers". Body: "{n} of {m} translation tasks answered. {p} of {q} practice fields answered." plus "Once you submit, your answers become read-only until your teacher responds." Actions: "Submit final answers" (primary), "Keep editing" (secondary).
- **Unsaved-change protection (DR-6).** No `beforeunload` and no native dialogs. `navigate()` is a bare function and Back/Forward arrive via popstate after the URL changes, so only some paths can be guarded.
  - Guarded paths: header nav, the in-page Back link, "Next awaiting review", and sign-out. Each flushes the save first. Only on flush failure does an app Modal "Leave without saving?" open, with "Stay and try saving again" (primary) and "Leave without saving" (caution-irreversible).
  - Sign-out uses an async-aware registration on `SignOutGuardContext`: the guard returns true to intercept, flushes, then calls `proceedSignOut` or opens the Modal. It generalizes the existing single synchronous slot.
  - Back/Forward and unmount get a best-effort keepalive flush with no Modal. The accepted limit is loss of up to the debounce window (2 s).
- **Accent strip:** `role=toolbar aria-label="Insert accented characters"`, roving tabindex, ArrowLeft/Right/Home/End. Nine quiet-tier buttons (á é í ó ú ü ñ ¿ ¡), each at least 44×44, `aria-label` "Insert {char}". `onMouseDown` `preventDefault` keeps focus in the textarea on pointer press. Keyboard activation inserts at the saved caret, then returns focus to the textarea with the caret after the character. The strip is always mounted and absent when `response_lang` is "en". The precedent is the roving toolbar in `CourseWorkspacePage.tsx`.
- **Focus after actions:** explicit Save draft keeps focus on the button. Autosave and blur-save never move focus. After submit the Modal closes and focus returns to the trigger (or the nearest preceding heading if it is gone). Owner Return/Mark reviewed keeps focus on the pressed button and shows a `role=status` confirmation. Route changes focus the destination h1. Filter or page changes focus the list heading or status line.
- Targets at least 44px (strip) and `--control-height` (Controls). WCAG 2.2 AA, forced-colors, 400% reflow. No new animation.

#### 4.12 Visual system spec

- **Tokens.** Zero new tokens. Reused: `--border-width-rule/thin/hairline/accent`, `--radius-square`, `--shadow-card/-sheet`, `--color-paper-50/100/200`, `--color-surface-chrome-default`, `--color-status-{error,success,warning,neutral}-{text,border}`, `--color-ink-700/900/1000`, `--color-ink-slate`, `--color-ink-moss`, `--color-brass-600/700`, `--color-terracotta-600`, `--control-height`, `--hit-target-min`, `--focus-ring-width/-offset`, `--space-1..10`, `--font-family-display/body/label`, `--font-size-caption/label`. Nothing from `scripts/lib/tokenDeprecationRegistry.ts` is used. `--color-ink-800` is contextual (color positions only). `--shadow-brass` stays reserved for owner tables and export links.
- **Typography.** Headings reuse the existing h2/h3/h4 rules and `.lesson-content-chunk h4` (mono eyebrow). The legend reuses the chunk h4 recipe. The prompt paragraph reuses `.lesson-content-chunk p`. The hint is body font at `--font-size-caption`, `--color-ink-700`, italic (the `.lesson-card-unlock-hint` recipe). Label and counter reuse `.field__label` and `.field__counter`. The chip word is IBM Plex Mono at `--font-size-caption`, `--font-weight-label`, .1em, uppercase (the `.feedback-ledger-row-status` recipe). The practice dl uses the chunk h4 recipe for dt and body type for dd. The feedback card heading is Fraunces 700 at 21px (the `FeedbackLedgerRow` documented literal).
- **Color and contrast** (`contrast_check` results from the visual specialist, not re-run by the director):

| Element | Pair | WCAG | APCA |
| --- | --- | --- | --- |
| Neutral chip and hint | ink-700 on paper-50 | 8.64:1 | Lc 88.5 |
| Draft saved | brass-700 on paper-100 | 5.47:1 | Lc 74.9 |
| Owner-only label | brass-700 on paper-200 | 4.89:1 | Lc 67.4 |
| Returned | terracotta-600 on paper-50 | 4.69:1 | Lc 71.3 |
| Reviewed | ink-moss on paper-50 | 7.42:1 | Lc 84.5 |
| Submitted | ink-slate on paper-100 | 6.5:1 | Lc 79.7 |
| Body on chrome ground | ink-1000 on paper-200 | 15.25:1 | not reported |

  The brass and terracotta APCA values carry deviations already accepted in `tokens.field-journal.json`. The over-limit counter text must reuse an existing status-error pair; the specialist did not measure it, so engineering must run `contrast_check` on that pair (EN-5). Never color alone: every chip has glyph plus word. Invalid and over-limit states also show text.
- **Layout and density.**
  - Student: reuse the `.lesson-content-chunk` padding and `--space-3` gap. The textarea is a bounded insert (paper-100 fill, 3px solid ink-1000 border) inside the chunk padding. It does not take the chunk's 27/28px ruled background (the J-39 lesson), and there is no double-border seam. The Practice panel has no CSS today and stays on the plain reading surface.
  - Task bar `.lesson-task-bar`: flex wrap, `--space-4` padding, 3px ink-1000 border, chrome surface, `--shadow-card`, margin-top `--space-4`. It stacks with full-width Controls when narrow. The overlay note sits directly beneath it.
  - Field footer `.lesson-task-field-footer`: strip left, counter right. It becomes a column when narrow.
  - Standalone page: max-width `var(--measure)`, centered.
  - Owner list: list-only. Rows use a NEW `SubmissionLedgerRow` (DR-10): the `journal-index-card-trim` class plus chip declarations duplicated under `owner-submission-*` names. `FeedbackLedgerRow` and its CSS are untouched. A non-regression test covers it.
  - Owner detail columns: `repeat(auto-fit, minmax(min(100%, 18rem), 1fr))`, gap `--space-5`, DOM order preserved. The practice detail shows prompt/instructions, the student's parts, then the owner-only model answer and success checklist in the reference column.
  - Reference sheet `.owner-submission-reference-sheet`: chrome surface, 3px ink-1000 border, 3px brass-600 left rule, `--shadow-card`, and a mono brass-700 label with an aria-hidden glyph.
- **Components and states** (new classes only, under `.lesson-task-*` or `.owner-submission-*`, additive):
  - Chip `.lesson-task-status-chip` (full) and `--compact` (WeekCard, `/learn` card, roster, student-detail). 2px tier border, mono caption uppercase. Tiers: neutral, warning (Draft), slate (Submitted), error (Returned), success (Reviewed). The unseen marker appends brass-700 text and border. Forced-colors uses border-style differentiation as in `Stamp.css`. The chip is not aria-hidden.
  - Textarea states: default, focus-visible (3px `--color-focus` ring), aria-invalid (error border plus text), over-limit (counter text), read-only (native `readOnly`, paper-200 fill, dashed border, caption, forced-colors dotted and GrayText).
  - Accent strip `.lesson-task-accent-strip` (flex, gap `--space-1`, wraps when narrow) with `.lesson-task-accent-button` layered on `control--quiet` (44×44, centered glyph), following the `.menu-trigger` layering precedent. Disabled only when the item is read-only.
  - Feedback card: B.06 index card via `.journal-index-card-trim` containing h3 "Feedback from your teacher", a dated meta line, optional "Score: N / 100", the body, and a quiet-outline `aria-expanded` "Earlier feedback" disclosure. The owner "Earlier attempts" disclosure uses the same recipe.
  - Error summary `.lesson-task-error-summary`: `role=alert`, heading, ordered links, error-tier left border.
  - Modals: content classes only (`.lesson-task-modal-actions`). The submit warning uses `--color-status-warning-text`.
  - Overlay note `.lesson-task-completion-overlay-note`: always visible, recipe from `.lesson-content-complete-confirmation`. "Mark recorded" uses the native-disabled contract and the visible explanation, never tooltip-only.
  - `/learn` card: compact chip after `.lesson-card-state-label` and the task link inside `.lesson-card-text`. The #174 `.lesson-card-materials` block stays a sibling after `.lesson-card-main`.
  - Owner nav: "Submissions" Control tier nav with `<span class="lesson-task-nav-count">` in mono. Accessible name "Submissions, N awaiting review".
  - Dashboard: `describeAttentionReason` gains 'awaiting_review' giving "Awaiting review". One quiet line "N submissions awaiting your review" sits between `.dashboard-metrics` and the grid. No fifth MetricPlate.
  - Student-detail `.admin-students-detail-submissions` nested list. Roster reuses `.roster-student-toggle` / `.roster-lesson-list` plus a compact chip per lesson row. WeekCard `.week-card-task-status` after `.week-card-state-row`.
  - Review actions: "Mark reviewed" (primary) and "Return for revision" (caution-reversible), each with an adjacent consequence caption. Mark reviewed: "The student will see this feedback{ and score} and the lesson can now be completed." Return: "The student will see your feedback and can revise their answers."

#### 4.13 Engineering invariants (binding)

1. Student-visible prompts come from the template's student prompt. Never render raw `PhraseGroup.translationTask` for a lesson with a template. Answers are stripped at source (P2) in content-source and in regenerated `lesson-content.json`.
   - Deterministic leak check (DR-9): a student-authenticated fetch of `lesson-content.json`, the `get_lesson_task` payload, and the rendered DOM contain none of the owner-only reference strings. Use fixture sentinel strings in the model answer and answer key.
   - The Q&A quiz "Answer:" rendering is out of scope (#180).
2. Desktop 1440 non-regression is a hard target (`src/__tests__/lessonContentViewDesktopVisualNonRegression.test.ts`). Only the enumerated permitted DOM deltas may differ. Templateless, ineligible, grandfathered, and authored lessons are byte-identical on desktop and mobile. Add DOM-equality tests. Deliberately update the chunk and footer tests only where a permitted delta requires it. `RHYTHM_SEGMENTS` (30/10/20) and its labels are unchanged.
3. The desktop completion control stays a plain `<button>` with its existing class. Only the footer carries `buttonTier`. The primary on Roadmap desktop is the task bar's. `recorded` is a new state with its own label, no Stamp, no completed flag, and no `justCompleted`. It is hydrated from `get_lesson_task` `mark_recorded_at` and set after a 'complete' write returning `completed_at` NULL. A templateless lesson never reaches recorded.
4. `/learn` must not invent a date or increment the completed count when `completed_at` is NULL (`LearnDetailPage` line 258).
5. Server contract assumptions the design needs, confirmed in this plan:
   - `get_lesson_task` returns, alongside the template and submission: `mark_recorded_at`, a completed indicator for grandfathering (cutover definition in C1, not "no submission" alone), and unseen/feedback timestamps.
   - A batched per-enrollment summary call exists for the `/learn` cards.
   - Owner-only reference fields are returned only to owner-authorized calls and are never in student payloads.
   - Submitted and reviewed are read-only server-side. Resubmission is only from `returned_for_revision`. Opening a task clears unseen (idempotent).
6. One shared `LessonTaskProvider` per page, mirroring "one machine per page". A breakpoint crossing must not re-run loads or reset drafts.
7. Exactly one primary per view per the one-primary rule, through the existing WP-G tie-break extended to the eligible-and-not-completed set. Test per state, including several actionable `/learn` tasks.
8. `/learn` eligibility uses the single exported #174 predicate client-side. The Roadmap relies on the server NULL.
9. No native dialogs and no `beforeunload` anywhere. Add or extend the source scan. Only app Modals are used: "Submit final answers" and "Leave without saving?". Guard scope per DR-6. The Back/Forward loss window is recorded as a limit.
10. Task textareas use the field classes directly with one pre-joined `aria-describedby`. There is no native `maxLength`. The counter is hand-built in the footer row. Server validation is authoritative. Limits are 4000 (translation) and 8000 (practice) at submit, with a 20000-character draft ceiling and a per-field message beyond it.
11. Roadmap-embedded responsive rules use `WEEK_DETAIL_BREAKPOINT_REM` (56.24rem). Standalone and owner surfaces use 48rem. Mobile footer geometry is unchanged for templateless lessons. The full note is never in the footer.
12. Routing touchpoints per DR-5, including query-string listener and focus targets.
13. Student copy is a `site_content` key under `lesson_task.*` with English defaults, and never mentions or hints at answer keys.
14. The owner never receives draft text. Owner draft rows show status only.
15. `SubmissionLedgerRow` is new. `FeedbackLedgerRow` and its CSS are untouched, with a non-regression test. Zero new `tokenDeprecationLint` findings.
16. (Added in revision 1, J-179-PLAN-003; no design change.) All student responses, teacher feedback, prompts, and answer keys render as plain React text nodes (escaped) everywhere: student task views, owner list and detail, student-detail, and roster. No `dangerouslySetInnerHTML`, and no markdown or HTML rendering of these fields. Whitespace is preserved with CSS (`white-space: pre-wrap`) only.

#### 4.14 Permitted variation

- Glyph characters, provided the word carries the meaning and the glyph is aria-hidden.
- Roster expansion as a list or compact table, provided it uses the existing disclosure and the chip text is intact.
- "Jump to review" as a top skip link or an anchor, provided it never obscures focus.
- Autosave debounce between 1500 and 3000 ms.
- Copy wording, if every key is kept and no student string refers to answer keys.
- Name of the batched summary call and any server field names, provided the contract in invariant 5 is met.
- Everything else is fixed.

#### 4.15 Browser validation brief (design)

Environment (P1): launch `npx vite --port 5179 --strictPort`, base URL `http://localhost:5179`, local Supabase reset per the repo runbook. Owner `owner@test.local`; students `fullaccess@test.local` and `student1-6@test.local`; password `password`. Journeys 1-9 and 14 use `fullaccess@test.local` as the student and `owner@test.local` as the owner. `student1-6@test.local` cover several-tasks, other-student isolation, and held/revoked states.

**Fixtures:**

- A templated lesson with at least 4 translation items (response_lang es, en, mixed, unspecified; one without a reference answer) and a two-part practice item.
- A templated lesson with a single-part practice item.
- Held, revoked, and date-locked lessons.
- A grandfathered-completed lesson without a submission.
- A templateless lesson.
- An authored-course lesson reachable via `/learn`.
- Several actionable `/learn` tasks on one enrollment.
- Distinct sentinel strings in owner-only model answers and answer keys.
- All sample prompt text is PLACEHOLDER. Reset clears submissions and mark-intent between journeys.

**Viewports:** 390×844 and 1440×900 for every journey. Spot checks at 320, 320×256 (400% zoom), 768, 1024, 1100, forced-colors, and reduced-motion.

**Validation journeys** (assert visible outcomes; screenshot names in brackets):

1. Roadmap draft and persistence: type in two translation fields and one practice part. Wait for "Draft saved at HH:MM". Switch segments and confirm the task bar and status stay visible. Reload and confirm text and the "✎ Draft saved" chip persist. The draft-privacy caption is visible. [roadmap-draft-390 / -1440]
2. `/learn`: the card shows the chip and the link "Open task" as the single primary, and Mark complete is secondary. With several actionable tasks, only the lowest-position card carries the primary. Open the task route, type, save, press Back, and confirm the card shows "Continue task". [learn-card-390 / -1440, learn-task-page-390 / -1440]
3. Error summary and limits: submit with an empty field, and with a field over the limit (the counter shows "N over the limit"). Confirm focus lands on the summary, links reveal the owning segment and focus the field, `aria-invalid` is set, and inline errors have no `role=alert`. Confirm a draft over 4000 characters still saves. [error-summary-390 / -1440]
4. Submit Modal: the dialog lists counts and the read-only warning, focus is trapped, Escape closes and focus returns to the trigger. Submit moves to "◆ Submitted, awaiting review", fields become read-only with captions, and the Mark control gets the correct overlay note. [submit-modal-390 / -1440, submitted-readonly-390 / -1440]
5. Owner inbox to return: the nav count shows. `/admin/submissions` defaults to Awaiting review. Open the detail. Confirm the three columns at 1440 and the stacked order at 390, the owner-only label, and the no-reference text on the keyless item. Return without feedback shows the inline error. Add feedback and return. Draft rows under "In progress" show status only, with no link and no text. [owner-list-1440 / -390, owner-detail-1440 / -390, owner-return-validation]
6. Student sees return, edits, resubmits: the unseen marker clears on open, prior answers are prefilled, and the feedback card shows. After resubmit the owner sees "Attempt 2" with attempt 1 collapsed and read-only. [returned-390 / -1440, attempt-history-1440]
7. Owner marks reviewed (score 85 once, no score once). The student sees "✓ Reviewed", the feedback, "Score: 85 / 100" only when given, and read-only fields. [reviewed-390 / -1440]
8. Mark complete before review: with the task submitted, press Mark complete (two-step on `/learn`, footer on Roadmap 390). Confirm "Mark recorded" (disabled), the in-flow note, no Stamp, no fabricated completed date, and no change to the completed count. Reload and confirm the recorded state persists. After the owner marks reviewed, reload and confirm Completed with no Stamp. Repeat with the task not started to confirm the other note text. Also confirm that marking after review completes immediately with the Stamp. [mark-recorded-390 / -1440, auto-completed-390 / -1440]
9. Ineligible and unchanged states: held, revoked, date-locked, grandfathered-completed, templateless, and authored lessons show no task UI and a byte-identical DOM against a stored snapshot. On `/learn` the task route shows only the generic message. A student requesting another student's task gets the same generic message. A held student on Roadmap sees no task UI even if the week renders.
10. Owner dashboard attention reason "Awaiting review" and the strip count, student-detail submissions list, and workspace roster chips. Direct-URL loads of `/admin/submissions?status=…`, `/admin/submissions/:id`, and the `/learn` task route work. A non-owner on `/admin/submissions*` is denied. A filter change focuses the list heading or status line. [dashboard-attention-1440, student-detail-submissions, roster-status]
11. Keyboard only: tab through segment tabs, fields, each accent strip (single tab stop; arrows move between buttons), Save draft, Review and submit, and the completion control. Open and close the Modal with the keyboard. Insert "ñ" via the strip and confirm focus returns to the textarea with the caret after it. Follow an error-summary link with the keyboard.
12. Accent aid with pointer: pressing an accent button never moves `document.activeElement` away from the textarea. The strip is absent for the "en" item and present for es, mixed, and unspecified.
13. Failures: a failed save (status line plus Retry, answers kept), a failed submit (Modal stays open with the inline error), and a conflict (message plus two actions).
14. Navigation guard: with a forced save failure, click header nav, the in-page Back link, "Next awaiting review", and Sign out. Confirm the "Leave without saving?" Modal appears with focus trap and Escape. With a successful flush, navigation proceeds without a Modal. Browser Back/Forward triggers a best-effort flush with no Modal.
15. Leak check: the student-authenticated `lesson-content.json`, the `get_lesson_task` payload, and the rendered DOM contain none of the sentinel owner-only strings.

**Deterministic checks:**

- Source scan: no `alert`/`confirm`/`prompt`/`window.*` and no `beforeunload`. A run-time check that no native dialog event fires.
- Exactly one `.control--primary` per view per state. The desktop Roadmap Mark button never has `.control--primary`.
- Footer geometry test unchanged for templateless lessons.
- Computed-style and structure: task textarea border 3px ink-1000. The translation chunk keeps a dashed border-bottom and a non-none background after insertion. Nine `.lesson-task-accent-button` per non-"en" item, exactly one with `tabindex` 0. Chip accessible name contains the status word. Owner column order is identical at all widths. Roadmap embedded layout switches at 56.24rem and standalone at 48rem.
- `FeedbackLedgerRow` non-regression test.
- Axe on every state and viewport. `aria-describedby` ids resolve. `lang` attributes follow `response_lang`. No horizontal scroll at 390 or 320. At 320×256 a focused control is not obscured by the footer. Forced-colors captures of chip, textarea, owner sheet, and Modal. No console errors.

**Screenshots:** the named captures above at both viewports, plus forced-colors-task-bar, zoom400-task-page, zoom400-owner-detail, and spot-768 / spot-1024 / spot-1100 of the Roadmap task bar.

#### 4.16 Design assumptions and evidence limits

- The template supplies, per item: stable id, student prompt, `response_lang` (es|en|mixed|absent), required flag, and for practice an ordered list of response parts. The client never parses "(1)…(2)…" at runtime.
- The `get_lesson_task` completed indicator and the batched `/learn` summary call are server additions the design needs. They are specified in PR A and PR C of this plan.
- The recorded state requires the progress write to expose `completed_at` to the hook. This is a small change to the existing client progress function.
- The Success checklist is read-only self-check text with no persisted checkbox state.
- Counts, nav badge, and unseen state resolve on page load and navigation (no realtime channel).
- Chrome copy ships in English with `site_content` keys. Spanish values come from the owner via `site_content`.
- The two breakpoint literals (56.24rem week-detail, 48rem feedback and workspace) are both intentional.
- Cards and Files tabs on mobile show no primary while a task is actionable. This is accepted.
- The WeekCard chip, "Jump to review", and "Next awaiting review" are director additions beyond the originally named surfaces.
- Sample prompts are PLACEHOLDER. No curriculum text was invented.
- Evidence: the director read `LessonContentView.tsx`, `lessonContent.ts`, `WeekDetailPage.tsx` lines 960-1090, `LearnDetailPage.tsx` lines 1-340, `SignOutGuardContext.tsx`, `Modal.tsx`, `OwnerFeedbackPage.tsx`, `OwnerDashboardPage.tsx`, `Field.tsx` lines 86-97 and 134, `weekDetailBreakpoint.ts`, `LessonContentView.css` line 382, `LessonCompletionControl.tsx` lines 20-125, `useLessonCompletion.ts` lines 20-146, and the #174 plan section 4. Reviewer claims about `learnMaterials.ts` 46-51, `LearnDetailPage` line 258, `WeekDetailPage` 1436, and the `useRoute`/`App`/`AdminShell` touchpoints were taken from the planner message and not re-read by the director (T1 re-verifies in Step 0). No rendered screenshots or live validation were run; the independent design-reviewer pass is recorded above.

The handoff's unresolved decisions are tracked in Section 12 (Decisions AD1 to AD7 map to its items 1 to 7).

## 5. Judge route

- **Risk:** high (new security-definer RPCs, RLS, owner-only data separation, completion gating).
- **Call cap:** 4, with one checkpoint repeat inside the cap. Extra calls need user approval. Deterministic failures dominate. Finding IDs from any judge pass flow into the engineering jobs and into Verifier checks. No model-generated finding is reproduced here beyond the dispositions in the Plan revision 1 table.
- **Accounting:** PLAN_DUCK used 1 of 4 (high-risk cap); CODE_REVIEW #1, CODE_REVIEW #2 and one optional VISUAL_REVIEW or repeat remain.
- **PLAN_DUCK:** ran once in shadow/advisory mode on the first draft (result REVISE; revision 1 applied, see the table near the top). Rubric J-179-PLAN: no student path to owner-only data; grandfathering never clears an existing `completed_at`; the completion gate cannot be bypassed by any student-callable path (`record_lesson_progress`, `record_lesson_completion`, sync paths); PR sequencing keeps main releasable; Browser UI inputs complete.
- **CODE_REVIEW #1 after PR A:** required. Rubric J-179-SEC: security definer `search_path`, grants and revokes, `auth.uid()` binding, canonical eligibility parity with `record_lesson_completion`, no answer key or model answer in any student payload or student-readable artifact, server-side validation, optimistic concurrency, RLS on all new tables.
- **CODE_REVIEW #2 after PR C:** required. Rubric J-179-COMPLETION: gate integration in both RPCs, mirror not written when gated, finalize-on-review atomicity, grandfathering, owner override semantics, #180 extension point, client never fabricates completion.
- **VISUAL_REVIEW:** optional, on 390/1440 screenshots against the design handoff in Section 4 (uses the 4th call if no repeat was needed).
- **Rubric additions from revision 1:** J-179-SEC also covers internal-function privilege lockdown (J-179-PLAN-001) and plain-text rendering of user-supplied fields (J-179-PLAN-003); J-179-COMPLETION also covers the cutover definition and every sync and materialization path (J-179-PLAN-002) and activity-event attribution (J-179-PLAN-004).

## 6. Ordered work

Owner: engineering-fleet, standard mode. T1 first line, Verifier after each PR, Browser Validator after PR B and PR C; T2 on two counted gate failures.

THREE PRs, one per phase, merged in order A, B, C, each on a new branch from the then-current `origin/main`. Main stays releasable after each merge because the completion gate is wired only in PR C. Production rollout happens only after PR C as one user-gated hosted release.

### Step 0. Preflight (T1, each PR)

- Fresh worktree from `origin/main`. For PR A, confirm #174 (PR #195, migration `202610040002`) has merged before branching; PR B and PR C branch from `main` after their predecessor merges. Re-verify every F-line reference, including `LearnDetailPage` (materials block) and `learnData` after #174.
- Re-check the latest migration timestamp on `main`; every #179 migration must sort after `202610040002` (use `2026100400xx` or later).
- Confirm #176 and #178 are present, and whether #174, #175, and #180 have landed (stale-plan check).
- PR C only: confirm that `materialize_enrollment_entitlements` never sets `completed_at` (F13 inference) and add the test.
- Run `npx supabase start` FROM the target worktree (the Edge runtime mounts the worktree that started the stack; otherwise `npx supabase stop` then start).
- Run `npx supabase db reset`, then `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`.
- Confirm band names and 78 lessons. Confirm `fullaccess@test.local` has entitlements and `/learn` renders cards.

### PR A. Data model, RPCs, RLS, answer-key separation, content pipeline

No completion behavior change; no UI except unchanged rendering of stripped text.

**A1. Content audit** (T1 runs a deterministic audit script; Scribe drafts wording; owner gate).

- `scripts/audit-translation-answers.ts` lists every `translationTask` with "**Answer:**" (expected 61 modules, ~224) and flags unmarked inline-answer candidates (for example "→", "Answer", "(Accept", equals-mappings) into a tracked report `docs/evidence/issue-179/translation-answer-audit.json`.
- For each flagged unmarked item, Scribe drafts a rewritten student prompt plus an answer-key text (no new curriculum claims). T1 applies the approved rewrites to `content-source/<band>WeekNN.ts` AND `curriculum/lessons/<band>-week-NN/phrases-and-qa.md` (keeping parity with the Python regenerator in `tools/lesson-generation`) by inserting the "**Answer:**" marker convention so the generator can split.
- Gate: user/owner reviews the rewrite list (Decision D1) before merge. Every `translationTask` must end the audit as either "no answer" or "marked".

**A2. Split at generation** (T1, TDD).

- No content-source schema change and no `LessonContent` type change (`lessonContent.ts` stays; `translationTask` becomes prompt-only in generated JSON).
- A shared pure function `splitTranslationTask(text)` returns `{prompt, answerKey|null}` with a strict grammar: exactly zero or one "**Answer:**" marker; the marker must be inside `translationTask`; text after the marker is the key; the prompt is trimmed; it fails loudly on any other "Answer:" pattern.
- `scripts/generate-lesson-content-json.ts` emits the stripped prompt (`validateGeneratedLessonContent` updated so the only allowed difference from the module is the stripped `translationTask`). Regenerate all 78 `lesson-content.json` (must write exactly 78; non-`translationTask` fields deep-equal to before). Content-source keeps answers (instructor source, outside `src`, never bundled).

**A3. Template generator** (T1, TDD).

- Promote the #178 parser to `scripts/lib/parsePracticeActivity.ts` and re-export it from `src/__tests__/helpers/parsePracticeActivity.ts` (keep #178 tests green).
- `scripts/generate-lesson-task-templates.ts` reads the 78 content-source modules and 78 `practice-activity.md` and builds per lesson (`content_key` '<band>-week-NN'):
  - Items: one translation item per phrase group `{id 'tg-<groupId>', kind 'translation', title, student_prompt (stripped), response_lang 'mixed' by default with an optional override map, parts [{id 'answer', max_chars 4000, required true}]}`, plus one practice item `{id 'practice', kind 'practice', title, summary, student fields Scenario/Your role(s)/What to write/Length and format/Register and dialect/Use these phrases/Success checklist[], parts}`. Practice parts: one per "(n)" numbered part in What to write (1-6, each max 8000 chars), else one 'answer' part.
  - Owner-only key per lesson: translation answer keys by item id (nullable) plus practice model answer plus success checklist copy.
- Deterministic output (stable ordering, sha256 `content_hash` per template). It emits `supabase/migrations/<ts>_issue179_seed_lesson_task_templates.sql` (idempotent upsert keyed by (`content_key`, `content_hash`); a changed hash inserts version n+1 and retires the prior active row).
- A drift test regenerates in memory and asserts the committed migration is byte-identical.
- Coverage test: 78/78 templates, each with at least 1 translation item, exactly one practice item with 1-6 parts, all eight Task prompt fields parsed, model answer non-empty.

**A4. Schema migration** `<ts>_issue179_lesson_tasks.sql` (timestamp after the latest on main), forward-only, create-or-replace and additive; plus an unapplied rollback file `supabase/rollbacks/issue179_lesson_tasks_rollback.sql` (precedent #176).

- `lesson_task_templates(id uuid pk, content_key text not null, version int not null, status text check in ('active','retired'), template jsonb not null (student-safe fields only), content_hash text not null, created_at; unique(content_key, version); partial unique (content_key) where status='active')`.
- `lesson_task_answer_keys(template_id uuid pk references lesson_task_templates on delete cascade, answer_key jsonb not null)`: owner-only.
- `lesson_task_submissions(id uuid pk, enrollment_id uuid not null references student_enrollments on delete cascade, lesson_revision_id uuid not null references lesson_revisions on delete restrict, template_id uuid not null references lesson_task_templates on delete restrict, template_version int not null, responses jsonb not null default '{}', status text not null check in ('draft','submitted','returned_for_revision','reviewed'), revision int not null default 1 (optimistic lock), attempt_no int not null default 0, submitted_at, returned_at, reviewed_at, reviewed_by uuid references auth.users on delete set null, teacher_feedback text (<=4000), score int null check 0..100, student_seen_feedback_at timestamptz, created_at, updated_at; unique(enrollment_id, lesson_revision_id))`.
- `lesson_task_submission_attempts(id, submission_id references lesson_task_submissions on delete cascade, attempt_no, responses jsonb (snapshot at submit), submitted_at, decision text null check in ('reviewed','returned_for_revision'), teacher_feedback, score, decided_at, decided_by; unique(submission_id, attempt_no))`. The owner reads submitted text ONLY from attempts, never the live responses (which may hold in-progress edits after a return).
- `enrollment_lesson_entitlements` gains `student_marked_complete_at timestamptz null` (additive; set only by PR C).
- RLS enabled on all four tables. Revoke all from anon and authenticated on templates, answer keys, and attempts. Students: SELECT own `lesson_task_submissions` only (policy: exists own active enrollment AND `is_account_active(auth.uid())` AND not `user_requires_password_change()`); no INSERT/UPDATE/DELETE grants. service_role full grants. Indexes: submissions(status, submitted_at desc, id desc), submissions(enrollment_id), attempts(submission_id).
- **Internal and owner function privileges (J-179-PLAN-001).** `resolve_lesson_task_template`, `review_lesson_task_submission`, `edit_lesson_task_review`, and (PR C) `lesson_completion_blockers` and `finalize_lesson_completion` are each SECURITY DEFINER with `set search_path = public`, `revoke all on function ... from public, anon, authenticated`, and `grant execute ... to service_role` only (precedent `202610030001` lines 127-128 and 181-182). Student RPCs call them internally; template resolution for students happens only inside the guarded student RPCs.
- Template resolution function `resolve_lesson_task_template(p_lesson_revision_id)` (definer, service_role only, per the privilege rule above): `lesson_revisions.legacy_lesson_id` to `lessons(band_id, week_number)` to `bands.name` to `content_key` to the active template; NULL for authored (non-legacy) lessons.
- **Student RPCs** (security definer, `set search_path=public`, revoke from public/anon, grant execute to authenticated). All apply: `auth.uid` not null; not `user_requires_password_change()`; `is_account_active(auth.uid())`; own enrollment status 'active'; entitlement exists and `manual_release_state` not in ('held','revoked') and (released or `unlock_at<=now()`) (the canonical #176 rule); template resolvable; otherwise fail closed.
  - `get_lesson_task(p_enrollment_id, p_lesson_revision_id)` returns jsonb or NULL: student-safe template, own submission (status, responses, revision, `attempt_no`, timestamps, latest feedback and score, earlier feedback list), `mark_recorded_at` (entitlement `student_marked_complete_at`), `completed_at`, grandfathered flag (entitlement `completed_at` not null AND `completed_at < cutover_at` AND no submission row; `cutover_at` is read from `completion_gate_settings`, which PR C creates; C1 create-or-replaces `get_lesson_task` and `get_lesson_task_summaries` to compute the flag this way, and no student UI consumes the flag before PR C), unseen flag. NEVER answer keys or model answers.
  - `get_lesson_task_summaries(p_enrollment_id)` returns a jsonb array per eligible templated lesson `{lesson_revision_id, legacy_lesson_id, status, unseen, mark_recorded_at, completed_at, grandfathered}`.
  - `save_lesson_task_draft(p_enrollment_id, p_lesson_revision_id, p_responses jsonb, p_expected_revision int)` returns jsonb `{status, revision, saved_at}`. Allowed when no row, draft, or `returned_for_revision` (stays returned until resubmit) and `entitlement.completed_at` is null. Keys must be a subset of template part ids, values strings at most 20000 chars, total payload cap (for example 200 KB). Revision mismatch gives a distinct conflict result. Never allowed on submitted or reviewed.
  - `submit_lesson_task(same args)` returns jsonb `{ok, field_errors[] | status, revision, attempt_no}`. Validates every required part non-empty after trim and `char_length` at most the part max (4000/8000). On failure returns `field_errors` without state change. On success status 'submitted', attempt snapshot row, `submitted_at`. Allowed only from none, draft, or `returned_for_revision`.
  - `mark_lesson_task_feedback_seen(p_enrollment_id, p_lesson_revision_id)` is idempotent.
- **Owner SQL** (service_role only, called by Edge after the owner gate): `review_lesson_task_submission(p_submission_id, p_decision 'reviewed'|'returned_for_revision', p_feedback, p_score, p_expected_revision, p_owner_id)` requires status 'submitted' and a matching revision; writes the decision onto the latest attempt and the submission; 'reviewed' sets `reviewed_at`/`by`. Activity events via `record_activity_event_with_actor` per the event contract in C1 ('lesson_task_submitted' actor student; 'lesson_task_reviewed' and 'lesson_task_returned' actor owner). In PR A the review function only records the decision; PR C adds finalize-on-review. `edit_lesson_task_review` (if the adopted default "edit review" holds) updates feedback and score of a reviewed submission without changing status or completion.

**A5. Leak guards** (T1). Extend `scripts/check-no-lesson-content-leak.js` (or add `scripts/check-no-answer-leak.ts` wired into `verify:build`) to:

- (i) fail if any storage-seed `lesson-content.json` `translationTask` contains "**Answer:**" or any normalized answer-key or model-answer string of at least 12 chars from the generator output;
- (ii) scan `dist/` for answer-key and model-answer fingerprints (all 78 lessons);
- (iii) report-only text extraction of the 78 student-handout PDFs and instructor PPTX for answer-key strings (expected 0 translation keys; recap answers are #180 and excluded with a documented reason).

**A6. Tests** (T1).

- Live SQL/RLS suites (vitest against the reset local stack, exact URL guard `http://127.0.0.1:54321`): every guard negative case separately (other student's enrollment, inactive enrollment, deactivated account, password-change flag, held, revoked, future unlock, unauthenticated, authored lesson returns NULL, no template returns NULL); students cannot select answer keys, templates, attempts, or other students' submissions; cannot insert, update, or delete submissions directly; state machine transitions (draft to submitted; submitted not editable; returned to draft edits to resubmit; reviewed terminal); validation errors per field; conflict on stale revision; 20000-char draft cap; `char_length` counting with accents and emoji; `get_lesson_task` payload contains no sentinel answer strings.
- Live privilege tests (J-179-PLAN-001), matching the pattern in `src/__tests__/issue176-completion-foundations-sql.test.ts` ~541-547: for each internal or owner function created in this PR (`resolve_lesson_task_template`, `review_lesson_task_submission`, `edit_lesson_task_review`), `has_function_privilege` (and `pg_proc` ACL) is false for `anon` and `authenticated` and true for `service_role`. Direct-invocation negative tests as `anon` and as an authenticated student (permission denied) for held, revoked, future-unlock, unrelated-lesson, and other-student cases.
- Activity-event tests: exactly one correctly attributed `lesson_task_submitted` event per successful submit and none on a failed or denied submit.
- Unit tests: `splitTranslationTask` grammar, generator coverage 78, drift test, parser parity.

**A7. Verification.** `type-check`, `lint`, full vitest, `verify:build` (including the new leak guard), `check:practice-complete`; Verifier; CODE_REVIEW #1.

### PR B. Owner review (depends on A merged)

**B1. Edge actions** in `supabase/functions/admin-student-operations/index.ts` (owner gate, service-role client, `isValidUUID`, `classifiedErrorResponse`, `listAllAuthUsers` patterns):

- `task-submissions-inbox`: payload `status` in awaiting_review|returned_for_revision|reviewed|in_progress|all (default awaiting_review); `band_id` or course filter; page; 25 per page newest first; rows: id, student email, band, week, lesson title, status, `attempt_no`, `submitted_at`. `in_progress` rows are status-only, never responses.
- `task-submissions-count`: awaiting review count for nav and dashboard.
- `task-submission-detail`: submission plus student-safe template plus owner-only answer key plus all attempts' submitted snapshots plus feedback history. Drafts return 404 or status-only; never live draft responses.
- `task-submission-review`: decision, feedback, score, `expected_revision` to `review_lesson_task_submission`. Validation: feedback required per the adopted default, at most 4000; score integer 0-100 or null.
- `task-submission-edit-review`.
- `handleDashboard` adds attention reason 'awaiting_review' per enrollment with submitted rows and a summary count. `handleGetStudentDetail` adds per-enrollment submissions (lesson, status, dates, id; drafts status-only). `handleWipeSave` also deletes the enrollment's task submissions (Decision D5 default yes); unassign/preserve keeps them. `course-authoring` `list_lesson_entitlements` adds task status per lesson (status only).

**B2. Owner UI per the design handoff.**

- Routes `/admin/submissions` (list-only, query-string filters) and `/admin/submissions/:submissionId` (full width; prompt | student answer | owner-only reference; "Owner only: never shown to students"; "No reference answer for this item."; Earlier attempts disclosure; `ReviewForm` with "Mark reviewed" primary and "Return for revision" caution-reversible; Jump to review; Next awaiting review).
- Nav "Submissions" with count (`AdminShell`, `MobileNav`); routing touchpoints (`useRoute` matchers, `App` `knownAdminRoute`, query listener).
- `OwnerDashboardPage` `describeAttentionReason` 'awaiting_review' plus quiet strip line; `AdminStudentsPage` submissions list; `CourseWorkspacePage` roster chips.
- `SubmissionLedgerRow` new (`FeedbackLedgerRow` untouched, plus non-regression test). `LessonTaskStatusChip` and `LessonTaskFeedbackCard` are built here as shared components.

**B3. Tests.** Edge tests (non-owner 403; malformed ids; drafts never expose text; answer key only in owner detail; review state machine including stale revision conflict; feedback validation; score bounds; wipe-save deletes submissions; exactly one correctly attributed `lesson_task_reviewed` or `lesson_task_returned` event per successful review and none on a failed, stale, or denied review), RTL tests, Playwright owner journeys (seeded submissions via service-role test setup). Deterministic no-native-dialog source scan. Deterministic source scan for `dangerouslySetInnerHTML` in the new and changed components (J-179-PLAN-003). RTL and Playwright tests with payloads `<img src=x onerror=alert(1)>`, `<script>alert(1)</script>`, `javascript:alert(1)`, `[link](https://example.com)`, and a bare URL, asserting each renders as inert literal text (no element created, no link, no dialog) in owner list, detail, student-detail, and roster. Verifier; Browser Validator (owner journeys 5, 7, 10 at 390 and 1440).

### PR C. Student form and completion integration (depends on A and B merged)

**C1. Completion gate migration** `<ts>_issue179_completion_gate.sql` (create or replace; rollback file updated).

- New definer function `lesson_completion_blockers(p_enrollment_id, p_lesson_revision_id) returns text[]`, the #180 extension point. It returns 'task_review' when an active template resolves for the revision and the enrollment's submission is not 'reviewed'. #180 adds 'quiz_pass' by create-or-replace of this one function (documented contract; `completion_rule` column semantics unchanged and not relied on). Evaluated ONLY when `entitlement.completed_at` is null, so existing completions are never touched (no backfill, no clearing).
- **Cutover marker (J-179-PLAN-002).** The C1 migration creates a single-row table `public.completion_gate_settings(id boolean pk default true check (id), cutover_at timestamptz not null)`, set to the migration's `now()`; read by service_role only (revoke from anon and authenticated). Grandfathering is defined precisely as: an entitlement with `completed_at` not null at cutover (never touched), plus any `student_lesson_progress.completed_at < cutover_at` (a pre-deployment record that may still be synced later for not-yet-materialized or preserved enrollments). The "grandfathered" flag in `get_lesson_task` and `get_lesson_task_summaries` is: entitlement `completed_at` not null AND `completed_at < cutover_at` AND no submission row.
- **Sync path gating.** `sync_enrollment_completions` (create or replace) copies a progress completion into the entitlement ONLY when `progress.completed_at < cutover_at` OR `lesson_completion_blockers(enrollment, revision)` is empty. It never sets the mirror for a gated row (the entitlement-to-progress direction already reads only gated entitlement completions) and still never clears anything. `sync_legacy_completion_to_entitlement` is gated the same way, or folded into `finalize_lesson_completion`. This covers every F13 caller: the `record_lesson_progress` lazy path, `resume_band_enrollment`, the backfill migration, and `seed.sql`.
- **Activity-event contract (J-179-PLAN-004).**
  - `set_lesson_completion` keeps its existing `lesson_completion_set` event (actor `p_owner_id`); its payload gains `bypassed_blockers` (text[] from `lesson_completion_blockers` at the time of the override, empty when none) and `source: 'owner_override'`.
  - `reset_lesson_completion` gains `p_actor_id uuid`. The Edge `handleResetLessonCompletion` passes `userData.user.id`, which requires threading `ownerId` into that handler as `handleUpdateDashboardSettings` already does. The event records actor `p_actor_id` with payload `source: 'owner_reset'`. T1 chooses between dropping the old signature and keeping it as a wrapper, and tests both grants.
  - Review events: `lesson_task_submitted` (actor student), `lesson_task_reviewed` and `lesson_task_returned` (actor owner; payload `submission_id`, `attempt_no`, and a boolean `score_present`), and `lesson_completion_finalized_on_review` (actor owner; payload `enrollment_id`, `lesson_revision_id`).
- `record_lesson_completion` and `record_lesson_progress('complete')`: after the existing guards, set `student_marked_complete_at = coalesce(existing, now())`. If blockers are non-empty: do NOT set `completed_at`; do NOT call `sync_legacy_completion_to_entitlement`; do NOT write `student_lesson_progress.completed_at` (`record_lesson_progress` still writes open timestamps); do NOT grant dependents or recalculate; return `completed_at` NULL. Else the existing path is unchanged.
- Shared internal `finalize_lesson_completion(enrollment, revision)` used by both RPCs and by `review_lesson_task_submission`: when decision is 'reviewed' and `student_marked_complete_at` is not null and `completed_at` is null and blockers are now empty, set `completed_at`, mirror, grant dependents, `recalculate_course_version_completion`, and write the activity event, all in the same transaction.
- Owner `set_lesson_completion` and `reset_lesson_completion`: unchanged semantics (owner override completes regardless of blockers, Decision D3 default; reset clears completion; a later student mark re-applies the gate). Sync paths remain set-only; add a test that after deploy no student-callable path sets `completed_at` or the mirror while blockers exist.

**C2. Client completion.** `useLessonCompletion` gains recorded state (hydrated from `get_lesson_task` `mark_recorded_at`; set when a 'complete' write returns `completed_at` NULL; never completed, `justCompleted`, or Stamp). `LessonCompletionControl` recorded label "Mark recorded", disabled, `describedById`; desktop plain button unchanged (never primary); mobile footer tier, label, and `aria-describedby` per design. `LearnDetailPage` never fabricates `completed_at` nor increments the count on NULL; `markLessonComplete` returns `completed_at` null for intent.

**C3. Student UI per the design handoff.**

- `LessonTaskProvider`/`useLessonTask` (one per page), `LessonTaskItem` (embedded|standalone), `LessonTaskBar`, `AccentStrip`, completion overlay note, error summary, submit Modal ("Submit final answers") via existing `Modal.tsx`, "Leave without saving?" Modal, autosave (2000 ms, blur, keepalive on `pagehide`/`visibilitychange`), async-aware SignOutGuard extension, `navigate()` guard.
- Roadmap: `WeekDetailPage` resolves legacy to revision via `getEnrollmentCompletion`, one `get_lesson_task` call, NULL renders exactly as today; `LessonContentView` permitted DOM deltas only (translation chunk prompt plus fieldset, practice dl plus fieldsets, task bar plus note between panels and completion control).
- `/learn`: `get_lesson_task_summaries` batched, card chip plus task link, one-primary rule over the eligible-and-not-completed set, new route `/learn/:enrollmentId/lessons/:lessonRevisionId/tasks`; `WeekCard` compact chip; unseen clear via `mark_lesson_task_feedback_seen` when the feedback card is visible (EN-1); `site_content` keys `lesson_task.*` with English defaults.

**C4. Tests.**

- SQL live tests for the gate: mark before review returns NULL plus intent; review finalizes atomically; mark after review completes immediately; grandfathered completed lessons unchanged after migration; templateless and authored lessons unchanged; owner override; reset then re-mark; mirror never written while gated; dependents granted only on finalize; recalculate enrollment completion.
- Sync-path regression tests, direct and indirect (J-179-PLAN-002): direct call of `sync_enrollment_completions` with a post-cutover progress completion on a gated lesson (no entitlement completion results); the same via the `record_lesson_progress` lazy materialization path; via `resume_band_enrollment` of a preserved enrollment; a pre-cutover progress completion still syncs (grandfathered); a `seed.sql` reset still yields the expected fixture completions; `materialize_enrollment_entitlements` never sets `completed_at`; `sync_legacy_completion_to_entitlement` is gated the same way.
- Privilege tests for `lesson_completion_blockers` and `finalize_lesson_completion` (same pattern as PR A: no execute for `anon` or `authenticated`, execute for `service_role`; direct-invocation denial), and for `completion_gate_settings` (not readable by `anon` or `authenticated`).
- Activity-event tests (J-179-PLAN-004): exactly one correctly attributed event per successful action and none on a failed or denied action, covering `set_lesson_completion` (`bypassed_blockers`, `source: 'owner_override'`), `reset_lesson_completion` (actor equals `p_actor_id`, `source: 'owner_reset'`, both signatures' grants if the wrapper is kept), `lesson_completion_finalized_on_review`, and the review events.
- Unit and RTL: one-primary per state, recorded state, no fabricated date, desktop DOM byte-identical for templateless/ineligible/grandfathered via snapshot; `lessonContentViewDesktopVisualNonRegression` updated only for permitted deltas; footer geometry test unchanged for templateless; SignOutGuard `/feedback` test kept.
- Playwright full student, owner, student journeys at 390 and 1440 (design journeys 1-15), deterministic no-native-dialog source scan.
- Plain-text rendering (J-179-PLAN-003): deterministic source scan for `dangerouslySetInnerHTML` in the new and changed components, plus RTL and Playwright tests with the payloads `<img src=x onerror=alert(1)>`, `<script>alert(1)</script>`, `javascript:alert(1)`, `[link](https://example.com)`, and a bare URL, asserting inert literal text (no element created, no link, no dialog) in the student task views (Roadmap and `/learn`, including the feedback card).
- Verifier; Browser Validator; CODE_REVIEW #2; optional VISUAL_REVIEW.

### Hosted and production (SEPARATE, USER-GATED; not covered by plan approval; after PR C merged)

- H1: apply the three migrations to hosted project `gvobtuhbpqvfhjljjcye`.
- H2: deploy Edge functions `admin-student-operations` and `course-authoring`.
- H3: re-provision the 78 stripped `lesson-content.json` objects with `scripts/provision-lessons.ts` hosted guards and #173 content-type behavior.
- H4: hosted read-only verification (78 active templates resolve; zero "**Answer:**" in hosted `lesson-content.json` `translationTask`; answer-key tables not readable by authenticated).
- H5: Netlify deploy.

Order H1, H2, H3, H4, H5. Each needs explicit go-ahead naming the project. Coordinate migration ordering with #174 Step 5 and #180 migrations.

### Follow-ups (text drafts only; GitHub writes user-gated)

- `completion_rule` 'manual' and 'quiz_pass' are not enforced by student RPCs (for #180).
- Optional student reveal of model answers after review (if wanted later).

## 7. Interfaces and data

- **New tables:** `lesson_task_templates`, `lesson_task_answer_keys`, `lesson_task_submissions`, `lesson_task_submission_attempts`. **New column:** `enrollment_lesson_entitlements.student_marked_complete_at`.
- **New student RPCs:** `get_lesson_task`, `get_lesson_task_summaries`, `save_lesson_task_draft`, `submit_lesson_task`, `mark_lesson_task_feedback_seen`.
- **New service-role functions:** `resolve_lesson_task_template`, `review_lesson_task_submission`, `edit_lesson_task_review`, `lesson_completion_blockers` (#180 extension point), `finalize_lesson_completion`.
- **Changed (PR C):** `record_lesson_progress` and `record_lesson_completion`; return shapes unchanged, `completed_at` may be NULL after 'complete'.
- **New Edge actions:** `task-submissions-inbox`, `task-submissions-count`, `task-submission-detail`, `task-submission-review`, `task-submission-edit-review`. **Extended:** dashboard, student-detail, wipe-save, `list_lesson_entitlements`.
- **Generated artifacts:** 78 regenerated `lesson-content.json` (`translationTask` stripped), template seed migration, audit report `docs/evidence/issue-179/translation-answer-audit.json`.
- **Unchanged:** `LessonContent` type shape, content-source schema, `get_student_learn_course`, resources/storage RLS, PDF/PPTX.
- **Retention:** submissions and attempts cascade with the enrollment (and so with student deletion); wipe-save deletes them; `reviewed_by` set null on owner deletion; templates and answer keys retained (restrict while referenced).
- **Compatibility:** legacy clients calling `record_*` still work; returned `completed_at` may be NULL for templated lessons after PR C.

## 8. Acceptance checks

- 78/78 templates generated and seeded locally after `db reset`; each resolves via `resolve_lesson_task_template` for the legacy revision; drift test byte-identical.
- Zero "**Answer:**" and zero answer-key strings in all 78 storage-seed `lesson-content.json`; the translation audit report shows every task "no answer" or "marked" (owner-approved rewrites applied); dist scan clean for answer fingerprints; PDF/PPTX extraction report shows no translation answer keys.
- `get_lesson_task` and summaries payloads never contain sentinel owner-only strings (test with sentinel fixtures); students cannot read templates, answer keys, attempts, or other students' submissions; no direct writes.
- All guard negative cases return NULL or access denied generically; validation per field; conflict on stale revision; draft cap 20000; submit limits 4000/8000 by `char_length`.
- Owner: inbox defaults to awaiting review, 25 per page; detail shows prompt | student answer | owner-only reference; drafts status-only; return requires feedback; score 0-100 optional; dashboard 'awaiting_review'; student detail and roster show status.
- Function privileges (J-179-PLAN-001): every internal or owner function has no execute for `anon` or `authenticated` and execute for `service_role` only (live privilege tests), and direct invocation as `anon` or as an authenticated student is denied for held, revoked, future-unlock, unrelated-lesson, and other-student cases.
- Plain-text rendering (J-179-PLAN-003): no `dangerouslySetInnerHTML` in new or changed components (source scan in PR B and PR C), and the XSS payload set renders as inert literal text in RTL and Playwright.
- Activity events (J-179-PLAN-004): exactly one correctly attributed event per successful action and none on a failed or denied action, with the payloads in C1.
- Grandfathering and sync (J-179-PLAN-002): the cutover definition in C1 holds; a post-cutover progress completion on a gated lesson never creates an entitlement completion through any F13 path; a pre-cutover one still syncs.
- Completion: grandfathered completions unchanged (count of `completed_at` identical before and after migration on a seeded fixture with prior completions); mark-before-review records intent and returns NULL; review finalizes atomically; mark-after-review completes immediately; no student path completes a gated lesson; client never fabricates completion; #180 can add a blocker by replacing `lesson_completion_blockers` only.
- UI: design journeys 1-15 at 390x844 and 1440x900 plus spot checks (320, 320x256 at 400% zoom, 768, 1024, 1100, forced-colors, reduced-motion); exactly one `.control--primary` per view and state; desktop `LessonContentView` byte-identical for templateless, ineligible, and grandfathered; `RHYTHM_SEGMENTS` 30/10/20 unchanged; axe zero critical or serious; no horizontal scroll at 390 and 320.
- `npm run type-check`, `lint`, full vitest (live suites against reset local stack), `verify:build`, `check:practice-complete`, targeted Playwright (new specs plus existing wp10, wp11, phase5 learn, gap-3) green; Verifier PASS per PR; Browser Validator PASS after PR B (owner) and PR C (full); CODE_REVIEW #1 and #2 with no unresolved blocking finding.

## 9. Browser UI dialog policy and browser validation inputs

**Dialog policy (required).** The Browser UI invariant applies (web app and Electron shell). No `alert`, `confirm`, `prompt`, `window.alert`/`confirm`/`prompt`, or `beforeunload`. Only app-owned Modals via `src/components/Modal.tsx`: "Submit final answers" and "Leave without saving?" (focus trap, Escape except while submitting, focus return). Inline validation with an error summary. Unsaved-change protection via `SignOutGuardContext` (async-aware extension) and a `navigate()` guard; no `beforeunload`. A deterministic source scan is required in PR B and PR C (grep `src` for `\b(window\.)?(alert|confirm|prompt)\s*\(` and `beforeunload`) plus a runtime no-native-dialog check in Playwright.

**`browser_ui_validation` inputs.**

- **Launch and readiness:** `npx vite --port 5179 --strictPort` (ready when `http://localhost:5179` serves the sign-in page).
- **Base URL:** `http://localhost:5179` (Playwright `E2E_BASE_URL=http://localhost:5179`).
- **Fixture and reset:** `npx supabase db reset`, then `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`. For Edge changes run `npx supabase stop` and `npx supabase start` from the target worktree (the edge runtime mounts the worktree the stack started from).
- **Accounts** (password `password`): `fullaccess@test.local` (primary student), `student1-6@test.local` (isolation, held/revoked, several-actionable-tasks), `owner@test.local`.
- **Per-journey states** (held, revoked, future unlock, grandfathered completion, submissions in each status, sentinel answer strings) are created by service-role test setup on the exact local URL `http://127.0.0.1:54321`, never by product code.
- **Viewports:** 390x844 and 1440x900 (spot checks 320, 320x256 at 400% zoom, 768, 1024, 1100, forced-colors, reduced-motion).
- **Journeys and visible outcomes:** design handoff journeys 1-15 (Section 4.15); screenshots under `browser-validation-artifacts/`.

## 10. Risks and rollback

| ID | Risk | Mitigation and rollback |
| --- | --- | --- |
| R1 | Owner-only data leak (answer keys, model answers, drafts) | Separate tables with no student grants; definer RPCs return student-safe fields only; sentinel leak tests; generator-level strip; dist and storage scans; CODE_REVIEW #1. Rollback: revert the PR; hosted H3 restores previous `lesson-content.json` objects from the prior seed if needed. |
| R2 | Completion gate bypass or wrong grandfathering | Gate evaluated only when `completed_at` is null; both RPCs and the mirror covered; tests for every writer; CODE_REVIEW #2. Rollback: the rollback file restores #176 function bodies (create or replace) and leaves new tables; data-safe because `completed_at` is never cleared. |
| R3 | Students stuck waiting on owner review (operational) | Dashboard attention reason plus nav count; owner override (D3); documented in the release note. |
| R4 | Template and content drift (seed migration versus content, #178 parser changes) | Drift test, parser parity, coverage test; stale-plan trigger. |
| R5 | Unmarked inline answers missed | Audit report plus Scribe and owner review plus heuristic flags; residual risk accepted for the owner-reviewed list only. |
| R6 | Desktop and mobile regressions on `LessonContentView` and `/learn` one-primary | Byte-identical snapshot tests for non-templated cases; permitted deltas enumerated; Browser Validator. |
| R7 | Seed ordering (lessons inserted after migrations locally) | `content_key` resolution at read time; local reset test. |
| R8 | Data loss in drafts (Back/Forward/unmount up to 2 s; network) | Autosave plus keepalive flush plus guarded nav Modal; accepted limit recorded. |
| R9 | Concurrency (two tabs, owner reviewing while student edits after return) | Optimistic revision checks; owner reads attempt snapshots only. |
| R10 | Interaction with #174/#175/#180 work in flight (`LearnDetailPage`, `LessonContentView`, completion RPCs, migration timestamps) | Stale-plan conditions; rebase per PR; #180 uses the blockers extension point. |
| R11 | Hosted ordering (UI before migrations, stale `lesson-content.json` with answers) | H1 to H5 order; H4 verification; production rollout only after PR C. |
| R12 | Local stack drift (edge runtime mounted from another worktree) | Step 0 procedure. |
| R13 | Grandfathering cutover boundary errors (a pre-deployment completion treated as gated, or a post-cutover completion slipping through a sync path) | Single-row `completion_gate_settings` cutover marker; precise definition in C1; gated `sync_enrollment_completions` and `sync_legacy_completion_to_entitlement`; direct and indirect regression tests for every F13 path; seeded-fixture before and after counts; CODE_REVIEW #2. Rollback: the rollback file restores #176 function bodies; `completed_at` is never cleared. |
| R14 | Stored XSS via student responses and teacher feedback | Invariant 16 (escaped plain text nodes, `white-space: pre-wrap` only); `dangerouslySetInnerHTML` source scan in PR B and PR C; RTL and Playwright inert-payload tests; CODE_REVIEW #1 and #2 rubrics. Rollback: revert the PR. |

**Overall rollback:** revert the PR(s) in reverse order (C, B, A); local `npx supabase db reset` restores; hosted steps have their own rollback (rollback SQL file, previous Edge deploy, previous storage objects).

## 11. Stale-plan conditions

The writer must return a blocker ("Plan stale") if any of the following holds:

- `origin/main` changes `record_lesson_progress`, `record_lesson_completion`, `set_lesson_completion`, `reset_lesson_completion`, `sync_enrollment_completions`, `get_enrollment_lesson_completion`, `enrollment_lesson_entitlements`, `LessonContentView`, `LearnDetailPage`, `WeekDetailPage` completion wiring, `useLessonCompletion`, `admin-student-operations` dashboard/student-detail/wipe-save, or the #178 Task prompt contract or parser.
- #180 lands first with its own completion integration.
- #174 (PR #195) changes `LearnDetailPage` or `learnData` in ways that conflict with the card chip and task-link placement, or a `main` migration after `202610040002` forces a different timestamp order.
- The content-source "**Answer:**" distribution changes materially (61 modules, ~224) or lessons/bands naming changes.
- `seed.sql` lesson insertion moves into migrations.
- Any Decision D1 to D6 or adopted default is answered differently after approval.
- Local reset no longer yields entitlements for band enrollments.

## 12. Assumptions and decisions

**Safe assumptions:**

- Bands are named Beginner, Intermediate, Advanced (verify in Step 0).
- Legacy lessons map to `revision_no` 1 via `legacy_lesson_id` (as #176).
- `response_lang` defaults to 'mixed' for all items unless an override map says otherwise.
- Counts and badges load on navigation (no realtime).
- English UI strings ship first via `site_content` keys.

**Recorded decisions (stated defaults; changeable before approval).** These are not open questions. The user is asked only about conflicts; D1 keeps its default with the owner review of the rewrite list before PR A merges as an approval gate.

- **D1.** Some translation tasks give the answer inside the prompt without an "**Answer:**" marker (for example Beginner Week 1 "Buenos días → Good morning ..."; "→" appears 22 times in 11 lessons). Removing those answers requires rewording the student prompt, a small curriculum content change beyond mechanical stripping. Default: yes, rewrite them (Scribe drafts, the owner reviews the list before PR A merges).
- **D2.** Quiz answers (shown openly in the Q&A segment and in `lesson-content.json`) and weekly-review recap answers stay student-visible after #179, because the approved #175 plan assigns that removal to #180. Default: keep with #180.
- **D3.** Owner manual "mark complete" override and "reset" keep working and bypass the task requirement (logged as activity). Default: yes.
- **D4.** Only lessons that have a task template (the 78 legacy lessons) gain the task requirement; authored-course lessons are unchanged. Default: yes.
- **D5.** "Wipe save" also deletes that enrollment's task submissions. Default: yes.
- **D6.** The #178 plan deferred "showing model answers to students" to #179; the user's decision says owner-only. Default: owner-only (students never see model answers or answer keys; the owner can paste guidance into feedback).

**Adopted defaults** (from design; changeable before approval). These resolve the design handoff's unresolved decisions AD1 to AD7:

- **AD1.** Feedback is required for both "Mark reviewed" and "Return for revision".
- **AD2.** The owner can edit feedback and score after review without reopening or changing completion ("Edit review").
- **AD3.** Grandfathered lessons (cutover definition in C1) with no submission show no task UI (no "Task not required" chip).
- **AD4.** Drafts and submissions bind to the template version at creation, with a dismissible "This task was updated. Refresh to see the latest version" note on unsubmitted drafts. Submitted attempts stay on their original version.
- **AD5.** The owner sees draft status only, never draft text, and students see "Your teacher sees your answers only after you submit."
- **AD6.** Optional score, integer 0-100, shown as "Score: N / 100" only when given.
- **AD7.** English UI first; Spanish via `site_content`, supplied by the owner.

## 13. Approvals

### Approval record

- **Approved:** 2026-10-04, by the user, together with the #180 plan (`docs/plans/lizbeth-spanish-issue180-interactive-quizzes.md`).
- **Decisions approved as recorded:** D1 to D6 (stated defaults) and adopted defaults AD1 to AD7.
- **Covered by this approval:** branches, commits, pushes, and pull requests per item (the user's standing instruction), and merging validated PRs.
- **Not covered (separate explicit go-ahead required after local validation):** every production write, including hosted migrations, key seeding, re-upload of the 78 `lesson-content.json` files, Edge deploys, Netlify deploys, and anything against project `gvobtuhbpqvfhjljjcye`. Each hosted step H1 to H5 needs its own go-ahead naming that project.
- **Retained gate:** D1 owner review of the reworded translation prompts (the rewrite list) before PR A merges.

## 14. Engineering mode and downstream owner

- **Engineering mode:** standard (single-writer, sequential PRs; no extreme advisory team). T1 first line; T2 takes over on two counted gate failures. `team_authorization`: not applicable.
- **Downstream owner:** engineering-fleet (Scribe drafts D1 prompt rewrites and follow-up issue texts).

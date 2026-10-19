# Lizbeth Spanish: Issue #180 Interactive Quizzes (Students Take and Submit Quizzes; Owner Grades and Tracks Results)

Status: APPROVED by the user on 2026-10-04. Cleared for engineering per this plan.

Plan ID: `lizbeth-spanish-issue180-interactive-quizzes`. Task ID: `lizbeth-spanish-issue180-interactive-quizzes`. Route: engineering.

Target repository: `lebobo88/lizbeth-spanish` (local family under `H:\CommandCenter\orchestrator\lizbeth_spanish*`). Build on NEW branches from `origin/main` in fresh worktrees, one branch and one pull request per phase (PR A, PR B, PR C, PR D). The lead reports `origin/main` = `bd551a4`, which includes #171, #173, #174, #175, #176, #177, #178.

**Sequencing.** #180 builds AFTER #179 (`docs/plans/lizbeth-spanish-issue179-lesson-task-form.md`).

- PR A branches from `main` only after #179 PR A merges (shared lesson-content generator, leak guard, content-key resolution).
- PR B (content authoring) follows PR A.
- PR C (owner grading and results) branches after #179 PR B (owner inbox) and #180 PR B merge.
- PR D (student UI, completion integration, artifact stripping) branches after #179 PR C and #180 PR C merge.
- Every #180 migration timestamp must sort after the latest migration on `main` at that PR's Step 0, which includes all #179 migrations.
- Main stays releasable after each merge: no student-visible change and no completion change until PR D. Production rollout is one separate user-gated release after PR D, coordinated with #179's hosted steps.

Planner's read-only reference checkout is `H:\CommandCenter\orchestrator\lizbeth_spanish-175` (branch `feat/issue-175-vocabulary-review-in-app`, contains migrations through `202610040002_issue174_student_course_assets.sql`). The local `origin/main` ref in the main checkout is stale (`efc9b23`). The main checkout `H:\CommandCenter\orchestrator\lizbeth_spanish` is on `release/fjds-course-management-20260915` and must not be used as a base. All line numbers below come from the 175 checkout and are re-verified at each PR's Step 0.

Audience: students (enrolled learners), Lizbeth (owner), engineering fleet (executor), and the user (approver).

GitHub reference: issue `lebobo88/lizbeth-spanish#180` (epic #172), interactive lesson quizzes.

Evidence labels: **Observed** means read at file level in the 175 checkout by Planner. **Inference** is a conclusion drawn from observations. **Assumption** is taken as true until a runtime step verifies it. **Unknown** is not yet established.

Judge accounting: PLAN_DUCK used 1 of 4 calls (shadow/advisory; revision 1 applied); CODE_REVIEW #1, CODE_REVIEW #2, and one optional VISUAL_REVIEW or repeat remain.

---

## Plan revision 1 (PLAN_DUCK shadow, advisory)

`PLAN_DUCK` (Codex) ran in shadow/advisory mode on the first draft and returned REVISE with one major finding, accepted by Planner. This revision was applied once, in place, and adds no scope beyond the disposition below. The design handoff is unchanged (no UX change), so design review was not re-run. Judge call accounting: PLAN_DUCK used 1 of 4 (high-risk cap); CODE_REVIEW #1, CODE_REVIEW #2, and one optional VISUAL_REVIEW or repeat remain.

| ID | Disposition | Summary | Sections changed |
| --- | --- | --- | --- |
| J-180-PLAN-001 (major) | accepted | Hosted rollout reordered: answers are removed from every hosted student-readable artifact and verified clean BEFORE the new quiz UI is exposed; the completion gate activates last; added a hard read-only hosted leak-verification gate and a frontend compatibility requirement; #179 coordination note. | Header (judge accounting), 5, 6 (A5, D2, D4, Hosted and production), 8, 10 (R9), 13 |

---

## 1. Outcome

Each of the 78 legacy lessons' quiz becomes an interactive quiz that the student takes and SUBMITS on both the Roadmap (`WeekDetailPage` Q&A segment) and `/learn`, through one shared component.

- Auto-graded types: true/false, fill-in, single-answer multiple choice, select-based matching. Teacher-graded type: open-ended.
- Policy: 3 attempts, best score counts. Per-item correctness (correct, incorrect, awaiting teacher) is shown immediately after each graded attempt.
- Correct answers and explanations are revealed only after a pass, or after the fully graded final attempt, through an eligibility-checked reveal RPC. Answer keys never reach the client before that.
- Passing completes the lesson once the other requirements are done (student Mark recorded, #179 task submitted and reviewed).
- The owner (Lizbeth) sees scores, attempts, per-item results, and a pending-review queue for teacher-graded items inside progress tracking.
- Answer text is removed from every student-readable artifact: `lesson-content.json` quiz answers, `weekly-review-recap.md` self-test answers, and instructor PPTX and handout PDF per decision U2.

## 2. Scope and non-goals

**In scope (user decisions final):**

- (a) Data model, revised grading RPC, reveal RPC.
- (b) Teacher-graded flow.
- (c) Completion integration through #179's blocker function and sync paths.
- (d) Content pipeline: quiz parser fix, curriculum-reviewed authoring pass over all quiz items, student-safe `lesson-content.json`, server-only key seed, recap answer strip, leak guards.
- (e) Student quiz UI as a shared component on Roadmap and `/learn`.
- (f) Owner results and grading UI.
- (g) Accessibility, the Browser UI invariant, tests.
- (h) Four reviewable PRs, plus separate user-gated production steps.

**Non-goals:**

- Authored-course (non-legacy) lessons and their `assessment_answer_keys` path. Enforcing `completion_rule` 'quiz_pass' or 'manual' for authored lessons is a follow-up.
- Audio, partial credit, owner "reset attempts" (v1 recovery is the existing owner completion override), reopening finalized grades.
- Server-side drafts of unsubmitted quiz answers, realtime, email or push.
- Changing `get_student_learn_course`.
- Regenerating curriculum markdown answers (`curriculum/lessons` stays the instructor source with answers).
- Any hosted or production write.
- Commit, push, or PR unless authorized at execution time.
- #179's own scope (task form, translation-task answer stripping) is not re-done here.

## 3. Repository findings (evidence)

All Observed in the 175 checkout unless labelled.

- **F1. Backend skeleton** (`202608280003_issue5_course_authoring.sql`).
  - `assessment_answer_keys` (lines 67-73): `lesson_revision_id uuid PRIMARY KEY references lesson_revisions on delete cascade`, `assessment_key text`, `answers jsonb`, `passing_score numeric(5,4) default .8`.
  - `quiz_attempts` (144-152): id, `user_id`, `lesson_revision_id`, `answers jsonb`, `score numeric(6,3)` 0..1, `passed boolean`, `submitted_at`.
  - RLS enabled (507, 513). Policy `quiz_attempts_own` select to authenticated using `user_id = auth.uid()` (526). `revoke all from anon, authenticated` on both tables (531), then `grant select on quiz_attempts to authenticated` (536). No student access to `assessment_answer_keys`.
- **F2. Legacy `submit_quiz_attempt(p_lesson_revision_id, p_answers)`** (489-503), granted to authenticated (548).
  - It checks only `auth.uid` and an entitlement with `unlock_at <= now()` and `manual_release_state` not in held/revoked, so a 'released'-early lesson is wrongly refused.
  - It has no `is_account_active`, no `user_requires_password_change`, no enrollment parameter, no attempt cap, exact jsonb equality per question (`a = q->'answer'`), no per-item results, no completion link. It returns the full `quiz_attempts` row.
  - Edge `supabase/functions/course-authoring/index.ts` calls it from a public 'grade' action before the owner gate (42-46) and again from the owner-path 'grade' action (413-417). Neither the client (`src`) nor any page calls 'grade' (grep: no use in `src`).
  - Tests referencing it: `src/__tests__/issue5BackendContract.test.ts:25-28` (reads old migration text) and `src/__tests__/issue5BackendIntegration.test.ts:60-63` (`prosrc` contains 'lesson is locked' and 'assessment_answer_keys').
- **F3. Legacy revision creation and seed order.** Legacy `lesson_revisions` are created by `backfill_legacy_courses()` (`202608280003:556-587`), which `seed.sql` calls AFTER migrations locally (same constraint as #179 F6).
  - **Inference and decision (planner, engineering):** a migration cannot seed per-revision keys for legacy lessons into `assessment_answer_keys` (PK/FK `lesson_revision_id`). Legacy quiz definitions and keys are content-keyed (`<band>-week-NN`), mirroring #179's `lesson_task_templates` and answer keys, and resolved at read time via `lesson_revisions.legacy_lesson_id` to `lessons(band_id, week_number)` to `bands.name`. `assessment_answer_keys` remains the authored-course store and is untouched.
  - `assessment_answer_keys` is also written by course-authoring `save_revision` (494-503, which strips `answers`/`answer_key`/`assessment_key` from revision content) and by `save_outline` (`202608300001:448`).
- **F4. `quiz_attempts` preserved across revoke.** Tests `issue5-phase1-acceptance.test.ts:295-316`, `issue5-phase1-entitlements-green.test.ts:328-380`, `issue5-phase3-sql-core.test.ts:265-283`, `issue5-phase4-sql-live.test.ts:215-238` insert rows with only `(user_id, lesson_revision_id, answers, score, passed[, submitted_at])`. Every new column must therefore be nullable or defaulted. `get_lesson_progress_evidence` (`202608290001:548-553`) counts attempts by user and lesson revision; `CourseWorkspacePage.tsx:684` shows "Quiz attempts".
- **F5. Static quiz today.**
  - `src/content/lessonContent.ts`: `QuizItem {question, answer}` (41-44), `LessonContent.quiz` (58), `RHYTHM_SEGMENTS` 30/10/20 (63-67).
  - `src/components/LessonContentView.tsx` Q&A segment 299-318 renders "Self-check: I can…", h3 "Quiz", and `<p className="lesson-content-quiz-answer">Answer: {item.answer}</p>` (313) unconditionally.
  - `lesson-content.json` under `supabase/storage-seed/lesson-assets/<band>/week-NN/` is student-readable (`students_read_unlocked_resources` in `202607170002_rls_policies.sql:35`; `students_read_unlocked_lesson_assets` in `202607170005_storage_gating_policy.sql:23`), so quiz answers leak over the network today.
  - `LearnDetailPage.tsx:68` maps `completion_rule` non-'view' to 'unlocked-pending-quiz' ("No action needed here."); `learnData.ts:95` carries `completion_rule`.
- **F6. Quiz content counts and the parser defect.**
  - `content-source/*.ts` holds 490 `{ question:` items across 78 modules (most 6-7; advancedWeek16 6, advancedWeek17 4, advancedWeek18 6, advancedWeek24 6, advancedWeek25 6, beginnerWeek01 2). The lead's estimate of ~493 implies merged items.
  - Quiz-section answer variants observed in `curriculum/lessons/*/phrases-and-qa.md`: advanced-week-16:159 "**Answer (any three):**", advanced-week-17:174 "**Answer (one reasonable option):**", intermediate-week-24:166 "**Answer (one acceptable rendering):**". Section membership is to be confirmed by the audit.
  - Many other "**Answer (translation):**"-style variants sit in TRANSLATION TASK sections (advanced weeks 05, 13, 19-26; for example advanced-week-24:55-158). That is #179's `splitTranslationTask` concern. **Cross-plan note:** #179's strict grammar must handle those variants.
  - Answers also carry hard-wrap artifacts ("\n   ", for example `content-source/advancedWeek13.ts:81-87`).
  - The mis-parse originates in `tools/lesson-generation/generate_lesson_ts.py` `parse_quiz` (regex at line 392: `(\d+)\.\s+(.+?)\*\*Answer:\*\*\s*(.+?)(?=\n\d+\.|\Z)`), a nested untracked repo present only in the main checkout. #178 established the delivery path `scripts/export-tooling-patches.ts` (exports nested commits as a checksummed patch series under `docs/tooling-patches/lesson-generation/issue-178/`).
  - **Correction to the brief:** `scripts/generate-lesson-content-json.ts` does not parse quizzes; it serializes content-source modules, so the merge is baked into the content-source quiz arrays.
  - Prompt-prefix format mix (lead-provided, to be re-counted by the audit): Name/Explain/What/Why 141, Translate 69, Which/Choose 62, True or false 61, Fill-in/Complete 53, correct-the-error 3, other ~104.
- **F7. Weekly review recap.** 293 "Answer" occurrences across all 78 `supabase/storage-seed/lesson-assets/*/week-NN/weekly-review-recap.md` (verified count). Self-test answers are inline parentheticals, for example beginner/week-05 lines 28-38 `(Answer: "¿Trabaja usted todos los días?"; …)`.
  - `scripts/provision-lessons.ts:874-875` copies `curriculum/lessons/<lesson>/weekly-review-recap.md` into storage-seed.
  - #175's in-app viewer renders recap text verbatim (plan `lizbeth-spanish-issue175-vocabulary-review-in-app.md` line 40: "#180 owns answer removal"; R9 line 377: the lang golden needs reviewed regeneration when #180 changes files).
  - Golden: `src/__tests__/fixtures/vocabReviewLangGolden.json`, regenerated with `UPDATE_VOCAB_GOLDEN=1` (`src/__tests__/vocabReviewLang.test.ts`); its scope is the "Consolidated vocabulary, by theme" section only.
- **F8. Instructor PPTX and student-handout PDF** are `resources` rows readable by entitled students through the same RLS and storage policies (Roadmap Files tab; `/learn` excludes pptx per #174 decision D2). Whether they contain quiz or recap answers is **Unknown** (#179 F11 inference: review slides and sections may carry recap answers). Decided by extraction in PR A plus decision U2.
- **F9. Leak guard.** `scripts/check-no-lesson-content-leak.js` (dist scan, one title fingerprint per week for 78 weeks), run by `npm run verify:build`. `package.json` scripts: `type-check`, `lint`, `test` (vitest), `test:e2e` (playwright), `verify:build`, `check:practice-complete`, `check:asset-content-types`, `check:canonical-assets`.
- **F10. Completion seams.**
  - #176 (`202610030001_issue176_single_completion_record.sql`) canonical unlock rule: locked when `manual_release_state in ('held','revoked') or (manual_release_state <> 'released' and unlock_at > now())` (lines 265-266, 312-313).
  - #179 (draft) adds `lesson_completion_blockers(enrollment, revision)` returning `text[]` as the documented #180 extension point (#180 adds 'quiz_pass' by create-or-replace), `finalize_lesson_completion`, `student_marked_complete_at` mark intent, `completion_gate_settings(cutover_at)` with sync-path gating of `sync_enrollment_completions` and `sync_legacy_completion_to_entitlement`, owner override `set_lesson_completion` with `bypassed_blockers`, the recorded completion state, the `/admin/submissions` inbox, `SubmissionLedgerRow`, status chips, `AccentStrip`, the guard registry, and EN-1 to EN-7.
  - #180 reuses these and must not duplicate them.

Research evidence: none. Research not needed: all decisions are grounded locally and in approved or draft plans #174, #175, #176, #178, #179.

## 4. Design route and handoff

DESIGN_ROUTE profile standard. Reasons: new multi-state quiz component on two surfaces, owner grading queue and results, changed completion flow. Agents: design-director (Sonnet), ux-architect, visual-system-designer, independent design-reviewer (Sonnet). Motion and asset specialists not applicable. Prototype forbidden. Model tier sonnet. `existing_system_mode`: extend (the #179 system).

Design review: the first pass was NEEDS_REVISION with findings DR-1 to DR-11 (blocking: DR-1 authored `quiz_pass` scope, DR-2 stripped-JSON no-definition rule, DR-3 in-session recorded-to-completed transition). DESIGN_REVIEW_RESULT verdict **PASS on revision 1**, with low engineering notes DR-12 and DR-13.

Engineering notes carried into the work and Verifier gates:

- **DR-12.** Tests must await provider settle. The loading placeholder needs a reserved min-height. Consider a load-failure fallback to static questions without answers.
- **DR-13.** Add `role="list"` to the `ol` if VoiceOver drops list semantics (the list uses `list-style: none`).
- Step 0 re-verifies every server contract named in the handoff (none of the #179 contracts exist in the 175 checkout).
- The exact key-field allowlist and denylist is an engineering deliverable and a gate (invariant 18).
- The Submit Modal unanswered list must scroll inside the dialog at 320x256.
- Re-run `contrast_check` on the final CSS (the brass-500 radio and select accent pairing and any new pairing).
- Carried from #179: EN-1 (separate idempotent unseen-clear call), EN-4 (async-aware guard registry), EN-7 (focus the field only after the segment panel is shown).

### Design handoff (reviewed, revision 1)

Task ID `lizbeth-spanish-issue180-interactive-quizzes`. Profile standard. Revision 1 of 1 resolves DR-1 to DR-11 and the Planner server-scope facts. Motion and asset spec: not applicable (no animation, no imagery; a real in-session Mark save still triggers the existing Stamp; owner-finalized completion, in-session completion at quiz pass, and recorded states fire no Stamp). Prose below is condensed; every journey, state, copy key, invariant, permitted variation, validation journey, and deterministic check is preserved. All sample items are PLACEHOLDER.

#### 4.1 Selected direction and brief

"Field Journal worksheet insert", mode EXTEND. A quiz is a printed quiz sheet tipped into the same reading page. Each question is a bounded worksheet insert. Results read as the teacher's hand-marked return, with a glyph plus word verdict and a left-rule style on every row. The student's answer key is a distinct "Correct answer" insert, slate-ruled rather than the owner's brass-ruled sheet. No new tokens, typefaces, radii, or shadows. Creative thesis: calm, roomy, honest; nothing in the UI hints at an answer before the reveal.

- **Audience.** Adult Spanish learners on the Roadmap lesson page (Q&A segment) and on `/learn`; the owner grades and tracks progress.
- **Problem.** The Q&A quiz is a static list that prints "Answer: ..." beside every question. Students cannot be scored, answers ship to the client, and nothing reaches the owner.
- **Desired outcome.** A student answers, submits, and immediately sees per-item correctness and a score. Correct answers and explanations appear only after a pass or after the fully graded 3rd attempt. Open-ended items are graded by the owner in one queue. A pass counts toward lesson completion alongside the student's Mark and the #179 task.
- **Success measures.** Network capture shows no key string and no correct-option or pairing field before reveal eligibility. Every shipped `lesson-content.json` quiz answer is empty. Exactly one primary per view per state. Every state is reachable by keyboard only. Every verdict is glyph plus word. Component-level DOM-equality fixtures with injected content are byte-identical to today's markup at 1440 and 390. Axe passes in every state, with no horizontal scroll at 320 or 400% zoom.
- **Current system.** The #179 handoff (chips, `AccentStrip`, error summary, B.06 index card, completion overlay note, "recorded" state, owner inbox, reference sheet, `SubmissionLedgerRow`, routing touchpoints). `LessonContentView.tsx` lines 299-318 is replaced only when an eligible definition exists. `LearnDetailPage.tsx` lines 55-69 (state derivation) and 287-289 (the "No action needed here." note).
- **Server-scope facts (from Planner):** definitions exist only for the 78 legacy lessons. Authored-course lessons get no definition and are unchanged, and `completion_rule` 'quiz_pass' stays unenforced (follow-up). Completion is the student's recorded Mark AND an empty `lesson_completion_blockers` set (`task_review`, `quiz_pass`), finalized server-side by whichever requirement completes last. The owner completion override bypasses blockers (settled, #179 D3). The generated `lesson-content.json` strips quiz answers for all 78 lessons. At the #180 cutover any already-completed lesson is grandfathered (practice). A Mark-recorded-but-incomplete lesson simply gains the quiz requirement, and the composed note covers it.
- **Constraints.** Text only, no animation. Zero new tokens. No native dialogs and no `beforeunload`. `RHYTHM_SEGMENTS` stays 30/10/20. English copy under `site_content` keys `lesson_quiz.*`.
- **Anti-goals.** No gamified chrome, streaks, or confetti. No color-only meaning. No inline nagging about unanswered items. No second implementation of any #179 device. No drag-only interaction.
- **Content rules.** Student strings never hint at keys before reveal. Owner strings may mention keys. Spanish chrome comes from the owner later.

#### 4.2 UX spec: journeys

- **J1 Take, Roadmap 1440.** One page-level `LessonQuizProvider`, created next to the `LessonTaskProvider`. It calls `get_lesson_quiz(enrollment_id, lesson_revision_id)` exactly once per page (DR-4: a breakpoint crossing or segment switch never re-runs it).
  - No-flash rule (DR-4). Until the quiz provider settles, the Q&A quiz region renders only the existing h3 "Quiz" plus ONE `role=status` paragraph "Loading your quiz..." in a min-height-reserved placeholder, with no quiz-dependent or static `ol` content. The overlay note renders nothing until BOTH the task and quiz providers settle. A settled NULL renders the static `ol` (J12). A non-NULL result renders the panel in place of the placeholder. A failed load renders the load-failure alert with Retry.
  - The QuizPanel is `role=group` with `aria-label="Quiz"` (DR-5). Contents: attempt banner, ordered item list (`list-style: none`, because the eyebrow carries the number; DR-11), answered-count line, and the button "Review and submit quiz".
  - Segment switching or crossing the breakpoint keeps typed answers, because the state lives in the provider.
- **J2 Take, Roadmap 390.** Same provider and panel, controls stacked full width at `--control-height`. The Lesson tabpanel `scroll-padding` equals the footer height so a focused field is never under the footer. Accent strips wrap.
- **J3 Take, `/learn`.** The card shows a compact quiz chip and a link inside `.lesson-card-text`, only on eligible cards whose lesson has a definition. Route `/learn/:enrollmentId/lessons/:lessonRevisionId/quiz` shows the Back link, h1 lesson title, h2 "Quiz", then the same QuizPanel. A malformed id or NULL shows "This quiz isn't available right now." plus the Back link, the same generic message for ineligible, other-student, and no-definition cases.
- **J4 Submit Modal.** "Review and submit quiz" is never disabled for incompleteness (DR-5: its accessible name is distinct from the #179 task button "Review and submit").
  - If any field is over its limit the Modal does NOT open. The error summary fires instead (`role=alert`, `tabIndex -1`, focus on mount). Each link activates the owning segment, then focuses the field on the next frame (EN-7).
  - Otherwise `Modal.tsx` opens unmodified, titled "Submit attempt {n} of 3" (distinct from the task Modal "Submit final answers"). Body: answered and unanswered counts and the unanswered question numbers as plain text; "Unanswered questions are scored as incorrect."; "This uses one of your 3 attempts and you can't change your answers afterward."; and, when the attempt has teacher-graded items, "{t} questions are graded by your teacher. You can't start another attempt until your teacher has graded this one." The unanswered list scrolls inside the dialog at 320x256.
  - Actions "Submit attempt {n}" (primary) and "Keep editing" (secondary). Escape closes except while submitting, and focus returns to the trigger. A submit failure shows an inline message in the Modal.
  - No per-item inline warnings while answering. The only live hint is the plain "{a} of {m} answered" line (not `aria-live`).
- **J5 Auto-only result.** Submit success closes the Modal. Focus moves to the results heading "Attempt {n} results" (`tabIndex -1`). One polite status region announces "{c} of {m} correct ({pct}%)" plus pass or fail wording. Each item shows glyph plus word correctness and the student's echoed answer (or "No answer submitted."), plus the lenient accent note when applicable, never a key. The result is final.
- **J6 Mixed result, pending teacher items.** Chip "Awaiting teacher review". Score uses provisional wording. Pending items show "Awaiting teacher review" and the echoed answer. No Start-attempt control; the pending note appears in its place. No reveal.
- **J7 Fail, attempts left.** Chip "Best {pct}%, {n} attempt(s) left". Primary "Start attempt {n+1} of 3", a client-side reset to a fresh empty form with focus on the new attempt heading. A "Previous attempts" `aria-expanded` disclosure lists score, status, and per-item correctness only.
- **J8 Final attempt fails, then reveal.** After the 3rd attempt is graded and not passed: chip "Not passed, no attempts left", the exhausted note, and the secondary button "Review answers and explanations". The click makes the separate eligibility-checked reveal call. Focus moves to the "Answers and explanations" heading; "Back to results" returns focus to the results heading. If the 3rd attempt is awaiting a teacher there is no reveal and the lock note shows.
- **J9 Pass, then reveal, with in-session completion (DR-1, DR-3).** The quiz closes with chip "Passed, {pct}%". There is no further Start action. Reveal opens the same view as J8.
  - A legacy lesson completes at pass ONLY when the student's Mark is recorded and the other blockers (task review) are empty. Authored-course lessons, including `completion_rule` 'quiz_pass', are unchanged in #180.
  - The submit response returns the lesson completion state (`completed_at`). If non-null, `useLessonCompletion` transitions recorded to completed WITHOUT `justCompleted` and WITHOUT the Stamp. The overlay note and the completion control update in place to the existing Completed presentation. The note is removed, as in #179.
  - The polite region announces "Attempt {n} graded. {c} of {m} correct, {pct}%. Quiz passed. Lesson complete." On `/learn`, the quiz page shows "You passed the quiz. This quiz is closed and your lesson is complete." The course page card and completed count refresh from the server on return. The completed date comes from the server only; nothing is fabricated.
  - If the response `completed_at` is NULL, the lesson stays incomplete. If unmarked, the note is "You passed the quiz. Mark this lesson complete to finish." A later Mark, with all blockers cleared, completes immediately as a real in-session save and the Stamp fires as today.
  - Owner-finalized completion stays "visible on next load".
- **J10 Owner queue and grading.** `/admin/submissions?type=quiz&status=awaiting_review` lists rows; a row opens `/admin/submissions/quizzes/:attemptId`. Detail order (DOM equals visual): h1; `dl` summary (student, course, submitted, provisional score, pass mark); skip link "Jump to grading"; h2 "Items awaiting grading ({n})" with per-item h3 "Question {n}", three columns (prompt | student answer | owner-only reference sheet), the grade fieldset (Correct/Incorrect, required), and "Comment to student (optional)" (limit 1000, counter); h2 "Auto-graded items ({n})", a read-only `aria-expanded` disclosure showing keys and results with the tag "Counted correct: accent marks differed" where lenient scoring applied; h2 "Finalize" with the outcome caption, the caption "Grades aren't saved until you finalize." (DR-9), and the sole primary "Finalize grades".
  - Missing grades produce the error summary. Finalize opens a Modal naming score and pass or not-pass. Confirming finalizes the attempt, and the server result wins over the preview (DR-9). If it was the last requirement and the mark is recorded, the lesson completes in the same server transaction with no Stamp.
  - Grades are client-only until finalize. A finalized attempt is a read-only view of all items with chips and comments.
- **J11 Owner results per student.** Student-detail gets a nested "Quizzes" list (lesson, chip, best score, "{n} of 3", link to latest attempt, expandable per-attempt per-item results). Roster rows get a compact quiz chip per lesson. Dashboard attention reasons `quiz_awaiting_grading` and `quiz_exhausted` are added, and the quiet line becomes "{n} awaiting your review ({t} tasks, {q} quizzes)".
- **J12 No definition, ineligible, held, authored (DR-1, DR-2).**
  - No shipped lesson shows "Answer:" lines, because `lesson-content.json` is stripped for all 78 lessons. The Answer paragraph is omitted when the answer is empty (`{item.answer && ...}`), so an ineligible lesson shows the static questions only.
  - NULL from `get_lesson_quiz` means no quiz UI. Held, revoked, and date-locked students see the static questions without Answer lines.
  - Authored-course lessons (including `completion_rule` 'quiz_pass') get no definition and are unchanged, including the existing `/learn` "No action needed here." card note. They show no quiz UI.
  - Non-regression: a component-level DOM-equality fixture injects content with NON-empty answers and no definition, and asserts the output is byte-identical to today's markup. A second snapshot, regenerated after stripping, covers shipped content with the Answer paragraph absent. Fixtures in `lessonContentViewDesktopVisualNonRegression` that carry answers get a deliberate update.
- **J13 Grandfathered, optional practice (recommended).** At the #180 cutover, any already-completed lesson is grandfathered. Banner: "Optional practice. This lesson is already complete, so your results won't change it." The same attempt and reveal policy applies. Completion is never altered. Attempts are tagged "Practice" in the owner queue and excluded from the nav count and both dashboard attention reasons. Rationale: hiding would delete study material the static quiz already provided, and the queue deprioritizes practice so the owner pays no visible cost. A Mark-recorded-but-incomplete lesson is NOT grandfathered; it gains the quiz requirement.
- **J14 Keyboard only.** Tab order: segment tabs, each item in DOM order, "Review and submit quiz", completion control. Radios are native groups. Selects and blanks follow document order. One AccentStrip per text field (DR-6), so a 2-blank item has the order blank 1, strip 1, blank 2, strip 2. Each strip is one tab stop with arrow and Home/End roving. The Modal traps focus. Error-summary links work from the keyboard. On results: Start attempt, Review answers, Previous attempts disclosure, Back link.
- **J15 Navigation guard (DR-8).** One guard registry accepts multiple registrants (quiz provider, task provider, owner grading page) through the `useRoute` `navigate()` pre-navigation hook and the async-aware `SignOutGuardContext` extension (#179 EN-4). One aggregator opens at most ONE Modal. It covers header nav, in-page Back link, "Next awaiting review", and sign-out.
  - Quiz only: "Leave this quiz?" with "Stay on quiz" (primary) and "Leave quiz" (caution-irreversible).
  - Task only: the #179 "Leave without saving?".
  - Both: "Leave this page?", with a line per registrant.
  - X, Escape, and backdrop mean Stay in every variant. Back/Forward, reload, and tab close are unguarded (accepted limit, disclosed by the draft caption).
- **J16 Exhausted, then owner override (DR-10).** After 3 failed attempts, a Mark-recorded lesson stays incomplete. The owner uses the existing completion override (settled, #179 D3), which bypasses blockers. There is no reset-attempts action in v1. The student sees Completed on the next load, with no Stamp.

#### 4.3 Information architecture and routing

- **New components:** `LessonQuizProvider`/`useLessonQuiz`; `QuizPanel` (embedded|standalone, heading-level prop, `role=group` `aria-label` "Quiz"); `QuizAttemptBanner`; `QuizItemFieldset` (one dispatcher for all five types); `QuizResultsView`; `QuizRevealView`; `QuizStatusChip` (a modifier on the shared chip, not a fork); `OwnerQuizAttemptDetailPage`; `QuizItemGradingRow`.
- **Reused:** `AccentStrip`; the #179 error summary; `Modal.tsx` unmodified; the completion overlay note, extended by composition (same single instance and shared id, present even without a task bar); `LessonCompletionControl` and `useLessonCompletion` (no new state beyond recorded and a completion transition without `justCompleted`); `OwnerSubmissionsPage` (adds `?type=`); `SubmissionLedgerRow`; chips on `WeekCard`, roster, student-detail; `describeAttentionReason`.
- **Headings.** Roadmap desktop and mobile keep the existing h3 "Quiz" (mobile keeps its deliberate skip), with h4 for banner, results, and reveal. `/learn` quiz page is h1 lesson title, h2 "Quiz", h3 sub-headings. Owner list h1 "Submissions". Owner detail per J10.
- **DOM order.** Roadmap Q&A panel: self-check `ul`, h3 "Quiz", then QuizPanel (banner, error summary when present, ordered item list, answered-count line, submit control, the single polite status region). Overall Roadmap order: panels, optional task bar, one overlay note, completion control. Owner DOM order equals visual order with no CSS `order`.
- **Queue placement.** The pending-review queue lives inside the #179 inbox as a type dimension, not a sibling route: one "needs my review" count, one nav badge, one "Next awaiting review", one place to look. A type filter costs one query param. The two detail pages stay separate because the grading layouts differ.
- **Routing touchpoints** (each needs a test, including direct-URL load):
  - `useRoute.ts`: add `/learn/:enrollmentId/lessons/:lessonRevisionId/quiz` and `/admin/submissions/quizzes/:attemptId`. The existing `LEARN_DETAIL_PATTERN` will not match the quiz route. Malformed ids fail closed to the generic message.
  - `App.tsx` `knownAdminRoute`: recognize the new routes (the 175 checkout does not yet contain `/admin/submissions*` because #179 is unbuilt; read at lines 79-95).
  - `AdminShell` and `MobileNav`: reuse the single Submissions entry. The count includes quiz attempts and excludes "Practice" attempts. Accessible name "Submissions, N awaiting review".
  - Query string: `?type=all|task|quiz` layered on `?status=`. Quiz status values are `awaiting_review` and `reviewed` only (no `returned_for_revision`, no `in_progress`). The #179 popstate plus custom-event listener handles query-only changes. A filter, type, or page change focuses the list heading or status line, never the h1.
  - Permissions: a non-owner on `/admin/submissions*` gets the existing inline permission-denied. A student requesting another student's quiz gets the generic unavailable message.
- **Permitted DOM deltas:** (1) the static `ol` is replaced by the QuizPanel for eligible lessons with a definition; (2) the Answer paragraph is conditional on a non-empty answer, the deliberate delta that removes Answer lines from every shipped lesson (all 78 stripped) and leaves output unchanged when injected answers are non-empty; (3) the overlay note text is composed (same single instance and id) and renders nothing until both providers settle; (4) tier and attribute changes on the task bar and footer; (5) the `/learn` card gains the quiz chip and link on eligible cards of lessons with a definition (up to two compact chips in one wrapper). The "No action needed here." note is unchanged on authored cards. Grandfathered lessons render the optional-practice banner.

#### 4.4 Item rendering

- Each item is an `li` (list-style none; the eyebrow carries the number) containing a `fieldset`. The legend contains BOTH a mono eyebrow span "Question {n} of {m}" AND the prompt span, so the accessible group name includes the prompt. This overrides the visual specialist's "short legend plus described-by paragraph" and is a named, intentional exception to #179's pattern. `lang` is set on spans (es or en; mixed or unspecified gets none).
- **True/False:** native radios "True" and "False". **Multiple choice:** native radios in server-shuffled order, stable per enrollment and quiz.
- **Fill-in:** one labelled text input per blank ("Blank 1", "Blank 2") with literal markers such as "[1]" in the prompt. 200 characters per blank, enforced by an error at submit; no native `maxLength` and no counter.
- **Matching:** one fieldset with one select per left row, labelled by the left text, placeholder "Choose...", duplicates allowed, used options not disabled, right column in server-shuffled order.
- **Open-ended:** textarea with the #179 counter pattern, limit 2000, and a "Teacher-graded" tag word beside the legend.
- **Accent aid (DR-6, chosen):** ONE AccentStrip per text field (each blank and each textarea), as in #179. Its `aria-label` is "Insert accented characters", or "Insert accented characters in Blank {n}" on multi-blank items. The strip is present for es, mixed, and unspecified fields and absent for en. A pointer press never moves focus.

#### 4.5 Responsive behavior

- Roadmap-embedded elements switch at `WEEK_DETAIL_BREAKPOINT_REM` 56.24rem. The `/learn` quiz page, owner pages, and `WeekCard` chip use 48rem.
- At 1440, 1024, and 768 matching rows are inline (label | select) and radio lists are vertical.
- At 390 matching rows stack (label above select), controls are full width at `--control-height`, accent strips wrap by flex-wrap, the field footer stacks, and the Lesson tabpanel keeps `scroll-padding` equal to the footer height.
- At 320 and 400% zoom (320x256) there is no clipping and no horizontal scroll, selects get `min-width: 0` in flex or grid items, the Modal unanswered list reflows and scrolls inside the dialog, and a focused control is never obscured by the footer.
- Owner columns use `repeat(auto-fit, minmax(min(100%, 18rem), 1fr))`: about three at 1440, two at about 1024, one at 390, DOM order preserved. The owner grade fieldset is a full-width stacked block under the columns, never a fourth column.

#### 4.6 Accessibility

- One `role=status` polite region per QuizPanel, announcing transitions only: "Attempt {n} graded. {c} of {m} correct, {pct}%. {Passed / Not passed yet}. {k} attempts left.", a provisional variant for pending attempts, and the in-session completion variant ending "Quiz passed. Lesson complete." (J9). Never per keystroke, never "Saving...". The loading status "Loading your quiz..." is its own single `role=status` placeholder (DR-4). Owner finalization arrives out of session and surfaces only as the unseen chip on load.
- **Focus:** submit success goes to the results heading; Start attempt goes to the new attempt heading; reveal goes to the reveal heading; Back to results goes to the results heading; invalid submit goes to the error summary; Modal close without submit returns to the trigger; owner Finalize or Keep grading returns to the button with an inline `role=status` confirmation; route change goes to the destination h1.
- The owner outcome caption is plain visible text referenced by the Finalize button's `aria-describedby`. It is NOT a live region, because radio changes would announce on every click (DR-F).
- Every status is a glyph (aria-hidden) plus a visible word plus a rule style. Forced-colors uses border style. Targets are at least 44px. The focus ring is `--color-focus` at 3px. All text renders escaped with `white-space: pre-wrap`.
- The student key block has the accessible name "Correct answer", distinct from the owner's "Owner only: never shown to students". `lang` on es and en prompts and response fields. The counter is hand-built with no native `maxLength` and a hidden polite crossing announcer. The error summary reuses `.lesson-task-error-summary`. Each AccentStrip is the existing roving toolbar.

#### 4.7 States and copy (keys `lesson_quiz.*`, English defaults)

- **Loading and chrome:**
  - `loading` (one `role=status`): "Loading your quiz..."
  - `panel.label` (aria-label on `role=group`): "Quiz"
  - `banner.attempt`: "Attempt {n} of 3"
  - `banner.pass_mark`: "Pass mark: 80% ({k} of {m} correct)"
  - `banner.best_score`: "Best score so far: {pct}%"
  - `banner.draft_caption`: "Your answers aren't saved until you submit this attempt."
  - `item.teacher_graded_tag`: "Teacher-graded"
  - `item.blank_label`: "Blank {n}"
  - `item.matching_placeholder`: "Choose..."
  - `item.tf_true` / `tf_false`: "True" / "False"
  - `item.answered_count`: "{a} of {m} answered"
  - `item.no_answer`: "No answer submitted."
  - `accent.strip_label_multi`: "Insert accented characters in Blank {n}"
  - `grandfathered.banner`: "Optional practice. This lesson is already complete, so your results won't change it."
- **Submit, errors, results:**
  - `submit.button`: "Review and submit quiz"
  - `modal.title`: "Submit attempt {n} of 3"
  - `modal.unanswered_note`: "Unanswered questions are scored as incorrect."
  - `modal.attempt_note`: "This uses one of your 3 attempts and you can't change your answers afterward."
  - `modal.teacher_graded_note`: "{t} questions are graded by your teacher. You can't start another attempt until your teacher has graded this one."
  - `modal.submit_action` / `keep_editing`: "Submit attempt {n}" / "Keep editing"
  - `error.over_limit_blank`: "This answer is {n} characters over the 200-character limit."
  - `error.over_limit_open`: "This answer is {n} characters over the 2,000-character limit."
  - `error.load_failure` (`role=alert`, Retry): "We couldn't load this quiz. Please try again."
  - `error.submit_failure` (in Modal): "Couldn't submit right now. Your answers are still here. Please try again."
  - `error.offline`: "You're offline. Reconnect to submit. Your answers are still here."
  - `error.conflict` (`role=alert`, action "Reload quiz"): "This attempt can't be submitted because the quiz changed or was already submitted. Reload to see the latest. Unsubmitted answers on this page will be lost."
  - `unavailable`: "This quiz isn't available right now." (plus Back link)
  - `results.heading`: "Attempt {n} results"
  - `results.score`: "{c} of {m} correct ({pct}%)"
  - `results.score_provisional`: "{c} of {m} correct so far ({pct}%) - provisional until your teacher grades the remaining questions."
  - `results.pass_mark`: "Pass mark: 80%"
  - `results.attempts_used`: "Attempt {n} of 3 ({k} left)"
  - `results.item_correct` / `item_incorrect` / `item_pending`: "Correct" / "Incorrect" / "Awaiting teacher review"
  - `results.pending_note`: "You can start another attempt after your teacher grades this one."
  - `results.start_next`: "Start attempt {n+1} of 3"
  - `results.passed_closed_note`: "You passed the quiz. This quiz is closed."
  - `results.passed_complete_note` (DR-3): "You passed the quiz. This quiz is closed and your lesson is complete."
  - `announce.passed_complete` (DR-3): "Quiz passed. Lesson complete."
  - `results.exhausted_note`: "You've used all your quiz attempts without reaching the pass mark. Ask your teacher about next steps."
  - `results.reveal_locked_note`: "Correct answers unlock after your teacher grades this attempt."
  - `results.review_button`: "Review answers and explanations"
  - `results.previous_attempts`: "Previous attempts"
  - `results.teacher_comment`: "Teacher comment"
- **Reveal:**
  - `reveal.heading`: "Answers and explanations"
  - `reveal.your_answer`: "Your answer (from attempt {n})"
  - `reveal.correct_answer`: "Correct answer" (key-block label)
  - `reveal.also_accepted`: "Also accepted: {list}"
  - `reveal.explanation`: "Explanation"
  - `reveal.model_answer`: "Model answer"
  - `reveal.back_to_results`: "Back to results"
  - `reveal.unavailable`: "Answers aren't available yet."
- **Accent policy (open user decision U1).** Recommended default lenient-with-note: `accent.lenient_note` "Correct. Check your accent marks." (the item counts correct; the note is non-revealing). Strict alternative: `accent.strict_note` "Incorrect. Accent marks matter for this answer." Under both policies n versus ñ always differs. The lenient note tells a student marked correct that the accent differed from the key; recorded as accepted limit A12.
- **`/learn` card:**
  - Links (`card.link.*`): not_taken "Take quiz"; retake "Retake quiz"; awaiting_teacher "View results" (quiet); closed "Review results" (quiet).
  - Chips (`chip.*`, full / compact): neutral "Not taken" / "Not taken"; warning "Best {pct}%, {n} attempt(s) left" / "{pct}%, {n} left"; slate "Awaiting teacher review" / "Awaiting review"; success "Passed, {pct}%" / "Passed {pct}%"; error "Not passed, no attempts left" / "No attempts left". Glyphs (aria-hidden): circle, recycle-arrow, diamond, check, cross.
  - The unseen marker "New" (screen-reader text "New grading results") clears via a separate idempotent call when results are mounted (EN-1 pattern). `WeekCard` shows a quiz chip only for non-initial states.
- **Owner copy:**
  - `owner.grade_correct` / `grade_incorrect`: "Correct" / "Incorrect" (required radios)
  - `owner.comment_label`: "Comment to student (optional)"
  - `owner.unsaved_caption` (DR-9): "Grades aren't saved until you finalize."
  - `owner.finalize_outcome`: "With these grades: {c} of {m} correct ({pct}%). Pass mark {t}%. The student will {pass / not pass}."
  - `owner.finalize_button`: "Finalize grades"
  - `owner.finalize_modal_title`: "Finalize grades for attempt {n}"
  - `owner.finalize_modal_body`: "The student will see this score and your comments. This can't be changed afterward."
  - `owner.finalize_modal_keep_grading`: "Keep grading"
  - `owner.error_ungraded`: "Mark every question Correct or Incorrect before finalizing."
  - `owner.auto_graded_heading`: "Auto-graded items ({n})"
  - `owner.accent_tag`: "Counted correct: accent marks differed"
  - `owner.practice_tag`: "Practice"
  - `owner.save_failure`: "Couldn't finalize grades. Please try again." (grades and comments kept)
  - Reused from #179: "Owner only: never shown to students." and "No reference answer for this item."
  - `dashboard.quiz_awaiting_grading`: "Quiz awaiting grading"
  - `dashboard.quiz_exhausted`: "Quiz not passed, no attempts left"
  - `dashboard.line`: "{n} awaiting your review ({t} tasks, {q} quizzes)"
- **Leave modals (DR-5, DR-8).** Dismissal (X, Escape, backdrop) means Stay in every variant.
  - `leave.title` "Leave this quiz?"; body "Your answers haven't been submitted and will be lost."; stay "Stay on quiz" (primary); leave "Leave quiz" (caution-irreversible).
  - Task-only: the #179 "Leave without saving?" Modal, unchanged.
  - Combined: `leave.combined.title` "Leave this page?"; one line per registrant ("Your quiz answers haven't been submitted and will be lost." plus the #179 task line); stay "Stay on page" (primary); leave "Leave page" (caution-irreversible).
- **Read-only attempt:** past attempts are not editable. Only the active, unsubmitted attempt is editable.

#### 4.8 Completion overlay matrix (extends #179 by composition, keys `lesson_quiz.completion.*`)

Rule: if a quiz is outstanding, note = `quizSentence(qStatus, mark)` + (task outstanding ? " " + taskTail : ""). Else if a task is outstanding, the #179 row verbatim. Else if unmarked, `passed_no_task`. Else it cannot persist, because the lesson completes automatically. `qStatus`: open (not started, or failed with attempts left), pending, exhausted. A lesson that already holds a recorded Mark simply gains the quiz requirement, and these rows cover it. When the lesson is completed the note is removed and the existing Completed presentation shows.

| Key | Note text |
| --- | --- |
| `open_unmarked` | "This lesson completes after you mark it complete and pass the quiz." |
| `open_recorded` | "You've marked this lesson. Pass the quiz to finish it." |
| `pending_unmarked` | "Your quiz attempt is waiting for your teacher to grade. Mark this lesson complete now and it finishes once your quiz is graded and passed." |
| `pending_recorded` | "Waiting for your teacher to grade your quiz attempt. Your lesson will complete automatically if it's graded as a pass." |
| `exhausted_unmarked` | "You've used all your quiz attempts without reaching the pass mark. Ask your teacher about next steps." |
| `exhausted_recorded` | "You've marked this lesson, but you've used all your quiz attempts without reaching the pass mark. Ask your teacher about next steps." |
| `task_tail_notsubmitted` | "Your task also needs to be submitted and reviewed." |
| `task_tail_submitted` | "Your task is also waiting for review." |
| `task_tail_returned` | "Your teacher also returned your task for revision." |
| `passed_no_task` | "You passed the quiz. Mark this lesson complete to finish." |

Mechanics: recorded generalizes. A Mark with any outstanding requirement stores intent, and the lesson completes server-side when the last requirement is satisfied, with no Stamp and no fabricated completed date. On mobile the full note stays in-flow in the Lesson tabpanel, the footer control references it via `aria-describedby`, and the footer shows only the short label. On `/learn` the two-step inline Confirm/Cancel is unchanged. A confirm with outstanding requirements shows the "Waiting..." label and note, a disabled "Mark recorded", and no count or date change, extending the #179 fix at `LearnDetailPage` line 259.

#### 4.9 One-primary rule (DR-G refined, DR-10)

"Quiz actionable" means "Review and submit quiz" or "Start attempt N" is available. The reveal button, pending note, and exhausted state are never primary-eligible.

- Roadmap desktop and mobile, Q&A active, quiz actionable: the quiz action is the single primary and the task bar action is SECONDARY (explicit for the mobile Lesson tab as well).
- Roadmap desktop, other segments: the task bar is primary while the task is actionable, else none (as today). The Mark button is never primary.
- Roadmap mobile Lesson tab: the footer is secondary if and only if (task actionable) OR (quiz actionable AND Q&A active). Otherwise it stays primary. This keeps a quiz-only lesson on the Phrases segment from losing its primary.
- Roadmap mobile Cards or Files tab: none while the task is actionable (accepted limit).
- `/learn` course page: the WP-G tie-break over the eligible-and-not-completed set selects the lowest-position actionable card. That card's first actionable action in DOM order is the page's single primary (task link, then quiz link, then Mark). All others are secondary or quiet. "Up next" follows that card.
- Quiz page: only "Review and submit quiz" or "Start attempt". Owner grading: only "Finalize grades".

#### 4.10 Visual system spec

- **Typography.** The legend eyebrow span uses the `.lesson-content-chunk h4` recipe (mono, uppercase, `--color-ink-700`) and carries the question number (DR-11). The prompt span uses `.lesson-content-chunk p` body type (DR-A). The "Teacher-graded" and "Counted correct" tags use the `.feedback-ledger-row-status` recipe, unbordered. The chip word uses the `.lesson-task-status-chip` recipe. Labels use `.field__label` with `--font-weight-label`. The teacher-comment heading uses Fraunces 700 at 21px (the `FeedbackLedgerRow` documented literal). Score, attempts, and pass mark use body type in `--color-ink-900`.
- **Contrast** (specialist `contrast_check` runs; the director re-ran only the brass-500 pairs; no text pair failed AA and none needed substitution):

| Element | Pair | WCAG | APCA |
| --- | --- | --- | --- |
| Neutral chip | ink-700 on paper-50 | 8.64:1 | Lc 88.5 |
| Warning chip | brass-700 on paper-100 | 5.47:1 | Lc 74.9 |
| Slate chip, Awaiting row | ink-slate on paper-100 | 6.5:1 | Lc 79.7 |
| Success chip, Correct row, lenient note | ink-moss on paper-50 | 7.42:1 | Lc 84.5 |
| Error chip, Incorrect row, over-limit counter text (EN-5 satisfied) | terracotta-600 (`--color-status-error-text`) on paper-50 | 4.69:1 | Lc 71.3 |
| Student key label | ink-slate on paper-200 | 5.8:1 | Lc 72.17 (accepted deviation, same pattern as #179 brass and terracotta on paper-200) |
| Key body, read-only input text | ink-1000 on paper-200 | 15.25:1 | not reported |
| Teacher-comment card body | ink-900 on paper-50 | 14.92:1 | Lc 100.4 |
| Owner "Counted correct" tag | ink-700 on paper-100 | 8.36:1 | Lc 86.2 |
| Owner read-only caption | ink-700 on paper-200 | 7.47:1 | Lc 78.7 |
| Focus ring (non-text) | ink-slate on paper-50 / paper-200 | 6.72:1 / 5.8:1 | clears the 3:1 floor |
| Radio and select accent (DR-11), director check | brass-500 `#a07e48` on paper-50 `#fdfcf9` / paper-100 `#faf8f4` | 3.67:1 / 3.55:1 | Lc 63.35 / 61.05 |

  The brass-500 accent clears the 3:1 non-text UI-component floor (WCAG 1.4.11) and fails the 4.5:1 text threshold, which does not apply because the accent is a control mark and not text. Radios and selects stay native-drawn with their native border and focus ring, so forced-colors keeps the OS control.
- **Layout and density.**
  - `.lesson-quiz-item` is a chunk-style insert: paper-100 fill, 3px ink-1000 border, `--shadow-card`, `--space-4` padding, `--space-3` gap between items. The ruled 27/28px chunk background is NOT applied (the J-39 lesson). The item list is `list-style: none`.
  - Radio lists are vertical with `--space-2` gap and label min-height `--hit-target-min`.
  - Matching rows are inline at 48rem and above and stacked below, with `min-width: 0` on any flex or grid item holding a select.
  - Results and reveal use `--space-5` between rows with `--space-3` internal padding. The standalone page is max-width `var(--measure)` and centered.
  - The Q&A wrapper `.lesson-content-qa` stays at zero CSS (the occlusion guard); the QuizPanel root takes its own class. The loading placeholder reserves a min-height so the swap to the panel does not shift the layout.
  - Owner grid uses `repeat(auto-fit, minmax(min(100%, 18rem), 1fr))` with `--space-5` gap. The grade fieldset is a full-width block under the columns.
- **Tokens.** Reused only. DTCG 2025.10 is a stable Community Group report, not a W3C Recommendation. Colors: `--color-ink-{1000,900,700,slate,moss}`, `--color-brass-{500,600,700}`, `--color-terracotta-600`, `--color-paper-{50,100,200,300}`, `--color-surface-{chrome,reading}-default`, `--color-status-{error,success,warning,neutral}-{text,border}`, `--color-focus`. Structure: `--border-width-*`, `--radius-square`, `--shadow-card`, `--control-height`, `--hit-target-min`, `--focus-ring-*`, `--space-1..10`, `--measure`. Type: `--font-family-*`, `--font-size-{caption,label,body}`, `--font-weight-label`. Zero additions and zero deprecated-registry use. `--color-ink-800` stays in color positions; `--shadow-brass` stays reserved for owner tables and export links. No component token is newly declared.
- **Components and states** (new classes, additive, under `.lesson-quiz-*` and `.owner-quiz-*`):
  - `.lesson-quiz-panel`: QuizPanel root (`role=group`). `.lesson-quiz-loading`: min-height placeholder with the single status paragraph.
  - `.lesson-quiz-item`: one per fieldset, legend with eyebrow plus prompt. `.lesson-quiz-item-type-tag`: status caption recipe, "Teacher-graded".
  - `.lesson-quiz-radio-group`: existing radio pattern, never `appearance: none` on radios.
  - `.lesson-quiz-match-row`: `.feedback-form-group` select pattern. The custom chevron must stay visible in forced-colors.
  - `.lesson-quiz-blank-field`: `.field` and `.field__control`, with its own accent strip. `.lesson-quiz-answer-field`: textarea on `.field__control` plus `.lesson-task-field-footer` and the accent strip.
  - `.lesson-task-status-chip--quiz` and `--compact`: the shared chip as a modifier, not a fork. Wrapper `.lesson-task-chip-group` holds up to two compact chips.
  - `.lesson-quiz-results-row`: status caption recipe plus a 4px left rule. The rule style carries the verdict: solid ink-moss for Correct, dashed terracotta-600 for Incorrect, dotted ink-slate for Awaiting. Glyph and word are always present.
  - `.lesson-quiz-reveal-key`: the owner reference-sheet shell (chrome ground, 3px ink-1000 border, `--shadow-card`) with a 3px ink-slate left rule, NOT brass, and a mono ink-slate label "Correct answer". It never reads as success, even when the student's answer was wrong.
  - `.lesson-quiz-model-answer`: `.journal-index-card-trim` (B.06) for teacher comment and model answer.
  - `.owner-quiz-ledger-row`: `SubmissionLedgerRow` pattern with type word, "Attempt n of 3", "{p} items awaiting grading", provisional score, and "Practice" tag. `.owner-quiz-grade-fieldset`: radio pattern plus an optional comment with counter. `.owner-quiz-autograded-tag`: status caption, unbordered. `.owner-quiz-finalize-caption`: plain text, not live.
  - States: default, focus-visible, native checked and disabled, read-only (`readOnly`, paper-200 fill, dashed border, full-ink text, caption), invalid (`aria-invalid` plus border change plus text), over-limit (counter text), loading, results rows (solid, dashed, or dotted rule).
  - Forced-colors: rule styles map to border-style. Read-only text becomes GrayText. The key block and chips use FieldText and Field.
  - Untouched: `FeedbackLedgerRow` TSX and CSS, `Field.css` base `.field__control` (scoped overrides only), and `.lesson-content-qa` (zero CSS). The legacy `.lesson-content-quiz-answer` rule stays in place for the conditional Answer paragraph.
- **Assumption:** the QuizPanel mounts inside the existing Q&A panel on the plain reading ground (paper-50). The standalone page and the results and reveal views inherit the reading ground. The owner grading page uses the chrome ground. The two tag words are unbordered neutral text, not full chips.
- **Visual unresolved (defaults):** select chevron treatment (reuse the mono chevron; use a native arrow if a specificity collision appears); results-row rule weight (default 4px).

#### 4.11 Engineering invariants (binding)

1. **Leak rule.** No answer key, accepted answer, explanation, model answer, correct option id, or pairing field appears in any student-visible DOM, payload, `lesson-content.json`, or storage before reveal eligibility. The generated `lesson-content.json` carries an empty quiz answer for ALL 78 lessons. `get_lesson_quiz` returns only: item id, type, prompt, `response_lang`, teacher-graded flag, options or blank count, matching left and right lists (option and right-column order server-shuffled, stable per enrollment and quiz), policy, attempts with per-item correct|incorrect|pending, the student's own answers, an `accent_note` boolean, teacher comments, and flags (grandfathered, `mark_recorded_at`, unseen, lesson completion state). Reveal comes only from a separate eligibility-checked call, made only after an explicit click. Ineligible callers get a generic denial.
2. **Scoring is server-side.** The student client never computes correctness or pass. The owner finalize preview (caption and Modal) uses one shared integer pass function, `correct*100 >= pass_percent*total`, with a parity test against the server function over a case table, and the server result wins when finalize returns (DR-9). Per-item scoring is all-or-nothing at equal weight; every blank and every pair must be correct. Fill-in is normalized before the accent policy: case-insensitive, trimmed, internal whitespace collapsed.
3. **Eligibility is server-side** in `get_lesson_quiz`, with NULL when ineligible or no definition. The Roadmap never re-derives it. `/learn` cards reuse the #174 predicate.
4. **Static Q&A rendering (DR-2).** The Answer paragraph renders only when the answer is non-empty. No shipped lesson shows Answer lines. A component-level DOM-equality fixture with injected non-empty answers and no definition must be byte-identical to today's markup, and a snapshot regenerated after stripping covers shipped content. `lessonContentViewDesktopVisualNonRegression` fixtures that carry answers get a deliberate update. `RHYTHM_SEGMENTS` is unchanged. `FeedbackLedgerRow` stays untouched, with a non-regression test.
5. **Unsaved answers** live in memory in `LessonQuizProvider` only: no server drafts and no `sessionStorage` mirror. One provider per page, loading once. Neither a breakpoint crossing nor a segment switch re-runs a load or clears answers. Answers are cleared on submit and sign-out.
6. **Guard registry (DR-8).** One registry supports multiple registrants and one aggregator opens at most one Modal. X, Escape, and backdrop mean Stay. It covers header nav, in-page Back, "Next awaiting review", and sign-out. No `beforeunload` and no native dialog.
7. **Completion (DR-1, DR-3).** The recorded state is hydrated from the server's `mark_recorded_at` and generalizes to any outstanding requirement. Completion is the Mark recorded AND an empty `lesson_completion_blockers` set, finalized server-side by whichever requirement completes last. The quiz submit response returns the lesson completion state. `useLessonCompletion` transitions recorded to completed without `justCompleted` and without the Stamp when `completed_at` is non-null, and the note and `/learn` card update in place. The completed date and count come from the server only. A grandfathered lesson is never un-completed. The owner override bypasses blockers (settled, #179 D3). Authored-course lessons (including `completion_rule` 'quiz_pass') are unchanged in #180.
8. **Attempt state.** A new attempt cannot start while another is pending or the quiz is closed, and the server enforces this on submit. Submit is idempotent per attempt number, and a stale or duplicate submit returns the conflict state. Reveal is available after a pass or after the final attempt is fully graded. Grandfathered attempts are tagged Practice, excluded from nav counts and attention reasons, and never change completion.
9. **One shared chip implementation** (a modifier, not a fork). The AccentStrip is not forked. `QuizItemFieldset` is one dispatcher for all five types. One strip per text field.
10. **Owner data.** Keys reach the owner only through owner-authorized calls. Ungraded client state is never sent to the server until finalize. A finalized attempt is read-only. Owner finalization is server-authoritative and may complete the lesson in the same transaction.
11. **Plain text.** All prompts, answers, comments, and keys render as escaped plain text with `white-space: pre-wrap`. No `dangerouslySetInnerHTML` and no markdown.
12. **One primary** per view per state per the one-primary rule.
13. **Source scan:** no `alert`, `confirm`, `prompt`, `window.*`, or `beforeunload`. Modals are used only for "Submit attempt", the leave variants, and "Finalize grades". A run-time dialog listener must stay silent.
14. **Tokens and copy.** Zero new tokens and zero `tokenDeprecationLint` findings. Student copy is `site_content` with English defaults and never hints at keys.
15. **Routing touchpoints** per section 4.3, including the query-string listener and focus targets.
16. **No-flash rule (DR-4).** The quiz region renders only the heading and the single "Loading your quiz..." status placeholder until the quiz provider settles, and the overlay note renders nothing until both providers settle. Each provider loads once per page.
17. **Placeholder limits**, all server-validated: 200 characters per blank, 2000 per open-ended answer, 1000 per owner comment.
18. **Allowlist gate.** Engineering supplies a closed allowlist of student-payload keys before the leak test is written. That list is a gate: the test fails if a student payload carries any key outside the allowlist.

#### 4.12 Permitted variation

- Glyph characters, provided the word carries the meaning and the glyph is aria-hidden.
- Copy wording, provided every key is kept and no student string hints at keys.
- Server RPC and field names, provided invariants 1 and 18 are met. The design's indicative names are `get_lesson_quiz`, `submit_quiz_attempt`, `reveal_quiz_attempt`, `get_lesson_quiz_summaries`, `finalize_quiz_attempt_grades`, `clear_quiz_unseen`. This plan uses `submit_lesson_quiz_attempt`, `reveal_lesson_quiz`, `grade_lesson_quiz_attempt`, and `mark_lesson_quiz_results_seen` (Section 7) so the legacy `submit_quiz_attempt` is not overloaded.
- Select chevron: the mono-chevron pattern, or a native arrow if a specificity collision appears.
- Results-row rule weight: 4px recommended, 3px acceptable.
- Quiz character limits (200, 2000, 1000).
- Roster expansion as a list or compact table.
- Legend markup (block legend or span-based), provided the accessible group name carries number plus prompt.
- Everything else is fixed.

#### 4.13 Browser validation brief (design)

Environment: launch `npx vite --port 5180 --strictPort`, base URL `http://localhost:5180`. Reset with `npx supabase db reset`, then `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`, and reset between journeys. Accounts (password `password`): primary student `fullaccess@test.local`, owner `owner@test.local`, and `student1-6@test.local`. Viewports: 390x844 and 1440x900 for every journey; spot checks at 320, 320x256 (400% zoom), 768, 1024, and forced-colors.

**Fixtures** (all PLACEHOLDER; sentinel strings appear ONLY in non-displayed fields, DR-7: accepted variants, explanations, model answers, fill-in keys, open-ended references; for MCQ, true/false, and matching the fixture is checked structurally because displayed options cannot carry sentinels):

- **Q-A:** auto-only quiz with all four auto types. An es fill-in with 2 blanks (each blank with its own strip) and an accent-only variant answer, an en item, a mixed item, an MCQ authored with the correct option first, a true/false item, and a matching item authored in answer order.
- **Q-B:** quiz with 2 open-ended items (es and en) plus auto items.
- A component-level injected-content fixture (no definition, non-empty answers) for DOM equality (DR-2). No shipped lesson serves it.
- An authored-course lesson reachable through `/learn` (including one with `completion_rule` 'quiz_pass'): no quiz UI and the unchanged "No action needed here." card note (DR-1).
- **Account mapping (DR-10):** student1 fails then passes Q-A. student2 has Q-B pending. student3 is exhausted. student4 holds a grandfathered-completed lesson. student5 holds a held (paused) lesson. student6 holds a revoked lesson and a date-locked lesson. Cross-student isolation: fullaccess requests student2's quiz and attempt URLs. A student with a Mark recorded before the cutover and an incomplete lesson covers "gains the quiz requirement".

**Validation journeys** (assert visible outcomes; screenshot names in brackets):

1. **Take on the Roadmap.** During load, one "Loading your quiz..." status and no quiz or static content appears, then the panel renders without layout shift. Answer across all item types, switch segments, and return. Answers persist, the count line updates, the draft caption is visible, and strips are present for es, mixed, and unspecified fields and absent for en. [quiz-loading-390 / -1440, quiz-take-roadmap-390 / -1440]
2. **Take on `/learn`.** The lowest-position actionable card holds the page's single primary (several actionable cards exist, and only that card's action is primary). The quiz route renders. [quiz-take-learn-390 / -1440, quiz-learn-card-390 / -1440]
3. **Submit Modal.** Counts, unanswered list, and notes appear; the teacher-graded line appears only for Q-B. Focus is trapped, Escape closes, and focus returns to "Review and submit quiz". An over-limit answer blocks the Modal and shows the error summary with link behavior. [quiz-submit-modal-390 / -1440, quiz-error-summary-390 / -1440]
4. **Auto-only fail.** Focus lands on the "Attempt 1 results" heading, the polite region announces the score, and rows show glyph plus word with the correct rule styles. No key appears anywhere. "Start attempt 2 of 3" is the primary. The lenient accent note shows on the accent-variant item. [quiz-results-fail-390 / -1440]
5. **Pass then reveal.** The attempt-2 pass closes the quiz, shows "Passed" and no Start action. Clicking "Review answers and explanations" fires the reveal call only then. The reveal shows the student's answer, the Correct answer block, and the explanation. "Back to results" returns focus. [quiz-results-pass-*, quiz-reveal-*]
6. **Exhausted then owner override (DR-10).** Three failed attempts show "Not passed, no attempts left", the exhausted note, the reveal button, and the exhausted completion row. The owner completion override then completes the lesson, and the student sees Completed on next load with no Stamp. [quiz-exhausted-*]
7. **Pending teacher items.** A Q-B submit shows "Awaiting teacher review", provisional score wording, and no Start action. Reveal is unavailable with the lock note. [quiz-results-pending-*]
8. **Owner queue and grading.** The nav count includes the quiz attempt and the `?type=quiz` default shows the row. The detail shows three columns at 1440 and stacked at 390, the "Owner only" label, auto-graded items read-only with keys, and the accent tag. The caption "Grades aren't saved until you finalize." shows. Finalizing without grades shows the error summary. Grade, check the outcome caption, and finalize through the Modal. The student then sees final results, the comment, and the "New" marker, which clears on open. [quiz-owner-queue-*, quiz-owner-grade-*, quiz-owner-finalize-modal, quiz-owner-finalized-readonly]
9. **Completion composition and in-session completion (DR-3).** With the Mark recorded and no other blocker, a passing submit leaves the lesson in the completed state in session, without the Stamp. The note is removed, the control shows the existing Completed presentation, the polite region announces "Quiz passed. Lesson complete.", and a return to `/learn` shows the card Completed with the server date and the count from the server. With Mark unrecorded, a pass shows "You passed the quiz. Mark this lesson complete to finish." and a later Mark completes with the Stamp. With a task still unreviewed, the composed quiz-plus-task note shows, and "Mark recorded" has no Stamp and no completed date. [quiz-pass-completed-in-session-390 / -1440, quiz-mark-recorded-*, quiz-auto-completed-*]
10. **Ineligible and unchanged states.** Held (student5), revoked and date-locked (student6), and cross-student isolation show no quiz UI. A defined-but-ineligible lesson shows the static questions with no Answer lines. The quiz route shows the generic unavailable message. The injected-content fixture is byte-identical to the stored golden. An authored lesson shows no quiz UI.
11. **Grandfathered.** The optional-practice banner shows. Attempt and reveal behave per policy. Completion is unchanged. The owner row shows the "Practice" tag and is excluded from the nav count and attention reasons.
12. **Owner results.** Student-detail Quizzes list, roster chips, dashboard reasons and quiet line. Direct-URL loads of the quiz route and `/admin/submissions/quizzes/:id` work. A non-owner is denied. A filter change focuses the list heading. [quiz-student-detail, quiz-roster-chip, quiz-dashboard-attention]
13. **Keyboard only.** Full Tab order (J14), radio arrows, select operation, and the 2-blank item check: Tab visits blank 1, strip 1, blank 2, strip 2, each strip with exactly one `tabindex` 0. Insert "ñ" in blank 2 and confirm focus returns to blank 2 with the caret after it. Open and close the Modal and follow an error-summary link.
14. **Navigation guard.** With answers entered, header nav, the Back link, and sign-out open "Leave this quiz?" with a focus trap, and X, Escape, and backdrop all keep the user on the page. Leave proceeds. With no answers there is no Modal. The combined "Leave this page?" Modal appears when the #179 flush also fails. [quiz-guard-modal]
15. **Failures.** A failed submit shows the Modal's inline message with answers kept. A stale or duplicate submit shows the conflict state. Offline shows its message. A failed reveal shows "Answers aren't available yet."

**Deterministic checks:**

- **Network capture.** Record every response body (Supabase RPC calls and `lesson-content.json`) per step. Assert none contains a sentinel (accepted variants, explanations, model answers, fill-in keys, open-ended references) from before submit through every pre-eligibility state (after the first fail, while pending, while attempts remain). Assert no reveal request is issued before the button click. Assert the reveal returns sentinels only after a pass or an exhausted, fully graded attempt. For MCQ, true/false, and matching, assert that no correct-option id or pairing field appears in any pre-eligibility payload and that displayed option order differs from authored order and is stable on reload.
- **Allowlist gate (DR-7).** Every student payload's keys are a subset of the engineering-supplied allowlist, and none match the denylist (answer, `accepted*`, `correct_option*`, explanation, `model_answer`, key, pairing, solution). Per-item result state values such as "correct" are allowed.
- **Shipped content.** Every shipped `lesson-content.json` quiz answer is empty, across all 78 lessons.
- **DOM and storage.** No sentinel in the DOM before reveal (`outerHTML`, hidden and aria-hidden nodes included). `localStorage` and `sessionStorage` hold no answer text at any point.
- **DOM equality.** The injected-content fixture is byte-identical to today's markup at 1440 and 390.
- **Pass-function parity.** The shared integer pass function matches the server function over the case table, and the server result wins on finalize.
- **No-dialog.** Source scan for native dialogs and `beforeunload`, plus a run-time dialog listener that fails on any event.
- **Primary count.** Exactly one `.control--primary` per view per state per the one-primary rule. The desktop Roadmap Mark button is never primary. On the mobile Lesson tab with Q&A active and the quiz actionable, the task bar action is secondary.
- **Loading.** One `role=status` paragraph during load, no flash of the static `ol`, and no layout shift beyond the reserved min-height.
- **Accessibility and structure.** QuizPanel is `role=group` with `aria-label` "Quiz". Fieldset and legend are present, with the legend accessible name containing number plus prompt, and no doubled list numbering. `lang` follows `response_lang`. Nine `.lesson-task-accent-button` per strip with exactly one `tabindex` 0. Chip names contain the status word. `aria-describedby` ids resolve. Axe on every state and viewport. No horizontal scroll at 390 or 320. At 320x256 a focused control is not obscured by the footer. Forced-colors captures of results rows, the key block, chips, and the owner reference sheet. No console errors.
- **Contrast.** The brass-500 radio and select accent is 3.67:1 on paper-50 and 3.55:1 on paper-100, above the 3:1 UI-component floor. Engineering re-checks any component that adds a new pairing.
- **Layout.** Owner column order is identical at all widths. The Roadmap embedded layout switches at 56.24rem and the standalone at 48rem.
- **Extra screenshots:** forced-colors-quiz-results, zoom400-quiz-page, zoom400-owner-grade, spot-768 and spot-1024 of the take view.

#### 4.14 Design assumptions, decisions, and evidence limits

- **Assumptions.**
  - A1 Scoring and normalization are server-side; the client only renders results.
  - A2 Per-item scoring is all-or-nothing at equal weight.
  - A3 The quiz RPCs, definition model, and owner finalize RPCs are new server work parallel to #179, as a QuizDefinition type family alongside the untouched legacy `QuizItem`.
  - A4 Eligibility, the grandfathered cutover flag, `mark_recorded_at`, and unseen state resolve from server calls on load, with no realtime channel; the quiz submit response additionally returns the lesson completion state.
  - A5 The recorded and server-side completion mechanism extends to any outstanding requirement; the #179 mark-intent write is generalized.
  - A6 Authored-course lessons, including `completion_rule` 'quiz_pass', get no definition and are unchanged; enforcement is a follow-up.
  - A7 The owner completion override bypasses blockers, including the quiz requirement (#179 D3).
  - A8 Spanish chrome and all sample items are owner-authored placeholders via `site_content`.
  - A9 Student answers echoed in results are the student's own and are not a leak.
  - A10 Per-item correctness after each attempt lets a student infer true/false answers across 3 attempts. This is an accepted consequence of user decision 3, not a design defect.
  - A11 Accepted limits: reload, Back, Forward, and tab close lose unsubmitted answers (no persistence and no `beforeunload`); owner finalization is visible only on next load; no primary is shown on mobile Cards or Files tabs while the task or quiz is actionable.
  - A12 The lenient accent note discloses that a correct answer differed from the key in an accent mark. Accepted; the strict alternative copy is specified.
- **Design unresolved decisions and their disposition in this plan (Section 12):** accent policy (U1); exhausted recovery CLOSED (owner completion override, no reset-attempts in v1); grandfathered default optional practice with the "Practice" tag (alternative: hide the quiz); owner grades final and read-only in v1 with a consequence line in the Finalize Modal ("reopen" is a follow-up); partial credit none; in-progress persistence in-memory only with the guard Modal (a `sessionStorage` mirror was considered and rejected because it would make the guard redundant and persist answers on shared devices); authored `quiz_pass` enforcement out of scope (follow-up); pass-mark rounding by the integer test `correct*100 >= pass_percent*total`, shown as k = ceil(pass% x total); text normalization case-insensitive, trimmed, whitespace collapsed (punctuation handling is specified in A4 of Section 6); reveal source attempt is the final attempt (the pass attempt, or the 3rd), labelled "from attempt {n}"; teacher comments shown per item once the attempt is graded; character limits 200, 2000, 1000; `/learn` within-card order task link, quiz link, Mark.
- **Evidence and limits.** The design is a static review: no rendered screenshots or live validation were run. The `/admin/submissions*` routes, `get_lesson_task`, and every #179 server contract named here do not exist in the 175 checkout; they are specified by the #179 plan and this handoff, and Step 0 re-verifies them. The `LearnDetailPage` line 259 finding is the UX specialist's and was not independently re-read by the director beyond lines 270-310. The director did not re-run the specialists' other `contrast_check` results. Planner server-scope facts were taken as given by the design. Design evidence reads: #179 plan lines 112-444; `docs/DESIGN-CONTRACT.md`; `LessonContentView.tsx` 260-350; `lessonContent.ts` 35-69; `LearnDetailPage.tsx` 1-125 and 230-319; `Modal.tsx`; `LessonCompletionControl.tsx`; `useLessonCompletion.ts`; `CourseWorkspacePage.tsx` 236-361; `App.tsx` 79-95; `useRoute.ts` 34 and 152-166; CSS files `LessonContentView.css`, `FeedbackLedgerRow.css`, `journal-devices.css`, `Field.css`, `FeedbackForm.css`, `CourseWorkspace.css`, `App.css`, `field-workbook.generated.css`.

## 5. Judge route

- **Risk:** high (new security-definer RPCs, RLS, answer-key separation, completion gating).
- **Call cap:** 4, with one checkpoint repeat inside the cap. Extra calls need user approval. Deterministic failures dominate. Finding IDs from any judge pass flow into the engineering jobs and into Verifier checks. This plan reproduces no model-generated finding.
- **Accounting:** PLAN_DUCK used 1 of 4 (high-risk cap); CODE_REVIEW #1, CODE_REVIEW #2, and one optional VISUAL_REVIEW or repeat remain.
- **PLAN_DUCK** ran once in shadow/advisory mode (result REVISE; revision 1 applied, see the table near the top), rubric J-180-PLAN: no answer key, accepted answer, explanation, model answer, or correct option id reaches any student path before reveal eligibility (RPC payloads, `quiz_attempts` RLS select, `lesson-content.json`, recap, PPTX/PDF, retired Edge 'grade', dist); attempt cap and pending-attempt lock are race-safe; the completion gate cannot be bypassed by any student-callable or sync path and grandfathering never clears `completed_at`; PR order keeps main releasable; browser inputs complete.
- **CODE_REVIEW #1 after PR A:** required. Rubric J-180-SEC: definer `search_path`, grants and revokes (internal and owner functions service_role only; student RPCs authenticated only), `auth.uid` binding, canonical eligibility parity with #176 and #179, no key material in any student payload or in `quiz_attempts` columns, normalization correctness, anti-probing measures, idempotency and locking, retirement of `submit_quiz_attempt` and Edge 'grade'.
- **CODE_REVIEW #2 after PR D:** required. Rubric J-180-COMPLETION: `quiz_pass` blocker via the #179 extension point only, finalize at the last requirement atomically (submit and owner grade paths), quiz cutover and sync gating, practice-mode semantics, client never fabricates completion, recorded-to-completed without Stamp, leak guards enforcing, plain-text rendering.
- **VISUAL_REVIEW:** optional, on 390 and 1440 screenshots against Section 4 (uses the 4th call if no repeat was needed).

## 6. Ordered work

Owner: engineering-fleet, standard mode. T1 first line, Verifier after each PR, Browser Validator after PR C (owner) and PR D (full); T2 on two counted gate failures. Scribe authors PR B content batches and follow-up texts.

FOUR PRs, one per phase, merged in order A, B, C, D, each on a new branch from the then-current `origin/main` and respecting the sequencing in the header. Main stays releasable after each merge because no student-visible change and no completion change ships before PR D. Production rollout happens only after PR D as one user-gated hosted release.

### Step 0. Preflight (T1, each PR)

- Fresh worktree from `origin/main`. Confirm predecessors are merged (see header sequencing).
- Re-verify every F-line reference and #179's shipped function names and signatures: `lesson_completion_blockers`, `finalize_lesson_completion`, `completion_gate_settings`, `resolve_lesson_task_template` (or an extracted content-key helper), the guard registry, chips, and inbox query params.
- Check the latest migration timestamp; every #180 migration sorts after it.
- Run `npx supabase start` FROM the target worktree (the Edge runtime mounts the worktree that started the stack; otherwise `npx supabase stop` then start).
- Run `npx supabase db reset`, then `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`.
- Confirm 78 lessons, band names, and `fullaccess@test.local` entitlements.

### PR A. Schema, RPCs, RLS, keys pipeline, parser fix

T1, TDD. No UI change and no completion change.

**A1. Quiz parser and audit.**

- `scripts/lib/parseQuizSection.ts` parses the "### Quiz" section of `curriculum/lessons/*/phrases-and-qa.md` with all marker variants (`**Answer:**`, `**Answer (<label>):**`, `**Model answer:**`), joins hard-wrapped lines, and records the variant label.
- `scripts/audit-quiz-items.ts` writes `docs/evidence/issue-180/quiz-item-audit.json`: per lesson curriculum item count versus content-source quiz length, merged-item detections, variant labels, prompt-prefix family counts, and inline-answer candidates.
- Fix the content-source quiz arrays for merged items (quiz arrays only; parity test content-source versus parser for all 78).
- If the nested `tools/lesson-generation` repo is present, fix `parse_quiz` there and export via `scripts/export-tooling-patches.ts` parameterized for issue-180 (`docs/tooling-patches/lesson-generation/issue-180/`). Otherwise record a follow-up (R13).

**A2. Authoring format.**

- One file per lesson `content-source/quizzes/<band>-week-NN.quiz.json` (outside `src`, never bundled, never uploaded), validated by a hand-written validator `scripts/lib/quizDefinitionSchema.ts` (no new dependency).
- Per item: stable `id` (q01…), `source_index`, `type` (`true_false` | `fill_in` | `multiple_choice` | `matching` | `open_ended`), `prompt`, `response_lang` (es|en|mixed|absent), `options` [{id opaque random, text}], blank count with literal `[n]` markers, matching `left[]`/`right[]` with opaque ids, `teacher_graded` flag.
- Key part: correct value (boolean | option id | per-blank `accepted[]` | left-to-right map | reference or model answer), accent policy override (inherit|strict|lenient), explanation, ambiguity flag, curriculum citation.
- Exemplar: one lesson fully authored in PR A (planner suggests beginner-week-05; T1 or the owner may pick) plus a `PENDING_WEEKS` list (the #178 pattern; the completeness test stays red until PR B finishes).

**A3. Generator.** `scripts/generate-quiz-seed.ts` writes `supabase/migrations/<ts>_issue180_seed_lesson_quiz_definitions.sql`: idempotent upsert keyed by (`content_key`, `content_hash`); a changed hash inserts version n+1 and retires the prior active row; student-safe `definition` jsonb and owner-only key jsonb in separate tables; deterministic output; drift test (byte-identical regeneration).

**A4. Schema migration** `<ts>_issue180_lesson_quizzes.sql` (forward-only, additive) plus an unapplied rollback `supabase/rollbacks/issue180_lesson_quizzes_rollback.sql`.

- `lesson_quiz_definitions(id uuid pk, content_key text, version int, status active|retired, definition jsonb student-safe only, max_attempts int default 3 check 1..10, pass_percent int default 80 check 1..100, reveal_policy text default 'after_pass_or_final', content_hash text, created_at; unique(content_key, version); partial unique (content_key) where active)`.
- `lesson_quiz_answer_keys(definition_id pk references lesson_quiz_definitions on delete cascade, keys jsonb not null)`: owner-only.
- `quiz_attempts` additive nullable or defaulted columns: `enrollment_id` (references `student_enrollments` on delete cascade), `definition_id` (references `lesson_quiz_definitions` on delete restrict), `definition_version`, `attempt_no`, `item_results jsonb` (per item: `status` correct|incorrect|pending, `accent_note` boolean, `teacher_comment`; NEVER key material), `status text check in ('graded','pending_review') default 'graded'`, `correct_count`, `total_count`, `graded_by` (`auth.users` on delete set null), `graded_at`, `client_token uuid`, `is_practice boolean default false`, `revision int default 1`, `student_seen_at`. Existing `score` and `passed` keep their meaning; `passed` is final only when `status='graded'`.
- Unique partial index (`enrollment_id`, `lesson_revision_id`, `attempt_no`) where `enrollment_id` is not null; unique (`enrollment_id`, `lesson_revision_id`, `client_token`). The attempt cap is per enrollment (a user has one enrollment per band; wipe-save resets).
- The existing `quiz_attempts_own` select policy stays. Because students can select their own rows directly, `item_results` and `answers` must hold only correctness and the student's own responses (test).
- Revoke all from anon and authenticated on the two new tables; service_role grants; indexes on `quiz_attempts(status, submitted_at desc)` and `(enrollment_id, lesson_revision_id)`.
- **Internal service_role-only definer functions** (`set search_path = public`; revoke from public, anon, authenticated; grant execute to service_role): `resolve_lesson_quiz_definition(p_lesson_revision_id)` (reuse #179's content-key mapping or extract a shared helper and call it from both resolvers; NULL for authored lessons), `grade_quiz_responses` (pure scoring and normalization), `grade_lesson_quiz_attempt` (owner), plus the owner read helpers.
- **Student RPCs** (definer, `set search_path = public`, revoke from public and anon, grant execute to authenticated). Guards on every call: `auth.uid` not null; not `user_requires_password_change()`; `is_account_active(auth.uid())`; own enrollment status 'active'; entitlement exists with `manual_release_state in ('automatic','released')` AND (`manual_release_state = 'released'` OR `unlock_at <= now()`) (the #176 rule as an allowlist); definition resolvable; otherwise fail closed with one generic result (NULL or a single generic error; no reason disclosure).
  - `get_lesson_quiz(p_enrollment_id, p_lesson_revision_id)` returns jsonb or NULL: student-safe items (ids, type, prompt, `response_lang`, `teacher_graded`, options and matching right column in server-shuffled order stable per (enrollment, definition) via a hash ordering, blank count), policy (`max_attempts`, `pass_percent`, `attempts_used`, `attempts_remaining`, `can_start`, `closed`), attempts (`attempt_no`, `status`, `correct_count`, `total_count`, `percent`, `passed`, `item_results`, own responses, teacher comments, `submitted_at`), `best_percent`, `reveal_eligible`, practice flag (grandfathered), `mark_recorded_at`, `completed_at`, unseen flag.
  - `get_lesson_quiz_summaries(p_enrollment_id)` returns per eligible lesson `{lesson_revision_id, legacy_lesson_id, chip status, best_percent, attempts_used, unseen, practice}`.
  - `submit_lesson_quiz_attempt(p_enrollment_id, p_lesson_revision_id, p_responses jsonb, p_client_token uuid, p_expected_attempt_no int)`: locks the entitlement row (`select … for update`) to serialize. Rejects when `attempts_used >= max_attempts`, when any attempt is `pending_review`, when the quiz is passed or closed, or on attempt-number mismatch (distinct conflict result). A repeated `client_token` returns the original result (idempotent). Validates response shape (keys subset of item ids, type-correct values, 200 chars per blank, 2000 per open-ended, total payload cap). Scores auto items server-side; status `pending_review` if any teacher item. Returns `{attempt_no, status, item_results, correct_count, total_count, percent, passed (null while pending), attempts_remaining, reveal_eligible, completed_at}`; never returns keys. Writes activity event `quiz_attempt_submitted` (actor student). The new name avoids overloading the legacy function.
  - `reveal_lesson_quiz(p_enrollment_id, p_lesson_revision_id)` returns jsonb or NULL: only when a graded attempt passed OR `attempts_used = max_attempts` and every attempt is graded. Returns per item the correct and accepted answers, explanation, model answer, and the student's answer from the reveal source attempt (the passing attempt or the final attempt). Generic NULL otherwise.
  - `mark_lesson_quiz_results_seen(p_enrollment_id, p_lesson_revision_id)`: idempotent (EN-1 pattern).
- **Normalization** (server, table-driven, unit and SQL tested): NFC; case-insensitive; trim; collapse internal whitespace; ignore surrounding and inline punctuation `. , ; : ! ? ¿ ¡ " '` and quotes; accent policy per decision U1 (default lenient-with-note: a response differing only in á/é/í/ó/ú/ü versus a/e/i/o/u counts correct with `accent_note=true`; ñ versus n must always match; per-item override strict or lenient); multiple accepted answers per blank; all-or-nothing per item at equal weight (every blank and every matching pair correct); pass test `correct*100 >= pass_percent*total` (integer). One shared TypeScript pass function is used by the owner preview, with a parity test against SQL.
- **Anti-probing.** Per-item correctness is a user decision (accepted consequence: true/false inference across 3 attempts). Bounds: the attempt cap, the pending lock, closed-after-pass, no single-item check endpoint, opaque random option ids not ordered by correctness, server shuffle, generic errors, idempotent `client_token`, and keys only via the eligibility-checked reveal.
- **Retire legacy grading.** `create or replace` `submit_quiz_attempt(uuid, jsonb)` to raise a generic 'retired' error and revoke execute from authenticated. The `course-authoring` 'grade' actions (public 42-46 and owner 413-417) return 410 with a generic message. Deliberately update `issue5BackendIntegration.test.ts:60-63`; `issue5BackendContract.test.ts` reads the old migration file and stays green.

**A5. Leak guards** (report mode for quiz and recap until PR D; enforcing for keys in dist now). Extend `scripts/check-no-lesson-content-leak.js` or add `scripts/check-no-answer-leak.ts`, wired into `verify:build`:

- (i) dist scan for key, explanation, and model-answer fingerprints (normalized strings of at least 12 chars) from the authoring files;
- (ii) storage-seed `lesson-content.json` quiz answers non-empty: report now, fail from PR D;
- (iii) storage-seed recap "Answer" markers: report now, fail from PR D;
- (iv) report-only text extraction of the 78 instructor PPTX and student-handout PDFs for quiz and recap answer strings, output to `docs/evidence/issue-180/artifact-answer-extraction.json` (input to decision U2);
- (v) hosted mode: `scripts/check-no-answer-leak.ts` gains a read-only `--hosted` mode (service-role download only, exact project-ref allowlist, refuses any write, prints no secrets) used by hosted steps H4 and H7; unit-tested against a local stack.

**A6. Tests.**

- Live SQL and RLS (vitest against the reset local stack, exact URL guard `http://127.0.0.1:54321`):
  - anon and authenticated cannot select `lesson_quiz_answer_keys` or `lesson_quiz_definitions`;
  - `get_lesson_quiz` and every student RPC payload contain no sentinel key strings and no key-bearing field names (allowlist and denylist gate);
  - every guard negative separately: other student, inactive enrollment, deactivated account, password-change flag, held, revoked, future unlock, released-early allowed, unauthenticated, authored lesson NULL, no definition NULL;
  - attempt cap; pending lock; closed after pass; concurrent double submit (two sessions) yields one attempt; `client_token` idempotency; attempt-number conflict;
  - normalization table (case, accents per policy, ñ, punctuation, whitespace, multiple accepted, multi-blank, matching all-pairs);
  - reveal eligibility matrix (before any attempt, after fail with attempts left, pending, exhausted fully graded, passed, practice);
  - `quiz_attempts` direct select shows no key material;
  - owner grade function authz (non-owner and stale revision denied);
  - privilege tests `has_function_privilege` and `pg_proc` ACL per the #176 pattern (`src/__tests__/issue176-completion-foundations-sql.test.ts` ~541-547) for every internal and owner function; direct invocation as anon and student denied; legacy `submit_quiz_attempt` denied for authenticated; Edge 'grade' returns 410;
  - activity events exactly one per success, none on failure;
  - legacy `quiz_attempts` insert tests (F4) still pass.
- Unit: parser variants and hard-wrap joining, validator, generator drift, normalization, pass function parity.

**A7. Verification.** `type-check`, `lint`, full vitest, `verify:build`, `check:practice-complete`; Verifier; CODE_REVIEW #1.

### PR B. Content authoring batches

Depends on PR A merged. Owner: Scribe authors the quiz authoring files; T1 owns validator, generator, and tests; a gate runs per batch, modeled on #178 Step 5.

**Gate Q (before any batch):** the user or owner approves the exemplar lesson and the typing rules below.

**Typing rules (defaults; decision U3):**

- Translate, Explain, Name: `open_ended`, teacher-graded (user decision).
- True or false: `true_false`.
- Which/Choose with curriculum-supplied options: `multiple_choice` (options only from the lesson's own content; no invented facts).
- Fill-in/Complete: `fill_in` with accepted variants.
- Correct-the-error: `fill_in` (corrected form) with accepted variants, else teacher-graded.
- What/Why/other: `fill_in` only when the curriculum answer is a single short canonical answer, else teacher-graded.
- Matching only where the item already lists pairs.
- ANY item whose answer is not uniquely determinable ("any three", "one reasonable option", model answers, multi-part analysis): teacher-graded, with the curriculum answer as the owner reference.
- Explanations come from the curriculum answer text; no new curriculum claims.

**Batches:** six, by band and half (beginner 1-13, beginner 14-26, intermediate 1-13, intermediate 14-26, advanced 1-13, advanced 14-26).

**Per-batch gate:**

1. T1 removes the batch from `PENDING_WEEKS`; validator and parity green (item count equals the corrected curriculum count).
2. Independent read-only Verifier rubric review: fidelity to curriculum, type per rules, key correctness against the curriculum answer, accepted variants plausible and not over-broad, distractors grounded and unambiguous, lang tags, accent overrides justified, explanation grounded, ambiguous items teacher-graded.
3. One Scribe fix and re-check; a second failure blocks for user review.
4. Owner sample review of one week per band before merge.
5. T1 regenerates the seed migration; coverage test 78/78 green; teacher-graded share reported in the audit file.

### PR C. Owner results and grading

Depends on #179 PR B and #180 PR B merged. Standard T1; works on service-role-seeded attempts; no student UI yet.

**C1. Edge actions** in `supabase/functions/admin-student-operations/index.ts` (owner gate, service-role client, `isValidUUID`, `classifiedErrorResponse` patterns):

- Extend #179's `task-submissions-inbox` with `type=task|quiz|all` (quiz statuses `awaiting_review|reviewed`; Practice-tagged rows shown but excluded from counts).
- `task-submissions-count` includes non-practice pending quiz attempts.
- `quiz-attempt-detail`: definition, keys and references, student responses, item results, attempt history; owner only.
- `quiz-attempt-grade`: per pending item `correct|incorrect`, optional comment of at most 1000 characters, expected revision. Calls `grade_lesson_quiz_attempt` (status `pending_review` required; all pending items graded; recompute counts, percent, passed; `graded_by` and `graded_at`; activity events `quiz_attempt_graded` actor owner). In PR C it records the grade only; finalize-on-pass is added in PR D.
- `handleDashboard` attention reasons `quiz_awaiting_grading` and `quiz_exhausted` and the quiet line "{n} awaiting your review ({t} tasks, {q} quizzes)".
- `handleGetStudentDetail` Quizzes list (best score, attempts, per-attempt per-item results).
- `course-authoring` `list_lesson_entitlements` adds quiz status per lesson.
- `handleWipeSave` also deletes that enrollment's quiz attempts (mirrors #179 D5; revoke still preserves attempts).

**C2. Owner UI per design:** `OwnerQuizAttemptDetailPage` at `/admin/submissions/quizzes/:attemptId`, `QuizItemGradingRow`, `?type=` on `OwnerSubmissionsPage`, owner-quiz ledger rows via `SubmissionLedgerRow`, student-detail and roster chips (shared chip modifier), dashboard reasons, owner guard registration, caption "Grades aren't saved until you finalize.", Finalize Modal.

**C3. Tests.**

- Edge: non-owner 403; malformed ids; keys only in owner detail; grade state machine including stale revision and incomplete grades; comment bounds; practice excluded from counts; wipe-save deletes attempts; exactly one attributed event per success.
- RTL; Playwright owner journeys with seeded attempts.
- No-native-dialog and `dangerouslySetInnerHTML` source scans; XSS inert-payload tests in owner views (payloads as in #179: `<img src=x onerror=alert(1)>`, `<script>alert(1)</script>`, `javascript:alert(1)`, `[link](https://example.com)`, bare URL).
- Verifier; Browser Validator (owner journeys 8 and 12 at 390 and 1440, on seeded attempts).

### PR D. Student UI, completion integration, artifact stripping

Depends on #179 PR C and #180 PR C merged.

**D1. Completion migration** `<ts>_issue180_quiz_completion_gate.sql` (create or replace; rollback updated).

- `completion_gate_settings` gains `quiz_cutover_at` (set to the migration's `now()`).
- `create or replace` #179's `lesson_completion_blockers` to add 'quiz_pass' when an active quiz definition resolves and the enrollment has no graded passed attempt for the revision.
- Add an as-of variant (internal helper) so sync paths apply 'task_review' only for completions at or after `cutover_at` and 'quiz_pass' only at or after `quiz_cutover_at`. Keep #179's public signature as a wrapper. `sync_enrollment_completions` and `sync_legacy_completion_to_entitlement` use the as-of rule. Blockers are evaluated only when entitlement `completed_at` is null, so existing completions are never touched.
- **Practice mode.** An attempt submitted while the entitlement is already completed is `is_practice=true` and never changes completion. The `get_lesson_quiz` practice flag equals entitlement `completed_at` not null. A Mark-recorded but incomplete lesson at quiz cutover simply gains the quiz requirement.
- `submit_lesson_quiz_attempt` (auto-only pass) and `grade_lesson_quiz_attempt` (owner pass) call #179's `finalize_lesson_completion` in the same transaction when `student_marked_complete_at` is set and blockers are now empty. `set_lesson_completion`'s `bypassed_blockers` includes 'quiz_pass'. Event `lesson_completion_finalized_on_quiz_pass` (actor student or owner).

**D2. Content stripping.**

- `scripts/generate-lesson-content-json.ts` emits quiz items with empty `answer` for all 78 lessons (`validateGeneratedLessonContent` updated); regenerate 78 `lesson-content.json`.
- Recap: the `provision-lessons` copy step applies a pure `stripRecapAnswers()` (removes "(Answer: …)" parentheticals and "**Answer:**" segments in self-test lists; curriculum source unchanged) and the 78 storage-seed recaps are regenerated. Rerun the #175 lang golden with `UPDATE_VOCAB_GOLDEN=1` and confirm the diff is empty or limited; if any tagged paragraph changes, the #175 Spanish-literate spot-check release gate applies.
- PPTX and PDF per decision U2. Leak guards switch to enforcing.
- **Frontend compatibility requirement.** The new frontend works with both the old (answers present) and the stripped `lesson-content.json`: when `get_lesson_quiz` returns a definition it renders the QuizPanel and never renders the JSON answer field; when it returns NULL the static list shows the Answer paragraph only if the answer is non-empty. RTL test with both JSON shapes.

**D3. Client completion.** `useLessonCompletion` recorded state generalized to any outstanding requirement; recorded to completed in session without `justCompleted` and without Stamp when a submit returns `completed_at`; `/learn` never fabricates `completed_at` or the count.

**D4. Student UI per design:** `LessonQuizProvider`/`useLessonQuiz` (one per page), `QuizPanel` (`role=group` "Quiz"), `QuizAttemptBanner`, `QuizItemFieldset` (one dispatcher), `QuizResultsView`, `QuizRevealView`, `QuizStatusChip` modifier, `AccentStrip` per text field, error summary, Submit Modal and "Leave this quiz?" via the shared guard registry aggregator, loading placeholder, Roadmap Q&A integration (conditional Answer paragraph), `/learn` card chip, link, and route, `WeekCard` chip, unseen clear, `site_content` keys `lesson_quiz.*`.

**D5. Tests.**

- SQL gate tests: mark before pass records intent; auto pass finalizes atomically; owner grade pass finalizes; mark after pass completes immediately; task plus quiz ordering in both orders; grandfathered unchanged with before and after `completed_at` counts; practice attempts never complete; owner override bypass; sync-path regressions direct and via the `record_lesson_progress` lazy path, `resume_band_enrollment`, and seed reset; pre-cutover progress still syncs.
- Privilege tests for new and changed internal functions.
- Unit and RTL: one-primary per state; recorded-to-completed without Stamp; byte-identical no-definition component fixture; `lessonContentViewDesktopVisualNonRegression` updated only for the permitted delta; `RHYTHM_SEGMENTS` unchanged. Tests await provider settle (DR-12).
- Playwright student journeys 1-16 at 390 and 1440 with network capture (no sentinel or key-bearing field in any response before reveal eligibility; reveal request only after click), keyboard-only, and the no-native-dialog runtime listener.
- Leak guard enforcing: all 78 `lesson-content.json` quiz answers empty; zero recap answer markers; dist clean.
- XSS inert payloads in student views.
- Verifier; Browser Validator (full student journeys 1-16, including journey 16, exhausted then owner override, which needs the student quiz UI); CODE_REVIEW #2; optional VISUAL_REVIEW.

### Hosted and production (SEPARATE, USER-GATED; not covered by plan approval)

After PR D, coordinated with #179's hosted steps. Each step needs an explicit go-ahead naming project `gvobtuhbpqvfhjljjcye`.

- H1: apply the schema and definition/key seed migrations (no completion gate). Invisible to students: no deployed client calls the new RPCs; the legacy `submit_quiz_attempt` revoke and Edge 'grade' 410 are safe because no client uses them.
- H2: deploy Edge `admin-student-operations` and `course-authoring`.
- H3: re-provision the 78 stripped `lesson-content.json` and the 78 stripped `weekly-review-recap.md` files (and the U2 disposition: owner-only instructor PPTX access change and/or regenerated student-handout PDFs, if the PR A extraction found answers) with `provision-lessons` hosted guards and #173 content types. The still-deployed old frontend keeps working: it renders the static quiz questions with an empty "Answer:" line (accepted cosmetic limit until H5); the #175 recap viewer is content-agnostic.
- H4 (HARD GATE): hosted read-only leak verification. Run the extended leak guard in hosted read-only mode against hosted storage: download every hosted `lesson-content.json`, `weekly-review-recap.md`, and each U2-covered artifact (service-role read-only, exact project-ref allowlist, no writes) and assert zero non-empty quiz answers, zero recap "Answer" markers, and zero answer-key, explanation, and model-answer fingerprints. Also a student-authenticated fetch spot check (one lesson per band) returning the stripped bytes; answer-key tables not readable by authenticated; legacy `submit_quiz_attempt` not executable by authenticated; 78 active definitions resolve. Any failure stops the release (no H5) and is remediated by re-running H3.
- H5: Netlify deploy of the new frontend (interactive quiz UI). Run H3 to H5 back-to-back in one release window to minimize the cosmetic window.
- H6: apply the quiz completion gate migration (`quiz_cutover_at`, `quiz_pass` blocker, sync gating) last, only after H5 is live, so students are never gated without the UI.
- H7: post-activation read-only verification: `completion_gate_settings.quiz_cutover_at` set; hosted function definitions match the merged migration; leak guard re-run clean; one student-authenticated end-to-end check by the user or owner if they choose.

**Coordination with #179 (ordering note).** When #179 and #180 release together or close together, #179's translation-task answer stripping rides the same H3 re-provision and the same H4 hosted verification (H4 also asserts zero "**Answer:**" in hosted `translationTask`), and any completion gate (#179's `task_review` gate and #180's quiz gate) is activated only after the frontend that renders the corresponding UI is live (H6). The #179 plan currently lists its gate among its H1 migrations and its stripping at H3 before its Netlify deploy at H5, so the orchestrator must reconcile #179's hosted order with this note before #179's production release (cross-plan item; no #179 file is edited here).

### Follow-ups (text drafts only; GitHub writes user-gated)

- Authored-course `quiz_pass` and `manual` enforcement.
- Owner reset-attempts.
- Reopen finalized grades.
- Nested Python `parse_quiz` fix if the nested repo was absent.

## 7. Interfaces and data

- **New tables:** `lesson_quiz_definitions`, `lesson_quiz_answer_keys`. **Extended:** `quiz_attempts` (additive nullable columns), `completion_gate_settings.quiz_cutover_at`.
- **New student RPCs** (names indicative per the design's permitted variation; the contract is fixed): `get_lesson_quiz`, `get_lesson_quiz_summaries`, `submit_lesson_quiz_attempt`, `reveal_lesson_quiz`, `mark_lesson_quiz_results_seen`.
- **New service_role functions:** `resolve_lesson_quiz_definition`, `grade_quiz_responses`, `grade_lesson_quiz_attempt` (plus owner read helpers).
- **Changed:** #179 `lesson_completion_blockers` (adds `quiz_pass`) and the sync paths. **Retired:** `submit_quiz_attempt` (execute revoked) and Edge 'grade' (410).
- **New Edge actions:** `quiz-attempt-detail`, `quiz-attempt-grade`. **Extended:** `task-submissions-inbox` (`?type`), `task-submissions-count`, dashboard, student-detail, wipe-save, `list_lesson_entitlements`.
- **Generated artifacts:** 78 quiz authoring files, seed migration, 78 regenerated `lesson-content.json` (empty quiz answers), 78 regenerated recaps, audit and extraction evidence under `docs/evidence/issue-180/`.
- **Unchanged:** `LessonContent` type shape (`QuizItem` keeps `question`/`answer`; `answer` is empty), `get_student_learn_course`, resources and storage RLS (unless U2 chooses owner-only PPTX), the authored-course `assessment_answer_keys` path.
- **Compatibility:** legacy `quiz_attempts` rows remain valid; old clients never called 'grade'.
- **Key correction after launch:** a corrected key ships as a new definition version via the seed generator; it applies to new attempts; existing attempts keep their recorded results; the owner override covers any student harmed by a wrong key.

## 8. Acceptance checks

- 78/78 definitions resolve after `db reset`; the quiz-item audit reconciles every curriculum item; the drift test is byte-identical.
- Zero quiz answers in all 78 storage-seed `lesson-content.json` and zero recap answer markers at PR D; dist scan clean; the extraction report is produced and the U2 disposition applied.
- anon and authenticated cannot read the keys and definitions tables. No key-bearing field or sentinel in any student payload before eligibility (allowlist gate).
- Attempt cap, pending lock, idempotency, reveal matrix, and normalization table are green.
- Function privileges: internal and owner functions are service_role-only; student RPCs authenticated-only; direct invocation as anon or student is denied; legacy `submit_quiz_attempt` is not executable by authenticated and Edge 'grade' returns 410.
- The completion gate cannot be bypassed via any student or sync path; grandfathered completions are unchanged.
- UI: design journeys 1-16 at 390x844 and 1440x900 plus spot checks (320, 320x256 at 400% zoom, 768, 1024, forced-colors); exactly one `.control--primary` per view and state; axe zero critical or serious; no horizontal scroll at 390 and 320.
- `npm run type-check`, `lint`, full vitest (live suites on the reset local stack), `verify:build`, `check:practice-complete`, targeted Playwright (new specs plus existing wp10, wp11, phase5 learn, gap-3, and #179 specs) green.
- Verifier PASS per PR; Browser Validator PASS after PR C (owner) and PR D (full); CODE_REVIEW #1 and #2 with no unresolved blocking finding.
- Frontend compatibility: the new frontend renders correctly with both the old (answers present) and stripped `lesson-content.json`, never rendering the JSON answer field when a definition exists (RTL test with both shapes).
- The leak guard's read-only `--hosted` mode is unit-tested against a local stack.
- Hosted H4 leak verification passes before H5 and H6; the completion gate is applied last (H6).

## 9. Browser UI dialog policy and browser validation inputs

**Dialog policy (required).** The Browser UI invariant applies. No `alert`, `confirm`, `prompt`, `window.alert`/`confirm`/`prompt`, or `beforeunload`. Only app-owned Modals via `src/components/Modal.tsx`: "Submit attempt {n} of 3", "Leave this quiz?" (aggregated with #179's guard; X, Escape, and backdrop mean Stay), and "Finalize grades for attempt {n}". Inline validation with an error summary. A deterministic source scan is required in PR C and PR D (grep `src` for `\b(window\.)?(alert|confirm|prompt)\s*\(` and `beforeunload`) plus a Playwright runtime dialog listener that fails on any dialog event.

**`browser_ui_validation` inputs.**

- **Launch and readiness:** `npx vite --port 5180 --strictPort` (ready when `http://localhost:5180` serves the sign-in page).
- **Base URL:** `http://localhost:5180` (Playwright `E2E_BASE_URL=http://localhost:5180`).
- **Fixture and reset:** `npx supabase db reset`, then `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`. For Edge changes run `npx supabase stop` and `npx supabase start` from the target worktree.
- **Accounts** (password `password`): `fullaccess@test.local` (primary student), `student1-6@test.local` per the design fixture mapping (Section 4.13), `owner@test.local`.
- **Per-journey states** (attempt histories, pending, exhausted, held, revoked, date-locked, grandfathered, sentinel keys) are created by service-role test setup on the exact local URL `http://127.0.0.1:54321`, never by product code.
- **Viewports:** 390x844 and 1440x900 (spot checks 320, 320x256 at 400% zoom, 768, 1024, forced-colors).
- **Journeys and visible outcomes:** design validation journeys 1-16 (Section 4; the design brief lists journeys 1-15 in Section 4.13 and J16 in Section 4.2); screenshots under `browser-validation-artifacts/`.

## 10. Risks and rollback

| ID | Risk | Mitigation and rollback |
| --- | --- | --- |
| R1 | Answer-key leak (RPC, `quiz_attempts` select, JSON, recap, PPTX/PDF, legacy grade, dist) | Separate owner-only tables, payload allowlist and denylist gate, sentinels, network capture, leak guards, CODE_REVIEW #1 and #2. Rollback: revert the PR; hosted H3 re-provision can restore prior objects only if the stripped content itself is defective (never to reintroduce answers once the new UI is live). |
| R2 | Answer probing via per-item correctness | Accepted consequence of the user decision; bounded by cap, pending lock, closed-after-pass, opaque ids, shuffle, idempotency; the owner sees attempts. |
| R3 | Completion bypass or wrong grandfathering | #179 extension point only, as-of sync rule, quiz cutover, practice mode, tests per path. Rollback: the rollback file restores #179 function bodies; `completed_at` is never cleared. |
| R4 | Owner grading load (teacher-graded share estimated at least ~40% of items by the user's typing rule) delays completions | Single inbox count, dashboard reasons, practice excluded, owner override; decision U3. |
| R5 | Wrong or over-broad keys from authoring | Gate Q, per-batch Verifier rubric, owner samples, ambiguity to teacher-graded, key-correction versioning, owner override. |
| R6 | Concurrency and double submit | Row lock, unique indexes, `client_token` idempotency. |
| R7 | #179 dependency drift (names, signatures, inbox, guard registry) | Step 0 re-verification; stale-plan trigger. |
| R8 | #175 recap viewer and golden regression | Golden rerun; spot-check gate if tagged paragraphs change. |
| R9 | Hosted ordering (answers fetchable while new UI/gate live; gate before UI) | Strip and re-provision first (H3), hard read-only hosted leak verification (H4) before the new UI (H5), completion gate last (H6), post-activation verification (H7); frontend compatible with both content shapes; #179 coordination note. Rollback: hosted rollback SQL for the gate; previous Netlify deploy; previous storage objects only if the stripped content itself is defective (never to reintroduce answers once the new UI is live). |
| R10 | `LessonContentView` desktop and mobile regressions | Component-level byte-identical fixture, permitted delta only, Browser Validator. |
| R11 | Legacy grading path abuse | Execute revoked, Edge 410. |
| R12 | Legacy `quiz_attempts` tests and revoke-preservation semantics | Additive nullable columns; tests stay green. |
| R13 | Nested Python tool absent from the repo | TS parser authoritative; patch export when present. |
| R14 | Stored XSS via responses and comments | Escaped plain text, source scans, inert payload tests. |

**Overall rollback:** revert PRs in reverse order (D, C, B, A); local `npx supabase db reset`; hosted rollback SQL, previous Edge deploy, previous storage objects.

## 11. Stale-plan conditions

The writer must return a blocker ("Plan stale") if any of the following holds:

- The #179 plan changes, or #179 ships different names or signatures for `lesson_completion_blockers`, `finalize_lesson_completion`, `completion_gate_settings`, mark intent, the inbox, the guard registry, or chips.
- #179 is not merged in the stated order.
- `origin/main` changes `record_lesson_progress`, `record_lesson_completion`, `set_lesson_completion`, the sync paths, `quiz_attempts`, `assessment_answer_keys`, `submit_quiz_attempt`, `LessonContentView`, `LearnDetailPage`, `WeekDetailPage` completion wiring, `useLessonCompletion`, `admin-student-operations` dashboard, student-detail, or wipe-save, or the #175 recap viewer or golden.
- Curriculum quiz content or counts change materially.
- `seed.sql` lesson insertion moves into migrations.
- Any decision U1 to U4 or adopted default is answered differently after approval.
- Local reset no longer yields band entitlements.

## 12. Assumptions and decisions

**Safe assumptions:**

- Bands are named Beginner, Intermediate, Advanced (verify in Step 0).
- Legacy lessons map to `revision_no` 1.
- Counts and badges load on navigation (no realtime).
- English UI ships first via `site_content`; Spanish comes from the owner.
- Each user has one enrollment per band.

**Decisions for the USER** (each with a recommended default; the user wants only real conflicts):

- **U1. Accent policy for Spanish typed answers.** Default lenient-with-note: answers differing only in á/é/í/ó/ú/ü count correct with the non-revealing note "Correct. Check your accent marks."; ñ versus n must always match; per-item strict override where accents are the tested point. Alternative: strict (accents required).
- **U2. Instructor PPTX and student-handout PDF.** The PR A extraction determines whether they contain quiz or recap answers. Default if answers are found: make `instructor.pptx` owner-only (removed from the student Roadmap Files tab and excluded from student resource and storage access; `/learn` already excludes it) and regenerate any affected student-handout PDF without answers via the nested tool; if none are found, no change. Alternative: regenerate decks without answers and keep student access.
- **U3. Teacher-graded volume and ambiguous items.** Default: follow the user's rule (Translate/Explain/Name teacher-graded) and make every item without a uniquely determinable answer teacher-graded with the curriculum answer as owner reference. Estimated at least ~40% of ~490 items need owner grading on every attempt, and a lesson cannot complete until those are graded. Alternative: convert closed-answer Name/What items to auto-graded fill-in or multiple-choice where the curriculum supplies a single answer (less owner work; Scribe-authored options reviewed per batch).
- **U4. Pass mark.** Default 80% per quiz (the existing schema default `passing_score` .8). Alternative: another fixed percentage.

**Adopted defaults** (from design; changeable before approval):

- Grandfathered (already completed) lessons keep the quiz as optional practice, tagged Practice and excluded from owner counts.
- No new attempt while one is pending teacher review; a pass closes the quiz.
- Reveal source is the passing or final attempt; teacher comments are visible when the attempt is graded.
- All-or-nothing per item, equal weight, no partial credit.
- Unsubmitted answers live in memory only with the guard Modal (reload, Back, Forward, and tab close lose them; accepted limit).
- Owner grades are final in v1.
- Limits: 200 per blank, 2000 per open-ended answer, 1000 per owner comment.
- `/learn` card order: task link, quiz link, Mark.
- Defined-but-ineligible lessons show static questions without answers.
- Option and right-column order is shuffled server-side, stable per enrollment.
- The owner override is the recovery for exhausted attempts.
- Wipe-save deletes quiz attempts; the attempt cap is per enrollment.
- The owner quiz queue lives in #179's `/admin/submissions` as a type filter.

**Discrepancies reported to the user** (resolved by the plan, no question):

- The quiz mis-parse is in the nested Python generator and is baked into content-source arrays, not in `scripts/generate-lesson-content-json.ts`.
- Legacy keys live in new content-keyed tables rather than `assessment_answer_keys` because of seed order.
- The legacy `submit_quiz_attempt` and Edge 'grade' are retired rather than revised.
- 490 parsed items today versus ~493 estimated.

## 13. Approvals

### Approval record

- **Approved:** 2026-10-04, by the user, together with the #179 plan (`docs/plans/lizbeth-spanish-issue179-lesson-task-form.md`).
- **Decisions approved with their stated defaults:** U1 accent-insensitive with note (lenient-with-note); U2 instructor slides decision confirmed after the PR A extraction report; U3 teacher-graded per the user's rule; U4 pass mark 80%. The adopted defaults in Section 12 are approved as recorded.
- **Covered by this approval:** branches, commits, pushes, and pull requests per item (the user's standing instruction), and merging validated PRs.
- **Not covered (separate explicit go-ahead required after local validation):** every production write, including hosted migrations, key seeding, re-upload of the 78 `lesson-content.json` files, Edge deploys, Netlify deploys, and anything against project `gvobtuhbpqvfhjljjcye`. Each hosted step H1 to H7 needs its own go-ahead naming that project.
- **Retained gates:** (1) Gate Q: user approval of one fully written example quiz and the item-type rules before the PR B content batches begin; (2) owner sample review per band before PR B merges; (3) U2 disposition confirmed after the PR A extraction report, if answers are found.
- **Note on PLAN_DUCK:** the orchestrator runs PLAN_DUCK after this approval, and it may produce a plan revision. This approval stands unless the revision changes scope.

### Gate and decision updates

- **2026-10-05, PR A merged:** PR A (PR #211) merged on 2026-10-05 (merge `f36ef05`). PR B content batches may now begin, subject to the retained gates above.
- **2026-10-05, Gate Q approved by the user:** the beginner-week-05 exemplar quiz and the item-type rules in `lizbeth_spanish/docs/evidence/issue-180/item-type-rules.md`, with the recommended defaults for the open points: yes/no "Does this..." items stay open-ended teacher-graded; "Is X tu/usted/voseo?" items stay multiple choice; Translate stays open-ended; accent policy lenient-with-note by default; the 3-attempt per-item-feedback probing consequence accepted.
- **2026-10-05, U2 confirmed by the user:** default disposition: instructor decks become owner-only (students lose access) and the 3 affected student handout PDFs (beginner weeks 8 and 16, intermediate week 23) are regenerated without answers, implemented in PR D with the PR D re-provisioning (hosted steps user-gated).

## 14. Engineering mode and downstream owner

- **Engineering mode:** standard (single writer, sequential PRs; no extreme advisory team). T1 first line; T2 takes over on two counted gate failures; when T2 identifies unbuilt work already approved by this plan as broader than remediation, the orchestration contract allows one direct T2 full-build continuation. `team_authorization`: not applicable.
- **Downstream owner:** engineering-fleet (Scribe authors PR B content batches and follow-up texts).

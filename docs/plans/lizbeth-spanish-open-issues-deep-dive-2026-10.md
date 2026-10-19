# Plan: Lizbeth Spanish open-issues deep dive (October 2026)

- Plan id: `lizbeth-spanish-open-issues-deep-dive-2026-10`
- Task id: `lizbeth-open-issues-deep-dive-2026-10`
- Status: **APPROVED 2026-10-12 (as recommended), including #208 and #203 (decisions of 2026-10-12, later the same day).** #208 and #203 are approved with the decisions below; D-21, D-22 and D-24 are resolved (see the approval note and section 14). Hosted actions (migration apply, Edge deploy, Netlify deploy) still need their separate approvals per D-28.
- Update 2026-10-13: the user approved merging the Wave 2 PRs (#239 #240 #241 #242 #246 #247) and the Wave 4/5 PRs (#248 #249 #250 #251), and the 5c sub-plan (`docs/plans/lizbeth-spanish-198-legacy-entitlement-rule.md`) is approved. The password-flow plan and the privacy-policy plan were also approved on 2026-10-13. Hosted actions still need separate explicit approval per D-28. See "Standing constraint: production is live" below.
- Update 2026-10-13 (later): the following merged to main (main `37f851e`): #229, #230, #231, #232, #237, #238, #254, #255, #257 and #258.
  - Wave 3 now begins with the #259 PR (per `docs/plans/lizbeth-spanish-post-password-change-landing.md`), then 3a (#235), then 3b (#236), which reuses `src/lib/roleHome.ts`.
  - Migrations on main pending hosted apply, each needing separate approval: 202610110001, 202610120001, 202610120002, 202610120003, 202610130001 and 202610130002. The brief for this note said "seven" but listed six identifiers; the count is unconfirmed.
- Approval note: the user approved on 2026-10-12, verbatim: "Approve as recommended. But leave 208, 203 for us to review and approve separately."
  - Accepted at their recommendations: all decisions D-1 to D-30, except where the decisions below differ.
  - Follow-up decisions, 2026-10-12, verbatim: "For 215 less grading." and "For 208, as suggested, you draft and she approves, as recommended. For 203, Lizbeth signs off, she will do that soon."
  - #208 (D-21) is approved: hybrid scope. Functional strings (buttons, errors, status chips, validation, announcements) get fixed EN/ES translations that are not owner-editable or hideable. Only explanatory and instructional messages become owner-editable in the site-content registry. Engineering and Scribe draft the Spanish and Lizbeth approves it before shipping. This waives the #177 plan's "no machine translation" rule for #208 only. The work stays in Wave 6 as a sub-plan and starts after PRs #229 and #232 merge.
  - #203 (D-24) is approved: Lizbeth is the signer. The Scribe checklist ships early as a small docs PR in the lizbeth repo (alongside Wave 2), and her sign-off is recorded when she completes the check.
  - #215 (D-22) is resolved as "less grading": Wave 7 reduces the advanced band's teacher-graded share (77.2%, 139/180) toward the other bands (about 35-40%), with the exact item set listed in the Wave 7 sub-plan for owner review.
  - Owner input still required before their waves: D-18 (#186 wording), D-25 (Stage B leak gate), and the ES expiry notice under D-7. Approval does not supply that content.
  - A separate privacy-policy workstream was requested; see section 15.4. It is not part of this plan.
  - Hosted rollout remains separately approved per D-28.
- Supersedes: the triage tables in `docs/plans/lizbeth-spanish-issue-batch-2026-10.md` (rev-1) sections 3.6 and 4, for the 31 issues listed in section 2 only. The already-executed closures from that plan (#63, #80, #148, #170, #197) and its Wave 2a/2b PRs (#229 to #232) stand unchanged.
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team.
- Target: `lebobo88/lizbeth-spanish` (private).
- Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_spanish-main-88b` at `origin/main` `88b43fd37f04af90860fc93b5f3c8e4d696a48f9`. Every `file:line` in this plan refers to `88b43fd` unless a PR worktree is named.
- Open-PR worktrees (reference only):
  - `lizbeth_spanish-224` = PR #229 (#224 #225 #226, bilingual sign-in)
  - `lizbeth_spanish-140` = PR #230 (#140 #183)
  - `lizbeth_spanish-228` = PR #231 (#228 create-and-assign, stacked on #230)
  - `lizbeth_spanish-227` = PR #232 (#227 site-copy editor previews, stacked on #229)

**Revision 1 (PLAN_DUCK shadow findings J-001, J-002 applied).** One judge-driven revision, applied in place:

- J-001 (B1 concurrency): the B1 fix now serializes finalization per course with a course-row lock taken first, with newest-version-wins and a stable `newer_version_current` rejection (HTTP 409). Touches sections 5.1, 6.1, 7.2 (D8 mapper), 10, 11.4 (gates 1a and 1c), 12.3, 13 (R2), and adds D-30. The new D8 copy is a wording addition within the reviewed binding categories (permitted variation), so no design re-review is needed.
- J-002 (PR 1b depends on unmerged PR #231): PR 1b now starts only after #231 (and its base #230) merge, and Wave 1 order becomes 1a, 1c, 1b. `src/App.css` is the sole owner of `.form-error`, and `.form-error--ink` is retired in 1b. Touches sections 3.5, 5.2, 5.5, 6.2, 7.2 (D1), 7.3 (invariant 1), 9, 9.1, 9.2, 10, 11.4 (gate 1b), 13 (adds R11), 14 (D-5, D-27), 16. The reviewed design already intended removal of the modifier, so no design re-review is needed.

Reading guide: sections 3, 9, 14 and 17 are what an approver needs. Sections 4 to 6 hold the evidence. Sections 7 to 13 are execution detail for the engineering fleet. Evidence is labelled Observed unless marked Inference or Unknown.

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

---

## 1. Outcome and audience

Audience: the repository owner (Rob), who approves waves and answers decisions, and the downstream engineering fleet, which executes approved waves.

This plan delivers five things:

1. A verdict with evidence for each of the 31 open issues.
2. Full root-cause analyses and RED-test-first fix plans for four newly discovered defects, B1 to B4.
3. A list of issues that can be closed now.
4. A dependency-ordered wave and PR plan with per-wave gates.
5. Numbered decisions, each with a recommendation.

User intent, verbatim: "do a comprehensive deep dive review of all the other issues logged on the repo"; "make sure we do proper root cause diagnosis and planning for proper fixes for the 3 new issues discovered".

B4, verbatim from the user: "sign outs or login timeouts should return the user to the main URL instead of leaving slugs in the browser URL that way when swapping between student or owner accounts we don't login to a page that the role can't access."

Standing direction: accomplish the goal rather than the literal proposal; proper root-cause diagnosis; proper implementation order; close issues that are already finished.

## 2. Scope and non-goals

In scope:

- The 31 open issues: #48 #53 #79 #81 #82 #137 #139 #150 #166 #186 #187 #188 #189 #190 #191 #193 #194 #196 #198 #199 #201 #202 #203 #206 #208 #209 #210 #212 #214 #215 #218.
- New defects B1 to B4 (the user referred to three; the evidence work produced four, see section 5).
- Two minor follow-ups: PR #232's #227 preview omits elements hidden below 900px, and PR #231's body omits `RegisterStudentModal.tsx:592`.

Non-goals:

- Replanning #224 #225 #226 #227 #228 #140 #183. They are in open PRs #229 to #232. Their diffs are accounted for only where they touch in-scope work.
- Any commit or push to main. Work ships as PRs only, base `main`, the user merges, bodies carry "Closes #N".
- Hosted or production deploy, migration apply, Edge deploy, or database write without a separate explicit approval (D-28).
- Closing or filing GitHub issues before this plan is approved.
- Machine-translated or fabricated Spanish.

## 3. Summary of findings

### 3.1 The headline

The expectation that most older issues were already done does not hold. Of the 31 open issues, only #79 is finished, and #139 is a duplicate of #82. The other 29 still have open work: 6 are partially done, 5 wait on an owner decision, and 18 are fully open.

### 3.2 Verdict counts (31)

| Verdict | Count | Issues |
|---|---|---|
| DONE, close | 1 | #79 |
| DUPLICATE | 1 | #139 (of #82) |
| PARTIAL | 6 | #48 #81 #137 #166 #203 #214 |
| NEEDS-OWNER-DECISION | 5 | #186 #187 #188 #196 #215 (#215 since decided: less grading, D-22) |
| OPEN | 18 | #53 #82 #150 #189 #190 #191 #193 #194 #198 #199 #201 #202 #206 #208 #209 #210 #212 #218 |

Note: #194 and #198 appear in the OPEN list above; #198 additionally needs an owner decision on the canonical rule (D-15). The handoff's per-issue verdict for #194 and #198 is OPEN.

### 3.3 Close now (after approval, Wave 0)

- #79: done, with evidence. Every failing spec's `signIn` uses `Open my journal`, matching `LoginForm.tsx:135`; the heading `Sign in` is at `LoginForm.tsx:98`; `issue-3-feedback-inbox.spec.ts:17`. The remaining issue-3 failure is a sign-out race, tracked under #218 (D-1).
- #139: duplicate of #82 (same root cause; #139's body does not reference #82). The fix PR still references both (D-2).

Closed later, once their fix is verified: #166 (after PR #231 merges and two clean runs).

### 3.4 New defects, ranked

| Id | Severity | One line |
|---|---|---|
| B1 | P1, production-impacting | Republishing a course fails: `finalize_publish_job` never clears the prior current version, so `course_versions_one_current` rejects the update. |
| B2 | WCAG AA failure, 17+ sites | `.form-error` text is terracotta-600 on paper-200 at 4.05:1. Two competing global rules. |
| B3 | Likely live in production | Wrong password shows generic copy because the mapping checks `invalid_grant` while GoTrue returns `invalid_credentials`. |
| B4 | User-reported | Sign-out and session expiry leave the deep-link URL, so the next account (other role) can land on a page it cannot access. |

### 3.5 Clusters

- Production defects: B1, B2 (+#189), #53 (the B1 UI surface), B3, B4 (+#150). The B2 PR (1b) waits for PR #231 to merge (R11).
- Test-infrastructure health: #218 umbrella, #201, #166, #48, #137, #81, #82/#139, #79.
- Security and database: #190, #198, #202, adjacent findings in section 15.
- Copy registry: #186, #187, #188, #208, #191.
- Content: #193, #194, #203, #212, #214, #215.
- UI polish: #199, #206, #209, #210.
- Backlog feature: #196.

## 4. Per-issue reconciliation (all 31)

### 4.1 Index table

Columns for sizes and risk carry only values stated in the evidence; "n/s" means the evidence did not state one. "DB/Edge/hosted" lists database, Edge function, or hosted deployment impact. User-visible impact and the long evidence, root cause, fix and acceptance text are in 4.2 so that each cell stays readable.

| Issue | Verdict | Size | Risk | DB / Edge / hosted | Depends on | Wave / PR |
|---|---|---|---|---|---|---|
| #79 | DONE, close | n/a | n/a | none | none | Wave 0 |
| #218 | OPEN (umbrella) | n/s | n/s | none (local test infra) | clusters a to d | Wave 2 (carried by last Wave 2 PR) |
| #201 | OPEN (test timing) | n/s | n/s | none | none | PR 2b |
| #166 | PARTIAL | n/s | n/s | Edge change already in PR #231 (deploy needed for hosted) | PR #231 merge | Closes after #231 (D-14) |
| #48 | PARTIAL | n/s | n/s | local only | none | PR 2c |
| #137 | PARTIAL | n/s | n/s | local only | none | PR 2c |
| #81 | PARTIAL | n/s | n/s | local only | none | PR 2c |
| #82 | OPEN (primary) | n/s | n/s | local only | none | PR 2e |
| #139 | DUPLICATE of #82 | n/a | n/a | n/a | #82 | Wave 0 (close), PR 2e (references) |
| #53 | OPEN (worse than reported) | n/s | n/s | none (client) | PR 1a for meaningful verification | PR 1c |
| #150 | OPEN | n/s | n/s | none | PR #229 merge, bundled with B4 | PR 3b |
| #189 | OPEN | n/s | n/s | none | folded into B2 | PR 1b |
| #190 | OPEN (local); hosted unknown | S | low-medium | migration (privileges only) | none | PR 5a |
| #191 | OPEN | n/s | n/s | none (no registry change, no Edge redeploy) | none | PR 4a |
| #193 | OPEN | M-L (~260 files) | n/s | content provisioning | sub-plan at wave start | Wave 7 |
| #194 | OPEN (small) | n/s | n/s | content | D-23 | Wave 7 |
| #196 | NEEDS-OWNER-DECISION (feature) | M-L | n/s | none stated; uses existing Edge and RPCs | #202 (recommended), D-26 | Wave 8 |
| #198 | OPEN, access-widening security defect, owner decision on rule | n/s | high | two RLS policy rewrites (migration) | #202, D-15 | PR 5c (sub-plan) |
| #199 | OPEN | n/s | n/s | none | none | PR 4a |
| #202 | OPEN | M | medium | migration + client; hosted data unknown | D-17 | PR 5b |
| #203 | PARTIAL | n/s | n/s | none (docs) | Lizbeth sign-off, D-24 (resolved) | Early docs PR (alongside Wave 2); re-check after Wave 7 |
| #206 | OPEN (4 items) + item 5 owner decision | n/s | n/s | none | D-9 for item 5 | PR 4a |
| #208 | OPEN | L | n/s | new registry keys need hosted site-content Edge redeploy | PRs #229 and #232 merge, D-21 (resolved) | Wave 6 (sub-plan) |
| #209 | OPEN (RETURNED) | n/s | n/s | none | none | PR 4a |
| #210 | OPEN (narrowed) | n/s | n/s | none | none | PR 4b |
| #212 | OPEN (nested repo only) | S | n/s | none (tooling patch) | none | Wave 7 (first) |
| #214 | PARTIAL | n/s | n/s | new quiz-definition migration + re-provision | D-25 | Wave 7 |
| #215 | DECIDED: less grading (D-22) | n/s | n/s | new quiz-definition migration + re-provision | D-25 | Wave 7 |
| #186 | NEEDS-OWNER-DECISION (wording) | XS | n/s | none (Netlify rebuild; no Edge redeploy) | D-18 | Wave 6 |
| #187 | NEEDS-OWNER-DECISION (feature) | M | n/s | migration option or site_content key (Edge redeploy) | D-19, most useful after #229 | Wave 6 (sub-plan) |
| #188 | NEEDS-OWNER-DECISION | n/s | n/s | if go: key + Edge redeploy | D-20, after #232 | Wave 6 (only if go) |

### 4.2 Detail per issue

#### #79 E2E sign-in helper targets removed label: DONE, close

- Evidence (Observed): every #218 failing spec's `signIn` uses `Open my journal`, matching `LoginForm.tsx:135`. Heading `Sign in` at `LoginForm.tsx:98`; `issue-3-feedback-inbox.spec.ts:17`.
- Root cause: the label was already fixed. issue-3's remaining failure is a sign-out race (see #218 cluster c), not the label.
- Fix: none. Close now with an evidence comment; issue-3 is tracked under #218.

#### #218 Ten pre-existing failing e2e tests (7 specs): OPEN umbrella

Root causes by cluster (Observed unless marked Inference):

- (a) Fixture gaps on a clean reset.
  - `issue-50-asset-card-grid` (3 tests) hard-codes course `6f435dc7…`, staged v2 `2b6efb05…`, v1 `0ced1deb…` (spec `:16-19`, `:40`). These exist nowhere under `supabase/`. The seed creates courses only via `backfill_legacy_courses()` (`seed.sql :188`, `:518`; migration `202608280003 :568-574`) with random ids and a published-only v1.
  - `issue-55-form-controls-ds-chrome` (2 tests) needs a "draft" course-card pill (`:63`, `:118`) that the seed never creates.
  - `wp4-roster` expects a "preserved" fullaccess enrollment in "Advanced Immersion (Empty Fixture)" (`:394-400`). Its own comment (`:350-357`) says it came from a manual dev run. `seed.sql :253-262` enrolls only student6.
- (b) Stale selector: `gap-1-owner-settings-persistence` reads `.app-header-eyebrow` (`:52`, `:108`) on `/admin/business-settings`. `App.tsx:470` renders app-header only when `!isAdminRoute`; the admin brand is `.admin-masthead-eyebrow` (`AdminShell.tsx:127`). Unknown whether gap-1 restores its `Test-Brand-<ts>` sentinel.
- (c) Test logic.
  - `wp5-feedback-inbox`: a one-shot route abort (`requestCount===0`, `:257-266`) is consumed by a cancelled effect (`OwnerFeedbackPage.tsx:47-55`). Inference, medium. Fix: abort until a flag flips before Retry.
  - `issue-3-feedback-inbox`: `page.goto('/')` immediately after Sign out (`:71`, `:102`) races session teardown. Inference, medium. Fix: await the login email field or URL after sign-out.
- (d) Probable product layout regression: `issue-54-header-nav-reachability` desktop row. #177 added a lang-toggle grid area (`App.css:1283-1284`) with nav `flex-wrap:nowrap` (`:1281`). Sign out may slide under the fixed `.accessibility-button` (`AccessibilitySettings.css:12-17`) at 900px and wider, despite `padding-inline-end` (`App.css:1276`). Inference, medium; needs runtime confirmation. The overlap test (`:223-234`) is sound.
- Also `neo-workbook-visual-smoke` (`:150`, `:169` signs in student1, clicks Open|Review week 1): Inference, low, shared-account or date drift.
- Not inspected: `wp2-owner-chrome` J3, `issue175`, intermittent vitest `issue5-services` PDF, `issue179` SQL, `courseAuthoringUi`. Diagnose at wave start.
- Vitest baseline: `require-backup.test.ts` reads gitignored `docs/cutover-evidence/G7-schema-20260725T230105Z.sql` and `G7-data-20260725T230001Z.sql` at module scope (`:29-33`; `.gitignore:62-65`), so a clean checkout fails the whole file with ENOENT. `:944` pins byte count 58657. Inference: the 4 symlink tests (`:861-918`) may raise EPERM on Windows without Developer Mode.
- Close #218 only after a clean-reset full e2e run shows 0 failures twice.

#### #201 `issue174-handout-links` J8 at 390: OPEN (test timing)

- Evidence: DOM order is correct. `LearnDetailPage.tsx:423-458` renders `MarkCompleteControl`, then (when `isMaterialsEligible && materials.length>0`) `ResourcesPanel`, with nothing focusable between.
- Root cause: the spec focuses Mark complete and Tabs (`:279-280`) without awaiting the async-loaded PDF button.
- Fix: `await expect(pdf).toBeVisible()` before focus.
- Acceptance: `--repeat-each=5` green at 390 and 1440.

#### #166 `status-clarity` Journey 1: PARTIAL

- Done: the fixture retarget. Journey 1 reads seeded student7 (`last_sign_in_at` NULL, `seed.sql:76`) at spec `:146-149`; no spec mutates student7.
- Remaining intermittency, root cause (Observed): `handleGetRoster` calls `serviceClient.auth.admin.listUsers()` unpaginated (`supabase/functions/admin-student-operations/index.ts:631`), while `:680` and `:776` paginate with `perPage 1000`. auth-js sends an empty `per_page` (`lizbeth_spanish-224/node_modules/@supabase/auth-js/src/GoTrueAdminApi.ts:523-536`), so GoTrue's default page (50, per PR #231's test comment) applies. Once `auth.users` exceeds 50 (test pollution, #48) rows drop from the roster.
- Already fixed in open PR #231 (worktree -228 `index.ts :692`, `:740`, `:836` paginated loop; new `issue228-roster-pagination-live.test.ts` creates 57 users). No new issue.
- Close #166 after PR #231 merges and two consecutive clean runs (D-14).
- Production note: any hosted owner with more than 50 auth users has a silently truncated roster until #231 is deployed.

#### #48 Test-suite pollution: PARTIAL

- Done: parallel-load 401s (`vitest.config.ts:32-43`, `fileParallelism:false`); `rlsIntegration` scoped to `SEEDED_TEST_USERS` (`:25-39`).
- Remaining (Observed): `gap-4-admin-students-remediation.spec.ts :199-207` registers `remediation-<Date.now()>@test.local` every run with no delete. `e2e/course-fixtures.ts :73-95` archives rather than deletes courses.
- Candidate student1 double-enrollment source (Inference, medium): `issue176-completion-foundations.spec.ts :215-228` assigns with `resume_previous_save:true` (insert versus reactivate unverified).
- Fix: per-spec cleanup, plus a loopback-guarded Playwright `globalTeardown` sweep of disposable domains, plus a count check.

#### #137 Re-issue validation mutates student2: PARTIAL

- Done: `browser-validation-status-clarity-and-gate.spec.ts :18-91` restores student1 (password and sign-in probe) and student2 (`force_password_change`) in `afterAll` with a loopback guard (`:39`).
- Gaps: restore is skipped if the run is killed; dependent specs have no precondition guard; ad hoc Browser Validator rotation journeys are unguarded.
- Fix: `beforeAll` precondition reassert via the loopback admin API; credential-rotating journeys use disposable accounts only.

#### #81 `issue5EdgeSmoke` leaks draft: PARTIAL

- Evidence: `create_version` and `save_outline` (`:31-38`) and assertions (`:39-52`) run before `try` (`:56`), so a failure skips the `finally` cleanup (`:68-81`). Cleanup deletes `course_versions` only (`:72`, `:79`). `course_version_lessons` cascades (migration `:76`), but `lesson_revisions` (`:55-65`) has no FK to the version, so an `HTTP draft edit` revision is orphaned.
- Knock-on: a leaked draft makes the next `create_version` raise `draft version already exists` (migration `:330`), which explains the intermittent `issue5EdgeSmoke` failures.
- Fix: move the clone into `try/finally`; delete the clone's `lesson_revisions`.
- RED: an injected failure at `:42` leaves no draft and the next run passes.

#### #82 Seed `now()`-relative dates drift: OPEN (primary)

- Evidence: 48 lines in `supabase/seed.sql` contain `now()` (about 30 interval offsets: enrollments `:183-246`, progress `:370-478`, `last_sign_in` `:484-487`). There is no fixture-date helper, and `playwright.config.ts` has no `globalSetup`. Week unlock and status boundaries move with elapsed time since reset. (rev-1 said 33 occurrences; corrected.)
- Fix: D-13, fixture-date re-anchor helper.

#### #139 Seeded relative dates drift: DUPLICATE of #82

- Same root cause. Close as a duplicate (D-2); the fix PR references both.

#### #53 Finalize publish not self-disabling: OPEN (worse than reported)

- Evidence: Publishing (`CourseWorkspacePage.tsx:1123-1148`) renders "Finalize publish" whenever `job && job.status !== 'failed'`, so it stays after a polled `succeeded`. `onClick` awaits `finalizePublish(job.id)` then only calls `setMessage('Version published.')`. There is no `setJob` and no in-flight guard (double-click sends two RPCs), and Stage stays enabled. Errors render raw via `e.message` in `<p role="status">`; this is where B1's raw Postgres text appears. `finalizePublish` returns `action<unknown>` (`src/services/courseAuthoring.ts:86`).
- Root cause: no explicit finalizing, published, or failed state.
- Fix: state machine per design D8 (section 7).
- Existing tests: `publishJobHydration.test.tsx`, `publishJobHydration.live.test.ts`, `e2e/wp8-course-workspace.spec.ts`. None asserts post-finalize button state.

#### #150 `isRoadmapRoute` divergence: OPEN

- Evidence: `App.tsx:136` is `!weekDetail && !isLearnRoute && !inLearnDetailArea && !isFeedbackRoute && !isAdminRoute` (catch-all). `ContextStatusStrip.tsx:99` is `!weekDetail && path === '/roadmap'`. They diverge at `/`, unknown paths, and `/roadmap/`. e2e `issue-132-authenticated-axe-audit.spec.ts:156-167` pins "no strip at `/`". Owner `/` is already replaced to `/admin/dashboard` (`App.tsx:90-92`).
- Fix (design D7): canonicalize student `/`, `/roadmap/`, and unknown fall-through with `replaceNavigate('/roadmap')`; invert the issue-132 assertion deliberately. Bundled with B4 because both touch the route effects in `App.tsx`.

#### #189 Admin masthead eyebrow 4.06:1: OPEN

- Evidence: `AdminShell.css:179-187` `.admin-masthead-eyebrow` uses brass-500 `#a07e48`, 0.625rem (9px mobile, `:345-346`), on `.admin-masthead` ink-900 `#2a2420` (`:125-129`), giving 4.06:1 (`statusColorContrast.test.ts:103` pins 4.063). `primitives.json:28` marks brass.500 decorative-only. Precedent: `App.tsx:750-752` moved brass-500 to brass-300 (6.80:1). Not touched by PR #232 or #230 (same rule at `:186` in both).
- Fix: brass-300. Folded into the B2 contrast PR.

#### #190 Default TRUNCATE/REFERENCES/TRIGGER grants: OPEN (local); hosted unknown

- Evidence: no migration revokes these privileges or alters default privileges.
- Tables already covered by `revoke all … from anon, authenticated`:
  - courses, course_versions, lesson_revisions, assessment_answer_keys, course_version_lessons, course_assets, cohorts, cohort_memberships, enrollment_requests, quiz_attempts, activity_events, publish_jobs, enrollment_lesson_entitlements (`202608280003:531`)
  - student_lesson_progress, owner_dashboard_settings (`202608270001:42-44`)
  - site_content, public_site_content (`202610040001:40-59`)
  - lesson_task_* (`202610040003:98-101`)
  - lesson_quiz_* (`202610050001:92-93`)
  - completion_gate_settings (`202610040006:22`)
- Not covered: bands, lessons, student_enrollments, resources, owner_settings (`202607170001`), reconciliation_preview_tokens (`202608290001:145`). feedback_submissions has only `revoke update, delete … from authenticated` (`202608280001:56`).
- Inference (Postgres behavior): RLS does not govern TRUNCATE; REFERENCES and TRIGGER allow FK and trigger creation; exploitation needs raw SQL, not PostgREST. Defense in depth, low to medium.
- Fix: a `do $$` loop revoking only `truncate, references, trigger` (NOT `revoke all`) on public tables from `anon, authenticated`, plus `alter default privileges for role postgres in schema public revoke truncate, references, trigger on tables from anon, authenticated`. Whether supabase_admin-owned defaults are alterable is Unknown. The rollback re-grants only to tables that had them, from a pre-apply catalog snapshot. Precedent: #222 (`202610070001/2`, `authenticatedFunctionExecuteGrants.test.ts` using a pg Client).
- RED: the pg-catalog query in section 11.3 returns 0 rows; a guard test shows existing SELECT grants unchanged.

#### #191 BandRoadmap legend hard-coded: OPEN

- Evidence: `BandRoadmap.tsx:246` holds `SOLID = COMPLETE · HATCHED = IN HAND` (the issue's `:229` drifted). The identical text is registry key `roadmap.ledger_footnote` (`siteContentRegistry.ts:306-314`), rendered page-level at `RoadmapPage.tsx:150`. BandRoadmap renders per band at `RoadmapPage.tsx:206`, so the duplicate is confirmed in one view.
- Root cause: #177 wired one of two duplicate instances.
- Fix (design D9): the page-level SiteText legend is authoritative; remove the per-band hard-coded legend (owner decision D-11). No registry change, no Edge redeploy.

#### #193 Align sibling lesson files with self-paced practice: OPEN

- Evidence: 78 of 78 `curriculum/lessons/*/phrases-and-qa.md` contain "Audience: the instructor delivering this lesson". Broad-regex hits (over-matching possible): vocabulary-list 77 files, weekly-review-recap 14, flashcards 17, README 78. beginner-week-26 classroom phrases remain (vocabulary-list 3, practice-activity 2, flashcards 6); intermediate-week-16 Machu Picchu is fixed. There are 0 hits in `content-source/` and `supabase/storage-seed/` for phrases-and-qa framing (not student-visible), but `weekly-review-recap.md` is provisioned (78 files) and shown in in-app vocabulary review, so recap wording IS student-visible. The handout PDF/DOCX regeneration script is unidentified (only `verify:handout-coverage`, `scripts/verify-handout-coverage.mjs`; `scripts/provision-lessons.ts`).
- Root cause: #178 reframed practice files but sibling files kept the classroom template.
- Size M-L (about 260 files). Sub-plan at wave start.

#### #194 Legal/financial disclaimer consistency: OPEN (small)

- Evidence: advanced `practice-activity.md` variants. "is not legal advice." in weeks 01-06; "is not financial advice." weeks 07-11; "is not legal or financial advice." weeks 12-13; invented-entities wording weeks 14, 15, 17; week 20 "not a verified primary text"; week 26 ceremony composed. Weeks 16, 18, 19, 21-25 are unverified.
- Fix after the owner picks a canonical template (D-23).

#### #196 Per-lesson authored handouts (non-legacy): NEEDS-OWNER-DECISION (feature)

- Exists: pdf-lib plus Unicode font (`src/services/exports.ts:2-28`); Edge `register_asset` checks `lesson_revision_id` is mapped (`course-authoring/index.ts:440`); student RPCs `get_student_lesson_assets` and `resolve_student_course_asset` filter `lesson_revision_id` not null and `integrity_status` verified (`202610040002:27-97`); owner bucket policies (`202608300003`).
- Missing: a per-lesson generate action, upload, register and verify UI, and copy.
- Dependency: `save_outline` creates new revision ids on every save (the #202 mechanism), so draft-registered handouts orphan. Recommend published-version-only generation, or wait for #202.
- Size M-L; own sub-plan and design route.

#### #198 Legacy date rule versus entitlement rule: OPEN, access-widening security defect, owner decision on the canonical rule

- Legacy rule: policies `students_read_unlocked_resources` (`public.resources`) and `students_read_unlocked_lesson_assets` (`storage.objects`) in `202610050005:20-66`. They unlock when `now() >= se.enrollment_date + lessons.unlock_offset_days` or when completed, joining `se.band_id = l.band_id`. They never read `cohort_id`, `cohorts.starts_at`, `course_version_lessons` offsets, or `manual_release_state`.
- Entitlement rule: anchor `coalesce(cohorts.starts_at, se.enrollment_date)` (`202608300001:34-40`); `unlock_at = anchor + course_version_lessons.unlock_offset_days` (`:56-63`); student policies require `manual_release_state not in ('held','revoked')` (`202608280003:521-527`).
- Cohort-anchored legacy enrollments exist (`enroll_cohort_member` inserts `band_id` with `cohort_id`, `202608300005:129-130`).
- Divergence:
  - Enrolled before cohort start: earlier unlock (widening).
  - Late joiner: later unlock (narrowing).
  - Held or revoked entitlements remain readable via PostgREST and storage (widening; applies to rolling enrollments too).
  - Cadence changes (`202608300001:493-499`) diverge offsets.
- PR #231 uses `assign_band_enrollment` (rolling, no cohort; -228 `index.ts:537`; `202610030001:574`), so no new cohort cases, but the held/revoked exposure applies.
- Recommendation: the entitlement rule is canonical. Rewrite both legacy policies to require an `enrollment_lesson_entitlements` row via `lesson_revisions.legacy_lesson_id` with `unlock_at <= now()` and not held or revoked. Depends on #202 (link loss would hide resources). High risk; detailed sub-plan at wave start; preview impact on live cohorts before hosted apply.

#### #199 Roadmap rail FLASHCARDS overflow: OPEN

- Evidence: `ResourcesPanel.css:137-145` stacks columns only for `.resources-panel--embedded`. The rail (default variant, `WeekDetailPage.tsx:1187`, `:1220`) keeps the space-between row (`:53-59`). `.resources-panel-row-type` has `min-width:0` (`:83`) without nowrap or flex-shrink, which lets the single word paint past the edge. `resourcesPanelRailOverflowFix.test.tsx:60` pins the min-width rule. Rail content is about 387px at 1440 (Inference: 34% of an 81rem page minus padding and border).
- Fix (design D6): stack at all widths, label `overflow-wrap: anywhere`; update the `:60` test deliberately.

#### #202 `save_outline` drops `legacy_lesson_id`: OPEN

- Evidence: `save_outline` was last defined at `202608300001:429` (earlier `202608280003:295`). Lines `:436-447` delete `course_version_lessons`, then insert `lesson_revisions(revision_no,title,description,content,created_by)` with `values(1,…)` and no `legacy_lesson_id`. The client `saveDraft` (`src/services/courseAuthoring.ts:118`) sends neither `legacy_lesson_id` nor a block id. `getCourse` (`:115`) spreads the revision, so blocks carry `id` and `legacy_lesson_id`; duplicate block sets null (`src/lib/courseAuthoring.ts:92`). The Edge function passes lessons unchanged (`index.ts:500-503`). `get_owner_resource_text` (`index.ts:165-167`) returns 404 on a null link.
- Constraint `unique(legacy_lesson_id, revision_no)` (`202608280003:64`), so reuse needs `revision_no = max+1`.
- Second-save trap: the client does not adopt the returned `lesson_revision_ids`.
- Root cause: whole-outline rebuild with no identity carried forward.
- Options:
  - (c) RECOMMENDED: the client round-trips `lesson_revision_id`; `save_outline` reuses `legacy_lesson_id` only from a revision currently mapped in this draft's `course_version_lessons`, otherwise NULL; `revision_no = coalesce(max,0)+1`; the client replaces block ids from the response.
  - (a) Client sends `legacy_lesson_id`: unsafe (cross-course resource attachment).
  - (b) Position match: integrity risk.
- RED tests: same-lessons save keeps the link; reorder follows the lesson; forged or foreign id gives NULL; two saves without reload; `get_owner_resource_text` after save and reload; no 23505.
- Medium risk, size M. Hosted Unknown: published versions may already hold null links (read-only query).

#### #203 Vocab spot-check checklist and golden procedure: PARTIAL

- Evidence: the golden procedure (`UPDATE_VOCAB_GOLDEN=1 npx vitest run src/__tests__/vocabReviewLang.test.ts`) exists only in tests and the July G9a cutover evidence. There is no owner checklist document. The owner spot-check of at least 5 recaps is outstanding per orchestrator evidence `lizbeth-spanish-prod-stageC-20261006.md` item 1 and `stageD-20261007.md:57` ("not possible without logins").
- Decision (D-24, 2026-10-12): Lizbeth is the signer and will check soon, so the checklist ships early as a small docs PR in the lizbeth repo (alongside Wave 2, ahead of Wave 7).
- Fix: Scribe writes the checklist and golden document. Lizbeth checks at least 5 recaps (beginner week-01, intermediate week-02, advanced week-05, plus 2 of her choice). The checklist covers Spanish phrases marked `lang=es`, English notes not marked, correct reading, and no answer text. She records the date and the recaps checked.
- Golden procedure: `UPDATE_VOCAB_GOLDEN=1 npx vitest run src/__tests__/vocabReviewLang.test.ts`, then a Spanish-literate review of the diff before commit. Recaps changed in Wave 7 must be re-checked under this procedure.

#### #206 Owner submission review polish: OPEN (4 items) plus item 5 owner decision

- Item 1: "Jump to review" is a plain anchor (`OwnerSubmissionDetailPage.tsx:214`) to a section without `tabIndex` (`ReviewForm.tsx:129`).
- Item 2 (root cause differs from rev-1): `App.tsx` `findHeading` (`:310-316`) skips any h1 inside `<header>`. The page h1 (`:226`) sits in `<header className="owner-submission-header">` (also `OwnerQuizAttemptDetailPage.tsx:249`). `headingRef` (`:136`) is unused.
- Item 3: `.lesson-task-status-chip` `flex-wrap:wrap` (`LessonTask.css:21`) orphans the glyph at 390. The chip is shared with the student task bar.
- Item 4: `.owner-submission-list` padding `var(--space-4)` (`SubmissionLedgerRow.css:11`) insets the cards (Inference, medium).
- Item 5: `ReviewForm.tsx:90-92`, `:114-115` have no focus move (reverses an earlier handoff, D-9).
- Existing tests: `issue179b-owner-submissions-pages.test.tsx`, `issue179b-owner-surfaces.test.tsx`, `e2e/issue179b-owner-review.spec.ts`.
- Fix: design D4.

#### #208 `lesson_task.*` copy keys: OPEN (L)

- Evidence: `src/lib/lessonTaskCopy.ts` defines 88 keys; 73 `lessonTaskText` call sites across 13 files, including non-React logic (`lessonTaskLogic.ts` 10, `lessonQuizLogic.ts` 1). Interpolation uses `{n}` `{max}` `{time}` `{a}-{d}` `{char}` `{course}`. The registry has no placeholder metadata. The site-content Edge function rejects unknown keys via `siteContentAuthorization.ts:101-104`, importing the Deno registry (`:14`), so new keys need a hosted Edge redeploy. The registry test pins the key set to `fixtures/siteTextBaseline.ts`. Spanish defaults need PR #229 (`default.es`).
- Root cause: the copy layer is a static map in a plain function.
- Decision (D-21, 2026-10-12): hybrid scope. Functional strings (buttons, errors, status chips, validation, announcements) get fixed EN/ES translations that are not owner-editable or hideable. Only explanatory and instructional messages become owner-editable registry keys. Engineering and Scribe draft the Spanish; Lizbeth approves it before shipping. This explicitly waives the #177 plan's "no machine translation" rule for #208 only.
- Note: the override seam (`useLessonTaskCopy`) is not wired, and `src/lib/lessonTaskCopy.ts` holds 88 `lesson_task.*` keys.
- Sub-plan after PRs #229 and #232 merge (Wave 6).

#### #209 "Draft saved" under RETURNED/REVIEWED: OPEN (RETURNED)

- Evidence: the visible line is already gated `task.savedAt && !task.readOnly` (`LessonTaskBar.tsx:157`), and `readOnly` is true for submitted and reviewed (`lessonTaskLogic.ts:85-88`). But `useLessonTask.tsx:166-167` sets `saveState` to `saved` and `savedAt = submission.updated_at` for any status, so RETURNED shows the owner's return time. `live` (`LessonTaskBar.tsx:150`) is not gated on `readOnly`, so REVIEWED may still announce.
- Root cause: load-time initialisation.
- Fix: design D5 matrix.

#### #210 Flush draft on Back/Forward/unmount: OPEN (narrowed; the issue's beacon proposal is rejected)

- Evidence: `useLessonTask.tsx:437-461` already flushes on pagehide, visibilitychange hidden, and unmount; `performSave` is stable (`:264`); in-app Back/Forward unmounts via `useRoute` popstate.
- Loss windows:
  - The keepalive fetch waits on async `getSupabaseClient().auth.getSession()` (`lessonTaskData.ts:134-154`), so on pagehide the document may be discarded first (Inference, medium; main window).
  - The keepalive response is ignored (rate limit or conflict drop).
  - An in-flight save leaves a stale revision.
  - Visibility hidden while mounted bumps the server revision without updating the local revision, causing a later conflict UI.
- `navigator.sendBeacon` cannot set Authorization or apikey, so it is not viable. `LessonTaskLeaveGuard.tsx:20-23` correctly avoids `beforeunload`.
- Fix: a synchronously readable token cache via `onAuthStateChange`; on hidden use `performSave`; send keepalive after an in-flight save; update the stale header comment `:36-38`.
- RED: vitest with deferred `getSession` plus pagehide expecting a synchronous fetch; vitest visibility hidden/visible with no conflict; Playwright delayed save plus `goBack` persists; Playwright `page.close` within 2s persists (Chromium and WebKit).

#### #212 Nested `parse_quiz` variants: OPEN (nested repo only)

- Evidence: `H:\CommandCenter\orchestrator\lizbeth_spanish\tools\lesson-generation\generate_lesson_ts.py:392` regex matches only `**Answer:**`. The curriculum has 35 `**Answer (label):**` or `**Model answer:**` markers in 12 phrases-and-qa files (44 in 20 overall). In-repo `scripts/lib/parseQuizSection.ts:6-10` already handles both.
- Root cause: the fix was never back-ported to the gitignored Python tool.
- Fix: port, and export via `scripts/export-tooling-patches.ts` (`docs/tooling-patches/lesson-generation/`). Size S.

#### #214 Curriculum source defects: PARTIAL

- Item 1 PRESENT and student-visible (Inference, medium-high; Stage B hosted = seed 156/156): leaked `(hay -> use "se necesita" as a substitute prompt)` at `curriculum/lessons/intermediate-week-17/phrases-and-qa.md:179-180`, `content-source/quizzes/intermediate-week-17.quiz.json:9`, `content-source/intermediateWeek17.ts`, storage-seed `intermediate/week-17/lesson-content.json`, and migration `202610050002_issue180_seed_lesson_quiz_definitions.sql`.
- Item 2 likely fixed ("la tuya" absent from intermediate-week-20).
- Item 3 unknown.
- Item 4 PRESENT: `advanced-week-04/phrases-and-qa.md:183-184` says pluperfect subjunctive but the answer is conditional perfect.
- Item 5 unknown.
- Item 6 PRESENT: "Replace the underlined noun" at `intermediate-week-09.quiz.json:33`, `intermediate-week-13.quiz.json:27`.
- Item 7 partial: `advanced-week-08/phrases-and-qa.md:176` still quotes a file name; others unverified.
- Fix needs source, quiz JSON, content-source, regeneration, a new quiz-definition migration, and re-provision, gated by the Stage B leak-gate owner decision (627 fingerprint hits, D-25).

#### #215 Teacher-graded share: DECIDED (less grading)

- Evidence: 139 of 180 advanced items are `open_ended`, 77.2% (`content-source/quizzes/advanced-*.quiz.json`). `check:quiz-complete` (`scripts/check-quiz-complete.mjs`) does not compute the share.
- Decision (D-22, 2026-10-12): "less grading". Wave 7 converts the advanced band's yes/no "Does/Is" meta items to `true_false` and drops or converts course-structure meta items, through a new quiz-definition migration plus re-provision (gated by D-25). The target brings advanced near the other bands (about 35-40%). The exact item set is listed in the Wave 7 sub-plan for owner review.
- Add a per-band teacher-graded share assertion to `check:quiz-complete`.

#### #186 Meta description "Phase 0 Scaffold": NEEDS-OWNER-DECISION (wording)

- Evidence: the literal is at `index.html:7`, `siteContentRegistry.ts:52` (`DEFAULT_META_DESCRIPTION`), and fixtures. `meta.description` is already owner-editable (registry `:260-268`) and applied at runtime (`PublicContentContext.tsx:77-86`, `:124-130`). Crawlers without JS and the blank or disabled fallback still show it. Registry test `:49-52` pins equality.
- Fix after wording (D-18): update `index.html`, the constant, and fixtures (no new key, no Edge redeploy; Netlify rebuild). Size XS.

#### #187 Owner default language: NEEDS-OWNER-DECISION (feature)

- Evidence: `readStoredLanguage` reads localStorage else `'en'` (`PublicContentContext.tsx:33-50`); admin is forced to `'en'` (`:58-92`); no default-language setting exists anywhere; `owner_settings` is readable only by authenticated users; first-time visitors are anonymous.
- Options: (a) `owner_settings` column plus an anon view (migration); (b) a `site_content` setting key (no migration, overloads semantics, Edge redeploy). First-paint flash risk.
- Independent of #229 but most useful after it. Size M; sub-plan (D-19).

#### #188 Decorative L mark editable: NEEDS-OWNER-DECISION

- Evidence: four `aria-hidden` instances: `App.tsx:667-675` (SVG text), `PublicCatalogPage.tsx:123`, `BrandLogo.tsx:30-31` (only without an uploaded logo), `BrandDesignPage.tsx:97` (locked by issue43). SVG text does not auto-fit (#177 D6 deferral).
- Recommendation: defer or no (cosmetic; an uploaded logo already replaces it, D-20). If go: design route, key, Edge redeploy, after #232.

## 5. New defects B1 to B4

### 5.1 B1 Republish failure (P1, production-impacting)

Confirmed by a prior planner and extended here.

**Mechanism (Observed).** `finalize_publish_job` (`supabase/migrations/202608280003_issue5_course_authoring.sql:267-280`) sets `is_current=true` (`:277`) without clearing the prior current version. The unique partial index `course_versions_one_current ON (course_id) WHERE is_current` (`:53`) rejects the update. No later migration redefines the function (only grant lists in `202610070001:29` and `202610070002:30`, and rollbacks).

`is_current` writers: the column default false (`:19`), `:277`, and the backfill insert (`:572`). Readers: SQL `resolve_band_course_version` (`202610030001:47-63`), which prefers published plus `is_current` and falls back to the lowest legacy-mapped published version; `scripts/audit/issue176-completion-audit.sql:35,67,104,136,185`; no runtime reader in `src` or `functions`. Release evidence `lizbeth-spanish-release-20260915.md:72-74` records provisioned v1 rows with `is_current=0`, with readers using status and `version_no`.

**Impact (Inference, high).** Backfilled courses can publish v2 once (v1 is not current) and fail on v3. Courses whose v1 was finalized fail on v2. Legacy `course_id` NULL rows never collide.

**Security observation.** `finalize_publish_job` is `SECURITY DEFINER` with `search_path=public` and has NO owner check (compare `stage_publish_job :435`, `retry_publish_job :424`). EXECUTE is granted only to `service_role` (`:538`; anon and authenticated revoked by `202610070001/2`). Ownership is enforced by Edge `ownershipFailure` to `ownedJob` to `ownedVersion` to `courses.owner_id` (`course-authoring/index.ts:111-127`).

**User-visible failure.** Edge `finalize_publish` (`index.ts:516-518`) returns raw `e.message` as a 422, which becomes `CourseAuthoringError` (`src/services/courseAuthoring.ts:30-32`), then Publishing `setMessage(e.message)` in `role=status` (`CourseWorkspacePage.tsx:1148`). The owner sees `duplicate key value violates unique constraint "course_versions_one_current"`. The failure is atomic (single plpgsql call): the version stays `staged` (`stage_publish_job :441`) and the job stays `queued`. On mount the panel rehydrates the job as resumable (`:1137-1147`), so Finalize keeps failing. "Retry publish" appears only when status is `failed` (`:1148`), and no SQL path ever sets `failed`.

**Data repair.** None needed (atomic). Leftovers only: versions stuck `staged` with unfinalized jobs (finalize should succeed after the fix; verify) and courses with published versions but no current (expected for backfilled v1; harmless via the fallback).

**Why tests missed it.** `issue5BackendIntegration.test.ts:112-124` builds versions with `band_id` only (`course_id` NULL, so the index ignores them) and asserts the prior version stays `published` (so the fix must NOT archive the old version). `issue176-completion-foundations-sql.test.ts:584` hand-clears `is_current` (pg Client `127.0.0.1:54322`, BEGIN/ROLLBACK, loads migration files by path `:18-25`).

**Fix.** A new forward migration (naming `YYYYMMDDNNNN_<issue>_<slug>.sql` after `202610070002`; for example `2026101X0001_issue<B1>_republish_current_version.sql`) with `create or replace function finalize_publish_job` revised as follows (Revision 1, J-001). A plain "clear the prior current" statement is atomic but not safe for two concurrent finalizations of different versions of the same course: the function locks only the job and the target version (`202608280003_issue5_course_authoring.sql:271-278`), so with no current version both transactions clear zero rows and the second fails on `course_versions_one_current` (`:53`).

When `v.course_id` is not null, serialize finalization per course:

1. Take a parent row lock first, before any `is_current` read or write: `perform 1 from public.courses where id = v.course_id for update;` (transaction-scoped). `pg_advisory_xact_lock(hashtextextended(v.course_id::text,0))` is acceptable only if the course-row lock proves impractical; record the choice in the PR. Because the target version and job are currently locked first at `:271-278`, the migration must reorder so the course lock is the first lock taken in the function, keeping a consistent lock order.
2. After the lock (the function is VOLATILE plpgsql under READ COMMITTED, so each later statement sees the winner's committed rows): if another version of the same course is already published with a higher `version_no` than `v.version_no`, raise a defined error, `raise exception using errcode = 'P0001', message = 'newer_version_current'`, and leave the target version `staged` and the job unchanged.
3. Otherwise clear the prior current, then set the target current:

```sql
update course_versions set is_current=false, updated_at=now()
where course_id = v.course_id and is_current and id <> v.id
```

The outcome is deterministic: never a raw unique violation; the newest `version_no` is always the current one; a finalization that is equal to or older than the current version is rejected with `newer_version_current`. Legacy rows with `course_id` null keep the existing path (the index skips null). All statements run in the same transaction. Preserve `SECURITY DEFINER`, `search_path`, and the #222 grant/revoke state (service_role only). Add a rollback file `supabase/rollbacks/issue<B1>_republish_current_version_rollback.sql` restoring the `:267-280` body. Remove the `:584` workaround in a follow-up assertion. Losing-finalization contract: Edge `finalize_publish` (`course-authoring/index.ts:516-518`) maps the message `newer_version_current` to HTTP 409 with body `{error: 'newer_version_current'}` (a stable code, not raw text). Any other DB error is returned as a generic code with no raw Postgres text. UI copy is handled by the #53 PR (design D8 mapper).

**RED tests (pg).**

- Create a course with a `course_id`-bearing v1 that is finalized (current); stage and finalize v2 succeeds.
- v1 stays `published` with `is_current=false`; v2 is current.
- A third publish also succeeds; exactly one current version per course.
- Rollback-file parity.
- Existing `issue5BackendIntegration:112` still passes.
- Finalize of a pre-existing stuck queued job succeeds after the migration.
- (i) Two-connection concurrent finalize, no-current case: two pg Clients, BEGIN each, call finalize for v2 and v3 of the same `course_id`-bearing course, commit in both orders. Assert no 23505, exactly one current per course, current = highest `version_no`, and the lower version either published and not current (if it committed first) or rejected with `newer_version_current` (if it committed second) with its job state unchanged.
- (ii) The same test with an existing current v1.
- (iii) Edge-level test that `newer_version_current` returns 409 with the stable code and no raw message.
- The concurrent test runs 10 iterations without flake.

**Read-only production queries (the user runs these; select-only).**

1. Duplicate currents:

```sql
select course_id, count(*) from public.course_versions where is_current group by course_id having count(*)>1;
```

2. Courses with published versions but no current:

```sql
select c.id, c.slug, count(*) filter (where cv.status='published') published_n, max(cv.version_no) filter (where cv.status='published') max_published from public.courses c join public.course_versions cv on cv.course_id=c.id group by c.id, c.slug having count(*) filter (where cv.is_current)=0 and count(*) filter (where cv.status='published')>0;
```

3. Courses with more than one published version:

```sql
select cv.course_id, array_agg(cv.version_no order by cv.version_no) filter (where cv.status='published') published, array_agg(cv.version_no) filter (where cv.is_current) current from public.course_versions cv where cv.course_id is not null group by cv.course_id having count(*) filter (where cv.status='published')>1;
```

4. Stuck jobs and staged versions:

```sql
select pj.id, pj.status, pj.created_at, pj.retry_count, pj.error_message, cv.course_id, cv.version_no, cv.status version_status from public.publish_jobs pj join public.course_versions cv on cv.id=pj.course_version_id where pj.status in ('queued','running') order by pj.created_at;
select id, course_id, version_no, updated_at from public.course_versions where status='staged';
```

Hosted migration apply needs separate approval (D-28). Adjacent, not in scope: an owner check inside `finalize_publish_job` (D-4); `publish_jobs` never set `failed`.

### 5.2 B2 Error-text contrast (WCAG AA failure, 17+ sites)

**Mechanism (Observed).** Two global `.form-error` rules compete:

- `ForcedPasswordChangeGate.css:93-100`: background `surface-chrome-default` (paper-200 `#f0ebe2` per `App.css:47`); color `--color-status-error-text` (terracotta-600 `#a85e4a` per `field-workbook.generated.css:85`).
- `RegisterStudentModal.css:30-36`: same background, ink-800, 3px border-left.

Every `.form-error` gets paper-200 from the rule itself. The color depends on load order; PR #231's comment (`lizbeth_spanish-228 RegisterStudentModal.css:38-43`) says ForcedPasswordChangeGate loads last (unverified). terracotta-600 on paper-200 is 4.05:1 and FAILS AA text (`statusColorContrast.test.ts:88-91`); on paper-50 it is 4.69 and on paper-100 4.54.

**Sites.** `AdminStudentModals.tsx:57,197,203,264,373,484,490,558,712,811,891`; `AdminStudentsPage.tsx:695,874,922`; `ForcedPasswordChangeGate.tsx:278,284,290`; `RegisterStudentModal.tsx:242,340`.

**PR #231 overlap.** #231 adds `.form-error.form-error--ink { color: var(--color-ink-900) }` (228 `RegisterStudentModal.css:44-46`), used only at its new sites (`AdminStudentsPage.tsx:359`; `AssignCoursesModal.tsx:191,223,251`; `RegisterStudentModal.tsx:399,427,494`; `OnboardingOutcome.tsx:85`). Pre-existing sites, including `RegisterStudentModal.tsx:592` (228 tree), are unchanged. The #231 body omits `:592`; 1b fixes that site after #231 merges, so a body note is optional (D-27).

**Token pipeline.** `field-workbook.generated.css` is generated from `.atelier/tokens/field-workbook.tokens.json` (`scripts/verify-token-pipeline.mjs`; `tokenPipelineOracle.test.ts:166` pins `status-error-text` = terracotta-600); `src/tokens/semantic.json:28`.

**Root cause.** Duplicated global class definitions with a cascade-order-dependent color, plus a token that is only AA-safe on paper-50 and paper-100 used on paper-200.

**Fix (design D1).** A single `.form-error` in `src/App.css`, color ink-900 (about 12.9:1), terracotta hairline plus 3px left bar (4.05:1 non-text, which meets the 3:1 requirement), forced-colors `CanvasText`. Delete both old rules. The token is unchanged. PR #231's `.form-error--ink` modifier is retired in the same PR (Revision 1, J-002): 1b removes the modifier rule and the class from all #231 sites. Because 1b deletes the rule in `RegisterStudentModal.css` that #231 also edits (`:44-46`), the two conflict textually and semantically, so 1b runs only after #231 and its base #230 merge, branching from the post-merge main head and never stacked on #231. The change covers `RegisterStudentModal.tsx:592`. Tests per design (pinned ratios; exactly one rule; rule color ink-900). Fold in #189 (brass-300).

**Follow-up audit (out of scope).** About 20 other `--color-status-error-text` consumers (`WeekDetailPage.css:934`, `OwnerDashboardPage.css:167`, `OwnerSettingsPage.css:212`, `LessonTaskForm.css:89`, `ReviewForm.css:57`, `Field.css:71`, and others) against their actual backgrounds.

### 5.3 B3 Wrong-password message generic (likely live in production)

**Mechanism.** On `88b`, `AuthContext.tsx:34-57` `getSignInErrorMessage` maps `email_not_confirmed` to a specific message, `'invalid_grant'` to "That email or password isn't right.", and everything else to generic copy. PR #229 (224 `AuthContext.tsx:41-56`) `getSignInErrorKind` has the same gap (`invalid_grant` maps to the `'invalid_credentials'` kind).

auth-js 2.110.7 (`package-lock.json:1345-1346`; supabase-js `^2.110.7`, `package.json:37`): `fetch.ts:96-109` takes `data.code` (API 2024-01-01 and later) else `data.error_code`; `:141` builds `AuthApiError(msg,status,errorCode)`; `error-codes.ts:88` includes `'invalid_credentials'`; no `'invalid_grant'` code appears anywhere in auth-js; `errors.ts:61` shows the example `AuthApiError('Invalid credentials', 400, 'invalid_credentials')`. So a wrong password yields code `'invalid_credentials'`, status 400, which falls to the generic copy. This is Inference, medium-high. External sources W1 to W3 (section 15) are snippet-level, medium confidence. The Supabase CLI and local GoTrue versions are Unknown (no `supabase/.temp`, no CLI dependency).

**Tests that missed it.** `AuthContext.test.tsx:121` mocks the message only (no code); `adminStudentOperationsFixes.test.ts:594` lists `invalid_grant`; e2e `wp13-unauth.spec.ts:95-118` asserts only `/sign|password/i`, with a comment admitting uncertainty (`:104-108`).

**Root cause.** The mapping is keyed on an OAuth-era code the client library never emits.

**Fix.** Map `'invalid_credentials'` (keep `'invalid_grant'` as an alias) to the existing bilingual invalid-credentials kind and copy from the approved #229 design. No account-existence leak: the same copy for unknown email and wrong password, and never surface the raw message.

**RED.** A unit test with `{code:'invalid_credentials', status:400}`; tighten `wp13` Surface 1 to the exact EN copy against local GoTrue (this also records the live response shape).

**Sequence.** A separate PR after #229 merges (D-6).

### 5.4 B4 Sign-out and timeout leave a deep link (user-reported)

**Mechanism (Observed unless marked).**

- The custom router `src/hooks/useRoute.ts:49-103`: `navigate` honors the leave guard (`:58-81`); `replaceNavigate` bypasses it (`:98-103`).
- `AuthContext.signOut` (`:172-177`) calls `client.auth.signOut()`, `setSession(null)`, `setError(null)`, with no navigation. It is wired via `SignOutGuardProvider onSignOut` (`App.tsx:140`) to `requestSignOut`/`proceedSignOut` (`SignOutGuardContext.tsx:51-73`); mobile panel `App.tsx:431-433`; `ForcedPasswordChangeGate.tsx:225`.
- `onAuthStateChange` (`:126-131`) only calls `setSession` for every event (expiry or refresh failure gives null, with no navigation).
- `AuthGate` (`App.tsx:714-811`): `/courses` is the public catalog; a loading status; a `sessionError` retry card; `!session` renders `<LoginForm>` in place (`:788-803`) with no URL change and no `returnTo` or `from` logic.
- The only role redirects: owner `/` to `/admin/dashboard` (`:90-92`), unknown `/admin/*` to dashboard (`:93-95`). A non-owner on `/admin/*` sees the AdminShell permission-denied card (`AdminShell.tsx:76-100`). An owner on student routes (`App.tsx:604-623`) has no guard and gets empty or not-found student states (`EnrollmentsContext.tsx:15` skips owners; Inference).

**Root cause.** The URL outlives the session. Neither `signOut` nor the SIGNED_OUT transition resets the path; `AuthGate` keeps the deep path while signed out; and there is no role-home validation after sign-in except from `/`.

**Fix (design D3, reviewed).**

- An `AuthGate` effect, gated `!loading && !sessionError && !session` (session is null during loading, `App.tsx:729`, and during `sessionError`, `:753`), on non-public paths (public = `/courses`, `/courses/:id`), and only when the URL carries no auth-token params. Token params: hash `access_token`, `refresh_token`, `type=recovery|invite|signup`; query `code`, `error`, `error_description`; evaluated against the URL at first render. Action: `replaceNavigate('/')`.
- `AuthContext` gains an explicit-sign-out ref marker set BEFORE `await client.auth.signOut()`. The listener sets `signedOutReason='expired'` only when the marker is unset; reset on the next sign-in; in-memory.
- Expiry shows a neutral `role=status` notice on the sign-in card. EN: "Your session ended. Sign in again." ES: "Tu sesión terminó. Inicia sesión de nuevo." (ES proposed; the owner confirms.) Language comes from `PublicContentContext` `lizbeth.siteLanguage`.
- Focus: explicit sign-out moves focus to the sign-in h2 (`tabIndex -1`) only when the card renders; expiry focuses the notice; initial load and post-login redirects never steal focus (precedent `App.tsx:337` `wasLastNavigationReplace`).
- Role-home defense in depth: an owner on `/roadmap*`, `/learn*`, `/feedback`, or an unknown non-admin path gets `replaceNavigate('/admin/dashboard')`; student `/` and fall-through go to `/roadmap` (#150); a student on `/admin/*` keeps the permission-denied card.
- No `returnTo` (D-7). Expiry bypasses the unsaved-work guard (draft flush is #210).

**PR #229 overlap (Observed/Inference, medium).** 224 `AuthContext` changes the error and `sessionError` types and lines 13, 19, 41-56, 91-92, 120, 160 (the `signOut` body `:168-173` is apparently unchanged). 224 `App.tsx` shifts `AuthGate` to `:715` and `LoginForm` to `:803`. Sequence after #229 merges.

**Tests to extend.** `App.test.tsx`, `AuthGatePublicRouting.test.tsx`, `AuthContext.test.tsx`, `SignOutGuardContext.test.tsx`, `wp2-signout-registration-app-level.test.tsx`, `MobileNavSignOutStacking.test.tsx`; e2e `wp2-owner-chrome.spec.ts`, `wp9-shared-chrome.spec.ts`, `issue-54-header-nav-reachability.spec.ts`, `wp13-unauth.spec.ts`. No existing test asserts the URL after sign-out or a cross-role re-login.

### 5.5 Minor follow-ups

- #227 preview does not mention elements hidden below 900px. Recommend amending PR #232 before merge (D-27).
- PR #231 body omits `RegisterStudentModal.tsx:592`. A note in the #231 body is now optional, because PR 1b fixes that site after #231 merges (D-27).

## 6. Proposed GitHub issue texts (B1 to B4)

Filing requires approval D-3. Each body below is ready to file after approval.

### 6.1 B1

- **Title:** Republishing a course fails: finalize_publish_job never clears the previous current version (course_versions_one_current)
- **Labels (suggested):** bug, severity:S1, area:content
- **Summary:** Finalizing a second publish of a course raises a unique-constraint error, so owners cannot republish.
- **Steps to reproduce:** (1) Publish version 1 of a course through Stage and Finalize so it becomes current. (2) Create and stage version 2. (3) Click "Finalize publish".
- **Expected:** version 2 becomes the current version; version 1 stays `published` and is no longer current.
- **Actual:** the owner sees `duplicate key value violates unique constraint "course_versions_one_current"`. The version stays `staged`, the job stays `queued`, and Finalize keeps failing after reload. "Retry publish" never appears because no SQL path sets `failed`.
- **Root cause:** `finalize_publish_job` (`supabase/migrations/202608280003_issue5_course_authoring.sql:267-280`) sets `is_current=true` (`:277`) without clearing the prior current version; the unique partial index `course_versions_one_current` (`:53`) rejects it. No later migration redefines the function.
- **Impact:** every republish of a course whose prior version is current fails; backfilled courses fail from the third publish.
- **Proposed fix:** forward migration that, for a `course_id`-bearing version, takes a course-row lock first, rejects a finalization older than the current published version with `newer_version_current`, and otherwise clears the prior `is_current` for the same `course_id` inside the function, same transaction. Edge maps `newer_version_current` to HTTP 409 with a stable code. Preserve SECURITY DEFINER, `search_path`, and service_role-only EXECUTE; rollback file.
- **Acceptance (RED test):** sequential and two-connection concurrent pg tests and the Edge 409 test as listed in section 5.1.

### 6.2 B2

- **Title:** Form error text fails WCAG AA (4.05:1): competing global .form-error rules put terracotta-600 text on paper-200
- **Labels (suggested):** bug, a11y
- **Summary:** `.form-error` is defined twice with a cascade-order-dependent color. The terracotta-600 variant on paper-200 measures 4.05:1.
- **Steps to reproduce:** trigger a validation error in the forced-password-change gate, the register-student modal, or an admin student modal, and measure the error text contrast.
- **Expected:** at least 4.5:1 for normal text.
- **Actual:** 4.05:1 at 17 or more sites (listed in section 5.2).
- **Root cause:** `ForcedPasswordChangeGate.css:93-100` and `RegisterStudentModal.css:30-36` both define global `.form-error`; the status-error-text token is only AA-safe on paper-50 and paper-100.
- **Impact:** low-vision users cannot reliably read error messages on active admin and onboarding surfaces.
- **Proposed fix:** one `.form-error` rule in `src/App.css` with ink-900 text and a terracotta hairline and 3px left bar; delete both old rules. #189 (admin masthead eyebrow, brass-300) is folded in. PR #231's `.form-error--ink` modifier is retired and its class removed from #231's sites, so this PR starts after #231 merges.
- **Acceptance:** contrast pins in `statusColorContrast.test.ts`; exactly one `.form-error` rule across `src/**/*.css`; computed color `rgb(42,36,32)` on every `.form-error` surface; axe 0 serious or critical.

### 6.3 B3

- **Title:** Wrong password shows the generic sign-in error: mapping checks invalid_grant but GoTrue returns invalid_credentials
- **Labels (suggested):** bug, area:auth
- **Summary:** Entering a wrong password shows the generic fallback instead of the invalid-credentials message.
- **Steps to reproduce:** open the sign-in form, enter a valid email with a wrong password, submit.
- **Expected:** "That email or password isn't right." (EN) or the approved ES copy, identical for unknown email and wrong password.
- **Actual (Inference, medium-high):** generic error copy.
- **Root cause:** `AuthContext.tsx:34-57` keys on `invalid_grant`. auth-js 2.110.7 emits `invalid_credentials` (`error-codes.ts:88`) and no `invalid_grant` code anywhere.
- **Impact:** users get unhelpful feedback on the most common sign-in mistake.
- **Proposed fix:** map `invalid_credentials` (keep `invalid_grant` alias) to the existing invalid-credentials kind and copy. Note: PR #229 carries the same mapping gap.
- **Acceptance (RED test):** unit with `{code:'invalid_credentials', status:400}`; `wp13` Surface 1 asserts the exact copy against local GoTrue.

### 6.4 B4

- **Title:** Sign-out and session expiry keep the deep-link URL, so the next account (other role) lands on a page it cannot access
- **Labels (suggested):** bug, area:auth
- **User report (verbatim):** "sign outs or login timeouts should return the user to the main URL instead of leaving slugs in the browser URL that way when swapping between student or owner accounts we don't login to a page that the role can't access."
- **Steps to reproduce:** sign in as owner, open `/admin/students`, sign out, sign in as a student.
- **Expected:** the URL returns to `/` on sign-out or expiry, and each role lands on its own home.
- **Actual:** the path is kept and the second role lands on a route it cannot use (permission-denied card for a student on `/admin/*`; empty student states for an owner on student routes, Inference).
- **Root cause:** the URL outlives the session; `signOut` and the SIGNED_OUT transition never reset the path (`AuthContext.tsx:172-177`, `:126-131`; `App.tsx:788-803`).
- **Impact:** confusing cross-role re-login, and stale protected paths in the address bar.
- **Proposed fix:** design D3 and D7 (section 7).
- **Acceptance:** unit tests (a) to (c) and e2e journeys J1 to J8 (section 12).

## 7. Design route, reviewed design handoff, design review

### 7.1 Design route

`DESIGN_ROUTE` profile: compact. Reasons: bounded brownfield corrections in the Field Workbook system. Agents: design-generalist and design-reviewer. Prototype forbidden. Model: sonnet. Existing system mode: preserve.

Covered: B2 plus #189 (D1, D2), B4 plus #150 (D3, D7), #206 (D4), #209 (D5), #199 (D6), #53 plus B1 UI (D8), #191 (D9).

Deferred to their own sub-plan design routes: #208, #187, #188, #196 (likely compact or standard), #186 (owner content), #210 (no visual change).

### 7.2 Design handoff: "Field Workbook, corrective pass"

Existing tokens only. No new screens, tokens, primitives, or modals.

**D1 Single global `.form-error` in `src/App.css`.**

- padding `var(--space-3)`; background `var(--color-surface-chrome-default)`; border `var(--border-width-hairline) solid var(--color-status-error-border)`; `border-left-width 3px`; `border-radius var(--radius-square)`; color `var(--color-ink-900)`; `font-size .875rem`; `margin 0`; `@media (forced-colors: active)` border-color `CanvasText`.
- Delete `ForcedPasswordChangeGate.css:93-100` and `RegisterStudentModal.css:30-36`. The token is unchanged. `src/App.css` is the sole owner of `.form-error`. Permitted selectors after 1b: the base `.form-error` rule plus its `@media (forced-colors: active)` block in `App.css`, and context-scoped spacing-only selectors elsewhere that do not set color, background, or border (for example a scoped margin-top for the forced-password gate).
- `.form-error--ink` (PR #231) is RETIRED in 1b: delete the modifier rule from `RegisterStudentModal.css` and remove the `form-error--ink` class from all #231 sites, since the base rule is already ink-900. 1b starts only after #231 merges (section 9).
- Tests: pin ink-900/paper-200 at 4.5 or more, terracotta-600/paper-100 at 4.5 or more, terracotta-600/paper-50 at 4.5 or more, and terracotta-600/paper-200 below 4.5 (with a documented reason); the single rule's color is ink-900; a cascade test asserting across `src/**/*.css` exactly one rule whose selector is `.form-error` that sets color (in `App.css`, value `var(--color-ink-900)`), zero selectors containing `.form-error--`, and no other rule targeting `.form-error` that sets color, background, or border; plus `rg -n "form-error--" src` returns zero hits.

**D2** `.admin-masthead-eyebrow` becomes `var(--color-brass-300)` (6.80:1); size and tracking unchanged.

**D3** As in section 5.4, plus notice styling: paper-50 background, ink-700 hairline plus 3px ink-700 left bar, ink-900 text at `.875rem`, forced-colors `CanvasText`. Required unit tests: (a) readiness gate; (b) marker ordering, expired reason, and reset; (c) each exempted param blocks the replace (evaluated at first render).

**D4 (#206).**

- "Jump to review" keeps its `href`; the click handler calls `preventDefault`, `scrollIntoView` (instant under reduced motion), and focuses `h2.review-form-heading` (`tabIndex -1`).
- `<header className="owner-submission-header">` becomes `<div>` at `OwnerSubmissionDetailPage.tsx:224` and `OwnerQuizAttemptDetailPage.tsx:249` (check `OwnerSubmissions.css:99`). `findHeading` is unchanged.
- Item 5 (if approved): focus the first invalid field in DOM order (feedback, score) after errors commit; the same for server `fieldErrors` (`ReviewForm.tsx:114-115`). Non-field failures go in a `role=alert` `tabIndex -1` region that is focused. `Field.tsx:95-96` forwards `aria-invalid` and `aria-describedby`; the error has `role=alert` at `:144`.
- Chip: nowrap, align baseline, glyph `flex none`, label `min-width 0` with `overflow-wrap anywhere`. List padding 0, keep the gap.

**D5 Save-line matrix (#209).**

| State | Visible line | Announcement |
|---|---|---|
| saving | saving | existing |
| saved this session | saved_at (student time) | announce |
| hydrated draft, no edit | none | none |
| returned, no edit | none | none |
| returned, edited and autosaved | saved_at | announce |
| submitted or reviewed | none | none |
| error, offline, too_long | existing | existing |

Gate `live` (`LessonTaskBar.tsx:150`) on `!readOnly` and a locally-set `savedAt`. The hook must not store a hydrated or owner timestamp.

**D6 (#199)** Stack the type label under the name at all widths, including the rail; `overflow-wrap anywhere`; the 701px-and-wider embedded grid is unchanged.

**D7 (#150)** Student `/`, `/roadmap/`, and unknown fall-through use `replaceNavigate('/roadmap')`; loop guard; owners excluded; the issue-132 e2e is inverted.

**D8 Publishing (#53, B1 UI).** One persistent `role=status` container (text changes only).

- idle: caution-irreversible tier.
- finalizing: `aria-disabled`, "Publishing…", status "Publishing this version…", focus stays, handler early-return guard, Stage and Retry inert.
- published: Finalize and Retry removed; note "Version published." in ink-900 on paper-50 with an ink-moss 3px bar, focused with `tabIndex -1`.
- failed: shared `.form-error` with `role=alert`; Finalize returns to idle; Retry appears when `job.status==='failed'`.
- Error mapper by code, then pattern; never render `error.message` (console only):
  - `23505` or `course_versions_one_current`: "Another version of this course is already published as the current version, so this one couldn't be finalized. Reload the page to see the current version."
  - `newer_version_current` or HTTP 409: "A newer version of this course was published while this one was finalizing. Reload the page to see the current version." (Revision 1, J-001. Owner admin copy is English-only. This is a wording addition within the reviewed binding categories, a permitted variation, so no design re-review is needed. The `23505` mapping above stays as a defensive fallback.)
  - network: "Couldn't reach the server. Check your connection and try again."
  - 401 or 403: "You don't have permission to publish this course."
  - other: "Couldn't finalize this publish. Try again, and contact support if it keeps happening."
  - stage fallback: "Couldn't build the course files. Try again."
  - retry fallback: "Couldn't retry the publish. Try again."
- No confirmation modal (D-10).

**D9 (#191)** The page-level SiteText `roadmap.ledger_footnote` is authoritative; remove the per-band hard-coded legend (or render it via the same key if the owner prefers; never hard-coded). A disabled key hides all legends with no gap.

### 7.3 Engineering invariants (11)

1. One `.form-error` rule, ink-900, owned solely by `src/App.css`; `.form-error--ink` retired.
2. The `status-error-text` token is unchanged.
3. The signed-out redirect fires only when `!loading && !sessionError && !session`, never on a public path or auth-token URL, and via `replaceNavigate`.
4. A role-invalid post-login state goes to the role home, with no `returnTo`.
5. The marker is set before `await signOut`; SIGNED_OUT sets `'expired'` only if unset.
6. Focus moves only on authed to unauthed, and only when the sign-in card renders.
7. No raw backend error in Publishing.
8. The finalize double-submit guard lives in the handler; a single persistent status container.
9. No native dialogs.
10. Returned and read-only tasks never show a non-student "Draft saved".
11. Owner admin is English-only (the only new Spanish string is the notice; the owner confirms it).

Permitted variation: file placement of the single `.form-error` rule (an always-loaded sheet); Jump via click handler or hash-change effect; owner publish copy wording within the binding categories; tightening `findHeading` only if the page-local fix fails; the mechanism of the marker and reason within the rules.

### 7.4 Contrast table (hand-computed; confirm in `statusColorContrast.test.ts`)

| Pair | Ratio | Result |
|---|---|---|
| ink-900 on paper-200 | 12.9 | pass |
| terracotta-600 on paper-200 | 4.05 | text FAIL, non-text pass |
| terracotta-600 on paper-100 | about 4.54 | pass |
| brass-500 on ink-900 | 4.06 | FAIL |
| brass-300 on ink-900 | 6.80 | pass |
| ink-900 on paper-50 | about 15 | pass |
| ink-700 on paper-50 | about 8.7 | pass |
| ink-moss on paper-50 | about 7.4 to 7.5 | pass |

### 7.5 Design review

`DESIGN_REVIEW_RESULT` PASS from an independent design-reviewer (Sonnet) after one evidence-backed NEEDS_REVISION:

- F1 (major): the redirect would fire during loading and `sessionError` and misclassify explicit sign-out.
- F2: untestable token test.
- F3: notice language, focus, forced-colors.
- F4: live region.
- F5: legend duplicate confirmed.
- F6: Back outcome and owner fall-through.

All were resolved in revision 1. Advisories: N1, evaluate the auth-token exemption against the URL at first render (in test (c)); N2, legend removal is an owner choice.

Remaining limits: ratios are hand-computed; rendered behavior and Supabase event ordering were not run; the reviewer did not re-verify Publishing line references. The ES notice, finalize confirmation, legend, #206 item 5, and `returnTo` remain owner confirmations. The `status-error-text` consumer audit is a follow-up.

## 8. Judge route

Per `docs/JUDGE-CONTRACT.md`; policy: shadow (advisory).

- PLAN_DUCK is eligible for this plan before approval (the orchestrator runs it).
- CODE_REVIEW is recommended for migration PRs (B1, #190, #202, #198, which is high-risk access control) and the auth PR (B4).
- VERIFICATION_CHALLENGE only where coverage risk remains (#210, #198).
- VISUAL_REVIEW is not required (compact, non-brand-critical), except optionally on the contrast PR.
- Respect the two and four call caps. Deterministic failures dominate. Finding ids flow into the engineering job and the Verifier brief. No judge pass is promised and no model-generated findings are included.

## 9. Waves and PRs

Rules for every PR: one PR per coherent cluster; base `main`; never push to main; each PR body carries "Closes #N"; T1 first-line in standard mode; Step 0: fetch origin, record the base SHA, re-verify cited lines, and trigger the stale-plan check if materially changed.

### Wave 0: after approval, no code (orchestrator via gh)

- Close #79 with an evidence comment (D-1).
- Close #139 as a duplicate of #82 (D-2).
- File B1 to B4 with the section 6 texts (D-3).
- The user optionally runs the read-only production queries: B1 (1) to (4); the #190 grants; roster count versus auth users (D-29).

### Wave 1: production defects (independent of open PRs except 1b, which waits for #231)

Execution order: 1a, then 1c, then 1b (Revision 1).

- **PR 1a** B1 republish backend: migration with per-course row lock and newest-version-wins, rollback, RED pg tests including two-connection concurrency, and the Edge 409 mapping (D-30). Closes B1. Hosted apply is separate (D-28).
- **PR 1c** #53 plus B1 Publishing UI state machine and error mapper (design D8, including the `newer_version_current` copy). Closes #53; Refs B1. After 1a (the code is independent, but sequencing keeps verification meaningful).
- **PR 1b** B2 plus #189 contrast: CSS and contrast/cascade tests, `.form-error--ink` retired. Closes B2 and #189. Starts only after PR #231 (and its base #230) are merged to main; branch from the post-merge main head; never stack 1b on #231. If #231 is not merged when 1a and 1c are done, 1b is deferred behind the Wave 2 PRs (not stacked) and resumes when #231 merges. Step 0 for 1b re-verifies every `.form-error` site on the new head, including #231's new sites and `RegisterStudentModal.tsx:592`.

### Wave 2: test-infrastructure health (closes the baseline)

- **PR 2a** `require-backup` environment: `skipIf` the gitignored dumps are missing; Windows symlink capability skip. Refs #218.
- **PR 2b** stale tests: gap-1 selector to `.admin-masthead-eyebrow` plus restore sentinel; issue-3 awaits login after sign-out; wp5 abort-until-flag; #201 awaits the PDF before Tab; issue-54 header overlap CSS fix only if it reproduces at 900/1024/1280/1440 (restores the approved #54 design). Closes #201; Refs #218.
- **PR 2c** isolation and pollution: #81 `try/finally` plus `lesson_revisions` cleanup; #137 `beforeAll` precondition guards and disposable accounts for rotation; #48 gap-4 cleanup plus a loopback-guarded `globalTeardown` sweep; identify the student1 double-enrollment source. Closes #81 and #137; closes #48 when two full runs keep `auth.users` and the student1 enrollment stable.
- **PR 2d** fixture provisioning for issue-50, issue-55, wp4 (D-12: self-provision recommended; wp8/#170 pattern via `createOwnerCourseFixture`). Refs #218.
- **PR 2e** date drift #82/#139 (D-13: re-anchor helper recommended). Closes #82 and #139 (if not already closed as a duplicate). The last Wave 2 PR carries "Closes #218" once the full e2e suite shows 0 failures twice after one reset.
- **PR 2f (#203 checklist, early docs PR)** Scribe writes the vocab spot-check checklist and golden procedure as a small docs PR in the lizbeth repo, delivered alongside Wave 2 and ahead of Wave 7 because Lizbeth will check soon (D-24). Lizbeth's sign-off (date and recaps checked) is recorded when she completes it. Refs #203; #203 closes after the sign-off and the post-Wave 7 re-check.
- **#166** closes after PR #231 merges and two clean runs (D-14).
- Diagnose wp2 J3, issue175, and the intermittent vitest suites at wave start. Each becomes a product-defect issue or a test fix with evidence. Never weaken assertions.

### Wave 3: auth (after PR #229 merges; B4 also after B3)

- **PR 3a** B3 `invalid_credentials` mapping. Closes B3.
- **PR 3b** B4 sign-out and expiry landing, role-home fallback, and #150 canonicalization (design D3, D7). Closes B4 and #150.

### Wave 4: UI corrective

- **PR 4a** #206 (items 1 to 4, plus 5 if D-9), #209, #199, #191 (design D4, D5, D6, D9). Closes all four.
- **PR 4b** #210 repro-first (four RED repros, then the fix). Closes #210.

### Wave 5: DB and security (forward migrations plus rollbacks; hosted apply separate)

- **PR 5a** #190 grant hardening (S). Closes #190.
- **PR 5b** #202 `save_outline` identity (option (c), client and SQL). Closes #202.
- **PR 5c** #198 canonical entitlement rule for the legacy policies; detailed sub-plan at wave start (after D-15 and 5b). Closes #198.

### Wave 6: copy registry (after PRs #229 and #232 merge)

#186 (after wording, XS); #208 sub-plan (L), starting after PRs #229 and #232 merge, hybrid scope with Lizbeth approving the drafted Spanish before shipping (D-21); #188 only if D-20 is go; #187 sub-plan (DB decision D-19). Each new key requires a hosted site-content Edge redeploy (separate approval).

### Wave 7: content batch

One regenerate and re-provision pass; re-provision is gated by the pending Stage B leak-gate owner decision (D-25). Order: #212 nested tooling port first; #214 (source, quiz JSON, content-source, regenerated `lesson-content.json`, new quiz-definition migration); #194 (after D-23); #193 sub-plan; #215 (decided, D-22: convert advanced yes/no "Does/Is" meta items to `true_false`, drop or convert course-structure meta items, add the per-band teacher-graded share assertion to `check:quiz-complete`; exact item set listed in the Wave 7 sub-plan for owner review). The #203 checklist is no longer a Wave 7 item (it ships early as PR 2f); Wave 7 triggers a re-check of any changed recaps under the golden procedure.

### Wave 8: backlog feature

#196 sub-plan with its own design route (after 5b; D-26).

### 9.1 Executable now versus deferred

- Executable from this plan once approved: Waves 0 to 4, and PRs 5a and 5b (grounded scope, root cause, acceptance). PR 1b is executable only after PRs #230 and #231 merge.
- Deferred detailed sub-plans (re-plan and approval at wave start): 5c #198, Wave 6 (#208, #187, #188), Wave 7 #193 (and the batch's provisioning steps), Wave 8 #196.

### 9.2 Order rationale

User-reported production defects come first: B1 blocks every republish, and B2 is an AA failure on active admin and onboarding surfaces. Test health follows so later PRs verify against a clean baseline. Auth waits for #229 to avoid conflicting hunks. Security migrations follow #202 because of the dependency. Copy and content wait for #229 and #232 and for owner decisions. Waves are serial (one writer). Wave 1 PRs are independent of open PRs except 1b, which waits for #231 because both edit the same `.form-error` rules. Wave 1 and Wave 2 PRs may otherwise reorder, and if #229 merges early Wave 3 may move up (B3 is small).

## 10. Interfaces and data

- **B1:** redefine `finalize_publish_job` (same signature, SECURITY DEFINER, `search_path=public`, service_role-only EXECUTE preserved); rollback file. Revision 1: the function takes a course-row lock first and raises `newer_version_current` (errcode P0001) for an older finalization; Edge `finalize_publish` maps it to HTTP 409 `{error: 'newer_version_current'}` and returns a generic code for any other DB error. The client error mapper (D8) adds the matching category.
- **#190:** privilege-only migration; rollback from the pre-apply snapshot.
- **#202:** the `save_outline` payload gains `lesson_revision_id` per lesson (client sends; server validates against the current draft mapping). The response already returns `{position, lesson_revision_id}`; the client adopts new ids.
- **#198:** two RLS policy rewrites (`public.resources`, `storage.objects`); sub-plan.
- **B4:** the `AuthContext` public value gains `signedOutReason: null | 'expired'` (consumers updated in the same PR); no DB change.
- **B3:** mapping only.
- **B2, #189, #199, #206, #209, #191:** CSS and component only. #191 reuses an existing key (no Edge redeploy). The `.form-error--ink` class and rule are removed (PR 1b); `src/App.css` is the sole owner of `.form-error`.
- **Wave 6:** new registry keys require a site-content Edge redeploy; no migration for keys; #187 may add a migration.
- **Content:** a new quiz-definition migration plus storage re-provision.
- **All migrations:** forward-only; naming `YYYYMMDDNNNN_<issue>_<slug>.sql` after `202610070002`; rollback in `supabase/rollbacks/<issue>_<slug>_rollback.sql` (issue176 precedent).

## 11. Acceptance and validation

### 11.1 Per PR (all)

- Step 0 preflight.
- `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`.
- Full `npx vitest run` on a freshly reset local stack with no new failures versus the recorded baseline (and Wave 2 shrinking it); targeted specs.
- A RED test shown failing before the fix and passing after (record both runs).
- Verifier PASS; Browser Validator PASS for UI PRs; CODE_REVIEW where routed.
- PR opened against `main` with "Closes #N"; no merge.

### 11.2 Commands

Port-shifted mirror: Windows reserves 54314-54413, so the mirror uses 643xx; mirror `.env.local` points to `http://127.0.0.1:64321`; per-file copies only, never `robocopy /MIR`; new Edge function files need a full `supabase stop/start`.

```text
npx supabase start
npx supabase db reset
docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish   (first request after reset may 502)
npx vite --port 5180 --strictPort    (ready when http://localhost:5180 serves sign-in)
E2E_BASE_URL=http://localhost:5180 npx playwright test    (testDir src/__tests__/e2e, workers 1, chromium)
```

Exact mirror procedure: `docs/plans/lizbeth-spanish-issue228-create-and-assign.md` section 10.1 and `docs/plans/lizbeth-spanish-issue227-site-copy-editor-preview.md`.

### 11.3 Known baseline on main (record at Step 0)

- Vitest: `require-backup.test.ts` (plus intermittent `issue5-services` PDF, `issue179` SQL, `courseAuthoringUi`, `issue5EdgeSmoke`). Also `fieldJournalTokens` (needs parent-dir config; rev-1 section 3.1).
- e2e: gap-1, issue-3, issue-50 (x3), issue-54, issue-55 (x2), wp4-roster, wp5-feedback-inbox, neo-workbook-visual-smoke; intermittent wp2-owner-chrome J3, issue174 J8, issue175, browser-validation-status-clarity J1.

### 11.4 Wave-specific gates

- **1a:** RED pg test (v1 finalized current, then v2 finalize succeeds, v1 published and not current, v3 succeeds, one current); `issue5BackendIntegration:112` passes; rollback parity; a stuck queued job finalizes post-migration; detection queries (1) to (4) on local before and after; the two-connection concurrent finalize tests (no-current and existing-current cases, both commit orders) pass 10 iterations without flake; the Edge test shows `newer_version_current` returns 409 with the stable code and no raw message.
- **1b:** (starts after #231 merges) `statusColorContrast` pins; cascade test: across `src/**/*.css` exactly one rule with selector `.form-error` that sets color (in `App.css`, `var(--color-ink-900)`), zero selectors containing `.form-error--`, no other `.form-error` rule setting color, background, or border; `rg -n "form-error--" src` returns zero hits; computed color `rgb(42,36,32)` on every `.form-error` surface (forced-password gate, register modal, admin student modals); eyebrow brass-300; axe 0 serious or critical on those pages.
- **1c:** unit tests: success hides or relabels Finalize; double-click sends one RPC; a rejected finalize shows mapped copy with no "ERROR:", SQLSTATE, or constraint text; polled `succeeded` shows no Finalize; persistent status container; a mocked 409 `newer_version_current` shows the mapped copy.
- **2a:** a clean-clone `require-backup` run passes with skips.
- **2b:** each named spec green 5 of 5 repeated runs; #201 `--repeat-each=5` at 390 and 1440.
- **2c:** injected-failure cleanup proof for `issue5EdgeSmoke`; PRE and POST fingerprints (auth.users count, student1 and student2 credentials and flags, enrollment counts, course_versions, lesson_revisions) unchanged across two full runs.
- **2d:** specs pass immediately after `db reset` and on a second run without reset.
- **2e:** an aged-database run (simulate +8 days) passes; full suite twice.
- **3a:** unit `{code:'invalid_credentials',status:400}` gives invalid-credentials copy in EN and ES; an unknown email gets identical copy; `wp13` Surface 1 asserts the exact copy against local GoTrue (records the live response shape).
- **3b:** unit tests (a) to (c) from the design; `signOut` gives pathname `/`; e2e cross-role journeys (section 12); issue-132 inverted; existing sign-out guard tests unchanged.
- **4a:** per design brief outcomes (#206 focus, chip line, list edge; #209 matrix; #199 bounding box at 1440, 390, 320; #191 enabled and disabled).
- **4b:** four RED repros fail then pass (Chromium and WebKit for Playwright); no `beforeunload`.
- **5a:** this pg-catalog query returns 0 rows:

```sql
select c.relname, r from pg_class c join pg_namespace n on n.oid=c.relnamespace, unnest(array['anon','authenticated']) r where n.nspname='public' and c.relkind in ('r','p') and (has_table_privilege(r,c.oid,'TRUNCATE') or has_table_privilege(r,c.oid,'REFERENCES') or has_table_privilege(r,c.oid,'TRIGGER'))
```

  SELECT grants are unchanged. The hosted read-only check also runs:

```sql
select defaclrole::regrole, defaclnamespace::regnamespace, defaclobjtype, defaclacl from pg_default_acl where defaclnamespace='public'::regnamespace;
```

- **5b:** the six RED tests listed under #202.

### 11.5 No-native-dialog scan (every UI PR)

```text
rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"
```

Zero product hits, plus a failing `page.on('dialog')` listener in each new or changed spec, and modal keyboard and focus verification wherever Modal is touched (Escape/Close, focus return).

## 12. Browser UI dialog policy and browser validation inputs

### 12.1 Dialog policy

Required for every UI wave (1b, 1c, 2b if CSS, 3b, 4a, 4b, 6, 8). No `alert`, `confirm`, `prompt`, `window.alert/confirm/prompt`, or `beforeunload` prompts. Use the app-owned accessible Modal (`src/components/Modal.tsx`) with Escape/Close and focus return for any confirmation; inline validation is preferred. #210 uses `pagehide`, `visibilitychange`, and `keepalive` only. Verification: the deterministic source scan (section 11.5), a runtime `page.on('dialog')` listener, and modal keyboard and focus checks where a modal is touched.

### 12.2 `browser_ui_validation` (standard block per UI PR)

- Launch and readiness in the port-shifted mirror: `npx supabase start`; `npx supabase db reset`; `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`; `npx vite --port 5180 --strictPort`; ready when `http://localhost:5180` serves the sign-in page.
- Base URL: `http://localhost:5180`.
- Reset and fixtures: `db reset` plus seed (then docker restart; the first request may 502). Accounts with password `password`: `owner@test.local`, `student1@test.local`, `fullaccess@test.local`. Credential-rotating journeys use disposable accounts only.
- Viewports: 1440x900 and 390x844 minimum; 320 and forced-colors spot checks for D1, D3, D4 item 3, D6, D8 (including the D3 notice and D8 status note borders).
- Evidence screenshots under `browser-validation-artifacts/<issue>/`.

### 12.3 Journeys and visible outcomes

**B4/#150 (PR 3b)**

- J1: owner signs in, opens `/admin/students`, signs out. URL is `/`, the sign-in card shows, no notice, focus on the card h2. student1 signs in and lands on `/roadmap` with a clean URL and the context strip.
- J2: reverse. student1 at `/roadmap/<id>/week/2` signs out; URL `/`. Owner signs in and lands on `/admin/dashboard`.
- J3: simulated expiry (revoke the session, clear the refresh token, or sign out in a second tab) at a deep page. URL `/`, notice visible and focused, EN. Repeat with Español chosen for the ES notice.
- J4: signed-in hard reload of `/admin/students` and `/roadmap/<id>/week/2` is not replaced.
- J5: signed-out load of a recovery or invite hash, `?code=`, or `?error=` is not replaced.
- J6: owner loads `/roadmap`, `/learn`, `/feedback`, `/xyz` and lands on `/admin/dashboard`; a student loading `/admin/students` sees the permission-denied card.
- J7: signed-out `/courses` and `/courses/<id>` are not replaced and focus does not move.
- J8: student `/`, `/roadmap/`, `/xyz` go to `/roadmap` with the strip; Back never shows protected content after sign-out.

**B2/#189 (PR 1b):** trigger errors in the forced-password gate, register modal, and admin student modals. Computed color is `rgb(42,36,32)`, the terracotta left bar is visible; the `/admin/dashboard` eyebrow is brass-300; the forced-colors border is visible.

**#53/B1 UI (PR 1c):** owner stages and finalizes. A busy state shows, one request is sent on double click, the success note is focused, and the status container persists. A forced duplicate-key failure (pre-1a database or injected 422) and an offline failure both show mapped copy, never raw Postgres text, and Retry is available. An injected 409 `newer_version_current` shows the newer-version copy and no raw text.

**PR 4a:** `/admin/submissions/<id>` at 390 and 1440: Jump focuses the review h2; Next lands on the destination h1; the chip glyph is on the first line; the list edge aligns with the h1; an invalid submit focuses the first invalid field (if D-9). Student returned and reviewed tasks show no "Draft saved" until an edit. The `/roadmap` rail FLASHCARDS label stays within row bounds at 1440, 390, 320 (bounding-box check with a long name). The legend shows once (page-level) when enabled and is gone everywhere with no gap when disabled.

**PR 4b:** type then Back within 2s, return and reload: the draft persists. Tab close within 2s: persists. No dialog event.

**PR 2b (if issue-54 CSS):** owner at 900, 1024, 1280, 1440: the accessibility trigger and Sign out boxes do not overlap; 390 mobile menu path; keyboard reaches both.

## 13. Risks and rollback

| Id | Risk | Containment |
|---|---|---|
| R1 | Stale base (origin/main advances; open PRs merge) | Step 0 re-verify; stale-plan trigger (section 16). |
| R2 | B1 migration on live data | Atomic same-transaction clear, no data repair needed; rollback file restores the prior body; detection queries before and after; hosted apply separately approved. Revision 1: lock wait on a concurrent finalize is short (one row, owner-initiated, rare). No deadlock, because the `courses` row is locked before the version and job rows in the single code path; the target version and job are currently locked first at `:271-278`, so the migration must take the course lock as the first lock in the function (reorder) to keep a consistent lock order. |
| R3 | B4 redirect regressions (deep-link reload, invite and recovery links, public catalog) | Readiness gate, exemption list, explicit journeys. Rollback is a PR revert (no data). |
| R4 | Conflicts with PR #229 | Wave 3 waits for the merge. |
| R5 | Contrast change alters the visual tone of errors | Design-reviewed; token unchanged. |
| R6 | Test fixes mask real defects | Never weaken assertions; issue-54 is treated as a product defect if reproduced; RED-first. |
| R7 | #190 over-revoke breaks RLS | Revoke only the three privileges; SELECT guard test; rollback from snapshot. |
| R8 | #202 and #198 authoring and access-control risk | Server-validated identity; sub-plan for #198 with a live-cohort preview. |
| R9 | Content re-provision blocked by the leak-gate decision | The content batch waits. |
| R10 | Cleanup helpers touching non-local data | Hard-fail unless the Supabase URL is 127.0.0.1 or localhost. |
| R11 | PR 1b depends on unmerged PR #231 (both edit `.form-error` rules; #231 adds `.form-error--ink`) | 1b starts only after #230 and #231 merge and is never stacked. If #231 changes again before merge, 1b's Step 0 re-inventory catches new sites. Stale-plan trigger if #231 introduces another `.form-error` variant. |

## 14. Decisions

Each requires an explicit user answer unless "default if silent" is stated (none of these carries a silent default).

| Id | Decision | Recommendation |
|---|---|---|
| D-1 | Close #79 now with evidence. | Yes. |
| D-2 | Close #139 as a duplicate of #82 now. | Yes (the fix PR still references both). |
| D-3 | File B1 to B4 as GitHub issues with the section 6 texts. | Yes. |
| D-4 | B1 scope: clear the prior `is_current` only (prior version stays `published`); do NOT add an in-DB owner check now (service_role-only EXECUTE plus the Edge ownership gate); record as a follow-up. | As stated. |
| D-5 | B2: one global ink-900 `.form-error` owned by `src/App.css` (changes pre-existing sites that PR #231 deliberately left alone); `.form-error--ink` retired; token unchanged; PR 1b sequenced after #231 merges. | Yes. |
| D-6 | B3 sequencing: a separate small PR after PR #229 merges. Alternatives: stack on #229, or add the one-line case to #229 before merge. | After merge (keeps #229's reviewed scope). If the #229 merge slips beyond about 1 week, hotfix main's `getSignInErrorMessage` instead. |
| D-7 | B4: role-home landing, no `returnTo` restoration for same-user timeouts; bundle #150 canonicalization; owner confirms the ES notice string. | Yes. |
| D-8 | #150: canonicalize student `/` to `/roadmap` (versus rendering the strip at the catch-all). | Canonicalize. |
| D-9 | #206 item 5: move focus to the first invalid field (reverses an earlier handoff). | Adopt. |
| D-10 | #53: no confirmation modal before Finalize. | No modal. |
| D-11 | #191: page-level legend authoritative; remove the per-band hard-coded legend. | Yes. |
| D-12 | #218 fixtures: self-provision per spec (wp8 pattern) versus deterministic seed rows. | Self-provision. |
| D-13 | #82: fixture-date re-anchor helper (local-only, loopback-guarded, invoked by the test global setup) versus `db reset` in Playwright `globalSetup`. | Re-anchor (covers vitest too, non-destructive). |
| D-14 | #166: no new roster work; close after PR #231 merges plus two clean runs. | Yes; also deploy #231's `admin-student-operations` Edge change promptly (hosted roster truncation). |
| D-15 | #198: entitlement rule canonical (cohort anchor, cvl offsets, held/revoked). | Yes; after #202. |
| D-16 | #190: revoke truncate/references/trigger on all public tables plus default privileges; hosted read-only check first. | Yes. |
| D-17 | #202: option (c), server-validated round-trip of `lesson_revision_id`. | Yes. |
| D-18 | #186: the owner supplies wording; then update `index.html`, the registry default, and fixtures. | Needs wording from the owner. |
| D-19 | #187: storage location (`owner_settings` column plus anon view versus a `site_content` setting key). | `owner_settings` column plus anon view, in a sub-plan. |
| D-20 | #188: go or no-go. | No or defer (decorative; an uploaded logo replaces it). |
| D-21 | #208: hybrid scope. Functional strings get fixed EN/ES translations (not owner-editable or hideable); only explanatory and instructional messages become owner-editable registry keys. Engineering and Scribe draft the Spanish and Lizbeth approves it before shipping (waives the #177 "no machine translation" rule for #208 only). Sub-plan after #229 and #232 merge. | RESOLVED 2026-10-12: approved as recommended ("you draft and she approves"). |
| D-22 | #215: target `open_ended` share. | RESOLVED 2026-10-12: "less grading". Wave 7 converts advanced yes/no "Does/Is" meta items to `true_false`, drops or converts course-structure meta items (new quiz-definition migration plus re-provision, gated by D-25), and adds a per-band teacher-graded share assertion to `check:quiz-complete`. Target about 35-40%, exact set in the Wave 7 sub-plan for owner review. |
| D-23 | #194: one template sentence with a topic slot. | Recommend. |
| D-24 | #203: Lizbeth performs a spot-check of at least 5 recaps and signs off on the Scribe checklist. | RESOLVED 2026-10-12: Lizbeth signs off and will do so soon. The checklist moves earlier (small docs PR in the lizbeth repo, alongside Wave 2); a re-check of recaps changed in Wave 7 is required under the golden procedure. |
| D-25 | Content re-provision depends on the pending Stage B leak-gate owner decision. | Needs the owner. |
| D-26 | #196: go, scoped to published-version-only generation, after #202. | Go later (Wave 8). |
| D-27 | Minor: amend PR #232 to state elements hidden below 900px in the preview. The `RegisterStudentModal.tsx:592` note in the PR #231 body is now optional (PR 1b fixes that site after #231 merges). | Yes. |
| D-28 | Hosted rollout (each migration apply, Edge deploy, Netlify) is a separate explicit approval per PR. | Standing. |
| D-29 | The user runs read-only production queries (B1 (1) to (4), #190 grants and default ACL, roster versus auth user count). | Yes, before the Wave 1 hosted rollout. |
| D-30 | Concurrent-finalize policy for B1: per-course row lock, newest version wins, an older or equal finalization is rejected with `newer_version_current` (HTTP 409). | Yes. |

## 15. Assumptions and adjacent findings

### 15.1 Safe assumptions

- GoTrue's default `listUsers` page is 50 (from PR #231's test comment).
- Stylesheet order is as stated in the PR #231 comment.
- Contrast ratios are hand-computed.
- Every Inference item is confirmed by the RED test in its wave.

### 15.2 Research basis and limits

Five sequential bounded Researcher passes (R1 B1 to B4; R2 test-infra; R3a UI; R3b data and security; R4a copy registry; R4b content). All were static and read-only at `88b43fd`. Bash was unavailable to Researcher, so no tests or git diffs were run. External: auth-js 2.110.7 source (local `node_modules` in `lizbeth_spanish-224`) and three web snippets, medium confidence, accessed 2026-10-12:

- W1: https://github.com/supabase/auth/issues/1662
- W2: https://www.guardlayer.io/blog/supabase-invalid-login-credentials
- W3: https://www.iloveblogs.blog/post/supabase-auth-error-codes-typescript

### 15.3 Adjacent findings (recorded, not scheduled)

- `save_revision` accepts any `payload.legacy_lesson_id` (`course-authoring/index.ts:492`). Verify the Edge owner gate (candidate issue).
- `202608280003:531` `revoke all` on `lesson_revisions` from authenticated may make the student read policies `:521-527` inert (verify).
- `finalize_publish_job` lacks an in-DB owner check.
- `publish_jobs` never set `failed`.
- An audit of about 20 `status-error-text` consumers.
- Hosted rosters may already be truncated (more than 50 auth users).

### 15.4 Separate workstream: privacy policy

The user requested a new, separate privacy-policy workstream (Michigan, US; 18+ only; payments off-site). It is planned in its own plan document and is not part of this plan.

## 16. Stale-plan conditions

This plan is stale and must be re-planned (or re-verified at Step 0) if any of these occur:

- `origin/main` moves past `88b43fd` with changes to any cited file.
- Any of PRs #229 to #232 merges with changes to cited hunks (notably `AuthContext.tsx`, `App.tsx` AuthGate, `RegisterStudentModal.css`, `admin-student-operations/index.ts`).
- New evidence contradicts a verdict in section 4 or a root cause in section 5.
- PR #231 introduces another `.form-error` variant before it merges (R11).

## 17. Approvals required

1. Explicit user approval of this plan: GRANTED 2026-10-12 (as recommended), including #208 (D-21), #203 (D-24) and #215 (D-22), which were resolved by the user's later decisions that day (section 14).
2. Per decision: answers to D-1 to D-30, in particular D-3 (file issues), D-1 and D-2 (close issues) before any Wave 0 action.
3. Separate explicit approval for each hosted action: migration apply, Edge deploy, Netlify deploy (D-28).
4. Owner input still required for: #186 wording (D-18), the Stage B leak-gate decision (D-25), and the ES expiry notice (D-7). Lizbeth's approval of the drafted #208 Spanish and her #203 sign-off are recorded when she completes them.
5. Re-plan and approval at the start of each deferred sub-plan (5c, Wave 6, Wave 7 #193, Wave 8).
6. No commit, push to main, merge, deploy, or live Codex smoke call without explicit user instruction.

## 18. Engineering mode and downstream owner

- Engineering mode: standard (T1 first-line; T2 escalation per fleet rules: two counted T1 gate failures escalate to T2; two counted T2 gate failures block for user review). No extreme-advisory team. Team authorization: not applicable.
- Downstream owner: engineering-fleet (code for Waves 1 to 5 and 8); Scribe for the #203 documents, the drafted #208 Spanish, and any later sub-plans; the orchestrator for Wave 0 `gh` actions after approval.

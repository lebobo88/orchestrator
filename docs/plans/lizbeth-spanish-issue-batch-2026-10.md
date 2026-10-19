# Lizbeth Spanish: October 2026 Open-Issue Batch (43 Issues Triaged; Wave 1 Test Health and Wave 2a Sign-In Executable)

Status: PARTIALLY APPROVED 2026-10-10 (revision 1). Only the scope in the approval banner below is approved for execution. All other waves are deferred and not approved.

> **Approval and status banner (user decision 2026-10-10, relayed by the lead)**
>
> User decision (verbatim): "i'm pretty sure all of those but the 5 new ones are already done. let's only implement the 5 new ones now. then we need to do a comprehensive deep dive review of all the other issues logged on the repo."
>
> - **Approved scope for execution now:** only #224, #225, and #226 (Wave 2a, one PR, fully planned and design-passed), and #227 and #228. Each of #227 and #228 requires its own sub-plan, design pass, and user approval before implementation, per this plan.
> - **Deferred, not approved:** Waves 1, 2b (#140, #183), 3, 3b, 4, and 5. A comprehensive deep-dive review of all other open issues follows after the five new issues. The user believes they are already done; that review will reconcile them against this plan's revision 1 reconciliation table (section 3.6).
> - **Baseline handling:** the Wave 1 baseline is not approved as a gate prerequisite. Wave 2a gates compare against current main's known pre-existing e2e failures (#218) rather than requiring them to be fixed.
> - **Already closed 2026-10-10 with evidence comments:** #63, #80, #148, and #170 (completed); #197 (not planned).
> - **Resolved decisions:** D-2, owner-customized English wins over built-in Spanish when Spanish is not customized. D-3, "tu profesora". D-4 and D-11 are recorded but apply to deferred waves.

Plan ID: `lizbeth-spanish-issue-batch-2026-10`. Task ID: `lizbeth-spanish-issue-batch-2026-10`. Route: engineering, with Scribe-authored content and evidence sub-deliverables in Wave 4.

Target repository: `lebobo88/lizbeth-spanish` (private; local family under `H:\CommandCenter\orchestrator\lizbeth_spanish*`). `origin/main` = `88b43fd37f04af90860fc93b5f3c8e4d696a48f9` (PR #223, the #222 least-privilege EXECUTE work, merged 2026-10-07; latest migration `202610070002_revoke_authenticated_execute_internal_functions.sql`).

Planner's evidence comes from a fresh detached read-only worktree of `origin/main` `88b43fd` at `H:\CommandCenter\orchestrator\lizbeth_spanish-main-88b`. Line numbers below are from that worktree and are re-verified at each PR's Step 0. The main checkout `H:\CommandCenter\orchestrator\lizbeth_spanish` is on the stale branch `release/fjds-course-management-20260915` (`b1e85e2`; Observed via `.git/HEAD` and `packed-refs`). It must NOT be used as a base or for line references. It matters only for the gitignored nested `tools/lesson-generation` repo (#212), which exists there alone.

Audience: the user (approver and sole merger), Lizbeth (owner; optional Spanish copy refinement), the engineering fleet (executor), and Scribe (evidence ledgers and content).

GitHub reference: the 43 open issues of `lebobo88/lizbeth-spanish` listed in section 4.

Evidence labels: **Observed** means read at file level in the `88b43fd` worktree by Planner. **Inference** is a conclusion drawn from observations. **Assumption** is taken as true until a runtime step verifies it. **Unknown** is not yet established.

Judge accounting: `PLAN_DUCK` 1 used (shadow; findings J-001, J-002, J-003 accepted and remediated in revision 1); one repeat is available if the Orchestrator chooses (standard cap 2). `CODE_REVIEW` and `VISUAL_REVIEW` unused. Policy: shadow.

---

## Plan revision 1 (PLAN_DUCK shadow, advisory; user decisions received)

`PLAN_DUCK` #1 (Codex, shadow) returned findings J-001, J-002, and J-003, all accepted by Planner and remediated in this revision, applied once and in place. Status stays DRAFT and approval (D-1) is still required. Per-PR judge budgets are unchanged.

| ID | Disposition | Summary | Sections changed |
| --- | --- | --- | --- |
| J-001 | accepted | Exact commands and spec paths added to every acceptance block (full-suite requirements stay; targeted runs are additional, never substitutes). | 8 |
| J-002 | accepted | A standard browser validation block plus per-issue and per-cluster journeys with visible outcomes; later sub-plans must supply a complete block before approval. | 9, 6 (re-plan trigger) |
| J-003 | accepted | W1.0 baseline protocol replaced with PRE, MID, and POST fixture fingerprints so the baseline never relies on a mutated seeded account; credential isolation (#137) moved first in Wave 1. | 6 (Wave 1), 5.4, 8 |
| Grounding | accepted | Evidence now comes from a fresh detached worktree of `origin/main` `88b43fd` (replaces the earlier 222 reference checkout). | Header, 3 |
| Reconciliation | added | Per-issue progress reconciliation, a "Close now" list, re-ordered waves, and updated triage statuses. | 3.6, 3.7, 4, 6 |
| Decisions | updated | D-2, D-3, D-4, D-11 resolved; D-6 replaced; D-12 added. | 5.2, 5.3, 5.5, 10, 13 |

User decisions received (relayed by Planner; recorded here, not independently confirmed by Scribe):

| Decision | Recorded outcome |
| --- | --- |
| Direction | The user believes only #224 to #228 still need work. Planner's per-issue verification does not bear that out: 5 issues are closable now, 5 more need only a baseline run to confirm, and the rest have open work with source evidence (section 3.6). The user pre-authorized closing verified-finished issues (the lead executes). Follow the normal per-issue routine, diagnose root causes, plan fixes that achieve each issue's intent rather than its literal proposal, and establish an implementation order. |
| D-1 | Revision requested (this revision). Approval is still required. |
| D-2 | RESOLVED as recommended: disabled is hidden; a stored ES override wins; if there is no custom EN, `default.es`; else the custom EN; else `default.en`. |
| D-3 | RESOLVED: use "tu profesora". The Spanish drafts are accepted as written by the user. The PR body lists them for optional owner refinement. It is no longer a merge gate. |
| D-4 | RESOLVED: test-only helper, no database or migration change. |
| D-5 | Planner recommendation recorded (section 5.5); awaiting the user. |
| D-6 | Replaced by the "Close now" list (user pre-authorized) and the "close after W1.0 baseline" list (section 3.7). |
| D-11 | APPROVED: #206 item 5 (move focus to the first invalid field). Verification shows it is not already done (section 3.6). |

---

## 1. Outcome

Every one of the 43 open issues is triaged with evidence, grouped into waves, and lands in exactly one of three states:

- (a) resolved by a reviewed pull request against `main` whose body contains `Closes #n`;
- (b) closed or proposed for closure with evidence (verified-finished issues the user pre-authorized the lead to close now; the rest after a baseline run, for the user to confirm);
- (c) parked as an explicit user decision.

This plan authorizes execution of Wave 0 closures, Wave 1 (test-infrastructure health), and Wave 2a (sign-in cluster #224, #225, #226) at full depth. Waves 2b, 3, 3b, 4, and 5 are triaged here with acceptance intent only. A mandatory re-plan (section 6, "Re-plan trigger") must produce an approved sub-plan before any of them starts.

## 2. Scope and non-goals

### Binding delivery policy (user-authorized)

- Never commit or push to `main`.
- One feature branch per issue (or an explicitly justified coupled cluster), created from the then-current `origin/main` in a fresh worktree.
- Push the branch to `origin` and open a pull request against `main`. PRs stay open. No agent merges. The user approves and merges.
- Each PR body contains `Closes #<n>` for every issue it resolves, so issues close on the user's merge. Agents never close a PR-resolved issue manually before merge.
- Issues resolvable without code get closure comments with evidence. The user pre-authorized the Wave 0 closures (section 3.7); every other no-code closure waits for the user's confirmation. The lead performs closures.
- No production deploys, Netlify actions, hosted database or content writes, or hosted read checks that need credentials without separate explicit user approval.

### Per-issue gates

T1 writer (TDD), then Codex `CODE_REVIEW` where eligible, then Verifier (independent), then Browser Validator for browser-rendered UI, then applicable judge gates, then PR opened. Two counted T1 gate failures escalate to T2. Two counted T2 failures block for user review.

### In scope

- Triage of all 43 issues (section 4) and the progress reconciliation (section 3.6).
- Wave 0 closures, Wave 1, and Wave 2a at full execution depth.
- Wave 2b (#140/#183 cluster, #227, #228) and Waves 3 to 5 at triage-plus-acceptance-intent depth.

### Non-goals

- Production releases.
- A new self-service password reset, or public signup.
- Replacing `PublicContentProvider` or adding a second locale state.
- Changing the admin English-only policy.
- Weakening, skipping, or deleting any assertion to reach green.
- Inventing a first-login profile or provisioning trigger (#228).
- Hosted grant changes (#190) without approval.

## 3. Repository findings (evidence)

All Observed unless labeled. Paths are relative to the `88b43fd` worktree `lizbeth_spanish-main-88b`.

### 3.1 Tooling and baseline

- `package.json` scripts: `dev` = vite, `build` = `tsc && vite build`, `test` = vitest, `test:e2e` = playwright test, `lint`, `type-check` = `tsc --noEmit`, `verify:build`, `check:practice-complete`, `check:quiz-complete`, `check:answer-leak`.
- `playwright.config.ts`: `testDir` `src/__tests__/e2e`, workers 1, baseURL `E2E_BASE_URL` or `http://localhost:8888` (a `netlify serve` webServer when unset), chromium only.
- `vitest.config.ts:32-43` sets `fileParallelism: false`.
- #222 evidence (`docs/evidence/lizbeth-spanish-prod-issue222-20261007.md` in the orchestrator repo): on a fresh `db reset`, the full `src/__tests__` run gave 4779 passed and 4 skipped, with one unrelated failure, `fieldJournalTokens` (needs a parent-directory config present only in a full checkout). Treat it as a known baseline item.

### 3.2 Additional detail carried from the original triage

Per-issue status and evidence are in section 3.6. These details are not repeated there.

- **#82 / #139.** `rlsIntegration.test.ts` reads the actual `enrollment_date` for some assertions (about lines 269 to 314). Drift manifests only on databases older than about 2 days. The student4 Beginner "5 days" scenario comment is at `seed.sql:417-421`.
- **#137.** `LOCAL_TEST_PASSWORD` is at `LoginForm.tsx:31`.
- **#183.** The generic `ownershipFailure` is at `course-authoring/index.ts:115-123`; the `list_enrollment_requests` handler (`index.ts:265-266`) filters by `cohorts.owner_id` and ignores `course_id`.
- **#202.** The Edge action `index.ts:500-503` passes lessons through unchanged.
- **#210.** `lessonTaskData.ts:130-145` is a keepalive fetch; `LessonTaskLeaveGuard.tsx:22` records an accepted limit.
- **#212.** `tools/lesson-generation` is a gitignored nested repo with separate history (`.gitignore:44-54`).
- **#191.** Earlier line references moved; T1 locates the legend at Step 0 (current hard-coded text at `BandRoadmap.tsx:246`).

### 3.3 Sign-in surface (Wave 2a)

- `LoginForm.tsx`: hard-coded "Sign in" (:98), "Email" (:109), "Password" (:121), "Open my journal" / "Signing in…" (:135), empty-email message (:65), focus-to-alert (:56-60), DEV quick-select (:139-162).
- `App.tsx`: `AuthBrandPanel` (:653-712) with `LanguageToggle` variant `on-dark` (:665); `AuthGate` early returns (:714-740) with English "Loading…" (:737); session-error card "Retry" (:777-779); `LoginForm` mount (:798); provider nesting `PublicContentProvider > AuthProvider > AuthGate` (:816-818).
- `AuthContext.tsx`: `getSignInErrorMessage` (:34-57, uses "instructor" wording); session-error string (:121-123); `setError(null)` (:151).
- `PublicContentContext.tsx`: single locale state, key `lizbeth.siteLanguage` (:23), admin forced English (:58-92), `html lang` (:120-122).
- `siteContentRegistry.ts`: `default: { en }` only, comment at :7 "Spanish defaults do not exist", `signin` keys (:83-160), `fallbackH1` 'Sign in' (:110). The registry is Deno-imported by the `site-content` Edge Function.
- `siteContentResolve.ts` :38-47: ES override, then EN override, then `default.en`.
- `SiteText.tsx` :41-43: English fallback h1.
- `LanguageToggle.tsx` :21-27: `aria-label` "Site language"; only Español has `lang="es"`.
- `Field.tsx` :92-98: spreads `...rest` after `aria-describedby`.

### 3.4 Prior design identity (binding)

Studio "Field Workbook" from `docs/plans/lizbeth-spanish-course-platform.md` sections 4.2, 4.5, and 8; sign-in design from `docs/plans/lizbeth-spanish-issue37-login-signin-screen.md`; site text from `docs/plans/lizbeth-spanish-issue177-owner-editable-site-text.md`.

### 3.5 Research status

Research evidence: none. Research not needed for this plan pass (local source evidence suffices; issue bodies are already source-grounded). Research triggers are recorded for #190 (current Supabase default-privilege guidance), #210 (keepalive, sendBeacon, and pagehide semantics with auth headers), and #228 (Auth Admin idempotency behavior) at their re-plans.

### 3.6 Reconciliation of actual progress

Lead-supplied cross-reference (66 merged PRs, 384 main commits): merged PRs mention only #48 (PRs #77, #78), #82 and #139 (PRs #141 to #149, cited as known-baseline references, not fixes), #166 and #170 (PR #171 release evidence), and #218 (PR #217 records the 10 failures). No issue has a GitHub comment, so status rests on the source and test evidence below.

Statuses: DONE (closable now), PARTIAL, OPEN, NOT-A-BUG, NEEDS-RUNTIME-CONFIRMATION.

| Issue | Status | Evidence | Remaining work / fold-in |
| --- | --- | --- | --- |
| #228 | OPEN | Observed: `RegisterStudentModal` and `registerStudent` are email-only; no combined create-and-assign operation exists. The reported first-login dependency is Unknown. | Disposable local or staging repro, then the #228 sub-plan (Wave 2b-2). |
| #227 | OPEN | Observed: `SiteContentFields` maps absent values to '' and shows no effective text; `BrandDesignPage` has a static preview (per the issue's links; `88b43fd` is the issue's own inspected commit). | #227 sub-plan (Wave 2b-1). |
| #226 | OPEN | Observed: `LoginForm.tsx:94-163` has no account-access copy. | Wave 2a. |
| #225 | OPEN | Observed: no recovery or help entry in `LoginForm.tsx`. | Wave 2a. |
| #224 | OPEN | Observed: `LoginForm.tsx:98,109,121,135` hard-coded English; `siteContentRegistry.ts:7` "Spanish defaults do not exist". | Wave 2a. |
| #218 | OPEN | Observed: the issue body (full run) lists 10 failures in `gap-1-owner-settings-persistence`, `issue-3-feedback-inbox`, `issue-50-asset-card-grid` (3), `issue-54-header-nav-reachability` (2), `issue-55-form-controls-ds-chrome` (2), `wp4-roster`, and `wp5-feedback-inbox`; PR #217 confirms they remain. | W1.4; the PR also carries `Closes #79`. |
| #215 | OPEN | Owner decision (D-9). | Wave 4 after D-9. |
| #214 | OPEN | Observed: `curriculum/lessons/intermediate-week-17/phrases-and-qa.md:180` still contains the leaked "substitute prompt" authoring note. | Wave 4. |
| #212 | OPEN | Observed: nested repo `lizbeth_spanish/tools/lesson-generation/generate_lesson_ts.py:392` `parse_quiz` regex matches only `**Answer:**` (no `**Answer (label):**` or `**Model answer:**`). The nested repo is gitignored and exists only in the main checkout. | Wave 4; export via `scripts/export-tooling-patches.ts`. |
| #210 | NEEDS-RUNTIME-CONFIRMATION | Observed: `useLessonTask.tsx:437-460` already flushes via keepalive on `pagehide`, `visibilitychange` hidden, and unmount (:458-459); the header comment at :36-38 still records "Back, Forward and unmount can lose up to the debounce window". Inference (root-cause hypothesis): the unmount keepalive can carry a stale revision when a debounced or in-flight save has not returned, or is skipped when dirty was cleared optimistically. | Reproduce before fixing (W1.0); fix in Wave 3 only if loss reproduces. |
| #209 | OPEN | Inference, with repro in the fix PR. Observed: `LessonTaskBar.tsx:152-167` `saveLine` shows "Draft saved at {time}" whenever `saveState==='saved'` and `!readOnly`, including the RETURNED state (not read-only) from the prior draft time; the reviewed state depends on `readOnly`. | Wave 3. |
| #208 | OPEN | Observed: no `lesson_task.*` keys in `siteContentRegistry.ts` (0 matches). | Wave 3b. |
| #206 | OPEN | Items 1, 2, and 5 Observed; items 3 and 4 are visual, confirm at runtime. `OwnerSubmissionDetailPage.tsx:136` declares `headingRef` and :226 attaches it with `tabIndex -1`, but no effect ever focuses it on navigation (item 2). "Jump to review" (:214) targets the `ReviewForm.tsx:129` section, which has no `tabIndex`, so focus does not land (item 1). `ReviewForm.tsx:90-92` returns on validation failure after `setErrors` without moving focus (item 5, change approved under D-11). The belief that #206 is complete is not supported. | Wave 3 (first). |
| #203 | PARTIAL | Observed: the golden update procedure lives only in `src/__tests__/vocabReviewLang.test.ts`; no owner checklist document exists; the orchestrator evidence `docs/evidence/lizbeth-spanish-prod-stage{A,B,C,D}-2026100{6,7}.md` records the owner 5-recap spot-check as still outstanding. | Wave 4: Scribe checklist plus owner sign-off (D-12). |
| #202 | OPEN | Observed: `save_outline` last defined in `supabase/migrations/202608300001_issue5_phase2_cadence_sql_core.sql:429`; no later redefinition preserves `legacy_lesson_id`. | Wave 3. |
| #201 | NEEDS-RUNTIME-CONFIRMATION | Flake vs defect; `src/__tests__/e2e/issue174-handout-links.spec.ts` J8. | W1.0 five warm runs; W1.6 only if a real defect. |
| #199 | OPEN | Observed: `ResourcesPanel.css:134-145` stacks the type label only for `.resources-panel--embedded`; the rail variant is unchanged. | Wave 3. |
| #198 | OPEN | Inference: no migration after the issue date touches the legacy date vs entitlement rules or the storage RLS held/revoked rules. | Wave 3 sub-plan (high risk). |
| #197 | NOT-A-BUG | Observed chain: `courseAuthoring.ts:115` `getCourse` returns `{ id: version.id, course_id: courseId }`; `CourseWorkspacePage.tsx:108` renders `<Publishing courseId={course.id}>` (a version id); :1141 filters publish jobs by `row.course_version_id === courseId`, confirming the prop carries a version id; :1148 `uploadGeneratedAsset(courseId, ...)` therefore passes the version id that `courseAuthoring.ts:128` expects. The prop name is misleading only. | Close now. Optional rename folded into the #140/#183 PR. |
| #196 | OPEN | Feature. | Wave 5 sub-plan. |
| #194 | OPEN | Consistency audit needed; disclaimers exist in 46 Advanced files with varying wording. | Wave 4. |
| #193 | OPEN | Observed: all 78 `curriculum/lessons/*/phrases-and-qa.md` still begin "Audience: the instructor delivering this lesson". | Wave 4 sub-plan. |
| #191 | OPEN | Observed: `BandRoadmap.tsx:246` hard-coded "SOLID = COMPLETE · HATCHED = IN HAND". | Wave 3b. |
| #190 | OPEN (local) | Observed: no migration revokes TRUNCATE, REFERENCES, or TRIGGER or alters default privileges for anon or authenticated on tables. Hosted state Unknown (user-gated check). | Wave 3 local migration; hosted steps need D-10. |
| #189 | OPEN | Observed: `AdminShell.css:186` `.admin-masthead-eyebrow { color: var(--color-brass-500) }`; `tokens/primitives.json:28` documents brass.500 as failing AA for text. | Wave 3. |
| #188 | OPEN | Decision D-8. | Wave 3b if pursued. |
| #187 | OPEN | Observed: `PublicContentContext.tsx:43-50` defaults to 'en'; no owner setting. | Wave 3b. |
| #186 | OPEN | Observed: `DEFAULT_META_DESCRIPTION` "Phase 0 Scaffold" in `siteContentRegistry.ts:52` and `index.html`. | Wave 3b after D-7. |
| #183 | OPEN | Observed: `CourseWorkspacePage.tsx:108` `<Students courseId={course.id}>` (version id), then `:715` `listEnrollmentRequests`, then `courseAuthoring.ts:67` `{course_id}`, then `course-authoring/index.ts:115-123` generic `ownershipFailure` treats it as a course id and returns 404; the handler at :265-266 never uses `course_id`. | Wave 2b-0. |
| #170 | DONE | Observed: `wp8-course-workspace.spec.ts` self-provisions the fixture (:86, :168, :249) and tears it down in `test.afterAll` (:252); PR #171 recorded release evidence for #170; PR #200 body records wp8 passing in a regression run. | Close now. |
| #166 | NEEDS-RUNTIME-CONFIRMATION | Observed: `browser-validation-status-clarity-and-gate.spec.ts:132-149` Journey 1 now reads seeded `student7` (`seed.sql:69-76`, `last_sign_in_at` NULL) instead of the timestamped row; PR #171 recorded "#166 Chromium 4/4". Recommend accept (D-5). | Close after W1.0 shows two consecutive passes without reset. |
| #150 | OPEN | Observed: `App.tsx:136` vs `ContextStatusStrip.tsx:99`. | Wave 3. |
| #148 | DONE | Observed: the malformed stub is absent from `package-lock.json`; PR #147 (merged 2026-09-09) removed it and verified `npm ci --dry-run`; the repo has no `.github` workflows, so there is no CI to re-check. | Close now. |
| #140 | OPEN | Observed: `courseAuthoring.ts:115` picks draft-else-latest version; `CourseWorkspacePage.tsx:513,530` `StudentRoster` returns null unless published. | Wave 2b-0. |
| #139, #82 | OPEN (one cluster) | Observed: `supabase/seed.sql` still uses `now()`-relative offsets (33 occurrences); no fixture-date helper exists; PRs #141 to #149 only cite them as known baseline failures. | W1.3. |
| #137 | PARTIAL | Observed: `browser-validation-status-clarity-and-gate.spec.ts:18-91` now restores `student1` (password) and `student2` (`force_password_change`) in `afterAll` with a verified sign-in probe and a hard-coded loopback URL guard; rotation journeys now use `student1`. Remaining: restoration is per-spec only and skipped if the run is killed; ad hoc Browser Validator rotation journeys have no guard; shared seeded accounts are still mutated mid-run. | W1.1. |
| #81 | PARTIAL | Observed: `issue5EdgeSmoke.test.ts:68-81` `finally` deletes the clone, but the clone and `save_outline` happen at :30-53 BEFORE the `try` at :56, so any assertion failure between :31 and :52 skips cleanup (the issue's acceptance requires cleanup even on mid-test failure); the delete targets `course_versions` only, so the 'HTTP draft edit' `lesson_revisions` row may remain (verify cascade). | W1.2. |
| #80 | DONE | Observed: spec :263 uses `'text=/Roadmap|Lesson \\d/i'` with a :264 count assertion and no skip or fixme; #218's full-run failure list excludes this spec (so the assertion executed and passed); PR #171 records repaired browser E2E 27/27. | Close now. |
| #79 | PARTIAL | Observed: 31 spec and fixture files now target "Open my journal", but #218 shows `issue-3-feedback-inbox` still fails waiting for `input[type=email]` (a sign-in-surface step). | Remaining work is inside #218; the #218 PR also carries `Closes #79`. |
| #63 | DONE | Observed: `WeekCard.tsx:116-183` "Review week N" and "Open week N" share `onOpen`; `neo-workbook-visual-smoke.spec.ts:169-171` clicks `/^(Open|Review) week 1$/` for `student1` (week 1 completed) and asserts the heading "Week 1"; `WeekCard.test.tsx:203` covers the label. | Close now. |
| #53 | OPEN | Observed: `CourseWorkspacePage.tsx:1148` "Finalize publish" Control has no disabled, in-flight, or published state after success (only a status message). | Wave 3. |
| #48 | PARTIAL | Observed: item 3 (parallel-load 401s) is addressed by `vitest.config.ts:32-43` `fileParallelism: false`; item 1's assertion harm is addressed by `rlsIntegration.test.ts:25-39` scoping to `SEEDED_TEST_USERS`; disposable-account cleanup exists in 5 files. Remaining NEEDS-RUNTIME-CONFIRMATION: `auth.users` growth and `student1` double-enrollment across consecutive full runs. | W1.0 counts; W1.5 only if growth or double-enrollment shows. |

### 3.7 Closures without code

**Close now** (user pre-authorized, relayed by Planner; the lead posts the comment and closes; no PR):

- **#63.** "Verified on main 88b43fd: 'Review week N' uses the same onOpen handler as 'Open week N' (WeekCard.tsx:116-183), and neo-workbook-visual-smoke.spec.ts:169-171 clicks 'Review week 1' for a completed week and asserts the Week 1 detail heading. Closing as fixed."
- **#80.** "Verified on main 88b43fd: the leak selector is 'text=/Roadmap|Lesson \\d/i' (browser-validation-status-clarity-and-gate.spec.ts:263) with no skip, and the full e2e run recorded in #218 shows this spec passing after the sign-in helper repair (PR #171: browser E2E 27/27). The assertion now executes. Closing."
- **#148.** "Verified on main 88b43fd: the malformed @floating-ui/dom stub is gone from package-lock.json (fixed in PR #147, which verified npm ci). The repo has no GitHub Actions CI to re-check. Closing as fixed."
- **#170.** "Verified on main 88b43fd: wp8-course-workspace.spec.ts self-provisions its published fixture course (lines 86, 168, 249) and tears it down in afterAll (line 252); release evidence in PR #171 and the regression run in PR #200. Closing as fixed."
- **#197.** "Not a bug. getCourse() returns the version id as course.id (courseAuthoring.ts:115), so Publishing's courseId prop is a version id (CourseWorkspacePage.tsx:108; publish jobs filtered by course_version_id === courseId at :1141), and uploadGeneratedAsset receives the version id it expects. The prop name is misleading; a rename is folded into the #140/#183 fix. Closing."

**Close after the W1.0 baseline confirms** (the lead closes with the baseline evidence):

- #166: two consecutive passes without reset (D-5).
- #48: only if the `auth.users` count and `student1` enrollment stay stable over two full runs; otherwise a W1 fix.
- #201: only if J8 is proven stable over 5 warm runs and the failure was environmental; otherwise a fix.
- #210: only if the deterministic repro shows no loss; otherwise a fix.

This supersedes the earlier ruling that #197 closure waits for the Wave 2b-0 regression test. The source chain above is the evidence; the rename rides in the #140/#183 PR.

## 4. Triage of all 43 open issues

Waves: 0 closures without code; 1 test-infrastructure health; 2a sign-in cluster; 2b course/version-id cluster plus #227 and #228; 3 bugs, accessibility, security; 3b owner-editable copy extensions (after #227); 4 content and curriculum; 5 backlog. Status values follow section 3.6; evidence detail is there.

| Issue | Title (short) | Type | Wave | Status | Evidence / root cause | Dependencies |
| --- | --- | --- | --- | --- | --- | --- |
| #228 | Owner creates student and assigns courses before first login | Feature (backend, SQL, Edge) | 2b-2 | OPEN; high risk; dedicated sub-plan required | No combined create-and-assign operation; the reported first-login dependency is Unknown (repro required) | After #140/#183; preserve #222 grants, #176, #198 semantics |
| #227 | Site-copy editor: effective text and placement previews, clearer visibility toggles | Feature / UI | 2b-1 | OPEN; sub-plan and Standard design | Raw overrides only, resolver unused by the editor, metadata lightly exposed, static brand preview, subtle toggle | After #224 (registry `default.es`, `fallbackH1Es`, `sourceLang`) |
| #226 | Sign-in: teacher-provided access explanation | UX / content / a11y | 2a | OPEN | No account-access copy in `LoginForm.tsx` | Coupled with #224, #225 |
| #225 | Sign-in: password-recovery guidance | UX / content / a11y | 2a | OPEN | No recovery or help entry; backend is not broken | Coupled with #224, #226 |
| #224 | Español leaves sign-in copy in English | Bug (i18n coverage) | 2a | OPEN | Functional copy hard-coded; registry has no ES defaults; toggle works | Coupled with #225, #226 |
| #218 | 10 pre-existing failing e2e tests across 7 specs | Test-infra bug | 1 (W1.4) | OPEN | Issue lists the 10 failures; PR #217 confirms | After W1.0 and W1.1; carries `Closes #79` |
| #215 | Reduce teacher-graded share (advanced 77%) | Content decision | 4 | OPEN; needs D-9 | n/a | #180 |
| #214 | Curriculum source defects (7 items) | Content | 4 | OPEN | Leaked authoring note at `intermediate-week-17/phrases-and-qa.md:180` | #180 quiz files |
| #212 | Nested `parse_quiz` variants | Tooling | 4 | OPEN; only if the nested repo is present | `generate_lesson_ts.py:392` matches only `**Answer:**` | None |
| #210 | Flush task draft on Back/Forward/unmount | Bug / reliability | 3 | NEEDS-RUNTIME-CONFIRMATION | Keepalive already present at `useLessonTask.tsx:437-460`; hypothesis: stale revision or optimistic dirty clear | W1.0 repro; no `beforeunload` prompts |
| #209 | "Draft saved" under REVIEWED/RETURNED chips | UI bug | 3 | OPEN | `LessonTaskBar.tsx:152-167` `saveLine` | Wave 3 UI micro-batch |
| #208 | `lesson_task.*` keys into the owner-editable registry (ES option) | Feature | 3b | OPEN | No `lesson_task.*` keys in the registry | After #224, #227 |
| #206 | Owner submission review a11y and layout polish (5 items) | A11y | 3 (first) | OPEN; item 5 approved (D-11) | Items 1, 2, 5 Observed in `OwnerSubmissionDetailPage.tsx` and `ReviewForm.tsx` | Wave 3 UI micro-batch |
| #203 | Vocabulary recap Spanish spot-check checklist and golden procedure | Document / process | 4 | PARTIAL | Golden procedure only in a test file; owner spot-check outstanding per stage A to D evidence | Lizbeth sign-off (D-12) |
| #202 | `save_outline` drops `legacy_lesson_id` | Bug (SQL) | 3 | OPEN | Unchanged since `202608300001` | Migration; `CODE_REVIEW` |
| #201 | Handout-links J8 Tab focus at 390 | Test-infra / a11y | 1 (W1.6, conditional) | NEEDS-RUNTIME-CONFIRMATION | Flake vs defect | W1.0 five warm runs |
| #199 | Roadmap rail FLASHCARDS overflow at 1440 | UI bug | 3 | OPEN | `ResourcesPanel.css:134-145` stacks the label only for the embedded variant | Wave 3 UI micro-batch |
| #198 | Reconcile legacy date rule with entitlement rule (+ storage RLS ignores held/revoked) | Security / data access | 3 | OPEN; dedicated sub-plan, high risk | Inference: no later migration touches it | Hosted apply needs D-10; interacts with #228 |
| #197 | Publishing export passes course id where version id is expected | Suspected bug | 0 | NOT-A-BUG; close now | `course.id` is the version id; prop name misleading | Rename folded into #140/#183 PR |
| #196 | Per-lesson authored handout generation | Feature | 5 | OPEN; sub-plan and Standard design | Issue | #174 delivery path |
| #194 | Legal/financial disclaimer consistency (Advanced) | Content | 4 | OPEN | Disclaimers in 46 Advanced files with varying wording | #178 |
| #193 | Align sibling lesson files with self-paced practice and regenerate handouts | Content (large) | 4 | OPEN; dedicated sub-plan | All 78 files still begin "Audience: the instructor..." | #178; handout regeneration |
| #191 | `BandRoadmap` legend is not a `site_content` key | Feature | 3b | OPEN | `BandRoadmap.tsx:246` hard-coded | After #227 |
| #190 | Default grants give anon/authenticated TRUNCATE/REFERENCES/TRIGGER | Security hygiene | 3 | OPEN (local); hosted check and apply need D-10 | No revoking migration; hosted state Unknown | #222 precedent; research trigger at re-plan |
| #189 | Admin masthead eyebrow contrast 4.06:1 | A11y bug | 3 | OPEN | `AdminShell.css:186` brass-500 | Wave 3 UI micro-batch |
| #188 | Decorative L logo mark editable key | Feature | 3b | OPEN; needs D-8 | Issue | Registry |
| #187 | Owner-set default language for first-time visitors | Feature | 3b | OPEN | `PublicContentContext.tsx:43-50` defaults to 'en' | After #224 |
| #186 | New meta description wording | Content / config | 3b | OPEN; needs D-7 | `DEFAULT_META_DESCRIPTION` "Phase 0 Scaffold" (`siteContentRegistry.ts:52`, `index.html`) | Registry and `index.html` |
| #183 | `list_enrollment_requests` 404 on Students tab | Bug | 2b-0 | OPEN; root cause Observed | Version id sent as `course_id` hits the generic ownership 404 | Coupled with #140 |
| #170 | wp8 non-seeded fixture course | Test-infra | 0 | DONE; close now | Self-provisioning and `afterAll` teardown present | None |
| #166 | status-clarity Journey 1 timestamped row | Test-infra | 1 (W1.0 confirm) | NEEDS-RUNTIME-CONFIRMATION; recommend accept (D-5) | Journey 1 reads seeded `student7` | W1.0 two-run check; guard in W1.1 |
| #150 | `isRoadmapRoute` divergence | UI bug | 3 | OPEN | `App.tsx:136` vs `ContextStatusStrip.tsx:99` | None |
| #148 | Lockfile corruption | Infra | 0 | DONE; close now | Stub absent; PR #147 | None |
| #140 | Students roster unreachable with newer non-published version | Bug | 2b-0 | OPEN; root cause Observed | `getCourse` version resolution plus published gate | Coupled with #183 |
| #139 | Seeded relative dates drift | Test-infra | 1 (W1.3) | OPEN; coupled with #82 | Seed `now()`-relative | #82 |
| #137 | Re-issue validation mutates `student2` | Test-infra | 1 (W1.1) | PARTIAL | Per-spec restore only; shared accounts mutated mid-run | First in Wave 1 (J-003) |
| #82 | Seed anchors to `now()` | Test-infra | 1 (W1.3) | OPEN; primary of the #82/#139 cluster | As above | #139 |
| #81 | `issue5EdgeSmoke` leaks draft version | Test-infra | 1 (W1.2) | PARTIAL | Clone created before the `try`; cleanup skipped on mid-test failure | None |
| #80 | Forced-password leak assertion blind | Test-infra / security test | 0 | DONE; close now | Spec :263 selector, no skip; spec passes in the #218 run | None |
| #79 | e2e sign-in helper targets removed label | Test-infra | 1 (inside W1.4) | PARTIAL | 31 files fixed; `issue-3-feedback-inbox` still fails | Closed by the #218 PR |
| #63 | "Review week 1" does not navigate | UI bug | 0 | DONE; close now | Shared `onOpen`; smoke spec asserts the Week 1 heading | None |
| #53 | Finalize publish button not self-disabling | UI enhancement | 3 | OPEN | `CourseWorkspacePage.tsx:1148` | Wave 3 UI micro-batch |
| #48 | Remaining test-suite pollution | Test-infra | 1 (W1.5, conditional) | PARTIAL | Items 1 (assertion harm) and 3 addressed; growth and double-enrollment need runtime confirmation | W1.0 counts; #137 |

## 5. Design route, judge route, and decisions

### 5.1 Design route

- **Wave 2a (#224, #225, #226).** `DESIGN_ROUTE` profile compact. Reasons: bounded brownfield change to one existing screen. Agents: design-generalist and design-reviewer. Prototype forbidden. Model sonnet. `existing_system_mode`: preserve. Result: compact passed (one evidence-backed revision, then PASS). The reviewed handoff is in section 5.2.
- **Wave 1.** Design none (test infrastructure). The #218 header-overlap item restores the existing approved #54 design; Browser Validator required.
- **Wave 2b.** #227 standard (director, UX, visual, reviewer; no prototype) at its sub-plan. #228 standard at its sub-plan. #140/#183 none unless the Students-tab affordance changes visibly (then compact).
- **Wave 3 UI micro-batch (#53, #189, #199, #206, #209, #150).** One compact design job at re-plan (token choice for #189, the #53 state label; the #206 item 5 decision is already approved under D-11). #187, #188, #191, #208: compact or standard at re-plan, after #227.
- **Waves 4 and 5.** None for content. #196 standard.

### 5.2 Wave 2a design handoff (compact, passed)

#### Selected direction

Field Workbook bilingual note card. Keep the existing sign-in card and add one static, non-interactive help note under the submit button. All functional copy comes from a fixed, compile-checked EN/ES map. No new screen, token, modal, disclosure, link, or native dialog.

#### Design brief

Audience: teacher-invited students, many of them Spanish speakers, often on mobile.

- **#224.** The whole signed-out surface follows the toggle: card text (`LoginForm.tsx:65,98,109,121,135`), Retry (`App.tsx:777-779`), "Loading…" (`App.tsx:737`), `AuthContext` error strings, and the editable `signin.*` keys, which lack Spanish.
- **#225 and #226.** One persistent help note: the teacher provides the account and re-issues access; nothing is self-serve and nothing is emailed.
- **Identity.** Preserve Field Workbook (paper-50 card, Plex Mono label, dashed hairline rule, brass-700 label, ink text). No icon, color, shadow, or motion.
- **Why static inline text.** Chosen over a modal, disclosure, or "Forgot password?" link: it is visible with no interaction, needs no focus management or extra tab stop, implies no self-serve path, and keeps one primary action.
- **Copy location.** Help copy is fixed functional copy in a new `src/lib/signInCopy.ts` (`getSignInCopy(lang)`), not an owner-editable key. Functional labels can never be disabled. `lessonTaskCopy.ts` is precedent for location and non-editability only.
- **Wording.** "instructor" is aligned to "teacher" in the `AuthContext` strings. The English submit label stays exactly "Open my journal".

#### UX journeys

- J1. A first-time visitor learns that the teacher creates the account.
- J2. Forgot or never received: the visitor is told to ask the teacher to set up access again. No request is sent.
- J3. EN/ES switch: all signed-out copy changes, `html lang` changes, focus stays on the pressed toggle, and the choice persists in `lizbeth.siteLanguage`.
- J4. An alert is visible, then the visitor toggles: the alert re-renders, focus stays on the toggle, and the typed email is preserved.
- J5. The session-error message and Retry follow the language.
- J6. The initial session-check "Loading…" follows the persisted language.
- J7. With `signin.heading` disabled, the structural h1 is localized ("Sign in" / "Iniciar sesión").

#### Information architecture

Card order:

1. `signin.card_eyebrow` (at 900px and wider).
2. h2 "Sign in".
3. Conditional `role=alert`.
4. Form: Email, Password, single primary submit.
5. Help note: a lead `<p>` plus a body paragraph with id `login-help-body`, static.
6. DEV quick-select, unchanged and English.

The lead is a styled `<p>`, not a heading. Optional `aria-describedby="login-help-body"` goes on Password ONLY, never on Email, because the `Field.tsx:92-98` spread would override the error id. Error messages say only "contact your teacher" (no duplicated instruction).

#### Contract

- `type SignInErrorKind = 'invalid_credentials' | 'email_not_confirmed' | 'generic'`.
- `AuthContext` `error: SignInErrorKind | null`; `sessionError: 'session_load_failed' | null`; `LoginFormProps.error: SignInErrorKind | null`; `LoginForm` local `emailError: 'email_required' | null`.
- Display text is derived at render by `getSignInCopy(lang)` via `useSiteLanguage`. No translated text lives in state.
- Mapping is EXACTLY the existing switch at `AuthContext.tsx:34-57`: `invalid_grant` maps to `invalid_credentials`; `email_not_confirmed` maps to `email_not_confirmed`; any other or missing value maps to `generic`. No new branches.
- Keep `setError(null)` at `AuthContext.tsx:151`.
- The focus effect is keyed on the error KIND arriving (null to kind, so consecutive same-kind failures refocus). A language switch never refocuses.

#### Strings (Spanish accepted by the user as written, D-3; tú register; "tu profesora")

The PR body lists the Spanish strings for optional owner (Lizbeth) refinement. Refinement is not a merge gate. Any edit applies on the same branch and is re-verified.

| Slot | EN | ES |
| --- | --- | --- |
| h2 / structural fallback h1 | Sign in | Iniciar sesión |
| Email label | Email | Correo electrónico |
| Password label | Password | Contraseña |
| Submit idle | Open my journal | Abrir mi diario |
| Submit loading | Signing in… | Entrando… |
| `email_required` | Please enter your email address. | Escribe tu correo electrónico. |
| `invalid_credentials` | That email or password isn't right. Please try again. | Ese correo o contraseña no es correcto. Inténtalo de nuevo. |
| `email_not_confirmed` | This account's email hasn't been confirmed yet. Contact your teacher to confirm it. | El correo de esta cuenta aún no está confirmado. Habla con tu profesora para que lo confirme. |
| `generic` | We couldn't sign you in. Please try again, or contact your teacher if this continues. | No pudimos iniciar tu sesión. Inténtalo de nuevo o habla con tu profesora si sigue pasando. |
| `session_load_failed` | Exact current English at `AuthContext.tsx:121-123` | No se pudo cargar tu sesión. Revisa tu conexión e inténtalo de nuevo. |
| Retry | Retry | Reintentar |
| Loading (`App.tsx:737`) | Loading… | Cargando… |
| Toggle aria-label | Site language | Idioma del sitio |
| Help lead | New here, or forgot your password? | ¿Es tu primera vez o olvidaste tu contraseña? |
| Help body | Your teacher creates your account and gives you your email and password. If you forgot your password or never received one, ask your teacher to set up your access again. Nothing is sent to you automatically. | Tu profesora crea tu cuenta y te da tu correo y tu contraseña. Si olvidaste tu contraseña o nunca la recibiste, pídele a tu profesora que te vuelva a dar acceso. No se envía nada automáticamente. |

Neutral alternative "tu docente" is not selected. Toggle button labels stay "English" / "Español". `lang="es"` stays on Español and `lang="en"` is added on English. The `aria-label` and `lang` change applies at all four `LanguageToggle` render sites (anonymous panel, `/courses`, authenticated header, mobile menu). `AuthGate` calls `useSiteLanguage` before any conditional return (`App.tsx:714-740`).

#### Editable `signin.*` Spanish built-in defaults (within `maxLength`)

- `signin.heading`: "Aprende \na cielo abierto"
- `signin.tagline_full`: "Setenta y ocho semanas de español, una página de cuaderno a la vez. Tu semana se abre cuando llegas a ella."
- `signin.tagline_short`: "Setenta y ocho semanas de español, una página de cuaderno a la vez."
- `signin.footer_levels`: "Principiante · Intermedio · Avanzado"
- `signin.footer_duration`: "78 semanas"
- `signin.card_eyebrow`: "Acceso"
- `brand.wordmark` and `brand.product_title` get no Spanish default.

Registry: optional `default.es`; optional `fallbackH1Es` only on `signin.heading` ("Iniciar sesión"), used by `SiteText` when the language is es. `resolveSiteText` returns an optional `sourceLang?: 'en'|'es'`; `SiteText` sets `lang="en"` only when es is requested and English text is returned. English resolution is unchanged; admin stays English-only; `resolveMetaText` keeps `default.en` (meta is out of scope).

#### Spanish resolution order (RESOLVED, D-2, as recommended)

1. Disabled: hidden.
2. A non-blank stored ES override wins.
3. If there is no custom EN (stored EN is blank or equals `default.en`): `default.es`.
4. Else the stored custom EN.
5. Else `default.en`.

Tradeoff accepted: this respects an owner who rewrote English, but a Spanish visitor still sees English on keys edited only in English.

#### Responsive behavior

- At 900px and wider: two columns, 460px card, eyebrow visible.
- Below 900px: single column, brand panel first, eyebrow hidden. At 390x844 the note is below the fold.
- The note is full card width, in normal flow, wraps, and uses `overflow-wrap:anywhere` (the `LoginForm.css:436-443` pattern). No horizontal scroll at 320.

#### Accessibility

The note has no control, link, or button and adds no tab stop. `html lang` matches. `role=alert` is kept. Contrast is at least 4.5:1. Forced-colors uses system colors. Nothing animates.

#### States

Idle (note visible); submitting (disabled, localized loading); empty email (inline, localized, focus email); server error (localized generic, no raw backend text); `email_not_confirmed`; session-error card (localized message plus Retry); initial loading (localized `role=status`); disabled heading (localized structural h1); language switch mid-error or mid-typing preserves values; DEV quick-select English.

#### Visual specification

- Lead: IBM Plex Mono `--font-size-label` / `--font-weight-label` (13px caption or larger permitted), brass-700 on paper-50 (5.65:1, `LoginForm.css:325-327`), sentence case, letter-spacing .08em, no uppercase.
- Body: `--font-size-body` (never below caption), `--font-line-height-body`, ink-900 (ink-700 only if at least 4.5:1).
- Placement: a block after `</form>` and before quick-select. `margin-top` `--space-6`, `padding-top` `--space-4`, `border-top` `--border-width-hairline` dashed `--color-ink-700` (copy the `.login-form-quick-select` rule at `LoginForm.css:370`). Lead margin `0 0 --space-2`; body margin 0.
- No new tokens. New classes: `.login-form-help`, `.login-form-help-lead`, `.login-form-help-body`. No new color literals, shadow, or tape. Keep the brass.300 / brass.700 AA corrections.

#### Engineering invariants

- No `alert`, `confirm`, `prompt`, `window.*` forms, or `beforeunload`. No new modal.
- Exactly one primary action.
- No `mailto`, URL, signup, or anonymous register or re-issue call. No invented support channel.
- Generic credentials wording never reveals which field is wrong.
- English "Email", "Password", "Sign in", and "Open my journal" stay exact.
- `getSignInCopy` is typed `Record<SignInLang, SignInCopy>` (a missing `es` is a compile error) and includes loading, retry, `session_load_failed`, and help.
- An EN/ES parity test exists.
- Admin stays forced English.

#### Required tests

- Two consecutive same-kind failures refocus the alert; a language switch does not refocus.
- Disabled `signin.heading` plus ES renders "Iniciar sesión".
- Resolution-order cases: ES present, ES missing, blank, disabled, custom EN only.
- `sourceLang` `lang="en"` cases.
- EN/ES parity.
- RTL test with `getSession` mocked as a deferred, never-resolving promise under language es, asserting `role=status` "Cargando…". This is the deterministic proof; the browser reload check is best-effort; add no new production test seam.
- In-scope test updates: `LoginForm.test.tsx:27`, `AuthContext.test.tsx:138`, `AuthContext-EmailNotConfirmed.test.tsx:70`, `step4b-email-not-confirmed-flow.test.tsx`, `adminStudentOperationsFixes.test.ts:594`, `App.test.tsx` ("instructor"), plus existing tests querying the group named "Site language".

#### Permitted variation and prohibitions

Permitted: naming; union vs enum; body token / ink-700 vs ink-900 if at least 4.5:1; optional Password `aria-describedby`; `section` vs `div` wrapper (no heading); owner-refined Spanish wording applied on the same branch.

Prohibited: a toggle, link, or modal for the help; a duplicated instruction; a "Forgot password?" link; a new color or shadow.

### 5.3 Design review

`DESIGN_REVIEW_RESULT` verdict PASS (re-review after one bounded revision). The first pass was NEEDS_REVISION with F1 to F3 (medium: error-code contract and test sweep; English structural fallback h1 under `lang=es`; English "Loading…" on reload) and F4 to F6 (low: lang-of-parts on fallback text; precedent wording; help-lead size and `aria-describedby` scoping). All were closed. Advisory N1 (low): prove "Cargando…" via an RTL deferred-`getSession` test; the browser reload check is best-effort.

Remaining limits from review:

- The Spanish strings were accepted by the user (D-3, "tu profesora"); "Entrando…" vs "Iniciando sesión…" stays available for optional owner refinement.
- The admin note "Leave blank to use the default" (`SiteContentFields.tsx:336`) is slightly imprecise for Spanish fields.
- Meta title and description keep `default.en`.
- With `sourceLang`, the wordmark and product title carry `lang="en"` in Spanish mode (harmless, visible in DOM assertions).
- `role=alert` may be re-announced on language switch (verify in the EN/ES a11y pass).
- DEV quick-select stays English.
- No real-device or screen-reader check occurred in static review.

### 5.4 Judge route (`docs/JUDGE-CONTRACT.md`; policy shadow)

- **Call budgets.** `PLAN_DUCK` for this batch plan: 1 call used (shadow); one repeat is available at the Orchestrator's choice (standard cap 2). Each Wave 1 and Wave 2a PR is a standard eligible task with at most 2 judge calls (`CODE_REVIEW`, plus one repeat after remediation); trivial single-file PRs skip judging. High-risk sub-plans (#228, #198, #190) set their own cap of at most 4.
- **`PLAN_DUCK` result.** Findings J-001, J-002, J-003 accepted and remediated in revision 1. Rubric `J-BATCH-PLAN`: the delivery policy never touches main and never closes a PR-resolved issue pre-merge; every closure is evidence-backed; no assertion-weakening path exists; Wave 2a design invariants are carried into acceptance; browser inputs are complete; all hosted actions are user-gated.
- **Wave 1.** `CODE_REVIEW` Luna/medium on the #137 credential-isolation PR (W1.1), the #82/#139 fixture-dating PR (W1.3), the #218 PR (W1.4), and the #48 PR if W1.5 proceeds (multi-file test infrastructure touching security-relevant RLS assertions and seeded credentials). Rubric `J-W1-TESTINTEGRITY`, extended for #137: no weakened, skipped, or deleted assertion; temporal pinning cannot mask an RLS regression; cleanup runs in `finally` or `afterAll`; no product-code test seams; no hosted URL; restore and guard code cannot touch non-loopback hosts; no seeded credential is left mutated. The #218 PR rubric also requires that each spec disposition is evidence-backed. Trivial single-file PRs skip judging.
- **Wave 2a.** `CODE_REVIEW` Terra/medium after `JOB_DONE`. Rubric `J-224-I18N`: error-kind contract and exact mapping, no raw backend text, focus behavior, resolution order matches the approved D-2, Edge `site-content` registry import compatibility, no native dialogs, no new network calls. `VISUAL_REVIEW` is not required (compact, preserve); optional only if the user requests it. Maximum 2 calls (standard).
- **Wave 2b and 3.** Sub-plans set their own judge routes. #228, #198, and #190 are high risk: `PLAN_DUCK` and `CODE_REVIEW` required.
- **Finding flow.** Finding IDs from any judge call are recorded in the PR's evidence summary, handed to T1 as remediation items, and re-checked by the Verifier. No judge pass is promised by this plan beyond the observed `PLAN_DUCK` result.

### 5.5 Decisions

Resolved or approved (recorded in "Plan revision 1"):

- **D-2.** Resolved as recommended (section 5.2).
- **D-3.** Resolved: "tu profesora"; drafts accepted as written; optional owner refinement via the PR body; not a merge gate.
- **D-4.** Resolved: test-only helper, no database or migration change.
- **D-6.** Replaced by the closure lists in section 3.7.
- **D-11.** Approved: #206 item 5.

Needed before approval or execution:

1. **D-1.** Approve this batch plan revision (Wave 0 closures, Wave 1, and Wave 2a execution; later waves only via re-plan). Approval is still required.
2. **D-5.** Accept #166's alternate fix (seeded read-only `student7`) and close after W1.0 confirms two consecutive passes without reset, or require literal self-provisioning. Planner recommendation: accept. Reasoning: the issue's need is a deterministic, reset-surviving Journey 1 that leaves no residue. Journey 1 only reads the pending-first-login state, so a reset-stable seeded fixture (`seed.sql:69-76`, `last_sign_in_at` NULL, zero enrollments) meets that need with no cleanup, and no test signs in as `student7` (only `rlsIntegration`'s `SEEDED_TEST_USERS` list and RLS-context queries reference it; `adminStudentOperationsFixes.test.ts:537` already moved its mutation off `student7`). Residual risk: a future test signing in as `student7` would silently destroy the pending state. Mitigation folded into the #137 PR (W1.1): Journey 1 asserts the precondition (`student7` `last_sign_in_at IS NULL` via the local admin API on `127.0.0.1`) and fails with an explicit fixture message, and a guard test asserts no spec signs in as `student7`.
3. **D-7.** New meta description wording (#186).
4. **D-8.** Whether to pursue #188 (logo mark editable key) at all.
5. **D-9.** Owner decision for #215 (convert yes/no meta items to true/false, drop course-structure meta items, or leave).
6. **D-10.** Hosted actions, each separately: #190 hosted grant read/verify and apply; any Netlify or Edge deploy of merged work; #228 and #198 hosted migrations.
7. **D-12 (new).** #203's owner (Lizbeth) spot-check of 5 recaps is an owner action outside engineering. Confirm that Scribe drafts the checklist and the owner records the sign-off.

## 6. Ordered work

Owner: engineering fleet, standard mode. T1 first line (TDD), Verifier after each PR's `JOB_DONE`, Browser Validator for any PR with a rendered UI change, T2 on two counted gate failures. Scribe writes evidence ledgers (`docs/evidence/lizbeth-spanish-issue-batch-2026-10-*.md` in the orchestrator repo) from engineering facts, and Wave 4 content.

Each PR: a new branch from the then-current `origin/main` in a fresh worktree `H:\CommandCenter\orchestrator\lizbeth_spanish-<issue>`. T1 commits on that branch only. After the gates pass, the lead pushes the branch and opens the PR against `main` with `Closes #n` lines, a test evidence summary, and the line "Do not merge without user approval"; never merge.

### Step 0. Preflight (T1, every PR)

1. `git fetch`, then create a fresh worktree from `origin/main` and record the SHA. If `origin/main` differs from `88b43fd`, re-verify every cited line and flag a stale plan if a cited behavior changed.
2. `npm ci`.
3. `npx supabase start` FROM the target worktree (the Edge runtime mounts the worktree that started the stack; otherwise run `npx supabase stop` and then start).
4. `npx supabase db reset`.
5. `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`.
6. Confirm 78 lessons and the seeded accounts.

### Wave 0. Closures without code (now)

The lead posts the closing comments in section 3.7 and closes #63, #80, #148, #170, and #197. User pre-authorized; no PR; no engineering work.

### Wave 1. Test-infrastructure health

Order: W1.0 baseline, W1.1 #137, W1.2 #81, W1.3 #82 and #139, W1.4 #218 (with #79), W1.5 #48 remainder (conditional), W1.6 #201 (conditional). No product behavior change except the #218 header overlap and #201 if they prove to be real defects.

**W1.0 Baseline and closure evidence** (no PR; T1 read and run only; Scribe writes `docs/evidence/lizbeth-spanish-issue-batch-2026-10-baseline.md` from T1 facts). Protocol:

1. Fresh worktree from `origin/main`; fresh `npx supabase db reset` plus the container restart.
2. Record a PRE fixture fingerprint with a local-only read script (`127.0.0.1` only): for each seeded account (`student1` to `student7`, `fullaccess`, `owner`, `qa-unconfirmed`), the sign-in probe result with password `password`, `app_metadata.force_password_change`, `banned_until`, and `last_sign_in_at` (`student7` must be NULL); `student_enrollments` count per seeded user; and `select count(*)` from `auth.users`, `course_versions`, and `lesson_revisions`.
3. Vitest baseline: `npx vitest run` twice on this reset stack. Record pass, fail, and skip counts for each run, and the counts between runs (#48, #81). Record the known `fieldJournalTokens` item.
4. Fresh `npx supabase db reset` plus restart again; record the PRE fingerprint again.
5. E2E baseline, non-mutating specs first: `E2E_BASE_URL=http://localhost:5180 npx playwright test --grep-invert "Status clarity and forced password change gate"`. Record the MID fingerprint. Record per-spec pass or fail and the exact 10 #218 failures or deltas.
6. The credential-mutating spec alone, twice without reset (#166 confirmation): `E2E_BASE_URL=http://localhost:5180 npx playwright test src/__tests__/e2e/browser-validation-status-clarity-and-gate.spec.ts`. Record the POST fingerprint. Any fingerprint delta is recorded as a finding and a #137 input. The baseline never relies on a mutated `student1` or `student2`.
7. #201: `E2E_BASE_URL=http://localhost:5180 npx playwright test src/__tests__/e2e/issue174-handout-links.spec.ts --repeat-each=5` on a warm dev server.
8. #210: a deterministic repro (Playwright or RTL with fake timers): type in a task field, navigate Back within 2 seconds, return, reload, and compare the persisted draft.
9. #209 and #206 items 3 and 4: screenshots at 390x844 and 1440x900 of the task bar in RETURNED and REVIEWED states and of the owner submission detail.

Output: the baseline evidence ledger with fingerprints, per-spec results, and the close-after-baseline determinations for #166, #48, #201, and #210. The user confirms; the lead closes.

**W1.1 #137** (branch `fix/137-seeded-credential-isolation`; Closes #137; `CODE_REVIEW` routed).

- Playwright `globalSetup` verifies every seeded credential and flag against the fingerprint and fails fast. `globalTeardown` restores via the existing local-only restore helper, extracted to `src/__tests__/e2e/helpers/seededFixtures.ts`.
- Rotation and reset journeys use per-run disposable accounts with cleanup. `student2@test.local` is never mutated.
- #166 precondition guard on `student7` (section 5.5, D-5), plus a guard test that no spec signs in as `student7`.
- Browser Validator guidance updated to use disposable accounts for credential journeys.

**W1.2 #81** (branch `fix/81-edge-smoke-cleanup`; Closes #81). Move the clone and `save_outline` calls inside the `try`/`finally`; delete dependent `lesson_revisions` and `course_version_lessons` for the clone; clean pre-existing 'HTTP draft edit' local rows; prove with a forced-failure variant and stable counts.

**W1.3 #82 + #139** (branch `fix/82-139-fixture-date-drift`; Closes #82, Closes #139; `CODE_REVIEW` routed). Coupling justification: same root cause, same files. Approach per D-4 (resolved): a test-only helper, no database or migration change.

- A helper (`src/__tests__/helpers/fixtureDates.ts` or equivalent) re-anchors the date-sensitive seeded enrollments and progress to the documented `seed.sql` offsets in `beforeAll` of every date-sensitive suite (`roadmapIntegration`, `rlsIntegration`, and any other found by grep), using only the existing local service-role or pg test connection.
- `seed.sql` comments stay the contract. NO new SQL function in `supabase/migrations` (it would ship to hosted). No product clock seam.
- Acceptance: artificially age the database (shift seeded enrollment and progress dates back at least 14 days via a local-only script), then two consecutive full `npx vitest run` passes are green. No week-state or RLS assertion is weakened. A fresh-reset run is still green.

**W1.4 #218** (branch `fix/218-preexisting-e2e-failures`; Closes #218, Closes #79; `CODE_REVIEW` routed; depends on W1.0 and W1.1).

- Per failing spec, find the root cause and fix the stale selector, navigation, or mock, or self-provision the missing fixture via `course-fixtures.ts` helpers (issue-50 asset library content; issue-55 draft course; wp4 preserved enrollment), with cleanup in `finally` or `afterAll`. Prefer self-provisioning over `seed.sql` edits.
- The PR body carries a per-spec disposition table. No assertion is weakened, skipped, or deleted without a recorded reason.
- issue-54 header overlap at 900px: first reproduce in the rendered app. If the overlap is real, it is a product defect and goes on a separate branch `fix/218-header-900-overlap` that restores the approved #54 inline-row behavior (CSS within existing tokens), with Browser Validator at 900, 1024, 1280, 1440, and 390. If only the spec is stale, correct it against observed behavior with evidence.

**W1.5 #48 remainder** (branch `fix/48-test-suite-pollution`; Closes #48; only if W1.0 shows `auth.users` growth or `student1` double-enrollment; otherwise #48 closes on the baseline evidence; `CODE_REVIEW` routed if it runs). Shared tracked-cleanup helper for disposable auth users; migrate any remaining register-without-cleanup file found by grep `register.*@test.local` in `src/__tests__`; root-cause the `student1` double-enrollment by identifying the writer test and fixing with cleanup or isolation. Mitigations must not mask auth defects. Acceptance: three consecutive full runs with the `auth.users` count unchanged and `student1` holding exactly one enrollment per seeded band contract.

**W1.6 #201** (branch `fix/201-handout-j8-focus`; Closes #201; only if W1.0 shows a real defect; otherwise close on the 5-run evidence). If a flake, stabilize the readiness wait (no assertion weakening). If a real focus-order defect, fix DOM order or tabindex, with Browser Validator at 390 and 1440 and a keyboard journey.

**Wave 1 exit gate.** Two consecutive full `npx vitest run` passes and one full e2e run green on a fresh reset, with fingerprints unchanged. Any remaining failure is filed as its own issue with evidence and accepted by the user. The result is recorded as the new baseline in the evidence ledger.

### Wave 2a. Sign-in bilingual help

Branch `feat/224-226-signin-bilingual-help`; Closes #224, Closes #225, Closes #226.

Coupled-cluster justification: one component and copy module, a shared locale mechanism, and the issues explicitly require a single coordinated help treatment. The design reviewer endorsed one treatment (design and plan unchanged by revision 1).

T1 may start after D-1 approval and the Wave 1 exit gate (reliable e2e helpers). D-2 and D-3 are resolved; D-3 is no longer a merge gate. The PR body lists the Spanish strings for optional owner refinement; any refinement is applied on the same branch and re-verified.

Steps (T1, TDD):

1. `signInCopy.ts` typed Record plus parity test.
2. `AuthContext` error-kind contract with the exact mapping, `setError(null)` preserved, and tests.
3. `LoginForm`: localized labels, heading, submit, loading, and `email_required`; focus effect keyed on kind; help note markup and CSS per the visual spec.
4. `AuthGate`: localized "Loading…" and session-error message and Retry (hook before early returns).
5. `LanguageToggle`: localized `aria-label` and `lang="en"` on English, at all four render sites.
6. Registry optional `default.es` (`signin.*` defaults) and `fallbackH1Es`; `resolveSiteText` ES order per D-2 with optional `sourceLang`; `SiteText` `lang="en"` marker and localized fallback h1. Keep the Edge `site-content` registry import compiling under Deno (run the existing Edge validation tests).
7. Update in-scope tests.
8. Playwright spec `src/__tests__/e2e/issue224-226-signin-bilingual-help.spec.ts` for EN to ES to EN, errors, the help note, network assertions, and a no-dialog listener.

Release note (not executed): no hosted content writes are needed (Spanish defaults ship in code). Netlify deploy and any Edge redeploy are separate user-approved release steps.

### Wave 2b (each requires its own Planner re-plan and user approval before T1)

Order: 2b-0, then 2b-1, then 2b-2.

- **2b-0 #140 + #183** (branch `fix/140-183-course-version-ids`; Closes #140, Closes #183). Separate course id and version id in `getCourse` consumers. The Students tab resolves the PUBLISHED version for roster context (or offers an explicit "View published roster" affordance; compact design if visible) and stops sending a version id as `course_id` to `list_enrollment_requests`. Includes the Publishing prop rename from #197 (#197 itself closes in Wave 0). Browser Validator on `/admin/courses/<id>/students`. Rationale for placing it before #228: #228's flow touches the same Students-tab and cohort directory code, and its issue requires reproducing #183.
- **2b-1 #227.** Sub-plan `docs/plans/lizbeth-spanish-issue227-site-copy-editor-preview.md` (Standard design: director, UX, visual, reviewer). Depends on the Wave 2a registry changes (provenance must include "Built-in Spanish default").
- **2b-2 #228.** Sub-plan `docs/plans/lizbeth-spanish-issue228-create-and-assign.md` (Standard design). High risk: Auth Admin, a forward-only migration, a service-only batch RPC, and a durable operation record. `PLAN_DUCK` and `CODE_REVIEW` required. Staging or disposable reproduction of the reported first-login symptom is required. Preserve #222 least-privilege grants. Hosted migration or Edge deploy is a separate user approval.

### Wave 3 (bugs, accessibility, security; re-plan before execution)

One compact design job at re-plan for #206, #209, #53, #189, #199, and #150; one PR per issue; Browser Validator on each. Order:

1. #206 (D-11 approved).
2. #209.
3. #53.
4. #150.
5. #189.
6. #199.
7. #210, only if W1.0 reproduces loss. No `beforeunload` prompts ever. Research trigger on keepalive and sendBeacon auth semantics.
8. #202 SQL fix: a migration redefining `save_outline` to preserve `legacy_lesson_id`, plus a save, reload, and vocabulary-row regression test; `CODE_REVIEW`.
9. #190 local migration revoking TRUNCATE, REFERENCES, and TRIGGER from anon and authenticated on public tables (plus default privileges), with a test. Hosted read-only verification and apply each need explicit user approval (#222 precedent).
10. #198 dedicated high-risk sub-plan (RLS and storage; `PLAN_DUCK` and `CODE_REVIEW`; hosted approval).

### Wave 3b (owner-editable copy extensions; after #227)

Order: #191, #208, #187, #186 (after D-7), #188 (after D-8).

### Wave 4 (content and curriculum)

Scribe-authored content batches per the #178 and #180 precedent. T1 runs generators and drift checks. Order:

1. #194 (small).
2. #214 (7 defects).
3. #193 (dedicated sub-plan; large; handout PDF and DOCX regeneration).
4. #203 (Scribe checklist plus golden procedure; owner sign-off, D-12).
5. #212 (only if the nested `tools/lesson-generation` repo in the main checkout is present; export via `scripts/export-tooling-patches.ts`; otherwise record a follow-up).
6. #215 (after owner decision D-9).

### Wave 5 (backlog)

#196 per-lesson authored handouts (dedicated sub-plan, Standard design).

### Order rationale

Test reliability comes first because every later gate depends on full-suite runs on reset fixtures. Credential isolation (#137) precedes all e2e work (J-003). Sign-in comes before owner flows because it is the highest-traffic student surface and #227 depends on its registry changes. #140 and #183 come before #228 because #228 touches the same Students-tab and course-version code and its issue requires reproducing #183.

### Re-plan trigger (binding)

Before any Wave 2b, 3, 3b, 4, or 5 item starts, the lead dispatches Planner for that item (or micro-batch) to produce an approved sub-plan or plan revision grounded on then-current `origin/main`. This batch plan alone does not authorize those items' implementation. For #227, #228, #187, #188, #191, #208, and #196, the sub-plan or re-plan MUST supply a complete browser validation block before approval: launch and readiness, base URL, fixture and reset, journeys with assertions, 390 and 1440 viewports, the no-dialog scan, and modal keyboard, focus, and return checks where a modal is touched.

## 7. Interfaces and data

- **Wave 1.** Test helpers only (`src/__tests__/e2e/helpers/seededFixtures.ts`, the fixture-dates helper, cleanup helpers). No migrations. No product interfaces, except a possible header CSS fix and a #201 DOM-order fix.
- **Wave 2a.**
  - The `AuthContext` public type changes (`error: SignInErrorKind | null`; `sessionError` kind). All consumers are updated in the same PR.
  - The `LoginFormProps.error` type changes.
  - The `siteContentRegistry` entry gains optional `default.es` and `fallbackH1Es`. It must remain Deno-importable, dependency-free, and use explicit `.ts` imports. `site-content` Edge validation is unaffected. The baseline test `siteContentRegistry.test.ts` keeps `default.en` byte-identical.
  - `resolveSiteText` results gain an optional `sourceLang`.
  - No database change. No Edge deploy is required for correctness.
- **Later waves.** #202, #190, #198, and #228 add forward-only migrations with rollback files under `supabase/rollbacks/`, per the #222 precedent.

## 8. Acceptance checks

### Command reference

Use these in every acceptance block. Full-suite requirements stay; targeted runs are additional, never substitutes.

- **Install.** `npm ci`.
- **Static.** `npm run type-check`; `npm run lint`; `npm run verify:build`.
- **Stack.** `npx supabase start` (from the PR worktree); `npx supabase db reset`; `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`.
- **Unit and integration, full suite.** `npx vitest run` (`vitest.config.ts` already serializes files; live suites require the reset stack).
- **Dev server.** `npx vite --port 5180 --strictPort` (ready when `http://localhost:5180` serves the sign-in page).
- **Full e2e.** `E2E_BASE_URL=http://localhost:5180 npx playwright test` (equivalently `npm run test:e2e` with the same environment variable); config `playwright.config.ts` (`testDir` `src/__tests__/e2e`, workers 1, chromium).
- **Wave 1 targeted specs** (in addition to full runs):
  - #218: `npx playwright test src/__tests__/e2e/gap-1-owner-settings-persistence.spec.ts src/__tests__/e2e/issue-3-feedback-inbox.spec.ts src/__tests__/e2e/issue-50-asset-card-grid.spec.ts src/__tests__/e2e/issue-54-header-nav-reachability.spec.ts src/__tests__/e2e/issue-55-form-controls-ds-chrome.spec.ts src/__tests__/e2e/wp4-roster.spec.ts src/__tests__/e2e/wp5-feedback-inbox.spec.ts` (with `E2E_BASE_URL` set), each run twice.
  - #137 and #166: `src/__tests__/e2e/browser-validation-status-clarity-and-gate.spec.ts` twice without reset, then the seeded-credential guard.
  - #82 and #139: `npx vitest run src/__tests__/roadmapIntegration.test.ts src/__tests__/rlsIntegration.test.ts` on an artificially aged database, then full `npx vitest run` twice.
  - #81: `npx vitest run src/__tests__/issue5EdgeSmoke.test.ts` with a forced mid-test failure variant proving cleanup, plus count checks.
  - #48: full `npx vitest run` three times with counts.
  - #201: `issue174-handout-links.spec.ts` with `--repeat-each=5`.
- **Wave 2a targeted.** `npx vitest run src/__tests__/LoginForm.test.tsx src/__tests__/AuthContext.test.tsx src/__tests__/AuthContext-EmailNotConfirmed.test.tsx src/__tests__/step4b-email-not-confirmed-flow.test.tsx src/__tests__/LanguageToggle.test.tsx src/__tests__/PublicContentContext.test.tsx src/__tests__/siteContentResolve.test.ts src/__tests__/siteContentRegistry.test.ts src/__tests__/siteTextWiringPublic.test.tsx src/__tests__/App.test.tsx src/__tests__/adminStudentOperationsFixes.test.ts src/__tests__/issue177SiteContentEdgeLive.test.ts`, plus the new `signInCopy` parity test. Playwright: the new `src/__tests__/e2e/issue224-226-signin-bilingual-help.spec.ts` plus the existing `src/__tests__/e2e/wp13-unauth.spec.ts`, `src/__tests__/e2e/issue177-site-text.spec.ts`, and `src/__tests__/e2e/issue177-overflow.spec.ts`; then the FULL e2e run (every spec helper signs in with the English "Open my journal").
- **No-native-dialog scan (every UI PR).** `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` returns zero product hits, plus a `page.on('dialog')` listener in each new or changed spec that fails the test on any dialog.

### Per PR (all)

- `npm ci`; `npm run type-check`; `npm run lint` (0 errors).
- Full `npx vitest run` on a freshly reset local stack (live suites included), with no new failures against the recorded baseline.
- `npm run verify:build`; the targeted specs from the command reference.
- For UI PRs, the no-native-dialog scan and runtime listener above.
- Verifier PASS; Browser Validator PASS for UI PRs; `CODE_REVIEW` where routed with no unresolved blocking finding.
- PR open against `main` with `Closes #n`; no merge.

### Wave 1 specific

- PRE, MID, and POST fixture fingerprints unchanged by the suites (seeded credentials, flags, enrollment counts, `auth.users`, `course_versions`, `lesson_revisions`).
- `student2`'s seeded password still valid after the suites (#137); `student7` precondition guard passes (#166).
- Aged-database double run for #82 and #139.
- Forced-failure cleanup proof and stable counts for #81.
- A per-spec disposition table for #218; each spec run twice.
- Three-run pollution check for #48 (if W1.5 runs).
- A 5-run flake determination for #201.

### Wave 2a specific (from the reviewed design)

- RTL/vitest: EN/ES parity; error-kind mapping with exactly three kinds; consecutive same-kind refocus; language switch causes no refocus; typed values preserved across a switch; disabled `signin.heading` plus ES gives "Iniciar sesión"; resolution-order cases per D-2 (ES present, ES missing, blank, disabled, custom EN only); `sourceLang` `lang="en"` marker; deferred `getSession` under es gives `role=status` "Cargando…"; `LoginForm` with the provider in both languages including the help note; existing sign-in, error-focus, and "Site language" group tests updated, not weakened.
- Network: no register or re-issue request ever; only sign-in on submit.
- One `.control--primary` on the card.
- axe: zero critical or serious findings in EN and ES.
- No horizontal scroll at 390 and 320.

## 9. Browser UI dialog policy and browser validation inputs

### Dialog policy

Required for every web-UI PR (Wave 1 header or focus fixes if any, Wave 2a, and all later UI). No `alert`, `confirm`, `prompt`, `window.alert`, `window.confirm`, `window.prompt`, or `beforeunload` prompts. #210 must use `pagehide`, `visibilitychange`, keepalive, or an equivalent, never a `beforeunload` prompt. Acknowledgement or confirmation uses only the app-owned accessible Modal (`src/components/Modal.tsx`) with Escape or Close and focus return; inline validation where better. Wave 2a adds no modal at all. A deterministic source scan plus a runtime dialog listener is required, and modal keyboard and focus verification is required wherever a modal is touched.

### Standard browser validation block (every UI issue or cluster)

- **Launch and readiness.** From the PR worktree, `npx supabase start`, then `npx vite --port 5180 --strictPort`. Ready when `http://localhost:5180` serves the sign-in page.
- **Base URL.** `http://localhost:5180` (Playwright `E2E_BASE_URL=http://localhost:5180`).
- **Reset.** `npx supabase db reset`, then the `docker restart` command from the command reference.
- **Accounts** (password `password`): `fullaccess@test.local`, `student1@test.local`, `owner@test.local`. Credential-rotating journeys use per-run disposable accounts, never seeded ones (W1.1).
- **Viewports.** 390x844 and 1440x900, with 320 and forced-colors spot checks.
- **Dialogs.** The no-native-dialog source scan plus the runtime listener. Modal keyboard, focus, and return checks wherever a modal is touched.
- **Evidence.** Screenshots under `browser-validation-artifacts/<issue>/`.

### Wave 2a browser validation (#224 to #226)

- **Fixture and reset specifics.**
  - Signed-out state with localStorage cleared (remove `lizbeth.siteLanguage`).
  - Session-error screen via the existing `__E2E_FORCE_SESSION_ERROR__` seam (`AuthContext.tsx` about 85-107).
  - Disabled-heading state via a local-only service-role write to the `site_content` row for `signin.heading` on `http://127.0.0.1:54321` (restored afterward; never hosted).
  - Wrong credentials via `owner@test.local` with a wrong password.
  - `email_not_confirmed` via an existing local fixture or test setup if available; otherwise RTL-only, recorded.
- **Journeys and visible outcomes.**
  - J1. EN default at `/` signed out: headline, eyebrow "Access" at 900px and wider, h2 "Sign in", labels, "Open my journal", English help note. Exactly one primary button. No horizontal scroll. The note does not overlap or clip the password field or submit (scroll to the note at 390).
  - J2. Press Español: headline, taglines (wide and narrow), eyebrow, h2, labels, submit, toggle `aria-label`, and help note in Spanish; `html lang=es`; Español `aria-pressed=true`; `activeElement` is the Español button. Press English: everything reverts.
  - J3. Reload in ES: Spanish persists with no English flash in the settled state ("Cargando…" proven by RTL; browser observation best-effort).
  - J4. Empty email submit: localized inline error, focus on the email input. A slow valid sign-in shows disabled "Entrando…" or "Signing in…".
  - J5. Wrong credentials: localized focused alert, no field disclosure, no raw backend text. Two consecutive failures refocus each time. Toggling language with the alert visible re-renders it, focus stays on the toggle, and the typed email is preserved. The `email_not_confirmed` message says teacher / profesora.
  - J6. Session-error screen: message and Retry localized.
  - J7. Disabled `signin.heading` plus ES: structural h1 "Iniciar sesión".
  - J8. Help note: visible on first load, in the accessibility tree, Tab order Email, Password, Submit with no extra stop; clicking in it submits nothing; typed values preserved.
  - J9. Authenticated: sign in as `fullaccess@test.local`; the header (1440) and mobile menu (390) `LanguageToggle` show the localized `aria-label` with correct `lang` attributes and pressed state.
- **Network.** No register or re-issue endpoint request at any time.
- **Other checks.** axe in EN and ES (contrast included); forced-colors readability; zero native dialog events. Screenshots under `browser-validation-artifacts/issue-224-226/`.

### Per-cluster journeys (later UI work; each uses the standard block)

- **#218 header overlap (only if real).** Owner signed in. At 900, 1024, 1280, and 1440 the accessibility trigger and Sign out bounding boxes do not overlap. At 390 the mobile menu path is used. Keyboard Tab reaches both.
- **#201 (if a real defect).** `fullaccess@test.local`, a `/learn` lesson with a handout, at 390: Tab from "Mark complete" focuses "Student handout"; the same at 1440.
- **#140 and #183.** `owner@test.local`, `/admin/courses/<id>/students` for a course with a published v1 and a newer draft (seeded "Learning Spanish with Luis Miguel" or a self-provisioned fixture): the Student roster heading is visible with published-version roster rows; the enrollment-requests panel loads with no 404 (network assertion: no 404 from `course-authoring`); a draft-only course shows an explicit explanation rather than nothing.
- **#206.** Owner, `/admin/submissions/<id>`: activating "Jump to review" puts `document.activeElement` inside or at the review section; "Next awaiting review" lands focus on the destination h1; an invalid review submit moves focus to the first invalid field with its error described; at 390 the status chip glyph is not orphaned and ledger rows align to the content column.
- **#209.** A student with a RETURNED and a REVIEWED task: no "Draft saved" line under those chips until the student edits; the draft state still shows it.
- **#53.** The owner publishes a staged version. After success, "Finalize publish" is disabled or relabelled and cannot be activated twice; the in-flight state is disabled; the caution-irreversible tier is preserved.
- **#150.** A student on `/` and `/roadmap`: `ContextStatusStrip` is present on both roadmap paths.
- **#189.** `/admin/business-settings` and `/admin/brand-design`: eyebrow contrast at least 4.5:1 (axe); forced-colors legible.
- **#199.** The student roadmap rail at 1440: the FLASHCARDS type label is within the rail bounds (Playwright bounding-box check), and also at 390.
- **#210.** The student task form: type, Back within 2 seconds, return and reload: the draft persists; no `beforeunload` prompt; no dialog event.
- **#227, #228, #187, #188, #191, #208, #196.** Their sub-plan or re-plan supplies the complete block before approval (section 6, re-plan trigger).

## 10. Risks and rollback

| ID | Risk | Mitigation |
| --- | --- | --- |
| R1 | Stale base (the local main checkout is stale; `origin/main` may advance) | Step 0 fetch, SHA record, line re-verification, stale-plan trigger |
| R2 | Hidden real defects surface when e2e runs (#79 warning) | Triage each as a product defect (own issue and PR) or a stale expectation with evidence; never weaken |
| R3 | Temporal pinning masks a real RLS regression | Pin only fixture inputs, keep exact assertions, `CODE_REVIEW` rubric, aged-database test |
| R4 | Cleanup, restore, and guard helpers touch non-test data or non-local hosts | Scope deletions to per-run unique identifiers on the local stack URL only; hard-fail if the Supabase URL is not 127.0.0.1 or localhost |
| R5 | The Wave 2a `AuthContext` type change breaks consumers | Type-check, consumer sweep, test updates in the same PR |
| R6 | Spanish copy quality and accuracy | Strings accepted by the user (D-3); listed in the PR body for optional owner refinement on the same branch; no hosted writes |
| R7 | The resolution-order change surprises an owner with custom EN | D-2 resolved with the tradeoff stated; tests per case |
| R8 | The registry change breaks `site-content` Edge validation (Deno import) | Keep optional fields dependency-free; run existing Edge validation tests; deploy separately |
| R9 | e2e helpers depend on "Open my journal" in English | Label unchanged in EN; specs must not set ES before sign-in |
| R10 | PR conflicts across parallel branches (shared test helpers, `CourseWorkspacePage`) | Serial execution order per wave; rebase on current `origin/main` before PR; one writer at a time |
| R11 | Accidental hosted contact | All scripts and tests assert local URLs; hosted actions require separate approval |
| R12 | A baseline or suite run leaves seeded credentials mutated (J-003) | PRE, MID, and POST fingerprints; W1.1 `globalSetup` and `globalTeardown`; disposable accounts for credential journeys |
| R13 | Closing issues on source evidence that a runtime check would contradict | Wave 0 limited to issues with a source chain plus test or PR evidence; the rest close only after the W1.0 baseline |

Rollback: each PR is independent and unmerged until the user merges. Post-merge rollback is a revert of that PR. Wave 1 and 2a have no migrations or hosted changes. Local `npx supabase db reset` restores fixtures. A wrongly closed issue is reopened by the lead.

## 11. Stale-plan conditions

This plan is stale and must return to Planner if any of the following occurs:

- `origin/main` changes a cited path's behavior.
- An issue body or its comments change scope (no issue has a comment as of revision 1).
- A new issue duplicates or supersedes one listed here.
- The Wave 1 baseline differs materially from #218's list or contradicts a Wave 0 closure.
- A resolved decision (D-2, D-3, D-4, D-11) is reversed by the user.
- Design invariants conflict with current source.

## 12. Assumptions

- The `88b43fd` worktree content-equals `origin/main` (it is a detached checkout of that commit; re-verified at Step 0).
- Local Supabase, Docker, and the Netlify CLI are available, as in prior #173 to #180 work.
- The `gh` CLI is available to the lead for PR creation. Researcher's `gh` is hook-blocked.
- Commit, push, and PR actors (Planner ruling): T1 commits on the feature branch in its worktree under `commit_authority` granted in its `ENGINEERING_JOB` (never on `main`). After Verifier PASS (and Browser Validator PASS for UI, and routed `CODE_REVIEW` with no unresolved blocking finding), the Orchestrator (lead) pushes the branch to `origin` and opens the PR against `main` with `gh pr create`, body containing `Closes #n` lines, an evidence summary, and "Do not merge without user approval". No agent merges. The lead performs no-code closures: the Wave 0 list on the user's pre-authorization, all others after the user confirms.
- Research status: not needed for this pass (see section 3.5).

## 13. Approvals

Status: DRAFT (revision 1). No approval has been given.

Gate: the user must explicitly approve this plan (D-1) before T1 starts. The lead relays that approval to Scribe, which then updates this plan's status in place. Resolved decisions (D-2, D-3, D-4, D-11) are recorded in "Plan revision 1" as relayed by Planner. D-5 and D-12 are needed before the work that depends on them; D-7, D-8, and D-9 before their Wave 3b and Wave 4 items. Hosted actions (D-10) are never covered by plan approval. The Wave 0 closures rest on the user's relayed pre-authorization and execute through the lead.

## 14. Engineering mode and downstream owner

Engineering mode: standard. Team authorization: not applicable (serial execution; one writer at a time). Downstream owner: engineering fleet (Scribe for evidence ledgers and Wave 4 content).

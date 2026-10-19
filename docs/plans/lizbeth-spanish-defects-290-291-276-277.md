# Plan: Lizbeth Spanish defects #290, #291, #276 and #277 (PR 291, PR 290, PR 277a, PR 277b, PR 276a, PR 276b)

- Plan id: `lizbeth-spanish-defects-290-291-276-277`
- Task id: `lizbeth-defects-290-291-276-277`
- Status: **APPROVED 2026-10-17; Revision 2 and 2a (the #276 sections) APPROVED 2026-10-18 ("2. approved"), with D-276-1 option C, D-276-1C.1 to D-276-1C.5, D-276-5, D-276-6, D-276-7, D-276-8 and D-276-9 adopted at their recommendations. Hosted actions remain unscheduled and each needs separate explicit approval.** Written 2026-10-17, Revision 1 applied 2026-10-17, Revision 2 drafted 2026-10-18. Revision 2 #277a change (D-277-4) is user-decided and approved 2026-10-18: verbatim "For 276 choose option a. For 277 choose option a." In context, "option a" for #276 adopts D-276-1 option C (database guard trigger on `storage.objects`) as the direction, with its sub-decisions D-276-1C.1 to D-276-1C.5 and D-276-5 to D-276-9 approved on 2026-10-18 ("2. approved"); "option a" for #277 adopts the cohort rule D-277-4. Production is live and the user said "We're not ready for prod rollout yet": no hosted action is scheduled; Revision 2 prepares scripts only. Revision 1 approval record follows. On 2026-10-17 the user stated, verbatim: "Approve the defect plan, and yes, I'm merging 295." This approves this document for engineering dispatch. All decisions in section 12 are adopted at their recommendations: D-ORD-1 (order 291, 290, 277a, 277b, 276a, 276b), D-277-1 (align the server policy), D-277-2 (yes), D-277-3 (yes; GO only with zero legitimate access loss), D-276-1 option A (conditional on the 276.0 spike and the H0 checks; otherwise option B needs re-approval; superseded by Revision 2), D-276-3 (yes; fail closed), D-276-4 (yes; keep the one-argument finalize defined and revoke EXECUTE at H276-3), D-290-1, D-290-2, D-291-1, D-276-2 and D-ES-1 (yes). Earlier context: on 2026-10-17 the user also stated "Approve the plan for 293 and proceed as planned for 290, 291, 276, and 277." Hosted actions (migration apply, Edge deploy, H0 previews run by the user, H276-3 revoke, Netlify deploy or merge, any production DB write, any grant change) each still require separate explicit approval. Production is live and nothing may be lost.
- Related prior plans (referenced, not duplicated): `docs/plans/lizbeth-spanish-198-5c2-roadmap-week-state.md` (origin of the week-state RPC and the `roadmapCopy` module; decision D-5c2-8 "FeedbackForm week list (legacy date rule): out of scope, open a follow-up issue", of which #277 is the follow-up; D-5c2-5 Spanish release gate; D-5c2-12 freshness numbers), `docs/plans/lizbeth-spanish-198-legacy-entitlement-rule.md` (5c-1; canonical rule and helper `student_can_read_legacy_lesson`), `docs/plans/lizbeth-spanish-187-owner-default-language.md` (origin of the S2 skew run, section 10 table row S2), `docs/plans/lizbeth-spanish-196-per-lesson-handouts.md` (8a immutability, J-002 re-hash precedent), and `docs/plans/lizbeth-spanish-293-accessible-lesson-view.md` (approved 2026-10-17; executes first; its process rules, capability-function precedent and mirror pattern are reused).
- Observed: no existing approved plan in `docs/plans` covers #290, #291, #276 or #277 (searched `docs/plans` and `docs/evidence`).
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team.
- Target: `lebobo88/lizbeth-spanish` (private), base `main`. Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013`, detached at `3594188` (its `node_modules` is a junction; never recurse-delete through it). Local clone: `H:\CommandCenter\orchestrator\lizbeth_spanish`. The live remote SHA was not verified. Every `file:line` below refers to `3594188` and must be re-verified at Step 0.
- Evidence labels: Observed (read in code, an approved plan or cited documentation), Inference (derived from Observed facts, with the test that verifies it), Unknown (not established).
- Design: Compact profile, reviewed `DESIGN_HANDOFF` revision 2 (judge remediation), review verdict PASS (section 4). #291 has no design surface.
- Judge route: Shadow (advisory), section 9.

**History.** Design review round 1 returned NEEDS_REVISION (F1 to F12); round 2 returned PASS on design revision 1. Judge remediation (PLAN_DUCK Revision 1 below) produced design revision 2, which design-reviewer re-reviewed with verdict PASS.

**Revision 1 (PLAN_DUCK J-276-1, J-276-2, J-277-1..4, shadow, Codex `gpt-6-astra`, verdict REVISE).** Planner re-checked each finding against the code and accepted all six. Each affected section is rewritten in place; no superseded text is kept. The judge output is advisory; the changes below are Planner's accepted revisions.

- J-276-1 (fail closed when atomic finalize is unavailable), ACCEPTED. The 276b Edge never calls the one-argument finalize. When the new overload `finalize_publish_job(uuid, jsonb)` is missing (PGRST202, HTTP 404 or 42883), the Edge returns HTTP 503 `{ error: 'finalize_unavailable' }` (stable code, no raw text) and the version stays staged. `mapPublishError` maps this code to the existing `PUBLISH_COPY.finalizeFallback`, with a unit test; no new owner string. D-276-3 now recommends fail closed. During the window between H276-1 and H276-2 the old Edge still calls the one-argument function (the pre-existing defect), so the plan recommends running H276-1 and H276-2 back to back in one approved window, then a new separately approved step H276-3 that revokes EXECUTE on `public.finalize_publish_job(uuid)` from `service_role` after H276-2 is verified, with a re-grant rollback statement. D-276-4 is revised: keep the function defined, revoke its EXECUTE at H276-3. Rollback order for 276 changes: re-grant the one-argument EXECUTE first if H276-3 ran, then redeploy the previous Edge, then run the 276a rollback. New RED tests cover the fail-closed paths. Sections touched: header, 1, 2, 5 (5.2, 5.4), 6 (6.6), 7, 8 (journey 16, mirror skew line), 10 (R4, R12, rollback, hosted rollout), 11, 12 (D-276-3, D-276-4), 13.
- J-276-2 (DELETE and blocked writes serialized with finalize, with no reliance on EPQ re-check), ACCEPTED. The "VOLATILE helper only" mechanism is replaced. 276a replaces the `owns_mutable_lesson_asset_path` usage in `owner_update_lesson_assets` (USING and WITH CHECK) and `owner_delete_lesson_assets` (USING) with a new VOLATILE SECURITY DEFINER boolean helper. The helper first takes `pg_advisory_xact_lock_shared` on a key derived from the path's version id (only when the first path segment is a valid uuid), then evaluates the same predicate (owned, version draft or staged, no handouts path) with a fresh snapshot. The new finalize overload takes `pg_advisory_xact_lock` (exclusive) on the same key immediately after the existing course, job and version row locks and before locking and comparing the `storage.objects` rows (FOR UPDATE, ordered by name). An owner write that has not passed its policy check waits for finalize and is then denied; one that already passed holds the shared lock, so finalize waits, sees the changed or missing object and raises `asset_changed_since_registration`. The spike confirms there is no deadlock. Real Storage API concurrency tests are required. Sections touched: 3 (F276-6), 5 (5.1), 6 (6.5), 7, 8, 10 (R2, R3), 11, 12 (D-276-1).
- J-277-1 (GO/NO-GO gate before applying 277a), ACCEPTED. The preview classifies every (active student, lesson) pair whose access changes into intentional restrictions, potential legitimate loss and gains. 277a applies only if the potential-legitimate-loss count is zero. Added as H0 and H277-1 gate steps, with new decision D-277-3 and updated R5 and R6. Sections touched: 6 (6.3), 7, 10 (R5, R6, hosted rollout), 12 (D-277-3), 13.
- J-277-2 (the skew message must be producible; capability signal), ACCEPTED. 277a adds `get_feedback_lesson_rule_capability()`. 277b probes it once per page load and chooses the lesson-list rule from the answer (entitlement rule, compat rule or legacy rule). The inline rejection message now fires only when the forced refetch shows the week no longer 'open' (a real mid-session change). The "unconfirmable" clause and the earlier design condition that accepted it are removed everywhere. Skew runs S1, S2 and S3 keep their names with new expectations. Design conditions C1 to C3 are added. Sections touched: header, 1, 4 (design revision 2: 4.3, 4.4, 4.7, 4.9, 4.10), 5, 6 (6.3, 6.4), 7, 8, 10, 11, 12 (D-277-2).
- J-277-3 (focus target after a retry with an empty result), ACCEPTED. After a successful Try again, if focus was inside the unmounting warning, focus moves to the first enabled element of the Lesson select, the Course select, then the feedback textarea, never body. The zero-open helpText is static and not announced (accepted limit). Sections touched: 4 (4.3, 4.10), 8 (journey 23).
- J-277-4 (the preview cannot use the `auth.uid()`-bound helper), ACCEPTED. The preview SQL is a read-only set-based equivalent of `student_can_read_legacy_lesson`, correlated per student, with an equivalence test for fixture students and a hosted read-only parity spot check. Sections touched: 3 (F277-6), 6 (6.3), 7, 10 (R13, H0, H277-1), 11.

**Revision 2 (user decisions 2026-10-18).** Written 2026-10-18 after the 276.0 spike (F276-8) and Researcher packet RE-276. The Revision 1 block above is kept verbatim as history. Only #276 and #277a content changes; #290, #291 and #277b content is unchanged except where a shared line names 276 mechanics (R2, rollback, H0, stale conditions, judge row).

- D-277-4 (cohort rule for the 277a preview), ADOPTED by the user 2026-10-18 ("For 277 choose option a."). A pure "cohort not started yet" restriction is class (i) intentional only when nothing else is wrong with that student's access; any combination with a blocking cause stays class (ii) NO-GO. A nine-step classification order and tests T-277-4a to T-277-4g are added. Sections touched: header, 6 (6.3 items 1, 2, 3a), 7, 10 (R5, R6, H0), 12, 13.
- #276 direction changes from option A (advisory-lock VOLATILE policy helper with a policy swap, and `FOR UPDATE` on `storage.objects` in finalize) to D-276-1 option C (a BEFORE UPDATE and BEFORE DELETE guard trigger on `storage.objects`), after the spike showed option A failed 3 of 3 and a waiting `FOR UPDATE` deadlocked with Storage (F276-8). The user's "option a" for #276 adopts option C as the direction; sub-decisions D-276-1C.1 to D-276-1C.5 and D-276-5 to D-276-9 were approved on 2026-10-18. Option A mechanism text is removed from the body and replaced with Revision 2 text marked "(Revision 2)". Sections touched: header, 2, 3 (3.3 F276-6 note and new rows F276-8 to F276-16, 3.6), 4 (4.5, 4.7, 4.8, new 4.11), 5 (5.1, 5.2, 5.4), 6 (6.5 rewritten, 6.6), 7, 8 (journey 16), 9, 10 (R1 to R4, R12, new R15 to R18, 10.2, 10.3), 11, 12, 13.
- A second stable 503 code `finalize_busy` maps to the existing `PUBLISH_COPY.finalizeFallback`; no new string, state or control (design note in 4.11).
- Hosted actions: none scheduled. The user said "We're not ready for prod rollout yet"; Revision 2 prepares scripts only.

**Revision 2a (PLAN_DUCK on Revision 2, shadow, Codex `gpt-6-astra` medium, verdict REVISE).** Planner re-checked each finding against the code and RE-276 and accepted all four. The judge output is advisory; the changes below are Planner's accepted revisions. The #276 sections were approved on 2026-10-18 ("2. approved"), D-277-4 stays adopted, and #290, #291 and #277b content is unchanged. No hosted step is scheduled; the user remains "not ready for prod rollout yet".

- J-276-R2-1 (spike coverage; implementation gate), ACCEPTED. 276.0b gains real, non-synthetic cases (12) TUS resumable overwrite, (13) S3 multipart overwrite, (14) Storage COPY onto an existing destination, (15) failure-cleanup paths, each on both pinned Storage images. Every API write case records the identities seen in the trigger, checks the served-object hash after each rejection, and asserts that no API write matches the exemption predicate. The full 276.0b ledger becomes an implementation gate. TUS, S3 multipart and COPY are Unknown (not covered by RE-276). Sections touched: 3 (F276-10), 6 (6.5 item 2), 7, 9, 11, 12 (D-276-1C.2), 13.1.
- J-276-R2-2 (lock-key canonicalization), ACCEPTED. Observed: `src/lib/courseAssetIntegrity.ts:7` `UUID_RE` has the `/i` flag and `:22` compares lowercased, and the guard's uuid regex accepts A-F, so an uppercase path prefix could hash to a different key than finalize's. The key helper takes the `uuid` type, never raw path text. New RED tests cover an uppercase prefix in both orders and key equality for the two forms. Sections touched: 5 (5.1), 6 (6.5 items 3 and 4), 10 (R2), 12 (D-276-1C.5).
- J-276-R2-3 (hosted removal capability as a deployment prerequisite), ACCEPTED. A confirmed hosted mechanism to remove the triggers is a prerequisite for H276-1; documentary confidence (RE-276 C6) alone is not sufficient. Result mapping: explicitly missing grant = FAIL; unreadable setting = inconclusive, which requires H0b or a verified alternative operator. The H0b dry run now includes DROP TRIGGER. Sections touched: 6 (6.5 item 6), 10 (R15, H0, H0b, H276-1), 12 (D-276-7), 13.2.
- J-277-R2-1 (mixed evidence across enrollments), ACCEPTED. Observed: `student_can_read_legacy_lesson` (`202610130002:44-55`) passes if ANY active enrollment of the student has a mapped, non-held, non-revoked, open row for the lesson, so a held or revoked row in one enrollment must not mask a blocking cause in another. The preview computes evidence per (active enrollment, lesson) first and then collapses to the pair with blocking evidence always winning over intentional evidence. The nine-step order is rewritten; this tightens the D-277-3 first-match order (held and revoked no longer win when blocking evidence exists), is more conservative for the GO gate, stays within D-277-3 and D-277-4, and needs no new user decision (Planner-accepted). Tests T-277-4h, T-277-4i and T-277-4j are added; T-277-4g stays. Sections touched: 6 (6.3 items 1, 2, 3a), 12 (D-277-4).
- Unknowns kept visible in section 11: hosted Storage version, Storage write identities, supautils configuration readability.

Reading guide: approvers need sections 1, 2, 10, 12 and 13. Sections 3 and 4 hold the evidence and the reviewed design. Sections 5 to 9 are execution detail for the engineering fleet.

### Standing constraint: production is live

Carried from the user's recorded words in the approved 196 and 293 plans: production Supabase is live with real student and course tracking data, and nothing may be lost.

- No production data may be lost.
- Every migration is additive and non-destructive, preserves existing rows, and has a data-preserving rollback.
- A read-only production preview runs before any apply that changes access or data.
- No hosted deploy, migration apply, grant change or production DB write happens without separate explicit approval.

This plan's database changes are policy and function replacements and additions (PR 277a), plus function additions and two guard triggers on `storage.objects` (PR 276a, Revision 2). No table, column or row change.

### Standing constraints

- Deploy skew: Netlify builds `main`, so every frontend change must degrade safely without its backend change, proven by an e2e skew run.
- PRs only, base `main`, body "Closes #N" (backend-only PRs of a pair use "Refs #N"). One PR per issue except where a backend and frontend pair is required (277a/277b, 276a/276b), justified by deploy-skew ordering. No push to `main`; the user merges.
- Root-cause each defect.
- Owner `/admin` copy is English only. Student Spanish strings are DRAFT ("DRAFT - pending Lizbeth's approval") and follow the existing `roadmapCopy` release gate (D-5c2-5). Observed: `roadmapText('es', ...)` returns draft text when the site language is `es`, so this is the existing project gate, not a separate inert mechanism.
- Browser UI invariant (#290, #277 and the #276 owner copy): no `alert`, `confirm`, `prompt`, `window.*` forms or `beforeunload`. An app-owned accessible modal only if ever needed (none planned). Inline status and alert regions. Keyboard and focus checks. Deterministic scan: `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"`.
- Dev-server rule, user, verbatim: "during implementation make sure no more than one dev server is running per browser validation at any given time. do not leave orphaned dev servers running indefinitely. we need to clean those up as we progress. this should also help avoid port conflicts. can use more than one dev server but only intentionally as needed." Start and stop every dev server by PID.
- CSP port patches in the mirror are local-only and must never be committed.
- Codex judges use model `gpt-6-astra`, effort medium.

---

## 1. Outcome and audience

Audience: Rob (approver), Lizbeth (Spanish draft copy), and the engineering fleet.

Outcome: four root-caused defect fixes, each in its own PR or PR pair against `main`:

1. **#290.** Student roadmap relative-day labels are computed by calendar days in the browser (student) time zone. A card whose unlock date is today reads "TODAY", and the next-week footer reads the grammatical "Unlocks today."
2. **#291.** The S2 deploy-skew e2e test is made deterministic by fixing its root cause, with no blanket retries and no sleeps.
3. **#276.** The course-authoring finalize re-hash TOCTOU window is closed, so finalize binds atomically to the verified bytes and owner writes are serialized with it. When the atomic path is unavailable, finalize fails closed with a stable 503 instead of publishing unbound. The owner sees an honest error string.
4. **#277.** The FeedbackForm lesson list is aligned with the canonical entitlement rule used by the server week states, and the feedback insert policy is aligned to the same predicate. The form chooses its list rule from a server capability signal, and applying the policy is gated by a read-only access preview (GO/NO-GO).

Delivery: serial, single writer, after the approved #293 work. No merge and no hosted action by the fleet.

## 2. Scope and non-goals

In scope:

- PR 291 (test-only unless the root cause is product code).
- PR 290 (frontend).
- PR 277a (additive policy-replacement migration, `get_feedback_lesson_rule_capability()`, rollback, set-based preview SQL with the GO/NO-GO classification).
- PR 277b (frontend FeedbackForm).
- PR 276a (Revision 2: additive migration with a two-int advisory-lock key helper, a guard trigger function in schema `public` plus BEFORE UPDATE and BEFORE DELETE row triggers on `storage.objects`, the finalize overload `finalize_publish_job(uuid, jsonb)` with an exclusive advisory lock and a plain non-locking comparison read, rollback, H0 preview SQL extended for trigger feasibility, and spike 276.0b). Owner storage policies are NOT changed (they stay at the `202610150001` text); the Revision 1 policy-helper swap is dropped (D-276-1C.3).
- PR 276b (Edge course-authoring finalize binding that fails closed, and owner copy mapping in `src/lib/publishingErrors.ts`).
- RED tests first, skew runs, hosted rollout steps and decisions.

Non-goals:

- Any change to #293 work.
- Changing server week-state semantics or `get_student_roadmap_week_states`.
- A stored per-student time zone. Observed: no time zone column exists in the migrations. The browser zone is the student's zone (Assumption A1).
- A local-midnight re-render timer (existing re-render triggers suffice, D-290-2).
- FeedbackForm localization beyond the strings listed (the form is English-only today).
- Changing the multiple-enrollments-per-band first-match behavior (`enrollments.find` by `band_id`). This is pre-existing and recorded as a limit.
- Dropping the one-argument `finalize_publish_job`. It stays defined; its EXECUTE is revoked at H276-3 (D-276-4).
- Changing Publishing controls. The "Retry finalize publish" control stays visible until re-stage (residual limit).
- (Revision 2) An INSERT guard on `storage.objects` (a new object cannot replace verified bytes; a delete plus insert changes the object id and is caught by finalize).
- (Revision 2) Any change to owner storage policies, and enabling Storage versioning.
- (Revision 2) Any hosted action, including hosted dry-run DDL, unless separately approved (D-276-7).
- Repairing access for students the 277a preview flags as potential legitimate loss. Any such repair is a separately approved, logged, data-preserving process outside this plan (D-277-3).
- Any hosted action or merge by the fleet.
- Tightening `lesson_revisions_student_read` (covered by the #293 follow-up).

## 3. Repository findings and evidence

All `file:line` references are to `3594188` and must be re-verified at Step 0. Issue bodies for #290, #291, #276, #277, #275, #292 (and #287) were not readable during planning (no `gh` access), so their acceptance criteria are Unknown until Step 0.

### 3.1 #290 findings

| Id | Finding | Label |
|---|---|---|
| F290-1 | `src/components/WeekCard.tsx:27-34` `relativeDistanceKey` computes `daysRemaining = Math.ceil((date - Date.now())/86400000)`; `<=0` gives TODAY, 1 gives IN 1 DAY, otherwise IN {n} DAYS. An unlock later today (now 08:00, unlock 23:00 the same local day) gives `ceil(15h/24h)=1`, so the card reads "OPENS 17 OCT 2026 · IN 1 DAY" while the printed date is today. An unlock tomorrow at 23:00 seen at 01:00 today gives 2 ("IN 2 DAYS") instead of 1. Root cause: elapsed-time distance is used instead of calendar-day distance. The date half (`formatCardDate`, `src/lib/roadmapCopy.ts:233-236`) uses browser-local getters, so label and date disagree. | Observed |
| F290-2 | The same ceil math exists in three more places: `src/pages/WeekDetailPage.tsx:338` (`computeServerNextWeekTarget` `unlockDays`), `src/lib/roadmapWeekState.ts:126-130` (`relativeUnlockLabel`, English-only "Unlocks in ..."), and `src/lib/roadmap.ts:104-109` (`buildEntry`, client-date fallback and legacy). `src/lib/weekUnlock.ts:119-127` `formatDaysRemaining` returns "today" for `n<=0`, so the fallback label reads "Unlocks in today". | Observed |
| F290-3 | Footer copy defect: `WeekDetailPage.tsx:1932-1950` composes `detail.next_locked` with `detail.next_locked_in` ("Unlocks in {when}.") where `when = rel.today` for `days<=0`, giving "Next week is locked. Unlocks in today." (ES draft "Se desbloquea en hoy."). The fallback branch (`:1947-1948`) appends its own period to `unlockInLabel`; `BandRoadmap.tsx:233-234` shows `unlockInLabel` raw. | Observed |
| F290-4 | Copy keys exist: `roadmapCopy.ts:40-43` (`card.opens` "OPENS {date} · {relative}", `card.in_days`, `card.in_one_day`, `card.today` "TODAY"); ES drafts at `:132-135` ("HOY" and the rest); `rel.*` at `:88-90`. | Observed |
| F290-5 | Existing e2e `src/__tests__/e2e/issue198-5c2-roadmap-week-states.spec.ts` J3 (`:717-749`, issue #287) pins the CEIL semantic ("4 d 1 h and 4 d 23 h are both IN 5 DAYS, 5 d 1 h is IN 6 DAYS") across UTC, America/New_York and Pacific/Auckland at 23:30 and 00:30 local, with `pinPageClock` (`:93-96`) and `cardDate` (`:107-111`). #290 supersedes that contract, so J3 must be rewritten to calendar-day expectations, not deleted (for example: at 00:30 local, +4 d 1 h gives IN 4 DAYS; at 23:30 local, +1 h gives IN 1 DAY; an unlock later the same local day gives TODAY). Line 194 expects "IN 5 DAYS" for a now()+5 days fixture with a pinned clock, which stays 5 under calendar days (Inference; verify). Unit tests touching labels: `src/__tests__/WeekCard.test.tsx`, `roadmapWeekState.test.ts:162`, `weekDetailNextServerStates.test.tsx:75`. | Observed (line 194 is Inference) |

### 3.2 #291 findings

| Id | Finding | Label |
|---|---|---|
| F291-1 | The only test named S2 with a skew tag is `src/__tests__/e2e/issue187-default-language.spec.ts:846-885`, in `test.describe.serial('skew: S1..S9')`, titled 'S2 @skew-old-schema: new frontend, rollback applied ... (J10b)'. Inference: this is the #291 test. Step 0 confirms from the issue body and its failure output. If #291 names another test, the plan is stale for #291. | Inference |
| F291-2 | Mechanics: `setDefault('es')`; `applyRollback()` runs `supabase/rollbacks/issue187_default_site_language_rollback.sql` through a pg client (begin; `lock_timeout` 5s; lock table `owner_settings` in share row exclusive mode; archive; drop view `public_site_settings`; drop column; commit; notify pgrst); then `waitForView(false)` polls the anon REST view until 404 (60 x 250 ms, uses the `SUPABASE_ANON_KEY` env). Owner context comes from `ownerStorage`, captured once in `beforeAll` (`storageOf` signs in owner and student, `:167-173`, `:298-310`). The test opens the business page and asserts `#default-language-unsupported` text, disabled radios, brand save "Business settings saved.", zero `trackLanguageCalls`, the DB `brand_name`, a visitor seeing "Sign in", and J10b (cached Spanish, then cache cleared, then English); `finally` runs `restoreSchema()`. `beforeEach` restores the schema and resets data (`:316-319`). | Observed |
| F291-3 | Precedent: issue #288 already fixed a race in this same file (`holdViewUntilGate`, `:272-287`): a fixed delay raced the app's 1500 ms bounded wait `SITE_DEFAULT_LANGUAGE_TIMEOUT_MS` (`src/lib/siteLanguage.ts:26`). | Observed |
| F291-4 | Ranked root-cause hypotheses, all Unknown until Step 291.1 evidence. **H1 shared session reuse:** `ownerStorage` is captured once and reused by many contexts; mirror auth has `jwt_expiry = 3600`, `enable_refresh_token_rotation = true`, `refresh_token_reuse_interval = 10` (`H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run\supabase\config.toml:177-186`, Observed). S2 is the first test of the serial skew block after the full J1-J19 matrix at two viewports; if more than an hour has passed since `beforeAll`, each context refreshes with the same refresh token and reuse detection can revoke the session family, producing a signed-out owner (timing-dependent). **H2 rollback lock timeout:** the share row exclusive lock with a 5 s `lock_timeout` can fail when a previous test left an in-flight `owner_settings` write (for example a context closed before its Edge save finished) or an idle-in-transaction session. **H3 schema-cache convergence:** `waitForView(false)` proves only the anon view path; the authenticated page read or the owner-settings Edge path may observe the schema before or after reload at different times. **H4 serial-block coupling:** a failure or skip earlier in the serial block, or the environment (`E2E_SKEW`), changes S2 preconditions. A product-code cause is possible (for example `PublicContentContext` default read classification) and must be ruled in or out. | Unknown |

### 3.3 #276 findings

| Id | Finding | Label |
|---|---|---|
| F276-1 | `supabase/functions/course-authoring/index.ts:811-822` `finalize_publish` reads `publish_jobs`, calls `changedRegisteredAsset` (`:159-168`, which re-hashes each verified `course_assets` row whose sha is in the manifest through `hashStoredObject`, `:143-157`, a stamp read then a signed-URL streaming read, with no stamp re-check after hashing), then calls rpc `finalize_publish_job(p_job_id)`. Root cause: verification and the status flip are separate steps with no binding between the hashed object identity and the commit. An object overwrite between the re-hash and the RPC commit publishes a version whose bytes differ from the verified sha (TOCTOU). | Observed |
| F276-2 | Owners can overwrite or delete staged bytes: `src/services/courseAuthoring.ts:131` `uploadGeneratedAsset` uploads `${versionId}/generated/${name}` with `upsert: true` (`CourseWorkspacePage.tsx:1258-1279` `stage()`). The owner UPDATE and DELETE storage policies (`supabase/migrations/202610150001_issue196_lesson_assets_owner_write_immutability.sql:32-85`) use `owns_mutable_lesson_asset_path`, which allows draft or staged versions and excludes handouts paths; the helper is declared STABLE (`:32-38`). After publish, owner UPDATE and DELETE are denied. `register_asset` already uses a before/after stamp check (`index.ts:567-577`, J-002), the precedent to extend. | Observed |
| F276-3 | Current `finalize_publish_job` text, `supabase/migrations/202610120001_issue233_finalize_publish_current_version.sql:18-52`: lock order `courses` -> `publish_jobs` -> `course_versions` (FOR UPDATE); status must be staged or draft; manifest and required-artifact checks; unverified legacy asset check; newest-version rule (P0001 'newer_version_current'); clears the previous current; publishes; EXECUTE `service_role` only. `stage_publish_job` (`202608280003:430-446`) checks manifest checksums against verified `course_assets`. `remove_course_asset` (`202610150001:93-129`) uses the same lock order. | Observed |
| F276-4 | The handout register (`index.ts:664-693`) is not the target: handout objects are write-once (`x-upsert` off) and handouts paths are excluded from owner UPDATE and DELETE. Step 0 confirms #276 targets `finalize_publish` (the PLAN_JOB links #276 to the #275/#292 line of work; those issue texts were not readable locally). | Observed (target is Unknown until Step 0) |
| F276-5 | `src/lib/publishingErrors.ts:38` maps any HTTP 409 to `PUBLISH_COPY.newerVersion`. Stage already returns 409 `asset_changed_since_registration` (`index.ts:807`; test `src/__tests__/issue196aJudgeRemediationEdgeLive.test.ts:120-122`) and register returns 409 `asset_changed_during_registration` (`:174`), so owners see the wrong "newer version" message today. Control labels: "Build and stage publish" (`CourseWorkspacePage.tsx:1299`), "Retry finalize publish" (`:1302`). An existing `PUBLISH_COPY.finalizeFallback` ("Couldn't finalize this publish. Try again, and contact support if it keeps happening.") is reused for the 503 `finalize_unavailable` mapping; Step 0 confirms the key and text. | Observed (finalizeFallback text per Planner handoff; verify) |
| F276-6 | Option A mechanism superseded by Revision 2 (D-276-1 option C); see Revision 2 block. The Revision 1 premise that a Storage upsert updates the `storage.objects` row in place as one commit point is refined by F276-8 and F276-9: the real write runs in a separate transaction from the policy check, so serialization is done by a guard trigger on the real write instead. | Inference (superseded) |
| F276-7 | Existing tests: `src/__tests__/issue233-finalize-publish-sql.test.ts`, `issue233-finalize-publish-edge-live.test.ts`, `issue196aJudgeRemediationEdgeLive.test.ts`, `authenticatedFunctionExecuteGrants.test.ts`, and e2e `issue53-publishing-state.spec.ts`, `wp8-course-workspace.spec.ts`. | Observed |
| F276-8 | Observed (276.0 spike by T1, local mirror, real Storage API, 2026-10-17/18): an owner overwrite (upsert) ran as two transactions. Tx1 ran as `authenticated` under RLS (it evaluates the owner policy helper and, in the option A draft, the shared advisory lock, and writes a placeholder row). Then the bytes upload. Then Tx2 ran as `service_role` without RLS and did the real UPDATE of version, eTag, size and `updated_at`. Option A failed 3 of 3 (40 MB upsert, finalize delays 180, 220, 260 ms): the version was published, then the bytes changed. A waiting `FOR UPDATE` in finalize deadlocked with Storage (40P01); `NOWAIT` avoided it. Option B (status freeze) has the same hole (Tx2 bypasses RLS). What worked: owner writes after finalize held its locks were denied; a stale stamp was refused; a delete that passed policy made finalize refuse. | Observed |
| F276-9 | Current supabase/storage master runs the real write in one superuser transaction: object advisory lock, `findObject` with a row lock, a caller re-authorization, then `INSERT ... ON CONFLICT DO UPDATE`; the probe (`testPermission`) runs as the caller and always rolls back (RE-276 C9, C11). This differs from the spike (older build). The hosted Storage version is Unknown, so the spike result for option A is version-dependent, while a trigger fires on the real write under either structure (the reason option C is preferred). | Observed (master); Unknown (hosted) |
| F276-10 | Every upload carries a new `version` (new backend key); `updated_at` is set by the built-in BEFORE UPDATE trigger `update_objects_updated_at`; on a refused DB write the old row and old bytes stay served (gap: `upload()`'s outer catch queues deletion of the new version without an `isCommittedVersion` check, new version only). DELETE: row delete and backend delete in one transaction, backend delete skipped if the DELETE raises; a multi-batch remove keeps earlier batches. MOVE: backend copy to a new version, then UPDATE of name, bucket_id, version, owner and metadata; on refusal the source row and bytes stay. Only `updateObjectOwner` writes `last_accessed_at` (with owner, owner_id) (RE-276 C10, C12, C13, C14, C15). TUS resumable uploads, S3-protocol multipart uploads and Storage COPY are not covered by RE-276 (Unknown; covered by 276.0b cases 12 to 14). | Observed; Unknown (TUS, S3 multipart, COPY) |
| F276-11 | Built-in triggers include `update_objects_updated_at` (BEFORE UPDATE row) and `protect_objects_delete` (BEFORE DELETE statement; Storage sets `storage.allow_delete_query`); prefix triggers may exist depending on version (Unknown on hosted). Same-kind triggers fire alphabetically; `INSERT ... ON CONFLICT DO UPDATE` fires BEFORE UPDATE on the conflict path; any trigger error rolls back the statement (RE-276 C16, C23, C24). | Observed; Unknown (hosted trigger set) |
| F276-12 | `storage.objects` is owned by `supabase_storage_admin`; Storage migration 0049 grants ALL on `storage.objects` to `postgres` WITH GRANT OPTION (ALL includes TRIGGER); 0073 revokes TRIGGER only from `anon` and `authenticated`. The April 21, 2025 restriction still allows "RLS policies and database triggers" on `storage.objects` but blocks creating functions in schema `storage` (so the trigger function lives in `public`). CREATE TRIGGER needs TRIGGER privilege plus EXECUTE, not ownership; DROP TRIGGER needs ownership, which `postgres` gets through supautils `drop_trigger_grants` (`storage.objects` is listed). ALTER TABLE ... DISABLE TRIGGER needs ownership, so emergency containment is DROP TRIGGER, not DISABLE. Community reports (C8, discussion #37611) say a raising trigger can surface to the client as a generic RLS-style error (RE-276 C1 to C6; S1 changelog 2025-03-18, S2, S3, S5, S8). | Observed |
| F276-13 | `supabase_storage_admin` runs Storage schema migrations at storage-api start; past migrations (0030, 0043) ran row backfills on `storage.objects`; Supabase docs advise against altering the storage schema. No official statement says user triggers are dropped by upgrades; no documented incident was found (RE-276 C20, C21, C22). | Observed; Unknown (upgrade behavior) |
| F276-14 | With bucket versioning ENABLED, a replacement is UPDATE ... SET `archived_at` then a plain INSERT, and delete becomes a delete-marker write; `buckets.versioning_status` defaults to DISABLED (migration 0062). A guard that only watches name, bucket_id, version and metadata would miss that path (RE-276 C17). | Observed |
| F276-15 | Reference checkout `index.ts:510-616` and `202610150001:93-129`. Edge `service_role` writers that touch `lesson-assets` objects: (a) `remove_asset`: `remove_course_asset` is draft-only under course and version row locks; afterwards the Edge MOVEs an unreferenced object to `<version>/removed-assets/<asset id>/<name>` (`index.ts:533-536`, move error ignored); the legacy PGRST202 fallback `remove()` (`index.ts:526`) is draft-only; (b) `upload_asset` upload with `upsert:false` and compensating remove on registration failure (`index.ts:550-553`, draft-only); (c) handout signed upload under `handouts/` and reconciliation MOVE from `handouts/` to `handouts-quarantine/` (`index.ts:596-616`), possibly under a version that is no longer draft; (d) `last_accessed_at` via `updateObjectOwner` (Storage-internal). Draft-version `course_assets` rows can be inherited and point at paths under an earlier published version's prefix (`index.ts:507` `inherited`). | Observed |
| F276-16 | With the guard, Edge (a) can be refused only if the version left draft between the RPC commit and the move; the refusal fails safe (bytes stay at the original path, unreferenced). (b) and the fallback remove act on draft only. (c) is excluded by the handouts rule on both names. (d) is allowed (no guarded column changes). Inherited paths under a published prefix are already immutable and are guarded. Spike 276.0b verifies each. | Inference |

### 3.4 #277 findings

| Id | Finding | Label |
|---|---|---|
| F277-1 | `src/components/feedbackForm.helpers.ts:14-19` `isLessonUnlockedForFeedback`: enrollment completed gives true, otherwise `enrollment_date + unlock_offset_days*86400000 <= Date.now()` (legacy date rule). Used at `src/components/FeedbackForm.tsx:321` to filter the Lesson select options ("Week {n}: {title}"). Context is loaded by `loadContext` (`:161-169`: `fetchEnrollmentsWithBand` plus `fetchLessonsForBand`, `src/services/roadmapData.ts:63-108`). | Observed |
| F277-2 | The server insert policy `students_insert_feedback` (latest definition `supabase/migrations/202608280002_issue3_feedback_inbox_hardening.sql:2-32`) also uses the legacy date rule plus a `completed_at` branch, with band membership, active enrollment, `user_id = auth.uid()`, not `user_requires_password_change()`, `is_account_active(auth.uid())`, a general branch (`lesson_id` null and `band_id` null), and `lesson.band_id = feedback.band_id`. No later migration redefines it. | Observed |
| F277-3 | The canonical rule elsewhere: `supabase/migrations/202610130002_issue198_legacy_entitlement_rule.sql:39-56` `student_can_read_legacy_lesson(p_lesson_id)` (SECURITY DEFINER, stable; password-change, account-active, active enrollment, entitlement not held or revoked and released or `unlock_at <= now()`, mapped in the enrollment's current version; completion branch removed per D-198-2), used by resources and storage RLS. The student roadmap uses server week states through `src/hooks/useRoadmapWeekStates.ts` (modes loading, server, fallback, error; `refetch({force})` bypasses the ~5 s throttle, `src/lib/roadmapWeekStatesStore.ts:23, 92-97`; mode stays 'error' while revalidating, `:99, :157-161`) and `src/services/roadmapWeekStates.ts` (function-missing only for PGRST202 or 404 naming the RPC). Week entries carry `legacyLessonId` and `weekNumber` (`src/lib/roadmapWeekState.ts:81-90`). | Observed |
| F277-4 | Consequence: client and server both use the legacy rule today, so they agree with each other and disagree with the canonical rule. Held and revoked lessons are offered and accepted; released-early and cohort-anchored late-joiner lessons are hidden and rejected. A client-only change to the canonical set would make released-early submits fail against the old policy, hence the 277a/277b pair. | Inference |
| F277-5 | `SelectField` (`FeedbackForm.tsx:40-69`) renders help `<p className="feedback-form-help">` with no id and no `aria-describedby`; `Field.tsx:96` sets `aria-describedby` only for its own error id. The submit Control is natively disabled while submitting (`:356`), so focus can fall to body. On submit failure the content is kept (reset only on success, `:196-202`). The Course select is disabled while `contextStatus !== 'ready'` (`:297`). Existing patterns: `.feedback-form-context-warning` with `role="status"` and a quiet Try again (`:303-310`), `.feedback-form-error` alert (`:373-377`). | Observed |
| F277-6 | The canonical helper is bound to `auth.uid()` (it evaluates the calling user's account-active and password-change state and enrollment), so a hosted preview run by an administrator cannot call it for other students. The preview must therefore be a set-based equivalent correlated per student (J-277-4). Step 0 re-reads the helper body and confirms. | Inference |

### 3.5 Shared test infrastructure (Observed)

`src/__tests__/helpers/testConfig.ts` (API from `SUPABASE_API_URL`, then `LIZBETH_TEST_API_PORT`, default 54321; DB from `SUPABASE_DB_URL`, then `SUPABASE_DB_PORT`, `LIZBETH_TEST_DB_PORT`, `E2E_DB_PORT`, `PGPORT`, default 54322; loopback enforced); `playwright.config.ts` (baseURL from `E2E_BASE_URL`, else `netlify serve` on 8888; workers 1); `src/__tests__/helpers/roadmapWeekStatesFallbackMock.ts`; fixture helpers `src/__tests__/e2e/course-fixtures.ts`; mirror `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` (API 64321, DB 64322, studio 64323; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`). The latest migration at `3594188` is `202610160001_issue196_lesson_handouts.sql`; the approved 293a migration will follow it, so new migration timestamps are assigned at Step 0 after the newest migration on the base.

### 3.6 Research evidence

Revision 1 record: None. Researcher was not invoked: every material fact is verifiable locally or through the read-only hosted H0 queries. The Supabase Storage, privilege and advisory-lock facts (F276-6) are verified empirically at Step 276.0 and H0 rather than from web sources. GitHub issue bodies were not readable during planning; Step 0 reads them.

Revision 2: Researcher packet RE-276 (topic `lizbeth-276-storage-objects-trigger-feasibility`, accessed 2026-10-18). Claims are cited as "RE-276 Cn". Sources: S1 Supabase changelog #34270 (2025-03-18); S2 Supabase Platform permissions; S3, S4, S5 supabase/storage tenant migrations 0049, 0046, 0073; S6, S7 PostgreSQL 17 CREATE TRIGGER and DROP TRIGGER; S8, S9 supabase/postgres `supautils.conf.j2` and the supautils README; S11 discussion #37611 (community); S12, S13, S15, S18 supabase/storage master `uploader.ts`, `pg.ts`, `scope.ts`, `object.ts`; S14 migration 0011; S17 Supabase Postgres Roles; S19 migration 0055; S20, S21 migrations 0062, 0066, 0067; S23 to S27 migrations 0030, 0043, 0065, 0052, 0072; S28 Supabase Storage schema docs; S31 PostgreSQL trigger behavior; S32 storage releases (rapid cadence). Limits: source was read from master, not the hosted tag; the hosted Storage version is Unknown; S22 (advisory key spaces do not overlap) was not fetched and is verified in spike 276.0b; a contradiction between S28 and S1 on indexes is noted and is not relevant to triggers.

## 4. Design (Compact profile, reviewed `DESIGN_HANDOFF` revision 2, verdict PASS)

`DESIGN_ROUTE`: profile compact; reasons: bounded brownfield copy and state corrections (#290 card and footer labels, #277 Lesson select states, #276 one owner string mapping); agents design-generalist (Sonnet) and design-reviewer (Sonnet); prototype forbidden; model tier Sonnet; `existing_system_mode` preserve. Design review round 1 returned NEEDS_REVISION with findings F1 to F12 (fallback double period, SelectField `aria-describedby`, insert-policy parity, honest skew classification and "right now" wording, refetch after rejection, announced selection reset, submit focus, Try again feedback, owner string label and operation coverage, zone agreement test, stale label case, live-region limit); revision 1 resolved them and passed. Judge remediation (Revision 1 above) produced design revision 2, which design-reviewer re-reviewed with verdict PASS. Revision 2 adds the capability-driven list rule, the narrowed rejection classification, conditions C1 to C3, the focus fallback chain, and the `finalize_unavailable` mapping.

### 4.1 Direction

Preserve existing roadmap, FeedbackForm and Publishing styling. No new screen, component, token or layout.

### 4.2 #290 labels

- One shared calendar-day helper: `d = localDate(unlock) - localDate(now)` using browser-local `getFullYear/getMonth/getDate` (the same zone as the date formatters), computed as `Date.UTC(y,m,d)` differences divided by 86,400,000 with `Math.round`. A raw millisecond delta is never divided (DST-safe). Tests set `TZ` or pass an injectable `Intl` time zone defaulting to local. One test asserts the printed date is today if and only if the label is TODAY.
- Card: `d<=0` TODAY; `d=1` IN 1 DAY; `d>=2` IN {d} DAYS. A stale week (instant passed, server still locked) shows TODAY, never a negative number or "ago".
- Footer (server path): `d<=0` "Next week is locked. Unlocks today." through a new key `detail.next_locked_today` (EN "Unlocks today."; ES `d('Se desbloquea hoy.')` DRAFT under the D-5c2-5 gate); `d=1` "Unlocks in 1 day."; `d>=2` "Unlocks in {d} days." (existing keys). `rel.today` stays but is no longer composed into "Unlocks in {when}".
- English-only `unlockInLabel`: the today variant is "Unlocks today" with no trailing period; `n>=1` is unchanged "Unlocks in {formatDaysRemaining(n)}" (`formatDaysRemaining` untouched) at `roadmapWeekState.ts:126-130` and `roadmap.ts:104-109`, fed by the shared helper (recommended, D-290-1). Unit and browser checks that ".." never appears in the fallback footer or `BandRoadmap`.
- All other approved strings are unchanged.

### 4.3 #277 Lesson select (id `feedback-lesson`)

`SelectField` gets `useId` on the help `<p>` and passes `aria-describedby` to Field only when help renders. DOM order is kept; association is tested per state.

The list rule depends on the week-state mode and on the feedback lesson-rule capability (4.4):

| State | Behavior |
|---|---|
| No course | Disabled; existing helpText "Choose a course to select an unlocked lesson." |
| Course chosen, context or week states loading | Disabled; "General / no lesson" only; helpText "Loading lessons…" |
| Server mode, capability positive, at least one open week | Enabled; "General / no lesson" plus "Week {n}: {title}" for each week with access 'open' (entitlement rule) |
| Server mode, capability unavailable or pending, at least one candidate | Enabled; compat rule: a week is listed only if access is 'open' AND the legacy helper `isLessonUnlockedForFeedback` allows it (accepted by both the old and the new insert policy) |
| Server mode, zero listed | Disabled; helpText "No lessons are open in this course yet." |
| Fallback mode (RPC missing) | Legacy helper only, unchanged |
| Error mode | Fails closed: disabled; "General / no lesson" only; no select helpText (avoids a duplicate "Loading lessons…"); below it the existing pattern `<p role="status" aria-live="polite" className="feedback-form-context-warning">Lesson list could not load. You can still send your note without a lesson.` plus `<Control type="button" tier="quiet">Try again</Control></p>` |

A pending capability call that resolves positive may add options but never changes the current selection.

Try again calls `refetch({ force: true })` and also re-probes the capability when the cached answer is absent (C1). While revalidating it is `aria-disabled="true"` (focusable, ignores activation) and the paragraph text becomes "Loading lessons…". A repeat failure restores the message with focus on the button. Success unmounts the warning. If focus was inside the unmounting warning, focus moves to the first enabled element of: the Lesson select, the Course select (disabled while `contextStatus !== 'ready'`, `FeedbackForm.tsx:297`), then the "Your feedback or suggestion" textarea. Focus is never left on body. Each step of the chain checks that the target is enabled. Warnings stack, not merged. Accepted limit: after an empty result the zero-open helpText is static and not announced, but it stays visible and associated through `aria-describedby`.

Selection reset: when a refresh drops the selected lesson, `lessonId = ''` and one polite status line appears under the select (same class): "That lesson is no longer open, so your lesson choice was cleared." It shows only when a reset happens, appears once (no duplicate after a rejection reset), clears on the next lesson or course change or submit, and is suppressed in the classified rejection path. A course change clears the lesson silently (existing).

### 4.4 #277 capability, compat list and rejection

**Capability.** 277b calls `get_feedback_lesson_rule_capability()` once per page load (the 293 precedent). The answer is positive only on a successful response whose value is `{"feedback_lesson_rule":"entitlement"}`. A positive answer and a definitive-missing answer (PGRST202, HTTP 404 or 42883) are cached. Any other error (for example HTTP 500) counts as unavailable for now, is not cached, and is re-probed on the next form mount or on Try again (C1). No capability text appears in the UI.

**Rejection message.** The inline rejection fires only when all three hold: `lessonId` is non-empty, the submit error is 42501 or RLS, and a forced week-state refetch shows the selected week is no longer 'open' (a real mid-session state change, for example a pause). Otherwise the existing `errorMessage` shows; this includes a refetch failure and a refetch that still shows 'open'. On the classified rejection: keep the textarea, course and lesson (until the refetch reset); show the existing `role="alert"` `.feedback-form-error` with exact text "That lesson isn't open right now. Your note is still here. Choose another lesson, or choose General / no lesson, then send again."; the forced refetch removes the lesson from the list; the reset must not clear the rejection error and must not add a second reset line. On a lesson-scoped 42501 where the refetch still shows 'open', the cached capability is invalidated so the next list uses the compat rule (C2; covers a mid-session 277a rollback).

**Focus.** On any submit failure, focus returns to the re-enabled submit Control through a ref (like `keepEditingRef`). The "focus never on body" check covers the whole form.

### 4.5 #276 owner string

`PUBLISH_COPY.assetChanged` = "The course files changed after they were checked, so this publish couldn't be completed. Use Build and stage publish to start again." It applies to stage, finalize and retry. `mapPublishError` order: `/newer_version_current/` gives `newerVersion`; `/asset_changed_(since|during)_registration/` gives `assetChanged`; the stable codes `finalize_unavailable` and `finalize_busy` (both HTTP 503, Revision 2) give the existing `PUBLISH_COPY.finalizeFallback` ("Couldn't finalize this publish. Try again, and contact support if it keeps happening."), with no new string; then `status === 409` gives `newerVersion` (split 409 out of the first condition at `publishingErrors.ts:38`). `error.message` is never echoed. Tests cover all three operations and the `finalize_unavailable` and `finalize_busy` mappings. Residual: "Retry finalize publish" stays visible until re-stage (accepted limit).

### 4.6 Responsive and accessibility requirements

- Wrap at 320, 390 and 1440 and at 200% zoom. "OPENS 17 OCT 2026 · IN 12 DAYS" has no clipping at 320. No horizontal scroll.
- Try again is at least 24x24 through the existing Control.
- Tab order: Type, Course, Lesson, Try again (when shown), textarea, submit.
- Polite status for warnings and the reset line; alert for the rejection and Publishing errors.
- Forced-colors legibility of disabled select help text (`Field.css:84-100`).
- Recorded limit: a polite region inserted already populated may be missed by some screen readers, and identical text does not re-announce (hence the text swap).

### 4.7 Engineering invariants

- No native dialogs.
- Labels are display-only; the server decides state.
- No `Math.ceil` on millisecond deltas for day labels.
- `unlockInLabel` never ends with a period.
- New `roadmapCopy` keys in en and es, with ES via `d()`.
- Lesson options by mode: server plus positive capability lists only access 'open'; server plus unavailable or pending capability lists access 'open' AND the legacy helper; fallback uses the legacy helper only; error fails closed.
- 277a is applied and verified before 277b merges.
- Never clear the student's text on submit failure.
- Three-part rejection classification (non-empty `lessonId`, 42501 or RLS, refetch shows the week no longer 'open'); the reset never clears the rejection error.
- A pending capability resolution never changes the current selection.
- `mapPublishError` order with `asset_changed` first, then `finalize_unavailable` and `finalize_busy` (both `finalizeFallback`), then the generic 409.
- The Edge never calls the one-argument finalize.

### 4.8 Permitted variation

Helper names and locations; the footer today sentence as a new key (recommended) or a composed branch with identical text; the 42501 detection mechanism within the three-part rule; the `aria-disabled` implementation if the text swap and focus retention hold; the capability hook name and cache mechanism within C1; the advisory-lock key derivation (identical in the guard trigger and the overload); empty-list wording only if product review rejects it.

### 4.9 Design conditions from the review (bind engineering)

- DC-1. The 277a replacement policy keeps the `band_id`/lesson join (`lesson.band_id = feedback.band_id`, `band_id` non-null for lesson-scoped rows, active band enrollment) and the general branch, replacing only the time-based predicate (and the `completed_at` branch) with `student_can_read_legacy_lesson(lesson_id)`.
- DC-2. Try again uses `refetch({ force: true })`, with a test for a click inside the throttle window.
- DC-4. Keep the select help text empty in error mode.
- C1. Cache only a positive or a definitive-missing capability answer; re-probe after any other error on the next form mount or on Try again.
- C2. On a lesson-scoped 42501 where the forced refetch still shows 'open', invalidate the cached capability so the next list uses the compat rule.
- C3. Known limit: in compat mode the picker can omit released-early weeks that the roadmap shows open, silently (transitional).
- Precision: every step of the focus fallback chain checks that the target is enabled.

### 4.10 Remaining design limits

Real browser focus, screen-reader announcement and forced-colors rendering are unverified (the Browser Validator verifies them). First-match enrollment per band was not examined. The Retry control residual is accepted. C3 (silent compat omission) and the static zero-open helpText are accepted limits. Hosted Storage concurrency behavior is an Unknown for #276 (section 11).

### 4.11 Revision 2 design note

Design revision 2 (Compact, PASS) is unchanged. The only user-visible deltas of Revision 2 are that a second stable 503 code, `finalize_busy` (finalize lock timeout or deadlock), maps to the already reviewed `PUBLISH_COPY.finalizeFallback` string (no new string, state or control), and that a guard-refused owner upload shows the existing generic upload failure copy with no raw database text. #277a is SQL only and has no design surface.

## 5. Interfaces and data

### 5.1 New SQL

- **PR 276a:**
  - (Revision 2) Option A mechanism superseded by Revision 2 (D-276-1 option C); see Revision 2 block.
  - (Revision 2, 2a) A two-int advisory-lock key helper, `public.lesson_asset_version_lock_key(p_version_id uuid)`: `pg_advisory_xact_lock(<fixed int4 class id>, hashtext(p_version_id::text))`, uuid-typed so the key is canonical lowercase, used identically by the trigger and finalize (D-276-1C.5).
  - (Revision 2) `public.lesson_assets_publish_guard()` (plpgsql, VOLATILE, SECURITY DEFINER, owner `postgres`, fixed search_path) and two row triggers on `storage.objects`: `lesson_assets_publish_guard_upd` (BEFORE UPDATE) and `lesson_assets_publish_guard_del` (BEFORE DELETE).
  - (Revision 2) `public.finalize_publish_job(uuid, jsonb)` (service_role only), function-level `lock_timeout` 5s. After the existing course, job and version row locks it takes `pg_advisory_xact_lock` (exclusive) on the version key, then a plain non-locking read of the `storage.objects` rows and a comparison (see 6.5).
  - (Revision 2) Owner storage policies are untouched (D-276-1C.3). Error contract: P0001 `lesson_asset_immutable` (guard), P0001 `asset_changed_since_registration` (finalize), 55P03 from the finalize `lock_timeout`.
- **PR 277a:**
  - Replaced policy `students_insert_feedback` (canonical predicate).
  - New `public.get_feedback_lesson_rule_capability()` returning `{"feedback_lesson_rule":"entitlement"}`: STABLE, SECURITY DEFINER not needed, EXECUTE `authenticated` only, revoked from `public`, `anon` and `service_role`. The rollback drops it.
- No table, column or row changes. Rollbacks restore prior text exactly.

### 5.2 Edge contract (course-authoring `finalize_publish`)

The request is unchanged from the client. Finalize adds the stable response 409 `{ error: 'asset_changed_since_registration' }` (already used by stage) and the stable response 503 `{ error: 'finalize_unavailable' }` (no raw text). Revision 2 adds the stable response 503 `{ error: 'finalize_busy' }` (finalize lock timeout 55P03 or deadlock 40P01; the version stays staged; no raw text).

Skew and failure behavior:

- New Edge plus old DB (overload missing: PGRST202, HTTP 404 or 42883): the Edge returns 503 `finalize_unavailable`, the version stays staged, no publish occurs. It never calls the one-argument function (D-276-3).
- Old Edge plus new DB: the old Edge still calls the one-argument function, which keeps the pre-existing defect during the window between H276-1 and H276-2. H276-3 closes that path by revoking EXECUTE on the one-argument function from `service_role`. Revision 2 skew note: once H276-1 is applied, the guard closes the post-publish byte change even for the old Edge (D-276-5); only the pre-commit overwrite window remains until H276-2.
- Frontend copy is independent of both.

### 5.3 Frontend

New `roadmapCopy` key `detail.next_locked_today`; a shared calendar-day helper; FeedbackForm consumes `useRoadmapWeekStates` and a capability hook for `get_feedback_lesson_rule_capability()`; `publishingErrors` gets the `assetChanged` branch and the `finalize_unavailable` mapping to the existing `finalizeFallback`. No new routes or tokens.

### 5.4 Compatibility

- #290 has no backend dependency.
- 277b degrades safely without 277a: capability unavailable gives the compat rule (access 'open' AND legacy helper), accepted by the old policy, so no rejection arises from the list. S2 (old frontend plus new policy) degrades with the existing generic error and no data loss.
- 276b frontend copy is safe in all orders. A new Edge against an old or rolled-back DB fails closed (503, no publish, no race). An old Edge against the new DB (Revision 2): the guard closes the post-publish byte change (the spike's failing case) as soon as H276-1 is applied, leaving only the pre-commit overwrite window (verify, then overwrite, then the one-argument commit) until H276-2 and H276-3.
- A4: the 5c-2 week-state RPC is applied wherever 277b runs; otherwise fallback mode applies (legacy helper, today's behavior).

## 6. Ordered work

Sequencing: the approved #293 plan executes first (293a, 293b) under its own approval. This plan then runs serial, single writer, recommended order PR 291 -> PR 290 -> PR 277a -> PR 277b -> PR 276a -> PR 276b (D-ORD-1). Owners: T1 (T2 per fleet escalation); Verifier per PR; Browser Validator for 290, 277b, 276b (owner copy) and for the 291 spec run evidence; Scribe for any follow-up issue texts; the orchestrator for `gh` actions.

**Step 0 (every PR).** Fetch origin and record the base SHA (`3594188` or later, including 293 work if merged). The orchestrator runs `gh issue view <N> --comments` for the PR's issue (and #275, #292 for 276; #287 for 290) and records results in the PR. Any acceptance criterion in an issue body that this plan does not cover is a stale-plan trigger (JOB_BLOCKED "Plan stale"). Re-verify every cited `file:line`. Assign migration timestamps after the newest migration on the base. Record the vitest baseline on a freshly reset local stack.

### 6.1 PR 291 (Closes #291; test-only unless the root cause is product code)

1. **291.1 Reproduce and collect evidence before any fix.** Read the issue's failure output. Run the S2 test isolated 10 times and the full issue187 spec 3 times against the mirror with `--trace retain-on-failure` and `--workers=1`. Record per run: elapsed time since `beforeAll`; the owner context's auth network (POST `/auth/v1/token?grant_type=refresh_token` responses); the rollback statement result (lock timeout or not) with a `pg_locks`/`pg_stat_activity` snapshot captured on failure; the view and authenticated read responses after rollback; and the failing assertion. Deterministic reproduction aids, allowed in investigation only: age the stored session (set the stored access token's expiry in the copied storage to the past) to force the refresh path in two contexts; hold an `owner_settings` row lock in a second pg session to test H2.
2. **291.2 Classify the root cause** against H1 to H4 (or a new one) with evidence; record it in the PR.
3. **291.3 Fix deterministically at the root.** Examples by hypothesis: H1, give each context its own session (sign in per context or per serial block, or never share a refresh token across contexts); H2, wait on the real condition (the prior save response settled before context close; no idle-in-transaction session) rather than time; H3, wait on the exact readiness signal the asserted path uses (authenticated view 404 or PGRST205 and Edge behavior) through `expect.poll`; if product code is at fault, fix it with a unit test. Prohibited: retries (no `test.describe.configure({ retries })`, no retries in `playwright.config` for this spec), new fixed sleeps or longer timeouts as the fix, weakening or removing assertions, and skipping S2.
4. **291.4 Proof.** A RED demonstration that the identified condition fails the old test deterministically (using the 291.1 aid) and passes after the fix; S2 isolated, 10 consecutive passes; full issue187 spec, 3 consecutive passes; the issue187 vitest and edge-live suites unaffected.

### 6.2 PR 290 (Closes #290; frontend only)

1. RED: unit tests for the shared calendar-day helper (new module, for example `src/lib/calendarDays.ts`) under TZ values UTC, America/Los_Angeles, America/New_York (DST day 2026-11-01) and Pacific/Auckland: same-day later unlock gives 0; 23:30 to next day 00:30 gives 1; 00:30 + 4 d 1 h gives 4; 23:30 + 4 d 23 h gives 5; past gives `<=0`; the printed date (`formatCardDate`) agrees with the label. WeekCard, footer and fallback label tests fail first.
2. Implement the helper. Replace the ceil math at `WeekCard.tsx:27-34`, `WeekDetailPage.tsx:338`, `roadmapWeekState.ts:126-130` and `roadmap.ts:104-109`. Pass `now` explicitly where `Date.now()` is read in render.
3. Copy: add `detail.next_locked_today` (EN "Unlocks today."; ES `d('Se desbloquea hoy.')`). The footer uses it for `d<=0`. The `unlockInLabel` today variant is "Unlocks today" (no period).
4. Update existing suites without weakening: `WeekCard.test.tsx`, `roadmapWeekState.test.ts`, `weekDetailNextServerStates.test.tsx`. Rewrite e2e J3 in `issue198-5c2-roadmap-week-states.spec.ts` to calendar-day cases including TODAY and the under-24-hour next-day case across the three zones. Re-verify line 194.
5. Browser validation per section 8. There is no backend change, so skew is not applicable beyond the existing fallback-mode journey (a route-intercepted PGRST202 shows the fallback label correctly).

### 6.3 PR 277a (Refs #277; backend)

1. **Set-based preview** `scripts/audit/issue277-feedback-policy-preview.sql` (read-only; run locally, and by the user as H0 hosted). Because the canonical helper is bound to `auth.uid()` (F277-6), the preview is a set-based equivalent of `student_can_read_legacy_lesson`, correlated per student: it joins `student_enrollments`, `enrollment_lesson_entitlements`, `course_version_lessons` and `lesson_revisions.legacy_lesson_id`, and evaluates the account-active and password-change conditions per user through the same underlying tables or functions with explicit user ids, alongside the legacy rule. Table and column names are as cited in the handoff and are re-verified at Step 0. It classifies every (active student, lesson) pair whose access changes:
   - (i) intentional restrictions: held, revoked, inactive enrollment, deactivated account, forced password change, lesson of another band, and (Revision 2, D-277-4) `cohort_not_started`;
   - (ii) potential legitimate loss: the legacy rule passes and the account and enrollment are active, but the canonical rule denies because of a missing entitlement row, a lesson revision not mapped in the enrollment's current version, an `unlock_at` later than the legacy date (`unlock_at_later`), or reliance on the removed `completed_at` branch; and (Revision 2) `cohort_not_started_with_blocking_cause`;
   - (iii) gains: released early, cohort late joiner (unchanged).
   - **Revision 2 pre-cohort definition (D-277-4, adopted 2026-10-18), per pair:** the canonical rule denies; at least one entitlement row for a revision of the lesson is mapped in its enrollment's current version and is neither held nor revoked; every such mapped, non-held, non-revoked row belongs to an active enrollment whose `cohort_id` is non-null and whose `cohorts.starts_at` is non-null and later than the preview instant t (cohort not started; unlock anchor per `resolve_entitlement_anchor`, migration `202608300001`); and the legacy rule passes through the date rule (not `completed_at` only). The cohort is correlated through the entitlement row's enrollment (join on enrollment id, not only user id). Rolling enrollments (cohort null or `starts_at` null) are never pre-cohort.
   - **Per-enrollment evidence (Revision 2a, J-277-R2-1; Planner-accepted).** Observed: `student_can_read_legacy_lesson` (`202610130002:44-55`) passes if ANY active enrollment of the student has a mapped, non-held, non-revoked, open row for the lesson, so a held or revoked row in one enrollment must not mask a blocking cause in another. Compute evidence per (active enrollment, lesson) first. Each enrollment-lesson gets one of: `open` (canonical allows); `held`; `revoked`; `missing_entitlement` (no row for any revision of the lesson in that enrollment); `unmapped_revision` (rows exist, none mapped in that enrollment's current version); `unlock_at_later`; or `pre_cohort` (mapped, not held or revoked, the cohort of that enrollment not started). `completed_at_only` is evaluated per pair from the legacy branch. The pre-cohort definition above is applied per enrollment-lesson.
   - **Collapse to the pair (blocking evidence ALWAYS wins over intentional evidence).** Pair label (ii) if any enrollment-lesson carries a blocking cause (`missing_entitlement`, `unmapped_revision`, `unlock_at_later`) or the pair is `completed_at_only`; cause precedence among blocking causes: `missing_entitlement`, `unmapped_revision`, `completed_at_only`, `unlock_at_later`. Otherwise (i) `account_deactivated`, `held` or `revoked` if any such intentional evidence exists. Otherwise `pre_cohort`, which goes to steps 8 and 9 (student-level blocking check).
   - **Exact classification order (rewritten in Revision 2a)** for a pair where the legacy rule passes and the canonical rule denies (first match wins): 1 account deactivated -> (i) `account_deactivated` (it denies everything, so it masks nothing); 2 `missing_entitlement` in any enrollment-lesson -> (ii) `missing_entitlement`; 3 `unmapped_revision` -> (ii) `unmapped_revision`; 4 legacy passes only through `completed_at` -> (ii) `completed_at_only`; 5 `unlock_at_later` in any enrollment-lesson (a later `unlock_at` for a started cohort or a rolling enrollment) -> (ii) `unlock_at_later`; 6 any held row -> (i) `held`; 7 any revoked row -> (i) `revoked`; 8 pre-cohort AND the student has no pair whose base cause is a blocking cause -> (i) `cohort_not_started`; 9 pre-cohort AND the student has at least one blocking pair -> (ii) `cohort_not_started_with_blocking_cause`. This tightens the D-277-3 first-match order: held and revoked no longer win when blocking evidence exists. It is more conservative for the GO gate and stays within D-277-3 and D-277-4, so it needs no new user decision (Planner-accepted).
   - **Blocking causes** (student level, across all of the student's active enrollments): `missing_entitlement`, `unmapped_revision`, `completed_at_only`, `unlock_at_later`. Intentional causes (`held`, `revoked`, `account_deactivated`) do not demote a pre-cohort pair. Implementation is two-pass: compute each pair's base cause from steps 1 to 7 (treating pre-cohort pairs as not blocking), aggregate `student_has_blocking` per user, then assign steps 8 and 9. Gains (iii) are unchanged.
   - **Output:** summary rows report `cohort_not_started` counts in class (i) so the user sees them; the decision row still counts class (ii) only; GO only when class (ii) is zero (D-277-3 unchanged). The script header comment's sentence "There is NO cohort exception (J-277A-2)" is replaced with the D-277-4 rule and order. Work continues on PR #299 (branch `fix/277a-feedback-policy-alignment`, head `cd5f470` at planning; re-verify at Step 0).
   It also confirms that existing `feedback_submissions` rows are untouched (the policy is insert-only).
2. **GO/NO-GO rule (D-277-3).** GO only if the class (ii) count is zero (Revision 2: class (ii) includes `cohort_not_started_with_blocking_cause`; `cohort_not_started` rows are reported in class (i), D-277-4). On NO-GO, do not apply 277a; report the counts to the user. Any repair of class (ii) runs only through a separately approved, logged, data-preserving process outside this plan (precedent: the 5c-1 access-preserving repair approach, D-198-2); then the preview is rerun.
3. **Preview equivalence test (local).** For at least four fixture students covering open, held, released-early, cohort late joiner, inactive enrollment and password-change cases, assert that the set-based prediction equals the actual authenticated insert outcome under each student's JWT context.
3a. **D-277-4 tests (Revision 2; live SQL, local fixtures; assert the preview's rows).** The equivalence test in item 3 is unchanged: D-277-4 changes classification only, never the `legacy_allows` or `canonical_allows` values.
   - T-277-4a pure pre-cohort (active cohort enrollment, `starts_at` = t + 7 days, old `enrollment_date` so legacy passes, mapped open-candidate rows, nothing else wrong) -> class (i) `cohort_not_started`, decision GO.
   - T-277-4b pre-cohort plus `missing_entitlement` -> NO-GO, two variants: same pair (no entitlement row, so `missing_entitlement` wins) and same student, another lesson (the pre-cohort pair becomes `cohort_not_started_with_blocking_cause`).
   - T-277-4c the same two variants for `unmapped_revision`.
   - T-277-4d the same two variants for `completed_at_only`.
   - T-277-4e a plain later `unlock_at` for a started cohort (`starts_at` in the past, `unlock_at` later than both now and the legacy date) -> (ii) `unlock_at_later`, NO-GO.
   - T-277-4f a rolling enrollment with a later `unlock_at` -> (ii) `unlock_at_later`, NO-GO.
   - T-277-4g pre-cohort plus a held lesson for the same student -> still GO (pins that intentional causes do not demote).
   - T-277-4h (Revision 2a) for one lesson, a held row in enrollment A plus a `missing_entitlement` (or `unmapped_revision`) case in enrollment B for the same student, plus a separate pure pre-cohort lesson -> NO-GO; the held-plus-blocking lesson is class (ii); the pre-cohort lesson is `cohort_not_started_with_blocking_cause`.
   - T-277-4i (Revision 2a) the same as T-277-4h with a revoked row.
   - T-277-4j (Revision 2a) held in enrollment A and open in enrollment B for the same lesson -> unchanged (the canonical rule allows), confirming no false loss.
4. RED live SQL tests. As an authenticated student, insert succeeds for an open lesson, a released-early lesson and a cohort-anchored late joiner. It fails for held, revoked, future-locked, no entitlement row, a lesson of another band, inactive enrollment, deactivated account, forced password change, and `lesson_id` with null `band_id`. General feedback (both null) succeeds. Course-only feedback (`band_id`, null lesson) succeeds for an active band enrollment. `user_id` spoofing fails.
5. Migration `supabase/migrations/<ts>_issue277_feedback_insert_entitlement_rule.sql`: `begin; set local lock_timeout '5s'; statement_timeout '60s'`; `drop policy if exists` plus `create policy students_insert_feedback` with the same structure as `202608280002` except the time-based predicate and `completed_at` branch are replaced by `public.student_can_read_legacy_lesson(feedback_submissions.lesson_id)` (keep the lesson and band join, `band_id` not null, active band enrollment, `user_id = auth.uid()`, password-change and account-active checks, the general branch); `comment on policy`; create `get_feedback_lesson_rule_capability()` with the grants in 5.1; `commit`. No table, column or row change.
6. Rollback `supabase/rollbacks/issue277_feedback_insert_entitlement_rule_rollback.sql`: restore the `202608280002` policy text exactly and drop `get_feedback_lesson_rule_capability()`; a test that the rollback restores behavior.
7. Catalog tests: the policy exists, is insert-only, and targets the intended roles; the capability function exists with EXECUTE `authenticated` only and returns the expected value.

### 6.4 PR 277b (Closes #277; frontend; merges only after hosted H277-1 is verified)

1. RED RTL tests for: the states in 4.3; `aria-describedby` association; the capability hook (positive cached, definitive-missing cached, HTTP 500 not cached and re-probed on remount and on Try again, pending then positive adds options without touching the selection); the list rule per mode and capability (entitlement, compat, legacy, fail closed); the three-part rejection classification, with a refetch that still shows 'open' and a refetch failure both keeping the existing error; capability invalidation on a lesson-scoped 42501 with the refetch still open; the reset status line appearing once with no duplicate after a rejection; Try again throttle bypass (`refetch({ force: true })`); the focus chain after a retry success with an empty result (Course select or the next enabled target, never body); focus return to submit after a failure; and the legacy helper used only in fallback and compat mode.
2. Implement in `FeedbackForm.tsx` using `useRoadmapWeekStates` for the selected course's enrollment (map access 'open' weeks to `LessonRow` through `legacyLessonId` or `weekNumber`, decided at Step 0 and tested) and the capability hook. Add `SelectField` `aria-describedby`. Strings as designed. Keep `isLessonUnlockedForFeedback` for fallback mode and the compat rule.
3. New e2e spec (for example `src/__tests__/e2e/issue277-feedback-lessons.spec.ts`) per the section 8 journeys, including:
   - Normal path (new frontend with 277a, capability positive): released-early and cohort late-joiner lessons are listed and accepted.
   - S1 (new 277b frontend, mirror without 277a, capability unavailable): the released-early lesson is absent, an open lesson that passes the legacy rule is present and accepted, a held lesson is absent, and no rejection message appears.
   - S2 (old frontend at base, mirror with 277a): a held lesson listed by the old legacy rule is rejected with the existing generic error and the text is kept; a released-early lesson is not listed.
   - S3 (new frontend after the 277a rollback): same expectations as S1.

### 6.5 PR 276a (Refs #276; backend migration) (Revision 2)

Option A mechanism superseded by Revision 2 (D-276-1 option C); see Revision 2 block. No instruction below uses a policy-helper swap or a `FOR UPDATE` on `storage.objects` in finalize.

1. **276.0 record (completed spike).** F276-8 is the result: option A and option B are disproven locally (option A failed 3 of 3; a waiting `FOR UPDATE` deadlocked with Storage; the status freeze has the same hole because Tx2 bypasses RLS).
2. **276.0b spike** (local mirror, real Storage API; production untouched). Environment: record the Storage image version; run on the CLI default image AND on the image matching the hosted Storage version (the user reads the hosted Storage version from the Supabase Dashboard; pin it in the mirror only through `supabase/.temp/storage-version`, never committed) (D-276-8). Install the draft 276a migration locally. Inside the trigger, a local-only diagnostic records `current_user`, `session_user` and `current_setting('storage.operation', true)` for each operation. Each case has recorded runs and deterministic ordering through `pg_stat_activity` waits (advisory waits included); no sleeps except the finalize-delay injection used in 276.0. Cases:
   - (1) 40 MB owner upsert on a staged version vs Edge finalize, delays 180, 220, 260 ms, both orders, at least 10 runs per delay. Upsert first: finalize raises `asset_changed_since_registration` and the version stays staged. Finalize first: the upsert is refused, the version is published, and a download hash of the served object equals the verified sha256.
   - (2) Owner DELETE vs finalize, both orders; a DELETE on a published prefix is refused and the object stays downloadable.
   - (3) `service_role` MOVE of a published non-handout object (the removed-assets path) is refused and the source is intact; the same on a draft is allowed.
   - (4) Handouts: signed upload and the quarantine move `handouts` -> `handouts-quarantine` under a published version are allowed; a move from a published non-handout path INTO a handouts path is refused (OLD and NEW names both checked).
   - (5) An UPDATE that changes only `last_accessed_at`, `owner` or `owner_id` (the `updateObjectOwner` equivalent, as `service_role`) is allowed.
   - (6) **Synthetic, the only exemption-positive case.** A simulated Storage-admin backfill UPDATE as `supabase_storage_admin` with `storage.operation` unset is allowed (D-276-1C.2); the same statement with `storage.operation` set is refused on a published prefix. Pass condition (Revision 2a): no API write in any case matches the exemption predicate.
   - (7) Zero 40P01 across all runs, with finalize taking no `storage.objects` row lock.
   - (8) Versioning: record the `lesson-assets` `versioning_status` and whether `archived_at` and `is_delete_marker` exist; if the columns exist, an `archived_at` change on a published row is refused.
   - (9) DROP TRIGGER and the full rollback run as `postgres` (local `postgres` may be superuser; hosted relies on supautils `drop_trigger_grants`, checked at H0).
   - (10) The owner UI on a refused upsert shows the existing upload failure copy and no raw database text (if this case runs the UI, start one vite server and stop it by PID).
   - (11) Overhead: the WHEN clause short-circuits other buckets and non-guarded column changes; record timings.
   - (12) (Revision 2a, real API, no synthetic SQL) A TUS resumable overwrite of an object whose prefix is staged when the upload starts, completed after finalize publishes.
   - (13) (Revision 2a, real API) An S3-protocol multipart overwrite completed after publish.
   - (14) (Revision 2a, real API) Storage COPY onto an existing destination under a published prefix.
   - (15) (Revision 2a, real API) Failure-cleanup paths: the upload outer-catch cleanup, the move and copy uncommitted-copy cleanup, and the remove batch path. Show that cleanup deletes only the new, uncommitted version's bytes.
   - Every case runs on BOTH pinned Storage images (D-276-8). For every API write case, (1) to (5) and (12) to (15): record the observed `current_user`, `session_user` and `current_setting('storage.operation', true)` inside the trigger; after each rejection, check that the download hash of the served object equals the verified sha256; and assert that EVERY Storage API write FAILS the upgrade-exemption predicate (D-276-1C.2).
   - **Implementation gate (J-276-R2-1).** The full 276.0b ledger (all cases, both images, identities, operation values, hash checks) must pass before the 276a RED tests and the migration are finalized and before 276b starts. If any API write matches the exemption predicate, there is no exemption and the user decides on R15.
   - S22 (the two-int advisory key space does not overlap Storage's bigint object locks) is verified here. Any failure stops 276a and is reported; no switch of direction without re-approval (D-276-6).
3. **RED live SQL tests** (replace the Revision 1 cases (a) to (k)), with two or more pg connections and deterministic ordering (wait on `pg_stat_activity` `wait_event_type = 'Lock'`, advisory waits included, never sleeps):
   - (a) a committed overwrite before finalize -> finalize raises `asset_changed_since_registration`; (b) a committed or in-flight DELETE before finalize -> raise.
   - (c) finalize holds the exclusive lock -> an UPDATE or DELETE of a guarded row waits in the trigger, finalize commits, the statement raises `lesson_asset_immutable`, and the row is intact.
   - Guard-only tests: a published-prefix UPDATE of name, bucket_id, version or metadata raises; a `last_accessed_at`-only UPDATE passes; the handouts both-names rule; other buckets untouched; draft and staged prefixes untouched; an orphan uuid prefix (no version row) untouched; `supabase_storage_admin` with `storage.operation` unset passes.
   - (e) no deadlock; (f) happy path publishes; (g) input validation (a missing object, mismatched sha, extra or unknown path in `p_verified_objects`, or an empty array when the manifest names assets raises); (h) `newer_version_current` and the issue233 tests stay green.
   - (i) EXECUTE grants on the overload (`service_role` only), and the trigger function has no EXECUTE for `anon` or `authenticated` beyond what the trigger needs.
   - (j) `remove_course_asset` and stage paths are unaffected.
   - (k) **required:** real Storage API concurrency (from 276.0b) in 276a and 276b validation.
   - (l) `lock_timeout` in finalize -> 55P03 surfaces.
   - (m) (Revision 2a) A concurrent overwrite through an UPPERCASE version-prefix path vs finalize, in both orders. The guard and finalize must contend on the same key: finalize waits or raises, and an update after publish is refused.
   - (n) (Revision 2a) A unit test that the key for the uppercase and lowercase forms of the same version id is equal.
4. **Migration** `supabase/migrations/<ts>_issue276_lesson_assets_publish_guard.sql` (`begin; set local lock_timeout '5s'; statement_timeout '60s'; commit`), additive:
   - Key helper (D-276-1C.5, Revision 2a): `public.lesson_asset_version_lock_key(p_version_id uuid)` returning (int, int), in the two-int advisory form `pg_advisory_xact_lock(<fixed int4 class id>, hashtext(p_version_id::text))` so it never collides with Storage's bigint object-lock space (RE-276 C18; verify S22 in the spike). The argument is the `uuid` type: the guard casts the validated first path segment with `split_part(name,'/',1)::uuid` and finalize passes `course_versions.id`, so the only text form hashed is `uuid::text`, which is canonical lowercase. Raw path text is never hashed. Reason (Observed): `src/lib/courseAssetIntegrity.ts:7` `UUID_RE` has the `/i` flag and `:22` compares lowercased, and the guard's uuid regex accepts A-F. Used identically by the trigger and finalize.
   - `public.lesson_assets_publish_guard()` plpgsql, VOLATILE, SECURITY DEFINER, owner `postgres`, fixed `search_path` (`pg_catalog`, `public`), REVOKE ALL from `public`, `anon`, `authenticated`, `service_role` (trigger functions do not need caller EXECUTE; verify in the spike and grant only if required). Logic: return early when (D-276-1C.2) the session or current role is `supabase_storage_admin` and `storage.operation` is unset (capture `current_user` before any SECURITY DEFINER effect, for example via `session_user` and a SECURITY INVOKER wrapper if needed; the spike decides the exact discriminator). For each of OLD.name and (UPDATE) NEW.name in bucket `lesson-assets`, skip names matching `/handouts(-quarantine)?/`; derive the version uuid from the first path segment with the same guarded uuid regex as `owns_mutable_lesson_asset_path`; for each guarded name take `pg_advisory_xact_lock_shared` on the key, then, in a separate statement (fresh read-committed snapshot), read `course_versions.status`; if a version row exists and status is not in ('draft','staged'), raise errcode P0001 with message `lesson_asset_immutable` (stable, no path or id in the text). UPDATE is guarded only when any of name, bucket_id, version, metadata, `archived_at`, `is_delete_marker` differs, compared through `to_jsonb(OLD)` and `to_jsonb(NEW)` key reads so absent columns compare as null (D-276-1C.1). DELETE is always guarded for `lesson-assets`.
   - Triggers: `lesson_assets_publish_guard_upd` BEFORE UPDATE FOR EACH ROW WHEN (OLD.bucket_id = 'lesson-assets' OR NEW.bucket_id = 'lesson-assets'); `lesson_assets_publish_guard_del` BEFORE DELETE FOR EACH ROW WHEN (OLD.bucket_id = 'lesson-assets'). The names sort before `update_objects_updated_at`, so the guard fires first (that built-in ignores `updated_at`).
   - `public.finalize_publish_job(p_job_id uuid, p_verified_objects jsonb)`, SECURITY DEFINER, function-level `SET lock_timeout = '5s'`: same body and lock order as `202610120001` (`courses` -> `publish_jobs` -> `course_versions` FOR UPDATE), then `pg_advisory_xact_lock` (exclusive) on the version key, then a plain SELECT (no FOR UPDATE or FOR SHARE, no NOWAIT needed) of the `storage.objects` rows for every verified `course_assets` row of the version whose sha is in the manifest, comparing path, object id, eTag, size, `updated_at` (and `version` when the Edge stamp carries it) with `p_verified_objects`, and sha256 with `course_assets.sha256`. Any mismatch, missing or extra entry raises P0001 `asset_changed_since_registration`; then publish (D-276-1C.4). Revoke all from `public`, `anon`, `authenticated`; grant execute to `service_role`. The one-argument function is unchanged (D-276-4).
   - Owner storage policies untouched (D-276-1C.3). No table, column or row change.
5. **Rollback** `supabase/rollbacks/issue276_lesson_assets_publish_guard_rollback.sql`: `DROP TRIGGER IF EXISTS` both triggers on `storage.objects`; drop the guard function, the key helper and the overload. No data touched; policies were never changed. Emergency containment is the same DROP TRIGGER statements (DISABLE TRIGGER is not available to `postgres` on hosted, F276-12).
6. **Preview SQL** `scripts/audit/issue276-finalize-preview.sql` (read-only, `BEGIN TRANSACTION READ ONLY ... ROLLBACK`), extended with the H0 trigger-feasibility checks: `relowner` of `storage.objects`; `has_table_privilege('postgres','storage.objects','TRIGGER')` and `'UPDATE'`; `pg_has_role('postgres','supabase_storage_admin','MEMBER')`, `rolsuper`, `rolbypassrls`; `current_setting('supautils.drop_trigger_grants', true)` and `'supautils.policy_grants'` (null is inconclusive, not a failure); the `pg_trigger` list on `storage.objects` (non-internal, with definitions); the `pg_event_trigger` list; `storage.objects` columns (are `archived_at`, `is_versioned`, `is_delete_marker` present?); `storage.buckets` `versioning_status` for `lesson-assets` if the column exists (expect DISABLED); the latest 5 `storage.migrations` names; `has_schema_privilege('postgres','public','CREATE')`; the existing staged-version and queued or failed `publish_jobs` counts; and the pending migrations list. The user also records the hosted Storage version from the Dashboard. Pass criteria: TRIGGER privilege true, no event trigger that blocks CREATE TRIGGER on `storage`, versioning DISABLED or columns absent. **Removal prerequisite (Revision 2a, J-276-R2-3).** A confirmed hosted removal mechanism for the triggers is a PREREQUISITE for H276-1. Accepted evidence is any one of: (a) the H0 read of `supautils.drop_trigger_grants` shows `storage.objects` covered for `postgres`; (b) a separately approved H0b transactional validation (`BEGIN; SET LOCAL lock_timeout '2s'; CREATE TRIGGER` (the guard) `...; DROP TRIGGER ...; ROLLBACK;`) showing both statements succeed as `postgres`; (c) a verified alternative operator with removal authority (for example a Supabase support-confirmed path), recorded in evidence. Result mapping: an explicitly missing grant = FAIL (do not apply; D-276-6 applies); inconclusive (the setting is unreadable) = (b) or (c) is required; documentary confidence (RE-276 C6) alone is NOT sufficient (D-276-7).

### 6.6 PR 276b (Closes #276; Edge plus owner copy; Edge deploy only after hosted H276-1)

1. RED Edge-live tests (local mirror):
   - finalize with bytes overwritten after verification gives 409 `asset_changed_since_registration` and the version stays staged;
   - a stamp change during hashing gives 409;
   - the happy path publishes;
   - with the overload missing and an intervening overwrite: 503 `finalize_unavailable`, the version stays staged, the job is unchanged, nothing publishes;
   - after the 276a rollback file runs, the new Edge fails closed the same way;
   - after the local equivalent of H276-3 (EXECUTE on the one-argument function revoked from `service_role`), the one-argument call fails for `service_role`;
   - real Storage API concurrency with an Edge finalize (required, see 6.5 item 2k);
   - unit tests for `mapPublishError` order for stage, finalize and retry, including `finalize_unavailable` mapping to `PUBLISH_COPY.finalizeFallback`.
2. Edge `index.ts` `finalize_publish`: replace the `changedRegisteredAsset` use with a verifier that, per manifest asset, reads the stamp, hashes, re-reads the stamp and requires equality (`sameStamp`, as `register_asset` does), collects `{storage_path, sha256, id, etag, size, updated_at}`, then calls `rpc('finalize_publish_job', { p_job_id, p_verified_objects })`. Map P0001 `asset_changed_since_registration` to HTTP 409 `{ error: 'asset_changed_since_registration' }`. When the overload is missing (PGRST202, HTTP 404 or 42883), return HTTP 503 `{ error: 'finalize_unavailable' }` and never call the one-argument function. Keep the `newer_version_current` mapping. Never return raw Postgres text. Stage keeps its check (optional: the same stamp re-check).
3. `src/lib/publishingErrors.ts`: add `PUBLISH_COPY.assetChanged` and the ordered branches per section 4.5.
4. Browser validation journey 16 (route-intercepted 409 and 503 variants on stage, finalize and retry) plus a real local overwrite race reproduced through the Edge.
5. **Revision 2 additions** (the Edge changes above stay: stamp re-check verifier, overload call, 409 mapping, 503 `finalize_unavailable` fail closed, never the one-argument call):
   - Map finalize 55P03 (lock timeout) and 40P01 to HTTP 503 `{ error: 'finalize_busy' }` (stable; the version stays staged).
   - Include the object `version` in the stamp only if the Edge can read it without new privileges; otherwise compare id, eTag, size and `updated_at` (the spike decides).
   - Removed-assets move refusal by the guard: log a stable warning code (no raw text) and keep the 200 response (the row delete is committed; bytes stay and are never deleted) (D-276-9).
   - `publishingErrors` maps `finalize_busy` to the existing `finalizeFallback`, with a unit test.
   - RED Edge-live tests add: the `finalize_busy` mapping under a held exclusive lock; an owner upsert refused after publish leaves the served bytes equal to the verified sha (real Storage API).

## 7. Acceptance and validation

Per PR:

- Step 0 recorded.
- `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`.
- Full `npx vitest run` on a freshly reset local stack, with no new failures versus the recorded baseline.
- RED shown failing then passing (record both).
- Every new or modified Playwright spec run at least 8 consecutive times with every run recorded (program precedent); for 291 the counts in 6.1 step 291.4.
- Verifier PASS.
- Browser Validator PASS for 290, 277b and 276b.
- CODE_REVIEW where routed (section 9).
- The deterministic no-native-dialog scan returns zero product hits.
- The PR is opened against `main` with the right Closes or Refs line. No merge by the fleet.

Additional per-PR requirements:

- **277a:** the set-based preview equivalence test passes for the fixture students (6.3 item 3); the capability function catalog test passes; the preview output format reports classes (i), (ii) and (iii) so the GO/NO-GO decision is mechanical. Revision 2: the D-277-4 tests T-277-4a to T-277-4j (6.3 item 3a) pass.
- **277b:** the capability, compat-rule and rejection-classification tests (6.4 item 1) pass; the skew runs S1, S2 and S3 and the normal-path run are recorded with their exact expectations.
- **276a and 276b (Revision 2):** the 276.0b spike ledger (both Storage images, all 15 cases, identities, operation values and served-hash checks) is an implementation gate: it is recorded and passes before the 276a RED tests and the migration are finalized and before 276b starts; the required real Storage API concurrency test (6.5 item 2 case 1 and item 3 case k) passes on the image matching hosted and its runs are recorded; zero 40P01; the rollback and DROP TRIGGER run; overhead is recorded; the fail-closed and `finalize_busy` Edge tests (6.6) pass. The dev-server rule in the standing constraints applies to every spike and validation run: at most one dev server per browser validation, PIDs recorded, stopped by PID, final port check; the spike needs no dev server unless case (10) runs the owner UI, in which case one vite server is started and stopped by PID.

Specific checks per PR are in section 6 and the section 8 journeys.

## 8. Browser UI dialog policy and browser validation

### 8.1 Dialog policy

Required for #290, #277b and #276b. No `alert`, `confirm`, `prompt`, `window.alert`, `window.confirm`, `window.prompt` or `beforeunload`. No modal is introduced, so the modal keyboard and focus check is recorded as not applicable; any future acknowledgement uses the app-owned `src/components/Modal.tsx`. Status uses inline `role="status"` (polite) and `role="alert"` regions.

Verification: the deterministic source scan `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` (zero product hits) and a failing `page.on('dialog')` listener in every journey. Keyboard and focus checks per section 4 (tab order; Try again with Enter and Space, including the `aria-disabled` no-op; focus returns to submit after failure; focus never on body in the form; the post-retry focus chain per 4.3).

### 8.2 `browser_ui_validation`

- **Mirror:** the port-shifted untracked mirror `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` (`supabase/config.toml` API 64321, DB 64322, studio 64323; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`). Windows reserves 54314-54413. Copy PR files per file, never `robocopy /MIR`. Never commit the mirror. CSP port patches stay local-only and are never committed. For skew S1 keep the mirror DB at the base (no new migration) and serve the PR frontend; for S2 serve the base frontend against the PR migration; for S3 apply the migration then its rollback and serve the PR frontend. For 276b, also serve the PR Edge against a mirror DB without 276a (overload missing) and after the 276a rollback, and expect 503 `finalize_unavailable` with no publish.
- **Launch and readiness:** `npx supabase start`; `npx supabase db reset`; `docker restart supabase_rest_lizbeth_spanish supabase_kong_lizbeth_spanish` after a migration change (PostgREST schema reload; the first request may return 502); `npx vite --host 127.0.0.1 --port 5180 --strictPort`; ready when `http://127.0.0.1:5180` serves sign-in.
- **Dev-server hygiene (user rule):** at most one dev server per browser validation at a time. Record the PID of every server started (vite, and `netlify serve` if used) and stop each by PID (`Stop-Process -Id <pid>`) when its run ends. Nothing is left running. Confirm at the end that nothing listens on 5180 (`Get-NetTCPConnection -LocalPort 5180` returns none). More than one server only intentionally (for example a base-frontend comparison for S2), with both stopped afterwards. Skew runs are sequential, with the frontend server stopped between them. Stop the mirror stack with `npx supabase stop` at the end unless the coordinator says to keep it. The PID record and final port check are evidence.
- **Test environment:** `SUPABASE_API_URL=http://127.0.0.1:64321` (or `LIZBETH_TEST_API_PORT=64321`), `SUPABASE_DB_PORT=64322`, `SUPABASE_SERVICE_ROLE_KEY` and `SUPABASE_ANON_KEY` from `npx supabase status`, `E2E_BASE_URL=http://127.0.0.1:5180`; `npx playwright test <spec> --workers=1`.
- **Base URL:** `http://127.0.0.1:5180`.
- **Fixtures and reset:** `db reset` plus seed (owner@test.local, student1@test.local, fullaccess@test.local; password "password"). Per-journey disposable fixtures through `src/__tests__/e2e/course-fixtures.ts` and direct entitlement rows (open, released-early, future-locked, later-today unlock, next-day under 24 h unlock, held, revoked, no entitlement, cohort-anchored late joiner). Browser time zones through context `timezoneId` and a pinned clock (`context.clock.setFixedTime`, the `pinPageClock` precedent). Owner Publishing 409 and 503 variants through route interception, plus a real local overwrite race and real Storage API concurrency for 276b. Loopback-guarded cleanup of rows and courses the test created. Site language reset to English after any Spanish check.

### 8.3 Journeys and visible outcomes

1. Card, same local day: "OPENS {today} · TODAY".
2. Next local day, including 23:30 to 00:30: "IN 1 DAY".
3. n of 2 or more: "IN {n} DAYS".
4. Stale TODAY, never negative, resolves after refetch or focus revalidation.
5. Footer: "Unlocks today." / "Unlocks in 1 day." / "Unlocks in {n} days.", never "Unlocks in today".
6. Fallback path (route-intercepted PGRST202): footer with exactly one period and no ".." on the footer or `BandRoadmap`.
7. Zones America/Los_Angeles, Pacific/Auckland, and DST day 2026-11-01 America/New_York, with printed date and label agreeing.
8. Lesson select, server mode: excludes a week the legacy rule would show but the server says is locked, and matches the roadmap's open weeks (capability positive).
9. After 277a, an entitlement-open week the legacy rule rejects (released early, cohort late joiner) is listed and its submit succeeds.
10. Lesson select states with screenshots: no course, loading (delayed request), server list, zero open, fallback, error, revalidating.
11. Try again repeat failure keeps focus on the button; success moves focus only if focus was inside the warning, per the focus chain.
12. `aria-describedby` association per state.
13. Skew S1 and S3 (capability unavailable): released-early lesson absent, an open legacy-passing lesson present and accepted, held lesson absent, no rejection message.
14. Lesson-scoped 42501 where the forced refetch still shows 'open': the existing error shows, and the cached capability is invalidated so the next list uses the compat rule.
15. Selection reset line shown once.
16. Publishing 409 `asset_changed_since_registration` and `asset_changed_during_registration` on stage, finalize and retry show the `assetChanged` string naming "Build and stage publish"; a plain 409 or `newer_version_current` shows `newerVersion`; 503 `finalize_unavailable` shows the existing `finalizeFallback` string; (Revision 2) 503 `finalize_busy` shows the existing `finalizeFallback` string.
17. S2 for 277 (base frontend plus 277a): generic error with text kept.
18. Keyboard-only pass of FeedbackForm.
19. Capability HTTP 500: compat list, no capability text in the UI.
20. Capability pending then positive: weeks are added without touching the current selection.
21. Mid-session pause: submit gives the exact rejection message, the refetch removes the lesson, no duplicate reset line appears, and a General / no lesson resend succeeds with the text intact.
22. Rejection with a failed forced refetch: the existing error shows.
23. Retry success with an empty result: focus lands on the Course select (or the next enabled target), never body.

### 8.4 Viewports and evidence

- Viewports: 1440x900, 390x844, 320x568, plus 200% zoom at 1440. Forced colors at 1440x900 and 320x568 for the FeedbackForm states and a locked card.
- Visible outcomes summary: correct calendar-day labels in every zone; grammatical footers; no double periods; Lesson list equal to the rule for its mode; inline, calm, honest messages; no horizontal scroll at 390 and 320; visible focus; no raw backend text; no native dialog.
- Evidence: screenshots per journey, state, viewport and zone; network logs for skew, capability and refetch; the 291 run ledger; the 276 concurrency run ledger; the PID record and final port check. Stored under `browser-validation-artifacts/<pr>/`, never committed unless the repository already tracks that path (follow repository convention).

## 9. Judge route

Shadow (advisory) per `docs/JUDGE-CONTRACT.md`. Codex model `gpt-6-astra`, effort medium. Respect the two and four call caps; deterministic failures dominate; no live Codex call occurs without explicit usage approval.

| Checkpoint | Requiredness |
|---|---|
| PLAN_DUCK on this draft | Run once (Revision 1 above); a further run is eligible before approval, orchestrator-run; Revision 2: PLAN_DUCK on Revision 2 is eligible before approval (orchestrator-run, usage approval required) |
| CODE_REVIEW | Required for PR 276a and 276b (Revision 2: guard trigger on `storage.objects`, advisory key, Storage-admin exemption, finalize overload, Edge binding and fail-closed path) and PR 277a (RLS policy replacement, capability function); recommended for 277b and 290; optional for 291 (test-only) |
| VERIFICATION_CHALLENGE | Optional for the 276 concurrency proofs, the 276.0b ledger (which is also an implementation gate, J-276-R2-1), the 277a preview equivalence and the D-277-4 tests, and the 291 root-cause evidence |
| VISUAL_REVIEW | Optional for 290 and 277b |

Finding IDs flow into the PR record and the Verifier brief for that PR. No judge pass beyond the one recorded in Revision 1 is promised.

## 10. Risks, rollback and hosted rollout

### 10.1 Risks

| Id | Risk | Mitigation |
|---|---|---|
| R1 | (Revision 2) #276 hosted privileges or Storage structure differ (TRIGGER privilege, event triggers, versioning, hosted Storage version). | H0 read-only checks; 276.0b on the hosted-matching image; stop and re-plan per D-276-6. Option A mechanism superseded by Revision 2 (D-276-1 option C); see Revision 2 block. |
| R2 | (Revision 2) #276 lock order. | Storage takes its object advisory lock and the object row lock, then the guard takes the shared version lock; finalize takes course, job and version row locks, then the exclusive version lock, then only a non-locking read of `storage.objects`, so finalize never waits on an object row lock and no cycle exists (RE-276 C18; the spike's 40P01 came from `FOR UPDATE`). Owner and Storage writes take no course, job or version row locks. The two-int advisory key space avoids Storage's bigint locks. Finalize `lock_timeout` 5s -> 503 `finalize_busy`. (Revision 2a) The key helper takes a `uuid`, so uppercase and lowercase path prefixes hash to the same key (RED test 6.5 item 3 case m). |
| R3 | (Revision 2) #276 trigger overhead on every `storage.objects` UPDATE and DELETE. | WHEN clauses and early return; measured in 276.0b case 11; the rollback drops the triggers. |
| R4 | #276 Edge and DB skew (Revision 2, D-276-5). | The new Edge fails closed (503 `finalize_unavailable`) when the overload is missing, so it cannot publish unbound. D-276-3 supersedes the #276 issue sentence that a new Edge against the previous function "keeps Publishing working" (D-276-5). The old Edge's post-publish window is closed by the guard once H276-1 applies; binding order H276-1 before Edge deploy. |
| R5 | #277 access change on a live table. | Read-only set-based preview H0 with counts by class; GO only if the potential-legitimate-loss class is zero (D-277-3; classes per D-277-4); insert-only policy, existing rows untouched; exact-restore rollback; binding order; capability signal and compat rule; S1/S2/S3 runs; post-apply parity check. |
| R6 | #277 students lose the ability to tag feedback to held, revoked or completed-only lessons. | Intended alignment with the canonical rule (D-198-2 precedent), reported as class (i), including the pure `cohort_not_started` case (D-277-4); class (ii) must be zero or 277a does not apply; counts let the user decide (D-277-1). |
| R7 | #290 changes a pinned contract (#287 J3). | Rewrite, do not delete; Step 0 reads #287 and #290; zone and DST tests. |
| R8 | #291 fix masks a real product race. | Root-cause classification with evidence; product fix if indicated; no retries or sleeps. |
| R9 | Hosted migration ordering: `supabase db push` applies every pending migration. | Apply 277a and 276a only after earlier pending migrations (including 293a) have their own approvals, or together only with explicit approval naming each. |
| R10 | Spanish draft release. | The new ES key follows D-5c2-5; Lizbeth approves before publish. |
| R11 | Multiple enrollments per band (first match). | Pre-existing; recorded limit. |
| R12 | Window between H276-1 and H276-2 in which the old Edge still calls the one-argument finalize (Revision 2: the guard closes post-publish changes once H276-1 is applied, so only the pre-commit overwrite window remains). | Run H276-1 and H276-2 back to back in one approved window; then H276-3 revokes EXECUTE on the one-argument function from `service_role`. |
| R13 | The set-based preview diverges from the real helper. | Local equivalence test for fixture students; hosted read-only parity spot check at H277-1; stop and reapproval if they differ. |
| R15 | (Revision 2) A Supabase Storage upgrade backfill is blocked by the guard. | The `supabase_storage_admin` plus `storage.operation`-unset exemption (D-276-1C.2); after any Supabase Storage upgrade the user runs the read-only `pg_trigger` check from the preview; containment is the rollback DROP TRIGGER statements (no data touched), then re-plan. (Revision 2a) Containment is only available if a hosted removal mechanism was confirmed before H276-1 (6.5 item 6, H0 and H0b). |
| R16 | (Revision 2) The owner sees a generic upload error when the guard refuses (Storage wraps the raise, RE-276 C8). | Acceptable: the owner can only hit it in the publish race; no raw text is echoed (276.0b case 10). |
| R17 | (Revision 2) The exemption could weaken the guard if hosted Storage performs API writes as `supabase_storage_admin` with `storage.operation` unset. | 276.0b case 6 diagnostic on the hosted-matching image; if the discriminator is not reliable, stop and ask the user (exemption off raises R15). |
| R18 | (Revision 2) Storage upload gap: a refused upsert's outer catch may delete the new version's bytes only (RE-276 C12). | The old bytes stay; verified by download hash in 276.0b case 1. |
| R14 | Compat mode silently omits released-early weeks the roadmap shows open (C3). | Transitional by design; only occurs while 277a is absent or rolled back; recorded limit. |

### 10.2 Rollback

- 290, 277b, 276b frontend: revert the PR (Netlify redeploy).
- 277a: run the rollback (restores the `202608280002` policy text and drops the capability function). 277b then reads the capability as definitive-missing and uses the compat rule, or, if its cached answer was positive, invalidates it on the first lesson-scoped 42501 with the refetch still open (C2).
- 276 (Revision 2), in this order:
  1. If H276-3 ran, re-grant EXECUTE on `public.finalize_publish_job(uuid)` to `service_role` (re-grant statement, section 10.3).
  2. Redeploy the previous Edge function version.
  3. Run the 276a rollback (drops both triggers on `storage.objects`, the guard function, the key helper and the overload). No policy restore is needed in Revision 2; no data is written.
  A new Edge left against a rolled-back DB fails closed: no publish and no race. This order leaves no window in which the previous Edge lacks EXECUTE.
- 291: revert.
- No data is written by any migration, so nothing needs restoring.

### 10.3 Hosted rollout (each step separately approved; the user runs hosted actions)

| Step | Action |
|---|---|
| H0 | Read-only previews: the pending migrations list; `scripts/audit/issue277-feedback-policy-preview.sql` (class counts per D-277-3 and D-277-4, and the GO/NO-GO result); `scripts/audit/issue276-finalize-preview.sql` (Revision 2: adds the trigger-feasibility checks of 6.5 item 6); the user also records the hosted Storage version from the Supabase Dashboard. (Revision 2a) The H0 `supautils.drop_trigger_grants` read maps to: covers `storage.objects` for `postgres` = removal evidence (a); explicitly missing = FAIL (do not apply, D-276-6); unreadable = inconclusive, so H0b or a verified alternative operator is required. |
| H0b | (Revision 2a, required when the H0 removal result is inconclusive, separately approved, not scheduled, D-276-7) `BEGIN; SET LOCAL lock_timeout '2s'; CREATE TRIGGER` (the guard) `...; DROP TRIGGER ...; ROLLBACK;`. Both statements must succeed as `postgres`. It takes a brief lock on `storage.objects` and is DDL even though rolled back. |
| H277-1 | Only on GO: apply 277a (after R9). Verify the policy text and the capability function read-only. Then run the hosted parity spot check (read-only): inside `BEGIN READ ONLY; SET LOCAL ROLE authenticated;` with `set_config('request.jwt.claims', ...)` for a sampled student, evaluate the policy predicate (or `student_can_read_legacy_lesson`) for that student's lessons; `ROLLBACK`; compare with the preview. On a mismatch, stop and report. |
| H277-2 | The user merges 277b (Netlify) only after H277-1 is verified. |
| H276-1 | Apply 276a (Revision 2) and verify the catalog (overload exists, EXECUTE `service_role` only, `pg_trigger` shows both triggers enabled, the guard function text). (Revision 2a) Prerequisite: a confirmed hosted trigger-removal mechanism (H0 evidence (a), H0b (b), or a verified alternative operator (c)); the 276.0b ledger has passed. Recommended to run back to back with H276-2 in one approved window (R12). |
| H276-2 | Deploy the course-authoring Edge function from 276b and merge 276b. Read-only smoke: none on production data; any owner publish smoke only on a test course with explicit approval. |
| H276-3 | After H276-2 is verified, revoke EXECUTE on `public.finalize_publish_job(uuid)` from `service_role` (illustrative form: `revoke execute on function public.finalize_publish_job(uuid) from service_role;`). Rollback statement: `grant execute on function public.finalize_publish_job(uuid) to service_role;`. Engineering supplies the reviewed script. This closes the one-argument path. |

290 and 291 have no hosted step beyond the user's merge.

Not scheduled: the user stated "We're not ready for prod rollout yet"; Revision 2 prepares the scripts only.

## 11. Assumptions and unknowns

Assumptions:

- A1. The student's time zone is the browser zone (no stored zone exists; the card date already uses it).
- A2. #291 is the issue187 S2 test (F291-1).
- A3. #276 targets `finalize_publish` (F276-4).
- A4. The 5c-2 week-state RPC is applied wherever 277b runs; otherwise fallback mode applies.

Unknowns:

- The issue bodies and acceptance criteria of #290, #291, #276, #277 (and #275, #292, #287).
- The live remote SHA.
- Whether the 5c-2 and 5c-1 migrations are applied in hosted (H0 pending list).
- Hosted Storage concurrency behavior, including the F276-6 storage facts, the advisory-lock interplay and real Storage API ordering.
- The #291 root cause.
- Whether the set-based preview matches the canonical helper on hosted data (R13; the parity check answers it).
- The exact text and key of the existing `PUBLISH_COPY.finalizeFallback` (F276-5).
- (Revision 2) The hosted Storage version and its write identity (which role and `storage.operation` value the real write uses).
- (Revision 2) The hosted `pg_trigger` set on `storage.objects`.
- (Revision 2) The `lesson-assets` versioning status on hosted.
- (Revision 2) Whether the supautils settings (`drop_trigger_grants`, `policy_grants`) are readable by `postgres` on hosted.
- (Revision 2a) How TUS resumable uploads, S3-protocol multipart uploads and Storage COPY write to `storage.objects` (not covered by RE-276; 276.0b cases 12 to 14).
- (Revision 2a) The role and `storage.operation` value seen in the trigger for each Storage API write (Storage write identities), on both pinned images.

## 12. Decisions

Each decision carries a recommendation. On 2026-10-17 the user approved the plan and every decision that existed then was adopted at its recommendation (see the Status line). On 2026-10-18 the user adopted D-277-4 and chose option C as the #276 direction ("For 276 choose option a."); the Revision 2 sub-decisions D-276-1C.1 to D-276-1C.5 and D-276-5 to D-276-9 were approved by the user on 2026-10-18 ("2. approved") and are adopted at their recommendations. D-276-1 option C is conditional on H0 and spike 276.0b; if either fails, D-276-6 applies.

| Id | Decision | Recommendation |
|---|---|---|
| D-ORD-1 | Order after 293: 291 -> 290 -> 277a -> 277b -> 276a -> 276b. | Recommend as stated: stabilize the e2e suite first, lowest risk next, highest-risk concurrency work last with its spike. |
| D-290-1 | Apply the shared calendar-day helper to the English-only fallback and legacy `unlockInLabel` too. | Yes. |
| D-290-2 | No local-midnight re-render timer; rely on existing re-render triggers (revalidation on focus and visibility, boundary timer). | Accept. |
| D-291-1 | If the root cause is in product code, fix it in PR 291 with a unit test (scope expands from test-only). | Yes, within the same PR, reported in the PR body. |
| D-277-1 | Align the server insert policy with the canonical rule (PR 277a) versus a client-only intersection (offer only lessons both rules allow; no migration, but released-early and cohort lessons stay unselectable and the legacy server rule remains). | PR 277a (policy alignment), after the H0 GO result. |
| D-277-2 | Skew handling: a capability gate on the list rule, the compat rule when the capability is unavailable, the narrowed inline rejection for real mid-session changes, and the binding order. | Yes: capability gate plus compat rule plus binding order. |
| D-277-3 | GO/NO-GO rule for applying 277a: GO only if the potential-legitimate-loss class (ii) is zero; on NO-GO do not apply, report counts, and repair only through a separately approved, logged, data-preserving process outside this plan, then rerun the preview. | Yes, as stated. |
| D-277-4 | (Revision 2, ADOPTED 2026-10-18, user decision) A "cohort not started yet" restriction is class (i) intentional only when nothing else is wrong with that student's access (no missing entitlement rows, no unmapped revision, no completed-only access, and no plain later `unlock_at`); any combination with a blocking cause stays class (ii) NO-GO. Evidence is computed per (active enrollment, lesson) and collapsed to the pair with blocking evidence always winning over intentional evidence (Revision 2a, Planner-accepted; tightens the D-277-3 first-match order, more conservative for the GO gate, within D-277-3 and D-277-4, no new user decision). Classification order (first match wins): 1 account deactivated (i); 2 missing_entitlement (ii); 3 unmapped_revision (ii); 4 completed_at_only (ii); 5 unlock_at_later (ii); 6 held (i); 7 revoked (i); 8 pre-cohort with no blocking pair for the student -> cohort_not_started (i); 9 pre-cohort with at least one blocking pair -> cohort_not_started_with_blocking_cause (ii). Definitions and tests T-277-4a to T-277-4j are in 6.3. | Adopted. |
| D-276-1 | Design. Revision 2: option C adopted by the user 2026-10-18 as the direction; options A and B disproven by the 276.0 spike (F276-8). Option C: a BEFORE UPDATE and BEFORE DELETE guard trigger on `storage.objects` under the per-version shared advisory key, raising on guarded changes to `lesson-assets` objects under non-draft and non-staged version prefixes, excluding `handouts/` and `handouts-quarantine/`, with finalize's exclusive lock on the same key serializing against it. Option A mechanism superseded by Revision 2 (D-276-1 option C); see Revision 2 block. | Option C (direction adopted); sub-decisions below adopted 2026-10-18. |
| D-276-2 | `asset_changed_during_registration` shares the owner string. | Yes. |
| D-276-3 | A new Edge against an old DB (overload missing) fails closed: HTTP 503 `finalize_unavailable`, version stays staged, the one-argument finalize is never called; the owner sees the existing `finalizeFallback` string. | Fail closed. |
| D-276-4 | Keep the one-argument `finalize_publish_job` defined, and revoke its EXECUTE from `service_role` at H276-3 (separately approved, after H276-2 is verified, with a re-grant rollback statement). Consider dropping it in a later reviewed change. | Keep defined; revoke at H276-3. |
| D-276-1C.1 | (Revision 2, ADOPTED 2026-10-18) Guard scope: UPDATE (when name, bucket_id, version, metadata, `archived_at` or `is_delete_marker` change, read through `to_jsonb` so absent columns are null) and DELETE; both OLD and NEW names; handouts exclusion on both names; orphan prefixes and draft or staged prefixes untouched. | Yes. |
| D-276-1C.2 | (Revision 2, ADOPTED 2026-10-18) Storage-upgrade exemption: skip the guard only when the role is `supabase_storage_admin` and `storage.operation` is unset (migration sessions), conditional on 276.0b case 6. | Yes. If any Storage API write in any 276.0b case (1 to 5, 12 to 15, either image) matches the predicate, there is no exemption and the user decides on R15 with the DROP TRIGGER containment. The full ledger is an implementation gate. |
| D-276-1C.3 | (Revision 2, ADOPTED 2026-10-18) Drop the Revision 1 policy-helper swap; owner policies stay at the `202610150001` text. | Yes (the guard covers every role; less RLS change). |
| D-276-1C.4 | (Revision 2, ADOPTED 2026-10-18) Finalize takes no `storage.objects` row lock (plain read after the exclusive advisory lock) with a 5s function `lock_timeout` mapped to 503 `finalize_busy`. | Yes. |
| D-276-1C.5 | (Revision 2, 2a, ADOPTED 2026-10-18) Two-int advisory key form, identical in the guard and finalize, with a `uuid`-typed helper `lesson_asset_version_lock_key(p_version_id uuid)`; the guard casts the validated first path segment to uuid and finalize passes `course_versions.id`; raw path text is never hashed. | Yes. |
| D-276-5 | (Revision 2, ADOPTED 2026-10-18) Deploy skew reconciliation: the #276 issue text says a new Edge against the previous function "keeps Publishing working", but approved D-276-3 fails closed. The plan records that D-276-3 supersedes that issue sentence; the orchestrator posts a comment on #276 citing D-276-3 and D-276-5 before 276b starts, so the Step 0 issue-criterion check does not raise Plan stale on this point. | Keep fail closed (D-276-3): a fallback to the one-argument function would publish unbound (the original defect); the new-Edge/old-DB state only occurs on an out-of-order deploy or a DB rollback, and the guard order (H276-1 before H276-2) makes it brief. |
| D-276-6 | (Revision 2, ADOPTED 2026-10-18) Fallback if H0 or 276.0b fails (no TRIGGER privilege, blocking event trigger, versioning enabled without coverage, deadlock, or an unreliable exemption): do not fall back to option A or B (disproven). Hold 276a and 276b entirely and re-plan toward an immutable stage snapshot (at stage the Edge copies each manifest asset to a never-mutable path that owner policies always deny, so no status-dependent race exists; finalize binds to the copies), with its own spike and fresh approval. | Yes. |
| D-276-7 | (Revision 2, 2a, ADOPTED 2026-10-18) H0 trigger feasibility is read-only. The H0b dry run (rolled-back CREATE TRIGGER and DROP TRIGGER as `postgres`) is required when the H0 removal result is inconclusive; it is separately approved and not scheduled. An explicitly missing drop-trigger grant = FAIL (D-276-6). A confirmed hosted removal mechanism is a prerequisite for H276-1; documentary confidence alone is not sufficient. | Yes. |
| D-276-8 | (Revision 2, ADOPTED 2026-10-18) Run 276.0b on both the CLI default Storage image and the image matching the hosted Storage version (the user reads it from the Dashboard; pinned in the mirror only). User record 2026-10-18: the user does not have the hosted Storage version and has authorized a read-only lookup, with no production writes. | Yes. |
| D-276-9 | (Revision 2, ADOPTED 2026-10-18) A removed-assets move refused by the guard is logged with a stable code and the response stays 200 (bytes kept, never deleted). | Yes. |
| D-ES-1 | The new Spanish draft "Se desbloquea hoy." follows D-5c2-5 (Lizbeth approves before publish). | Yes. |

## 13. Approvals and stale-plan conditions

### 13.1 Required approvals

- Explicit user approval of this plan before any writer starts: GRANTED 2026-10-17 ("Approve the defect plan, and yes, I'm merging 295."), recorded in the Status line. Decisions are adopted as stated in section 12.
- Separate approval for each hosted step: H0 (user-run, read-only, including the GO/NO-GO result), H277-1, H277-2 (merge), H276-1, H276-2, H276-3 (grant revoke), and the user's merges of 290 and 291.
- Codex live calls only with usage approval.
- (Revision 2) Revision 2 (#276 sections) requires explicit user approval of D-276-1C.1 to D-276-1C.5 and D-276-5 to D-276-9 before 276a or 276b work beyond the 276.0b spike starts. Recommendation: the 276.0b spike (local only) may run after that approval as the first 276a step. (Revision 2a) The full 276.0b ledger (cases 1 to 15, both pinned Storage images, identities, operation values, served-hash checks) is an implementation gate: the 276a RED tests and migration are not finalized, and 276b does not start, until it passes. D-277-4 is recorded as approved (2026-10-18).

### 13.2 Stale-plan conditions

The plan is stale, and the fleet returns JOB_BLOCKED "Plan stale", when any of these hold:

- An issue body acceptance criterion is not covered here.
- #291 names a different test.
- #276 targets a different finalize path.
- The base changes any cited file materially: WeekCard, the WeekDetailPage footer, `roadmapWeekState`, `roadmap.ts`, FeedbackForm, `feedbackForm.helpers`, `students_insert_feedback`, `finalize_publish_job`, `owns_mutable_lesson_asset_path`, course-authoring finalize, `publishingErrors` (including `PUBLISH_COPY.finalizeFallback`), or `student_can_read_legacy_lesson`.
- A migration redefines `students_insert_feedback` or `finalize_publish_job`.
- (Revision 2) H0 or 276.0b disproves a prerequisite of option C (TRIGGER privilege, event triggers, versioning, lock order, exemption discriminator).
- (Revision 2a) H0 shows the drop-trigger grant missing for `storage.objects`.
- (Revision 2) The hosted Storage version changes between 276.0b and H276-1.
- (Revision 2) PR #299 head differs materially from `cd5f470` in the preview classification.
- The 293 work changes any shared file.

A NO-GO from the 277a preview is a blocker for 277a, reported to the user, and is not a stale-plan condition.

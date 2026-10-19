# Lizbeth Spanish: Issue #174 Student Handout Links for Every Lesson

Status: APPROVED by the user on 2026-10-04. Cleared for engineering per this plan.

Plan ID: `lizbeth-spanish-issue174-student-handout-links`. Task ID: `lizbeth-spanish-issue174-student-handout-links`. Route: engineering.

Target repository: `lebobo88/lizbeth-spanish` (local family under `H:\CommandCenter\orchestrator\lizbeth_spanish`). Build on a NEW branch from `origin/main` (for example `feat/issue-174-student-handout-links`) in a fresh worktree, one PR for this item. `origin/main` includes #171, #173 (content-type fix plus check/retag tooling), #176 (entitlements as the single completion record; band enrollments carry `course_version_id`), and #177.

Planner's read-only reference checkout is `H:\CommandCenter\orchestrator\lizbeth_spanish-177b` (contains #173, #176, #177; closest available to `origin/main`). The main checkout `H:\CommandCenter\orchestrator\lizbeth_spanish` is stale (no `services/completionData.ts`, no #173 scripts) and must not be used as the base. All line numbers below come from 177b and must be re-verified on `origin/main` in Step 0.

Audience: students (product), Lizbeth (owner), engineering fleet (executor), and the user (approver).

## Plan revision 1 (PLAN_DUCK shadow, advisory)

`PLAN_DUCK` (Codex) ran in shadow/advisory mode on the first draft. This revision was applied once, in place, and adds no scope beyond the dispositions below. The visual and UX design was not re-run: it is unchanged, because eligibility remains a data predicate that produces the same "no materials area" state. Judge call accounting: PLAN_DUCK used 1 of 4 (high-risk cap); CODE_REVIEW and any repeat remain.

| ID | Disposition | Summary | Sections changed |
| --- | --- | --- | --- |
| J-174-01 (critical) | accepted (clarified) | The prior predicate excluded held/revoked only indirectly, through the merged client value `paused`. It is replaced everywhere by an explicit allowlist: `has_entitlement === true` AND `manual_release_state IN ('automatic','released')` AND (`manual_release_state === 'released'` OR (`unlock_at != null` AND `unlock_at <= now`)). Server paths use exactly the canonical rule used by `record_lesson_completion` and `record_lesson_progress`. Separate negative tests added for held, revoked, null state, future unlock, completed-then-held, bridge rows, `/learn` RTL and Playwright, Step 5 paths, and the Roadmap panel. | 4, 6 (Steps 4, 5), 8, 9 (J7), 12 (F9 note carried in 3) |
| J-174-02 (major) | accepted | Honest acceptance statement added: authored courses have no per-lesson handouts today. The 78 legacy lessons are fully satisfiable; authored lessons get a secure delivery path that serves any per-lesson PDF that exists. D1-a (Step 5) is now IN SCOPE. Whole-course exports are never delivered. Follow-up issues A and B are named deliverables (text drafts only). D1 is reworded as a user confirmation. | 1, 2, 6 (Steps 5, 9), 8, 12, 13 |
| J-174-03 (major) | accepted | Step 5 variant language replaced with ONE mandatory design: two security-definer functions bound to `auth.uid()`, exact predicate, caller-client resolver call in the Edge action, in-memory path, path guard, exact-path signing with service role, one generic error. Full confused-deputy negative test list. CODE_REVIEW is required (no longer conditional). | 5, 6 (Steps 5, 8), 7, 8, 10 |
| J-174-04 (major) | accepted | Hard rollout gate: production rollout is BLOCKED until #173 Phase P is complete and hosted content-type verification passes, recorded as evidence. Local implementation, PR review, and local validation may proceed before Phase P. `PENDING-PHASE-P` becomes a blocking state for rollout. | 6 (Step 6), 8, 10 (R3), 11, 13 |

Evidence labels: **Observed** means read at file level in 177b by Planner. **Inference** is a conclusion drawn from observations. **Assumption** is taken as true until a runtime step verifies it. **Unknown** is not yet established. Items the handout marks "suspected" or "unverified" keep that label.

---

## 1. Outcome

Every enrolled student can download the correct student handout PDF for every lesson they are entitled to, in every class:

- all 78 legacy lessons (3 bands x 26 weeks) on both Roadmap (`WeekDetailPage`) and `/learn` (`LearnDetailPage`);
- authored (non-legacy) course lessons through a defined, secure per-lesson delivery path (Step 5, in scope).

Each activation issues a fresh signed URL with a download filename.

**Honest acceptance statement.** Authored courses currently have no per-lesson handouts (only owner-generated whole-course exports registered at version level). "Handout works for every lesson of every class" is satisfiable today for the 78 legacy-backed lessons, plus a secure delivery path that serves any per-lesson authored PDF that exists. Authored lessons without a per-lesson file show no materials until per-lesson generation is built (follow-up issue A). Whole-course exports are never delivered to students.

## 2. Scope and non-goals

**In scope:**

- (a) Fix local per-week fixture paths (`seed.sql`, provision naming, remove duplicate fixture files, tests, count constants) while preserving production naming.
- (b) One shared resources component and data path (reuse `ResourcesPanel` and the `fetchResourcesForLesson` pattern) rendered on `/learn` lesson cards for legacy-mapped lessons, RLS-compatible, no access widening.
- (c) Authored-course per-lesson handout delivery path (Step 5; D1-a confirmed by the user at approval).
- (d) Link lifecycle: fresh signed URL per activation, download filename.
- (e) Deterministic coverage tests: offline manifest, gated local integration for all 78, hosted read-only SQL check script.
- (f) Playwright journeys for both surfaces at 390 and 1440 with the Browser UI invariant.
- (g) `storageSigning.ts` stale constants and doc cleanup.

**Non-goals:**

- Re-doing the #173 content-type fix or its hosted re-tag. Phase P remains a separate user-gated step.
- Vocabulary review presentation (#175) beyond leaving the `rowRenderers` slot.
- Changing `storage.objects` or `public.resources` RLS predicates.
- Generating per-lesson handouts in the owner authoring tool.
- Fixing the suspected authored-export registration defect (F10); file it as a follow-up.
- Any production write. The hosted check is read-only.
- Commit, push, or PR creation unless the user authorizes it at execution time.
- Changing the legacy date-rule versus entitlement-rule semantics.

## 3. Repository findings (evidence)

Verified at file level in 177b unless marked.

- **F1. #173 is present.** `package.json` scripts `check:asset-content-types`, `retag:asset-content-types`, `verify:asset-signed-urls`. `scripts/provision-lessons.ts` `uploadToStorage` resolves `contentTypeForPath` before upload (~974-1003). `src/lib/storageContentType.ts` maps `.pdf` to `application/pdf`. The hosted re-tag (Phase P, project `gvobtuhbpqvfhjljjcye`) is still pending and user-gated (`docs/plans/lizbeth-spanish-issue173-storage-content-type.md`). This item does not duplicate it.
- **F2. Seed resources reuse week 1's filenames.** `supabase/seed.sql:301-324` inserts resources for Beginner weeks 1-4 with `storage_path` `'beginner/week-0N/'` plus `'beginner-week-01-student-handout.pdf'` / `'beginner-week-01-instructor.pptx'` for every week, so weeks 2-4 serve week 1's handout. The seed comment at ~287-294 (security note: distinct per-week paths keep gating independent) must be preserved in spirit: the fix keeps distinct per-week paths and makes the filenames per-week.
- **F3. Six duplicate fixture files.** `supabase/storage-seed/lesson-assets/beginner/week-0{2,3,4}/` each contain both `beginner-week-01-student-handout.pdf` and `beginner-week-01-instructor.pptx` (6 duplicate files: 3 pdf + 3 pptx) AND the correct per-week `beginner-week-0N-student-handout.pdf` / `-instructor.pptx`. `supabase/config.toml` `[storage.buckets.lesson-assets]` `objects_path = "./storage-seed/lesson-assets"` seeds local storage from this directory.
- **F4. Local naming branch.** `scripts/provision-lessons.ts` `resolveResourceNaming(entry, preserveLocalFixtures)` (~534-572) reproduces the week-01 filename for Beginner 2-4 when `preserveLocalFixtures` is true (local); used by `buildExpectedResourceTuples` and `provisionLessons`. Beginner 1-4 are skipped by `provisionLessons`, `prepareStorageFiles`, and `uploadToStorage` locally. `isFixtureDuplicateUploadToSkip` (~946-954) skips `beginner-week-01-*` outside week-01 only for non-local targets (protects production gate G7a cleanup) and is imported by `scripts/lib/lessonAssetsContentTypes.ts:21/121`.
- **F5. Count constants assume the 6 local duplicates.** `provision-lessons.ts` ~1206-1236 `expectedCount = isLocalDevelopment ? 474 : 468`; `scripts/lib/lessonAssetsContentTypes.ts:99` total `isLocal ? 474 : 468` (local byExt `.pdf` 81, `.pptx` 81); `scripts/check-lesson-assets-content-types.ts:13` doc; `src/__tests__/lessonAssetsContentTypes.test.ts:149-151` asserts both. After the fix local must equal production: 468 (`.pdf` 78, `.pptx` 78, `.md` 156, `.yaml` 78, `.json` 78).
- **F6. Tests referencing the fixture duplicate names.** `src/__tests__/provision-lessons.test.ts` (1403-1425 `isFixtureDuplicateUploadToSkip` cases; 1744-1803 `resolveResourceNaming`; 1864-1865); `src/__tests__/storageIntegration.test.ts` (53, 64, 82, 112, 123: `beginner/week-03|04/beginner-week-01-*`); `src/__tests__/e2e/gap-3-rls-signed-url-denial.spec.ts` (205: `beginner/week-04/beginner-week-01-student-handout.pdf`); `src/__tests__/lessonAssetsContentTypes.test.ts` (159-195 FIXTURE-DUP cases). `src/__tests__/storageObjectExistence.test.ts` already expects per-week names for fixture weeks 1-4 and skips fixture weeks in the other two cases.
- **F7. `/learn` has no resources UI.** `src/pages/LearnDetailPage.tsx` `LessonCard` (~226-292) renders title, state, `MarkCompleteControl`, and `LockedDisclosure` only. `src/services/learnData.ts` `LearnCourseLessonRow` has `lesson_revision_id` but no `legacy_lesson_id`. `get_student_learn_course` (`supabase/migrations/202608310002_issue5_phase5_student_learn_sql_core.sql:74-160`) is security definer with a binding leak prohibition (never returns assets, paths, or signed URLs). It is NOT modified by this plan.
- **F8. Legacy bridge without a migration.** `authenticated` has SELECT on `public.lesson_revisions` (`202608280003:536`) under policy `lesson_revisions_student_read` (`:521`), which requires an own active-enrollment entitlement with `unlock_at <= now()` and `manual_release_state` not in (`held`, `revoked`). `public.resources` is readable under `students_read_unlocked_resources` and `storage.objects` under `students_read_unlocked_lesson_assets` (latest definitions in `202608070001_force_password_change_rls_enforcement.sql:58-113`): both join lessons to `student_enrollments` on `band_id` with status active, `is_account_active`, not `user_requires_password_change`, and `now() >= enrollment_date + unlock_offset_days` or completed. Version and cohort enrollments carry `band_id = version.band_id` (`202608280003:413,469`; `202608300005:129-130`); authored courses without a band have `band_id` null.
- **F9. Intersection of rules.** Effective `/learn` legacy access is the intersection of the entitlement rule (bridge) and the legacy date rule (resources/storage RLS). No policy change is needed and nothing is widened. Known divergence: a cohort-anchored or manually released legacy entitlement can unlock before `enrollment_date + offset`; the bridge then returns the revision but resources RLS returns zero rows, so the card shows no materials. Pre-existing and out of scope: legacy resources RLS ignores held/revoked entitlements (the `/learn` UI will not render materials for paused cards, but the existing table and storage access is unchanged). This remains under follow-up (D5) and is not changed by this item. Planner-verified (177b): the canonical active-entitlement rule used by `record_lesson_completion` and `record_lesson_progress` (`supabase/migrations/202610030001_issue176_single_completion_record.sql` ~261-266, ~312-313) is `manual_release_state NOT IN ('held','revoked') AND (manual_release_state = 'released' OR unlock_at <= now())`. `get_student_learn_course` (`202608310002:121-124`) merges held/revoked into the single client value `paused`, so the client only sees `automatic` | `released` | `paused` | null. Because the bridge RLS also requires `unlock_at <= now()` and the resources/storage RLS applies the band date rule, a `released`-early legacy lesson shows no materials (silent empty, covered by D3/D5); this is conservative and widens nothing.
- **F10. Authored courses have no per-lesson handout.** `public.course_assets` (`202608280003:86-101`) has `lesson_revision_id` and/or `course_version_id`, `storage_bucket`/`path`, `content_type`, `integrity_status`, `metadata`. RLS policy `course_assets_student_read` exists (`:523`) but `authenticated` has no table grant (revoked `:531`; not in `:536`), so students cannot read it directly. The storage read policy only matches `public.resources` paths. Owner authoring today produces only whole-course exports: `src/services/courseAuthoring.ts:128` `uploadGeneratedAsset(versionId, name, ...)` uploads to `${versionId}/generated/${name}` and registers with `course_version_id` only (`lesson_revision_id` null). `src/pages/CourseWorkspacePage.tsx` Publishing calls `uploadGeneratedAsset(courseId, 'course.pdf', ...)` and `(courseId, 'course.pptx', ...)`, passing a course id where a version id is expected. The Edge function `ownershipFailure` (`supabase/functions/course-authoring/index.ts:77-89`) checks `ownedVersion(version_id)`, so registration would likely 404 and roll back the upload. This is a **SUSPECTED defect, unverified at runtime**; out of scope, file as a follow-up issue. No per-lesson authored handout exists today. Delivering a whole-course PDF on first unlock would expose locked-lesson content.
- **F11. Student actions in the Edge function.** `course-authoring/index.ts:35-58` handles student actions (`grade`, `get_student_learn_index`, `get_student_learn_course`) before the owner gate using the RLS-scoped caller client; the service-role `db` client is created only after the owner gate (`:59-61`). A student signing action that uses service role would be a new pattern and must be bounded (Section 7).
- **F12. ResourcesPanel today.** `src/components/ResourcesPanel.tsx`: "Get a link for X" calls `getSignedResourceUrl` (default TTL 3600) and renders `<a target=_blank rel=noopener>`; stale after 1 h; no download option; empty copy "No resources published for this week yet."; `aria-label` "Resources"; `presentation` inline|overlay for flashcards. The Roadmap call site `WeekDetailPage.tsx` ~1089-1124 excludes `lesson_content` once, then `ResourcesPanel`, then `IpNotice`.
- **F13. storageSigning stale constants.** `src/lib/storageSigning.ts` `STORAGE_CONFIG.RESOURCE_EXTENSIONS` is stale (flashcards `.json` but real files are `flashcards.yaml`; vocabulary_review `.pdf` but real files are `weekly-review-recap.md`; `lesson_content` missing). The `generateStoragePath` doc example `beginner/week-1/pdf.pdf` does not match real naming (`<band>/week-NN/<band>-week-NN-student-handout.pdf`). `@supabase/storage-js` 2.110.7 (installed in the main checkout `node_modules`; `package.json` pins supabase-js `^2.110.7`) supports `createSignedUrl(path, expiresIn, { download: string | boolean })`.
- **F14. Test infrastructure.** `vitest.config.ts` runs live local-Supabase suites in the default run with `fileParallelism` false. Playwright config `testDir` `src/__tests__/e2e`, `baseURL` from `E2E_BASE_URL` (default netlify serve 8888). Existing `/learn` specs: `wp11-learn.spec.ts`, `phase5-learn-detail-live-verification.spec.ts`; Roadmap: `wp10-roadmap-week-flashcards.spec.ts`. The seed creates 78 lessons (`seed.sql:123-168`) but resources rows only for Beginner 1-4; weeks 5-26 resource rows come from running `scripts/provision-lessons.ts` against the local stack.
- **F15. Guard tests that assert the old lifecycle.** These must be updated deliberately: `src/__tests__/fjdsAuthenticatedScreensRemediation.test.ts` (~167, 205, 371), `designSystemConsistency.test.ts` (~229), `weekDetailCardsFilesPanels.test.tsx` (~531 `/Get a link for/i`), `storageSigning.test.ts` (~262, 273: `createSignedUrl` called with `(path, 3600)` and `(path, 60)`).

Research evidence: none. Research not needed: all decisions are grounded locally and the storage-js download option is confirmed in the installed package. Remaining browser-behavior uncertainty (cross-origin anchor download on 4xx, iOS Safari) is handled by validation, not research.

## 4. Design route and handoff

DESIGN_ROUTE profile compact. Reasons: bounded brownfield addition to existing `/learn` cards reusing `ResourcesPanel`, plus a shared link-lifecycle change. Agents: design-generalist (Sonnet) and design-reviewer (Sonnet). Prototype forbidden. `existing_system_mode`: preserve.

Design review: DESIGN_REVIEW_RESULT PASS (final cycle) after one NEEDS_REVISION (F1-F7 resolved: flashcards focus and live regions, adapter bridge, accessible names, 404-after-sign, aria-disabled styling, test/TTL/class consistency, denied copy). Advisories R1 (404 behavior is an assumption validated by journey; preflight becomes mandatory on failure) and R2 (default gate toggle to embedded) are adopted below. Remaining limits: static review only; Chromium cross-origin anchor and iOS Safari unvalidated; the authored server path is outside design scope.

### Binding design spec (reviewed, revision 1)

**Placement.** In the `LessonCard` `<li>`: `.lesson-card-main`, then a new non-landmark `<div class="lesson-card-materials">` with `<h4 class="lesson-card-materials-heading">Lesson materials</h4>` (new class with eyebrow declarations in `--color-ink-700`: `--font-size-label`, `--font-weight-label`, `--font-letter-spacing-eyebrow`, uppercase, the page's mono eyebrow family; do NOT reuse `.lesson-card-primary-marker`, which is terracotta), then `LockedDisclosure` (locked family only).

**Eligibility predicate** (J-174-01; one exported function shared by fetch and render), as an explicit allowlist: `has_entitlement === true` AND `manual_release_state IN ('automatic','released')` (so `paused`, which is the delivered form of held and revoked, and null are denied) AND (`manual_release_state === 'released'` OR (`unlock_at != null` AND `unlock_at <= now`)). Gate on this, not `deriveLessonState` (`completed_at` priority would show completed-then-held). Locked-family, paused, held, and revoked cards: no area, no placeholder, no hint.

**Server-side rule.** Every new SQL or Edge path (Step 5 resolver and listing) uses exactly the canonical rule in F9 plus own active enrollment, `is_account_active(auth.uid())`, and `NOT user_requires_password_change()`.

**Allowlist.** Applied once in an adapter on `/learn`: `pdf`, `flashcards`, `vocabulary_review`; never `lesson_content`; `pptx` excluded on `/learn` (decision D2).

**Adapter contract.**

- After `fetchLearnCourse` resolves, run one batched bridge query `lesson_revisions.select('id, legacy_lesson_id').in('id', eligibleRevisionIds)` (never select content), then one `resources.select('id, lesson_id, name, resource_type, storage_bucket, storage_path').in('lesson_id', legacyIds)`, mapped back to `lesson_revision_id`. `ResourceRow.id = resources.id`, `lesson_id` = legacy lesson id.
- Null `legacy_lesson_id` gives empty legacy rows (the Step 5 authored path supplies rows).
- RLS-empty is a legitimate empty: it renders nothing (decision D3).
- Any bridge or resources failure gives a single page-level "We couldn't load your lesson files." plus Retry (partials discarded).
- Page-level `<p role="status">` "Loading lesson files…" is always mounted; text becomes visible after ~300 ms (200-400 permitted). Cards never wait on the batch. Mark complete must not remount or refetch materials.

**ResourcesPanel API** (all optional; defaults reproduce Roadmap except the recorded lifecycle change):

- `variant` 'rail' | 'embedded' (default rail; embedded drops brass 3px border and shadow).
- `listLabel` (default 'Resources'; `/learn`: `Materials for "{title}"`).
- `emptyMessage` string | null (default week copy; null renders nothing and no `role=status`).
- `downloadBasename`.
- `accessibleContext` (embedded: names `Download {LABEL} for "{title}"`, `Retry: {LABEL} for "{title}"`, `View flashcards for "{title}"`).
- `deniedMessage` (embedded: "This file isn't available right now. Try again later or contact your instructor.").
- `signResource(row, options) => Promise<SignedResourceUrlResult>`, defaulting to `getSignedResourceUrl` (source-agnostic).
- `rowRenderers` `Partial<Record<resource_type, (ctx {resource, defaultAction, status, state}) => ReactNode | undefined>>`, the #175 slot.
- `presentation`, `onFlashcardsReady`, `flashcardsTriggerRef` unchanged.
- `SignedResourceUrlResult` gains optional `kind?: 'denied' | 'network'` (never distinguishes locked from missing).

**Row states.**

- Idle: secondary Control "Download {label}".
- Signing: `aria-disabled` plus `aria-busy` (not `disabled`), repeat presses ignored, status "Preparing your download…".
- Ready: status "Your download should start now. If it doesn't, press Download again."; button returns to the idle label; no `href` left on screen.
- Denied: `deniedMessage` or generic.
- Error: reason shown, same button reads "Retry", focus kept. Offline uses the network reason "Could not generate a download link right now. Please try again.".
- A persistent per-row status slot (`role=status` `aria-live=polite`) is always mounted.
- Resource controls are never primary (exactly one `.control--primary` on `/learn` stays `MarkCompleteControl`).
- Scoped CSS `.resources-panel-row .control[aria-disabled='true'] {cursor: progress; transform: none; box-shadow: none}` mirrored under forced-colors. Remove `.resources-panel-link` and its `:visited` rule with the anchor (record in a CSS comment).

**Link lifecycle.**

- Sign at activation with `{ download: filename }` and TTL 300 s passed explicitly by the panel (permitted 120-300; the shared `getSignedResourceUrl` default stays 3600). Call `createSignedUrl(path, ttl)` with exactly two args when no options.
- Then click a transient `<a download>` (no target) pointing at the signed URL carrying `?download=<filename>`, removed immediately. No `window.open`, no `target=_blank`, no `location.assign`.
- Filenames: `{slug}-student-handout.pdf` (pdf); `{slug}-weekly-vocabulary-review.<real ext>` for vocabulary_review (the real object is `.md`, so engineering must derive the extension from `storage_path`, not hardcode `.pdf`); `{slug}-slides.pptx` (pptx).
- `slug` = `downloadBasename`, else slug(`resource.name`): NFD strip diacritics, lowercase, non-alphanumerics to `-`, collapse and trim, cap 80, fallback `lesson`. `/learn` passes slug(lesson title).
- Flashcards: sign without download, fetch and parse as today; ignore results after unmount.

**Signed-OK-but-object-404 (reviewer advisory R1, binding here).** The claim that the transient anchor keeps the SPA on a 4xx is an **ASSUMPTION** (Chrome may ignore the `download` attribute cross-origin). It is validated by a dedicated 404-after-sign journey (J3). If that journey shows the tab navigating or the URL changing, a Range-GET preflight (`fetch(url, { headers: { Range: 'bytes=0-0' } })` routing non-2xx to the row error state) becomes mandatory, after confirming storage-origin CORS.

**Flashcards inline on `/learn`.** The button stays mounted as an `aria-expanded` show/hide toggle with `aria-controls` to a stable deck region. Loading keeps the button (`aria-busy`, "Preparing your flashcards…"). Success keeps focus on the button. Collapse retains the parsed deck, no refetch or re-sign. Error Retry keeps focus. Default (reviewer R2, decision D4): toggle only in `variant="embedded"`; Roadmap inline flashcards and the mobile overlay launcher stay as shipped.

**Responsive.** At 1440, rows are horizontal (name and type left, action right; status, error, and deck full width). At <=700 px, rows stack with a full-width button >= `--control-height`. Keep `min-width:0` and `overflow-wrap:anywhere`; no horizontal scroll at 390 or 320. No new tokens; no animation.

**Roadmap.** Layout, call sites, empty copy, `aria-label` "Resources", and `IpNotice` order are unchanged. Row lifecycle and idle label change ("Get a link for X" to "Download X", anchor removed) per the user's shared-component decision.

## 5. Judge route

- **PLAN_DUCK:** required on this draft by the orchestrator before approval. Risk high because of a new service-role-backed student signing action and RLS-adjacent data paths. Rubric J-174-PLAN: no access widening (resources, storage, `course_assets`); fixture fix preserves production naming and G7a idempotency; coverage test determinism; Browser UI invariant inputs complete.
- **PLAN_DUCK accounting:** 1 of 4 used (shadow/advisory, revision 1 above). Remaining capacity covers CODE_REVIEW and one checkpoint repeat.
- **CODE_REVIEW:** after implementation; required because Step 5 is in scope (J-174-03). Rubric J-174-SEC: SQL security definer `search_path`, grants and revokes; `auth.uid()` ownership; entitlement predicate parity with `lesson_revisions_student_read`; Edge action exact-path signing; no path or bucket from the client; TTL; error non-enumeration.
- **VERIFICATION_CHALLENGE:** optional. **VISUAL_REVIEW:** optional, on the 390/1440 screenshots against the design handoff in Section 4.
- **Call cap:** 4 (high risk), one checkpoint repeat after remediation; extra calls need user approval. Deterministic failures dominate. Finding IDs from any judge pass flow into the engineering job and into Verifier checks. No judge result is included in this draft.

## 6. Ordered work

Owner: engineering-fleet, standard mode. T1 first, then Verifier, then Browser Validator.

### Step 0. Preflight (T1)

- New worktree from `origin/main`. Re-verify every Fn line reference. Confirm #173 and #176 are present.
- Run `npx supabase start` from this worktree (the Edge runtime mounts the worktree that started the stack; if another worktree started it, run `npx supabase stop` then `npx supabase start` here).
- Run `npx supabase db reset`, then `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`.
- Run local provisioning per the repo's existing runbook (`scripts/provision-lessons.ts` against exactly `http://127.0.0.1:54321`) so all 78 lessons have resource rows.
- Confirm `fullaccess@test.local` band enrollments have entitlements and `/learn` renders lesson cards (not the legacy "available on Roadmap" panel). If not, stop and report (stale-plan condition); do not change product code to force it.

### Step 1. Fixture fix (T1, TDD)

Write failing tests first:

- (i) A new offline manifest test (for example `src/__tests__/handoutCoverageManifest.test.ts`, no network): for all 78 manifest entries the file `supabase/storage-seed/lesson-assets/<band>/week-NN/<band>-week-NN-student-handout.pdf` exists and its first 5 bytes are `%PDF-`; no `beginner-week-01-*` file exists outside `beginner/week-01/`; `resolveResourceNaming(entry, true)` and `(entry, false)` yield identical per-week pdf/pptx paths for every entry; `seed.sql` (static parse) contains no week-01 filename for weeks 2-4.

Then:

- Change `seed.sql:301-324` to per-week filenames (`'beginner-week-' || lpad(week,2,'0') || '-student-handout.pdf'` / `'-instructor.pptx'`), keeping distinct per-week paths and updating the comment.
- Remove the `isLocalFixtureWeek` filename branch from `resolveResourceNaming` (keep the Beginner 1-4 skip behavior in `provisionLessons`, `prepareStorageFiles`, `uploadToStorage`).
- Delete the 6 duplicate files `beginner/week-0{2,3,4}/beginner-week-01-student-handout.pdf` and `beginner-week-01-instructor.pptx` (include the 3 stray instructor pptx copies).
- Keep `isFixtureDuplicateUploadToSkip`'s production behavior unchanged (G7a idempotency) and update its doc comment (local no longer has duplicates).
- Update count constants local 474 to 468 (`provision-lessons.ts` ~1206-1236; `lessonAssetsContentTypes.ts:99` byExt local `.pdf` 78, `.pptx` 78; `check-lesson-assets-content-types.ts` doc).
- Update tests in F5/F6 (`storageIntegration`, gap-3 e2e, `lessonAssetsContentTypes`, `provision-lessons`) to per-week paths, preserving each test's original intent (for example the gap-3 locked-week denial must still target a distinct locked-week path).
- Re-run `db reset` and `npm run check:asset-content-types` (local; expect 0 mismatches, total 468).

### Step 2. storageSigning cleanup (T1, TDD)

- `getSignedResourceUrl` gains optional `options { download?: string | boolean }`, passed as the third `createSignedUrl` arg only when present. The result gains optional `kind` 'denied' | 'network'.
- Fix `RESOURCE_EXTENSIONS` (flashcards `.yaml`, vocabulary_review `.md`, add `lesson_content` `.json`). Fix the `generateStoragePath` doc, example, and implementation to the real naming (`<band>/week-NN/<band>-week-NN-student-handout.pdf` etc.), or mark it clearly deprecated if unused (grep callers first).
- Add a pure `buildDownloadFilename(resource, basename)` plus slug helper with unit tests (diacritics, empty, 80-char cap, extension derived from `storage_path`).

### Step 3. Shared ResourcesPanel (T1, TDD, RTL)

- Implement the design API and states in Section 4. Keep Roadmap call sites byte-identical.
- Update the F15 guard tests deliberately: old label, anchor, and CSS assertions are replaced with the new lifecycle assertions; the `storageSigning` two-arg assertions remain valid.
- Unit tests: fresh sign per activation (two presses give two `createSignedUrl` calls); TTL 300 plus download option passed; no `href` rendered after activation; `aria-busy`/`aria-disabled` during signing; focus retained; Retry path; `deniedMessage` via `kind`; `rowRenderers` fallthrough; `emptyMessage` null renders nothing; flashcards toggle in embedded only; overlay mode unchanged.

### Step 4. /learn integration (T1, TDD)

- `learnData` (or a sibling service) adds the batched bridge plus resources fetch and the adapter (allowlist, mapping, and the exported eligibility predicate from Section 4).
- `LearnDetailPage` renders the materials block per the design with page-level loading, error, and Retry. No change to `get_student_learn_course`.
- Deterministic negative tests, each separate (J-174-01):
  - (i) Adapter and eligibility unit tests: held and revoked (as delivered `paused`), null state, future `unlock_at` with `automatic`, completed-then-held.
  - (ii) Live tests that the bridge query returns no row for a held entitlement and for a revoked entitlement (set via service-role test setup on the exact local URL).
  - (iii) `/learn` RTL tests and Playwright journeys: held and revoked cards render no materials.
  - (iv) Step 5 resolver, listing, and Edge signer deny held and revoked (Step 5).
  - (v) Roadmap: its existing access is governed by the unchanged legacy RLS (pre-existing behavior, F9). Add a test that the shared panel itself adds no access beyond what the passed rows and RLS allow.
- Other unit tests: exactly one `.control--primary`; mark-complete does not refetch materials.

### Step 5. Authored-course per-lesson delivery (T1; in scope, D1-a; CODE_REVIEW required)

One mandatory design (J-174-03). There are no variants.

**Migration** (timestamp after the latest on `origin/main`): two functions, both `SECURITY DEFINER`, `LANGUAGE sql STABLE` (or `plpgsql STABLE` if needed), `SET search_path = public` (`pg_catalog` implicit), `REVOKE ALL ... FROM public, anon`, `GRANT EXECUTE ... TO authenticated` (and `service_role` for tests). Both are bound to `auth.uid()` and return nothing when `auth.uid()` is null.

- `get_student_lesson_assets(p_enrollment_id uuid) RETURNS jsonb`: an array of `{asset_id uuid, lesson_revision_id uuid, display_name text, content_type text}`. It never returns bucket or path.
- `resolve_student_course_asset(p_enrollment_id uuid, p_asset_id uuid) RETURNS TABLE(storage_bucket text, storage_path text, content_type text, display_name text)`: zero rows when not authorized.

**Exact authorization predicate (both functions).**

- There exists a `student_enrollments se` where `se.id = p_enrollment_id` AND `se.user_id = auth.uid()` AND `se.status = 'active'` AND `public.is_account_active(auth.uid())` AND `NOT public.user_requires_password_change()`.
- There exists a `course_assets ca` where `ca.lesson_revision_id IS NOT NULL` (version-level and whole-course exports never match) AND `ca.content_type = 'application/pdf'` AND `ca.integrity_status = 'verified'` AND `ca.storage_bucket = 'lesson-assets'`.
- The revision belongs to `se.course_version_id` via `course_version_lessons`.
- An `enrollment_lesson_entitlements` row (`enrollment_id = se.id`, `lesson_revision_id = ca.lesson_revision_id`) satisfies the canonical active rule from F9: `manual_release_state NOT IN ('held','revoked') AND (manual_release_state = 'released' OR unlock_at <= now())`.
- For `resolve_student_course_asset`, additionally `ca.id = p_asset_id`.

**Edge action `sign_student_course_asset`** in `supabase/functions/course-authoring/index.ts`, placed before the owner gate:

- Validate that `enrollment_id` and `asset_id` are UUIDs.
- Call `resolve_student_course_asset` via the RLS-scoped CALLER client (JWT-bound). Keep bucket and path in memory only.
- Reject if the bucket is not `lesson-assets` or the path contains `..`, a leading `/`, or backslashes.
- Sign that exact path with the service-role storage client, TTL 300 s, `{ download: filename }`.
- Respond `{ data: { signedUrl } }` only. On any failure respond with one generic non-enumerating error (same status and message for missing, foreign, and locked).

**Accepted exposure note.** Because the resolver is granted to `authenticated`, a student calling it directly could see their own entitled asset's path. This is acceptable because no `storage.objects` policy matches `course_assets` paths, so the student's own client cannot sign it. A test proves that the student's anon client `createSignedUrl` on that path is denied.

**Client.** An authored-row adapter source and a `signResource` implementation that calls this Edge action; `ResourcesPanel` unchanged.

**Tests** (SQL and Edge, each negative case separate):

- Other student's `enrollment_id`.
- Own enrollment with another course's `asset_id`.
- Locked lesson (future `unlock_at`).
- Held entitlement; revoked entitlement.
- Inactive enrollment; deactivated account; force-password-change flag.
- Whole-course export asset (`lesson_revision_id` null, for example `<version>/generated/course.pdf`) is never listed or signable.
- `lesson_content` and non-PDF assets are never listed.
- Malformed or non-UUID ids.
- A crafted asset row whose `storage_path` contains `..` or a leading `/` (inserted by service-role test setup) is refused by the Edge path guard.
- Unauthenticated call rejected.
- Positive: an entitled student downloads the local fixture per-lesson PDF (200, `application/pdf`, `%PDF-`). The fixture `course_asset` is inserted by service-role test setup (no seed or product data change unless approved).
- Restart the edge runtime after Edge changes.

### Step 6. Coverage tooling (T1)

- (i) A gated local integration test (for example `src/__tests__/handoutCoverage.live.test.ts`, `describe.runIf(process.env.HANDOUT_COVERAGE_LIVE === '1')`, plus npm script `verify:handout-coverage`). For all 78 lessons (exact local URL guard `http://127.0.0.1:54321`) it signs the pdf resource as an entitled test student (`fullaccess@test.local`) via the real anon client plus RLS, GETs it, and asserts HTTP 200, Content-Type `application/pdf`, body starts with `%PDF-`, Content-Length/byte length equals the storage-seed file size, and (with the download option) Content-Disposition attachment with the expected filename. It reports all failures, not the first.
- (ii) A hosted read-only check script (for example `scripts/check-hosted-handout-coverage.sql` plus a tsx/psql wrapper or a documented Supabase SQL editor procedure): wrapped in `BEGIN TRANSACTION READ ONLY ... ROLLBACK`, no writes, no DDL. Per band and week it asserts exactly one pdf resource row, path equals `<band>/week-NN/<band>-week-NN-student-handout.pdf`, a matching `storage.objects` row exists, `metadata->>'mimetype'` and size are reported (mimetype `application/pdf` expected only after #173 Phase P; before Phase P report as `PENDING-PHASE-P`; this is a BLOCKING state for production rollout (J-174-04), not an informational one), no `beginner-week-01-*` objects outside week-01, and every lesson has a `lesson_revisions` mapping.
- Running (ii) against hosted requires explicit user go-ahead naming project `gvobtuhbpqvfhjljjcye`; credentials from env only; output saved as evidence under `docs/cutover-evidence/` (git-ignored policy per existing convention).

### Step 7. Playwright journeys (T1)

New spec (for example `src/__tests__/e2e/issue174-handout-links.spec.ts`) against `E2E_BASE_URL=http://localhost:5177` at 390x844 and 1440x900 covering the journeys in Section 9. Add a deterministic no-native-dialog source scan test (grep `src` for `alert(`, `confirm(`, `prompt(`, `window.alert|confirm|prompt|open`, `beforeunload`) if not already present in the repo.

### Step 8. Verification

Run `npm run type-check`, `npm run lint`, `npm test` (full vitest including live suites against the reset local stack), `HANDOUT_COVERAGE_LIVE=1` `verify:handout-coverage`, `npm run check:asset-content-types` (local), `npm run verify:build`, and `npm run test:e2e` for the new spec and the existing wp10, wp11, phase5, and gap-3 specs. Then Verifier, then Browser Validator; CODE_REVIEW judge (required, Step 5 is in scope).

### Step 9. Follow-ups (orchestrator, text only, user-gated)

Named deliverables, text drafts only; GitHub writes remain user-gated:

- **Follow-up issue A:** "per-lesson authored handout generation".
- **Follow-up issue B:** "Publishing export registration passes course id where version id is expected" (`CourseWorkspacePage` Publishing calls `uploadGeneratedAsset(courseId, ...)`; the `register_asset` ownership check is on `version_id`). SUSPECTED; verify at runtime (F10).
- **Follow-up issue C (optional):** reconciliation of the legacy date rule vs the entitlement rule for cohort-anchored legacy enrollments, including legacy resources/storage RLS ignoring held/revoked (F9, D5).

No GitHub writes without user authorization.

## 7. Interfaces and data

- No change to `storage.objects`, `public.resources`, `public.lessons`, or `lesson_revisions` RLS; no change to `get_student_learn_course` or `get_student_learn_index`.
- New (Step 5): one migration with two security-definer functions and explicit grants and revokes; one new Edge action `sign_student_course_asset` (student-authorized, pre-owner-gate; service role used only to sign a server-resolved exact path). Hosted deploy of the migration and Edge function is a separate user-gated step, not part of the build.
- Client contracts: `getSignedResourceUrl(client, bucket, path, ttl?, options?)` backwards compatible; `SignedResourceUrlResult` adds optional `kind`; `ResourcesPanel` props are additive; the new adapter lives in `learnData` or a sibling.
- Data and fixtures: `seed.sql` resource paths for Beginner 2-4 change locally only; storage-seed loses 6 duplicate files; production naming and production objects are unchanged.

## 8. Acceptance checks

- Offline manifest test passes: 78/78 PDFs present at expected paths with `%PDF-` header; zero `beginner-week-01-*` outside week-01; `resolveResourceNaming` identical for local and production modes.
- After `db reset` plus provisioning: local storage object total 468 with per-extension counts equal to production; `npm run check:asset-content-types` reports 0 mismatches.
- Gated live coverage: 78/78 lessons sign and GET 200, `application/pdf`, `%PDF-` body, length equals the seed file, Content-Disposition attachment with the expected filename.
- Beginner week 2, 3, 4 downloads are byte-identical to the beginner-week-02/03/04 handouts (not week 1) on both Roadmap and `/learn`.
- RLS non-widening tests: a student without enrollment, with a locked week, with a paused/held entitlement, or with the password-change flag gets no rows or a denied sign on both surfaces; the gap-3 denial spec still passes with per-week paths.
- `/learn`: eligible cards show Lesson materials; locked, paused, prerequisite, and null-unlock cards show none; exactly one `.control--primary`.
- Each activation produces a new `createSignedUrl` call (unit) and a new signed URL (network) with TTL 300 and `?download=`; no signed `href` persists in the DOM.
- Step 5: all SQL and Edge tests listed in Step 5 pass, including every confused-deputy negative case and the proof that the student's anon client cannot sign the returned path; the CODE_REVIEW judge has no unresolved blocking finding.
- Eligibility (J-174-01): the separate negative tests (i)-(v) in Step 4 all pass (held, revoked, null state, future unlock with `automatic`, completed-then-held; bridge returns no row for held and revoked; `/learn` RTL and Playwright show no materials for held and revoked cards; Step 5 paths deny held and revoked; the shared panel adds no access beyond the passed rows and RLS).
- Honest scope statement (J-174-02): acceptance is "78 legacy lessons fully working on both surfaces, plus a secure per-lesson authored delivery path that serves any per-lesson authored PDF that exists". Authored lessons without a per-lesson file show no materials. Follow-up issues A and B are drafted.
- **Rollout gate (J-174-04):** production rollout (merge-to-production deploy, hosted migration and Edge deploy) is BLOCKED until #173 Phase P is complete and hosted content-type verification passes: `npm run check:asset-content-types` against hosted with 0 mismatches and `verify:asset-signed-urls` showing `application/pdf`, recorded as evidence. Local implementation, PR review, and local validation may proceed before Phase P.
- `type-check`, `lint`, full vitest, `verify:build`, and targeted e2e are all green; Verifier PASS; Browser Validator PASS.

## 9. Browser UI dialog policy and browser validation inputs

**Dialog policy (required).** No `alert`, `confirm`, `prompt`, `window.alert`/`confirm`/`prompt`, `beforeunload`, and additionally no `window.open`. Errors are inline with Retry. No modal is introduced (Browser Validator records "no modal present" and confirms no `role="dialog"`). If a modal ever becomes necessary it must be the app-owned accessible modal with focus trap, Escape, and focus return. A deterministic source scan is required (Step 7).

**`browser_ui_validation` inputs.**

- **Launch and readiness:** `npx vite --port 5177 --strictPort` (5173 belongs to another project); ready when `http://localhost:5177` responds 200 and the login page renders.
- **Base URL:** `http://localhost:5177` (Playwright via `E2E_BASE_URL=http://localhost:5177`).
- **Fixture and reset:** `npx supabase db reset`, then `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`; run local provisioning (`scripts/provision-lessons.ts` against `http://127.0.0.1:54321`) for weeks 5-26 resources; if Edge changes (Step 5): `npx supabase stop` plus `npx supabase start` from the target worktree. Accounts (password `password`): `fullaccess@test.local` (all bands, 200 days), `student1-6@test.local`, `owner@test.local`. Per-journey card states (paused, prerequisite, future unlock, zero-row, null-legacy authored lesson, per-lesson authored PDF fixture) are created by test setup via service role on the exact local URL, not by product code.
- **Viewport profiles:** 390x844 and 1440x900 (320 spot check).

**Journeys** (each at 390x844 and 1440x900):

- **J1 `/learn` download:** the eligible card shows "Lesson materials"; press "Download Student handout (PDF)"; status "Preparing your download…" then "Your download should start now…"; Playwright download event with filename `{slug}-student-handout.pdf`; page URL unchanged, no popup; downloaded bytes start `%PDF-` and match the lesson's week (Beginner wk 2/3/4 not week 1).
- **J2:** a second press issues a different signed URL; after `page.clock` advance > 1 h a press still downloads.
- **J3 404-after-sign (route stub):** the SPA stays, URL unchanged, no native dialog, row keeps guidance; if not, the preflight fallback is required.
- **J4 denied (stub):** embedded copy without "locked"; Roadmap shows a generic reason.
- **J5 network failure (stub):** reason plus focused Retry; Retry succeeds.
- **J6 list failure (stub bridge or resources):** a single page message plus Retry restores.
- **J7:** locked, paused, held, revoked, prerequisite, completed-then-held, and null-unlock cards show no materials (held and revoked are set via service-role test setup); exactly one `.control--primary`.
- **J8 keyboard:** Tab from Mark complete to resource buttons to open deck controls; Enter/Space; focus retained through states; accessible names include the lesson title.
- **J9:** flashcards toggle on `/learn` (`aria-expanded`, no refetch on toggle).
- **J10:** mark complete keeps materials intact.
- **J11 Roadmap:** rail layout, `aria-label` "Resources", empty-week copy, `IpNotice` order unchanged; Download works with the new lifecycle, no anchor left, no `lesson_content` row; the mobile Cards-tab overlay launcher is unchanged.
- **J12 (Step 5):** an authored lesson with a fixture PDF downloads via Edge signing; another student's enrollment and asset ids are denied generically; held and revoked authored lessons show no materials.

**Visible outcomes:** as listed per journey; no horizontal scroll at 390 (and 320 spot check); busy button cursor progress and no shadow; forced-colors visible border; screenshots of idle, signing, ready, error, denied, locked card, list-error, and open deck on both surfaces at both viewports saved under `browser-validation-artifacts/`.

## 10. Risks and rollback

| ID | Risk | Mitigation |
| --- | --- | --- |
| R1 | RLS or access widening (high impact) | No policy changes; the `/learn` legacy path is the intersection of existing RLS; Step 5 functions are security definer with parity filters, path never returned to the client, explicit revokes; CODE_REVIEW required; negative tests. Rollback: revert the PR; for Step 5 a down migration dropping the two functions and redeploying the prior Edge function. |
| R2 | Service-role use in a student Edge action (new pattern) | Authorization decided solely by the `auth.uid()`-bound SQL resolver; service role only signs the returned exact path; 300 s TTL; generic errors; SQL and Edge tests for the full confused-deputy list in Step 5; CODE_REVIEW required. Containment: the user may choose to drop Step 5 instead (D1 alternative), which defers authored delivery to a follow-up issue. |
| R3 | Hosted prerequisite: hosted handouts are still served as `text/plain` until #173 Phase P runs; downloads with `?download=` still save the file but inline preview may be wrong | Hard rollout gate (J-174-04): production rollout is BLOCKED until Phase P is complete and hosted content-type verification passes, recorded as evidence. The hosted check's `PENDING-PHASE-P` state is blocking for rollout. Local implementation, PR review, and local validation may proceed before Phase P. |
| R4 | Fixture change breaks existing tests or the #173 count assertions | Step 1 updates all listed references; full vitest run. Rollback: revert the commit. |
| R5 | Production naming regression via the `resolveResourceNaming` edit | Test that production-mode naming output is unchanged for all 78 entries (snapshot of `buildExpectedResourceTuples(manifest, false)` before vs after); `isFixtureDuplicateUploadToSkip` production behavior unchanged. |
| R6 | Cross-origin anchor download may navigate on 4xx (Chrome may ignore the `download` attribute cross-origin) | Dedicated journey J3; mandatory Range-GET preflight fallback if it fails. |
| R7 | Legacy date rule vs entitlement divergence leaves some cohort-anchored legacy cards without materials | Documented, silent empty per D3; follow-up issue; no policy change. |
| R8 | Local stack drift (edge runtime mounted from another worktree; stale storage volume) | Step 0 restart procedure; `db reset` reseeds `storage.objects` from `objects_path`. |
| R9 | Roadmap lifecycle change surprises users or tests | Explicit in this plan; guard tests updated deliberately; Roadmap visual non-regression checks. |

**Overall rollback:** revert the PR (local-only data and fixture changes; no hosted writes in this item).

## 11. Stale-plan conditions

The writer must return a blocker ("Plan stale") if any of the following holds:

- `origin/main` changes `ResourcesPanel`, `LearnDetailPage`, `learnData`, `storageSigning`, `provision-lessons` naming, the `seed.sql` resources block, storage/resources/`lesson_revisions` RLS, `get_student_learn_course`, or the `course-authoring` Edge student actions.
- #175 lands first and changes the panel.
- #173 Phase P state changes the hosted check expectations. If Phase P fails or is rolled back, production rollout is re-blocked.
- Local reset no longer yields entitlements for band enrollments.
- The 78-lesson manifest or naming convention changes.
- Any decision D1-D6 is answered differently from the defaults after approval.

## 12. Assumptions and decisions

**Safe assumptions:**

- The storage-js 2.110.7 `download` option behaves as documented (verify in Step 2 tests).
- `lesson_revisions_student_read` is the correct bridge (policy text verified; T1 confirms at runtime).
- Local reset plus provisioning yields 78 pdf resource rows.

**D1 is a user confirmation.** The coordinator will ask the user: "Confirm that #174 is accepted as: 78 legacy lessons fully working on both surfaces + secure authored per-lesson delivery path, with authored per-lesson generation and the export-registration bug tracked as follow-up issues A and B." Under this confirmation no authored lesson has a handout today, so authored students see no materials until per-lesson generation exists. Alternatives the user may choose instead (each changes scope and makes this plan stale): (b) also deliver the whole-course PDF only when every lesson in the version is visible-unlocked to that student; (c) defer authored delivery entirely to a follow-up issue (Step 5 dropped).

**D2-D6 are recorded as stated defaults.** Each is changeable by the user before approval.

- **D2 Instructor PPTX on `/learn`:** excluded (alternative: include as on Roadmap).
- **D3 Eligible card with zero materials:** silent empty card (alternative: one quiet line).
- **D4 Roadmap inline flashcards:** unchanged; toggle only on `/learn` embedded (alternative: adopt the toggle on Roadmap too).
- **D5 Legacy date-rule vs entitlement divergence:** accept the intersection, no RLS change, follow-up issue (alternative: open a separate reviewed policy change).
- **D6 Signed URL TTL for panel downloads:** 300 s (permitted 120-300).

## 13. Approvals

User approvals still needed:

1. Explicit approval of this plan before engineering (T1 is not dispatched until then), including answers to D1-D6 or acceptance of the defaults.
2. A separate explicit go-ahead naming `gvobtuhbpqvfhjljjcye` before running the hosted read-only check.
3. A separate explicit go-ahead for hosted migration and Edge deploy (Step 5). Both, and any production deploy of this UI, are additionally blocked until #173 Phase P is complete and hosted content-type verification passes (rollout gate, J-174-04).
4. Explicit authorization to commit, push, and open a PR at execution time.

## 14. Engineering mode and downstream owner

- **Engineering mode:** standard (no extreme advisory team; coupling is sequential and single-writer). T1 is first line; T2 takes over on two counted gate failures. `team_authorization`: not applicable.
- **Downstream owner:** engineering-fleet.

## Approval record

Approved by the user on 2026-10-04, relayed by the lead. This plan and `lizbeth-spanish-issue175-vocabulary-review-in-app` were approved together.

- Approved by: the user
- Date: 2026-10-04
- Covered: engineering per this plan, including commits, pushes, new branches, and pull requests per item (user standing instruction: new branches and PRs as needed).
- Decisions: D1 confirmed by the user as recommended. Done means all 78 legacy lessons work on Roadmap and `/learn`, plus a secure per-lesson authored delivery path. Follow-up issue A (per-lesson authored handout generation) and follow-up issue B (export registration passes the course id instead of the version id) are deliverables, to be drafted and filed when this item completes. D2 to D6 are accepted as the stated defaults.
- Rollout gate: the user agreed that production rollout of the handout UI is gated on #173 Phase P completion (J-174-04).
- Not covered: production writes (storage re-tag Phase P, hosted migrations, Edge Function deploys, Netlify deploys) each need a separate explicit user go-ahead. The read-only hosted check against `gvobtuhbpqvfhjljjcye` needs its own explicit go-ahead naming that project.

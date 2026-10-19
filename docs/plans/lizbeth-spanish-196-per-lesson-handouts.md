# Plan: Lizbeth Spanish #196, per-lesson printable handouts (Wave 8, PRs 8a, 8b, 8c)

- Plan id: `lizbeth-spanish-196-per-lesson-handouts`
- Task id: `lizbeth-wave8-196-lesson-handouts`
- Status: **APPROVED 2026-10-15 (Revision 1).** User words, verbatim, 2026-10-15: "Approve all four plans as recommended". Decisions D-196-1 to D-196-15 are adopted at their recommendations. This includes D-196-14 (the storage-policy hardening ships in PR 8a) and D-196-15 option B (honest disclosure plus a follow-up issue for an accessible lesson view), so the D-196-15 precondition for starting engineering is met. Each hosted step (H1a, H1b, H2, H3, H4) still needs its own separate explicit approval. Lizbeth must approve any drafted Spanish before it ships. Written 2026-10-15, Revision 1 applied 2026-10-15.

**Revision 1 (PLAN_DUCK J-196-001..009, shadow, Codex).** One revision applied in place across every affected section; no superseded text is kept. Planner re-checked each finding against the code and accepted all nine. Design review of the revised handoff (revision 3) is PASS and covers option B of D-196-15; its minor items R3-1 to R3-5 are folded into section 4. The status stays DRAFT. The base moved from `f8a95a3` to `73fe9f2`: the cited Edge action lines, migrations and student-surface lines were re-verified unchanged; PR #273 (self-hosted fonts) is now merged (F2). A premise correction (F17) removes every claim that an accessible HTML lesson exists for authored courses.

- Premise correction (F17, Observed). Authored (non-legacy) courses have no student-facing HTML lesson body view. For those students the handout may be the only way to read a lesson's text, and an untagged PDF does not meet WCAG 2.2 AA. The plan now discloses this and no longer calls the HTML lesson the accessible primary version or the PDF a companion to an online lesson. Sections touched: header, 1, 2, 3 (F17), 4.4, 4.12 to 4.14, 4.16, 10 (R6, R14), 12 (D-196-8, D-196-15), 13.
- J-196-001 (critical), ACCEPTED. Owner update and delete storage policies on `lesson-assets` have no version-status condition, so an owner session can overwrite or delete any object under an owned version-id prefix, including published versions. Remedy moves into PR 8a as a policy-only migration with rollback (finding F18, section 5.5). New decision D-196-14; new hosted read-only check H0 q5; new risk R13. Handout objects use content-addressed, intent-scoped paths and are never updated or deleted by any product path. Sections touched: 2, 3 (F18), 5.1, 5.5, 6, 7, 10, 12, 13.
- J-196-002 (major), ACCEPTED. The earlier `register` took a client path and removed the object on failure, so a bad-checksum replay against a live handout path could delete it, and concurrent register and cleanup was unguarded. Replaced by single-use server-side upload intents (new table `lesson_handout_upload_intents`); `register_lesson_handout` takes only the intent id; a failed verification deletes nothing. Sections touched: 5.1, 5.2, 7, 10 (R12).
- J-196-003 (major), ACCEPTED. The rollback no longer restores the old student RPC bodies. It keeps all three tables and the removal and per-version filters in the student RPCs, so removed or replaced handouts never reappear. Sections touched: 5.1, 7, 10.
- J-196-004 (major), ACCEPTED. `register_asset` no longer trusts a client `sha256` or `byte_size`; the Edge downloads the object, computes both, and stores the server values (PR 8a). Sections touched: 3 (F3), 6, 7.
- J-196-005 (major), ACCEPTED. Slots are per version, writes require the current published version, and student RPCs serve a handout only for the enrollment's own version. No automatic carry-over. D-196-2, D-196-5 and R8 reworded; new error key `versionNotCurrent`. Sections touched: 4.2, 4.3, 4.7, 4.12, 5.1, 5.2, 7, 10, 12.
- J-196-006 (major), ACCEPTED. Reconciliation: pending intents past expiry become expired; unreferenced objects of failed or expired intents older than 24 hours are moved (never deleted) to a quarantine prefix. R12 rewritten; "orphan cleanup deferred" removed. Sections touched: 5.1, 5.2, 7, 10.
- J-196-007 (major), ACCEPTED with correction. The finding asked for an online-lesson link beside each handout; none exists for authored courses (F17). New decision D-196-15: (B) ship with honest disclosure and file a follow-up for an accessible authored lesson view on `/learn`, or (A) build that view first. Sections touched: 4.4, 4.5, 4.12, 4.13, 12, 13.
- J-196-008 (minor), ACCEPTED. New generation rule: Generate is enabled when the lesson has any printable content for the slot language; cards and questions are not language-keyed. Sections touched: 4.4, 4.14, 5.3, 7, 8.
- J-196-009 (minor), ACCEPTED. PDF test methods revised: D-196-10 now recommends `pdfjs-dist` as a test-only devDependency, with a documented fallback. Sections touched: 7, 12.

- Parent: approved plan `docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md`, section 4.2 "#196", section 9 Wave 8, section 14 D-26 ("go, scoped to published-version-only generation, after #202"). #202 is merged (PR #251). #198 is merged (PR #258), not applied to hosted.
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team.
- Target: `lebobo88/lizbeth-spanish` at `main` `73fe9f2` (`73fe9f2455d74510b0b9472e58c0895979d4fcfd`; previously `f8a95a3`).
- Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013`, now at `73fe9f2`. Every `file:line` below refers to it. Items marked "re-verified at 73fe9f2" were rechecked on the new base: `course-authoring/index.ts` action lines (`sign_student_course_asset` :73, `get_version` :197, `list_assets` :418, `remove_asset` :441, `upload_asset` :452, `register_asset` :467, `save_revision` :494, unknown action :677), absence of any migration after `202610140001`, `ResourcesPanel.tsx:110`, `learnMaterials.ts:68`, `storageSigning.ts:325`, `LearnDetailPage.tsx:453`, `CourseWorkspacePage.tsx:32`, and the owner storage policies (only in `202608300003`). All other line references were observed at `f8a95a3` and must be re-verified at Step 0. Migration filenames are given by numeric prefix and slug under `supabase/migrations/`.
- Evidence labels: Observed (read in code, an approved plan or cited documentation), Inference (derived from Observed facts, with the test that verifies it), Unknown (not established).
- Design: Standard profile, reviewed `DESIGN_HANDOFF` revision 3, review verdict PASS (section 4).
- Judge route: Shadow (advisory), section 9.

Reading guide: approvers need sections 1, 2, 10, 12 and 13. Sections 3 and 4 hold the evidence and the reviewed design. Sections 5 to 9 are execution detail for the engineering fleet.

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

Carried forward from the user:

- Accomplish the goal with proper root-cause analysis.
- Pull requests only: base `main`, no push to `main`, the user merges.
- Production is LIVE. Nothing may be lost. Migrations are additive and non-destructive. Each hosted action is separately approved.
- Owner admin copy is English-only.
- Student Spanish strings are drafted for Lizbeth's approval and stay inert until she approves them.
- Deploy-skew safety: every new frontend degrades safely against an older backend, proven by an e2e run.

---

## 1. Outcome and audience

Audience: Rob (approver) and the engineering fleet.

Outcome: the owner (Lizbeth) can attach a printable PDF handout per lesson and per language (Spanish, English) to the CURRENT PUBLISHED version of an authored (non-legacy) course. She either generates it in the browser from the lesson's published content or uploads her own PDF, then previews, replaces, removes (soft) and restores it, with visible status. Handouts belong to one published version; there is no automatic carry-over. Entitled students download the handout of their own enrollment's version from the `/learn` lesson card under the canonical entitlement rule. Nothing is ever deleted. Every new frontend degrades safely against an older backend. Because authored courses have no student-facing lesson text view (F17), the handout may be the only way a student reads a lesson; the plan discloses that honestly and does not claim an accessible equivalent.

Delivery: three pull requests against `main`, serial, single writer: PR 8a (Edge hardening, server-side hashing, owner-write immutability policy), PR 8b (handouts migration, intents, Edge actions), PR 8c (frontend, "Closes #196"). No merge and no hosted action by the fleet.

## 2. Scope and non-goals

In scope:

1. Definition of a per-lesson, per-version authored handout.
2. Client-side PDF generation in the browser.
3. Upload with single-use server-side intents and server-side verification.
4. Owner "Handouts" tab with soft remove, restore and replace.
5. Student `/learn` labels, note and filenames.
6. Data model, RLS, Edge validation, ownership checks and upload reconciliation (quarantine, never delete).
7. Hardening of `register_asset`, `upload_asset` (including server-side hashing) and `save_revision` (adjacent findings), and the owner-write immutability policy for published and handout paths in `lesson-assets` (F18).
8. RED tests; e2e at 1440 and 390 including skew runs.
9. Hosted rollout plan and decisions.

Non-goals:

- Legacy (band) courses and Roadmap/WeekDetailPage (legacy-band-only; their curriculum handouts stay on `public.resources`).
- Draft-version handouts.
- Handout lineage and Reuse across versions, and automatic carry-over (deferred follow-up).
- An older-published-version selector (deferred).
- An accessible authored lesson view on `/learn` (follow-up issue under D-196-15 option B; its own sub-plan and design route under option A).
- Tagged PDF and PDF-UA.
- Embedding the self-hosted brand WOFF2 fonts (now on `main` via PR #273) in PDFs.
- Changing the shared `lesson-assets` bucket's `allowed_mime_types` or size limit.
- Changing #198 legacy policies.
- A student-language switching mechanism (ES strings stay inert drafts).
- Permanent deletion of quarantined objects (needs a separate approved data plan).
- Any hosted action or merge without separate approval; any commit or push to `main`.

## 3. Repository findings and evidence

Observed at `f8a95a3` unless marked "re-verified at 73fe9f2" or "new at 73fe9f2".

### 3.1 Findings

| Id | Finding | Label |
|---|---|---|
| F1 | PDF stack: `src/services/exports.ts:1-29` uses `pdf-lib` ^1.17.1 and `@pdf-lib/fontkit` ^1.1.1 (`package.json:36,45`), bundled static `src/assets/fonts/NotoSans-Regular.ttf` (`:8-9`, unchanged at 73fe9f2), `embedFont(..., {subset:true})` (`:26`), fixed creation and modification dates 2000-01-01 (`:25`). `generatePdfDocument` draws lines with no word wrap (`drawText` at x=54 with no `maxWidth`, `:27-28`), so long paragraphs overflow. `setTitle` is called without `showInWindowTitleBar`; there is no `setLanguage`. No unit test exercises `generatePdfDocument` (grep of `src/__tests__`). Only whole-course exports exist: Content tab "Build PDF/PPTX" downloads (`CourseWorkspacePage.tsx:233`) and Publishing `uploadGeneratedAsset(courseVersionId,'course.pdf'...)` (`:1255-1261`). | Observed |
| F2 | Self-hosted fonts PR #273 is now MERGED on `main` (new at 73fe9f2): `src/App.css:18` imports `./assets/fonts/fonts.css`; `src/assets/fonts/web/*.woff2` plus licenses exist; `NotoSans-Regular.ttf` is unchanged. The fonts are WOFF2 Latin and Latin-ext unicode-range subsets, several variable. They are web fonts only and must never be embedded in PDFs (RE1). The earlier stale-plan trigger "PR #273 merges" has fired and is resolved by this statement. | Observed |
| F3 | CORRECTION to parent evidence, re-verified at 73fe9f2: Edge `register_asset` does NOT check that `lesson_revision_id` is mapped. `register_asset` (`supabase/functions/course-authoring/index.ts:467-474`) checks only required fields, a 64-hex sha256, `byte_size >= 0` and version status `'draft'`, then inserts `course_assets` with the client-supplied `lesson_revision_id`, `storage_bucket`, `storage_path`, `sha256` and `byte_size` and `integrity_status 'verified'` WITHOUT downloading or hashing the object. The parent's ":440" points at `remove_asset` (`:441-451`), whose `:445` mapped-count check only refuses removal of referenced assets. `upload_asset` (`:452-466`) computes the hash server-side but accepts any `storage_bucket`/`storage_path` and any `lesson_revision_id` with no mapping check; no client caller sends `upload_asset`. Neither client helper sends `lesson_revision_id`: `uploadCourseAsset` and `uploadGeneratedAsset` (`src/services/courseAuthoring.ts:122,131`). Version ownership is enforced for `version_id` by `ownershipFailure` (`index.ts:115-127`). | Observed |
| F3i | Impact of F3: an owner session can make any `lesson-assets` PDF path student-deliverable on a draft version with a client-claimed checksum. Owner-only, so low severity, but it bypasses the verification this feature requires. | Inference |
| F4 | Student delivery (#174): `get_student_lesson_assets` and `resolve_student_course_asset` (`supabase/migrations/202610040002_issue174_student_course_assets.sql:27-102`) require own active enrollment, `is_account_active`, not `user_requires_password_change`, `ca.lesson_revision_id` not null, `content_type 'application/pdf'`, `integrity_status 'verified'`, `storage_bucket 'lesson-assets'`, revision mapped in the enrollment's `course_version`, entitlement `manual_release_state` not in (`'held'`,`'revoked'`) and (released or `unlock_at <= now()`). EXECUTE `authenticated` only (`:109-112`). `get_student_lesson_assets` returns only `asset_id`, `lesson_revision_id`, `display_name` (`metadata.display_name` else lesson title), `content_type` (`:36-41`); never a bucket or path. Edge `sign_student_course_asset` (`index.ts:66-96`, :73 re-verified at 73fe9f2) runs before the owner gate, resolves via the caller JWT client, path-guards bucket `lesson-assets` and traversal, signs 300 s with a sanitized `.pdf` download filename, and returns one generic 404 for every refusal. | Observed |
| F5 | Owner storage policies (`202608300003_storage_lesson_assets_owner_write_policies.sql:68-218`, re-verified at 73fe9f2 as the only owner policies): `owns_lesson_asset_path(name)` (first path segment = owned `course_version` id, guarded uuid cast, SECURITY DEFINER, boolean); owner INSERT/SELECT/UPDATE/DELETE on `lesson-assets`, deliberately not constrained to draft (`:105-115`). No student storage policy matches `course_assets` paths; the #198 storage policy only matches `public.resources` rows (`202610130002:59-94`). | Observed |
| F6 | `course_assets` table (`202608280003:86-101`): FKs `lesson_revision_id` and `course_version_id` ON DELETE CASCADE; `integrity_status` in (`'verified'`,`'unverified_legacy'`); unique (`storage_bucket`, `storage_path`, `sha256`); trigger `course_assets_immutable` rejects every UPDATE (`:103-107`). Soft remove cannot be an in-place UPDATE of `course_assets`; it needs a new table. `authenticated` has no grant on `course_assets` (`:531,536`); policy `course_assets_student_read` (`:523`) is inert. Legacy backfill rows are `'unverified_legacy'` with `content_type = resource_type` (`:580-585`), so never served. | Observed |
| F7 | #202 did NOT stop revision churn: `save_outline` (`202610120003_issue202_save_outline_identity.sql:31-84`) still deletes `course_version_lessons` and inserts a NEW `lesson_revisions` row for every lesson on every draft save; it only carries `legacy_lesson_id` forward. Authored lessons (`legacy_lesson_id` null) have no stable cross-version key. Handouts keyed on `lesson_revision_id` therefore orphan if attached to a draft; published versions are never rebuilt (`save_outline` requires status `'draft'`, `:40`). `clone_course_version` (`202608280003:323-342`) copies the published version's revision ids into the new draft, so a revision id can be shared by two versions until the draft's first save. Handout slots are therefore keyed per version (D-196-2) and are never carried over automatically. Lock order in `save_outline`: `courses` row then `course_versions` row (`:36-39`). | Observed |
| F8 | `save_revision` (`index.ts:494-504`, re-verified at 73fe9f2), VERIFIED: inserts `lesson_revisions` with `legacy_lesson_id = payload.legacy_lesson_id ?? null` with NO ownership check, a client-chosen `revision_no` (default 1), and returns raw `e.message` (409) on error. Client `saveRevision` exists (`src/services/courseAuthoring.ts:86`) but has no UI caller (grep). Containment today: `map_lesson` enforces legacy-band ownership (`index.ts:510-518`, J-202-001); `save_outline` only inherits a legacy link from a revision already mapped in the owner's draft with ownership (`202610120003:47-58`); `get_owner_resource_text` requires the revision mapped in an owned version (`index.ts:157-184`). Residual: unowned orphan revisions, `revision_no` squatting on unique (`legacy_lesson_id`, `revision_no`), raw error leakage. Low severity, owner-only. | Observed |
| F9 | #198 helpers (`202610130002:39-67`) govern only legacy `public.resources` and storage objects matched to `resources` rows; they do NOT govern `course_assets` handouts. The #174 RPC predicate is the same canonical rule (held/revoked excluded, released-early allowed), so handout gating is already consistent with #198 and 5c-2. `/learn` client gating `isMaterialsEligible` (`src/services/learnMaterials.ts:46-51`) hides materials for held/revoked (client value `'paused'`), locked, and no-entitlement lessons. Held and revoked weeks show no handout and signing returns the generic 404. | Observed |
| F10 | Student surfaces: authored courses use `/learn` only (`LearnDetailPage.tsx:444-458` "Lesson materials" with `ResourcesPanel` embedded; `fetchLearnMaterials` authored branch `learnMaterials.ts:78-97` maps every asset to `resource_type 'pdf'`; `learnMaterials.ts:68` re-verified at 73fe9f2). `course_is_legacy = courses.legacy_band_id is not null` (`202608310002:84,181`). Roadmap/WeekDetailPage reads legacy lessons and resources by band (`src/services/roadmapData.ts:95-119`), so it is not a handout surface. `RESOURCE_LABEL` `pdf` -> "Student handout (PDF)" (`ResourcesPanel.tsx:109-114`, :110 re-verified); `buildDownloadFilename` names every pdf row `${slug}-student-handout.pdf` (`src/lib/storageSigning.ts:325-340`, :325 re-verified) and `/learn` passes `downloadBasename={row.title}` (`LearnDetailPage.tsx:453`, re-verified), so two languages would collide on label and filename. | Observed |
| F11 | Owner workspace: `CourseWorkspacePage` (`src/pages/CourseWorkspacePage.tsx`) `TABS` (`:32`, re-verified) = outline, content, students, progress, activity, settings, versions, publishing; it loads the draft if one exists, else the latest (`courseAuthoring.ts:118` `getCourse`); `published_version_id` is the latest published (`:118`). The Students tab already scopes to `publishedVersionId` (`:99-102,130`). Content-tab file upload uses a label with a `hidden` input (`:250`), which is not keyboard operable. The page-level refresh at `CourseWorkspacePage.tsx:49` can overwrite unsaved draft blocks. Error mapper precedent: `src/lib/publishingErrors.ts` (never echoes `error.message`). Modal: `src/components/Modal.tsx` with `useFocusTrap` (initial focus on the dialog container, restores focus to the trigger). | Observed |
| F12 | Edge behaviour for skew: unknown actions return HTTP 400 `{error:'Unknown authoring action.'}` (`index.ts:677`, re-verified). `get_version` (`index.ts:197-217`, re-verified) returns `course_version_lessons` with `lesson_revisions(id, legacy_lesson_id, revision_no, title, description, content)` under the version ownership check. | Observed |
| F13 | Storage config: `supabase/config.toml:134-137` `lesson-assets` private, `file_size_limit` 50MiB locally, no `allowed_mime_types`; the hosted bucket is created outside migrations (`202607170003_storage_setup.sql`) and also holds pptx instructor decks (`202610050005`). | Observed |
| F14 | Product code never deletes `course_versions`, `lesson_revisions` or `courses` (grep of `supabase/`, `src/`, `scripts/`). Test cleanup helpers do delete `lesson_revisions` (#81 cleanup) and must delete `lesson_handout_events`, `lesson_handouts` and `lesson_handout_upload_intents` first once the FKs below exist. | Observed |
| F15 | Hosted state (from the parent plan header): migrations on `main` pending hosted apply, each needing separate approval: `202610110001`, `202610120001`, `202610120002`, `202610120003`, `202610130001`, `202610130002` (count unconfirmed); `202610130003` and `202610140001` exist on `main` after that note (status Unknown). No migration exists on `main` after `202610140001` (re-verified at 73fe9f2). | Observed / Unknown |
| F15i | `supabase db push` applies every pending migration in order, so neither the 8a nor the 8b migration can be pushed alone without explicitly approving the earlier ones. | Inference |
| F16 | Test assets to reuse: `src/__tests__/e2e/issue174-fixtures.ts`, `src/__tests__/e2e/issue174-handout-links.spec.ts`, `src/__tests__/issue174SignStudentCourseAssetEdgeLive.test.ts`, `src/__tests__/e2e/course-fixtures.ts` (`createOwnerCourseFixture`), `src/__tests__/helpers/testConfig.ts` (env-driven `SUPABASE_API_URL` and `SUPABASE_DB_PORT`, loopback guard), `playwright.config.ts` (baseURL from `E2E_BASE_URL`, workers 1, globalSetup re-anchor, globalTeardown loopback sweep). | Observed |
| F17 | PREMISE CORRECTION (new at 73fe9f2). Authored (non-legacy) courses have NO student-facing HTML lesson body view. `/learn` cards (`src/pages/LearnDetailPage.tsx:346-459`) render title, state, task link (`/learn/:e/lessons/:rev/tasks`), quiz link (`/quiz`), completion control and materials. No non-test `src` code reads `lesson_revisions.content` for students (only `learnMaterials.ts:99` reads `id`, `legacy_lesson_id`). `LessonContentView` renders only on the legacy `WeekDetailPage`. `get_student_learn_course` never returns content (`202608310002:23-31,163`). Consequence: for authored-course students the handout may be the only way to read a lesson's text, and the untagged PDF does not meet WCAG 2.2 AA (disclosed limitation, D-196-8, D-196-15). | Observed |
| F18 | Owner storage mutability (new, J-196-001). `owner_update_lesson_assets` and `owner_delete_lesson_assets` (`202608300003:183-194`, `:211-218`) use `owns_lesson_asset_path(name)` with no version-status condition (comment `:105-115` states this deliberately), so an owner session can overwrite (upsert) or delete any object under an owned version-id prefix, including published versions. | Observed |
| F18i | Production exposure assessment. Legacy student files live under band/week paths whose first segment is not a uuid, so they are not exposed. Objects under version prefixes today are whole-course publish exports (`${versionId}/generated/course.pdf|pptx`) and Content-tab uploads, which are not student-served. Per-lesson student-served `course_assets` rows are expected to be zero (H0 q1). Live student-facing exposure is believed nil, but published publish artifacts are mutable by an owner session (an integrity gap). Verified by H0 q1 and q5. | Inference |
| F18c | Compatibility of the fix: Publishing `uploadGeneratedAsset` upsert (`courseAuthoring.ts:131`) and the register-rollback `remove()` target draft or staged versions; the Content-tab upload is hidden for published versions (`CourseWorkspacePage.tsx:250`). RED-tested; Step 0 must find and deliberately update any existing test asserting owner upsert or delete on a published prefix. | Inference |

### 3.2 Research evidence (Researcher `RESEARCH_EVIDENCE`, accessed 2026-10-15)

Research ids are RE1 to RE3 to keep them distinct from the risk ids in section 10.

| Id | Claim | Label |
|---|---|---|
| RE1 | WOFF2 parses in `@pdf-lib/fontkit` 1.1.1, but WOFF2 with `subset:true` is broken for transformed glyf/loca (TTFSubset copies raw glyf bytes; upstream foliojs/fontkit #201 open since 2019-05-25; pdf-lib #1396 "RangeError: Index out of range" on 1.17.1). WOFF2 with `subset:false` writes non-TrueType bytes as FontFile2 (non-conformant). Variable fonts embed only the default instance (pdf-lib #853). Static TTF subsets work for Latin; no Latin static-TTF subset defect found. A ToUnicode CMap is written for subset fonts, so copy and paste of Spanish Latin-1 text works. | Observed (non-conformance of WOFF2 `subset:false` is Inference) |
| RE1r | Recommendation: embed only static TTF/OTF; keep `NotoSans-Regular.ttf`; never embed the WOFF2 files merged by PR #273; reject WOFF2, WOFF and `fvar` font bytes with a typed error. | Recommendation |
| RE2 | pdf-lib 1.17.1 has no tagged-PDF/PDF-UA API (#756 closed to roadmap). It can set Title with `showInWindowTitleBar` (DisplayDocTitle), catalog `/Lang` via `setLanguage`, author, subject and keywords. Recommendation: untagged with minimum metadata, and say so in the UI copy. | Observed |
| RE3 | Supabase hosted (docs accessed 2026-10-15): Edge 256 MB memory, wall clock 150 s Free / 400 s paid, 2 s CPU per request excluding async I/O, 20 MB bundle; no documented request body limit. Free plan global upload max 50 MB; standard uploads recommended up to 6 MB. Per-bucket `file_size_limit` and `allowed_mime_types` are enforced including on signed uploads, but the MIME check trusts the declared type (no sniffing), so server-side magic-byte and hash verification is required. | Observed |
| RE3i | Downloading and hashing a 10-20 MB object in an Edge function fits the limits. | Inference |
| RE3u | Unknowns: the Edge request body cap; whether `subtle.digest` counts toward the 2 s CPU limit; hosted bucket settings and plan limit (no hosted access). | Unknown |
| RE4 | `createSignedUploadUrl` is present in `node_modules/@supabase/storage-js/src/packages/StorageFileApi.ts`. | Observed |

Source ledger:

- S1 local `node_modules/@pdf-lib/fontkit` dist and README.
- S2 local pdf-lib `es/` sources.
- S4 https://github.com/foliojs/fontkit/issues/201
- S5 https://github.com/Hopding/pdf-lib/issues/1396
- S6 https://github.com/Hopding/pdf-lib/issues/853
- S10 https://github.com/Hopding/pdf-lib/issues/756
- S11 https://supabase.com/docs/guides/functions/limits
- S12 https://supabase.com/docs/guides/storage/uploads/file-limits
- S13 https://supabase.com/docs/guides/storage/buckets/creating-buckets
- S14 https://supabase.com/docs/guides/storage/uploads/standard-uploads
- S16 https://raw.githubusercontent.com/supabase/storage/master/src/storage/uploader.ts
- S17 https://raw.githubusercontent.com/supabase/storage/master/src/http/routes/object/uploadSignedObject.ts

## 4. Design (Standard profile, reviewed `DESIGN_HANDOFF` revision 3, verdict PASS)

`DESIGN_ROUTE`: profile standard; reasons: new multi-state owner flow inside an existing admin workspace plus a small student change; agents design-director (Sonnet 5, high), ux-architect, visual-system-designer, design-reviewer (Sonnet); prototype forbidden; `existing_system_mode` extend. Motion and assets were not invoked (no trigger recorded).

Review history: the first review returned NEEDS_REVISION (F1 to F12: Reuse/selector contradiction, lesson source, backend contract, hidden file input not keyboard operable, Modal focus contract, replace sub-state, per-slot errors and live-region prefix, stylesheet and chip specifics, Preview popup and disabled reason, student language rule, TipTap-to-PDF mapping, consistency). Revision 2 passed review. Revision 3 is a bounded delta (premise correction, per-version slots, upload intents, generation rule, PDF test methods, no URL in the PDF) and also passed review; it covers option B of D-196-15. If the user chooses option A, the disclosure strings get a brief design re-check. Engineering items from review:

- R2-1: cite `src/components/quiz/QuizStatusChip.tsx` and render the shared `.lesson-task-status-chip` classes plus `--handout` and `data-handout-state`; do not instantiate `LessonTaskStatusChip`.
- R2-2: `fetchLearnMaterials` must pass through the additive `language` and `kind` keys, and authored pdf filenames gain a language suffix while legacy filenames stay unchanged.
- R2-3: Restore without conflict announces "{Slot}: Restored." via the polite region (the separate inline "Restored." status is removed) and moves focus to the slot heading when the Restore control unmounts.
- R2-4: the lesson-switch lock is released by the request's own resolve, error or timeout (no separate UI timer), and object URLs are revoked on replace, lesson switch and unmount only (never after opening a preview).
- R3-1: the `versionNotCurrent` Reload control must not call the page refresh (`CourseWorkspacePage.tsx:49`), which can overwrite unsaved draft blocks. Use a narrower published-version refresh, or guard the refresh on a dirty draft.
- R3-2: place the student note before the materials list inside `.lesson-card-materials`, with an id referenced by `aria-describedby` on the handout Download controls.
- R3-3: show the owner accessibility disclosure once per lesson panel (or only once a PDF exists in that slot), and include the sentence "Students are told to ask their teacher for another format."
- R3-4: the `uploadExpired` copy is "This upload took too long and expired. Try again."
- R3-5: the student download filename is `{slug}-student-handout-{es|en}.pdf` (via `buildDownloadFilename`); the owner and signing filename is `{course-slug}-lesson-{nn}-handout-{es|en}.pdf`. The student RPC returns no lesson position or course slug, so the two differ; the difference is intentional and documented here.

### 4.1 Selected direction

Field Journal extended as-is, in a "ledger entry" treatment. A dedicated "Handouts" workspace tab holds two language-slot cards (Spanish, English) per lesson, scoped to the course's current published version. All status is text plus glyph. Every control, modal, chip and empty state is an existing shipped primitive, plus one thin wrapper (`HandoutStatusChip`). No new typeface, imagery, motion or tokens. Lizbeth works in English-only admin copy and is likely to attach handouts to several lessons in one sitting. The surface must make three things obvious: which published version, which lesson and language, and whether students can see the file now. Students see one new thing: a language-labelled download row plus one short honest note.

### 4.2 Placement and version bar

- `TABS` becomes outline, content, **handouts**, students, progress, activity, settings, versions, publishing. Route `/admin/courses/:courseId/handouts`, following the existing `tab` prop convention (`CourseWorkspacePage.tsx:32,37,130`).
- Props reuse those computed for the Students tab (`:99-102,130`). Recommended: `<Handouts courseId={course.course_id} publishedVersionId={publishedVersionId} publishedVersionNo={course.published_version_no ?? null} draftExists={course.status !== 'published' && !!publishedVersionId} onReloadCourse={...} />`, where `onReloadCourse` refreshes only the published version id (R3-1).
- Rationale: the Students-tab precedent; draft block ids are replaced on every save (`CourseWorkspacePage.tsx:84-91`, #202), so the tab fetches its own lessons via `get_version` and keys everything by version, lesson revision id and language; the 8-tab strip already scrolls horizontally (`:103-119`); Content is already dense (`:222-251`). Rejected alternative: a "Handouts" section inside the Content tab.
- Content-tab pointer: one static line (not a live region) under the Content toolbar, in both draft and read-only views: "Printable PDF handouts for published lessons live in the Handouts tab."
- Version bar: "Published version v{n} · Current". `v{n}` is IBM Plex Mono and "CURRENT" is a mono eyebrow, not a Badge. A 3px ink-1000 rule sits beneath it. No version selector.
- If a draft exists, a role=status note: "You're editing draft v{m} on other tabs. Handouts here apply to published v{n} only."
- If `earlier_versions_with_active_enrollments` is true, a second role=status note: "Students still on an earlier version won't see handouts attached here." Never shown otherwise.
- Static per-version line below the notes: "Handouts belong to one published version. After you publish a new version, attach its handouts again."
- Each slot heading names lesson and language, for example "Lesson 3 · {title}: Spanish".

### 4.3 Lesson source and layout

- The tab calls `get_version(publishedVersionId)` (Edge `index.ts:197-217`). Fields used: revision id, position, `title{es,en}`, `body{es,en}` (TipTap), `metadata.cards` (`{front, back}`), `metadata.questions` (`{prompt, answer}`; only prompts are used), kind, `legacy_lesson_id`, and the media URL for media lessons. It never reads the page-level `blocks`.
- 1440: two-column grid; left rail `minmax(220px,280px)` matching `.studio-layout` and `.lesson-navigator` (`src/pages/CourseWorkspace.css:203`), lessons in position order; right panel with two slot cards side by side via `grid-template-columns: repeat(auto-fit, minmax(min(100%, 20rem), 1fr))`.
- 390 and 320: the rail is replaced by the existing `.lesson-select` pattern (`CourseWorkspace.css:203-204`); slots stack; action rows wrap; the tab strip stays horizontally scrollable. At 320 every new text node uses `overflow-wrap: anywhere` and `min-width: 0`; no horizontal scroll.
- Lesson-switch lock: while any slot of the selected lesson is Generating, Uploading or Verifying, navigator buttons get `aria-disabled="true"` and the select gets native `disabled`, with the visible line directly above: "Wait for this handout to finish before switching lessons." The lock is released by the in-flight request's own resolve, error or timeout; there is no separate UI timer. A Preview-ready unattached file is discarded on switching, with the visible line under the preview: "Switching lessons discards this unattached preview." Tab switching is not blocked (`beforeunload` is prohibited); on return `list_lesson_handouts` is the source of truth.
- Slot state is keyed by `{course_version_id}:{lesson_revision_id}:{language}`, never by list index or position. Object URLs are revoked on replacement, lesson switch and unmount only (R2-4).

### 4.4 Lesson panel, slot card anatomy and actions

Once per lesson panel, above the two slot cards, the owner accessibility disclosure appears (R3-3): "For students, this PDF may be the only way to read this lesson's text. Generated handouts have selectable text but are not tagged for screen readers. Students are told to ask their teacher for another format." It is advisory text (the existing `.schedule-severity-advisory` treatment after a contrast check, or a flat paper-200 note with ink-900 text). Permitted variation: show it only once a PDF exists in a slot.

Slot card, top to bottom:

1. Slot heading (h3, Fraunces unchanged), `tabindex="-1"`, the focus target for completion events.
2. `HandoutStatusChip` (glyph plus word).
3. Active-handout summary when Available: "Generated from published content · attached {date}" or "Uploaded · {filename} · attached {date}". Filename and date are mono.
4. Replacement secondary line, only during a Replace.
5. Image notice when the lesson body contains images: "Images in the lesson aren't included in the PDF."
6. Action row (with the upload accessibility warning directly beneath the Upload control, see 4.5), then the slot's error block directly beneath the action row (role=alert).
7. "Removed handouts" disclosure (quiet-outline, `aria-expanded`, collapsed by default). Each removed row has a mono removed-date, filename or "Generated", and a secondary "Restore" control.

Actions:

- Generate (secondary). Generation rule: Generate is enabled for a language slot when the lesson has ANY of: body text in that language (non-whitespace after flattening), vocabulary cards (`metadata.cards {front, back}`), quiz prompts (`metadata.questions {prompt}`; the answer is never printed), or a media link. Eligibility is evaluated on the content that will actually print for the lesson's kind, so a handout is never title-only. Cards and questions are not language-keyed (Observed: `StructuredRows` in `CourseWorkspacePage.tsx:253-254`), so both slots print the same cards and prompts under slot-language headings. Title is `title[lang]`, falling back to the other language's title; the fallback is marked only by the language tag in the title block. Native `disabled` only when none of these exist, with the visible adjacent reason: "This lesson has no {Spanish|English} text, vocabulary, questions or media link to put in a handout yet." `aria-describedby` is supplementary.
- Upload PDF (see 4.5).
- Preview (secondary) (see 4.6).
- Attach (primary, one per view). Enabled once a local PDF is held. On an Available slot, Attach opens the Replace modal first. When the held file is an upload, Attach's `aria-describedby` includes the upload accessibility warning.
- Remove (caution-reversible) opens the Remove modal.
- Retry (secondary), shown only after Verification failed, an expired intent, or a failed replacement.

### 4.5 Upload control

- Do not use the `hidden` attribute and do not copy the Content tab's hidden-input pattern (`CourseWorkspacePage.tsx:243-250`). Render a real `<input type="file" accept="application/pdf">` visually hidden with the clip pattern (`position:absolute; width:1px; height:1px; margin:-1px; padding:0; overflow:hidden; clip:rect(0 0 0 0); clip-path:inset(50%); white-space:nowrap; border:0`), kept in the tab order, with a visible `<label for>` "Upload a PDF handout" styled to Control-secondary geometry (48px, 3px ink-1000 border, `--shadow-card`).
- Visible focus ring via `:focus-within` on the wrapper (or `input:focus-visible + label`) using the global 3px `--color-focus-ring` at 2px offset, plus a forced-colors outline (`outline: 2px solid Highlight`).
- The input is not `disabled` while busy; busy blocks via `aria-disabled` on the wrapper and ignored change events.
- Two visible helper lines sit directly beneath the control, linked by `aria-describedby`: the hint "PDF only, up to 10 MB." and the upload accessibility warning: "Uploaded PDFs may not work with screen readers. Prefer Generate, or make sure your PDF has selectable text." The warning is visible before the owner chooses a file and stays visible through Preview ready until Attach. Style with the existing advisory treatment (`.schedule-severity-advisory`, used at `CourseWorkspacePage.tsx:202`); verify its text meets 4.5:1, otherwise use a flat paper-200 note with ink-900 text.
- Validation order on choose: extension `.pdf` (else `notAPdf`), MIME `application/pdf` (else `notAPdf`), size <= 10,485,760 (else `fileTooLarge`), then read the first five bytes and require `%PDF-` (else `notAPdf`). Failures render inline with no network call and no state change. The input keeps focus, its value is cleared so the same file can be re-chosen, and the message is linked by `aria-describedby`. Client checks are advisory; the server is authoritative.

### 4.6 Preview

- Local (unattached) Preview: `window.open(objectUrl, '_blank')` synchronously in the click handler, with `opener = null`. The object URL is not revoked on open.
- Active-file Preview (signed): open a blank window synchronously (`const w = window.open('', '_blank'); if (w) w.opener = null`), then after `sign_owner_lesson_handout` resolves set `w.location.href` to the signed URL. If signing fails, close the blank window and show the mapped error (`previewFailed`) adjacent to the action row.
- If `window.open` returns null, show `previewBlocked` inline and offer a secondary "Download" fallback using the transient-anchor pattern from `ResourcesPanel.tsx` with the filename from the signed response.
- A same-page viewer is a permitted alternative. Focus returns to Preview in either case. Preview is never a native dialog.

### 4.7 Slot state machine

```text
None -- Generate -> Generating -> Preview ready (local) -- Attach -> Uploading -> Verifying -> Available to students
None -- choose valid PDF -> Preview ready -- Attach -> Uploading -> Verifying -> Available
Generating -- build fails (including unsupportedCharacters) -> None, plus inline error. Nothing is uploaded.
Uploading -- network error -> None (or the prior Available state, untouched), plus inline error.
Uploading or Verifying -- verification failure or expired intent -> Verification failed (client-held, bytes retained) -- Retry (new intent) -> Uploading -> Verifying
Any write -- version not current -> the slot's error block with versionNotCurrent and a "Reload handouts" control; no state change
Available -- Attach another file (Replace modal confirm) -> Available with the replacement sub-state -> Available (new file); the previous file moves to Removed
Available -- Remove (modal confirm) -> None, row in Removed handouts, disclosure auto-expanded
Removed -- Restore, slot is None -> Available. No modal.
Removed -- Restore, slot is Available -> Restore-conflict modal -> Available; the current handout moves to Removed
```

"Preview ready" is a transient local compose state, not a server status. "Verifying" is the in-flight `register_lesson_handout` call; "Uploading" covers hashing, prepare (a new single-use intent) and the upload to the signed token. Neither is persisted. "Verification failed" is client-held and lost on reload, when the slot returns to the server's state. Retry requests a new intent and re-uploads the locally held bytes, then re-registers; if the bytes are gone, Retry reopens compose with identical copy.

Replace sub-state: the chip stays "Available to students" (the current handout stays active and visible to students until the new one verifies). A plain-text secondary line (not a live region) shows "Replacement: Uploading…", "Replacement: Verifying…", or "Replacement couldn't be verified. The current handout is unchanged." with Retry beside it (corrected `.form-error` pattern). On success the line disappears, the summary updates, and the previous file appears under Removed handouts.

Restore semantics: Restore sends `expected_active_handout_id` equal to the active id the UI shows, or null when the slot shows None. Slot None: no modal, expected = null; on success announce "{Slot}: Restored." through the polite region, and focus moves to the slot heading when the Restore control unmounts. Slot Available: Restore-conflict modal first, expected = current active id. Server 409 `handout_slot_changed`: show `conflict` copy with a secondary "Reload this lesson" control that refetches `list_lesson_handouts` and keeps lesson and language selected.

Version not current: if a write returns the version-not-current code, show `versionNotCurrent` adjacent to the slot's action row with a secondary "Reload handouts" control. It calls `onReloadCourse` (the narrower refresh, R3-1) to refresh the page's published version id, then refetches `get_version` and `list_lesson_handouts`. Unattached local previews are discarded with the visible preview-discard note.

### 4.8 Whole-tab states

- Loading: `<p role="status">Loading lessons…</p>` while `get_version` and `list_lesson_handouts` are fetched in parallel.
- Load error: role=alert block with mapped copy (`network`, `permission`, `lessonsLoadFailed` or fallback) and a secondary "Try again". Focus stays on the tab.
- Draft-only, never published: `JournalEmptyState` "Handouts can be attached once this course has a published version." with an optional secondary "Go to Publish" (match the on-screen label of the existing publish tab exactly). No fetch, no version bar, no lesson list.
- Legacy-backed (`version.course_is_legacy` true): flat paper-200 note (`.studio-readonly`-style, role=status), no lesson list, no actions: "This course's curriculum handouts are managed by the curriculum, so there are no handout actions here." A single lesson with a non-null `legacy_lesson_id` inside an otherwise authored course shows the same note in place of its slots.
- Feature unavailable: only for the two capability responses (HTTP 400 `Unknown authoring action.`; 503 `handouts_unavailable`), both from `list_lesson_handouts`. Flat paper-200 note, role=status (never alert): "Handouts aren't available yet." No actions, no version bar, no lesson list. Every other failure is an error with Try again.

### 4.9 Modals

Replace, Remove and Restore-conflict use `src/components/Modal.tsx`.

- Initial focus lands on the dialog container (`tabIndex={-1}`, `Modal.tsx:114`; `useFocusTrap.ts:109-110`). Pass `ariaDescribedBy` pointing at the body paragraph id.
- Cancel, Escape and Close restore focus to the trigger. Confirm success: after the closed state commits (in an effect running after the Modal's own focus restore) move focus to the slot heading; a test asserts the final focus target.
- Remove and Restore-conflict in flight: `suppressDismiss` on Modal (hides Close, disables Escape and backdrop dismissal), `aria-busy="true"` and `aria-disabled="true"` on Confirm (kept focusable), busy label, Cancel `aria-disabled`. On failure: mapped error as a role=alert block inside the modal body, modal stays open, `suppressDismiss` cleared, Confirm retryable.
- Replace differs: Confirm closes the modal right away because upload and verification are long; failures appear in the slot.
- Copy:
  - Replace: title "Replace this handout?"; body "Replacing this handout will move the current one to Removed, where you can restore it. Students keep the current handout until the new one is verified."; confirm "Replace"; cancel "Cancel".
  - Remove: title "Remove this handout?"; body "Students will no longer see this handout. You can restore it from Removed handouts."; confirm "Remove"; busy "Removing…"; cancel "Cancel".
  - Restore-conflict: title "Restore this handout?"; body "Restoring will replace the handout students currently see. The current one moves to Removed."; confirm "Restore"; busy "Restoring…"; cancel "Cancel".

### 4.10 Focus table

| Trigger | Focus lands |
|---|---|
| Generate or Upload begins | Stays on the activating control (`aria-busy`). |
| Generate completes | Preview, if focus is still inside the slot card. |
| Valid file chosen | Stays on the file input; Preview is the next tab stop. |
| Attach reaches Available | Slot heading (`tabindex=-1`), if focus is inside the slot card and not already on the heading. |
| Verification fails or intent expires | Retry (initial or replacement). |
| Modal opens | The dialog container. |
| Modal Cancel, Escape or Close | The trigger control. |
| Modal Confirm succeeds | Slot heading, set after the close commits. |
| Modal Confirm fails | Stays inside the modal on Confirm; the role=alert block announces the error. |
| Restore without modal succeeds | Slot heading, when the Restore control unmounts. |
| Preview blocked or sign failure | Stays on Preview; the error appears adjacent. |
| Version not current | Stays on the activating control; the error and the Reload handouts control appear adjacent. |

Generate uses `aria-busy` with `aria-disabled` (not native `disabled`) so it keeps focus.

### 4.11 Live regions

One persistent polite region (role=status, `aria-live="polite"`, `aria-atomic="true"`) is always mounted in the Handouts panel. Text is replaced from completion handlers, never from render. Every message is slot-prefixed (for example "Spanish handout, Lesson 3: Uploading…"). Failures use a separate role=alert adjacent to the slot's action row and are not duplicated into the polite region. Messages:

- "{Slot}: Generating handout…"
- "{Slot}: Handout ready to preview."
- "{Slot}: Uploading…"
- "{Slot}: Verifying file…"
- "{Slot}: Handout available to students."
- "{Slot}: Replacement uploading…" and "{Slot}: Replacement verifying…"
- "{Slot}: Handout removed. You can restore it below."
- "{Slot}: Restored."

### 4.12 Owner copy deck and `HANDOUT_COPY`

Status words: None, Generating, Uploading, Verifying, Available to students, Verification failed, Removed, Preview ready. Other owner strings: file input label "Upload a PDF handout"; hint "PDF only, up to 10 MB."; image notice, lock reason, discard note, version notes, per-version line, accessibility disclosure, upload accessibility warning, disabled-Generate reason, modal and replacement copy as given in 4.2 to 4.9.

`HANDOUT_COPY` keys (a constants module with `mapHandoutError(error, operation)` mirroring `src/lib/publishingErrors.ts`):

| Key | Text |
|---|---|
| `network` | Couldn't reach the server. Check your connection and try again. |
| `permission` | You don't have permission to manage handouts for this course. |
| `fileTooLarge` | This file is larger than 10 MB. Choose a smaller PDF. |
| `notAPdf` | Only PDF files can be attached as a handout. Choose a file ending in .pdf. |
| `verificationFailed` | This file couldn't be verified and wasn't attached. Try again. |
| `uploadExpired` | This upload took too long and expired. Try again. |
| `unsupportedCharacters` | This lesson has characters the handout font can't print, such as emoji. Remove them from the lesson or upload a PDF instead. |
| `lessonNotInVersion` | This lesson isn't part of the published version anymore. Reload this lesson to see what's current. |
| `versionNotPublished` | Handouts can only be attached to a published version. Publish this course first. |
| `versionNotCurrent` | This version is no longer the current published version. Reload to manage handouts for the current version. |
| `conflict` | This handout was changed in another tab. Reload this lesson to see the current version. |
| `featureUnavailable` | Handouts aren't available yet. |
| `lessonsLoadFailed` | Couldn't load the published lessons. Try again. |
| `previewBlocked` | Your browser blocked the preview window. Allow pop-ups for this site, then try again. |
| `previewFailed` | Couldn't open the preview. Try again. |
| `genericFallback` | Couldn't complete that action. Try again, and contact support if it keeps happening. |

Controls for errors: `conflict` offers "Reload this lesson"; `versionNotCurrent` offers "Reload handouts"; `verificationFailed` and `uploadExpired` offer "Retry"; load errors offer "Try again".

Mapper contract: never returns or echoes `error.message`; log the original to the console only. Mapping order: capability (applies only to `list_lesson_handouts`), then 401/403, then 409 `handout_slot_changed`, then size, type, verification, expired intent, unsupported characters, lesson, version-not-published and version-not-current codes, then network or offline (TypeError or `navigator.onLine === false`), then fallback. Stable code strings other than `handout_slot_changed` are an engineering confirmation.

### 4.13 Student strings

English (ships now):

- `handout_es_label`: "Student handout (PDF, Spanish)"
- `handout_en_label`: "Student handout (PDF, English)"
- fallback when language is absent: "Student handout (PDF)"
- note: "Printable handout for this lesson. If you need it in another format, ask your teacher."
- download control: "Download {label}"
- accessible name: `Download {label} for "{lesson title}"`

Spanish: **DRAFT, pending Lizbeth's approval, not machine-validated.** Inert catalog entries, not rendered by any code path, not to ship until she approves them and a student-language mechanism exists.

- `handout_es_label`: "Material para imprimir (PDF, español)"
- `handout_en_label`: "Material para imprimir (PDF, inglés)"
- `note`: "Material imprimible de esta lección. Si lo necesitas en otro formato, pídeselo a tu docente."
- `download_control`: "Descargar {label}"

Label rule (additive RPC keys from `get_student_lesson_assets`, passed through `fetchLearnMaterials`): `kind === 'lesson_handout'` with `language === 'es'` gives the Spanish label; with `'en'` the English label; `language` absent or null (old backend or legacy `pdf` row) gives the existing "Student handout (PDF)" label and no note. The suffix always shows when the language is present, even for one handout. Handout rows are ordered ES then EN, grouped after the lesson's existing materials. Implement by extending `labelFor` in `src/components/ResourcesPanel.tsx` with optional `language` and `kind` on the resource row type; do not rename the `pdf` entry in `RESOURCE_LABEL` (`:110`). The note renders once per lesson card, only when at least one row has `kind === 'lesson_handout'` with a non-null language, as a plain caption (ink-700, `--font-size-caption`, non-italic, wrapping at 320px), placed before the materials list inside `.lesson-card-materials` with an id referenced by `aria-describedby` on the handout Download controls (R3-2). Filenames: authored handout rows download as `{slug}-student-handout-es.pdf` or `-en.pdf` (R3-5); legacy `pdf` rows keep their current filenames. Unchanged: fresh signed URL per activation, inline error on failure, `isMaterialsEligible` gating (locked, held and revoked show nothing). Rows reuse `.resources-panel-row` and `.resources-panel-row-main`.

If option A of D-196-15 is later approved, the owner disclosure and student note are replaced by the strings under the design's `if_online_lesson_route_exists` (owner "Students can read this lesson online. This PDF is a printable version of it."; student link "Open the online lesson"; student note "Printable handout for this lesson."; optional PDF title-block line "Online course: {site origin}/learn"). Until then none of these appear.

### 4.14 PDF layout spec

- Page: US Letter portrait, 612 x 792 pt. Margins: top and bottom 72 pt, left and right 63 pt. Text width 486 pt (right margin edge at 549 pt).
- Font: Noto Sans Regular only (static TTF via pdf-lib with fontkit). No bold, italic, WOFF2 or variable fonts. Hierarchy by size, caps, letter-spacing and rules.
- Glyph policy: before drawing, check every code point of every string (title block, body, vocabulary, quiz prompts, media link) against the embedded font (for example fontkit `hasGlyphForCodePoint`), NFC-normalized, tabs mapped to spaces, control characters stripped. Any missing glyph blocks generation with `unsupportedCharacters`; never substitute, never draw a notdef box, never drop characters. Required coverage: á é í ó ú ñ ü Ñ ¿ ¡ « » “ ” — · •. If the bundled subset lacks any, ship a full Latin static TTF.
- Title block: course title 16 pt; below it `Lesson {n}: {lesson title}` at 20 pt (`title[lang]`, falling back to the other language); language tag in the handout's own language, uppercase, 1 pt letter-spacing, `ESPAÑOL` or `ENGLISH`, 10 pt (the only marker of a title fallback); a 2 pt ink-1000 rule, then 18 pt space. No URL or "Online course" line.
- Body: 11 pt, line-height 1.4 (15.4 pt), left-aligned, word-wrapped to 486 pt, paragraph spacing 8 pt. Headings in body: 14 pt and 12 pt Regular, 0.75 pt rule above, 12 pt space before.
- Vocabulary: heading "Vocabulary" / "Vocabulario" (slot language), two columns with a 20 pt gutter, each card `front — back` from `metadata.cards` at 11 pt, filled left then right; cards never split across columns or pages; both slots print the same cards; section omitted if no cards.
- Practice questions: heading "Practice questions" / "Preguntas de práctica", numbered list of `metadata.questions[].prompt` only at 11 pt, never `answer`. A 10 pt line follows: "(Answers are not included.)" / "(Las respuestas no están incluidas.)". Both slots print the same prompts; omitted if no questions.
- Footer: Noto Sans Regular 9 pt, centered, 36 pt from page bottom: `Page {n} of {N}` (es: `Página {n} de {N}`) on every page.
- Metadata: Title `{Course title} · Lesson {n}: {lesson title} ({Español|English})`; Language `es` or `en`; Title shows in the viewer title bar (DisplayDocTitle). Untagged and not PDF/UA, a documented limitation disclosed to the owner and the student; generated PDFs have selectable, copyable text. Dates fixed so identical input yields an identical SHA-256.
- Filename (owner and signing): `{course-slug}-lesson-{nn}-handout-{es|en}.pdf`, zero-padded two-digit position.
- Colour: pure white page; body and footer ink-900 `#2a2420` (rgb 0.165, 0.141, 0.125); title rule and headings ink-1000 `#1a1512` (rgb 0.102, 0.082, 0.071); no tints.
- Lesson kinds: standard lesson gets title block, body, then vocabulary and quiz sections if present; media lesson gets title block, body, one plain-text paragraph `Media link: {url}` (no annotation, embed or thumbnail), then vocabulary and quiz sections if present; checkpoint and any other kind get title block and body text only.

TipTap mapping:

| Node | PDF |
|---|---|
| doc, paragraph | Body paragraph, 11 pt. An empty paragraph adds one line of spacing only between two non-empty paragraphs. |
| heading level 1 or 2 | 14 pt heading with rule above. |
| heading level 3 | 12 pt heading. |
| heading level 4 to 6 | Flattened to a body paragraph. |
| bulletList / listItem | Hanging-indent list, bullet `•`, 14 pt indent per nesting level to depth 3, deeper levels flattened to depth 3. |
| orderedList / listItem | Hanging-indent list with `1.`, `2.` numbering restarting per list, same indent rule. |
| marks: bold, italic, strike, underline, code, highlight | Flattened to plain text. |
| link mark | Link text followed by ` (url)` when the text differs from the URL; the bare URL once when equal. Plain text, not a clickable annotation. |
| hardBreak | Line break within the paragraph. |
| blockquote | Flattened to body paragraphs with a 14 pt left indent. |
| codeBlock | Flattened to a body paragraph in Noto Sans Regular, line breaks preserved. |
| horizontalRule | 0.5 pt rule across the text width. |
| table / tableRow / tableCell | Flattened row-wise: one line per row, cells joined with ` | `. No grid or borders. |
| image | Dropped, no placeholder. The owner sees the image notice in the slot. |
| any unknown node | Its text content is flattened if it has any; otherwise dropped. |

### 4.15 Visual system and chip map

- Typography: body and summary 17px `--font-family-body` (Source Sans 3); machine facts (`v{n}`, filenames, dates, status words, CURRENT eyebrow) in IBM Plex Mono; headings unchanged (Fraunces 600). The version bar, notes and slot labels are not headings. The self-hosted fonts from PR #273 are the shipped web fonts; the plan introduces no new font.
- Contrast (verified against `src/tokens/field-workbook.generated.css`): ink-900 `#2a2420` on paper-200 `#f0ebe2` 12.9:1; ink-700 `#504940` on paper-50 `#fdfcf9` 8.64:1; brass-700 `#7c6136` on paper-100 `#faf8f4` 5.46:1; ink-slate `#3d5f6b` on paper-100 6.49:1; terracotta-600 `#a85e4a` on paper-50 4.69:1 (passes AA at 13px chip text); ink-moss `#2f5d3f` on paper-50 7.41:1.
- Errors, validation, replacement-failure and disabled-reason text use the corrected `.form-error` pattern (`src/App.css:1485-1494`): ink-900 text, terracotta only as a 3px left rule, role=alert for failures. Do not reuse raw `.field__error` terracotta text. The owner disclosure and upload warning are advisory text, not errors.
- `HandoutStatusChip` follows the `QuizStatusChip` pattern in `src/components/quiz/QuizStatusChip.tsx`: shared `.lesson-task-status-chip` classes (with the tier class for the status) plus a `--handout` modifier class and `data-handout-state`, an aria-hidden glyph, and the visible word; no colour declarations of its own; `LessonTask.css` untouched.

| State | Glyph | Tier |
|---|---|---|
| None | ○ | neutral (ink-700 text and border, paper-50) |
| Generating | ◆ | slate (ink-slate, paper-100) |
| Uploading | ↑ | slate |
| Verifying | ◇ | slate |
| Available to students | ✓ | success (ink-moss, paper-50) |
| Verification failed | ↺ | error (terracotta-600, paper-50) |
| Removed | – | neutral |
| Preview ready | ✎ | warning (brass-700, paper-100) |

- Forced colors: existing mapping `src/components/lessonTask/LessonTask.css:146-165` (`forced-color-adjust: none`; warning dashed, slate double, error dotted, success solid, neutral solid). Disclosed limits: Generating, Uploading and Verifying share the double border; None, Removed and Available share a solid border style. The word and glyph carry meaning.
- Slot card `.handout-slot`: `border: var(--border-width-rule) solid var(--color-ink-1000)`, `box-shadow: var(--shadow-card)`, `border-radius: var(--radius-square)`, padding `var(--space-4)`, matching `AssetCard.css`. Action row flex-wrap, gap `var(--space-2)`, controls 48px (`--control-height`; verify the token exists). Slot grid gap `var(--space-4)`; rail gap `var(--space-3)`. Navigator rows (`CourseWorkspace.css:203`): default transparent; hover paper-100; selected `border-color: var(--color-terracotta-600); background: var(--color-paper-200)`; focus the global 3px `--color-focus-ring` at 2px offset (`App.css:206-214`); locked uses `aria-disabled` with GrayText in forced-colors.
- Handouts-scoped stylesheet (for example `src/pages/HandoutsTab.css`), scoped to `.handout-slot` only: re-declare the busy paint for `[aria-busy="true"][aria-disabled="true"]` controls (`cursor: progress; transform: none; box-shadow: none;`; the existing rules in `ResourcesPanel.css:106-110` do not apply); apply a doubled-class specificity guard (for example `.handout-slot .control.control`) so the busy and disabled paint beats `Control.css` `:hover` and `:active`; re-declare forced-colors paint for `[aria-disabled="true"]` controls (`color: GrayText; border-color: GrayText`) and the label-styled upload control (`outline: 2px solid Highlight` on `:focus-within`). Do not edit `Control.css`, `LessonTask.css`, `Field.css`, `Modal.css`, `AssetCard.css`, `JournalEmptyState.css` or legacy `ResourcesPanel.css` rules.
- Control tiers: Generate, Upload, Preview, Retry, Restore and the Reload controls secondary; Attach primary; Remove caution-reversible; modal confirms caution-reversible (never caution-irreversible). Busy is `aria-disabled` plus `aria-busy`, never native `disabled`. Native `disabled` only for Generate with no printable content. The disclosure toggle is `Control tier="quiet-outline"` with `aria-expanded`. A removed row has a thin ink-1000 border (`--border-width-thin`), padding `--space-3`, a mono date and a secondary Restore.
- Student side: the note is two sentences and must wrap cleanly at 320px; the download control keeps its 48px target.
- No new tokens. The `handout.*` names are descriptive aliases only (`handout.slot.border` -> `{border.width.rule}` with `{color.ink.1000}`; `handout.slot.shadow` -> `{shadow.card}`; `handout.status.<state>` -> the tiers above). No ninth Control tier, no Badge variant. Reduced motion: no new animation. Motion and asset spec: not applicable.

### 4.16 Engineering invariants

1. No native `alert`, `confirm`, `prompt`, `window.*` variants or `beforeunload`. Confirmations use `Modal.tsx`. The OS file chooser and `window.open` for Preview are not dialogs under this rule. Add a deterministic no-native-dialog source scan.
2. Modal contract as in 4.9.
3. The tab fetches via `get_version(publishedVersionId)` and never reads page `blocks`. Handouts are managed against the current `publishedVersionId` only; a draft existing must not change which version is edited. No version selector, no cross-version Reuse, no automatic carry-over.
4. Slot state keyed by `{course_version_id}:{lesson_revision_id}:{language}`; revoke object URLs on replace, lesson switch and unmount only.
5. Lesson switching disabled with the visible reason while a slot is Generating, Uploading or Verifying; released by the request's own resolve, error or timeout.
6. Generate follows the generation rule (4.4). Unprintable characters block with `unsupportedCharacters`; never substitute silently.
7. Honest disclosure: do not describe the PDF as a companion to an online lesson, and do not state that an accessible HTML lesson exists, anywhere in the owner UI, student UI or PDF, unless an online authored lesson route exists. The owner disclosure and upload warning, and the student note with its alternative-format path, are required copy.
8. The generated PDF never contains quiz answers; a test asserts no fixture `answer` string appears in the PDF text.
9. Embed only the static Noto Sans Regular TTF. No WOFF2 or variable fonts, and no use of the PR #273 fonts. Set PDF Title and Language. Do not claim the PDF is tagged or accessible.
10. Server verification (size cap 10,485,760 bytes, `%PDF-` magic bytes, SHA-256) is authoritative; client checks are advisory. A Replace attempt never removes the active handout until the new one verifies. Copy says "10 MB" consistently.
11. Upload intents are single-use and expire after one hour; `register` takes only the intent id. Retry requests a new intent and re-uploads the held bytes. An expired intent maps to `uploadExpired`; a non-current version maps to `versionNotCurrent`.
12. Remove is soft; nothing is deleted. Replace moves the previous handout to Removed. Restore sends `expected_active_handout_id`; a 409 `handout_slot_changed` maps to `conflict` with "Reload this lesson".
13. Capability fallback applies only to `list_lesson_handouts` HTTP 400 `Unknown authoring action.` and 503 `handouts_unavailable`.
14. Errors pass through the stable-copy mapper; raw backend or Postgres text is never rendered or echoed; the original is logged to the console only.
15. Status is text plus glyph, never colour alone. Transitions (including Restore) are announced once from handlers into one persistent polite region; failures use role=alert adjacent to the action row.
16. The upload input is visually hidden by the clip pattern and stays focusable; never the `hidden` attribute.
17. Signed Preview opens a blank window synchronously and sets its location after signing; a blocked window shows `previewBlocked` and offers Download.
18. Student downloads keep fresh-signed-URL-per-activation; locked, held and revoked lessons show no materials; the legacy `pdf` label and filename are unchanged; when `language` is absent the old label shows with no note.
19. Legacy-backed courses and lessons with `legacy_lesson_id` show a read-only note with no actions; never-published courses show the explanatory empty state.
20. Owner admin copy is English-only; Spanish student strings are inert drafts marked "pending Lizbeth approval". Sample lesson names in fixtures are placeholders; no fabricated production data.
21. `pdfjs-dist` is a test-only devDependency and needs approval (D-196-10) before it is installed; this plan does not authorize an install.

### 4.17 Permitted variation

- Additive optional field names for `language` and `kind` on the student resource row type, and the helper structure inside `labelFor`, provided labels, ordering and filename rules hold and the legacy `pdf` label and filename are unchanged.
- "(PDF, Español)" in place of "Spanish" on the student row only if Lizbeth prefers native-language names and approves it.
- If option A of D-196-15 is later approved: the strings and link listed at the end of 4.13.
- Slot padding `--space-3` or `--space-4`; navigator hover step.
- Navigator as rail or select at the existing `.lesson-select` swap breakpoint (700px), provided 390 and 320 have no horizontal scroll.
- A same-page PDF viewer for Preview, provided focus returns to Preview and no native dialog is used.
- Whether the optional "Go to Publish" control appears on the draft-only state.
- Showing the owner disclosure only once a PDF exists in a slot.
- Internal component and file names, hook structure, and where the PDF builder module lives.
- The visually-hidden clip technique may be a shared utility class, provided the input stays focusable and the label ring is visible.

### 4.18 Remaining design limits

Backend contract is planned work; error-code names (including expired intent), remove idempotency at the Edge layer, Noto glyph coverage (fixture check) and the existence of `--control-height` are engineering-confirmed; PDF untagged and not WCAG 2.2 AA; ES drafts pending; lineage, selector and the accessible authored lesson view are deferred; no rendered validation yet. Deferred follow-ups: accessible authored lesson view on `/learn` (option A or follow-up under option B), handout lineage across versions (needs a stable cross-version lesson key), and a student-language mechanism.

## 5. Interfaces and data

### 5.1 Handouts migration (PR 8b; additive; no DROP/TRUNCATE/DELETE of existing data)

One forward migration `<timestamp after the latest on main>_issue196_lesson_handouts.sql` plus `supabase/rollbacks/issue196_lesson_handouts_rollback.sql`.

- Table `public.lesson_handouts`: `id` uuid pk default `gen_random_uuid()`; `course_asset_id` uuid not null unique references `course_assets(id)` ON DELETE RESTRICT; `course_id` uuid not null references `courses(id)` ON DELETE RESTRICT; `course_version_id` uuid not null references `course_versions(id)` ON DELETE RESTRICT; `lesson_revision_id` uuid not null references `lesson_revisions(id)` ON DELETE RESTRICT; `language` text not null check in (`'es'`,`'en'`); `source` text not null check in (`'generated'`,`'uploaded'`); `status` text not null default `'active'` check in (`'active'`,`'removed'`); `original_filename` text null (sanitized, <=120 chars); `created_by` uuid; `created_at` timestamptz default `now()`; `removed_at`, `removed_by`, `restored_at`, `restored_by`. **Partial unique index on (`course_version_id`, `lesson_revision_id`, `language`) where `status = 'active'`** (slots are per version, so a revision shared by two versions has an independent slot in each). RLS enabled, no policies for anon or authenticated; revoke all from anon and authenticated; grant select, insert, update to `service_role` (no delete grant).
- Table `public.lesson_handout_upload_intents`: `id` uuid pk; `owner_id`; `course_id`; `course_version_id`; `lesson_revision_id`; `language`; `source`; `storage_path` (server-built, includes the intent id); `expected_sha256`; `expected_byte_size`; `status` in (`'pending'`,`'consumed'`,`'failed'`,`'expired'`,`'quarantined'`); `created_at`; `expires_at` (`created_at` + 1 hour); `consumed_at`; `failure_code`. RLS on, `service_role` only, no delete grant. FKs RESTRICT as for `lesson_handouts`.
- Table `public.lesson_handout_events` (append-only audit, D-196-11): `id`, `handout_id` references `lesson_handouts` ON DELETE RESTRICT, `action` in (`'attached'`,`'replaced'`,`'removed'`,`'restored'`), `actor` uuid, `at` timestamptz; `service_role` insert and select only.
- `course_assets` rows for handouts: `storage_bucket 'lesson-assets'`, `storage_path` `${course_version_id}/handouts/${lesson_revision_id}/${language}/${intent_id}/${sha256}.pdf` (server-chosen, content-addressed, intent-scoped), `content_type 'application/pdf'`, `integrity_status 'verified'` ONLY after server verification, `course_version_id` and `lesson_revision_id` set, `metadata {kind:'lesson_handout', language, display_name}`, server-computed `byte_size` and `sha256`. Handout objects are written only by service-role signed upload, never updated, and never deleted by any product path; removal is the soft status change. A path already referenced by `course_assets` can never be the subject of any delete or move.
- SQL functions, SECURITY DEFINER, `search_path public`, EXECUTE `service_role` only (the #222 grant pattern), each taking `p_owner_id` and re-checking `courses.owner_id`:
  - Intent creation (used by `prepare_lesson_handout_upload`): validates ownership, version `published` and current (`course_versions.is_current = true`), non-legacy, revision mapped, size cap, and creates the pending intent.
  - `register_lesson_handout` takes the intent id (plus `original_filename` and the Edge's server-verified size and SHA-256): locks the `courses` row, then the `course_versions` row (same order as `save_outline` and `finalize_publish_job`), then the intent row FOR UPDATE; requires intent status `pending`, not expired, same owner; requires version status `'published'` and `is_current`, course `legacy_band_id` null, the revision mapped in that version; then in one transaction consumes the intent, inserts `course_assets` and `lesson_handouts`, moves any previous active handout in the (version, revision, language) slot to `'removed'`, and writes events. A consumed, failed or expired intent returns 409 `upload_intent_invalid`.
  - `remove_lesson_handout(p_owner_id, p_handout_id)`: idempotent; already removed returns the row.
  - `restore_lesson_handout(p_owner_id, p_handout_id, p_expected_active_handout_id)`: raises `handout_slot_changed` if the slot's active handout differs from the expected id, otherwise swaps. Requires the handout's version to be current.
  - `list_lesson_handouts(p_owner_id, p_version_id)`: returns version facts (`id`, `version_no`, `course_is_legacy`, `earlier_versions_with_active_enrollments` boolean) and handouts (`handout_id`, `lesson_revision_id`, `language`, `status`, `source`, `original_filename`, `byte_size`, `attached_at`, `removed_at`).
  - Reconcile function (used by `reconcile_lesson_handout_uploads`): see 5.2.
- Student RPCs, `CREATE OR REPLACE` of `get_student_lesson_assets` and `resolve_student_course_asset` with the same signatures and grants (authenticated only). A `lesson_handouts`-backed asset is served only when `h.status = 'active'` AND `h.course_version_id` equals the enrollment's `course_version_id` (alias per the `202610040002` body), so each enrollment sees its own version's handout. Assets with no `lesson_handouts` row keep #174 behaviour (D-196-13). `get_student_lesson_assets` adds additive JSON keys `language` (`metadata.language` or null) and `kind` (`metadata.kind` or null); rows ordered by position, then language es before en, then `created_at`, `id`.
- Rollback file: revokes and drops only the owner write functions (intent creation, register, remove, restore, list) and the reconcile function. It KEEPS `lesson_handouts`, `lesson_handout_events` and `lesson_handout_upload_intents`, and KEEPS the student RPC bodies with their removal and per-version filters (it does NOT restore the `202610040002` bodies), so removed or replaced handouts never reappear. Data written after apply is preserved. Document this in the file.

### 5.2 Edge actions

All in the existing `supabase/functions/course-authoring/index.ts` (no new function files). Owner gate plus ownership; never echo raw errors; all errors are stable codes.

- `list_lesson_handouts {version_id}` returns the data above, and opportunistically runs reconciliation bounded to 20 intents. If the SQL function is missing (PostgREST PGRST202 or 42883), return 503 `{error:'handouts_unavailable'}`.
- `prepare_lesson_handout_upload {version_id, lesson_revision_id, language, byte_size, sha256}`: creates the intent and returns `{intent_id, path, token}` (service-role `createSignedUploadUrl` for that exact server-built path; the client uploads with its own `uploadToSignedUrl`, no signed-URL host rebasing needed). Refuses with `version_not_current` 409 for a non-current version.
- `register_lesson_handout {intent_id, original_filename}`: the Edge verifies the object at the intent's own path with the service role (actual size <= 10,485,760, first bytes `%PDF-`, server-computed SHA-256 equals the intent's expected value). On success calls the SQL function (consume intent, insert, swap) and returns the handout. On failure it marks the intent `failed` with a stable code and deletes NOTHING: 422 `handout_verification_failed`, 413 `handout_too_large`, 422 `handout_not_pdf`. Single-use: a consumed, failed or expired intent returns 409 `upload_intent_invalid` (engineering confirms whether expiry has its own code that maps to `uploadExpired`).
- `reconcile_lesson_handout_uploads` (owner-gated): intents `pending` past `expires_at` become `expired`; for `failed` or `expired` intents older than 24 hours whose object exists and is not referenced by `course_assets`, the Edge MOVES the object to `${course_version_id}/handouts-quarantine/${intent_id}/${sha256}.pdf` (never deletes) and marks the intent `quarantined` with the new path; everything is logged on the intent row. Permanent deletion of quarantined objects is out of scope.
- `remove_lesson_handout {handout_id}`; `restore_lesson_handout {handout_id, expected_active_handout_id|null}` (409 `handout_slot_changed` on conflict); `sign_owner_lesson_handout {handout_id}` (300 s signed URL, sanitized download filename `{course-slug}-lesson-{nn}-handout-{es|en}.pdf`).
- Ownership for handout_id-based actions: resolve handout to `course_id` to `courses.owner_id` = caller, else 404 `'Resource not found.'`.
- Other stable codes: `version_not_published` 409, `version_not_current` 409, `course_is_legacy` 409, `lesson_not_in_version` 409, `upload_intent_invalid` 409, `not_found` 404, `handout_failed` 422 (generic).
- `list_assets` excludes metadata kind `'lesson_handout'` rows (the asset library stays for course files); `remove_asset` refuses kind `'lesson_handout'` rows (defense in depth).
- Size cap: `10 * 1024 * 1024 = 10,485,760` bytes, enforced client-side (advisory) and in Edge (authoritative); owner copy says "10 MB". The shared `lesson-assets` bucket's `file_size_limit` and `allowed_mime_types` are not changed (D-196-4).

### 5.3 Generation contract (client)

Source is the published revision content from `get_version`: `title.es/en` (slot language, falling back to the other), `body.es/en` (TipTap) in the slot language, `metadata.cards` front/back and `metadata.questions` prompts (not language-keyed, printed in both slots), prompts ONLY, never `answer`, `answers` or `answer_key`. Enablement follows the generation rule in 4.4. Lesson kinds: media prints title, body, "Media link: {url}" as text, then cards and prompts; checkpoint and others print title and body. Unsupported glyph blocks with `HANDOUT_COPY.unsupportedCharacters` (no substitution). Fixed dates so identical input yields an identical SHA-256.

### 5.4 Compatibility matrix

| Combination | Behavior |
|---|---|
| New frontend, old backend | 400 `Unknown authoring action.` gives "Handouts aren't available yet." (role=status, no actions) |
| New frontend, new Edge, no migration | 503 `handouts_unavailable` gives the same state |
| Any other error | Fails as a mapped error |
| New student side, old backend | `language`/`kind` absent gives a single "Student handout (PDF)" label, no note, legacy filename |
| Old frontend, new backend | Asset library excludes handouts; Publishing and Content uploads unchanged; `/learn` shows handouts with the old generic label (transitional, acceptable) |

### 5.5 Owner-write immutability policy migration (PR 8a; policy-only)

One migration `<timestamp>_issue196_lesson_assets_owner_write_immutability.sql` plus a rollback file (restores the two original policies and drops the helper). It drops and recreates by name `owner_update_lesson_assets` and `owner_delete_lesson_assets` so both `USING` (and the UPDATE `WITH CHECK`) require a new SECURITY DEFINER boolean helper `owns_mutable_lesson_asset_path(name)` = the path's first segment is an owned version (as `owns_lesson_asset_path`) AND `course_versions.status in ('draft','staged')` AND the path contains no `/handouts/` or `/handouts-quarantine/` segment. `owner_insert_lesson_assets` and `owner_select_lesson_assets` are unchanged (new objects cannot alter existing bytes; SELECT unchanged). EXECUTE `authenticated` only (same pattern as `owns_lesson_asset_path`). No data is changed. Hosted apply follows the ordering rule (R9) with its own approval (H1a).

## 6. Ordered work

PRs only, base `main`, never push to `main`, user merges, serial single writer, T1 first-line standard mode. Step 0 for every PR: fetch origin, record the base SHA (expected `73fe9f2` or later), re-verify every cited `file:line` not marked re-verified, run the stale-plan check (section 13). Engineering does not start until D-196-15 is answered.

**PR 8a (M): Edge hardening, server-side hashing and owner-write immutability.** "Refs #196" plus a new issue for the `save_revision` finding (D-196-9).

1. `save_revision`: if `legacy_lesson_id` is given it must belong to a legacy band course owned by the caller (same check as `map_lesson`, `index.ts:514-518`), otherwise generic 404; ignore client `revision_no` and compute `coalesce(max,0)+1` for a legacy link, else 1; replace raw `e.message` with stable codes.
2. `register_asset` and `upload_asset`: reject any `lesson_revision_id` with 422 `{error:'per_lesson_assets_use_handouts'}`; require `storage_bucket` `'lesson-assets'` and `storage_path` starting with `${version_id}/` and free of `..`, leading `/`, backslash and control characters.
3. `register_asset` server-side hashing (J-196-004): the Edge downloads the object at the validated path with the service role, computes size and SHA-256 itself, rejects with 422 `asset_checksum_mismatch` if a client claim is present and differs, and stores the server values with `integrity_status 'verified'`. `stage_publish` manifest checks (`202608280003:436-440`) keep working because the client hashes the same bytes.
4. The policy-only immutability migration and rollback (5.5).
5. Regression: Publishing `course.pdf`/`course.pptx` registration, Publishing re-upload (upsert on draft or staged), register-rollback `remove()`, and Content-tab upload still work. Step 0 finds and deliberately updates any existing test that asserts owner upsert or delete on a published prefix.
6. RED Edge live and pg tests first. Edge deploy and migration apply are separate approvals (H1a, H1b).

**PR 8b (M): backend handouts.** One forward migration plus rollback file (5.1), intents, reconcile, Edge actions in the existing `index.ts`, and tests. CODE_REVIEW required. "Refs #196".

**PR 8c (M-L): frontend.** "Closes #196". Contents:

- New PDF builder module (location permitted variation, for example `src/services/lessonHandoutPdf.ts`) reusing pdf-lib and `NotoSans-Regular.ttf` with word wrap, Title (`showInWindowTitleBar`), `setLanguage`, deterministic dates, glyph pre-check, WOFF2/variable rejection.
- Services for the new Edge actions; `mapHandoutError` and `HANDOUT_COPY` mirroring `publishingErrors.ts`; a narrower published-version refresh for the Reload control (R3-1).
- Handouts tab per section 4 (capability gate, focusable file input, Modal contract, replace sub-state, per-slot errors, polite live region, owner disclosure and upload warning); Content-tab pointer line.
- Student `fetchLearnMaterials` pass-through of `language`/`kind`; `RESOURCE_LABEL` entries for authored handouts with the language suffix (legacy pdf label unchanged), ES-then-EN ordering, language-suffixed filenames, the student note with its `aria-describedby` association.
- e2e spec `issue196-lesson-handouts.spec.ts`.
- A test-only `pdfjs-dist` devDependency only if D-196-10 is approved.
- Merge only after PR 8b's migration and Edge are live on hosted (Netlify builds `main` on merge).

Follow-up issues (Scribe drafts, orchestrator files after approval): `save_revision` hardening, handout lineage across versions, and (under option B) an accessible authored lesson view on `/learn`.

Dependencies: 8a then 8b then 8c (8a and 8b both edit `course-authoring/index.ts`). Owners: T1 (T2 per fleet escalation); Verifier; Browser Validator for 8c; Scribe for follow-up issue texts; orchestrator for `gh` actions after approval.

## 7. Acceptance and validation

Per PR: Step 0; `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`; full `npx vitest run` on a freshly reset local stack with no new failures versus the recorded baseline; RED shown failing then passing (record both); Verifier PASS; Browser Validator PASS for PR 8c; CODE_REVIEW where routed; PR opened against `main` with "Closes #196" only on 8c (8a and 8b "Refs #196"); no merge by the fleet.

RED tests (write first):

- **PR 8a, Edge live and pg:**
  - `save_revision` with a foreign or unowned `legacy_lesson_id` gives generic 404 and no row; client `revision_no` ignored; no raw Postgres text in any error.
  - `register_asset` with `lesson_revision_id` gives 422 `per_lesson_assets_use_handouts`; `upload_asset` likewise; a path outside `${version_id}/`, `..`, leading `/`, backslash, or the wrong bucket gives 422.
  - `register_asset` with a wrong claimed sha256 gives 422 `asset_checksum_mismatch` and no row; a correct claim stores the server-computed size and hash; `stage_publish` manifest checks still pass.
  - Owner storage upsert and delete on a published version prefix are denied; allowed on draft and staged prefixes; denied on any `/handouts/` or `/handouts-quarantine/` path regardless of status; owner insert and select unchanged.
  - Publishing re-upload (upsert on draft or staged), the register-rollback `remove()` and Content-tab upload still work.
  - Rollback restores the two original policies and drops the helper.
- **PR 8b, pg and live:**
  1. Register on a published, current, mapped, non-legacy lesson gives one active row; an entitled student sees it with language and kind.
  2. Draft version gives `version_not_published`; a published but non-current version gives `version_not_current`.
  3. Unmapped revision gives `lesson_not_in_version`.
  4. Legacy course gives `course_is_legacy`.
  5. Wrong owner is not authorized.
  6. Second register in a slot moves the previous to removed, leaves exactly one active, and the student sees only the new one.
  7. Remove: student list excludes it, resolver returns zero rows, Edge sign returns the generic 404.
  8. Restore with a mismatched expected id gives `handout_slot_changed`; matching swaps.
  9. Held, revoked, locked: hidden and unsignable; released-early: visible (canonical rule).
  10. Inactive enrollment, deactivated account, forced password change: none.
  11. A pre-existing #174-style verified `course_assets` row with no `lesson_handouts` row is still served.
  12. Catalog query: anon and authenticated hold no privileges on `lesson_handouts`, `lesson_handout_events` and `lesson_handout_upload_intents`; new functions EXECUTE `service_role` only; student RPCs EXECUTE `authenticated` only.
  13. Rollback: after rollback a removed handout stays invisible and unsignable, and all three tables and their rows survive; the student RPC bodies keep the removal and per-version filters.
  14. No DELETE grant or product delete path on the new tables; FK RESTRICT blocks cascading deletes; test cleanup helpers delete events, handouts and intents first.
  15. Per-version serving: a v1 enrollment never sees a v2 handout even when the revision id is shared by both versions.
  16. Intent single-use; expiry; replay of a consumed or failed intent gives 409 `upload_intent_invalid` with no deletion; concurrent double register of one intent yields exactly one success.
  17. Reconcile moves only unreferenced failed or expired objects older than 24 hours to the quarantine path and never touches a path referenced by `course_assets`; nothing is deleted.
  - Edge live: `prepare` refuses non-owner, draft, legacy, unmapped, non-current, oversize; `register` refuses tampered bytes (sha mismatch), non-`%PDF-` bytes and actual size 10,485,761, and in each case marks the intent failed, deletes nothing and creates no `course_assets` row; success path returns verified; `list_assets` excludes handouts; `remove_asset` refuses a handout row; `sign_owner_lesson_handout` ownership; the 503 mapping unit test for a missing function.
- **PR 8c, unit and RTL:**
  - PDF builder determinism (same input gives same SHA-256); Title, `/Lang` and DisplayDocTitle present; emoji gives `unsupportedCharacters`; WOFF2, WOFF and `fvar` font bytes rejected with a typed error.
  - Text and layout checks per D-196-10. If approved (recommended): `pdfjs-dist` `getTextContent` verifies the Spanish round-trip "á é í ó ú ñ ü Ñ ¿ ¡ « » “ ” — ·", list markers, flattened marks, and absence of every fixture `answer` string; a clipping check renders each page to a canvas with pdfjs inside a Playwright page and asserts no ink outside the margin box except the footer band; a geometric check asserts every text item's x + width <= 549 pt. If declined: ToUnicode CMap parsing with pdf-lib for the text round-trip plus geometric line-width checks (every drawn line fits 486 pt); no raster clipping check, recorded as a limit.
  - `mapHandoutError` never returns `error.message` and maps each code, including expired intent to `uploadExpired` and version not current to `versionNotCurrent`; `featureUnavailable` only for exactly 400 `Unknown authoring action.` and 503 `handouts_unavailable`.
  - Handouts tab states and focus table; Modal Escape, Close and Cancel return focus to the trigger; the tab never reads page blocks (`get_version` mocked); slot key includes version id, revision id and language; object URLs revoked on replace, lesson switch and unmount only; the lesson-switch lock clears on request resolve or error; the `versionNotCurrent` Reload does not call the page refresh.
  - `learnMaterials` passes `language`/`kind`; labels, ES-then-EN order, fallback without language, language-suffixed filenames; the student note renders once and its id is referenced by `aria-describedby` on handout Download controls.
  - Copy scan: the strings "companion to the online lesson", "lesson above" and any "accessible HTML" claim are absent from owner, student and PDF output.
  - Deterministic no-native-dialog source scan: `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` returns zero product hits.
- **PR 8c, e2e** (`src/__tests__/e2e/issue196-lesson-handouts.spec.ts`, chromium, one worker, a failing `page.on('dialog')` listener in every journey) at 1440x900 and 390x844, plus 320x568 and forced-colors spot checks: journeys J1 to J11 (section 8) including an expired-intent case and the student note association, and skew runs:
  - S1: new frontend (8c) against the mirror database and Edge at `main` without 8b: Handouts tab shows "Handouts aren't available yet." as role=status, no alert, no console-visible raw error, student `/learn` unchanged, Content and Publishing unaffected.
  - S2: new frontend plus 8b Edge without the 8b migration: same calm state.
  - S3: old frontend (`main`) plus 8b backend: asset library excludes handouts, Publishing and Content uploads still work, `/learn` lists handouts with the generic label.
  - Plus route-intercepted 400 and 503 variants.

## 8. Browser UI dialog policy and browser validation

Dialog policy (required): no `alert`, `confirm`, `prompt`, `window.alert/confirm/prompt` or `beforeunload`. Replace, Remove and Restore-conflict confirmations use the app-owned Modal (`src/components/Modal.tsx`): initial focus on the dialog container; Escape, Close and Cancel return focus to the trigger; `suppressDismiss` and `aria-busy` on Confirm while a mutation runs; in-modal role=alert on failure. Inline validation for file type and size. Verification: the deterministic source scan above, a failing `page.on('dialog')` listener in every journey, and modal keyboard and focus checks.

`browser_ui_validation`:

- **Mirror:** the port-shifted untracked mirror pattern of `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` (`supabase/config.toml` API 64321, DB 64322, studio 64323; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`). Windows reserves 54314-54413. Copy PR files per file, never `robocopy /MIR`; never commit the mirror. For the S1 skew run, keep the mirror's database and Edge at `main` (no 8b migration or Edge) and serve the 8c frontend.
- **Launch and readiness:** `npx supabase start`; `npx supabase db reset`; `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish` (the first request may 502; Edge changes are in an existing function file, so a restart suffices; a `config.toml` change needs a full `supabase stop`/`start`); `npx vite --host 127.0.0.1 --port 5180 --strictPort`; ready when `http://127.0.0.1:5180` serves sign-in.
- **Test environment:** `SUPABASE_API_URL=http://127.0.0.1:64321`, `SUPABASE_DB_PORT=64322`, `SUPABASE_SERVICE_ROLE_KEY=<from npx supabase status>`, `E2E_BASE_URL=http://127.0.0.1:5180`; `npx playwright test src/__tests__/e2e/issue196-lesson-handouts.spec.ts` with one worker.
- **Base URL:** `http://127.0.0.1:5180`.
- **Fixtures and reset:** `db reset` plus seed (`owner@test.local`, `student1@test.local`, `fullaccess@test.local`; password "password"). Per-journey disposable authored course via the `createOwnerCourseFixture` pattern (`src/__tests__/e2e/course-fixtures.ts`): published with at least 8 lessons: lesson 1 ES+EN content with a heading, bullet list, ordered list, bold text, a link, vocabulary cards and quiz prompts with answers; lesson 2 Spanish body only; lesson 3 a very long title; lesson 4 a media lesson with a media URL; lesson 5 a checkpoint; lesson 6 a body with an image, a table and an emoji (the unsupported-glyph lesson); lesson 7 only vocabulary cards and prompts (no body text); lesson 8 nothing printable in English (Generate disabled for English); one lesson with a non-null `legacy_lesson_id`. Also: a second course with a draft present, a never-published course, a legacy band course, a course whose newer version is published from a second browser context (version-not-current), and a disposable student enrolled with entitlements unlocked, locked, held and revoked (`set_lesson_access_state`), plus a second enrollment on a different course version. Files generated in-test: valid small PDF, exactly 10,485,760 bytes, 10,485,761 bytes, `.txt` renamed `.pdf`, a non-PDF, a `.pdf`-named file with a non-PDF MIME. Capability modes for `list_lesson_handouts`: normal, 400, 503, and 500 (which must show an error with Try again, not the calm state); `earlier_versions_with_active_enrollments` true and false; injectable failures (network, 403, 409 `handout_slot_changed`, verification failure, expired intent, version-not-current, lesson-not-in-version, version-not-published, a held `register_lesson_handout` long enough to observe Verifying); a second browser context for the stale-tab conflict. Loopback-guarded cleanup in `afterEach` (delete `lesson_handout_events`, `lesson_handouts`, `lesson_handout_upload_intents`, then `course_assets` and storage objects created by the test only). Language reset to English after any ES check.
- **Journeys** (design `browser_validation_brief`, revision 3):
  - J1 generate and attach: version bar, draft note, per-version line, owner accessibility disclosure in the lesson panel, enrollment note when enabled; select lesson 1; Generate Spanish and verify chips None, Generating, Preview ready; open Preview and extract PDF text (title block, language tag, heading sizes, list markers, flattened bold, link as text plus URL, two-column vocabulary, quiz prompts without answers, footer "Page n of N", Spanish glyphs, title and language metadata, no URL line); Attach and observe Uploading, Verifying, Available to students with "Generated from published content"; slot-prefixed live-region text and focus landing at each step.
  - J2 upload validation and attach: keyboard check first (input reachable, label focus ring and forced-colors outline, the warning "Uploaded PDFs may not work with screen readers. Prefer Generate, or make sure your PDF has selectable text." visible before choosing a file and still visible in Preview ready, Enter or Space triggers the filechooser event); valid PDF attach; then the 10,485,761-byte file, renamed `.txt`, wrong-MIME file and non-PDF with inline text, no network call, no state change, `aria-describedby` linkage; exactly 10,485,760 accepted; same file re-choosable after rejection.
  - J3 replace: app-owned Replace modal, initial focus on the container with description announced; Escape, Close and Cancel keep the old handout and return focus to Attach; Confirm closes, focus to slot heading, chip stays Available, "Replacement: Uploading…" then "Replacement: Verifying…"; forced failure shows "Replacement couldn't be verified. The current handout is unchanged." with Retry (new intent) and students still see the old handout; on success the old file appears under Removed handouts.
  - J4 remove and restore: Remove modal busy state (aria-busy on Confirm, no Close or Escape while pending), forced failure role=alert inside the modal then cancellable; success makes the slot None, auto-expands Removed handouts, focus to slot heading; Restore with slot None announces "{Slot}: Restored." and focus lands on the slot heading when Restore unmounts; Restore with another handout Available opens the Restore-conflict modal; stale-tab conflict shows `conflict` copy with "Reload this lesson".
  - J5 is not defined in the reviewed brief (Reuse was removed in revision 2); numbering is preserved from the design handoff.
  - J6 whole-tab states: draft-only (empty state, "Go to Publish" if present, no fetch); `course_is_legacy` note with no actions; 400 and 503 calm status with no actions and no alert role; 500 mapped error with Try again; lesson with `legacy_lesson_id` note in place of slots; lesson 8 shows English Generate disabled with the visible reason "This lesson has no English text, vocabulary, questions or media link to put in a handout yet."; lesson 7 enables Generate in both languages; `get_version` failure shows `lessonsLoadFailed` with Try again.
  - J7 error mapping: each injected failure shows stable owner copy adjacent to the action row, no raw backend text in the DOM, role=alert, conflict offers "Reload this lesson"; Verification failed and expired intent (`uploadExpired`) show Retry with focus, Retry requests a new intent and re-uploads the held bytes; publish a newer version from the second context, then write in the first and confirm `versionNotCurrent` with "Reload handouts" that refreshes to the new current version without overwriting unsaved draft blocks; after reload the failed state is gone.
  - J8 keyboard only: complete J1 to J4 by keyboard (tab strip, lesson selection, focusable upload input, every slot action, modal trap, Escape, focus return, disclosure toggle); lesson switching blocked with visible reason while a slot is in flight and released when the request resolves or fails; a Preview-ready file discarded with the visible note on switching.
  - J9 preview: local Preview opens synchronously and the object URL stays valid after opening; active-file Preview opens a blank window then loads the signed URL; blocked pop-ups show `previewBlocked` and the Download fallback; forced signing failure closes the blank window and shows `previewFailed`; focus remains on Preview.
  - J10 PDF content: lessons 1, 4, 5, 6, 7: media link as plain text, checkpoint title and body only, lesson 6 image notice and generation blocked with `unsupportedCharacters` and nothing uploaded, lesson 7 title block plus vocabulary and questions in both languages with slot-language headings, table row-wise with ` | `, image dropped without placeholder, a Spanish slot for a lesson with only an English title uses the English title with the tag ESPAÑOL, no quiz answer in any PDF text.
  - J11 student download: entitled student on `/learn` sees "Student handout (PDF, Spanish)" then "Student handout (PDF, English)" with the note "Printable handout for this lesson. If you need it in another format, ask your teacher." once; fresh signed link per activation, download starts, filename ends in `-es.pdf` or `-en.pdf`; forced sign failure shows inline error with retry on the same control; locked, held and revoked show nothing; one-language lesson still shows its suffix; old-backend variant shows one "Student handout (PDF)" and no note; the legacy label and filename are unchanged; each enrollment sees only handouts attached to its own course version; the note and rows wrap with no horizontal scroll at 320; the note id is referenced by `aria-describedby` on the Download controls.
  - Skew runs S1 to S3 and the route-intercepted 400 and 503 variants.
- **Viewports:** 1440x900 and 390x844; 320x568 reflow and forced-colors (1440x900 and 320x568) spot checks.
- **Visible outcomes:** status always glyph plus word; per-slot errors adjacent to actions with stable copy and no raw backend text in the DOM; slot-prefixed polite announcements; focus landings per 4.10; no horizontal scroll at 390 and 320; generated PDF title block, language tag, wrapped body, two-column vocabulary, prompts without answers, "Page n of N" footer and no text clipped outside the margin box (except the footer band); student rows with the note once and language-suffixed filenames; locked, held and revoked show nothing; legacy "Student handout (PDF)" unchanged; no owner, student or PDF string claims an online lesson or an accessible HTML version exists. Status and chips meet AA contrast (section 4.15); advisory warning text meets 4.5:1.
- **States to capture:** loading, load-error, none, generating, preview-ready (generated and uploaded, with the upload warning), uploading, verifying, available, available with replacement line (uploading, verifying, failed), verification-failed, expired-intent, removed list expanded, each modal (idle, busy, failed), each error including `versionNotCurrent`, draft-only, legacy, lesson-level legacy note, feature-unavailable, 500 error, disabled Generate with reason, lesson-switch lock, preview-blocked, student rows (two languages, one language, old backend) with the note, student download error.
- **Evidence:** screenshots per state, viewport and skew mode, plus network logs, under `browser-validation-artifacts/196/`.

## 9. Judge route

Shadow (advisory) per `docs/JUDGE-CONTRACT.md`. PLAN_DUCK was run on the first draft (J-196-001..009, folded in Revision 1); a second PLAN_DUCK on Revision 1 is eligible before approval (the orchestrator runs it). CODE_REVIEW is required for PR 8a (now including storage policies and server-side hashing) and PR 8b (authorization, storage, SECURITY DEFINER functions, intents) and recommended for PR 8c. VERIFICATION_CHALLENGE is optional for PR 8b (coverage of refusal and replay cases). VISUAL_REVIEW is optional for PR 8c. Respect the two and four call caps; deterministic failures dominate; finding ids flow into the engineering job and the Verifier brief. No live Codex call without explicit usage approval.

## 10. Risks, rollback and hosted rollout

| Id | Risk | Mitigation |
|---|---|---|
| R1 | Authorization or leak through new SECURITY DEFINER functions | `service_role`-only EXECUTE, `p_owner_id` re-check, path pattern, catalog test, CODE_REVIEW |
| R2 | Integrity bypass via `register_asset`/`upload_asset` | PR 8a rejects `lesson_revision_id` and hashes server-side |
| R3 | Data loss, or removed handouts reappearing after rollback | No deletes; soft status; FK RESTRICT; rollback keeps all three tables and the student RPC filters; audit events; rollback test |
| R4 | Deploy skew | Exact capability gate, skew e2e S1 to S3, rollout order backend before frontend merge; student RPC additive keys with a label fallback |
| R5 | Student-visible wrong file (wrong lesson, language or version) | Server-chosen content-addressed path, mapped-revision check, per-version slot index, per-version serving, owner preview before attach |
| R6 | Untagged PDF accessibility | Disclosed to owner and student; generated PDFs have selectable text; follow-up for an accessible authored lesson view |
| R7 | Font defects | Static TTF only, glyph pre-check, text round-trip test |
| R8 | Revision churn and per-version slots mean handouts do not follow a new version | Documented in the per-version line; the owner attaches handouts to each new published version; no automatic carry-over; lineage follow-up issue |
| R9 | Hosted migration ordering | `db push` applies all pending migrations; apply the 8a and 8b migrations only after earlier pending migrations have their own approvals, or together only with explicit approval naming each |
| R10 | Shared bucket | Limits enforced in Edge; bucket settings unchanged |
| R11 | Lock contention with `save_outline`/finalize | Same courses-then-versions lock order, then the intent row |
| R12 | Abandoned or failed uploads leave unreferenced objects, or a replay deletes a live object | Single-use intents; failures delete nothing; reconcile moves unreferenced failed or expired objects older than 24 hours to a quarantine prefix, logged on the intent; permanent deletion needs a separate approved data plan |
| R13 | Owner-session mutation of published publish artifacts today (F18) | PR 8a immutability policy migration; H0 q5 integrity spot check; RED policy tests |
| R14 | The untagged PDF may be the only route to a lesson's text for a student using assistive technology | Honest disclosure (owner and student copy), alternative-format path, D-196-15 decision and follow-up for an accessible authored lesson view |

Rollback: PR 8c revert (frontend; Netlify redeploy); Edge redeploy of the previous `course-authoring` version; the 8b rollback file (owner write functions dropped, tables and student RPC filters kept); the 8a policy rollback (original owner policies restored). Containment without rollback: the owner removes a handout (soft).

Hosted rollout (each step a separate explicit approval per D-28; the user runs hosted actions):

- **H0** read-only queries the user runs: (q1) count and list `course_assets` with `lesson_revision_id` not null, `content_type 'application/pdf'`, `integrity_status 'verified'`, `storage_bucket 'lesson-assets'` (expected 0); (q2) the `storage.buckets` row for `lesson-assets` (`file_size_limit`, `allowed_mime_types`) and the project's global upload limit (dashboard); (q3) count authored courses (`legacy_band_id` null) with a published version and active enrollments; (q4) `supabase_migrations.schema_migrations` to list which earlier migrations are still pending; (q5) list `lesson-assets` objects whose first path segment is a published (non-draft, non-staged) `course_version` id, with storage metadata size versus `course_assets.byte_size` for referenced rows (read-only integrity spot check; any mismatch is an incident to report before H1a).
- **H1a** apply the PR 8a policy migration (after earlier pending migrations are resolved, R9).
- **H1b** deploy `course-authoring` Edge for PR 8a.
- **H2** apply the PR 8b migration.
- **H3** deploy `course-authoring` Edge for PR 8b; read-only smoke: owner `list_lesson_handouts` on a published course.
- **H4** the user merges PR 8c (Netlify deploys); read-only smoke: owner opens the Handouts tab. Any production write smoke (generating a handout) only on a non-enrolled test course with explicit approval (D-196-12).

## 11. Assumptions and unknowns

Safe assumptions: single owner role in practice; `NotoSans-Regular.ttf` covers the listed Spanish glyphs (fixture-verified in 8c); supabase-js 2.110.7 provides `createSignedUploadUrl`/`uploadToSignedUrl` (RE4 confirms `createSignedUploadUrl` in storage-js; verify the client side at Step 0); the hosted plan global upload limit is >= 10 MB (H0 q2); `course_versions.status` uses the values `draft`, `staged` and `published`, and `is_current` marks the current published version (verify at Step 0).

Unknowns: the Edge request body cap; whether `subtle.digest` counts toward the 2 s CPU limit; hosted bucket settings and plan limit; whether `202610130003` and `202610140001` are applied on hosted; exact stable error code names beyond `handout_slot_changed` (including whether expiry has its own code); remove idempotency at the Edge layer (the SQL function is specified idempotent); Noto glyph coverage; existence of the `--control-height` token; whether any existing test asserts owner upsert or delete on a published prefix (Step 0).

## 12. Decisions

Each needs an explicit answer. Recommendations in the right column. Changed in Revision 1: D-196-2, 3, 5, 7, 8, 9, 10, 13. New: D-196-14, D-196-15.

| Id | Decision | Recommendation |
|---|---|---|
| D-196-1 | Scope: authored (non-legacy) courses, current published version only; legacy courses show a read-only note. | Yes |
| D-196-2 | One active handout per (course version, lesson revision, language), languages es and en; writes require the current published version; replace moves the previous one to Removed. (Changed: per version.) | Yes |
| D-196-3 | Generate client-side with pdf-lib and the bundled static Noto Sans Regular TTF; never embed the WOFF2 web fonts merged by PR #273; adding a static Noto Sans Bold TTF (OFL) for headings is optional. (Changed: #273 is merged.) | Regular only for this iteration |
| D-196-4 | 10 MB cap (10,485,760 bytes) enforced client and Edge; do not change the shared `lesson-assets` bucket settings. | Yes |
| D-196-5 | No automatic carry-over of handouts between versions; the owner attaches handouts to each new published version; reuse and lineage across versions deferred, with a follow-up issue. (Changed.) | Yes |
| D-196-6 | Older published-version selector deferred. | Yes |
| D-196-7 | Student labels ship in English with the language suffix and the English note "Printable handout for this lesson. If you need it in another format, ask your teacher."; Spanish drafts ("Material para imprimir (PDF, español)", "Material para imprimir (PDF, inglés)", "Material imprimible de esta lección. Si lo necesitas en otro formato, pídeselo a tu docente.", "Descargar {label}") stay inert pending Lizbeth's approval and a student-language mechanism. (Changed: note text.) | Yes |
| D-196-8 | PDF accessibility bar: untagged with Title, `/Lang`, DisplayDocTitle and selectable text; no claim of an accessible equivalent unless option A of D-196-15 exists; tagged PDF out of scope. (Changed: HTML-primary claim removed.) | Yes |
| D-196-9 | Include PR 8a hardening (`save_revision`; `register_asset`/`upload_asset`; server-side hashing in `register_asset`) and file a new issue for the `save_revision` finding. (Changed: adds server-side hashing.) | Yes |
| D-196-10 | PDF test methods. Approve `pdfjs-dist` as a test-only devDependency for the Spanish round-trip, answer absence, page-canvas clipping check and geometric width checks; if declined, use ToUnicode CMap parsing with pdf-lib plus geometric line-width checks and record that no raster clipping check exists. (Changed.) | Approve `pdfjs-dist` as a test-only devDependency |
| D-196-11 | Add the append-only `lesson_handout_events` audit table. | Yes |
| D-196-12 | Hosted post-deploy smoke stays read-only; any write smoke only on a non-enrolled test course with explicit approval. | Yes |
| D-196-13 | Student RPCs serve a `lesson_handouts`-backed asset only when its handout is `active` and belongs to the enrollment's own course version; assets with no `lesson_handouts` row keep #174 behaviour (compatibility with #174 tests). (Changed.) | Yes; revisit if H0 q1 finds unexpected rows |
| D-196-14 | Ship the owner-write immutability policy fix (F18) in PR 8a (hotfix-class, low live exposure) rather than a separate emergency PR; its hosted apply follows R9 with its own approval (H1a). (New.) | Yes |
| D-196-15 | Authored-course accessibility premise (F17). (B) Ship handouts with honest disclosure (owner disclosure, upload warning, student note with the alternative-format path) and file a follow-up issue "accessible authored lesson view on /learn". (A) Build that view first as its own sub-plan and design route, then show "Open the online lesson" beside each handout. Engineering does not start until this is answered. (New.) | (B) |

## 13. Approvals and stale-plan conditions

Approvals required:

1. Explicit user approval of this plan (the status changes from DRAFT only on the lead's relay of that approval).
2. Answers to D-196-1 to D-196-15. D-196-15 must be answered before engineering starts.
3. Approval of `pdfjs-dist` as a test-only devDependency (D-196-10) or acceptance of the fallback.
4. Separate approval for each hosted action H1a, H1b, H2, H3 and H4.
5. Lizbeth's approval before any Spanish student string ships.
6. No commit to `main`, merge, deploy or live Codex call without explicit instruction.

Stale-plan conditions: base is now `73fe9f2`; `origin/main` moves past `73fe9f2` with changes to any cited file (`course-authoring/index.ts`, the `202610040002` functions, `learnMaterials.ts`, `ResourcesPanel.tsx`, `storageSigning.ts`, `LearnDetailPage.tsx`, `CourseWorkspacePage.tsx`, `exports.ts`, `Modal.tsx`/`useFocusTrap`); the owner storage policies change (`202608300003` or a successor); an authored lesson view lands on `/learn` (changes D-196-15 and the disclosure copy); a student-language mechanism (#208 functional strings) lands; PR #273 font assets change in a way that affects `src/assets/fonts/NotoSans-Regular.ttf` (the merge itself has occurred and is resolved, F2); the hosted pending-migration set changes; `save_outline` or `clone_course_version` semantics change (lineage); H0 q1 returns unexpected rows or H0 q5 reports a mismatch.

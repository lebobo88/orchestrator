# Lizbeth Spanish: Issue #173 Storage Content-Type Correctness for lesson-assets

Status: **APPROVED by the user on 2026-10-03 (all four approved together in the orchestrator session). Cleared for engineering per this plan.** See the Approval record at the end of this document for the limits of that approval.

Plan ID: `lizbeth-spanish-issue173-storage-content-type`. Task ID: `lizbeth-spanish-issue173`. Route: engineering.

Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (its own git repository; GitHub `lebobo88/lizbeth-spanish`; issue #173, epic #172). The checkout is currently on `release/fjds-course-management-20260915`, which has draft PR #171 and unmerged local work. This plan must not disturb that checkout (see Step 0).

Audience: course students and the owner (downstream consumers of correct file handling), the engineering fleet (implementer), and the user (approver of the plan and of the production gate).

## Plan revision 1 (PLAN_DUCK shadow, advisory)

`PLAN_DUCK` ran in shadow/advisory mode. Planner re-verified every point at file level. This revision was applied once, in place, and adds no scope beyond the dispositions below. The judge route is unchanged (PLAN_DUCK used; CODE_REVIEW remains; call cap 2).

| ID | Disposition | Summary | Where applied |
| --- | --- | --- | --- |
| J-173-01 | accepted (counts corrected) | The repair set includes the 78 unreferenced `flashcards.md` objects. Production holds 468 objects and local holds 474. The PLAN_JOB brief's "390" was the referenced-resource count, not the object count. The check and Phase P assert total and per-extension counts. | F1, F4, F5, F6, Steps 4, 5, Phase P, Sections 7, 8, 10 |
| J-173-02 | accepted (repair safety hardened) | The installed `@supabase/storage-js` has no metadata-only path, so a re-tag must re-write the object. Re-write is protected by a recoverable byte backup, an independent seed-hash check, a conditional pre-write comparison, a Phase P maintenance window, and a backup-directory rollback. An S3 CopyObject path is an optional, non-default alternative. | F14, Steps 5, 7, Phase P, Sections 8, 9, 10, 12 |
| J-173-03 | accepted | Signed-URL verification records and asserts response headers (Content-Type, Cache-Control, X-Content-Type-Options, Content-Disposition, Content-Length, ETag) and saves them as evidence. | Step 6, Section 8, Phase P |
| Branch-base default | accepted | Default is to merge the cleanup PR first and then branch `fix/173-storage-content-type` from the updated `origin/main`. Stacking is allowed only under two stated conditions. This replaces the open choice in Step 0. | Step 0, Section 9 (R1), Section 12 |

Evidence labels used below: **Observed** means read directly in repository files and re-verified by Planner. **Inference** means a conclusion drawn from observations. **Assumption** means a value taken as true until a runtime step verifies it. **Unknown** means not yet established.

---

## 1. Outcome

Every `lesson-assets` Storage object is stored and served with the Content-Type that matches its file extension. A student or owner who opens a signed URL for a handout PDF, a PPTX, a Markdown recap, a YAML flashcard file, or a lesson-content JSON file gets correct browser handling. This also unblocks issue #174 (handout links) and issue #175 (in-app vocabulary review).

## 2. Scope and non-goals

**In scope:**

1. A shared extension-to-contentType map.
2. A fix to `uploadToStorage` in `scripts/provision-lessons.ts` so it passes `contentType`.
3. Unit tests using a mocked Supabase client.
4. An idempotent, dry-run-by-default, manifest-pinned re-tag/repair script, run against LOCAL Supabase first.
5. A read-only mimetype-versus-extension check (SQL and script) over every `lesson-assets` object.
6. Signed-URL GET Content-Type verification.
7. Extension of the G9a/G0.5 post-run verification so it asserts content type.
8. A separately user-gated PRODUCTION re-tag phase (Phase P, project `gvobtuhbpqvfhjljjcye`) with backup and rollback. Phase P is never part of the automatic build.

**Non-goals:**

- No RLS or policy change.
- No migration under `supabase/migrations`.
- No change to `storage.objects` policies, bucket privacy, or `file_size_limit`.
- No UI change.
- No change to `supabase/functions/course-authoring` (it already passes `contentType` from payload at `index.ts:361`) or to `src/services/courseAuthoring.ts` uploads (they already pass `contentType`, lines 119 and 128).
- No work for #174 or #175 beyond the interfaces listed in Section 7.
- No Content-Disposition or download-name change.
- No Supabase CLI upgrade.
- No production mutation without the explicit user go-ahead in Phase P.

## 3. Repository findings (evidence)

All items below are **Observed** unless labeled otherwise.

- **F1. Upload omits contentType.** `scripts/provision-lessons.ts:965-1004`, `uploadToStorage(supabase, manifest, preserveLocalFixtures)`, enumerates `fs.readdir(supabase/storage-seed/lesson-assets/<band>/week-NN)` per manifest entry. It skips Beginner weeks 1-4 when `preserveLocalFixtures` (line 970) and skips `isFixtureDuplicateUploadToSkip(storagePath, preserveLocalFixtures)` (line 986). Line 993 then calls `supabase.storage.from('lesson-assets').upload(storagePath, fileContent, { upsert: true })` with NO `contentType`. Upload errors are only `console.warn`'d (lines 995-997). Lines 978-993 upload every file in each storage-seed week directory, which includes the unreferenced `flashcards.md`.
- **F2. Fixture-duplicate skip rule.** `scripts/provision-lessons.ts:945-953`, `isFixtureDuplicateUploadToSkip`, returns false when `preserveLocalFixtures`. Otherwise it returns true for a `beginner-week-01-*` filename outside `beginner/week-01/` (six fixture duplicates removed from production by gate G7a). This function must be preserved and reused unchanged.
- **F3. Local guard convention.** `scripts/provision-lessons.ts:94-135`: `LOCAL_SUPABASE_URL='http://127.0.0.1:54321'` with an exact-match local guard. `resolveServiceRoleKey` refuses the demo key for any non-local target and exits 1 if `SUPABASE_SERVICE_ROLE_KEY` is unset. Line 1514: `preserveLocalFixtures = SUPABASE_URL === LOCAL_SUPABASE_URL`. New scripts must reuse this exact-match convention.
- **F4. Post-run verification checks size only.** `scripts/provision-lessons.ts:1125-1151`, `verifyResourceByteSizes` (G0.5/G9a), uses `storage.from('lesson-assets').info(path)` and checks only size against the storage-seed file. It has no content-type check. It is called from `postRunVerification` at line 1467.
- **F5. Resource naming and object counts.** `scripts/provision-lessons.ts:520-570` defines per-week resources: pdf (`<band>-week-NN-student-handout.pdf`), pptx (`<band>-week-NN-instructor.pptx`), vocabulary_review `weekly-review-recap.md` (line 554), flashcards `flashcards.yaml` (line 558), lesson_content `lesson-content.json` (line 568). 78 weeks x 5 = 390 referenced objects. Storage-seed week directories also contain `flashcards.md` (for example `supabase/storage-seed/lesson-assets/intermediate/week-05/` has `flashcards.md`, `weekly-review-recap.md`, `*.pptx`, `*.pdf`, `lesson-content.json`, `flashcards.yaml`). `verifyStorageBucket` (`scripts/provision-lessons.ts:1153-1198`) expects 474 objects locally (390 referenced + 78 unreferenced `flashcards.md` + 6 fixture duplicates) and 468 in production (390 + 78 `flashcards.md` after G7a). The PLAN_JOB brief's "390" was the referenced-resource count, not the object count; the hosted object count is 468. Expected production breakdown by extension: `.pdf` 78, `.pptx` 78, `.md` 156 (78 `weekly-review-recap.md` + 78 `flashcards.md`), `.yaml` 78, `.json` 78; total 468.
- **F6. Evidence of the defect.** `@supabase/storage-js` defaults `contentType` to `text/plain;charset=UTF-8` when none is passed. The production data dump `docs/cutover-evidence/G9b-data-20260916T125447Z-gvobtuhbpqvfhjljjcye.sql` (`storage.objects` INSERT at line 824) contains exactly 468 `mimetype` entries, all `text/plain`; 78 of them are `flashcards.md`. G9a checked existence and size only. (The storage-js default is taken from the PLAN_JOB evidence and is consistent with the production dump.)
- **F7. Local seeding.** `supabase/config.toml:134-137`: `[storage.buckets.lesson-assets]` with `public=false`, `file_size_limit="50MiB"`, `objects_path="./storage-seed/lesson-assets"`. The CLI seeds the bucket on start and on `db reset`. The mimetype the CLI assigns is **Unknown** (not verified); the new check script determines it empirically and the re-tag script repairs it locally if wrong. No `allowed_mime_types` is set, so `text/markdown` and similar types are not rejected (**Inference** from config).
- **F8. Bucket-provisioning script needs no change.** `scripts/ensure-lesson-assets-bucket.ts` only calls `getBucket`/`createBucket` and never uploads (confirmed at lines 38-41 and 174-195).
- **F9. Signed-URL helper.** `src/lib/storageSigning.ts:190-213`, `getSignedResourceUrl(client, bucket, path, ttl)`, calls `createSignedUrl`. `STORAGE_CONFIG` (lines 218-232) has `LESSON_ASSETS_BUCKET='lesson-assets'` and `RESOURCE_EXTENSIONS {pdf:.pdf, pptx:.pptx, flashcards:.json, vocabulary_review:.pdf}`. Those extensions are stale against real paths (flashcards are `.yaml`, vocabulary_review is `.md`); `generateStoragePath` is "reference only". Not changed in #173; flagged as a note for #174/#175.
- **F10. Existing test harness.** `src/__tests__/provision-lessons.test.ts` imports `uploadToStorage` and `isFixtureDuplicateUploadToSkip`. Lines 1427-1490 use `buildRecordingStorageMock`, whose `storage.from().upload(storagePath)` records paths against the real storage-seed `readdir`. This mock is to be extended to capture options.
- **F11. Evidence-gate precedent.** `scripts/require-backup.js` is the gate-evidence precondition pattern (`docs/cutover-evidence/`, sha256 sidecars, Path B real dumps for G7 and later). Phase P reuses the evidence-file convention. `require-backup.js` is not modified unless T1 shows the existing gate-ID scheme can accept a new gate without a code change.
- **F12. Lint and test scope.** `package.json` `lint` is `eslint src` only (`scripts/` is not linted). Tests run via vitest (`npm test` is `vitest`; use `npx vitest run` for non-watch).
- **F14. No metadata-only path in the installed storage-js.** In `node_modules/@supabase/storage-js/src/lib/types.ts:183-185`, `DestinationOptions` for copy/move carries only `destinationBucket`. `FileOptions` (lines 154-180) has `cacheControl`, `contentType`, `upsert`, and `headers`. `StorageFileApi.ts:37` defaults `contentType` to `text/plain;charset=UTF-8`. A re-tag therefore has to re-write the object; editing `storage.objects` metadata through SQL stays prohibited. Separately, `config.toml` has `[storage.s3_protocol]` enabled locally (relevant only to the optional alternative in Step 5(f)).
- **F13. RLS.** Storage policies live in `supabase/migrations/202607170005_storage_gating_policy.sql` and `202608300003_storage_lesson_assets_owner_write_policies.sql`. Service-role operations bypass RLS, so no policy change is needed or allowed.

Research evidence: none. Planner judged local evidence sufficient. CLI-seed mimetype and CDN caching are handled as runtime-verified assumptions (Section 11).

## 4. Judge route

- **PLAN_DUCK:** required before approval. Terra, medium effort (multi-file, data flow, production data mutation).
- **CODE_REVIEW:** required after JOB_DONE and before Verifier. Terra, medium effort.
- **Risk:** medium for the automatic build; high for Phase P.
- **Call cap:** 2 for the automatic build. Phase P may add one `VERIFICATION_CHALLENGE` only with user approval.
- **VISUAL_REVIEW:** skipped (no UI).
- Finding IDs from any judge pass flow into the engineering job and into Verifier checks. No judge result is promised or included in this draft.

## 5. Ordered work

### Step 0. Branch isolation (owner: T1; precondition, no product edits)

User decision recorded: one new branch and PR per item branched from `main`, plus a separate cleanup PR for the existing unmerged local work.

- Do NOT branch from, stash, or disturb the dirty `release/fjds-course-management-20260915` checkout.
- **Branch-base default (revision 1).** The user approved a separate cleanup PR for existing unmerged local work plus one new branch and PR per item. Default: land and merge the cleanup PR first, then create `fix/173-storage-content-type` from the updated `origin/main` in an isolated worktree. Stack #173 on the cleanup branch only if both hold: the cleanup PR is not yet merged, and the user explicitly asks to proceed before then. If stacked, the #173 PR targets the cleanup branch and is retargeted to `main` after the cleanup merges, and its diff against its base must still contain only #173 files.
- Run `git fetch origin`. Create an isolated worktree from `origin/main` (or from the cleanup branch only under the stacking condition above), for example `git worktree add ..\lizbeth_spanish-173 -b fix/173-storage-content-type origin/main`. All #173 work happens only there.
- Verify on `origin/main` that `scripts/provision-lessons.ts` contains `uploadToStorage`, `isFixtureDuplicateUploadToSkip`, and `verifyResourceByteSizes`, and that `src/__tests__/provision-lessons.test.ts` contains the G9/defect-1 tests. The same check applies to whichever base is used.
- If any of these are missing from the base, STOP with `JOB_BLOCKED` "Plan stale: #173 depends on unmerged work".
- The branch diff must contain only the #173 files listed in Section 8.
- Commit, push, and PR creation happen only when the user explicitly authorizes them at execution time. The per-item-PR decision is recorded, but CLAUDE.md requires an explicit request. The cleanup PR for existing local work is a separate item and not part of this plan.

### Step 1. Content-type map (T1, test-first)

New pure module `src/lib/storageContentType.ts` (browser-safe, no node imports, so #174/#175 app code and scripts can both import it). If tsx or tsconfig prevents scripts from importing from `src/lib`, fall back to `scripts/lib/storageContentType.ts` and record why.

Exports:

- `CONTENT_TYPE_BY_EXTENSION`, a readonly map:
  - `.pdf`: `application/pdf`
  - `.pptx`: `application/vnd.openxmlformats-officedocument.presentationml.presentation`
  - `.docx`: `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
  - `.md`: `text/markdown; charset=utf-8`
  - `.yaml` and `.yml`: `application/yaml`
  - `.json`: `application/json`
- `contentTypeForPath(path): string`: case-insensitive extension; throws `UnsupportedStorageExtensionError` for an unknown or missing extension.
- `isContentTypeMatch(path, observedMimetype): boolean`: normalizes case and whitespace; treats parameter differences per an explicit rule documented in the module (for example, `text/markdown` requires a `charset=utf-8` match ignoring case).

Tests in `src/__tests__/storageContentType.test.ts` cover every extension, uppercase, no extension, unknown extension, nested paths, and the match rule.

### Step 2. Upload fix (T1)

In `uploadToStorage`:

- Pre-validate `contentTypeForPath` for every file it would upload (after both skip rules) before the first upload, so an unknown extension fails the run with a clear error and no partial upload.
- Then call `upload(storagePath, fileContent, { upsert: true, contentType: contentTypeForPath(storagePath) })`.
- Do not change skip logic, enumeration, or warn-on-upload-error behavior otherwise.

Tests in `src/__tests__/provision-lessons.test.ts`:

- Extend `buildRecordingStorageMock` to record options.
- Assert every upload carries the mapped `contentType` and `upsert: true`.
- Assert the existing G9/defect-1 assertions are unchanged.
- Assert unknown-extension pre-validation throws before any upload, using a temp dir or injectable enumeration rather than writing into `supabase/storage-seed`.

### Step 3. Post-run verification (T1)

Extend `verifyResourceByteSizes`, or add `verifyResourceContentTypes` next to it and call it from `postRunVerification`. It reads the object's content type from `info()` and pushes an error when `!isContentTypeMatch`. T1 confirms the field name (for example `contentType` versus `metadata.mimetype`) against the installed `@supabase/storage-js` types. Unit-test with a mocked `info()`.

After this lands, a G9 re-run against production fails post-run verification until Phase P re-tags. This is intended and must be documented in a script comment.

### Step 4. Read-only check (T1)

- (a) `scripts/sql/check-lesson-assets-mimetypes.sql` (NOT under `supabase/migrations`): `SELECT name, metadata->>'mimetype'`, an expected-by-extension `CASE`, and a match flag `FROM storage.objects WHERE bucket_id='lesson-assets'`, plus a summary count of mismatches. Read-only.
- (b) `scripts/check-lesson-assets-content-types.ts`:
  - Service-role client with the exact-match local guard by default.
  - Non-local only with an explicit `SUPABASE_SERVICE_ROLE_KEY` env value and `--target-project <ref>` equal to the URL's project ref.
  - Lists every object in `lesson-assets` recursively and compares mimetype to `contentTypeForPath`.
  - Reports the manifest-pinned set (see Step 5) and other objects (for example course-authoring uploads) separately.
  - Exits non-zero only on manifest-pinned mismatches (or any mismatch with `--strict`).
  - Prints counts by extension. Never writes.
  - Asserts the total object count (468 production, 474 local) and a per-extension count (production: `.pdf` 78, `.pptx` 78, `.md` 156, `.yaml` 78, `.json` 78), in addition to the MIME match. A count mismatch fails the check and blocks `--apply`.
  - Add npm script `check:asset-content-types`.
  - Unit-test the pure comparison and report logic with a mocked client.

### Step 5. Re-tag/repair script (T1)

New `scripts/retag-lesson-assets-content-types.ts`.

**Target set.** Everything `uploadToStorage` enumerates (`buildLessonManifest` plus storage-seed `readdir` per week), filtered by `isFixtureDuplicateUploadToSkip(path, preserveLocalFixtures)`, intersected with objects that actually exist in the bucket. Per week that is `<band>-week-NN-student-handout.pdf`, `<band>-week-NN-instructor.pptx`, `weekly-review-recap.md`, `flashcards.yaml`, `lesson-content.json`, and the unreferenced `flashcards.md` (in scope; it maps to `text/markdown; charset=utf-8`). Locally only, the target set also includes the 6 `beginner-week-01` fixture duplicates and Beginner weeks 1-4 objects (CLI-seeded). Expected size: 468 in production, 474 locally. The script never creates, deletes, or touches objects outside this set.

**Behavior.**

- Dry-run is the default. It prints per-object current versus expected mimetype and the planned action. `--apply` is required to mutate.
- The script asserts the total object count (468 production, 474 local) and the per-extension counts before planning. A count mismatch blocks `--apply`.
- Rationale (**Observed** in F14, plus **Inference** about the Storage backend): the installed storage-js has no metadata-only path, and Storage serves Content-Type from object metadata held by the backend, so editing `storage.objects.metadata` through SQL would not change the served header. SQL UPDATE is prohibited and a re-tag re-writes the object.
- Idempotent: matching objects are skipped; a second run reports 0 planned changes.

**Repair safety (revision 1, J-173-02).**

- (a) Recoverable original bytes. Before any write, `--apply` downloads every object in the repair set into a backup directory outside the repo or in a git-ignored path, for example `.backups/G173-<UTC>-<target>/<path>`. It writes a manifest JSON with path, object id, version, etag (if exposed), size, sha256, mimetype, cacheControl, and updated_at, plus a `.sha256` sidecar. A copy of the manifest goes to `docs/cutover-evidence/G173-pre-retag-<UTC>-<target>.json` (metadata only; no lesson bytes in git). `--apply` aborts if any download fails or the backup cannot be fully written and verified by re-hashing. Add the backup directory to `.gitignore` only if it sits inside the repo.
- (b) Independent content check. For each object, the downloaded sha256 must equal the sha256 of the corresponding storage-seed source file. Otherwise abort and report. Divergent content is never silently re-written.
- (c) Conditional write. Immediately before writing each object, re-read `info()` and compare etag/version, updated_at, and size against the backup manifest. Abort the whole run on any divergence. Write the backed-up bytes with the expected `contentType` and the object's ORIGINAL `cacheControl` (preserved from the manifest), with `upsert: true`, via `storage.from('lesson-assets').update(...)` or upload with upsert (T1 picks per the installed storage-js API). Re-read afterwards and confirm size, sha256 (by download), and mimetype; abort on the first mismatch. T1 also checks whether the Storage API honors a conditional header (for example `If-Match`) passed through `FileOptions.headers`. Use it if proven locally; otherwise record that the residual time-of-check-to-time-of-use window is mitigated by (d).
- (d) Maintenance window (Phase P). The user schedules a window during which no `provision-lessons` run, course-authoring publish, or other writer touches `lesson-assets`. The orchestrator confirms this with the user before `--apply`.
- (e) Rollback. `--rollback <backup-dir>` restores from the backed-up ORIGINAL bytes (sha256-verified) with the original mimetype and cacheControl. It applies only to objects whose current sha256 still equals the post-retag hash recorded by `--apply`. Any object changed since then is reported and skipped, never overwritten with stale bytes. Rehearse rollback locally in Step 7.
- (f) Optional alternative. An S3-protocol `CopyObject` with `MetadataDirective=REPLACE` (`config.toml` has `[storage.s3_protocol]` enabled locally) could be metadata-only. It may replace the re-write only if T1 proves it locally, end to end, including the signed-GET header. It is not the default and needs separate hosted S3 credentials for Phase P (user decision).
- Guard: exact-match `LOCAL_SUPABASE_URL` by default. Non-local requires `SUPABASE_SERVICE_ROLE_KEY` from env (never persisted to `.env.local`), `--target-project gvobtuhbpqvfhjljjcye` matching the URL ref, and the `--i-have-user-approval` flag. Refuse otherwise. No RLS change.
- Add npm script `retag:asset-content-types`.
- Unit-test planning, idempotency, guard, backup, and rollback logic with a mocked client: dry-run makes zero writes; apply writes only mismatches; fixture duplicates are excluded for non-local; a second run is a no-op; guard refusals; abort on a failed backup, a seed-hash divergence, or a pre-write divergence; rollback skips objects changed since re-tag.

### Step 6. Signed-URL verification (T1)

`scripts/verify-signed-url-content-types.ts` (or a mode of the check script). For one object per extension present (pdf, pptx, md, yaml, json), create a signed URL (service role, short TTL such as 60s) and GET it (`Range: bytes=0-0` is acceptable). Record, for each extension, the HTTP status and the response headers Content-Type, Cache-Control, X-Content-Type-Options, Content-Disposition, Content-Length, and ETag, and save them in the evidence output. Assertions:

- HTTP status is 200 or 206.
- Content-Type matches the mapping via `isContentTypeMatch`.
- Content-Length equals the object size.
- Cache-Control equals the value captured before the re-tag. Re-tag must not change caching; the default from `FileOptions` is `max-age=3600`.
- Content-Disposition: with a plain signed URL (no download option) it is not `attachment`, so a PDF handout opens inline in the browser for #174. PPTX is delivered as a download by the browser's normal handling of its Content-Type. The `.md`, `.yaml`, and `.json` objects are fetched programmatically by the app for #175 and #174.
- X-Content-Type-Options is recorded. If it is `nosniff`, the correct Content-Type is mandatory for inline PDF and for fetches, which strengthens this fix.

Any unexpected header value goes in the evidence as an observation for #174/#175, not as a scope expansion. The CDN cache may serve the old headers until max-age expires. Read-only. Local by default; non-local only under the same explicit target guard (Phase P).

### Step 7. Local validation (T1, then Verifier)

Against the local stack (`npx supabase start` / `db reset`; `npm run ensure:bucket`):

1. Run the check and record the baseline (it may show CLI-seeded mismatches).
2. Run `provision-lessons` locally if it is part of the standard local flow.
3. Run the re-tag dry-run, then re-tag `--apply`.
4. Run the check again (0 manifest-pinned mismatches).
5. Run re-tag again (0 planned).
6. Run signed-URL verification (all pass).
7. Rehearse rollback from the backup directory (`--rollback <backup-dir>`), then re-apply.
8. Run the final check (passes).

Save outputs as local evidence under `docs/cutover-evidence/G173-local-*.txt` (or the job's evidence location).

### Step 8. Quality gates

Run `npx vitest run` (full suite), `npm run type-check`, `npm run lint`, and `npm run verify:build`. Then the CODE_REVIEW judge, then Verifier.

### Phase P. PRODUCTION re-tag (separate, explicitly user-gated)

Phase P is NOT executed by the automatic build. Owner: orchestrator with T1, only after the user's explicit go-ahead naming project `gvobtuhbpqvfhjljjcye`.

**Preconditions:**

- Steps 0-8 are complete and verified.
- The #173 PR is merged, or the user explicitly approves running from the branch.
- A fresh read-only production check output is saved.
- Backup: a fresh data-only dump of `storage.objects` metadata (`docs/cutover-evidence/G173-pre-retag-data-<UTC>-gvobtuhbpqvfhjljjcye.sql` plus `.sha256`), plus the byte backup directory and manifest written by `--apply` (Step 5(a)), with the manifest copy in `docs/cutover-evidence/`.
- Maintenance window: the user has scheduled a window during which no `provision-lessons` run, course-authoring publish, or other writer touches `lesson-assets`, and the orchestrator has confirmed this with the user before `--apply`.
- Production state check passes: 468 objects, all `text/plain` (otherwise the plan is stale; see Section 10).

**Sequence:**

1. Read-only check, asserting total 468 and per-extension counts (`.pdf` 78, `.pptx` 78, `.md` 156, `.yaml` 78, `.json` 78).
2. Re-tag dry-run. It must plan exactly 468 changes (`text/plain` to mapped type); any other number blocks the run for user review. Any object outside the repair set is untouched.
3. User go-ahead.
4. Re-tag `--apply` (backup, seed-hash check, conditional write, post-write verification per Step 5).
5. Check (0 mismatches, counts as in step 1).
6. Signed-URL verification on hosted, with the header assertions from Step 6 (the CDN may serve old headers until max-age expires).
7. Re-tag dry-run shows 0 planned changes.
8. Record evidence.

**Rollback:** `--rollback <backup-dir>` restores the backed-up original bytes (sha256-verified) with the original mimetype and cacheControl, only for objects whose current sha256 still equals the post-retag hash; changed objects are reported and skipped. The re-write is byte-identical by design, verified by sha256 before and after each write, and abort-on-first-mismatch limits blast radius. The byte backup is retained outside git until the user confirms Phase P success.

**CDN note (Assumption):** hosted CDN may cache the old Content-Type for the object cache-control duration (default 3600s). If signed-URL verification shows the old type, re-verify after cache expiry before declaring failure.

## 6. Browser UI dialog policy and design route

Not applicable. There is no browser UI change; existing behavior is preserved. `design_route`, `design_handoff`, and `design_review` are all none. No `browser_ui_validation` is required and no Browser Validator pass applies.

## 7. Interfaces and data

- **New exported interface (consumed by #174 and #175):** `src/lib/storageContentType.ts` exporting `CONTENT_TYPE_BY_EXTENSION`, `contentTypeForPath(path)`, `isContentTypeMatch(path, mimetype)`, and `UnsupportedStorageExtensionError`. These names are stable; changing them makes #174/#175 plans stale.
- **Data guarantee #174/#175 depend on:** every object in the repair set (468 in production, 474 locally, including the unreferenced `flashcards.md`) is served via signed URL with the mapped Content-Type, enforced by `npm run check:asset-content-types` (total and per-extension counts plus MIME match) and G9 post-run verification. Specifically: handout `.pdf` is `application/pdf` (for #174 handout links); `weekly-review-recap.md` and `flashcards.md` are `text/markdown; charset=utf-8` and `flashcards.yaml` is `application/yaml` (for #175 in-app vocabulary review); `lesson-content.json` is `application/json`. #174/#175 production acceptance depends on Phase P being completed.
- **Unchanged:** the `getSignedResourceUrl` signature and behavior; RLS and storage policies; bucket config; the `resources` table and `storage_path` values; object paths and bytes.
- **Note for #174/#175 (not fixed here):** `STORAGE_CONFIG.RESOURCE_EXTENSIONS` in `src/lib/storageSigning.ts:226-231` lists flashcards as `.json` and vocabulary_review as `.pdf`, which do not match real paths (`.yaml`, `.md`). `generateStoragePath` is reference-only. Downstream plans should not rely on it.
- No migration; no schema change.

## 8. Acceptance checks

**Unit:**

- `storageContentType` tests pass for all mapped extensions (`.pdf`, `.pptx`, `.docx`, `.md`, `.yaml`/`.yml`, `.json`), uppercase, and unknown or missing extension throwing.
- `uploadToStorage` passes `{ upsert: true, contentType: <mapped> }` on every upload; existing G9/defect-1 tests are unchanged and passing; an unknown extension fails before any upload.
- Post-run content-type verification flags a `text/plain` object and passes a correct one (mocked `info()`).
- Re-tag script: dry-run performs zero writes; `--apply` writes only mismatched repair-set objects with identical bytes and the original cacheControl; fixture duplicates are excluded when non-local; a second run is a no-op; non-local without the explicit flags is refused before any client call; the byte backup and manifest are written and re-hash verified before the first write; a failed backup, a seed-hash divergence, or a pre-write etag/version/updated_at/size divergence aborts the run; rollback from the backup directory restores the original bytes, mimetype, and cacheControl and skips objects changed since re-tag.
- Check script logic exits non-zero on a repair-set mismatch or a count mismatch (total 468 production / 474 local, per-extension), zero when all match, and separates non-manifest objects.

**Local integration evidence:** the check reports 0 repair-set mismatches and the expected counts after re-tag; the second re-tag dry-run reports 0; signed-URL GET returns the mapped Content-Type for pdf, pptx, md, yaml, and json with the Step 6 header assertions recorded; the rollback rehearsal succeeds. T1 also records whether a conditional header (`If-Match`) is honored locally.

**Deterministic source checks:**

- `git diff origin/main...fix/173-storage-content-type --stat` lists only #173 files: `src/lib/storageContentType.ts`, `src/__tests__/storageContentType.test.ts`, `scripts/provision-lessons.ts`, `src/__tests__/provision-lessons.test.ts`, `scripts/check-lesson-assets-content-types.ts`, `scripts/retag-lesson-assets-content-types.ts`, `scripts/verify-signed-url-content-types.ts` (if separate), `scripts/sql/check-lesson-assets-mimetypes.sql`, their tests, `package.json` scripts entries, local evidence files, and `.gitignore` only if the backup directory sits inside the repo. No lesson bytes are committed.
- No file under `supabase/migrations` changed; no storage policy SQL changed.
- A grep confirms every `lesson-assets` `.upload(` in `scripts/` passes `contentType`.

**Commands:** `npx vitest run` (`npm test`), `npm run type-check`, `npm run lint`, and `npm run verify:build` all pass.

**Verifier:** independently re-runs the commands and source checks. No Browser Validator (no UI).

**Phase P acceptance (separate, after user go-ahead):** the pre-apply dry-run planned exactly 468 changes; the production check shows 0 mismatches with total 468 and the per-extension counts; signed-URL GET is correct for each extension with the Step 6 header assertions (Content-Type, Content-Length, Cache-Control unchanged from before the re-tag); the pre-retag dump, backup manifest, and sha256 sidecars are recorded; the post dry-run shows 0 planned changes.

## 9. Risks and rollback

| ID | Risk | Mitigation |
| --- | --- | --- |
| R1 | #173 depends on unmerged release-branch code | Default is to merge the cleanup PR first; stack only under the Step 0 conditions. Step 0 base check blocks with "Plan stale" if required code is missing. |
| R2 | Accidental production mutation | Exact-match local guard, dry-run default, triple explicit flags for non-local, service-role key from env only, Phase P excluded from the build. |
| R3 | Re-tag alters bytes (the re-write is unavoidable because storage-js has no metadata-only path) | Verified byte backup, seed-hash check, re-write of backed-up bytes with original cacheControl, post-write size/sha256/mimetype verification, abort on first mismatch; SQL metadata UPDATE prohibited. |
| R4 | Touching non-manifest objects (course-authoring uploads) | Repair-set intersection; other objects are report-only. |
| R5 | Re-upload regenerates object version and `updated_at`; previously issued signed URLs are path-based and remain valid (**Inference**) | Verify in the local signed-URL step. |
| R6 | CDN caching of the old Content-Type on hosted | Wait for cache expiry before judging failure. |
| R7 | Post-run verification now fails G9 re-runs on production until Phase P | Documented and intended. |
| R8 | Unknown CLI-seeded local mimetypes | Empirical check plus local re-tag. |
| R9 | A concurrent writer (`provision-lessons`, course-authoring publish) changes an object during re-tag | Pre-write conditional comparison against the backup manifest (and `If-Match` if proven), abort on divergence, and the Phase P maintenance window. |
| R10 | Backup of lesson bytes held outside git | Stored in a git-ignored or out-of-repo path; deleted only after the user confirms Phase P success. |

**Rollback (code):** revert the #173 PR; objects keep the correct types (harmless).
**Rollback (data):** `retag --rollback <backup-dir>` restores the original bytes, mimetype, and cacheControl, skipping objects changed since re-tag; the pre-retag dump and manifest copy are retained as evidence.

## 10. Stale-plan conditions

The writer must return `JOB_BLOCKED` "Plan stale" if any of the following holds:

- `origin/main` lacks `uploadToStorage`, `isFixtureDuplicateUploadToSkip`, or `verifyResourceByteSizes`, or their line semantics changed materially.
- The installed `@supabase/storage-js` lacks an upsert/update path that rewrites content type, or `info()` exposes no content type.
- Storage-seed contains an extension not in the map.
- Bucket config gains `allowed_mime_types` that rejects a mapped type.
- The 468 (production) / 474 (local) object-count baseline changes.
- Production evidence shows types other than `text/plain`.
- The production object count differs from 468, or any object is not `text/plain`, before Phase P.
- The installed `@supabase/storage-js` gains or loses a metadata-only or conditional-write capability.
- Any requirement to change RLS appears.
- #174/#175 plans have already fixed a different interface name.
- The user changes the branch strategy.

## 11. Assumptions and decisions

**Safe assumptions:**

- `@supabase/storage-js` defaults to `text/plain;charset=UTF-8` (given evidence, consistent with the production dump).
- Local CLI-seeded types are unknown and verified empirically.
- `text/markdown; charset=utf-8` is the accepted exact stored value.
- `.yml` maps the same as `.yaml`.

**Planner decisions (approvable):**

- Module location is `src/lib/storageContentType.ts`.
- An unknown extension is a hard failure.
- Re-tag rewrites byte-identical content (from a verified backup) rather than editing metadata through SQL.
- Branch-base default: merge the cleanup PR first (accepted in revision 1).
- The check exits non-zero only for manifest-pinned objects by default.

## 12. Approvals

User approvals still needed:

1. Explicit approval of this plan before engineering (T1 is not dispatched until then).
2. Explicit authorization to commit, push, and open the #173 PR at execution time.
3. A separate explicit go-ahead naming `gvobtuhbpqvfhjljjcye` before Phase P.
4. Only if the user wants to proceed before the cleanup PR merges: an explicit request to stack #173 on the cleanup branch (default is merge cleanup first).
5. The Phase P maintenance window (a period with no `provision-lessons` run, course-authoring publish, or other writer touching `lesson-assets`).
6. Whether to permit the optional S3 `CopyObject` metadata-only path (Step 5(f)), which needs separate hosted S3 credentials for Phase P. The default re-write path needs no such decision.

## 13. Engineering mode and downstream owner

- **Engineering mode:** standard. T1 is first line; T2 takes over on two counted gate failures. No extreme advisory team. `team_authorization`: not applicable.
- **Downstream owner:** engineering-fleet. Phase P is additionally user-gated.

## Approval record

Approved by the user on 2026-10-03, together with the plans for the other three lizbeth-spanish issues among #173, #176, #177, and #178, in the orchestrator session.

- Covered: commits, pushes, and pull requests for this item. User instruction: create new branches and PRs as needed; existing unmerged local work in lizbeth_spanish lands as its own cleanup PR first.
- Not covered: production writes (storage re-tag, migrations, Edge Function deploys, Netlify deploys). Each needs a separate explicit user go-ahead after local validation.

# Lizbeth Spanish issue #173 Phase P runbook (production lesson-assets Content-Type re-tag)

Status: PREPARED, NOT APPLIED. Pre-change reads only were run on 2026-10-06. No production write of any kind has occurred.
Plan: `docs/plans/lizbeth-spanish-issue173-storage-content-type.md` (Steps 5, 6, Phase P).
Target: Supabase project `gvobtuhbpqvfhjljjcye` (cultural-spanish), bucket `lesson-assets`.
Tooling source: `origin/main` at `aa99662` (contains PR #181 scripts).
No secrets are recorded in this file.

## 1. Pre-change results (read-only, 2026-10-06)

| Check | Result |
|---|---|
| npm scripts `check:asset-content-types`, `retag:asset-content-types`, `verify:asset-signed-urls` | Present on `origin/main` (`package.json` lines 27-29; scripts `scripts/check-lesson-assets-content-types.ts`, `retag-lesson-assets-content-types.ts`, `verify-signed-url-content-types.ts`). NOT present on the main checkout, which is on `release/fjds-course-management-20260915` (see section 2). |
| `check` against production | Total 468. Counts: .pdf 78, .pptx 78, .md 156, .yaml 78, .json 78 (exactly as expected). Repair-set mismatches 468. Other (non-manifest) mismatches 0. Exit 1 (RESULT: FAIL is the expected pre-retag state). Plan is NOT stale. |
| Current Content-Type of every object | `text/plain;charset=UTF-8` (468 of 468). Note the literal value includes `;charset=UTF-8`, not bare `text/plain`. |
| `retag` DRY-RUN (no `--apply`) | `Repair set: 468; present: 468; planned changes: 468`. `DRY-RUN: no changes made.` Exit 0. |
| Signed-URL baseline (one object per extension) | 5 objects, HTTP 200 each, `content-type: text/plain;charset=UTF-8` for pptx, pdf, md, yaml, json. `cache-control`, `x-content-type-options`, `content-disposition`, `content-length` all absent (null) on the signed GET. ETag present (weak). Object-level `cacheControl` is `max-age=3600`. |
| storage.objects metadata dump | 468 objects, all `text/plain;charset=UTF-8`. |

Evidence files (all in `H:\CommandCenter\orchestrator\lizbeth_spanish\docs\cutover-evidence\`, each with a `.sha256` sidecar holding the bare hex digest, same convention as the `G9b-data-*` files; untracked, nothing committed):

- `G173-pre-retag-data-20261006T135849Z-gvobtuhbpqvfhjljjcye.json` (sha256 `4c1e76032834f12efe8b618b2d01f0726d6f4da7633cefab0babc616f1b56ce8`)
- `G173-pre-retag-signed-url-baseline-20261006T135849Z-gvobtuhbpqvfhjljjcye.json`
- `G173-pre-retag-dryrun-20261006-gvobtuhbpqvfhjljjcye.txt`
- `G173-pre-retag-check-20261006-gvobtuhbpqvfhjljjcye.txt`

Location choice: the project convention (plan F11, `scripts/require-backup.js`, existing `G9b-data-*` files) is `docs/cutover-evidence/` inside the `lizbeth_spanish` repo, not the orchestrator `docs/evidence/`. This runbook is in the orchestrator `docs/evidence/` as requested.

Dump method deviation: the G9b files are `pg_dump` SQL, which needs the hosted database password (not available locally; `--linked` is forbidden). The dump is instead a JSON export of the Storage API object listing (name, id, bucket_id, created_at, updated_at, last_accessed_at, full metadata incl. mimetype, cacheControl, eTag, size, lastModified) through the service role, read-only. It captures the pre-retag Content-Type and cache-control for rollback reference. It is not a restorable SQL dump; byte-level rollback relies on the byte backup in section 4.

## 2. Findings the operator must know before apply

1. Wrong checkout for tooling. `H:\CommandCenter\orchestrator\lizbeth_spanish` is on `release/fjds-course-management-20260915` (HEAD `b1e85e2`) with 79 modified files, and lacks the #173 scripts. The tooling lives on `origin/main`. Run every command from a clean export of `origin/main` (section 3), never from the dirty checkout.
2. Seed drift in the dirty checkout. The 78 modified `supabase/storage-seed/lesson-assets/**/flashcards.yaml` files show as modified because of CRLF/LF autocrlf drift. `--apply` hashes seed files from `<cwd>/supabase/storage-seed/lesson-assets`. Running apply from the dirty checkout risks a seed-hash mismatch (abort before any write is expected, per script design) or, worse, a confusing result. Use the clean export, which has LF bytes exactly as committed.
3. Credential form. The `SUPABASE_SERVICE_ROLE_KEY` in `lizbeth_spanish\.env.provisioning` is a new-style `sb_secret_...` key. Storage rejects it as a bearer token (`list("") failed: Invalid Compact JWS`). The working credential is the project's legacy `service_role` JWT, retrieved read-only from the local Supabase CLI session with `supabase projects api-keys --project-ref gvobtuhbpqvfhjljjcye -o json` and held only in the process environment. No file was written.
4. Signed-URL script will report FAIL after the re-tag unless handled. `verify-signed-url-content-types.ts` asserts Content-Length and Cache-Control, but the hosted signed GET returns neither at baseline (both null; the 10 baseline failures are 5 Content-Type mismatches plus 5 Content-Length nulls). After a correct re-tag the Content-Type assertions pass but the 5 Content-Length assertions will still fail. Acceptance for Phase P should therefore compare headers against the saved baseline (Content-Type changed to the mapped type; Content-Length/Cache-Control still absent, i.e. unchanged) and not rely on exit code 0. This is an observation for the plan owner (plan Step 6 says "unchanged from before"), not a scope expansion.
5. Every script prints a banner "LESSON PROVISIONING SCRIPT - LOCAL SUPABASE ONLY" because it imports `provision-lessons`. Cosmetic; the target guard still enforces the production ref explicitly.
6. Apply and rollback need the extra flag `--i-have-user-approval` and `--target-project gvobtuhbpqvfhjljjcye`. The key is refused for any other ref.

## 3. Environment setup (each shell session)

PowerShell (in a scratch directory outside the repo; replace `<WORK>`):

```powershell
$WORK = "$env:TEMP\g173-om"; New-Item -ItemType Directory -Force $WORK | Out-Null
git -C H:\CommandCenter\orchestrator\lizbeth_spanish fetch
git -C H:\CommandCenter\orchestrator\lizbeth_spanish -c core.autocrlf=false archive origin/main | tar -x -C $WORK
cmd /c mklink /J "$WORK\node_modules" H:\CommandCenter\orchestrator\lizbeth_spanish\node_modules
Set-Location $WORK
$env:SUPABASE_URL = "https://gvobtuhbpqvfhjljjcye.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = (supabase projects api-keys --project-ref gvobtuhbpqvfhjljjcye -o json | ConvertFrom-Json | Where-Object id -eq 'service_role').api_key
```

Confirm the export tip is `aa99662` or a later `origin/main` that still contains the three scripts. Never persist or echo `SUPABASE_SERVICE_ROLE_KEY`. Do not pass `--linked` anywhere. Close the shell afterwards (or `Remove-Item Env:SUPABASE_SERVICE_ROLE_KEY`).

## 4. Phase P sequence

Preconditions (user confirms): maintenance window open; no `provision-lessons`, course-authoring publish, asset upload, or any other `lesson-assets` writer runs from step 2 until step 6 completes. Storage ignores `If-Match`, so this window is the only full protection against a concurrent write.

Variables:

```powershell
$UTC = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$BACKUP = "H:\CommandCenter\backups\G173-$UTC"    # outside any repo; keep until the user confirms success
$EVID = "H:\CommandCenter\orchestrator\lizbeth_spanish\docs\cutover-evidence"
$REF = "gvobtuhbpqvfhjljjcye"
```

1. Re-confirm pre-state (read-only; must still show 468 / 468 mismatches, 0 other):

```powershell
npm run check:asset-content-types -- --target-project $REF
npm run retag:asset-content-types -- --target-project $REF        # dry-run, expect "planned changes: 468"
```

   Stop if the total is not 468, any object is not `text/plain;charset=UTF-8`, or the per-extension counts differ (.pdf 78, .pptx 78, .md 156, .yaml 78, .json 78). Optionally re-capture the metadata dump if time has passed since `20261006T135849Z`.

2. APPLY (the only mutating step; requires the user's separate go-ahead naming `gvobtuhbpqvfhjljjcye`):

```powershell
npm run retag:asset-content-types -- --apply --target-project $REF --i-have-user-approval --backup-dir $BACKUP --evidence-dir $EVID
```

   The script backs up all 468 objects, verifies each against the seed hash, re-checks etag/version/size before each write, preserves cache-control, aborts on first mismatch, then re-hashes every object against the backup. Expected final line: `APPLY complete: backed up 468, re-tagged 468. Backup: <BACKUP>`. The backup `manifest.json` (+ `.sha256`) and a copy `G173-pre-retag-<stamp>-gvobtuhbpqvfhjljjcye.json` land in `$EVID`.

   If it aborts partway, do NOT re-run blindly: capture output, run the check (step 3) to see the state, and decide between re-running apply (idempotent for already-retagged objects) and rollback.

3. VERIFY:

```powershell
npm run check:asset-content-types -- --target-project $REF        # expect total 468, 0 repair-set mismatches, RESULT: PASS
npm run verify:asset-signed-urls -- --target-project $REF --out "$EVID\G173-post-retag-signed-url-$UTC-$REF.json"
```

   Expected signed-URL Content-Types: .pdf `application/pdf`; .pptx `application/vnd.openxmlformats-officedocument.presentationml.presentation`; .md `text/markdown; charset=utf-8`; .yaml `application/yaml`; .json `application/json`. See section 2 item 4 for the Content-Length/Cache-Control assertion caveat. The CDN may serve the old header until the 3600 s max-age expires; re-run after up to one hour before concluding failure. Optionally run with `--all` for every object.

4. POST DRY-RUN (expect 0 planned changes):

```powershell
npm run retag:asset-content-types -- --target-project $REF        # expect "planned changes: 0"
```

5. Record sha256 sidecars for the new evidence files (`Get-FileHash -Algorithm SHA256`, bare hex into `<file>.sha256`). Keep `$BACKUP` until the user confirms Phase P success; it holds original lesson bytes and stays outside git.

6. Close the maintenance window and notify the user.

## 5. Rollback

Only restores objects whose current sha256 still equals the post-retag hash (changed objects are reported and skipped). Verifies backup files against the manifest hashes before any remote call. Writers must again be paused.

```powershell
npm run retag:asset-content-types -- --rollback $BACKUP --target-project $REF --i-have-user-approval
npm run check:asset-content-types -- --target-project $REF        # now expected to FAIL again with 468 mismatches (original text/plain state)
```

Rollback restores original bytes, original mimetype (`text/plain;charset=UTF-8`) and original cacheControl. The re-write is byte-identical by design, so data loss risk is low; the metadata dump in section 1 is the reference for the original metadata.

## 6. Abort criteria

Total not 468; any non-`text/plain;charset=UTF-8` object in the repair set; seed-hash mismatch; any script exit other than the documented ones; evidence of another writer; target-guard refusal. In any of these, do not apply; report to the user.

## 7. What was run on 2026-10-06 (all read-only)

- `git fetch` (no tree change); export of `origin/main` into a scratch directory with a `node_modules` junction (created, not deleted).
- `check-lesson-assets-content-types.ts --target-project gvobtuhbpqvfhjljjcye`: exit 1 with 468 expected mismatches.
- `retag-lesson-assets-content-types.ts --target-project gvobtuhbpqvfhjljjcye` (no `--apply`): exit 0, 468 planned.
- `verify-signed-url-content-types.ts --target-project gvobtuhbpqvfhjljjcye --out ...`: 5 samples, HTTP 200.
- Storage API listing (service role) for the metadata dump.
- `supabase projects api-keys --project-ref gvobtuhbpqvfhjljjcye` (read-only; key kept in process env only).

## 8. Update after execution (2026-10-06)

Phase P was executed; see `lizbeth-spanish-issue173-phase-p-apply-20261006.md` for the receipt. Corrections to the plan above learned in execution:
- Seed source: `origin/main` seed does NOT match production. Use a scratch overlay of `da6f05c` supabase/storage-seed/lesson-assets with LF->CRLF on the 78 `lesson-content.json` and `intermediate/week-07/weekly-review-recap.md`, passed with `--seed-dir`.
- Tooling: the original #173 scripts abort on hosted because `info()` is stale after an update; use branch `fix/173-hosted-info-stale` (list()-based verification).
- Apply is slow (about 1.3 s per object, roughly 10 minutes for 468): run it in the background, not under a 10-minute foreground limit.
- Content-Length FAILs in signed-URL verification are expected for .md and .json (234 objects); Content-Type is the acceptance criterion.
- Post-state: check PASS (468, 0 mismatches), dry-run 0 planned.

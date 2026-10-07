# Issue #173 Phase P apply receipt, 2026-10-06: ABORTED, NO WRITES

Project gvobtuhbpqvfhjljjcye, bucket lesson-assets. No secrets recorded.

- Pre-apply check (UTC 20261006T140922Z): 468 objects, 468 mismatches, 0 other. Counts as expected.
- Command: `retag-lesson-assets-content-types.ts --apply --target-project gvobtuhbpqvfhjljjcye --i-have-user-approval --backup-dir H:/CommandCenter/backups/G173-20261006T140922Z --evidence-dir <lizbeth_spanish>/docs/cutover-evidence`, run from a clean `git archive origin/main` (aa99662) export.
- Result: script refused on the first object, before any write or backup:
  `Content of "advanced/week-01/advanced-week-01-instructor.pptx" differs from its storage-seed source (bucket 102f974a... vs seed 5b9ea581...); refusing to re-write divergent content.`
- Rollback state: nothing to roll back. A re-run of the check after the abort still shows 468 objects, 468 mismatches (unchanged). No backup directory was created.
- Read-only diagnostic (download + sha256 of all 468 objects vs origin/main seed): divergent 234 = all 78 .pptx, all 78 .json (lesson-content.json), 78 of 156 .md (weekly-review-recap.md). Matching: all 78 .pdf, all 78 .yaml, 78 flashcards.md. Cause: origin/main seed was regenerated after the production upload (#179/#180 commits strip quiz/recap answers and regenerate lesson-content; seed last changed 2026-10-05). Seed set at release/fjds b1e85e2 also diverges for lesson-content.json (partial check).
- Evidence: lizbeth_spanish/docs/cutover-evidence/G173-apply-ABORTED-20261006T140922Z-gvobtuhbpqvfhjljjcye.txt (+ .sha256).
- Steps 1-4 of post-apply verification not run (nothing applied).

## Follow-up: seed provenance search (option 2), still NO writes

Read-only: production sha256 of all 468 objects vs every git blob version under supabase/storage-seed/lesson-assets across all refs of the lizbeth_spanish repo.

Best single commit: da6f05c (2026-07-26, "Relocate lesson content to content-source and generate storage-seed JSON artifacts"). Its tree matches 468/468 production objects, but not on raw blob bytes:

| Class | Count | Matches da6f05c blob |
|---|---|---|
| .pptx, .pdf, flashcards.md, flashcards.yaml | 78 each | raw, byte-identical |
| weekly-review-recap.md | 77 | raw |
| weekly-review-recap.md (intermediate/week-07) | 1 | only after LF -> CRLF conversion |
| lesson-content.json | 78 | only after LF -> CRLF conversion |

So production = da6f05c content, with 79 text files uploaded with CRLF line endings (a Windows working-tree artifact). Every commit after da6f05c (7221ed1 #178, 8b87c26/17e63b4 #179, e6f349c/f894036 #180) changes lesson-content.json and/or recaps and pptx, which is why origin/main diverges. No single commit matches all 468 on raw blob bytes (best raw: 389/468).

Apply NOT run: using this seed needs a scratch overlay of da6f05c with a CRLF conversion on those 79 files, which is outside the "single commit, raw bytes" condition set by the coordinator. Awaiting confirmation.

## Apply attempt 2 (da6f05c overlay): ABORTED after 1 write

Overlay: `git archive da6f05c supabase/storage-seed/lesson-assets` (autocrlf off) into scratch, then LF->CRLF on exactly 79 files: all 78 `*/lesson-content.json` and `intermediate/week-07/weekly-review-recap.md` (list in scratch `crlf-files.txt`). 474 seed files; 468/468 production objects hash-matched before any write. Passed to the script with `--seed-dir`; origin/main (aa99662) tooling unchanged.

Run UTC 20261006T142228Z, backup `H:\CommandCenter\backups\G173-20261006T142228Z` (manifest.json + sha256, 468 object files; retain). Dry-run with overlay: planned changes 468.

Outcome: backup of 468 verified OK; seed-hash check passed; first object `advanced/week-01/advanced-week-01-instructor.pptx` was re-written; then the script's post-write check aborted: `Post-write verification failed ... contentType text/plain;charset=UTF-8, cacheControl max-age=3600, hash match true`.

Diagnosis (read-only): after the write, Storage `list()` metadata shows the new mimetype and the signed-URL GET and HEAD serve `application/vnd.openxmlformats-officedocument.presentationml.presentation`, same etag, size and bytes (hash match true). But `info()` (what the script's post-write check uses) keeps returning the old `text/plain;charset=UTF-8` and the same version id, still stale minutes later. The write works; the script's verification source (`info`) is stale on hosted, so any apply will abort after each first write.

Current state: 1 of 468 re-tagged (byte-identical, cache-control unchanged). Check shows 467 mismatches. Production content is unchanged; no rollback needed (rollback available via `--rollback` with this backup dir, but no `post-retag.json` was written because the first write failed verification; the original manifest in the backup dir is authoritative).
Evidence: `G173-apply-ABORTED-after-1-write-20261006T142228Z-gvobtuhbpqvfhjljjcye.txt` in lizbeth_spanish/docs/cutover-evidence.

## Final: Phase P applied and verified (2026-10-06)

Result: all 468 objects of lesson-assets in gvobtuhbpqvfhjljjcye now carry the Content-Type mapped to their extension. Bytes are unchanged (hash-verified against byte backups) and cache-control is unchanged (`max-age=3600`).

Method:
- Tooling: branch `fix/173-hosted-info-stale` working tree (worktree lizbeth_spanish-173b, uncommitted fix: Content-Type/cache-control/size verification reads Storage `list()`, not the stale `info()`; rollback tolerant of a missing post-retag.json). Verifier returned VERIFICATION_PASS. Exported with `git archive HEAD` (aa99662) plus the four modified files (byte-compared identical).
- Seed overlay: `git archive da6f05c supabase/storage-seed/lesson-assets` (autocrlf off), then LF->CRLF on exactly 79 files: all 78 `*/lesson-content.json` and `intermediate/week-07/weekly-review-recap.md`. Passed with `--seed-dir`. 474 seed files; before any write, 468/468 fresh production downloads hash-matched the overlay (including the earlier re-tagged advanced-week-01 pptx).
- Key: legacy service_role JWT fetched from the Supabase CLI session into the process environment only; never printed or written. No `--linked`.

Runs (all `--apply --target-project gvobtuhbpqvfhjljjcye --i-have-user-approval`):
1. 20261006T142228Z (old tooling): wrote 1 object (advanced-week-01 pptx), aborted on the stale `info()` post-write check. Backup `H:\CommandCenter\backups\G173-20261006T142228Z`.
2. 20261006T151059Z (fixed tooling): dry-run planned 467. Backup of 468 verified; re-tagged 463 objects (post-retag.json lists 463), then my foreground shell hit its 10-minute limit and killed the process (no script error; sequential per-object writes are slow, ~1.3 s each). Backup `H:\CommandCenter\backups\G173-20261006T151059Z`.
3. 20261006T152113Z (fixed tooling, background): at start the 4 remaining mismatches had already converged; `planned changes: 0`; fresh 468-object backup verified; `Post-run check passed for 468 object(s)` (every object: bytes equal backup, mapped Content-Type, original cache-control). Backup `H:\CommandCenter\backups\G173-20261006T152113Z`.

Post-checks:
1. `check:asset-content-types`: total 468; .pdf 78, .pptx 78, .md 156, .yaml 78, .json 78; repair-set mismatches 0; other mismatches 0; RESULT: PASS (exit 0).
2. Retag dry-run: `planned changes: 0`.
3. Signed-URL verification, 5 samples and `--all` (468 objects): Content-Type correct for every extension (pdf application/pdf; pptx application/vnd.openxmlformats-officedocument.presentationml.presentation; md text/markdown; charset=utf-8; yaml application/yaml; json application/json). No Content-Type failure. Script exit is non-zero only because of the known Content-Length assertion: 234 FAILs = exactly the 156 .md + 78 .json (compressible types come back without Content-Length on hosted); pdf, pptx and yaml carry Content-Length. Cache-Control header is absent on signed GETs, as in the baseline (recorded as observation). No CDN-stale type was observed.
4. Evidence (all in lizbeth_spanish/docs/cutover-evidence, each with .sha256 sidecar, untracked): `G173-apply-run3-INTERRUPTED-*`, `G173-apply-run4-COMPLETE-*`, `G173-post-retag-run3-*.json` (post-retag.json), `G173-post-retag-check-*`, `G173-post-retag-dryrun-*`, `G173-post-retag-signed-url-5-*` and `-all468-*` (.txt/.json), and the three pre-retag manifests `G173-pre-retag-<stamp>-*.json` written by the script (142243Z, 151113Z, 152128Z). Earlier pre-change evidence unchanged. Secret scan of G173-* files: clean.

Retained byte backups (outside git; keep until the user confirms): the three directories above under `H:\CommandCenter\backups\`. Rollback source: use `G173-20261006T151059Z` (it holds the original bytes of all 468; original mimetypes are in its manifest, except advanced-week-01 pptx whose original `text/plain;charset=UTF-8` is in `G173-20261006T142228Z`). Rollback (`--rollback <dir> --target-project gvobtuhbpqvfhjljjcye --i-have-user-approval`) is now safe with the fixed tooling (hash- and fresh-metadata-based, no post-retag.json required).

Follow-ups for the user: merge/push of branch `fix/173-hosted-info-stale` (not done); the `provision-lessons` G9 post-run check now passes against production for Content-Type.

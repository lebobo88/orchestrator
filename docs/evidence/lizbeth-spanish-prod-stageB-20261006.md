# Lizbeth Spanish production Stage B rollout (#179 / #180), 2026-10-06

Project `gvobtuhbpqvfhjljjcye`. Source `origin/main` `8e89737`. No `--linked`. No secrets in this file. No Netlify action. Nothing committed, no issues closed.

## Status summary

| Step | Status |
|---|---|
| 1. Local: full chain, and rehearsal of the production sequence | PASS |
| 2. Fresh hosted backup, rollback files | DONE |
| 3. Hosted migrations 040003, 040004, 040005, 040007, 050001, 050002, 050003 | Applied and verified (one data-encoding defect found and fixed, see below) |
| 4. Edge deploy `admin-student-operations`, `course-authoring` | DONE (v2, verify_jwt true) |
| 5. Re-provision 78 `lesson-content.json` + 78 `weekly-review-recap.md` | DONE, 156 of 156 equal the seed |
| 6. HARD GATE `check-no-answer-leak.ts --hosted` | FAIL on the fingerprint rule only (627 hits, identical to the clean seed's own hits); 0 quiz answers, 0 recap markers. STOPPED here as instructed |
| 7. Gate migrations (040006, 050004) and decks-owner-only (050005) | NOT applied, held |
| 8. Live smoke, evidence | DONE |

## DECISION NEEDED: the hard gate fails on a rule that the clean content cannot satisfy

`scripts/check-no-answer-leak.ts --hosted --url https://gvobtuhbpqvfhjljjcye.supabase.co` reports `missing 0`, `lessonContentChecked 78`, `recapChecked 78`, `nonEmptyQuizAnswers 0`, `recapAnswerMarkers 0`, but `fingerprintHits` has 627 entries, so it exits 1.

- The hits are multi-word phrases that the lessons legitimately teach and that are also quiz references or answers (examples: "cómo te llamas", "buenas noches", "cincuenta y dos"). The hosted scan uses the strict rule with no dictionary or co-location relaxation.
- Scanning the repo's own seed files with the same rule gives exactly the same 627 hits, and the seed passes the enforcing seed leak guard (0 quiz answers, 0 recap markers). The gate-signed run below confirms hosted hits equal the seed's hits, hit for hit. So I treat it as a defect in the gate's definition, not a leak. The same failure appears in the local rehearsal after a correct re-provision; the unit test uses synthetic fixtures, so it never saw this.
- The same check on the old (Phase P-era) hosted content showed 493 non-empty quiz answers and 293 recap markers locally in the rehearsal, so the check does detect real answers.
- Evidence of cleanliness that I did produce: a read-only variant reading all 156 artifacts through freshly signed URLs (the path students use) shows hosted bytes equal the seed for 156 of 156, 0 quiz answers, 0 recap markers, and fingerprint hits identical to the seed's (`lizbeth-spanish-prod-stageB-gate-signed.txt`).

Please decide whether to accept the structural gate (hosted equals seed, 0 answers, 0 markers) instead of the zero-fingerprint rule. Until then 050005 and both gate migrations stay unapplied.

## Findings during execution

1. Encoding defect (fixed). My first transport sent migration SQL through PowerShell's default body encoding. `202610040004_issue179_seed_lesson_task_templates` contains Spanish text and was seeded with corrupted characters ("días" became "d?as", 78 template rows). Detected by comparing hash digests with the local database. Remediation, same stage: with the submissions tables confirmed empty (0 rows), I deleted and re-ran the seed in one transaction (`lesson_task_answer_keys` and `lesson_task_templates` only, both created minutes earlier) using UTF-8 byte transport, and refreshed the recorded `statements` text. Afterwards hosted templates hash `dbbbcf07...` and answer keys hash `396b90a2...` equal the local database exactly. `202610050001` then failed at the request level before running (nothing applied), the transport was fixed, and `202610050002` (Spanish quiz seed) was applied with the corrected transport: 78 definitions and 78 answer keys, hashes equal to local (`c973ed55...` and `2690ad17...`). All Stage A migrations were ASCII-only, so they are unaffected.
2. Read-after-write lag. Hosted Storage serves the authenticated download path from a cache and read-after-write on signed GETs can lag by seconds. My re-provision tool therefore reads through signed URLs and polls up to 30 s. Two aborts (first object, then week-05) were this effect; both stopped before more writes, and the object contents were then confirmed correct.
3. `check-no-answer-leak.ts --hosted` uses the cached download path and could read stale bytes after a write; after the content had settled it agreed with the signed-URL variant.
4. Only #179 and #180 plan hosted steps H1 to H4 were done (and H2 deploys). Not in this flow and not done: Netlify deploy, the gate migrations, #178 Step 10 (hosted `lesson-content.json` and `lesson_revisions` reconcile for the practice text). The hosted `.pptx` instructor decks are unchanged and still student-readable (they still contain answers until `202610050005` is applied); this is the pre-existing state.

## 1. Local verification (isolated stack `lizbeth_stagea`, shifted ports; other stacks untouched)

- Full chain, 48 migrations on a fresh database: vitest for #176, #177, #179, #180 and RLS suites, 57 files, 989 tests passed, 1 skipped.
- Rehearsal of the production sequence: gates (040006, 050004, 050005) moved aside; `supabase db reset` applied the other 45 migrations cleanly (so 040007 does not need 040006, and 050001 to 050003 do not need the gates; the 040004 and 050002 seeds apply without the gates). Old content uploaded, the hosted gate run against it (FAIL: 493 non-empty answers, 293 markers), then the re-provision tool (replace 156, all verified, 312 other objects untouched), rollback of the tool (restored 156) and re-apply. Then the gates were applied in order (040006, 050004, 050005) and their SQL suites passed (138 tests). The only no-gate test difference: one #180 SQL test calls `lesson_completion_blockers`, which exists only after 040006.
- Local edge-function suites (#176 dashboard, #179b owner review, #180c owner quiz) passed in the no-gate state.
- Evidence: `lizbeth-spanish-prod-stageB-local-vitest-summary.txt`.

## 2. Backups and rollback files

- Hosted data backup before any write (JSON + sha256 per table): `H:\CommandCenter\backups\StageB-20261006T162352Z-gvobtuhbpqvfhjljjcye\`.
- Byte backups of replaced storage objects (original bytes, sha256 manifests): `StageB-reprovision-20261006T162757Z` (all 156 originals), `StageB-reprovision2-20261006T163047Z` (155), `StageB-reprovision3-20261006T163426Z` (147). The first directory alone is the complete original set. Tool rollback: `reprovision-stripped.ts --rollback <dir>` (rehearsed locally).
- Rollback SQL in `supabase/rollbacks/`: present for 040003, 040005, 040006, 040007, 050001, 050003, 050004, 050005. No separate rollback exists for the two pure data seeds 040004 and 050002 (removing them is covered by dropping their tables in the 040003 and 050001 rollbacks). Not applied.

## 3. Hosted migrations (one transaction each, recorded in `schema_migrations`)

| Version | Verification |
|---|---|
| 202610040003 lesson tasks | RLS on for all four tables; answer keys and templates unreadable by anon and authenticated; student RPCs (`get_lesson_task`, `get_lesson_task_summaries`, `save_lesson_task_draft`, `submit_lesson_task`, `mark_lesson_task_feedback_seen`) executable by authenticated only; internal and owner functions service_role only |
| 202610040004 template seed | 78 templates, 78 keys; re-applied once after the encoding fix; hashes equal local |
| 202610040005 owner event attribution | applied; reset and set completion functions not executable by anon or authenticated |
| 202610040007 draft rate limit | applied without 040006; `save_lesson_task_draft` now contains the 750 ms limit; authenticated only |
| 202610050001 lesson quizzes | RLS on for `lesson_quiz_definitions`, `lesson_quiz_answer_keys`, `quiz_attempts`; key tables unreadable by anon and authenticated; student RPCs authenticated only; legacy `submit_quiz_attempt` not executable by anon or authenticated; owner RPCs service_role only |
| 202610050002 quiz definition seed | 78 definitions, 78 keys; hashes equal local |
| 202610050003 owner quiz authorization | applied |

Final state: 45 migrations recorded, latest `202610050003`. Not applied: `202610040006`, `202610050004`, `202610050005`.

## 4. Edge functions

`admin-student-operations` and `course-authoring` deployed (version 2, verify_jwt true as before), no `--linked`. Probes: no-JWT POST 401 for both (not 404); the four functions all respond. Owner dashboard-type reads no longer reference a missing relation: `lesson_task_submissions` and `quiz_attempts` exist and queries run (0 rows), the four owner RPCs (`review_lesson_task_submission`, `edit_lesson_task_review`, `get_lesson_quiz_attempt_for_owner`, `grade_lesson_quiz_attempt`) exist. No owner login was used, so the functions were not invoked as the owner.

## 5. Re-provision (hosted storage writes, 156 objects only)

78 `lesson-content.json` and 78 `weekly-review-recap.md` replaced with the seed bytes (LF, stripped), mapped Content-Type (`application/json`, `text/markdown; charset=utf-8`), original cache-control `max-age=3600`, byte backup first, hash-verified, abort on first mismatch, post-run check that all 156 equal the seed and the other 312 objects are unchanged (etag, type, cache-control). The 78 pptx, 78 pdf, 78 yaml and 78 flashcards.md objects were not touched (the pptx seed differs from production; see finding 4). Log: `lizbeth-spanish-prod-stageB-reprovision-log.txt`.

## 7. Cutover semantics of the held gate migrations (for the one user confirmation)

- `202610040006` (task gate) creates `completion_gate_settings` with `cutover_at = now()` at the moment it runs. `202610050004` adds `quiz_cutover_at = now()` the same way. Both stamp the instant of application.
- Existing completions with `completed_at` before the cutover are grandfathered: never cleared, no task or quiz required, practice only. Production today has 2 active enrollments (1 student), 52 entitlement rows (26 each), 1 completed entitlement and 1 progress row; that completed lesson stays complete. Every other lesson becomes gated: the student must mark it, the task must be reviewed by the owner, and the quiz must be passed (graded non-practice attempt, 80 percent) before it completes. The owner set and reset actions bypass the requirements (logged). Authored-course lessons are unaffected.
- The matching Netlify client already deployed (`aa99662`) renders the task form and quiz UI; no further deploy is required for the gate.
- Post-gate verification plan: `completion_gate_settings` has `cutover_at` and `quiz_cutover_at` set and the single row; function definitions match the migration files; audit rerun unchanged (a=0, d=0, f=0, g=0); completed entitlement count unchanged (1); leak check rerun; owner-side check that the task review inbox and quiz grading list load; one student-authenticated journey if the owner chooses. `202610050005` (decks owner-only) should follow the gate decision; it is a restriction (students lose access to the instructor decks), `supabase/rollbacks/issue180d_instructor_decks_owner_only_rollback.sql` exists.

## 8. Live smoke after Stage B

All 8 routes HTTP 200, `public_site_content` 200, 0 console errors, 0 page errors, 0 failed requests. Raw: `lizbeth-spanish-prod-stageB-smoke-after-assets/`.

## Files (this folder, each with a sha256 sidecar)

`lizbeth-spanish-prod-stageB-20261006.md`, `lizbeth-spanish-prod-stageB-gate-signed.txt`, `lizbeth-spanish-prod-stageB-reprovision-log.txt`, `lizbeth-spanish-prod-stageB-local-vitest-summary.txt`, `lizbeth-spanish-prod-stageB-smoke-after-assets/`.

## Next steps

1. Decide the gate rule (above), then apply `202610050005`.
2. One confirmation for `202610040006` and `202610050004`.
3. #178 Step 10 reconcile (hosted `lesson-content.json` and `lesson_revisions` for the practice text) is the next separate step; the hosted `lesson-content.json` now carries the repo's current (post-#178) seed content.
4. Owner spot-check of at least 5 recaps (#175 viewer) is now possible: `get_owner_resource_text` is live in `course-authoring`.

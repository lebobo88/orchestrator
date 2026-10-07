# Lizbeth Spanish production Stage C and consolidated rollout receipt, 2026-10-06

Project `gvobtuhbpqvfhjljjcye`. Source `origin/main` `8e89737`. No `--linked`. No secrets in this file. No Netlify action. Nothing committed, no issue closed. Earlier receipts: `lizbeth-spanish-issue173-phase-p-apply-20261006.md`, `lizbeth-spanish-prod-stageA-20261006.md`, `lizbeth-spanish-prod-stageB-20261006.md`.

## Stage C result

| Step | Status |
|---|---|
| Leak gate accepted definition recorded (deviation) | Recorded below |
| 202610050005 instructor decks owner-only | Applied, verified |
| 202610040006 task completion gate | Applied, verified |
| 202610050004 quiz completion gate | Applied, verified |
| Post-gate verification plan | All items PASS |
| #178 Step 10 reconcile | Verified; no further hosted write needed (see below) |
| Final live smoke | PASS |

## Deviation recorded: leak gate definition (user decision)

The Stage B hard gate (`check-no-answer-leak.ts --hosted`) exits 1 because its strict fingerprint rule hits 627 times on phrases that the lessons legitimately teach. The user accepted the gate as: hosted bytes equal the clean seed, 0 non-empty quiz answers, 0 recap answer markers. Result, re-run after the gates (read through freshly signed URLs): 156 of 156 artifacts equal the seed, 0 non-empty quiz answers, 0 recap markers, nothing missing, and the 627 fingerprint hits are identical to the clean seed's own 627. Evidence: `lizbeth-spanish-prod-stageC-gate-signed-post.txt`.

## Migrations applied in this stage (each in its own transaction, recorded in `schema_migrations`)

| Version | Applied | Verification |
|---|---|---|
| 202610050005_issue180d_instructor_decks_owner_only | first | `students_read_unlocked_resources` now requires `resource_type <> 'pptx'`; the storage policy `students_read_unlocked_lesson_assets` requires `r.resource_type <> 'pptx'`; new `owner_read_instructor_decks` (resources) and `owner_read_instructor_deck_objects` (storage) allow only the owner role and only pptx. Read-only policy check; no logins or impersonation |
| 202610040006_issue179c_completion_gate | second | `completion_gate_settings` single row, `cutover_at` = 2026-10-06 17:14:56 UTC; readable by service_role only |
| 202610050004_issue180d_quiz_completion_gate | third | same row, `quiz_cutover_at` = 2026-10-06 17:14:58 UTC (not null) |

All 48 repo migrations are now applied in hosted (latest `202610050005`).

## Post-gate verification

- Cutover timestamps: both set, one row; anon and authenticated have no access.
- Function definitions: all 94 public functions in hosted compared with the local database that ran the identical migration chain (definitions normalised for whitespace): 94 vs 94, 0 differences. (An unnormalised comparison differed on 39 older functions only because of line-ending and whitespace differences from how they were originally applied.)
- Audit unchanged after the gates: (a) 0, (b) 0, (c) 2 enrollments x 26 entitlement rows, (d.1) 0, (d.2) 0, (d.3) 0, (e) would_set 0 and would_clear 0, (f) 0, (g) 0.
- Completed entitlements still 1 of 52; completed progress rows still 1; no completion was changed by the gate (grandfathered).
- Owner task inbox and quiz grading (read-only): `lesson_task_submissions` and `quiz_attempts` queries run (0 submitted, 0 pending review, since no student has submitted); owner RPCs exist and are service_role only.
- Student decks: students cannot read pptx rows or objects by policy (above); owners can.
- Evidence: `lizbeth-spanish-prod-stageC-data-20261006.json`.

## #178 Step 10 (hosted reconciliation)

- Hosted `lesson-content.json`: already re-provisioned in Stage B (78 of 78 equal the seed). The old classroom text is replaced by the self-paced practice text (example: beginner week 1 `practice.summary` changed from the "structured mingle/role-play" text to "Visit a virtual Introductions Market on your own, in about 20 minutes"; all 78 seed weeks carry `practice.title`).
- Hosted `lesson_revisions`: 78 legacy revisions, 0 authored; `content` holds only `legacy_lesson_id` and `legacy_assets` (max 654 characters), no lesson text, so there is nothing to reconcile.
- Owner authoring: `course-authoring get_version` hydrates lesson text from `course_assets` of type `lesson_content`. All 78 of those assets point at the `lesson-content.json` objects and all 78 objects exist, so owner authoring now reads the new text. Caveat: that function uses the cached download path, so for up to about one hour after an object was replaced (max-age 3600) an owner view could still show the old text; it then corrects itself.
- `course_versions`: 3 published versions, all legacy-mapped; no republish or new revision is needed because the text comes from storage at read time. No hosted write was needed for this step.

## Final live smoke

All 8 routes HTTP 200, `public_site_content` 200, 0 console errors, 0 page errors, 0 failed requests. Raw: `lizbeth-spanish-prod-stageC-smoke-after-assets/`.

## Consolidated production state (end of day)

| Area | State |
|---|---|
| #173 content types | 468 of 468 mapped Content-Types, check PASS (Phase P); tooling PR #219 merged |
| #176 completion record | Applied; band enrollments have `course_version_id` and 52 entitlements; audit a/d/f/g = 0 |
| #177 site text and owner settings | Applied; `site-content` and `owner-settings` deployed; `site_content` empty (defaults) |
| #174 handouts, #175 recap viewer | Applied; `course-authoring` v2 with `sign_student_course_asset`, `get_owner_resource_text`; handout coverage 78 of 78 PASS with `application/pdf` |
| #178 practice text | Hosted lesson content is the new self-paced text |
| #179 task form | Tables, 78 templates and keys, owner review, gate on (cutover 17:14:56 UTC) |
| #180 quizzes | 78 definitions and keys, owner grading, gate on (cutover 17:14:58 UTC), decks owner-only, legacy submit revoked |
| Edge functions | `owner-settings` v2, `site-content` v1, `admin-student-operations` v2, `course-authoring` v2, all verify_jwt true |
| Netlify | Live client is `aa99662` (published); `8e89737` build unpublished and unchanged client code; no Netlify action taken |

## What remains (one page)

1. Owner spot-check (Lizbeth Spanish): open at least 5 weekly recaps in the in-app vocabulary review (3 bands) and confirm they read correctly and contain no answer text. Also open the Course Workspace for a legacy course and confirm the practice text appears (allow up to 1 hour for the cache noted above). I did not use any login.
2. One student-authenticated end-to-end pass by the owner or the user (not done here; no logins were allowed): sign in as a test student, open a week, complete the task form and a quiz, and confirm the mark-then-review-then-quiz completion flow, and that a pptx deck link is no longer offered. The first real student journey is the main untested path in production, because no student had submitted anything.
3. Instructor decks: the pptx objects in storage are the older versions (the repo seed has newer decks). They are now owner-only, so there is no exposure, but the owner may want the newer decks uploaded; this is a separate, optional content refresh.
4. Backups to retain until the user confirms: `H:\CommandCenter\backups\` Phase P directories `G173-*`, `StageA-*`, `StageB-*`, `StageB-reprovision-*`, `StageB-reprovision2-*`, `StageB-reprovision3-*`. The StageB-reprovision-20261006T162757Z directory is the complete set of original bytes of the 156 replaced objects.
5. Housekeeping: the tool used for the content replacement (`reprovision-stripped.ts`) and the SQL transport scripts live in scratch only, not in the repo. The `fix/173-hosted-info-stale` branch and worktree `lizbeth_spanish-173b` remain. The local scratch stack `lizbeth_stagea` is stopped (volumes kept).
6. Observations for follow-up issues (not blocking): (a) `recalculate_progress_completion` is executable by anon (pre-existing); (b) the hosted leak check's fingerprint rule needs a dictionary or co-location relaxation like the dist scan has, or it will keep failing on clean content; (c) `check-no-answer-leak.ts --hosted` and `course-authoring get_version` read through the cached download path; (d) the `verify-signed-url-content-types.ts` Content-Length assertion fails for compressible types on hosted (known); (e) the Management API plus PowerShell migration transport corrupted non-ASCII text on one migration until byte transport was used; any future hosted migration with Spanish text should be compared by hash against a local run.

## Issue comment and closure readiness (no issues were touched)

| Issue | Production state | Ready to comment and close? |
|---|---|---|
| #173 storage Content-Type | Done and verified (468 of 468, tooling merged) | Yes |
| #174 handout links | Backend and function live, coverage PASS | After owner/student check of the handout link (item 2) |
| #175 recap review in app | Backend live | After the owner recap spot-check (item 1) |
| #176 completion foundations | Applied, audit clean | Yes (post-apply audit evidence is in the Stage A and C receipts) |
| #177 owner-editable site text | Applied and functions deployed; no keys set | After one owner save of a site text key and reset (not done here; I created no keys) |
| #178 self-paced practice | Hosted content reconciled | Yes, after the owner views the Workspace practice text |
| #179 task form | Live with gate on | After the student-authenticated pass (item 2) |
| #180 quizzes | Live with gate on, decks owner-only | After the student-authenticated pass (item 2) |
| Epic #172 | All child pieces deployed to production | After the rows above |

## Files (this folder, each with a sha256 sidecar)

`lizbeth-spanish-prod-stageC-20261006.md`, `lizbeth-spanish-prod-stageC-data-20261006.json`, `lizbeth-spanish-prod-stageC-gate-signed-post.txt`, `lizbeth-spanish-prod-stageC-smoke-after-assets/`.

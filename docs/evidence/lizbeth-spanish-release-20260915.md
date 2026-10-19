# Lizbeth Spanish — Release status handoff (2026-09-15)

This is a compact documentation handoff for the root orchestrator. It records scoped evidence only; it is not a publish authorization or an all-gates-green declaration.

## Local implementation and verification

- Course management is implemented locally: `/admin/course-settings` supports owner-gated archive/unarchive and archived-course disclosure. Earlier WP-C evidence covers the create/archive/unarchive journey.
- #166 is locally verified within scope: local Chromium 4/4 in 28.7 seconds, one worker; two fixture restores HTTP 200; sign-in probe HTTP 200; 14 fresh screenshots in `browser-validation-artifacts/status-clarity-gate`. Required AGY review: `gemini-3.8-flash-medium`, `PASS`, conversation `d4e4feaf-e3c8-468d-b345-cc3d14f522f9`. GitHub issue remains open.
- #170's repaired course-workspace coverage is included in the fresh repaired E2E result of 27/27; the repeat affected set is 12/12 and focused #49 coverage is 8/8. The spec creates isolated owner-scoped staged/published courses, lessons, and a UUID-suffixed cohort, then archives only created courses. Final runtime Gemini review and hosted authenticated smoke remain pending; the issue remains open.
- Fresh full Vitest: **254 file results, 3,142/3,142 tests passed**. RLS is 36/36. Type-check exits 0; scoped ESLint is 0 errors with 813 warnings (no provenance claim is made for the warnings). The original browser evidence remains authoritative: repaired E2E 27/27, repeat affected set 12/12, focused #49 8/8, and #166 Chromium 4/4. No rerun is required for this documentation-only step.

## Production target and publish state

- User-selected production Supabase target: `gvobtuhbpqvfhjljjcye`.
- User confirmed Netlify Supabase environment variables were updated. No secret values are recorded or overwritten by this documentation work.
- Netlify site: `36497726-71dd-42f6-a84e-834353a92cba` / `lizbeth-spanish.netlify.app`.
- Current published deploy: `6a91c5a16bd89d0008ba7b80`, ready/locked; treat it as the frontend rollback baseline, not a known-good new candidate. Existing reachability is HTTP-only evidence.
- Fresh backend-first deployment is complete only as `DEPLOYED_WITH_LIMITS` on `gvobtuhbpqvfhjljjcye`: `course-authoring`, `admin-student-operations`, and `owner-settings` are ACTIVE v1 with `verify_jwt=true`; see the backend readiness receipt for immutable function IDs/hashes and limits. The exact owner assignment for `thereallizbeth@gmail.com` is complete per the [owner-assignment audit receipt](lizbeth-spanish-owner-assignment-20260915.md). As of this 2026-09-15 handoff, the target still needed the existing legacy projection backfill; the dated 2026-09-16 addendum below records its bounded completion.
- Both additive hosted security migrations are applied and verified. The child-repository receipts are [hosted security](../../lizbeth_spanish/docs/evidence/lizbeth-spanish-hosted-security-20260915.md) and [local security](../../lizbeth_spanish/docs/evidence/lizbeth-spanish-release-security-20260915.md).
- The local Netlify CLI is available at `node_modules/netlify-cli` v17.38.1 with native auth; only global PATH/linking is absent. Read-only API evidence confirmed site `36497726-71dd-42f6-a84e-834353a92cba`, current deploy state `ready`, `locked=true`, production commit `4c6a8919...`, and `dist` publish directory. The API response omitted `stop_builds`; the user-provided current control remains `stop_builds=true`.
- Fresh target build, unpublished alias candidate upload, anonymous candidate/deep-route smoke, unchanged-live rollback check, authenticated smoke, and final release review remain gates. Publish hold remains active. The selected archive policy disables anonymous preview when archived and retains enrolled-student access; local lifecycle proof passed, while no hosted archived-course fixture existed for an archived-specific endpoint probe. As of this 2026-09-15 handoff, the one-time backfill remained unrun and awaited explicit user approval after fresh backup and judge gates; the dated 2026-09-16 addendum below supersedes that state.

At the time of this earlier documentation update, no hosted mutation, Git stage/commit/push, PR action, or issue closure had been performed.

## Packaging handoff — 2026-09-15

- Fresh packaging state: branch `release/fjds-course-management-20260915`, starting HEAD `220ceb2596cdfbfda921d80d57f008e0c2038348`; the seven-file child-repository release set was explicitly staged and committed. The 78 storage-seed YAML edits and `vitest-full-report-fixture-repair.json` remain excluded and unstaged; no credential, environment, or raw-auth file is in the intended set.
- Candidate build/upload is explicitly held pending explicit user approval for the one-time course backfill and the remaining candidate/release gates. This packaging step performs no candidate build or upload, production publish, merge, hosted environment/configuration change, backfill, or issue closure.
- The child-repository release receipt records the current validation counts, both security receipts, exact owner email, hosted limits, and preserved unrelated work: [child release evidence](../../lizbeth_spanish/docs/evidence/lizbeth-spanish-release-20260915.md). Final exact-model diff review: AGY terminal `SUCCESS`, exact model `gemini-3.8-flash-medium`, verdict `APPROVE`, conversation `ce3246d4-f99e-4935-aedf-87a9c591b9e8`; the judge authorized this unmerged draft-PR packaging only.

## Packaging result — 2026-09-15

- Local commit: `7395951` (`chore(release): refresh security and release handoff`), containing the reviewed seven-file child-repository set only; the final amended change corrected one outside-child evidence link.
- Remote branch: `release/fjds-course-management-20260915` pushed to `lebobo88/lizbeth-spanish`.
- Draft PR: https://github.com/lebobo88/lizbeth-spanish/pull/171, base `main`; it is review-only and must not be merged by this step.
- No candidate build/upload, merge, production publish, hosted environment/configuration change, course backfill, or issue closure occurred. Candidate exposure remains held pending explicit user approval for the one-time backfill and the remaining authenticated/candidate/deep-route/anonymous smoke, rollback verification, and final release gates. Owner assignment is complete; it is not an open gate.

## Dated addendum — 2026-09-16

The earlier 2026-09-15 packaging and hold records are historical. The approved
one-time backfill on production target `gvobtuhbpqvfhjljjcye` completed exactly
once after target, owner, ACL, and backup checks. Its bounded postcheck recorded
3 courses owned by `thereallizbeth@gmail.com`, 3 published v1 versions, 78
revisions, 78 version links, and 390 exact mapped assets. Legacy 3 bands, 78
lessons, 390 resources, and 468 `lesson-assets` storage objects were unchanged;
no extra users or enrollments were created. Receipt:
`H:\CommandCenter\orchestrator\docs\evidence\lizbeth-spanish-course-backfill-20260916.md`.

The backfill's `is_current=0` result is expected for provisioned published v1
rows. Independent production catalog/learn/enrollment/owner-workspace review
confirmed readers use `status=published` and highest `version_no`, not
`is_current`; do not describe these as three current versions. Preview rows and
`is_preview=0` remain expected because the backfill does not set the preview
flag. No corrective SQL was authorized or executed. Assets remain
`unverified_legacy` with null SHA; storage contents were not hash-verified by
the backfill. No restore drill or full auth-backup-coverage claim is made.

The current post-backfill hold is not approval. The targeted chunk-aware
verifier fix and native regression tests now pass the scoped guard, type-check,
and lint checks. No artifact upload, frontend publication, merge, environment
change, or issue closure has occurred. Netlify site
`36497726-71dd-42f6-a84e-834353a92cba` remains locked on deploy
`6a91c5a16bd89d0008ba7b80`, with `stop_builds=true`. Operator authentication,
hosted authenticated owner/student QA, and final release review remain
outstanding. The 3,142/3,142 full-test result predates the verifier fix and no
new full rerun was performed.

## Candidate packaging handoff — 2026-09-16

The intended follow-up child commit was limited to six files: the updated
`README.md`, updated child release receipt, the verifier JS and declaration,
its native regression fixtures, and the static TypeScript contract test. The
78 storage-seed YAML changes and `vitest-full-report-fixture-repair.json` remain
outside scope and unstaged. Required AGY review of the staged manifest/diff,
current scoped test results, and candidate plan returned terminal `SUCCESS`,
exact model `gemini-3.8-flash-medium`, and `APPROVED`; the follow-up commit was
pushed to the existing draft PR #171. Only the verified `dist` artifact was
then uploaded as an unpublished Netlify alias candidate; production deploy,
settings, environment variables, and backend data remained out of scope.

The unpublished candidate handoff is now complete under the bounded receipt
[`lizbeth-spanish-candidate-20260916.md`](lizbeth-spanish-candidate-20260916.md):
READY deploy `6aaa9a540d612bf3163361c6` is isolated at the candidate alias,
all 11 served files matched the local manifest, anonymous smoke passed, and
the production published deploy remained unchanged. Authenticated
owner/student QA and any promotion remain operator-controlled gates.

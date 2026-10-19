# Lizbeth Spanish — production release receipt — 2026-09-17

This receipt records the bounded publication of the verified candidate. It is
not a claim of 100% verification or an absolute operational guarantee.

## Authorization and review gates

- User authorization: publish the build after the user-confirmed owner/student
  content and access QA. No temporary test users were needed or created.
- Repository: branch `release/fjds-course-management-20260915`, exact HEAD
  `b1e85e260163b0b69e5c09e67fe87725a6489f8c`. PR #171 remains open/draft and
  was not merged; no source push occurred.
- Pre-publication AGY review: terminal `SUCCESS`, exact model
  `gemini-3.8-flash-medium`, verdict `APPROVE`, conversation
  `2681f1cd-3eea-4ca4-8d7e-27786fa4134a`. The review approved native restore
  of the immutable candidate, preservation of `stop_builds=true`, and
  post-restore lock/rollback checks.
- Post-publication AGY review: terminal `SUCCESS`, exact model
  `gemini-3.8-flash-medium`, verdict `APPROVE`, conversation
  `1459a91f-522e-46f1-9405-3098c93b8839`. Its sanitized conclusion was that
  the exact candidate is acceptably published and protected within the
  disclosed limitations.

## Exact publication action

- Netlify site: `lizbeth-spanish`, site ID
  `36497726-71dd-42f6-a84e-834353a92cba`.
- Candidate: deploy `6aaa9a540d612bf3163361c6`, ready branch-deploy alias
  `candidate-20260916-093156`, immutable URL
  `https://6aaa9a540d612bf3163361c6--lizbeth-spanish.netlify.app`.
- Fresh preflight confirmed the site still pointed to rollback baseline
  `6a91c5a16bd89d0008ba7b80`, with `locked=true`, `stop_builds=true`, and the
  candidate ready. The three production Supabase environment keys were
  present; their values were kept in memory and were not recorded.
- Native Netlify API operation `restoreSiteDeploy` promoted the exact
  candidate. It returned deploy ID `6aaa9a540d612bf3163361c6`, state `ready`,
  `published_at=2026-09-18T00:14:36.022Z`, and `locked=true`.
- No unlock was required. No `unlockDeploy`, `lockDeploy`, build, upload,
  `--trigger`, environment/configuration change, backend write, user or
  enrollment change, seed/reset, backfill rerun, impersonation, or login-link
  mint occurred. `stop_builds=true` remained unchanged.
- Netlify reports the resulting published deploy context as
  `branch-deploy`; the production site pointer and production URL are
  nevertheless the live published target. This context was preserved from
  the candidate and was not rewritten.

## Post-publication verification

- Live published deploy: `6aaa9a540d612bf3163361c6`, `ready`, `locked=true`.
- Site build protection: `stop_builds=true`.
- All 11 production-served files returned HTTP 200 and matched local `dist`
  byte-for-byte: 6,098,485 bytes, 0 mismatches, and 0 fetch failures.
- `index.html` SHA-256:
  `b3172eee57db30f1a2be439eb8771f20ceb2c58e4d1204cf866ac57aa946b3a3`.
  The verified candidate manifest was 11 files with recorded canonical
  digest `c2ae939aac26581fa13a023c5d181cd6989978fc669b217b61057c4122c37a0d0`.
- Served JavaScript exposed only
  `https://gvobtuhbpqvfhjljjcye.supabase.co`; the old project
  `udrlwexyzaqaqxdxdsml` was absent. Local service-role and 78-week
  lesson-content guards passed, and the production bytes equal that verified
  artifact.
- Read-only anonymous Chromium QA passed 9/9 route loads with HTTP 200,
  classified console errors 0, failed requests 0, and HTTP error responses 0.
  `/courses` rendered exactly 3 catalog cards. Catalog-derived preview
  routes rendered the safe unavailable state with 0 lesson-content DOM nodes
  and 0 `lesson-assets` requests. Protected `/roadmap`, `/learn`,
  `/feedback`, `/admin`, and the deep roadmap path showed the sign-in gate.
  No mutation controls were used.

## Operator attestation and limits

The user attested that the owner workspace, created student/login/assigned
course/visibility, lesson/resources, and unassigned-access QA are good. This
is recorded as operator attestation, not automated authenticated or
impersonated QA.

The production backend is Supabase project `cultural-spanish`, ref
`gvobtuhbpqvfhjljjcye`; the one-time backfill already ran exactly once and was
not repeated. The 78 dirty storage-seed YAML files, untracked
`vitest-full-report-fixture-repair.json`, backups, and test results were
preserved. The prior mock error remains of unknown exact cause. Preview rows
remain absent/`is_preview=0` as documented; this release does not claim
preview-lesson configuration. Storage-object byte hashing, a restore drill,
and Netlify CI install-stage proof were not performed.

## Rollback

If a material live verification failure appears, restore the validated baseline
using the native API operation below with the existing authenticated Netlify
CLI session; do not run a build or change environment variables:

```text
node node_modules/netlify-cli/bin/run.js api restoreSiteDeploy --data {"site_id":"36497726-71dd-42f6-a84e-834353a92cba","deploy_id":"6a91c5a16bd89d0008ba7b80"}
```

Then verify the site points to `6a91c5a16bd89d0008ba7b80`, is `ready`, retain
`stop_builds=true`, and ensure the resulting published deploy is locked. Record
the failure and rollback outcome in a follow-up receipt.

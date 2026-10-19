# Lizbeth Spanish — unpublished candidate receipt (2026-09-16)

This receipt records bounded candidate evidence only. It is not publication,
merge, authenticated-QA, or all-gates-green authorization.

## Git and review

- Branch: `release/fjds-course-management-20260915`; follow-up commit
  `b1e85e260163b0b69e5c09e67fe87725a6489f8c` was pushed only to that branch;
  remote HEAD matched.
- Existing PR [#171](https://github.com/lebobo88/lizbeth-spanish/pull/171)
  remains OPEN/DRAFT against `main`.
- The commit contains exactly six reviewed files: `README.md`, the child
  release receipt, the verifier JS/declaration, its native JS fixtures, and
  the static TypeScript contract test. The 78 storage-seed YAML changes and
  `vitest-full-report-fixture-repair.json` remain unstaged and uncommitted.
- Pre-commit AGY review: terminal `SUCCESS`, model
  `gemini-3.8-flash-medium`, verdict `APPROVED`, conversation
  `ff790560-6560-45fa-aa32-d70079f20b9b`.

## Static artifact and candidate

- Production-target `CONTEXT=production` verifier passed against
  `gvobtuhbpqvfhjljjcye` and inspected 5 reachable JS assets. Source/dist
  service-role leak guards passed; lesson-content fingerprint scan was 0/78;
  native regression tests were 6/6; type-check passed; scoped ESLint had 0
  errors and 813 warnings.
- Recursive pre-upload SHA-256 manifest: 11 files, 6,098,485 bytes; canonical
  manifest digest
  `c2ae939aac26581fa13a023c5d181cd6989978fc669b217b61057c4122c37a0d`;
  `dist/index.html` SHA-256
  `b3172eee57db30f1a2be439eb8771f20ceb2c58e4d1204cf866ac57aa946b3a3`.
  The local post-upload manifest was identical, and all 11 candidate-served
  files matched with 0 mismatches.
- Unpublished Netlify candidate: deploy `6aaa9a540d612bf3163361c6`, state
  `ready`, branch-deploy context; alias
  `https://candidate-20260916-093156--lizbeth-spanish.netlify.app`; permalink
  `https://6aaa9a540d612bf3163361c6--lizbeth-spanish.netlify.app`.
  Upload used the exact site with `--dir dist` and `--alias`, omitting
  `--prod`, `--build`, and `--trigger`.

## Read-only anonymous smoke

Fresh Playwright Chromium direct loads passed for `/`, `/login`, `/courses`,
catalog-derived public preview
`/courses/137dd7fb-4ad6-4e64-8717-5d5d353b2f5d`, `/roadmap`, `/learn`,
`/feedback`, `/admin`, and the route-contract deep path
`/roadmap/137dd7fb-4ad6-4e64-8717-5d5d353b2f5d/week/1`:

- 9/9 HTTP 200 and SPA-renderable;
- `/courses` showed exactly 3 catalog cards;
- preview metadata rendered, with 0 lesson-content DOM nodes and 0
  `lesson-assets` requests, consistent with intentional preview-less state;
- anonymous protected routes showed login/auth gating; no enrollment, auth,
  owner, or admin action was clicked and 0 mutation payloads were observed;
- no service-role/private-credential/old-project leak was found; only
  `gvobtuhbpqvfhjljjcye.supabase.co` was observed and the old project was not;
- classified console errors, failed requests, and HTTP error responses were
  all empty.

## Production immutability and final review

Fresh read-only metadata after upload still showed site
`36497726-71dd-42f6-a84e-834353a92cba`, published deploy
`6a91c5a16bd89d0008ba7b80`, `state=ready`, `locked=true`, production context,
and `build_settings.stop_builds=true`.

Final AGY review: terminal `SUCCESS`, model `gemini-3.8-flash-medium`, bounded
verdict `PASS (CONDITIONAL / CANDIDATE STAGE VERIFIED)`, conversation
`9bf48866-fdec-45e9-8b39-68fad4093341`.

Limits: the 3,142/3,142 full Vitest result predates the verifier fix; no
authenticated owner/student QA, operator authentication, preview-lesson
configuration decision, Netlify CI secret/install-stage proof, storage-byte
verification, restore proof, or absolute operational guarantee is claimed.
The preserved unstaged workspace changes remain user work and are not resolved
by this candidate handoff. No production publish, merge, settings or
environment change, backend mutation, identity/enrollment change, seed/reset,
backfill rerun, impersonation, or login-link minting occurred.

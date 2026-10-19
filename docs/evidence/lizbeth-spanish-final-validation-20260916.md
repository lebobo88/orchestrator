# Lizbeth Spanish — final local validation receipt (2026-09-16)

This receipt records the bounded LunaHigh local validation for repository HEAD
`b1e85e260163b0b69e5c09e67fe87725a6489f8c`. It is not publication, merge, or
production-mutation authorization.

## Harness and scope

- Local Supabase only: API `127.0.0.1:54321`; database `127.0.0.1:54322`.
- `VITE_SUPABASE_URL`, the local anon key, and the local service-role key were
  injected in memory for the test process; no credentials are recorded here.
- Configuration inspection confirmed the local URL/ports, and the preserved
  stdout/stderr scan found no hosted Supabase URL token.
- No hosted writes, users, enrollments, backfill, flags, deploy, merge, or
  push occurred. The existing backfill for
  `newprodgvobtuhbpqvfhjljjcye` was not rerun.

## Single full-suite run

Command:

```text
npx vitest run --reporter=verbose --reporter=json --outputFile=test-results/lizbeth-spanish-full-validation-20260916-123731086-a74913f68dc04ae3bf73e1bc9801c213.json
```

Result: process exit `0`; `257/257` test files passed; `3,148/3,148`
tests passed; failed `0`; skipped `0`; todo `0`.

New collision-checked local evidence artifacts (no existing report was
overwritten):

- `lizbeth_spanish/test-results/lizbeth-spanish-full-validation-20260916-123731086-a74913f68dc04ae3bf73e1bc9801c213.json`
- matching `.stdout.log` and `.stderr.log` files in the same directory;
  JSON size `1,415,108` bytes, stdout `711,367` bytes, stderr `27,966`
  bytes.

The earlier isolated `LessonContentView` run was `21/21` passed. The prior
`20/21` report with `mocks.forEach is not a function` remains of unknown exact
cause; this run does not classify it as transient or as an application
regression. The historical `3,142/3,142` result predates the latest verifier
fix and is not used as the current full-suite result.

## Protected workspace and limits

The 78 dirty storage-seed YAML files and existing untracked
`vitest-full-report-fixture-repair.json` were preserved. No application code or
other documentation was modified by this validation. Candidate anonymous
browser evidence remains `9/9` passed and awaits user decision; it is not
authenticated owner/student QA.

This is local automated unit/integration evidence only. It does not prove
hosted deployment behavior, authenticated owner/student QA, operator
authentication, preview-lesson configuration, Netlify CI secret/install-stage
proof, storage-byte verification, restore proof, or production immutability
beyond previously recorded evidence.

## AGY cross-review

- Terminal status: `SUCCESS`
- Model: `gemini-3.8-flash-medium`
- Verdict: `LOCAL_VALIDATION_PASSED`
- Conversation ID: `1a0d9e3e-7eb9-45d2-bc41-da3d8e0d8c44`
- AGY conclusion: the exact prior failure cause remains unknown; hold merge and
  deployment actions and present the evidence for user review and the required
  authenticated staging/production QA gates.

## Next step

Hold merge, publication, and production mutations. Present this receipt and the
preserved local artifacts for user review, then obtain the separately required
authenticated QA and release decision.

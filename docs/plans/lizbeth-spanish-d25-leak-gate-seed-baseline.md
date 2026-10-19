# Plan: Lizbeth Spanish D-25 Quiz-Answer Leak Gate With Reviewed Seed Baseline

Status: **DRAFT (2026-10-19).** Owner decision D-25 is approved (option B). The rest of this PR design has not been approved. The user must explicitly approve this plan before any engineering writer (T1) starts.

Plan id: `lizbeth-spanish-d25-leak-gate-seed-baseline`
Task id: `lizbeth-d25-leak-gate-seed-baseline`
Route: engineering, standard mode. Downstream owner: engineering-fleet (T1 after explicit user approval; Verifier required).

## 1. Decisions and approvals

| Item | State | Record |
| --- | --- | --- |
| D-25 option B | **APPROVED** by the user, 2026-10-18 | Verbatim: "d-25: option b fix the check as needed." |
| Rest of the PR design (this plan) | **Awaiting explicit user approval** | No engineering writer starts until the user approves. |
| (a) Baseline storage | Recommended: committed fixture. Alternative: computed at check time. | Section 5. |
| (b) Disposition of initial entries that fail the taught-phrase test, and the #214 item-1 text | Recommended: `known-defect` with issue ref. Alternative: block until content is fixed. | Section 5. |
| (c) Add the seed fingerprint check to `verify:build` (the Netlify deploy gate) | Recommended: yes. Alternative: `check:answer-leak` only. | Section 6, step 3. |
| (d) Hosted read path through signed URLs | Recommended: yes. | Section 7. |
| (e) PR reference style | Recommended: `Refs #180`, `Refs #214`, `Refs #215`, and "Resolves owner decision D-25" in the body. Alternative: open a tracking issue so the PR can say `Closes #<new>`. | Section 9. The alternative is a GitHub write and needs user approval. |
| (f) One read-only hosted confirmation run before Wave 7 | Recommended, not required for merge. | Section 7. |

## 2. Outcome and audience

Outcome: one small PR that changes the hosted quiz-answer leak gate, and adds the same rule to the local seed check, so that clean content passes and real leaks still fail.

Audience: the owner approving Wave 7, and the T1 implementer.

## 3. Scope

In scope:

- `scripts/lib/quizLeakGuard.ts`
- `scripts/check-no-answer-leak.ts`
- One new committed baseline fixture and its generator script with `--check`
- Tests
- A short rule note next to `docs/evidence/issue-180/dist-leak-scan-rule.md`

Non-goals:

- No hosted write of any kind (production is LIVE).
- No migration.
- No content change to curriculum, content-source, quiz JSON, or storage-seed.
- No change to the dist scan rule (the dictionary/co-location relaxation stays as is).
- No Wave 7 content work.
- No Netlify deploy action.
- No issue creation or closing without approval.
- No commit, push, or PR without the user's explicit request.

## 4. Evidence and findings

Target: `lebobo88/lizbeth-spanish` (private). Implementation must start from a fresh worktree of current `origin/main` (e21afa9 or later). The read-only reference checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013` is detached at an older main. The local mirror used for planning evidence is `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run`. `node_modules` in the reference checkout is a junction: never recurse-delete through it.

Findings are Observed in the mirror unless marked. Step 0 re-confirms them on `origin/main`. Research evidence: none (local evidence was sufficient).

### 4.1 Gate inventory

- `npm run verify:build` (package.json:19) runs build, `check-no-service-role-leak.js`, `verify-build-config.js`, `check-no-lesson-content-leak.js`, and `npx tsx scripts/check-no-answer-leak.ts`. `netlify.toml:2` runs `npm run verify:build` as the Netlify build command, so this is the deploy gate. No `.github/workflows` directory exists in the mirror or the reference checkout, so "CI" here means the Netlify build plus local runs (Step 0 confirms on `origin/main`).
- `npm run check:answer-leak` (package.json:23) runs `check-no-answer-leak.ts --no-dist`.
- Local (non-hosted) mode of `check-no-answer-leak.ts` checks the storage seed (`supabase/storage-seed/lesson-assets`):
  - 78 `lesson-content.json` expected.
  - `answerLeakGuard` markers, owner-only task answer text, and unmarked arrow patterns.
  - Quiz answers and recap markers are ENFORCING (`ENFORCE_QUIZ_AND_RECAP_ANSWERS = true`, line 30).
  - It scans `dist/` with quiz-key fingerprints using the bundled-dictionary/co-location relaxation (`scanDistForQuizKeys` with `loadBundledDictionaryWords`).
  - It does NOT run any quiz fingerprint scan against the seed `lesson-content.json` or recap files.
  - This mode passes today and is not the source of the 627 hits.
- Hosted mode (`check-no-answer-leak.ts --hosted --url https://gvobtuhbpqvfhjljjcye.supabase.co`, with `SUPABASE_SERVICE_ROLE_KEY` in env; `runHosted`, lines 37-55) is the hand-run hard gate used at Stage B/C after re-provision.
  - It downloads 78 `lesson-content.json` and 78 `weekly-review-recap.md` through storage `download()` (`runHostedReadOnlyScan`, `quizLeakGuard.ts:256-295`).
  - It builds fingerprints as `collectQuizKeyFingerprints(authored quiz JSON: explanation, reference, accepted variants)` plus `collectCurriculumAnswerFingerprints(curriculum quiz answers + recap answers)`.
  - It scans each file with `scanTextForFingerprints` WITHOUT a dictionary (strict).
  - It exits 1 if missing > 0, either count != 78, `nonEmptyQuizAnswers` > 0, `recapAnswerMarkers` > 0, or `fingerprintHits.length` > 0.
- The lesson-content fingerprint scan for #179 (`answerLeakGuard.ts`) and `check-no-lesson-content-leak.js` are separate and unchanged.
- Wave 7 scripts: none exist yet. Wave 7 is a plan section (`docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md`, lines ~780-782). The re-provision tool used at Stage B (`reprovision-stripped.ts`) lives in scratch, not the repo (stage C evidence, line 72).

### 4.2 Root cause (Observed)

Sources: `docs/evidence/lizbeth-spanish-prod-stageB-20261006.md` lines 14-27; stage C lines 17-19; the gate-signed `.txt` files.

The hosted rule treats any normalized occurrence of a quiz answer/key fingerprint (>= 12 chars) in lesson text as a leak. Lessons legitimately teach those phrases ("cómo te llamas", "buenas noches", "cincuenta y dos"). Scanning the clean seed itself gives 627 hits, identical hit-for-hit to hosted, while the seed has 0 quiz answers and 0 recap markers. So clean content can never pass.

The unit tests use synthetic fixtures and never ran the strict scan over the real seed. The old Phase P content showed 493 quiz answers and 293 recap markers, so the structural checks do catch real answers.

On 2026-10-06 the user accepted, for that rollout only: hosted bytes equal clean seed (156/156), 0 quiz answers, 0 recap markers. Stage C observation 6(b) already flagged that the hosted rule needs relaxing.

### 4.3 Normalization today

Sources: `quizLeakGuard.ts:31-33`, `answerLeakGuard.ts:36-43`, `quizItemAudit.ts:22-28`.

- `fpNorm(s) = looseNorm(normalizeForMatch(s))`.
- `normalizeForMatch` unescapes `\n`, `\"` and `\'`, collapses whitespace, and trims.
- `looseNorm` applies NFC, lowercases, replaces each run of non-letter/non-number characters with one space, and trims. Accents are preserved.
- Fingerprints shorter than 12 normalized chars are dropped and longer ones are truncated to 80 (`MIN/MAX_FINGERPRINT_CHARS`).
- A hit is substring inclusion of `fp.text` in the normalized file.

### 4.4 Existing tests

- `src/__tests__/issue180-quiz-leak-guard.test.ts`: synthetic fingerprints; the real seed has 0 answers and 0 markers; hosted target allowlist; a source scan forbidding `.upload`, `.remove`, `.update`, `.insert`, `.upsert`, `.delete`, `.move`, `.copy`, `createSignedUploadUrl`, and `.rpc` in `quizLeakGuard.ts`; a live local-stack scan that skips unless the stack is on 127.0.0.1:54321.
- `issue180-quiz-leak-dictionary.test.ts`.
- `issue179-answer-leak-guard.test.ts`: asserts package.json invokes `check-no-answer-leak.ts` without `--strict`.
- `issue180d-answer-stripping.test.ts`: asserts enforcement is on.

### 4.5 Baseline-with-check pattern to reuse

- `scripts/build-practice-baseline-manifest.ts` writes `curriculum/practice-baseline-manifest.json` and supports `--check`.
- `scripts/generate-token-deprecation-baseline.ts` writes `docs/token-deprecation-baseline/phase1-baseline.json`.

### 4.6 Known leak already in the seed

Observed in the deep-dive plan, #214 item 1. Inference (medium-high confidence) that students can see it: `(hay -> use "se necesita" as a substitute prompt)` appears at:

- `curriculum/lessons/intermediate-week-17/phrases-and-qa.md:179-180`
- `content-source/quizzes/intermediate-week-17.quiz.json:9`
- `content-source/intermediateWeek17.ts`
- storage-seed `intermediate/week-17/lesson-content.json`
- migration `202610050002`

Unknown: whether this text is among the 627 fingerprint hits. It is the concrete case of "masking a leak that was already in the seed".

### 4.7 Quiz attempts integrity

Observed in `supabase/migrations/202610050001_issue180_lesson_quizzes.sql:53-56`: `quiz_attempts.definition_id` references `lesson_quiz_definitions(id) ON DELETE RESTRICT` and carries `definition_version`.

This PR touches no migration. The baseline is keyed by artifact path and fingerprint text, never by quiz item id or index, so later quiz-definition migrations (#214, #215) do not invalidate it by renumbering. Wave 7 migrations must add new definition versions and must never delete or rewrite definitions that existing `quiz_attempts` reference. Carry this constraint into the Wave 7 sub-plan.

### 4.8 Blocking map

Source: deep-dive plan section 4.1 lines 151-164 and Wave 7 line 782.

- D-25 gates the single Wave 7 re-provision pass.
- #214 and #215 list D-25 as their dependency (each needs a new quiz-definition migration plus re-provision).
- #194 (also needs D-23) and #193 (needs its sub-plan) ride the same Wave 7 re-provision.
- #212 (nested Python tooling port, no re-provision) is not gated by D-25.

## 5. The new rule

### 5.1 Definitions

- **Fingerprint set F.** Sources unchanged, computed from the checkout at run time: `collectQuizKeyFingerprints(loadAuthoredQuizEntries)` plus `collectCurriculumAnswerFingerprints`. New quiz answers added in Wave 7 become fingerprints automatically.
- **Artifact set A.** The 78 `<band>/week-NN/lesson-content.json` and the 78 `<band>/week-NN/weekly-review-recap.md`, identified by that relative path. Read from `supabase/storage-seed/lesson-assets` locally, and from the `lesson-assets` bucket in hosted mode.
- **Normalization.** Unchanged `fpNorm` (section 4.3). Strict scan, no dictionary or co-location relaxation.
- **Hit.** The pair (artifact relative path, normalized fingerprint text) where `fpNorm(file)` contains `fp.text`. Deduplicate by that pair. Keep `contentKey` and the list of sources as metadata only.
- **Baseline B.** A committed fixture of hit pairs. Each entry has:
  - `category`: `quiz-answer`, `recap-answer`, `quiz-key-accepted`, `quiz-key-explanation`, or `quiz-key-reference`.
  - `disposition`:
    - `taught-phrase`: reviewed; the evidence is that the text also appears in a curriculum teaching section outside the quiz/answer section of the same lesson.
    - `known-defect`: must cite an issue (for example #214); reported as a WARN line until removed.
    - `unreviewed`.
- **New (leaked) phrase.** Any hit not in B. Hits are path-scoped, so a baseline phrase copied into another lesson, or from content into a recap, is new.

### 5.2 Gate fails on

1. Any new hit.
2. Any baseline entry with disposition `unreviewed`.
3. Non-empty quiz answers > 0 (unchanged, independent of the baseline).
4. Recap answer markers > 0 (unchanged, independent of the baseline).
5. Missing artifacts, or counts != 78.
6. Hosted mode only: any artifact whose sha256 differs from the seed in the same checkout. This codifies the rule the user accepted on 2026-10-06.
7. Local mode only: a stale baseline entry (in B but no longer hit), with a message to regenerate. The baseline can therefore only shrink silently, never grow silently.

### 5.3 Known limitations (to state in the rule note)

- A second copy of a phrase already present in the same artifact cannot be distinguished, because hits are presence-based, not counts.
- An accent-stripped copy of an accented fingerprint is not matched. This is pre-existing behaviour.

### 5.4 Baseline storage decision

| Option | Assessment |
| --- | --- |
| 1. Computed from the seed at check time | Zero maintenance, but every seed change becomes its own baseline. A leak introduced by Wave 7 regeneration, or the existing #214 item-1 text, is masked by construction. **Rejected.** |
| 2. Committed fixture (**recommended**) | Reviewable, and growth requires a reviewed PR. Detail below. |

Option 2 detail:

- Proposed path: `docs/answer-leak-baseline/seed-fingerprint-baseline.json`. It sits outside `src/` and outside `supabase/storage-seed`, so it is never bundled or provisioned; the dist scan would also catch it.
- Generator: `scripts/build-seed-fingerprint-baseline.ts`, mirroring `build-practice-baseline-manifest.ts`. The default writes the file; `--check` verifies the committed file is reproduced.
- Regeneration keeps existing dispositions, drops stale entries, and writes every new entry as `unreviewed`. That fails the gate until a human changes it in a reviewed PR with a stated reason.
- The generator applies the objective `taught-phrase` test (text present in a curriculum teaching section outside the quiz/answer section) only to record evidence. It never sets `taught-phrase` on its own for `quiz-key-explanation` or `quiz-key-reference` entries, which always need explicit review.
- The fixture holds normalized answer text. This is acceptable because the repo is private and the quiz JSON with answers is already committed. Storing hashes instead was considered and rejected because it makes review impossible.
- Initial 627 entries: the PR ships a triage report (counts by category and disposition). Entries that fail the taught-phrase test, and the #214 item-1 text (if it hits), are set to `known-defect` citing the issue, or left `unreviewed` for user decision. The PR must not mark them `taught-phrase` without review.

## 6. Ordered work

Owner is T1 unless stated; standard mode. Dependencies: step 1 before steps 2-3; step 4 depends on step 2; step 5 last.

**Step 0 (read-only).**
- Create a fresh worktree from `origin/main` (e21afa9 or later). Never reuse the detached reference checkout. Do not recurse-delete through any `node_modules` junction.
- Confirm that `quizLeakGuard.ts`, `check-no-answer-leak.ts`, the package.json `verify:build` and `check:answer-leak` scripts, `netlify.toml`, and the four test files match section 4. Confirm there is no `.github/workflows`.
- Compute the current strict seed hit count. If it is not 627, or the files differ materially, return `JOB_BLOCKED` with "Plan stale".
- Check read-only whether #180, #214, and #215 are open.

**Step 1. RED tests first.** New file `src/__tests__/d25-seed-baseline-leak-gate.test.ts`, with temp-dir seed fixtures and synthetic fingerprints.

| ID | Case | Expected |
| --- | --- | --- |
| R1 | Quiz-key accepted/reference text injected into a `lesson-content.json` body field (for example `practice.summary`) | Fails as a new hit |
| R2 | Curriculum quiz answer injected into recap prose without any marker | Fails as a new hit |
| R3 | `(Answer: x)` and `**Answer:** x` markers injected into a recap, using text that IS in the baseline | Still fails via recap markers |
| R4 | Non-empty `quiz[].answer` in `lesson-content.json` | Fails |
| R5 | A baseline phrase (for example the "buenas noches" fingerprint) at its baselined path, including case, punctuation, and spacing variants | Passes |
| R6 | The same baseline phrase placed in a different artifact (other week, or recap instead of content) | Fails |
| R7 | Baseline entry with disposition `unreviewed`; entry with `known-defect` | `unreviewed` fails; `known-defect` passes with a WARN line naming the issue |
| R8 | Stale baseline entry | Local mode fails with the regenerate message |
| R9 | Masking guard: the generator run over a seed with an injected leak | Marks that entry `unreviewed`, so the gate still fails |
| R10 | Hosted evaluator, a pure function over a fetched-files map (no network): hash differs from seed; extra hit only in hosted; hosted equal to seed with only baselined hits; missing object | Hash differs: fail. Extra hosted-only hit: fail. Equal with only baselined hits: pass. Missing object: fail |
| R11 | Real repository: the current seed | Passes with 0 new hits and 0 unreviewed entries; `build-seed-fingerprint-baseline.ts --check` reproduces the committed file |

Confirm R1-R10 fail before the implementation (RED), then pass.

**Step 2. Implement in `quizLeakGuard.ts`.** Seed hit computation, baseline load/compare, a pure hosted evaluator, and sha256 comparison. Refactor `runHostedReadOnlyScan` so fetching is separate from evaluation. Keep the `resolveHostedTarget` allowlist and the no-write source-scan contract unchanged.

**Step 3. Wire `check-no-answer-leak.ts`.**
- Local mode adds the seed fingerprint scan against the baseline, so `verify:build` (Netlify) and `check:answer-leak` both enforce it.
- Hosted mode replaces `fingerprintHits.length > 0` with the new rule and adds the hash check.
- Print counts: total hits, baselined, known-defect, new, stale.

**Step 4. Generator, fixture, and rule note.** Add the generator script, the fixture with triage, and the rule note `docs/evidence/issue-180/seed-baseline-leak-rule.md` (or extend `dist-leak-scan-rule.md`). Scribe writes prose docs if the user wants more than a short rule note.

**Step 5. Validate.** Run the validation in section 8, then the Verifier (read-only), then the optional CODE_REVIEW judge.

## 7. Interfaces, rollout, and read path

Interfaces and data:

- No migration, no schema change, no hosted write.
- New fixture JSON schema: `{ version, generatedFrom: { commit, seedSha256Manifest }, entries: [{ path, text, contentKey, category, sources[], disposition, issue?, reason? }] }`, sorted by path then text.
- CLI exit codes unchanged (0 pass, 1 fail). The `check:answer-leak` and `verify:build` command names are unchanged.

Rollout:

- Local scripts and the Netlify build gate only. No hosted write.
- A hosted read-only run is not required to merge. It is recommended once, after merge and before the Wave 7 re-provision, to confirm hosted bytes still equal the seed and 0 new hits. Production has not been confirmed since Stage C on 2026-10-06; Unknown whether anything changed since. The run needs `SUPABASE_SERVICE_ROLE_KEY` in env, writes nothing, and prints no secret. The same hosted run then becomes the mandatory post-re-provision gate in Wave 7.

Read path decision: hosted `download()` reads through the cache and served stale bytes after writes at Stage B (finding 3; Stage C observation 6c). The Stage B/C clean evidence used freshly signed URLs. Recommendation: hosted mode reads via `createSignedUrl` (a read token, not an object write) and adds `createSignedUrl` handling to the source-scan comment, while still forbidding `createSignedUploadUrl` and all write calls.

## 8. Acceptance and validation

- R1-R11 pass. All existing tests in `issue180-quiz-leak-guard`, `issue180-quiz-leak-dictionary`, `issue179-answer-leak-guard`, and `issue180d-answer-stripping` stay green. The no-write source scan still passes.
- `npm run check:answer-leak` passes on the real seed.
- `npm run verify:build` passes (proves the Netlify deploy gate is not broken).
- `npx tsx scripts/build-seed-fingerprint-baseline.ts --check` passes.
- `tsc` and lint pass as the repo defines them.
- Output shows 627 baselined hits (or the Step 0 count), 0 new, 0 unreviewed, plus any known-defect lines.
- No browser UI, so no Browser Validator pass.
- Browser UI dialog policy and `browser_ui_validation`: not applicable.
- No dev server is needed. If any is started, the user's rule applies verbatim: "during implementation make sure no more than one dev server is running per browser validation at any given time. do not leave orphaned dev servers running indefinitely. we need to clean those up as we progress. this should also help avoid port conflicts. can use more than one dev server but only intentionally as needed." A local Supabase stack used for the optional live test must be stopped afterwards.

## 9. Judge route and PR

Judge route:

- PLAN_DUCK is eligible on this draft before approval (the orchestrator owns it).
- CODE_REVIEW is recommended on the PR diff because it changes a content-safety gate.
- Codex judges use gpt-6-astra at medium effort. The call cap is 2 for this task under `docs/JUDGE-CONTRACT.md`.
- Deterministic test and gate failures always dominate judge output. No judge pass is promised or recorded here; any finding IDs will flow into engineering and verification only if a judge actually runs.

PR: one PR, suggested branch `fix/d25-seed-baseline-leak-gate`. No dedicated D-25 issue exists. Recommended trailers: `Refs #180` (the quiz leak guard origin), `Refs #214`, `Refs #215`, and "Resolves owner decision D-25" in the body. The alternative is a small tracking issue so the PR can say `Closes #<new>`; that is a GitHub write and needs the user's approval. Commit, push, and PR creation need the user's explicit request.

## 10. What this unblocks

The D-25 dependency of the Wave 7 re-provision gate, therefore #214 and #215 directly, and the re-provision step of #194 and #193 (which still need D-23 and their sub-plan respectively). #212 was never gated by D-25. Wave 7 still needs its own sub-plan, owner review of the #215 item set, and separate approval for every hosted write.

## 11. Risks and rollback

| Risk | Mitigation |
| --- | --- |
| Masking a pre-existing seed leak | Committed fixture, disposition field, `unreviewed` fails, path scoping, explanation/reference entries never auto-cleared, explicit `known-defect` entries for #214 |
| Breaking the Netlify deploy gate | The new local check must pass on the current seed before merge (`verify:build` run) |
| Baseline churn in Wave 7 content PRs | Expected. Regeneration diffs are reviewable, removals are safe, additions fail until reviewed |
| Stale hosted reads | Signed-URL read path |

Rollback: revert the PR. It is tooling only, with no hosted or database state involved.

## 12. Assumptions and open items

- Safe assumption: the mirror reflects current main for these files. Step 0 verifies.
- Open decisions (a) through (f) in section 1 await the user.
- Unknown: whether the #214 item-1 text is among the 627 hits (section 4.6).
- Unknown: current production state since 2026-10-06 (section 7).

## 13. Approval gate

The user must explicitly approve this plan, including decisions (a) through (f) or their changes, before T1 is dispatched. Scribe updates this status to approved only after the lead relays that explicit user approval. D-25 option B (section 1) is already approved and does not substitute for approval of the rest of the design.
